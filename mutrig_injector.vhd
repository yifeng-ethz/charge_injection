-- File name: mutrig_injector.vhd 
-- Author: Yifeng Wang (yifenwan@phys.ethz.ch)
-- =======================================
-- Version: 3.0 (Nov 8, 2024) (add system-level verification features; change setting: frequency -> pwm in cycles;
--                             add avmm *read)
-- =======================================
-- Date: Aug 10, 2023 (inher. from charge_inj_pulser which is deprecated)
-- =========
-- Description:	[MuTRiG Injector]
--              Inject the mutrig through TDC or analog injection (requires DAB 2.2+)
--                  -> can be synchronized with run control signals
--                  -> verify the functionality and synchronization of mutrig
--
--              Test scheme:
--                  1) injection synchronized with mutrig frame: 
--                          test the mts->gts mapping (inject_ts - hit_ts) should be constant, which verifis the mapping is correct. 
--                          this also measures the latency between the injection and its been received/latched by mutrig (test the TDC/PLL time offset and ch-by-ch/asic-by-asic variantion) 
--                          this test has been used for debugging the root cause of mutrig reset glitches, triggered by DAB lvds buffer.
--
--                  2) inject with periodic pulse: 
--                          test the generic traffic on fpga. hits' lifetime (hit_ts - rcv_ts) can have variable latency due to mutrig frame buffer.
--                          the latency is expected to be 0-2000 cycles (actually measured to be 200-1000 cycles). 
--                          furthermore, as a pressure test, user can vary the injection frequency to probe the upper limit of the system throughput by measuring the efficiency (ring-buffer-cam and fifo overflows).
--
--                  3) inject with periodic pulse *(with random phase w.r.t the mutrig pll):
--                          measure the fine counter DNL for offline compensation.
--
--                  4) onClick injection
--                          generate one or a few bunches of hits (with multipliticy equals to the number of enabled channels).
--                          allow debugger to capture the processing of the hits step-wise within the data path system. 
--                          this also fully verifies the ts correctness of the hits on a system-level. such injection pulse can be registered
--                          from outside of FPGA to check the presence/alignment of hits offline.
--
--                  5) pseudo-random injection
--                          to simulates the real physics experiment, the injection will be issued randomly based on a local random number generator.
--                          this generates random test stimuli to the daq system, similar to the "formal verification", in which test converage can be derived.
--



-- ================ synthsizer configuration =================== 		
-- altera vhdl_input_version vhdl_2008
-- ============================================================= 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.log2;
use IEEE.math_real.ceil;
use ieee.math_real.floor;


entity mutrig_injector is
generic(
	MIN_PULSE_W     : natural := 5; -- minimal pulse high clock cycles according to MuTRiG TDC has b-lvds with frequency < 40MHz

    -- +------------+
    -- | IP setting |
    -- +------------+
    CLK_FREQUENCY	            : natural := 125000000; -- input clock 
    HEADERINFO_CHANNEL_W        : natural := 4;
	DEBUG			            : natural := 1
);
port (
	-- AVMM <csr>
	avs_csr_writedata		: in  std_logic_vector(31 downto 0);
    avs_csr_readdata        : out std_logic_vector(31 downto 0);
    avs_csr_read            : in  std_logic;
	avs_csr_write			: in  std_logic;
	avs_csr_waitrequest		: out std_logic;
    avs_csr_address         : in  std_logic_vector(3 downto 0);
    

    -- AVST <runctl>
    asi_runctl_data         : in  std_logic_vector(8 downto 0);
    asi_runctl_valid        : in  std_logic;
    asi_runctl_ready        : out std_logic;
    
    -- AVST <headerinfo>
    asi_headerinfo_data     : in  std_logic_vector(41 downto 0);
    asi_headerinfo_valid    : in  std_logic;
    asi_headerinfo_channel  : in  std_logic_vector(HEADERINFO_CHANNEL_W-1 downto 0);
	
	-- CONDUIT <inject>
	coe_inject_pulse		: out	std_logic;
	
	-- clock and reset interface
	i_clk			        : in	std_logic; -- main clock -> csr_hub and pulse logics 
	i_rst			        : in	std_logic
	
);
end entity;

architecture rtl of mutrig_injector is 
	
    -- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ csr \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    constant default_header_delay           : integer := 100;
    constant default_header_interval        : integer := 1; 
    constant default_injection_multiplicity : integer := 1;
    constant default_header_ch              : integer := 0;
    constant default_pulse_interval         : integer := 1000;
    constant default_pulse_high_cycles      : integer := 5; 
    type csr_t is record
        mode                    : std_logic_vector(3 downto 0);
        header_delay            : std_logic_vector(31 downto 0);
        header_interval         : std_logic_vector(31 downto 0);
        injection_multiplicity  : std_logic_vector(31 downto 0);
        header_ch               : std_logic_vector(HEADERINFO_CHANNEL_W-1 downto 0);
        pulse_interval          : std_logic_vector(31 downto 0);
        pulse_high_cycles       : std_logic_vector(7 downto 0);
    end record;
    signal csr                  : csr_t;
	
	
    
    -- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ header_injector \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    constant MIN_PULSE_CYCLES       : integer := 5; -- (0-255)
    type header_injector_t is (IDLE,DELAY,INJECT,LO,RESET);
    signal header_injector          : header_injector_t;
    
    signal header_injector_hcnt             : unsigned(15 downto 0); -- header interval (0-65535)
    signal header_injector_delay            : unsigned(15 downto 0); -- delay after header (0-65535)
    signal header_injector_icnt             : unsigned(7 downto 0); -- pulse high cycles (0-255)
    signal header_injector_pcnt             : unsigned(15 downto 0); -- number of pulses for each injection (0-65535)
    signal header_injector_idle_cnt         : unsigned(7 downto 0); -- pulse seperation (0-255)
    
    signal header_injector_pulse            : std_logic;
    
    
    -- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ periodic_injector \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    type periodic_injector_t is (INJECT,LO,IDLE,RESET);
    signal periodic_injector            : periodic_injector_t;
    
    signal periodic_injector_i_cnt      : unsigned(31 downto 0); -- match: csr.pulse_interval
    signal periodic_injector_j_cnt      : unsigned(7 downto 0); -- match: csr.pulse_high_cycles
    
    signal periodic_injector_pulse      : std_logic;
    
    
begin



    proc_csr_hub : process(i_clk)
    begin
        if (rising_edge(i_clk)) then 
            if (i_rst = '1') then 
                csr.mode            <= (others => '0');
                csr.header_delay    <= std_logic_vector(to_unsigned(default_header_delay,csr.header_delay'length));
                csr.header_interval <= std_logic_vector(to_unsigned(default_header_interval,csr.header_interval'length));
                csr.injection_multiplicity  <= std_logic_vector(to_unsigned(default_injection_multiplicity,csr.injection_multiplicity'length));
                csr.header_ch       <= std_logic_vector(to_unsigned(default_header_ch,csr.header_ch'length));
                csr.pulse_interval  <= std_logic_vector(to_unsigned(default_pulse_interval,csr.pulse_interval'length));
                csr.pulse_high_cycles   <= std_logic_vector(to_unsigned(default_pulse_high_cycles,csr.pulse_high_cycles'length));
                
            else 
                -- default 
                avs_csr_waitrequest     <= '1';
                avs_csr_readdata        <= (others => '0');
                -- ================================== read ==================================
                if (avs_csr_read = '1') then 
                    avs_csr_waitrequest         <= '0';
                    
                    case to_integer(unsigned(avs_csr_address)) is 
                        when 0 => -- general mode setting 
                            avs_csr_readdata(csr.mode'high downto 0)            <= csr.mode; -- mode from 1 to 5
                            --                              0=off; 1=header_sync; 2=periodic; 3=periodic_async; 4=onclick; 5=random
                        -- -------------------- mode 0 --------------------
                        --           reg name               description
                        -- ------------------------------------------------------------------------------------------
                        when 1 => -- header_delay           delay after header in clock cycles
                            avs_csr_readdata(csr.header_delay'high downto 0)    <= csr.header_delay;
                        when 2 => -- header_interval        interval between header in number of headers (0 is invalid)
                            avs_csr_readdata(csr.header_interval'high downto 0) <= csr.header_interval;
                        when 3 => -- header_multiplicity    number of pulses for each injection
                            avs_csr_readdata(csr.injection_multiplicity'high downto 0)  <= csr.injection_multiplicity;
                        when 4 => -- header_ch              input selection of <headerinfo> channel
                            avs_csr_readdata(csr.header_ch'high downto 0)       <= csr.header_ch;
                        -- -------------------- mode 1+ --------------------
                        when 5 => -- pulse_interval         interval between pulses in clock cycles
                            avs_csr_readdata(csr.pulse_interval'high downto 0)  <= csr.pulse_interval;
                        when 6 => -- pulse_high             pulse high duration in clock cycles (TDC=5)
                            avs_csr_readdata(csr.pulse_high_cycles'high downto 0)       <= csr.pulse_high_cycles;
                        when others =>
                            null;
                    end case;
                -- ================================== write ==================================
                elsif (avs_csr_write = '1') then 
                    avs_csr_waitrequest         <= '0';
                    case to_integer(unsigned(avs_csr_address)) is 
                        when 0 =>
                            csr.mode                <= avs_csr_writedata(csr.mode'high downto 0);
                        when 1 =>
                            csr.header_delay        <= avs_csr_writedata(csr.header_delay'high downto 0);
                        when 2 => 
                            csr.header_interval     <= avs_csr_writedata(csr.header_interval'high downto 0);
                        when 3 =>
                            csr.injection_multiplicity <= avs_csr_writedata(csr.injection_multiplicity'high downto 0);
                        when 4 =>
                            csr.header_ch           <= avs_csr_writedata(csr.header_ch'high downto 0);
                        when 5 =>
                            csr.pulse_interval      <= avs_csr_writedata(csr.pulse_interval'high downto 0);
                        when 6 =>
                            csr.pulse_high_cycles   <= avs_csr_writedata(csr.pulse_high_cycles'high downto 0);
                        when others => 
                            null;
                    end case;
                -- ================================== routine ==================================
                else 
            
        
                end if;
            end if;
        end if;
    end process;

    
    
    
    
    proc_header_injector : process (i_clk)
    begin
        if (rising_edge(i_clk)) then 
            if (i_rst = '1') then 
                header_injector             <= RESET;
            else 
                case header_injector is 
                    when IDLE =>
                        -- detection of the header 
                        if (to_integer(unsigned(csr.mode)) = 1) then 
                            if (asi_headerinfo_valid = '1' and asi_headerinfo_channel = csr.header_ch) then 
                                header_injector_hcnt    <= header_injector_hcnt + 1;
                                if (to_integer(header_injector_hcnt) + 1 = to_integer(unsigned(csr.header_interval))) then 
                                    header_injector         <= DELAY;
                                    header_injector_hcnt    <= (others => '0');
                                end if;
                            end if;
                        end if;
                    when DELAY => 
                        -- insert a delay between header seen and pulses
                        header_injector_delay   <= header_injector_delay + 1;
                        if (header_injector_delay = unsigned(csr.header_delay)) then 
                            header_injector         <= INJECT;
                            header_injector_delay   <= (others => '0');
                        end if;
                    when INJECT =>
                        -- pulse multiple times
                        header_injector_icnt     <= header_injector_icnt + 1;
                        if (header_injector_icnt = to_unsigned(0,header_injector_icnt'length)) then 
                            header_injector_pulse       <= '1';
                        elsif (header_injector_icnt = unsigned(csr.pulse_high_cycles)) then 
                            header_injector_pulse       <= '0';
                            header_injector_pcnt    <= header_injector_pcnt + 1;
                            if (to_integer(header_injector_pcnt) + 1 = to_integer(unsigned(csr.injection_multiplicity))) then 
                                -- enough pulse: exit
                                header_injector         <= RESET;
                                header_injector_pcnt    <= (others => '0');
                                header_injector_icnt    <= (others => '0');
                            else
                                -- more pulses: continue
                                header_injector         <= LO;
                                header_injector_icnt    <= (others => '0'); 
                            end if;
                        end if;
                    when LO => 
                        -- intermediate wait state between injections with multi-pulses
                        header_injector_idle_cnt            <= header_injector_idle_cnt + 1;
                        if (header_injector_idle_cnt = to_unsigned(MIN_PULSE_CYCLES,header_injector_idle_cnt'length)) then 
                            header_injector             <= INJECT;
                            header_injector_idle_cnt    <= (others => '0');
                        end if;
                    when RESET =>
                        header_injector             <= IDLE;
                        header_injector_hcnt        <= (others => '0');
                        header_injector_delay       <= (others => '0');
                        header_injector_icnt        <= (others => '0');
                        header_injector_pcnt        <= (others => '0');
                        header_injector_idle_cnt    <= (others => '0');
                        header_injector_pulse       <= '0';
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
    
    
    
    
    
    proc_periodic_injector : process (i_clk)
    begin
        if rising_edge(i_clk) then 
            if (i_rst = '1') then 
                periodic_injector       <= RESET;
            else 
                case periodic_injector is 
                    when INJECT => 
                        periodic_injector_i_cnt     <= periodic_injector_i_cnt + 1;
                        periodic_injector_j_cnt     <= periodic_injector_j_cnt + 1;
                        periodic_injector_pulse     <= '1';
                        if (periodic_injector_j_cnt = unsigned(csr.pulse_high_cycles)) then 
                            periodic_injector_pulse     <= '0';
                            periodic_injector_j_cnt      <= (others => '0');
                            periodic_injector           <= LO;
                        end if;
                    when LO =>
                        periodic_injector_i_cnt      <= periodic_injector_i_cnt + 1;
                        if (periodic_injector_i_cnt > to_unsigned(MIN_PULSE_CYCLES,header_injector_idle_cnt'length)) then 
                            if (periodic_injector_i_cnt >= unsigned(csr.pulse_interval)) then 
                                periodic_injector           <= IDLE;
                            end if;
                        end if;
                    when IDLE => 
                        if (to_integer(unsigned(csr.mode)) = 2 or to_integer(unsigned(csr.mode)) = 3) then 
                            periodic_injector               <= INJECT;
                        end if;
                        periodic_injector_i_cnt         <= (others => '0');
                    when RESET =>
                        periodic_injector               <= IDLE;
                        periodic_injector_i_cnt         <= (others => '0');
                        periodic_injector_j_cnt         <= (others => '0');
                        periodic_injector_pulse         <= '0';
                    when others =>
                        null;
                end case;
            end if;
        end if;
    
    end process;
	
    
    
	proc_pulse_arb : process (all)
    begin
        case to_integer(unsigned(csr.mode)) is 
            when 0 =>
                coe_inject_pulse        <= '0';
            when 1 =>
                coe_inject_pulse        <= header_injector_pulse;
            when 2 =>
                coe_inject_pulse        <= periodic_injector_pulse;
            when others =>
                coe_inject_pulse        <= '0';
        end case;
    end process;
    
    
    
    proc_run_management_agent : process (i_clk)
    begin
        if rising_edge(i_clk) then 
            if (i_rst = '1') then 
            
            else 
                asi_runctl_ready        <= '1';
            end if;
        end if;
    
    
    
    end process;



end architecture;























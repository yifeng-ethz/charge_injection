-- megafunction wizard: %LPM_DIVIDE%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: LPM_DIVIDE 

-- ============================================================
-- File Name: alt_lpm_div.vhd
-- Megafunction Name(s):
-- 			LPM_DIVIDE
--
-- Simulation Library Files(s):
-- 			lpm
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 18.1.0 Build 625 09/12/2018 SJ Standard Edition
-- ************************************************************


--Copyright (C) 2018  Intel Corporation. All rights reserved.
--Your use of Intel Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Intel Program License 
--Subscription Agreement, the Intel Quartus Prime License Agreement,
--the Intel FPGA IP License Agreement, or other applicable license
--agreement, including, without limitation, that your use is for
--the sole purpose of programming logic devices manufactured by
--Intel and sold by Intel or its authorized distributors.  Please
--refer to the applicable agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

ENTITY alt_lpm_div IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		denom		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		remain		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END alt_lpm_div;


ARCHITECTURE SYN OF alt_lpm_div IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (15 DOWNTO 0);



	COMPONENT lpm_divide
	GENERIC (
		lpm_drepresentation		: STRING;
		lpm_hint		: STRING;
		lpm_nrepresentation		: STRING;
		lpm_pipeline		: NATURAL;
		lpm_type		: STRING;
		lpm_widthd		: NATURAL;
		lpm_widthn		: NATURAL
	);
	PORT (
			clock	: IN STD_LOGIC ;
			denom	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			numer	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			quotient	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			remain	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	quotient    <= sub_wire0(31 DOWNTO 0);
	remain    <= sub_wire1(15 DOWNTO 0);

	LPM_DIVIDE_component : LPM_DIVIDE
	GENERIC MAP (
		lpm_drepresentation => "UNSIGNED",
		lpm_hint => "MAXIMIZE_SPEED=6,LPM_REMAINDERPOSITIVE=TRUE",
		lpm_nrepresentation => "UNSIGNED",
		lpm_pipeline => 32,
		lpm_type => "LPM_DIVIDE",
		lpm_widthd => 16,
		lpm_widthn => 32
	)
	PORT MAP (
		clock => clock,
		denom => denom,
		numer => numer,
		quotient => sub_wire0,
		remain => sub_wire1
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Arria V"
-- Retrieval info: PRIVATE: PRIVATE_LPM_REMAINDERPOSITIVE STRING "TRUE"
-- Retrieval info: PRIVATE: PRIVATE_MAXIMIZE_SPEED NUMERIC "6"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
-- Retrieval info: PRIVATE: USING_PIPELINE NUMERIC "1"
-- Retrieval info: PRIVATE: VERSION_NUMBER NUMERIC "2"
-- Retrieval info: PRIVATE: new_diagram STRING "1"
-- Retrieval info: LIBRARY: lpm lpm.lpm_components.all
-- Retrieval info: CONSTANT: LPM_DREPRESENTATION STRING "UNSIGNED"
-- Retrieval info: CONSTANT: LPM_HINT STRING "MAXIMIZE_SPEED=6,LPM_REMAINDERPOSITIVE=TRUE"
-- Retrieval info: CONSTANT: LPM_NREPRESENTATION STRING "UNSIGNED"
-- Retrieval info: CONSTANT: LPM_PIPELINE NUMERIC "32"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_DIVIDE"
-- Retrieval info: CONSTANT: LPM_WIDTHD NUMERIC "16"
-- Retrieval info: CONSTANT: LPM_WIDTHN NUMERIC "32"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
-- Retrieval info: USED_PORT: denom 0 0 16 0 INPUT NODEFVAL "denom[15..0]"
-- Retrieval info: USED_PORT: numer 0 0 32 0 INPUT NODEFVAL "numer[31..0]"
-- Retrieval info: USED_PORT: quotient 0 0 32 0 OUTPUT NODEFVAL "quotient[31..0]"
-- Retrieval info: USED_PORT: remain 0 0 16 0 OUTPUT NODEFVAL "remain[15..0]"
-- Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
-- Retrieval info: CONNECT: @denom 0 0 16 0 denom 0 0 16 0
-- Retrieval info: CONNECT: @numer 0 0 32 0 numer 0 0 32 0
-- Retrieval info: CONNECT: quotient 0 0 32 0 @quotient 0 0 32 0
-- Retrieval info: CONNECT: remain 0 0 16 0 @remain 0 0 16 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL alt_lpm_div.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL alt_lpm_div.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL alt_lpm_div.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL alt_lpm_div.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL alt_lpm_div_inst.vhd TRUE
-- Retrieval info: LIB_FILE: lpm

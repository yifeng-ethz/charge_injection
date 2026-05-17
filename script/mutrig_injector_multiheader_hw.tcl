##################################################################################
# mutrig_injector_multiheader "MuTRiG Timestamp Precision Injector (8-header)" v3.3
# Yifeng Wang 2026.03.26
# Inject pulse into MuTRiG for on-board verification while monitoring all 8 header streams directly.
###################################################################################

################################################
# History
################################################
# ...
# 26.0.0326 - fold v2 multi-header injector into source IP tree
# 26.1.0511 - drop runctl ready output to match rc-network readyless contract
# 26.1.0517 - gate generated pulses to RUNNING and emit exact periodic intervals
# 26.1.2.0517 - constrain mode-3 RUNNING CDC synchronizer

################################################
# request TCL package from ACDS 16.1
################################################
package require -exact qsys 16.1

set VERSION_MAJOR_DEFAULT_CONST 26
set VERSION_MINOR_DEFAULT_CONST 1
set VERSION_PATCH_DEFAULT_CONST 2
set BUILD_DEFAULT_CONST         517
set VERSION_DATE_DEFAULT_CONST  20260517
set VERSION_GIT_DEFAULT_CONST   0x00000000
set VERSION_GIT_HEX_DEFAULT_CONST [format "0x%08X" $VERSION_GIT_DEFAULT_CONST]
set IP_UID_DEFAULT_CONST        0x4D494E4A
set INSTANCE_ID_DEFAULT_CONST   0

set VERSION_STRING_DEFAULT_CONST [format "%d.%d.%d.%04d" \
    $VERSION_MAJOR_DEFAULT_CONST \
    $VERSION_MINOR_DEFAULT_CONST \
    $VERSION_PATCH_DEFAULT_CONST \
    $BUILD_DEFAULT_CONST]

################################################
# module mutrig_injector_multiheader
################################################
set_module_property DESCRIPTION "MuTRiG Timestamp Precision Injector Mu3e IP Core"
set_module_property NAME mutrig_injector_multiheader
set_module_property VERSION $VERSION_STRING_DEFAULT_CONST
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Mu3e Data Plane/Modules"
set_module_property AUTHOR "Yifeng Wang"
set_module_property ICON_PATH ../../firmware_builds/misc/logo/mu3e_logo.png
set_module_property DISPLAY_NAME "MuTRiG Timestamp Precision Injector (8-header)"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate

proc add_html_text {group_name item_name html_text} {
    add_display_item $group_name $item_name TEXT ""
    set_display_item_property $item_name DISPLAY_HINT html
    set_display_item_property $item_name TEXT $html_text
}

################################################
# file sets
################################################
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL mutrig_injector_multiheader
add_fileset_file mutrig_injector_multiheader.vhd VHDL PATH ../rtl/vhdl/mutrig_injector_multiheader.vhd TOP_LEVEL_FILE
add_fileset_file mutrig_injector_multiheader.sdc SDC PATH ../syn/mutrig_injector_multiheader.sdc

################################################
# parameters
################################################
add_parameter HEADERINFO_CHANNEL_W NATURAL 4
set_parameter_property HEADERINFO_CHANNEL_W DISPLAY_NAME "Header Channel Width"
set_parameter_property HEADERINFO_CHANNEL_W TYPE NATURAL
set_parameter_property HEADERINFO_CHANNEL_W UNITS Bits
set_parameter_property HEADERINFO_CHANNEL_W ALLOWED_RANGES 1:8
set_parameter_property HEADERINFO_CHANNEL_W HDL_PARAMETER true
set dscpt \
"<html>
Width of each monitored <headerinfo*> channel field.
</html>"
set_parameter_property HEADERINFO_CHANNEL_W LONG_DESCRIPTION $dscpt
set_parameter_property HEADERINFO_CHANNEL_W DESCRIPTION $dscpt

add_parameter IP_UID NATURAL $IP_UID_DEFAULT_CONST
set_parameter_property IP_UID DISPLAY_NAME "UID"
set_parameter_property IP_UID TYPE NATURAL
set_parameter_property IP_UID UNITS None
set_parameter_property IP_UID ALLOWED_RANGES 0:2147483647
set_parameter_property IP_UID HDL_PARAMETER true
set_parameter_property IP_UID DISPLAY_HINT hexadecimal
set_parameter_property IP_UID DESCRIPTION {Software-visible IP identifier. Default is ASCII "MINJ".}

add_parameter VERSION_MAJOR NATURAL $VERSION_MAJOR_DEFAULT_CONST
set_parameter_property VERSION_MAJOR DISPLAY_NAME "Version Major"
set_parameter_property VERSION_MAJOR TYPE NATURAL
set_parameter_property VERSION_MAJOR UNITS None
set_parameter_property VERSION_MAJOR ALLOWED_RANGES 0:255
set_parameter_property VERSION_MAJOR HDL_PARAMETER true
set_parameter_property VERSION_MAJOR ENABLED false
set_parameter_property VERSION_MAJOR DESCRIPTION {Major packaging year exposed through META page 0 VERSION[31:24].}

add_parameter VERSION_MINOR NATURAL $VERSION_MINOR_DEFAULT_CONST
set_parameter_property VERSION_MINOR DISPLAY_NAME "Version Minor"
set_parameter_property VERSION_MINOR TYPE NATURAL
set_parameter_property VERSION_MINOR UNITS None
set_parameter_property VERSION_MINOR ALLOWED_RANGES 0:255
set_parameter_property VERSION_MINOR HDL_PARAMETER true
set_parameter_property VERSION_MINOR ENABLED false
set_parameter_property VERSION_MINOR DESCRIPTION {Feature revision exposed through META page 0 VERSION[23:16].}

add_parameter VERSION_PATCH NATURAL $VERSION_PATCH_DEFAULT_CONST
set_parameter_property VERSION_PATCH DISPLAY_NAME "Version Patch"
set_parameter_property VERSION_PATCH TYPE NATURAL
set_parameter_property VERSION_PATCH UNITS None
set_parameter_property VERSION_PATCH ALLOWED_RANGES 0:15
set_parameter_property VERSION_PATCH HDL_PARAMETER true
set_parameter_property VERSION_PATCH ENABLED false
set_parameter_property VERSION_PATCH DESCRIPTION {Compatible-fix revision exposed through META page 0 VERSION[15:12].}

add_parameter BUILD NATURAL $BUILD_DEFAULT_CONST
set_parameter_property BUILD DISPLAY_NAME "Build"
set_parameter_property BUILD TYPE NATURAL
set_parameter_property BUILD UNITS None
set_parameter_property BUILD ALLOWED_RANGES 0:4095
set_parameter_property BUILD HDL_PARAMETER true
set_parameter_property BUILD ENABLED false
set_parameter_property BUILD DESCRIPTION {MMDD packaging stamp exposed through META page 0 VERSION[11:0].}

add_parameter VERSION_DATE NATURAL $VERSION_DATE_DEFAULT_CONST
set_parameter_property VERSION_DATE DISPLAY_NAME "Version Date"
set_parameter_property VERSION_DATE TYPE NATURAL
set_parameter_property VERSION_DATE UNITS None
set_parameter_property VERSION_DATE ALLOWED_RANGES 0:2147483647
set_parameter_property VERSION_DATE HDL_PARAMETER true
set_parameter_property VERSION_DATE ENABLED false
set_parameter_property VERSION_DATE DESCRIPTION {YYYYMMDD packaging date exposed through META page 1.}

add_parameter VERSION_GIT NATURAL $VERSION_GIT_DEFAULT_CONST
set_parameter_property VERSION_GIT DISPLAY_NAME "Git Stamp"
set_parameter_property VERSION_GIT TYPE NATURAL
set_parameter_property VERSION_GIT UNITS None
set_parameter_property VERSION_GIT ALLOWED_RANGES 0:2147483647
set_parameter_property VERSION_GIT HDL_PARAMETER true
set_parameter_property VERSION_GIT ENABLED false
set_parameter_property VERSION_GIT DISPLAY_HINT hexadecimal
set_parameter_property VERSION_GIT DESCRIPTION {Truncated packaging git stamp exposed through META page 2.}

add_parameter INSTANCE_ID NATURAL $INSTANCE_ID_DEFAULT_CONST
set_parameter_property INSTANCE_ID DISPLAY_NAME "Instance ID"
set_parameter_property INSTANCE_ID TYPE NATURAL
set_parameter_property INSTANCE_ID UNITS None
set_parameter_property INSTANCE_ID ALLOWED_RANGES 0:2147483647
set_parameter_property INSTANCE_ID HDL_PARAMETER true
set_parameter_property INSTANCE_ID DESCRIPTION {Integration-time instance identifier exposed through META page 3.}

set TAB_CONFIGURATION "Configuration"
set TAB_IDENTITY      "Identity"
set TAB_INTERFACES    "Interfaces"
set TAB_REGMAP        "Register Map"

add_display_item "" $TAB_CONFIGURATION GROUP tab
add_display_item $TAB_CONFIGURATION "Overview" GROUP
add_display_item $TAB_CONFIGURATION "Header Selection" GROUP
add_display_item $TAB_CONFIGURATION "Modes" GROUP
add_html_text "Overview" injector_overview_html {<html><b>Injector scope</b><br/>This is the active MuTRiG injection IP for Phase-5 and later builds. It observes all eight 42-bit header streams and emits one <b>coe_inject_pulse</b> conduit toward the MuTRiG/emulator injection aperture.</html>}
add_html_text "Header Selection" header_select_html {<html><b>Header monitor width</b><br/>HEADERINFO_CHANNEL_W sets the channel-field width on each of the eight headerinfo streams. The CSR word HEADER_CH selects which observed header channel can launch mode-1 header-synchronous pulses.</html>}
add_display_item "Header Selection" HEADERINFO_CHANNEL_W parameter
add_html_text "Modes" mode_html {<html><table border="1" cellpadding="3" width="100%">
<tr><th>Mode</th><th>Name</th><th>Pulse source</th></tr>
<tr><td>0</td><td>Off / one-click return</td><td>Normal idle. Writing mode 4 creates one pulse, then the RTL stores mode 0.</td></tr>
<tr><td>1</td><td>Header synchronous</td><td>Wait for selected header channel, apply HEADER_DELAY, then emit INJECTION_MULTIPLICITY pulses.</td></tr>
<tr><td>2</td><td>Periodic 125 MHz</td><td>Emit pulses from the main clock domain every PULSE_INTERVAL cycles.</td></tr>
<tr><td>3</td><td>Periodic oscillator</td><td>Emit pulses from the oscillator clock domain after scaling interval/high-cycle settings.</td></tr>
<tr><td>4</td><td>One-click pulse</td><td>Write-only command value on MODE. RTL emits one pulse and clears mode to 0.</td></tr>
<tr><td>5</td><td>PRBS random</td><td>Advance the PRBS generator at PRBS_RATE and inject when the configured pattern matches.</td></tr>
</table></html>}

add_display_item "" $TAB_IDENTITY GROUP tab
add_display_item $TAB_IDENTITY "Delivered Profile" GROUP
add_display_item $TAB_IDENTITY "Versioning" GROUP
add_html_text "Delivered Profile" profile_html [format {<html><b>Catalog revision</b><br/>This package is delivered as <b>%s</b>.<br/><br/><b>Build date</b><br/>%d<br/><br/><b>Git stamp</b><br/>%s<br/><br/><b>Runtime visibility</b><br/>Software can identify this CSR window through <b>UID</b> at word <b>0</b> and the <b>META</b> mux at word <b>1</b>.</html>} $VERSION_STRING_DEFAULT_CONST $VERSION_DATE_DEFAULT_CONST $VERSION_GIT_HEX_DEFAULT_CONST]
add_html_text "Versioning" versioning_html {<html><b>Common identity header</b><br/>Word <b>0</b> is <b>UID</b>.<br/>Word <b>1</b> is <b>META</b>: write 0=VERSION, 1=DATE, 2=GIT, 3=INSTANCE_ID.<br/><br/><b>VERSION encoding</b><br/>VERSION[31:24] = MAJOR, VERSION[23:16] = MINOR, VERSION[15:12] = PATCH, VERSION[11:0] = BUILD.<br/><br/><b>Editability</b><br/><b>IP_UID</b> and <b>INSTANCE_ID</b> remain integration-editable. Version, build, date, and git provenance fields are locked to the packaged image.</html>}
add_display_item "Versioning" IP_UID parameter
add_display_item "Versioning" VERSION_MAJOR parameter
add_display_item "Versioning" VERSION_MINOR parameter
add_display_item "Versioning" VERSION_PATCH parameter
add_display_item "Versioning" BUILD parameter
add_display_item "Versioning" VERSION_DATE parameter
add_display_item "Versioning" VERSION_GIT parameter
add_display_item "Versioning" INSTANCE_ID parameter

add_display_item "" $TAB_INTERFACES GROUP tab
add_display_item $TAB_INTERFACES "Clock / Reset" GROUP
add_display_item $TAB_INTERFACES "Streams" GROUP
add_display_item $TAB_INTERFACES "Control And Conduit" GROUP
add_html_text "Clock / Reset" clock_html {<html><b>clock_interface</b><br/>Main CSR, run-control, header monitor, header-synchronous, periodic, and PRBS logic clock.<br/><br/><b>osc_clock_interface</b><br/>Independent oscillator domain for mode 3 periodic injection.<br/><br/><b>reset_interface</b><br/>Synchronous reset associated with clock_interface; internally synchronized into the oscillator domain.</html>}
add_html_text "Streams" streams_html {<html><b>runctl</b><br/>9-bit Avalon-ST run-control sink. The current RTL accepts the stream and holds ready high after reset.<br/><br/><b>headerinfo0..headerinfo7</b><br/>Eight 42-bit Avalon-ST header monitor inputs. Each has valid and channel sideband. Header matching ORs all valid streams against HEADER_CH.</html>}
add_html_text "Control And Conduit" control_html {<html><b>csr</b><br/>16-word Avalon-MM slave, word addressed, 32-bit data, 4-bit address.<br/><br/><b>inject</b><br/>Conduit source carrying <b>coe_inject_pulse</b>. This replaces the deprecated analog pulser path in active systems.</html>}

add_display_item "" $TAB_REGMAP GROUP tab
add_display_item $TAB_REGMAP "CSR Window" GROUP
add_html_text "CSR Window" csr_html {<html><table border="1" cellpadding="3" width="100%">
<tr><th>Word</th><th>Byte</th><th>Name</th><th>Access</th><th>Reset</th><th>Description</th></tr>
<tr><td>0x0</td><td>0x00</td><td>UID</td><td>RO</td><td>0x4D494E4A</td><td>Software-visible IP identifier. Default is ASCII <b>MINJ</b>.</td></tr>
<tr><td>0x1</td><td>0x04</td><td>META</td><td>RW/RO</td><td>VERSION page</td><td>Read-multiplexed metadata word. Write <b>0</b>=VERSION, <b>1</b>=DATE, <b>2</b>=GIT, <b>3</b>=INSTANCE_ID. VERSION is packed as MAJOR[31:24], MINOR[23:16], PATCH[15:12], BUILD[11:0].</td></tr>
<tr><td>0x2</td><td>0x08</td><td>MODE</td><td>RW</td><td>0</td><td>Bits 3:0 select injection mode. Write value 4 emits one pulse and stores 0. Write value 5 also reseeds PRBS state.</td></tr>
<tr><td>0x3</td><td>0x0C</td><td>HEADER_DELAY</td><td>RW</td><td>100</td><td>Main-clock cycles from selected header match to first header-synchronous pulse.</td></tr>
<tr><td>0x4</td><td>0x10</td><td>HEADER_INTERVAL</td><td>RW</td><td>1</td><td>Number of selected header matches between mode-1 injection bursts.</td></tr>
<tr><td>0x5</td><td>0x14</td><td>INJECTION_MULTIPLICITY</td><td>RW</td><td>1</td><td>Number of pulses emitted per header or PRBS-triggered burst.</td></tr>
<tr><td>0x6</td><td>0x18</td><td>HEADER_CH</td><td>RW</td><td>0</td><td>Selected header channel compared against headerinfo0..7 channel sidebands.</td></tr>
<tr><td>0x7</td><td>0x1C</td><td>PULSE_INTERVAL</td><td>RW</td><td>1000</td><td>Mode-2 main-clock period, and source value for mode-3 oscillator-domain scaled interval.</td></tr>
<tr><td>0x8</td><td>0x20</td><td>PULSE_HIGH_CYCLES</td><td>RW</td><td>5</td><td>Pulse high duration, stored in bits 7:0. RTL enforces a minimum low gap between burst pulses.</td></tr>
<tr><td>0x9</td><td>0x24</td><td>PRBS_RATE</td><td>RW</td><td>999</td><td>Number of main-clock cycles between PRBS state advances in mode 5.</td></tr>
<tr><td>0xA</td><td>0x28</td><td>PRBS_PATTERN</td><td>RW</td><td>0x00000001</td><td>Pattern compared against the low PRBS bits selected by PRBS_CTRL.</td></tr>
<tr><td>0xB</td><td>0x2C</td><td>PRBS_SEED</td><td>RW</td><td>0x0000ACE1</td><td>Seed used when entering or reseeding mode 5. All-zero selected bits are sanitized to bit 0 set.</td></tr>
<tr><td>0xC</td><td>0x30</td><td>PRBS_CTRL</td><td>RW</td><td>0x00000004</td><td>Bits 1:0 select PRBS7/15/23/31. Bits 7:2 select match width, clipped to the selected LFSR width.</td></tr>
<tr><td>0xD..0xF</td><td>0x34..0x3C</td><td>RESERVED</td><td>RO</td><td>0</td><td>Decoded reserved words return zero and ignore writes.</td></tr>
</table></html>}

################################################
# connection point clock_interface
################################################
add_interface clock_interface clock end
set_interface_property clock_interface clockRate 0

add_interface_port clock_interface i_clk clk Input 1

################################################
# connection point osc_clock_interface
################################################
add_interface osc_clock_interface clock end
set_interface_property osc_clock_interface clockRate 0

add_interface_port osc_clock_interface i_osc_clk clk Input 1

################################################
# connection point reset_interface
################################################
add_interface reset_interface reset end
set_interface_property reset_interface associatedClock clock_interface
set_interface_property reset_interface synchronousEdges BOTH

add_interface_port reset_interface i_rst reset Input 1

################################################
# connection point csr
################################################
add_interface csr avalon end
set_interface_property csr addressUnits WORDS
set_interface_property csr associatedClock clock_interface
set_interface_property csr associatedReset reset_interface
set_interface_property csr bitsPerSymbol 8
set_interface_property csr readLatency 1
set_interface_property csr readWaitTime 0
set_interface_property csr writeWaitTime 0
set_interface_property csr timingUnits Cycles

add_interface_port csr avs_csr_writedata writedata Input 32
add_interface_port csr avs_csr_write write Input 1
add_interface_port csr avs_csr_waitrequest waitrequest Output 1
add_interface_port csr avs_csr_read read Input 1
add_interface_port csr avs_csr_readdata readdata Output 32
add_interface_port csr avs_csr_address address Input 4

################################################
# connection point runctl
################################################
add_interface runctl avalon_streaming end
set_interface_property runctl associatedClock clock_interface
set_interface_property runctl associatedReset reset_interface
set_interface_property runctl dataBitsPerSymbol 9

add_interface_port runctl asi_runctl_data data Input 9
add_interface_port runctl asi_runctl_valid valid Input 1

################################################
# connection point headerinfo0
################################################
add_interface headerinfo0 avalon_streaming end
set_interface_property headerinfo0 associatedClock clock_interface
set_interface_property headerinfo0 associatedReset reset_interface
set_interface_property headerinfo0 dataBitsPerSymbol 42

add_interface_port headerinfo0 asi_headerinfo0_data data Input 42
add_interface_port headerinfo0 asi_headerinfo0_valid valid Input 1
add_interface_port headerinfo0 asi_headerinfo0_channel channel Input HEADERINFO_CHANNEL_W

################################################
# connection point headerinfo1
################################################
add_interface headerinfo1 avalon_streaming end
set_interface_property headerinfo1 associatedClock clock_interface
set_interface_property headerinfo1 associatedReset reset_interface
set_interface_property headerinfo1 dataBitsPerSymbol 42

add_interface_port headerinfo1 asi_headerinfo1_data data Input 42
add_interface_port headerinfo1 asi_headerinfo1_valid valid Input 1
add_interface_port headerinfo1 asi_headerinfo1_channel channel Input HEADERINFO_CHANNEL_W

################################################
# connection point headerinfo2
################################################
add_interface headerinfo2 avalon_streaming end
set_interface_property headerinfo2 associatedClock clock_interface
set_interface_property headerinfo2 associatedReset reset_interface
set_interface_property headerinfo2 dataBitsPerSymbol 42

add_interface_port headerinfo2 asi_headerinfo2_data data Input 42
add_interface_port headerinfo2 asi_headerinfo2_valid valid Input 1
add_interface_port headerinfo2 asi_headerinfo2_channel channel Input HEADERINFO_CHANNEL_W

################################################
# connection point headerinfo3
################################################
add_interface headerinfo3 avalon_streaming end
set_interface_property headerinfo3 associatedClock clock_interface
set_interface_property headerinfo3 associatedReset reset_interface
set_interface_property headerinfo3 dataBitsPerSymbol 42

add_interface_port headerinfo3 asi_headerinfo3_data data Input 42
add_interface_port headerinfo3 asi_headerinfo3_valid valid Input 1
add_interface_port headerinfo3 asi_headerinfo3_channel channel Input HEADERINFO_CHANNEL_W

################################################
# connection point headerinfo4
################################################
add_interface headerinfo4 avalon_streaming end
set_interface_property headerinfo4 associatedClock clock_interface
set_interface_property headerinfo4 associatedReset reset_interface
set_interface_property headerinfo4 dataBitsPerSymbol 42

add_interface_port headerinfo4 asi_headerinfo4_data data Input 42
add_interface_port headerinfo4 asi_headerinfo4_valid valid Input 1
add_interface_port headerinfo4 asi_headerinfo4_channel channel Input HEADERINFO_CHANNEL_W

################################################
# connection point headerinfo5
################################################
add_interface headerinfo5 avalon_streaming end
set_interface_property headerinfo5 associatedClock clock_interface
set_interface_property headerinfo5 associatedReset reset_interface
set_interface_property headerinfo5 dataBitsPerSymbol 42

add_interface_port headerinfo5 asi_headerinfo5_data data Input 42
add_interface_port headerinfo5 asi_headerinfo5_valid valid Input 1
add_interface_port headerinfo5 asi_headerinfo5_channel channel Input HEADERINFO_CHANNEL_W

################################################
# connection point headerinfo6
################################################
add_interface headerinfo6 avalon_streaming end
set_interface_property headerinfo6 associatedClock clock_interface
set_interface_property headerinfo6 associatedReset reset_interface
set_interface_property headerinfo6 dataBitsPerSymbol 42

add_interface_port headerinfo6 asi_headerinfo6_data data Input 42
add_interface_port headerinfo6 asi_headerinfo6_valid valid Input 1
add_interface_port headerinfo6 asi_headerinfo6_channel channel Input HEADERINFO_CHANNEL_W

################################################
# connection point headerinfo7
################################################
add_interface headerinfo7 avalon_streaming end
set_interface_property headerinfo7 associatedClock clock_interface
set_interface_property headerinfo7 associatedReset reset_interface
set_interface_property headerinfo7 dataBitsPerSymbol 42

add_interface_port headerinfo7 asi_headerinfo7_data data Input 42
add_interface_port headerinfo7 asi_headerinfo7_valid valid Input 1
add_interface_port headerinfo7 asi_headerinfo7_channel channel Input HEADERINFO_CHANNEL_W

################################################
# connection point inject
################################################
add_interface inject conduit start
set_interface_property inject associatedClock clock_interface
set_interface_property inject associatedReset reset_interface

add_interface_port inject coe_inject_pulse pulse Output 1

proc elaborate {} {
    set max_channel [expr {(1 << [get_parameter_value HEADERINFO_CHANNEL_W]) - 1}]
    for {set idx 0} {$idx <= 7} {incr idx} {
        set_interface_property headerinfo$idx maxChannel $max_channel
    }
}

proc validate {} {
    if {[get_parameter_value HEADERINFO_CHANNEL_W] < 1} {
        send_message error "HEADERINFO_CHANNEL_W must be at least 1."
    }
    if {[get_parameter_value IP_UID] < 0 || [get_parameter_value IP_UID] > 2147483647} {
        send_message error "IP_UID must stay in the signed 31-bit Platform Designer integer range."
    }
    if {[get_parameter_value VERSION_MAJOR] < 0 || [get_parameter_value VERSION_MAJOR] > 255} {
        send_message error "VERSION_MAJOR must stay in range 0..255."
    }
    if {[get_parameter_value VERSION_MINOR] < 0 || [get_parameter_value VERSION_MINOR] > 255} {
        send_message error "VERSION_MINOR must stay in range 0..255."
    }
    if {[get_parameter_value VERSION_PATCH] < 0 || [get_parameter_value VERSION_PATCH] > 15} {
        send_message error "VERSION_PATCH must stay in range 0..15."
    }
    if {[get_parameter_value BUILD] < 0 || [get_parameter_value BUILD] > 4095} {
        send_message error "BUILD must stay in range 0..4095."
    }
    if {[get_parameter_value VERSION_DATE] < 0 || [get_parameter_value VERSION_DATE] > 2147483647} {
        send_message error "VERSION_DATE must stay in the signed 31-bit Platform Designer integer range."
    }
    if {[get_parameter_value VERSION_GIT] < 0 || [get_parameter_value VERSION_GIT] > 2147483647} {
        send_message error "VERSION_GIT must stay in the signed 31-bit Platform Designer integer range."
    }
    if {[get_parameter_value INSTANCE_ID] < 0 || [get_parameter_value INSTANCE_ID] > 2147483647} {
        send_message error "INSTANCE_ID must stay in the signed 31-bit Platform Designer integer range."
    }
}

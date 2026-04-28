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

################################################
# request TCL package from ACDS 16.1
################################################
package require -exact qsys 16.1

set VERSION_MAJOR_DEFAULT_CONST 26
set VERSION_MINOR_DEFAULT_CONST 0
set VERSION_PATCH_DEFAULT_CONST 1
set BUILD_DEFAULT_CONST         428
set VERSION_DATE_DEFAULT_CONST  20260428
set VERSION_GIT_DEFAULT_CONST   0x528DBAD5

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
set_module_property ICON_PATH ../firmware_builds/misc/logo/mu3e_logo.png
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
add_fileset_file mutrig_injector_multiheader.vhd VHDL PATH mutrig_injector_multiheader.vhd TOP_LEVEL_FILE
add_fileset_file mutrig_injector_multiheader.sdc SDC PATH mutrig_injector_multiheader.sdc

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
add_html_text "Delivered Profile" profile_html [format {<html><b>Catalog revision</b><br/>This package is delivered as <b>%s</b>.<br/><br/><b>Build date</b><br/>%d<br/><br/><b>Git stamp</b><br/>0x%08X</html>} $VERSION_STRING_DEFAULT_CONST $VERSION_DATE_DEFAULT_CONST $VERSION_GIT_DEFAULT_CONST]
add_html_text "Versioning" versioning_html {<html><b>Version encoding</b><br/>The Platform Designer component version uses YY.MINOR.PATCH.MMDD. This RTL does not expose a software-readable identity header; software must use the system inventory generated from Qsys plus this SVD/package version.</html>}

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
<tr><th>Word</th><th>Name</th><th>Reset</th><th>Description</th></tr>
<tr><td>0x0</td><td>MODE</td><td>0</td><td>Bits 3:0 select injection mode. Write value 4 emits one pulse and stores 0. Write value 5 also reseeds PRBS state.</td></tr>
<tr><td>0x1</td><td>HEADER_DELAY</td><td>100</td><td>Main-clock cycles from selected header match to first header-synchronous pulse.</td></tr>
<tr><td>0x2</td><td>HEADER_INTERVAL</td><td>1</td><td>Number of selected header matches between mode-1 injection bursts.</td></tr>
<tr><td>0x3</td><td>INJECTION_MULTIPLICITY</td><td>1</td><td>Number of pulses emitted per header or PRBS-triggered burst.</td></tr>
<tr><td>0x4</td><td>HEADER_CH</td><td>0</td><td>Selected header channel compared against headerinfo0..7 channel sidebands.</td></tr>
<tr><td>0x5</td><td>PULSE_INTERVAL</td><td>1000</td><td>Mode-2 main-clock period, and source value for mode-3 oscillator-domain scaled interval.</td></tr>
<tr><td>0x6</td><td>PULSE_HIGH_CYCLES</td><td>5</td><td>Pulse high duration, stored in bits 7:0. RTL enforces a minimum low gap between burst pulses.</td></tr>
<tr><td>0x7</td><td>PRBS_RATE</td><td>999</td><td>Number of main-clock cycles between PRBS state advances in mode 5.</td></tr>
<tr><td>0x8</td><td>PRBS_PATTERN</td><td>0x00000001</td><td>Pattern compared against the low PRBS bits selected by PRBS_CTRL.</td></tr>
<tr><td>0x9</td><td>PRBS_SEED</td><td>0x0000ACE1</td><td>Seed used when entering or reseeding mode 5. All-zero selected bits are sanitized to bit 0 set.</td></tr>
<tr><td>0xA</td><td>PRBS_CTRL</td><td>0x00000004</td><td>Bits 1:0 select PRBS7/15/23/31. Bits 7:2 select match width, clipped to the selected LFSR width.</td></tr>
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
set_interface_property csr readWaitTime 1
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
add_interface_port runctl asi_runctl_ready ready Output 1

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
}

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

################################################
# module mutrig_injector_multiheader
################################################
set_module_property DESCRIPTION "Inject pulse into MuTRiG for on-board verification while monitoring all 8 header streams directly."
set_module_property NAME mutrig_injector_multiheader
set_module_property VERSION 26.0.326
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Mu3e Data Plane/Modules"
set_module_property AUTHOR "Yifeng Wang"
set_module_property ICON_PATH ../figures/mu3e_logo.png
set_module_property DISPLAY_NAME "MuTRiG Timestamp Precision Injector (8-header)"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false

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

################################################
# connection point csr
################################################
add_interface csr avalon end
set_interface_property csr addressUnits WORDS
set_interface_property csr associatedClock clock_interface
set_interface_property csr associatedReset reset_interface
set_interface_property csr bitsPerSymbol 8

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

################################################
# connection point clock_interface
################################################
add_interface clock_interface clock end
set_interface_property clock_interface ENABLED true

add_interface_port clock_interface i_clk clk Input 1

################################################
# connection point osc_clock_interface
################################################
add_interface osc_clock_interface clock end
set_interface_property osc_clock_interface ENABLED true

add_interface_port osc_clock_interface i_osc_clk clk Input 1

################################################
# connection point reset_interface
################################################
add_interface reset_interface reset end
set_interface_property reset_interface associatedClock clock_interface
set_interface_property reset_interface synchronousEdges DEASSERT

add_interface_port reset_interface i_rst reset Input 1

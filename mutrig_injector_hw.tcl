##################################################################################
# mutrig_injector "MuTRiG Timestamp Precision Injector" v3.0
# Yifeng Wang 2025.05.05 17:08
# Inject pulse into MuTRiG for on-board verification
###################################################################################

################################################
# History 
################################################
# ...
# 25.0.0505 - use pwr-up default for csr registers
# 25.0.0710 - add onClick injection mode

################################################
# request TCL package from ACDS 16.1
################################################
package require qsys 

################################################ 
# module mutrig_injector
################################################ 
set_module_property DESCRIPTION "Inject pulse into MuTRiG for on-board verification"
set_module_property NAME mutrig_injector
set_module_property VERSION 25.0.0710
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Mu3e Data Plane/Modules"
set_module_property AUTHOR "Yifeng Wang"
set_module_property ICON_PATH ../figures/mu3e_logo.png
set_module_property DISPLAY_NAME "MuTRiG Timestamp Precision Injector"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property ELABORATION_CALLBACK my_elaborate


################################################ 
# file sets
################################################ 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL mutrig_injector
add_fileset_file mutrig_injector.vhd VHDL PATH mutrig_injector.vhd TOP_LEVEL_FILE

# 
# parameters
# 
add_parameter HEADERINFO_CHANNEL_W NATURAL 4

set_parameter_property HEADERINFO_CHANNEL_W DISPLAY_NAME "channel width"
set_parameter_property HEADERINFO_CHANNEL_W TYPE NATURAL
set_parameter_property HEADERINFO_CHANNEL_W UNITS Bits
set_parameter_property HEADERINFO_CHANNEL_W ALLOWED_RANGES 1:8
set_parameter_property HEADERINFO_CHANNEL_W HDL_PARAMETER true
set dscpt \
"<html>
Set the channel width of <headerinfo> interface 
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
# connection point headerinfo
################################################
add_interface headerinfo avalon_streaming end
set_interface_property headerinfo associatedClock clock_interface
set_interface_property headerinfo associatedReset reset_interface
set_interface_property headerinfo dataBitsPerSymbol 42

add_interface_port headerinfo asi_headerinfo_data data Input 42
add_interface_port headerinfo asi_headerinfo_valid valid Input 1
add_interface_port headerinfo asi_headerinfo_channel channel Input HEADERINFO_CHANNEL_W


################################################
# connection point inject
################################################
add_interface inject conduit start
set_interface_property inject associatedClock clock_interface
set_interface_property inject associatedReset reset_interface

add_interface_port inject coe_inject_pulse pulse Output 1



################################################ 
# connection point reset_interface
################################################ 
add_interface reset_interface reset end
set_interface_property reset_interface associatedClock clock_interface
set_interface_property reset_interface synchronousEdges BOTH

add_interface_port reset_interface i_rst reset Input 1

################################################ 
# connection point clock_interface
################################################ 
add_interface clock_interface clock end
set_interface_property clock_interface clockRate 0

add_interface_port clock_interface i_clk clk Input 1


################################################ 
# callbacks
################################################ 
proc my_elaborate {} {
    # set max channel
    set_interface_property headerinfo maxChannel [expr 2**[get_parameter_value HEADERINFO_CHANNEL_W]-1]

}










package require Tcl 8.5

set script_dir [file dirname [info script]]
set helper_file [file normalize [file join $script_dir .. toolkit infra cmsis_svd lib mu3e_cmsis_svd.tcl]]
source $helper_file

namespace eval ::mu3e::cmsis::spec {}

proc ::mu3e::cmsis::spec::build_device {} {
    return [::mu3e::cmsis::svd::device MU3E_MUTRIG_INJECTOR \
        -version 26.0.0 \
        -description "CMSIS-SVD description of the mutrig_injector CSR window. This initial schema exposes the 16-word relative aperture as read-write WORD registers so the frontend can stage explicit injector words while the IP author later refines field names and side effects." \
        -peripherals [list \
            [::mu3e::cmsis::svd::peripheral MUTRIG_INJECTOR_CSR 0x0 \
                -description "Relative 16-word control/status aperture for the MuTRiG injector." \
                -groupName MU3E_DATA_PATH \
                -addressBlockSize 0x40 \
                -registers [::mu3e::cmsis::svd::word_window_registers 16 \
                    -descriptionPrefix "MuTRiG injector CSR word" \
                    -fieldDescriptionPrefix "Raw MuTRiG injector CSR word" \
                    -access read-write]]]]
}

if {[info exists ::argv0] &&
    [file normalize $::argv0] eq [file normalize [info script]]} {
    set out_path [file join $script_dir mutrig_injector.svd]
    if {[llength $::argv] >= 1} {
        set out_path [lindex $::argv 0]
    }
    ::mu3e::cmsis::svd::write_device_file \
        [::mu3e::cmsis::spec::build_device] $out_path
}

package require Tcl 8.5

set script_dir [file dirname [info script]]
set helper_file [file normalize [file join $script_dir .. toolkits infra cmsis_svd lib mu3e_cmsis_svd.tcl]]
source $helper_file

namespace eval ::mu3e::cmsis::spec {}

proc ::mu3e::cmsis::spec::build_device {} {
    set registers [list \
        [::mu3e::cmsis::svd::register CONTROL 0x00 \
            -description {Write-only charge-injection pulser control word. Bit 0 enables the generator. Bits [23:8] program the pulse repetition frequency in kHz. Bits [31:24] program the pulse width in clock cycles. Reads are not implemented by the RTL and should not be issued.} \
            -access write-only \
            -fields [list \
                [::mu3e::cmsis::svd::field enable 0 1 \
                    -description {1 enables periodic pulse generation; 0 disables the output.} \
                    -access write-only] \
                [::mu3e::cmsis::svd::field reserved0 1 7 \
                    -description {Reserved, write zero.} \
                    -access write-only] \
                [::mu3e::cmsis::svd::field pulse_freq_khz 8 16 \
                    -description {Pulse repetition frequency in kHz. Zero selects the compile-time default.} \
                    -access write-only] \
                [::mu3e::cmsis::svd::field pulse_width_cycles 24 8 \
                    -description {Pulse width in clock cycles. Zero selects the compile-time default.} \
                    -access write-only]]]]

    return [::mu3e::cmsis::svd::device MU3E_CHARGE_INJECTION_PULSER \
        -version 4.0.5 \
        -description {CMSIS-SVD description of the charge injection pulser control aperture. BaseAddress is 0 because this file describes the relative CSR aperture of the IP; system integration supplies the live slave base address.} \
        -access read-write \
        -peripherals [list \
            [::mu3e::cmsis::svd::peripheral CHARGE_INJECTION_PULSER_CSR 0x0 \
                -description {Single-word write-only CSR aperture for charge-injection pulse generation.} \
                -groupName MU3E_CHARGE_INJECTION \
                -addressBlockSize 0x4 \
                -registers $registers]]]
}

if {[info exists ::argv0] &&
    [file normalize $::argv0] eq [file normalize [info script]]} {
    set out_path [file join $script_dir charge_injection_pulser.svd]
    if {[llength $::argv] >= 1} {
        set out_path [lindex $::argv 0]
    }
    ::mu3e::cmsis::svd::write_device_file \
        [::mu3e::cmsis::spec::build_device] $out_path
}

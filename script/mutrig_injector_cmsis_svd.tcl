package require Tcl 8.5

set script_dir [file dirname [info script]]
set helper_file [file normalize [file join $script_dir .. .. toolkits infra cmsis_svd lib mu3e_cmsis_svd.tcl]]
source $helper_file

namespace eval ::mu3e::cmsis::spec {}

proc ::mu3e::cmsis::spec::reg {name offset description reset access fields} {
    return [::mu3e::cmsis::svd::register $name $offset \
        -description $description \
        -access $access \
        -resetValue $reset \
        -fields $fields]
}

proc ::mu3e::cmsis::spec::build_device {} {
    set registers [list \
        [::mu3e::cmsis::spec::reg UID 0x00 \
            {Software-visible IP identifier. Default payload is ASCII MINJ.} \
            0x4D494E4A read-only \
            [list [::mu3e::cmsis::svd::field uid 0 32 \
                -description {Compile-time / integration-time IP identifier.} \
                -access read-only]]] \
        [::mu3e::cmsis::spec::reg META 0x04 \
            {Read-multiplexed metadata word. Write 0=VERSION, 1=VERSION_DATE, 2=VERSION_GIT, 3=INSTANCE_ID before reading back.} \
            0x1A0031AD read-write \
            [list \
                [::mu3e::cmsis::svd::field page_select 0 2 \
                    -description {Write selector: 0=VERSION, 1=VERSION_DATE, 2=VERSION_GIT, 3=INSTANCE_ID.} \
                    -access read-write] \
                [::mu3e::cmsis::svd::field meta_payload 0 32 \
                    -description {Read payload for the selected metadata page. VERSION packs MAJOR[31:24], MINOR[23:16], PATCH[15:12], BUILD[11:0].} \
                    -access read-only]]] \
        [::mu3e::cmsis::spec::reg MODE 0x08 \
            {Injection mode selector. Writing value 4 emits a one-click pulse and stores mode 0. Writing value 5 also reseeds PRBS state.} \
            0x00000000 read-write \
            [list [::mu3e::cmsis::svd::field mode 0 4 \
                -description {0=off/one-click return, 1=header synchronous, 2=periodic main clock, 3=periodic oscillator clock, 4=one-click command, 5=PRBS random.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg HEADER_DELAY 0x0C \
            {Main-clock delay from selected header match to first header-synchronous pulse.} \
            0x00000064 read-write \
            [list [::mu3e::cmsis::svd::field cycles 0 32 \
                -description {Header delay in clock_interface cycles.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg HEADER_INTERVAL 0x10 \
            {Number of selected header matches between mode-1 bursts.} \
            0x00000001 read-write \
            [list [::mu3e::cmsis::svd::field matches 0 32 \
                -description {Selected-header match interval.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg INJECTION_MULTIPLICITY 0x14 \
            {Number of pulses in each header-triggered or PRBS-triggered burst.} \
            0x00000001 read-write \
            [list [::mu3e::cmsis::svd::field count 0 32 \
                -description {Pulse count per burst.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg HEADER_CH 0x18 \
            {Selected header channel. The RTL compares this value against all eight headerinfo channel sidebands.} \
            0x00000000 read-write \
            [list [::mu3e::cmsis::svd::field channel 0 8 \
                -description {Selected header channel. Width is set by HEADERINFO_CHANNEL_W in Platform Designer.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg PULSE_INTERVAL 0x1C \
            {Mode-2 interval in main-clock cycles. Mode 3 derives the oscillator-domain interval from this value.} \
            0x000003E8 read-write \
            [list [::mu3e::cmsis::svd::field cycles 0 32 \
                -description {Pulse period before mode-3 clock-domain scaling. Use 1250 for 100 kHz at 125 MHz.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg PULSE_HIGH_CYCLES 0x20 \
            {Pulse high duration. RTL uses bits [7:0] and enforces a minimum low gap between burst pulses.} \
            0x00000005 read-write \
            [list [::mu3e::cmsis::svd::field cycles 0 8 \
                -description {Pulse high duration in cycles.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg PRBS_RATE 0x24 \
            {Number of main-clock cycles between PRBS state advances in mode 5.} \
            0x000003E7 read-write \
            [list [::mu3e::cmsis::svd::field cycles 0 32 \
                -description {PRBS advance interval.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg PRBS_PATTERN 0x28 \
            {Pattern compared against the low PRBS bits selected by PRBS_CTRL.} \
            0x00000001 read-write \
            [list [::mu3e::cmsis::svd::field pattern 0 32 \
                -description {Pattern bits used for PRBS match.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg PRBS_SEED 0x2C \
            {Seed used when entering or reseeding mode 5. All-zero selected bits are sanitized to bit 0 set.} \
            0x0000ACE1 read-write \
            [list [::mu3e::cmsis::svd::field seed 0 32 \
                -description {PRBS seed word.} \
                -access read-write]]] \
        [::mu3e::cmsis::spec::reg PRBS_CTRL 0x30 \
            {PRBS polynomial and match-width selector.} \
            0x00000004 read-write \
            [list \
                [::mu3e::cmsis::svd::field poly_select 0 2 \
                    -description {0=PRBS7, 1=PRBS15, 2=PRBS23, 3=PRBS31.} \
                    -access read-write] \
                [::mu3e::cmsis::svd::field match_width 2 6 \
                    -description {Number of low PRBS bits compared against PRBS_PATTERN, clipped to selected polynomial width. Zero is treated as one.} \
                    -access read-write]]] \
        [::mu3e::cmsis::spec::reg RESERVED13 0x34 \
            {Reserved decoded word. Current RTL returns zero and ignores writes.} \
            0x00000000 read-only \
            [list [::mu3e::cmsis::svd::field value 0 32 \
                -description {Reserved zero readback.} \
                -access read-only]]] \
        [::mu3e::cmsis::spec::reg RESERVED14 0x38 \
            {Reserved decoded word. Current RTL returns zero and ignores writes.} \
            0x00000000 read-only \
            [list [::mu3e::cmsis::svd::field value 0 32 \
                -description {Reserved zero readback.} \
                -access read-only]]] \
        [::mu3e::cmsis::spec::reg RESERVED15 0x3C \
            {Reserved decoded word. Current RTL returns zero and ignores writes.} \
            0x00000000 read-only \
            [list [::mu3e::cmsis::svd::field value 0 32 \
                -description {Reserved zero readback.} \
                -access read-only]]]]

    return [::mu3e::cmsis::svd::device MU3E_MUTRIG_INJECTOR \
        -version 26.0.3.0429 \
        -description {CMSIS-SVD description of the mutrig_injector_multiheader CSR window with the common Mu3e UID/META header. The peripheral base is relative to the Platform Designer instance base.} \
        -peripherals [list \
            [::mu3e::cmsis::svd::peripheral MUTRIG_INJECTOR_CSR 0x0 \
                -description {Relative 16-word control/status aperture for the MuTRiG injector.} \
                -groupName MU3E_DATA_PATH \
                -addressBlockSize 0x40 \
                -registers $registers]]]
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

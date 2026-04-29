package require Tcl 8.5

set script_dir [file dirname [info script]]
set helper_file [file normalize [file join $script_dir .. .. toolkits infra board_bring_up lib board_bring_up_meta.tcl]]
if {![llength [info commands ::board_bring_up::meta::field]]} {
    source $helper_file
}

namespace eval ::board_bring_up::meta::mutrig_injector {
}

proc ::board_bring_up::meta::mutrig_injector::get_contract {} {
    set registers [list \
        [::board_bring_up::meta::register \
            "uid" \
            "Software-visible IP identifier. Default payload is ASCII MINJ." \
            "0x0" \
            [list [::board_bring_up::meta::field "uid" "Compile-time / integration-time overridable IP identifier." {[31:0]} "read-only"]]] \
        [::board_bring_up::meta::register \
            "meta" \
            "Read-multiplexed metadata word. Write 0=VERSION, 1=DATE, 2=GIT, 3=INSTANCE_ID before reading back." \
            "0x4" \
            [list \
                [::board_bring_up::meta::field "version" {MAJOR[31:24], MINOR[23:16], PATCH[15:12], BUILD[11:0] when selector=0.} {[31:0]} "read-write"] \
                [::board_bring_up::meta::field "date" {YYYYMMDD provenance word when selector=1.} {[31:0]} "read-write"] \
                [::board_bring_up::meta::field "git" {Truncated build git hash when selector=2.} {[31:0]} "read-write"] \
                [::board_bring_up::meta::field "instance_id" {Integrator-defined instance identifier when selector=3.} {[31:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "mode" \
            "Injection mode selector. Writing value 4 emits a one-click pulse and stores mode 0." \
            "0x8" \
            [list [::board_bring_up::meta::field "mode" "0=off, 1=header-sync, 2=periodic main clock, 3=periodic oscillator, 4=one-click command, 5=PRBS random." {[3:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "header_delay" \
            "Main-clock delay from selected header match to first header-synchronous pulse." \
            "0xc" \
            [list [::board_bring_up::meta::field "cycles" "Header delay in clock_interface cycles." {[31:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "header_interval" \
            "Number of selected header matches between mode-1 bursts." \
            "0x10" \
            [list [::board_bring_up::meta::field "matches" "Selected-header match interval." {[31:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "injection_multiplicity" \
            "Number of pulses emitted per header-triggered or PRBS-triggered burst." \
            "0x14" \
            [list [::board_bring_up::meta::field "count" "Pulse count per burst." {[31:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "header_ch" \
            "Selected header channel compared against headerinfo0..7 channel sidebands." \
            "0x18" \
            [list [::board_bring_up::meta::field "channel" "Selected header channel; width is HEADERINFO_CHANNEL_W in Platform Designer." {[7:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "pulse_interval" \
            "Mode-2 interval in main-clock cycles. Use 1250 for 100 kHz at 125 MHz." \
            "0x1c" \
            [list [::board_bring_up::meta::field "cycles" "Pulse period before mode-3 clock-domain scaling." {[31:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "pulse_high_cycles" \
            {Pulse high duration. RTL uses bits [7:0].} \
            "0x20" \
            [list [::board_bring_up::meta::field "cycles" "Pulse high duration in clock_interface cycles." {[7:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "prbs_rate" \
            "Number of main-clock cycles between PRBS state advances in mode 5." \
            "0x24" \
            [list [::board_bring_up::meta::field "cycles" "PRBS advance interval." {[31:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "prbs_pattern" \
            "Pattern compared against the low PRBS bits selected by PRBS_CTRL." \
            "0x28" \
            [list [::board_bring_up::meta::field "pattern" "PRBS match pattern." {[31:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "prbs_seed" \
            "Seed used when entering or reseeding mode 5." \
            "0x2c" \
            [list [::board_bring_up::meta::field "seed" "PRBS seed word." {[31:0]} "read-write"]]] \
        [::board_bring_up::meta::register \
            "prbs_ctrl" \
            "PRBS polynomial and match-width selector." \
            "0x30" \
            [list \
                [::board_bring_up::meta::field "poly_select" "0=PRBS7, 1=PRBS15, 2=PRBS23, 3=PRBS31." {[1:0]} "read-write"] \
                [::board_bring_up::meta::field "match_width" "Number of low PRBS bits compared against PRBS_PATTERN." {[7:2]} "read-write"]]]]

    return [::board_bring_up::meta::contract $registers]
}

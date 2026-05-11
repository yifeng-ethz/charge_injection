# BUG_HISTORY.md - charge_injection history ledger

Class legend:
- `R` = RTL / DUT bug
- `H` = harness / testcase / reporting bug

Severity legend:
- `non-datapath-refactor` = observability, reporting, contract refactor with no direct datapath effect

Encounterability legend:
- `directed-only` = requires targeted audit, formal/probe flow, or another non-operational stimulus

## Index

| bug_id | class | severity | encounterability | status | first seen | commit | summary |
|---|---|---|---|---|---|---|---|
| [BUG-001-R](#bug-001-r-runctl-sinks-still-declared-asi-runctl-ready-against-the-rc-network-readyless-contract) | R | non-datapath-refactor | `directed-only (Qsys auto-inserts timing_adapter on rc fan-out)` | fixed | FEB v3 integration audit `tb_int_run_emulator_directed` | this commit | The `runctl` sink in both `mutrig_injector` (legacy) and `mutrig_injector_multiheader` still declared `asi_runctl_ready` so Qsys auto-inserted `altera_avalon_st_timing_adapter` on the rc fan-out, carrying the B002 ready-default hazard on silicon. |

## 2026-05-11

### BUG-001-R: runctl sinks still declared asi_runctl_ready against the rc-network readyless contract

- First seen:
  - FEB v3 integration audit during the rc-readyless rollout
  - Hub `runctl_mgmt_host._hw.tcl` advertises `USE_READY=0` for the broadcast `runctl` source; every sink that still declared `asi_*_ready` caused Qsys to silently auto-insert `altera_avalon_st_timing_adapter` on the rc fan-out
  - The timing_adapter is the structural carrier of the B002 ready-default hazard already documented for the FEB SC plane
- Symptom:
  - Both `mutrig_injector` (legacy) and `mutrig_injector_multiheader` still exposed `asi_runctl_ready` on the entity boundary even though the hub source has no ready signal
  - Qsys-generated `feb_system_v3.vhd` wired the injector instances through an adapter even though the local FSM was driving the ready as a constant `'1'`
- Root cause:
  - The Avalon-ST sink interface contract is "readyless" only when both ends declare `USE_READY=0`. The injector RTL was still on the legacy backpressured-rc form. The `proc_run_management_agent` / `run_management_agent` processes only registered a constant `'1'` ready and had no other observable effect on the datapath.
- Fix status:
  - state:
    - fixed
  - mechanism:
    - Removed the `asi_runctl_ready` entity port from `legacy/mutrig_injector.vhd` and `rtl/vhdl/mutrig_injector_multiheader.vhd`
    - Removed the matching `add_interface_port asi_runctl_ready ready Output 1` line from `legacy/mutrig_injector_hw.tcl` and `script/mutrig_injector_multiheader_hw.tcl`
    - Removed the `proc_run_management_agent` / `run_management_agent` processes that only registered a constant ready
    - Bumped versions: `mutrig_injector` 25.0.0710 -> 25.1.0511 and `mutrig_injector_multiheader` 26.0.3.0429 -> 26.1.0.0511
  - after_fix_outcome:
    - FEB v3 Qsys regeneration produced `feb_system_v3.vhd` with the `mutrig_injector_0` instance wired with `asi_runctl_valid` only, no paired ready wire
    - `tb_int` regression passed: `B065`, `B066`, `B067`, `B068`, `B069`, and the directed `RC_EMUL` run all reported `*** TEST PASSED ***` with zero UVM errors and zero UVM fatals
  - potential_hazard:
    - The change is interface-contract only; no internal logic was modified.
- Commit:
  - this commit (`[FIX] HW: Drop runctl ready output (rc-network readyless contract)`)

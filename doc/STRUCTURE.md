# Charge Injection Structure

`charge_injection/` is a standalone IP root. Active source belongs under
`rtl/`, packaging and machine-readable CSR collateral under `script/`, and
synthesis constraints under `syn/`.

The old flat-layout files were moved into `legacy/`:

- `analog_pulser_hw.tcl`
- `charge_inj_pulser.vhd`
- `charge_injection_pulser_cmsis_svd.tcl`
- `charge_injection_pulser.svd`
- `mutrig_injector_hw.tcl`
- `mutrig_injector.vhd`
- `lpm_div/`

Do not wire new Qsys systems to files in `legacy/`. The active MuTRiG injector
package is `script/mutrig_injector_multiheader_hw.tcl`.

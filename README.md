# Charge Injection IP

Standalone source root for Mu3e charge-injection and MuTRiG injector IP.

Active maintained sources use the standalone IP layout:

| Path | Purpose |
|---|---|
| `rtl/vhdl/` | Maintained active RTL. |
| `script/` | Platform Designer `_hw.tcl`, CSR metadata, and SVD generator/output. |
| `syn/` | Synthesis constraints owned by the active package. |
| `doc/` | Local notes for structure and migration decisions. |
| `legacy/` | Retired flat-layout analog pulser and single-header injector sources. |

The active Phase-5 package is `script/mutrig_injector_multiheader_hw.tcl`.

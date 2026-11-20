# Guard Decision (P1-T5)

Timestamp: 2026-11-04T00-56
Command: DD5 rule application over `evidence/regression-testing/fail-before-guard.2026-11-04T00-53.md` (S0), `evidence/other/probe-single-process.2026-11-04T00-54.md` (S1), and `evidence/other/probe-coverage-run.2026-11-04T00-56.md` (S2)
EXIT_CODE: 0
Output Summary:
- GuardForm: b
- Every applicable rule holds in every shape, so DD5 selects the nested in-process `Invoke-Pester` guard (DD2).

## Rule table

| Shape | R1 control passes | R2 environment testcase fails naming only PATH | R3 container profiles and totals | R4 coverage |
|---|---|---|---|---|
| S0 GUARD alone (P1-T2) | holds | holds | not applicable | not applicable |
| S1 Leak order over REPRO with GUARD (P1-T3) | holds | holds | holds: 45 non-GUARD containers equal PL_min and PL_max; total 1051 = 1048 + 3 | not applicable |
| S2 Invoke-PoshQCTest over tests/scripts/dev-tools with coverage (P1-T4) | holds | holds | holds: 37 non-GUARD containers equal P0-T9; total 695 = 692 + 3 | holds: same 265 files, same per-file line totals, no covered count lower |

## Fallback tasks

- P1-T6: not applicable: GuardForm b. GUARD is unchanged since P1-T1.
- P1-T7: not applicable: GuardForm b.

## Note on the LASTEXITCODE testcase

The nested harness itself leaves `$global:LASTEXITCODE` at 0 on this host (P1-T2 probe), and the pre-fix TARGET also leaves 0, so the third GUARD testcase passes on the pre-fix tree. The environment testcase carries the fail-before. The `$global:LASTEXITCODE` restore of DD1 is verified by P2-T4 through `SCRATCH/issue-1066-global-state.ps1`.

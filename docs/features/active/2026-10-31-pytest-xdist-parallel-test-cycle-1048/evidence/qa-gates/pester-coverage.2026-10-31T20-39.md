# Final QA: full Pester suite with coverage (#1048, P10-T7)

Timestamp: 2026-10-31T20-39
Command: in a new pwsh process, `Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root>` (scan folders from `config/poshqc-scan.json`: `scripts`, `tests/powershell`, `tests/scripts`) through SCRATCH/issue-1048-pester-serial.ps1; totals and per-file line coverage read from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` through SCRATCH/issue-1048-pester-summary.ps1
EXIT_CODE: 0
Output Summary:
- JUnit root: tests=13643, failures=0, errors=0, disabled=10, 485 test suites. Wall-clock 1144.3 s, including coverage processing.
- Coverage report total (LINE counter): 21115 covered, 1451 missed (93.57%).
- Per-file line coverage from the coverage XML:

| File | Covered | Missed | Line coverage | P0-T3 baseline | Result |
|---|---|---|---|---|---|
| `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | 144 | 6 | 96.00% | new file | PASS (>= 85%) |
| `scripts/powershell/PoshQC/PoshQC.Shard.psm1` | 138 | 0 | 100.00% | 100% | PASS (>= 85%, not below baseline) |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | 192 | 13 | 93.66% | 93.60% | PASS (>= 85%, not below baseline) |

- First run: the first P10-T7 run (same command) also had 0 failures but reported `PoshQC.Shard.psm1` at 98.55%, below the 100% baseline, with lines 296 and 316 of `ConvertFrom-PoshQCShardWeightJson` unexecuted (the non-object document and non-relative key branches). SW04 gained two malformed documents covering both branches (deviation D6), the toolchain loop restarted from P10-T1, and this record comes from the re-run.
- Pester does not measure branch coverage, so no branch figure applies.

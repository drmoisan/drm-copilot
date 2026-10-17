# Coverage Comparison (P7-T23)

Timestamp: 2026-10-01T17-58

## PowerShell (report-level LINE counter, powershell-coverage.xml from CI; D5)

| Measure | Baseline (P0-T13, run 36890793420) | Post-change (P7-T3, run 36901896617) |
| --- | --- | --- |
| covered | 11236 | 11236 |
| missed | 430 | 430 |
| percent | 96.31 | 96.31 |

Post-change 96.31% is at least 85.00 and equal to the baseline. This plan adds no production `.ps1` or `.psm1` file, so equality is the expected result.

## Bash (kcov)

| Measure | Baseline (P0-T23, run 36890790108) | Post-change (P7-T20, run 36901896617) |
| --- | --- | --- |
| `Bash coverage (lines):` headline | 93.4% | 93.7% |
| `scripts/bash/shell_qc_lib.sh` line-rate | 0.865 | 0.905 |
| `scripts/bash/kcov_trace_env.sh` line-rate | (file absent) | 1.000 |

Post-change headline 93.7% is at least 85.0.

Changed-line records (P7-T20, SP10): `scripts/bash/shell_qc_lib.sh` lines 253, 254, 255, 257, 262, 267 `hits=1`; lines 227, 228, 234 to 241, 256 `NOT-INSTRUMENTED` (comment or blank lines). `scripts/bash/kcov_trace_env.sh` lines 8 and 9 `hits=1`; lines 1 to 7 `NOT-INSTRUMENTED` (shebang and comments). No changed, instrumented bash line has `hits=0`.

Every value is numeric. Bash coverage is line-only; no branch gate applies (kcov and Pester do not measure branch coverage).

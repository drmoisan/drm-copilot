# Regression: Concurrent-Shard Pester Run (loop pass 2) — Issue #1093

Timestamp: 2026-11-07T01-33
Command: sh SCRATCH/issue-1093-parallel.sh (PowerShell 7: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest` over the scan folders of `config/poshqc-scan.json`, which include `tests/scripts`); merged counts from `artifacts/pester/pester-junit.xml`; shard assignment from each `artifacts/pester/parallel/shard-<i>/pester-junit.xml`
EXIT_CODE: 0
Output Summary: 8 shard processes, every shard exit code 0, merge exit code 0, wall clock 342.93 s; merged JUnit 14461 tests, 14451 passed, 0 failed, 10 skipped; the seven touched suites 163 passed, 0 failed; merged coverage entry 90.82%, Logic, State, Metrics, Render and forwarder 100%.

## Shards

| Shard | Exit code | Passed | Failed | Skipped |
|---|---|---|---|---|
| 1 | 0 | 439 | 0 | 0 |
| 2 | 0 | 1781 | 0 | 0 |
| 3 | 0 | 2430 | 0 | 1 |
| 4 | 0 | 1958 | 0 | 7 |
| 5 | 0 | 2040 | 0 | 2 |
| 6 | 0 | 2045 | 0 | 0 |
| 7 | 0 | 2192 | 0 | 0 |
| 8 | 0 | 1566 | 0 | 0 |

## Touched suites

| Container | Shard | Tests | Failures |
|---|---|---|---|
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` | 2 | 35 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1` | 3 | 31 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Metrics.Tests.ps1` | 4 | 20 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.Tests.ps1` | 6 | 14 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1` | 7 | 38 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1` | 8 | 17 | 0 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 8 | 8 | 0 |

The mocked state-write cases and the forwarder's `Join-Path` mock were honored under the PoshQC-hosted shard runs (default trampoline).

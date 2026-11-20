# Regression: Fresh Single-Process Pester Run Over tests/scripts (loop pass 2) — Issue #1093

Timestamp: 2026-11-07T01-27
Command: sh SCRATCH/issue-1093-pester.sh single2 tests/scripts (PowerShell 7: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -ScanFolders tests/scripts`, one fresh process with the default trampoline and coverage); counts from `artifacts/pester/pester-junit.xml` (complete) by sh SCRATCH/issue-1093-report.sh
EXIT_CODE: 0
Output Summary: 14461 tests in 514 containers: 14451 passed, 0 failed, 10 skipped (1286.09 s). The seven touched suites: 163 passed, 0 failed. The three host-transient child-process failures of loop pass 1 (`evidence/regression-testing/pester-single-process.2026-11-07T00-50.md`, exit code 134) did not recur.

## Touched suites (JUnit)

| Container | Tests | Failures | Errors | Skipped |
|---|---|---|---|---|
| `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1` | 17 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1` | 38 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Metrics.Tests.ps1` | 20 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.Tests.ps1` | 14 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1` | 31 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` | 35 | 0 | 0 | 0 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 8 | 0 | 0 | 0 |

Failures outside the touched suites: none.

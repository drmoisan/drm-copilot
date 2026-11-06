# Baseline Pester With Coverage — Issue #1093

Timestamp: 2026-11-06T23-56
Command: sh SCRATCH/issue-1093-pester.sh baseline tests/scripts/dev-tools (PowerShell 7: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -ScanFolders tests/scripts/dev-tools`); counts read from `artifacts/pester/pester-junit.xml` and per-file line coverage from `artifacts/pester/powershell-coverage.xml` by sh SCRATCH/issue-1093-report.sh
EXIT_CODE: 0
Output Summary: 828 tests, 826 passed, 0 failed, 2 skipped across 41 containers; Get-EpicProgressReport.Logic.Tests.ps1 74/74 passed, Get-EpicProgressReport.Tests.ps1 32/32 passed; line coverage scripts/dev-tools/Get-EpicProgressReport.ps1 91.18% (93 of 102), scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 100% (227 of 227).

Environment note: the host had only Pester 5.9.1, outside the range `Invoke-PoshQCTest` requires (6.2.0 to 6.99.99). The repository installer `Install-PoshQCTool` from `scripts/powershell/PoshQC/PoshQC.psd1` installed Pester 6.2.0 for the current user before this run; no tracked file changed.

## Totals (JUnit)

| Total | Passed | Failed | Skipped |
|---|---|---|---|
| 828 | 826 | 0 | 2 |

## Merged suites (per container)

| Container | Tests | Failures | Errors | Skipped |
|---|---|---|---|---|
| `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | 74 | 0 | 0 | 0 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 32 | 0 | 0 | 0 |

## Per-file line coverage (JaCoCo LINE counters)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | 93 | 9 | 91.18% |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | 227 | 0 | 100% |

Uncovered lines of the entry script are the three native wrappers' invocation lines, the state write inside `ShouldProcess`, the clock read, and the entry-point block (skipped when dot-sourced).

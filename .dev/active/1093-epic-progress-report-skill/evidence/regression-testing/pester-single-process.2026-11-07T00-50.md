# Regression: Fresh Single-Process Pester Run Over tests/scripts — Issue #1093

Timestamp: 2026-11-07T00-50
Command: sh SCRATCH/issue-1093-pester.sh single tests/scripts (PowerShell 7: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -ScanFolders tests/scripts`, one fresh process with the default trampoline and coverage); counts from `artifacts/pester/pester-junit.xml` (complete, not truncated) by sh SCRATCH/issue-1093-report.sh
EXIT_CODE: 3
Output Summary: 14459 tests in 514 containers: 14446 passed, 3 failed, 10 skipped (1274.76 s). The seven touched suites: 161 passed, 0 failed. The 3 failures are outside the touched suites, are host-environment crashes of a child PowerShell process (exit code 134), and pass when re-run both on the branch and at the merge base.

## Touched suites (JUnit)

| Container | Tests | Failures | Errors | Skipped |
|---|---|---|---|---|
| `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1` | 17 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1` | 38 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Metrics.Tests.ps1` | 20 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.Tests.ps1` | 14 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1` | 31 | 0 | 0 | 0 |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` | 33 | 0 | 0 | 0 |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | 8 | 0 | 0 | 0 |

## Failures outside the touched suites

| Test | Suite | Observed | Classification |
|---|---|---|---|
| `exits 2 in a separate process when the stdin envelope lacks a PR reference` | `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1` | `Expected 2, but got 134.` | host-transient; passes on re-run at branch and merge base |
| `exits 2 in a separate process when the stdin envelope lacks a spec-path` | `tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1` | `Expected 2, but got 134.` | host-transient; passes on re-run at branch and merge base |
| `exits 2 in a separate process when the stdin envelope lacks a research-path` | `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` | `Expected 2, but got 134.` | host-transient; passes on re-run at branch and merge base |

Exit code 134 is an abort of the child PowerShell process. During this session the host's PowerShell startup profile cache (the non-interactive startup profile under the user's PowerShell cache directory) was observed corrupted once, which made every new PowerShell process abort with exit code 134 (`System.IO.FileLoadException: The given assembly name was invalid`); the cache was moved aside and PowerShell started normally again. The three failing cases each start a separate PowerShell process, and none of the three suites or the hooks they test is changed by this branch.

Comparison runs (plain Pester 6 run of the three suites in one process, coverage off):

| Checkout | Command | Passed | Failed |
|---|---|---|---|
| branch (item worktree) | sh SCRATCH/issue-1093-quick.sh <three suites> | 91 | 0 |
| merge base of `origin/main` and `HEAD` (extracted with `git archive` into SCRATCH/mb) | sh SCRATCH/issue-1093-quick-mb.sh <three suites> | 91 | 0 |

Per-suite in both checkouts: `validate-pr-author-output.Tests.ps1` 13 passed; `validate-prd-feature-output.Coverage.Tests.ps1` 12 passed; `validate-task-researcher-output.Coverage.Tests.ps1` 66 passed.

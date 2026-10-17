# Pester Re-run Over tests/scripts (#964, review finding CR-4)

Timestamp: 2026-10-17T03-12
Command: sh SCRATCH/issue-964-pwsh.sh 'Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders "tests/scripts" *>&1 | Select-Object -Last 40; Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm' (one fresh single-process run, branch-current self-hosted PoshQC module); counts read with poetry run python SCRATCH/issue-964-junit-read.py artifacts/pester/pester-junit.xml artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Supersedes: the Pester bullet of `evidence/qa-gates/toolchain-rerun.2026-10-17T02-28.md` ("Pester over `tests` in one fresh process: Passed=11046 Failed=0 Skipped=10 Total=11056"). That figure has no on-disk JUnit source and its scope (`tests`) differs from the plan's (`tests/scripts`); the earlier file is not edited.
Output Summary:
- Run window: 2026-10-17T03-12 to 2026-10-17T03-29 UTC (start and end stamps printed by the run itself). Scope: `tests/scripts`.
- Source of counts: `artifacts/pester/pester-junit.xml`, written 2026-10-17T03-29 UTC by this run. Root attributes: tests=11057 failures=0 errors=0 disabled=10 time=880.382. Passed = 11057 - 0 - 0 - 10 = 11047.
- Console summary of the same run agrees: "Tests Passed: 11047, Failed: 0, Skipped: 10, NotRun: 0".
- Line coverage from `artifacts/pester/powershell-coverage.xml` (written by this run): total 17411/18877 = 92.23%.
- Changed hooks: `.claude/hooks/validate-executor-output.ps1` 168/168 = 100.00%; `.claude/hooks/premortem-section.ps1` 45/45 = 100.00%; `.claude/hooks/validate-planner-output.ps1` 206/207 = 99.52%; `.claude/hooks/validate-task-researcher-output.ps1` 107/109 = 98.17%.
- The run includes the review-fix changes to `validate-executor-output.ps1` and two new `It` blocks in `validate-executor-output.Preflight.Tests.ps1` (11055 earlier JUnit total + 2 = 11057).
- `Invoke-PoshQCTest` exits 0 on failing tests only when Pester's exit is not enabled, so the pass result is taken from the JUnit `failures` and `errors` attributes, not from the exit code.

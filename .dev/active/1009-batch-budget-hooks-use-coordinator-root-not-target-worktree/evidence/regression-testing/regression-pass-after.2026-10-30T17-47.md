# Regression Pass-After (issue #1009)

Timestamp: 2026-10-30T17-47
Command: sh SCRATCH/issue-1009-pester.sh issue-1009-hook-suites.txt (Invoke-PoshQCTest over the three `*.TargetWorktree.Tests.ps1` suites), then SCRATCH/issue-1009-report.ps1 -NamePattern for the R rows; counts from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: JUnit total=61 passed=61 failed=0 skipped=0. All twelve R1, R2, and R3 rows that failed in `regression-fail-before.2026-10-30T17-16.md` now pass.

| Suite | Total | Passed | R1 | R2 | R3 |
|---|---|---|---|---|---|
| claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1 | 20 | 20 | passed | passed | passed |
| claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1 | 21 | 21 | passed | passed | passed |
| codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1 (Python hook) | 10 | 10 | passed | passed | passed |
| codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1 (PowerShell hook) | 10 | 10 | passed | passed | passed |

Test-side correction recorded for audit: after the fail-before run, the R rows' `$PSDefaultParameterValues` entry was changed from the invoker scriptblock itself to a scriptblock that returns the invoker, because PowerShell evaluates a scriptblock default value and binds its result. Before the fix the hook functions had no `WorktreeListInvoker` parameter, so the default was never evaluated; the fail-before failures were the behavioral denials recorded there, and the correction does not change that outcome.

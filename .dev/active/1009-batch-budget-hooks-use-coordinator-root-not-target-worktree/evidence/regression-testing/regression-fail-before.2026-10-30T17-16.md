# Regression Fail-Before (issue #1009)

Timestamp: 2026-10-30T17-16
Command: sh SCRATCH/issue-1009-pester.sh issue-1009-hook-suites.txt (Invoke-PoshQCTest over the three new `*.TargetWorktree.Tests.ps1` suites; counts from artifacts/pester/pester-junit.xml)
EXIT_CODE: 12
ExpectedExitCode: 12
Output Summary: JUnit total=12 passed=0 failed=12 skipped=0. Every R1, R2, and R3 row fails on its behavioral assertion (a direct-mode denial); no row fails by parse or parameter-binding error. The `WorktreeListInvoker` default supplied through `$PSDefaultParameterValues` is ignored by the pre-fix hook functions, as designed.

| Suite / row | Result | Assertion message (abridged) |
|---|---|---|
| claude-hooks/enforce-python-batch-budget.TargetWorktree: R1 item worktree checkpoint large leaves the item uncapped | failed | expected no denial; got `PYTHON_LARGE_PATH_REQUIRED` for `/repo/.claude/worktrees/item/src/d.py` (already counted the three item paths) |
| claude-hooks/enforce-python-batch-budget.TargetWorktree: R2 two worktrees fill independent counters | failed | expected 'allow'; got `PYTHON_LARGE_PATH_REQUIRED` (already counted `/repo/src/a.py, b.py, c.py`; requested the item path) |
| claude-hooks/enforce-python-batch-budget.TargetWorktree: R3 root-level artifacts scratch is not counted | failed | expected 'allow'; got `PYTHON_LARGE_PATH_REQUIRED` for `artifacts/scratch/issue-1009-x.py` |
| claude-hooks/enforce-powershell-batch-budget.TargetWorktree: R1 | failed | expected no denial; got `POWERSHELL_LARGE_PATH_REQUIRED` for the fourth item path |
| claude-hooks/enforce-powershell-batch-budget.TargetWorktree: R2 | failed | expected 'allow'; got `POWERSHELL_LARGE_PATH_REQUIRED` for the item path |
| claude-hooks/enforce-powershell-batch-budget.TargetWorktree: R3 | failed | expected 'allow'; got `POWERSHELL_LARGE_PATH_REQUIRED` for `artifacts/scratch/issue-1009-x.ps1` |
| codex-hooks/codex-batch-budget.TargetWorktree: the Python hook R1 | failed | expected no denial; got `PYTHON_LARGE_PATH_REQUIRED` for the fourth item path |
| codex-hooks/codex-batch-budget.TargetWorktree: the Python hook R2 | failed | expected 'allow'; got `PYTHON_LARGE_PATH_REQUIRED` for the item path |
| codex-hooks/codex-batch-budget.TargetWorktree: the Python hook R3 | failed | expected 'allow'; got `PYTHON_LARGE_PATH_REQUIRED` for `artifacts/scratch/issue-1009-x.py` |
| codex-hooks/codex-batch-budget.TargetWorktree: the PowerShell hook R1 | failed | expected no denial; got `POWERSHELL_LARGE_PATH_REQUIRED` for the fourth item path |
| codex-hooks/codex-batch-budget.TargetWorktree: the PowerShell hook R2 | failed | expected 'allow'; got `POWERSHELL_LARGE_PATH_REQUIRED` for the item path |
| codex-hooks/codex-batch-budget.TargetWorktree: the PowerShell hook R3 | failed | expected 'allow'; got `POWERSHELL_LARGE_PATH_REQUIRED` for `artifacts/scratch/issue-1009-x.ps1` |

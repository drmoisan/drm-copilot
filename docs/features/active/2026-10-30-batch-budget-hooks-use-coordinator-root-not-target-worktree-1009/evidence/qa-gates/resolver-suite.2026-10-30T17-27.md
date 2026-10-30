# Resolver Module Suite (issue #1009)

Timestamp: 2026-10-30T17-27
Command: sh SCRATCH/issue-1009-pester.sh issue-1009-module-suite.txt issue-1009-cov-hooks.txt (Invoke-PoshQCTest over tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1 with coverage; counts from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- JUnit: total=83 passed=83 failed=0 skipped=0
- Passed tests driven by the four shared row lists: 74 (Get-HookTargetWorktreeHelperRows 24 across the four helper Describe blocks, Get-HookTargetWorktreePorcelainRows 7, Get-HookTargetWorktreeResolverRows 18, Get-HookTargetWorktreeIdentityRows 25)
- Module-only rows passed: 9 (implementation guard 1, reason-code accessor equality 1, AST and session-id rows 7)
- Line coverage `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`: 151/152 = 99.34% (threshold 85%); the uncovered line is the host-bound default WorktreeListInvoker body.
- CI: this suite runs only in `poshqc / PowerShell QC` (Windows shards).

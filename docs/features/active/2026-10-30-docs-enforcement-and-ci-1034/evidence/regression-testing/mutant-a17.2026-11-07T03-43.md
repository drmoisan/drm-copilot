# Mutant A17 - Issue 1034 Remediation Cycle 2 (P2-T7, N10)

Timestamp: 2026-11-07T03-43
Command: sh SCRATCH/issue-1034-c2-mutant.sh (a copy of .claude/hooks, .claude/lib and enforce-docs-complete-gate.Tests.ps1 under SCRATCH/mutant keeps the repository layout; an unmutated control run comes first, then A17 removes the check in Read-DocsCompleteGateMergeOperand that returns unreadable for a flag outside both tables; the worktree is not modified)
EXIT_CODE: 0
Output Summary: PASS. Control run: 149 tests, 149 passed, 0 failed. Mutant run: 149 tests, 148 passed, 1 failed. The one failing row is 'denies PR_UNRESOLVED with no gh call for gh pr merge 12 --unknown x', so that row discriminates the unknown-flag check. The mutated line count went from 1 to 0, which confirms the mutant was applied.

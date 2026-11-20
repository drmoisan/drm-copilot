# Fail-Before: Claude Target-Worktree Suite (Issue #1010, P2-T2)

Timestamp: 2026-10-30T20-51
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-tw-claude.txt -NoCoverage (Invoke-PoshQCTest from scripts/powershell/PoshQC/PoshQC.psd1 over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1, Run.Exit off; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Run before any Phase 3 fix. JUnit total 25, failed 12, passed 13. T4 (git -c k=v -C <wt> commit) fails: the pre-fix gate reads the session-root checkpoint and denies (expected allow). The launcher exit code is 0 because Run.Exit is disabled; the failure count is read from the JUnit file.

## Failing Rows (JUnit)

- T1 admits a Write into an item worktree whose checkpoint is ready, reading the item checkpoint
- T1 admits a Edit into an item worktree whose checkpoint is ready, reading the item checkpoint
- T2 denies a Write into an item worktree whose checkpoint is absent
- T3 denies a Write into an item worktree whose checkpoint is not ready
- T4 admits git -c k=v -C <wt> commit against a ready item checkpoint, reading the item checkpoint
- T5 reads the item checkpoint for git add with an absolute operand inside the item worktree
- T6 reads the item checkpoint for a git -C selector on a later command segment
- T8 denies operands in two registered worktrees naming TARGET_WORKTREE_AMBIGUOUS and the resolver Source
- T9 denies an absolute Write naming TARGET_WORKTREE_NOT_DERIVABLE when the worktree listing throws, reading no checkpoint
- T10 denies an absolute git -C commit naming TARGET_WORKTREE_NOT_DERIVABLE when the worktree listing names no worktree, reading no checkpoint
- T11 denies a resolver result with no root naming TARGET_WORKTREE_NOT_DERIVABLE
- T12 denies an otherwise ready item checkpoint whose lifecycle_ready is the string false

## Passing Rows (expected before the fix)

- baseline mock interception probe; B1 to B8 (P1-T1 already added the building blocks)
- T7 (outside, relative, none): the pre-fix gate already reads the session-root checkpoint for these targets
- T13: P1-T1 already added the guarded HookTargetWorktree.psm1 import

All four leg rows T1, T4, T5, and T6 fail before the fix, so no fail-before exception dossier is required for this suite.

T4 failure: `Expected strings to be the same, but they were different.` at the `permissionDecision | Should -Be 'allow'` assertion (the pre-fix decision is deny).

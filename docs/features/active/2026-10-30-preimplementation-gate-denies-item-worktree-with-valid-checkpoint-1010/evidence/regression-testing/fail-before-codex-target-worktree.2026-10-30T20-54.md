# Fail-Before: Codex Target-Worktree Suite (Issue #1010, P2-T4)

Timestamp: 2026-10-30T20-53
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-tw-codex.txt -NoCoverage (Invoke-PoshQCTest from scripts/powershell/PoshQC/PoshQC.psd1 over tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1, Run.Exit off; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Run before any Phase 3 fix. JUnit total 29, failed 18, passed 11. C1 (Write leg) and C7 (apply_patch leg) fail: the pre-fix gate reads the parameterless session checkpoint (empty under the mock) and denies (expected allow). The launcher exit code is 0 because Run.Exit is disabled; the failure count is read from the JUnit file.

## Failing Rows (JUnit)

- C1 admits a mapped Write into an item worktree whose checkpoint is ready, reading the item checkpoint
- C1 admits a mapped Edit into an item worktree whose checkpoint is ready, reading the item checkpoint
- C2 denies a mapped Write into an item worktree whose checkpoint is absent
- C3 denies a mapped Write into an item worktree whose checkpoint is not ready
- C4 admits git -c k=v -C <wt> commit against a ready item checkpoint
- C5 reads the item checkpoint for git add with an absolute operand
- C6 reads the item checkpoint for a later-segment git -C selector
- C7 admits an apply_patch whose absolute marker path lies in a ready item worktree, reading the item checkpoint
- C8 denies an apply_patch whose markers lie in two registered worktrees naming TARGET_WORKTREE_AMBIGUOUS
- C9 (outside), C9 (relative), C9 (none): the pre-fix read is parameterless, so no session-root path read is observed
- C10 denies Bash operands in two registered worktrees naming TARGET_WORKTREE_AMBIGUOUS
- C11 denies an absolute Write naming TARGET_WORKTREE_NOT_DERIVABLE when the worktree listing throws, reading no checkpoint
- C12 denies an absolute git -C commit naming TARGET_WORKTREE_NOT_DERIVABLE when the worktree listing names no worktree
- C13 denies a resolver result with no root naming TARGET_WORKTREE_NOT_DERIVABLE
- C14 denies an otherwise ready item checkpoint whose lifecycle_ready is the string false
- C15 Get-CheckpointContent rejects a relative Path

## Passing Rows (expected before the fix)

- baseline mock interception probe; B1 to B9 (P1-T2 already added the building blocks and the reason-code pair)
- C16: P1-T2 already added the guarded hook-target-worktree.ps1 dot-source

All leg rows C1, C4, C5, C6, and C7 fail before the fix, so no fail-before exception dossier is required for this suite.

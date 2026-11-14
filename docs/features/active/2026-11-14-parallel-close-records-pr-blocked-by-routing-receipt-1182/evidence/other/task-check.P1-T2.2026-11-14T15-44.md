# Task Check: P1-T2 (CR-2, expect-fail)

Timestamp: 2026-11-14T15-44
Command: sh SCRATCH/issue-1182-taskcheck.sh (same selection as the P1-T1 task check)
EXIT_CODE: 1
Output Summary:
- Changed file: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1. Debugging only, not a gate.
- Expected failure confirmed: the row "(h) starts no worktree listing for an absolute non-receipt path" fails with "Expected Get-OrchestrationGateWorktreeList to be called 0 times exactly, but was called 1 time". Passed 24, Failed 1.

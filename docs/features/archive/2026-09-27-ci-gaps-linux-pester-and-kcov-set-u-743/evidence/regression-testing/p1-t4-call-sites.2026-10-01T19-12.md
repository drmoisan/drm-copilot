# P1-T4 Call Sites (R1d)

Timestamp: 2026-10-01T19-12
Edit: the four `Test-ParallelDriftFindingPresent` call sites now pass `-WorktreePath $script:SyntheticWorktree`.

Command: grep -c -F -e '-WorktreePath $script:SyntheticWorktree' tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
EXIT_CODE: 0
Output Summary: `4`

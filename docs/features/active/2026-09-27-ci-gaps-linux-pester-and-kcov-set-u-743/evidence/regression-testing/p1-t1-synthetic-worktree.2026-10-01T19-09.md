# P1-T1 Synthetic Worktree Definition (R1a)

Timestamp: 2026-10-01T19-09
Edit: inserted the two R1a lines (comment plus `$script:SyntheticWorktree = if ($IsWindows) { 'C:/worktrees/alpha' } else { '/worktrees/alpha' }`) immediately after the `$script:AlphaPrompt = ...` line in `BeforeAll` of `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`. LF endings preserved (0 CR characters).

Command: grep -c -F -e '$script:SyntheticWorktree = if ($IsWindows)' tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
EXIT_CODE: 0
Output Summary: `1`

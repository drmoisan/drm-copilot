# Drift-Gate Edit Sites (P0-T6)

Timestamp: 2026-10-01T19-03
Command: grep -n -F -e 'C:/worktrees/alpha' tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
EXIT_CODE: 0
Output Summary: six lines, at line numbers 46, 338, 345, 351, 357, 365:
```
46:            '"worktree_path":"C:/worktrees/alpha","blast_radius":{"paths":["scripts/declared/"],"modules":[],' +
338:            @{ Label = 'a blank feature folder'; Worktree = 'C:/worktrees/alpha'; Folder = '' }
345:            Test-ParallelDriftFindingPresent -WorktreePath 'C:/worktrees/alpha' -FeatureFolder 'alpha-501' -EventAt '2026-08-08T21-19' | Should -BeFalse
351:            Test-ParallelDriftFindingPresent -WorktreePath 'C:/worktrees/alpha' -FeatureFolder 'alpha-501' -EventAt '2026-01-01T00-00' | Should -BeFalse
357:            Test-ParallelDriftFindingPresent -WorktreePath 'C:/worktrees/alpha' -FeatureFolder 'alpha-501' -EventAt '2026-08-08T21-19' | Should -BeTrue
365:            Test-ParallelDriftFindingPresent -WorktreePath 'C:/worktrees/alpha' -FeatureFolder 'alpha-501' -EventAt '2026-08-08T21:19:00Z' | Should -BeFalse
```
Acceptance: exactly six lines at 46, 338, 345, 351, 357, 365. Met.

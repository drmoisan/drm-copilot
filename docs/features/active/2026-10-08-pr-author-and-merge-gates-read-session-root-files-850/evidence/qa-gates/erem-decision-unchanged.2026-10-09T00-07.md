# P3-T13 Decision-unchanged proof (AC-38)

Timestamp: 2026-10-09T00-07
Command: sh SCRATCH/run-ps.sh SCRATCH/diff-line-count.ps1  -BaseRef 497cb504ad9a4e5435dc8946333ebc28baea50c4 -File tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1,tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
EXIT_CODE: 0
Output Summary:
  DIFF-COUNT file=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 added=0 removed=0
  DIFF-COUNT file=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 added=0 removed=0
  DIFF-COUNT file=tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 added=0 removed=0
  DIFF-COUNT file=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 added=1 removed=0

Note: The first three files print added=0 removed=0 and the fourth added=1 removed=0; with P3-T12 (SET-REM 232/232) every existing row passed with an unchanged expected decision.

## Full output

```text
DIFF-COUNT file=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 added=0 removed=0
DIFF-COUNT file=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 added=0 removed=0
DIFF-COUNT file=tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 added=0 removed=0
DIFF-COUNT file=tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 added=1 removed=0
```

# Baseline Physical Line Counts

Timestamp: 2026-10-29T10-29
Task: [P0-T3]
Command: wc -l <the twenty files listed below>
EXIT_CODE: 0
Output Summary: twenty files counted after the [P0-T2] merge of origin/main; the largest production file is `WorktreeRunResolution.psm1` at 497 lines.

| File | Lines |
| --- | --- |
| .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 497 |
| .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | 415 |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 455 |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 460 |
| .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 236 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | 452 |
| tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | 152 |
| tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | 345 |
| tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py | 485 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | 485 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 193 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | 192 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | 153 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | 101 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | 428 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 176 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | 206 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | 192 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1 | 92 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | 120 |

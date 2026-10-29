# Physical Line Counts (before and after)

Timestamp: 2026-10-29T11-43
Task: [P6-T10]
Command: wc -l <every file of [P0-T3], every file this plan creates, and WorktreeResolution.Manifest.Tests.ps1 (edited in loop pass 3)>; the Manifest suite's before count from `git show $(git merge-base origin/main HEAD):<path> | wc -l`
EXIT_CODE: 0
Output Summary: no PowerShell or Python file exceeds 500 lines; the largest are enforce-parallel-worktree-removal-gate.ps1 at 494, test_parallel_orchestrator_surface_contracts.py at 495, and enforce-parallel-worktree-removal-gate.Tests.ps1 at 491. Before counts come from line-counts.2026-10-29T10-29.md ([P0-T3]).

| File | Before | After |
| --- | --- | --- |
| .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | 497 | 487 |
| .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 | 415 | 425 |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 455 | 494 |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 460 | 468 |
| .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | 236 | 277 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 | 452 | 455 |
| tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | 152 | 176 |
| tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | 345 | 391 |
| tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py | 485 | 495 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | 485 | 491 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 193 | 196 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 | 192 | 195 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | 153 | 156 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | 101 | 104 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | 428 | 431 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 | 176 | 179 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 | 206 | 209 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 | 192 | 195 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1 | 92 | 95 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | 120 | 123 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | 104 | 108 |
| .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1 (new) | N/A | 153 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1 (new) | N/A | 247 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1 (new) | N/A | 147 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1 (new) | N/A | 159 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1 (new) | N/A | 172 |
| tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1 (new) | N/A | 175 |

The bundle copies under extensions/drm-copilot/resources/claude-customizations/ are byte-identical to the repository copies (mirror-parity.2026-10-29T11-41.md) and therefore have the same counts.

Result: PASS.

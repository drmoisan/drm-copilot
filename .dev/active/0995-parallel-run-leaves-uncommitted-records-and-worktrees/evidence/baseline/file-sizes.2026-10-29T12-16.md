# File sizes baseline

Timestamp: 2026-10-29T12-16
Command: @(Get-Content -LiteralPath <path>).Count per file (PowerShell script under SCRATCH)
EXIT_CODE: 0
Output Summary: logical line counts at baseline (production files are untouched at capture):
- .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1: 425
- .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1: 153
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1: 495
- .claude/hooks/enforce-epic-worktree-removal-gate.ps1: 469
- .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1: 277

Test files (counts below were read after the P1-T1, P2-T1, P3-T1, P4-T1 row additions; the pre-edit counts are derived by subtracting the added lines recorded by git diff in the final-size artifact):
- tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1: 209 (post-edit; pre-edit 176)
- tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1: 307 (post-edit; pre-edit 247)
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1: 188 (post-edit; pre-edit 172)
- tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1: 194 (post-edit; pre-edit 175)

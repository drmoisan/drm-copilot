# File sizes

Timestamp: 2026-10-29T13-11
Command: wc -l per changed file
EXIT_CODE: 0
Output Summary: every count is at most 500; no production file grew except WorktreeRunRecordPath.psm1 and CleanupWorktreeManifest.psm1, which this plan grows.
- .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1: 442 (baseline 425, grown by P1-T2)
- .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1: 185 (baseline 153, grown by P2-T2)
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1: 466 (baseline 495, shrunk)
- .claude/hooks/enforce-epic-worktree-removal-gate.ps1: 468 (baseline 469)
- .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1: 249 (baseline 277, shrunk)
- tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1: 209 (grown from 176)
- tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1: 307 (grown from 247)
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1: 199 (grown from 172)
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1: 186 (grown from 159, for the coverage rows RP5 and RP6)
- tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1: 194 (grown from 175)
Note: counts by wc -l differ from the logical-line counts of the baseline artifact by at most one line per file (terminator handling); the production hook baseline values were counted with Get-Content and the post-change values with wc -l.

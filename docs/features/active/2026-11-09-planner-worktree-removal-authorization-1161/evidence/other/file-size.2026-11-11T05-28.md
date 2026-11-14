# File size after the gate edits ([P2-T6])

Timestamp: 2026-11-11T05-28
Command: wc -l < <file> for each file below (physical line count)
EXIT_CODE: 0
Output Summary: both Claude gates and the resolution sibling are at or below 500 physical lines after the edit; before counts are from the Phase 0 file-size baseline.

| File | Before (Phase 0) | After |
|---|---|---|
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 468 | 483 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 466 | 482 |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 249 | 249 |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 190 | 220 |
| `.claude/hooks/hook-planner-worktree-removal.ps1` (new) | none | 482 |
| `.codex/hooks/hook-planner-worktree-removal.ps1` (new, byte-identical twin) | none | 482 |
| `.claude/hooks/enforce-worktree-removal-gate-planner.ps1` (new) | none | 161 |
| `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` (new) | none | 152 |

# File size and checkpoint baseline ([P0-T1])

Timestamp: 2026-11-10T03-22
Command: wc -l < <file> for each file below (physical line count); test -e artifacts/orchestration/epic-planner-state.json at the item worktree root
EXIT_CODE: 0
Output Summary: physical line counts before any edit; the epic-planner checkpoint is absent at the item worktree root.

| File | Physical lines |
|---|---|
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 468 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 466 |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 249 |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 190 |
| `scripts/dev_tools/validate_epic_planner_state.py` | 410 |
| `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | 495 |

`artifacts/orchestration/epic-planner-state.json` at the item worktree root: absent.

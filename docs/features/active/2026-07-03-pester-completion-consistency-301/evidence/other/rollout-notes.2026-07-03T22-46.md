# Rollout Notes

Timestamp: 2026-07-04T10-08

No separate deployment step is required beyond merging. The bundled `.codex` resource copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` is staged into new Codex worktree sessions at worktree-creation time. Consequently, the fix takes effect automatically for the next worktree created after this change merges; no manual rollout, migration, or re-deployment action is required.

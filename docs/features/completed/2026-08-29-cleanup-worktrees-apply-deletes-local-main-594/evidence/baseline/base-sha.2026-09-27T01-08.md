# P0-T1 — BASE_SHA Record (issue #594)

Timestamp: 2026-09-27T01-08
Task: [P0-T1]
Working directory: repository worktree root (branch `bug/cleanup-worktrees-apply-deletes-local-main-594`)

## BASE_SHA remap

- Plan literal BASE_SHA: `0658f6945aa833c6960dc5bf8a43635fc346991f`
- Effective BASE_SHA used for every P0-T1 command: `92d78897371cc5c4f301c8cc2238adeb3fff2fea` (the rebased `docs(spec)` commit)
- Reason: coordinator-mandated rebase of this branch onto origin/main `b6745383` (orchestrator deviation DEV-1). The rebase replayed the six docs-only commits; the plan literal is no longer an ancestor of HEAD, and a diff from it would include unrelated main-branch changes.
- Observed: `git merge-base --is-ancestor 0658f6945aa833c6960dc5bf8a43635fc346991f HEAD` -> EXIT_CODE 1 (the plan literal is not an ancestor after the rebase).

Equivalence command 1 (plan literal vs. rebased counterpart, scoped to code/test/skill/workflow paths):

Command: `git diff --exit-code 0658f694 92d78897 -- scripts/bash/ tests/shell/ tests/fixtures/cleanup_worktrees/ .claude/skills/cleanup-merged-worktrees/ extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/ .github/workflows/_shell-coverage.yml`
Observed EXIT_CODE: 0 (no output)

Equivalence command 2 (rebased counterpart vs. HEAD):

Command: `git diff --exit-code 92d78897 HEAD -- scripts/ tests/ .claude/skills/cleanup-merged-worktrees/ extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/ .github/workflows/`
Observed EXIT_CODE: 0 (no output)

## Command 1 — HEAD

Command: `git rev-parse HEAD`
EXIT_CODE: 0
Output: `b5f98be268c8c9e0752027486f6500f0a6fa26ce`

## Command 2 — ancestry check

Command: `git merge-base --is-ancestor 92d78897371cc5c4f301c8cc2238adeb3fff2fea HEAD`
EXIT_CODE: 0

## Command 3 — full path listing since BASE_SHA

Command: `git diff --stat=400 92d78897371cc5c4f301c8cc2238adeb3fff2fea HEAD`
EXIT_CODE: 0
Output:

```
 docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/plan.2026-09-25T22-07.md | 937 +++...---
 1 file changed, 910 insertions(+), 27 deletions(-)
```

Every listed path begins with `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/` (one path: the plan file).

## Checkpoint fields (`artifacts/orchestration/orchestrator-state.json`)

- `issue-num`: `"594"` — present, matches.
- `feature-folder`: `docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594` — present, matches.
- `route_id`: `large` — present (`path_selected` is also `large`).
- `lifecycle_ready`: `true` — present.

All four commit-gate fields are present with the required values.

## Command 4 — scoped code/test/skill/workflow diff (gate)

Command: `git diff --exit-code --stat 92d78897371cc5c4f301c8cc2238adeb3fff2fea HEAD -- scripts/ tests/ .claude/skills/cleanup-merged-worktrees/ extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/ .github/workflows/`
EXIT_CODE: 0

Output Summary:
- HEAD SHA: `b5f98be268c8c9e0752027486f6500f0a6fa26ce`.
- Ancestry check against effective BASE_SHA `92d78897`: EXIT_CODE 0.
- Scoped diff: EXIT_CODE 0 with empty output; no code, test, skill, or workflow path changed since BASE_SHA.
- Full `--stat` listing: one path, the plan file under this feature folder (docs-only).
- Checkpoint: issue-num 594, feature-folder matches, route_id large, lifecycle_ready true.
- BASE_SHA remap equivalence commands both exit 0. Result: PASS.

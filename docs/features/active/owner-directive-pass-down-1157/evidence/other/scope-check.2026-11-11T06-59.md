# Scope check (issue #1157, P6-T8)

Timestamp: 2026-11-11T06-59
Command: git diff --name-status $(git merge-base origin/main HEAD) HEAD, together with git status --porcelain (in the item worktree)
EXIT_CODE: 0
Output Summary:
- Committed diff from the merge base: 105 paths (37 added, 68 modified, 0 deleted).
- Added `.py` files: 0. Changed `.py` paths: exactly one, `M tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
- Paths under `.codex/` or `.github/hooks/`: 0.
- `scripts/dev_tools/validate_orchestrator_state.py` or any `extensions/drm-copilot/src/` file: 0.
- `.claude/agents/epic-orchestrator.md`, `.claude/agents/orchestrator.md`, `.claude/agents/parallel-orchestrator.md`: 0.
- git status --porcelain: only this feature folder's plan check-offs and new evidence files under docs/features/active/owner-directive-pass-down-1157/ (no `.py`, `.codex/`, `.github/hooks/`, validator, or extension source path).
- Every listed condition holds (AC-43, AC-48).

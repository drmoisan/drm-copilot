# Scope check (issue #1157, P6-T8, re-run on the tree containing the origin/main merge with #1167)

Timestamp: 2026-11-13T13-48
Command: git diff --name-status $(git merge-base origin/main HEAD) HEAD, together with git status --porcelain (in the item worktree)
EXIT_CODE: 0
Output Summary:
- Merge base of origin/main and HEAD: 1d62aa292 (origin/main itself, merged into the branch by 4fb158d74); HEAD 85384d9e4.
- Committed diff from the merge base: 114 paths (46 added, 68 modified, 0 deleted). The earlier record (scope-check.2026-11-11T06-59.md, 105 paths) predates the merge; the 9 additional paths are evidence files of this feature folder. Paths outside docs/features/active/owner-directive-pass-down-1157/: 85, the same set the merge commit 4fb158d74 differs from origin/main by.
- Added `.py` files: 0. Changed `.py` paths: exactly one, `M tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
- Paths under `.codex/` or `.github/hooks/`: 0.
- `scripts/dev_tools/validate_orchestrator_state.py` or any `extensions/drm-copilot/src/` file: 0.
- `.claude/agents/epic-orchestrator.md`, `.claude/agents/orchestrator.md`, `.claude/agents/parallel-orchestrator.md`: 0.
- git status --porcelain: only the new evidence file evidence/qa-gates/pytest-final.2026-11-13T13-47.md of this feature folder (no `.py`, `.codex/`, `.github/hooks/`, validator, or extension source path).
- Every listed condition holds (AC-43, AC-48).

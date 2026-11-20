# Fixtures tracked ([P0-T4])

Timestamp: 2026-10-08T17-31
Command: git ls-files -- tests/fixtures/worktree-resolution/pr-author/item-own-not-ready/artifacts/orchestration/orchestrator-state.json tests/fixtures/worktree-resolution/shared/item-own-empty/artifacts/orchestration/orchestrator-state.json tests/fixtures/worktree-resolution/shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json
EXIT_CODE: 0
Output Summary: printed exactly the three fixture paths (not-ready, empty, invalid-json).

Command: git ls-files -- tests/fixtures/worktree-resolution/shared/item-own-absent
EXIT_CODE: 0
Output Summary: printed nothing; the missing path is not tracked.

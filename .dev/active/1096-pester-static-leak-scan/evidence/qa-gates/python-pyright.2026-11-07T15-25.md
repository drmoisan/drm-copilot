# QA Gate: Python Pyright

Timestamp: 2026-11-07T15-25
Command: poetry run pyright --stats, run from <item worktree> with a temporary pyrightconfig.json at the worktree root that copies [tool.pyright] of pyproject.toml exactly and adds only "extraPaths": ["packages/discovery-runtime/src"]; the file was deleted after the run and git status --porcelain was empty afterwards
EXIT_CODE: 0
Output Summary: Second pass after the self-review fix. Found 994 source files; 0 errors, 0 warnings, 0 informations.

## Environment Note

The item worktree has no `.venv`, so `poetry run` uses the shared main-checkout environment, whose `drm_copilot_discovery.pth` points at the main checkout's `packages/discovery-runtime/src`. The plain command `poetry run pyright` therefore resolves `drm_copilot_discovery` to the main checkout while it analyzes the worktree copy, and reports 27 reportArgumentType errors in `packages/discovery-runtime/src/drm_copilot_discovery` (the same 27 that the P0-T2 baseline recorded; no file of that package is in the branch diff). The `extraPaths` entry makes the worktree copy resolve first, which matches a CI checkout whose editable install points at its own copy. The plain command was also run at this timestamp: 27 errors, EXIT_CODE 1, all in the files the baseline lists.

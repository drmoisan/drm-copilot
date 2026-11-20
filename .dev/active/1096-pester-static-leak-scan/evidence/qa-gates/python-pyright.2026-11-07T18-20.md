# QA Gate: Python Pyright (Remediation Cycle 2, Phase 2 restart)

Timestamp: 2026-11-07T18-20
Command: poetry run pyright --stats, run from <item worktree> with a temporary pyrightconfig.json at the worktree root that copies [tool.pyright] of pyproject.toml exactly and adds only "extraPaths": ["packages/discovery-runtime/src"]; the file was deleted after the run and git status --porcelain through -C was empty afterwards
EXIT_CODE: 0
Output Summary: Found 998 source files; 0 errors, 0 warnings, 0 informations.

## Plain Command Result

The plain command `poetry run pyright --stats` was also run at this timestamp: EXIT_CODE 1, 27 errors, all in `packages/discovery-runtime/src/drm_copilot_discovery` (0 errors elsewhere). These are the environment-resolution errors recorded in the cycle 2 remediation baseline (`remediation-baseline/python-pyright.2026-11-07T17-49.md`): the item worktree has no `.venv`, so the shared environment's path file resolves `drm_copilot_discovery` to the main checkout's copy. No file of that package is in the branch diff.

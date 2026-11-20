# Baseline: Python Pyright

Timestamp: 2026-11-07T14-09
Command: poetry run pyright
EXIT_CODE: 1
Output Summary: 27 errors, 0 warnings, 0 informations. All 27 are reportArgumentType in packages/discovery-runtime/src/drm_copilot_discovery (claim_rules.py 1, init_io.py 1, operations.py 3, profile_v2.py 8, references.py 8, service_contracts.py 6). Each reports the worktree copy of a class (module path prefixed `.claude.worktrees.feature-1096.packages...`) as not assignable to the same class resolved as `drm_copilot_discovery...` through the shared main-checkout environment. Pyright also printed that the worktree has no `.venv` subdirectory. The errors come from running in an item worktree without its own environment, not from code under change; no file of this item's scope is involved.

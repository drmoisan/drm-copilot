# Pyright Type-Checking Baseline — parallel-planner-surface (#443)

Timestamp: 2026-08-08T13-53

Task: [P0-T4]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aa53d4070e6155e59` (repository root of the feature worktree)
Branch: `feature/parallel-planner-surface-443`

Command: `poetry run pyright`

EXIT_CODE: 0

Output Summary:

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aa53d4070e6155e59.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
```

- Result: PASS.
- Errors: 0.
- Warnings: 0.
- Informations: 0.

## Coverage-of-Analysis Confirmation

The plain `poetry run pyright` invocation does not print the analyzed-file count, so a confirming run with `--stats` was executed to verify that the zero-error result reflects a real analysis rather than an empty file set.

Command: `poetry run pyright --stats`

EXIT_CODE: 0

Output Summary:

```
Loading pyproject.toml file at c:\Users\...\agent-aa53d4070e6155e59\pyproject.toml
Found 362 source files
pyright 1.1.409
0 errors, 0 warnings, 0 informations
Analysis stats
Total files parsed and bound: 612
Total files checked: 362
```

- Source files found: 362 (matches the 362 files Black evaluated in [P0-T2]).
- Files checked: 362.
- Files parsed and bound: 612 (includes resolved third-party and stdlib stubs).

## Environment Notes (recorded, not remediated)

- Pyright emits `venv .venv subdirectory not found in venv path <worktree root>` because the Poetry virtual environment is not materialized as a `.venv` subdirectory inside this worktree. The message is informational; the run still resolved imports (612 files parsed and bound) and checked all 362 source files, and it exits 0. This is a pre-existing environment characteristic of running inside a git worktree, not a defect introduced by this plan.
- Pyright reports a newer version (v1.1.411) is available; the pinned version 1.1.409 was used. Version pinning is out of scope for this plan.

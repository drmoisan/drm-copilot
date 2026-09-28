# Baseline — Pyright Type Check

Timestamp: 2026-08-07T14-21

Task: [P0-T4]
Plan: `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/plan.2026-08-07T11-11.md`
Branch: `feature/parallel-cohort-scheduler-445`
Working directory: repository worktree root

Command: poetry run pyright

EXIT_CODE: 0

Output Summary:
0 errors, 0 warnings, 0 informations. Pyright 1.1.409 completed the repository type check with a
clean result. A confirmation run of `poetry run pyright --stats` reported `Found 334 source files`
and `Total files checked: 334`, verifying that the clean result reflects a full analysis rather than
an empty file set.

Two non-blocking environmental notices were emitted and are recorded as pre-existing observations,
not findings introduced by this feature:

- `venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a67c9747dbb0e6436.`
  The repository virtualenv is shared at the repository root, so the worktree contains no local
  `.venv` subdirectory. Pyright still resolved imports and checked all 334 files, and the run exits 0.
- `WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).`
  A tool-version upgrade notice only. No upgrade was performed; changing the pinned tool version is
  outside the scope of this feature.

Neither notice affects the exit code, and no pre-existing type errors were observed.

## Raw Output

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a67c9747dbb0e6436.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

## Supporting Confirmation Run (`poetry run pyright --stats`)

```
Loading pyproject.toml file at c:\...\agent-a67c9747dbb0e6436\pyproject.toml
Found 334 source files
pyright 1.1.409
0 errors, 0 warnings, 0 informations
Completed in 4.686sec

Analysis stats
Total files parsed and bound: 584
Total files checked: 334
```

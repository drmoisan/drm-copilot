# Baseline — Python Type Checking (Pyright)

Timestamp: 2026-08-08T20-59

Task: [P0-T4]
Feature: 2026-08-07-parallel-drift-detection-446 (issue #446)
Branch: feature/parallel-drift-detection-446
Integration head at execution: c939b5b8
Working directory: repo root of the feature worktree
Pyright version: v1.1.409

Command: `poetry run pyright`

EXIT_CODE: 0

Output Summary: PASS. Error count = 0 (`0 errors, 0 warnings, 0 informations`). Two
non-diagnostic notices are emitted and do not affect the exit code: (1) an informational
notice that no `.venv` subdirectory exists inside the worktree path, because the Poetry
virtual environment for this worktree is resolved outside the worktree tree; (2) a Pyright
self-update notice (v1.1.409 -> v1.1.411). Neither notice is a type diagnostic. Baseline
type-error count is zero, so any Pyright error in the Phase 7 final-QC loop is attributable
to code added by this feature.

## Raw Output

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

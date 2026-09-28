# Baseline — Python Type Check (Pyright)

Timestamp: 2026-08-07T14-17

Task: [P0-T4]
Feature: 2026-08-07-parallel-blast-radius-447 (issue #447)
Branch: feature/parallel-blast-radius-447
Working directory: repository root (worktree `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a2857bcb4458f15cf`)

Command: `poetry run pyright`

EXIT_CODE: 0

Output Summary: Clean baseline — 0 errors, 0 warnings, 0 informations. Two non-blocking notices were emitted and are recorded verbatim below: (a) pyright could not find a `.venv` subdirectory under the worktree path (the Poetry virtualenv is external to the worktree), and (b) a newer pyright version (v1.1.411) is available than the pinned v1.1.409. Neither notice affects the exit code and neither blocks later phases.

## Counts

- Errors: 0
- Warnings: 0
- Informations: 0

## Raw Output

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a2857bcb4458f15cf.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

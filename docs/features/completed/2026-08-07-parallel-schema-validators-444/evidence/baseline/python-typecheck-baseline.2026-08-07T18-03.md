# Python Type-Check Baseline — [P0-T4]

Timestamp: 2026-08-07T18-03

Feature: 2026-08-07-parallel-schema-validators-444 (issue #444)
Task: [P0-T4]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e` (repository root)
Branch: `feature/parallel-schema-validators-444`
State captured: PRE-CHANGE baseline

Command: `poetry run pyright`

EXIT_CODE: 0

Output Summary: Pyright reported 0 errors, 0 warnings, 0 informations. A confirming
`poetry run pyright --stats` run established that the clean result reflects real analysis rather
than an empty file set: 348 source files found and checked, 598 files parsed and bound, pyright
version 1.1.409, completed in 4.04 seconds. Two non-blocking advisories were emitted and are
recorded as known-baseline conditions: (1) `venv .venv subdirectory not found in venv path`, and
(2) a pyright upgrade advisory (v1.1.409 -> v1.1.411). Neither advisory affects the exit code, and
the file count confirms analysis proceeded normally. The Python type-check baseline is clean.

## Raw Output — `poetry run pyright`

```
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

## Confirming Run — `poetry run pyright --stats` (EXIT_CODE: 0)

```
Loading pyproject.toml file at c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e\pyproject.toml
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e.
Found 348 source files
pyright 1.1.409
0 errors, 0 warnings, 0 informations
Completed in 4.04sec

Analysis stats
Total files parsed and bound: 598
Total files checked: 348
```

## Known-Baseline Conditions

- `venv .venv subdirectory not found in venv path <worktree root>` — advisory only; pyright resolved
  imports and checked all 348 source files. Expected to recur in the Phase 7 final-QC type-check step.
- Pyright upgrade advisory v1.1.409 -> v1.1.411 — advisory only; the pinned version is 1.1.409. No
  version change is in scope for this feature.

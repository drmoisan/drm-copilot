# Baseline — Python Type Check (Pyright) — Issue #475

Timestamp: 2026-08-15T19-19

Command: `poetry run pyright` (run from the worktree root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-afc9f4fd25ec235a5`; configuration loaded from `pyproject.toml`)

EXIT_CODE: 0

Output Summary: **0 errors, 0 warnings, 0 informations.** Pyright version 1.1.409.

Emitted warning and its disposition: the run prints `venv .venv subdirectory not found in venv path c:\...\agent-afc9f4fd25ec235a5.` This is benign in this worktree and does not indicate an unanalyzed tree. The Poetry virtual environment lives outside the worktree and is supplied by `poetry run`, so no `.venv` subdirectory exists at the worktree root. A confirming `poetry run pyright --stats` run was executed to rule out a silent no-op:

```
Found 415 source files
0 errors, 0 warnings, 0 informations
Analysis stats
Total files parsed and bound: 667
Total files checked: 415
Timing stats
Resolve Imports:      0.12sec
Check:                3.73sec
```

415 source files were checked and 667 files parsed and bound, with imports resolved, confirming the zero-error result reflects a real full analysis rather than an empty scan. A separate advisory that a newer Pyright (v1.1.411) is available is informational only; the pinned version 1.1.409 is the baseline instrument and is not changed by this plan.

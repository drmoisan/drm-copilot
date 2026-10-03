# r2 P0-T9 Python environment

Timestamp: 2026-10-03T15-51
Command: pwsh -NoProfile -File "SCRATCH/steps/r2-p0-t9.ps1" -Worktree "WORKTREE" (Test-Path Env:VIRTUAL_ENV; poetry env info --path; worktree .venv check; poetry run python --version; VERDICT)
EXIT_CODE: 0
Output Summary: VIRTUAL_ENV-SET=False, POETRY-ENV-EXIT=0, POETRY-ENV-IS-WORKTREE-VENV=True, Python 3.13.12, PYTHON-EXIT=0; VERDICT passed. The environment path itself is not printed.

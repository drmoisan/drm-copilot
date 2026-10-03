# r1 P0-T17 — Python type-check baseline

Timestamp: 2026-10-03T12-49
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t17.ps1 -Worktree WORKTREE; step script runs `poetry run pyright *> "$Scratch/r1-pyright-baseline.log"; $LASTEXITCODE` and the summary Select-String line
EXIT_CODE: 0
Output Summary:
- pyright exit code: 0
- `0 errors, 0 warnings, 0 informations`; BASELINE-PYRIGHT-SET = (empty); error count 0

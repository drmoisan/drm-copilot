# r1 P0-T18 — full pytest baseline with coverage

Timestamp: 2026-10-03T12-49
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t18.ps1 -Worktree WORKTREE; step script runs `poetry run pytest --cov=src --cov=scripts.dev_tools --cov-report=term-missing -q *> "$Scratch/r1-pytest-baseline.log"; $pytestExit = $LASTEXITCODE; "PYTEST-EXIT=$pytestExit"`, the summary Select-String line, and the P0-T18 RELAY line
EXIT_CODE: 0
Output Summary:
- PYTEST-EXIT=0 (relayed; TOTAL line and summary line present)
- `TOTAL                                                                 17552   1118    94%` (baseline Python coverage 94%)
- `6554 passed, 6 skipped in 61.30s (0:01:01)` (P0-T18 passed count = 6554)
- No `FAILED ` or `ERROR ` node. BASELINE-PYTEST-FAILURES = (empty).

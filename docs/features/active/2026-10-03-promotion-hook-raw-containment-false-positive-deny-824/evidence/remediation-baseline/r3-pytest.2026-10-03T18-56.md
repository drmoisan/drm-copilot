# r3 P0-T18 full pytest baseline with coverage (issue #824)

Timestamp: 2026-10-03T18-56
Command: poetry run pytest --cov=src --cov=scripts.dev_tools --cov-report=term-missing -q *> "$Scratch/r3-pytest-baseline.log"; $pytestExit = $LASTEXITCODE; "PYTEST-EXIT=$pytestExit" (inside SCRATCH/steps/r3-p0-t18.ps1, run in the background; TOTAL/FAILED/ERROR/summary line extraction; RELAY($pytestExit, TOTAL and summary present))
EXIT_CODE: 0
Output Summary:
TS=2026-10-03T18-56
PYTEST-EXIT=0
TOTAL                                                                 17552   1118    94%
6595 passed, 6 skipped in 56.97s
P0-T18 passed count: 6595. TOTAL line coverage: 94%.
BASELINE-PYTEST-FAILURES: empty (no FAILED or ERROR nodes).

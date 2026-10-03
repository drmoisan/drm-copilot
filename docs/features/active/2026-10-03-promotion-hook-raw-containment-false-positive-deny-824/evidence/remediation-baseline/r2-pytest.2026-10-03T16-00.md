# r2 P0-T18 pytest baseline with coverage

Timestamp: 2026-10-03T16-00
Command: poetry run pytest --cov=src --cov=scripts.dev_tools --cov-report=term-missing -q *> "$Scratch/r2-pytest-baseline.log"; $pytestExit = $LASTEXITCODE (step script SCRATCH/steps/r2-p0-t18.ps1, with the TOTAL, summary, FAILED, and ERROR lines and the RELAY line)
EXIT_CODE: 0
Output Summary:
- PYTEST-EXIT=0; relayed exit 0 (TOTAL line and summary line present)
- TOTAL 17552 statements, 1118 missed, 94% (baseline Python coverage headline)
- Summary: 6595 passed, 6 skipped in 58.17s (P0-T18 passed count = 6595)
- FAILED and ERROR nodes: none (BASELINE-PYTEST-FAILURES empty)

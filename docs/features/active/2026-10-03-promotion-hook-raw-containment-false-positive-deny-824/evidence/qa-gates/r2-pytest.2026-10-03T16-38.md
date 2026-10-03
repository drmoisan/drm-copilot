# r2 P8-T8 pytest with coverage (final QC)

Timestamp: 2026-10-03T16-38
Command: poetry run pytest --cov=src --cov=scripts.dev_tools --cov-report=term-missing -q *> "$Scratch/r2-pytest-final.log"; $pytestExit = $LASTEXITCODE (step script SCRATCH/steps/r2-p8-t8.ps1, with the TOTAL, summary, FAILED, and ERROR lines, UNEXPECTED-FAILURES, PASSED, and the RELAY line; RECORDED P0-T18 failures empty and passed count 6595)
EXIT_CODE: 0
Output Summary:
- PYTEST-EXIT=0; relayed exit 0
- TOTAL 17552 statements, 1118 missed, 94% (P0-T18 baseline 94%; unchanged)
- Summary: 6595 passed, 6 skipped in 58.75s (equal to the P0-T18 passed count)
- UNEXPECTED-FAILURES=0; no FAILED or ERROR node
- Python new-code coverage: N/A - no production file of this language changes

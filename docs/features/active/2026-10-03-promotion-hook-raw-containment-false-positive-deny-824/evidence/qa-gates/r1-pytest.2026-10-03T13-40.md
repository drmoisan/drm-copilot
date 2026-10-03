# r1 P8-T8 — Python tests with coverage

Timestamp: 2026-10-03T13-40
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p8-t8.ps1 -Worktree WORKTREE (A0; `poetry run pytest --cov=src --cov=scripts.dev_tools --cov-report=term-missing -q *> "$Scratch/r1-pytest-final.log"; $pytestExit = $LASTEXITCODE; "PYTEST-EXIT=$pytestExit"`; the summary lines; the unexpected-failure computation with RECORDED(P0-T18 BASELINE-PYTEST-FAILURES) = @(); RELAY with RECORDED(P0-T18 passed count) = 6554)
EXIT_CODE: 0
Output Summary:
- PYTEST-EXIT=0
- `TOTAL                                                                 17552   1118    94%` (baseline P0-T18: 94%; unchanged because no production Python file changed)
- `6595 passed, 6 skipped in 58.62s` (P0-T18 6554 plus 41: PYG 40 and the new PYA test)
- UNEXPECTED-FAILURES=0 PASSED=6595; no FAILED or ERROR node
- Python new-code coverage: N/A - no production file of this language changes

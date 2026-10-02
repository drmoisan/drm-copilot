# Baseline: full suite in coverage mode (P0-T12)

Timestamp: 2026-10-01T20-49
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
- TOTAL row (columns Stmts Miss Branch BrPart Cover): `TOTAL                                                                 17246   1116   6232    573    92%`
- BaselineTotalCover: 92%
- Result line: `================= 6296 passed, 6 skipped in 93.32s (0:01:33) ==================`
- BaselineFailingNodes: none
- Note: the 6 skipped nodes are `SKIPPED` lines in the `-ra` summary (for example `tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231`), not failures.

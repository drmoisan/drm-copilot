# Final QC: full suite in coverage mode (P2-T5)

Timestamp: 2026-10-01T20-57
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary:
- TOTAL row: `TOTAL                                                                 17246   1116   6232    573    92%`
- PostChangeTotalCover: 92%
- Result line: `================= 6331 passed, 6 skipped in 85.27s (0:01:25) ==================`
- FinalFailingNodes: none
- Issue510Check: not invoked (no failing node)
- Note: 6331 passed = 6296 baseline passed + 35 guard nodes added (52 - 17). The TOTAL row is identical to the baseline because the only Python file changed is under `tests/`, which coverage omits.

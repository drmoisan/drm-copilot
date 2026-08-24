Timestamp: 2026-08-22T13-41
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary: 4078 passed, 5 skipped. TOTAL row: 14939 Stmts, 1105 Miss -> statement coverage
(14939-1105)/14939 = 92.60%. Branch coverage from totals.percent_branches_covered in
artifacts/python/coverage.json = 85.19%. Both figures exceed the quality-tiers.md thresholds
(85% statements, 75% branches) and match the cycle-2 closing figures.

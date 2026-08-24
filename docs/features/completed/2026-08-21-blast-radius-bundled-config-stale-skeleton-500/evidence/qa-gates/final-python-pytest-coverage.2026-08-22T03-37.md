Timestamp: 2026-08-22T03-37
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary: 4078 passed, 5 skipped (one more than the P0-T15 baseline's 4077, from the new
test_every_top_level_key_is_classified_and_shared_by_both_copies case). TOTAL row: 14939 Stmts,
1105 Miss -> statement coverage (14939-1105)/14939 = 92.60%, unchanged from baseline. Branch
coverage from totals.percent_branches_covered = 85.19%, unchanged from baseline. No regression;
scripts.dev_tools carries no production changes this cycle.

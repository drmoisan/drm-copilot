Timestamp: 2026-08-21T21-49
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary: 4077 passed, 5 skipped (one more passed than the P0-T15 baseline's 4076, from the
new test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle case). TOTAL row:
14939 Stmts, 1105 Miss -> statement coverage (14939-1105)/14939 = 92.60%, unchanged from baseline.
Branch coverage from totals.percent_branches_covered = 85.19%, unchanged from baseline. No
regression; scripts.dev_tools carries no production changes this cycle.

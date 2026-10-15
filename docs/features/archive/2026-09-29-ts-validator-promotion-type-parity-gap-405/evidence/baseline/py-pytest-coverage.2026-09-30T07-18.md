# Python full-suite coverage baseline (P0-T14)

Timestamp: 2026-09-30T07-18
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p0-t14.json -q -p no:cacheprovider
(The two trailing flags `-q -p no:cacheprovider` only reduce console verbosity and disable the pytest cache directory; they do not change test selection or coverage measurement.)
EXIT_CODE: 0
Output Summary:
- Result line: `5697 passed, 6 skipped in 100.27s`. Passed 5697, failed 0, skipped 6. Failed node IDs: none.
- Read from the `totals` object of artifacts/python/cov-p0-t14.json:
  - percent_statements_covered: 93.4 (93.3518..., 15811 of 16937 statements)
  - percent_branches_covered: 86.3 (86.3085..., 5270 of 6106 branches)
- Terminal TOTAL row for reference: 16937 statements, 1126 missed, 6106 branches, 584 partial branches, 91% combined.

# Python full-suite coverage final QA (P5-T9)

Timestamp: 2026-09-30T07-45
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p5-t9.json -q -p no:cacheprovider
(The trailing `-q -p no:cacheprovider` flags only reduce console verbosity and disable the pytest cache directory, as in the P0-T14 baseline.)
EXIT_CODE: 0
Output Summary:
- Result line: `5712 passed, 6 skipped in 115.26s (0:01:55)`. Passed 5712, failed 0, skipped 6. Failed node IDs: none (equal to the empty P0-T14 set).
- Passed count check: P0-T14 passed 5697 plus 15 equals 5712.
- Read from the `totals` object of artifacts/python/cov-p5-t9.json (one-line node script):
  - percent_statements_covered: 93.4 (93.3518..., 15811 of 16937 statements)
  - percent_branches_covered: 86.3 (86.3085..., 5270 of 6106 branches)

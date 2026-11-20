# pytest Phase 0 Baseline (issue #1141, [P0-T4])

Timestamp: 2026-11-08T19-24
Command: env -u VIRTUAL_ENV poetry run pytest -n auto -q -rfE --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1141-pytest-baseline.json --cov
EXIT_CODE: 0
Output Summary:
- 16560 passed, 6 skipped in 198.23s; failed 0; errors 0.
- Failing node IDs: none.
- Total line coverage (JSON report totals): 97.11% (34296 of 35317 statements).
- Total branch coverage (JSON report totals): 94.36% (12648 of 13404 branches).
- Combined percent_covered (JSON) 96.35%; terminal TOTAL row 96%.

Note: the first launcher passed the JSON report path in MSYS form, so coverage.py wrote it under a `c/` subtree of the drive root instead of SCRATCH; the file was moved into SCRATCH unchanged before it was read, and the launcher now passes a Windows-form path.

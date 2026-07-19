Timestamp: 2026-07-18T16-50
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Output Summary:
1720 passed, 0 failed (up from the pre-remediation baseline's 1717 passed;
the increase of 3 matches the 3 new test functions added in Phase 1).

Aggregate coverage totals (full repository, coverage.py totals):
- Aggregate line (statement) coverage: 88.26% (`percent_statements_covered`,
  10010/11342 statements), up from the pre-remediation baseline of 88.21%
  reported in `remediation-inputs.2026-07-18T16-04.md`.
- Aggregate branch coverage: 79.11% (`percent_branches_covered`,
  3356/4242 branches), up from the pre-remediation baseline of 79.02%
  reported in `remediation-inputs.2026-07-18T16-04.md`.
- Aggregate blended `percent_covered`: 85.77% (displayed as `86%`).

`scripts/dev_tools/schema_loading.py` in the full-suite context now reports
100% line coverage (35/35 statements) and 100% branch coverage (14/14
branches) — all branches, including the `http(s)://` fetch-and-cache path,
are exercised once this file's own tests plus the pre-existing
`test_validate_json.py` indirect-exercise tests are combined.

Result: both aggregate line coverage (88.26% >= 88.21%) and aggregate
branch coverage (79.11% >= 79.02%) are greater than or equal to the
pre-remediation aggregate figures. No regression is present.

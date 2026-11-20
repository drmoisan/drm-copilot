# Baseline: Python Test + Coverage

Timestamp: 2026-07-18T21-19
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: 1839 passed, 0 failed, in 9.29s. Coverage totals (from
`coverage json` on the same `.coverage` data file, `artifacts/.coverage`):
- Line (statement) coverage: 88.87% (10524/11842 covered lines counted via
  `percent_statements_covered`)
- Branch coverage: 79.51% (3462/4354 covered branches via `percent_branches_covered`)
- Combined coverage.py "Cover" column (line+branch weighted): 86%

This is the pre-change reference for the Phase 5 coverage-delta check (P5-T6). Both the line
(>=85%) and branch (>=75%) thresholds are already met at baseline.

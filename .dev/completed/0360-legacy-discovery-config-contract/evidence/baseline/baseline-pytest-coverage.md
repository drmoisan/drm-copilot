# Baseline Test-and-Coverage (P0-T6)

Timestamp: 2026-07-18T14-13
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Output Summary: PASS. 1537 passed in 14.36s.

Coverage headline (TOTAL row): Stmts=10909, Miss=1335, Branch=4114, BrPart=549,
combined Cover=85%.

Numeric baseline coverage:
- Line coverage: (10909 - 1335) / 10909 = 87.8%.
- Branch coverage: derived from the combined figure; covered branches
  = (0.85 * (10909 + 4114)) - (10909 - 1335) = 3196 of 4114 = 77.7%.
- Combined (reported TOTAL): 85%.

Per-module baseline for the new discovery package: N/A — `scripts/dev_tools/discovery/`
does not yet exist at baseline (confirmed in `namespace-free.md`).

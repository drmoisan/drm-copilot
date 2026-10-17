---
Timestamp: 2026-09-30T11-20
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py --cov=scripts.dev_tools.compute_blast_radius --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
  - Total tests passed: 20
  - Module: scripts/dev_tools/compute_blast_radius.py
  - Stmts: 80, Miss: 24, Branch: 14, BrPart: 3, Cover: 63%
  - Line percentage (baseline): 70% = (80 - 24) / 80
  - Branch percentage (baseline): 21.43% = 3 / 14 (branch hits / total branches)
---

# Baseline — Pytest Coverage

Captures baseline coverage metrics for the `compute_blast_radius` module.

## Coverage Table

```
Name                                        Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------
scripts\dev_tools\compute_blast_radius.py      80     24     14      3    63%   202, 213, 241-248, 312-318, 376-408, 444-446, 472
---------------------------------------------------------------------------------------
TOTAL                                          80     24     14      3    63%
```

## Calculated Percentages

For the target module row (`compute_blast_radius.py`):
- **Line coverage (baseline):** (Stmts - Miss) / Stmts = (80 - 24) / 80 = **70.0%**
- **Branch coverage (baseline):** BRH / BRF = 3 / 14 = **21.43%**

## Notes

- All 20 tests passed (0 failed).
- Coverage is captured on the target production module, not on test code.
- LCOV report written to `artifacts/python/lcov.info`.
- This baseline establishes the no-regression threshold for changed lines.
Correction (remediation 2026-09-30T12-05, finding R2): the branch percentage previously derived here as (Branch - BrPart) / Branch was wrong. BrPart counts partially covered branch points, not missed branches. The measured branch hit fraction is BRH / BRF = 3 / 14 = 21.43%, read from the LCOV record during the 2026-09-30T12-05 audit and consistent with the printed Cover of 63% = (56 + 3) / (80 + 14). The line percentage and the no-regression conclusion are unchanged.

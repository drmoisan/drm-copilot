---
Timestamp: 2026-09-30T11-27
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py --cov=scripts.dev_tools.compute_blast_radius --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
  - Tests passed: 20 (matches baseline)
  - Coverage: Stmts: 80, Miss: 24, Branch: 14, BrPart: 3, Cover: 63%
  - Line percentage: 70% (matches baseline 70%)
  - Branch percentage: 21.43% (matches baseline 21.43%)
---

# QA Gate — Final Pytest with Coverage

Runs the full test suite with coverage measurement to verify test passing and coverage integrity.

## Coverage Table

```
Name                                        Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------
scripts\dev_tools\compute_blast_radius.py      80     24     14      3    63%   202, 213, 241-248, 312-318, 376-408, 444-446, 472
---------------------------------------------------------------------------------------
TOTAL                                          80     24     14      3    63%
```

## Test Results

```
collected 20 items

tests\scripts\dev_tools\test_blast_radius_config_parity.py ............. [ 65%]
.......                                                                  [100%]

20 passed in 0.21s
```

## Coverage Analysis

For the target module row (`compute_blast_radius.py`):
- **Line coverage (final):** (Stmts - Miss) / Stmts = (80 - 24) / 80 = **70.0%** ✓ (no regression; matches baseline 70%)
- **Branch coverage (final):** BRH / BRF = 3 / 14 = **21.43%** ✓ (no regression; matches baseline 21.43%)

**Result:** All 20 tests pass with no failures. Coverage metrics are identical to baseline (P0-T10), confirming no coverage regression on changed or unchanged lines.
Correction (remediation 2026-09-30T12-05, finding R2): the branch percentage previously derived here as (Branch - BrPart) / Branch was wrong. BrPart counts partially covered branch points, not missed branches. The measured branch hit fraction is BRH / BRF = 3 / 14 = 21.43%, read from the LCOV record during the 2026-09-30T12-05 audit and consistent with the printed Cover of 63% = (56 + 3) / (80 + 14). The line percentage and the no-regression conclusion are unchanged.

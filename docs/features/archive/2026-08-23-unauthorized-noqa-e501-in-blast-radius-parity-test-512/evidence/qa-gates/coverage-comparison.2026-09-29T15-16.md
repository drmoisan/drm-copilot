---
Timestamp: 2026-09-30T11-27
Command: "Comparison of evidence/baseline/pytest-coverage-baseline.2026-09-29T15-16.md vs evidence/qa-gates/final-pytest-coverage.2026-09-29T15-16.md"
EXIT_CODE: 0
Output Summary:
  - Baseline and final coverage identical (no regression)
  - Baseline line %: 70%, Final line %: 70% ✓
  - Baseline branch %: 21.43%, Final branch %: 21.43% ✓
  - Changed-code coverage: Not applicable (only test function definition changed, excluded from coverage)
---

# Coverage Comparison — No Regression

Compares baseline coverage (P0-T10) with final coverage (P3-T5) to verify no regression.

## Baseline Coverage (P0-T10)

```
Name                                        Stmts   Miss Branch BrPart  Cover
---------------------------------------------------------------------------------------
scripts\dev_tools\compute_blast_radius.py      80     24     14      3    63%
```

Calculated:
- Line coverage: (80 - 24) / 80 = **70%**
- Branch coverage: BRH / BRF = 3 / 14 = **21.43%**

## Final Coverage (P3-T5)

```
Name                                        Stmts   Miss Branch BrPart  Cover
---------------------------------------------------------------------------------------
scripts\dev_tools\compute_blast_radius.py      80     24     14      3    63%
```

Calculated:
- Line coverage: (80 - 24) / 80 = **70%**
- Branch coverage: BRH / BRF = 3 / 14 = **21.43%**

## Analysis

✓ **Line coverage:** 70% → 70% (no change, no regression)
✓ **Branch coverage:** 21.43% → 21.43% (no change, no regression)
✓ **Changed-code coverage:** Not applicable because the only changed line is the test function definition on line 358, which is test code and is excluded from coverage measurement per `.claude/rules/general-unit-test.md`.

## Conclusion

Coverage is identical between baseline and final state. No regression detected. The change (renaming a test function and removing a suppression comment) does not affect the coverage profile of the production module `compute_blast_radius.py`.
Correction (remediation 2026-09-30T12-05, finding R2): the branch percentage previously derived here as (Branch - BrPart) / Branch was wrong. BrPart counts partially covered branch points, not missed branches. The measured branch hit fraction is BRH / BRF = 3 / 14 = 21.43%, read from the LCOV record during the 2026-09-30T12-05 audit and consistent with the printed Cover of 63% = (56 + 3) / (80 + 14). The line percentage and the no-regression conclusion are unchanged.

# Final QA — Python Coverage-Bearing Test (issue #472)

Timestamp: 2026-08-15T12-29

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (working directory: repo root)

EXIT_CODE: 0

Output Summary:

## Coverage headline (TOTAL row)

```
Stmts   Miss   Branch   BrPart   Cover
14396   1108   5286     557      90%
```

Numeric post-change values:

- **Combined coverage (coverage.py TOTAL, statements + branches): 90%**
- **Line (statement) coverage: 92.30% ((14396 - 1108) / 14396)**
- **Branch coverage: 89.46% ((5286 - 557) / 5286)**

## Test result

```
====================== 3785 passed, 5 skipped in 13.52s =======================
```

- **3785 passed, 5 skipped.** Zero failures.
- The passed count rose from the Phase 0 baseline of 3781 by exactly 4: the P1-T1 disjoint-items test, the three P1-T2 matrix tests, and the two P1-T3 negative-pin parametrizations (+6), less the two shape parametrizations that the corrected twelve-module map no longer generates (-2).
- The five skips are the pre-existing declared parametrizations in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231`, unchanged from baseline and unrelated to this item.

## No regression

Baseline (`evidence/baseline/phase0-py-pytest-coverage.md`) recorded the identical
TOTAL row: `14396 1108 5286 557 90%`. Statement, miss, branch, and branch-partial
counts are unchanged, so line and branch coverage are unchanged at 92.30% and
89.46%. This is expected: the only Python change in this item is a test file,
which is excluded from coverage measurement, plus two JSON configuration files,
which carry no executable Python.

No restart of the Python loop was required; this is the first and only pass of
the final Python loop.

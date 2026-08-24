# Phase 0 — Python Coverage-Bearing Test Baseline (issue #472)

Timestamp: 2026-08-15T10-50

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (working directory: repo root)

EXIT_CODE: 0

Output Summary:

Baseline coverage headline (TOTAL row of the `term-missing` report):

```
Stmts   Miss   Branch   BrPart   Cover
14396   1108   5286     557      90%
```

Numeric baseline values:

- **Combined coverage (coverage.py TOTAL, statements + branches): 90%**
- **Line (statement) coverage: 92.30% ((14396 - 1108) / 14396)**
- **Branch coverage: 89.46% ((5286 - 557) / 5286)**

Test result:

- **3781 passed, 5 skipped in 14.34s**
- The five skips are declared parametrizations in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231` that declare no accessor expectation; they are pre-existing and unrelated to this item.
- Coverage LCOV written to `artifacts/python/lcov.info`.

All suites green at baseline. These numeric values are the reference for the P7-T12 coverage delta comparison.

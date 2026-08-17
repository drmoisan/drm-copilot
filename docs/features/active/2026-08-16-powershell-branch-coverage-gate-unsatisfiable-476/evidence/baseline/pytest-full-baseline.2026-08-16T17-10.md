# Full Python Suite Baseline with Coverage (Issue #476)

Timestamp: 2026-08-16T17-10

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (run from the repository root)

EXIT_CODE: 0

## Coverage Totals (raw `TOTAL` row)

```text
Name                                                                Stmts   Miss Branch BrPart  Cover
---------------------------------------------------------------------------------------------------
TOTAL                                                               14396   1108   5286    557    90%
Coverage LCOV written to file artifacts/python/lcov.info
```

## Numeric Coverage Values

| Metric | Denominator | Missed / Partial | Percentage |
| --- | --- | --- | --- |
| Statements (line coverage) | 14396 | 1108 missed | 92.30% |
| Branches (branch coverage) | 5286 | 557 partial | 89.46% |
| Combined reported total | — | — | 90% |

## Test Result Summary

```text
3785 passed, 5 skipped in 20.05s
```

The five skips are declared skips in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231` for manifest fixtures that declare no accessor expectation. They are pre-existing and unrelated to this change.

Output Summary: 3785 passed, 0 failed, 5 skipped, exit code 0. Line coverage 92.30% (14396 statements, 1108 missed), branch coverage 89.46% (5286 branches, 557 partial), combined reported total 90%. Both exceed the repository thresholds of line >= 85% and branch >= 75%. This change modifies no Python source or test file, so the expected post-change delta is zero on every value above.

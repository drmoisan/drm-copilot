# Python Baseline — Issue #462

Timestamp: 2026-08-10T14-57

Task: [P0-T3]
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

## Output Summary

- Result: 3665 passed, 0 failed, in 18.59s.
- Coverage totals row: `TOTAL 14396 1108 5286 557 90%`
  - Statements: 14396
  - Statements missed: 1108
  - Branches: 5286
  - Partial branches: 557
- Line coverage: 92.30% ((14396 - 1108) / 14396)
- Branch coverage: 89.46% ((5286 - 557) / 5286)
- coverage.py combined total reported by the terminal report: 90%
- Coverage LCOV written to `artifacts/python/lcov.info`.

Both baseline values clear the uniform thresholds in `.claude/rules/quality-tiers.md`
(line >= 85%, branch >= 75%). These are the reference values for the [P7-T11]
coverage delta.

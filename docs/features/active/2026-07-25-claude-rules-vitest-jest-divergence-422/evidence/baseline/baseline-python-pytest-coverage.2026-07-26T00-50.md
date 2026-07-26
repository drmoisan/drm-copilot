# Baseline — Python Tests and Coverage (Pytest) (Issue #422)

Timestamp: 2026-07-26T00-50

Command:
```
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

Supplementary command used to extract exact numeric line and branch percentages from the same coverage data file (no re-run of the test suite):
```
poetry run coverage json -o <scratch>/baseline-cov.json
```

EXIT_CODE: 0

Output Summary:

Test results:
- Passed: 2123
- Failed: 0
- Errors: 0
- Skipped: 0
- Duration: 11.55s
- Verbatim result line: `2123 passed in 11.55s`

Coverage (numeric, from `coverage json` `totals` over the same run data):
- Line (statement) coverage: **91.00%** (`covered_lines` 11175 / `num_statements` 12280; `missing_lines` 1105) — policy floor >= 85%: PASS
- Branch coverage: **81.84%** (`covered_branches` 3642 / `num_branches` 4450; `missing_branches` 808, `num_partial_branches` 554) — policy floor >= 75%: PASS
- coverage.py combined statement+branch total (the `TOTAL` row printed by the terminal report): 88.57% (displayed as `89%`)
- LCOV side artifact written by the run: `artifacts/python/lcov.info`

Baseline test-and-coverage state: clean, both policy floors satisfied.

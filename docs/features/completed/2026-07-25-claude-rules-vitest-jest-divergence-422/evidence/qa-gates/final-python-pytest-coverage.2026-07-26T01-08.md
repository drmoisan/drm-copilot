# Final QC — Python Tests and Coverage (Pytest) (Issue #422)

Timestamp: 2026-07-26T01-08

Command:
```
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

Supplementary command used to extract exact numeric line and branch percentages from the same coverage data file (no re-run of the test suite):
```
poetry run coverage json -o <scratch>/final-cov.json
```

EXIT_CODE: 0

Output Summary:

Test results:
- Passed: **2138**
- Failed: 0
- Errors: 0
- Skipped: 0
- Duration: 9.60s
- Verbatim result line: `2138 passed in 9.60s`
- Delta against the `[P0-T11]` baseline (2123 passed): **+15 tests**, exactly the 15 cases contributed by the new module `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`. No previously passing test regressed.

Coverage (numeric, from `coverage json` `totals` over the same run data):
- Line (statement) coverage: **91.00%** (`covered_lines` 11175 / `num_statements` 12280; `missing_lines` 1105) — policy floor >= 85%: **PASS**
- Branch coverage: **81.84%** (`covered_branches` 3642 / `num_branches` 4450; `missing_branches` 808, `num_partial_branches` 554) — policy floor >= 75%: **PASS**
- coverage.py combined statement+branch total (the `TOTAL` row printed by the terminal report): 88.57% (displayed as `89%`)
- LCOV side artifact written by the run: `artifacts/python/lcov.info`

Loop position: step 4 of the Phase 5 final QA loop. All four steps (format, lint, type-check, test) completed without error and without changing files in a single pass, so no restart was required.

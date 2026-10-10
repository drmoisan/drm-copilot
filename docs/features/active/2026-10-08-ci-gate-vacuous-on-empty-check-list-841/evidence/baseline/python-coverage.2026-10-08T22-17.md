# Python Coverage Baseline (#841, P0-T15)

Timestamp: 2026-10-10T09-17
Command: poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py --cov=scripts.dev_tools.skill_bundle_contract --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- `38 passed in 0.91s`
- Coverage row: `scripts\dev_tools\skill_bundle_contract.py     141      5    96%   109, 216, 245-246, 254`
- PY_BASE_PCT=96 (Stmts 141, Miss 5, Cover 96%)
- LCOV also written to artifacts/python/lcov.info (gitignored)

Route: run exactly as written (Python tasks are not affected by the route substitution).

## Terminal coverage table

```text
Name                                         Stmts   Miss  Cover   Missing
--------------------------------------------------------------------------
scripts\dev_tools\skill_bundle_contract.py     141      5    96%   109, 216, 245-246, 254
--------------------------------------------------------------------------
TOTAL                                          141      5    96%
```

PY_BASE_PCT=96

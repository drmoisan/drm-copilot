# #797 CR-1/CR-4 Python Pass-After (P4-T9)

Timestamp: 2026-10-13T11-24
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py -v --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/scratch-903/py-cov-token-shapes-after-903.json"
EXIT_CODE: 0
Output Summary: 138 passed in 16.55s. Both new nodes PASSED. Module coverage 100% line and 100% branch (27 statements, 0 missed, 10 branches, 0 partial); `Missing` column empty. Parity and historical suites pass unmodified.

## New nodes

- test_is_file_shaped_component_classifies_a_component[kelvin-sign-extension] PASSED
- test_is_file_shaped_component_classifies_a_component[dotted-capital-i-extension] PASSED

## Coverage table (term-missing)

```
Name                                              Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\_blast_radius_token_shapes.py      27      0     10      0   100%
TOTAL                                                27      0     10      0   100%
```

The `Missing` column of the module row is empty, so it lists none of the new guard lines (`if not extension.isascii():` / `return False`).

## Extraction

Command: poetry run python -c "import json,sys;s=json.load(open(sys.argv[1]))['totals'];print('TOTAL line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2))" artifacts/scratch-903/py-cov-token-shapes-after-903.json
EXIT_CODE: 0
Output: `TOTAL line 100.0 branch 100.0`

- After-Line: 100.0 (threshold 85)
- After-Branch: 100.0 (threshold 75)

## Unmodified suites

`git status --porcelain -- tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py` printed nothing: neither suite was edited, and both passed, so no pinned value changed.

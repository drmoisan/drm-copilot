# Targeted Python Coverage Baseline: _blast_radius_token_shapes (P0-T21)

Timestamp: 2026-10-13T00-14
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/scratch-903/py-cov-token-shapes-baseline-903.json"
EXIT_CODE: 0
BASE: fd81a43b45de65078236da6c1cbfd077c3eb010c

Pytest output (excerpt):
```
collected 136 items
Name                                              Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\_blast_radius_token_shapes.py      25      0      8      0   100%
TOTAL                                                25      0      8      0   100%
Coverage JSON written to file artifacts/scratch-903/py-cov-token-shapes-baseline-903.json
============================ 136 passed in 19.29s =============================
```

Extraction command (P0-T20 form against this JSON):
`poetry run python -c "import json,sys;s=json.load(open(sys.argv[1]))['totals'];print('TOTAL line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2))" artifacts/scratch-903/py-cov-token-shapes-baseline-903.json`
Extraction EXIT_CODE: 0
Extraction output:
```
TOTAL line 100.0 branch 100.0
```

Baseline-Line: 100.0
Baseline-Branch: 100.0

Output Summary: PASS. 136 passed (token-shapes, parity, historical-runs suites). `scripts.dev_tools._blast_radius_token_shapes`: 25 statements, 0 missed, 8 branches, 0 partial; line 100.0%, branch 100.0%.

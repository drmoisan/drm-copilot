# Targeted Module Coverage: scripts.dev_tools._blast_radius_token_shapes (P12-T6)

Timestamp: 2026-10-13T13-47
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py -v --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/scratch-903/py-cov-token-shapes-final-903.json"; poetry run python -c "import json,sys;s=json.load(open(sys.argv[1]))['totals'];print('TOTAL line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2))" artifacts/scratch-903/py-cov-token-shapes-final-903.json
EXIT_CODE: 0
HEAD: 4e8d9f92d63c686f64f9f97e975448dc126c92f1
Loop-Iteration: 2

Pytest output captured to `artifacts/scratch-903/py-cov-token-shapes-iter2-903.txt` (not committed).

Pytest summary:
```
============================ 138 passed in 19.02s =============================
```

Coverage table (verbatim):
```
scripts\dev_tools\_blast_radius_token_shapes.py      27      0     10      0   100%
TOTAL                                                27      0     10      0   100%
```

Extraction output (exit 0):
```
TOTAL line 100.0 branch 100.0
```

Post-Line: 100.0
Post-Branch: 100.0
Missing column: empty (no uncovered line, including the new guard lines).

Output Summary: PASS. 138 passed, 0 failed (including `kelvin-sign-extension` and `dotted-capital-i-extension`). Line 100.0% and branch 100.0% for `scripts.dev_tools._blast_radius_token_shapes`, above 85/75.

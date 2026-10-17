# Baseline: quality-tiers targeted coverage ([P0-T11])

Timestamp: 2026-10-09T20-58
Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"
EXIT_CODE: 0
Output Summary: 61 passed in 0.37s (61 collected). quality_tiers_contract.py Missing column lists 124, 155, 199 (as expected for #734 CR-2). check_quality_tiers.py Missing lists the partial arc 146->149. COVJSON: check_quality_tiers.py line 100.0% branch 91.67%; quality_tiers_contract.py line 98.43% branch 96.15%.

## Term-missing rows (verbatim)

```
Name                                          Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------
scripts\dev_tools\check_quality_tiers.py         64      0     12      1    99%   146->149
scripts\dev_tools\quality_tiers_contract.py     191      3     78      3    98%   124, 155, 199
-----------------------------------------------------------------------------------------
TOTAL                                           255      3     90      4    98%
```

## Block 2

Command: poetry run python -c "import json,sys;d=json.load(open(sys.argv[1]));[print(k,'line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2) if s['num_branches'] else 'n/a') for k,v in d['files'].items() for s in [v['summary']]]" artifacts/python/cov-targeted.json
EXIT_CODE: 0
Output Summary: two rows printed (verbatim below).

```
scripts\dev_tools\check_quality_tiers.py line 100.0 branch 91.67
scripts\dev_tools\quality_tiers_contract.py line 98.43 branch 96.15
```

Baseline-Line: scripts.dev_tools.quality_tiers_contract 98.43; scripts.dev_tools.check_quality_tiers 100.0
Baseline-Branch: scripts.dev_tools.quality_tiers_contract 96.15; scripts.dev_tools.check_quality_tiers 91.67

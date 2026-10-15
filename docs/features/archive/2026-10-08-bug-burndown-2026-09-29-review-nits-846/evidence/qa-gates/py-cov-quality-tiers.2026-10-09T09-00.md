# Final QC: quality-tiers targeted coverage ([P10-T4])

Timestamp: 2026-10-09T21-52
Loop-Iteration: 1
Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"
EXIT_CODE: 0
Output Summary: 67 passed in 0.43s. quality_tiers_contract.py Missing column is empty (none of 124, 155, 199). check_quality_tiers.py Missing lists only the partial arc 157->160. COVJSON: check_quality_tiers.py line 100.0 branch 92.86 (>= 85 / >= 75); quality_tiers_contract.py line 100.0 branch 100.0.

## Term-missing rows (verbatim)

```
Name                                          Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------
scripts\dev_tools\check_quality_tiers.py         70      0     14      1    99%   157->160
scripts\dev_tools\quality_tiers_contract.py     191      0     78      0   100%
-----------------------------------------------------------------------------------------
TOTAL                                           261      0     92      1    99%
```

## Block 2

Command: poetry run python -c "import json,sys;d=json.load(open(sys.argv[1]));[print(k,'line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2) if s['num_branches'] else 'n/a') for k,v in d['files'].items() for s in [v['summary']]]" artifacts/python/cov-targeted.json
EXIT_CODE: 0
Output Summary: two rows printed (verbatim below).

```
scripts\dev_tools\check_quality_tiers.py line 100.0 branch 92.86
scripts\dev_tools\quality_tiers_contract.py line 100.0 branch 100.0
```

## Baseline ([P0-T11]) versus post-change

| Module | Baseline line | Post line | Baseline branch | Post branch |
| --- | --- | --- | --- | --- |
| scripts.dev_tools.check_quality_tiers | 100.0 | 100.0 | 91.67 | 92.86 |
| scripts.dev_tools.quality_tiers_contract | 98.43 | 100.0 | 96.15 | 100.0 |

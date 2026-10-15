# Regression: quality-tiers targeted coverage after CR-2 and CR-4 ([P3-T5])

Timestamp: 2026-10-09T21-15
Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"
EXIT_CODE: 0
Output Summary: 67 passed in 0.82s (51 contract/classification + 16 CLI). quality_tiers_contract.py Missing column is empty (baseline listed 124, 155, 199; all three now covered). check_quality_tiers.py Missing lists only the partial arc 157->160 (the same `if not manifest_path.is_absolute()` partial arc recorded at baseline as 146->149, shifted by the 11 added lines). COVJSON: check_quality_tiers.py line 100.0 branch 92.86 (baseline 100.0 / 91.67); quality_tiers_contract.py line 100.0 branch 100.0 (baseline 98.43 / 96.15).

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

Post-Line: scripts.dev_tools.quality_tiers_contract 100.0; scripts.dev_tools.check_quality_tiers 100.0
Post-Branch: scripts.dev_tools.quality_tiers_contract 100.0; scripts.dev_tools.check_quality_tiers 92.86

Acceptance (AC-4): exit 0; quality_tiers_contract.py Missing contains none of 124, 155, 199; check_quality_tiers.py line 100.0 >= 85 and branch 92.86 >= 75; both rows recorded verbatim. PASS.

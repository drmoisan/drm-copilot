# Baseline: potential_to_issue_filesystem targeted coverage ([P0-T12])

Timestamp: 2026-10-09T20-59
Command: poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "--cov=scripts.dev_tools.potential_to_issue_filesystem" --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"
EXIT_CODE: 0
Output Summary: 8 passed in 0.12s. Module 31 statements, 0 missed, 14 branches, 0 partial, 100%, no Missing entries. COVJSON: line 100.0% branch 100.0%.

## Term-missing row (verbatim)

```
Name                                                 Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------
scripts\dev_tools\potential_to_issue_filesystem.py      31      0     14      0   100%
------------------------------------------------------------------------------------------------
TOTAL                                                   31      0     14      0   100%
```

## Block 2

Command: poetry run python -c "import json,sys;d=json.load(open(sys.argv[1]));[print(k,'line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2) if s['num_branches'] else 'n/a') for k,v in d['files'].items() for s in [v['summary']]]" artifacts/python/cov-targeted.json
EXIT_CODE: 0
Output Summary: `scripts\dev_tools\potential_to_issue_filesystem.py line 100.0 branch 100.0`

Baseline-Line: scripts.dev_tools.potential_to_issue_filesystem 100.0
Baseline-Branch: scripts.dev_tools.potential_to_issue_filesystem 100.0

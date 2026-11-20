# Python Derived Coverage Baseline (P0-T11)

Timestamp: 2026-09-30T14-19
Command: poetry run python -c "import json; d=json.load(open('artifacts/python/coverage-523-baseline.json', encoding='utf-8')); [print(k, v['summary']['covered_lines'], v['summary']['num_statements'], v['summary']['covered_branches'], v['summary']['num_branches']) for k, v in d['files'].items() if k.replace(chr(92), '/').endswith('dev_tools/validate_orchestrator_state.py')]"
EXIT_CODE: 0
Output Summary: Exactly one line printed: `scripts\dev_tools\validate_orchestrator_state.py 168 170 80 82`.
- Line percent (covered_lines/num_statements): 168/170 = 98.82%
- Branch percent (covered_branches/num_branches): 80/82 = 97.56%

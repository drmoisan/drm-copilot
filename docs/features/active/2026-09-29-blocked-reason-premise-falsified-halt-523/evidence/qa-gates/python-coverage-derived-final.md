# Python Derived Coverage Final QA (P8-T6)

Timestamp: 2026-09-30T15-43
Command: poetry run python -c "import json; d=json.load(open('artifacts/python/coverage-523-final.json', encoding='utf-8')); [print(k, s['covered_lines'], s['num_statements'], s['covered_branches'], s['num_branches'], s['missing_lines']) for k, s in ((k, v['summary'] | {'missing_lines': v['missing_lines']}) for k, v in d['files'].items()) if 'orchestrator_state_blocked_reason' in k or k.endswith('validate_orchestrator_state.py')]"
EXIT_CODE: 0
Output Summary:
- `scripts\dev_tools\_orchestrator_state_blocked_reason.py 15 15 8 8 []`
  - Line: 15/15 = 100.00% (>= 85: PASS); Branch: 8/8 = 100.00% (>= 75: PASS)
- `scripts\dev_tools\validate_orchestrator_state.py 168 170 80 82 [116, 130]`
  - Line: 168/170 = 98.82% (>= 85: PASS); Branch: 80/82 = 97.56% (>= 75: PASS)
  - missing_lines: [116, 130]
- Loop iteration 2 (restart after remediation cycle 1; supersedes the iteration 1 artifact).

# Python Remediation Module Derived Coverage Final (P8-T7)

Timestamp: 2026-10-01T22-44
Task: P8-T7
Loop iteration: 2

Command: poetry run python -c "import json; d=json.load(open('artifacts/python/coverage-484-final.json', encoding='utf-8')); [print(k, v['summary']['covered_lines'], v['summary']['num_statements'], v['summary']['covered_branches'], v['summary']['num_branches'], v['missing_lines']) for k, v in d['files'].items() if 'orchestrator_state_remediation' in k.replace(chr(92), '/')]"
EXIT_CODE: 0
Output: `scripts\dev_tools\_orchestrator_state_remediation_loop.py 138 138 73 74 []`

## Output Summary:

- One printed line (one measured module; no Python split).
- Line: covered_lines 138 / num_statements 138 = 1.0000 (100.00%), at least 0.85.
- Branch: covered_branches 73 / num_branches 74 = 0.9865 (98.65%), at least 0.75.
- missing_lines: none. The single partial branch is `141->154`.
- Result: PASS.

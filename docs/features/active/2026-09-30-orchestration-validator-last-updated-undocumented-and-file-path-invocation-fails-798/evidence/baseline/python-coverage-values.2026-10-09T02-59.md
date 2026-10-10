# P0-T13 Baseline Numeric Coverage Values

Timestamp: 2026-10-09T02-59 (corrected to the host-clock reading; the value first written was composed and ahead of the clock)
Command: poetry run python -S -c "import json, pathlib; d = json.loads(pathlib.Path('artifacts/python/coverage-798.json').read_text(encoding='utf-8')); f = next(v for k, v in d['files'].items() if k.replace(chr(92), '/').endswith('scripts/dev_tools/validate_orchestration_artifacts.py')); s = f['summary']; t = d['totals']; print('FILE_LINE', round(100 * s['covered_lines'] / s['num_statements'], 2), 'FILE_BRANCH', round(100 * s['covered_branches'] / s['num_branches'], 2), 'TOTAL_LINE', round(t['percent_statements_covered'], 2), 'TOTAL_BRANCH', round(t['percent_branches_covered'], 2))"
EXIT_CODE: 0
Output Summary:
- Printed: `FILE_LINE 97.3 FILE_BRANCH 92.86 TOTAL_LINE 93.67 TOTAL_BRANCH 87.09`
- BASELINE_FILE_LINE = 97.3
- BASELINE_FILE_BRANCH = 92.86
- BASELINE_TOTAL_LINE = 93.67
- BASELINE_TOTAL_BRANCH = 87.09
- Thresholds: file line >= 85 and file branch >= 75 hold; no stop.
- OPERATOR_OVERRIDE: `-S` added to the plan's `poetry run python -c` command (operator override 2).

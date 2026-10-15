# P6-T8 Final Numeric and Changed-Line Coverage

Timestamp: 2026-10-09T03-12
Command: poetry run python -S -c "import json, pathlib; d = json.loads(pathlib.Path('artifacts/python/coverage-798.json').read_text(encoding='utf-8')); f = next(v for k, v in d['files'].items() if k.replace(chr(92), '/').endswith('scripts/dev_tools/validate_orchestration_artifacts.py')); s = f['summary']; t = d['totals']; print('FILE_LINE', round(100 * s['covered_lines'] / s['num_statements'], 2), 'FILE_BRANCH', round(100 * s['covered_branches'] / s['num_branches'], 2), 'TOTAL_LINE', round(t['percent_statements_covered'], 2), 'TOTAL_BRANCH', round(t['percent_branches_covered'], 2), 'MISSING_16_TO_19', [n for n in f['missing_lines'] if 16 <= n <= 19], 'EXECUTED_17', 17 in f['executed_lines'])"
EXIT_CODE: 0
Output Summary:
- Loop iteration: 1
- Printed: `FILE_LINE 97.99 FILE_BRANCH 92.86 TOTAL_LINE 93.68 TOTAL_BRANCH 87.09 MISSING_16_TO_19 [] EXECUTED_17 True`
- FINAL_FILE_LINE = 97.99 (>= 85; >= BASELINE 97.3)
- FINAL_FILE_BRANCH = 92.86 (>= 75; >= BASELINE 92.86)
- FINAL_TOTAL_LINE = 93.68
- FINAL_TOTAL_BRANCH = 87.09
- MISSING_16_TO_19 [] and EXECUTED_17 True: every changed executable line is covered
- OPERATOR_OVERRIDE: `-S` added to the plan's `poetry run python -c` command (operator override 2).
- Result: PASS

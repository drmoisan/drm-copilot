# P0-T16 Baseline Python Coverage Values

Timestamp: 2026-10-09T22-55
Command: poetry run python -c "import json, pathlib; t = json.loads(pathlib.Path('artifacts/python/coverage.json').read_text(encoding='utf-8'))['totals']; print('LINE', round(t['percent_statements_covered'], 2), 'BRANCH', round(t['percent_branches_covered'], 2), 'COMBINED', round(t['percent_covered'], 2))"
EXIT_CODE: 0
Output Summary:
- "LINE 93.68 BRANCH 87.1 COMBINED 91.93"
- BASE_PY_LINE: 93.68
- BASE_PY_BRANCH: 87.1
- BASE_PY_COMBINED: 91.93
- Result: PASS (numeric values)

# P0-T12 Baseline numeric Python line and branch coverage

Timestamp: 2026-10-03T09-23
Command: poetry run python -c "import json, pathlib; t = json.loads(pathlib.Path('artifacts/python/coverage.json').read_text(encoding='utf-8'))['totals']; print('LINE', round(t['percent_statements_covered'], 2), 'BRANCH', round(t['percent_branches_covered'], 2), 'COMBINED', round(t['percent_covered'], 2))"
EXIT_CODE: 0
Output Summary:
- "LINE 93.63 BRANCH 86.93 COMBINED 91.85"
- BASELINE_LINE: 93.63
- BASELINE_BRANCH: 86.93
- BASELINE_COMBINED: 91.85
- Source report: artifacts/python/coverage.json from P0-T11
- Result: PASS

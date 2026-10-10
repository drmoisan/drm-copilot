# P9-T11 Post-Change Python Coverage Values

Timestamp: 2026-10-10T00-15
Command: poetry run python -c "import json, pathlib; t = json.loads(pathlib.Path('artifacts/python/coverage.json').read_text(encoding='utf-8'))['totals']; print('LINE', round(t['percent_statements_covered'], 2), 'BRANCH', round(t['percent_branches_covered'], 2), 'COMBINED', round(t['percent_covered'], 2))"
EXIT_CODE: 0
Output Summary:
- Loop iteration: 1
- Output: "LINE 93.68 BRANCH 87.1 COMBINED 91.93"
- FINAL_PY_LINE 93.68 (>= 85 and >= BASE_PY_LINE 93.68). Met.
- FINAL_PY_BRANCH 87.1 (>= 75 and >= BASE_PY_BRANCH 87.1). Met.
- FINAL_PY_COMBINED 91.93
- Python new/changed-code coverage: N/A - no production Python line changed
- Result: PASS

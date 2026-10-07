# P0-T25 Baseline Coverage Totals

Timestamp: 2026-10-02T03-18
Command: poetry run python -c "import json,pathlib; t=json.loads(pathlib.Path('artifacts/python/coverage-baseline.json').read_text(encoding='utf-8'))['totals']; print(t['percent_statements_covered'], t['percent_branches_covered'])"
EXIT_CODE: 0
Output Summary: Printed `93.52893424562217 86.76187419768935`. Baseline line percent 93.53; baseline branch percent 86.76.

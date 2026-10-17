# P8-T13 Final Coverage Totals (pass 2)

Timestamp: 2026-10-02T03-41
Command: poetry run python -c "import json,pathlib; t=json.loads(pathlib.Path('artifacts/python/coverage.json').read_text(encoding='utf-8'))['totals']; print(t['percent_statements_covered'], t['percent_branches_covered'])"
EXIT_CODE: 0
Output Summary: Printed `93.60607965259128 86.88706105662764`. Final line percent 93.61; final branch percent 86.89.

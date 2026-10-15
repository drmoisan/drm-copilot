# P8-T10 CLI-Module Line and Branch Values

Timestamp: 2026-10-02T03-37
Command: poetry run python -c "import json,pathlib; t=json.loads(pathlib.Path('artifacts/python/coverage-check-quality-tiers.json').read_text(encoding='utf-8'))['totals']; print(t['percent_statements_covered'], t['percent_branches_covered'])"
EXIT_CODE: 0
Output Summary: Printed `100.0 91.66666666666667`. scripts/dev_tools/check_quality_tiers.py line coverage 100.0 (>= 85) and branch coverage 91.67 (>= 75).

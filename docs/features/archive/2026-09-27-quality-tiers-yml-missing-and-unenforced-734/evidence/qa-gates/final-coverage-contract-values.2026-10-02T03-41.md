# P8-T7 Contract-Module Line and Branch Values (pass 2)

Timestamp: 2026-10-02T03-41
Command: poetry run python -c "import json,pathlib; t=json.loads(pathlib.Path('artifacts/python/coverage-quality-tiers-contract.json').read_text(encoding='utf-8'))['totals']; print(t['percent_statements_covered'], t['percent_branches_covered'])"
EXIT_CODE: 0
Output Summary: Printed `98.42931937172774 96.15384615384616`. Line 98.43 (>= 85), branch 96.15 (>= 75).

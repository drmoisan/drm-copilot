# P8-T7 Contract-Module Line and Branch Values

Timestamp: 2026-10-02T03-37
Command: poetry run python -c "import json,pathlib; t=json.loads(pathlib.Path('artifacts/python/coverage-quality-tiers-contract.json').read_text(encoding='utf-8'))['totals']; print(t['percent_statements_covered'], t['percent_branches_covered'])"
EXIT_CODE: 0
Output Summary: Printed `98.42931937172774 96.15384615384616`. scripts/dev_tools/quality_tiers_contract.py line coverage 98.43 (>= 85) and branch coverage 96.15 (>= 75).

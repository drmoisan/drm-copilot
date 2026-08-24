# Final QC — Pytest with Coverage

Timestamp: 2026-07-18T11-12
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0

Output Summary: PASS. 1713 passed, 0 failed.

Post-change coverage headline (TOTAL row): Stmts=11388, Miss=1336, Branch=4254, BrPart=550, combined Cover=86%.
- Post-change total line coverage: (11388-1336)/11388 = 88.27%.
- Post-change total branch coverage: (4254-550)/4254 = 87.07%.
- Combined reported total: 86%.

Per-module coverage for scripts/dev_tools/generate_acceptance_scenarios.py:
- Stmts=186, Miss=0, Branch=42, BrPart=0, Cover=100%.
- Module line coverage: 100.00%.
- Module branch coverage: 100.00%.

Thresholds (line >= 85%, branch >= 75%) are met at both the total and per-module level.

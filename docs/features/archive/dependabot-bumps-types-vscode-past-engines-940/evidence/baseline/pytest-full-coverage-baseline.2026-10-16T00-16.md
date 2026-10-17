# Full-suite coverage baseline (P0-T6)

Timestamp: 2026-10-16T00-16
Command: poetry run pytest --cov=src --cov=scripts.dev_tools --cov-report=term-missing --cov-branch --cov-report=json:SCRATCH/940/coverage-baseline.json
EXIT_CODE: 0
Output Summary:
- (a) Final pytest line: 7094 passed, 6 skipped in 178.62s (0:02:58); failed count 0.
- (b) TOTAL row (verbatim): `TOTAL   17638   1094   6368    504    92%` (Stmts 17638, Miss 1094, Branch 6368, BrPart 504, Cover 92%).
- (c) Line percentage computed from the TOTAL row as (17638 - 1094) / 17638 = 93.8%. Computed because the table prints one combined Cover column.
Output captured to SCRATCH/940/pytest-full-baseline.txt.

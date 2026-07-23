# Remediation Baseline — Python Test + Coverage (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

Command: poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term (from repo root)

EXIT_CODE: 0

Output Summary:
- Tests: 1982 passed, 0 failed.
- TOTAL (repo-wide dev_tools context): Stmts 12252, Miss 1114, Branch 4446, BrPart 564, Cover 88%.
- Per-module scripts/dev_tools/potential_to_issue.py (from per-module counts): Stmts 200, Miss 18, Branch 66, BrPart 21, combined Cover 85%.
  - Per-module line coverage: (200-18)/200 = 182/200 = 91.00%.
  - Per-module branch coverage: (66-21)/66 = 45/66 = 68.18% (BELOW the 75% floor at baseline; R2 target).
- These per-module figures are derived from the module's own Stmts/Miss/Branch/BrPart counts, not the TOTAL row.

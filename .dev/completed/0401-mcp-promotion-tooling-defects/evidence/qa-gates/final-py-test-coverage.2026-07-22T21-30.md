# Final QA — Python Test + Coverage (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

Command: poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term (from repo root)

EXIT_CODE: 0

Output Summary:
- Tests: 1992 passed, 0 failed (baseline 1982 + 10 new branch-coverage cases).
- TOTAL (repo-wide dev_tools context): Stmts 12252, Miss 1105, Branch 4446, BrPart 554, Cover 89%.
- Per-module scripts/dev_tools/potential_to_issue.py: Stmts 200, Miss 10, Branch 66, BrPart 12, combined Cover 92%.
  - Per-module line coverage: (200-10)/200 = 190/200 = 95.00% (>= 85%). PASS.
  - Per-module branch coverage: (66-12)/66 = 54/66 = 81.82% (>= 75%). PASS.
- Per-module figures are derived from the module's own counts, not the TOTAL row.
- Clean single pass following format/lint/type-check in the same loop.

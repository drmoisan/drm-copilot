# Python Per-Module Branch Coverage Verification — potential_to_issue.py (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

Command: poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term (from repo root)

EXIT_CODE: 0

Output Summary:
- Tests: 1992 passed (baseline 1982 + 10 new branch-coverage cases), 0 failed.
- Per-module scripts/dev_tools/potential_to_issue.py row: Stmts 200, Miss 10, Branch 66, BrPart 12, Cover 92%.
- Per-module branch coverage (from per-module counts): (66 - 12) / 66 = 54/66 = 81.82%.
- Threshold: >= 50/66 = 75.76% (>= 75%). VERDICT: PASS (54/66 = 81.82% >= 75%).
- Per-module line coverage: (200 - 10) / 200 = 190/200 = 95.00% (>= 85%). PASS.
- Baseline branch was 45/66 = 68.18%; the +9 additional branch arcs (45 -> 54) clear the floor.
- This figure is computed from the module's own per-module counts, not the TOTAL row.

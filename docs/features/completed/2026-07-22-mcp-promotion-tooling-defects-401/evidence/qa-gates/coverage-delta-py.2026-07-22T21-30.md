# Coverage Delta — Python (CORRECTED) (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

Compared commands:
- Baseline (P0-T10): poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term
- Post-change (P3-T8): poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term

EXIT_CODE: 0

## AC-11 Threshold Verdict — PER-MODULE scripts/dev_tools/potential_to_issue.py

The AC-11 threshold verdict is computed strictly from the changed module's own per-module counts, NOT the TOTAL row. This corrects the evidence-accuracy defect in coverage-delta-py.2026-07-22T20-17.md line 15, which computed the branch check against the overall measured set (87.3%) instead of the changed module.

Per-module potential_to_issue.py row:
- Baseline: Stmts 200, Miss 18, Branch 66, BrPart 21 -> line 182/200 = 91.00%, branch 45/66 = 68.18%.
- Post-change: Stmts 200, Miss 10, Branch 66, BrPart 12 -> line 190/200 = 95.00%, branch 54/66 = 81.82%.

- Per-module BRANCH coverage: 54/66 = 81.82%. Threshold >= 50/66 = 75.76% (>= 75%). VERDICT: PASS.
- Per-module LINE coverage: 190/200 = 95.00%. Threshold >= 85%. VERDICT: PASS.
- Delta: branch +9 arcs (45 -> 54, 68.18% -> 81.82%); line +8 statements (182 -> 190, 91.00% -> 95.00%). No regression on any previously-covered line or branch.

## TOTAL row (repo-wide dev_tools context ONLY — not used for the AC-11 verdict)

- Baseline TOTAL: Stmts 12252, Miss 1114, Branch 4446, BrPart 564, Cover 88%.
- Post-change TOTAL: Stmts 12252, Miss 1105, Branch 4446, BrPart 554, Cover 89%.
- The TOTAL row is repo-wide context only. The AC-11 verdict above is tied exclusively to the per-module potential_to_issue.py counts.

Tests: 1982 baseline -> 1992 post-change (+10 new branch-coverage cases), 0 failed. Full Python toolchain green in a single pass (format, lint, type-check, test).

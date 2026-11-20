# Final QC — Python tests and coverage, Pytest (Issue #500)

Timestamp: 2026-08-22T00:30:00Z
Issue: #500
Task: [P8-T4]

Command:
```
poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
```
(working directory: worktree root; the selection matches [P0-T8] exactly and is NOT narrowed to
named files, so the post-change figure is comparable with the baseline)

EXIT_CODE: 0

Output Summary:

Test counts, from `4076 passed, 5 skipped in 28.09s`:
- passed: **4076**
- failed: **0**
- skipped: **5**

The passed count rose from the Phase 0 baseline of 4062 by 14, which is exactly the 14 cases in
`tests/scripts/dev_tools/test_blast_radius_config_parity.py`. That module is inside this selection;
its own targeted run is recorded separately by [P6-T14] at
`evidence/qa-gates/phase6-python-gate.2026-08-22T00-04.md`.

Coverage, two distinct figures from two different sources:

| Figure | Value | Source |
| --- | --- | --- |
| Statement coverage | **92.60%** | `TOTAL` row of the terminal report, `(Stmts - Miss) / Stmts` = `(14939 - 1105) / 14939` = 92.6033%. Cross-checked against `totals.percent_statements_covered` = 92.6032532298012 in `artifacts/python/coverage.json`. |
| Branch coverage | **85.19%** | `totals.percent_branches_covered` = 85.18586005830903 in `artifacts/python/coverage.json`. |

The `TOTAL` row reads `14939  1105  5488  559  91%` for `Stmts / Miss / Branch / BrPart / Cover`.
The combined `Cover` cell of 91% is deliberately NOT recorded as either figure: under
`--cov-branch` it is the combined statements-plus-branches ratio (`totals.percent_covered` =
90.6105%). `BrPart` is `num_partial_branches` (559), not `missing_branches` (813), so
`(Branch - BrPart) / Branch` = 89.81% is a different and wrong quantity.

Threshold status: statement 92.60% >= 85% and branch 85.19% >= 75%. Both thresholds in
`.claude/rules/quality-tiers.md` are met.

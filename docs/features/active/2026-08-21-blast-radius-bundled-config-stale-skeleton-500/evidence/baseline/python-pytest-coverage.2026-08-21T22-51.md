# Python test and coverage baseline — Pytest (Issue #500)

Timestamp: 2026-08-21T22:51:10Z
Issue: #500
Task: [P0-T8]

Command:
```
poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
```
(working directory: worktree root; whole-suite selection, NOT narrowed to named files)

EXIT_CODE: 0

Output Summary:

Test counts, from the pytest summary line `4062 passed, 5 skipped in 28.54s`:
- passed: **4062**
- failed: **0**
- skipped: **5**

Coverage, two distinct figures from two different sources:

| Figure | Value | Source |
| --- | --- | --- |
| Statement coverage | **92.60%** | `TOTAL` row of the terminal report, computed as `(Stmts - Miss) / Stmts` = `(14939 - 1105) / 14939` = 92.6033%. Cross-checked against `totals.percent_statements_covered` = 92.6032532298012 in `artifacts/python/coverage.json`. |
| Branch coverage | **85.19%** | `totals.percent_branches_covered` = 85.18586005830903 in `artifacts/python/coverage.json`. |

The `TOTAL` row of the terminal report reads
`14939  1105  5488  559  91%` for `Stmts / Miss / Branch / BrPart / Cover`. The single combined
`Cover` cell of 91% is deliberately NOT recorded as either figure above: under `--cov-branch` that
cell is the combined statements-plus-branches ratio (`totals.percent_covered` = 90.6105%,
displayed as 91), and it is not the quantity the 75% branch gate is written against. The `TOTAL` row
yields no branch figure at all, because `BrPart` is `num_partial_branches` (559), not
`missing_branches` (813), so `(Branch - BrPart) / Branch` = 89.81% is a different and wrong
quantity. The branch figure is therefore read from the JSON report only.

Threshold status at baseline: statement 92.60% >= 85% and branch 85.19% >= 75%. Both thresholds in
`.claude/rules/quality-tiers.md` are met before the change.

The `--cov-report=json:artifacts/python/coverage.json` destination is a gitignored tool-output path
already used by the existing `addopts` for `artifacts/python/lcov.info`. It is not an evidence path;
no evidence is written there. This artifact is the evidence, and it resides at the canonical
`<FEATURE>/evidence/baseline/` location.

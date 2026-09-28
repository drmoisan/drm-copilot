# Coverage Delta and Threshold Verification

- Task: [P2-T6]
- Feature: 2026-08-07-parallel-cohort-scheduler-445 (issue #445)

Timestamp: 2026-08-07T14-39
Command: poetry run coverage json -o -
EXIT_CODE: 0

Output Summary:
- Three numeric coverage sets recorded below (baseline, post-change total, new module).
- All four threshold verdicts are PASS. No regression: both total figures increased relative to the
  Phase 0 baseline, and both remain above the repository thresholds.

## Source of Each Coverage Set

| Set | Source |
|---|---|
| Baseline | `evidence/baseline/baseline-pytest.2026-08-07T14-24.md` ([P0-T5], JSON-derived) |
| Post-change total | Coverage data written by the [P2-T4] run of `poetry run pytest --cov --cov-branch --cov-report=term-missing`, read via `poetry run coverage json -o -` within this task |
| New module | Same coverage data, `files["scripts\\dev_tools\\parallel_cohort_computation.py"].summary` |

## Set 1 — Baseline (Phase 0, [P0-T5])

| Metric | Value |
|---|---|
| Total line (statement) coverage | **91.02%** (91.02000976085895) |
| Total branch coverage | **81.91%** (81.91393993724787) |
| Tests | 2149 passed |

## Set 2 — Post-Change Total (Phase 2, [P2-T4])

| Metric | Value |
|---|---|
| Total line (statement) coverage | **91.06%** (91.06289970047762) |
| Total branch coverage | **82.00%** (82.00267618198038) |
| `totals.num_statements` / `missing_lines` | 12353 / 1104 |
| `totals.num_branches` / `missing_branches` | 4484 / 807 |
| Tests | 2187 passed |

## Set 3 — New Module `scripts/dev_tools/parallel_cohort_computation.py`

| Metric | Value |
|---|---|
| Line (statement) coverage | **100.00%** (100.0) |
| Branch coverage | **100.00%** (100.0) |
| `summary.num_statements` / `missing_lines` | 59 / 0 |
| `summary.num_branches` / `missing_branches` | 22 / 0 |

## Delta (Baseline -> Post-Change)

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Total line coverage | 91.02000976085895% | 91.06289970047762% | **+0.0429 pp** |
| Total branch coverage | 81.91393993724787% | 82.00267618198038% | **+0.0887 pp** |
| Tests passed | 2149 | 2187 | +38 |

## Threshold Verdicts

Thresholds per `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`:
line coverage >= 85%, branch coverage >= 75%, and no regression below those thresholds.

| # | Threshold | Measured | Verdict |
|---|---|---|---|
| 1 | New module line coverage >= 85% | 100.00% | **PASS** |
| 2 | New module branch coverage >= 75% | 100.00% | **PASS** |
| 3 | Total line coverage not regressed below 85% | 91.06% (baseline 91.02%, delta +0.0429 pp) | **PASS** |
| 4 | Total branch coverage not regressed below 75% | 82.00% (baseline 81.91%, delta +0.0887 pp) | **PASS** |

Overall coverage verdict: **PASS**. No required coverage value was unavailable and no value is below
threshold, so no remediation is required on coverage grounds.

## Explicit exclusion of the combined `Cover` column

The `--cov-report=term-missing` `TOTAL` row reported `89%`. That value is `totals.percent_covered`,
a combined line-plus-branch figure, and is **not** recorded as the line-coverage value anywhere in
this artifact. Every line-coverage figure above is `percent_statements_covered` and every
branch-coverage figure is `percent_branches_covered`, both read from the coverage JSON.

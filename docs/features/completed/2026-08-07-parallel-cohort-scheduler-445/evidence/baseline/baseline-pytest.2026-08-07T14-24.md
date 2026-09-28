# Baseline — Pytest and Coverage

Timestamp: 2026-08-07T14-24

Task: [P0-T5]
Plan: `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/plan.2026-08-07T11-11.md`
Branch: `feature/parallel-cohort-scheduler-445`
Working directory: repository worktree root

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing

EXIT_CODE: 0

Output Summary:
2149 tests passed, 0 failed, 0 errors, 0 skipped, in 12.81s (pytest 9.0.2, Python 3.13.12,
pytest-cov 7.0.0, configfile `pyproject.toml`, testpaths `tests`).

Baseline total coverage, derived from the coverage data written by the command above:

- Total line (statement) coverage: **91.02%** (`totals.percent_statements_covered` = 91.02000976085895)
- Total branch coverage: **81.91%** (`totals.percent_branches_covered` = 81.91393993724787)

Both figures are at or above the repository thresholds of >= 85% line and >= 75% branch
(`.claude/rules/quality-tiers.md`). No pre-existing test failures and no pre-existing coverage
shortfall were observed at the repository total level.

## Coverage Derivation (performed within this task)

The numeric percentages above were derived by running the following against the coverage data file
written by the pytest command in this same task:

```
poetry run coverage json -o -
```

The relevant `totals` fields read from that JSON:

| Field | Value |
|---|---|
| `totals.percent_statements_covered` | 91.02000976085895 |
| `totals.percent_branches_covered` | 81.91393993724787 |
| `totals.num_statements` | 12294 |
| `totals.missing_lines` | 1104 |
| `totals.num_branches` | 4462 |
| `totals.missing_branches` | 807 |
| `totals.percent_covered` (combined) | 88.59513010264979 |

Scope is repository total only; no per-module figure is required for this baseline per the [P0-T5]
acceptance clause.

### Explicit exclusion of the combined `Cover` column

The `--cov-report=term-missing` `TOTAL` row is:

```
TOTAL                                                              12294   1104   4462    553    89%
```

That trailing `89%` is `totals.percent_covered`, a combined line-plus-branch figure. Per the plan
constraint it is **not** recorded as the line-coverage value. The recorded line coverage is the
JSON-derived `percent_statements_covered` of 91.02%, and the recorded branch coverage is the
JSON-derived `percent_branches_covered` of 81.91%.

## Test Result Summary Line

```
============================ 2149 passed in 12.81s ============================
```

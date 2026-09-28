# Final QC — Pytest and Coverage

- Task: [P2-T4]
- Feature: 2026-08-07-parallel-cohort-scheduler-445 (issue #445)

Timestamp: 2026-08-07T14-39
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0

Output Summary:
- 2187 tests passed, 0 failed, 0 errors, 0 skipped, in 9.06s (pytest 9.0.2, Python 3.13.12,
  pytest-cov 7.0.0, configfile `pyproject.toml`, testpaths `tests`).
- Post-change repository total coverage, derived from the coverage data written by the command above:
  - Total line (statement) coverage: **91.06%** (`totals.percent_statements_covered` = 91.06289970047762)
  - Total branch coverage: **82.00%** (`totals.percent_branches_covered` = 82.00267618198038)
- New-module coverage for `scripts/dev_tools/parallel_cohort_computation.py`:
  - Line (statement) coverage: **100.00%** (`percent_statements_covered` = 100.0)
  - Branch coverage: **100.00%** (`percent_branches_covered` = 100.0)
- Test gate: PASS. Coverage gate inputs captured; threshold verdicts are recorded in
  `evidence/qa-gates/coverage-delta.2026-08-07T14-39.md` ([P2-T6]).

## Coverage Derivation (performed within this task)

The numeric percentages above were derived by running the following against the coverage data file
written by the pytest command in this same task:

```
poetry run coverage json -o -
```

Fields read from that JSON:

| Scope | Field | Value |
|---|---|---|
| Total | `totals.percent_statements_covered` | 91.06289970047762 |
| Total | `totals.percent_branches_covered` | 82.00267618198038 |
| Total | `totals.num_statements` | 12353 |
| Total | `totals.missing_lines` | 1104 |
| Total | `totals.num_branches` | 4484 |
| Total | `totals.missing_branches` | 807 |
| Total | `totals.percent_covered` (combined) | 88.64999703034982 |
| Module | `files["scripts\\dev_tools\\parallel_cohort_computation.py"].summary.percent_statements_covered` | 100.0 |
| Module | `files["scripts\\dev_tools\\parallel_cohort_computation.py"].summary.percent_branches_covered` | 100.0 |
| Module | `...summary.num_statements` | 59 |
| Module | `...summary.missing_lines` | 0 |
| Module | `...summary.num_branches` | 22 |
| Module | `...summary.missing_branches` | 0 |

### Explicit exclusion of the combined `Cover` column

The `--cov-report=term-missing` rows for the module and the repository total are:

```
scripts\dev_tools\parallel_cohort_computation.py                      59      0     22      0   100%
TOTAL                                                              12353   1104   4484    553    89%
```

The trailing `TOTAL` percentage of `89%` is `totals.percent_covered`, a combined line-plus-branch
figure. Per the plan constraint it is **not** recorded as the line-coverage value. The recorded
total line coverage is the JSON-derived `percent_statements_covered` of 91.06%, and the recorded
total branch coverage is the JSON-derived `percent_branches_covered` of 82.00%.

## Delivered Test Files in This Run

```
tests\scripts\dev_tools\test_parallel_cohort_computation.py ............ [ 59%]
tests\scripts\dev_tools\test_parallel_cohort_computation_errors.py ..... [ 59%]
```

## Test Result Summary Line

```
============================ 2187 passed in 9.06s =============================
```

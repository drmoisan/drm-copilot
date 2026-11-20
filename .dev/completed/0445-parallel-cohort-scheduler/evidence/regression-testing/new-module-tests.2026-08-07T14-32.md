# New-Module Targeted Test and Coverage Run — [P1-T18]

Timestamp: 2026-08-07T14-32

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_cohort_computation.py tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py --cov=scripts.dev_tools.parallel_cohort_computation --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: 38 passed, 0 failed, 0 skipped. Derived module line coverage for `scripts/dev_tools/parallel_cohort_computation.py` is 100.0% (threshold >= 85%, PASS) and derived module branch coverage is 100.0% (threshold >= 75%, PASS). The `--cov` scope was limited to the new module, so the run's total figures equal the module figures: total line 100.0%, total branch 100.0%. The term-missing table reported 59 statements with 0 missed and 22 branches with 0 partial, and no missing lines.

## Coverage Derivation

The `Cover` column of `--cov-report=term-missing` is a combined line-plus-branch figure and is not recorded as the line-coverage value. The numbers below were derived in this same task from the coverage data written by the command above.

Derivation command: `poetry run coverage json -o -`

| Field | Value |
| --- | --- |
| `totals.percent_statements_covered` | 100.0 |
| `totals.percent_branches_covered` | 100.0 |
| `files["scripts\\dev_tools\\parallel_cohort_computation.py"].summary.percent_statements_covered` | 100.0 |
| `files["scripts\\dev_tools\\parallel_cohort_computation.py"].summary.percent_branches_covered` | 100.0 |

## Threshold Verdicts

| Gate | Threshold | Measured | Verdict |
| --- | --- | --- | --- |
| Module line coverage | >= 85% | 100.0% | PASS |
| Module branch coverage | >= 75% | 100.0% | PASS |

## Test Files Executed

- `tests/scripts/dev_tools/test_parallel_cohort_computation.py`
- `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` (added because the [P1-T17] split was applied)

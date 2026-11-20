# Baseline — Python Tests with Coverage — [P0-T5]

Timestamp: 2026-08-23T00-12

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T5]
State captured: PRE-CHANGE baseline

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Why `term-missing` is passed explicitly

The project's `addopts` supplies only an LCOV reporter (`Coverage LCOV written to file
artifacts/python/lcov.info` appears in the run output). Without an explicit terminal reporter no
coverage table is printed at all, so the percentages this task must record would not be
observable. `--cov-report=term-missing` is therefore mandatory on this command and on its
[P8-T4] counterpart.

## TOTAL row, verbatim

```text
TOTAL                                                               14939   1105   5488    559    91%
```

The `term-missing` reporter prints a single combined `Cover` column (91%), not two percentages.
The two figures this task requires are therefore derived from the raw column totals.

## Derived coverage figures

| Figure | Derivation | Columns used | Value |
| --- | --- | --- | --- |
| line coverage | (Stmts - Miss) / Stmts = (14939 - 1105) / 14939 | `Stmts`, `Miss` | **92.60%** |
| branch coverage | (Branch - BrPart) / Branch = (5488 - 559) / 5488 | `Branch`, `BrPart` | **89.81%** |
| combined (printed) | ((Stmts - Miss) + (Branch - BrPart)) / (Stmts + Branch) | all four | 91.85%, printed as 91% |

The combined derivation is shown only to demonstrate that the printed 91% is the combined metric
and not either of the two thresholds' metrics. The uniform thresholds are line >= 85% and
branch >= 75%; both hold at baseline.

## Test counts

| Metric | Count |
| --- | --- |
| passed | 4062 |
| skipped | 5 |
| failed | 0 |

Final summary line, verbatim:

```text
====================== 4062 passed, 5 skipped in 19.39s =======================
```

All five skips are parametrized cases in
`tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` that declare no accessor
expectation; they are pre-existing and unrelated to this item.

## Output Summary

Baseline Python suite is green: exit code 0, 4062 passed, 5 skipped, 0 failed. Baseline line
coverage is 92.60% (derived from Stmts 14939 and Miss 1105) and baseline branch coverage is
89.81% (derived from Branch 5488 and BrPart 559). Both exceed their uniform thresholds.

# Final QA Gate — Pytest with Branch Coverage

Timestamp: 2026-08-08T15-25

Task: [P8-T4]
Working directory: repository root

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: PASS. 2968 tests passed, 0 failed, in 12.35s. Total line coverage is 91.82% (12432 covered of 13539 statements). Total branch coverage is 83.80% (4190 covered of 5000 branches). Both figures exceed the policy thresholds of >= 85% line and >= 75% branch. The two changed Python modules are fully covered: `scripts/dev_tools/parallel_kickoff_contract.py` at 100.00% line and 100.00% branch, and `scripts/dev_tools/_parallel_kickoff_tables.py` at 100.00% line and 100.00% branch.

Test count moved from 2959 at the Phase 0 baseline to 2968, an increase of 9, matching exactly the 9 tests added by the new seam module `tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py`. No test was deleted, skipped, or weakened.

## Numeric Coverage Values

| Scope | Line coverage | Branch coverage |
|---|---|---|
| Repository total | 91.82% (91.8236%) | 83.80% (83.8000%) |
| `scripts/dev_tools/parallel_kickoff_contract.py` | 100.00% | 100.00% |
| `scripts/dev_tools/_parallel_kickoff_tables.py` | 100.00% | 100.00% |

Raw totals: `num_statements=13539`, `covered_lines=12432`, `num_branches=5000`, `covered_branches=4190`.

Per-file raw rows from the `term-missing` table:

```
scripts\dev_tools\_parallel_kickoff_tables.py     72      0     38      0   100%
scripts\dev_tools\parallel_kickoff_contract.py    91      0     26      0   100%
--------------------------------------------------------------------------------
TOTAL                                          13539   1107   5000    556    90%
```

The `TOTAL ... 90%` value is coverage.py's combined statement-plus-branch rate, not the line rate; the separated rates above are derived from the coverage JSON totals.

## Stability of the Measurement

Three consecutive full-suite runs produced identical totals: line 91.8236%, branch 83.8000%, covered_branches 4190. See `evidence/qa-gates/coverage-delta.2026-08-08T15-25.md` for the analysis of the single-branch difference against the Phase 0 measurement.

## Test Counts

- Passed: 2968
- Failed: 0
- Duration: 12.35s

# Remediation Baseline — Pytest with Branch Coverage

Timestamp: 2026-08-08T15-25

Task: [P0-T5]
Working directory: repository root

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: PASS. 2959 tests passed, 0 failed, in 13.35s. Total line coverage is 91.82% (12432 covered of 13539 statements). Total branch coverage is 83.82% (4191 covered of 5000 branches). Both figures exceed the policy thresholds of >= 85% line and >= 75% branch. The changed-module reference files are both fully covered: `scripts/dev_tools/parallel_kickoff_contract.py` at 100.00% line and 100.00% branch, and `scripts/dev_tools/_parallel_kickoff_tables.py` at 100.00% line and 100.00% branch.

## Numeric Coverage Values

| Scope | Line coverage | Branch coverage |
|---|---|---|
| Repository total | 91.82% | 83.82% |
| `scripts/dev_tools/parallel_kickoff_contract.py` | 100.00% | 100.00% |
| `scripts/dev_tools/_parallel_kickoff_tables.py` | 100.00% | 100.00% |

Raw totals: `num_statements=13539`, `covered_lines=12432`, `num_branches=5000`, `covered_branches=4191`, `missing_branches=809`.

Per-file raw rows from the `term-missing` table:

```
scripts\dev_tools\_parallel_kickoff_tables.py     72      0     38      0   100%
scripts\dev_tools\parallel_kickoff_contract.py    91      0     26      0   100%
--------------------------------------------------------------------------------
TOTAL                                          13539   1107   5000    555    90%
```

## Discrepancy Resolution

The prior audit artifacts recorded the repository branch figure as 83.80%. This Phase 0 measurement resolves that to 83.8200% (4191 / 5000), which rounds to 83.82%. The Phase 0 values in this artifact are the authoritative comparison reference for the Phase 8 delta verification.

The `TOTAL ... 90%` value in the terminal table is coverage.py's combined statement-plus-branch rate, not the line rate; the separated line and branch rates above are derived from the coverage JSON totals.

## Test Counts

- Passed: 2959
- Failed: 0
- Duration: 13.35s

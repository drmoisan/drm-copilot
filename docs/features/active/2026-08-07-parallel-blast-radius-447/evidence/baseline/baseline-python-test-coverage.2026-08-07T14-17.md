# Baseline — Python Tests and Coverage (Pytest + coverage.py)

Timestamp: 2026-08-07T14-17

Task: [P0-T5]
Feature: 2026-08-07-parallel-blast-radius-447 (issue #447)
Branch: feature/parallel-blast-radius-447
Working directory: repository root (worktree `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a2857bcb4458f15cf`)

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: 2149 tests passed, 0 failed, 0 errored, 0 skipped, in 11.49s. Baseline total line coverage is 91.02% (11190 of 12294 statements covered; 1104 missing). Baseline total branch coverage is 81.91% (3655 of 4462 branch exits covered; 807 missing; 553 partial branches). Both baseline values exceed the repository thresholds of line >= 85% and branch >= 75%. The combined figure printed on the terminal `TOTAL` row is 89% (coverage.py `percent_covered_display`), which blends statements and branches; the separate line and branch percentages above are the values to compare against in Phase 6.

## Numeric Coverage Baseline

| Metric | Value |
|---|---|
| Total line (statement) coverage | 91.02% |
| Total branch coverage | 81.91% |
| Combined coverage.py `TOTAL` display | 89% |
| Statements | 12294 |
| Statements covered | 11190 |
| Statements missing | 1104 |
| Branch exits | 4462 |
| Branch exits covered | 3655 |
| Branch exits missing | 807 |
| Partial branches | 553 |
| Excluded lines | 371 |

## Test Counts

| Result | Count |
|---|---|
| Passed | 2149 |
| Failed | 0 |
| Errored | 0 |
| Skipped | 0 |
| Collected | 2149 |

## Derivation of the Separate Percentages

The `term-missing` report emits a single blended `TOTAL` percentage. The separate line and branch percentages were read from coverage.py's own totals block, exported with `poetry run coverage json` from the same `.coverage` data file produced by the run above (export written outside the repository, to the session scratchpad, so no repository file was added or modified):

```
covered_branches=3655
covered_lines=11190
missing_branches=807
missing_lines=1104
num_branches=4462
num_partial_branches=553
num_statements=12294
percent_branches_covered=81.91393993724787
percent_covered=88.59513010264979
percent_statements_covered=91.02000976085895
```

## Raw Output (terminal TOTAL row and summary line)

```
TOTAL                                                              12294   1104   4462    553    89%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 2149 passed in 11.49s ============================
```

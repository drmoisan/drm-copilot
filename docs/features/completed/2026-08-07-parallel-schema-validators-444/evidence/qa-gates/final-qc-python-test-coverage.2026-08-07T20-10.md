# Final QC — Python Coverage-Enabled Test (P7-T4)

Timestamp: 2026-08-07T20-10

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e`)

EXIT_CODE: 0

Output Summary: 2835 tests collected, 2835 passed, 0 failed, 0 errored, 0 skipped, completed in
10.18 seconds. Post-change LINE (statement) coverage: **91.71%** (12,247 of 13,354 statements
covered; 1,107 missing). Post-change BRANCH coverage: **83.58%** (4,122 of 4,932 branch exits
covered; 810 missing; 556 partial branches). The `term-missing` TOTAL row displays 90%, which is
coverage.py's combined statements-plus-branches figure (89.52%), not the separate line and branch
percentages; the separate percentages above are the authoritative post-change values for the P7-T9
coverage-delta comparison. Both figures satisfy the uniform repository thresholds (line >= 85%,
branch >= 75%) and both are above the P0-T5 baseline (line 91.32%, branch 82.54%).

## Precise Coverage Totals

| Metric | Value |
| --- | --- |
| Line (statement) coverage | 91.71034895911338% (displayed 92%) |
| Branch coverage | 83.57664233576642% (displayed 84%) |
| Combined coverage.py `percent_covered` | 89.51657005359291% (TOTAL row displays 90%) |
| Covered statements / total statements | 12247 / 13354 |
| Missing statements | 1107 |
| Excluded lines | 383 |
| Covered branch exits / total branch exits | 4122 / 4932 |
| Missing branch exits | 810 |
| Partial branches | 556 |

Threshold check against `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`:
line 91.71% >= 85% (PASS); branch 83.58% >= 75% (PASS).

## Per-New-Module Rows (from the `term-missing` per-file table)

```
scripts\dev_tools\_parallel_state_common.py                          122      0     62      0   100%
scripts\dev_tools\_parallel_state_records.py                          88      0     50      0   100%
scripts\dev_tools\_parallel_state_structures.py                      149      0     86      0   100%
scripts\dev_tools\parallel_manifest_contract.py                       65      0     22      0   100%
scripts\dev_tools\validate_parallel_orchestrator_state.py             82      2     34      2    97%   226, 265
scripts\dev_tools\validate_parallel_planner_state.py                 112      0     46      0   100%
```

Full per-module line/branch derivation is recorded in
`evidence/qa-gates/coverage-delta.2026-08-07T20-30.md` (P7-T9).

## Raw Output — summary lines

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e
configfile: pyproject.toml
testpaths: tests
plugins: anyio-4.12.1, cov-7.0.0
collected 2835 items
...
TOTAL                                                              13354   1107   4932    556    90%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 2835 passed in 10.18s ============================
```

## Derivation of the Separate Line and Branch Percentages

The `term-missing` reporter emits a single combined `Cover` column. To obtain the separate line and
branch percentages required by the plan, the coverage data file produced by the run above was
re-serialized without re-running any test, using the same method as the P0-T5 baseline:

```
poetry run coverage json -o <scratchpad>/py-final-cov.json
```

EXIT_CODE: 0. The report was written outside the repository tree (session scratchpad), so no
repository file was added or modified. Its `totals` block is the source of the figures above:

```json
{
  "covered_lines": 12247,
  "num_statements": 13354,
  "percent_covered": 89.51657005359291,
  "percent_covered_display": "90",
  "missing_lines": 1107,
  "excluded_lines": 383,
  "percent_statements_covered": 91.71034895911338,
  "percent_statements_covered_display": "92",
  "num_branches": 4932,
  "num_partial_branches": 556,
  "covered_branches": 4122,
  "missing_branches": 810,
  "percent_branches_covered": 83.57664233576642,
  "percent_branches_covered_display": "84"
}
```

## Loop Status

Python final-QC stages 1-4 (`black`, `ruff check`, `pyright`, coverage-enabled `pytest`) all
completed with exit code 0 in a single pass with zero file mutations. The Python loop does not
restart.

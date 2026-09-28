# Python Coverage-Enabled Test Baseline — [P0-T5]

Timestamp: 2026-08-07T18-05

Feature: 2026-08-07-parallel-schema-validators-444 (issue #444)
Task: [P0-T5]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e` (repository root)
Branch: `feature/parallel-schema-validators-444`
State captured: PRE-CHANGE baseline

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: 2465 tests collected, 2465 passed, 0 failed, 0 errored, 0 skipped, completed in
13.55 seconds. Baseline LINE (statement) coverage: **91.32%** (11,619 of 12,724 statements covered;
1,105 missing). Baseline BRANCH coverage: **82.54%** (3,820 of 4,628 branch exits covered; 808
missing; 554 partial branches). The `term-missing` TOTAL row displays 89%, which is coverage.py's
combined statements-plus-branches figure (88.98%), not the separate line and branch percentages; the
separate percentages above are the authoritative baseline values for the Phase 7 coverage-delta
comparison. Both figures satisfy the uniform repository thresholds (line >= 85%, branch >= 75%).
No pre-existing test failure was observed.

## Precise Coverage Totals

| Metric | Value |
| --- | --- |
| Line (statement) coverage | 91.31562401760452% (displayed 91%) |
| Branch coverage | 82.54105445116681% (displayed 83%) |
| Combined coverage.py `percent_covered` | 88.97533425541724% (TOTAL row displays 89%) |
| Covered statements / total statements | 11619 / 12724 |
| Missing statements | 1105 |
| Excluded lines | 383 |
| Covered branch exits / total branch exits | 3820 / 4628 |
| Missing branch exits | 808 |
| Partial branches | 554 |

Threshold check against `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`:
line 91.32% >= 85% (PASS); branch 82.54% >= 75% (PASS).

## Raw Output — summary lines

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c400dcb993312e
configfile: pyproject.toml
testpaths: tests
plugins: anyio-4.12.1, cov-7.0.0
collected 2465 items
...
TOTAL                                                              12724   1105   4628    554    89%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 2465 passed in 13.55s ============================
```

## Derivation of the Separate Line and Branch Percentages

The `term-missing` reporter emits a single combined `Cover` column. To obtain the separate line and
branch percentages required by the plan, the existing coverage data file produced by the run above
was re-serialized without re-running any test:

```
poetry run coverage json -o <scratchpad>/py-cov-baseline.json
```

EXIT_CODE: 0. The report was written outside the repository tree (session scratchpad), so no
repository file was added or modified. Its `totals` block is the source of the figures in the table
above:

```json
{
  "covered_lines": 11619,
  "num_statements": 12724,
  "percent_covered": 88.97533425541724,
  "percent_covered_display": "89",
  "missing_lines": 1105,
  "excluded_lines": 383,
  "percent_statements_covered": 91.31562401760452,
  "percent_statements_covered_display": "91",
  "num_branches": 4628,
  "num_partial_branches": 554,
  "covered_branches": 3820,
  "missing_branches": 808,
  "percent_branches_covered": 82.54105445116681,
  "percent_branches_covered_display": "83"
}
```

## Known-Baseline Conditions

- The pytest run writes `artifacts/python/lcov.info` as a configured coverage side effect. This is a
  build output path, not evidence, and is expected to be rewritten by the Phase 7 final-QC test step.
- No pre-existing Python test failure exists on this branch. Any Python test failure observed in a
  later phase is attributable to this feature's changes.

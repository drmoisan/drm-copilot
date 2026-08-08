# Baseline — Python Tests and Coverage (Pytest) (P0-T5)

- **Issue:** #441
- **Feature:** 2026-08-07-parallel-orchestrator-surface-441
- **Task:** [P0-T5]
- **Working directory:** repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)
- **Branch:** `feature/parallel-orchestrator-surface-441`
- **HEAD at capture:** `ee0626e8` (merge of PR #454)

Timestamp: 2026-08-08T16-47

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary:

- **Tests passed: 2968**
- **Tests failed: 0**
- **Errors: 0; skipped: 0; xfailed: 0**
- Collected: 2968 items. Wall time: 14.74s.
- **Baseline line (statement) coverage: 91.82%** (12432 covered / 13539 statements; 1107 missing; 387 excluded).
- **Baseline branch coverage: 83.80%** (4190 covered / 5000 branch destinations; 810 missing; 556 partial branches).
- Combined coverage.py headline figure (statements + branch destinations in one denominator, as printed on the terminal `TOTAL` row): **89.66%**, displayed as `90%`.
- Threshold status at baseline: line 91.82% >= 85% required (PASS); branch 83.80% >= 75% required (PASS).

Environment: platform win32, Python 3.13.12, pytest 9.0.2, pluggy 1.6.0, pytest-cov 7.0.0, anyio 4.12.1. `configfile: pyproject.toml`, `testpaths: tests`. Coverage LCOV side-output written by project configuration to `artifacts/python/lcov.info` (gitignored tool byproduct; not evidence).

Terminal `TOTAL` row and summary line, verbatim:

```
TOTAL                                                              13539   1107   5000    556    90%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 2968 passed in 14.74s ============================
```

Precise line/branch split source: the terminal report prints a single combined `Cover` column, so the separate line and branch percentages above were read from the machine-readable coverage totals rather than derived by hand. Command used to extract them (reads the existing `.coverage` data file; does not re-run tests):

`poetry run coverage json -o <scratchpad>/cov-baseline.json --quiet` (EXIT_CODE: 0)

`totals` block, verbatim:

```json
{
  "covered_lines": 12432,
  "num_statements": 13539,
  "percent_covered": 89.65963644209505,
  "percent_covered_display": "90",
  "missing_lines": 1107,
  "excluded_lines": 387,
  "percent_statements_covered": 91.82362065145136,
  "percent_statements_covered_display": "92",
  "num_branches": 5000,
  "num_partial_branches": 556,
  "covered_branches": 4190,
  "missing_branches": 810,
  "percent_branches_covered": 83.8,
  "percent_branches_covered_display": "84"
}
```

These are the authoritative baseline values for the P6-T5 coverage-delta comparison.

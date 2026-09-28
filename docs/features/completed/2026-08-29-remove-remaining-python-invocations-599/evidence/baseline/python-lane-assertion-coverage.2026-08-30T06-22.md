# Baseline — Python Coverage Over the Reference Module

Timestamp: 2026-08-30T06-22
Task: [P0-T7]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion.py --cov=scripts.dev_tools.parallel_lane_assertion --cov-report=term-missing -p no:cacheprovider` (run from the worktree root)

EXIT_CODE: 0

Output Summary:

- **pytest pass count:** 43 passed, 0 failed. Summary line verbatim: `43 passed in 0.22s`.
- **Collected:** 43 items.
- **Coverage of `scripts/dev_tools/parallel_lane_assertion.py`: 100%** — 143 statements, 0 missed,
  no missing line ranges.

The `term-missing` coverage table, verbatim:

```
Name                                           Stmts   Miss  Cover   Missing
----------------------------------------------------------------------------
scripts\dev_tools\parallel_lane_assertion.py     143      0   100%
----------------------------------------------------------------------------
TOTAL                                            143      0   100%
```

Environment as reported by the run: platform win32, Python 3.13.12, pytest 9.0.2, pytest-cov 7.0.0,
configfile `pyproject.toml`.

## Argument Form

The `--cov` value is the importable dotted module name
`scripts.dev_tools.parallel_lane_assertion`, not a filesystem path. A path spelling such as
`--cov=scripts/dev_tools/parallel_lane_assertion.py` collects no data, which is the defect rules G1
through G3 of `.claude/rules/plan-acceptance-gates.md` report; the dotted form is what makes the
143-statement measurement above real rather than vacuous.

`--cov-report=term-missing` is supplied explicitly because the project `addopts` value at
`pyproject.toml:115` is `-ra --cov-report=lcov:artifacts/python/lcov.info`, which provides an LCOV
reporter only. Verified this pass by reading that line. Without the explicit terminal reporter no
coverage table is printed at all and the numeric percentage recorded above could not be read — the
condition rule G9 reports.

## Bearing on Later Tasks

This module is the Python reference implementation the bash port must match. Its 100% line coverage
and 43 passing cases are the pre-change reference point. This feature does not modify
`scripts/dev_tools/parallel_lane_assertion.py`, so this value is expected to be unchanged at the
final QC loop; a movement here would indicate an unintended edit to the reference module.

# Python Full Test Suite, Pass 1 (P8-T4)

Timestamp: 2026-09-29T17-59
Command: poetry run pytest -q
EXIT_CODE: 0

Output Summary:
- Exit code 0.
- Final summary line: `5472 passed, 6 skipped in 19.06s`
- Passed 5472 (baseline 5340; +132 new tests); Failed 0; Skipped 6 (same six skips as baseline); Errors 0.
- Failing node IDs: none
- Precondition: the gitignored hook state directory `.claude/state/` held no `python-batch-budget.*.json` file at run time (see evidence/regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md for the local-only failure that file causes).

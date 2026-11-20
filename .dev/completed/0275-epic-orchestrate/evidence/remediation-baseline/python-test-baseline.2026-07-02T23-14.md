# Python Test Baseline, with Coverage (Remediation Cycle 1)

- **Timestamp:** 2026-07-02T23-14
- **Task:** [P0-T10]
- **Command:** `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools`
- **EXIT_CODE:** 0

## Output Summary

**1184 passed, 19 skipped, 0 failed** (19 skips are pre-existing `.codex`/`.agents`
gitignore-unavailable-in-CI skips, unrelated to this remediation cycle).

Coverage `TOTAL` row (combined statement + branch, per `coverage.py`'s standard reporting):
`Stmts=9006, Miss=1242, Branch=3242, BrPart=447, Cover=83%`.

This matches the plan's stated baseline of 1184 passed + 19 skipped, 0 failed. This numeric 83%
combined coverage figure is the pre-fix-4/pre-fix-5 baseline against which Phase 4 (test-file
split) and Phase 5 (new `epic_wave_computation` module) changes are compared for regression in
Phase 6.

# Python Pytest Coverage Baseline

Timestamp: 2026-09-03T00-46:00-04:00
Command: poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: 4,382 tests passed and 5 skipped. LINE_COVERAGE is 14,646/15,772 = 92.8607659142785%. BRANCH_COVERAGE is 4,903/5,740 = 85.418118466899%. Both pinned TaskMaster plan fixtures remained unchanged from HEAD, 101,998 bytes each, with SHA-256 `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`.

```text
collected 4387 items
TOTAL 15772 1126 5740 583 91%
Coverage LCOV written to file artifacts/python/lcov.info
4382 passed, 5 skipped in 17.07s

CoveredLines    : 14646
TotalLines      : 15772
LineCoverage    : 92.8607659142785
CoveredBranches : 4903
TotalBranches   : 5740
BranchCoverage  : 85.418118466899
FixtureDiffExit : 0
```

Fixture identity:

```text
claude-to-codex/plan.2026-08-29T12-22.md  Bytes=101998  SHA256=54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f
codex-to-claude/plan.2026-08-29T12-22.md  Bytes=101998  SHA256=54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f
```

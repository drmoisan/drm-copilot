# Python Unit Tests and Coverage — P3-T10

Timestamp: 2026-09-06T00-00
Task: [P3-T10]
Working directory: repository root

Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Pass count: 4384
Skip count: 5
Fail count: 0

Terminal coverage table TOTAL row:

```
TOTAL                                                               15772   1126   5740    583    91%
Coverage LCOV written to file artifacts/python/lcov.info
====================== 4384 passed, 5 skipped in 21.26s =======================
```

The `91%` in the terminal table is pytest-cov's single combined
statement-and-branch column. The separate line and branch percentages the
acceptance condition requires are not printed by that table, so they are
derived from `artifacts/python/lcov.info` by the same summation the Phase 0
baseline used (`LF`/`LH` for lines, `BRF`/`BRH` for branches):

```
CoveredLines    : 14646
TotalLines      : 15772
LINE_COVERAGE   : 92.86076591427846
CoveredBranches : 4903
TotalBranches   : 5740
BRANCH_COVERAGE : 85.41811846689895
```

## Threshold comparison

| Metric | Baseline (P0-T4 artifact) | Final | Result |
| --- | --- | --- | --- |
| Passed | 4382 | 4384 | at or above baseline |
| Skipped | 5 | 5 | unchanged |
| LINE_COVERAGE | 92.8607659142785% | 92.86076591427846% | at baseline |
| BRANCH_COVERAGE | 85.418118466899% | 85.41811846689895% | at baseline |

Both coverage figures are compared against the numeric values recorded in the
Phase 0 artifact rather than a rounded restatement. The final values and the
baseline values are the same rational quantities, 14646/15772 and 4903/5740,
printed to the precision each recorder used; neither metric regressed.

## Fixture identity

Command: `git diff --quiet 8defb1df335efc47063a5f5394faa539e9513bfe -- tests/fixtures/orchestration-handoff/taskmaster-469/claude-to-codex/plan.2026-08-29T12-22.md tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/plan.2026-08-29T12-22.md`
EXIT_CODE: 0
Both TaskMaster plan fixtures are unchanged.

Output Summary: Pytest exited 0 with 4384 passed and 5 skipped, exceeding the
4382-pass baseline at the same skip count. Line coverage is 92.86076591427846%
and branch coverage is 85.41811846689895%, neither below the recorded baseline.
The TaskMaster fixtures remain byte-identical.

# Python Test Baseline — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P0-T5]
Working directory: repo root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`)
HEAD: `bcf2de15`

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Output Summary

- Outcome: **3176 passed**, 0 failed, 0 errored, 0 skipped, in 10.89s.
- Repo-wide line coverage: **92.02%** (12761/13868).
- Repo-wide branch coverage: **84.11%** (4286/5096).
- LCOV written to `artifacts/python/lcov.info`. The repo-wide and per-file figures below were
  recomputed from that LCOV report rather than read off the terminal's rounded single-column
  percentage, so they are directly comparable to the plan's benchmark table.

### Per-File Coverage — the six new drift modules and the modified validator

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | 100.00% (94/94) | 100.00% (32/32) |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 100.00% (66/66) | 100.00% (6/6) |
| `scripts/dev_tools/parallel_drift_halt.py` | 100.00% (42/42) | 100.00% (6/6) |
| `scripts/dev_tools/_parallel_drift_shape.py` | 100.00% (40/40) | 100.00% (20/20) |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | 100.00% (41/41) | 100.00% (18/18) |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | 100.00% (44/44) | 100.00% (14/14) |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 97.62% (82/84) | 94.12% (32/34) |

Every value reproduces the plan's `## Non-Regression Benchmarks` figure exactly. No discrepancy.

### Terminal Tail

```
scripts\dev_tools\parallel_drift_detection.py       94  0  32  0  100%
scripts\dev_tools\parallel_drift_detection_cli.py   66  0   6  0  100%
scripts\dev_tools\parallel_drift_halt.py            42  0   6  0  100%
scripts\dev_tools\validate_parallel_orchestrator_state.py  84  2  34  2  97%   227, 266
TOTAL                                            13868 1107 5096 556  90%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 3176 passed in 10.89s ============================
```

The terminal `TOTAL ... 90%` column is coverage.py's combined statement-and-branch measure and is not
the line-coverage figure; the 92.02% line and 84.11% branch values above are the comparable ones.

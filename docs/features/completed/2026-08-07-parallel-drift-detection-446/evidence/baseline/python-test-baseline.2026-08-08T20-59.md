# Baseline — Python Tests and Coverage (Pytest)

Timestamp: 2026-08-08T20-59

Task: [P0-T5]
Feature: 2026-08-07-parallel-drift-detection-446 (issue #446)
Branch: feature/parallel-drift-detection-446
Integration head at execution: c939b5b8
Working directory: repo root of the feature worktree
Environment: win32, Python 3.13.12, pytest 9.0.2, pytest-cov 7.0.0

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: PASS. 3007 tests collected, 3007 passed, 0 failed, 0 errored, 0 skipped,
0 xfailed, runtime 15.29s. No pre-existing Python test failures at baseline. Coverage
measured over 158 source files. Numeric baseline coverage headline values:
**line coverage = 91.82% (12432 of 13539 lines hit)** and
**branch coverage = 83.80% (4190 of 5000 branch destinations hit)**. The combined
coverage.py `TOTAL` column reports `90%` (13539 statements, 1107 missed, 5000 branches,
556 partial), which is the blended statement-plus-branch figure; the separated line and
branch values above are derived from the LCOV report the same run emitted to
`artifacts/python/lcov.info` and are the authoritative numbers for the Phase 7 coverage-delta
comparison. Both baseline values satisfy the uniform policy thresholds
(line >= 85%, branch >= 75%).

## Numeric Coverage Detail

| Metric | Hit | Total | Percent | Policy threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Line coverage | 12432 | 13539 | 91.82% | >= 85% | meets |
| Branch coverage | 4190 | 5000 | 83.80% | >= 75% | meets |

Derivation command for the separated values (aggregation over the run's own LCOV output,
no re-execution of the test suite):
`awk -F: '/^LF:/{lf+=$2} /^LH:/{lh+=$2} /^BRF:/{brf+=$2} /^BRH:/{brh+=$2} END{...}' artifacts/python/lcov.info`

## Files In This Feature's Production Scope (baseline state)

The three Python modules this feature will add do not exist at baseline and therefore have
no baseline coverage row:

- `scripts/dev_tools/parallel_drift_detection.py` — absent at baseline
- `scripts/dev_tools/parallel_drift_detection_cli.py` — absent at baseline
- `scripts/dev_tools/_parallel_orchestrator_state_drift.py` — absent at baseline

The one existing file this feature will edit has the following baseline coverage row:

```
scripts\dev_tools\validate_parallel_orchestrator_state.py   82   2   34   2   97%   226, 265
```

## Raw Output (session header and final summary)

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44
configfile: pyproject.toml
testpaths: tests
plugins: anyio-4.12.1, cov-7.0.0
collected 3007 items
...
--------------------------------------------------------------------------------------------------------------
TOTAL                                                              13539   1107   5000    556    90%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 3007 passed in 15.29s ============================
```

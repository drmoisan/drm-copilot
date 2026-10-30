# p1t5-tests-pass1

Timestamp: 2026-10-18T05-37
Command: poetry run pytest tests/schemas/discovery tests/discovery_runtime/test_resources.py tests/scripts/dev_tools/test_build_discovery_runtime.py tests/scripts/dev_tools/test_build_discovery_runtime_io.py -q -o addopts= --cov=drm_copilot_discovery.resources --cov=scripts.dev_tools.build_discovery_runtime --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p1t5-coverage.json
EXIT_CODE: 0
Output Summary: ---------------------------------------------------------------------------------------------------------------; TOTAL                                                                 312      0    132      0   100%; Coverage JSON written to file SCRATCH/issue-980-p1t5-coverage.json; 805 passed in 10.99s

Working directory: .
Started: 2026-10-18T05:37:10.475456+00:00
Duration seconds: 12.236
Phase: P1-T5 coverage/inventory/transport schemas; focused task verification.

## Captured output

```text
........................................................................ [  8%]
........................................................................ [ 17%]
........................................................................ [ 26%]
........................................................................ [ 35%]
........................................................................ [ 44%]
........................................................................ [ 53%]
........................................................................ [ 62%]
........................................................................ [ 71%]
........................................................................ [ 80%]
........................................................................ [ 89%]
........................................................................ [ 98%]
.............                                                            [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\resources.py     103      0     34      0   100%
scripts\dev_tools\build_discovery_runtime.py                          209      0     98      0   100%
---------------------------------------------------------------------------------------------------------------
TOTAL                                                                 312      0    132      0   100%
Coverage JSON written to file SCRATCH/issue-980-p1t5-coverage.json
805 passed in 10.99s
```

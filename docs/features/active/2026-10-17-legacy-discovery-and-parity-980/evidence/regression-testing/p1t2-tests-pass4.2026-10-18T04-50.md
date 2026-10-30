# p1t2-tests-pass4

Timestamp: 2026-10-18T04-50
Command: poetry run pytest tests/discovery_runtime tests/scripts/dev_tools/test_build_discovery_runtime.py tests/scripts/dev_tools/test_build_discovery_runtime_io.py -o addopts=-ra --cov=drm_copilot_discovery.resources --cov=scripts.dev_tools.build_discovery_runtime --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p1t2-coverage.json
EXIT_CODE: 0
Output Summary: ---------------------------------------------------------------------------------------------------------------; TOTAL                                                                 312      0    132      0   100%; Coverage JSON written to file SCRATCH/issue-980-p1t2-coverage.json; ============================= 245 passed in 0.71s =============================

Working directory: .
Started: 2026-10-18T04:50:45.076996+00:00
Duration seconds: 1.984
Phase: P1-T2 resource staging; focused task verification.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 245 items

tests\discovery_runtime\test_package_contract.py ....................... [  9%]
........................................................................ [ 38%]
......................................................                   [ 60%]
tests\discovery_runtime\test_resources.py .............................. [ 73%]
...................                                                      [ 80%]
tests\scripts\dev_tools\test_build_discovery_runtime.py ................ [ 87%]
.....................                                                    [ 95%]
tests\scripts\dev_tools\test_build_discovery_runtime_io.py ..........    [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\resources.py     103      0     34      0   100%
scripts\dev_tools\build_discovery_runtime.py                          209      0     98      0   100%
---------------------------------------------------------------------------------------------------------------
TOTAL                                                                 312      0    132      0   100%
Coverage JSON written to file SCRATCH/issue-980-p1t2-coverage.json
============================= 245 passed in 0.71s =============================
```

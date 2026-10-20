Timestamp: 2026-10-20T16-39
Command: `.venv/Scripts/python.exe -m pytest -o addopts= tests/discovery_runtime/test_gateway.py tests/discovery_runtime/test_gateway_local.py tests/discovery_runtime/test_doctor.py tests/discovery_runtime/test_gateway_boundaries.py --cov=drm_copilot_discovery.gateway --cov=drm_copilot_discovery.gateway_local --cov=drm_copilot_discovery.doctor --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\issue-980-p6t1-gateway-contract1-coverage.json`
EXIT_CODE: 0
Output Summary: contract1-tests; exit 0; elapsed 156.692 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 98 items

tests\discovery_runtime\test_gateway.py ................................ [ 32%]
.........                                                                [ 41%]
tests\discovery_runtime\test_gateway_local.py .......................... [ 68%]
..                                                                       [ 70%]
tests\discovery_runtime\test_doctor.py .................                 [ 87%]
tests\discovery_runtime\test_gateway_boundaries.py ............          [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\doctor.py            112      0     28      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\gateway.py           117      0     28      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py     125      1     38      1    99%   130
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                     354      1     94      1    99%
Coverage JSON written to file SCRATCH\issue-980-p6t1-gateway-contract1-coverage.json
======================= 98 passed in 155.84s (0:02:35) ========================

```

# P4-T4 focused-3 tests

Timestamp: 2026-10-19T05-52
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_configuration.py tests/discovery_runtime/analyzer/test_configuration_input.py --cov=drm_copilot_discovery.analyzer.configuration --cov=drm_copilot_discovery.analyzer.configuration_input --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t4-focused-3-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
.............................................................            [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                   Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration.py            68      0     24      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration_input.py     186      3     86      6    97%   169->192, 178->180, 186->192, 280, 341, 344
----------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                    254      3    110      6    98%
Coverage JSON written to file SCRATCH\p4t4-focused-3-coverage.raw.json
61 passed in 37.10s

```

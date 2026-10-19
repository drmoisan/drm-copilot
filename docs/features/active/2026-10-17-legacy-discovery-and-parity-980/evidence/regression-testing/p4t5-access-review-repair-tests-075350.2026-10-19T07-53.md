# P4-T5 review-repair tests

Timestamp: 2026-10-19T07-53
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_filesystem_access.py tests/discovery_runtime/analyzer/test_registry_access.py --cov=drm_copilot_discovery.analyzer.api_access --cov=drm_copilot_discovery.analyzer.api_syntax --cov=drm_copilot_discovery.analyzer.filesystem_access --cov=drm_copilot_discovery.analyzer.registry_access --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t5-access-review-repair-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
........................................................................ [ 40%]
........................................................................ [ 80%]
....................................                                     [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                 Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_access.py             91      0     30      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_syntax.py            115      0     64      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\filesystem_access.py      11      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry_access.py         9      0      0      0   100%
--------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                  226      0     94      0   100%
Coverage JSON written to file SCRATCH\p4t5-access-review-repair-coverage.raw.json
180 passed in 106.54s (0:01:46)

```

# P4-T3 scanners tests

Timestamp: 2026-10-19T04-42
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_csharp_declarations.py tests/discovery_runtime/analyzer/test_event_subscriptions.py tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py --cov=drm_copilot_discovery.analyzer.csharp_declarations --cov=drm_copilot_discovery.analyzer.event_subscriptions --cov=drm_copilot_discovery.analyzer.dotnet_inventory --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t3-scanners-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
........................................................................ [ 64%]
.......................................                                  [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                   Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\csharp_declarations.py     161      0     94      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_inventory.py        137      0     36      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\event_subscriptions.py      47      0     28      0   100%
----------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                    345      0    158      0   100%
Coverage JSON written to file SCRATCH\p4t3-scanners-coverage.raw.json
111 passed in 15.03s

```

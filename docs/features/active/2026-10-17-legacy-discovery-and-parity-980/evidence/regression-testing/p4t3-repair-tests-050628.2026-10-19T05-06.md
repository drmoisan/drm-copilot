# P4-T3 repair tests

Timestamp: 2026-10-19T05-06
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_csharp_declarations.py tests/discovery_runtime/analyzer/test_event_subscriptions.py tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py tests/discovery_runtime/analyzer/test_csharp_declaration_regressions.py --cov=drm_copilot_discovery.analyzer.csharp_declarations --cov=drm_copilot_discovery.analyzer.event_subscriptions --cov=drm_copilot_discovery.analyzer.dotnet_inventory --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t3-repair-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
........................................................................ [ 52%]
.................................................................        [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                   Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\csharp_declarations.py     174      0     98      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_inventory.py        137      0     36      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\event_subscriptions.py      47      0     28      0   100%
----------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                    358      0    162      0   100%
Coverage JSON written to file SCRATCH\p4t3-repair-coverage.raw.json
137 passed in 31.60s

```

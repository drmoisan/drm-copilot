Timestamp: 2026-10-19T02:54:16.411603+00:00
Command: poetry run python -m pytest tests\scripts\dev_tools\discovery\analyzer\test_vsto_office.py tests\scripts\dev_tools\discovery\analyzer\test_stack_neutrality.py tests\scripts\dev_tools\discovery\analyzer\test_stack_cli.py tests\scripts\dev_tools\discovery\analyzer\test_source_text.py tests\scripts\dev_tools\discovery\analyzer\test_pipeline.py tests\scripts\dev_tools\discovery\analyzer\test_models.py tests\scripts\dev_tools\discovery\analyzer\test_inventory_e2e.py tests\scripts\dev_tools\discovery\analyzer\test_inventory.py tests\scripts\dev_tools\discovery\analyzer\test_emitter.py tests\scripts\dev_tools\discovery\analyzer\test_dotnet_inventory.py tests\scripts\dev_tools\discovery\analyzer\test_domain_neutrality.py tests\scripts\dev_tools\discovery\analyzer\test_cli.py tests\discovery_runtime\analyzer\test_repository.py tests\discovery_runtime\analyzer\test_registry.py tests\discovery_runtime\analyzer\test_pipeline.py tests\discovery_runtime\analyzer\test_input_capture.py -q -o addopts= --cov=drm_copilot_discovery.analyzer --cov=scripts.dev_tools.discovery.analyzer.models --cov=scripts.dev_tools.discovery.analyzer.pipeline --cov=scripts.dev_tools.discovery.analyzer.inventory --cov=scripts.dev_tools.discovery.analyzer.emitter --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t1-final-coverage.2026-10-19T02-49.json
EXIT_CODE: 0
Output Summary:

```text
........................................................................ [ 29%]
........................................................................ [ 59%]
........................................................................ [ 88%]
...........................                                              [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                             Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\__init__.py            0      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py            50      0     14      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\findings.py           22      0      2      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\input_capture.py     112      0     46      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py          80      0     22      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\models.py            109      0     24      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py           60      0     10      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry.py           14      0      2      0   100%
scripts\dev_tools\discovery\analyzer\emitter.py                                      2      0      0      0   100%
scripts\dev_tools\discovery\analyzer\inventory.py                                    6      0      0      0   100%
scripts\dev_tools\discovery\analyzer\models.py                                       8      0      0      0   100%
scripts\dev_tools\discovery\analyzer\pipeline.py                                     4      0      0      0   100%
----------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                              467      0    120      0   100%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t1-final-coverage.2026-10-19T02-49.json
243 passed in 269.31s (0:04:29)

```

Exact source/test bytes unchanged: True
Raw command output and hashes: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t1-final-tests-reverse-run-025416.2026-10-19T02-54.json

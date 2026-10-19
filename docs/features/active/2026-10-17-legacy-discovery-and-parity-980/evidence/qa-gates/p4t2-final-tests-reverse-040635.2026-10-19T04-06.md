# P4-T2 final tests-reverse

Timestamp: 2026-10-19T04-06
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_dotnet_projects.py tests/discovery_runtime/analyzer/test_solution_input.py tests/discovery_runtime/analyzer/test_xml_input.py --cov=drm_copilot_discovery.analyzer.xml_input --cov=drm_copilot_discovery.analyzer.solution_input --cov=drm_copilot_discovery.analyzer.dotnet_projects --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/p4t2-final-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Stage 5 of7; exact source bindings, timestamps and raw output hashes are in the adjacent JSON.

```text
........................................................................ [ 36%]
........................................................................ [ 72%]
......................................................                   [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                               Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_projects.py     126      0     50      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\solution_input.py       63      0     34      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\xml_input.py           101      0     32      0   100%
------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                290      0    116      0   100%
Coverage JSON written to file SCRATCH/p4t2-final-coverage.raw.json
198 passed in 41.95s

```

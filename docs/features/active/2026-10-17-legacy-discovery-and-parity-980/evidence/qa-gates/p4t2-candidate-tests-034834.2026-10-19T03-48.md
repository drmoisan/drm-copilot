# P4-T2 candidate-tests

Timestamp: 2026-10-19T03-48
Command: `poetry run pytest -o addopts= tests/discovery_runtime/analyzer/test_xml_input.py tests/discovery_runtime/analyzer/test_solution_input.py tests/discovery_runtime/analyzer/test_dotnet_projects.py --cov=drm_copilot_discovery.analyzer.xml_input --cov=drm_copilot_discovery.analyzer.solution_input --cov=drm_copilot_discovery.analyzer.dotnet_projects --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t2-candidate-coverage.2026-10-19T03-47.json`
EXIT_CODE: 0
Output Summary: Exact diagnostics, timing and source hashes are retained in the adjacent JSON; raw output hashes bind the retained scratch bytes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 150 items

tests\discovery_runtime\analyzer\test_xml_input.py ..................... [ 14%]
................................................                         [ 46%]
tests\discovery_runtime\analyzer\test_solution_input.py ................ [ 56%]
..............................                                           [ 76%]
tests\discovery_runtime\analyzer\test_dotnet_projects.py ............... [ 86%]
....................                                                     [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                               Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_projects.py     126      0     50      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\solution_input.py       63      0     34      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\xml_input.py           101      0     32      0   100%
------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                290      0    116      0   100%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t2-candidate-coverage.2026-10-19T03-47.json
============================ 150 passed in 39.74s =============================

```

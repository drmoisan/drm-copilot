# P4-T2 adapter-tests

Timestamp: 2026-10-19T03-44
Command: `poetry run pytest -o addopts= tests/discovery_runtime/analyzer/test_dotnet_projects.py --cov=drm_copilot_discovery.analyzer.dotnet_projects --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t2-adapter-coverage.2026-10-19T03-43.json`
EXIT_CODE: 0
Output Summary: Exact diagnostics, timing and source hashes are retained in the adjacent JSON; raw output hashes bind the retained scratch bytes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 35 items

tests\discovery_runtime\analyzer\test_dotnet_projects.py ............... [ 42%]
....................                                                     [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                               Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_projects.py     126      0     50      0   100%
------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                126      0     50      0   100%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t2-adapter-coverage.2026-10-19T03-43.json
============================= 35 passed in 39.61s =============================

```

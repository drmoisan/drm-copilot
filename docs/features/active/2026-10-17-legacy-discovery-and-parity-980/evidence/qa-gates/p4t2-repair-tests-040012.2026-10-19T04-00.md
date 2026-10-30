# P4-T2 repair-tests

Timestamp: 2026-10-19T04-00
Command: `poetry run pytest tests/discovery_runtime/analyzer/test_solution_input.py --cov=drm_copilot_discovery.analyzer.solution_input --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t2-repair-coverage.2026-10-19T04-00.json --cov-fail-under=90 -q`
EXIT_CODE: 0
Output Summary: Exact diagnostics, timing and source hashes are retained in the adjacent JSON; raw output hashes bind the retained scratch bytes.

```text
........................................................................ [ 76%]
......................                                                   [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                              Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\solution_input.py      63      0     34      0   100%
-----------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                63      0     34      0   100%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t2-repair-coverage.2026-10-19T04-00.json
Coverage LCOV written to file artifacts/python/lcov.info
Required test coverage of 90% reached. Total coverage: 100.00%
94 passed in 0.17s

```

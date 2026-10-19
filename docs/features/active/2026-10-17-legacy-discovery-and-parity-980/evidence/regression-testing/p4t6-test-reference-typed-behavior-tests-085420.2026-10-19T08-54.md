# P4-T6 typed-behavior tests

Timestamp: 2026-10-19T08-54
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_test_references.py tests/discovery_runtime/analyzer/test_test_reference_syntax.py --cov=drm_copilot_discovery.analyzer.test_references --cov=drm_copilot_discovery.analyzer.test_reference_syntax --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t6-test-reference-typed-behavior-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
........................................................................ [ 53%]
..............................................................           [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                     Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\test_reference_syntax.py      62      1     38      1    98%   55
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\test_references.py           135      2     44      2    98%   317, 351
------------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                      197      3     82      3    98%
Coverage JSON written to file SCRATCH\p4t6-test-reference-typed-behavior-coverage.raw.json
134 passed in 131.70s (0:02:11)

```

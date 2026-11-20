Timestamp: 2026-10-19T02:31:33.961522+00:00
Command: poetry run python -m pytest tests/discovery_runtime/analyzer/test_input_capture.py tests/discovery_runtime/analyzer/test_pipeline.py -q -o addopts= --cov=drm_copilot_discovery.analyzer.input_capture --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p4t1-repair-coverage-run-022728.2026-10-19T02-27.json
EXIT_CODE: 0
Output Summary:

```text
..........................                                               [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                             Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\input_capture.py     112      0     46      0   100%
----------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                              112      0     46      0   100%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p4t1-repair-coverage-run-022728.2026-10-19T02-27.json
26 passed in 245.31s (0:04:05)

```

Elapsed seconds: 245.907702
Source and test bytes unchanged: True

```json
{
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py": "23c07e93bba1c6f15de40994530d7d2cedd6c170df57150ca04b05631c7c4886",
  "tests/discovery_runtime/analyzer/test_input_capture.py": "6b479acd2afb810e727106c1dbff79497f7113067c425a449bb089a33c5ea033",
  "tests/discovery_runtime/analyzer/test_pipeline.py": "bae65907bf98d5168050448b3bcd15c2f3851c2afee4291427ba0bffee1447e0"
}
```

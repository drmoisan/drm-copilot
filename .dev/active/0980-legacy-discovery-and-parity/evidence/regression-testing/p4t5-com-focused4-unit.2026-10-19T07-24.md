# p4t5-com-focused4-unit

Timestamp: 2026-10-19T07-24
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/analyzer/test_com_candidates.py tests/discovery_runtime/analyzer/test_com_interop.py -q --cov=drm_copilot_discovery.analyzer.com_interop --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p4t5-com-coverage.json
EXIT_CODE: 0
Output Summary: PASS scoped COM stage 5; duration 31.431 seconds. Exact bytes and original command output are in the paired JSON.

```text
........................................................................ [ 64%]
.......................................                                  [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\com_interop.py     170      0     74      0   100%
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            170      0     74      0   100%
Coverage JSON written to file SCRATCH/issue-980-p4t5-com-coverage.json
111 passed in 29.70s
```

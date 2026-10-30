# p4t5-com-repair2-unit

Timestamp: 2026-10-19T07-56
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/analyzer/test_com_candidates.py tests/discovery_runtime/analyzer/test_com_interop.py -q --cov=drm_copilot_discovery.analyzer.com_interop --cov=drm_copilot_discovery.analyzer.com_syntax --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p4t5-com-repair-coverage.json
EXIT_CODE: 0
Output Summary: PASS scoped COM stage 5; duration 35.121 seconds. Exact bytes and original command output are in the paired JSON.

```text
........................................................................ [ 52%]
.................................................................        [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\com_interop.py     121      0     46      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\com_syntax.py       85      0     42      0   100%
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            206      0     88      0   100%
Coverage JSON written to file SCRATCH/issue-980-p4t5-com-repair-coverage.json
137 passed in 33.39s
```

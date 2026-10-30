# p3t8-final-unit

Timestamp: 2026-10-19T01-32
Command: poetry run python SCRATCH/issue-980-p3t8-tests.py forward --cov=drm_copilot_discovery.source_reads --cov=drm_copilot_discovery.source_read_models --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t8-final-coverage.json
EXIT_CODE: 0
Output Summary: PASS scoped P3-T8 stage 5; duration 49.459 seconds. Exact source hashes are in the paired JSON receipt.

```text
........................................................................ [ 56%]
.......................................................                  [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                         Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\source_read_models.py     200      0     72      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py           209      0    104      0   100%
------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                          409      0    176      0   100%
Coverage JSON written to file SCRATCH/issue-980-p3t8-final-coverage.json
127 passed in 47.35s
```

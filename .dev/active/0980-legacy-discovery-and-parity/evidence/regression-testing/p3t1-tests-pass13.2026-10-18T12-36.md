# p3t1-tests-pass13

Timestamp: 2026-10-18T12-36
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_mutation_filesystem.py tests/discovery_runtime/test_mutation_plan.py tests/discovery_runtime/test_mutation_commit.py --cov=drm_copilot_discovery.mutation_plan --cov=drm_copilot_discovery.mutation_io --cov=drm_copilot_discovery.mutation_filesystem --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t1-coverage.json -x -q
EXIT_CODE: 0
Output Summary: -------------------------------------------------------------------------------------------------------------------------; TOTAL                                                                           489      5    142      7    98%; Coverage JSON written to file SCRATCH/issue-980-p3t1-coverage.json; 89 passed in 528.23s (0:08:48)

Working directory: .
Started: 2026-10-18T12:28:07.725993+00:00
Duration seconds: 532.057
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
........................................................................ [ 80%]
.................                                                        [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py     209      2     54      3    98%   154->156, 243, 409
packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py             131      1     32      1    99%   365
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py           149      2     56      3    98%   125, 171->170, 358
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           489      5    142      7    98%
Coverage JSON written to file SCRATCH/issue-980-p3t1-coverage.json
89 passed in 528.23s (0:08:48)
```

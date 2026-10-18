# p3t2-batch2-first-run-diagnostic

Timestamp: 2026-10-18T13-17
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_initialization.py -x -q --cov=drm_copilot_discovery.init_flow --cov=drm_copilot_discovery.init_io --cov=drm_copilot_discovery.init_projection --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t2-batch2-coverage.json --cov-branch --cov-fail-under=0
EXIT_CODE: 0
Output Summary: ---------------------------------------------------------------------------------------------------------------------; TOTAL                                                                       413     75    138     47    75%; Coverage JSON written to file SCRATCH/issue-980-p3t2-batch2-coverage.json; 4 passed in 577.45s (0:09:37)

Working directory: .
Started: 2026-10-18T13:07:35.268407+00:00
Duration seconds: 578.805
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
....                                                                     [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                      Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py           137     32     32     12    69%   88, 113, 130, 188->191, 216, 238, 242, 243->251, 251->259, 272, 282, 284->288, 293->295, 303, 326-341, 365-369, 382-390, 392-396, 405->406, 407-424
packages\discovery-runtime\src\drm_copilot_discovery\init_io.py             173     28     66     22    76%   57, 94, 130, 134, 189-192, 227, 251-254, 266, 274, 281, 310, 330, 334->344, 344->366, 345, 346->347, 366->367, 366->375, 387-393, 416, 418->424, 425->exit, 428-429, 430->433, 441->425, 448
packages\discovery-runtime\src\drm_copilot_discovery\init_projection.py     103     15     40     13    79%   82, 84, 92, 94, 112-116, 130, 142, 164, 200, 225, 229, 234, 239
---------------------------------------------------------------------------------------------------------------------
TOTAL                                                                       413     75    138     47    75%
Coverage JSON written to file SCRATCH/issue-980-p3t2-batch2-coverage.json
4 passed in 577.45s (0:09:37)
```

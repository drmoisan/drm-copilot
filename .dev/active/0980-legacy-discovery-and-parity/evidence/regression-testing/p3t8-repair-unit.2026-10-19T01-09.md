# p3t8-repair-unit

Timestamp: 2026-10-19T01-09
Command: poetry run pytest tests/discovery_runtime/test_source_reads.py tests/discovery_runtime/test_source_read_limits.py -o addopts=-ra --cov=drm_copilot_discovery.source_reads --cov=drm_copilot_discovery.source_read_models --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t8-repair-coverage.json
EXIT_CODE: 0
Output Summary: PASS scoped P3-T8 stage 5; duration 41.721 seconds. Exact source hashes are in the paired JSON receipt.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 125 items

tests\discovery_runtime\test_source_reads.py ........................... [ 21%]
...                                                                      [ 24%]
tests\discovery_runtime\test_source_read_limits.py ..................... [ 40%]
........................................................................ [ 98%]
..                                                                       [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                         Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\source_read_models.py     182      0     60      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py           227      1    116      1    99%   141
------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                          409      1    176      1    99%
Coverage JSON written to file SCRATCH/issue-980-p3t8-repair-coverage.json
============================ 125 passed in 40.02s =============================
```

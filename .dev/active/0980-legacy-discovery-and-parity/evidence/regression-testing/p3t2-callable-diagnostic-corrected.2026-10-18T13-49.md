# p3t2-callable-diagnostic-corrected

Timestamp: 2026-10-18T13-49
Command: poetry run python SCRATCH/issue-980-p3t2-units.py targeted13 -o addopts=-ra tests/discovery_runtime/test_initialization.py -k commit_failure_dispositions or capture_rechecks_physical -x -q --durations=5 --cov=drm_copilot_discovery.init_flow --cov=drm_copilot_discovery.init_io --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t2-callable-diagnostic-corrected-coverage.json --cov-fail-under=0
EXIT_CODE: 0
Output Summary: ; (4 durations < 0.005s hidden.  Use -vv to show these durations.); 5 passed, 26 deselected in 12.42s; SOURCE_BINDING_STABLE: True

Working directory: .
Started: 2026-10-18T13:49:32.118061+00:00
Duration seconds: 13.661
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
PYTEST_ARGUMENTS: ["-o", "addopts=-ra", "tests/discovery_runtime/test_initialization.py", "-k", "commit_failure_dispositions or capture_rechecks_physical", "-x", "-q", "--durations=5", "--cov=drm_copilot_discovery.init_flow", "--cov=drm_copilot_discovery.init_io", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:SCRATCH/issue-980-p3t2-callable-diagnostic-corrected-coverage.json", "--cov-fail-under=0"]
.....                                                                    [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py     136     33     36      8    72%   71, 97, 100, 122, 184-187, 271, 312, 322-362, 374-376, 414-415, 423-433, 440-446, 456-458, 473-475
packages\discovery-runtime\src\drm_copilot_discovery\init_io.py       140     97     50      2    26%   95-98, 133->132, 146, 158-161, 177-202, 218-329, 353-398
---------------------------------------------------------------------------------------------------------------
TOTAL                                                                 276    130     86     10    48%
Coverage JSON written to file SCRATCH/issue-980-p3t2-callable-diagnostic-corrected-coverage.json
============================= slowest 5 durations =============================
12.15s setup    tests/discovery_runtime/test_initialization.py::test_commit_failure_dispositions_preserve_guarded_boundary[reconstruction]

(4 durations < 0.005s hidden.  Use -vv to show these durations.)
5 passed, 26 deselected in 12.42s
SOURCE_BINDING_STABLE: True
```

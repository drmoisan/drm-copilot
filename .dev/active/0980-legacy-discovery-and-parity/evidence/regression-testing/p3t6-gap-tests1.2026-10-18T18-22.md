# p3t6-gap-tests1

Timestamp: 2026-10-18T18-22
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_snapshot_import.py -k existing_import_preserves or source_and_target_roles -x -q --cov=drm_copilot_discovery.source_snapshots --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t6-api-gap-coverage.json
EXIT_CODE: 0
Output Summary: ----------------------------------------------------------------------------------------------------------------------; TOTAL                                                                        152     27     52      9    78%; Coverage JSON written to file SCRATCH/issue-980-p3t6-api-gap-coverage.json; 5 passed, 27 deselected in 20.10s

Working directory: .
Started: 2026-10-18T18:22:30.007875+00:00
Duration seconds: 21.341
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
.....                                                                    [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                       Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\source_snapshots.py     152     27     52      9    78%   71, 79, 93, 102, 116, 134-159, 176, 220, 311, 378-379, 396-397, 416, 433
----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                        152     27     52      9    78%
Coverage JSON written to file SCRATCH/issue-980-p3t6-api-gap-coverage.json
5 passed, 27 deselected in 20.10s
```

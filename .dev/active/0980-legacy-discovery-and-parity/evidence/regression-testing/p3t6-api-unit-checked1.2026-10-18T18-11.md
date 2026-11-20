# p3t6-api-unit-checked1

Timestamp: 2026-10-18T18-11
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_snapshot_export.py tests/discovery_runtime/test_snapshot_import.py -k export_projection or export_retains or export_rejects_invalid or export_never or export_repeat or import_verifies_new or import_rejects_foreign or import_respects_custom or public_planner or public_commit -x -q --cov=drm_copilot_discovery.source_snapshots --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t6-api-unit-preparation.json
EXIT_CODE: 0
Output Summary: ----------------------------------------------------------------------------------------------------------------------; TOTAL                                                                        152      9     52      6    92%; Coverage JSON written to file SCRATCH/issue-980-p3t6-api-unit-preparation.json; 33 passed, 32 deselected in 59.01s

Working directory: .
Started: 2026-10-18T18:10:07.166441+00:00
Duration seconds: 60.279
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
.................................                                        [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                       Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\source_snapshots.py     152      9     52      6    92%   155, 202, 220, 307, 334, 341-352
----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                        152      9     52      6    92%
Coverage JSON written to file SCRATCH/issue-980-p3t6-api-unit-preparation.json
33 passed, 32 deselected in 59.01s
```

# p3t6-replica2-coverage

Timestamp: 2026-10-18T18-50
Command: poetry run pytest -o addopts=-ra -q tests/discovery_runtime/test_snapshot_replica_resolution.py --cov=drm_copilot_discovery.references --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\issue-980-p3t6-replica-coverage.json --junitxml=SCRATCH\issue-980-p3t6-replica-tests.xml
EXIT_CODE: 0
Output Summary: ----------------------------------------------------------------------------------------------------------------; TOTAL                                                                  171     81     84     10    42%; Coverage JSON written to file SCRATCH\issue-980-p3t6-replica-coverage.json; 4 passed in 0.22s

Working directory: .
Started: 2026-10-18T18:50:05.117564+00:00
Duration seconds: 1.467
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
....                                                                     [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                 Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\references.py     171     81     84     10    42%   69, 113->111, 115->111, 175->179, 182, 184, 186, 197, 200, 240, 242->245, 256-301, 307-327, 334-363, 368-436
----------------------------------------------------------------------------------------------------------------
TOTAL                                                                  171     81     84     10    42%
Coverage JSON written to file SCRATCH\issue-980-p3t6-replica-coverage.json
4 passed in 0.22s
```

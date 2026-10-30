# p3t1-report-root-pass1-tests

Timestamp: 2026-10-18T11-32
Command: poetry run pytest tests/discovery_runtime/test_validation_modes.py -q -o addopts=-ra --cov=drm_copilot_discovery.validation_inputs --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t1-report-root-coverage.json
EXIT_CODE: 0
Output Summary: -----------------------------------------------------------------------------------------------------------------------; TOTAL                                                                          51      0     22      0   100%; Coverage JSON written to file SCRATCH/issue-980-p3t1-report-root-coverage.json; 38 passed in 151.06s (0:02:31)

Working directory: .
Started: 2026-10-18T11:29:52.521830+00:00
Duration seconds: 152.293
Phase: P3-T1 report-root prerequisite correction; exact two-path verification.

## Captured output

```text
......................................                                   [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\validation_inputs.py      51      0     22      0   100%
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                          51      0     22      0   100%
Coverage JSON written to file SCRATCH/issue-980-p3t1-report-root-coverage.json
38 passed in 151.06s (0:02:31)
```

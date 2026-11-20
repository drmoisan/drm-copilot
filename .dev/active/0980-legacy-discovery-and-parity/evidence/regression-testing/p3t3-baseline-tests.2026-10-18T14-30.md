# p3t3-baseline-tests

Timestamp: 2026-10-18T14-30
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_profile_dimensions.py --cov=drm_copilot_discovery.activation_models --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t3-baseline-coverage.json -q
EXIT_CODE: 0
Output Summary: -----------------------------------------------------------------------------------------------------------------------; TOTAL                                                                          28      0      4      0   100%; Coverage JSON written to file SCRATCH/issue-980-p3t3-baseline-coverage.json; 51 passed in 64.46s (0:01:04)

Working directory: .
Started: 2026-10-18T14:29:15.011706+00:00
Duration seconds: 65.623
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
...................................................                      [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\activation_models.py      28      0      4      0   100%
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                          28      0      4      0   100%
Coverage JSON written to file SCRATCH/issue-980-p3t3-baseline-coverage.json
51 passed in 64.46s (0:01:04)
```

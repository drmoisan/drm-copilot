# p1t10-tests-pass8

Timestamp: 2026-10-18T07-05
Command: poetry run pytest -o addopts= tests/discovery_runtime tests/scripts/dev_tools/discovery tests/scripts/dev_tools/test_validate_discovery_profile.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py --cov=drm_copilot_discovery.profile_v2 --cov=drm_copilot_discovery.profile_models --cov=drm_copilot_discovery.activation_models --cov=drm_copilot_discovery.domain_profile --cov=scripts.dev_tools.validate_discovery_profile --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p1t10-coverage.json -q
EXIT_CODE: 0
Output Summary: -----------------------------------------------------------------------------------------------------------------------; TOTAL                                                                         572      1    152      5    99%; Coverage JSON written to file SCRATCH/issue-980-p1t10-coverage.json; 1008 passed in 312.90s (0:05:12)

Working directory: .
Started: 2026-10-18T07:00:31.689618+00:00
Duration seconds: 314.171
Phase: P1-T10 immutable profile, inherited gates and explicit compatibility; focused task verification.

## Captured output

```text
........................................................................ [  7%]
........................................................................ [ 14%]
........................................................................ [ 21%]
........................................................................ [ 28%]
........................................................................ [ 35%]
........................................................................ [ 42%]
........................................................................ [ 50%]
........................................................................ [ 57%]
........................................................................ [ 64%]
........................................................................ [ 71%]
........................................................................ [ 78%]
........................................................................ [ 85%]
........................................................................ [ 92%]
........................................................................ [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\activation_models.py      28      0      4      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\domain_profile.py        203      1     90      5    98%   89, 357->exit, 363->exit, 432->exit, 438->exit
packages\discovery-runtime\src\drm_copilot_discovery\profile_models.py        173      0     20      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py            150      0     32      0   100%
scripts\dev_tools\validate_discovery_profile.py                                18      0      6      0   100%
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         572      1    152      5    99%
Coverage JSON written to file SCRATCH/issue-980-p1t10-coverage.json
1008 passed in 312.90s (0:05:12)
```

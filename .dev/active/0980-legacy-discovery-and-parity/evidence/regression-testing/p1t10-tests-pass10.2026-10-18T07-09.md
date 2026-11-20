# p1t10-tests-pass10

Timestamp: 2026-10-18T07-09
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_profile_v2.py tests/discovery_runtime/test_profile_dimensions.py tests/discovery_runtime/test_package_contract.py tests/scripts/dev_tools/discovery tests/scripts/dev_tools/test_validate_discovery_profile.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py --cov=drm_copilot_discovery.profile_v2 --cov=drm_copilot_discovery.profile_models --cov=drm_copilot_discovery.activation_models --cov=drm_copilot_discovery.domain_profile --cov=scripts.dev_tools.validate_discovery_profile --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p1t10-coverage.json -q
EXIT_CODE: 0
Output Summary: -----------------------------------------------------------------------------------------------------------------------; TOTAL                                                                         572      1    144      1    99%; Coverage JSON written to file SCRATCH/issue-980-p1t10-coverage.json; 578 passed in 146.92s (0:02:26)

Working directory: .
Started: 2026-10-18T07:07:05.242561+00:00
Duration seconds: 148.122
Phase: P1-T10 immutable profile, inherited gates and explicit compatibility; focused task verification.

## Captured output

```text
........................................................................ [ 12%]
........................................................................ [ 24%]
........................................................................ [ 37%]
........................................................................ [ 49%]
........................................................................ [ 62%]
........................................................................ [ 74%]
........................................................................ [ 87%]
........................................................................ [ 99%]
..                                                                       [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\activation_models.py      28      0      4      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\domain_profile.py        203      1     82      1    99%   89
packages\discovery-runtime\src\drm_copilot_discovery\profile_models.py        173      0     20      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py            150      0     32      0   100%
scripts\dev_tools\validate_discovery_profile.py                                18      0      6      0   100%
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         572      1    144      1    99%
Coverage JSON written to file SCRATCH/issue-980-p1t10-coverage.json
578 passed in 146.92s (0:02:26)
```

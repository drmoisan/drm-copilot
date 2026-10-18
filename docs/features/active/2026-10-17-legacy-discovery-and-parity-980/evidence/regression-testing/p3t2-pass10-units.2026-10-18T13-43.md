# p3t2-pass10-units

Timestamp: 2026-10-18T13-43
Command: poetry run python SCRATCH/issue-980-p3t2-units.py forward10 -o addopts=-ra tests/scripts/dev_tools/discovery/test_init_flow.py tests/scripts/dev_tools/discovery/test_init_cli.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_domain_neutrality.py tests/discovery_runtime/test_initialization_conflicts.py tests/discovery_runtime/test_initialization.py -x -q --cov=drm_copilot_discovery.init_flow --cov=drm_copilot_discovery.init_io --cov=drm_copilot_discovery.init_projection --cov=scripts.dev_tools.discovery.init_flow --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t2-pass10-coverage.json --cov-fail-under=0
EXIT_CODE: 0
Output Summary: TOTAL                                                                       456     11    146      9    97%; Coverage JSON written to file SCRATCH/issue-980-p3t2-pass10-coverage.json; 87 passed in 701.35s (0:11:41); SOURCE_BINDING_STABLE: True

Working directory: .
Started: 2026-10-18T13:32:15.834778+00:00
Duration seconds: 702.656
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
PYTEST_ARGUMENTS: ["-o", "addopts=-ra", "tests/scripts/dev_tools/discovery/test_init_flow.py", "tests/scripts/dev_tools/discovery/test_init_cli.py", "tests/scripts/dev_tools/discovery/test_init_models.py", "tests/scripts/dev_tools/discovery/test_domain_neutrality.py", "tests/discovery_runtime/test_initialization_conflicts.py", "tests/discovery_runtime/test_initialization.py", "-x", "-q", "--cov=drm_copilot_discovery.init_flow", "--cov=drm_copilot_discovery.init_io", "--cov=drm_copilot_discovery.init_projection", "--cov=scripts.dev_tools.discovery.init_flow", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:SCRATCH/issue-980-p3t2-pass10-coverage.json", "--cov-fail-under=0"]
COVERAGE_REQUEST: ['drm_copilot_discovery.init_flow', 'drm_copilot_discovery.init_io', 'drm_copilot_discovery.init_projection', 'scripts.dev_tools.discovery.init_flow']
ORDER: cheap boundary and fixture cases first; all collected cases retained: 87
........................................................................ [ 82%]
...............                                                          [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                      Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py           136      7     36      5    93%   96, 119, 261, 290, 314, 377-378
packages\discovery-runtime\src\drm_copilot_discovery\init_io.py             140      4     50      4    96%   133, 198, 219, 268
packages\discovery-runtime\src\drm_copilot_discovery\init_projection.py     178      0     60      0   100%
scripts\dev_tools\discovery\init_flow.py                                      2      0      0      0   100%
---------------------------------------------------------------------------------------------------------------------
TOTAL                                                                       456     11    146      9    97%
Coverage JSON written to file SCRATCH/issue-980-p3t2-pass10-coverage.json
87 passed in 701.35s (0:11:41)
SOURCE_BINDING_STABLE: True
```

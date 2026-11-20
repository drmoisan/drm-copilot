# p3t2-pass14-units

Timestamp: 2026-10-18T14-03
Command: poetry run python SCRATCH/issue-980-p3t2-units.py forward14 -o addopts=-ra tests/scripts/dev_tools/discovery/test_init_flow.py tests/scripts/dev_tools/discovery/test_init_cli.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_domain_neutrality.py tests/discovery_runtime/test_initialization_conflicts.py tests/discovery_runtime/test_initialization.py -x -q --durations=10 --cov=drm_copilot_discovery.init_flow --cov=drm_copilot_discovery.init_io --cov=drm_copilot_discovery.init_projection --cov=scripts.dev_tools.discovery.init_flow --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t2-pass14-coverage.json --cov-fail-under=0
EXIT_CODE: 0
Output Summary: 12.20s setup    tests/discovery_runtime/test_initialization_conflicts.py::test_partial_workspace_recovers_and_repeat_preserves_all_valid_bytes; 12.00s call     tests/discovery_runtime/test_initialization_conflicts.py::test_stale_physical_inputs_invalidate_a_prepared_plan[collision]; 92 passed in 738.59s (0:12:18); SOURCE_BINDING_STABLE: True

Working directory: .
Started: 2026-10-18T13:50:42.730176+00:00
Duration seconds: 739.889
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
PYTEST_ARGUMENTS: ["-o", "addopts=-ra", "tests/scripts/dev_tools/discovery/test_init_flow.py", "tests/scripts/dev_tools/discovery/test_init_cli.py", "tests/scripts/dev_tools/discovery/test_init_models.py", "tests/scripts/dev_tools/discovery/test_domain_neutrality.py", "tests/discovery_runtime/test_initialization_conflicts.py", "tests/discovery_runtime/test_initialization.py", "-x", "-q", "--durations=10", "--cov=drm_copilot_discovery.init_flow", "--cov=drm_copilot_discovery.init_io", "--cov=drm_copilot_discovery.init_projection", "--cov=scripts.dev_tools.discovery.init_flow", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:SCRATCH/issue-980-p3t2-pass14-coverage.json", "--cov-fail-under=0"]
COVERAGE_REQUEST: ['drm_copilot_discovery.init_flow', 'drm_copilot_discovery.init_io', 'drm_copilot_discovery.init_projection', 'scripts.dev_tools.discovery.init_flow']
ORDER: cheap boundary and fixture cases first; all collected cases retained: 92
........................................................................ [ 78%]
....................                                                     [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                      Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py           136      2     36      2    98%   97, 122
packages\discovery-runtime\src\drm_copilot_discovery\init_io.py             140      3     50      3    97%   200, 221, 271
packages\discovery-runtime\src\drm_copilot_discovery\init_projection.py     178      0     60      0   100%
scripts\dev_tools\discovery\init_flow.py                                      2      0      0      0   100%
---------------------------------------------------------------------------------------------------------------------
TOTAL                                                                       456      5    146      5    98%
Coverage JSON written to file SCRATCH/issue-980-p3t2-pass14-coverage.json
============================ slowest 10 durations =============================
228.03s call     tests/discovery_runtime/test_initialization_conflicts.py::test_partial_workspace_recovers_and_repeat_preserves_all_valid_bytes
175.66s call     tests/discovery_runtime/test_initialization.py::test_first_combined_initialization_publishes_parity_through_real_writer
95.20s call     tests/discovery_runtime/test_initialization_conflicts.py::test_existing_graph_preservation_without_writes
34.82s call     tests/discovery_runtime/test_initialization.py::test_dry_run_is_repeatable_and_retains_exact_physical_absence
21.73s call     tests/discovery_runtime/test_initialization.py::test_each_role_projects_a_complete_honest_structural_draft[combined]
21.38s call     tests/discovery_runtime/test_initialization.py::test_each_role_projects_a_complete_honest_structural_draft[modernization-target]
19.12s call     tests/discovery_runtime/test_initialization.py::test_each_role_projects_a_complete_honest_structural_draft[legacy-source]
12.53s setup    tests/discovery_runtime/test_initialization_conflicts.py::test_invalid_or_incompatible_existing_content_aborts_before_any_write[profile]
12.20s setup    tests/discovery_runtime/test_initialization_conflicts.py::test_partial_workspace_recovers_and_repeat_preserves_all_valid_bytes
12.00s call     tests/discovery_runtime/test_initialization_conflicts.py::test_stale_physical_inputs_invalidate_a_prepared_plan[collision]
92 passed in 738.59s (0:12:18)
SOURCE_BINDING_STABLE: True
```

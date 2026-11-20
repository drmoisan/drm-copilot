# p1t11-tests-pass4

Timestamp: 2026-10-18T07-30
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_path_policy.py tests/discovery_runtime/test_path_resolution.py tests/discovery_runtime/test_path_collisions.py --cov=drm_copilot_discovery.path_models --cov=drm_copilot_discovery.path_policy --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p1t11-coverage.json --durations=8 -q
EXIT_CODE: 0
Output Summary: 0.90s call     tests/discovery_runtime/test_path_collisions.py::test_conflicting_input_file_and_directory_declarations_fail[documentation_roots-value1]; 0.70s setup    tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[src/discovery]; 0.65s call     tests/discovery_runtime/test_path_collisions.py::test_protection_is_bidirectional_and_host_additions_cannot_be_overridden; 241 passed in 24.63s

Working directory: .
Started: 2026-10-18T07:29:36.529020+00:00
Duration seconds: 25.879
Phase: P1-T11 portable path policy and injected metadata; focused task verification.

## Captured output

```text
........................................................................ [ 29%]
........................................................................ [ 59%]
........................................................................ [ 89%]
.........................                                                [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                  Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py      98      0     34      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py     153      0     82      0   100%
-----------------------------------------------------------------------------------------------------------------
TOTAL                                                                   251      0    116      0   100%
Coverage JSON written to file SCRATCH/issue-980-p1t11-coverage.json
============================= slowest 8 durations =============================
1.34s call     tests/discovery_runtime/test_path_collisions.py::test_extension_schema_cannot_be_placed_in_writable_artifact_scope
1.32s setup    tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[relative]
1.32s setup    tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host[/workspace]
1.30s call     tests/discovery_runtime/test_path_collisions.py::test_custom_unicode_layout_and_separate_output_roots_are_supported
0.92s call     tests/discovery_runtime/test_path_collisions.py::test_conflicting_input_file_and_directory_declarations_fail[project_entry_points-value0]
0.90s call     tests/discovery_runtime/test_path_collisions.py::test_conflicting_input_file_and_directory_declarations_fail[documentation_roots-value1]
0.70s setup    tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[src/discovery]
0.65s call     tests/discovery_runtime/test_path_collisions.py::test_protection_is_bidirectional_and_host_additions_cannot_be_overridden
241 passed in 24.63s
```

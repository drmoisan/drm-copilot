# p3t2-pass14-reverse

Timestamp: 2026-10-18T14-09
Command: poetry run python SCRATCH/issue-980-p3t2-units.py reverse14 -o addopts=-ra tests/discovery_runtime/test_initialization.py tests/discovery_runtime/test_initialization_conflicts.py tests/scripts/dev_tools/discovery/test_domain_neutrality.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_init_cli.py tests/scripts/dev_tools/discovery/test_init_flow.py -x -q --durations=10
EXIT_CODE: 0
Output Summary: 4.95s call     tests/discovery_runtime/test_initialization_conflicts.py::test_stale_physical_inputs_invalidate_a_prepared_plan[source-byte]; 4.91s call     tests/discovery_runtime/test_initialization_conflicts.py::test_stale_physical_inputs_invalidate_a_prepared_plan[parent-identity]; 92 passed in 298.48s (0:04:58); SOURCE_BINDING_STABLE: True

Working directory: .
Started: 2026-10-18T14:04:06.575704+00:00
Duration seconds: 299.570
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
PYTEST_ARGUMENTS: ["-o", "addopts=-ra", "tests/discovery_runtime/test_initialization.py", "tests/discovery_runtime/test_initialization_conflicts.py", "tests/scripts/dev_tools/discovery/test_domain_neutrality.py", "tests/scripts/dev_tools/discovery/test_init_models.py", "tests/scripts/dev_tools/discovery/test_init_cli.py", "tests/scripts/dev_tools/discovery/test_init_flow.py", "-x", "-q", "--durations=10"]
........................................................................ [ 78%]
....................                                                     [100%]
============================ slowest 10 durations =============================
92.88s call     tests/discovery_runtime/test_initialization_conflicts.py::test_partial_workspace_recovers_and_repeat_preserves_all_valid_bytes
74.80s call     tests/discovery_runtime/test_initialization.py::test_first_combined_initialization_publishes_parity_through_real_writer
37.36s call     tests/discovery_runtime/test_initialization_conflicts.py::test_existing_graph_preservation_without_writes
14.23s call     tests/discovery_runtime/test_initialization.py::test_dry_run_is_repeatable_and_retains_exact_physical_absence
9.48s call     tests/discovery_runtime/test_initialization.py::test_each_role_projects_a_complete_honest_structural_draft[modernization-target]
8.46s call     tests/discovery_runtime/test_initialization.py::test_each_role_projects_a_complete_honest_structural_draft[combined]
7.91s call     tests/discovery_runtime/test_initialization.py::test_each_role_projects_a_complete_honest_structural_draft[legacy-source]
5.17s setup    tests/discovery_runtime/test_initialization_conflicts.py::test_invalid_or_incompatible_existing_content_aborts_before_any_write[profile]
4.95s call     tests/discovery_runtime/test_initialization_conflicts.py::test_stale_physical_inputs_invalidate_a_prepared_plan[source-byte]
4.91s call     tests/discovery_runtime/test_initialization_conflicts.py::test_stale_physical_inputs_invalidate_a_prepared_plan[parent-identity]
92 passed in 298.48s (0:04:58)
SOURCE_BINDING_STABLE: True
```

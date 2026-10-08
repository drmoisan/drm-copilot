# Python Builders Prefix Run (P1-T4)

Timestamp: 2026-10-02T04-32
Command: poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state.py tests/scripts/dev_tools/test_validate_parallel_planner_state_bounds.py tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py -q
EXIT_CODE: 0
Output Summary:
107 passed, 0 failed.
The unmodified validator accepts items that carry the three routing fields from the new builders module (tests/scripts/dev_tools/parallel_planner_state_builders.py).
Note: an earlier invocation of this command, before any artifact was written, stopped at collection with NameError for build_blast_radius, because the P1-T2 edit had removed an import still used by the blast-radius source cases. The import was restored as a mechanical correction within P1-T2, and this run is the first recorded attempt.

# Permission Surface — Contract Suites

Timestamp: 2026-10-10T08-42
Task: [P6-T8]
Command: poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py
EXIT_CODE: 0

Output Summary:
- `40 passed in 0.47s`; 0 failed.
- Covers the bundled-payload runtime-contract check after the settings, agent, and skill mirrors were updated, the parallel-orchestrator surface contracts, and the persona permission contracts (every prescribed command invocation has a persona Bash grant after the `-m` grant removal and the remove-grant addition).

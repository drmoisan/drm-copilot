Timestamp: 2026-08-22T23-41
Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py::test_duplicate_topology_inputs_resolve_once_per_validation tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py::test_duplicate_codex_model_inputs_resolve_once_per_validation`
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Expected fail-before result: 2 tests collected and 2 failed.
- Topology validator preserved an empty error list but invoked `resolve_codex_topology` 2 times instead of 1 for duplicate valid inputs.
- Model-routing validator preserved an empty error list but invoked `resolve_codex_deployment` 2 times instead of 1 for duplicate valid inputs.
- This failing intermediate state was not staged or committed.

# P6-T26 Additional Hot Paths Fail-Before

Timestamp: 2026-08-23T03:36:05-04:00

Command: `poetry run pytest -o "addopts=" "tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py::test_non_strict_route_membership_skips_validation" "tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py::test_duplicate_complexity_signals_compute_floor_once_and_preserve_index_diagnostics"`

ExpectedExitCode: 1

EXIT_CODE: 1

Output Summary: Pytest collected exactly the two named nodes and reported exactly two failures. `test_non_strict_route_membership_skips_validation` observed one call to `validate_route_membership` instead of zero. `test_duplicate_complexity_signals_compute_floor_once_and_preserve_index_diagnostics` observed two calls to `compute_complexity_floor` instead of one. Both failures match the intended pre-correction hot paths; no other failure reason or test node was present.

# Contract tests fail-before (P1-T3) [expect-fail]

Timestamp: 2026-10-09T20-18
TimestampNote: the label was entered before a clock read; the clock read taken after the artifact was written showed 2026-10-09T20-16, so the actual run time lies between 2026-10-09T20-11 and 2026-10-09T20-16.
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py -q -ra
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
Run before any Markdown edit (only the four P1-T2 tests and constants were added).
FAILED tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_orchestrate_kickoff_band_source_names_admitted_item_source
FAILED tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_orchestrate_model_selection_names_admitted_item_source
FAILED tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_orchestrator_agent_names_admitted_item_source
FAILED tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_add_step_two_defers_model_to_parallel_orchestrate
Result line: 4 failed, 7 passed in 0.09s

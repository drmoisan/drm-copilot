Timestamp: 2026-08-04T10-36
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py -q --no-cov
EXIT_CODE: 1
Output Summary: Expected fail-before result: 2 tests failed and 22 passed in 0.13 seconds. The strict Codex topology and model-routing readers ignore canonical mixed-object agents, so missing receipt assertions do not fire. Python baseline line coverage is 91% (P0-T5); this command intentionally uses the plan-required `--no-cov` option.

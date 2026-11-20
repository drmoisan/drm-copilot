Timestamp: 2026-08-04T10-33
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_delegation_receipts.py tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_gate.py -q --no-cov
EXIT_CODE: 1
Output Summary: Expected fail-before result: 5 failed and 29 passed in 0.16 seconds. Object-form `agents` is rejected as unsupported, routing does not observe canonical object-form agents, and the legacy model-routing gate ignores them. Python baseline line coverage is 91% (P0-T5); this command intentionally uses the plan-required `--no-cov` option.

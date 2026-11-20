Timestamp: 2026-08-25T16-03
Command: poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py -k routed_delegation_launch_binding
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: Expected fail-before result: 1 selected test failed because root `.codex/agents/orchestrator.toml` does not yet contain `codex_model_routing_receipts` or the required durable pre-spawn launch-binding contract. Six unrelated tests were deselected.

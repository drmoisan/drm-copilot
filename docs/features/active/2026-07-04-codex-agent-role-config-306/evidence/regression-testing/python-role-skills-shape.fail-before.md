Timestamp: 2026-07-04T14-05
Command: poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py::test_orchestrator_role_uses_skills_config_sequence -q
EXIT_CODE: 1
Output Summary:
- Expected fail-before test failed as intended.
- Failure: `assert isinstance(config, list)` failed.
- Observed value: parsed `skills.config` is a map of skill names to booleans, not a sequence of `{ name, enabled }` objects.
- Tests: 1 failed.

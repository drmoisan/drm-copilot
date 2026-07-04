Timestamp: 2026-07-04T14-05
Command: poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py::test_orchestrator_role_excludes_role_local_mcp_transport -q
EXIT_CODE: 1
Output Summary:
- Expected fail-before test failed as intended.
- Failure: `assert "mcp_servers" not in role` failed.
- Observed value: parsed role TOML contains `mcp_servers.drm-copilot` with `enabled = true`.
- Tests: 1 failed.

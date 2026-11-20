Timestamp: 2026-07-04T14-06
Command: poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py::test_orchestrator_role_uses_skills_config_sequence tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py::test_orchestrator_role_excludes_role_local_mcp_transport tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_config_files_retain_full_drm_copilot_transport -q
EXIT_CODE: 1
Output Summary:
- Expected fail-before suite failed while role TOML regressions remain unresolved.
- `test_codex_config_files_retain_full_drm_copilot_transport` passed in the same run.
- Failing tests:
  - `test_orchestrator_role_uses_skills_config_sequence`: parsed `skills.config` is a map, not a list.
  - `test_orchestrator_role_excludes_role_local_mcp_transport`: parsed role TOML contains `mcp_servers.drm-copilot`.
- Tests: 2 failed, 1 passed.

# Final Python Parity Suites (#769, P10-T1)

Timestamp: 2026-09-29T14-39
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_resolve_codex_topology.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 89 passed (same totals as the P0-T20 baseline)
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
Assertion message: "Repo file missing from bundle: .claude\state\current-session-id"
No output line contains "Bundle content differs from repo for:".
KL-510: STATE-ONLY
Every other node PASSED.

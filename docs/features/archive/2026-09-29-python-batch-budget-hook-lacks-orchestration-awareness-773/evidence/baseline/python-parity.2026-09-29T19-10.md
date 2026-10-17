# Python Parity Baseline (P0-T22)

Timestamp: 2026-09-29T19-10
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_resolve_codex_topology.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
1 failed, 93 passed in 1.82s
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
KL-510: STATE-ONLY
Assertion message: `AssertionError: Repo file missing from bundle: .claude\state\current-session-id`
No output line contains "Bundle content differs from repo for:". The KL-510 node is the only FAILED line; every other node PASSED.

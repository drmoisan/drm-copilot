# Contract Checks (Final QA)

Timestamp: 2026-10-28T21-59
Command: git add -A (every created file staged); poetry run pytest tests/scripts/dev_tools/{test_push_down_claude_resource_contracts,test_push_down_codex_and_agents_resource_contracts,test_push_down_claude_pack_manifest_completeness,test_push_down_codex_and_agents_pack_manifest_completeness,test_push_down_pack_manifest_dependency_closure,test_codex_agent_wrapper_contracts,test_codex_handoff_contract_parity,test_claude_rules_frontmatter,test_push_down_issue_824_follow_ups,test_execution_environment_brief_contracts,test_parallel_orchestrator_surface_contracts,test_typescript_toolchain_instruction_contracts,test_generate_codex_agent_variants}.py -q --no-cov; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; poetry run python -m scripts.dev_tools.check_quality_tiers
EXIT_CODE: 0
Output Summary:
- pytest: 211 passed, 0 failed (baseline 211 passed).
- Generator `--check`: exit 0; stderr line count 0.
- Tier check: exit 0 (`quality-tiers: OK (26 entries, 26 discovered projects)`; baseline 25/25, plus `.claude/lib/file-size-policy`).

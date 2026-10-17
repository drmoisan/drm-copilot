# Regression Set — After Phase 1 Edits

Timestamp: 2026-10-12T23-48
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- `98 passed in 0.81s`; zero failed, zero skipped.
- Passed count equals the P0-T9 baseline passed count (98). No pre-existing failures existed at baseline.
- Includes the re-pinned frozen-digest test, the bundled-payload parity tests, and `test_all_repo_agent_skills_are_bundled_and_identical`.

# Contract Test Set (remediation cycle 1)

Timestamp: 2026-11-03T19-54
Task: [P5-T4]
Command: poetry run pytest -p no:cacheprovider -q <the 27 modules of the plan's ## Contract Test Set under tests/scripts/dev_tools/> (serial; project addopts -ra --cov-report=lcov:artifacts/python/lcov.info --strict-markers --strict-config)
EXIT_CODE: 0
Output Summary: 419 passed, 0 failed, 0 errors in 4.90 s. Includes the [P3-T4] skill tests (test_parallel_planner_no_scratch_worktree_contracts.py, test_parallel_planner_surface_contracts.py, test_parallel_planner_surface_contracts_landed.py, test_parallel_issue_adoption_skill_contracts.py, test_skill_bundle_contract_repo.py) and the [P4-T2] rule tests (test_parallel_mutation_rejection_signal_contracts.py, test_claude_rules_frontmatter.py, test_parallel_complexity_routing_contracts.py, test_parallel_issue_combination_contracts.py, test_epic_bounded_child_return_contract.py).

Modules:

- tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py
- tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py
- tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py
- tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py
- tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py
- tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py
- tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py
- tests/scripts/dev_tools/test_parallel_mutation_rejection_signal_contracts.py
- tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py
- tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py
- tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py
- tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py
- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
- tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
- tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py
- tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
- tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py
- tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py
- tests/scripts/dev_tools/test_codex_handoff_contract_parity.py
- tests/scripts/dev_tools/test_claude_rules_frontmatter.py
- tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
- tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py
- tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py
- tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
- tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py
- tests/scripts/dev_tools/test_quality_tiers_contract_classification.py

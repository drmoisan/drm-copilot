# Pytest Contract Set (serial)

Timestamp: 2026-11-03T13-38
Task: [P6-T6]
Command: sh SCRATCH/issue-1047-pytest-contracts.sh (runs `poetry run pytest --strict-markers -q` serially over the 23 modules of the plan's `## Contract Test Set` under tests/scripts/dev_tools/)
EXIT_CODE: 0
Output Summary: 410 passed, 0 failed, 0 skipped in 2.57s (baseline 408; the two added cases are the kickoff-plan-hash-verification and merge-on-green-turn-gap-redelegation parametrizations of test_parallel_orchestrator_surface_contracts.py::test_orchestrate_skill_section_states_its_required_obligations).

Named tests from Phase 5 tasks, all inside this run and passing: test_parallel_mutation_rejection_signal_contracts.py, test_parallel_complexity_routing_contracts.py (including test_parallel_orchestration_rule_defines_p10 and test_parallel_add_requires_complexity_assessment), test_parallel_issue_combination_contracts.py, test_epic_bounded_child_return_contract.py, test_parallel_planner_surface_contracts.py, test_parallel_issue_adoption_skill_contracts.py, test_parallel_planner_no_scratch_worktree_contracts.py, test_parallel_kickoff_template_seam.py, test_parallel_planner_surface_contracts_landed.py, test_skill_bundle_contract_repo.py, test_parallel_orchestrator_surface_contracts.py, test_parallel_orchestrator_permission_contracts.py, test_ci_gate_all_checks_contracts.py, test_completion_gate_documentation_contracts.py, test_orchestrator_state_remediation_docs.py, test_claude_rules_frontmatter.py, test_push_down_claude_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py, test_push_down_codex_and_agents_customizations.py, test_parallel_mutation_run_bash_parity.py, test_parallel_cohort_barrier_parity.py, test_quality_tiers_contract_classification.py.

Pester suites named by Phase 5 tasks (run separately with Invoke-PoshQCTest; counts from artifacts/pester/pester-junit.xml): enforce-parallel-drift-gate.Tests.ps1 49/0, validate-orchestrator-output-resolution.Tests.ps1 15/0, validate-orchestrator-output.MutationRejection.Tests.ps1 28/0, parallel-orchestrate-run-closing.Tests.ps1 60/0.

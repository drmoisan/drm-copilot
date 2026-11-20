# Pytest Final Gate ([P2-T2])

Timestamp: 2026-11-19T11-33
Plan: plan.2026-10-30T18-39.md
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/pytest-final.json --junitxml=SCRATCH/pytest-final.xml -q
EXIT_CODE: 0
Output Summary: one `pytest -n auto` run through the launcher (integration and golden lanes excluded): 17102 passed, 0 failed, 6 skipped in 166.73s (five earlier attempts exited 75, queue timeout). Repository-wide coverage (JSON report totals): line 98.00% (35359/36079), branch 95.46% (13091/13714). `scripts/dev_tools/agentic_sync.py`: line 98.02% (99/101), branch 94.12% (32/34); missing lines 209 and 364 (the same two statements as at Phase 0, moved by one docstring line).

## Named Modules in the Passing Set (from the JUnit report, 0 failures each)

UPDATED-PYTEST-MODULES: `test_execution_environment_brief_contracts` 27, `test_discovery_documentation_contracts` 32, `test_legacy_discovery_skills_contracts` 138, `test_discovery_workflow_contracts` 66, `test_discovery_publication_contracts` 31, `test_completion_gate_documentation_contracts` 44, `test_evidence_timestamp_contracts` 10, `test_minor_audit_acceptance_criteria_contracts` 3, `test_csharp_orchestration_contracts` 6, `test_push_down_issue_824_follow_ups` 58, `test_plan_gate_document_docs` 6, `test_single_pass_preflight_contracts` 12, `test_agentic_sync` 5, `test_agentic_sync_artifacts` 7, `test_push_down_copilot_customizations` 3, `test_push_down_copilot_customizations_rewrites` 6.

UNCHANGED-AGENT-PYTEST: `test_orchestrator_direct_command_contracts` 4, `test_push_down_copilot_customizations_helpers` 16, `test_codex_full_migration_inventory` 3, `test_discovery_agent_contracts` 43, `test_quality_tiers_contract` 45, `test_agentic_sync_branches` 13.

PUSH-DOWN-CONTRACT-TESTS: `test_push_down_claude_resource_contracts` 14, `test_push_down_codex_and_agents_resource_contracts` 9, `test_push_down_claude_pack_manifest_completeness` 2, `test_push_down_codex_and_agents_pack_manifest_completeness` 2, `test_push_down_pack_manifest_dependency_closure` 18.

Also: `test_vscode_workspace_settings` 2, `test_bash_command_shape_surfaces` 12.

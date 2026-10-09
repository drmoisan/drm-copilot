# P8-T16 Python parity and contracts (CMD-PY-PARITY-EXT)

Timestamp: 2026-10-09T01-01
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py
EXIT_CODE: 0
Output Summary:
  ============================= 71 passed in 0.68s ==============================
  PASSED node lines: 72; FAILED node lines: 0
  KL-510: PASSED

## Full output (worktree root shown as `.`; interpreter host path redacted)

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- (virtualenv python)
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 71 items

tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files PASSED [  1%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED [  2%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_planner_review_resources_exist_and_are_byte_identical PASSED [  4%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_handoff_runtime_has_bundle_pack_and_effective_install_parity PASSED [  5%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_pack_manifests_are_outside_the_parity_scope PASSED [  7%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_excludes_settings_local_json PASSED [  8%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_excludes_variant_subtree_from_parity PASSED [  9%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_variant_subtree_is_bundle_only_and_non_colliding PASSED [ 11%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_agent_memory_scopes_are_well_formed PASSED [ 12%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_legacy_variant_files_contain_corrected_gate_commands PASSED [ 14%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_legacy_variant_files_exclude_stale_gate_commands PASSED [ 15%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_modern_csharp_profile_retains_modern_gate_commands PASSED [ 16%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_consumer_uses_published_typescript_handoff_authority PASSED [ 18%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_orchestrate_requires_independent_expected_context PASSED [ 19%]
tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest PASSED [ 21%]
tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest PASSED [ 22%]
tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources PASSED [ 23%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_required_runtime_files PASSED [ 25%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_pack_manifests_and_variants_exist PASSED [ 26%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_routing_config_remains_a_shared_resource_outside_codex_bundle PASSED [ 28%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts PASSED [ 29%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_root_and_bundle_payload_contract_excludes_ephemeral_codex_state PASSED [ 30%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_config_files_retain_full_drm_copilot_transport PASSED [ 32%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_role_files_do_not_retain_drm_copilot_transport PASSED [ 33%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_legacy_variant_files_contain_corrected_gate_commands PASSED [ 35%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_legacy_variant_files_exclude_stale_gate_commands PASSED [ 36%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_codex_ci_green_gate_names_ci_gate_keys_from_validator PASSED [ 38%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_codex_ci_green_gate_names_pr_gate_keys_from_validator PASSED [ 39%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_codex_completion_list_includes_ci_gate_and_pr_gate PASSED [ 40%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_codex_orchestrate_states_ci_dependent_checkoff_rule PASSED [ 42%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_orchestrate_pr_creation_gate_condition_two_excludes_ci_dependent_ac PASSED [ 43%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_orchestrate_s9_requires_ci_dependent_checkoff_push_and_rerun PASSED [ 45%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_parallel_orchestrate_merge_requires_head_sha_match_and_no_pending_ci_ac PASSED [ 46%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_parallel_orchestrator_agent_states_child_owns_ci_dependent_checkoffs PASSED [ 47%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[claude] PASSED [ 49%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[agents] PASSED [ 50%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[github] PASSED [ 52%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_feature_review_agent_grants_mcp_artifact_validator PASSED [ 53%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_feature_review_agent_body_validates_each_review_artifact_type PASSED [ 54%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_first_occurrence_for_all_schema_fields[claude] PASSED [ 56%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_first_occurrence_for_all_schema_fields[agents] PASSED [ 57%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_first_occurrence_for_all_schema_fields[github] PASSED [ 59%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_timestamp_system_clock_source[claude] PASSED [ 60%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_timestamp_system_clock_source[agents] PASSED [ 61%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_timestamp_system_clock_source[github] PASSED [ 63%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[agents-orchestrate] PASSED [ 64%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-orchestrate] PASSED [ 66%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-parallel-orchestrate] PASSED [ 67%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-parallel-orchestrator-agent] PASSED [ 69%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-ac-tracking] PASSED [ 70%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[agents-ac-tracking] PASSED [ 71%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[github-ac-tracking] PASSED [ 73%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-feature-review-agent] PASSED [ 74%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-evidence] PASSED [ 76%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[agents-evidence] PASSED [ 77%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[github-evidence] PASSED [ 78%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_feature_review_skill_lists_every_literal PASSED [ 80%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_orchestrator_agent_lists_every_literal PASSED [ 81%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_rules_review_outcome_section_lists_every_literal PASSED [ 83%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_rules_introduction_drops_three_invariants_wording[.claude/rules/orchestrator-state.md] PASSED [ 84%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_rules_introduction_drops_three_invariants_wording[.agents/skills/orchestrator-state/SKILL.md] PASSED [ 85%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_remediation_input_prefixes_avoid_blocking_tokens[.claude/agents/feature-review.md] PASSED [ 87%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_remediation_input_prefixes_avoid_blocking_tokens[.agents/skills/feature-review/SKILL.md] PASSED [ 88%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_feature_review_agent_states_evidence_text_constraint[.claude/agents/feature-review.md] PASSED [ 90%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_feature_review_agent_states_evidence_text_constraint[.agents/skills/feature-review/SKILL.md] PASSED [ 91%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_loop_documents_state_completed_attempts PASSED [ 92%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_orchestrate_skills_state_halt_and_wait_rules[.claude/skills/orchestrate/SKILL.md] PASSED [ 94%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_orchestrate_skills_state_halt_and_wait_rules[.agents/skills/orchestrate/SKILL.md] PASSED [ 95%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_documents_classify_mcp_contract_lag[.agents/skills/feature-review/SKILL.md] PASSED [ 97%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_documents_classify_mcp_contract_lag[.claude/skills/feature-review-workflow/SKILL.md] PASSED [ 98%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_contract_documents_share_review_outcome_section PASSED [100%]

============================= 71 passed in 0.68s ==============================
```

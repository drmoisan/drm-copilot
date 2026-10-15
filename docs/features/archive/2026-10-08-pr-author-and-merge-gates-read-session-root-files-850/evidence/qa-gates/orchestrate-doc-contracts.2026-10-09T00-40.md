# P7-T3 Documentation contract tests after the SKILL edit

Timestamp: 2026-10-09T00-40
Command: poetry run pytest -v tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py
EXIT_CODE: 0
Output Summary:
  ============================= 45 passed in 0.22s ==============================
  PASSED node lines: 46; FAILED node lines: 0
  KL-510: not applicable (the KL-510 node is not part of this command)

## Full output (worktree root shown as `.`; interpreter host path redacted)

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- (virtualenv python)
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 45 items

tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_codex_ci_green_gate_names_ci_gate_keys_from_validator PASSED [  2%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_codex_ci_green_gate_names_pr_gate_keys_from_validator PASSED [  4%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_codex_completion_list_includes_ci_gate_and_pr_gate PASSED [  6%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_codex_orchestrate_states_ci_dependent_checkoff_rule PASSED [  8%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_orchestrate_pr_creation_gate_condition_two_excludes_ci_dependent_ac PASSED [ 11%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_orchestrate_s9_requires_ci_dependent_checkoff_push_and_rerun PASSED [ 13%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_parallel_orchestrate_merge_requires_head_sha_match_and_no_pending_ci_ac PASSED [ 15%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_parallel_orchestrator_agent_states_child_owns_ci_dependent_checkoffs PASSED [ 17%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[claude] PASSED [ 20%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[agents] PASSED [ 22%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[github] PASSED [ 24%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_feature_review_agent_grants_mcp_artifact_validator PASSED [ 26%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_feature_review_agent_body_validates_each_review_artifact_type PASSED [ 28%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_first_occurrence_for_all_schema_fields[claude] PASSED [ 31%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_first_occurrence_for_all_schema_fields[agents] PASSED [ 33%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_first_occurrence_for_all_schema_fields[github] PASSED [ 35%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_timestamp_system_clock_source[claude] PASSED [ 37%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_timestamp_system_clock_source[agents] PASSED [ 40%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_evidence_skill_states_timestamp_system_clock_source[github] PASSED [ 42%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[agents-orchestrate] PASSED [ 44%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-orchestrate] PASSED [ 46%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-parallel-orchestrate] PASSED [ 48%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-parallel-orchestrator-agent] PASSED [ 51%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-ac-tracking] PASSED [ 53%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[agents-ac-tracking] PASSED [ 55%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[github-ac-tracking] PASSED [ 57%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-feature-review-agent] PASSED [ 60%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-evidence] PASSED [ 62%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[agents-evidence] PASSED [ 64%]
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[github-evidence] PASSED [ 66%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_feature_review_skill_lists_every_literal PASSED [ 68%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_orchestrator_agent_lists_every_literal PASSED [ 71%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_rules_review_outcome_section_lists_every_literal PASSED [ 73%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_rules_introduction_drops_three_invariants_wording[.claude/rules/orchestrator-state.md] PASSED [ 75%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_rules_introduction_drops_three_invariants_wording[.agents/skills/orchestrator-state/SKILL.md] PASSED [ 77%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_remediation_input_prefixes_avoid_blocking_tokens[.claude/agents/feature-review.md] PASSED [ 80%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_remediation_input_prefixes_avoid_blocking_tokens[.agents/skills/feature-review/SKILL.md] PASSED [ 82%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_feature_review_agent_states_evidence_text_constraint[.claude/agents/feature-review.md] PASSED [ 84%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_feature_review_agent_states_evidence_text_constraint[.agents/skills/feature-review/SKILL.md] PASSED [ 86%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_loop_documents_state_completed_attempts PASSED [ 88%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_orchestrate_skills_state_halt_and_wait_rules[.claude/skills/orchestrate/SKILL.md] PASSED [ 91%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_orchestrate_skills_state_halt_and_wait_rules[.agents/skills/orchestrate/SKILL.md] PASSED [ 93%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_documents_classify_mcp_contract_lag[.agents/skills/feature-review/SKILL.md] PASSED [ 95%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_documents_classify_mcp_contract_lag[.claude/skills/feature-review-workflow/SKILL.md] PASSED [ 97%]
tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_contract_documents_share_review_outcome_section PASSED [100%]

============================= 45 passed in 0.22s ==============================
```

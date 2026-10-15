# P2-T2 [expect-fail] DOCS-MODULE Against Unmodified RULE, SKILL, AGENT

Timestamp: 2026-10-09T03-03
Command: git status --porcelain -- .claude/rules/orchestrator-state.md .claude/skills/orchestrate/SKILL.md .claude/agents/orchestrator.md; poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- status: no output (exit 0); RULE, SKILL, AGENT unchanged
- pytest summary: `======================== 37 failed, 15 passed in 0.20s ========================` (exit 1)
- FAILED lines (verbatim, prefix `FAILED tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py::`):
  - test_required_key_is_documented_in_rule[objective]
  - test_required_key_is_documented_in_rule[change_budget_estimate]
  - test_required_key_is_documented_in_rule[path_selected]
  - test_required_key_is_documented_in_rule[promotion-type]
  - test_required_key_is_documented_in_rule[short-name]
  - test_required_key_is_documented_in_rule[relativeFile]
  - test_required_key_is_documented_in_rule[long-name]
  - test_required_key_is_documented_in_rule[issue-num]
  - test_required_key_is_documented_in_rule[feature-folder]
  - test_required_key_is_documented_in_rule[work-mode]
  - test_required_key_is_documented_in_rule[plan-path]
  - test_required_key_is_documented_in_rule[completed_steps]
  - test_required_key_is_documented_in_rule[next_step]
  - test_required_key_is_documented_in_rule[last_updated]
  - test_required_key_is_documented_in_rule[step5_status]
  - test_required_key_is_documented_in_rule[step6_status]
  - test_required_key_is_documented_in_rule[step7_status]
  - test_required_key_is_documented_in_rule[step8_status]
  - test_required_key_is_documented_in_rule[step9_status]
  - test_required_key_is_documented_in_rule[step10_status]
  - test_required_key_is_documented_in_rule[delegation_receipts]
  - test_required_key_is_documented_in_rule[blocked_reason]
  - test_rule_documented_keys_equal_required_state_keys
  - test_required_keys_section_sits_between_foreign_schema_and_scope_sections
  - test_rule_section_names_authority_and_check_semantics
  - test_rule_documents_last_updated_semantics
  - test_orchestrate_skill_references_last_updated_and_rule_section
  - test_orchestrate_skill_records_hyphenated_issue_num_key
  - test_orchestrator_agent_checkpoint_persistence_lists_required_keys[relativeFile]
  - test_orchestrator_agent_checkpoint_persistence_lists_required_keys[long-name]
  - test_orchestrator_agent_checkpoint_persistence_lists_required_keys[work-mode]
  - test_orchestrator_agent_checkpoint_persistence_lists_required_keys[plan-path]
  - test_orchestrator_agent_checkpoint_persistence_lists_required_keys[step6_status]
  - test_orchestrator_agent_checkpoint_persistence_lists_required_keys[step7_status]
  - test_orchestrator_agent_checkpoint_persistence_lists_required_keys[step8_status]
  - test_orchestrator_agent_checkpoint_persistence_lists_required_keys[step9_status]
  - test_rule_documents_both_dispatcher_invocation_forms
- Passing set: test_parity_comparison_detects_undocumented_and_extra_keys and the 14 other agent-persona cases.
- Result: expected split observed (fail-before evidence for AC-8, AC-9, AC-10, AC-12, AC-13, AC-15, AC-16; AC-11 negative control passes)

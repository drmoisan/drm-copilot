# P1-T3 [expect-fail] REGRESSION-MODULE against unmodified rule text

Timestamp: 2026-10-03T09-34
Command: git status --porcelain -- .claude/rules .claude/agents/feature-review.md .claude/skills/feature-review-workflow .agents/skills/quality-tiers .agents/skills/general-code-change .agents/skills/general-unit-test extensions/drm-copilot/resources/claude-customizations/.claude/rules extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test; poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- git status: empty output, exit=0 (no rule, agent, skill, or mirror file changed).
- pytest: exit=1; summary "52 failed, 28 passed in 0.26s" (matches the planned 52/28 split).
- Note: the pytest invocation also passed `-ra`, which is already in pyproject addopts ("-ra --cov-report=lcov:..."), so behavior is identical to the planned command.
- Failing set matches the plan enumeration exactly: legacy classification sentence (4 general-code-change copies), unconditional CI sentence (4 quality-tiers copies), preamble adoption gate (4), quality-tiers repo-scope phrase (4), consuming product (4), general-code-change conditional section (4), general-unit-test repo-scope phrase (4), test categories gate (4), CLAUDE.md precedence (4), AGENTS.md precedence (4), Codex tier-skill citation (6), feature-review tier finding (4), review agent governing thresholds (2).
- Passing set: test_every_scanned_copy_exists, the 12 remaining cases of each sentence test, and the three negative-control tests (28).

FAILED lines (-ra short summary, assertion message trimmed):
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_copy_omits_legacy_classification_sentence[.claude/rules/general-code-change.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_copy_omits_legacy_classification_sentence[extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_copy_omits_legacy_classification_sentence[.agents/skills/general-code-change/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_copy_omits_legacy_classification_sentence[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_copy_omits_unconditional_ci_sentence[.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_copy_omits_unconditional_ci_sentence[extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_copy_omits_unconditional_ci_sentence[.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_copy_omits_unconditional_ci_sentence[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_preamble_states_adoption_gate[.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_preamble_states_adoption_gate[extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_preamble_states_adoption_gate[.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_preamble_states_adoption_gate[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_copy_drops_repo_scope_phrase[.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_copy_drops_repo_scope_phrase[extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_copy_drops_repo_scope_phrase[.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_copy_drops_repo_scope_phrase[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_copy_names_no_consuming_product[.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_copy_names_no_consuming_product[extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_copy_names_no_consuming_product[.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_quality_tiers_copy_names_no_consuming_product[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_general_code_change_tier_section_is_conditional[.claude/rules/general-code-change.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_general_code_change_tier_section_is_conditional[extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_general_code_change_tier_section_is_conditional[.agents/skills/general-code-change/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_general_code_change_tier_section_is_conditional[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_general_unit_test_copy_drops_repo_scope_phrase[.claude/rules/general-unit-test.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_general_unit_test_copy_drops_repo_scope_phrase[extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_general_unit_test_copy_drops_repo_scope_phrase[.agents/skills/general-unit-test/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_general_unit_test_copy_drops_repo_scope_phrase[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_unit_test_categories_gate_tier_obligations[.claude/rules/general-unit-test.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_unit_test_categories_gate_tier_obligations[extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_unit_test_categories_gate_tier_obligations[.agents/skills/general-unit-test/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_unit_test_categories_gate_tier_obligations[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_claude_copy_states_claude_md_precedence[.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_claude_copy_states_claude_md_precedence[extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_claude_copy_states_claude_md_precedence[.claude/rules/general-unit-test.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_claude_copy_states_claude_md_precedence[extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_copy_states_agents_md_precedence[.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_copy_states_agents_md_precedence[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_copy_states_agents_md_precedence[.agents/skills/general-unit-test/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_copy_states_agents_md_precedence[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_skill_copy_cites_existing_tier_skill[.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_skill_copy_cites_existing_tier_skill[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_skill_copy_cites_existing_tier_skill[.agents/skills/general-code-change/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_skill_copy_cites_existing_tier_skill[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_skill_copy_cites_existing_tier_skill[.agents/skills/general-unit-test/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_codex_skill_copy_cites_existing_tier_skill[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_feature_review_copy_gates_tier_finding[.claude/agents/feature-review.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_feature_review_copy_gates_tier_finding[extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_feature_review_copy_gates_tier_finding[.claude/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_feature_review_copy_gates_tier_finding[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_review_agent_copy_uses_governing_thresholds[.claude/agents/feature-review.md]
- FAILED tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py::test_review_agent_copy_uses_governing_thresholds[extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md]

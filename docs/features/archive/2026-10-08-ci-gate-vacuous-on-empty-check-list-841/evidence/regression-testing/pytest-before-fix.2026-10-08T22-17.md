# Pytest Before-Fix Run (#841, P1-T5) [expect-fail]

Timestamp: 2026-10-10T09-20
Command: poetry run pytest -v tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Summary line: `======================== 20 failed, 6 passed in 0.16s =========================`
- The six PASSED nodes are exactly the six the plan names (listed below).
- Result matches the plan expectation; no design-review stop.

Route: run exactly as written (Python tasks are not affected by the route substitution). Full output captured to SCRATCH and inspected; not committed.

## PASSED nodes (6)

1. test_orchestrate_parser_command_stays_on_one_line[.claude/skills/orchestrate/SKILL.md]
2. test_orchestrate_parser_command_stays_on_one_line[extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md]
3. test_review_rule_drops_sha_exact_definition[.agents/skills/feature-review-workflow/SKILL.md]
4. test_review_rule_drops_sha_exact_definition[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
5. test_rule_resolution_reports_missing_heading
6. test_rule_resolution_accepts_defined_heading

## FAILED nodes (20)

1. test_orchestrate_s9_states_epic_child_guard[.claude/skills/orchestrate/SKILL.md]
2. test_orchestrate_s9_states_epic_child_guard[extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md]
3. test_orchestrate_schema_head_sha_names_queried_checks[.claude/skills/orchestrate/SKILL.md]
4. test_orchestrate_schema_head_sha_names_queried_checks[extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md]
5. test_orchestrate_drops_required_check_wording[.claude/skills/orchestrate/SKILL.md]
6. test_orchestrate_drops_required_check_wording[extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md]
7. test_review_rule_defines_satisfiable_qualifying_run[.claude/skills/feature-review-workflow/SKILL.md]
8. test_review_rule_defines_satisfiable_qualifying_run[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
9. test_review_rule_defines_satisfiable_qualifying_run[.agents/skills/feature-review-workflow/SKILL.md]
10. test_review_rule_defines_satisfiable_qualifying_run[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
11. test_review_rule_drops_sha_exact_definition[.claude/skills/feature-review-workflow/SKILL.md]
12. test_review_rule_drops_sha_exact_definition[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
13. test_agents_review_rule_sits_before_ordered_procedure[.agents/skills/feature-review-workflow/SKILL.md]
14. test_agents_review_rule_sits_before_ordered_procedure[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
15. test_agents_review_rule_carries_codex_bullets[.agents/skills/feature-review-workflow/SKILL.md]
16. test_agents_review_rule_carries_codex_bullets[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
17. test_agents_citing_copy_resolves_rule[.agents/skills/ci-workflows/SKILL.md]
18. test_agents_citing_copy_resolves_rule[.agents/skills/benchmark-baselines/SKILL.md]
19. test_agents_citing_copy_resolves_rule[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/ci-workflows/SKILL.md]
20. test_agents_citing_copy_resolves_rule[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/benchmark-baselines/SKILL.md]

(All node IDs are prefixed `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::`.)

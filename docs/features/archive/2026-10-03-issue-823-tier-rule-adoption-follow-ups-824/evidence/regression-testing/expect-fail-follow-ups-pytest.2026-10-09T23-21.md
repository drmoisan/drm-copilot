# P2-T1 Expect-Fail: Follow-Ups Pytest Module Against Unmodified Production Text

Timestamp: 2026-10-09T23-21
Command: git status --porcelain -- .claude .agents .github .codex extensions/drm-copilot/resources; poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Command 1 (git status): EXIT 0, printed nothing. No production, rule, skill, or mirror file has changed.
- Command 2 (pytest): EXIT 1; "collected 43 items"; summary "38 failed, 5 passed".
- The plain run's traceback output exceeded the tool display limit before the summary, so the same module was rerun with `--tb=no -ra -q -p no:cacheprovider` solely to read the short summary; the rerun reported the same "38 failed, 5 passed". The pytest "rootdir:" header line is not recorded (absolute host path).
- Failing set by test function (observed / expected): test_listed_copy_names_no_consuming_product 6/6; test_surface_does_not_hard_code_solution_file 14/14; test_pushed_roots_carry_no_hard_coded_solution_file 1/1; test_review_workflow_step_eight_uses_governing_thresholds 2/2; test_precedence_copy_states_per_metric_fallback 14/14; test_pushed_rule_and_skill_files_name_no_consuming_product 1/1. Total 38.
- Passing set (5): test_every_follow_up_copy_exists, test_consuming_product_detection_flags_a_reintroduced_name, test_step_eight_extraction_stops_at_step_nine, test_pushed_rule_and_skill_scan_covers_the_listed_copies, test_name_exceptions_still_name_a_consuming_product.
- FAILED lines of the -ra summary (node IDs under tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::):
  - test_listed_copy_names_no_consuming_product[.claude/rules/architecture-boundaries.md]
  - test_listed_copy_names_no_consuming_product[extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md]
  - test_listed_copy_names_no_consuming_product[.agents/skills/architecture-boundaries/SKILL.md]
  - test_listed_copy_names_no_consuming_product[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md]
  - test_listed_copy_names_no_consuming_product[.claude/skills/quota-throttling/SKILL.md]
  - test_listed_copy_names_no_consuming_product[extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md]
  - test_surface_does_not_hard_code_solution_file[.github/instructions/csharp-code-change.instructions.md]
  - test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md]
  - test_surface_does_not_hard_code_solution_file[.github/instructions/csharp-unit-test.instructions.md]
  - test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md]
  - test_surface_does_not_hard_code_solution_file[.github/agents/csharp-typed-engineer.agent.md]
  - test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md]
  - test_surface_does_not_hard_code_solution_file[.agents/skills/csharp/SKILL.md]
  - test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md]
  - test_surface_does_not_hard_code_solution_file[.agents/skills/csharp-qa-gate/SKILL.md]
  - test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md]
  - test_surface_does_not_hard_code_solution_file[.codex/codex-web-setup.sh]
  - test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh]
  - test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md]
  - test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md]
  - test_pushed_roots_carry_no_hard_coded_solution_file
  - test_review_workflow_step_eight_uses_governing_thresholds[.claude/skills/feature-review-workflow/SKILL.md]
  - test_review_workflow_step_eight_uses_governing_thresholds[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
  - test_precedence_copy_states_per_metric_fallback[.claude/rules/quality-tiers.md]
  - test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md]
  - test_precedence_copy_states_per_metric_fallback[.claude/rules/general-unit-test.md]
  - test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md]
  - test_precedence_copy_states_per_metric_fallback[.agents/skills/quality-tiers/SKILL.md]
  - test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md]
  - test_precedence_copy_states_per_metric_fallback[.agents/skills/general-unit-test/SKILL.md]
  - test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md]
  - test_precedence_copy_states_per_metric_fallback[.claude/agents/feature-review.md]
  - test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md]
  - test_precedence_copy_states_per_metric_fallback[.claude/skills/feature-review-workflow/SKILL.md]
  - test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
  - test_precedence_copy_states_per_metric_fallback[.claude/hooks/validate-feature-review-coverage.ps1]
  - test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1]
  - test_pushed_rule_and_skill_files_name_no_consuming_product
- Result: EXPECTED FAILURE CONFIRMED (split matches the plan exactly).

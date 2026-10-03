# r1 P1-T11 [expect-fail] — PYG against the unfixed tree

Timestamp: 2026-10-03T13-02
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p1-t11.ps1 -Worktree WORKTREE; step script runs `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -q -rfE *> "$Scratch/r1-pyg-expect-fail.log"; $pytestExit = $LASTEXITCODE; "PYTEST-EXIT=$pytestExit"`, the summary Select-String line, and the P1-T11 RELAY line
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- PYTEST-EXIT=1; RELAY passed the exit through because the summary is `37 failed, 3 passed in 0.31s`, there are 37 `FAILED ` lines, and there is no `ERROR ` line.
- Failed nodes: 6 test_listed_copy_names_no_consuming_product, 14 test_surface_does_not_hard_code_solution_file, 1 test_pushed_roots_carry_no_hard_coded_solution_file, 2 test_review_workflow_step_eight_uses_governing_thresholds, 14 test_precedence_copy_states_per_metric_fallback.
- Passing tests: test_every_follow_up_copy_exists, test_consuming_product_detection_flags_a_reintroduced_name, test_step_eight_extraction_stops_at_step_nine.

FAILED lines (37), node prefix `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::`:

FAILED test_listed_copy_names_no_consuming_product[.claude/rules/architecture-boundaries.md]
FAILED test_listed_copy_names_no_consuming_product[extensions/drm-copilot/resources/claude-customizations/.claude/rules/architecture-boundaries.md]
FAILED test_listed_copy_names_no_consuming_product[.agents/skills/architecture-boundaries/SKILL.md]
FAILED test_listed_copy_names_no_consuming_product[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/architecture-boundaries/SKILL.md]
FAILED test_listed_copy_names_no_consuming_product[.claude/skills/quota-throttling/SKILL.md]
FAILED test_listed_copy_names_no_consuming_product[extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md]
FAILED test_surface_does_not_hard_code_solution_file[.github/instructions/csharp-code-change.instructions.md]
FAILED test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/customizations/.github/instructions/csharp-code-change.instructions.md]
FAILED test_surface_does_not_hard_code_solution_file[.github/instructions/csharp-unit-test.instructions.md]
FAILED test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/customizations/.github/instructions/csharp-unit-test.instructions.md]
FAILED test_surface_does_not_hard_code_solution_file[.github/agents/csharp-typed-engineer.agent.md]
FAILED test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/customizations/.github/agents/csharp-typed-engineer.agent.md]
FAILED test_surface_does_not_hard_code_solution_file[.agents/skills/csharp/SKILL.md]
FAILED test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md]
FAILED test_surface_does_not_hard_code_solution_file[.agents/skills/csharp-qa-gate/SKILL.md]
FAILED test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp-qa-gate/SKILL.md]
FAILED test_surface_does_not_hard_code_solution_file[.codex/codex-web-setup.sh]
FAILED test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh]
FAILED test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md]
FAILED test_surface_does_not_hard_code_solution_file[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md]
FAILED test_pushed_roots_carry_no_hard_coded_solution_file
FAILED test_review_workflow_step_eight_uses_governing_thresholds[.claude/skills/feature-review-workflow/SKILL.md]
FAILED test_review_workflow_step_eight_uses_governing_thresholds[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
FAILED test_precedence_copy_states_per_metric_fallback[.claude/rules/quality-tiers.md]
FAILED test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md]
FAILED test_precedence_copy_states_per_metric_fallback[.claude/rules/general-unit-test.md]
FAILED test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md]
FAILED test_precedence_copy_states_per_metric_fallback[.agents/skills/quality-tiers/SKILL.md]
FAILED test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers/SKILL.md]
FAILED test_precedence_copy_states_per_metric_fallback[.agents/skills/general-unit-test/SKILL.md]
FAILED test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md]
FAILED test_precedence_copy_states_per_metric_fallback[.claude/agents/feature-review.md]
FAILED test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md]
FAILED test_precedence_copy_states_per_metric_fallback[.claude/skills/feature-review-workflow/SKILL.md]
FAILED test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
FAILED test_precedence_copy_states_per_metric_fallback[.claude/hooks/validate-feature-review-coverage.ps1]
FAILED test_precedence_copy_states_per_metric_fallback[extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1]

`37 failed, 3 passed in 0.31s`

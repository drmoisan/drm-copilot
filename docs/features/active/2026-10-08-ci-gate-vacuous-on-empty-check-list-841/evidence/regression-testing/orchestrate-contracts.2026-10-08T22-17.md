# Epic-Child Contract Suite After the Orchestrate Edits (#841, P3-T5 and P3-T6) [expect-fail]

Timestamp: 2026-10-10T09-27
Command: poetry run pytest -v tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Summary line: `======================== 14 failed, 12 passed in 0.14s ========================`
- All eight `test_orchestrate_` nodes PASSED (S9 guard x2, schema head_sha x2, superseded wording x2, one-line command x2).
- The 14 failures are the feature-review stages that Phases 4 and 5 address; the exit code 1 is the expected outcome for this stage.
- P3-T5 mirror pair: PAIR-SUMMARY pairs=1 unequal=0
- Result matches the plan expectation exactly; no design-review stop.

Route: the pytest command ran exactly as written. Output was captured to SCRATCH and inspected; not committed.

## PASSED nodes (12)

- test_orchestrate_s9_states_epic_child_guard[.claude/skills/orchestrate/SKILL.md]
- test_orchestrate_s9_states_epic_child_guard[extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md]
- test_orchestrate_schema_head_sha_names_queried_checks[.claude/skills/orchestrate/SKILL.md]
- test_orchestrate_schema_head_sha_names_queried_checks[extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md]
- test_orchestrate_drops_required_check_wording[.claude/skills/orchestrate/SKILL.md]
- test_orchestrate_drops_required_check_wording[extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md]
- test_orchestrate_parser_command_stays_on_one_line[.claude/skills/orchestrate/SKILL.md]
- test_orchestrate_parser_command_stays_on_one_line[extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md]
- test_review_rule_drops_sha_exact_definition[.agents/skills/feature-review-workflow/SKILL.md]
- test_review_rule_drops_sha_exact_definition[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
- test_rule_resolution_reports_missing_heading
- test_rule_resolution_accepts_defined_heading

## FAILED node IDs (14, verbatim)

- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_review_rule_defines_satisfiable_qualifying_run[.claude/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_review_rule_defines_satisfiable_qualifying_run[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_review_rule_defines_satisfiable_qualifying_run[.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_review_rule_defines_satisfiable_qualifying_run[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_review_rule_drops_sha_exact_definition[.claude/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_review_rule_drops_sha_exact_definition[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_review_rule_sits_before_ordered_procedure[.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_review_rule_sits_before_ordered_procedure[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_review_rule_carries_codex_bullets[.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_review_rule_carries_codex_bullets[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_citing_copy_resolves_rule[.agents/skills/ci-workflows/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_citing_copy_resolves_rule[.agents/skills/benchmark-baselines/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_citing_copy_resolves_rule[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/ci-workflows/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_citing_copy_resolves_rule[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/benchmark-baselines/SKILL.md]

## P3-T5 mirror copy (recorded here; P3-T5 has no artifact of its own)

- Copy command: `cp .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (the plan's `cp` route; tool permissions allowed it).
- ROUTE_SUBSTITUTION: the acceptance command `sh SCRATCH/run-ps.sh SCRATCH/pair-hashes.ps1 <pair>` was replaced by the A4 substitute `git hash-object <source> <mirror>`.
- `git hash-object` output: both `.claude/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` -> 1136a01d54e31483bb588e6fa1c97043448d61d5
- PAIR-SUMMARY pairs=1 unequal=0

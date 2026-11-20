# Epic-Child Contract Suite After the Claude Review Edit (#841, P4-T3 and P4-T4) [expect-fail]

Timestamp: 2026-10-10T09-30
Command: poetry run pytest -v tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Summary line: `======================== 10 failed, 16 passed in 0.14s ========================`
- The four Claude-copy review nodes PASSED: `test_review_rule_defines_satisfiable_qualifying_run` and `test_review_rule_drops_sha_exact_definition`, each for `.claude/skills/feature-review-workflow/SKILL.md` and its Claude bundle mirror.
- The 10 failures are the `.agents` stage that Phase 5 addresses; exit code 1 is the expected outcome for this stage.
- P4-T3 mirror pair: PAIR-SUMMARY pairs=1 unequal=0
- Result matches the plan expectation exactly; no design-review stop.

Route: the pytest command ran exactly as written. Output was captured to SCRATCH and inspected; not committed.

## Claude-copy review nodes (PASSED)

- test_review_rule_defines_satisfiable_qualifying_run[.claude/skills/feature-review-workflow/SKILL.md]
- test_review_rule_defines_satisfiable_qualifying_run[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]
- test_review_rule_drops_sha_exact_definition[.claude/skills/feature-review-workflow/SKILL.md]
- test_review_rule_drops_sha_exact_definition[extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md]

The other 12 PASSED nodes are the eight `test_orchestrate_` nodes, the two `.agents` `test_review_rule_drops_sha_exact_definition` nodes, and the two synthetic `test_rule_resolution_` nodes.

## FAILED node IDs (10, verbatim)

- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_review_rule_defines_satisfiable_qualifying_run[.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_review_rule_defines_satisfiable_qualifying_run[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_review_rule_sits_before_ordered_procedure[.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_review_rule_sits_before_ordered_procedure[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_review_rule_carries_codex_bullets[.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_review_rule_carries_codex_bullets[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_citing_copy_resolves_rule[.agents/skills/ci-workflows/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_citing_copy_resolves_rule[.agents/skills/benchmark-baselines/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_citing_copy_resolves_rule[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/ci-workflows/SKILL.md]
- FAILED tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py::test_agents_citing_copy_resolves_rule[extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/benchmark-baselines/SKILL.md]

## P4-T3 mirror copy (recorded here; P4-T3 has no artifact of its own)

- Copy command: `cp .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` (the plan's `cp` route; tool permissions allowed it).
- ROUTE_SUBSTITUTION: the A4 acceptance check was replaced by `git hash-object <source> <mirror>`.
- `git hash-object` output: both files -> 37371ab450d222a7036e5c1a1a16a371e5f8eb52
- PAIR-SUMMARY pairs=1 unequal=0

# Preflight Fixes

Timestamp: 2026-11-09T22-23
Plan: docs/features/active/owner-directive-pass-down-1157/plan.2026-11-09T16-32.md

1. `## Required References` | glob token in prose | `issue-1157-*` replaced by the prefix statement `issue-1157-`.
2. `## Binding Constraints` | illustrative path | `/synthetic-worktrees/...` replaced by "fixture roots under `/synthetic-worktrees/`".
3. `## Binding Constraints` | sibling merge-order binding incomplete | re-read-before-edit rule extended to every other existing file the plan edits (owner-directives copies, nine agents and bundle copies, the stop hook, the owner-directives module, and their bundle copies).
4. `## Binding Constraints` | changed-behavior disposition missing | added the disposition that `OrchestratorState.Manifest.Tests.ps1` (bundle byte identity) and `test_push_down_claude_resource_contracts.py` fail for an edited bundled file until its copy task, and no earlier acceptance runs them.
5. [P3-T2] | glob token in prose | `validate-orchestrator-output.*.Tests.ps1` replaced by the eleven concrete suite names under `tests/scripts/claude-hooks/`.
6. [P4-T1] | changed-behavior disposition missing | named the discovery-driven suites that pick up the new registration with dispositions: `hook-dependency-guard-completeness.Tests.ps1`, `PreToolUsePayload.Contract.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `claude-settings.Tests.ps1`.
7. [P5-T3] | citation correction | `PRESCRIPTIVE_EPIC_LITERALS` applies to the delivered parallel surface (`.claude/skills/parallel-orchestrate/SKILL.md`), not the epic skill, which already carries those literals; the sentence now names the parallel text and `test_delivered_runtime_files_carry_no_prescriptive_epic_literal`.
8. [P5-T3] | glob token / citation | `KICKOFF_*` replaced by the five tuple names and their file `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
9. [P5-T3] | changed-behavior disposition missing | named the existing kickoff-section tests with dispositions: `test_kickoff_section_carries_no_child_merge_instruction`, `test_parallel_issue_adoption_skill_contracts.py`, `test_kickoff_element_three_carries_the_combined_issues_line`, and the marker-binding row of `enforce-parallel-drift-gate.Tests.ps1`.
10. `## Pre-Mortem` (CI-only behavior) | illustrative path | `/synthetic-worktrees/...` replaced by "roots under `/synthetic-worktrees/`".
11. `## Pre-Mortem` (Evidence) | placeholder path | `evidence/<kind>/` replaced by the three concrete evidence folders the plan writes.

Validation after fixes: branch-current Python CLI `plan` subcommand exit 0.

# Task Check P4-T2

Timestamp: 2026-11-14T05-35
Command: sh SCRATCH/issue-1162-py.sh -q -n 4 -p no:cacheprovider -o addopts="" --tb=line <7 contract files>; sh SCRATCH/issue-1162-tc.sh "" "<5 Pester files>"
EXIT_CODE: 1
Output Summary: pytest 68 passed, 2 failed; Pester 109 passed, 0 failed (DocumentationEstateEpicTemplate.Tests.ps1 passes unchanged). Both pytest failures are bundle-presence checks owned by P4-T5: test_epic_skill_script_citations_shipped.py::test_every_epic_surface_citation_is_shipped (Invoke-EpicCrossReadiness.ps1 not yet bundled) and test_epic_run_kickoff_discovery_contract.py::test_discovery_fix_is_mirrored_into_bundled_payload (epic-run SKILL.md bundle copy).

## Changed files

- .claude/skills/epic-plan/SKILL.md: new section `## Cross-Epic Dependencies in Preparation (cross_epic_depends_on)` after `## Preparation-Mode Child Delegation`, naming the key, its planner-checkpoint copy, and the preparation-mode line starting `Upstream context for` with `not merged`.
- .claude/skills/epic-run/SKILL.md: one appended sentence in `## Scope` naming `cross_epic_depends_on`.
- .claude/agents/epic-planner.md: appended field-list sentence in `## Checkpoint Persistence` naming `cross_epic_depends_on`.
- docs/features/templates/epic/epic.md and extensions/drm-copilot/resources/feature-templates/epic/epic.md: `cross_epic_depends_on` comment lines above `features:`; no live key line. cmp reports the two files identical.

## Selection and rule

Contract tests that read the changed paths: test_claude_rules_frontmatter.py, test_epic_kickoff_contract.py, test_epic_run_kickoff_discovery_contract.py, test_epic_skill_script_citations_shipped.py, test_parallel_planner_surface_contracts.py, test_push_down_codex_and_agents_customizations.py, test_single_pass_preflight_contracts.py; Pester checkpoint-hygiene-skill-contract, early-start-skill-contract, planner-worktree-removal-contract, codex-epic-runtime-contracts, and the plan-named DocumentationEstateEpicTemplate.Tests.ps1. Hook suites that only name an epic.md path inside checkpoint fixtures were not selected.

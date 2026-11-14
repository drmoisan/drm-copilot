# Task Check P4-T1

Timestamp: 2026-11-14T05-33
Command: sh SCRATCH/issue-1162-py.sh -q -n 4 -p no:cacheprovider -o addopts="" <12 contract files>; sh SCRATCH/issue-1162-tc.sh "" "<9 Pester contract files>"
EXIT_CODE: 1
Output Summary: pytest 178 passed, 8 failed; Pester 228 passed, 1 failed. test_epic_orchestrator_permission_contracts.py, test_epic_orchestrate_main_sync_contract.py, test_epic_bounded_child_return_contract.py, and early-start-skill-contract.Tests.ps1 pass. Every failure is a bundle-mirror or frozen-digest check owned by a later task (listed below); no failure concerns the content of the new section.

## Changed files

- .claude/skills/epic-orchestrate/SKILL.md: new section `## Cross-Epic Dependencies (cross_epic_depends_on)` placed after `## Early Dependent Starts (early_start)` (not between `## Merge-on-Green Kickoff Parameter` and `## Model Selection`); appended reference text in `## Epic Dependency Manifest`, at the end of `## Epic Integration Branch Lifecycle` (unnumbered paragraph, no MAIN_SYNC_FRAGMENTS or REMOVED_CHILD_ITEM_PHRASES text), in `## Epic-Level Checkpoint`, and in `## Completion Requirements`.
- .claude/agents/epic-orchestrator.md: `Bash(pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1*)` grant in the trailing-wildcard form of the Invoke-EpicWave.ps1 grant; appended paragraphs in `## Wave Scheduling` and `## Completion Requirements`.

## Selection and rule

Contract tests that read the two changed paths (git grep of the test tree for `epic-orchestrate/SKILL.md` and `epic-orchestrator.md`), plus the consumers of parallel_orchestrator_surface_expectations.py and merge_queue_documentation_expectations.py, and claude-architecture-doc.Tests.ps1 (agent tool names).

pytest: test_claude_rules_frontmatter.py, test_codex_full_migration_inventory.py, test_epic_bounded_child_return_contract.py, test_epic_orchestrate_main_sync_contract.py, test_epic_orchestrator_permission_contracts.py, test_epic_run_kickoff_discovery_contract.py, test_epic_skill_script_citations_shipped.py, test_execution_environment_brief_contracts.py, test_orchestrator_state_remediation_docs.py, test_skill_bundle_contract_repo.py, test_completion_gate_documentation_contracts.py, test_parallel_orchestrator_surface_contracts.py.

Pester: enforce-epic-wave-barrier.FolderResolution, enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder, validate-orchestrator-output-resolution, checkpoint-hygiene-skill-contract, early-start-skill-contract, NestingDepthContract, owner-directives-skill-contract, codex-epic-runtime-contracts, claude-architecture-doc.

## Failures owned by later tasks

- P4-T5 (bundle copies and core.json): test_epic_run_kickoff_discovery_contract.py::test_discovery_fix_is_mirrored_into_bundled_payload; test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror[claude-epic-orchestrate] and [claude-epic-orchestrator-agent]; test_epic_skill_script_citations_shipped.py::test_every_epic_surface_citation_is_shipped (Invoke-EpicCrossReadiness.ps1 not yet in the bundle); test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled and ::test_every_skill_folder_file_is_carried_by_skill_packs; NestingDepthContract 'bundle copy matches live file'.
- P5-T2 (frozen digests): test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest for both files.

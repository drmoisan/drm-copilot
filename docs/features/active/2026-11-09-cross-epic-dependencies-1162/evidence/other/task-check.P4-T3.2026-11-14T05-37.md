# Task Check P4-T3

Timestamp: 2026-11-14T05-37
Command: sh SCRATCH/issue-1162-gen.sh (generate_codex_agent_variants --check); sh SCRATCH/issue-1162-py.sh -q -n 4 -p no:cacheprovider -o addopts="" --tb=line <6 Codex contract files>; sh SCRATCH/issue-1162-tc.sh "" "<4 Pester files>"
EXIT_CODE: 1
Output Summary: generator check exit 0; pytest 50 passed, 2 failed; Pester 89 passed, 1 failed. test_codex_agent_wrapper_contracts.py, test_codex_handoff_contract_parity.py, test_epic_orchestrate_main_sync_contract.py, and early-start-skill-contract.Tests.ps1 (ESS-KICKOFF-LITERAL-INTACT) pass, and the no-`command =` rule of codex-epic-runtime-contracts.Tests.ps1 passes. Every failure is a root-versus-bundle byte-identity check owned by P4-T5.

## Changed files

- .agents/skills/epic-orchestrate/SKILL.md: D1 rules naming `cross_epic_depends_on` appended to `## Manifest Contract`; new section `## Cross-Epic Dependencies (cross_epic_depends_on)` before `## Fan-In and Conflict Handling`, citing `.codex/lib/epic-wave/Invoke-EpicCrossReadiness.ps1` and carrying the same token list as the P4-T1 section. `## Integration Branch and Child Worktrees` is not edited, and the full epic-mode kickoff literal is not repeated.
- .agents/skills/epic-plan/SKILL.md: appended paragraph naming `cross_epic_depends_on` and the preparation-mode line starting `Upstream context for` with `not merged`.
- .agents/skills/epic-run/SKILL.md: appended sentence naming `cross_epic_depends_on`.
- .codex/agents/epic-orchestrator.toml: one `## Scheduling and Routing` bullet with the launch hold, `git merge --no-ff`, `-Mode main`, and `-WaitSeconds 540`, citing `Invoke-EpicCrossReadiness.ps1`; no line begins with `command =`.
- .codex/agents/epic-planner.toml: appended sentence in `## Checkpoint` naming `cross_epic_depends_on`.

## Selection and rule

Contract tests that read the Codex surfaces: test_codex_agent_wrapper_contracts.py, test_codex_handoff_contract_parity.py, test_epic_orchestrate_main_sync_contract.py, test_push_down_codex_and_agents_customizations.py, test_push_down_codex_and_agents_resource_contracts.py, test_codex_full_migration_inventory.py, and the generator check; Pester codex-epic-runtime-contracts, early-start-skill-contract, planner-worktree-removal-contract, checkpoint-hygiene-skill-contract.

## Failures owned by P4-T5

- test_codex_full_migration_inventory.py::test_all_repo_agent_skills_are_bundled_and_identical
- test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts
- codex-epic-runtime-contracts.Tests.ps1 'keeps root and tracked bundle runtime copies byte-identical'

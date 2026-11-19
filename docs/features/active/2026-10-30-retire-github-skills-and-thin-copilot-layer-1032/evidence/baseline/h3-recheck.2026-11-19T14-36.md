# H3 Upstream Assumption Re-check ([P0-T1])

Timestamp: 2026-11-19T14-36
Plan: plan-h3-sync-writer-retirement.md
Command: git fetch origin epic/shared-agent-harness-layer-integration main; git merge-base origin/epic/shared-agent-harness-layer-integration HEAD; ls, grep and Grep reads of each H3-SURFACES anchor at HEAD; grep of the main plan checklist; grep of the greatest main-plan self-review for FAIL rows
EXIT_CODE: 0
Output Summary: UH-1 holds; UH-2 holds. No blocked: premise_falsified item.

MB derivation: per orchestrator decision AD-7, MB is the merge base of origin/epic/shared-agent-harness-layer-integration and HEAD (recorded in `<FEATURE>/evidence/other/ad7-merge-base-deviation-h3.2026-11-19T14-36.md`). The anchors were read in the current tree at HEAD, after the sync with the integration branch; HEAD differs from MB only by this feature's own commits, none of which edits an H3-SURFACES file.

## UH-1 — holds

- `plan.2026-10-30T18-39.md`: 36 canonical tasks checked, 0 unchecked.
- Greatest self-review carrying `Plan: plan.2026-10-30T18-39.md`: `self-review.2026-11-19T12-03.md`; 0 rows with `| FAIL`, 135 PASS rows. (The later `self-review.2026-11-19T14-22.md` belongs to remediation cycle 1, also complete.)

## UH-2 — holds

- `scripts/dev-tools/sync-agents-from-instructions.ps1`, `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`, `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`: present.
- `drmCopilotExtension.syncAgentsFromInstructions` in `contributes.commands` of `extensions/drm-copilot/package.json`: present.
- `registerSyncAgentsFromInstructionsCommand` and its call in `registerRepoAutomationAdminCommands` (`repo-automation-command-registration-admin.ts`); `executeBundledScript` and `getWorkspaceRoot` imported from `./command-runtime`: present.
- Catalog entries keyed `scripts/dev_tools/sync-agents-from-instructions.ps1` in `reference-rewrites.ts` and `push_down_copilot_customizations_rewrites.py`: present.
- Tests: `contains all seven catalog entries keyed by normalized reference`, `rewrites the sync-agents-from-instructions reference`, `reports unmatched references without rewriting them, in first-seen order` (reference-rewrites.test.ts); `test_sync_agents_script_reference_rewrites_to_live_command`, `test_push_down_reports_unmatched_script_references_without_rewrite`; `test_build_rewrite_catalog_contains_expected_command_targets` and `test_rewrite_text_references_reports_unique_unmatched_references` (in `test_push_down_copilot_customizations_helpers.py`); the four extension tests named by P1-T2: present.
- Task `Dev: Sync AGENTS.md from Instructions` in `.vscode/tasks.json`: present.
- Key `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` in `config/poshqc-shard-weights.json`: present.
- `README.md`: `Customization conversion and publishing:` and `### Sync AGENTS.md from instructions` present. `extensions/drm-copilot/README.md`: `## VS Code Commands` and `## Sync AGENTS.md from Instructions` present. `extensions/drm-copilot/CHANGELOG.md`: `## [Unreleased]` present.
- Child 3 has not edited the writer: `git log` of `scripts/dev-tools/sync-agents-from-instructions.ps1` shows only the original sync-agents commits; no #1028 commit.

## Observation (not an upstream assumption)

- Child 3 (#1028) added `scripts/harness-generation/HarnessInstructions.psm1`, whose `GENERATED-NOTE` check names `sync-agents-from-instructions` in a header comment and in its finding detail text. It is neither a `historical` nor an `example` reference class; P2-T4 must classify or resolve it. Recorded in `writer-reference-baseline` and carried to P2-T4.

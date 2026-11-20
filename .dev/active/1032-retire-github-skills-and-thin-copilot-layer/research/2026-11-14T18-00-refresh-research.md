# Research Refresh: Retire `.github/skills`, Settle `.github/agents`, Thin Copilot Layer (Issue #1032)

- Issue: #1032 (child 6 of epic #1018); branch `feature/retire-github-skills-and-thin-copilot-layer-1032`
- Mode: preparation-mode planning refresh (research only; no plan or spec edited)
- Inputs: `spec.md`, `user-story.md`, `issue.md`, `research/research.2026-10-30T23-02.md`, `plan.2026-10-30T18-39.md`, `plan-agents-branch-a.md`, `plan-agents-branch-b.md`; the name-status list of files changed outside `docs/features` since the feature folder was last touched (`SCRATCH/issue-1032-changed-since-plan.txt`); the current worktree tree.
- Filename: `<timestamp>-<short-name>-research.md` per the researcher hook. The stamp `2026-11-14T18-00` is the value the orchestrator supplied, not a clock reading (the task-researcher route has no clock tool). An identical earlier copy, `research-refresh.2026-11-14T18-00.md`, was written under a non-conforming name and can be deleted by the orchestrator.
- Method: every fact below was read with Read, Grep or Glob against the worktree. Facts that need `git` or `gh` are marked UNVERIFIED for the orchestrator.

## UNVERIFIED Items for the Orchestrator

- U-V1: issues #1001, #1002, #1003, #1006 merged and #1013 closed (stated by the orchestrator; needs `gh`).
- U-V2: byte identity among copies (for example the six brief copies, the `.github` and `.agents` copies of the docs skills apart from role-link lines). No hash tool is available; the tests named in section 2.7 assert these identities.
- U-V3: whether `Get-ChildItem -LiteralPath` on a missing sweep root fails the `TCW-SWEEP-*` and parallel-gate-wording sweep `It` blocks under Pester 6 (section 2.7). The recommendation removes the root either way.
- U-V4: the exact hunk boundaries of process-reduction patches `0001` and `0006` around the brief `## Preflight Defect Classes the Validator Cannot See` bullet and the test modules they touch (section 3). The ledger chain test settles it.
- U-V5: the `name:` values of `epic-review`, `feature-review`, `prd-feature`, `staged-review` and `task-researcher` in `.github/agents` (they decide whether those stems are name collisions; the prior research counted 11 name collisions without them).
- U-V6: whether any test outside the searched trees counts `contributes.commands` entries in `extensions/drm-copilot/package.json` (searched `extensions/drm-copilot/test` for `contributes`; no count assertion found in the five hits' file names, contents not read).

## 1. Superseded-Work Check at Citation Level

### 1.1 Spec and research citations

| Citation | State | Detail |
| --- | --- | --- |
| `.github/skills/` (33 folders + `README.md`, 34 files) | changed | 42 skill folders + `README.md` (43 direct entries, 51 files: 42 `SKILL.md`, 8 `docs-author-page/templates/*.md`, `README.md`). Nine folders added: `docs-author-page`, `docs-init`, `docs-inventory-surface`, `docs-plan-ia`, `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`, `documentation-workflow`, `owner-directives`. |
| `extensions/drm-copilot/resources/customizations/.github/skills/` | changed | Same 51 files as the source tree. |
| U1, U2: `.github/skills/feature-promotion-lifecycle/SKILL.md` `## MCP-First Execution Rule`, `## Canonical Fallback Command Sequence`, `## Canonical Fallback Short-Path Sequence (Minor Audit Mode)` | unchanged | File not in the changed list; headings present. |
| U3: `.github/skills/feature-review-workflow/SKILL.md` `## File Size Advisory` | unchanged (heading); file changed | File gained `## Documentation Surface Check` (new unique section, U5 in section 2.1). |
| Execution-environment brief, six copies, `## Purpose and Maintenance` "byte-identical in six locations" | unchanged | All six copies exist and each contains `byte-identical in six locations`. New "six" statements were added (section 2.6). |
| `## Preflight Defect Classes the Validator Cannot See` token `in all six byte-identical copies` | unchanged | Present in the brief; inside ledger regions (section 3). |
| `atomic-plan-contract` `## Design-Level Plan Contract (Mandatory)` Pre-Mortem token `in all six byte-identical copies` | unchanged | Present; inside ledger regions (section 3). |
| Seven `.github/agents` files referencing `.github/skills` | changed | Four remain: `atomic_executor`, `atomic_planning`, `orchestrator`, `task-researcher`, each with the read-first line naming `.github/skills/execution-environment/SKILL.md`. `csharp-orchestrator`, `powershell-orchestrator`, `python-orchestrator` no longer name `.github/skills`. |
| `.github/agents` 46 files, 20 `handoffs:` | changed | 50 files (added `docs-architect`, `docs-author`, `docs-coverage-reviewer`, `docs-reconciler`); `handoffs:` still in the same 20 files. |
| Name collisions with `.claude/agents` (11) | changed | The four docs roles collide: each `.github/agents/docs-*.agent.md` `name:` equals a `.claude/agents/docs-*.md` stem. At least 15 (see U-V5). |
| `.github/copilot-instructions.md` `# Tone policy` body | unchanged | Five bullets, not in the changed list. |
| `.github/prompts` | changed | Four prompt files modified (`execute-hard-lock`, `generate-commit-message-repo`, `remediate-comments`, `review-feature`); none references `.github/skills` (not re-counted). |
| `.github/hooks` six files | unchanged | Same six files; not in the changed list. |
| `.github/instructions` | changed | `bash-command-shape.instructions.md` added; five modified. Not edited by this child. |
| `CLAUDE.md` `## Tone Policy`, `## Policy Compliance Reading Order` item 1 naming `.github/copilot-instructions.md` | unchanged | Both still name it (OQ5 still applies to `CLAUDE.md`). |
| `.claude/rules/tonality.md` naming `.github/copilot-instructions.md` | changed | No longer names it (only `.claude/rules/parallel-orchestration.md` does; OQ6 unchanged). |
| `AGENTS.md` token `Do not use jokes` | unchanged | Present (under `## Source: tonality.md` and `## Tone Policy`). |
| `.vscode/settings_required.json`, "`.vscode/settings.json` is gitignored" | moved | Renamed to tracked `.vscode/settings.json`; `.gitignore` now ignores only `.vscode/settings.json.bak`. No `chat.*` key present. |
| `tests/scripts/dev_tools/test_vscode_workspace_settings.py` | changed | Reads `.vscode/settings.json` only: `test_workspace_settings_pin_vscode_to_powershell_7`, `test_workspace_settings_contain_no_host_specific_paths` (four host-specific markers, including `file:///` and `vscode-remote://`). |
| `COPILOT_ROOT_FOLDERS` in `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` | unchanged | Five roots including `.github/skills`. |
| `ROOT_FOLDERS` in `scripts/dev_tools/agentic_sync.py` and its module docstring | unchanged | Five roots including `Path(".github/skills")`. |
| Pack manifests list no `.github/` path | unchanged | 12 manifest files under `claude-customizations/pack-manifests/` and `codex-and-agents-customizations/pack-manifests/`; zero `.github/` and zero writer-token matches; no `customizations/pack-manifests/` folder. |
| `config/harness-parity-matrix.json`, schema, `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` | gone (not yet delivered) | Absent; child 1 (#1025) open. |
| `scripts/harness-generation/Invoke-HarnessGeneration.ps1` | gone (not yet delivered) | Absent; child 3 (#1028) open. |
| `Get-DiscoveryAgentProfilePath`, `.github/hooks/discovery.json` | unchanged | `discovery.json` still registers the five `discovery-*.ps1` scripts. |
| `docs/engineering/claude-code-architecture.md` `## 1. Copilot-to-Claude Equivalence Table`, `## 3. Sync Strategy` authoritative statement, `### Authoritative source by asset category`, ``### Canonical `.github/skills` migration map``, `### Manual sync procedure` | unchanged | All headings present; file modified elsewhere (ledger 0005 holds a block in the planner paragraph, outside these sections). |
| `.agents/README.md` "historical source material" sentence; `README.md` `## Policy and skills references` link to `.github/skills/README.md` | unchanged | Both present. |
| `docs/engineering/legacy-discovery-and-parity/maintainer-guide.md`, `workflow.md`, `consumer-onboarding.md` | unchanged in content cited | One `.github/skills` hit each. |
| H3: `scripts/dev-tools/sync-agents-from-instructions.ps1`, template, `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` | unchanged / changed | Script and template present; script still names `copilot-instructions.md` (4 matches). The Pester suite was modified but still asserts only writer behavior; `It` `Bundled sync-agents template matches the repo-root script exactly` present. |
| H3: `drmCopilotExtension.syncAgentsFromInstructions` in `package.json`, `registerSyncAgentsFromInstructionsCommand` and its entry in `registerRepoAutomationAdminCommands`, `executeBundledScript` import | unchanged | All present. |
| H3 Jest tests in `extension.test.ts`, `extension.integration.test.ts`, `extension.workflow-commands.test.ts` | unchanged | All four named tests present. |
| H3: `buildRewriteCatalog` entry and "seven Python catalog entries" doc comment; tests `contains all seven catalog entries keyed by normalized reference`, `rewrites the sync-agents-from-instructions reference`, `reports unmatched references without rewriting them, in first-seen order` | unchanged | Present. |
| H3: `build_rewrite_catalog` entry; `test_sync_agents_script_reference_rewrites_to_live_command`, `test_push_down_reports_unmatched_script_references_without_rewrite` | unchanged | Present. |
| H3: `.vscode/tasks.json` label `Dev: Sync AGENTS.md from Instructions` | unchanged | Present; tasks.json modified elsewhere. Ledger 0001 holds four tasks.json blocks that do not contain this task. |
| H3: `README.md` `Customization conversion and publishing:`, `### Sync AGENTS.md from instructions`; `extensions/drm-copilot/README.md` `## VS Code Commands` item and `## Sync AGENTS.md from Instructions`; `extensions/drm-copilot/CHANGELOG.md` `## [Unreleased]` | unchanged | Present; `## [Unreleased]` has `### Added`, `### Changed`, `### Fixed` and no `### Removed`. |
| H3 claim "no `config/poshqc-*.json` entry names these files" (plan P5-T1) | changed | `config/poshqc-shard-weights.json` (new) carries the key `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`. |

### 1.2 Main plan citations

Every Python symbol and test the main plan names was found unchanged: `_BRIEF_COPIES`, `test_brief_copies_are_byte_identical`, `test_brief_is_referenced_by_copilot_base_agents`, `test_brief_preflight_classes_include_brief_maintenance`, `test_architecture_doc_lists_brief`, `test_execution_environment_fact_is_unchanged_across_copies`, `_CONTRACTS`, `_REMEDIATION_SURFACES`, `_COPILOT_BASE_EDITED`, `_ROUTER_AND_PROMPT_SURFACES`, `test_contract_premortem_mirror_parity_requires_brief_update_task`, `AC_TRACKING_SKILLS`, `EVIDENCE_SKILLS`, `_GITHUB_BUNDLE`, the `github-ac-tracking` and `github-evidence` pairs, `PLAN_CONTRACT_SKILLS`, `ROOT_MIRROR_PAIRS`, `required_paths`, `_assert_state_machine_contract`, `test_csharp_change_budget_router_requires_orchestrated_small_path_wording`, `_assert_bundle_mirror_contract`, `STEP_EIGHT_COPIES`, `FEATURE_REVIEW_TEXT_COPIES`, `SOLUTION_SCAN_ROOTS`, `_ALL_CONTRACT_COPIES`, `COPILOT_ROOTS`, `test_copilot_bundle_mirrors_every_scoped_github_file`, `test_skill_is_represented_on_every_host`, `canonical_path`, `test_generated_copies_are_the_deterministic_role_link_rewrite`, `skill` (discovery workflow), `test_root_folders_include_published_github_hooks_in_scoped_order`, `test_force_left_to_right_overrides_newer_right`, `_seed_scoped_source_files`, `test_push_down_copies_scoped_github_trees_to_empty_destination`, `test_push_down_overwrites_existing_destination_file`, `test_build_rewrite_catalog_contains_expected_command_targets`, `test_rewrite_text_references_reports_unique_unmatched_references`, `test_thinking_beast_mode_bundle_mirror_matches_root_agent`, `test_cli_reference_lists_every_discovery_mcp_tool_and_command`. Jest tests `classifies created vs overwritten and enumerates in root then path order`, `accumulates rewrite counters and first-seen unmatched references`, `exposes the inlined copilot root-folder enumeration order`: unchanged. Pester `claude-architecture-doc.Tests.ps1`: unchanged (both `It` blocks).

Citations that changed or became stale: `.vscode/settings_required.json` (moved, P0-T3 Edit Set row, P4-T4); "each still hold one `SKILL.md` per skill folder plus `README.md`" (P0-T3; `docs-author-page` also holds `templates/`); the #1003 and #1013 notes in `## Edit Set` (obsolete, section 4); the P5-T1 claim about `config/poshqc-*.json` (section 1.1); `Invoke-PoshQCTest` subset runs in P0-T11, P6-T8 and the isolation runs of P6-T9 (superseded by the test-execution launcher and parallel-only gates, section 5).

### 1.3 Branch plan citations

Both branch plans cite only main-plan evidence, `config/harness-parity-matrix.json`, `$script:AgentProfileLayout` (unchanged) and the agent-pinning tests (all present). Stale: the expected agent file count (50, not 46), the collision-name list (adds the four docs roles), `Invoke-PoshQCTest` runs, the reversed-order and seeded shuffled runs of P2-T1 and P2-T2, and the absence of a `[phase-gate]` task at the end of Phase 1.

### 1.4 Judgment

No merged change since 2026-10-31 delivers any deliverable of this feature:

- `.github/skills` was not retired; it grew from 33 to 42 folders.
- `.github/agents` was not settled; it grew to 50 files.
- `.github/copilot-instructions.md` was not thinned.
- No `chat.*` collision key exists in `.vscode/settings.json`. The rename of `settings_required.json` to a tracked `settings.json` removes the OQ1 delivery problem but does not deliver the keys.
- `sync-agents-from-instructions.ps1`, its template, task, command and rewrite entries all remain.
- The brief still states six copies.
- No parity matrix exists.

Main removed the `.github/skills` reference from three Copilot orchestrator agents, but the plan already edits only the four agents that still carry it, so no plan task becomes redundant.

SUPERSEDED: none

## 2. Known Facts, Verified and Quantified

### 2.1 `.github/skills` inventory

Every one of the 42 folders has a same-named folder in `.agents/skills` and in `.claude/skills` (each name checked against Globs of `.agents/skills/**/SKILL.md` and `.claude/skills/**/SKILL.md`). `.github/skills` remains a strict subset of both trees by name.

| Folder | `.agents` | `.claude` | Unique content in the Copilot copy |
| --- | --- | --- | --- |
| acceptance-criteria-tracking, adjudicate-unspecified-behavior, characterize-runtime-behavior, csharp-change-budget-router, csharp-orchestration-state-machine, discovery-behavior-reconciliation, discovery-coverage-ledger, discovery-parity-matrix, discovery-repo-inventory, discovery-runtime-characterization, discovery-validate-artifacts, discovery-workflow, extract-feature-contract, generate-acceptance-scenarios, initialize-discovery-workspace, inventory-legacy-system, make-skill-template, policy-audit-template-usage, policy-compliance-order, powershell-change-budget-router, powershell-orchestration-state-machine, pr-base-branch-merge-base, pr-context-artifacts, reconcile-parity-matrix, review-discovery-coverage, skill-canonical-location-audit, validate-discovery-artifacts | yes | yes | As in prior research section 1.2 (the 16 discovery skills carry Copilot role links `../../agents/<role>.agent.md`; canonical family per issue #980). These files are not in the changed list. |
| feature-promotion-lifecycle | yes | yes | U1, U2 (unchanged; stale per issue #168). |
| feature-review-workflow | yes | yes | U3 `## File Size Advisory` (present elsewhere). **U5 (new)** `## Documentation Surface Check`: present by content in `.claude/agents/feature-review.md`, `.agents/skills/feature-review/SKILL.md` and `.codex/agents/feature-review.toml` under the same heading; absent from the `.claude` and `.agents` `feature-review-workflow` skills. Same placement class as U3: mechanism-only, no port. |
| atomic-plan-contract | yes | yes | No unique heading: the Copilot copy's level-two headings are a subset of the `.agents` copy (it lacks `## Non-Overridable Evidence Path Clause`). It is a non-identical source in the process-reduction ledger (section 3). Sentence-level comparison not performed. |
| evidence-and-timestamp-conventions | yes | yes | No unique heading (Copilot copy lacks `## Non-Overridable Authority`). |
| execution-environment | yes | yes | None; one of the six byte-identical copies (asserted by tests). |
| remediation-handoff-atomic-planner | yes | yes | No unique heading (same five headings). |
| docs-author-page (+ 8 templates), docs-inventory-surface, docs-plan-ia, docs-reconcile-behavior, docs-review-coverage, docs-validate, documentation-workflow | yes | yes | **U4 (new)**: per-tool role links. The Copilot copies link `../../agents/<role>.agent.md`; the `.agents` copies link `../../../.codex/agents/<role>.toml` (verified in `documentation-workflow` `## Dispatch Order` list). Same class as the discovery family: a single byte-identical source cannot carry per-tool links (OQ4 extends to this family). Templates are byte-identical across all six skill locations (asserted by `docs-authoring-roles.Mirrors.Tests.ps1`). |
| docs-init | yes | yes | None found (no role link). |
| owner-directives | yes | yes | None: `owner-directives-skill-contract.Tests.ps1` (`S11 keeps the skill copy <Copy> byte-identical to the .claude skill`) asserts byte identity. |

Disposition summary: U1, U2 stale; U3, U5 present elsewhere (mechanism-only); U4 is a per-tool link difference that depends on child 3's role-link rewrite, which child 3's current plan (`plan.2026-10-30T18-30.md`) does not mention for the docs family (it names only the six brief copies). No section requires a port by this child.

### 2.2 `.github/agents` versus `.claude/agents`

- `.github/agents`: 50 files. New since planning: `docs-architect`, `docs-author`, `docs-coverage-reviewer`, `docs-reconciler` (each `name:` equals its stem; each has a `.claude/agents/<role>.md` and `.codex/agents/<role>.toml` counterpart, and bundle copies, asserted by `docs-authoring-roles.Mirrors.Tests.ps1` `places <Role> at all six agent locations with byte-identical bundle copies`).
- The docs roles are not handoff targets and declare no `handoffs:`; they name skills by name (`docs-author-page`), so retiring `.github/skills` does not break them.
- `.claude/agents`: 29 files, including the four docs roles.
- Consequence: the docs roles enlarge the VS Code name-collision set (`chat.agentFilesLocations`), and they are bound by `tests/scripts/claude-runtime/DocsAuthoringRoles.Helpers.ps1` `Get-DocsAuthoringAgentPath` (Copilot path `.github/agents/<role>.agent.md`). Neither branch removes them under the OQ2 default; the branch plans' file set and the `copilot:agent:*` count must include them.

### 2.3 `.vscode/settings.json`

- Tracked; carries coverage-gutters, koverage, Jest (`jest.jestCommandLine`, `jest.rootPath`, `jest.runMode`, `jest.useJest30`), PowerShell 7 pin, pytest, terminal and Pester settings. No `chat.*` key.
- Asserting tests: only `tests/scripts/dev_tools/test_vscode_workspace_settings.py` (two tests above). `test_json_config.py` and `test_validate_json.py` mention `.vscode` but were classified by the prior plan as building their own fixtures (not re-read). `config/blast-radius.json` and `extensions/drm-copilot/src/poshqc-folder-picker.ts` list `.vscode` as a directory name, not as an assertion.
- Effect: collision controls become a direct edit of the tracked file when E4 shows workspace scope works; the copy step, `settings_required.json`, and OQ1's gitignore premise are obsolete. The collision keys contain none of the four host markers, so both tests stay green.

### 2.4 PreToolUse dispatcher (#1159)

- `.claude/settings.json` has one PreToolUse registration (`invoke-pretooluse-dispatch`); hooks are listed in `.claude/hooks/pretooluse-dispatch.json` (no `github` token in it). Codex has the same shape.
- `.github/hooks` is unaffected: `.github/hooks/discovery.json` is the Copilot-native registration of the five `discovery-*.ps1` scripts and is not part of either dispatcher.
- Plan citations: no task of the three plans edits or cites a hook registration. The run-only contract test `test_push_down_pack_manifest_dependency_closure.py` (spec `## Execution Preconditions`) reads hook scripts named by `.claude/settings.json` and now also by the dispatcher registry; this child edits neither, so the citation stays valid as run-only. AC8 and child 5's row are unchanged.

### 2.5 Push-down packs and root constants

- Current pack manifests: `claude-customizations/pack-manifests/{core,csharp-legacy,csharp-modern,powershell,python,typescript}.json` and `codex-and-agents-customizations/pack-manifests/{core,csharp-legacy,csharp-modern,powershell,python,typescript}.json`. None lists a `.github/` path or a writer token. No Copilot bundle manifest exists.
- `COPILOT_ROOT_FOLDERS` and `agentic_sync.ROOT_FOLDERS` exist unchanged, each listing `.github/skills`.
- Upstream drift risk: child 4's refreshed plan (`docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/plan.2026-10-30T18-37.md`) creates `RES/customizations/pack-manifests/{core,python,powershell,typescript,csharp}.json` listing every file under the five `.github` sub-roots (P3-T6), keeps `COPILOT_ROOT_FOLDERS` unchanged (P3-T3), edits `repo-automation-command-registration-admin.ts` (P4-T12) and adds a bullet to all six brief copies (P6-T3). If #1029 merges first, this feature must remove the `.github/skills` entries from those manifests and from any bundle-manifest completeness test, and must rebase P5-T2 and P2-T1 over child 4's edits.

### 2.6 Execution-environment brief

- Six copies exist: `.claude/skills/...`, `.agents/skills/...`, `.github/skills/...`, and the three bundle copies under `extensions/drm-copilot/resources/` (`claude-customizations/.claude/skills/`, `codex-and-agents-customizations/.agents/skills/`, `customizations/.github/skills/`). Each contains `byte-identical in six locations`.
- Copy-count wording now in the brief (all must become four after retirement):
  1. `## Purpose and Maintenance`: "The same text is byte-identical in six locations: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and their bundled copies under `extensions/drm-copilot/resources/`."
  2. `## Preflight Defect Classes the Validator Cannot See`: "... in all six byte-identical copies ...".
  3. `## Contract Tests That Pin Mirrored Files`, `documentation-workflow.CommitStage.Tests.ps1` bullet: "in the six `documentation-workflow` copies, and ... in the six copies of this brief" (new).
  4. Same section, `planning-contract-wording.Tests.ps1` bullet: "in the six `atomic-plan-contract` copies" (new).
  5. Same section, `test-cadence-wording.Tests.ps1` bullet: "in the six `atomic-plan-contract` copies" (new).
- Tests that pin the brief's `.github` copies or the count: `test_execution_environment_brief_contracts.py` (`_BRIEF_COPIES`, module docstring "six locations", `test_brief_copies_are_byte_identical` docstring "All six", `test_brief_is_referenced_by_copilot_base_agents`, `test_architecture_doc_lists_brief` row, `test_brief_preflight_classes_include_brief_maintenance` token "updates the brief in the same change, in all six byte-identical copies"); `test_discovery_documentation_contracts.py` `test_execution_environment_fact_is_unchanged_across_copies` (canonical `.github` copy, `len(copies) == 6`); `documentation-workflow.CommitStage.Tests.ps1` `$script:BriefCopyRows` (two `.github` rows); `planning-contract-wording.Tests.ps1` `$briefCopy` (`GITHUB`, `GITHUB-BUNDLE`); `test-cadence-wording.Tests.ps1` brief row `GITHUB` (and its bundle row via `Get-TcwBundlePath`); `NestingDepthContract.Tests.ps1` `$script:BriefFiles` (two `.github` rows; `brief carries nesting-depth line`). None of these tests asserts byte identity of the `.github` copy by name other than through the copy lists; `test_brief_copies_are_byte_identical` and the discovery test assert identity across the listed copies.

### 2.7 Tests that name `.github/skills`, a `.github` skill path, or `.github/agents`

Search scope: `tests/` and `extensions/drm-copilot/test/`; patterns `.github/skills`, `github.*skills`, `customizations/.github`, `'.github'`, `".github" / "skills"`, `.github/agents`. Dispositions assume `.github/skills` retirement; `.github/agents` files stay in both branches.

Python (`tests/scripts/dev_tools/`):

| Test module | Asserts | Disposition |
| --- | --- | --- |
| `test_execution_environment_brief_contracts.py` | See 2.6; `_COPILOT_AGENTS` read-first line | Update (P2-T5) |
| `test_discovery_documentation_contracts.py` | `test_execution_environment_fact_is_unchanged_across_copies` | Update (P2-T5) |
| `test_legacy_discovery_skills_contracts.py` | `.github/skills` canonical (`canonical_path`, docstring, role-link rewrite test) | Re-anchor per child 3 (P3-T8) |
| `test_discovery_workflow_contracts.py` | `skill` reads `.github/skills/<name>` | Re-anchor (P3-T8) |
| `test_discovery_publication_contracts.py` | `COPILOT_ROOTS`, `test_skill_is_represented_on_every_host`, docstring; role tests read `.github/agents` | Update skills; agents unchanged (P3-T7) |
| `test_completion_gate_documentation_contracts.py` | `github` entries, `github-ac-tracking`, `github-evidence` (index-based `[2]`), `_GITHUB_BUNDLE` | Update (P3-T1) |
| `test_evidence_timestamp_contracts.py` | `github` entries, mirror pair, `_GITHUB_BUNDLE` | Update (P3-T2) |
| `test_minor_audit_acceptance_criteria_contracts.py` | three skill pairs, `required_paths` | Retarget (P3-T3) |
| `test_csharp_orchestration_contracts.py` | two skill texts, three Copilot-bundle skill mirrors; agents | Retarget skills; agents unchanged (P3-T4) |
| `test_push_down_issue_824_follow_ups.py` | `STEP_EIGHT_COPIES`, `FEATURE_REVIEW_TEXT_COPIES` | Update (P3-T5) |
| `test_plan_gate_document_docs.py` | `_ALL_CONTRACT_COPIES`, docstring | Update (P3-T6); ledger 0008 holds hunks in this module (section 3) |
| `test_single_pass_preflight_contracts.py` | four tuples, brief token test; agent entries | Update skills (P2-T6); ledger 0001 holds a hunk in this module |
| `test_agentic_sync.py`, `test_agentic_sync_artifacts.py` | `ROOT_FOLDERS` | Update (P1-T4) |
| `test_push_down_copilot_customizations.py`, `test_push_down_copilot_customizations_rewrites.py` | synthetic `.github/skills/example` seeds | Update with `ROOT_FOLDERS` (P1-T4) |
| `test_orchestrator_direct_command_contracts.py`, `test_push_down_copilot_customizations_helpers.py`, `test_codex_full_migration_inventory.py`, `test_discovery_agent_contracts.py`, `test_quality_tiers_contract.py`, `test_agentic_sync_branches.py` | `.github/agents` paths | Unchanged (agents stay) |
| `codex_native_converter/test_*.py` | synthetic input paths | Unchanged (generic input) |

Pester (`tests/scripts/`), new since planning unless marked:

| Suite | Asserts | Disposition |
| --- | --- | --- |
| `claude-runtime/claude-architecture-doc.Tests.ps1` (existing) | migration-map heading, `.github/skills/README.md` documentation-only | Update (P2-T4) |
| `claude-runtime/documentation-workflow.CommitStage.Tests.ps1` | `$script:WorkflowCopyRows` and `$script:BriefCopyRows` include `.github` and Copilot-bundle rows; synopsis "all six copies" | Update: drop four rows, synopsis four |
| `claude-runtime/less-evidence-contract.Tests.ps1` | `CONTRACT-GITHUB`, `CONTRACT-GITHUB-BUNDLE`, `WORKFLOW-GITHUB`, `WORKFLOW-GITHUB-BUNDLE` rows | Update; the file is a create hunk of ledger 0009 (section 3) |
| `claude-runtime/light-remediation-skill-contract.Tests.ps1` | two `feature-review-workflow` Copilot rows | Update |
| `claude-runtime/owner-directives-skill-contract.Tests.ps1` | `$script:SkillCopy` two Copilot rows; description "six byte-identical copies" | Update |
| `claude-runtime/NestingDepthContract.Tests.ps1` | `$script:BriefFiles` two Copilot rows | Update |
| `claude-runtime/parallel-gate-wording.Tests.ps1` | `PLAN-GITHUB`, `PLAN-GITHUB-BUNDLE`, `REVIEW-GITHUB`, `REVIEW-GITHUB-BUNDLE`; sweep root `.github/skills`; Copilot agent bundle rows | Update skill rows and sweep root; agent rows unchanged. Create hunk of ledger 0001, modified by 0006 |
| `claude-runtime/planning-contract-wording.Tests.ps1` | `$script:ContractCopy` and `$briefCopy` `GITHUB`/`GITHUB-BUNDLE`; `HANDOFF-GITHUB`; `COPILOT-PLANNER(-BUNDLE)`, `COPILOT-ORCH` | Update skill rows; agent rows unchanged. Ledger 0008 hunk covers the `$script:PlannerAgent` block, not the skill rows |
| `claude-runtime/test-cadence-wording.Tests.ps1` | `$contractBase` `GITHUB`; brief row `GITHUB`; sweep root `.github/skills`; Copilot agent rows and `TCW-BUNDLE-*` byte identity | Update skill rows and sweep root; agent rows unchanged |
| `claude-runtime/DocsAuthoringRoles.Helpers.ps1` and consumers `docs-authoring-roles.Skills.Tests.ps1`, `docs-authoring-roles.Templates.Tests.ps1`, `docs-authoring-roles.Mirrors.Tests.ps1` | `Get-DocsAuthoringSkillRoot` `Copilot`, `CopilotBundle`; `places <Skill> at all six skill locations ...`; template identity across six skill locations | Update helper (four skill roots) and the "six" test names; `Get-DocsAuthoringAgentPath` unchanged |
| `dev-tools/ProcessReductionLedger.Tests.ps1` | `PRL-RULE-STATED-IN-EVERY-COPY` and `PRL-RULE-BUNDLE-PARITY` rows for `.github/skills/feature-review-workflow/SKILL.md` | Update: drop the Copilot rows |
| `dev-tools/ProcessReductionChain.Ledger.Tests.ps1` | reverts every ledger entry in memory over the live tree | No path literal; fails until the ledger records are updated (section 3) |
| `dev-tools/ProcessReductionChain.Tests.ps1` `GITHUB-SKILL-MIRROR` case | synthetic mapping | Unchanged |
| `claude-hooks/enforce-docs-role-write-scope.Tests.ps1`, `claude-hooks/hook-cleanup-context.Tests.ps1` | synthetic `.github` paths | Unchanged |
| `claude-runtime/legacy-discovery-agent-roles.Tests.ps1`, `dev-tools/agents-attribution.Tests.ps1`, `claude-lib/discovery-validation/DiscoveryStart.Tests.ps1`, `copilot-hooks/discovery-start.Tests.ps1`, `claude-runtime/policy-toolchain-naming.Tests.ps1` | `.github/agents` | Unchanged |
| `powershell/PoshQC/PoshQC.ShardWeights.Tests.ps1` | weights behavior over in-memory documents; no stale-key check | Unchanged; `config/poshqc-shard-weights.json` key for the retired H3 suite should be removed (stale data) |

Jest (`extensions/drm-copilot/test/`): `lib/push-down/copilot-customizations-engine.test.ts` (seeds `/src/.github/skills/s/SKILL.md` and asserts the five-root order) — update with `COPILOT_ROOT_FOLDERS` (P1-T3); `lib/codex-native-converter/*.test.ts` and `repo-automation-service.codex-native-converter.test.ts` — synthetic, unchanged; `packaging/discovery-resources.test.ts`, `packaging/mcp-server-prepack.test.ts` — `.github/agents` and hooks, unchanged.

## 3. Process-Reduction Ledger

`docs/engineering/process-reductions/` exists (entries `0001` to `0011`, `README.md`, `patches/`). `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` reverts every entry newest-first in memory through `scripts/dev-tools/ProcessReductionChain.psm1` and fails when a block or hunk does not apply; `PRC-LEDGER-NO-EXCEPTIONS` forbids skip or allowed-error lists in that test. In the module, `Invoke-ProcessReductionBlockStep` reports "the file is absent at this step" for a block whose path is absent, and `Invoke-ProcessReductionPatchStep` reports the same for a modify hunk of an absent non-derived path; `Get-ProcessReductionDerivedSource` treats a mapped path as derived only when its live text exists and equals its source.

Regions this feature would delete:

- Revert blocks naming `.github/skills/atomic-plan-contract/SKILL.md`: entries 0001, 0003, 0004, 0005, 0006, 0011.
- Revert blocks naming `.github/skills/feature-review-workflow/SKILL.md` and `.github/skills/remediation-handoff-atomic-planner/SKILL.md`: entry 0003.
- Stored-patch sections for `.github/skills/{atomic-plan-contract,feature-review-workflow,execution-environment,evidence-and-timestamp-conventions}/SKILL.md` and their `customizations/.github/skills/` bundle copies: patches 0001, 0006, 0008, 0009.

Regions this feature would edit:

- `atomic-plan-contract` Pre-Mortem token `in all six byte-identical copies`: `+` lines in patch 0001 (six copies) and context lines in patch 0008 (P2-T2).
- Brief bullet "updates the brief in the same change, in all six byte-identical copies": hunks in patches 0001 and 0006 (P2-T1; hunk boundaries U-V4).
- Brief bullet for `test-cadence-wording.Tests.ps1` ("six `atomic-plan-contract` copies"): the `Current` fence of an entry 0011 block on `.claude/skills/execution-environment/SKILL.md`.
- `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1`: created by patch 0009 (create hunk; the chain compares the file to the hunk text exactly).
- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`: created by patch 0001 and modified by patch 0006.
- Possibly `test_execution_environment_brief_contracts.py` (patches 0001, 0006) and `test_single_pass_preflight_contracts.py` (patch 0001): the edited tuples may lie outside the hunks (U-V4).
- Not in any region: the read-first lines of the four Copilot agents (zero ledger matches for "execution-environment/SKILL.md` first"), `.vscode/tasks.json` writer task, `README.md`, `.agents/README.md`, the architecture-doc sections this feature edits, `planning-contract-wording.Tests.ps1` skill rows, `test-cadence-wording.Tests.ps1`.

Ledger tests that pin text: `ProcessReductionLedger.Tests.ps1` (`PRL-RULE-*` rows above) and `ProcessReductionChain.Ledger.Tests.ps1` (whole chain).

Recommended approach: apply the README rule "An edit inside a recorded region ... must update that entry's record in the same commit" to both the deletions and the edits. In the commit that deletes `.github/skills`, remove the `### Revert Block:` subsections and the patch file sections whose path is under `.github/skills/` or `extensions/drm-copilot/resources/customizations/.github/skills/` from entries 0001, 0003, 0004, 0005, 0006, 0008, 0009, 0011 (each entry's `## Files Changed` gains a note that issue #1032 retired those copies), and regenerate the hunks and blocks that the "six to four" edits and the two created test files land in, so both images carry the edit. The commit subject carries the `reduction:` token of each touched entry as the README requires (whether one subject may carry several tokens is not stated by the README; the plan should use one commit per entry if the checker requires it). The plan's task check for this work runs `ProcessReductionChain.Ledger.Tests.ps1` and `ProcessReductionLedger.Tests.ps1`. These are Markdown and patch-data edits; no code changes.

Rejected alternative: a retired-path rule in `ProcessReductionChain.psm1` that skips absent paths. It is the skip list that `PRC-LEDGER-NO-EXCEPTIONS` exists to prevent, and it would also hide an accidental deletion.

## 4. Obsolete Gates

The parallel run `bugs-1001-1002-1003-1006` has merged and #1013 is closed (U-V1). Locations that rely on them:

- `spec.md` `## Execution Preconditions`: bullet 1 (run must merge), the blast-radius list introduced "Files in the parallel run's blast radius", the H3 bullet citing #1003 and "the only item still open at planning time (#1013)", and "Run-only files in the blast radius".
- `spec.md` `## Phase 0 Gate` check 1 ("Parallel run merged").
- `spec.md` `## Non-Goals` last bullet ("in-flight parallel run").
- `user-story.md` acceptance flow step 1.
- `issue.md` execution-start constraint.
- `research/research.2026-10-30T23-02.md` section 6 and `## Phase 0 Gate Checks` item 1.
- Main plan: `## Upstream Assumptions` UA-P1; P0-T2; `## Edit Set` preamble (#1003 rows, #1013 note) and the four rows marked (#1003); P0-T3 "for the four #1003 rows".
- Branch plans: none.

The merge-base re-read of every edited anchor (P0-T3) stays useful and is independent of the parallel run.

## 5. Deltas

### 5.1 Spec delta

1. `## Overview` and `## Scope` item 1: "the 33 skill folders and `README.md`" becomes 42 skill folders, 8 templates and `README.md` (51 files) in each of the source tree and the Copilot bundle; numeric evidence N1-R below.
2. `## Scope` item 1 unique-content list: add U4 (Copilot role links in seven docs skills; depends on child 3's per-tool rewrite) and U5 (`## Documentation Surface Check`, present elsewhere, mechanism-only).
3. `## Scope` item 1 canonical-anchor families: add the documentation family (`docs-*`, `documentation-workflow`) beside legacy discovery; OQ4 covers both. `owner-directives` needs no re-anchor (byte-identical).
4. `## Scope` item 1 repoint: the agents to repoint are the four that still carry the read-first line.
5. `## Scope` item 2 and research section 2.1: `.github/agents` has 50 files; the four docs roles join the name-collision list.
6. `## Scope` item 4, `## Inputs / Outputs` config keys, OQ1, child 1 Q5 row, R1, AC9, US-AC5, `user-story.md` constraint, `issue.md`: `.vscode/settings.json` is tracked and `settings_required.json` no longer exists; collision keys go into `.vscode/settings.json` when E4 shows workspace scope works, with no copy step; OQ1 reduces to "workspace file when E4 holds, else user-scope documentation"; child 4 destination delivery request unchanged.
7. `## Scope` item 5: still true today that no pack manifest lists `.github/`; add that child 4's plan adds `customizations/pack-manifests/*.json` listing `.github` sub-roots, whose `.github/skills` entries this child removes if #1029 merges first.
8. `## Scope` item 6 and `## Data & State`: the four-location fact also covers the three `## Contract Tests That Pin Mirrored Files` bullets that state six copies (section 2.6).
9. `## Scope` item 9: add `config/poshqc-shard-weights.json` (key for the retired Pester suite) to the surfaces the retirement edits.
10. New scope item: process-reduction ledger records (section 3) updated in the same commits as the deletions and edits.
11. `## Upstream Dependencies` child 3 row: `.claude/rules/tonality.md` already no longer names `.github/copilot-instructions.md`; `CLAUDE.md` still does (OQ5 applies to `CLAUDE.md` only). Add the docs-family role links to the child 3 assumption.
12. `## Execution Preconditions`, `## Phase 0 Gate` check 1, `## Non-Goals` last bullet: drop the parallel-run gate (section 4); keep the merge-base anchor re-check.
13. AC10: add the brief pins in `documentation-workflow.CommitStage.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `test-cadence-wording.Tests.ps1` and `NestingDepthContract.Tests.ps1`.
14. AC11: add the Pester suites of section 2.7 marked Update, `ProcessReductionLedger.Tests.ps1` and `ProcessReductionChain.Ledger.Tests.ps1`.
15. AC13: add the classes for the ledger records under `docs/engineering/process-reductions/` (historical records that the chain still reads) and the generic mapping regex in `scripts/dev-tools/ProcessReductionChain.psm1` (`Get-ProcessReductionMappedSource`).
16. AC17: replace the reversed-order, seeded shuffled and single-process runs with the parallel gates (one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, Jest through its normal workers), each re-run only after a fix (owner directive: parallel-only; shuffle runs dropped).
17. New risks: R9 ledger chain failure on deletion (mitigated by item 10); R10 child 4 overlap on registration-admin, brief and Copilot pack manifests.
18. Keep unchanged: owner decision H3 (retire, not redirect), AC16 coverage wording, R2 to R8.

### 5.2 Main plan delta (`plan.2026-10-30T18-39.md`)

Tasks that must change:

- `## Terms`: `TOUCHED-PESTER` gains the section 2.7 Pester suites marked Update, `ProcessReductionLedger.Tests.ps1` and `ProcessReductionChain.Ledger.Tests.ps1`; `RETIRED-PESTER` unchanged.
- `## Upstream Assumptions`: drop UA-P1; UA-C3b adds the docs family role links; UA-C4b records whether `customizations/pack-manifests/` exists at `MB` (child 4) and, if so, requires a removal task instead of a stop.
- `## Edit Set`: drop the #1003 and #1013 notes; replace `.vscode/settings_required.json` with `.vscode/settings.json`; add the new test files, the ledger entries and patches, and `config/poshqc-shard-weights.json`.
- P0-T3: the tree holds one `SKILL.md` per folder plus `docs-author-page/templates/` and `README.md`.
- P0-T9, P0-T10, P0-T11: each becomes the one `Phase 0 baseline` run of its gate through the test-execution launcher (one `pytest -n auto` with coverage, one Jest coverage run, one `Invoke-PoshQCParallelTest`), recording pass and fail counts, repo-wide coverage and each in-scope file's coverage; `RETIRED-PESTER` is covered by that Pester run.
- P1-T1: add U4 and U5.
- P1-T2: 51 files per tree.
- P2-T1: also change the three `## Contract Tests That Pin Mirrored Files` "six" statements, and update the ledger records the brief edits land in (0001, 0006, 0011).
- P2-T2: also regenerate the 0001 and 0008 hunks.
- P4-T4: edit tracked `.vscode/settings.json`; no copy step.
- P5-T1: remove the `config/poshqc-shard-weights.json` key; correct the "no `config/poshqc-*.json`" statement.
- P5-T2: name child 4's P4-T12 edit of the same file as a merge-order dependency.
- P6-T1 to P6-T3: one final-QC static artifact per language (Python: Black check, Ruff, Pyright in one artifact).
- P6-T8: the Pester gate is one `Invoke-PoshQCParallelTest` run through the launcher, not an `Invoke-PoshQCTest` subset.
- P6-T9: replace with a statement that isolation is proven by the parallel gates; no reversed, shuffled or single-process run.
- P6-T10: keep the wording unchanged (no regression on changed lines, at least 85% line and 75% branch per remaining changed file).
- P6-T11: add the new AC13 classes.
- Phases 1 to 5: each ends with a `[phase-gate]` task (`## Test Cadence (Mandatory)`), or phases are merged so that fewer gates are needed.
- `## Pre-Mortem`: `Test isolation` names the three parallel gates; `Mirror parity` names the brief task (P2-T1), the ledger task, and the new contract suites; `CI-only behavior` names the chain test in the PowerShell shards.
- Size: a re-stamped plan falls under the 20-task and 250-line guideline (G13). Recommended: move the H3 writer retirement (Phase 5 and its share of QA) into its own plan, executed after the main plan, and keep a `## Size Justification` in the remaining main plan.

Tasks main already delivers (candidates to drop): P0-T2 (gate satisfied; record the merged state once as a note, or drop); P0-T1 (routine policy reads are no longer required by `## Phase 0 Requirements`; optional). No implementation task is delivered by main.

New tasks required:

- N-1: ledger record updates per section 3, with the chain and ledger suites as the task check.
- N-2: update the Pester suites and helper of section 2.7 marked Update (can be grouped by file family: brief pins; atomic-plan-contract pins; feature-review-workflow pins; docs-authoring helper and test names; owner-directives; ledger rule rows).
- N-3: if `customizations/pack-manifests/*.json` exists at `MB`, remove every `.github/skills` entry and update the completeness test child 4 adds.
- N-4: record U4 against child 3's per-tool role-link output for the docs family; a missing rewrite is an OQ4 stop.

### 5.3 Branch A delta (`plan-agents-branch-a.md`)

- Must change: UA-A3 and P0-T3 expect 50 agent files (including the four docs roles) and the matching `copilot:agent:*` ids; P1-T4 collision list adds `docs-architect`, `docs-author`, `docs-coverage-reviewer`, `docs-reconciler`; `AGENT-PESTER` adds `docs-authoring-roles.Mirrors.Tests.ps1` (agent rows) and `DocsAuthoringRoles.Helpers.ps1` consumers; P0-T4 and P2-T2 run the Pester gate through the launcher; P2-T1 and P2-T2 drop the reversed and shuffled runs; Phase 1 ends with a `[phase-gate]` task; Pre-Mortem `Test isolation` names the parallel gates.
- Candidates to drop: P0-T1 (optional policy read).
- New: none beyond the above.

### 5.4 Branch B delta (`plan-agents-branch-b.md`)

- Same changes as Branch A for the agent count, `AGENT-PESTER`, launcher, isolation runs, `[phase-gate]` and Pre-Mortem.
- UB-2 stays (child 3's plan still lists no `.github/agents` target).
- Candidates to drop: P0-T1.

## Numeric Derivation Evidence

### N1-R: `.github/skills` skill folders retired

- Complete Family: skill folders directly under `.github/skills`.
- Exhaustive Search Scope: every file under `.github/skills/`.
- Inclusion Rules: a direct child folder holding `SKILL.md`.
- Exclusion Rules: `README.md`; files under a skill's `templates/` folder do not create a folder.
- Primary Search Strategy or Query Expression: Glob `**/SKILL.md` rooted at `.github/skills`.
- Primary Member Set: the 33 folders of prior research N1 plus `docs-author-page`, `docs-init`, `docs-inventory-surface`, `docs-plan-ia`, `docs-reconcile-behavior`, `docs-review-coverage`, `docs-validate`, `documentation-workflow`, `owner-directives`.
- Primary Count: 42.
- Cross-check Search Strategy or Query Expression: Glob `*` (all files, recursive listing) rooted at `.github/skills` (51 files), remove `README.md` and the 8 `docs-author-page/templates/*.md` files, take the top-level folder of each remaining file.
- Cross-check Member Set: the same 42 names.
- Cross-check Count: 42.
- Member-set Comparison: identical sets, no duplicates. The Copilot bundle tree lists the same 51 relative paths.

### N2-R: `.github/agents` files

- Complete Family: files under `.github/agents`.
- Exhaustive Search Scope: `.github/agents/`.
- Inclusion Rules: any file. Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `*` rooted at `.github/agents`.
- Primary Member Set: the 46 files of prior research N2 plus the four `docs-*.agent.md` files.
- Primary Count: 50.
- Cross-check Search Strategy or Query Expression: the changed-file list (`SCRATCH/issue-1032-changed-since-plan.txt`) rows for `.github/agents/` with status `A` (four docs roles) added to the 46-member set of prior research N2, with no `D` row under `.github/agents/`.
- Cross-check Member Set: the same 50 names.
- Cross-check Count: 50.
- Member-set Comparison: identical.

### N3-R: handoff-bearing agents

- Complete Family: `.github/agents` files whose frontmatter declares `handoffs:`.
- Exhaustive Search Scope: `.github/agents/`.
- Inclusion Rules: a `^handoffs:` line. Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Grep `^handoffs:` (count mode).
- Primary Member Set: `atomic_planning`, `csharp-atomic-planning`, `csharp-orchestrator`, `csharp-typed-engineer`, `epic-review`, `feature-review`, `orchestrator`, `Powershell DI Unit Test Engineer`, `powershell-atomic-planning`, `powershell-orchestrator`, `powershell-typed-engineer`, `prd-feature`, `pytest-unit-test-coding`, `python-atomic-planning`, `python-execution-only-typed`, `python-orchestrator`, `python-typed-engineer`, `staged-review`, `status_updater`, `typescript-engineer`.
- Primary Count: 20.
- Cross-check Search Strategy or Query Expression: the 20-member list of prior research N3.
- Cross-check Member Set: the same 20 names.
- Cross-check Count: 20.
- Member-set Comparison: identical; the four docs roles declare no `handoffs:`.

### N4-R: execution-environment brief copies after retirement

- Complete Family: committed copies of `execution-environment/SKILL.md`.
- Exhaustive Search Scope: `.claude/skills`, `.agents/skills`, `.github/skills` and the three bundle roots under `extensions/drm-copilot/resources/` (`packages/` holds none: Glob returned no file).
- Inclusion Rules: the file contains `byte-identical in six locations`.
- Exclusion Rules: the two `.github` copies (retired).
- Primary Search Strategy or Query Expression: Grep `byte-identical in six locations` on each of the six paths (six hits) minus the two `.github` paths.
- Primary Member Set: `.claude/skills/...`, `.agents/skills/...`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/...`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/...`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: the location list in the brief's `## Purpose and Maintenance` sentence minus `.github/skills/...` and its bundled copy.
- Cross-check Member Set: the same four paths.
- Cross-check Count: 4.
- Member-set Comparison: identical.

## Pre-Mortem

- Review checklists: a reviewer may flag removed unique content (U4 docs role links, U5 surface check), unclassified stale references (ledger records, the mapping regex), or ledger records edited without the README's commit-subject token. Mitigation: the plan records U1 to U5 with dispositions, adds the AC13 classes of section 5.1, and carries each touched entry's `reduction:` token in the ledger commits.
- Coverage: the production edits stay `agentic_sync.py`, `push_down_copilot_customizations_rewrites.py`, `copilot-customizations-engine.ts`, `repo-automation-command-registration-admin.ts` and `reference-rewrites.ts`. Mitigation: `Phase 0 baseline` and final runs of the parallel gates with per-file figures, and P6-T10 unchanged (no regression on changed lines, at least 85% line and 75% branch per remaining changed file); the ledger and config edits are data.
- Mirror parity: the brief has five copy-count statements, not two, and the four remaining copies must stay byte-identical. Mitigation: P2-T1 names all five statements in all four copies, the brief contract suites in section 2.6 run as task checks, and the Pre-Mortem `Mirror parity` bullet names P2-T1 and the ledger task.
- File size: Markdown, JSON, patch data and existing tests only; ledger entries and patches are documentation and exempt. Mitigation: the existing file-size gate (`FileSizePolicy.RepoGate.Tests.ps1`) in the Pester gate; no edited test grows.
- Test isolation: edited tests read committed files and in-memory data only. Mitigation: the three parallel gates (one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, Jest through its normal workers), each re-run only after a fix; no reversed, shuffled, serial or single-process run.
- CI-only behavior: `ProcessReductionChain.Ledger.Tests.ps1` runs in the PowerShell shards, and the Linux hook-suite job is case-sensitive. Mitigation: run the chain and ledger suites in the task check of the ledger task; exact-case paths; remove `.github/skills` from both sweep roots so no `Get-ChildItem` reads a missing root (U-V3).
- Evidence: Phase 0 records, the U1 to U5 record, the branch selection and the stale-reference classification each need an artifact under `<FEATURE>/evidence/<kind>/` with write-time stamps; evidence is append-only. Mitigation: the plan names each artifact; scratch locations are recorded as `SCRATCH`; no absolute path is written.

## Rejected Alternatives

- Treating the `.vscode` rename as delivering the collision controls: rejected; no `chat.*` key exists.
- Skipping retired paths in `ProcessReductionChain.psm1`: rejected (section 3).
- Keeping the retirement and H3 in one re-stamped plan without justification: rejected by G13; a split or a `## Size Justification` is required.

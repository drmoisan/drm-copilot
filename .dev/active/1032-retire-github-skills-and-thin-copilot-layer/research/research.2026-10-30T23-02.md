# Research: Retire `.github/skills`, Settle `.github/agents`, Thin Copilot Layer (Issue #1032)

- Issue: #1032 (child 6 of epic #1018)
- Feature folder: `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032`
- Mode: preparation (research only)
- Inputs read: `docs/features/epics/shared-agent-harness-layer/epic.md`; `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md` (settled design, not re-opened); this feature's `issue.md` and `spec.md`; child 1 outputs cited as `origin/feature/harness-survey-gold-standard-contracts-parity-matrix-1025:docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/<file>` (`spec.md`, `research/research.2026-10-30T21-08.md`, `plan.2026-10-30T17-06.md`), read from scratch copies under `SCRATCH`; the parallel-run blast-radius list and the `.github/skills`/`.github/agents` referrer list under `SCRATCH`.
- Tree read: identical to `origin/main` outside `docs/features` plus the epic documents (per the orchestrator).
- Filename stamp note: the task-researcher route has no clock-reading tool; the stamp in this file name was not read from a host clock. The orchestrator may rename the file to a clock-read stamp.

## 1. `.github/skills` Inventory and Unique Content

### 1.1 Inventory

`.github/skills` holds 33 skill folders, each containing only `SKILL.md`, plus `README.md` (34 files). Every folder name also exists in `.claude/skills` and in `.agents/skills` (each checked by name against a Glob of `.claude/skills/*/SKILL.md` and `.agents/skills/*/SKILL.md`). `.github/skills` is therefore a strict subset of both trees by name.

Folders (all present in `.claude/skills` and `.agents/skills`): `acceptance-criteria-tracking`, `adjudicate-unspecified-behavior`, `atomic-plan-contract`, `characterize-runtime-behavior`, `csharp-change-budget-router`, `csharp-orchestration-state-machine`, `discovery-behavior-reconciliation`, `discovery-coverage-ledger`, `discovery-parity-matrix`, `discovery-repo-inventory`, `discovery-runtime-characterization`, `discovery-validate-artifacts`, `discovery-workflow`, `evidence-and-timestamp-conventions`, `execution-environment`, `extract-feature-contract`, `feature-promotion-lifecycle`, `feature-review-workflow`, `generate-acceptance-scenarios`, `initialize-discovery-workspace`, `inventory-legacy-system`, `make-skill-template`, `policy-audit-template-usage`, `policy-compliance-order`, `powershell-change-budget-router`, `powershell-orchestration-state-machine`, `pr-base-branch-merge-base`, `pr-context-artifacts`, `reconcile-parity-matrix`, `remediation-handoff-atomic-planner`, `review-discovery-coverage`, `skill-canonical-location-audit`, `validate-discovery-artifacts`.

The Copilot bundle `extensions/drm-copilot/resources/customizations/.github/skills/` mirrors the same 34 files.

Subset by name is not subset by authority. Two families treat the `.github` copy as the canonical source today:

- Legacy discovery (issue #980): the nine workflows and seven aliases under `.github/skills` are canonical; the `.claude/skills` and `.agents/skills` copies are a deterministic role-link rewrite of them (`tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`, module docstring and `test_generated_copies_are_the_deterministic_role_link_rewrite`; `docs/engineering/legacy-discovery-and-parity/maintainer-guide.md`). The rewrite maps `../../agents/<role>.agent.md` to `../../../.claude/agents/<role>.md` (Claude) or `../../../.codex/agents/<role>.toml` (Codex), so the Claude and Codex copies are not byte-identical to each other.
- Execution-environment brief: `test_execution_environment_fact_is_unchanged_across_copies` in `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` reads `.github/skills/execution-environment/SKILL.md` as the canonical byte source.

Retirement must move the canonical anchor for both families. For discovery, a single `.agents/skills` source mirrored byte-identically into `.claude/skills` (child 3's generator) cannot reproduce the per-tool role links; child 3's skill generator must carry a per-tool rewrite, or the links must become tool-neutral. This is a child 3 deliverable checked in the Phase 0 gate.

### 1.2 Unique Sections (content comparison)

Compared by content, not headings, against `.claude/skills/<name>/SKILL.md`, `.agents/skills/<name>/SKILL.md`, and other artifacts of each ecosystem (agent bodies, sibling skills).

| ID | Location | Content unique to the Copilot copy | Present elsewhere? | Recommendation |
| --- | --- | --- | --- | --- |
| U1 | `.github/skills/feature-promotion-lifecycle/SKILL.md`, `## MCP-First Execution Rule` (the "Documented alternatives" list) | Permits VS Code extension commands when MCP is unreachable and direct script/CLI commands when neither is available. | No. Claude and Codex copies state the opposite in `## MCP Tool Availability Preflight` ("Agent sessions do not have an approved non-MCP execution branch") and keep only a non-authoritative note on VS Code commands. | Stale. Issue #168 (`docs/features/completed/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`) removed fallback guidance and replaced it with a single non-authoritative note; the Copilot copy was not updated. Porting would re-introduce a removed policy. |
| U2 | Same file, `## Canonical Fallback Command Sequence` and the VS Code command forms in `## Canonical Fallback Short-Path Sequence (Minor Audit Mode)` | VS Code command-palette invocations with command IDs `drmCopilotExtension.newPotentialEntry`, `drmCopilotExtension.newPotentialBugEntry`, `drmCopilotExtension.potentialToIssue`, `drmCopilotExtension.newActiveFeatureFolder`. | The command IDs still exist in `extensions/drm-copilot/package.json` (`contributes` commands); no skill references them. The short-path steps 3a to 8 and the "Automation rule" are present in the Codex copy (steps 7a to 12). | Stale for agent sessions (same reason as U1). The command IDs are an interactive extension surface documented by the extension itself, not skill content. |
| U3 | `.github/skills/feature-review-workflow/SKILL.md`, `## File Size Advisory` | Tiered file-size reporting rules for reviews. | Yes, by content: `.claude/agents/feature-review.md` (`## File Size Advisory`), `.agents/skills/feature-review/SKILL.md` (`## File Size Advisory`), `.codex/agents/feature-review.toml` (`## File Size Advisory`). Not in the Claude or Codex `feature-review-workflow` skill. | Mechanism-only (placement difference); no port required. Child 1's survey classifies the corresponding `D-feature-review-workflow-<nn>` difference; if the owner approves it as `positive`, child 3 ports it into the shared `.agents/skills/feature-review-workflow/SKILL.md` when it authors the neutral body (child 1 Q4 assigns porting to child 3). |

Other `feature-review-workflow` differences are not unique to the Copilot copy: the final report fields in step 9 (`REVIEW_STATUS`, `FEATURE_FOLDER`, and the rest) and the constraint "Do not omit any required final result field" appear in a superset form in `.agents/skills/feature-review-workflow/SKILL.md`. The Copilot copy lacks `## Policy Rules` and the coverage step that the Claude and Codex copies carry, so it is a stale subset.

Result: no section requires a port by child 6. Child 6 records U1 and U2 as stale and U3 as present elsewhere, each with its reason, in an evidence artifact, and cross-references child 1's approved classifications (`#1025:survey/difference-approval.md`). If the owner overrode any of these in child 1, the override governs and the port lands in `.agents/skills/<name>/SKILL.md` (child 3 mirrors it).

## 2. `.github/agents` Inventory and the E3 Branches

### 2.1 Inventory

- 46 tracked files, all `*.agent.md`. 42 declare `name:`; `api-architect`, `hlbpa`, `mentor`, `voidbeast-gpt41enhanced` declare only `description:` and take their name from the file stem.
- 20 files declare `handoffs:` in frontmatter: `atomic_planning`, `csharp-atomic-planning`, `csharp-orchestrator`, `csharp-typed-engineer`, `epic-review`, `feature-review`, `orchestrator`, `Powershell DI Unit Test Engineer`, `powershell-atomic-planning`, `powershell-orchestrator`, `powershell-typed-engineer`, `prd-feature`, `pytest-unit-test-coding`, `python-atomic-planning`, `python-execution-only-typed`, `python-orchestrator`, `python-typed-engineer`, `staged-review`, `status_updater`, `typescript-engineer`.
- Handoff targets resolve by Copilot agent `name`. Targets outside the 20: `atomic_executor`, `csharp-atomic-executor`, `Task Researcher Instructions` (`task-researcher.agent.md`), `commit_steward`, `powershell_atomic_executor`, `python-atomic-executor`, `TDD Red Phase - Write Failing Tests First` (`tdd-red.agent.md`); `agent` is the built-in agent. Handoff closure: 27 files.
- Native prompts bind agents by name through `agent:` frontmatter. Bound agents outside the handoff closure: `prd_creator` (`prd.agent.md`), `pr-author`, `comment_remediator` (`commentary-remediation.agent.md`). Closure with prompts: 30 files.
- Copilot hook dependency: `.github/hooks/discovery.json` registers `discovery-agent-start.ps1`; `Get-DiscoveryAgentProfilePath` in `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1` (`$script:AgentProfileLayout`, key `github-copilot`) resolves `.github/agents/<role>.agent.md` and `Read-DiscoveryAgentProfile` throws `AGENT_PROFILE_INVALID` when the file is absent. This binds `legacy-parity-analyst`, `runtime-characterization-analyst`, `requirements-reconciler`, `migration-coverage-reviewer`; `discovery-capability-sentinel` is the agent the Copilot capability probe (`.github/hooks/discovery-capability-probe.ps1`) observes. 5 files.
- Remaining 11 personas with no project routing and no `.claude/agents` equivalent (per `docs/engineering/claude-code-architecture.md`, `### Canonical .github/agents migration map`): `5.1-Beast-adjusted`, `5.1-Thinking-Beast-Mode-adjusted`, `api-architect`, `expert-nextjs-developer`, `expert-react-frontend-engineer`, `gpt-5-beast-mode`, `hlbpa`, `mentor`, `tdd-green`, `tdd-refactor`, `voidbeast-gpt41enhanced`.
- Name collisions with `.claude/agents` (both read by Copilot in VS Code by default): `orchestrator`, `pr-author`, `csharp-typed-engineer`, `powershell-typed-engineer`, `python-typed-engineer`, `typescript-engineer`, `discovery-capability-sentinel`, `legacy-parity-analyst`, `runtime-characterization-analyst`, `requirements-reconciler`, `migration-coverage-reviewer`.
- Seven Copilot agents reference `.github/skills` (`atomic_executor`, `atomic_planning`, `csharp-orchestrator`, `orchestrator`, `powershell-orchestrator`, `python-orchestrator`, `task-researcher`); four of them (`atomic_executor`, `atomic_planning`, `task-researcher`, `orchestrator`) carry the line "Read `.github/skills/execution-environment/SKILL.md` first" pinned by `test_brief_is_referenced_by_copilot_base_agents`. All seven survive in both branches, so retiring `.github/skills` requires editing each reference and the bundle copies; the plan enumerates the exact lines with a Grep at execution.
- 82 files under `.codex/agents/*.toml` (base agents and generated variants) name their source as `.github/agents/<name>.agent.md` ("Canonical migration source" and a source list). Base agents are hand-edited; variants are generated by `scripts/dev_tools/generate_codex_agent_variants.py`.

What Copilot reads today: VS Code reads `.github/agents` and `.claude/agents` (default of `chat.agentFilesLocations`); the Copilot CLI reads `~/.copilot/agents`, `.github/agents`, and the organization `.github-private` `agents` folder; the cloud agent reads `.github/agents` (sources in 2.2).

### 2.2 Documentation Evidence on E3 (fetched 2026-10-30)

| Source | Finding |
| --- | --- |
| https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview | Custom agents load from `~/.copilot/agents`, "the `.github/agents` directory in your local and remote repositories", and "the `/agents` directory in the `.github-private` repository". No mention of `.claude/agents`. |
| https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents | Repository profiles are created in `.github/agents` with an `.agent.md` suffix; no mention of `.claude/agents` or a Claude format. |
| https://docs.github.com/en/copilot/reference/custom-agents-configuration | No Claude-format support described. "`argument-hint` and `handoffs` properties from VS Code and other IDE custom agents are currently not supported for Copilot in the cloud on GitHub.com" and are ignored. File name minus `.md`/`.agent.md` is used for deduplication between levels. |
| https://code.visualstudio.com/docs/copilot/customization/custom-agents | VS Code lists `.claude/agents` as a workspace location (Claude format). "GitHub Copilot CLI and the GitHub Copilot app do not inherit editor location settings." Handoff support for Claude-format agents is not stated. |

Consistent with child 1's E3 status ("partly resolved, documentation indicates no"). Absence in documentation is not proof; the E3 runbook result governs.

### 2.3 Execution Branches

Constraint common to both branches: handoffs stay native (settled design). Handoffs are a VS Code feature (ignored by the cloud agent), resolve targets by Copilot `name`, and the `.claude/agents` names differ (`atomic-executor` versus `atomic_executor`), so the handoff closure cannot be satisfied by `.claude/agents`.

- **Branch A (E3 result: both CLI and cloud agent read `.claude/agents`).** Retire `.github/agents` files that are outside every native binding. Edits: delete eligible `.github/agents/*.agent.md` and their bundle copies under `extensions/drm-copilot/resources/customizations/.github/agents/`; set their parity-matrix `copilot:agent:<name>` entries (and orphaned `copilot:subagent-frontmatter-field` entries) to `dropped` with `reason` and `decision_ref`; update tests that pin removed files (`tests/scripts/dev-tools/agents-attribution.Tests.ps1` if the two `-adjusted` personas go; `test_thinking_beast_mode_bundle_mirror_matches_root_agent` in `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`); remove or annotate `.codex/agents` provenance lines for removed sources (coordinate with child 3). Finding: by the bindings in 2.1, only the 11 personas are eligible, and none has a Claude-format equivalent, so their retirement is a capability drop that needs an owner-approved `dropped` reason (epic acceptance criterion). Without that approval, Branch A removes nothing and reduces to adding the collision control in section 5.
- **Branch B (E3 result: no, or deferred).** `.github/agents` remains the only repository agent source for the Copilot CLI and cloud agent. Reduce it to files generated by child 3's agent generator from the one logical definition if child 3 delivers a `.github/agents` target that can emit `handoffs:` and Copilot tool identifiers; otherwise keep the files native and record the matrix disposition `native` with the reason. Edits (generated case): replace hand-written `.github/agents/*.agent.md` with generator output and bundle copies, register the files in the generator's `--check`, set matrix entries to `generated` with `generated_from`, re-pin text-content tests whose strings change (`test_orchestrator_direct_command_contracts.py`, `test_single_pass_preflight_contracts.py`, `test_csharp_orchestration_contracts.py`, `test_discovery_publication_contracts.py` role tests, `legacy-discovery-agent-roles.Tests.ps1`). Edits (native case): matrix disposition and `decision_status: approved` only. Note: the epic scope for child 3 lists `.claude/agents/*.md` and `.codex/agents/*.toml` as agent targets and does not list `.github/agents`; the generated case therefore depends on a child 3 extension that Phase 0 must confirm.

## 3. Consumers of the Retired Paths

Classification: **Must change** (runtime code, tests, manifests, bundle mirrors, generator inputs, documents that state current facts); **May stay** (historical records, generic input-format handling, fixtures); **Other child** (owned by children 3, 4 or 5; checked in Phase 0).

| Referrer | Class | Reason / action |
| --- | --- | --- |
| `extensions/drm-copilot/resources/customizations/.github/skills/**` (34 files) | Must change | Delete with the source tree. |
| `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` (`COPILOT_ROOT_FOLDERS` includes `.github/skills`) | Other child (4) / must change if child 4 kept it | Removing the root stops shipping the folder. Whether `fs.listFiles` tolerates a missing root was not verified; plan must confirm or remove the root. Consumer: `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts` (`resources/customizations`). |
| `scripts/dev_tools/agentic_sync.py` (`ROOT_FOLDERS`) and `scripts/dev_tools/push_down_copilot_customizations.py` | Other child (4) / must change if retained | Existing Python; edit in place only. `test_root_folders_include_published_github_hooks_in_scoped_order` in `tests/scripts/dev_tools/test_agentic_sync_artifacts.py` pins the tuple. |
| Pack manifests `extensions/drm-copilot/resources/{claude-customizations,codex-and-agents-customizations}/pack-manifests/*.json` | No change today | They list no `.github/` path (Grep, zero matches). The Copilot bundle has no `pack-manifests` folder; if child 4 adds one, child 6 removes the retired entries. |
| `.github/skills/README.md` and bundle copy | Must change | Deleted with the tree; its facts move to `.agents/README.md`. |
| Execution-environment brief, six copies (`## Purpose and Maintenance`) | Must change | Two `.github` copies deleted; the remaining four (`.claude/skills/...`, `.agents/skills/...`, and their bundle copies) update the six-location sentence in the same change (brief maintenance rule). All six are in the parallel-run blast radius. |
| `.github/skills` references in seven `.github/agents` files and bundle copies | Must change | Repoint to `.agents/skills/execution-environment/SKILL.md` (the file Copilot reads after retirement). |
| `docs/engineering/claude-code-architecture.md` (`### Canonical .github/skills migration map`, statement that `.github/` is authoritative) | Must change | States current facts that become false. Pinned by `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` and by a row assertion in `test_execution_environment_brief_contracts.py`. |
| `.agents/README.md` (".github/skills and .github/agents remain as historical source material") and bundle copy | Must change | Current-fact statement. |
| `README.md` (link to `.github/skills/README.md`) | Must change | Broken link after retirement. |
| `docs/engineering/legacy-discovery-and-parity/maintainer-guide.md`, `workflow.md` | Must change | State `.github/skills` as canonical for discovery. `consumer-onboarding.md` lists push-down output roots (change if the Copilot root list changes). |
| `.github/skills/skill-canonical-location-audit/SKILL.md` | Must change (deleted) | Claude and Codex copies already scope to their own trees. |
| `.claude/skills/translate-copilot-to-claude/SKILL.md` and bundle copy | May stay | Describes the Copilot input format for any repository; only its two examples naming this repository's `.github/agents` files may need updating if Branch A removes them. |
| `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1` and its two bundle copies | May stay (both branches keep the four roles) / Other child (5) | Changes only if child 5 reworks the Copilot discovery hooks. |
| `.codex/agents/*.toml` provenance lines | Other child (3) | Generated by child 3's agent generator or `generate_codex_agent_variants.py`; `test_codex_full_migration_inventory.py` asserts `.github/agents/` in wrappers; `test_discovery_publication_contracts.py` asserts the Codex base names `.github/agents/<role>.agent.md`. Unchanged while `.github/agents` remains. |
| `extensions/drm-copilot/src/lib/codex-native-converter/*`, `scripts/dev_tools/codex_native_converter/*`, `tests/fixtures/codex_native_converter/**` | May stay | Generic Copilot-to-Codex conversion of any input repository. |
| `tests/fixtures/blast_radius/historical-runs/*`, `verification-integrity/*`, `virtual/**`, `testResults.xml` | May stay | Historical fixtures and recorded outputs. |
| `scripts/dev-tools/sync-agents-from-instructions.ps1` (builds `AGENTS.md` from `.github/copilot-instructions.md` and `.github/instructions`) and its template copy | Other child (3) | Conflicts with `AGENTS.md` as source; if left in place, running it after section 4's reduction would drop the tone text from `AGENTS.md`. |

## 4. Thin Copilot Layer

- `.github/prompts`: 30 files (24 top-level `*.prompt.md`, `execute-plan-template.md`, 5 under `drafts/`). None references `.github/skills`. Prompts bind agents by `agent:` name (section 2.1). Native; unchanged.
- `.github/hooks`: 6 files (`discovery.json` and five `discovery-*.ps1`). Native; dispositions settled by child 5. `quality-tiers.yml` entry `.github/hooks` stays valid.
- `.github/instructions`: 17 files. Generated by child 3 from one rule source. Child 6 does not edit them.
- `.github/copilot-instructions.md`: one `# Tone policy` section of five bullets. All of it duplicates the tone policy in `AGENTS.md` (`## Source: tonality.md` and `## Tone Policy`) and `CLAUDE.md` (`## Tone Policy`). It holds no Copilot-only text. Per the settled design it is reduced to Copilot-only text. Keep the file (the `docs-validation` job in `.github/workflows/_docs-validation.yml` warns when it is missing) with a short Copilot-only body, for example that prompts and handoff-bearing agents live natively in `.github/prompts` and `.github/agents` and that shared instructions come from `AGENTS.md`.
- AGENTS.md coverage per Copilot surface (fetched 2026-10-30): VS Code reads workspace-root `AGENTS.md` (`chat.useAgentsMdFile`, default `true`); the CLI overview lists "Agent files such as `AGENTS.md`"; https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions describes `AGENTS.md` but does not state per surface whether the cloud agent reads it. Risk recorded in section 11.
- Interaction with `CLAUDE.md`: `CLAUDE.md` (`## Tone Policy`, `## Policy Compliance Reading Order` item 1) and `.claude/rules/tonality.md` name `.github/copilot-instructions.md` as the authoritative tone source, and `CLAUDE.md` states the `.github/instructions` files are canonical and must not be modified. Child 6 does not modify `.github/instructions` (child 3 generates them), so the second statement does not block it. The first statement becomes false once the tone text leaves `.github/copilot-instructions.md`. Child 3 owns `CLAUDE.md` (`@AGENTS.md` plus Claude-only text); the Phase 0 gate confirms child 3 has repointed these lines; if not, owner question OQ5 applies.

## 5. Copilot Collision Controls

### 5.1 Settings (https://code.visualstudio.com/docs/copilot/reference/copilot-settings, fetched 2026-10-30)

| Setting | Default | Collision role after retirement |
| --- | --- | --- |
| `chat.agentSkillsLocations` | `.agents/skills`, `.github/skills`, `.claude/skills`, `~/.agents/skills`, `~/.copilot/skills`, `~/.claude/skills` all `true` | Shared skills exist in `.agents/skills` and the generated `.claude/skills` mirror; set `".claude/skills": false`. |
| `chat.instructionsFilesLocations` | `.github/instructions`, `.claude/rules`, `~/.copilot/instructions`, `~/.claude/rules` all `true` | Rules are generated into both; set `".claude/rules": false`. |
| `chat.agentFilesLocations` | `.github/agents`, `.claude/agents`, `~/.copilot/agents` all `true` | Eleven name collisions (2.1); set `".claude/agents": false` while `.github/agents` remains. |
| `chat.promptFilesLocations` | `.github/prompts: true` (marked deprecated) | No collision. |
| `chat.hookFilesLocations` | `{}` (preview) | Not a collision source. |
| `chat.useAgentsMdFile` | `true` | Keep. |
| `chat.useClaudeMdFile` | `true` | `CLAUDE.md` carries `@AGENTS.md` plus Claude-only text; set `false`. |
| `chat.useClaudeHooks` | `false` (preview) | Keep. |
| `github.copilot.chat.codeGeneration.useInstructionFiles` | `true` | Keep. |

The reference does not label these settings user-scope or workspace-scope, and states that the location settings are "not recommended for Copilot workflows because other clients do not inherit this setting". The CLI and the Copilot app do not inherit editor location settings. Workspace effectiveness is child 1's E4.

### 5.2 Repository State

- `.gitignore` (`# VS Code` block) ignores `.vscode/settings.json` and `.vscode/settings.json.bak`.
- Tracked: `.vscode/extensions.json`, `.vscode/launch.json`, `.vscode/settings_required.json`, `.vscode/tasks.json`.
- `.vscode/settings_required.json` holds coverage, Jest, PowerShell 7, pytest and terminal settings. Its only reader is `tests/scripts/dev_tools/test_vscode_workspace_settings.py` (asserts the PowerShell 7 pin in `settings_required.json`, and in `settings.json` when that file exists). No push-down ships it (no `.vscode` path under `extensions/drm-copilot/resources/**`; no pack-manifest entry). No tool merges it into `settings.json`.
- No repository file contains any of the `chat.*` collision settings (Grep, zero matches outside `docs/`).

### 5.3 Q5 Delivery Options and Recommended Default

| Option | Effect | Trade-offs |
| --- | --- | --- |
| 1. Add the collision keys to `.vscode/settings_required.json` and document the copy step (in the thin `.github/copilot-instructions.md`-adjacent documentation or `README.md`) | Follows the existing tracked pattern; no `.gitignore` change. | Not automatic: other users load duplicates until they copy the keys, so the epic's "default settings" goal is not met for them in this repository. |
| 2. Commit `.vscode/settings.json` (remove it from `.gitignore`) | Automatic for every clone when E4 shows workspace scope works. | Collides with existing personal workspace files (untracked-to-tracked conflict on pull); personal edits become tracked changes; the file must carry the PowerShell 7 pin that `test_vscode_workspace_settings.py` asserts. |
| 3. Deliver to destinations through the push-down (child 4) as a merge into the destination's `.vscode/settings.json` | Reaches destination repositories. | Needs TypeScript in the push-down (permitted: MCP tool code) and the no-overwrite rule; does not address this repository. |

Recommended default: Option 1 for this repository, applied only when E4 shows workspace scope works (otherwise document the keys as user-scope settings), plus a recorded request that child 4 carry Option 3 for destinations. Escalate to Option 2 only on owner instruction.

## 6. Overlap with the Parallel Run `bugs-1001-1002-1003-1006`

Files child 6 edits or deletes that are in the run's blast radius (`SCRATCH` list):

- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md` (deleted)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` (deleted)
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`
- `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`
- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`

Run-only in the blast radius (re-checked, not edited): `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, both `pack-manifests/core.json` files, `scripts/dev_tools/generate_codex_agent_variants.py`.

The Phase 0 gate re-reads each listed file at the merge base of `origin/main` and `HEAD` and stops for re-planning when a named file, symbol, heading or asserted string has moved.

## 7. Language Classification

| Artifact | Change | Classification |
| --- | --- | --- |
| `.github/skills/**` and bundle copies | Delete | Markdown; no code. |
| `.github/agents/*.agent.md` read-first lines and bundle copies; Branch A/B edits | Edit or delete | Markdown; no code. |
| Execution-environment brief, four copies | Edit | Markdown. |
| `.github/copilot-instructions.md` and bundle copy | Edit | Markdown. |
| `docs/engineering/claude-code-architecture.md`, `.agents/README.md` (+ bundle), `README.md`, legacy-discovery documents | Edit | Markdown. |
| `.vscode/settings_required.json` | Edit | JSON configuration. |
| `config/harness-parity-matrix.json` | Edit | JSON data (child 1 schema). |
| Existing Python contract tests (section 8) | Edit in place | Existing Python, tolerated. |
| Existing Pester suites (section 8) | Edit in place | PowerShell. |
| `copilot-customizations-engine.ts` and Jest test, if child 4 left the root list | Edit | TypeScript in MCP-tool code; permitted. |
| `scripts/dev_tools/agentic_sync.py`, if child 4 left it | Edit in place | Existing Python, tolerated. |
| Any new verification helper | None planned | If one is needed it is PowerShell under `SCRATCH`, not committed. |

No artifact requires new Python or pushed-down TypeScript. No case needs an owner language decision.

## 8. Test Impact

Pytest (`tests/scripts/dev_tools/`):

| Test | Assertion touching retired paths | Disposition |
| --- | --- | --- |
| `test_execution_environment_brief_contracts.py` | `_COPIES` lists six copies including the two `.github` copies; `test_brief_is_referenced_by_copilot_base_agents` requires "Read `.github/skills/execution-environment/SKILL.md` first" in four Copilot agents; a row pin on `docs/engineering/claude-code-architecture.md`. | Drop the two copies; change the required string to the new path; update the row pin. |
| `test_discovery_documentation_contracts.py` | `test_execution_environment_fact_is_unchanged_across_copies`: canonical `.github` copy and `len(copies) == 6`. | Canonical `.agents/skills/execution-environment/SKILL.md`; count 4. |
| `test_legacy_discovery_skills_contracts.py` | `.github/skills` canonical; existence and role-link-rewrite equality against it. | Re-anchor on the new source per child 3's design (Phase 0 dependency). |
| `test_discovery_publication_contracts.py` | `test_copilot_bundle_mirrors_every_scoped_github_file` over `COPILOT_ROOTS` including `.github/skills` (fails on an empty root); `test_skill_is_represented_on_every_host` mirrors `.github/skills/<skill>`; role tests read `.github/agents/<role>.agent.md`. | Remove `.github/skills` from `COPILOT_ROOTS` and the Copilot skill mirror assertion; role tests unchanged in both branches. |
| `test_completion_gate_documentation_contracts.py` | `github` entries in `AC_TRACKING_SKILLS`, `EVIDENCE_SKILLS`; `github-ac-tracking`, `github-evidence` mirror pairs. | Remove the `github` entries and pairs. |
| `test_evidence_timestamp_contracts.py` | `github` entries in `EVIDENCE_SKILLS`, `PLAN_CONTRACT_SKILLS`; `github` mirror pair. | Remove. |
| `test_minor_audit_acceptance_criteria_contracts.py` | Three `.github/skills` paths in `ROOT_MIRROR_PAIRS` and `required_paths`. | Remove skill entries; keep prompt entries. |
| `test_single_pass_preflight_contracts.py` | `.github/skills` paths in `_CONTRACTS`, `_REMEDIATION_SURFACES`, `_COPILOT_BASE_EDITED`, `_ROUTER_AND_PROMPT_SURFACES`. | Remove skill entries; agent entries per branch. |
| `test_csharp_orchestration_contracts.py` | Reads `.github/skills/csharp-orchestration-state-machine` and `csharp-change-budget-router` text and three Copilot-bundle skill mirrors. | Retarget text assertions to the `.agents/skills` copies after confirming each asserted string is present there (the router strings were confirmed in all three copies); remove the skill mirror assertions; agent assertions unchanged. |
| `test_push_down_issue_824_follow_ups.py` | `.github/skills/feature-review-workflow` and bundle copy in `STEP_EIGHT_COPIES` and `FEATURE_REVIEW_TEXT_COPIES`. | Remove those entries; `SOLUTION_SCAN_ROOTS` `.github` unchanged. |
| `test_orchestrator_direct_command_contracts.py` | Four `.github` orchestrator agents and bundle mirrors. | Unchanged unless Branch B regenerates their text. |
| `test_push_down_copilot_customizations_helpers.py` | `test_thinking_beast_mode_bundle_mirror_matches_root_agent`. | Unchanged unless Branch A drops the persona. |
| `test_codex_full_migration_inventory.py` | `".github/agents/" in wrapper_text`. | Unchanged while `.github/agents` remains (child 3 owns provenance). |
| `test_agentic_sync_artifacts.py` | `ROOT_FOLDERS` equals the five-root tuple including `.github/skills`. | Update only if `ROOT_FOLDERS` changes (child 4 ownership). |
| `test_vscode_workspace_settings.py` | PowerShell 7 pin in `settings_required.json` and in `settings.json` when present. | Unchanged under Option 1; Option 2 must keep the pin. |
| `test_push_down_copilot_customizations.py`, `_rewrites.py`, `test_agentic_sync.py`, `test_agentic_sync_branches.py`, `test_quality_tiers_contract.py`, `codex_native_converter/*` | Synthetic in-memory paths. | Unaffected. |

Pester:

| Suite | Assertion | Disposition |
| --- | --- | --- |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | Headings `### Canonical .github/skills migration map`, `### Canonical .github/agents migration map`; `.github/skills/README.md` documentation-only. | Update with the document (in blast radius). |
| `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1` | Canonical directory `.github/agents`. | Unchanged in both branches. |
| `tests/scripts/dev-tools/agents-attribution.Tests.ps1` | `*-adjusted.agent.md` under `.github/agents`. | Unchanged unless Branch A drops both personas. |
| `tests/scripts/claude-lib/discovery-validation/DiscoveryStart.Tests.ps1`, `tests/scripts/copilot-hooks/discovery-start.Tests.ps1` | `github-copilot` profile path `.github/agents/...`. | Unchanged. |

Jest (`extensions/drm-copilot/test/`): `lib/push-down/copilot-customizations-engine.test.ts` pins `COPILOT_ROOT_FOLDERS` including `.github/skills` (update if the constant changes); `packaging/discovery-resources.test.ts` and `packaging/mcp-server-prepack.test.ts` pin `customizations/.github/agents/<role>.agent.md` and hooks (unchanged); `push-down-service-call.test.ts`, `copilot-customizations.test.ts`, codex-native-converter tests use synthetic paths (unaffected).

Parity matrix: after deletion, `copilot:skill:<name>` entries are orphans and are already `dropped` by default; `copilot:skill-frontmatter-field:<key>` entries (bootstrapped `native`, owner child 3) also become orphans and must be set to `dropped` with `reason` and `decision_ref`, or `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` fails (orphan rule, child 1 spec `## Data & State` invariant 5).

## 9. Quality Tiers

`quality-tiers.yml` exists at the repository root. Discovery rules in `scripts/dev_tools/quality_tiers_contract.py` (R1 to R5) create projects only for package or project files, PowerShell module pairs, `scripts/<name>` code folders, `.claude/lib/<name>` folders, and the three hook folders. Child 6 creates no new code folder, so no new entry is needed (no QT008). The `.github/hooks` entry stays valid because the hooks remain (no QT007).

## Numeric Derivation Evidence

### N1: `.github/skills` folders retired

- Complete Family: skill folders directly under `.github/skills`.
- Exhaustive Search Scope: every file under `.github/skills/`.
- Inclusion Rules: a direct child folder of `.github/skills` that contains `SKILL.md`.
- Exclusion Rules: `README.md`.
- Primary Search Strategy or Query Expression: Glob `.github/skills/*/SKILL.md`.
- Primary Member Set: the 33 names listed in section 1.1.
- Primary Count: 33.
- Cross-check Search Strategy or Query Expression: Glob `.github/skills/**/*` (34 files), remove `README.md`, take the parent folder of each remaining file.
- Cross-check Member Set: the same 33 names (each remaining file is `<name>/SKILL.md`; no folder holds a second file).
- Cross-check Count: 33.
- Member-set Comparison: identical sets; no duplicates.

### N2: `.github/agents` files

- Complete Family: tracked files under `.github/agents`.
- Exhaustive Search Scope: `.github/agents/**`.
- Inclusion Rules: any file.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `.github/agents/**/*`.
- Primary Member Set: the 46 files partitioned in section 2.1 (27 handoff closure, 3 prompt-bound, 5 discovery-bound, 11 personas).
- Primary Count: 46.
- Cross-check Search Strategy or Query Expression: Grep count of the frontmatter delimiter `^---\s*$` per file in `.github/agents`.
- Cross-check Member Set: 46 files, the same names.
- Cross-check Count: 46.
- Member-set Comparison: identical. (A Grep for `^name:` returns 42 files; the four without `name:` are listed in 2.1, so that query is not used as a cross-check.)

### N3: handoff-bearing agents

- Complete Family: `.github/agents` files whose frontmatter declares handoffs.
- Exhaustive Search Scope: `.github/agents/**`.
- Inclusion Rules: a `handoffs:` key.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Grep `^handoffs:` (files with matches).
- Primary Member Set: the 20 files listed in 2.1.
- Primary Count: 20.
- Cross-check Search Strategy or Query Expression: unanchored Grep `handoffs` (count mode; 23 occurrences).
- Cross-check Member Set: the same 20 files.
- Cross-check Count: 20.
- Member-set Comparison: identical.

### N4: execution-environment brief copies after retirement

- Complete Family: committed files named `execution-environment/SKILL.md`.
- Exhaustive Search Scope: the whole tree.
- Inclusion Rules: path ends `execution-environment/SKILL.md`.
- Exclusion Rules: the two copies under `.github/skills/` and `extensions/drm-copilot/resources/customizations/.github/skills/` (retired).
- Primary Search Strategy or Query Expression: Glob `**/execution-environment/SKILL.md` (6) minus the two `.github` paths.
- Primary Member Set: `.claude/skills/...`, `.agents/skills/...`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/...`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/...`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: the six-location list in the brief's `## Purpose and Maintenance` minus the `.github` location and its bundled copy.
- Cross-check Member Set: the same four paths.
- Cross-check Count: 4.
- Member-set Comparison: identical.

## Recommended Plan Structure

Plans (each within 40 tasks and 400 lines):

1. `plan.<stamp>.md` (main plan, about 35 tasks): Phase 0 gate (records results; does not decide the branch); `.github/skills` retirement with the U1 to U3 record; source and bundle deletion; brief update in four copies and its tests; the seven read-first lines (needed in both branches); `.github/copilot-instructions.md` reduction; documentation updates; matrix entries for skills and frontmatter fields; collision controls per E4 and Q5; Python, Pester and Jest test updates for skills; toolchain loop and evidence.
2. `plan-agents-branch-a.md` (about 15 tasks) and `plan-agents-branch-b.md` (about 20 tasks, generated and native sub-cases): agent-file edits, matrix `copilot:agent:*` and handoff entries, agent-pinning tests, evidence.

Justification: the E3 result is recorded by child 1 before this child executes, so branch selection is an orchestrator decision between executor plans, not an executor halt. The orchestrator delegates the main plan, reads the Phase 0 evidence, and delegates exactly one branch plan. An owner stop is needed only when E3 is deferred and the owner chooses to wait, or when Branch A would drop personas (OQ2). Splitting agent work out keeps the main plan inside 40 tasks. A third plan for tests was considered and rejected: tests must change in the same plan as the files they pin, or the plan's own acceptance cannot pass.

## Phase 0 Gate Checks

1. Parallel run `bugs-1001-1002-1003-1006` merged to `main`; the section 6 files re-read at the merge base of `origin/main` and `HEAD` with every named heading, symbol and asserted string present.
2. Child 1: E3 and E4 (and E6) result files under `#1025:evidence/other/` or owner deferrals; `Approval-Status` of `#1025:survey/difference-approval.md`; classifications of the `feature-promotion-lifecycle` and `feature-review-workflow` differences; `config/harness-parity-matrix.json` and schema present with `copilot:*` entries owned by child 6.
3. Child 3: `.agents/skills` is the shared source with a `--check` mirror into `.claude/skills`; how the discovery role links are rewritten per tool; whether the agent generator emits `.github/agents`; `CLAUDE.md` and `.claude/rules/tonality.md` no longer name `.github/copilot-instructions.md` as authoritative; status of `sync-agents-from-instructions.ps1`; `.codex/agents` provenance handling.
4. Child 4: whether `COPILOT_ROOT_FOLDERS` and `agentic_sync.ROOT_FOLDERS` still exist and who owns them; whether the Copilot bundle gained a pack manifest; destination cleanup of previously pushed `.github/skills`.
5. Child 5: dispositions for `.github/hooks/*`; whether `Get-DiscoveryAgentProfilePath` still resolves `.github/agents`.
6. Any mismatch stops for re-planning (one plan revision accepted per owner decision E3 of the epic).

## Owner Questions

| ID | Question | Recommended default |
| --- | --- | --- |
| OQ1 (Q5) | How are collision controls delivered given `.vscode/settings.json` is gitignored? | Option 1 (section 5.3) when E4 shows workspace scope works; otherwise document as user settings; child 4 carries destination delivery. |
| OQ2 | Under Branch A, may the 11 personas without Claude equivalents be dropped? | No; keep them native. Branch A then changes only collision controls and matrix status. |
| OQ3 | Should `## File Size Advisory` (U3) be ported into the shared `feature-review-workflow` skill? | Follow child 1's approved classification; default mechanism-only, no port. |
| OQ4 | If child 3 does not provide per-tool role-link handling for the 16 discovery skills, who re-anchors their canonical source? | Phase 0 stop and re-plan with child 3 scope, not a child 6 workaround. |
| OQ5 | If `CLAUDE.md` still names `.github/copilot-instructions.md` as authoritative at execution, may child 6 edit those pointer lines? | Yes, pointer lines only, naming `AGENTS.md`. |

## Pre-Mortem

- Review checklists: a reviewer may flag removed unique content or stale cross-references; mitigation: the U1 to U3 evidence record with reasons and child 1 decision references, plus a final Grep for `.github/skills` across non-historical paths with every remaining hit classified.
- Coverage: no production code changes in the main plan; if `copilot-customizations-engine.ts` or `agentic_sync.py` is edited, per-file coverage must stay at or above 85% line and 75% branch with no regression on changed lines; mitigation: coverage task for each touched production file, measured in module form for Python and with the existing Jest threshold entry.
- Mirror parity: deleted sources must lose their bundle copies in the same task, and the brief must stay byte-identical in four copies; mitigation: paired source and bundle tasks, the brief-update task named here, and runs of the contract tests listed in the execution-environment brief after each mirrored edit.
- File size: only Markdown and existing tests change; mitigation: confirm no edited test file grows past 800 lines (`config/file-size-baseline.json` rules).
- Test isolation: edited Python and Pester tests read committed files only; mitigation: reversed-order run of changed Python modules, three seeded shuffled runs of touched Pester suites, a single-process run over `tests/scripts`, and a seeded Jest run if Jest tests change, recorded under `evidence/regression-testing/`.
- CI-only behavior: the PowerShell hook suites run on Linux with case-sensitive paths, and the parity-matrix gate runs in `poshqc / PowerShell QC`; mitigation: exact-case paths and running the matrix gate locally before push; deleting a whole `.github/skills` root must not leave a test that asserts a non-empty root.
- Evidence: Phase 0 results, the unique-section record, documentation fetch dates, and the branch selection must each have an artifact under `evidence/baseline/` or `evidence/other/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; no absolute paths, scratch locations recorded as `SCRATCH`.

## Risks

- Duplicate loading persists without collision controls: after retirement Copilot in VS Code still reads both `.agents/skills` and `.claude/skills`, both rule folders, both agent folders, and `CLAUDE.md`, by default.
- The cloud agent's `AGENTS.md` support is not stated per surface in the fetched documentation; removing the tone text from `.github/copilot-instructions.md` may remove it from the cloud agent if that surface does not read `AGENTS.md`.
- Destinations that received `.github/skills` from earlier push-downs keep stale copies unless child 4's migration removes them.
- E3 deferral leaves `copilot:agent:*` entries `provisional`; Branch B is the safe default.
- `fs.listFiles` behavior on a missing root in the Copilot push-down was not verified.

## Rejected Alternatives

- Porting U1 and U2 into `.agents/skills`: rejected because issue #168 removed that policy.
- One plan containing both agent branches: rejected because a conditional branch inside an executor plan leaves unchecked tasks or requires a mid-plan halt.
- Committing `.vscode/settings.json` as the default: rejected as default because it conflicts with existing personal workspace files; kept as an owner option.

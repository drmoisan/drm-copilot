# 2026-10-30-retire-github-skills-and-thin-copilot-layer — Spec

- **Issue:** #1032
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`), child 6
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Primary research input:** `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/research/research.2026-10-30T23-02.md` (cited below as "research", with section numbers)
- **Settled design (not re-opened):** `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`

## Overview

Epic #1018 moves the three agent ecosystems in this repository onto shared cross-tool conventions so that each tool loads every skill and instruction exactly once with default settings. GitHub Copilot in VS Code reads `.github/skills`, `.claude/skills` and `.agents/skills`; `.github/skills` is a strict subset of the other two skill folders by name (research section 1.1) and causes duplicate loading. `.github/agents` duplicates agent definitions that Copilot in VS Code also reads from `.claude/agents`, with name collisions listed in research section 2.1. Collision controls currently exist only in the owner's personal user settings; no repository file contains any of the `chat.*` collision settings (research section 5.2).

This feature (child 6 of the epic) retires `.github/skills`, settles `.github/agents` according to child 1's recorded E3 result, reduces the Copilot layer to the native surfaces that have no shared equivalent, delivers or documents the Copilot collision controls according to child 1's recorded E4 result, and updates every mirror, manifest, matrix entry and contract test that pins a removed or changed file.

## Scope

### In scope

1. **Retire `.github/skills`.**
   - Record the unique-content dispositions before deletion (research section 1.2):
     - U1 — `.github/skills/feature-promotion-lifecycle/SKILL.md`, `## MCP-First Execution Rule` ("Documented alternatives" list): **stale**. Issue #168 (`docs/features/completed/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/spec.md`) removed the fallback policy; porting would re-introduce it.
     - U2 — same file, `## Canonical Fallback Command Sequence` and the VS Code command forms in `## Canonical Fallback Short-Path Sequence (Minor Audit Mode)`: **stale** for agent sessions for the same reason; the `drmCopilotExtension.*` command IDs remain documented by `extensions/drm-copilot/package.json` (`contributes` commands).
     - U3 — `.github/skills/feature-review-workflow/SKILL.md`, `## File Size Advisory`: disposition follows child 1's approved classification of the corresponding `D-feature-review-workflow-<nn>` difference. Default: **present elsewhere / mechanism-only** (the content exists in `.claude/agents/feature-review.md`, `.agents/skills/feature-review/SKILL.md` and `.codex/agents/feature-review.toml`, each under `## File Size Advisory`); no port by this child. If child 1 approved it as `positive`, the port lands in `.agents/skills/feature-review-workflow/SKILL.md` and is mirrored by child 3's skill generator.
     - If the owner overrode U1 or U2 in child 1's `survey/difference-approval.md`, the override governs and the port lands in `.agents/skills/<name>/SKILL.md`.
   - Delete the 33 skill folders and `README.md` under `.github/skills/` and the mirror under `extensions/drm-copilot/resources/customizations/.github/skills/` (numeric evidence N1 in the research).
   - Move the canonical anchor of the two families that treat the `.github` copy as canonical (research section 1.1): the execution-environment brief (canonical becomes `.agents/skills/execution-environment/SKILL.md`) and the legacy-discovery skills (re-anchored per child 3's shared-source design; Phase 0 dependency, OQ4).
   - Repoint every `.github/agents/*.agent.md` reference to `.github/skills` (research section 2.1) and its bundle copy to `.agents/skills/...`; the exact lines are enumerated by Grep at execution.
2. **Settle `.github/agents` per child 1's recorded E3 result** as Branch A or Branch B (research section 2.3):
   - **Branch A** (E3 result: both the Copilot CLI and the Copilot cloud agent read `.claude/agents`): retire only `.github/agents` files that are outside every native binding (handoff closure, prompt `agent:` bindings, and the discovery-hook profile bindings in research section 2.1). Under the default answer to OQ2, no persona is dropped and Branch A reduces to the collision control and parity-matrix status updates.
   - **Branch B** (E3 result: no, or deferred): `.github/agents` remains the repository agent source for the Copilot CLI and cloud agent. Generated case: replace hand-written files with child 3 generator output when child 3 delivers a `.github/agents` target that emits `handoffs:` and Copilot tool identifiers, registered in that generator's `--check`. Native case: keep the files native and record matrix disposition `native` with a reason.
   - In both branches handoffs stay native (settled design).
3. **Thin Copilot layer.** `.github/prompts`, handoffs in `.github/agents`, and `.github/hooks` remain native in `.github`. `.github/copilot-instructions.md` is kept (the `docs-validation` job in `.github/workflows/_docs-validation.yml` warns when it is missing) and reduced to Copilot-only text; its current tone-policy body duplicates `AGENTS.md` and `CLAUDE.md` (research section 4). `.github/instructions` is generated by child 3 and is not edited by this child.
4. **Copilot collision controls.** When child 1's E4 result shows workspace-scope settings work, deliver the keys in research section 5.1 at workspace scope by the OQ1 delivery option; otherwise document them as user-scope settings.
5. **Mirrors, packs and contract tests.** Remove bundle mirrors of every removed file; remove retired entries from any pack manifest child 4 delivers (none of today's pack manifests lists a `.github/` path, research section 3); update `COPILOT_ROOT_FOLDERS` / `agentic_sync.ROOT_FOLDERS` only if child 4 left them in place; update the contract tests listed in research section 8.
6. **Execution-environment brief.** Update the copy-count fact in `## Purpose and Maintenance` in all four remaining copies in the same change (numeric evidence N4 in the research): `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`.
7. **Current-fact documents.** Update `docs/engineering/claude-code-architecture.md` (`### Canonical .github/skills migration map` and the statement that `.github/` is authoritative), `.agents/README.md` and its bundle copy, `README.md` (link to `.github/skills/README.md`), and `docs/engineering/legacy-discovery-and-parity/maintainer-guide.md` and `workflow.md` (research section 3).
8. **Parity matrix.** Set the orphaned `copilot:skill-frontmatter-field:<key>` entries and any `copilot:agent:<name>` / `copilot:subagent-frontmatter-field` entries affected by the selected branch to their disposition with `reason` and `decision_ref`, so child 1's completeness and orphan gate passes (research section 8, "Parity matrix").

### Out of scope

See `## Non-Goals`.

## Upstream Dependencies (Interface Assumptions)

This feature is planned before its upstream outputs exist (owner decision E3 in the epic `## Shared Design`). Each dependency is recorded as an interface assumption with its source. The Phase 0 gate re-checks each assumption at execution time and stops for re-planning when an output differs; one plan revision is accepted.

| Upstream | Source | Assumed interface | Phase 0 check |
| --- | --- | --- | --- |
| Child 1 (#1025) | Spec on `origin/feature/harness-survey-gold-standard-contracts-parity-matrix-1025`: `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/spec.md` and `research/research.2026-10-30T21-08.md` | Parity matrix at `config/harness-parity-matrix.json` with its schema; `copilot:*` entries owned by child 6; dispositions `shared`, `native`, `generated`, `dropped` with `reason` and `decision_ref` in the format child 1's spec defines (`## Data & State`); orphan rule (child 1 spec `## Data & State` invariant 5) enforced by `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`. | Matrix file, schema and gate present; entry keys and fields match. |
| Child 1 (#1025) | Same branch, `evidence/other/` | E3 (Copilot CLI and cloud agent read `.claude/agents`), E4 (workspace-scope Copilot settings) and E6 result files, or recorded owner deferrals. | Result files or deferrals present; the E3 result selects Branch A or Branch B. |
| Child 1 (#1025) | Same branch, `survey/difference-approval.md` | `Approval-Status` approved; classifications for the `feature-promotion-lifecycle` and `feature-review-workflow` differences. | Classifications for U1, U2 and U3 read and cross-referenced. |
| Child 1 (#1025) | Child 1 spec, owner question Q5 | Q5 (delivery of collision controls given `.vscode/settings.json` is gitignored) is assigned to this child. | Folded into OQ1 below. |
| Child 3 | Epic manifest `## Scope` (child 3; not yet specified) | `.agents/skills` is the shared skill source mirrored into `.claude/skills` with `--check`; per-tool handling of discovery role links; `AGENTS.md` is the instruction source and `CLAUDE.md` imports it; `.github/instructions` generated. Not assumed: a `.github/agents` generator target (Branch B generated case only). | Shared-source generator present; role-link handling present (else OQ4); `CLAUDE.md` and `.claude/rules/tonality.md` no longer name `.github/copilot-instructions.md` as authoritative (else OQ5); status of `scripts/dev-tools/sync-agents-from-instructions.ps1`; `.codex/agents` provenance handling. |
| Child 4 | Epic manifest `## Scope` (child 4; not yet specified) | One push-down pipeline with per-ecosystem packs; owner of `COPILOT_ROOT_FOLDERS` (`extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts`) and `ROOT_FOLDERS` (`scripts/dev_tools/agentic_sync.py`); destination cleanup of previously pushed `.github/skills`. | Whether both constants still exist; whether the Copilot bundle has a pack manifest; destination cleanup owner. |
| Child 5 | Epic manifest `## Scope` (child 5; not yet specified) | Dispositions for `.github/hooks/*`; whether `Get-DiscoveryAgentProfilePath` in `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1` still resolves `.github/agents`. | Hook dispositions recorded; profile resolution unchanged or re-planned. |

## Execution Preconditions

- The parallel run `bugs-1001-1002-1003-1006` must have merged to `main` before execution starts (epic `## Execution Preconditions`).
- The Phase 0 gate re-reads every file the plans edit at the merge base of current `origin/main` and `HEAD`, and stops for re-planning when a named file, symbol, heading or asserted string has moved. Files in the parallel run's blast radius that this feature edits or deletes (research section 6):
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
- Run-only files in the blast radius (re-checked, not edited): `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, both `pack-manifests/core.json` files, `scripts/dev_tools/generate_codex_agent_variants.py`.

## Phase 0 Gate

The main plan starts with a Phase 0 gate that records results and does not decide the agents branch. Checks (research `## Phase 0 Gate Checks`):

1. Parallel run merged; the files in `## Execution Preconditions` re-read with every named heading, symbol and asserted string present.
2. Child 1 outputs per `## Upstream Dependencies`.
3. Child 3 outputs per `## Upstream Dependencies`.
4. Child 4 outputs per `## Upstream Dependencies`.
5. Child 5 outputs per `## Upstream Dependencies`.
6. Any mismatch stops execution for re-planning. One plan revision is accepted (owner decision E3).

Results are written to `<FEATURE>/evidence/baseline/` with `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` fields.

## Behavior

- After delivery, `.github/skills` does not exist in the tree or in the Copilot bundle; Copilot in VS Code reads shared skills from `.agents/skills` (and from the generated `.claude/skills` mirror unless the collision control disables it).
- `.github/agents` is in the state the selected branch defines; handoffs and prompt `agent:` bindings resolve.
- `.github/copilot-instructions.md` contains only Copilot-only text (for example, that prompts and handoff-bearing agents live natively in `.github/prompts` and `.github/agents`, and that shared instructions come from `AGENTS.md`).
- Collision-control keys (research section 5.1): `chat.agentSkillsLocations` with `".claude/skills": false`; `chat.instructionsFilesLocations` with `".claude/rules": false`; `chat.agentFilesLocations` with `".claude/agents": false` while `.github/agents` remains; `chat.useClaudeMdFile: false`. `chat.useAgentsMdFile`, `chat.useClaudeHooks` and `github.copilot.chat.codeGeneration.useInstructionFiles` keep their defaults.

## Inputs / Outputs

- Inputs: child 1 E3/E4 results, `survey/difference-approval.md`, `config/harness-parity-matrix.json`; child 3, 4 and 5 merged outputs; current `origin/main`.
- Outputs: deletions under `.github/skills/` and its bundle mirror; edits listed in `## Scope`; evidence artifacts under `<FEATURE>/evidence/<kind>/`.
- Config keys: `.vscode/settings_required.json` gains the collision keys under the OQ1 default when E4 shows workspace scope works. The PowerShell 7 pin asserted by `tests/scripts/dev_tools/test_vscode_workspace_settings.py` is preserved.
- Backward compatibility: destination repositories that received `.github/skills` from earlier push-downs keep stale copies unless child 4's migration removes them (risk R3).

## Data & State

- Invariants: no bundle mirror exists without its source; the four execution-environment brief copies are byte-identical; every parity-matrix entry has a disposition and no orphaned entry lacks `reason` and `decision_ref`.
- No persistence, caching or migration logic is introduced by this child.

## Language Classification

Owner rule (epic `## Shared Design`, refined 2026-10-30), verbatim in substance: Avoid new Python; existing Python is tolerated (reuse, call or extend in place only). Anything pushed down to destination repos — skills, skill helpers, hooks and libs — is PowerShell or bash, never TypeScript and never Python. TypeScript is only for MCP commands (tools in the MCP server package) and extension commands. Owner exception E2: a language-native analyzer is allowed when it analyzes that same language and ships only with that language's pack; PowerShell remains the baseline.

| Planned artifact | Change | Classification under the rule |
| --- | --- | --- |
| `.github/skills/**` and `extensions/drm-copilot/resources/customizations/.github/skills/**` | Delete | Markdown; no code. |
| `.github/agents/*.agent.md` read-first lines and bundle copies; Branch A or B agent edits | Edit or delete | Markdown; no code. |
| Execution-environment brief, four copies | Edit | Markdown. |
| `.github/copilot-instructions.md` and bundle copy | Edit | Markdown. |
| `docs/engineering/claude-code-architecture.md`, `.agents/README.md` and bundle copy, `README.md`, `docs/engineering/legacy-discovery-and-parity/maintainer-guide.md`, `workflow.md` | Edit | Markdown. |
| `CLAUDE.md` and `.claude/rules/tonality.md` pointer lines (only under OQ5) | Edit | Markdown. |
| `.vscode/settings_required.json` | Edit | JSON configuration. |
| `config/harness-parity-matrix.json` | Edit | JSON data (child 1 schema). |
| Existing pytest contract tests (research section 8) | Edit in place | Existing Python, tolerated. |
| Existing Pester suites (research section 8) | Edit in place | PowerShell. |
| `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` and its Jest test, only if child 4 left `COPILOT_ROOT_FOLDERS` | Edit | TypeScript in MCP-tool code; permitted. |
| `scripts/dev_tools/agentic_sync.py` and `test_agentic_sync_artifacts.py`, only if child 4 left `ROOT_FOLDERS` | Edit in place | Existing Python, tolerated. |
| Verification helpers | None planned | If needed: PowerShell under the session scratch location, not committed. |

No artifact requires new Python or pushed-down TypeScript. The research found no case that cannot follow the rule, so no artifact requires an owner language question.

## Owner Questions

No owner stop sits inside an executor plan. The orchestrator selects the agents branch plan from child 1's recorded E3 result between plans, and any owner question that is unanswered at execution takes its recommended default.

| ID | Question | Recommended default |
| --- | --- | --- |
| OQ1 (includes child 1 Q5) | How are Copilot collision controls delivered, given `.vscode/settings.json` is gitignored? | When E4 shows workspace scope works: add the keys to `.vscode/settings_required.json` and document the copy step into `.vscode/settings.json`. When E4 does not show it works: document the keys as user-scope settings. Record a request that child 4 delivers a merge into destination `.vscode/settings.json` (research section 5.3, Option 3). Owner alternative: commit `.vscode/settings.json` (remove it from `.gitignore`), which must keep the PowerShell 7 pin. |
| OQ2 | Under Branch A, may the personas that have no `.claude/agents` equivalent (research section 2.1) be dropped? | No; keep them native. Branch A then changes only collision controls and matrix status. |
| OQ3 | Should `## File Size Advisory` (U3) be ported into the shared `feature-review-workflow` skill? | Follow child 1's approved classification; default mechanism-only, no port. |
| OQ4 | If child 3 does not provide per-tool role-link handling for the legacy-discovery skills, who re-anchors their canonical source? | Phase 0 stop and re-plan within child 3 scope; no child 6 workaround. |
| OQ5 | If `CLAUDE.md` or `.claude/rules/tonality.md` still names `.github/copilot-instructions.md` as authoritative at execution, may this child edit those pointer lines? | Yes, pointer lines only, naming `AGENTS.md`. |

## Plan Structure

- **Main plan** (`plan.<stamp>.md`): Phase 0 gate; `.github/skills` retirement with the U1–U3 record; source and bundle deletion; brief update in four copies and its tests; the `.github/agents` read-first line repoints (needed in both branches); `.github/copilot-instructions.md` reduction; current-fact documentation; parity-matrix entries for skills and skill frontmatter fields; collision controls per E4 and OQ1; pytest, Pester and Jest updates for skills; mirrors; final toolchain loop, QA gates and self-review.
- **`plan-agents-branch-a.md`**: Branch A agent edits, matrix `copilot:agent:*` and handoff entries, agent-pinning tests, evidence.
- **`plan-agents-branch-b.md`**: Branch B generated and native sub-cases, matrix entries, agent-pinning tests, evidence.
- Exactly one branch plan executes. The orchestrator delegates the main plan, reads the Phase 0 evidence, and delegates the branch plan that matches the recorded E3 result (Branch B when E3 is deferred). Tests change in the same plan as the files they pin.

## Acceptance Criteria

- [ ] AC1 — `.github/skills/` does not exist in the tree: Glob `.github/skills/**` returns no files.
- [ ] AC2 — `extensions/drm-copilot/resources/customizations/.github/skills/` does not exist: Glob returns no files, and `test_copilot_bundle_mirrors_every_scoped_github_file` in `tests/scripts/dev_tools/test_discovery_publication_contracts.py` passes with `.github/skills` removed from `COPILOT_ROOTS`.
- [ ] AC3 — An evidence artifact under `<FEATURE>/evidence/other/` records U1 and U2 as stale and U3 per child 1's classification, each with its reason and a reference to child 1's `survey/difference-approval.md`; where an owner override required a port, the ported text is present in `.agents/skills/<name>/SKILL.md`.
- [ ] AC4 — Exactly one agents branch plan was executed, matching child 1's recorded E3 result (Branch B when deferred); an evidence artifact under `<FEATURE>/evidence/other/` records the E3 result path and the selected branch.
- [ ] AC5 — Branch outcome: under Branch A, every removed `.github/agents` file was outside every native binding and has an owner-approved `dropped` matrix entry, and no file was removed under the OQ2 default; under Branch B, `.github/agents` files are either reported as no-drift by child 3's generator `--check` (generated case) or carry matrix disposition `native` with a reason (native case).
- [ ] AC6 — Every prompt `agent:` binding in `.github/prompts` and every `handoffs:` target in `.github/agents` resolves to an existing `.github/agents` file or the built-in agent, recorded in an evidence artifact.
- [ ] AC7 — `.github/copilot-instructions.md` exists and contains no tone-policy text that duplicates `AGENTS.md` or `CLAUDE.md`; its bundle copy is identical to it.
- [ ] AC8 — `.github/prompts` and `.github/hooks` contain the same files as at the Phase 0 baseline, except changes recorded by child 5.
- [ ] AC9 — Collision controls: when E4 shows workspace scope works, `.vscode/settings_required.json` contains each collision key listed in `## Behavior` (`chat.agentSkillsLocations`, `chat.instructionsFilesLocations`, `chat.agentFilesLocations`, `chat.useClaudeMdFile`) and the copy step is documented; otherwise the keys are documented as user-scope settings. `tests/scripts/dev_tools/test_vscode_workspace_settings.py` passes.
- [ ] AC10 — The four remaining execution-environment brief copies are byte-identical and state the four-location fact; `test_execution_environment_fact_is_unchanged_across_copies` in `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` (canonical `.agents/skills/execution-environment/SKILL.md`) and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (including `test_brief_is_referenced_by_copilot_base_agents` with the new path) pass.
- [ ] AC11 — Named contract tests pass: `test_discovery_publication_contracts.py`, `test_completion_gate_documentation_contracts.py`, `test_evidence_timestamp_contracts.py`, `test_minor_audit_acceptance_criteria_contracts.py`, `test_single_pass_preflight_contracts.py`, `test_csharp_orchestration_contracts.py`, `test_push_down_issue_824_follow_ups.py`, `test_legacy_discovery_skills_contracts.py`, `test_orchestrator_direct_command_contracts.py`, `test_push_down_copilot_customizations_helpers.py`, `test_codex_full_migration_inventory.py`, `test_agentic_sync_artifacts.py` (all under `tests/scripts/dev_tools/`), and Pester `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1`, `tests/scripts/dev-tools/agents-attribution.Tests.ps1`.
- [ ] AC12 — Push-down contract tests pass: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and the Jest suite `extensions/drm-copilot/test/lib/push-down/copilot-customizations-engine.test.ts`; no pack manifest (including any child 4 adds) lists a removed path.
- [ ] AC13 — No stale reference: a Grep for `.github/skills` across the tree, excluding `docs/features/` historical records, returns only hits that an evidence artifact under `<FEATURE>/evidence/other/` classifies as historical, fixture, or generic input-format handling (research section 3, "May stay"); every `.github/agents` file and bundle copy has zero matches.
- [ ] AC14 — Parity matrix: the `copilot:skill-frontmatter-field:<key>` entries and any agent entries changed by the selected branch carry a disposition with `reason` and `decision_ref`, and `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` passes.
- [ ] AC15 — Current-fact documents no longer state that `.github/skills` is canonical or present: `docs/engineering/claude-code-architecture.md`, `.agents/README.md` and bundle copy, `README.md`, `docs/engineering/legacy-discovery-and-parity/maintainer-guide.md` and `workflow.md`.
- [ ] AC16 — Toolchain and coverage gates are green: the seven-stage toolchain loop completes in one pass for every touched language; when `copilot-customizations-engine.ts` or `agentic_sync.py` is edited, its line coverage is at least 85% and branch coverage at least 75% (TypeScript, Python) with no regression on changed lines; results are recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] AC17 — Test isolation: a reversed-order run of changed pytest modules, three seeded shuffled runs of touched Pester suites, and a seeded Jest run when Jest tests change all pass, recorded under `<FEATURE>/evidence/regression-testing/`.
- [ ] AC18 — No new Python: `git diff --name-status origin/main...HEAD` shows no added `*.py` file, and no added file under a pushed-down tree is TypeScript or Python.
- [ ] AC19 — No edited file grows past 800 lines, and no file listed in `config/file-size-baseline.json` grows.

## Non-Goals

- Re-opening any decision in the settled design or the epic manifest.
- Editing `.github/instructions` (generated by child 3), the shared-source generators (child 3), push-down pipeline consolidation (child 4) or hook behavior (child 5).
- Removing `.codex/agents` provenance lines that name `.github/agents` (child 3), except where Branch A removes a source file and child 3 has handed this over.
- Changing `extensions/drm-copilot/src/lib/codex-native-converter/*`, `scripts/dev_tools/codex_native_converter/*`, or their fixtures (generic input handling).
- Changing historical records under `docs/features/` or historical test fixtures.
- Delivering collision controls to destination repositories (requested of child 4).
- Edits to files or branches of the in-flight parallel run `bugs-1001-1002-1003-1006`.

## Constraints & Risks

- **R1 — Duplicate loading persists without collision controls.** After retirement Copilot in VS Code still reads `.agents/skills` and `.claude/skills`, both rule folders, both agent folders, and `CLAUDE.md` by default. Other users get the controls only after the documented copy step under the OQ1 default.
- **R2 — Unverified: cloud-agent `AGENTS.md` support.** The fetched documentation does not state per surface whether the Copilot cloud agent reads `AGENTS.md`; removing the tone text from `.github/copilot-instructions.md` may remove it from that surface.
- **R3 — Stale destination copies.** Destinations that received `.github/skills` from earlier push-downs keep stale copies unless child 4's migration removes them.
- **R4 — E3 deferral.** `copilot:agent:*` entries stay `provisional`; Branch B is the safe default.
- **R5 — Unverified: `fs.listFiles` on a missing root.** Behavior of the Copilot push-down when a root in `COPILOT_ROOT_FOLDERS` is absent was not verified; the plan confirms it or removes the root.
- **R6 — Upstream drift.** Children 3, 4 and 5 are not yet specified; the Phase 0 gate stops for re-planning on mismatch.
- **R7 — Discovery role links.** A single byte-identical mirror cannot reproduce per-tool role links in the discovery skills (research section 1.1); depends on child 3 (OQ4).
- **R8 — CI-only behavior.** PowerShell suites run on Linux with case-sensitive paths, and the parity-matrix gate runs in `poshqc / PowerShell QC`; exact-case paths and a local matrix-gate run before push mitigate it.

## Evidence Locations

All evidence is written under `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`:

- `evidence/baseline/` — Phase 0 gate results and pre-change test baselines.
- `evidence/other/` — U1–U3 disposition record, E3/E4 result references and branch selection, binding-resolution record, stale-reference classification, documentation fetch dates.
- `evidence/qa-gates/` — toolchain loop and coverage results.
- `evidence/regression-testing/` — isolation and regression runs.
- `evidence/issue-updates/` — issue update records, when produced.

Scratch locations are recorded as `SCRATCH`; no absolute host path appears in any artifact.

## Definition of Done

- [ ] Every item in `## Acceptance Criteria` is checked off with evidence.
- [ ] The acceptance criteria in `user-story.md` are checked off with evidence.
- [ ] Final self-review and feature review completed.

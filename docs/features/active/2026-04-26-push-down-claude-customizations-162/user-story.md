# `2026-04-26-push-down-claude-customizations` — User Story

- Issue: #162
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-04-26T13-49

## Story Statement

- As a developer working in a destination repository with the `drmCopilotExtension` installed, I want a single command that publishes the entire `.claude/` orchestration runtime from this repository into my workspace, so that I can adopt the same agents, skills, rules, hooks, and settings without manually copying files.
- As a developer who has already pulled down the runtime once, I want to refresh it by re-running the same command, so that upstream changes to skills or hooks are propagated without manual diffing.
- As a developer auditing what was published, I want a deterministic JSON summary artifact for each run, so that I can verify which files were created or overwritten and inspect the run metadata.
- As an agent running in a destination Claude Code session, I want every skill in the pushed `.claude/` tree to reference MCP tools rather than local scripts, so that the instructions resolve to actionable invocations against the `drmCopilotExtension` MCP server already present in my session.
- As an agent routing feature or bug delivery in a destination Claude Code session, I want to invoke the pushed-down orchestrate skill so that work proceeds through a deterministic checkpoint-driven workflow — with structured remediation and a non-negotiable PR creation gate — without requiring any local scripts or manual coordination.

## Problem / Why

The `.claude/` runtime surface (agents, skills, rules, hooks, settings) is project-scoped and lives only inside the repository that owns it. Other repositories that need the same orchestration runtime have no supported path to consume it. The Claude Code plugin system was investigated and rejected as the distribution channel: it has no native mechanism for shipping path-scoped standing instructions equivalent to `.claude/rules/*.md`.

The repository already operates two parallel one-way publishers — `push_down_copilot_customizations.py` for `.github/` content and `push_down_codex_and_agents_customizations.py` for `.codex/` and `.agents/` content. Both publish bundled customizations into a destination workspace via a parameterized engine. The `.claude/` tree has no equivalent publisher today.

A second concern compounds the distribution gap. Several `.claude/` markdown files reference local repository scripts (e.g., `poetry run python -m scripts.dev_tools.potential_to_issue`). Those scripts do not exist in destination workspaces, so any pushed copy of those files contains dead-link instructions. The Copilot publisher solves this with a runtime rewrite catalog. The user has rejected runtime rewriting in favor of source-side cleanup.


## Personas & Scenarios

### Primary Persona — Destination-Repository Developer

- **Who they are:** A developer working in a separate repository who has the `drmCopilotExtension` VS Code extension installed and an active Claude Code session connected to the `drmCopilotExtension` MCP server.
- **What they care about:** Adopting the orchestration runtime (agents, skills, rules) defined in this repository without forking or manually duplicating the `.claude/` tree.
- **Constraints:** Cannot install Claude Code plugins to deliver path-scoped standing instructions. Does not have the source repository's `scripts/dev_tools/` modules locally. Must keep their workspace's machine-local `.claude/settings.local.json` (if present) untouched.
- **Goals and frustrations:** Wants a single repeatable command that copies the runtime and produces an audit trail. Frustrated by ad-hoc copy-paste, drift between repositories, and dead-link instructions in skill files.
- **Context and motivations:** Onboarding a new repository to the same orchestration model, or refreshing an existing destination after upstream changes.

### Secondary Persona — Agent in a Destination Claude Code Session

- **Who they are:** An agent (orchestrator, executor, planner, or specialist) running inside the destination repository's Claude Code session, reading the pushed `.claude/` skill files at runtime.
- **What they care about:** Every invocation reference resolves to an MCP tool the agent can actually call. No instruction surface contains dead references to scripts that do not exist locally.
- **Constraints:** Can call MCP tools registered with the connected `drmCopilotExtension` server. Cannot run arbitrary `poetry run python -m scripts...` commands because those modules are not in the destination repository.

### Scenario 1 — First-time push-down into a new workspace

- **Trigger:** Developer opens the destination workspace in VS Code with the `drmCopilotExtension` installed.
- **Steps:**
  1. Developer opens the command palette and selects `drm-copilot: Push Down Claude Customizations`, OR a Claude Code session in the destination invokes `mcp__drmCopilotExtension__push_down_claude_customizations` with `workspaceRoot` set to the destination root.
  2. The extension resolves the bundled `push_down_claude_customizations.py` from `resources/templates/` and runs it against the destination root.
  3. The script copies every file under the bundled `.claude/` tree (except `settings.local.json`) into the destination workspace.
  4. The script writes a JSON summary artifact at `<destination>/artifacts/claude-customizations/push-down-{timestamp}.json`.
  5. The extension reports a one-line summary identifying the artifact path.
- **Obstacles or decisions:** None expected if the extension is installed. If `.claude/settings.local.json` already exists at the destination, it remains unchanged.
- **Expected outcome:** The destination's `.claude/` tree mirrors the source; every skill, agent, rule, and hook is present; a JSON summary is available for inspection.

### Scenario 2 — Repeated push-down updating existing files

- **Trigger:** The source repository has updated several skills since the last push-down. The developer wants the changes propagated.
- **Steps:**
  1. Developer re-runs the same command or MCP tool call.
  2. The script re-copies every tracked file. Files whose source has changed are classified as `overwritten` in the JSON summary; files unchanged on disk are also `overwritten` deterministically (the engine performs a per-file write rather than a hash-aware diff, matching the existing Copilot precedent).
  3. The new JSON summary lists `created_count`, `overwritten_count`, and per-file results so the developer can confirm which files were touched.
- **Expected outcome:** The destination's `.claude/` tree reflects the latest source state. The developer can audit the change by reading the new summary artifact.

### Scenario 3 — Destination missing the MCP server

- **Trigger:** A developer attempts to act on a pushed-down skill file in a Claude Code session that does not have the `drmCopilotExtension` MCP server connected.
- **Steps:**
  1. Agent reads the pushed copy of `.claude/skills/feature-promotion-lifecycle/SKILL.md`.
  2. The skill instructs the agent to invoke `mcp__drmCopilotExtension__new_potential_entry` or another MCP tool.
  3. The agent attempts the call; it fails because the MCP tool is not registered in the current session.
- **Outcome and rationale:** The failure is informative (a missing MCP tool, not a silent miss against a non-existent script). The skill file's `### Fallback only — when MCP server is unreachable` subsection documents the on-repository script form, which clarifies that the fallback applies to direct-source developers and not to destination-repository agents. The destination agent therefore reports a missing MCP-server prerequisite rather than executing an undefined script.

### Scenario 4 — Developer reading the pushed `feature-promotion-lifecycle/SKILL.md`

- **Trigger:** A developer (or agent) opens the pushed copy of `.claude/skills/feature-promotion-lifecycle/SKILL.md` in the destination workspace and follows it for promoting a potential into a feature.
- **Steps:**
  1. The reader sees the renamed "MCP-First Execution Rule" section with `mcp__drmCopilotExtension__*` identifiers in place of the previous VS Code command IDs.
  2. The reader follows the canonical sequence: `mcp__drmCopilotExtension__new_potential_entry`, then `mcp__drmCopilotExtension__potential_to_issue`, then `mcp__drmCopilotExtension__new_active_feature_folder`.
  3. Each call resolves to an MCP tool present in the connected `drmCopilotExtension` server.
- **Expected outcome:** The reader completes the promotion workflow without ever needing a `scripts/dev_tools/...` invocation. The fallback subsection is visible as a clearly-labeled developer-only affordance and is not the primary instruction surface.

### Scenario 5 — End-to-end orchestration using the pushed-down orchestrate skill

- **Who they are:** An agent acting as the orchestrator in a destination Claude Code session that received the pushed-down `.claude/` runtime. The agent has the `drmCopilotExtension` MCP server connected.
- **Trigger:** The agent is asked to deliver a feature identified by an active feature folder (e.g., `2026-04-25-calendar-windows-wrong-55`).
- **Steps:**
  1. The agent reads `artifacts/orchestration/orchestrator-state.json`. No checkpoint exists, so the orchestration lifecycle starts from the beginning.
  2. The agent derives the canonical issue number `55` from the feature folder name and records it in the checkpoint as `issue_num`.
  3. The agent delegates to `atomic-planner`, including the line `Canonical issue number for this feature is 55` near the top of the prompt.
  4. After plan review, the agent delegates to `atomic-executor` for task-by-task execution. Each task runs the mandatory toolchain loop (format → lint → type-check → test) before being marked complete.
  5. The agent delegates to `feature-review` with a neutral instruction to execute the full review workflow. The prompt contains no scope-narrowing language and no assertions that any language category is not applicable.
  6. The agent reads the produced `remediation-inputs.<timestamp>.md`. It contains two blocking findings, so the remediation loop is entered. `remediation_pass: 1` is recorded in the checkpoint.
  7. R1: the agent delegates to `atomic-planner` to produce `remediation-plan.<timestamp>.md` addressing both blocking findings.
  8. R2: the agent delegates to `atomic-executor` for preflight-only validation. Preflight returns `ALL_CLEAR`.
  9. R3: the agent delegates to `atomic-executor` with full execution authorization. Execution completes with a clean final toolchain pass.
  10. R4: the agent delegates to `feature-review` again with the same inputs and no scope narrowing. The re-audit produces no blocking findings.
  11. R5: the remediation loop exits. The checkpoint is updated with `step6_status: "complete_no_blocking_findings"` and `blocking_findings_resolved: true`.
  12. The agent verifies the PR creation gate: all four conditions are met. The PR is created.
- **Obstacles or decisions:** If the remediation loop runs 3 full iterations without clearing all blocking findings, the agent stops and records `step6_status: "blocked_remediation_loop_limit"`. It reports the unresolved findings to the user and does not create a PR.
- **Expected outcome:** The feature is delivered through a fully auditable, deterministic workflow. The checkpoint file at `artifacts/orchestration/orchestrator-state.json` documents every phase transition. A PR is created only after all blocking findings are resolved and all four gate conditions are simultaneously met.

## Acceptance Hooks

- Scenarios 1 and 2 exercise acceptance criteria 6, 7, and 8: the new Python module exists, runs end-to-end, is bundled, and the extension exposes both the VS Code command and the MCP tool.
- Scenario 2 also exercises the JSON summary artifact behavior implied by acceptance criterion 6 (`writing a summary artifact under artifacts/claude-customizations/`).
- Scenario 3 exercises acceptance criteria 1 and 2: the absence of script references in the primary instruction surface and the requirement that every replacement points at an MCP tool registered with `drmCopilotExtension`. The informative failure mode is the user-visible consequence of those criteria.
- Scenario 4 exercises acceptance criteria 1, 4, and 5: zero script references in the agent's primary surface; `feature-promotion-lifecycle/SKILL.md` reframed as MCP-first; bare tool-name references normalized to fully-qualified MCP identifiers in `atomic-plan-contract/SKILL.md` and `policy-audit-template-usage/SKILL.md` (the latter two are referenced from the promotion workflow surface).
- The settings allow-list expansion implied by acceptance criterion 3 is what makes Scenarios 1, 3, and 4 actually executable in a base session of the source repository: without those entries, the orchestrator's wildcard would cover the calls but the base session would block them.

## Acceptance Criteria

- [ ] Zero local-script references remain in any `.claude/` markdown file (verified by repo-wide grep).
- [ ] Every replaced reference points at an MCP tool that exists in `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
- [ ] `.claude/settings.json` allow list includes the seven previously-missing MCP tools.
- [ ] `feature-promotion-lifecycle/SKILL.md` no longer references VS Code command IDs in its primary invocation surface; it references MCP tools and is reframed as "MCP-first".
- [ ] `atomic-plan-contract/SKILL.md` and `policy-audit-template-usage/SKILL.md` use fully-qualified MCP tool names throughout.
- [ ] `scripts/dev_tools/push_down_claude_customizations.py` exists and runs end-to-end against an in-memory destination workspace, copying every tracked `.claude/` file except `settings.local.json` and writing a summary artifact under `artifacts/claude-customizations/`.
- [ ] The new push-down script is bundled into the extension at `extensions/drm-copilot/resources/templates/`.
- [ ] The extension exposes `drmCopilotExtension.pushDownClaudeCustomizations` as a VS Code command and `mcp__drmCopilotExtension__push_down_claude_customizations` as an MCP tool.
- [ ] Parity unit tests exist for the new Python module mirroring those for the Codex/Agents variant.
- [ ] Parity unit tests exist for the new TypeScript MCP handler, service method, and command registration.
- [ ] Repository-wide line coverage remains >= 80 %; new modules reach >= 90 %.
- [ ] Toolchain passes in a single pass for both Python (Black -> Ruff -> Pyright -> Pytest) and TypeScript (Prettier -> ESLint -> TSC -> Jest).
- [ ] `.claude/skills/orchestrate/SKILL.md` is present in the pushed-down `.claude/skills/` tree.
- [ ] The orchestrate skill implements checkpoint resumption from `artifacts/orchestration/orchestrator-state.json`.
- [ ] The remediation loop in the orchestrate skill terminates after at most 3 full iterations, recording `step6_status: "blocked_remediation_loop_limit"` when the limit is reached without resolution.
- [ ] The PR creation gate in the orchestrate skill requires all four specified conditions to be simultaneously true before a PR is created.
- [ ] The canonical issue number is derived from the feature folder name and supplied in every `atomic-planner`, `atomic-executor`, and `feature-review` delegation prompt.
- [ ] Feature-review delegation prompts in the orchestrate skill contain none of the four categories of prohibited prompt language.


## Non-Goals

- Building a runtime rewrite catalog for `.claude/` content. Source-side cleanup in Part A removes the need.
- Rewriting `scripts/...` references in `.github/` content. Out of scope; handled by the existing Copilot push-down catalog.
- Modifying any file under `.claude/hooks/`. Audit confirms zero references.
- Adding any new MCP tool beyond `push_down_claude_customizations`. Audit confirms zero functional gaps in the existing 18-tool surface.
- The Claude plugin construction work explored prior to 2026-04-25. Abandoned after research confirmed no native mechanism for path-scoped standing instructions.
- Removing the `Bash(poetry run *)` allow-list entry from `.claude/settings.json`. Required by the local toolchain.
- Modifying frontmatter `allowed-tools` and `tools` arrays in skill files (other than the additive change to `.claude/settings.json` permissions).
- Removing script references from the explicitly-labeled fallback subsection in `feature-promotion-lifecycle/SKILL.md`. That subsection is the documented developer-only affordance for direct-source environments.

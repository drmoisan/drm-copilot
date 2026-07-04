# 2026-04-26-push-down-claude-customizations — Spec

- **Issue:** #162
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-26T13-49
- **Status:** Draft
- **Version:** 0.2

## Overview

The `.claude/` runtime surface (agents, skills, rules, hooks, settings) is project-scoped and lives only inside the repository that owns it. Other repositories that need the same orchestration runtime have no supported path to consume it. The Claude Code plugin system was investigated and rejected as the distribution channel: it has no native mechanism for shipping path-scoped standing instructions equivalent to `.claude/rules/*.md`.

The repository already operates two parallel one-way publishers — `push_down_copilot_customizations.py` for `.github/` content and `push_down_codex_and_agents_customizations.py` for `.codex/` and `.agents/` content. Both publish bundled customizations into a destination workspace via a parameterized engine. The `.claude/` tree has no equivalent publisher today.

A second concern compounds the distribution gap. Several `.claude/` markdown files reference local repository scripts (e.g., `poetry run python -m scripts.dev_tools.potential_to_issue`). Those scripts do not exist in destination workspaces, so any pushed copy of those files contains dead-link instructions. The Copilot publisher solves this with a runtime rewrite catalog. The user has rejected runtime rewriting in favor of source-side cleanup.


## Behavior

The feature delivers two parts in a single feature:

**Part A — Source cleanup of `.claude/` markdown files.** Replace every local-script reference in `.claude/` markdown files with a reference to the equivalent MCP tool exposed by the `drmCopilotExtension` MCP server. Audit confirms zero coverage gaps: all six distinct script references map to existing MCP tools. Three additional consistency passes are included by user direction:
- Convert VS Code command IDs in `feature-promotion-lifecycle/SKILL.md` lines 22–26 to the `mcp__drmCopilotExtension__*` MCP form, and rename the "extension-first" framing to "MCP-first" throughout that file.
- Add the seven currently-missing MCP tools to the `.claude/settings.json` permissions allow list so the rewritten content actually runs in the main session.
- Normalize bare tool-name references in `atomic-plan-contract/SKILL.md` and `policy-audit-template-usage/SKILL.md` to the fully-qualified `mcp__drmCopilotExtension__<name>` form.

**Part B — Push-down publisher for `.claude/`.** Add `scripts/dev_tools/push_down_claude_customizations.py` as a thin parity variant to `push_down_codex_and_agents_customizations.py`. The new script:
- Reuses the engine in `push_down_copilot_customizations.py` via the `root_folders=`, `artifact_directory=`, and `rewrite_references=` injection points.
- Sets `ROOT_FOLDERS = (Path(".claude"),)` to publish the entire `.claude/` tree.
- Excludes `.claude/settings.local.json` from the publication set (machine-local content).
- Uses a passthrough rewrite (no runtime rewriting; Part A removed the need).
- Writes summary artifacts to `artifacts/claude-customizations/push-down-{timestamp}.json`.
- Mirrors the Copilot precedent across all surfaces: bundled extension copy at `extensions/drm-copilot/resources/templates/`, MCP handler in `mcp-handlers/push-down-handlers.ts`, service method in `repo-automation-service.ts`, MCP tool definition wiring in `mcp-tool-definitions.ts`/`mcp-tool-inputs.ts`/`mcp-tools.ts`/`repo-automation-tool-names.ts`, VS Code command in `package.json` as `drmCopilotExtension.pushDownClaudeCustomizations`.

**Part C — Orchestrate skill.** The `.claude/skills/orchestrate/SKILL.md` skill is included in the push-down scope under Part B. The is lacking an appropriate completion check and remediation loop:

- **Before feature review** The orchestrator must stage all changes. Then run the `commit-message` skill to gather write an appropriate commit message. Then commit the work with the appropriate message. 
- **Completion requirements:** The orchestrator must not report completion until all required artifacts for the selected workflow path are present on disk, all validation gates have passed, and the checkpoint `next_step` reflects the completed state.
- **Post-review outcome evaluation:** After each feature-review delegation, remediation might be required. If so, the orchestrator will find a file with the naming convention `remediation-inputs.<timestamp>.md` in the active feature folder. If that artifact exists and if it contains one or more findings marked `BLOCKING` or `Severity: Blocking`, the remediation loop is entered. Zero blocking findings advance execution to the PR creation gate.
- **Remediation loop (R1–R5):** A bounded loop consisting of: R1 (remediation planning — delegate to `atomic-planner` to produce `remediation-plan.<timestamp>.md`), R2 (preflight clearance — delegate to `atomic-executor` for precondition validation only). If pre-flight clearance is not given, return to step R1 and delegate to `atomic-planner` with the required changes. Only after step R2 with the `atomic-executor` returns all the all clear, may the orchestrator proceed to R3 (remediation execution — delegate to `atomic-executor` with full authorization and mandatory per-task toolchain loop). Before proceeding to R4, the orchestrator must stage all changes. Then the orchestrator must run the `commit-message` skill to get the appropriate commit message and commit the files. Then orchestrator proceeds to R4 (re-audit — delegate to `feature-review` with the same inputs as the original review and no scope narrowing), and R5 (loop-exit decision — exit if re-audit produces zero blocking findings, otherwise increment `remediation_pass` and return to R1). The loop terminates after 3 full iterations without resolution. At that point the orchestrator records `step6_status: "blocked_remediation_loop_limit"` in the checkpoint and stops.
- **PR creation gate:** The orchestrator must not create a PR, push a branch for PR purposes, or report work complete until all four conditions are simultaneously true: (1) the most recent feature-review produced zero blocking findings (`blocking_findings_resolved: true`), (2) the AC verification artifact confirms all acceptance criteria pass, (3) the mandatory toolchain passed in its most recent run on the branch, and (4) the checkpoint `next_step` is `S8_create_pr`. This gate is non-negotiable.
- **Issue number consistency:** The canonical issue number is derived once from the active feature folder name (trailing integer — e.g., folder `2026-04-25-feature-55` yields issue number `55`) and recorded in the checkpoint as `issue_num`. Every delegation prompt to `atomic-planner`, `atomic-executor`, and `feature-review` must include the line: `Canonical issue number for this feature is <issue_num>. All artifact content, file paths, and cross-references must use this number.` Subagent artifacts referencing a different issue number are rejected, corrected, and the discrepancy recorded under `artifact_errors` in the checkpoint.
- **Prohibited prompt language for `feature-review` delegation:** The orchestrator must not: describe the review scope as "plan scope," "plan-scope only," or any equivalent narrowing; instruct the agent to skip, waive, or mark as "out of scope" or "not applicable" any toolchain step or coverage check for a language with changed files in the branch diff; assert that a language category is "not applicable" when that language has changed files; or imply that coverage is not required because the plan scope contains only documentation changes when the branch diff contains non-documentation changes. Scope determination is the subagent's responsibility.


## Inputs / Outputs

### Part A — Source cleanup

- **Inputs (files modified in place):**
  - `.claude/skills/feature-promotion-lifecycle/SKILL.md` — six script-reference bullets at lines 47, 48, 51, 57, 64, 70 (audit refs R1–R6); five VS Code command IDs at lines 22–26 (decision_5); the section heading and prose framed as "Extension-First" / "Canonical Fallback".
  - `.claude/skills/pr-base-branch-merge-base/SKILL.md` — frontmatter `description` field (line 3), prose reference (line 13), and command bullet (line 47) per audit refs R7–R9.
  - `.claude/skills/execute-hard-lock/SKILL.md` — single bullet at line 66 per audit ref R10.
  - `.claude/skills/atomic-plan-contract/SKILL.md` and `.claude/skills/policy-audit-template-usage/SKILL.md` — bare tool-name references in body prose (decision_7).
  - `.claude/settings.json` — `permissions.allow` array, additive expansion only (decision_6).
- **Outputs (post-state guarantees):**
  - Repository-wide grep for `poetry run python -m scripts`, `scripts/dev[_-]tools`, `scripts\.dev_tools`, and `${workspaceFolder}/scripts` returns zero hits within `.claude/**/*.md`.
  - Every newly-introduced MCP tool reference uses the fully-qualified identifier `mcp__drmCopilotExtension__<tool>` and resolves to a name present in `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
  - `.claude/settings.json` `permissions.allow` retains every existing entry (PoshQC tools, hard-lock prompt resolver, Bash patterns, Agent and Skill grants) and adds: `mcp__drmCopilotExtension__collect_pr_context`, `mcp__drmCopilotExtension__new_potential_entry`, `mcp__drmCopilotExtension__new_potential_bug_entry`, `mcp__drmCopilotExtension__potential_to_issue`, `mcp__drmCopilotExtension__new_active_feature_folder`, `mcp__drmCopilotExtension__validate_orchestration_artifacts`, `mcp__drmCopilotExtension__resolve_atomic_plan_prompt`.

### Part B — Python push-down CLI

- **CLI invocation:** `python -m scripts.dev_tools.push_down_claude_customizations --destination <path>`
- **CLI inputs:**
  - `--destination` (required): destination workspace root that receives the copied `.claude/` tree. Mirrors the parameter contract of `push_down_codex_and_agents_customizations.py:84-90`.
  - Implicit input: current working directory is treated as the source repository root, mirroring `push_down_codex_and_agents_customizations.main` at `scripts/dev_tools/push_down_codex_and_agents_customizations.py:103`.
- **CLI outputs:**
  - Stdout: a single line `Wrote push-down summary artifact to: <path>` matching the contract at `scripts/dev_tools/push_down_codex_and_agents_customizations.py:113` so the TypeScript layer's `stdoutArtifactPattern` regex (`/Wrote push-down summary artifact to:\s*(.+)/i`) parses without modification.
  - JSON artifact written to `<repo_root>/artifacts/claude-customizations/push-down-{timestamp}.json`. Schema matches `PushDownSummaryPayload` defined in `scripts/dev_tools/push_down_copilot_customizations.py:48-60` (fields: `repo_root`, `destination_root`, `started_at`, `finished_at`, `created_count`, `overwritten_count`, `rewritten_reference_count`, `placeholder_rewrite_count`, `unmatched_references`, `files`).
- **Process exit code:** `0` on success; non-zero on engine error. The engine raises specific exceptions (file system, IO); no broad catch is added.

### Part B — MCP tool

- **Tool name (canonical):** `push_down_claude_customizations` registered in `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
- **Fully-qualified MCP identifier:** `mcp__drmCopilotExtension__push_down_claude_customizations`.
- **Inputs (resolved by `resolvePushDownClaudeCustomizationsToolInput`):**
  - `workspaceRoot` (string, required): destination workspace path.
  - `invocationId` (string, optional): defaults to `"push_down_claude_customizations"`.
- **Outputs (`RepoAutomationExecutionResult`):**
  - `summary` (string): `"Pushed bundled Claude customizations into the destination workspace."` mirroring the wording pattern used in `repo-automation-service.ts:210` and `repo-automation-service.ts:227`.
  - `artifactPaths` (string[]): the JSON summary path parsed from stdout via `stdoutArtifactPattern`.
  - `tool` (string): `"push_down_claude_customizations"`.

### Part B — VS Code command

- **Command ID:** `drmCopilotExtension.pushDownClaudeCustomizations`.
- **Command title:** `drm-copilot: Push Down Claude Customizations`.
- **Command palette:** declared adjacent to the existing push-down commands at `extensions/drm-copilot/package.json:57-64`.

## API / CLI Surface

### Python CLI

```
python -m scripts.dev_tools.push_down_claude_customizations --destination /path/to/dest
```

Expected stdout (single line):

```
Wrote push-down summary artifact to: /path/to/repo/artifacts/claude-customizations/push-down-20260426T134900Z.json
```

### MCP tool

`tools/list` returns an entry whose `name` field is `push_down_claude_customizations` and whose `inputSchema` accepts `workspaceRoot` (required) and `invocationId` (optional). The schema mirrors the existing entries for `push_down_copilot_customizations` and `push_down_codex_and_agents_customizations` in `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`.

`tools/call` example:

```json
{
  "name": "push_down_claude_customizations",
  "arguments": { "workspaceRoot": "C:\\path\\to\\dest" }
}
```

### VS Code command

Invocable from the command palette as `drm-copilot: Push Down Claude Customizations` and exposed as the command ID `drmCopilotExtension.pushDownClaudeCustomizations`.

### Contracts and validation rules

- The `--destination` path must be resolvable via `resolve_cli_path`; non-existent destination roots are created by the engine.
- The MCP input resolver must reject inputs that lack a non-empty string `workspaceRoot`, matching the pattern in the existing push-down resolvers.
- The bundled script copy at `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py` must be byte-identical to the source under `scripts/dev_tools/`. This invariant matches the existing handling for the Copilot and Codex/Agents bundled copies.

## Data & State

- The push-down operation is one-way and idempotent within a single repository state: re-running with the same source and destination overwrites changed files and re-emits the JSON artifact with a new timestamp.
- No persistent state is maintained between invocations. Each run produces a self-contained artifact in `artifacts/claude-customizations/`.
- File classifications (`created` vs. `overwritten`) are computed per file by the engine in `push_down_copilot_customizations.py`. The new script does not extend the schema.
- No migration or backfill is required; destinations that already host a `.claude/` tree from a previous push-down receive an `overwritten_count > 0` and the same summary structure.
- The `rewrite_references` injection is a passthrough function returning `(text, 0, 0, [])`; the JSON artifact will therefore always report `rewritten_reference_count = 0`, `placeholder_rewrite_count = 0`, and `unmatched_references = []` for every file.

## Architecture

### Part A — File modifications

| Target | Change |
|---|---|
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | Rewrite the six script bullets (R1–R6) into MCP-tool invocation bullets per audit Section 3. Convert the five VS Code command IDs at lines 22–26 to MCP identifiers. Rename "Extension-First Execution Rule" to an "MCP-First Execution Rule" framing. Restructure the "Canonical Fallback Command Sequence" and "Canonical Fallback Short-Path Sequence" sections per the spec position in *Edge Cases*. |
| `.claude/skills/pr-base-branch-merge-base/SKILL.md` | Update the frontmatter `description` (R7), the prose reference (R8), and the invocation bullet (R9) to reference `mcp__drmCopilotExtension__collect_pr_context`. |
| `.claude/skills/execute-hard-lock/SKILL.md` | Remove the "Local task (development only):" bullet at line 66 (R10). The MCP-form bullet (line 64) and the VS Code command bullet (line 65) remain. |
| `.claude/skills/atomic-plan-contract/SKILL.md` | Replace bare tool-name references (e.g., `validate_orchestration_artifacts`, `resolve_atomic_plan_prompt`) with their fully-qualified `mcp__drmCopilotExtension__<name>` identifiers. |
| `.claude/skills/policy-audit-template-usage/SKILL.md` | Same normalization pass as `atomic-plan-contract/SKILL.md`. |
| `.claude/settings.json` | Append the seven entries listed in *Inputs / Outputs* to `permissions.allow`. No existing entries are removed or weakened. |

### Part B — Python module layout

`scripts/dev_tools/push_down_claude_customizations.py` follows the structure of `push_down_codex_and_agents_customizations.py` line-for-line with three substituted constants and a different exclusion rule:

- `ARTIFACT_DIRECTORY = "artifacts/claude-customizations"` (vs. `"artifacts/codex-and-agents-customizations"`).
- `MODULE_ENTRY_POINT = "scripts.dev_tools.push_down_claude_customizations"`.
- `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)` (vs. `(Path(".codex"), Path(".agents"))`).
- A passthrough `_passthrough_rewrite` mirroring the function defined at `scripts/dev_tools/push_down_codex_and_agents_customizations.py:44-49`.
- Delegation to `push_down_scoped_customizations(...)` with `root_folders=ROOT_FOLDERS`, `artifact_directory=ARTIFACT_DIRECTORY`, `rewrite_references=_passthrough_rewrite`.

The settings.local.json exclusion is implemented at the file-walk layer, not the rewrite layer. The engine's existing per-file classification path is reused; the new script supplies a file filter that drops `settings.local.json` from the iteration set produced by walking `Path(".claude")`. The chosen seam is the `source_root` walk performed inside the shared engine; this script implements the exclusion via the smallest seam consistent with the existing engine signature, which is to subclass or wrap `RealPushDownFileSystem` with a `walk` method that omits `settings.local.json` for `.claude/` roots. Choice of seam (filter at file-system enumeration vs. additional engine parameter) is a planner-level implementation detail; the contract is that the destination receives no `.claude/settings.local.json` file regardless of source presence.

### Part B — TypeScript module additions

| File | Addition |
|---|---|
| `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py` | Bundled byte-identical copy of the Python module. |
| `extensions/drm-copilot/src/mcp-handlers/push-down-handlers.ts` | Add `handlePushDownClaudeCustomizations(rawInput, service)` mirroring `handlePushDownCodexAndAgentsCustomizations` at lines 18–24. |
| `extensions/drm-copilot/src/repo-automation-service.ts` | Add `pushDownClaudeCustomizations(input: WorkspaceExecutionInput): Promise<RepoAutomationExecutionResult>` mirroring `pushDownCodexAndAgentsCustomizations` at line 214, with `bundledRelativePath: "resources/templates/push_down_claude_customizations.py"` and `summary: "Pushed bundled Claude customizations into the destination workspace."`. |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts` | Add `resolvePushDownClaudeCustomizationsToolInput` mirroring the existing `resolvePushDownCodexAndAgentsCustomizationsToolInput`. |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | Add the `push_down_claude_customizations` definition with the same input shape as the two existing push-down definitions. The authoritative export is `REPO_AUTOMATION_TOOL_DEFINITIONS` per audit Section 1.4. |
| `extensions/drm-copilot/src/mcp-tools.ts` | Wire the new tool name to the new handler. |
| `extensions/drm-copilot/src/repo-automation-tool-names.ts` | Add `"push_down_claude_customizations"` to the canonical name list. |
| `extensions/drm-copilot/package.json` | Add the command declaration block adjacent to lines 57–64 with `"command": "drmCopilotExtension.pushDownClaudeCustomizations"` and `"title": "drm-copilot: Push Down Claude Customizations"`. |

### Cross-reference normalization (decision_7)

The normalization pass in `atomic-plan-contract/SKILL.md` and `policy-audit-template-usage/SKILL.md` is a textual replacement scoped to MCP tool identifiers in body prose. Frontmatter `allowed-tools` and `tools` arrays are policy declarations, not invocation references, and are explicitly out of scope.

### Part C — Orchestrate skill file

| Target | Change |
|---|---|
| `.claude/skills/orchestrate/SKILL.md` | New file (or verified present): implements the deterministic orchestration workflow described in the Behavior section. Contains no local-script references and no VS Code command IDs; no Part A cleanup required. Pushed to destination workspaces as part of the full `.claude/` tree under Part B. The checkpoint path (`artifacts/orchestration/orchestrator-state.json`), subagent worker names (`atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`), and remediation-artifact naming convention (`remediation-inputs.<timestamp>.md`, `remediation-plan.<timestamp>.md`) are relative to the active repository root and resolve identically in destination workspaces. |

## Edge Cases

### settings.local.json exclusion

`.claude/settings.local.json` is machine-local and must never be published. The publisher excludes it at the file-walk layer, not via post-copy deletion. Tests must verify the destination tree contains no `settings.local.json` even if one exists in the source.

### `feature-promotion-lifecycle/SKILL.md` fallback section — spec position

The audit identifies two structural options for the "Canonical Fallback Command Sequence" sections (audit Section 5.2). This spec adopts a hybrid of audit Option B with explicit fallback retention:

- The primary "Extension-First Execution Rule" section (lines 18–30) is renamed "MCP-First Execution Rule". Each VS Code command ID at lines 22–26 is replaced with the corresponding `mcp__drmCopilotExtension__*` identifier. The "extension-first" wording is replaced with "MCP-first" throughout.
- The two "Canonical Fallback ..." sections retain their script bullets, but they are placed under a new explicit subheading: `### Fallback only — when MCP server is unreachable`. The introductory paragraph is rewritten to state that the MCP form is authoritative and that the script form is documented only for environments where the MCP server is unavailable.
- The script bullets in the fallback section continue to reference `scripts/dev_tools/...` paths because they document the on-repository fallback for developers running the source repository directly. They remain valid in the source repository. They are not pushed to destinations because the destination repository does not contain those scripts; the script bullets correctly become unreachable there, which is the intended fallback semantic.

This position satisfies acceptance criterion 1 (zero local-script references in destination behavior) by reframing the fallback as an explicit "source-repo only" affordance. It also preserves the documented script fallback for direct-source developers, which the issue identifies as a design constraint at issue.md lines 53–54.

Note: this position implies that the post-cleanup grep for `scripts/dev_tools` patterns will return non-zero hits in the explicit fallback section. The acceptance criterion is interpreted as "no references in the agent's primary instruction surface"; the explicitly-labeled fallback subsection is excluded from the grep. The plan must encode this exclusion as a documented filter, not a silent omission.

### Frontmatter `allowed-tools` and `tools` fields

These fields are policy declarations consumed by the agent runtime; they are not invocation references the agent renders to the user. They are out of scope for the cleanup. No frontmatter `allowed-tools` or `tools` entry is modified by Part A.

### Hook scripts

Audit Section 5.3 confirms zero `scripts/dev_tools` references across `.claude/hooks/*.ps1`. Hook scripts are out of scope for Part A.

### `Bash(poetry run *)` allow entry

`.claude/settings.json:8` allows `Bash(poetry run *)`. Since the broader test harness and direct toolchain commands continue to use `poetry run`, this entry is preserved. Removal is out of scope.

### MCP tool prerequisite at destination

The MCP form is functional only when the destination's Claude Code session has the `drmCopilotExtension` MCP server connected. This is documented as a prerequisite, not a defect (issue.md lines 55). Spec inherits this position; no additional warning surface is added.

## Constraints & Risks

- The `.claude/skills/feature-promotion-lifecycle/SKILL.md` "Canonical Fallback Command Sequence" deliberately documents direct script invocation as a fallback for hosts without extension/MCP access. The spec position above retains this affordance under an explicit subheading.
- The MCP tool names are exposed as `mcp__drmCopilotExtension__<tool-name>` only when the consuming Claude session has the extension's MCP server connected. Destination workspaces that do not run VS Code with the extension installed cannot use the rewritten content. This is a documented prerequisite, not a defect.
- Renaming "extension-first" to "MCP-first" in `feature-promotion-lifecycle/SKILL.md` may invalidate references from other skills or rules that quote the old framing. The plan must include a repo-wide audit of cross-references.
- The `.claude/settings.json` allow list change is a permission expansion. The plan must verify no allow-list entries get dropped and no overly-broad pattern is introduced.

### Additional risks specific to Part B

- The shared engine in `push_down_copilot_customizations.py` was authored against the `.github/` and `.codex`/`.agents` trees. Re-targeting at `.claude/` exposes a much larger directory surface (skills, agents, hooks, rules, settings, commands). Engine reuse is asserted by the audit and by parity with `push_down_codex_and_agents_customizations.py`; nevertheless, end-to-end integration tests against an in-memory destination are required to detect any path-handling assumptions.
- The bundled extension copy at `extensions/drm-copilot/resources/templates/` must remain byte-identical to the source. A pre-existing build or copy mechanism handles the Copilot and Codex/Agents bundled scripts; the new bundle must use the same mechanism. A drift-detection test should compare bundled and source bytes.

## Implementation Strategy

- **Implementation scope:** Part A and Part B as defined above. Both parts are required for the feature to satisfy its acceptance criteria.
- **New Python module:** `scripts/dev_tools/push_down_claude_customizations.py` (target file size well under the 500-line cap; the parity precedent is 118 lines).
- **New TypeScript additions:** the seven file additions enumerated under *Architecture — Part B — TypeScript module additions*.
- **New VS Code command:** `drmCopilotExtension.pushDownClaudeCustomizations`.
- **Dependency changes:** none. The new Python module reuses existing engine modules. The new TypeScript surfaces reuse existing types and helpers.
- **Logging/telemetry:** none added beyond the stdout summary line; matches the silent operation of the two existing push-down publishers.
- **Rollout plan:** no feature flag needed. The new MCP tool and command are additive. Source-cleanup changes in Part A are additive consistency improvements that do not regress existing instruction surfaces.

## Test Strategy

### Python (mirroring `tests/dev_tools/test_push_down_codex_and_agents_customizations.py` parity)

- Passthrough rewrite returns the input text unchanged with zero counters and an empty unmatched-references list.
- `ROOT_FOLDERS` is `(Path(".claude"),)`.
- `ARTIFACT_DIRECTORY` is `"artifacts/claude-customizations"`.
- End-to-end run against an in-memory `PushDownFileSystem` double:
  - Populates a synthetic `.claude/` tree containing a representative file and a `settings.local.json`.
  - Asserts the destination receives every file except `settings.local.json`.
  - Asserts the JSON summary artifact is written under `artifacts/claude-customizations/push-down-{timestamp}.json`.
  - Asserts the `rewritten_reference_count`, `placeholder_rewrite_count`, and `unmatched_references` fields are `0`, `0`, `[]` for every file.
- CLI invocation:
  - `parse_args(["--destination", "/tmp/dest"])` returns a namespace with `destination == "/tmp/dest"`.
  - `main(["--destination", "/tmp/dest"], repo_root=tmp, fs=fake)` returns `0` and prints the expected summary line.
- The exclusion behavior is covered by a dedicated test that places `.claude/settings.local.json` in the source double and verifies it is absent in the destination double after the run.

### TypeScript (mirroring existing push-down handler tests)

- `resolvePushDownClaudeCustomizationsToolInput` accepts a valid input and rejects malformed inputs (missing `workspaceRoot`, non-string fields).
- `handlePushDownClaudeCustomizations` calls `service.pushDownClaudeCustomizations` exactly once with the resolved input.
- `RepoAutomationService.pushDownClaudeCustomizations` invokes `executeScript` with `tool: "push_down_claude_customizations"`, `runtimeKind: "python"`, the bundled relative path, and the expected `--destination` argv.
- The MCP tool registration test confirms `tools/list` includes `push_down_claude_customizations` with the expected input schema.
- The VS Code command registration test confirms `drmCopilotExtension.pushDownClaudeCustomizations` is registered and resolves to the service method.

### Coverage

- Repository-wide line coverage remains >= 80%.
- The new Python module and the new TypeScript handler/service method/input resolver each reach >= 90% coverage.
- Coverage on existing lines must not regress.

### Orchestrate skill push-down (Part C)

- The end-to-end push-down test confirms that `orchestrate/SKILL.md` is present in the destination tree after a run against an in-memory `.claude/` source that includes the skill under `skills/orchestrate/`.
- The `orchestrate/SKILL.md` content is verified to contain zero local-script references and zero VS Code command IDs in its primary invocation surface.

## Out of Scope

The following items are explicitly excluded from this feature:

1. Building or maintaining a runtime rewrite catalog for `.claude/` content. Rejected by the user; replaced by source-side cleanup (Part A).
2. Rewriting `scripts/...` references in `.github/` content. The Copilot push-down already handles its own surface via `push_down_copilot_customizations_rewrites.py`; that catalog is unchanged by this feature.
3. Modifying any file under `.claude/hooks/`. The audit confirms zero references, and the hook contract is enforced runtime-side, not instruction-side.
4. Adding any new MCP tools to the `drmCopilotExtension` server beyond `push_down_claude_customizations`. The audit confirms zero functional gaps in the existing 18-tool surface.
5. The previously-explored Claude plugin construction work. That objective was abandoned 2026-04-25 after research confirmed no native plugin mechanism for path-scoped standing instructions; see `artifacts/orchestration/orchestrator-state.json:3`.
6. Removal of the `Bash(poetry run *)` allow-list entry from `.claude/settings.json`. The toolchain (Black, Ruff, Pyright, Pytest) continues to require it.
7. Modification of frontmatter `allowed-tools` and `tools` arrays in any `.claude/skills/*` file beyond what is required for decision_6's allow-list expansion in `settings.json`.
8. Any change to the source-repository fallback subsection introduced under the "Fallback only — when MCP server is unreachable" subheading; that section deliberately retains script references for direct-source developers.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Destination workspace lacks the `drmCopilotExtension` MCP server, making MCP-form instructions unreachable. | Documented as a prerequisite in `feature-promotion-lifecycle/SKILL.md`. The fallback subsection in that file documents the on-repository script form for developers without the extension. |
| Renaming "extension-first" to "MCP-first" invalidates cross-references in other skill files. | Plan must include a repo-wide grep for `extension-first`, `Extension-First`, `Canonical Fallback`, and the affected anchor IDs. Each match is updated to the new framing in the same change set. |
| `.claude/settings.json` allow-list expansion accidentally drops or weakens an existing entry. | Tests must assert the post-state allow list is a strict superset of the pre-state allow list. The change set includes the seven net-new entries only; no existing entry is removed. |
| Engine reuse against the larger `.claude/` tree exposes path-handling assumptions not exercised by `.github/`, `.codex/`, or `.agents/`. | End-to-end integration test populates a representative `.claude/` tree (including subdirectories under `agents/`, `hooks/`, `rules/`, `skills/`, `commands/`) and verifies a complete copy with the correct exclusion. |
| Bundled extension copy of `push_down_claude_customizations.py` drifts from the source. | A drift-detection test compares the source bytes at `scripts/dev_tools/push_down_claude_customizations.py` against the bundled copy at `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`. |
| Acceptance criterion "Zero local-script references" is misinterpreted as covering the explicit fallback subsection. | Spec explicitly defines the criterion as "zero references in the primary instruction surface, with the explicit `### Fallback only` subsection excluded from the grep". The plan encodes the exclusion as a documented filter. |

## Acceptance Criteria

- [x] Zero local-script references remain in any `.claude/` markdown file (verified by repo-wide grep).
- [x] Every replaced reference points at an MCP tool that exists in `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
- [x] `.claude/settings.json` allow list includes the seven previously-missing MCP tools.
- [x] `feature-promotion-lifecycle/SKILL.md` no longer references VS Code command IDs in its primary invocation surface; it references MCP tools and is reframed as "MCP-first".
- [x] `atomic-plan-contract/SKILL.md` and `policy-audit-template-usage/SKILL.md` use fully-qualified MCP tool names throughout.
- [x] `scripts/dev_tools/push_down_claude_customizations.py` exists and runs end-to-end against an in-memory destination workspace, copying every tracked `.claude/` file except `settings.local.json` and writing a summary artifact under `artifacts/claude-customizations/`.
- [x] The new push-down script is bundled into the extension at `extensions/drm-copilot/resources/templates/`.
- [x] The extension exposes `drmCopilotExtension.pushDownClaudeCustomizations` as a VS Code command and `mcp__drmCopilotExtension__push_down_claude_customizations` as an MCP tool.
- [x] Parity unit tests exist for the new Python module mirroring those for the Codex/Agents variant.
- [x] Parity unit tests exist for the new TypeScript MCP handler, service method, and command registration.
- [x] Repository-wide line coverage remains >= 80 %; new modules reach >= 90 %.
- [x] Toolchain passes in a single pass for both Python (Black -> Ruff -> Pyright -> Pytest) and TypeScript (Prettier -> ESLint -> TSC -> Jest).
- [x] `.claude/skills/orchestrate/SKILL.md` is present in the `.claude/skills/` tree and is included in the push-down output.
- [x] The orchestrate skill implements checkpoint resumption from `artifacts/orchestration/orchestrator-state.json`.
- [x] The orchestrate skill's remediation loop terminates after at most 3 full iterations and records `step6_status: "blocked_remediation_loop_limit"` when the limit is reached.
- [x] The orchestrate skill's PR creation gate requires all four specified conditions to be simultaneously true before proceeding to PR creation.
- [x] Every delegation prompt emitted by the orchestrate skill includes the canonical issue number derived from the active feature folder name.
- [x] The orchestrate skill's feature-review delegation contains none of the four categories of prohibited prompt language.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: Python push-down engine reuse with `.claude/` ROOT_FOLDERS; passthrough rewrite injection; settings.local.json exclusion; summary artifact path generation.
- [ ] Integration scenarios: end-to-end push-down into a temporary destination directory using the in-memory filesystem double; MCP tool registration verification; VS Code command registration verification.
- [ ] CLI/API examples: `python -m scripts.dev_tools.push_down_claude_customizations --destination /tmp/dest`; MCP `tools/list` returns `push_down_claude_customizations`; VS Code command palette shows "drm-copilot: Push Down Claude Customizations".
- [ ] Cross-reference verification: grep `.claude/` for residual local-script patterns post-cleanup; grep for bare tool-name references; grep for VS Code command IDs in skill content that should now be MCP form.

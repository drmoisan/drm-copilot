# push-down-claude-customizations (Issue #162)

- Date captured: 2026-04-26
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/push-down-claude-customizations/ (Issue #162)

- Issue: #162
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/162
- Last Updated: 2026-04-26
- Work Mode: full-feature

## Problem / Why

The `.claude/` runtime surface (agents, skills, rules, hooks, settings) is project-scoped and lives only inside the repository that owns it. Other repositories that need the same orchestration runtime have no supported path to consume it. The Claude Code plugin system was investigated and rejected as the distribution channel: it has no native mechanism for shipping path-scoped standing instructions equivalent to `.claude/rules/*.md`.

The repository already operates two parallel one-way publishers — `push_down_copilot_customizations.py` for `.github/` content and `push_down_codex_and_agents_customizations.py` for `.codex/` and `.agents/` content. Both publish bundled customizations into a destination workspace via a parameterized engine. The `.claude/` tree has no equivalent publisher today.

A second concern compounds the distribution gap. Several `.claude/` markdown files reference local repository scripts (e.g., `poetry run python -m scripts.dev_tools.potential_to_issue`). Those scripts do not exist in destination workspaces, so any pushed copy of those files contains dead-link instructions. The Copilot publisher solves this with a runtime rewrite catalog. The user has rejected runtime rewriting in favor of source-side cleanup.

## Proposed Behavior

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

## Acceptance Criteria (early draft)

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

## Constraints & Risks

- The `.claude/skills/feature-promotion-lifecycle/SKILL.md` "Canonical Fallback Command Sequence" deliberately documents direct script invocation as a fallback for hosts without extension/MCP access. Removing those references entirely would lose the fallback affordance. The plan must decide whether to keep the fallback as documented exceptions or to drop the section.
- The MCP tool names are exposed as `mcp__drmCopilotExtension__<tool-name>` only when the consuming Claude session has the extension's MCP server connected. Destination workspaces that do not run VS Code with the extension installed cannot use the rewritten content. This is a documented prerequisite, not a defect.
- Renaming "extension-first" to "MCP-first" in `feature-promotion-lifecycle/SKILL.md` may invalidate references from other skills or rules that quote the old framing. The plan must include a repo-wide audit of cross-references.
- The `.claude/settings.json` allow list change is a permission expansion. The plan must verify no allow-list entries get dropped and no overly-broad pattern is introduced.

## Test Conditions to Consider

- [ ] Unit coverage areas: Python push-down engine reuse with `.claude/` ROOT_FOLDERS; passthrough rewrite injection; settings.local.json exclusion; summary artifact path generation.
- [ ] Integration scenarios: end-to-end push-down into a temporary destination directory using the in-memory filesystem double; MCP tool registration verification; VS Code command registration verification.
- [ ] CLI/API examples: `python -m scripts.dev_tools.push_down_claude_customizations --destination /tmp/dest`; MCP `tools/list` returns `push_down_claude_customizations`; VS Code command palette shows "drm-copilot: Push Down Claude Customizations".
- [ ] Cross-reference verification: grep `.claude/` for residual local-script patterns post-cleanup; grep for bare tool-name references; grep for VS Code command IDs in skill content that should now be MCP form.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/push-down-claude-customizations/` folder from the template
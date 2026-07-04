<!-- markdownlint-disable-file -->

# Task Research Notes: codex-native-converter

## Research Executed

### File Analysis

- `docs/features/active/2026-04-26-codex-native-converter-164/issue.md`
  - Current issue is marked `minor-audit`, but the requested converter scope already names multiple ecosystems, dry-run and apply modes, mapping catalogs, strict hard gates, and end-to-end fixtures.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/README.md`
  - Repository-local Codex guidance defines `.agents/skills` as the canonical reusable workflow surface and `.codex/agents` plus `.codex/prompts` as the current agent and launcher surfaces.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/repo-automation-adapter/SKILL.md`
  - Host-specific automation is intentionally centralized behind semantic MCP usage through `drmCopilotExtension`, with fail-closed behavior when no safe MCP or deterministic fallback exists.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/repo-automation-adapter/agents/openai.yaml`
  - Repo-local Codex skills declare MCP dependencies in `agents/openai.yaml`; the canonical dependency name in this repo is `drmCopilotExtension`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`
  - Current Codex agent files are TOML custom-agent manifests with `name`, `description`, and `developer_instructions`; repository-specific hard gates are expressed inside instructions, not via a separate native handoff schema.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/prompts/orchestrate-work.md`
  - The repository currently treats `.codex/prompts/*.md` as launch surfaces, but this pattern is repo-observed rather than externally verified from the latest Codex product docs.
- `.github/agents/orchestrator.agent.md`
  - GitHub Copilot agents combine persona, handoffs, workflow routing, and enforcement language inside one Markdown manifest.
- `.github/prompts/orchestrate-work.prompt.md`
  - GitHub prompt files are dedicated launcher assets with explicit runtime directions and no direct Codex-equivalent schema in the latest official docs.
- `.github/skills/feature-promotion-lifecycle/SKILL.md`
  - GitHub skills already encode MCP-first lifecycle behavior and work-mode semantics, which provides direct mapping clues for Codex skills.
- `CLAUDE.md`
  - Claude uses a standing-instructions file as a persistent, repo-wide runtime surface separate from `.claude/skills`, `.claude/agents`, `.claude/rules`, `.claude/hooks`, and `.claude/settings.json`.
- `.claude/agents/orchestrator.md`
  - Claude subagents are Markdown manifests with frontmatter for tools, skills, memory, and hooks, plus a thin body.
- `.claude/skills/orchestrate/SKILL.md`
  - Claude uses skills as reusable workflows and relies on the main thread for orchestration.
- `.claude/rules/general-code-change.md`
  - Claude `rules` are Markdown instruction files, not shell-execution approval rules.
- `.claude/settings.json`
  - Claude hard gates are enforced through `permissions.allow/deny` plus `PreToolUse` and `SubagentStop` hooks.
- `.claude/skills/translate-copilot-to-claude/SKILL.md`
  - The existing Copilot→Claude translation design already uses deterministic classification, plan artifacts, conflict reporting, and apply-vs-plan mode separation.
- `scripts/dev_tools/push_down_codex_and_agents_customizations.py`
  - Existing Codex publisher pattern is a Python engine with deterministic root-folder enumeration, dedicated artifact directory, and a summary object.
- `extensions/drm-copilot/src/repo-automation-service.ts`
  - Analogous Codex-specific features are exposed through shared repo automation service methods, bundled scripts, extension commands, and semantic MCP tools.
- `extensions/drm-copilot/src/mcp-tool-definitions.ts`
  - Semantic MCP tools in this repo use explicit JSON schemas and are the preferred automation surface when a deterministic operation exists.
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
  - Tool inputs are normalized and validated centrally before execution, which is the current TypeScript pattern for hard input validation.
- `extensions/drm-copilot/src/mcp-handlers/push-down-handlers.ts`
  - MCP handlers are intentionally thin wrappers over validated tool inputs and shared service methods.
- `docs/features/archive/2026-04-05-push-down-codex-agents-customizations-124/spec.md`
  - The closest existing Codex-facing feature used a Python engine, bundled resource payloads, extension wiring, MCP exposure, JSON summary artifacts, and mirrored test coverage across Python and TypeScript.

### Code Search Results

- `drmCopilotExtension|mcp`
  - Repo-local Codex skills repeatedly require semantic MCP usage, central adapter routing, and `validate_orchestration_artifacts` fail-closed checks.
- `push_down_codex_and_agents_customizations`
  - Existing TypeScript wiring spans `extension.ts`, `repo-automation-service.ts`, `mcp-tools.ts`, `mcp-tool-definitions.ts`, `mcp-tool-inputs.ts`, `mcp-handlers/push-down-handlers.ts`, extension tests, and Python publisher tests.
- `translate-copilot-to-claude`
  - Existing translation work is skill-only today; no Python or TypeScript converter engine exists yet for a Codex-native import path.
- `.github/**/*.instructions.md`
  - GitHub instruction files are a major source artifact class that currently has no 1:1 Codex-native file surface.
- `.github/**/*.prompt.md`
  - GitHub prompt files include orchestration, review, hard-lock, and research launchers that will require decomposition or repo-local prompt targeting.
- `.github/**/*.agent.md`
  - GitHub agent files mix multiple concerns in one file and therefore need deterministic splitting during conversion.
- `.claude/**`
  - Claude runtime content spans `CLAUDE.md`, `.claude/agents`, `.claude/skills`, `.claude/rules`, `.claude/hooks`, and `.claude/settings.json`, which means converter output cannot be a naive 1:1 file rename.
- `.codex/prompts`
  - Observed only in repository-local Codex payloads; not found in the upstream `openai/codex` text search used here.

### External Research

- `#githubRepo:"openai/codex hooks PreToolUse PermissionRequest Stop"`
  - Upstream Codex repository contains generated hook schemas and runtime code for `PreToolUse`, `PermissionRequest`, `PostToolUse`, `SessionStart`, `UserPromptSubmit`, and `Stop`, confirming those are real native hook events rather than repository invention.
- `#fetch:https://developers.openai.com/codex/`
  - Official Codex overview links to native docs for Rules, Hooks, AGENTS.md, MCP, Skills, Subagents, Authentication, Agent approvals & security, and configuration surfaces.
- `#fetch:https://developers.openai.com/codex/guides/agents-md`
  - Official instruction discovery is based on layered `AGENTS.md` and `AGENTS.override.md` files, merged from Codex home and the project root down to the current directory.
- `#fetch:https://developers.openai.com/codex/skills`
  - Skills are officially stored under `.agents/skills`, use `SKILL.md`, may include `agents/openai.yaml`, and are the native reusable-workflow surface.
- `#fetch:https://developers.openai.com/codex/subagents`
  - Custom subagents are officially stored under `.codex/agents/*.toml` and support required keys `name`, `description`, and `developer_instructions`, with optional `model`, `sandbox_mode`, `mcp_servers`, and `skills.config`.
- `#fetch:https://developers.openai.com/codex/hooks`
  - Official hooks live in `.codex/hooks.json` or inline `[hooks]` in `.codex/config.toml`; hook events are deterministic and can deny or continue execution depending on event type.
- `#fetch:https://developers.openai.com/codex/rules`
  - Official Codex `.rules` files are Starlark execution-policy rules for shell approval decisions (`allow`, `prompt`, `forbidden`), not general coding-style or path-scoped instruction files.
- `#fetch:https://developers.openai.com/codex/agent-approvals-security`
  - Strict native enforcement layers are sandbox mode, approval policy, protected paths, optional auto-review, rules, and hooks; `.agents` and `.codex` are protected read-only paths in default writable roots.
- `#fetch:https://developers.openai.com/codex/mcp`
  - MCP servers are configured in `.codex/config.toml` with `[mcp_servers.<name>]`, support `required = true`, tool allowlists and deny lists, and are shared between CLI and IDE extension.
- `#fetch:https://developers.openai.com/codex/prompting`
  - Official Codex docs describe prompts as user messages and thread interactions, but do not document a prompt-file runtime surface like `.codex/prompts`.

### Project Conventions

- Standards referenced: repo-local Codex layering, shared repo-automation service wiring, MCP-first automation, deterministic artifact output, centralized tool-input validation, and anti-duplication skill guidance.
- Instructions followed: `policy-compliance-order` skill, repository tone policy, research-only constraint, and the repository guidance embedded in `issue.md`, Codex payload README, Claude standing instructions, and archived Codex publisher spec.

## Key Discoveries

### Project Structure

The latest verified Codex product/runtime taxonomy is broader than this repository’s current observable Codex payload. Official Codex supports these native building blocks:

- layered persistent instructions via `AGENTS.md` and `AGENTS.override.md`
- reusable workflows via `.agents/skills/<name>/SKILL.md`
- custom subagents via `.codex/agents/<name>.toml`
- agent/runtime configuration via `.codex/config.toml`
- enforcement hooks via `.codex/hooks.json` or inline `[hooks]` in `.codex/config.toml`
- execution-policy `.rules` files under a `rules/` folder next to an active Codex config layer
- MCP server configuration under `[mcp_servers.<name>]`

Repository evidence adds one more surface:

- `.codex/prompts/*.md` is currently used in the bundled Codex payload as a launcher surface for this repository.

That prompt-file surface is **verified as repository-local structure** but **not verified as an official Codex product taxonomy element** from the fetched docs. It should therefore be treated as a repository convention, not as portable native Codex behavior.

The repository also currently stores Codex-native assets primarily in the bundled extension payload at `extensions/drm-copilot/resources/codex-and-agents-customizations/`, not in a checked-in top-level `.codex/` + `.agents/` runtime root for day-to-day development.

### Implementation Patterns

The strongest repository-backed Codex pattern is decomposition rather than literal mirroring:

- reusable workflow logic is authored once in `.agents/skills`
- agent TOML files stay thin and point to shared skills through `developer_instructions`
- host-specific repo automation is isolated in `repo-automation-adapter`
- semantic MCP tools are preferred over raw command IDs
- bundled publisher features use a Python engine, a bundled wrapper, TypeScript command/MCP exposure, and JSON summary artifacts

This matters for conversion because GitHub Copilot and Claude both store multiple concerns inside single artifacts:

- GitHub agent files combine identity, hard gates, routing, and handoffs.
- GitHub instruction files act as persistent path-scoped guidance, which Codex does not natively represent with a directly equivalent Markdown rules surface.
- Claude settings combine permissions and hook registration; Claude rules are Markdown instruction files, while Codex rules are shell execution policies.

The deterministic Codex target is therefore a **classification-and-split** process, not a file-extension rewrite.

### Complete Examples

```toml
name = "reviewer"
description = "PR reviewer focused on correctness, security, and missing tests."
model = "gpt-5.4"
sandbox_mode = "read-only"
developer_instructions = """
Review code like an owner.
Prioritize correctness, security, behavior regressions, and missing test coverage.
"""

[mcp_servers.openaiDeveloperDocs]
url = "https://developers.openai.com/mcp"
```

### API and Schema Documentation

- **AGENTS.md discovery**
  - Official precedence is Codex home (`AGENTS.override.md` then `AGENTS.md`) followed by project-root-to-CWD layering, with later files overriding earlier guidance.
- **Skills**
  - Required: `name`, `description`, and `SKILL.md`.
  - Optional: `scripts/`, `references/`, `assets/`, and `agents/openai.yaml`.
- **Custom agents**
  - Required TOML keys: `name`, `description`, `developer_instructions`.
  - Optional keys include `model`, `model_reasoning_effort`, `sandbox_mode`, `mcp_servers`, and `skills.config`.
- **Hooks**
  - Supported events: `SessionStart`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `UserPromptSubmit`, `Stop`.
  - Native hook storage: `.codex/hooks.json` or inline `[hooks]` in `.codex/config.toml`.
- **Rules**
  - Native Codex rules are Starlark `prefix_rule()` definitions for shell approval policy only.
- **MCP**
  - Project-scoped MCP servers live in `.codex/config.toml`.
  - Important native enforcement knobs include `required`, `enabled_tools`, `disabled_tools`, `startup_timeout_sec`, and `tool_timeout_sec`.
- **Unsupported as a verified official Codex schema in this research**
  - `.codex/prompts/*.md` as a product-documented runtime surface.
  - A first-class native manifest field for GitHub-style `handoffs:` blocks.
  - A first-class native path-scoped Markdown instruction file equivalent to GitHub `.instructions.md` or Claude `.claude/rules/*.md`.

### Configuration Examples

```toml
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[features]
codex_hooks = true

[[hooks.PermissionRequest]]
matcher = "^mcp__drmCopilotExtension__.*$"

[[hooks.PermissionRequest.hooks]]
type = "command"
command = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/permission-request.ps1"'
timeout = 30

[mcp_servers.drmCopilotExtension]
command = "node"
args = ["extensions/drm-copilot/esbuild-mcp-server.cjs"]
required = true
enabled_tools = ["collect_pr_context", "validate_orchestration_artifacts"]
```

### Technical Requirements

- The converter must classify source artifacts into **direct**, **decomposed**, **repo-convention**, or **unsupported** mappings.
- Hard gates must use the strictest native Codex surface that actually enforces behavior:
  - shell escape control -> `.codex/rules/*.rules` plus approval policy
  - tool-call approval and side-effect approval -> `PermissionRequest` hooks
  - pre-execution tool blocking -> `PreToolUse` hooks where supported
  - end-of-turn completion blocking -> `Stop` hooks
  - missing required external automation -> `[mcp_servers.<name>].required = true`
  - repo-wide behavioral guidance -> `AGENTS.md` and agent `developer_instructions`
- MCP-only repo automation should target semantic tool names, not host command IDs, and should fail closed when no supported semantic tool mapping exists.
- Dry-run mode should generate a plan, machine-readable mapping catalog, validation results, and a proposed tree without mutating the destination runtime.
- Apply mode should require a destination root and should write only Codex-native outputs plus the same report artifacts.

**Mandatory unachievable objective callout**:
- **A completely lossless, one-file-to-one-file translation from GitHub Copilot or Claude into Codex is not achievable.** Verified rationale: Codex does not expose an official path-scoped Markdown instruction-file surface equivalent to `.github/instructions/*.instructions.md` or `.claude/rules/*.md`, and the latest fetched docs do not document `.codex/prompts` as a portable official runtime surface. Several source artifacts therefore require decomposition across `AGENTS.md`, skills, custom agents, hooks, rules, and MCP config rather than direct mirroring.

## Recommended Approach

Use a **deterministic Python converter engine with explicit mapping catalogs and fail-closed validation**, then optionally expose it through the existing extension/MCP repo-automation layer after the engine contract is stable.

Selected design:

1. **Classifier-first engine** in `scripts/dev_tools/` that accepts one or more source paths or a source root plus explicit source ecosystem (`github-copilot` or `claude`).
2. **Strict target taxonomy**:
   - persistent repo guidance -> `AGENTS.md`
   - reusable workflows -> `.agents/skills/**`
   - custom agents -> `.codex/agents/*.toml`
   - command-approval rules -> `.codex/rules/*.rules`
   - hook scripts + registration -> `.codex/hooks/*` plus `.codex/hooks.json` or inline config
   - MCP config updates -> `.codex/config.toml`
   - prompt launchers -> `.codex/prompts/*.md` **only as a repository convention**, not as a generic product mapping
3. **Mapping catalog output** that records `source_path`, `artifact_kind`, `classification`, `target_surface`, `target_path`, `mapping_kind`, `validation_status`, and `notes`.
4. **Hard-failure policy** for unsupported mappings, missing MCP rewrites, mixed-concern artifacts that cannot be decomposed safely, or outputs that still reference non-Codex runtime surfaces.
5. **Review/apply split**:
   - review mode writes only artifacts under `artifacts/codex-native-converter/<timestamp>/`
   - apply mode writes Codex-native outputs into an explicit destination root and also writes the same artifact set
6. **MCP-first rewrite catalog** owned separately from the classifier so host-specific command references are normalized toward semantic `drmCopilotExtension` tools or reported unsupported.

Rejected alternatives summary:

- **Literal file mirroring** was rejected because official Codex surfaces do not match GitHub/Claude one-to-one.
- **Skill-only conversion** was rejected because skills alone cannot reproduce strict hard-gate behavior.
- **Prompt-only conversion into `.codex/prompts`** was rejected as the primary strategy because that surface is repository-observed, not officially documented.

## Implementation Guidance

- **Objectives**: build a converter that imports supported GitHub Copilot and Claude artifact sets into Codex-native outputs only, enforces fail-closed rewrites, and supports both review and apply modes.
- **Key Tasks**:
  - define artifact taxonomy and source classifier
  - define mapping catalog schema and validation rules
  - implement rewrite catalog for host/MCP translations
  - implement dry-run artifact emission and apply-mode destination writes
  - add extension/MCP exposure only after the engine contract is stable
  - add fixtures for representative GitHub and Claude source trees plus unsupported cases
- **Dependencies**:
  - repository Python dev-tool pattern for conversion engine and artifacts
  - TypeScript repo-automation service and MCP tool wiring if command exposure is added
  - bundled Codex payload conventions under `extensions/drm-copilot/resources/codex-and-agents-customizations/`
  - semantic MCP server `drmCopilotExtension`
- **Success Criteria**:
  - dry-run report identifies every examined source artifact and deterministic target classification
  - unsupported or lossy mappings are explicit and fail closed when required
  - apply mode emits only Codex-native files and no lingering GitHub or Claude surface references
  - hard-gate mappings use native Codex enforcement surfaces rather than advisory instructions alone
  - at least one GitHub fixture and one Claude fixture convert into reviewable Codex-native output sets with validator-backed reports
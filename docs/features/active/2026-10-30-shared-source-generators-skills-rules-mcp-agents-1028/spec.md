# 2026-10-30-shared-source-generators-skills-rules-mcp-agents — Spec

- **Issue:** #1028
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-30
- **Status:** Draft
- **Version:** 0.1

## Overview

Shared skills, path-scoped rules, MCP servers, agents and top-level instructions are authored
separately for each ecosystem (Claude Code, Codex, GitHub Copilot). The copies drift, and no
check reports the drift. Epic #1018 settles one source per surface with generated native
outputs; this child delivers the generators and their `--check` modes. The settled design is in
`docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`
and is not re-opened here.


## Behavior

Generators, each with a `--check` mode that reports drift and exits non-zero on drift:

- Shared skill mirror: `.agents/skills` (source) to `.claude/skills`. Tool-only skills stay in
  their native folder and are not mirrored. Mirrors are generated, never symlinked.
- Path-scoped rules: one source with globs, generated into `.claude/rules` (`paths:`
  frontmatter) and `.github/instructions` (`applyTo` frontmatter).
- MCP servers: one list, generated into `.mcp.json` and the `[mcp_servers]` table of
  `.codex/config.toml`.
- Agents: one logical definition, generated into `.claude/agents/*.md` and
  `.codex/agents/*.toml`, reusing or calling the existing Codex agent-variant generator without
  adding Python to it. Agent write scopes satisfy the D-16 write-scope contract from child 2.
- Instructions: `AGENTS.md` is the instruction source; `CLAUDE.md` is `@AGENTS.md` plus
  Claude-only text.
- CI runs every `--check` mode.

Language rule (owner, epic #1018): no new Python; code that skills or hooks invoke, or that is
pushed down to destination repositories, is PowerShell or bash; TypeScript is used only for MCP
tools and extension commands. Every planned artifact records its classification.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

## Constraints & Risks

- Planned before child 1's contracts, dispositions and approvals exist (owner decision E3); the
  plan re-checks child 1's outputs at execution time and stops for re-planning when they differ.
- Execution starts only after the parallel run `bugs-1001-1002-1003-1006` merges; the plan
  re-checks every edited file, symbol and heading against `origin/main` at execution time.
- Generated mirrors also exist as bundled copies under `extensions/drm-copilot/resources/` and
  are pinned by push-down contract tests.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Unit coverage areas: each generator with and without drift; tool-only skill exclusion; write-scope coverage.
- [x] Integration scenarios: CI `--check` jobs on a clean tree and on a drifted tree.
- [ ] CLI/API examples

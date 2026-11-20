# shared-source-generators-skills-rules-mcp-agents (Issue #1028)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/shared-source-generators-skills-rules-mcp-agents/ (Issue #1028)
- Epic: #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 3
- Epic manifest: `docs/features/epics/shared-agent-harness-layer/epic.md`
- Depends on: child 1 (#1025, survey, gold-standard contracts, parity matrix) and child 2 (#1016 Phase 1, development-docs root resolver and write-scope contract D-16)

- Issue: #1028
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1028
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

Shared skills, path-scoped rules, MCP servers, agents and top-level instructions are authored
separately for each ecosystem (Claude Code, Codex, GitHub Copilot). The copies drift, and no
check reports the drift. Epic #1018 settles one source per surface with generated native
outputs; this child delivers the generators and their `--check` modes. The settled design is in
`docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`
and is not re-opened here.

## Proposed Behavior

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

## Acceptance Criteria (early draft)

- [ ] Each generator (skills, rules, MCP, agents) produces its native outputs from one source, and its `--check` mode exits non-zero and names each drifted file when an output differs from the generated form.
- [ ] Tool-only skills are not mirrored, and no mirror is a symlink.
- [ ] `CLAUDE.md` imports `AGENTS.md` and carries only Claude-only text in addition.
- [ ] Generated agent write scopes satisfy the D-16 write-scope contract.
- [ ] CI runs each `--check` mode and fails on drift.
- [ ] No new Python is added; each new artifact's language follows the epic language rule.

## Constraints & Risks

- Planned before child 1's contracts, dispositions and approvals exist (owner decision E3); the
  plan re-checks child 1's outputs at execution time and stops for re-planning when they differ.
- Execution starts only after the parallel run `bugs-1001-1002-1003-1006` merges; the plan
  re-checks every edited file, symbol and heading against `origin/main` at execution time.
- Generated mirrors also exist as bundled copies under `extensions/drm-copilot/resources/` and
  are pinned by push-down contract tests.

## Test Conditions to Consider

- [x] Unit coverage areas: each generator with and without drift; tool-only skill exclusion; write-scope coverage.
- [x] Integration scenarios: CI `--check` jobs on a clean tree and on a drifted tree.
- [ ] CLI/API examples

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/shared-source-generators-skills-rules-mcp-agents/` folder from the template

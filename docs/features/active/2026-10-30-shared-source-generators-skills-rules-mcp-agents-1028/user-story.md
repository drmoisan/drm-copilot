# `2026-10-30-shared-source-generators-skills-rules-mcp-agents` — User Story

- Issue: #1028
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-30

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

Shared skills, path-scoped rules, MCP servers, agents and top-level instructions are authored
separately for each ecosystem (Claude Code, Codex, GitHub Copilot). The copies drift, and no
check reports the drift. Epic #1018 settles one source per surface with generated native
outputs; this child delivers the generators and their `--check` modes. The settled design is in
`docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`
and is not re-opened here.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] Each generator (skills, rules, MCP, agents) produces its native outputs from one source, and its `--check` mode exits non-zero and names each drifted file when an output differs from the generated form.
- [ ] Tool-only skills are not mirrored, and no mirror is a symlink.
- [ ] `CLAUDE.md` imports `AGENTS.md` and carries only Claude-only text in addition.
- [ ] Generated agent write scopes satisfy the D-16 write-scope contract.
- [ ] CI runs each `--check` mode and fails on drift.
- [ ] No new Python is added; each new artifact's language follows the epic language rule.


## Non-Goals

Call out what is explicitly excluded from this feature.

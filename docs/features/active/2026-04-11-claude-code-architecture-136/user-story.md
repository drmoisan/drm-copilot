# `2026-04-11-claude-code-architecture` — User Story

- Issue: #136
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-04-11T19-55

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The repository's orchestration model is built around Copilot-specific primitives: auto-attached instruction files, declarative agent handoffs, reusable skill contracts, and extension-backed MCP tool surfaces. Claude Code can support the same overall workflows, but it uses a distinct four-layer native architecture:

1. `CLAUDE.md` and `.claude/rules/` for persistent standing instructions (not a monolithic single file)
2. `.claude/skills/` for user-invocable or automatically loaded reusable workflows (first-class primitive — not `.claude/commands/`)
3. `.claude/agents/` for named specialist personas with their own tool allowlists, models, hooks, memory, and MCP server scoping (first-class primitive — not ad hoc file reads at delegation time)
4. `.claude/settings.json` and `.claude/hooks/` for permissioned-enforced behavior and deterministic stop gates

Without a documented and implemented Claude-native architecture that uses all four layers, the current orchestration assets are not portable outside the Copilot runtime. Specifically, the repository cannot leverage Claude Code's per-subagent tool restrictions, subagent-scoped hooks, preloaded skills, or project-level permission enforcement — all of which are required to replicate the deterministic routing, guarded handoffs, and completion-gate behavior the Copilot orchestration model provides.

A command-only or `CLAUDE.md`-only approach (the original draft design) intentionally discards supported Claude features and is not a correct Claude-native architecture.


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

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Non-Goals

Call out what is explicitly excluded from this feature.

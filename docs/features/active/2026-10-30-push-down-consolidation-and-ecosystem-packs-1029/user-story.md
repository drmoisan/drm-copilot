# `push-down-consolidation-and-ecosystem-packs` — User Story

- Issue: #1029
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-37

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The repository pushes its agent harness down to destination repositories through three separate push-downs (Claude, Codex, Copilot), each exposed as its own MCP tool with its own payload layout and pack manifests. Epic #1018 makes the shared layer (`AGENTS.md`, `.agents/skills`, generated rules, MCP configuration and agents produced by child 3) the source for all three ecosystems. Three independent push-downs cannot install one shared layer once, cannot let a destination omit an ecosystem it does not use, and cannot protect a destination's own edits consistently.


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

- [ ] One push-down pipeline serves Claude, Codex and Copilot, and the existing MCP push-down tools delegate to it as thin wrappers.
- [ ] A destination chooses packs per ecosystem; the shared layer is always installed; an unused ecosystem installs no files.
- [ ] A push-down reports a dry run before writing.
- [ ] A destination file whose content differs from the last pushed-down manifest entry is not overwritten and is reported.
- [ ] Pack manifests list the generated files produced by child 3.


## Non-Goals

Call out what is explicitly excluded from this feature.

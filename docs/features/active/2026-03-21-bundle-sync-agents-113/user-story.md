# `2026-03-21-bundle-sync-agents` — User Story

- Issue: #113
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-03-21T20-41

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The repository already has `scripts/dev-tools/sync-agents-from-instructions.ps1`, but it is not exposed through the VS Code extension command surface that currently drives other destination-workspace workflows. Users who push bundled tooling into another workspace can sync customization files there, but they cannot trigger `AGENTS.md` regeneration from the extension in the same way.

The current script also hard-codes a fixed section list and rewrites section titles instead of discovering the canonical instruction sources that actually exist under `.github/`. That makes the sync brittle when new instruction files are added, renamed, or reorganized, and creates drift between the generated `AGENTS.md` content and the instruction set the repo actually ships.


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

- [ ] The extension contributes a new command for syncing `AGENTS.md`, and invoking it runs the bundled sync workflow against the open workspace root rather than the extension installation directory.
- [ ] The bundled sync workflow reads `.github/copilot-instructions.md` and discovers instruction sources under `.github/` from the destination workspace instead of depending on a hard-coded section-definition array.
- [ ] The generated `AGENTS.md` includes the canonical repository instructions plus the discovered instruction bodies in a deterministic order, strips YAML frontmatter from source files, and produces identical output on repeated runs when inputs have not changed.
- [ ] If the destination workspace is missing required source files such as `.github/copilot-instructions.md` or has no discoverable instruction files, the command fails with an actionable error message instead of generating partial or misleading output.
- [ ] Adding a new instruction file under the supported `.github/` discovery scope causes the next sync run to include it automatically without requiring a code change to the sync script.


## Non-Goals

Call out what is explicitly excluded from this feature.

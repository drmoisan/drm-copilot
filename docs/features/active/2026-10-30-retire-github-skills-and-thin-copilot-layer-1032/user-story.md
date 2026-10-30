# `2026-10-30-retire-github-skills-and-thin-copilot-layer` — User Story

- Issue: #1032
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-39

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

Epic #1018 moves the three agent ecosystems in this repository onto shared cross-tool conventions so that each tool loads every skill and instruction exactly once with default settings. GitHub Copilot in VS Code reads `.github/skills`, `.claude/skills` and `.agents/skills`, so the `.github/skills` folder (a strict subset of the other two skill folders) causes duplicate loading. `.github/agents` duplicates agent definitions that Copilot in VS Code also reads from `.claude/agents`. Collision controls currently live only in the owner's personal user settings; other users do not have them.


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

- [ ] `.github/skills` is retired with no loss of unique content; each of its three unique sections is ported or recorded as stale with a reason.
- [ ] `.github/agents` is retired or reduced to a generated file, according to child 1's recorded E3 result.
- [ ] The thin Copilot layer keeps prompts, handoffs and hooks native in `.github`, and `.github/copilot-instructions.md` holds only Copilot-only text.
- [ ] Copilot collision controls are delivered at workspace scope when E4 shows it works, otherwise documented.
- [ ] Push-down pack manifests and bundled mirrors contain no entry for a removed file, and the push-down contract tests pass.


## Non-Goals

Call out what is explicitly excluded from this feature.

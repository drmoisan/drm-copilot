# `hook-parity-across-claude-codex-copilot` — User Story

- Issue: #1030
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-37

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

This repository runs enforcement and validation hooks in three agent ecosystems: Claude Code
(`.claude/hooks`, 75 files on `main`), Codex (`.codex/hooks`, 50 files) and GitHub Copilot
(`.github/hooks`, 6 files). The sets were built separately and drifted: some Claude gates have no
Codex counterpart, some Codex hooks exist only to express Codex-specific attestation, and the
Copilot hooks cover only the discovery surface. No record states, for each hook, whether its
function is shared across ecosystems, native to one ecosystem, generated, or deliberately dropped,
so a missing gate in one ecosystem is not detectable.

Epic #1018 settles the design: hook parity is parity of function, tracked in the parity matrix
owned by child 1 (#1025, `config/harness-parity-matrix.json`). Hook counts need not match, and
Codex gains a hook only where its hook system can express the behavior.


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

- [ ] Every hook registration in `.claude/settings.json`, agent frontmatter, `.codex/config.toml`
- [ ] and `.github/hooks` has a parity-matrix disposition, and the completeness test passes.
- [ ] Every hook whose disposition is shared has a counterpart in each ecosystem that can express
- [ ] it, with a test proving equivalent behavior.
- [ ] No enforcement hook invokes Python.
- [ ] Bundled mirrors and their parity tests are green.


## Non-Goals

Call out what is explicitly excluded from this feature.

# `2026-10-30-harness-survey-gold-standard-contracts-parity-matrix` — User Story

- Issue: #1025
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T17-06

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

Epic #1018 restructures the three agent ecosystems in this repository (Claude Code, Codex and GitHub Copilot) onto shared cross-tool conventions. Before any generator, push-down or retirement work can start, the epic needs three settled inputs that do not exist today:

- A content-level comparison of the 90 skill names across `.claude/skills`, `.agents/skills` and `.github/skills`. The existing heading comparison (12 byte-identical, 27 wording-only, 16 material differences among 55 shared names) overstates differences because the same topic appears under different headings.
- A tool-neutral gold-standard contract for each shared skill, against which each ecosystem's expression can be judged.
- A machine-readable parity matrix that gives every native feature of every ecosystem a disposition, so later children can prove that no native capability is lost.

Several behaviors that the design depends on are also unverified: Copilot duplicate-skill listing, Codex tolerance of Claude-only frontmatter, whether the Copilot CLI and cloud agent read `.claude/agents`, whether Copilot settings work at workspace scope, and details of the Claude hooks, subagent and permissions documentation.


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

- [ ] Every one of the 90 skill names is surveyed by content, and each shared skill's differences are recorded.
- [ ] Each shared skill has `.agents/skills/<name>/references/standard.md` with objective, observable behaviors and acceptance checks.
- [ ] Every recorded difference is classified as positive, negative, neutral or mechanism-only, and an owner bulk-approval artifact lists the classifications with disputed cases separated.
- [ ] The parity matrix exists at its specified location, conforms to its specified schema, and gives every native feature of every ecosystem a disposition.
- [ ] A completeness test in TypeScript or PowerShell fails when a feature has no disposition or a dropped feature has no reason, and passes on the committed matrix.
- [ ] Each unverified behavior has a recorded result, or an owner-run runbook with a recorded-result artifact and an explicit stop.
- [ ] No new Python script, tool, checker or CLI entry point is added.


## Non-Goals

Call out what is explicitly excluded from this feature.

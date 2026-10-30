# `2026-10-30-documentation-estate-template-and-onboarding` — User Story

- Issue: #1038
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-59

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The documentation-estate-tooling epic (#1019) delivers a docs profile and schemas, a page
checker, surface analyzers, a coverage ledger and `docs-complete` receipt, a reference generator,
docs MCP tools, CI enforcement and an authoring workflow as separate children. A consumer
repository has no single entry point that composes them: there is no epic template that plans a
documentation estate, no onboarding guide that documents every subcommand and MCP tool, and no
end-to-end test that proves the pieces work together on one fixture repository.


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

- [ ] The end-to-end test runs inventory, ledger, generation and `docs-complete` validation; it
- [ ] fails naming the undocumented command and the stale page, passes after both are fixed, and
- [ ] the result records `analysis_method` per element.
- [ ] The template is accepted by `/epic-plan` as a manifest path.
- [ ] A Pester test proves the template manifest has a cycle-free dependency graph under the epic
- [ ] manifest rules.
- [ ] The onboarding guide documents every subcommand and MCP tool with an example and states the
- [ ] destination-repository prerequisite (PowerShell 7.4); it states that the optional python
- [ ] pack enables the native Python analyzer and that linting is optional.
- [ ] No test creates temporary files.


## Non-Goals

Call out what is explicitly excluded from this feature.

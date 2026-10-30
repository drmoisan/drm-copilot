# `docs-authoring-workflow` — User Story

- Issue: #1037
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-59

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The documentation-estate-tooling epic (#1019) delivers a docs profile, surface analyzers, a page
checker, a coverage ledger with a `docs-complete` receipt, a reference generator and six docs MCP
tools. Without constrained documentation roles and reusable skills, a consumer repository still has
to hand-orchestrate inventory, information-architecture planning, page authoring, behavior
reconciliation and coverage review, and an unconstrained agent could edit the ledger or parity
matrix directly instead of going through the single mutation boundary (`update-ledger`).


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

- [ ] Each role's tool list excludes Write and Edit on ledger and matrix paths; a test asserts it.
- [ ] Every skill references only MCP tools and subcommands defined in the epic's earlier children (1020 through the docs MCP tools child).
- [ ] Mirror and push-down parity tests pass for all new agents and skills.
- [ ] The SubagentStop check blocks a role output that lacks its required result fields.


## Non-Goals

Call out what is explicitly excluded from this feature.

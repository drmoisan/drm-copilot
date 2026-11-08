# `owner-directive-relay` — User Story

- Issue: #1139
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-08T12-32

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

When the repository owner gives an instruction to the coordinator session (for example "merge without waiting for X", "skip the optional Y", "approve one more planner revision"), the coordinator relays it to a delegated orchestrator or specialist in the delegation prompt or via SendMessage. Subagents refuse these relayed instructions because they cannot distinguish an owner directive from model-authored text, and the harness tells them that agent-to-agent messages carry no user authority. Observed in the iar-migration three-layer redesign epic (E1/E2, 2026-11-07/08): owner instructions relayed by the coordinator were refused, stalling the run. There is no defined, auditable mechanism for an owner directive to reach a subagent.


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

- [ ] Directive block schema and checkpoint field defined and validated.
- [ ] Honor/refuse policy documented in orchestrate, epic-orchestrate, and the relevant agent definitions (all mirrors and bundle copies).
- [ ] A relayed directive in an allowed class is honored and recorded; a directive in a refused class is refused and recorded.
- [ ] No hook or gate is weakened; refused classes are enforced by existing hooks regardless of directives.
- [ ] Regression tests for schema validation and the honor/refuse classification.


## Non-Goals

Call out what is explicitly excluded from this feature.

# `2026-10-30-docs-enforcement-and-ci` — User Story

- Issue: #1034
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-40

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The documentation-estate tooling of epic #1019 can check pages and emit a `docs-complete`
receipt, but nothing enforces either result. A destination repository can change its documentable
surface (for example add a CLI command) without changing its coverage ledger, and an epic
integration branch can merge to `main` without a passing receipt for its head revision. In one
consumer repository, a feature epic changed 138 `src/` files while only 4 of 79 documentation
pages were edited, and the gap was found by hand. The epic's correspondence half needs a CI
surface, a merge gate, and a review check that act on the tooling's results.


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

- [ ] With the gate disabled (default) the hook allows every call; enabled, it denies when the receipt is absent, failing, or pinned to another revision, and the deny text names the reason.
- [ ] `surface-delta` reports an added CLI command with no ledger change and reports nothing when the ledger records it.
- [ ] The workflow template requires `pwsh` only.
- [ ] Mirror parity checks pass for the edited `feature-review` surfaces.


## Non-Goals

Call out what is explicitly excluded from this feature.

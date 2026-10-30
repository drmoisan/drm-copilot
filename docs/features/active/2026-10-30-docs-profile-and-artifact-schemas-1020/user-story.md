# `docs-profile-and-artifact-schemas` — User Story

- Issue: #1020
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T16-08

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The documentation-estate-tooling epic (#1019) needs a stable set of contracts before its analyzer,
ledger, generator, MCP and enforcement features can be built in parallel. No documentation profile,
documentation artifact schema, surface element model or analyzer protocol exists in the repository
today. Without them, every downstream feature would invent its own shapes, and the coverage ledger,
parity matrix and `docs-complete` receipt could not be validated consistently. Framework code must also
stay domain-neutral: all repository specificity must be runtime configuration in a docs profile.


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

- [ ] Every example under `examples/docs/v1/` validates against its schema; each schema rejects a missing required field and an unknown disposition or element kind.
- [ ] `dev.docs.validate-profile` exits 0 for the example profile and non-zero with a message naming the failing field for an invalid profile; `dev.docs.init` emits a starter profile that validates.
- [ ] Element identifiers are deterministic (property test: same kind, path and declaration yield the same identifier; distinct inputs yield distinct identifiers).
- [ ] A neutrality test fails when a configured consumer identifier appears under `packages/docs-runtime/src/` or `schemas/docs/`.
- [ ] Line coverage >= 85% and branch coverage >= 75% for `drm_copilot_docs`.


## Non-Goals

Call out what is explicitly excluded from this feature.

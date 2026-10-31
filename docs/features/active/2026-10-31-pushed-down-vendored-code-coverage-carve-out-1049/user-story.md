# `2026-10-31-pushed-down-vendored-code-coverage-carve-out` — User Story

- Issue: #1049
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-31T14-03

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The push-down copies hooks, skills, agents, libraries and rules into destination repositories. It does not copy the Pester tests that cover them: `extensions/drm-copilot/resources/` contains no `*.Tests.ps1` files, and the push-down source does not reference tests. A destination repository therefore receives PowerShell production code without its suite.

The pushed-down rule `general-unit-test.md` states that no production file may be excluded from coverage and lists the only permitted exclusions (build output, tests and test infrastructure, non-production config, `node_modules`). A destination that enforces that rule must cover the pushed-down hooks, and at least one destination has done so by recreating a Pester suite locally. Those recreated tests duplicate coverage already established upstream, drift from the hooks on every push-down, and can fail for reasons unrelated to the destination's own code.

Packages and plugins conventionally ship without their tests, and consumers do not hold vendored code to their own coverage targets. The rule has no vendored-code category, so a destination cannot exempt pushed-down files without violating it.


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

- [ ] The pushed-down coverage rules define the vendored-code exception with the hash-verified, exact-path conditions.
- [ ] The push-down writes a manifest of path and content hash for every file it writes.
- [ ] A destination check fails closed: a changed or unlisted file is not exempt.
- [ ] The exclusion list used by the destination's coverage tooling is derived from the manifest.
- [ ] A destination-added hook under `.claude/hooks/` stays in the coverage denominator.
- [ ] The feature-review rule that treats a production-path exclusion as Blocking recognizes manifest-derived entries and still blocks hand-written ones.
- [ ] The destination documentation states the ownership policy and the removal of recreated duplicate tests.


## Non-Goals

Call out what is explicitly excluded from this feature.

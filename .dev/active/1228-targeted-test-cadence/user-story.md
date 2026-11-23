# `targeted-test-cadence` — User Story

- Issue: #1228
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-23T06-50

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The orchestration rules run the full unit suite at every `[phase-gate]` task, and some skills also require it for remediation cycles and post-merge sync checks. On large destination repositories this repeats a multi-minute full run many times per orchestration. The owner directed on 2026-11-23: "The full test suite for any destination repo should only be run at the beginning of the orchestration and in the qc run. everything else should be targeted tests. this change should be reflected in every rule that operates otherwise for all orchestrators."


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

- [ ] `## Test Cadence (Mandatory)` in atomic-plan-contract (all surfaces) defines the phase gate's unit stage as the union of the phase's task test selections, and the full suite only at the Phase 0 baseline and the final QA loop.
- [ ] No rule, skill, agent, prompt, or instruction on any surface or bundle still requires a full-suite run outside the Phase 0 baseline and the final QC loop. This is verified by a repository-wide search recorded in evidence.
- [ ] Generated outputs are regenerated from sources, and `Invoke-HarnessGeneration.ps1 -Check` reports no drift.
- [ ] Bundle copies are in parity, AGENTS.md matches its bundle copy byte for byte, and push-down contract tests pass.
- [ ] Any validator, hook, or contract test that pins the old wording is updated in step.
- [ ] A process-reduction ledger entry records the prior text and the revert steps.
- [ ] The final QC loop and the Phase 0 baseline remain full runs with coverage comparison. CI is unchanged.


## Non-Goals

Call out what is explicitly excluded from this feature.

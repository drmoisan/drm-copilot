# `epic-child-ci-opt-out` — User Story

- Issue: #1233
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-23T22-42

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

Every epic child must pass CI on its own pull request before it merges into the epic integration branch. The merge gate `enforce-epic-merge-gate-child-ci.ps1` (issue #1130), byte-identical in `.claude/hooks/` and `.codex/hooks/`, enforces this. The S9 dispatch fallback starts a `CI` run per child head, because `ci.yml` does not trigger on pull requests into `epic/**`. An epic with N children pays for N full CI runs plus the integration run. The owner directed on 2026-11-23: "for the epic run, do not run CI on each feature. only run it on the final epic merge to main". The owner chose to change the gate rather than bypass it.


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

- [ ] With `child_ci: integration_only` in the epic checkpoint, the epic merge gate allows a child merge into its integration branch without a `CI` run on the child head, provided the final-QC evidence and the review-guard conditions hold. With `per_child`, or with the key absent, behavior is unchanged.
- [ ] The gate never applies the opt-out to a pull request whose base is `main`.
- [ ] The S9 epic-child procedure issues no CI dispatch under the opt-out, and the integration PR still requires green `CI`.
- [ ] The validators accept a completed epic child under the opt-out without `ci_gate` success, and reject the same checkpoint when the opt-out is absent. The Python, TypeScript, and PowerShell error strings are byte-identical.
- [ ] Claude and Codex hook copies stay byte-identical, bundle parity holds, and harness generation reports no drift.
- [ ] Pester tests cover the allow and deny paths, the main-base exclusion, and the default behavior.
- [ ] A process-reduction ledger entry records the prior text and the revert steps.


## Non-Goals

Call out what is explicitly excluded from this feature.

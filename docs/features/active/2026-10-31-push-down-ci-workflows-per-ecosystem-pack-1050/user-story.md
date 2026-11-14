# `2026-10-31-push-down-ci-workflows-per-ecosystem-pack` — User Story

- Issue: #1050
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-14T09-31

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The push-down ships rules, skills, agents, hooks and libraries per ecosystem option (Python, PowerShell, TypeScript, and .NET in legacy and current forms). It ships no CI: `extensions/drm-copilot/resources/` contains no GitHub workflow files.

The harness assumes CI exists. The merge gate and the S9 step read check names and a required-context list, and the toolchain rules assume artifact paths such as `artifacts/python/coverage.json` for the coverage-threshold step. A destination without matching CI makes those gates unsatisfiable or vacuous, so agents wait for checks that never run. Each destination currently builds its own CI, and the check names drift from what the harness expects.

This repository's workflows are already reusable (`_quality-checks.yml`, `_poshqc.yml`, `_root-typescript-tests.yml`, `_shell-coverage.yml`), which makes a thin-caller push-down possible.


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

- [ ] Each ecosystem pack option includes a CI template, and selecting the option writes only that pack's workflows.
- [ ] The template check names and artifact paths match the toolchain rules and the merge gate's expectations; a contract test fails when they diverge.
- [ ] The default template is a thin caller with a pinned ref; a copy mode records content hashes in the manifest.
- [ ] The required-check list is emitted as data and consumed by the merge gate and the brief.
- [ ] The push-down never overwrites an existing workflow file and reports each conflict.
- [ ] Branch protection is changed only by an explicit opt-in command.
- [ ] No new Python; the push-down is TypeScript, and any helper is PowerShell or bash.


## Non-Goals

Call out what is explicitly excluded from this feature.

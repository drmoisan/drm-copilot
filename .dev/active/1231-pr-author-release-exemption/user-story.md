# `2026-11-23-pr-author-release-exemption` — User Story

- Issue: #1231
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-23T17-58

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

Issue #1201 added the release-commit allowance: a destination repository that commits `.claude/release-commit-allowance.json` lets an agent stage and commit a release version bump on a matching branch without an orchestration checkpoint. Opening the release pull request remains blocked. `.claude/hooks/enforce-pr-author-skill.ps1` requires an orchestrator-state checkpoint that passes `--require-pr-creation-ready` for every `gh pr create --body-file`, and its only checkpoint-free exemptions are the docs-only exemption (#901, every path under `docs/`) and the cleanup consolidation exemption (#1026, branch `documentationandmemories`). A release diff changes package manifests, lockfiles, and configuration files, so neither exemption applies.

Today a release pull request is opened only because `scripts/dev-tools/Invoke-FullRelease.ps1` calls `gh pr create` inside a PowerShell process the hook cannot read. That is an inspection gap, not a designed path, and destination repositories have no equivalent script. An agent-driven release therefore needs a full orchestration checkpoint for a version-bump diff of a few files.


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

- [ ] A checkpoint-free `gh pr create --body-file` on a branch matching an allowance, whose diff lies entirely in that allowance's `allowed_paths`, passes the checkpoint preflight of `enforce-pr-author-skill.ps1` and is still subject to the receipt checks.
- [ ] A diff path outside the matched allowance, a branch matching no allowance, an invalid allowance file, an existing checkpoint, a missing or repeated `--head`/`--base`, a remote head that differs from `HEAD`, or `gh pr edit` each keeps the deny, with a distinct release sub-code appended after the existing exemption reasons.
- [ ] Without `.claude/release-commit-allowance.json` every existing deny text is byte-identical.
- [ ] Every other gate on the checkpoint-free release pull-request path admits the same release case through an equivalent leg, with the same fail-closed behaviour.
- [ ] The allowance parser of `hook-release-allowance-context.ps1` is reused, not reimplemented; the schema is unchanged.
- [ ] All changed hook files are mirrored byte-identically into the bundle copies, the pack manifests list any new file, and the execution-environment brief and orchestrator-state rule describe the leg.
- [ ] Pester tests cover each allow and deny case; enforcement hooks invoke no Python.


## Non-Goals

Call out what is explicitly excluded from this feature.

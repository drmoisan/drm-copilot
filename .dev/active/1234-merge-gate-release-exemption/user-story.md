# `2026-11-23-merge-gate-release-exemption` — User Story

- Issue: #1234
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-23T22-54

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

Issue #1201 lets an agent commit a release version bump without an orchestration checkpoint on a branch matching the destination-owned `.claude/release-commit-allowance.json`, and issue #1231 (PR #1232) lets the same agent open the release pull request without a checkpoint. Merging that pull request is still blocked. `.claude/hooks/enforce-epic-merge-gate.ps1` admits a `gh pr merge` only through an epic, parallel, green-CI standalone, or `standalone_merge_authorizations` branch, and every one of those reads an orchestrator checkpoint. A checkpoint-free release pull request therefore reaches `EPIC_MERGE_GATE_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE`, and the release flow stops one step before completion. This was recorded as out of scope (decision D1) in #1231.


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

- [ ] A checkpoint-free `gh pr merge <N> --merge --match-head-commit <sha>` for a pull request whose head branch matches an allowance, whose changed paths all lie in that allowance's `allowed_paths`, whose live head equals the given SHA, and whose CI run on that head succeeded is admitted.
- [ ] A changed path outside the allowance, a branch matching no allowance, an invalid allowance file, a missing `--match-head-commit`, a head mismatch, a CI run that is missing, pending, failed, or from a `push` event, a checkpoint that records the pull request, or a disallowed command shape each keeps the deny with a distinct release sub-code.
- [ ] Without `.claude/release-commit-allowance.json`, every existing deny text is byte-identical and no extra `gh` call is made.
- [ ] The allowance parser and branch matcher of `hook-release-allowance-context.ps1` and the shared predicate file from #1231 are reused, not reimplemented.
- [ ] All changed hook files are mirrored byte-identically into the bundle copies, the pack manifests list any new file, and the orchestrator-state rule and execution-environment brief describe the leg through their generation sources.
- [ ] Pester tests cover each allow and deny case with injected `gh` seams; enforcement hooks invoke no Python.


## Non-Goals

Call out what is explicitly excluded from this feature.

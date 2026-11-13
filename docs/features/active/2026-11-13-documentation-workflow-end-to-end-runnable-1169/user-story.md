# `documentation-workflow-end-to-end-runnable` — User Story

- Issue: #1169
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-13T12-10

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

Make the documentation workflow end-to-end runnable (commit, push, PR) and fix defects found in a first consumer run.

A first full run of `/documentation-workflow` (docs-init → inventory → IA plan → author → reconcile → review → validate) was completed in a consumer repository: a Python package of 3,061 surface elements (2,610 public symbols, 386 architecture components, 65 config keys), 22 pages, docs-complete passing. The run exposed (A) gaps that prevent a docs run from committing, opening a PR, or merging without an orchestration checkpoint, and (B) defects in the docs tooling, hooks, templates and skills. Fix all items below. Each item states the observed behavior, the evidence and the required change. Follow the repository's toolchain, test, file-size and tonality rules; add a regression test per item.

Design principle for part A: a docs run writes no orchestration checkpoint by design. Give it a checkpoint-free path modelled on the cleanup-worktrees context (issue #1026: session-root manifest + consolidation branch + path restriction), using the docs profile and a passing docs-complete receipt as the readiness evidence.


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

- [ ] A first-time `/documentation-workflow` run in a repository with no orchestration checkpoint reaches docs-complete, commits, pushes, and creates its PR through `Agent(pr-author)` with no hook denial and no manual workaround, and its first PR passes the docs-only exemptions.
- [ ] A non-docs path in the same branch is still denied at commit, PR-create and merge.
- [ ] Reconciling a ~3,000-element estate completes in minutes through the supported `update-ledger` path.
- [ ] The integration docs-complete gate accepts a receipt produced by the documented workflow and denies one whose source drifted.
- [ ] Every item above (A1-A5, B1-B13) has a regression test, and the full toolchain loop passes.


## Non-Goals

Call out what is explicitly excluded from this feature.

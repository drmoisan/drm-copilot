# `2026-11-23-docs-epic-scale-routing` — User Story

- Issue: #1223
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-23T05-58

## Story Statement

- As a maintainer starting a first full documentation estate, I want the `documentation-workflow` skill to state when and how to route the work through `epic-plan`, so that the estate is split into dependency waves instead of one oversized run.
- As an agent running one wave child, I want the skill to state that I run the dispatch order for my families only and that I never write the docs-complete receipt, so that the receipt appears once on the integration branch.

## Problem / Why

The `documentation-workflow` skill assumes one run, one pull request, and docs-only paths. A first full documentation estate, or an estate large enough that one run cannot author and review it in a single pass, has no documented route. The reference estate in `rgf-forecast` (`docs/features/epics/comprehensive-documentation/epic.md`) needed an epic with dependency waves of documentation families, which the workflow does not describe.

## Personas & Scenarios

- Persona: Repository maintainer
  - Owns a repository whose documentation estate is missing or incomplete.
  - Cares about reviewable pull requests and a single docs-complete receipt.
  - Constraint: `epic-plan` can be started only from the main session.
  - Goal: pick the right route without re-deriving the decomposition.
- Scenario: Maintainer plans a first full estate
  - The maintainer opens the skill with no committed profile.
  - The skill states that a first full estate routes through `epic-plan`.
  - The maintainer starts `epic-plan` from the main session and uses the default waves: foundation, then architecture and related families, then guides, administration, and security, then operations and service management.
  - If the epic-worthiness verdict returns a single feature, the maintainer follows the single-run route.
  - Outcome: wave children run their own dispatch order, and the receipt is written once on the integration branch before the integration pull request.
- Persona: Wave child agent
  - Runs inside an orchestrated child with a checkpoint.
  - Needs to know which parts of the single-run stage do not apply to it.
  - Outcome: it runs the dispatch order for its families only and leaves the receipt to the integration branch.

## Acceptance Criteria

- [x] The skill places `## Epic-Scale Routing` after `## Rules` and before `## Commit, Receipt and Pull Request` in every copy, and the contract test fails otherwise.
- [x] The skill states the routing condition (a first full estate, or a planned page count above the default threshold recorded in the spec decision D2), that `epic-plan` is started from the main session, that the epic-worthiness verdict can return the work to the single-run route, and that deviating from the default is a recorded decision.
- [x] The skill states the default waves in order with each default family id in its own wave without repetition, names docs-family-profile-model as the owner of the ids, and contains no family-record field names.
- [x] The skill states that each child runs the dispatch order for its families only, and that the docs-complete receipt is written on the integration branch at its head by the final integration step only before the integration pull request, with no receipt from a wave child.
- [x] The skill qualifies the existing single-run statements (When to Use, Commit/Receipt/Pull Request stage, docs path set rule, Refresh) so that none contradicts the epic route.
- [x] `references/standard.md` gains a new behavior and check for epic-scale routing and passes the skill contract shape rules.
- [x] A parallel Pester contract test, `documentation-workflow.EpicRouting.Tests.ps1`, pins these statements in every copy, creates no temporary files, and reads no clock.
- [x] All surface and bundle copies are in parity, the harness generator check passes, the push-down contract tests and pack-manifest completeness tests pass, and the new suite is listed in the execution-environment brief copies.

## Non-Goals

- No profile option for the threshold; the threshold is skill text only.
- No change to `epic-orchestrate`, `epic-orchestrator`, `docs-plan-ia`, the substitutions file, any library, or any MCP surface.
- No restatement of the family record or of docs-complete family semantics, which docs-family-profile-model and docs-family-gate-and-ia own.
- No specification of how the receipt is committed on the integration branch; preflight and the epic's final step own that mechanism.

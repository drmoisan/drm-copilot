# `2026-08-29-claude-planning-integrity` — User Story

- Issue: #593
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-08-29T12-07

## Story Statement

- As a Claude workflow maintainer, I want approved planning facts and preflight handoffs to include verifiable provenance, so that implementation starts from requirements and plans that are traceable to the repository.
- As an orchestration operator, I want section-bounded requirement measurements and batched initial parallel intake, so that workflow decisions are not distorted by unrelated checklist items or redundant admission attempts.

## Problem / Why

Planning quality gaps are currently discovered after requirements or plans have already been handed downstream. A narrow search can be recorded as a numeric acceptance-criterion fact, a planner can rely on executor preflight to find traceability gaps, a document counter can include unrelated checkboxes, and initial parallel items can be admitted one at a time before execution begins.

The required behavior makes those conditions testable at the Claude-native contract boundary. It preserves issue #586's executor-owned validation-only preflight rather than introducing a second preflight workflow.


## Personas & Scenarios

- Persona: Claude workflow maintainer
  - Maintains Claude agents, skills, hooks, focused tests, and the required published Claude bundle mirrors.
  - Needs approved acceptance criteria to distinguish measured facts from unverified estimates.
  - Must preserve established issue #586 preflight behavior and keep Codex runtime changes out of scope.
  - Needs contract tests that reject missing evidence before a workflow is published.
- Scenario: Preparing a full-feature plan
  - A researcher identifies a potential numeric fact for an acceptance criterion and records complete family-search provenance plus an independently constructed cross-check.
  - The PRD author approves the numeric criterion only when both derivations agree; otherwise the criterion omits the numeric assertion.
  - The planner performs citation-to-tree, acceptance-criterion traceability, and scope-boundary review before handing the plan to the existing executor preflight.
  - If preflight needs an additional round for a well-scoped item, the workflow records a process-defect investigation rather than treating the result as ordinary iteration.
  - The maintainer verifies that document counters ignore unrelated checkboxes and that initial parallel intake is batched before the Claude bundle is published.


## Acceptance Criteria

- [x] A numeric count, enumeration, or population is approved in `spec.md` only when its research record identifies the complete symbol or method family, inclusion and exclusion rules, the member set, and an independently constructed cross-check that agrees with the first derivation; focused tests reject a numeric claim without that provenance.
- [x] The Claude planner completes and records a preflight-shaped internal review of citation-to-tree verification, acceptance-criterion-to-implementation traceability, and scope-boundary consistency before executor preflight; the existing issue #586 validation-only preflight loop remains intact, and a well-scoped handoff requiring more than one preflight round produces a process-defect investigation identifying the incomplete review dimension.
- [x] Each reusable counter for checkbox items in generated requirements documents requires a named section and counts only between that heading and the next equal-or-shallower heading; focused fixture coverage proves that unrelated checkboxes outside the section do not affect the result.
- [x] Initial parallel intake requires the complete item set through `/parallel-plan`; `/parallel-add` admits an item only after execution has started and rejects pending or not-started runs with instructions to consolidate the initial set through `/parallel-plan`, with focused contract coverage for both paths.


## Non-Goals

- Changing Codex runtime agents, skills, prompts, hooks, or orchestration behavior.
- Replacing, duplicating, or weakening issue #586's executor-owned validation-only preflight loop, convergence signals, or iteration ceiling.
- Retrofitting historical approved acceptance criteria or changing the generic plan-progress counter that measures plan tasks.
- Adding external services, dependencies, or a new product-facing API.

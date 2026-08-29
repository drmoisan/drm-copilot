# 2026-08-29-claude-planning-integrity — Spec

- **Issue:** #593
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-29T12-07
- **Status:** Draft
- **Version:** 0.1

## Overview

Strengthen the Claude-native planning workflow so approved requirements, preflight handoffs, generated-document measurements, and parallel intake are based on verifiable facts. The change applies to Claude agents, skills, hooks, tests, and their required published Claude bundle mirrors; Codex runtime behavior is excluded except for repository-required bundle publication support.


## Behavior

Before a numeric count, enumeration, or population is written into an approved `spec.md` acceptance criterion, research must record the complete symbol or method family searched, inclusion and exclusion rules, the resulting member set, and an independently constructed cross-check that reaches the same result. The PRD author must not write the numeric assertion when this provenance is absent.

Before handing a plan to executor preflight, the planner performs and records an internal review of citation-to-tree verification, acceptance-criterion-to-implementation traceability, and scope-boundary consistency. The existing issue #586 executor-owned, validation-only preflight loop remains the clearance step; if a well-scoped item needs more than one preflight round, the workflow records and investigates the incomplete planner-review dimension instead of treating the extra round as routine iteration.

Reusable generated-document counters must count checkbox items only within the named section, ending at the next heading of equal or shallower level. Initial parallel intake accepts the complete item set through `/parallel-plan`; `/parallel-add` is reserved for an execution-started run and rejects pending or not-started intake with consolidation guidance.


## Inputs / Outputs

- Inputs: feature research records, `spec.md` and `user-story.md`, planner handoff content, preflight results, generated Markdown document text, and parallel-run state.
- Outputs: numeric-derivation provenance in research, an evidence-bearing planner internal-review declaration, a process-defect investigation when the documented preflight threshold is exceeded, section-bounded counter results, and actionable parallel-intake rejection guidance.
- Config keys and defaults: existing Claude contract signals and issue #586 remediation-loop fields remain authoritative; no new external configuration is required.
- Versioning or backward-compatibility constraints: retain the existing validation-only executor preflight contract, convergence reporting, and iteration ceiling introduced by issue #586.

## API / CLI Surface

No external product API is introduced. Claude workflow contracts are updated as follows:

- Research and PRD handoff: numeric acceptance-criterion facts require exhaustive family-search provenance and an independently constructed matching cross-check before they are approved.
- Planner to executor handoff: a declaration records that citation-to-tree verification, acceptance-criterion traceability, and scope-boundary consistency were reviewed and any findings were resolved before preflight.
- Generated-document counter: the caller supplies the target section name; the counter returns checkbox results only from that section.
- Parallel intake: `/parallel-plan` receives the complete initial item set; `/parallel-add` rejects a pending or not-started run and directs the caller to consolidate the set through `/parallel-plan`.
- Contracts and validation rules: Claude hooks and focused tests reject missing required planner-review evidence, unbounded document counting, incomplete numeric provenance, and invalid initial parallel admission.

## Data & State

Research supplies numeric-derivation provenance to the feature documents. The planner records its internal-review declaration in the handoff consumed by the existing preflight validator. The existing remediation-loop preflight state continues to retain iterations, final status, and convergence information; an over-threshold well-scoped handoff additionally requires a process-defect investigation that identifies the deficient internal-review dimension.

- Data transformations and invariants: section counting starts after the requested heading and stops before the next equal-or-shallower heading; unrelated checkboxes must not affect the result. Numeric acceptance-criterion facts are approved only when the independent derivations agree.
- Caching or persistence details: no cache is introduced. Research records, plan handoffs, hook output, focused test fixtures, and existing remediation state are the authoritative evidence.
- Migration or backfill requirements (if any): none. Existing approved numeric criteria are not retroactively changed by this item.

## Constraints & Risks

Preserve issue #586's single executor-owned validation-only preflight loop, convergence signals, and iteration ceiling. Do not replace preflight with planner self-review or create a second clearance loop.

The scope is limited to the Claude-native runtime surfaces and their required published bundle mirrors. Codex agents, skills, prompts, hooks, and runtime contracts are outside scope. The existing generic plan-progress counter remains outside scope because it measures plan tasks rather than acceptance criteria in generated requirements documents.


## Implementation Strategy

- Implementation scope (what changes, not sequencing): update the Claude research, PRD, planner, preflight, remediation, acceptance-criteria, and parallel-intake contracts; add focused Claude hook, parser, and parallel-surface tests; copy every changed canonical Claude runtime file to its required published Claude bundle mirror.
- New classes/functions/commands to add or update: add a small pure, named-section Markdown checkbox counter only if no existing Claude runtime helper satisfies the contract; update the existing contract owners rather than adding a competing preflight workflow.
- Dependency changes (new/removed packages) and rationale: none. The section counter and tests use existing PowerShell and repository test tooling.
- Logging/telemetry additions and locations: emit contract-level planner-review and preflight process-defect information through existing handoff, hook, and remediation artifacts.
- Rollout plan (feature flags, staged deploys, fallback path): publish canonical Claude changes with byte-identical bundle mirrors and verify repository bundle-parity tests before release.

## Acceptance Criteria

- [x] A numeric count, enumeration, or population is approved in `spec.md` only when its research record identifies the complete symbol or method family, inclusion and exclusion rules, the member set, and an independently constructed cross-check that agrees with the first derivation; focused tests reject a numeric claim without that provenance.
- [ ] The Claude planner completes and records a preflight-shaped internal review of citation-to-tree verification, acceptance-criterion-to-implementation traceability, and scope-boundary consistency before executor preflight; the existing issue #586 validation-only preflight loop remains intact, and a well-scoped handoff requiring more than one preflight round produces a process-defect investigation identifying the incomplete review dimension.
- [x] Each reusable counter for checkbox items in generated requirements documents requires a named section and counts only between that heading and the next equal-or-shallower heading; focused fixture coverage proves that unrelated checkboxes outside the section do not affect the result.
- [x] Initial parallel intake requires the complete item set through `/parallel-plan`; `/parallel-add` admits an item only after execution has started and rejects pending or not-started runs with instructions to consolidate the initial set through `/parallel-plan`, with focused contract coverage for both paths.

## Definition of Done

- [ ] Acceptance criteria are documented and mapped to focused Claude contract tests.
- [ ] Claude research, PRD, planner, preflight, remediation, generated-document counting, and parallel-intake behavior meet the documented acceptance criteria.
- [ ] Focused positive, rejection, and boundary-path tests cover numeric provenance, internal-review evidence, section boundaries, unrelated checkboxes, and pending parallel intake.
- [ ] Required canonical Claude runtime files and published bundle mirrors are byte-identical.
- [ ] Documentation and contract references use the Claude-native scope and preserve issue #586 terminology.
- [ ] The applicable repository toolchain loop completes without new failures.

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas
- [ ] Integration scenarios
- [ ] CLI/API examples

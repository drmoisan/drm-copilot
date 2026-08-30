# Feature Audit: Claude Planning Integrity (#593)

**Audit Date:** 2026-08-29
**Feature Folder:** `docs/features/active/2026-08-29-claude-planning-integrity-593`
**Base Branch:** `main` at `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`
**Head Branch:** `feature/claude-planning-integrity-593` at `56c2611245dfde879f44ca7cb72762e7fb0bf035`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

## Scope and Baseline

- **Primary evidence:** `artifacts/pr_context.summary.txt`, generated 2026-08-29 17:50:57 UTC and bound to the reviewed head.
- **Secondary baseline:** `artifacts/pr_context.appendix.txt`, same timestamp and head binding.
- **Feature evidence:** `evidence/qa-gates/numeric-provenance-powershell-tests-and-coverage.2026-08-29T13-15.md`, bundle parity evidence, and the review-time focused test runs.
- **Requirements sources:** `spec.md` and `user-story.md`, resolved from `issue.md` work mode `full-feature`.
- **Scope note:** Entire `25d4cb8..56c2611` diff reviewed; no Codex runtime contract files are modified.

## Acceptance Criteria Inventory

1. A numeric count, enumeration, or population is approved in `spec.md` only when its research record identifies the complete symbol or method family, inclusion and exclusion rules, the member set, and an independently constructed cross-check that agrees with the first derivation; focused tests reject a numeric claim without that provenance.
2. The Claude planner completes and records a preflight-shaped internal review of citation-to-tree verification, acceptance-criterion-to-implementation traceability, and scope-boundary consistency before executor preflight; the existing issue #586 validation-only preflight loop remains intact, and a well-scoped handoff requiring more than one preflight round produces a process-defect investigation identifying the incomplete review dimension.
3. Each reusable counter for checkbox items in generated requirements documents requires a named section and counts only between that heading and the next equal-or-shallower heading; focused fixture coverage proves that unrelated checkboxes outside the section do not affect the result.
4. Initial parallel intake requires the complete item set through `/parallel-plan`; `/parallel-add` admits an item only after execution has started and rejects pending or not-started runs with instructions to consolidate the initial set through `/parallel-plan`, with focused contract coverage for both paths.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| 1 | Numeric provenance enforcement | FAIL | PRD validator implementation and unit tests exist, but it is absent from `prd-feature` `SubagentStop` registration in canonical and bundle settings. | Full settings inspection; focused Pester and Python reruns. | The validation cannot enforce the lifecycle condition until registered. |
| 2 | Planner internal review and process-defect handling | PASS | Planner contract, agent, hook, and remediation handoff changes; focused Pester coverage. | Focused Pester rerun. | Existing executor-owned preflight remains the clearance mechanism. |
| 3 | Named-section checkbox counter | PASS | `GeneratedDocumentCounters.psm1` and inline Pester fixture with outside-before and outside-after checkboxes. | Focused Pester rerun; section-bounded count independently returned four AC items in each requirements file. | Counter stops at equal-or-shallower headings. |
| 4 | Batched parallel intake | PASS | `parallel-plan` and `parallel-add` contracts plus focused Python test. | Focused Python rerun. | Pending/not-started add is explicitly rejected and directs consolidated planning. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

- **PASS:** 3 criteria
- **FAIL:** 1 criterion
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria

The blocker is the unregistered PRD-output validation hook. Remediation must add the canonical and published settings registrations and a test that would fail if either registration is missing.

## Acceptance Criteria Check-off

No acceptance-criteria source change was made in this review. AC2 through AC4 were already checked and remain supported by current evidence. AC1 remains unchecked in both authoritative sources because its runtime enforcement is incomplete.

### AC Status Summary

- Source: `docs/features/active/2026-08-29-claude-planning-integrity-593/spec.md` and `docs/features/active/2026-08-29-claude-planning-integrity-593/user-story.md`
- Total AC items: 4 per source, counted with `Get-NamedSectionCheckboxCount` scoped to `## Acceptance Criteria`
- Checked off: 3 per source
- Remaining: 1 per source
- Item remaining: numeric provenance enforcement criterion (AC1)

| Source File | Total AC | Checked | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 4 | 3 | 1 | AC1 remains unchecked. |
| `user-story.md` | 4 | 3 | 1 | AC1 remains unchecked. |

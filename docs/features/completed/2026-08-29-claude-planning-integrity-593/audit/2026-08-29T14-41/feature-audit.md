# Feature Audit: Claude Planning Integrity (#593)

**Audit Date:** 2026-08-29
**Feature Folder:** `docs/features/active/2026-08-29-claude-planning-integrity-593`
**Base Branch:** `main`
**Head Branch:** `feature/claude-planning-integrity-593` at `3658effcc58c946ee430c758fce666a5d451686c`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

## Scope and Baseline

- **Base branch:** `main` at `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`
- **Head branch/commit:** `feature/claude-planning-integrity-593` at `3658effcc58c946ee430c758fce666a5d451686c`
- **Merge base:** `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`
- **Evidence sources:** Fresh `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, branch diff, feature evidence, and direct focused verification.
- **Requirements source:** `spec.md` and `user-story.md`; `issue.md` marks this item `full-feature`.

## Acceptance Criteria Inventory

1. A numeric count, enumeration, or population is approved in `spec.md` only when its research record identifies the complete symbol or method family, inclusion and exclusion rules, the member set, and an independently constructed cross-check that agrees with the first derivation; focused tests reject a numeric claim without that provenance.
2. The Claude planner completes and records a preflight-shaped internal review of citation-to-tree verification, acceptance-criterion-to-implementation traceability, and scope-boundary consistency before executor preflight; the existing issue #586 validation-only preflight loop remains intact, and a well-scoped handoff requiring more than one preflight round produces a process-defect investigation identifying the incomplete review dimension.
3. Each reusable counter for checkbox items in generated requirements documents requires a named section and counts only between that heading and the next equal-or-shallower heading; focused fixture coverage proves that unrelated checkboxes outside the section do not affect the result.
4. Initial parallel intake requires the complete item set through `/parallel-plan`; `/parallel-add` admits an item only after execution has started and rejects pending or not-started runs with instructions to consolidate the initial set through `/parallel-plan`, with focused contract coverage for both paths.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| 1 | Numeric provenance | PASS | PRD and research hooks require complete family, exhaustive scope, independent strategies, member sets, count agreement, and explicit comparison; dedicated PRD registration is now active in both settings files. | Focused 77 Pester and 31 pytest checks; direct exact-entry parsing and 15-file parity check. | Complete-omission, broad-only, duplicate, extra-command, wrong-path, wrong-type, wrong-matcher, and divergence fixtures are present in both language suites. |
| 2 | Planner self-review and preflight process defect | FAIL | `.claude/hooks/validate-planner-output.ps1:113-120` accepts the bare three-label declaration. | `Test-HasPlannerInternalReview` direct invocation returned `True` for a declaration containing no record details. | This contradicts P2-T3’s requirement to reject missing citation enumeration or traceability. Existing process-defect wording does not compensate for missing enforcement. |
| 3 | Named-section counter | PASS | `Get-NamedSectionCheckboxCount` takes `Heading`, begins after the matched heading, and stops at equal-or-shallower headings. | Focused Pester passed; counter fixture has outside-before, nested, and outside-after checkboxes. | No whole-file fallback is present. |
| 4 | Batched parallel intake | PASS | `parallel-plan` requires the complete initial set; `parallel-add` rejects pending/not-started runs and directs operators to `/parallel-plan`. | Focused pytest passed; contract inspection covered pending rejection and execution-started admission. | The implementation keeps this distinct from execution-started incremental admission. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

- **PASS:** 3 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion

**Top gap preventing PASS:** enforce the complete self-review record before executor preflight, including outcome fields, current-tree citation enumeration, per-AC implementation/test/evidence mapping, scope-boundary result, and explicit unresolved-gap disposition. Add negative tests for each missing or blocked component and parity coverage for any mirrored runtime change.

## Acceptance Criteria Check-off

AC2 is not verified and must remain unchecked in both authoritative full-feature sources. AC1, AC3, and AC4 remain checked.

### AC Status Summary

- Source: `docs/features/active/2026-08-29-claude-planning-integrity-593/spec.md` and `docs/features/active/2026-08-29-claude-planning-integrity-593/user-story.md`
- Total AC items: 4 per source
- Checked off (delivered): 3 per source
- Remaining (unchecked): 1 per source
- Items remaining: AC2, planner self-review and process-defect behavior.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 4 | 3 | 1 | AC2 unchecked by this review. |
| `user-story.md` | 4 | 3 | 1 | AC2 unchecked by this review. |

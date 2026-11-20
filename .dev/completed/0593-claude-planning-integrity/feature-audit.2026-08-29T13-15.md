# Feature Audit: Claude Planning Integrity (#593)

**Audit Date:** 2026-08-29
**Feature Folder:** `docs/features/active/2026-08-29-claude-planning-integrity-593`
**Base Branch:** `main` at `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`
**Head Branch:** `feature/claude-planning-integrity-593` at `4c87251f2783c0e4383fe33545fd8b8df5eded53`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Merge base:** `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`.
- **Primary evidence:** `artifacts/pr_context.summary.txt`, generated at `2026-08-29 17:11:57 UTC` and bound to the reviewed HEAD.
- **Secondary evidence:** `artifacts/pr_context.appendix.txt`, with the same generation timestamp and HEAD binding.
- **Feature evidence:** `evidence/qa-gates/` and `evidence/baseline/` under this feature folder.
- **Requirements sources:** `spec.md` and `user-story.md`, as required by the persisted `full-feature` work-mode marker in `issue.md`.
- **Scope note:** The review covers the complete feature-vs-base diff. It does not narrow to a plan subset.

## Acceptance Criteria Inventory

The two authoritative sources contain the same four criteria under `## Acceptance Criteria`.

1. Numeric facts in approved `spec.md` criteria require complete family provenance and an independently constructed agreeing cross-check.
2. Claude planner handoffs require an internal review before the existing executor preflight, and excess rounds require process-defect investigation.
3. Generated-document checkbox counters must be named-section bounded and tested against unrelated outside-section checkboxes.
4. Initial parallel intake must use `/parallel-plan`; `/parallel-add` must reject pending or not-started runs.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| 1 | Numeric facts require exhaustive family provenance and independent agreement | FAIL | Both hooks only validate labels and equal counts; the code review identifies the missing independent-search proof. | Static inspection of `Test-NumericDerivationEvidence` in both hook files. | A duplicate `Cross-check Count` can be accepted without a second search. |
| 2 | Planner internal review and excess-round process-defect investigation | PASS | Planner contract, planner agent, hook tests, and remediation skill contain the three review dimensions and `preflight.iterations > 1` rule. | Recorded focused Pester evidence and static review. | Existing executor-owned preflight remains intact. |
| 3 | Named-section generated-document counter | PASS | `Get-NamedSectionCheckboxCount` starts after the named heading and stops at the next equal-or-shallower heading; fixture contains outside checkboxes. | Imported counter and independent bounded scan both reported four criteria in each authoritative source. | The two strategies agreed. |
| 4 | Batched initial parallel intake | PASS | `parallel-plan` names the multi-item intake form; `parallel-add` rejects pending/not-started runs and permits admission after execution starts. | Recorded focused Python contract evidence and static review. | Contract coverage includes both paths. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 3 logical criteria in both authoritative sources.
- **FAIL:** 1 logical criterion in both authoritative sources.

**Top gap preventing PASS:**

1. Numeric provenance does not require a recorded second independently constructed search; matching counts are insufficient.

**Recommended follow-up verification steps:**

1. Add enforceable fields for distinct primary and cross-check derivations, and tests that reject a copied or undocumented cross-check count.
2. Mirror changed Claude runtime files and rerun focused PowerShell/Python contracts, coverage, and bundle parity.

## Acceptance Criteria Check-off

The source criteria were initially marked complete by execution evidence. This review corrects the status for the failed first criterion in both authoritative files; the remaining three criteria stay checked after individual evaluation.

### AC Status Summary

- Source: `spec.md` and `user-story.md`.
- Each source's `## Acceptance Criteria` section contains four items by the named-section counter and by an independent heading-bounded scan.
- The first item is unchecked in both sources pending remediation; the remaining three are checked.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 4 | 3 | 1 | First numeric-provenance criterion fails. |
| `user-story.md` | 4 | 3 | 1 | Same criterion is duplicated for full-feature tracking. |

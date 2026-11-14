# Preflight Fixes - Issue 1034 Remediation Cycle 4

Timestamp: 2026-11-07T14-00
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T05-55.md
Signal: PREFLIGHT: ALL CLEAR
Snapshot: the pre-fix plan text is kept at SCRATCH/issue-1034-c4-plan-snapshot.md for diffing.

## Fixes

1. `## Execution Rules`, unchanged-file bullet | unsatisfiable literal anchor, meaning kept | `HELPER` and `HELPER_BUNDLE` were added by this feature after `MERGE_BASE` (`git diff --stat MERGE_BASE HEAD` reports 334 insertions in each), so "unchanged against `MERGE_BASE`" cannot hold for them. The bullet now anchors the helper pair to `CYCLE_START`. The eight scanner files keep the `MERGE_BASE` anchor, under which they are verified unchanged.
2. `[P2-T7]` acceptance | unsatisfiable literal anchor, meaning kept | Removed the two helper paths from the `git diff MERGE_BASE HEAD` operand list, which already contained 668 added lines and so could not be empty. The task's existing clause, under which the only paths changed outside `FEATURE/` since `CYCLE_START` are `HOOK` and `HOOK_BUNDLE`, already asserts that the helper pair is unchanged in this cycle. The clause now says so explicitly. The eight scanner paths and the empty-diff assertion are unchanged.
3. `[P2-T8]` | line-number citation (design-level contract; G11's path form needs a file extension and does not report the `spec:` and `story:` forms) | "the criteria at spec:516, story:65 and story:73" replaced by "criteria E1 and U2 of `## Acceptance Criteria Traceability`".
4. `## Acceptance Criteria Traceability` preamble | line-number citation | `spec:516`, `story:65` and `story:73` replaced by the criterion's position under `## Acceptance Criteria` and a short description of its content.
5. `## Pre-Mortem`, `CI-only behavior` bullet | line-number citation | `spec:544` replaced by "the CI-dependent criterion of `SPEC`".

## Checks Made Without a Fix

- Named-form rows: SCRATCH/issue-1034-c4-driver.ps1, run against the current `HOOK` (decision code is unchanged by this cycle). R1 to R9 each allow with 0 lookups, C1 to C3 allow with 0 lookups, and C4 and C5 each record 1 lookup. R3 emits the N19 error text on the error stream, as the plan anticipates.
- The anchors `Residual limits`, `What it establishes`, `Outside what it can observe` and `Ambient state` in the `HOOK` help block resolve, and so do the spec heading `### Hook` and the two bullet lines. `in the unquoted text` occurs once in each target. `HOOK` is 342 logical lines.
- `Get-DocsCompleteGateUnquotedView` joins the `MaskedText` of `Read-CommandLineSegment`, and its `.DESCRIPTION` holds the sentence quoted in `## Out of Scope by Owner Decision`.
- The test search of `## Existing Asserting Tests and Dispositions` finds only the unrelated `MermaidLineScanner.Tests.ps1` among the header phrases; no test asserts header or `SPEC` text.
- The resource search for the feature folder name under `extensions/drm-copilot/resources/` finds no file.
- `Invoke-PoshQCParallelTest` takes `-Root` and `-WorkerCount`; the CI step `Run tests with Pytest and coverage` exists; the three policy-audit templates exist.
- The checkpoint route is `large`; the Poetry environment resolves to the worktree's own `.venv`.

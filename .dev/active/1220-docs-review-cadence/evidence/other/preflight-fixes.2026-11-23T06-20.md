# Preflight Fixes - docs-review-cadence (#1220)

Timestamp: 2026-11-23T06-20
Plan: .dev/active/1220-docs-review-cadence/plan.2026-11-23T00-39.md
Command: in-place task-text edits during single-pass preflight (no task added, removed, or reordered)
EXIT_CODE: 0
Output Summary: 3 trivial fixes applied; substantive defects returned to the planner separately.

## Fixes

1. [P4-T5] | stale anchor | The scope diff was anchored on the merge base of `origin/main` and `HEAD`. `spec.md` states the no-diff conditions for `DocsCompleteGate.psm1` and `DocsStaleness.psm1` against the integration base, and `.dev/epics/documentation-estate-families/epic.md` (`## Decomposition and Waves`) shows that the wave-1 feature docs-family-gate-and-ia edits `DocsCompleteGate` and the MCP tools. After the rebase onto the integration tip, an `origin/main` anchor would include those upstream changes and the condition could not be met. The anchor now reads: the merge base of `origin/epic/documentation-estate-families-integration` and `HEAD`. The remote ref exists. What is asserted stays the same: this feature's own diff.
2. [P4-T6] | stale anchor | The self-review "branch diff from the merge base" now names the same integration-base anchor as P4-T5, so the review covers only this feature's diff.
3. [P2-T3] | disposition completeness | Added `DocsHashLineEnding.Tests.ps1` and `EndToEndDocumentationEstate.Tests.ps1` to the `Unchanged tests` line. Both run `validate` in docs-complete mode, and both are unchanged because they are unaffected: on the current tree no test fixture carries `required_families`, `legacy_exclusions`, or `review_due` (verified by a search of `tests/`). This adds no assertion.

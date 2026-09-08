# P8-T1 — acceptance-criteria check-off record (PARTIAL)

Timestamp: 2026-09-08T02-45
Task: [P8-T1]
AC source: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`,
section `## Acceptance Criteria`, 38 items, identified `AC-01` through `AC-38` in file order.
Work Mode: `full-bug` (persisted marker in `issue.md`), so `spec.md` is the sole AC source.

## Status

This record is PARTIAL and [P8-T1] is NOT complete. 20 of the 38 criteria are checked off in
`spec.md`; the remaining 18 are left unchecked because the evidence artifact each one names does
not exist yet. Every one of the 18 depends on a bats gate in Phase 5 or a toolchain gate in
Phase 7, neither of which this executor runs.

Measured checkbox counts in `spec.md` after this check-off:

- count of `- [ ]` lines = 21 (3 severity radios in `## Context` plus 18 pending criteria)
- count of `- [x]` lines = 25 (5 pre-existing checked boxes plus 20 criteria checked here)

The [P8-T2] target pair is 3 and 43. That pair is reached only after the 18 pending criteria are
checked, which requires the Phase 5 and Phase 7 gate results.

The three checkboxes at `spec.md:24`, `:26`, and `:27` are the Blocker / Medium / Low severity
radios in `## Context`. They are not acceptance criteria and were not touched.

## Per-criterion table

| ID | spec line | Satisfying plan task(s) | Evidence | Status |
|---|---|---|---|---|
| AC-01 | :616 | P4-T1..P4-T5, P5-T1, P5-T6 | `evidence/qa-gates/dirt-lib-source-guard.2026-09-08T02-15.md`; `evidence/regression-testing/source-chain-wiring.2026-09-08T02-30.md`; `evidence/qa-gates/wrapper-source-block.2026-09-08T02-45.md` | CHECKED |
| AC-02 | :620 | P2-T1, P4-T3 | classify-suite test 1 reported `ok` in `evidence/regression-testing/pass-after-dirt-classify.2026-09-08T02-30.md` | CHECKED |
| AC-03 | :623 | P2-T3, P4-T3 | classify-suite test 4 reported `ok`, same artifact | CHECKED |
| AC-04 | :626 | P2-T4, P4-T3 | classify-suite test 6 reported `ok`, same artifact | CHECKED |
| AC-05 | :629 | P2-T5, P4-T3 | classify-suite test 8 reported `ok`, same artifact | CHECKED |
| AC-06 | :632 | P2-T6, P4-T2, P4-T4 | classify-suite tests 9 and 10 reported `ok`, same artifact | CHECKED |
| AC-07 | :636 | P2-T7, P4-T3, P4-T4 | classify-suite test 13 reported `ok`, same artifact | CHECKED |
| AC-08 | :639 | P4-T3 | classify-suite test 15 reported `ok`, same artifact | CHECKED |
| AC-09 | :643 | P4-T3 | classify-suite test 12 reported `ok`, same artifact; fail-before recorded in `evidence/regression-testing/fail-before-dirt-classify.2026-09-08T02-05.md` | CHECKED |
| AC-10 | :646 | P4-T3 | classify-suite test 5 reported `ok`, same artifact pair | CHECKED |
| AC-11 | :649 | P4-T3 | classify-suite test 2 reported `ok`, same artifact pair | CHECKED |
| AC-12 | :651 | P4-T3 | classify-suite test 7 reported `ok`, same artifact pair | CHECKED |
| AC-13 | :653 | P2-T10, P4-T3, P4-T5 | classify-suite test 14 recorded `ok`; clearing-suite test 6 pending `evidence/regression-testing/pass-after-dirt-clear.<ts>.md` from [P5-T9] | PENDING |
| AC-14 | :656 | P2-T2, P4-T3 | classify-suite test 3 reported `ok` in `evidence/regression-testing/pass-after-dirt-classify.2026-09-08T02-30.md` | CHECKED |
| AC-15 | :659 | P4-T4, P5-T3 | classify-suite test 16 recorded `ok`; test 19 pending `evidence/regression-testing/pass-after-dirt-classify-full.<ts>.md` from [P5-T3] | PENDING |
| AC-16 | :663 | P4-T4 | classify-suite test 16 recorded `ok`; regression-suite test 11 pending `evidence/regression-testing/regression-byte-identity-postchange.<ts>.md` from [P5-T10] | PENDING |
| AC-17 | :666 | P2-T12, P4-T4 | classify-suite test 17 reported `ok` in `evidence/regression-testing/pass-after-dirt-classify.2026-09-08T02-30.md` | CHECKED |
| AC-18 | :669 | P2-T16, P3-T1, P5-T3 | pending `evidence/regression-testing/regression-byte-identity-postchange.<ts>.md` from [P5-T10] | PENDING |
| AC-19 | :673 | P2-T17, P3-T1, P5-T5 | pending `evidence/regression-testing/regression-byte-identity-postchange.<ts>.md` from [P5-T10] | PENDING |
| AC-20 | :677 | P5-T1, P5-T4, P5-T12 | `evidence/qa-gates/actions-lib-header-scope.2026-09-08T02-45.md` records the unchanged `remove_worktree_safe`; the suite pass is pending `evidence/regression-testing/deletion-hard-failures-unmodified.<ts>.md` from [P5-T12] | PENDING |
| AC-21 | :681 | P5-T8 | pending `evidence/regression-testing/pass-after-cli-flag.<ts>.md` from [P5-T11] | PENDING |
| AC-22 | :684 | P5-T8 | pending `evidence/regression-testing/pass-after-cli-flag.<ts>.md` from [P5-T11] | PENDING |
| AC-23 | :686 | P2-T8, P4-T5, P5-T5 | pending `evidence/regression-testing/pass-after-dirt-clear.<ts>.md` from [P5-T9] | PENDING |
| AC-24 | :691 | P2-T9, P4-T5, P5-T5 | pending `evidence/regression-testing/pass-after-dirt-clear.<ts>.md` from [P5-T9]; the flag prohibition is additionally covered by `evidence/qa-gates/clean-flags.2026-09-08T02-15.md` | PENDING |
| AC-25 | :696 | P2-T11, P5-T5 | pending `evidence/regression-testing/pass-after-dirt-clear.<ts>.md` from [P5-T9] | PENDING |
| AC-26 | :701 | P5-T5, P5-T13 | `evidence/qa-gates/worktree-remove-call-sites.2026-09-08T02-45.md` records the two-call-site half; clearing-suite test 3 pending from [P5-T9] | PENDING |
| AC-27 | :704 | P4-T2, P5-T3 | pending clearing-suite test 10 in `evidence/regression-testing/pass-after-dirt-clear.<ts>.md` from [P5-T9] | PENDING |
| AC-28 | :707 | P1-T1 | `evidence/qa-gates/stub-env-log.2026-09-07T20-48.md`, the set-versus-unset two-invocation observation | CHECKED |
| AC-29 | :709 | P1-T2, P4-T2, P4-T4 | pending clearing-suite test 11 in `evidence/regression-testing/pass-after-dirt-clear.<ts>.md` from [P5-T9] | PENDING |
| AC-30 | :711 | P2-T6, P4-T2 | classify-suite test 11 reported `ok` in `evidence/regression-testing/pass-after-dirt-classify.2026-09-08T02-30.md` | CHECKED |
| AC-31 | :714 | P7-T1, P7-T2, P7-T3, P7-T8 | pending `evidence/qa-gates/single-consecutive-pass.<ts>.md` | PENDING |
| AC-32 | :716 | P7-T4, P7-T5 | pending `evidence/qa-gates/coverage-delta.<ts>.md` | PENDING |
| AC-33 | :718 | P0-T7, P4-T7, P7-T7 | `evidence/other/line-count-remeasure.2026-09-07T20-48.md` and `evidence/qa-gates/dirt-lib-size.2026-09-08T02-15.md` cover the pre-change and new-library measurements; the post-change sweep is pending `evidence/qa-gates/file-size-limit.<ts>.md` from [P7-T7] | PENDING |
| AC-34 | :720 | P6-T1 | `evidence/qa-gates/doc-literals.2026-09-08T02-45.md`; `evidence/qa-gates/pytest-push-down-contract.2026-09-08T02-45.md` | CHECKED |
| AC-35 | :723 | P6-T2, P6-T3 | `evidence/qa-gates/doc-literals.2026-09-08T02-45.md`; `evidence/qa-gates/pytest-push-down-contract.2026-09-08T02-45.md` | CHECKED |
| AC-36 | :728 | P6-T4 | `evidence/qa-gates/doc-literals.2026-09-08T02-45.md`; `evidence/qa-gates/pytest-push-down-contract.2026-09-08T02-45.md` | CHECKED |
| AC-37 | :733 | P6-T5, P6-T6 | `evidence/qa-gates/skill-mirror-parity.2026-09-08T02-45.md`; `evidence/qa-gates/pytest-push-down-contract.2026-09-08T02-45.md` | CHECKED |
| AC-38 | :736 | P5-T2, P5-T7 | `evidence/qa-gates/doc-literals.2026-09-08T02-45.md` covers the contract-comment half; the `--help` half is pinned by CLI test 4, pending `evidence/regression-testing/pass-after-cli-flag.<ts>.md` from [P5-T11] | PENDING |

## Summary

- Total AC items: 38
- Checked off: 20 (AC-01 through AC-12, AC-14, AC-17, AC-28, AC-30, AC-34 through AC-37)
- Remaining: 18 (AC-13, AC-15, AC-16, AC-18 through AC-27, AC-29, AC-31 through AC-33, AC-38)

Every remaining item is blocked on a gate this executor does not run, not on unfinished
implementation. The implementation for all 18 is in the tree and was locally pre-validated through
scratchpad harnesses; the missing element is the recorded bats or toolchain measurement that each
criterion names as its evidence. Checking any of them off now would mean marking a criterion whose
evidence artifact does not exist.

`Outcome Summary:` is deliberately absent from this artifact. It is [P8-T3]'s field and requires the
[P7-T5] coverage delta, which has not been measured.

# Acceptance-criteria check-off state after the Phase 7 remediation

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T03-25Z (nominal run-timestamp scheme).
Source file: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`,
`## Acceptance Criteria` section. Work Mode is `full-bug`, so `spec.md` is the sole AC source.

Total: 38. Checked: 36. Remaining: 2 (AC-31, AC-32), both blocked on the coverage gate.

This supersedes `ac-checkoff.2026-09-08T02-45.md`, which recorded the state before Phase 5's
gates were run.

| ID | Spec line | Satisfying task(s) | Proof | State |
|---|---|---|---|---|
| AC-01 | :616 | P4-T1..T5, P5-T1, P5-T6 | `evidence/qa-gates/dirt-lib-source-guard.2026-09-08T02-15.md` | [x] |
| AC-02 | :620 | P2-T1, P4-T3 | classify suite test 1 | [x] |
| AC-03 | :623 | P2-T3, P4-T3 | classify suite test 4 | [x] |
| AC-04 | :626 | P2-T4, P4-T3 | classify suite test 6 | [x] |
| AC-05 | :629 | P2-T5, P4-T3 | classify suite test 8 | [x] |
| AC-06 | :632 | P2-T6, P4-T2, P4-T4 | classify suite tests 9 and 10 | [x] |
| AC-07 | :636 | P2-T7, P4-T3, P4-T4 | classify suite test 13 | [x] |
| AC-08 | :639 | P4-T3 | classify suite test 15 | [x] |
| AC-09 | :643 | P4-T3 | classify suite test 12 | [x] |
| AC-10 | :646 | P4-T3 | classify suite test 5 | [x] |
| AC-11 | :649 | P4-T3 | classify suite test 2 | [x] |
| AC-12 | :651 | P4-T3 | classify suite test 7 | [x] |
| AC-13 | :653 | P2-T10, P4-T3, P4-T5 | classify suite test 14 and clearing suite test 6, `evidence/regression-testing/pass-after-dirt-clear.2026-09-08T03-30.md` | [x] |
| AC-14 | :656 | P2-T2, P4-T3 | classify suite test 3 | [x] |
| AC-15 | :659 | P4-T4, P5-T3 | classify suite tests 16 and 19, `evidence/regression-testing/pass-after-dirt-classify-full.2026-09-08T03-30.md` | [x] |
| AC-16 | :663 | P4-T4 | classify suite test 16 and regression suite test 11, `evidence/regression-testing/regression-byte-identity-postchange.2026-09-08T03-30.md` | [x] |
| AC-17 | :666 | P2-T12, P4-T4 | classify suite test 17 | [x] |
| AC-18 | :669 | P2-T16, P3-T1, P5-T3 | regression suite tests 1-8, `evidence/regression-testing/regression-byte-identity-postchange.2026-09-08T03-30.md` | [x] |
| AC-19 | :673 | P2-T17, P3-T1, P5-T5 | regression suite tests 9 and 10, same artifact as AC-18 | [x] |
| AC-20 | :677 | P5-T1, P5-T4, P5-T12 | `evidence/regression-testing/deletion-hard-failures-unmodified.2026-09-08T03-30.md` (28 ok, diff hunks enumerated) | [x] |
| AC-21 | :681 | P5-T8 | CLI suite tests 8 and 9, `evidence/regression-testing/pass-after-cli-flag.2026-09-08T03-30.md` | [x] |
| AC-22 | :684 | P5-T8 | CLI suite test 10, same artifact as AC-21 | [x] |
| AC-23 | :686 | P2-T8, P4-T5, P5-T5 | clearing suite tests 4 and 5, `evidence/regression-testing/pass-after-dirt-clear.2026-09-08T03-30.md` | [x] |
| AC-24 | :691 | P2-T9, P4-T5, P5-T5 | clearing suite tests 1, 2, 3, same artifact as AC-23 | [x] |
| AC-25 | :696 | P2-T11, P5-T5 | clearing suite tests 8 and 9, same artifact as AC-23 | [x] |
| AC-26 | :701 | P5-T5, P5-T13 | `evidence/qa-gates/worktree-remove-call-sites.2026-09-08T02-45.md`, re-measured this run: two matches at `cleanup_worktrees_actions_lib.sh:191` and `:292`, neither carrying `--force` | [x] |
| AC-27 | :704 | P4-T2, P5-T3 | clearing suite test 10, same artifact as AC-23 | [x] |
| AC-28 | :707 | P1-T1 | `evidence/qa-gates/stub-env-log.2026-09-07T20-48.md` | [x] |
| AC-29 | :709 | P1-T2, P4-T2, P4-T4 | clearing suite test 11, same artifact as AC-23 | [x] |
| AC-30 | :711 | P2-T6, P4-T2 | classify suite test 11 | [x] |
| AC-31 | :714 | P7-T1, P7-T2, P7-T3, P7-T8 | format, check and test all EXIT_CODE 0 in one uninterrupted sequence (`shell-qc-format`, `shell-qc-check`, `shell-qc-test`, all `.2026-09-08T03-30.md`); the P7-T8 declaration artifact is not yet writable because it also requires P7-T4 | [ ] |
| AC-32 | :716 | P7-T4, P7-T5 | none; kcov is absent and WSL is denied, see `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T03-30.md` | [ ] |
| AC-33 | :718 | P0-T7, P4-T7, P7-T7 | `evidence/qa-gates/file-size-limit.2026-09-08T03-30.md`, max 496 of 500 | [x] |
| AC-34 | :720 | P6-T1 | `evidence/qa-gates/doc-literals.2026-09-08T02-45.md`, `evidence/qa-gates/pytest-push-down-contract-final.2026-09-08T03-30.md` | [x] |
| AC-35 | :723 | P6-T2, P6-T3 | same two artifacts as AC-34 | [x] |
| AC-36 | :728 | P6-T4 | same two artifacts as AC-34 | [x] |
| AC-37 | :733 | P6-T5, P6-T6 | `evidence/qa-gates/skill-mirror-parity.2026-09-08T02-45.md`, `evidence/qa-gates/pytest-push-down-contract-final.2026-09-08T03-30.md` (11 passed, equal to baseline) | [x] |
| AC-38 | :736 | P5-T2, P5-T7, P6-T7 | `evidence/qa-gates/doc-literals.2026-09-08T02-45.md` and CLI suite test 11 | [x] |

## Why AC-31 is left unchecked although its three named stages passed

The criterion's own text names format, check and test only, and all three completed with no error
in one consecutive sequence this run. It is nonetheless left unchecked because the plan's
traceability row for AC-31 also names P7-T8, and P7-T8's acceptance requires four artifacts each
carrying `EXIT_CODE: 0`, including P7-T4's. Checking AC-31 now would assert a completed loop
declaration that does not exist. This is a deliberate fail-closed choice: the check-off protocol
requires evidence before check-off, and the plan names an artifact that has not been produced.

## Outcome Summary (partial; P8-T3 is not complete)

- P0-T7 measured line counts: recorded in `evidence/other/line-count-remeasure.2026-09-07T20-48.md`
  and re-measured at P7-T7 this run. The largest production file is
  `scripts/bash/cleanup_worktrees_lib.sh` at 496 lines, four below the 500 cap.
- Extraction contingency (P0-T8): did NOT run. `scripts/bash/cleanup_worktrees_report_lib.sh` was
  not created and does not exist.
- P7-T5 coverage delta: NOT AVAILABLE. Baseline is 93.5 line coverage and the threshold is 85.0,
  but no post-change value exists, so no delta can be stated. This is the single field that keeps
  P8-T3 incomplete.

The spec header `Status` field is deliberately left unchanged for the same reason: P8-T3's
acceptance requires the Outcome Summary to name the coverage delta, and it cannot.

# P7-T8 — the single consecutive clean pass is NOT declarable yet

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T03-22Z (nominal run-timestamp scheme).

This artifact is deliberately NOT named `single-consecutive-pass.<run-timestamp>.md`. That
filename is the plan's declaration of a completed loop, and the loop is not complete. Writing it
under the declared name would assert a pass that three of the four steps support and the fourth
does not.

## State of the four toolchain steps, run in one uninterrupted sequence

| Task | Artifact | EXIT_CODE | Result |
|---|---|---|---|
| P7-T1 format | `shell-qc-format.2026-09-08T03-30.md` | 0 | PASS; before and after digests identical at `642907b7252c94350acbb6909218f27d097521ce93dc1900730ceccb5ced1db7` |
| P7-T2 check | `shell-qc-check.2026-09-08T03-30.md` | 0 | PASS; no shfmt hunk, no shellcheck finding |
| P7-T3 test | `shell-qc-test.2026-09-08T03-30.md` | 0 | PASS; 390 tests, 0 failures, delta over baseline 47 |
| P7-T4 coverage | `shell-qc-test-coverage.2026-09-08T03-30.md` | 127 | INCOMPLETE; kcov absent, WSL denied |

Nothing in the sequence rewrote a file, so no restart is required for the three steps that ran.
P7-T4 did not fail on the code under test; it could not execute at all.

## What completes the declaration

A coverage run producing a numeric `Bash coverage (lines):` value over a tree containing the
Phase 4 through Phase 7 work, then the P7-T5 delta comparison against the 93.5 baseline and the
85.0 threshold. See the handback section of the P7-T4 artifact.

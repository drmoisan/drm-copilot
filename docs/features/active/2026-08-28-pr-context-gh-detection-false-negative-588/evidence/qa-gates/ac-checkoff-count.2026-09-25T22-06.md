# Acceptance-Criteria Check-Off Count ([P10-T20])

Timestamp: 2026-09-26T22-40

Command: `awk '/^## Acceptance Criteria/{f=1;next} /^## /{f=0} f&&/^- \[x\]/{x++} f&&/^- \[ \]/{u++} END{print "checked=" x+0, "unchecked=" u+0}' docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/spec.md`

EXIT_CODE: 0

Output Summary: `checked=19 unchecked=0`. The spec diff changes exactly 19 lines, each from `- [ ]` to `- [x]` within `## Acceptance Criteria`; no criterion text was modified.

Evidence map ([P10-T1]-[P10-T19]):
- AC 1: R1 passed (`evidence/regression-testing/ts-unit-tests.2026-09-25T22-06.md`).
- AC 2: R2, R3 passed ([P6-T3] artifact).
- AC 3: R4, R5, R6 passed ([P6-T3]).
- AC 4: R7 passed ([P6-T3]).
- AC 5: R8, R9, R10 passed ([P6-T3]).
- AC 6: D1, D2 passed ([P6-T3]).
- AC 7: S1 failed in `ts-fail-first` and passed in `ts-pass-after`; [P3-T2] complete.
- AC 8: C1 failed in [P2-T5] and passed in [P6-T1].
- AC 9: `scope-excluded-files` passed; [P5-T3]-[P5-T6] complete; [P6-T1] and [P6-T3] passed.
- AC 10: H1, H2 (exact-body `toBe`) passed ([P6-T3]); K1 passed ([P6-T1]); K1 failed in [P2-T5].
- AC 11: Python unit tests incl. the two `splitlines()[-1]` assertions passed (`py-unit-tests`); `OfflineGh` passed ([P6-T2]); it failed in [P2-T6] (`Mode: FAIL-FIRST`).
- AC 12: H4 and the two existing fallback tests passed ([P6-T3]); K2 passed ([P6-T1]); `test_build_issues_to_autoclose_section_keeps_available_fallback_texts` passed ([P6-T4]); `OnlineGh` empty case passed ([P6-T2]).
- AC 13: [P9-T1], [P9-T2], [P9-T3] passed (anchored to the sync SHA); H3 and `test_build_issues_to_autoclose_section_lists_pending_refs_when_gh_unavailable` passed.
- AC 14: `ts-jest-coverage`, `ts-coverage-delta`, `jest-threshold-entries` passed.
- AC 15: `py-coverage-json` and `py-coverage-delta` passed.
- AC 16: `hermeticity-new-tests` and `hermeticity-modified-tests` passed.
- AC 17: `line-caps` passed.
- AC 18: every Phase 7 artifact ([P7-T1]-[P7-T5]) records `Loop iteration: 2` and every Phase 8 artifact ([P8-T1]-[P8-T4]) records `Loop iteration: 2`; each passed, and neither iteration 2 changed a file.
- AC 19: `d5-documentation` passed.

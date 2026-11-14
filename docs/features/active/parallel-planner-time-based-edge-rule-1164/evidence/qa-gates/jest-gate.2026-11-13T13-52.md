# Jest Gate (remediation cycle 1, P2-T6, post-main-merge head)

Timestamp: 2026-11-13T13-51
Command: sh SCRATCH/issue-1164-jest-gate.sh (in extensions/drm-copilot: node run-jest.cjs --coverage; normal workers); per-file figures read from the coverage/lcov.info this run wrote (copied to SCRATCH/issue-1164-jest-final-lcov.info, written 2026-11-13T13-51 UTC)
EXIT_CODE: 0
Output Summary:
- Run on head a27a608aa, whose non-docs tree equals the post-main-merge head 01547c4c7; final QA loop gate, one run with normal workers.
- Test Suites: 341 passed, 341 total; Tests: 5502 passed, 5502 total (0 failed); Time 12.024 s (P0-T6: 341 suites, 5499 passed, 0 failed).
- Coverage summary: Lines 97.16% (63986/65852); Branches 93.91% (9788/10422) (P0-T6: Lines 97.16% (63979/65845); Branches 93.91% (9785/10419)). No drop.
- Per-file (lcov LF/LH, BRF/BRH), each compared with P0-T6:
  - src/lib/validate/parallel-state-shared.ts: line 480/493 = 97.36%, branch 103/106 = 97.17% (P0-T6: 473/486 = 97.33%, 100/103 = 97.09%). No drop; uncovered lines (13) and uncovered branches (3) unchanged; at or above 85% line and 75% branch.
  - src/lib/validate/parallel-state-records.ts: line 658/658 = 100.00%, branch 141/141 = 100.00% (P0-T6: 658/658, 141/141). No drop.
- parallel-state-scheduling-parity.test.ts builds its "reproduces the expected errors of %s" cases from readdirSync over tests/fixtures/parallel_state_scheduling/ (24 files, including the three new stems reject-item-read-path-apostrophe-outside-radius, reject-overlap-reason-apostrophe, and reject-overlap-reason-both-quotes); the suite passed (0 failed suites), and the total grew by exactly 3 tests against P0-T6.
- No failing test, so no failure is classified under the Execution Terms.

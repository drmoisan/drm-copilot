# Root Jest Gate (remediation cycle 2, P2-T6)

Timestamp: 2026-11-13T16-33
Command: sh SCRATCH/issue-1164-jest-gate.sh root (at the worktree root under jest.config.cjs: node run-jest.cjs --coverage); figures read from coverage/lcov.info by SCRATCH/issue-1164-lcov.js
EXIT_CODE: 0
Output Summary:
- Run on head 8eeda9c08; 2026-11-13T16-32-50 to 16-33-00 UTC.
- Test Suites: 344 passed, 344 total; Tests: 5525 passed, 5525 total; 0 failed (P0-T6: 5519 passed, 0 failed).
- Repo-wide (lcov totals, 284 files): line 70015 / 71235 = 98.29% (P0-T6 98.29%); branch 10445 / 11153 = 93.65% (P0-T6 93.64%). No drop.
- coverage/lcov.info exists at the worktree root with modification time 2026-11-13T16:33:00Z, later than the run start 16-32-50.

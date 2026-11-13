# Extension Jest Gate (remediation cycle 2, P2-T5)

Timestamp: 2026-11-13T16-32
Command: sh SCRATCH/issue-1164-jest-gate.sh ext (in extensions/drm-copilot: node run-jest.cjs --coverage); per-file figures read from coverage/lcov.info (copied to SCRATCH/issue-1164-lcov-ext-p2.info) by SCRATCH/issue-1164-lcov.js
EXIT_CODE: 0
Output Summary:
- Run on head 97ebe8119; 2026-11-13T16-32-22 to 16-32-31 UTC.
- Test Suites: 341 passed, 341 total; Tests: 5508 passed, 5508 total; 0 failed (P0-T5: 5502 passed; +6 are the P1-T3 stems run by parallel-state-scheduling-parity.test.ts, which passes as part of the 341 suites).
- Per-file (lcov LH/LF, BRH/BRF): src/lib/validate/parallel-state-shared.ts: line 525 / 538 = 97.58%, branch 116 / 119 = 97.48% (P0-T5 97.36% line, 97.17% branch; no drop; at or above 85% line and 75% branch).
- Repo-wide (extension lcov): line 64031 / 65897 = 97.17%; branch 9801 / 10435 = 93.92%.

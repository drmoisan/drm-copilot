# Root Jest Phase 0 Baseline (remediation cycle 2, P0-T6)

Timestamp: 2026-11-13T14-53
Command: sh SCRATCH/issue-1164-jest-gate.sh root (at the item worktree root: node run-jest.cjs --coverage with normal workers, under jest.config.cjs); figures read from coverage/lcov.info by SCRATCH/issue-1164-lcov.js
EXIT_CODE: 0
Output Summary:
- Run on head df6ce8e0f; 2026-11-13T14-53-52 to 14-54-09 UTC.
- Test Suites: 344 passed, 344 total; Tests: 5519 passed, 5519 total (0 failed).
- coverage/lcov.info written 2026-11-13T14:54:08Z; 284 source files.
- Repo-wide (lcov totals): line 69970 / 71190 = 98.29%; branch 10432 / 11140 = 93.64%.
- Per-file (lcov): extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts: line 480 / 493 = 97.36%, branch 103 / 106 = 97.17%.
- No failing test.

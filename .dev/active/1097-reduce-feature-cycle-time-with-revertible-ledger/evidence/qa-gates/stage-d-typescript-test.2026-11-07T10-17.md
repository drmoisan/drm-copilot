# Stage D TypeScript Test Gate

Timestamp: 2026-11-07T10-17
Command: node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary, run once in extensions/drm-copilot from a `sh` launcher under SCRATCH, after the pytest gate of the same loop pass
EXIT_CODE: 0
Output Summary: Test Suites: 330 passed, 330 total. Tests: 5339 passed, 5339 total, 0 failed, against 5305 at baseline: 34 more, which covers the 6 new `orchestrator-state-light-cycle.test.ts` tests and the 14 new corpus rows of the parity suite. Jest's exit enforces the new `coverageThreshold` entry `./src/lib/validate/orchestrator-state-light-cycle.ts` (lines 85, branches 75). From `coverage/lcov.info`: `src/lib/validate/orchestrator-state-light-cycle.ts` lines 193 of 193 (100.00%), branches 35 of 37 (94.59%), new; `src/lib/validate/orchestrator-state-remediation.ts` lines 297 of 297 (100.00%), branches 59 of 59 (100.00%), beside the baseline 283 of 283 lines and 56 of 56 branches. Repo-wide: lines 97.09% (62167 of 64030), branches 93.71% (9448 of 10082). `extensions/drm-copilot/coverage/lcov.info` stays on disk.

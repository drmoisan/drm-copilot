# P0-T17 TypeScript Jest coverage baseline

Timestamp: 2026-10-09T20-08
Command: npm run test:coverage --prefix extensions/drm-copilot
EXIT_CODE: 0
Output Summary:
- Test Suites: 256 passed, 256 total
- Tests:       3917 passed, 3917 total
- B_TS (failing test names): empty (suite green)
- Global coverage summary: Statements 97.16%, Branches 91.7%, Functions 91.59%, Lines 97.16%
- src/lib/validate/epic-orchestrator-state-core.ts record in extensions/drm-copilot/coverage/lcov.info: LF 491, LH 481, BRF 90, BRH 82
- Core module line percent: 97.96 (481 / 491 * 100)
- Core module branch percent: 91.11 (82 / 90 * 100)

```
> drm-copilot@1.1.18 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

=============================== Coverage summary ===============================
Statements   : 97.16% ( 51037/52524 )
Branches     : 91.7% ( 7520/8200 )
Functions    : 91.59% ( 1525/1665 )
Lines        : 97.16% ( 51037/52524 )
================================================================================

Test Suites: 256 passed, 256 total
Tests:       3917 passed, 3917 total
Snapshots:   0 total
Time:        9.406 s
Ran all test suites.
```

# P3-T10 Final TypeScript Jest coverage

Timestamp: 2026-10-09T20-24
Command: npm run test:coverage --prefix extensions/drm-copilot
EXIT_CODE: 0
Output Summary:
- Test Suites: 257 passed, 257 total
- Tests:       3925 passed, 3925 total (baseline 3917 plus 8 new)
- Failing test names: none (subset of the empty B_TS)
- Global coverage summary: Statements 97.16%, Branches 91.7% (7521/8201), Functions 91.59%, Lines 97.16%
- src/lib/validate/epic-orchestrator-state-core.ts record in extensions/drm-copilot/coverage/lcov.info: LF 491, LH 481, BRF 91, BRH 83
- Core module line percent: 97.96 (481 / 491 * 100)
- Core module branch percent: 91.21 (83 / 91 * 100)
- Observation: the core record reports BRF 91 and BRH 83, against BRF 90 and BRH 82 in the baseline, although no TypeScript production file changed (the global branch total moved from 7520/8200 to 7521/8201 in step). The extra branch is counted as covered, so the branch percent rose from 91.11 to 91.21.

```
> drm-copilot@1.1.18 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

=============================== Coverage summary ===============================
Statements   : 97.16% ( 51037/52524 )
Branches     : 91.7% ( 7521/8201 )
Functions    : 91.59% ( 1525/1665 )
Lines        : 97.16% ( 51037/52524 )
================================================================================

Test Suites: 257 passed, 257 total
Tests:       3925 passed, 3925 total
Snapshots:   0 total
Time:        8.157 s
Ran all test suites.
```

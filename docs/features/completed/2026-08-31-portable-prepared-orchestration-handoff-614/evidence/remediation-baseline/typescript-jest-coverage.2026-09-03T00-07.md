# TypeScript Jest Coverage Baseline

Timestamp: 2026-09-03T00-44:00-04:00
Command: npm run test:coverage
Working Directory: `extensions/drm-copilot`
EXIT_CODE: 0
Output Summary: 213/213 suites and 2,894/2,894 tests passed. Overall line coverage is 47,197/48,763 = 96.78%; branch coverage is 6,729/7,453 = 90.28%. `orchestration-handoff-authority-service.ts` line coverage is 259/265 = 97.735849%. The passing baseline lacks the FR-614-005 production-boundary behavior reproduced in `code-review.2026-09-03T00-07.md`.

```text
> drm-copilot@1.1.9 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

=============================== Coverage summary ===============================
Statements   : 96.78% ( 47197/48763 )
Branches     : 90.28% ( 6729/7453 )
Functions    : 90.54% ( 1407/1554 )
Lines        : 96.78% ( 47197/48763 )
================================================================================

Test Suites: 213 passed, 213 total
Tests:       2894 passed, 2894 total
Snapshots:   0 total
Time:        6.911 s
Ran all test suites.
```

Authority service LCOV detail:

```text
CoveredLines : 259
TotalLines   : 265
LineCoverage : 97.7358490566038
```

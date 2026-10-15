# TypeScript Test and Coverage Baseline (#623)

Timestamp: 2026-09-30T08-26
Command: npm --prefix extensions/drm-copilot run test:coverage; then NODE-LCOV against "extensions/drm-copilot/coverage/lcov.info"
EXIT_CODE: 0
Output Summary:
- `Test Suites: 236 passed, 236 total`
- `Tests:       3315 passed, 3315 total`
- text-summary: Lines 97.02% (49780/51304); Branches 91.17% (7211/7909)
- Baseline failure set J0: empty (no failing tests)
- Baseline coverage-threshold set T0: empty (no line containing "coverage threshold")
- promotion.ts: LH/LF=438/443 (line 98.87%); BRH/BRF=54/65 (branch 83.08%)
- potential-to-issue-service-call.ts: LH/LF=238/238 (line 100.00%); BRH/BRF=17/20 (branch 85.00%); DA223=2

## Jest output (verbatim)

```
> drm-copilot@1.1.17 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

=============================== Coverage summary ===============================
Statements   : 97.02% ( 49780/51304 )
Branches     : 91.17% ( 7211/7909 )
Functions    : 90.87% ( 1494/1644 )
Lines        : 97.02% ( 49780/51304 )
================================================================================

Test Suites: 236 passed, 236 total
Tests:       3315 passed, 3315 total
Snapshots:   0 total
Time:        12.366 s
Ran all test suites.
```

## NODE-LCOV output (verbatim; paths are repository-relative under extensions/drm-copilot/)

```
src/lib/potential-to-issue/potential-to-issue-service-call.ts LH/LF=238/238 BRH/BRF=17/20 DA223=2
src/lib/potential-to-issue/promotion.ts LH/LF=438/443 BRH/BRF=54/65 DA223=33
```

J0: (empty)
T0: (empty)

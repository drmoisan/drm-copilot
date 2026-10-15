# TypeScript Test and Coverage Gate (#623)

Timestamp: 2026-09-30T08-46
Command: npm --prefix extensions/drm-copilot run test:coverage; then NODE-LCOV against "extensions/drm-copilot/coverage/lcov.info" (with trailing line numbers 443 444 445 447 for the P9-T1 changed-line check)
EXIT_CODE: 0
Output Summary: Case (a). `Tests:       3318 passed, 3318 total` (0 failed); `Test Suites: 237 passed, 237 total`; no line contains "coverage threshold" (the new promotion.ts per-file threshold passed).
- text-summary: Lines 97.02% (49787/51311); Branches 91.17% (7214/7912)
- promotion.ts: LH/LF=445/450 (line 98.89% >= 85); BRH/BRF=57/68 (branch 83.82% >= 75)
- potential-to-issue-service-call.ts: LH/LF=238/238 (line 100.00% >= 85); BRH/BRF=17/20 (branch 85.00% >= 75); DA223=2 (>= 1)

P7-T5 case: (a)

## Jest output (verbatim)

```
> drm-copilot@1.1.17 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

=============================== Coverage summary ===============================
Statements   : 97.02% ( 49787/51311 )
Branches     : 91.17% ( 7214/7912 )
Functions    : 90.87% ( 1494/1644 )
Lines        : 97.02% ( 49787/51311 )
================================================================================

Test Suites: 237 passed, 237 total
Tests:       3318 passed, 3318 total
Snapshots:   0 total
Time:        7.515 s
Ran all test suites.
```

## NODE-LCOV output (verbatim; paths under extensions/drm-copilot/)

```
src/lib/potential-to-issue/potential-to-issue-service-call.ts LH/LF=238/238 BRH/BRF=17/20 DA223=2 DA443=none DA444=none DA445=none DA447=none
src/lib/potential-to-issue/promotion.ts LH/LF=445/450 BRH/BRF=57/68 DA223=36 DA443=53 DA444=2 DA445=2 DA447=37
```

The DA443..DA447 fields are meaningful only on the promotion.ts line; the DA223 field is meaningful only on the service-call line.

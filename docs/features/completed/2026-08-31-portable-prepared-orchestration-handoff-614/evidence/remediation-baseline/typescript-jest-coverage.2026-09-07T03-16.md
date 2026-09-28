# TypeScript Jest Coverage Baseline — [P0-T3]

Timestamp: 2026-09-07T10-58
Task: [P0-T3]
Head: fca8c0455dd7207b21096e70fe7ffbf8cfc56ca1

Command: `npm --prefix extensions/drm-copilot run test:coverage`
EXIT_CODE: 0

Underlying script: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`

## Coverage summary block (verbatim)

```
=============================== Coverage summary ===============================
Statements   : 96.87% ( 47769/49309 )
Branches     : 90.43% ( 6824/7546 )
Functions    : 90.62% ( 1421/1568 )
Lines        : 96.87% ( 47769/49309 )
================================================================================
```

## Test result lines (verbatim)

```
Test Suites: 214 passed, 214 total
Tests:       2973 passed, 2973 total
Snapshots:   0 total
```

Output Summary: The full extension Jest suite passed with `Test Suites: 214 passed, 214 total` and `Tests: 2973 passed, 2973 total`; 0 failed. The four `Coverage summary` percentages with their ratios are Statements 96.87% (47769/49309), Branches 90.43% (6824/7546), Functions 90.62% (1421/1568), and Lines 96.87% (47769/49309). These four values are the floor for [P2-T4], and the passed count 2973 is the floor for the [P2-T4] passed-count comparison. Both uniform thresholds are already satisfied at baseline: Lines 96.87% >= 85.00% and Branches 90.43% >= 75.00%.

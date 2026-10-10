# Baseline: Jest coverage ([P0-T22])

Timestamp: 2026-10-09T21-04
Command: npm run test:coverage (run from extensions/drm-copilot)
EXIT_CODE: 0
Output Summary: "Test Suites: 257 passed, 257 total"; "Tests: 3925 passed, 3925 total". Text summary: Statements 97.16% (51037/52524), Branches 91.7% (7521/8201), Functions 91.59% (1525/1665), Lines 97.16% (51037/52524). No line containing `coverage threshold` was printed.

Baseline-Lines: 97.16
Baseline-Branches: 91.7

## Verbatim output

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
Time:        10.493 s
Ran all test suites.
```

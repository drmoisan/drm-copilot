# Extension Jest Baseline - Remediation Cycle 2 (P0-T5)

Timestamp: 2026-11-13T16-56
Command: npm --prefix <worktree root>/extensions/drm-copilot run test:coverage
EXIT_CODE: 0
Output Summary: Test Suites: 340 passed, 340 total; Tests: 5476 passed, 5476 total; failing tests: none; coverage threshold failures: none; text-summary: Statements 97.15% (63660/65526), Branches 93.87% (9710/10344), Functions 92.11% (1904/2067), Lines 97.15% (63660/65526).

## Counts

| Measure | Passed | Failed | Total |
|---|---|---|---|
| Test suites | 340 | 0 | 340 |
| Tests | 5476 | 0 | 5476 |

Failing tests: none

Coverage threshold failure lines: none (the per-file `coverageThreshold` map of `extensions/drm-copilot/jest.config.cjs` was in force; exit 0).

## text-summary reporter

| Metric | Percent | Covered / Total |
|---|---|---|
| Statements | 97.15% | 63660 / 65526 |
| Branches | 93.87% | 9710 / 10344 |
| Functions | 92.11% | 1904 / 2067 |
| Lines | 97.15% | 63660 / 65526 |

Run through Jest's normal parallel workers (`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`).

# Stage E2 TypeScript Test Gate (compared with the Phase 0 baseline)

Timestamp: 2026-11-07T15-24
Command: node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary (one run, in extensions/drm-copilot; launcher stored under SCRATCH); baseline: stage-e2-typescript-test-baseline.2026-11-07T14-26.md
EXIT_CODE: 0
Output Summary:
  Test Suites: 330 passed, 330 total. Tests: 5345 passed, 5345 total; 0 failed. Baseline: 330 suites, 5345 tests, 0 failed. Difference: none.
  policy-audit-artifact.test.ts: 17 tests (17 it/test cases, no it.each rows), all passed; baseline 17.
  Text-summary totals: Lines 97.09% (62167 of 64030), Branches 93.71% (9447 of 10081), Statements 97.09%, Functions 91.93% (1859 of 2022). Baseline: identical counts. Difference: 0 for each total; not below the baseline.
  extensions/drm-copilot/coverage/lcov.info written by the run and left on disk.

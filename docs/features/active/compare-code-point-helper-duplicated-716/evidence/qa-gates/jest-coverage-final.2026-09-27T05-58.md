# Final QA — Jest coverage (full suite)

Timestamp: 2026-09-27T05-58
Command: node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=lcov (cwd: extensions/drm-copilot)
EXIT_CODE: 0
Output Summary:
- Test Suites: 227 passed, 227 total
- Tests:       3142 passed, 3142 total (baseline 3130; +12 from P3-T1/P3-T2)
- All files row: % Stmts 96.95 | % Branch 90.89 | % Funcs 90.65 | % Lines 96.95
- `src/lib/pr-context` group row: % Stmts 94.91 | % Branch 90.53 | % Funcs 86.01 | % Lines 94.91
- `models.ts` row under the `src/lib/pr-context` group heading (third of three `models.ts` rows in the table):
  `  models.ts | 100 | 100 | 100 | 100 |` -> % Lines 100, % Branch 100
- Exit code 0 confirms every per-file `coverageThreshold` entry in `jest.config.cjs` passed, including pr-context `models.ts` (lines: 85, branches: 75).

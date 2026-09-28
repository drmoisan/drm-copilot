# Baseline — Jest coverage (full suite)

Timestamp: 2026-09-27T05-53
Command: node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=lcov (cwd: extensions/drm-copilot)
EXIT_CODE: 0
Output Summary:
- Test Suites: 227 passed, 227 total
- Tests:       3130 passed, 3130 total
- All files row: % Stmts 96.89 | % Branch 90.79 | % Funcs 90.62 | % Lines 96.89
- `src/lib/pr-context` group row: % Stmts 94.47 | % Branch 89.69 | % Funcs 86 | % Lines 94.47
- `models.ts` row under the `src/lib/pr-context` group heading (third of three `models.ts` rows in the table):
  `  models.ts | 100 | 100 | 100 | 100 |` -> % Lines 100, % Branch 100 (AC9 baseline)
- For disambiguation, the other two `models.ts` rows are under `src/lib/codex-native-converter` (Lines 100, Branch 95) and `src/lib/new-active-feature-folder` (Lines 97.36, Branch 83.33); they are out of scope.

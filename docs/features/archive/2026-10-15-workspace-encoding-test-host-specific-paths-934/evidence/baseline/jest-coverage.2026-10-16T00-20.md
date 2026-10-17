# Jest Full Coverage Baseline (P0-T18, Issue #934)

Timestamp: 2026-10-16T00-20
Command: npx jest --config jest.config.cjs --coverage --coverageReporters=text --coverageDirectory=../../SCRATCH/issue-934/coverage-baseline   (working directory: extensions/drm-copilot; stdout and stderr captured to SCRATCH/issue-934/jest-coverage-baseline.log)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 270 passed, 270 total`
- `Tests:       4002 passed, 4002 total`
- Lines containing `coverage threshold`: 0 (no threshold failure).
- `All files` row: % Stmts 97.26 | % Branch 92.28 | % Funcs 91.63 | % Lines 97.26
- Directory row ` src/lib/subagent-tree`: % Stmts 91.45 | % Branch 95.37 | % Funcs 96.29 | % Lines 91.45
- `workspace-encoding.ts` (beneath ` src/lib/subagent-tree`): % Branch 100 | % Lines 100 (Stmts 100, Funcs 100, no uncovered lines)
- `session-transcript-resolver.ts` (beneath ` src/lib/subagent-tree`): % Branch 85.71 | % Lines 100 (Stmts 100, Funcs 100, uncovered branch at line 71)
- Both modules meet the 85% line / 75% branch defaults at baseline.

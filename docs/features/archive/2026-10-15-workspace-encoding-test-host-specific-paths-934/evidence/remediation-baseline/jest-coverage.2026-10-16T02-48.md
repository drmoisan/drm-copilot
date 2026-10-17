# Baseline Full Coverage Run (P0-T17, Issue #934, remediation cycle 1)

Timestamp: 2026-10-16T02-48
Command: npx jest --config jest.config.cjs --coverage --coverageReporters=text --coverageDirectory=../../SCRATCH/issue-934/coverage-rem-baseline   (working directory: extensions/drm-copilot; stdout and stderr captured to SCRATCH/issue-934/jest-coverage-rem-baseline.log)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 270 passed, 270 total`
- `Tests:       4002 passed, 4002 total`
- No output line contains `coverage threshold` (case-insensitive count 0).
- `All files`: % Branch 92.28, % Lines 97.26 (% Stmts 97.26, % Funcs 91.63).
- Directory row ` src/lib/subagent-tree`: % Branch 95.37, % Lines 91.45.
  - `workspace-encoding.ts`: % Branch 100, % Lines 100.
  - `session-transcript-resolver.ts`: % Branch 85.71, % Lines 100 (uncovered line 71).
- Thresholds: line >= 85% and branch >= 75% (defaults; `EXT/jest.config.cjs` gates both modules at these values) are met. Values equal the cycle-0 QA artifact `FEATURE/evidence/qa-gates/jest-coverage.2026-10-16T01-16.md`.

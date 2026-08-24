# QA Gate — TypeScript Test + Coverage

- Timestamp: 2026-07-10T18-25
- Command: `npm run test:coverage` (in `extensions/drm-copilot/`; per-file figures from `node run-jest.cjs --coverage --coverageReporters=text`)
- EXIT_CODE: 0

## Output Summary

- Test Suites: 140 passed, 140 total
- Tests: 1640 passed, 1640 total
- Whole-package coverage: Statements 96.77% (32547/33631), Branches 88.78% (4149/4673), Functions 87.8% (936/1066), Lines 96.77%.

Per-file coverage for new/changed modules (all exceed line >= 85%, branch >= 75%):

| File | % Stmts | % Branch | % Funcs | % Lines |
|---|---|---|---|---|
| poshqc-scan-config.ts | 96.49 | 88.57 | 100 | 96.49 |
| poshqc-terminal-output.ts | 99.29 | 100 | 90 | 99.29 |
| poshqc-folder-picker.ts | 100 | 100 | 100 | 100 |
| poshqc-command-registration.ts | 94.27 | 85.71 | 90 | 94.27 |

All changed TypeScript modules meet the line >= 85% and branch >= 75% thresholds with no coverage regression.

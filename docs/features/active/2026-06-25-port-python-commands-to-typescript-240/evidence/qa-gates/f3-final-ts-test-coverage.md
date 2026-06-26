# F3 Final QC — TypeScript Test + Coverage

Timestamp: 2026-06-26T01-35
Command: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"
EXIT_CODE: 0
Output Summary:
- Test Suites: 73 passed, 73 total
- Tests: 825 passed, 825 total (0 failed)
- Overall `src/lib/**` (All files): line 96.97%, branch 87.93%, funcs 93.83%.

Per new `src/lib/push-down/*.ts` file (line% / branch%):
- claude-customizations.ts            100    / 83.33
- claude-filesystem-adapter.ts        94.38  / 83.33
- claude-memory-scope.ts              100    / 86.36
- claude-pack-selection.ts            100    / 98
- codex-agents-customizations.ts      100    / 100
- copilot-customizations-engine.ts    97.99  / 82
- copilot-customizations.ts           100    / 100
- filesystem-adapter.ts               98.03  / 86.95
- push-down-service-call.ts           100    / 86.66
- reference-rewrites.ts               99.17  / 93.75

Every new push-down file meets line >= 85% and branch >= 75%.

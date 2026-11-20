# TypeScript Test and Coverage Gate (P7-T9)

Timestamp: 2026-10-02T05-19
Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text --coverageReporters=json-summary --coverageReporters=lcov
EXIT_CODE: 0
Output Summary:
Test Suites: 251 passed, 251 total
Tests:       3808 passed, 3808 total
No threshold message was printed; exit 0 includes the per-file coverageThreshold gates, among them the P4-T3 entry for ./src/lib/validate/parallel-planner-state-routing.ts (lines 85, branches 75).
Read from extensions/drm-copilot/coverage/coverage-summary.json:
src/lib/validate/parallel-planner-state-routing.ts - lines.pct = 100 (225/225); branches.pct = 92.59 (25/27) (threshold 85% line / 75% branch: met)
src/lib/validate/parallel-planner-state-core.ts - lines.pct = 100 (464/464); branches.pct = 97.95 (48/49)
Text-reporter uncovered-line column: routing 60, core 446.
The authorized pre-existing-item branch was not taken (baseline evidence/baseline/ts-jest-coverage.2026-10-02T04-29.md recorded no failing suite and no threshold message).

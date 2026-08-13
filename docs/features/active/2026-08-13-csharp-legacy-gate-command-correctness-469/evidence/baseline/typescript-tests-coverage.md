# Baseline — TypeScript Tests and Coverage (Issue #469)

Timestamp: 2026-08-13T17-28

Command: `npm run test:coverage` (working directory `extensions/drm-copilot`; resolves to `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`)

EXIT_CODE: 0

Output Summary:
- Test suites: 183 passed of 183. Tests: 2495 passed of 2495, 0 failed (7.235s).
- Coverage headline from the text-summary reporter:
  - Statements: 96.57% (40958/42412)
  - Branches: 89.90% (5822/6476)
  - Functions: 90.15% (1191/1321)
  - Lines: 96.57% (40958/42412)
- Both uniform thresholds are met at baseline (line >= 85%, branch >= 75%).
- Command-name note: the extension's coverage script is `test:coverage`; `test:unit:coverage` does not exist in `extensions/drm-copilot/package.json`.

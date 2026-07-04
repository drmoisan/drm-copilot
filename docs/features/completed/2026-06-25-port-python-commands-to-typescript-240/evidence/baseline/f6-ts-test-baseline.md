# F6 Baseline — TypeScript Test + Coverage (pre-change)

Timestamp: 2026-06-26T02-08

Command: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (run from `extensions/drm-copilot/`)

EXIT_CODE: 0

Output Summary:
- Test result: 60 suites passed / 60 total; 698 tests passed / 698 total.
- Overall coverage for the `src/lib/**` collection set ("All files" row, which here is the `src/lib/**` set due to `--collectCoverageFrom`):
  - Statements: 96.3%
  - Branch: 88.06%
  - Functions: 92.8%
  - Lines: 96.3%
- `src/lib/new-potential-bug-entry.ts` does not yet exist, so it contributes nothing to this baseline.
- `src/lib/new-potential-bug-entry-service-call.ts` does not yet exist, so it contributes nothing to this baseline.
- Existing per-directory headline values: `lib` line 97.96% / branch 91.51%; `lib/resolve` line 96.8% / branch 83.79%; `lib/validate` line 95.19% / branch 88.88%.

# [P0-T9] Jest Coverage Baseline — root (`.`)

- **Timestamp:** 2026-07-22T12-15
- **Command:** `npm run test:unit:coverage` (run in `.`, repo root; wraps Jest via `node run-jest.cjs --coverage`)
- **EXIT_CODE:** 0

## Output Summary

- Test Suites: 166 passed, 166 total.
- Tests: 2007 passed, 2007 total.
- Time: 10.867 s.
- **All files coverage: 96.97% statements, 89.09% branches, 89.25% functions, 96.97% lines.**
- This is the pre-Phase-1 baseline; Phase 6 (P6-T4) will re-run this command post-fix and compare against these numeric values (96.97% line / 89.09% branch), expecting zero regression since no source lines are changed by this dependency-manifest-only fix.

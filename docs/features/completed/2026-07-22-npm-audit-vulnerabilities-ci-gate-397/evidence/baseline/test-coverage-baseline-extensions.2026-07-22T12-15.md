# [P0-T12] Jest Coverage Baseline — `extensions/drm-copilot/`

- **Timestamp:** 2026-07-22T12-15
- **Command:** `npm run test:coverage` (run in `extensions/drm-copilot/`; wraps Jest via `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`)
- **EXIT_CODE:** 0

## Output Summary

- Test Suites: 165 passed, 165 total.
- Tests: 2006 passed, 2006 total.
- Time: 6.17 s.
- **Coverage summary: Statements 96.3% (37511/38949), Branches 89.22% (5198/5826), Functions 89.48% (1098/1227), Lines 96.3% (37511/38949).**
- This is the pre-Phase-2 baseline; Phase 6 (P6-T7) will re-run this command post-fix and compare against these numeric values (96.3% line / 89.22% branch), expecting zero regression since no source lines are changed by this dependency-manifest-only fix.

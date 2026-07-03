# Final TypeScript Test with Coverage, Including `lcov` (Remediation Cycle 1)

- **Timestamp:** 2026-07-02T23-55
- **Task:** [P6-T11]
- **Command:** `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary` (run from `extensions/drm-copilot`)
- **EXIT_CODE:** 0

## Output Summary

Test Suites: 121 passed, 121 total. Tests: 1462 passed, 1462 total.

Coverage summary:
- Statements: 96.88% (31320/32326)
- Branches: 88.27% (4052/4590)
- Functions: 88.24% (961/1089)
- Lines: 96.88% (31320/32326)

**Delta vs. `evidence/qa-gates/coverage-delta-verification.2026-07-02T22-30.md` (96.88%
statements, 88.27% branches, 96.88% lines):** 0.00pp on all three metrics — no regression.

Confirmed `extensions/drm-copilot/coverage/lcov.info` exists (`Test-Path` = `True`) after this
run. The `text-summary`/`json-summary` reporters remain alongside `lcov`, per the plan's "Do Not
Do" constraint against dropping existing reporter formats.

# TypeScript `lcov` Coverage Artifact (Fix #2, Remediation Cycle 1)

- **Timestamp:** 2026-07-02T23-25
- **Tasks:** [P2-T1], [P2-T2], [P2-T3], [P2-T4]
- **Command:** `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary` (run from `extensions/drm-copilot`)
- **EXIT_CODE:** 0

## Output Summary

Test Suites: 121 passed, 121 total. Tests: 1462 passed, 1462 total. All Jest test suites passed
with 0 failures.

Coverage summary:
- Statements: 96.88% (31320/32326)
- Branches: 88.27% (4052/4590)
- Functions: 88.24% (961/1089)
- Lines: 96.88% (31320/32326)

Confirmed `extensions/drm-copilot/coverage/lcov.info` exists (`Test-Path` = `True`) and is
non-empty (428547 bytes).

**Delta vs. `evidence/qa-gates/coverage-delta-verification.2026-07-02T22-30.md` (96.88%
statements, 88.27% branches, 96.88% lines):** 0.00pp on all three metrics — no regression. The
`text-summary`/`json-summary` reporters were retained alongside the new `lcov` reporter, per the
plan's "Do Not Do" constraint against dropping existing reporter formats.

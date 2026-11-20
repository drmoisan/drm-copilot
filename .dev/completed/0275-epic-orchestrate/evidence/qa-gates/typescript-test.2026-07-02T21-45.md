# TypeScript Test (P4-T11)

- Timestamp: 2026-07-02T21-45
- Command: `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`
  (run from `extensions/drm-copilot`; the repository-equivalent coverage invocation for the
  actual Jest-based toolchain — see the toolchain-substitution note in
  `evidence/baseline/typescript-test-baseline.2026-07-02T19-50.md` for why `test:coverage`
  / Vitest are not the actual repository commands).
- EXIT_CODE: 0

## Output Summary

- Test Suites: 121 passed, 121 total.
- Tests: 1462 passed, 1462 total (22 new tests added across P4-T4/P4-T5/P4-T6; 0 failures).
- Statements coverage: 96.88% (31320/32326).
- Branches coverage: 88.27% (4052/4590).
- Functions coverage: 88.24% (961/1089).
- Lines coverage: 96.88% (31320/32326).

Both the 85% line-coverage floor and 75% branch-coverage floor are met.

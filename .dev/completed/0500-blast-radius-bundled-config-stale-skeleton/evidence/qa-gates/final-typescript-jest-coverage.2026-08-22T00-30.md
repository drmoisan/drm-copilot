# Final QC — TypeScript tests and coverage, Jest (Issue #500)

Timestamp: 2026-08-22T00:30:00Z
Issue: #500
Task: [P8-T8]

Command:
```
npm run test:coverage
```
(working directory: `extensions/drm-copilot`; the script runs
`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`.
Plan constraint C3 records that no `test:unit:coverage` script exists in this manifest, so the
corrected script name is used here and in spec AC15.)

EXIT_CODE: 0

Output Summary:

Suite and test counts:
- Test Suites: **195 passed**, 195 total
- Tests: **2656 passed**, 2656 total
- Failures: **0**

The test count rose from the Phase 0 baseline of 2654 by 2: the [P1-T4] published-document assertion
and the [P2-T6] payload-module negative assertion.

Coverage percentages, from the `text-summary` reporter:

| Metric | Percentage | Ratio |
| --- | --- | --- |
| Statements | **96.66%** | 43071/44558 |
| Branches | **90.04%** | 6122/6799 |
| Functions | **89.67%** | 1259/1404 |
| Lines | **96.66%** | 43071/44558 |

Threshold status: line 96.66% >= 85% and branch 90.04% >= 75%. Both thresholds in
`.claude/rules/quality-tiers.md` are met.

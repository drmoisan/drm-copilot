# TypeScript test and coverage baseline — Jest (Issue #500)

Timestamp: 2026-08-21T22:52:36Z
Issue: #500
Task: [P0-T11]

Command:
```
npm run test:coverage
```
(working directory: `extensions/drm-copilot`; the script runs
`node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`.
Plan constraint C3 records that no `test:unit:coverage` script exists in this manifest.)

EXIT_CODE: 0

Output Summary:

Suite and test counts:
- Test Suites: **195 passed**, 195 total
- Tests: **2654 passed**, 2654 total
- Snapshots: 0 total
- Failures: **0**

Coverage percentages, from the `text-summary` reporter:

| Metric | Percentage | Ratio |
| --- | --- | --- |
| Statements | **96.66%** | 43055/44542 |
| Branches | **90.04%** | 6122/6799 |
| Functions | **89.67%** | 1259/1404 |
| Lines | **96.66%** | 43055/44542 |

Threshold status at baseline: line 96.66% >= 85% and branch 90.04% >= 75%. Both thresholds in
`.claude/rules/quality-tiers.md` are met before the change.

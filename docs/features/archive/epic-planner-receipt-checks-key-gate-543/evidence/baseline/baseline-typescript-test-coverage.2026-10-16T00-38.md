# Baseline TypeScript Full Suite and Coverage (P0-T17)

Timestamp: 2026-10-16T00-38
Command: npm --prefix extensions/drm-copilot test -- --coverage --coverageReporters=text --coverageReporters=text-summary
Route: npm-prefix (the test script is node run-jest.cjs; npm printed "> node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary")
EXIT_CODE: 0
Output Summary:
- Test Suites: 270 passed, 270 total
- Tests:       4002 passed, 4002 total
- text-summary: Lines        : 97.26% ( 51159/52596 )
- text-summary: Branches     : 92.28% ( 7561/8193 )
- text row (verbatim):

```
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
  epic-planner-state-core.ts                                |   98.31 |     93.8 |     100 |   98.31 | 69-70,75-76,78-79,273-274
```

- epic-planner-state-core.ts: % Lines 98.31 >= 85 and % Branch 93.8 >= 75; no stop condition.

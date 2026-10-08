# TypeScript Full Coverage Baseline (P0-T11)

Timestamp: 2026-09-30T13-51
Task: [P0-T11]
Location: `extensions/drm-copilot` (invoked as `npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=text` from the worktree root; the script runs `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=text`)

Command: npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=text
EXIT_CODE: 0
Output Summary:
- `Test Suites: 239 passed, 239 total`
- `Tests:       3357 passed, 3357 total` — passed 3357, failed 0, total 3357.
- Failed tests: none (the failed set P8-T4 must reproduce is empty).
- Output lines containing the token `coverage threshold`: 0 (`grep -c -e "coverage threshold"` over the captured output printed `0`).
- `text-summary` block:
  - Statements: 97.03% (49837/51359)
  - Branches: 91.19% (7219/7916)
  - Functions: 90.88% (1495/1645)
  - Lines: 97.03% (49837/51359)
- `orchestrator-state-routing.ts` row (verbatim):
  `orchestrator-state-routing.ts | 95.82 | 92.15 | 93.75 | 95.82 | 138-141,158-159,219-220,257-258,290-291,349-353,387-388`
  - % Stmts 95.82, % Branch 92.15, % Funcs 93.75, % Lines 95.82.
- Threshold check (spec discrepancy resolution 1): `% Lines` 95.82 >= 85 and `% Branch` 92.15 >= 75, so no `BLOCKED: ROUTING ROW BELOW THRESHOLD` signal.
- For reference, the #405 row: `orchestrator-state-promotion-tools.ts | 100 | 100 | 100 | 100`.

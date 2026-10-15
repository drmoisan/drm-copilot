# Phase 0 TypeScript Coverage Baseline

Timestamp: 2026-09-30T09-37

Plan task: [P0-T13]

Command: npm run test:coverage --prefix extensions/drm-copilot -- --coverageReporters=text

EXIT_CODE: 0

Output Summary: 236 of 236 suites and 3315 of 3315 tests passed; no failing tests, so B_TS is `none`. Overall: Statements 97.02%, Branches 91.17%, Functions 90.87%, Lines 97.02%. `epic-orchestrator-state-core.ts`: Lines 97.79%, Branch 89.87%.

## Test counts (verbatim)

```text
Test Suites: 236 passed, 236 total
Tests:       3315 passed, 3315 total
```

## Coverage summary block (verbatim)

```text
=============================== Coverage summary ===============================
Statements   : 97.02% ( 49780/51304 )
Branches     : 91.17% ( 7211/7909 )
Functions    : 90.87% ( 1494/1644 )
Lines        : 97.02% ( 49780/51304 )
================================================================================
```

## epic-orchestrator-state-core.ts text-reporter row (plan rule 6, verbatim)

Directory row:

```text
 src/lib/validate                                           |   97.56 |    92.02 |   95.69 |   97.56 |
```

File row under that directory row:

```text
  epic-orchestrator-state-core.ts                           |   97.79 |    89.87 |     100 |   97.79 | 179-180,188-189,261-262,321-322,326-327
```

Columns: `% Stmts | % Branch | % Funcs | % Lines`.

BASELINE_TS_CORE_LINE_PCT: 97.79

BASELINE_TS_CORE_BRANCH_PCT: 89.87

## B_TS

none

(No test in the full suite failed. No test in `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` is in B_TS.)

## Result

GREEN: EXIT_CODE 0; `Tests:` line carries numeric passed count 3315; both core percentages numeric; B_TS empty. No `ExpectedExitCode:` is recorded because the exit code is 0.

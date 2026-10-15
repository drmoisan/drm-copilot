# Final QC: TypeScript Coverage

Timestamp: 2026-09-30T09-55

Plan task: [P2-T8]

QC_PASS: 3

Command: npm run test:coverage --prefix extensions/drm-copilot -- --coverageReporters=text

EXIT_CODE: 0

Output Summary: 237 of 237 suites and 3331 of 3331 tests passed (baseline [P0-T13] 3315 + 16 = 3331); failing-name set empty. Overall: Statements 97.03%, Branches 91.18%, Functions 90.88%, Lines 97.03%. `epic-orchestrator-state-core.ts`: Lines 97.96%, Branch 91.11%.

## Test counts (verbatim)

```text
Test Suites: 237 passed, 237 total
Tests:       3331 passed, 3331 total
```

## Coverage summary block (verbatim)

```text
=============================== Coverage summary ===============================
Statements   : 97.03% ( 49818/51342 )
Branches     : 91.18% ( 7223/7921 )
Functions    : 90.88% ( 1495/1645 )
Lines        : 97.03% ( 49818/51342 )
================================================================================
```

## epic-orchestrator-state-core.ts text-reporter row (plan rule 6, verbatim)

Directory row:

```text
 src/lib/validate                                           |   97.57 |    92.06 |    95.7 |   97.57 |
```

File row under that directory row:

```text
  epic-orchestrator-state-core.ts                           |   97.96 |    91.11 |     100 |   97.96 | 181-182,190-191,290-291,359-360,364-365
```

Columns: `% Stmts | % Branch | % Funcs | % Lines`.

FINAL_TS_CORE_LINE_PCT: 97.96

FINAL_TS_CORE_BRANCH_PCT: 91.11

## Failing-name set

none

Rule 7: the empty set is a subset of `B_TS` (`none`); no test in `test/lib/validate/epic-orchestrator-state-core.test.ts` or `test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts` failed. No `ExpectedExitCode:` is recorded because the exit code is 0.

## Result

PASS: failing-name set satisfies rule 7; passed count 3331 >= 3315 + 16; FINAL_TS_CORE_LINE_PCT 97.96 >= 85; FINAL_TS_CORE_BRANCH_PCT 91.11 >= 75.

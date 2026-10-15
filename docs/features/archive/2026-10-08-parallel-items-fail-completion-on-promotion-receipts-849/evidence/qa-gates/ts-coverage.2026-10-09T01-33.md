# Final QA TypeScript Coverage (Issue #849)

Timestamp: 2026-10-10T10-41
Task: P7-T5
Command: npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=text > docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-output.2026-10-09T01-33.txt 2>&1
EXIT_CODE: 0

Output file: `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-output.2026-10-09T01-33.txt`. It contains no absolute host path (0 matches for a drive-letter or `/home/` prefix), so no replacement was needed. Exit 0 means every per-file `coverageThreshold` was met.

## Test lines (verbatim)

```text
Test Suites: 267 passed, 267 total
Tests:       3981 passed, 3981 total
Snapshots:   0 total
```

- Tests passed: 3981; failed: 0. Expected RB_TS_TESTS_PASSED + 12 = 3969 + 12 = 3981. Met.

## Summary lines (verbatim)

```text
Statements   : 97.25% ( 51131/52575 )
Branches     : 92.07% ( 7532/8180 )
Functions    : 91.63% ( 1523/1662 )
Lines        : 97.25% ( 51131/52575 )
```

## Module row (verbatim, trailing padding trimmed)

```text
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
  orchestrator-state-issue-adoption.ts                      |     100 |      100 |     100 |     100 |
```

- % Lines: 100 (threshold 85; baseline RB_TS_LINE 100). Not below baseline. Met.
- % Branch: 100 (threshold 75; baseline RB_TS_BRANCH 100). Not below baseline. Met.
- Uncovered Line #s: empty.

Output Summary: Exit 0 (all coverage thresholds met); Tests 3981 passed of 3981 (= 3969 + 12), 267 suites passed. Totals: Statements 97.25%, Branches 92.07%, Lines 97.25%. orchestrator-state-issue-adoption.ts: % Lines 100, % Branch 100, no uncovered lines; equal to baseline.

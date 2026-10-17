# Baseline TypeScript Coverage (Issue #849)

Timestamp: 2026-10-10T09-56
Task: P0-T15
Command: npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=text > docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-coverage-output.2026-10-09T01-33.txt 2>&1
EXIT_CODE: 0

Output file: `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-coverage-output.2026-10-09T01-33.txt` (245 lines). The resolved npm script is `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=text`. A search of the output file for a drive-letter path or `/home/` prefix returned no match, so no `ABSOLUTE_PATH` substitution was needed.

## Tests line (verbatim, output line 242)

```text
Tests:       3969 passed, 3969 total
```

Suites line (output line 241): `Test Suites: 266 passed, 266 total`

RB_TS_TESTS_PASSED: 3969

## Summary lines (verbatim, output lines 7, 8, and 10)

```text
Statements   : 97.25% ( 51102/52546 )
Branches     : 92.07% ( 7528/8176 )
Lines        : 97.25% ( 51102/52546 )
```

## Text-reporter row for orchestrator-state-issue-adoption.ts (verbatim, output line 205, trailing spaces removed)

Header (output line 13):

```text
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
```

Row:

```text
  orchestrator-state-issue-adoption.ts                      |     100 |      100 |     100 |     100 |
```

- RB_TS_LINE (% Lines): 100
- RB_TS_BRANCH (% Branch): 100
- Uncovered Line #s: none (empty column)

Output Summary: Coverage run exit 0; 266 of 266 suites and 3969 of 3969 tests passed. All files: statements 97.25%, branches 92.07%, lines 97.25%. orchestrator-state-issue-adoption.ts: RB_TS_LINE = 100%, RB_TS_BRANCH = 100%, no uncovered lines.

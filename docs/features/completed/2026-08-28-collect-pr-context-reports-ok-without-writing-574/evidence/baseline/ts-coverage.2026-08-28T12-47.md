# Phase 0 — TypeScript Coverage Baseline

Timestamp: 2026-08-28T12-47

Task: [P0-T8]

Command: `npm run test:coverage -- --coverageReporters=text` (working directory
`extensions/drm-copilot`)

EXIT_CODE: 0

The recorded exit code is the exit code of the coverage command itself, captured directly from
the command and not from a pipeline tail.

## Output Summary

The Jest text reporter prints separate `% Stmts`, `% Branch`, `% Funcs`, and `% Lines` columns,
so every value below is read directly from the printed table. No value is derived.

### Overall run totals, verbatim from the `All files` row

```
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
All files                                                   |   96.71 |    90.14 |   89.87 |   96.71 |
```

- Overall statement coverage: **96.71**
- Overall branch coverage: **90.14**
- Overall function coverage: **89.87**
- Overall line coverage: **96.71**

### Per-file rows for the three production files in scope, verbatim

```
  collector-output.ts                                       |   97.57 |    81.01 |     100 |   97.57 | 112,253-256,300-303,374-375
  pr-context-service-call.ts                                |     100 |      100 |     100 |     100 |
  summary-helpers.ts                                        |   93.09 |    87.14 |   88.88 |   93.09 | 72-73,76-77,103-104,107-108,178-180,182-184,236-246
```

| File | % Stmts | % Branch | % Funcs | % Lines |
| --- | --- | --- | --- | --- |
| `src/lib/pr-context/pr-context-service-call.ts` | 100 | 100 | 100 | 100 |
| `src/lib/pr-context/collector-output.ts` | 97.57 | 81.01 | 100 | 97.57 |
| `src/lib/pr-context/summary-helpers.ts` | 93.09 | 87.14 | 88.88 | 93.09 |

All three files are already above the 85 line and 75 branch thresholds at baseline. These are the
numbers `[P8-T11]` compares the post-change values against for the no-regression check.

### Test result recorded alongside the coverage run

```
Test Suites: 199 passed, 199 total
Tests:       2710 passed, 2710 total
Snapshots:   0 total
Time:        10.774 s
Ran all test suites.
```

The run reported no coverage-threshold failure. At baseline the `coverageThreshold` map in
`extensions/drm-copilot/jest.config.cjs` carries no entry for any `src/lib/pr-context/` file; the
three entries are added by `[P5-T5]`.

No placeholder value appears in this artifact.

# TypeScript Test and Coverage Baseline — Issue #614 Remediation

Timestamp: 2026-09-07T01-32
Cycle: 2026-09-06T23-30
Task: [P0-T11]
Command: `npm run test:coverage` run from `extensions/drm-copilot`
EXIT_CODE: 0

The script passes `--coverageReporters=lcov --coverageReporters=text-summary`, so the run
prints a coverage summary block and no per-file table. Per-file data below is read from
`extensions/drm-copilot/coverage/lcov.info`.

## 1. Suite and test counts

```
Test Suites: 214 passed, 214 total
Tests:       2966 passed, 2966 total
```

Failed tests: 0.

## 2. Coverage summary, exactly as printed

```
Statements   : 96.82% ( 47738/49304 )
Branches     : 90.37% ( 6815/7541 )
Functions    : 90.61% ( 1420/1567 )
Lines        : 96.82% ( 47738/49304 )
```

## 3. `orchestration-handoff-materializer.ts` record from `coverage/lcov.info`

Exactly one `SF:` record in the file ends with the file name
`orchestration-handoff-materializer.ts`. Its value is written with the platform separator:

```
SF:src\lib\validate\orchestration-handoff-materializer.ts
LF:439
LH:406
```

It is distinct from the three sibling records in the same directory, whose values end with
`orchestration-handoff-materializer-production.ts`,
`orchestration-handoff-materializer-request.ts`, and
`orchestration-handoff-materializer-support.ts`.

Ascending list of line numbers carrying a zero-hit `DA:` record:

```
143, 144, 205, 206, 207, 208, 209, 358, 359, 360, 361, 362, 363, 392, 393, 394, 395, 396,
397, 398, 411, 412, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424
```

The list includes 358, 392, and 411 — the three recovery-path entry lines that R3 is scoped
to cover.

Output Summary: Jest exits 0 with 214 suites and 2966 tests passing and 0 failing. Summary
coverage is Statements 96.82%, Branches 90.37%, Functions 90.61%, Lines 96.82%. The
materializer module covers 406 of 439 lines, with 33 zero-hit lines including the
recovery paths beginning at 358, 392, and 411.

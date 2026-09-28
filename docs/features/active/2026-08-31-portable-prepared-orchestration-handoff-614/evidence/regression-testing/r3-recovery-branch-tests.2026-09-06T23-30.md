# R3 Materialization Recovery Branch Tests — Issue #614 Remediation

Timestamp: 2026-09-07T02-08
Cycle: 2026-09-06T23-30
Task: [P3-T2]
Command: `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts` run from `extensions/drm-copilot`; `(Get-Content -LiteralPath extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts).Count` run from the workspace root
EXIT_CODE: 0

## 1. Tests added

Six tests, named exactly as section 3.3 numbers them 1 through 6:

1. `blocks when a pre-existing archive cannot be re-read`
2. `blocks a pre-existing candidate whose digest differs from the projection`
3. `materializes when a pre-existing candidate already holds the projection bytes`
4. `discards the candidate and blocks when re-validation rejects it`
5. `discards the candidate and blocks when the candidate cannot be re-read`
6. `blocks with the retained candidate when candidate removal also fails`

Each asserts the returned `primaryFailureCode` and `affectedPaths`. Tests 1, 2, 4, 5, and 6
assert `status` is `blocked`; test 3 is the idempotent case and asserts `materialized`.

## 2. Citations for branches that need no new test

**Pre-existing archive whose digest matches.** Already exercised by the existing test
`atomically replaces the canonical checkpoint after candidate validation` at lines 226-260
of `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts` as
that file stood at `a7b80f2d`. That test seeds the archive at line 232 and asserts both
`materialized` status and unchanged archive bytes at line 245. No duplicate test is added.

**Pre-existing archive whose digest differs.** Already exercised by the `archive write
failure` entry at lines 163-168 of the parametrized test `blocks $name without mutation` in
the same file at `a7b80f2d`, which asserts `HANDOFF_SOURCE_HASH_MISMATCH`. That entry
supplies no `affectedPaths` value, so the archive-path half of the remediation input's
bullet for this branch remains unasserted. This is recorded here as an accepted deviation
rather than closed.

## 3. Jest run

EXIT_CODE: 0

```
Test Suites: 1 passed, 1 total
Tests:       40 passed, 40 total
Snapshots:   0 total
Time:        0.358 s, estimated 1 s
```

Passed: 40. Failed: 0. P3-T1 recorded 34, so the count is exactly six greater.

## 4. Line count

```
472
```

472 is at most 500.

Output Summary: The six recovery tests pass. The suite exits 0 with 40 passed and 0 failed,
exactly six more than the 34 P3-T1 recorded, and the test file stands at 472 lines against
the 500-line cap. Two further branches named in the remediation inputs are covered by
existing tests and are cited above rather than duplicated; one of the two carries a
recorded, accepted deviation on its `affectedPaths` half.

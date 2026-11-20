# R3 Materializer Test-Support Seams — Issue #614 Remediation

Timestamp: 2026-09-07T02-02
Cycle: 2026-09-06T23-30
Task: [P3-T1]
EXIT_CODE: 0

## Seams added to `orchestration-handoff-materializer-test-support.ts`

- `failReadFor?: (filePath: string) => boolean` on `ScenarioOptions`, consulted at the top
  of the `readFile` fake and throwing when it returns `true`.
- `removeFailure?: boolean` on `ScenarioOptions`. `removeFile` is now a named `jest.fn`
  that throws when the flag is set and otherwise deletes the entry from `files`; the named
  mock is exposed on the returned scenario object beside `readFile`, `writeFile`, and
  `replaceFile`.
- `candidateProjectionErrors?: readonly string[]` on `ScenarioOptions`. The
  `validateDestinationProjection` fake counts its calls and returns
  `candidateProjectionErrors` on the second and later calls when that option is defined,
  and `projectionErrors ?? []` otherwise. The production module calls that validator once
  during preparation (line 285) and once during candidate re-validation (line 408), so the
  second-call rule targets the re-validation site only. With the option undefined the fake
  returns exactly what it returned before, so no existing test changes behavior.
- `archivePathFor(sourceSha256)` and `candidatePathFor(envelopeSha256)` exports returning
  the archive and candidate paths the existing success test previously built inline.
- `materializedProjectionBytes()` which builds a materialize scenario, runs one transition,
  and returns the second recorded `writeFile` argument, throwing when no second write was
  recorded.

All additions default to today's behavior.

## 1. `npm run typecheck` (run from `extensions/drm-copilot`)

EXIT_CODE: 0

```
> drm-copilot@1.1.9 typecheck
> tsc -p ./ --noEmit
```

## 2. `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts` (run from `extensions/drm-copilot`)

EXIT_CODE: 0

```
Test Suites: 1 passed, 1 total
Tests:       34 passed, 34 total
Snapshots:   0 total
Time:        0.367 s, estimated 1 s
```

Exact passed-test count: 34. Failed: 0. This is the baseline count P3-T2 and P3-T4 compare
against.

## 3. `(Get-Content -LiteralPath extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts).Count`

```
300
```

300 is at most 500.

Output Summary: Both commands exit 0, the materializer suite reports 34 passed and 0 failed
with the seams in place and no existing test altered, and the support module stands at 300
lines against the 500-line cap.

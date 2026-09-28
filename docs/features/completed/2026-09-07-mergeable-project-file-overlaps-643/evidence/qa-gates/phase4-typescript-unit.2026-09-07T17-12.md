# Phase 4 QA Gate — TypeScript unit tests (issue #643)

Timestamp: 2026-09-07T17-12

Command: `pwsh -NoProfile -Command 'Push-Location extensions/drm-copilot; npm run test:unit; $code = $LASTEXITCODE; Pop-Location; exit $code'` (run from the worktree root)

EXIT_CODE: 0

Output Summary:

Verbatim summary lines from the run:

```text
Test Suites: 205 passed, 205 total
Tests:       2749 passed, 2749 total
```

The `Tests:` line contains no `failed`. The [P0-T11] baseline recorded in
`evidence/baseline/typescript-jest-coverage.2026-09-07T15-20.md` is
`Tests: 2735 passed, 2735 total`, so the passed count rose by 14, which is at
least the required baseline plus 10. Suite count rose by 2, matching the two
suites added by [P4-T8] and [P4-T9].

## Per-suite PASS evidence

DEVIATION FROM STATED ACCEPTANCE: [P4-T11] asks for the `PASS` lines of five
named suites. Jest's default reporter emits per-file `PASS` lines only when its
stderr is a TTY. Every invocation available to this executor redirects or pipes
that stream, so the command above produced no `PASS` line at all; adding
`--verbose` did not change this. The complete captured output of the run is the
ten lines below, which is the whole file, so the absence is a property of the
reporter rather than of the extraction:

```text
> drm-copilot@1.1.10 test:unit
> node run-jest.cjs


Test Suites: 205 passed, 205 total
Tests:       2749 passed, 2749 total
Snapshots:   0 total
Time:        4.748 s
Ran all test suites.
```

Equivalent per-suite evidence was therefore obtained from the machine-readable
reporter, which carries the same per-file status the `PASS` line renders.

Supplementary command: `pwsh -NoProfile -Command 'Push-Location extensions/drm-copilot; npx jest test/lib/push-down/blast-radius-derive-manifests.test.ts test/lib/push-down/blast-radius-derive-mergeable.test.ts test/lib/push-down/blast-radius-derive-core.test.ts test/lib/push-down/blast-radius-derive.test.ts test/lib/push-down/claude-config-carriage.test.ts --json --outputFile=../../artifacts/jest-p4t11.json; $code = $LASTEXITCODE; Pop-Location; exit $code'`

Supplementary EXIT_CODE: 0

```text
Test Suites: 5 passed, 5 total
Tests:       92 passed, 92 total
```

Per-file `status` values read from the JSON report:

```text
PASS blast-radius-derive-core.test.ts
PASS blast-radius-derive-manifests.test.ts
PASS blast-radius-derive-mergeable.test.ts
PASS blast-radius-derive.test.ts
PASS claude-config-carriage.test.ts
```

All five named suites report `passed`. `artifacts/jest-p4t11.json` was a
transient tool output and was deleted after the values above were extracted; it
is not an evidence artifact.

# Fail-before — TypeScript renderer regression, expectation row line absent

Timestamp: 2026-08-20T09-53

Task: [P1-T8] [expect-fail]

Command: (from `extensions/drm-copilot`) npm run test:unit -- test/lib/pr-context/collector-output.test.ts
EXIT_CODE: 1

## Expected outcome for this task

This task is tagged `[expect-fail]`. A FAILING run is the required outcome. The new case was added at
the head of the existing `describe("renderVerificationEvidenceSection")` block; no existing test body
was edited, and the four pre-existing cases in that block plus the other nine tests in the file all
passed. The fixture uses the in-memory `TreeFileSystem`, so no disk access and no temporary file is
involved.

## Missing expectation line, quoted from the run

```
FAIL test/lib/pr-context/collector-output.test.ts
  ● renderVerificationEvidenceSection › renders the expectation line for a non-zero declared expectation

    expect(received).toBeGreaterThan(expected)

    Expected: > -1
    Received:   -1

     289 |     const expectedIndex = lines.indexOf("  - Expected EXIT_CODE: 1");
     290 |     const resultIndex = lines.indexOf("  - Normalized result: pass");
     291 |     expect(expectedIndex).toBeGreaterThan(-1);
         |                           ^

      at Object.<anonymous> (test/lib/pr-context/collector-output.test.ts:291:27)

Test Suites: 1 failed, 1 total
Tests:       1 failed, 13 passed, 14 total
```

`indexOf` returned `-1`, so the rendered section contains no `  - Expected EXIT_CODE: 1` line at all.
The pre-change renderer at
`extensions/drm-copilot/src/lib/pr-context/collector-output.ts:116-123` emits exactly six lines per
row with no conditional expectation line.

Output Summary: 1 failed, 13 passed; exit code 1, the expected outcome for this `[expect-fail]` task.
The `  - Expected EXIT_CODE: 1` line is absent from the rendered section (`indexOf` = `-1`). This
mirrors the Python renderer failure recorded at [P1-T6], completing the four-way fail-before set for
Phase 1. The pass-after run is recorded at [P5-T7].

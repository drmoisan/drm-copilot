# Fail-before — TypeScript parser regression, declared non-zero expectation ignored

Timestamp: 2026-08-20T09-53

Task: [P1-T4] [expect-fail]

Command: (from `extensions/drm-copilot`) npm run test:unit -- test/lib/pr-context/verification-evidence.test.ts
EXIT_CODE: 1

## Expected outcome for this task

This task is tagged `[expect-fail]`. A FAILING run is the required outcome. The added test uses only
symbols that exist today (`parseVerificationEvidenceMarkdown`, `record.normalizedResult`,
`record.exitCode`), so the failure is a behavior failure at an expectation rather than a compile or
import error. No existing test body was edited; the new test was appended inside the existing
`describe("parseVerificationEvidenceMarkdown")` block.

## Failing expectation quoted from the run

```
FAIL test/lib/pr-context/verification-evidence.test.ts
  ● parseVerificationEvidenceMarkdown › normalizes to pass when the observed code equals a non-zero expectation

    expect(received).toBe(expected) // Object.is equality

    Expected: "pass"
    Received: "fail"

     169 |     expect(record.normalizedResult).toBe("pass");
         |                                     ^

      at Object.<anonymous> (test/lib/pr-context/verification-evidence.test.ts:169:37)

Test Suites: 1 failed, 1 total
Tests:       1 failed, 9 passed, 10 total
```

The nine pre-existing tests in the file all passed, so the failure is isolated to the new behavior.
The parser discarded the expectation line (it is not a member of the exported `REQUIRED_FIELDS`
accept-list tested at `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:24,111`)
and normalized against the literal `0` at `verification-evidence.ts:146`.

Output Summary: 1 failed, 9 passed; exit code 1, which is the expected outcome for this
`[expect-fail]` task. The failing expectation is `Expected: "pass"` / `Received: "fail"` for an
artifact whose observed code `1` equalled its declared expectation `1`. This is the same defect as
the Python leg recorded at [P1-T2], confirming the parity pair. The pass-after run is recorded at
[P4-T12].

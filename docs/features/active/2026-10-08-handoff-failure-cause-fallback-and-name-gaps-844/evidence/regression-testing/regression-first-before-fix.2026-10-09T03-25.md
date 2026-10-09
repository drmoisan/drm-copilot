# Regression-First Run Before Fix (P2-T4) [expect-fail]

Timestamp: 2026-10-09T03-25
Task: [P2-T4]
Working directory: extensions/drm-copilot
Command: npx jest --config jest.config.cjs --verbose test/lib/validate/orchestration-handoff-failure-cause.test.ts test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts --reporters=default
ExpectedExitCode: 1
EXIT_CODE: 1

Run state: no production file had been edited (Phase 3 not started). The only branch changes at run time were the Phase 1 split and the Phase 2 test edits.

Verbatim summary lines:

    Test Suites: 3 failed, 3 total
    Tests:       10 failed, 35 passed, 45 total

## orchestration-handoff-failure-cause.test.ts

| Case | Result | Diagnostic |
| --- | --- | --- |
| (a) through (g) | √ passed | pre-existing |
| (h) a custom Error name with non-identifier characters falls back to Error | × failed | Expected `checkpoint-read: Error`, Received `checkpoint-read: Bad Name: /home/operator` |
| (i) a custom Error name that is an identifier is the token | √ passed | positive control; an identifier name was already used before the fix |
| (j) an empty custom Error name falls back to Error | × failed | Expected `checkpoint-read: Error`, Received `checkpoint-read: ` |
| never copies an error message, path, or environment value into the cause | √ passed | pre-existing |
| M1 through M17, B1, B2, P1 | √ passed | pre-existing |

## orchestration-handoff-failure-cause-authority.test.ts

| Case | Result | Diagnostic |
| --- | --- | --- |
| A1 through A6 | √ passed | pre-existing |
| A7 envelope text is not valid JSON | × failed | Expected `envelope-parse: HANDOFF_UNSUPPORTED_VERSION`, Received `undefined` |

## orchestration-handoff-failure-cause-fallback.test.ts

Outcome: (B) — the suite ran, and F1 through F7 are each reported failed (ts-jest transpiled without type-checking, so the missing export surfaced at run time rather than as `Test suite failed to run`).

| Case | Result | Diagnostic |
| --- | --- | --- |
| F1 a HandoffContractError keeps its code and names it | × failed | `TypeError: (0 , orchestration_handoff_materializer_request_1.describeEnvelopeParseFailure) is not a function` |
| F2 a TypeError falls back to HANDOFF_UNSUPPORTED_VERSION and names the class | × failed | same `describeEnvelopeParseFailure ... is not a function` |
| F3 a thrown string is a non-error value | × failed | same `describeEnvelopeParseFailure ... is not a function` |
| F4 production validateEnvelope returns the envelope-parse cause for malformed JSON | × failed | `toMatchObject`: `failureCause` missing from the validation result |
| F5 the materializer forwards a validation failureCause to the blocked result | × failed | Expected `envelope-parse: TypeError`, Received `undefined` |
| F6 a projection error without a code yields destination-projection: TypeError | × failed | Expected `destination-projection: TypeError`, Received `undefined` |
| F7 a projection error with a code yields destination-projection: HANDOFF_UNSUPPORTED_VERSION | × failed | Expected `destination-projection: HANDOFF_UNSUPPORTED_VERSION`, Received `undefined` |

## Acceptance check

- Observed exit code 1 equals ExpectedExitCode 1.
- Rows (h) and (j) failed; row (i) passed.
- Row A7 failed; rows A1-A6 passed.
- Fallback suite: outcome (B), F1-F7 each failed.
- Every pre-existing case in the first two files passed.

FAIL_BEFORE_OUTCOME: B

Output Summary: Expected failure observed. 10 failed (h, j, A7, F1-F7), 35 passed. Row (h) shows the defect directly: a non-identifier Error name (`Bad Name: /home/operator`) reaches the cause string. The fallback suite produced outcome (B).

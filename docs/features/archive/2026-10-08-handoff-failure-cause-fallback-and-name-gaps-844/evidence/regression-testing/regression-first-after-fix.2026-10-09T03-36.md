# Regression-First Run After Fix (P3-T11)

Timestamp: 2026-10-09T03-36
Task: [P3-T11]
Working directory: extensions/drm-copilot
Command: npx jest --config jest.config.cjs --verbose test/lib/validate/orchestration-handoff-failure-cause.test.ts test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts --reporters=default
EXIT_CODE: 0

Verbatim summary lines:

    Test Suites: 3 passed, 3 total
    Tests:       45 passed, 45 total

Expected passed count: FAILURE_CAUSE_BASELINE (28) + 3 + AUTHORITY_CAUSE_BASELINE (6) + 1 + 7 = 45. Observed: 45 passed, 0 failed. PASS.

## Failed-before / passed-after pairing (AC-8)

| Case | P2-T4 (before fix) | P3-T11 (after fix) |
| --- | --- | --- |
| (h) a custom Error name with non-identifier characters falls back to Error | × failed | √ passed |
| (i) a custom Error name that is an identifier is the token | √ passed (positive control) | √ passed |
| (j) an empty custom Error name falls back to Error | × failed | √ passed |
| A7 envelope text is not valid JSON | × failed | √ passed |
| F1 a HandoffContractError keeps its code and names it | × failed | √ passed |
| F2 a TypeError falls back to HANDOFF_UNSUPPORTED_VERSION and names the class | × failed | √ passed |
| F3 a thrown string is a non-error value | × failed | √ passed |
| F4 production validateEnvelope returns the envelope-parse cause for malformed JSON | × failed | √ passed |
| F5 the materializer forwards a validation failureCause to the blocked result | × failed | √ passed |
| F6 a projection error without a code yields destination-projection: TypeError | × failed | √ passed |
| F7 a projection error with a code yields destination-projection: HANDOFF_UNSUPPORTED_VERSION | × failed | √ passed |

All pre-existing cases in the first two files (a)-(g), the message-redaction case, M1-M17, B1, B2, P1, and A1-A6 remain passed.

Output Summary: Pass. 3 suites and 45 tests passed with 0 failed. Every case that failed before the fix (h, j, A7, F1-F7) now passes; row (i) passes before and after.

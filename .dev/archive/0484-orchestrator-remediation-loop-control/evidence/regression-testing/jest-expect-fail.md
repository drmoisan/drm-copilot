# Jest Accounting and Parity Suites Before the Fix (P2-T8, expect-fail)

Timestamp: 2026-10-01T21-44
Task: P2-T8
Command: npm run test:unit -- test/lib/validate/orchestrator-state-remediation-accounting.test.ts test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts (run from extensions/drm-copilot)
EXIT_CODE: 1
ExpectedExitCode: 1

Key lines:

```
FAIL test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts
FAIL test/lib/validate/orchestrator-state-remediation-accounting.test.ts
Test Suites: 2 failed, 2 total
Tests:       130 failed, 68 passed, 198 total
```

Failure mechanism per suite:

- Parity suite: 30 failed, one per corpus case with a non-empty `expected_errors` list (for example `reproduces the expected remediation errors for r10_pass_with_autonomous_finding`, which expects `Checkpoint remediation review outcome #0 verdict PASS does not match its findings (expected REMEDIATION_REQUIRED).` and receives no such message).
- Accounting suite: 100 failed. The suite does not fail to compile under Jest, because `tsconfig.jest.json` sets `isolatedModules: true` and ts-jest therefore transpiles without type diagnostics; the missing exports resolve to `undefined` at run time and each dependent case fails, for example `TypeError: (0 , orchestrator_state_remediation_1.deriveReviewVerdict) is not a function`, and each R5-R11 case fails on the missing messages. A separate type check (`npx tsc -p tsconfig.jest.json --noEmit`) reports exactly nine `TS2305` errors in this test file, one per missing export (`CANDIDATE_APPLIED_KEY`, `COMPLETED_ATTEMPTS_KEY`, `deriveReviewVerdict`, `HALT_CLASSES`, `NON_REMEDIABLE_CLASSES`, `OPENED_BY_REVIEW_KEY`, `REMEDIABILITY_CLASSES`, `REVIEW_OUTCOMES_KEY`, `REVIEW_VERDICTS`), and none in the parity or back-compat test files. See plan-deviations.md D3.

Output Summary: EXIT_CODE 1; `Test Suites: 2 failed, 2 total`; `Tests: 130 failed, 68 passed, 198 total`. Both suites fail before the fix, as expected.

Toolchain status for the two new files: `npx prettier --write` left the parity file unchanged and formatted the accounting file once at authoring; `npx eslint` on each file printed no problem.

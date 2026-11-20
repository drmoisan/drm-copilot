# TypeScript Part B Tests (P11-T6)

Timestamp: 2026-09-27T17-28
Command: npm --prefix extensions/drm-copilot run test -- test/lib/push-down/blast-radius-derive.test.ts test/lib/push-down/blast-radius-derive-mergeable.test.ts test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts test/lib/push-down/claude-config-carriage.test.ts
EXIT_CODE: 0
Output Summary: Exit 0. "Test Suites: 4 passed, 4 total" and "Tests: 43 passed, 43 total". The Tests summary line contains "passed" and does not contain "failed"; no line begins "FAIL ". The run covers the three test files of P11-T3 and P11-T5 and the carriage suite claude-config-carriage.test.ts, which consumes the helper edited in P11-T2.

## Full printed output

```text
> drm-copilot@1.1.12 test
> node run-jest.cjs test/lib/push-down/blast-radius-derive.test.ts test/lib/push-down/blast-radius-derive-mergeable.test.ts test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts test/lib/push-down/claude-config-carriage.test.ts


Test Suites: 4 passed, 4 total
Tests:       43 passed, 43 total
Snapshots:   0 total
Time:        0.404 s, estimated 1 s
Ran all test suites matching test/lib/push-down/blast-radius-derive.test.ts|test/lib/push-down/blast-radius-derive-mergeable.test.ts|test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts|test/lib/push-down/claude-config-carriage.test.ts.
```

## B21 Part B cases added by P11-T5

The tolerance-keys suite now holds six cases: the two Part A conflict_tolerance cases and four Part B
cases (write_intent_extraction carried verbatim, write_intent_extraction omitted when absent,
path_roots carried verbatim, path_roots omitted when absent). The repository Jest reporter does not
print per-test names.

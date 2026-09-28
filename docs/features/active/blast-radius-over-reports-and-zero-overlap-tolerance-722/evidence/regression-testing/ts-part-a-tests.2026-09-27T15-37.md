# TypeScript Part A Tests (P4-T8)

Timestamp: 2026-09-27T15-37
Command: npm --prefix extensions/drm-copilot run test -- test/lib/push-down/blast-radius-derive.test.ts test/lib/push-down/blast-radius-derive-mergeable.test.ts test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts test/lib/validate/parallel-state-tolerated-edge-fields.test.ts test/lib/push-down/claude-config-carriage.test.ts
EXIT_CODE: 0
Output Summary: Exit 0. "Test Suites: 5 passed, 5 total" and "Tests: 44 passed, 44 total". The Tests summary line contains "passed" and does not contain "failed"; no line begins "FAIL ". The carriage suite claude-config-carriage.test.ts, which consumes the helper edited in P4-T2 and was left failing by Phase 3, now passes.

## Printed summary

```text
Test Suites: 5 passed, 5 total
Tests:       44 passed, 44 total
Snapshots:   0 total
```

## Supplementary run (the two new suites only)

Command: npm --prefix extensions/drm-copilot run test -- --verbose test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts test/lib/validate/parallel-state-tolerated-edge-fields.test.ts
EXIT_CODE: 0

```text
Test Suites: 2 passed, 2 total
Tests:       7 passed, 7 total
```

The count of 7 equals the two B21 Part A cases (verbatim carriage and omission of conflict_tolerance)
plus the five B22 cases (orchestrator edge extra fields, planner edge extra fields, orchestrator
tolerated_overlaps list, planner tolerated_overlaps list, out-of-enum reason still rejected). The
repository Jest reporter does not print per-test names under --verbose.

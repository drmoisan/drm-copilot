# Acceptance-criteria Check-off, Phase 4 (P4-T10)

Timestamp: 2026-09-27T15-39
Command: edit of FEATURE/spec.md (the AC-19 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-19 (edges keep only the four reason members; the tolerated extra fields and the tolerated_overlaps list are accepted with zero errors by the Python validators and the TypeScript validator port). Its traceability row cites evidence/regression-testing/drift-and-validator-tests and ts-part-a-tests, both of which exist.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-19 | enum unchanged; tolerated fields accepted | evidence/regression-testing/drift-and-validator-tests, ts-part-a-tests | FEATURE/evidence/regression-testing/drift-and-validator-tests.2026-09-27T15-25.md; FEATURE/evidence/regression-testing/ts-part-a-tests.2026-09-27T15-37.md |

## Verification against the criterion text

- Python validators: the five B14 tests of test_validate_parallel_state_tolerated_edge_fields
  PASSED (recorded in the drift-and-validator-tests artifact).
- TypeScript validator port: parallel-state-tolerated-edge-fields.test.ts ran in the P4-T8 run,
  which exited 0 with "Tests: 44 passed, 44 total" and no failed test; its five B22 cases assert
  zero errors for the extra edge fields and the tolerated_overlaps list on both checkpoints, and
  the exact existing reason-enum error for an out-of-enum reason.

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.

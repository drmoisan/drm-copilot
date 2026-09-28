# Acceptance-criteria Check-off, Phase 2 (P2-T10)

Timestamp: 2026-09-27T15-27
Command: edit of FEATURE/spec.md (the AC-20 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-20 (drift via helper module). Its traceability row cites evidence/regression-testing/drift-and-validator-tests, which exists as FEATURE/evidence/regression-testing/drift-and-validator-tests.2026-09-27T15-25.md and records all 8 B13 tests and all 16 existing drift-conflict tests passing.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-20 | drift via helper module | evidence/regression-testing/drift-and-validator-tests | FEATURE/evidence/regression-testing/drift-and-validator-tests.2026-09-27T15-25.md |

## Verification against the criterion text

- Drift recomputation evaluates each in-flight peer pair through the scheduling rule via the new
  helper module: recompute_conflicts_with_observed calls observed_pair_is_edge of
  scripts/dev_tools/_parallel_drift_scheduling.py, which calls decide_pair
  (FEATURE/evidence/qa-gates/phase2-module-structure.2026-09-27T15-24.md).
- A tolerated pair within tolerance is not reported: test_tolerated_pair_within_tolerance_is_not_reported PASSED.
- A tolerated pair that becomes hard is reported: test_tolerated_pair_that_becomes_hard_is_reported PASSED.
- A tolerated pair that exceeds tolerance is reported: test_tolerated_pair_exceeding_tolerance_is_reported PASSED.
- Output at tolerance 0 equals the pre-change output: test_tolerance_zero_output_equals_conflict_only_output
  PASSED (compares against the conflict-only result, at tolerance 0 and with the key absent), and the
  unmodified pre-change drift conflicts module (block B45) passes all 16 nodes.

## Criteria not checked off in this phase

AC-19 (enum unchanged; tolerated fields accepted) has its Python half verified here (all 5 B14 tests
PASSED) and is checked off by P4-T10 after the TypeScript half. AC-21 (drift module not grown; drift
tests unmodified) has Phase 2 evidence (460 lines against a baseline of 499; drift-tests-unmodified
artifact) and is checked off by P18-T4.

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.

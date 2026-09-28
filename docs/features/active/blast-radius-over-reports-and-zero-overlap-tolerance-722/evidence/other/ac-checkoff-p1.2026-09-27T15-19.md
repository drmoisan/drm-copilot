# Acceptance-criteria Check-off, Phase 1 (P1-T15)

Timestamp: 2026-09-27T15-19
Command: edit of FEATURE/spec.md (the AC-15 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-15 (property tests for the scheduling rule). Its traceability row cites evidence/regression-testing/scheduling-tests-pass, which exists as FEATURE/evidence/regression-testing/scheduling-tests-pass.2026-09-27T15-18.md and records a PASSED line for each of the four properties under all three truth tables. Deviation: the properties are exhaustive checks over a fixed domain, not hypothesis tests, because hypothesis is not installed; see FEATURE/evidence/other/property-test-framework-deviation.2026-09-27T15-17.md.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-15 | property tests: edge implies conflict; tolerance 0 equals conflict; monotonicity; symmetry | evidence/regression-testing/scheduling-tests-pass | FEATURE/evidence/regression-testing/scheduling-tests-pass.2026-09-27T15-18.md |

## Verification against the criterion text

- Edge implies conflict: test_property_edge_implies_conflict, PASSED for committed, unit, and skewed.
- Tolerance 0 equals conflict: test_property_tolerance_zero_equals_conflict, PASSED for all three.
- Monotonicity in tolerance_percent: test_property_monotone_in_tolerance, PASSED for all three.
- Symmetry: test_property_symmetric_decision, PASSED for all three.
- Framework: the criterion names hypothesis. hypothesis is not installed and the plan contains no
  task that adds it; the properties are checked exhaustively over 13,689 decisions per truth table
  instead (property-test-framework-deviation.2026-09-27T15-17.md records the absent-package run and
  the discrimination measurement). This check-off rests on property coverage; the framework
  difference is reported to the caller.

## Criteria not checked off in this phase

AC-13 (edge rule, each term tested in both runtimes) and AC-16 (reader rejections in both runtimes)
depend on the PowerShell work of Phase 5 and are checked off by P5-T13. AC-07 through AC-12 and AC-14
are checked off by P7-T6.

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.

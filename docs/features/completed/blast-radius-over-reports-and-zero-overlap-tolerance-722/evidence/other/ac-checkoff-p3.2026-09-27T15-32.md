# Acceptance-criteria Check-off, Phase 3 (P3-T12)

Timestamp: 2026-09-27T15-32
Command: edit of FEATURE/spec.md (the AC-17 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-17 (both config copies carry the committed conflict_tolerance values, byte-equal). Its traceability row cites evidence/regression-testing/config-and-historical-before, which exists as FEATURE/evidence/regression-testing/config-and-historical-before.2026-09-27T15-30.md and records the four B16 Part A cases and the byte-equal B19 case for conflict_tolerance passing.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-17 | both config copies carry committed values | evidence/regression-testing/config-and-historical-before | FEATURE/evidence/regression-testing/config-and-historical-before.2026-09-27T15-30.md |

## Verification against the criterion text

- Both config copies carry conflict_tolerance with the committed values of the spec:
  test_committed_conflict_tolerance_values[self-hosted] and [bundled] PASSED; the strict reader
  accepts both copies (test_committed_conflict_tolerance_reads_cleanly, both PASSED).
- Byte-equal between the copies: conflict_tolerance is in the byte-equal key tuple and
  test_class_one_keys_are_equal_across_both_committed_copies[conflict_tolerance] PASSED; the
  exhaustiveness case test_every_top_level_key_is_classified_and_shared_by_both_copies PASSED.
- The committed append_only_paths value is exactly the two entries of block B2, as decided in
  FEATURE/evidence/baseline/config-value-inputs.2026-09-27T15-12.md.

## Criteria not checked off in this phase

AC-03 (three historical fixtures with BEFORE and AFTER) has its BEFORE half delivered here (three
fixtures, all B18 BEFORE tests passing) and is checked off by P12-T9 after the AFTER sections. AC-05
(historical tests read committed fixtures only) is checked off by P13-T3; the Python test file
contains none of the three forbidden substrings at this point.

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.

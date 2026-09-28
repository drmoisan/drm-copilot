# Acceptance-criteria Check-off, Phase 9 (P9-T14)

Timestamp: 2026-09-27T17-08
Command: edit of FEATURE/spec.md (the AC-28 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-28 (the 28th checklist entry of the Acceptance Criteria section, spec line 662, confirmed by counting checkbox lines in document order). Its traceability row cites evidence/regression-testing/config-part-b, which exists and records 17 passed tests.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-28 | config copies: mandate amendment, flag, path_roots | evidence/regression-testing/config-part-b | FEATURE/evidence/regression-testing/config-part-b.2026-09-27T17-06.md; FEATURE/evidence/other/config-part-b-members.2026-09-27T17-04.md |

## Verification against the criterion text

- Both config copies add .github/copilot-instructions.md to mandate_reads:
  test_mandate_reads_include_copilot_instructions[self-hosted] and [bundled] PASSED.
- Both set write_intent_extraction to true: test_committed_write_intent_extraction_is_true[self-hosted]
  and [bundled] PASSED, and the Class 1 byte-equal node for write_intent_extraction PASSED.
- path_roots: the self-hosted value equals the P0-T28 directory list
  (test_self_hosted_path_roots_match_pinned_directory_list PASSED) and the bundled value is an empty
  list (test_class_two_bundled_path_roots_are_empty PASSED).

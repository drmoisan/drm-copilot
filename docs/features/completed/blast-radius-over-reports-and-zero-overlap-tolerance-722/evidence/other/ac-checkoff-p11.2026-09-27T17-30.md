# Acceptance-criteria Check-off, Phase 11 (P11-T8)

Timestamp: 2026-09-27T17-30
Command: edit of FEATURE/spec.md (the AC-30 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-30 (the 30th checklist entry of the Acceptance Criteria section, spec line 672, confirmed by counting checkbox lines in document order). Its traceability row cites evidence/regression-testing/ts-part-b-tests, which exists and records 4 suites and 43 tests passed.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-30 | TypeScript carries three keys; tests pass | evidence/regression-testing/ts-part-b-tests | FEATURE/evidence/regression-testing/ts-part-b-tests.2026-09-27T17-28.md; FEATURE/evidence/qa-gates/phase11-ts-static.2026-09-27T17-29.md; FEATURE/evidence/regression-testing/ts-part-a-tests.2026-09-27T15-37.md |

## Verification against the criterion text

- The derivation core carries conflict_tolerance (Phase 4), write_intent_extraction, and path_roots
  (P11-T1) verbatim through the carried-key list and the emitted document literal.
- blast-radius-derive-tolerance-keys.test.ts confirms each of the three keys reaches the destination
  document verbatim and is omitted when the source lacks it (two Part A and four Part B cases).
- The key-order assertions in blast-radius-derive.test.ts and blast-radius-derive-mergeable.test.ts
  use the Part B order of block B20, and the source-document helper
  config-carriage.test-helpers.ts equals the bundled config; all four suites pass (43 tests).
- Prettier check, ESLint, and tsc pass (phase11-ts-static).

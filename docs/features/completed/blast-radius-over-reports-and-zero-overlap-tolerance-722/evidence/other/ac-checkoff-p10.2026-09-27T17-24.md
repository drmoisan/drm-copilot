# Acceptance-criteria Check-off, Phase 10 (P10-T14)

Timestamp: 2026-09-27T17-24
Command: edit of FEATURE/spec.md (the AC-22, AC-23, AC-24, AC-25, AC-26, AC-27, and AC-29 checkboxes changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: Seven criteria checked off in FEATURE/spec.md: AC-22, AC-23, AC-24, AC-25, AC-26, AC-27, and AC-29 (checklist entries 22 through 27 and 29 of the Acceptance Criteria section, spec lines 648, 651, 654, 656, 659, 660, and 668, confirmed by counting checkbox lines in document order). Their traceability rows cite evidence/regression-testing/write-intent-python, pester-part-b, and config-part-b, all of which exist and record passing runs (Python 28 passed; Pester write-intent 28 of 28 and key-partition 6 of 6; Python config 17 passed).

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-22 | W1-W6 in both runtimes | evidence/regression-testing/write-intent-python, pester-part-b | FEATURE/evidence/regression-testing/write-intent-python.2026-09-27T17-02.md; FEATURE/evidence/regression-testing/pester-part-b.2026-09-27T17-20.md |
| AC-23 | shared-surface read-citation fixture | evidence/regression-testing/write-intent-python | FEATURE/evidence/regression-testing/write-intent-python.2026-09-27T17-02.md; FEATURE/evidence/regression-testing/pester-part-b.2026-09-27T17-20.md |
| AC-24 | spec-contracts-only fixture | evidence/regression-testing/write-intent-python | FEATURE/evidence/regression-testing/write-intent-python.2026-09-27T17-02.md; FEATURE/evidence/regression-testing/pester-part-b.2026-09-27T17-20.md |
| AC-25 | flag-absent identity fixture, both runtimes | evidence/regression-testing/pester-part-b | FEATURE/evidence/regression-testing/pester-part-b.2026-09-27T17-20.md; FEATURE/evidence/regression-testing/write-intent-python.2026-09-27T17-02.md |
| AC-26 | derived radius passes V1 and V2 in write-intent mode | evidence/regression-testing/write-intent-python | FEATURE/evidence/regression-testing/write-intent-python.2026-09-27T17-02.md; FEATURE/evidence/regression-testing/pester-part-b.2026-09-27T17-20.md |
| AC-27 | vocabularies pinned by parity test | evidence/regression-testing/pester-part-b | FEATURE/evidence/regression-testing/pester-part-b.2026-09-27T17-20.md |
| AC-29 | key-partition tests classify new keys | evidence/regression-testing/config-part-b | FEATURE/evidence/regression-testing/config-part-b.2026-09-27T17-06.md; FEATURE/evidence/regression-testing/pester-part-b.2026-09-27T17-20.md |

## Verification against the criterion text

- AC-22: each rule has a named Python test (test_w1_* through test_w6_*) and a Pester It ('drops
  glob-mention tokens (W1)' through 'drops placeholder-stem tokens (W6)'), and a write-intent fixture
  (glob-mention, command-span, read-task, root-anchoring, spec-contracts-only, placeholder-stem)
  reproduced in both runtimes. The rules are active only when the flag is true: the flag-absent and
  flag-false cases reproduce current extraction.
- AC-23: the shared-surface-read-citation fixture passes in both runtimes: items A (read task) and D
  (command span) record no shared surface; B and C (write tasks) keep config/blast-radius.json and form
  one hard edge (2, 3) at tolerance 100; no pair with A or D is an edge or a tolerated overlap.
- AC-24: the spec-contracts-only fixture passes in both runtimes: paths are {FG, src/app.py} (none from
  the spec) and contracts are {computeWidget} (the wildcard token and the command span contribute none).
- AC-25: the flag-absent-matches-current fixture passes in both runtimes for both the absent and false
  cases: derivation keeps the current tokens, normalization returns the recorded radius unchanged, and
  validation reports no finding; the Python and Pester flag-absent and flag-false unit cases also
  compare against a config without both keys.
- AC-26: test_derived_radius_passes_v1_v2_in_write_intent_mode and the Pester 'derives radii that pass
  V1 and V2 in write-intent mode' validate all 11 fixture items with zero V1 and V2 findings; both
  validators select the plan-side extractor through the shared selector (select_plan_paths and
  Get-PlanPathForConfig).
- AC-27: the Pester case 'pins the same read-verb, write-verb, and placeholder-stem sets as the Python
  module' reads the committed Python module source and compares each of the three vocabularies with
  the PowerShell constants member for member; the Python test pins the same three lists.
- AC-29: write_intent_extraction is in the Python byte-equal key tuple (Class 1 node
  [write_intent_extraction] PASSED) and in the PowerShell Class 1 list ('declares equal values for the
  runtime-describing keys in both copies' passed); path_roots is in the Python Class 2 registry
  CLASS_TWO_TOLERANCE_KEY_ASSERTIONS consumed by test_class_two_bundled_path_roots_are_empty and in the
  PowerShell Class 2 consumer registry consumed by 'declares an empty bundled path_roots list'; the
  exhaustiveness tests pass in both runtimes with every key present in both copies. conflict_tolerance
  was classified in Part A.

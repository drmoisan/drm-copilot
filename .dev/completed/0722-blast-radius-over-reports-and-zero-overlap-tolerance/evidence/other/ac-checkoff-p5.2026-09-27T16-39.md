# Acceptance-criteria Check-off, Phase 5 (P5-T15)

Timestamp: 2026-09-27T16-39
Command: edit of FEATURE/spec.md (the AC-13 and AC-16 checkboxes changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: Two criteria checked off in FEATURE/spec.md: AC-13 (edge rule implemented in both runtimes, each term covered by a named unit test) and AC-16 (conflict_tolerance reader rejects every invalid shape with an error naming the key, in both runtimes). Their traceability rows cite evidence/regression-testing/scheduling-tests-pass and pester-part-a, both of which exist.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-13 | edge rule implemented, each term tested | evidence/regression-testing/scheduling-tests-pass, pester-part-a | FEATURE/evidence/regression-testing/scheduling-tests-pass.2026-09-27T15-18.md; FEATURE/evidence/regression-testing/pester-part-a.2026-09-27T15-52.md; re-run FEATURE/evidence/regression-testing/pester-part-a.2026-09-27T16-35.md |
| AC-16 | conflict_tolerance reader rejections, both runtimes | evidence/regression-testing/pester-part-a | FEATURE/evidence/regression-testing/pester-part-a.2026-09-27T15-52.md; re-run FEATURE/evidence/regression-testing/pester-part-a.2026-09-27T16-35.md |

## Verification against the criterion text

- AC-13: the Python scheduling tests passed in P1-T12 (scheduling-tests-pass artifact). The Pester
  P5-T2 file ran 50/50 with the 'Edge rule terms' context naming each term (hard classes, same_file,
  append_only precedence, possible_overlap, module weight, mergeable zero, minimum band benefit,
  default_band, strict integer inequality boundary, first canonical reason kind, absent key strict),
  and the scheduling module line coverage was 100 percent. The re-run after the P5-T14 format change
  printed identical counts.
- AC-16: the Pester 'conflict_tolerance reader' context passed every rejection case (the P5-T10
  artifact lists 15 lines containing "rejects"); the Python reader rejections passed in P1-T12.

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.

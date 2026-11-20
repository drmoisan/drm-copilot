# Acceptance-criteria Check-off, Phase 7 (P7-T6)

Timestamp: 2026-09-27T16-49
Command: edit of FEATURE/spec.md (the AC-07, AC-08, AC-09, AC-10, AC-11, AC-12, and AC-14 checkboxes changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: Seven criteria checked off in FEATURE/spec.md: AC-07, AC-08, AC-09, AC-10, AC-11, AC-12, and AC-14. Their traceability rows cite evidence/qa-gates/part-a-strict-identity-python and part-a-strict-identity-powershell, both of which exist and record passing runs (Python 13 passed; PowerShell six filtered runs, each FailedCount=0 with PassedCount of at least 1).

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-07 | strict identity tests, Python and Pester | evidence/qa-gates/part-a-strict-identity-python | FEATURE/evidence/qa-gates/part-a-strict-identity-python.2026-09-27T16-46.md; FEATURE/evidence/qa-gates/part-a-strict-identity-powershell.2026-09-27T16-47.md |
| AC-08 | absent-key identity fixture | evidence/qa-gates/part-a-strict-identity-powershell | FEATURE/evidence/qa-gates/part-a-strict-identity-powershell.2026-09-27T16-47.md; FEATURE/evidence/qa-gates/part-a-strict-identity-python.2026-09-27T16-46.md |
| AC-09 | #452 shared-surface case hard | evidence/qa-gates/part-a-strict-identity-python | FEATURE/evidence/qa-gates/part-a-strict-identity-python.2026-09-27T16-46.md; FEATURE/evidence/qa-gates/part-a-strict-identity-powershell.2026-09-27T16-47.md |
| AC-10 | #452 directory-prefix case weighted, edge at 0 | evidence/qa-gates/part-a-strict-identity-python | FEATURE/evidence/qa-gates/part-a-strict-identity-python.2026-09-27T16-46.md; FEATURE/evidence/qa-gates/part-a-strict-identity-powershell.2026-09-27T16-47.md |
| AC-11 | #452 negative controls edge-free | evidence/qa-gates/part-a-strict-identity-powershell | FEATURE/evidence/qa-gates/part-a-strict-identity-powershell.2026-09-27T16-47.md; FEATURE/evidence/qa-gates/part-a-strict-identity-python.2026-09-27T16-46.md |
| AC-12 | #452 fixtures embed radii | evidence/qa-gates/part-a-strict-identity-python | FEATURE/evidence/qa-gates/part-a-strict-identity-python.2026-09-27T16-46.md (test_452_scheduling_fixtures_embed_radii PASSED) |
| AC-14 | soft-pair tolerated fixture | evidence/qa-gates/part-a-strict-identity-python | FEATURE/evidence/qa-gates/part-a-strict-identity-python.2026-09-27T16-46.md; FEATURE/evidence/qa-gates/part-a-strict-identity-powershell.2026-09-27T16-47.md |

## Verification against the criterion text

- AC-07: Python test_strict_identity_over_existing_conflict_fixtures, test_before_strict_scheduling_equals_detection
  (three runs), and test_before_cohorts_match_pins (three runs) passed. Pester "matches detection at
  tolerance 0" passed for all 15 existing conflict fixtures (P7-T2 run 6), and the Pester historical-run
  file (BlastRadius.HistoricalRuns.Tests.ps1) passed "reproduces the pinned BEFORE edges" and "matches
  detection at tolerance 0" for all three runs (pester-part-a artifacts of P5-T10, 6/6). The cohort
  coloring equality with the pinned BEFORE partition is asserted by the Python node
  test_before_cohorts_match_pins; cohort coloring has no PowerShell implementation (it is a Python and
  bash function of the edge list), and the Pester side asserts the edge list that coloring consumes
  equals the pinned BEFORE edges.
- AC-08: scheduling-absent-key-strict passed in Python and in Pester (P7-T2 run 5).
- AC-09: scheduling-452-shared-surface-hard passed in both runtimes; the fixture records hard true at
  tolerance_percent 0, 100 (committed), and 1000000.
- AC-10: scheduling-452-directory-prefix-weighted passed in both runtimes; the fixture records a
  detected conflict with cost 2 (the possible_overlap weight) and hard false, an edge at tolerance 0.
- AC-11: scheduling-452-negative-controls passed in both runtimes at tolerance_percent 0, 100, and
  1000000.
- AC-12: test_452_scheduling_fixtures_embed_radii passed (Python) and "embeds the radii in every #452
  scheduling fixture" is part of the Pester file that ran 50/50 in P5-T10.
- AC-14: scheduling-soft-pair-tolerated passed in both runtimes.

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.

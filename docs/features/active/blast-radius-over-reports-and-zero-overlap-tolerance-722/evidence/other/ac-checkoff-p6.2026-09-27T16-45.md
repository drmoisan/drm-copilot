# Acceptance-criteria Check-off, Phase 6 (P6-T10)

Timestamp: 2026-09-27T16-45
Command: edit of FEATURE/spec.md (the AC-18 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-18 (the parallel-plan and parallel-add skills and the parallel-planner agent, and their bundled mirrors, call the scheduling function instead of a hand pair loop, record tolerated overlaps, and state the soft-overlap merge rule). Its traceability row cites evidence/regression-testing/mirror-contract-p6, which exists.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-18 | skills and agent call scheduling function | evidence/regression-testing/mirror-contract-p6 | FEATURE/evidence/regression-testing/mirror-contract-p6.2026-09-27T16-44.md; FEATURE/evidence/regression-testing/mirror-hashes-p6.2026-09-27T16-44.md |

## Verification against the criterion text

- Scheduling function instead of a hand pair loop: step 1 of the parallel-plan seeding procedure,
  step 3 of parallel-add, and the parallel-planner library section each name
  Get-BlastRadiusConflictEdge (and the Python schedule_conflict_edges) and state that the detection
  relation is not applied to each pair by hand.
- Tolerated overlaps recorded: each of the three files names the tolerated_overlaps list on the
  checkpoint.
- Soft-overlap merge rule: each of the three files states that the later-merging item of a tolerated
  pair merges origin/main and re-passes CI.
- Bundled mirrors: the four A5 pairs of mirror-hashes-p6 print equal hashes.
- Contract tests: the B43 Python run (92 passed) and TypeScript run (57 passed) in mirror-contract-p6
  show no failure.

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.

# Acceptance-criteria Check-off, Phase 0 (P0-T34)

Timestamp: 2026-09-27T15-27
Command: edit of FEATURE/spec.md (the AC-02 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-02 (P0 historical re-derivation, both runtimes). Its traceability row cites evidence/baseline/historical-before-rederivation, which exists as FEATURE/evidence/baseline/historical-before-rederivation.2026-09-27T15-10.md and records MATCH for all three runs.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-02 | P0 historical re-derivation, both runtimes | evidence/baseline/historical-before-rederivation | FEATURE/evidence/baseline/historical-before-rederivation.2026-09-27T15-10.md |

## Verification against the criterion text

- Recorded radii read verbatim with git show from each run's plan-home ref: yes, at the plan-home
  commit recorded by P0-T23 (FEATURE/evidence/baseline/historical-extract.2026-09-27T15-00.md; the
  verbatim-copy cross-check matched 228, 346, and 594 radius entries).
- BEFORE edge member set, edge count, cohort partition, cohort count, and maximum cohort width computed
  independently by the Python and PowerShell runtimes: yes (contracts C2 and C3; the PowerShell partition
  is computed by applying the Python cohort-coloring function to the PowerShell edge set, as stated in
  the artifact).
- The two member sets compared explicitly: yes (contract C4; empty symmetric difference; MATCH for all
  three runs).
- The artifact records the commit, the commands, both member sets, and the comparison: yes.
- Values pinned into fixtures only after the two runtimes agree: no value has been pinned yet; the
  runtimes agree, so the pinning in Phase 3 is not blocked.

## Criteria not checked off in this phase

AC-01 (P0 #452 detection gate) is checked off by P14-T8 per the traceability table, after the P14-T3
re-gate. Its Phase 0 evidence exists (452-fixture-inventory, 452-gate-python, 452-gate-powershell). The
PowerShell gate artifact records a deviation: the per-fixture FullName filter of P0-T22 selects zero
tests under Pester 5.6.1, and the gate outcome was observed from an unfiltered run of the same file.

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.

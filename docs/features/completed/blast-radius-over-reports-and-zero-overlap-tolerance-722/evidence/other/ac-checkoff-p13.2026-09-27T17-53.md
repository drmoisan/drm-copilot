# Acceptance-criteria Check-off, Phase 13 (P13-T3)

Timestamp: 2026-09-27T17-53
Command: edit of FEATURE/spec.md (the AC-05 checkbox changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: One criterion checked off in FEATURE/spec.md: AC-05 (the 5th checklist entry of the Acceptance Criteria section, spec line 590, confirmed by counting checkbox lines in document order). Its traceability row cites evidence/qa-gates/historical-tests-no-forbidden-refs, which records both historical test files as tracked (exit 0 each) and the forbidden-reference search as exiting 1 with no output.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-05 | historical tests read committed fixtures only | evidence/qa-gates/historical-tests-no-forbidden-refs | FEATURE/evidence/qa-gates/historical-tests-no-forbidden-refs.2026-09-27T17-50.md; FEATURE/evidence/regression-testing/historical-after-tests.2026-09-27T17-48.md |

## Verification against the criterion text

- The Python module test_blast_radius_historical_runs asserts the pinned BEFORE values (radius sizes, edges, strict-scheduling identity, cohorts) and the pinned AFTER values (edges, tolerated overlaps, cohorts, and the AFTER-subset-of-BEFORE relation) for all three runs: 24 passed.
- The Pester file BlastRadius.HistoricalRuns.Tests asserts the pinned BEFORE edges, detection identity at tolerance 0, and the pinned AFTER edges and tolerated overlaps for all three runs: 9 passed, FailedCount=0. Cohort partitions are asserted by the Python module only, as block B24 specifies.
- Both files read only the committed fixtures under tests/fixtures/blast_radius/historical-runs, are tracked, and contain none of origin/, artifacts/, or worktree (git grep exit 1, no output).

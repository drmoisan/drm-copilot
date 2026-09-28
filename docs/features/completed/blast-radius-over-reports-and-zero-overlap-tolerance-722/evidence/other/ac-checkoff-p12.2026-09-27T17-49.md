# Acceptance-criteria Check-off, Phase 12 (P12-T9)

Timestamp: 2026-09-27T17-49
Command: edit of FEATURE/spec.md (the AC-03 and AC-04 checkboxes changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: Two criteria checked off in FEATURE/spec.md: AC-03 (spec line 583) and AC-04 (spec line 587), the 3rd and 4th checklist entries of the Acceptance Criteria section, confirmed by counting checkbox lines in document order. AC-03 cites evidence/regression-testing/historical-after-tests (24 pytest PASSED; Pester 9/9). AC-04 cites evidence/qa-gates/historical-before-after-summary, which states BEFORE, AFTER (recorded radii), and AFTER (plan text) edge count, cohort count, and maximum cohort width for each of the three runs.

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-03 | three historical fixtures with BEFORE and AFTER | evidence/regression-testing/historical-after-tests | FEATURE/evidence/regression-testing/historical-after-tests.2026-09-27T17-48.md (re-run after black; the 17-44 run is kept); FEATURE/evidence/other/historical-fixtures-after.2026-09-27T17-40.md |
| AC-04 | final BEFORE/AFTER evidence incl. W2, W3, W5 | evidence/qa-gates/historical-before-after-summary | FEATURE/evidence/qa-gates/historical-before-after-summary.2026-09-27T17-38.md (cites FEATURE/evidence/baseline/historical-before-rederivation.2026-09-27T15-10.md, FEATURE/evidence/qa-gates/historical-after-recorded-radii.2026-09-27T17-32.md, and FEATURE/evidence/qa-gates/historical-after-plan-text.2026-09-27T17-36.md) |

## BEFORE and AFTER values recorded by the AC-04 artifact

| Run | BEFORE edges / cohorts / max width | AFTER (recorded radii) edges / cohorts / max width | AFTER (plan text) edges / cohorts / max width |
| --- | --- | --- | --- |
| epic-655-followups | 1 / 2 / 1 | 1 / 2 / 1 | 0 / 1 / 2 |
| backlog-2026-09-26 | 4 / 2 / 3 | 2 / 2 / 3 | 2 / 2 / 3 |
| followups-2026-09-27 | 46 / 8 / 2 | 17 / 5 / 4 | 15 / 5 / 4 |

## Verification against the criterion text

- AC-03: tests/fixtures/blast_radius/historical-runs holds followups-2026-09-27.json, backlog-2026-09-26.json, and epic-655-followups.json. Each carries the recorded radii (items[].radius), the per-item complexity_band with band_source (null plus "default_band" for epic-655-followups), the pre-change config (before.config), the pinned radius sizes (expected_radius_sizes), and before and after sections with edges, cohorts, cohort_count, and max_cohort_width (after also carries its config and tolerated_overlaps). The B18 tests assert every BEFORE and AFTER value for all three runs and pass.
- AC-04: the summary artifact lies under this feature folder's evidence tree and reports, per run, BEFORE and AFTER edge count, cohort count, and maximum cohort width. Its AFTER (plan text) columns come from P12-T2, which re-derived each item's radius from the plan and spec text at the pinned commit BASE_SHA beae3f021674e64fa6662097fe48a332d8da62b8 with write-intent extraction enabled, so the line-context rules W2 and W3 and the spec-contracts-only rule W5 apply. Every value was verified in both runtimes (MATCH).

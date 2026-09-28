# Historical BEFORE and AFTER Summary (P12-T3)

Timestamp: 2026-09-27T17-38
Command: none (summary of three cited artifacts; every value below is copied from them)
EXIT_CODE: 0
Output Summary: Three historical runs, each with BEFORE, AFTER (recorded radii), and AFTER (plan text) edge count, cohort count, and maximum cohort width. epic-655-followups: BEFORE 1/2/1, AFTER recorded radii 1/2/1, AFTER plan text 0/1/2. backlog-2026-09-26: BEFORE 4/2/3, AFTER recorded radii 2/2/3, AFTER plan text 2/2/3. followups-2026-09-27: BEFORE 46/8/2, AFTER recorded radii 17/5/4, AFTER plan text 15/5/4 (each triple is edges/cohorts/maximum cohort width). No AFTER edge count exceeds its BEFORE edge count, and in both AFTER derivations every run's cohort count is at most its BEFORE cohort count.

## Cited artifacts

| Column group | Source task | Artifact |
| --- | --- | --- |
| BEFORE | P0-T27 | FEATURE/evidence/baseline/historical-before-rederivation.2026-09-27T15-10.md (per-run JSON: FEATURE/evidence/other/historical-S-before-python.2026-09-27T15-05.json) |
| AFTER (recorded radii) | P12-T1 | FEATURE/evidence/qa-gates/historical-after-recorded-radii.2026-09-27T17-32.md (per-run JSON: FEATURE/evidence/other/historical-S-after-python.2026-09-27T17-32.json) |
| AFTER (plan text) | P12-T2 | FEATURE/evidence/qa-gates/historical-after-plan-text.2026-09-27T17-36.md (per-run JSON: FEATURE/evidence/other/historical-S-planafter-python.2026-09-27T17-36.json) |

FEATURE is docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722 and S is the run slug. Every run in every cited artifact was verified in both runtimes (Python and PowerShell) and printed MATCH.

## Summary table (three rows, nine numeric columns)

| Run | BEFORE edges | BEFORE cohorts | BEFORE max width | AFTER (recorded radii) edges | AFTER (recorded radii) cohorts | AFTER (recorded radii) max width | AFTER (plan text) edges | AFTER (plan text) cohorts | AFTER (plan text) max width |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| epic-655-followups | 1 | 2 | 1 | 1 | 2 | 1 | 0 | 1 | 2 |
| backlog-2026-09-26 | 4 | 2 | 3 | 2 | 2 | 3 | 2 | 2 | 3 |
| followups-2026-09-27 | 46 | 8 | 2 | 17 | 5 | 4 | 15 | 5 | 4 |

## Per-run BEFORE and AFTER tables

### epic-655-followups

| Measure | BEFORE | AFTER (recorded radii) | AFTER (plan text) |
| --- | --- | --- | --- |
| Edge count | 1 | 1 | 0 |
| Tolerated overlaps | not applicable (no scheduling layer) | 0 | 0 |
| Cohort count | 2 | 2 | 1 |
| Maximum cohort width | 1 | 1 | 2 |
| Cohort partition | [[660], [663]] | [[660], [663]] | [[660, 663]] |

### backlog-2026-09-26

| Measure | BEFORE | AFTER (recorded radii) | AFTER (plan text) |
| --- | --- | --- | --- |
| Edge count | 4 | 2 | 2 |
| Tolerated overlaps | not applicable (no scheduling layer) | 0 | 0 |
| Cohort count | 2 | 2 | 2 |
| Maximum cohort width | 3 | 3 | 3 |
| Cohort partition | [[513, 528, 622], [588, 594]] | [[513, 588, 594], [528, 622]] | [[513, 588, 594], [528, 622]] |

### followups-2026-09-27

| Measure | BEFORE | AFTER (recorded radii) | AFTER (plan text) |
| --- | --- | --- | --- |
| Edge count | 46 | 17 | 15 |
| Tolerated overlaps | not applicable (no scheduling layer) | 1 (708-711, module_overlap) | 0 |
| Cohort count | 8 | 5 | 5 |
| Maximum cohort width | 2 | 4 | 4 |
| Cohort partition | [[710], [713], [716], [707, 714], [708], [712], [706, 709], [711, 715]] | [[707, 712, 714, 715], [706, 709, 711, 716], [708], [710], [713]] | [[706, 707, 712, 714], [710, 711, 715, 716], [713], [708], [709]] |

## Derivation notes

- BEFORE: the recorded radii with the pre-change config (config/blast-radius.json at BASE_SHA beae3f021674e64fa6662097fe48a332d8da62b8) through the unchanged detection relation; every conflict is an edge.
- AFTER (recorded radii): the same recorded radii normalized with the committed config (HEAD 6f81b876df5dfb2334cf84c58b2dd408dbba5335; write_intent_extraction true, path_roots set, conflict_tolerance at tolerance_percent 100), then scheduled with the integration-cost edge rule. Normalization applies the token-level rules W1, W4, and W6 only.
- AFTER (plan text): each item's plan and spec text at BASE_SHA re-derived with the committed config, so the line-context rules W2 and W3 and the spec-contracts-only rule W5 also apply, then scheduled with the same edge rule. Items 660 and 528 carry no spec (SPEC-ABSENT, "- Work Mode: minor-audit").
- Subset check (SCRATCH/p12-subset-check.py, comparing the (a, b) pair sets of the cited per-run JSON files): in every run, both the AFTER (recorded radii) and the AFTER (plan text) edge pair sets are subsets of the BEFORE edge pair set, with no extra pair. Printed output:

```text
SUBSET slug=epic-655-followups after=recorded subset=True extra=[]
SUBSET slug=epic-655-followups after=plantext subset=True extra=[]
SUBSET slug=backlog-2026-09-26 after=recorded subset=True extra=[]
SUBSET slug=backlog-2026-09-26 after=plantext subset=True extra=[]
SUBSET slug=followups-2026-09-27 after=recorded subset=True extra=[]
SUBSET slug=followups-2026-09-27 after=plantext subset=True extra=[]
```

The pinned fixtures and the test test_after_edges_are_subset_of_before_edges (P12-T4 through P12-T7) assert the recorded-radii subset relation from committed data.

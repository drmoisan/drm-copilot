# Recalibration Basis and Before/After Scheduling Comparison (P1-T5)

Timestamp: 2026-11-09T23-45
Command: sh SCRATCH/issue-1164-recalibration.sh (env -u VIRTUAL_ENV poetry run python SCRATCH/issue-1164-recalibration.py <worktree>: schedule_conflict_edges over the five items of tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json, with the fixture's after.config and its conflict_tolerance replaced by each value set)
EXIT_CODE: 0
Output Summary:
- Items (issue_num, band): 513 C2, 528 C2, 588 C3, 594 C3, 622 C3. No item carries read_paths or separable_paths, so the access rows of spec B2 do not apply.
- Old committed values (weights same_file 8, possible_overlap 2, append_only 1, module 2, contract 8; bands 1/2/4/8; three append_only_paths): 3 edges, 1 tolerated overlap.
  - 528:588 edge, cost 16, benefit 2
  - 528:594 edge, cost 6, benefit 2
  - 588:622 edge, cost 230, benefit 4
  - 594:622 tolerated, cost 4, benefit 4
- New committed values (spec B3 minutes: same_file 90, possible_overlap 20, append_only 10, module 10, contract 90, separable 15; bands 30/45/90/180; four append_only_paths): 3 edges, 1 tolerated overlap.
  - 528:588 edge, cost 180, benefit 45
  - 528:594 edge, cost 60, benefit 45
  - 588:622 edge, cost 2540, benefit 90
  - 594:622 tolerated, cost 30, benefit 90
- Pairs whose verdict changed: 0. Every pair of this fixture keeps its verdict; the merge-time and gain estimates are now integer minutes.

Measured durations behind the committed values (research section 3.2):
- Item execution-phase duration, run bug-burndown-2026-10-11: C2 (n=8) 58, 50, 33, 43, 31, 34, 41, 30 minutes, median 37.5, mean 40.0; C3 (n=6, excluding #901 and #903) 76, 73, 76, 186, 60, 44 minutes, median 74.5, mean 85.8.
- Full-feature execution start to CI end: #1105 205 min, #1153 215 min; lower bounds #1139 138+, #1130 114+, #1127 104+, #1136 72+, #1106 61+.
- One remediation pass: #1105 113, #1139 40, #1153 53, #1130 5 (+3.5 re-review) minutes, median about 47; one CI pass: #1105 17, #1153 63, #1009 about 25 minutes.
- Derivation (research section 3.4): C1 30 (below the C2 median), C2 45 (C2 median 37.5, mean 40), C3 90 (C3 mean 85.8), C4 180 (twice C3; largest measured 205-215); same_file 90 (one remediation pass plus one CI pass); contract 90; possible_overlap 20; module 10; append_only 10; separable 15; read-only on either side 0. The sample is small (8 C2 and 6 C3 executions from one run; no measured C1 or C4), recorded for owner review as decision D2.

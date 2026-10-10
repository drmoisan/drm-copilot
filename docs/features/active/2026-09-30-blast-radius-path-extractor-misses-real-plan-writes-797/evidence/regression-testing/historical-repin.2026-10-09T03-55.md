# Historical Fixture Re-Pin (P4-T4, P4-T5, P4-T6)

Timestamp: 2026-10-09T03-55
Command: git diff --numstat 3d5a8446d6e39f66dd593a53280e47aedd83ba1c -- tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json tests/fixtures/blast_radius/historical-runs/epic-655-followups.json tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json; git diff -U0 3d5a8446d6e39f66dd593a53280e47aedd83ba1c -- tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json; grep -n '"after": {' tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json
EXIT_CODE: 0
Output Summary: one pin changed, in agreement between Python (P4-T1, P4-T3) and PowerShell (P4-T2). The numstat listing prints a line only for backlog-2026-09-26.json (`1 1`), matching the P4-T3 record that only that run moved. The single -U0 hunk header is `@@ -690 +690 @@`, whose old-side start 690 is greater than the `after` key line 570.

## Changed pins

| Fixture | Section | Field | Before | After | Python | PowerShell |
|---|---|---|---|---|---|---|
| backlog-2026-09-26.json | after.edges[1] (a 588, b 622) | cost | 152 | 160 | 160 (P4-T1, P4-T3) | 160 (P4-T2) |

`edge_count` (2), `tolerated_overlaps` ([]), `cohorts`, `cohort_count`, and `max_cohort_width` equal the P4-T3 values and were not edited. The change matches the spec's expectation (the `cost` of edge 588-622 rises by the same_file weight 8, because extensions/drm-copilot/jest.config.cjs recorded in both items now survives normalization).

## P4-T5 epic-655-followups.json

NO-CHANGE. P4-T3 recorded no difference for this run; the file is untouched and the numstat listing prints no line for it.

## P4-T6 followups-2026-09-27.json

NO-CHANGE. P4-T3 recorded no difference for this run; the file is untouched and the numstat listing prints no line for it.

## Note on the diff route

The plan runs these diffs in the PowerShell tool with `(Get-Content -LiteralPath <base-sha.txt>)` as the ref operand. Inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md), so the same `git diff` commands run in the shell with the literal SHA recorded in P0-T3 (base-sha.txt content).

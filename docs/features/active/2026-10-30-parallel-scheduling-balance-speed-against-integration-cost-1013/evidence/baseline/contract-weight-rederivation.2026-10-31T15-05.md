# D-7 Input Re-derivation (post-#1006 tree)

Timestamp: 2026-10-31T15-05
Command: Grep `possible_overlap` over the seven roots; read `conflicts` and `Test-BlastRadiusConflict`; poetry run python SCRATCH/issue-1013-p0t4c.py; Grep of the two #1006 suites
EXIT_CODE: 0
Output Summary: (a) 27 files, equal to the Weight-map set; (b) ordinal intersection of contracts; (c) n = 1 only for followups-2026-09-27 edge 708-710 (52 -> 60); (d) no for both files. Result: PASS.

## (a) Files containing `possible_overlap` under the seven roots

27 files, equal to the `Weight-map set` convention:

- `scripts/dev_tools/_blast_radius_scheduling.py`
- `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1`
- `config/blast-radius.json`
- `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`
- `.claude/rules/parallel-orchestration.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
- `tests/fixtures/blast_radius/scheduling/scheduling-soft-pair-tolerated.json`
- `tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json`
- `tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json`
- `tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json`
- `tests/fixtures/blast_radius/write-intent/write-intent-shared-surface-read-citation.json`
- `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json`
- `tests/fixtures/blast_radius/historical-runs/epic-655-followups.json`
- `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`
- `tests/fixtures/parallel_drift/tolerated-overlap-under-conflict-tolerance.json`
- `tests/fixtures/blast_radius_overlay/shared-surfaces-demote-already-append-only.json`
- `tests/scripts/dev_tools/test_blast_radius_scheduling.py`
- `tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py`
- `tests/scripts/dev_tools/test_blast_radius_historical_runs.py`
- `tests/scripts/dev_tools/test_parallel_drift_scheduling.py`
- `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`
- `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1`
- `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1`
- `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1`
- `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`
- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts`

## (b) Shared contract set

- Python: the `CONFLICT_CONTRACT_DEPENDENCY` level of `conflicts` passes `a.contracts` and `b.contracts` to `_smallest_common`, which takes `set(left) & set(right)` (ordinal string equality) and reports its minimum.
- PowerShell: the `contracts` level of `Test-BlastRadiusConflict` passes both normalized `contracts` arrays to `Get-SmallestCommonEntry`, which builds an ordinal `HashSet[string]` of the right side and keeps left entries it contains.
- The relation applies no further filtering; #1006's generic-token filter runs at extraction and normalization, before the relation.

## (c) Historical-run AFTER edges (normalized under each fixture's `after.config`)

| Run | a | b | pinned cost | n | new cost |
|---|---|---|---|---|---|
| followups-2026-09-27 | 706 | 707 | 16 | 0 | 16 |
| followups-2026-09-27 | 706 | 708 | 16 | 0 | 16 |
| followups-2026-09-27 | 706 | 710 | 16 | 0 | 16 |
| followups-2026-09-27 | 706 | 713 | 16 | 0 | 16 |
| followups-2026-09-27 | 706 | 715 | 48 | 0 | 48 |
| followups-2026-09-27 | 707 | 708 | 100 | 0 | 100 |
| followups-2026-09-27 | 707 | 709 | 50 | 0 | 50 |
| followups-2026-09-27 | 707 | 710 | 132 | 0 | 132 |
| followups-2026-09-27 | 707 | 711 | 8 | 0 | 8 |
| followups-2026-09-27 | 707 | 713 | 148 | 0 | 148 |
| followups-2026-09-27 | 708 | 709 | 34 | 0 | 34 |
| followups-2026-09-27 | 708 | 710 | 52 | 1 (`CodeCoverage.Path`) | 60 |
| followups-2026-09-27 | 708 | 713 | 76 | 0 | 76 |
| followups-2026-09-27 | 709 | 710 | 66 | 0 | 66 |
| followups-2026-09-27 | 709 | 713 | 82 | 0 | 82 |
| followups-2026-09-27 | 710 | 713 | 196 | 0 | 196 |
| followups-2026-09-27 | 714 | 716 | 16 | 0 | 16 |
| epic-655-followups | 660 | 663 | 8 | 0 | 8 |
| backlog-2026-09-26 | 528 | 588 | 8 | 0 | 8 |
| backlog-2026-09-26 | 588 | 622 | 160 | 0 | 160 |

## (d) #1006 suites

- `tests/scripts/dev_tools/test_blast_radius_generic_contracts.py`: no. It reads `COMMITTED_TABLES` and asserts token recognition, filtering sites, hard-edge absence, and tolerance-0 edge-set equality; it asserts no `cost` and constructs no `weights` map.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1`: no. It reads the committed tables through `Read-CommittedTable` and asserts the same classes; no `cost` and no `weights` map.

Result: PASS

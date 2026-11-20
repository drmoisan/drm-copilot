# Sample Report Output (P7-T8, issue #1118)

Timestamp: 2026-11-07T23-07
Command: pwsh -NoProfile -File SCRATCH/issue-1118-sample.ps1 -Root <item worktree> (dot-sources .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1, redefines its I/O seams over an in-memory fixture of one item checkpoint in review with one full remediation cycle, and prints TL;DR and Full output in epic and item mode); then sh SCRATCH/issue-1118-real.sh (real runs from the item worktree with -StartUtc 2026-11-07T15:00:00Z and -StatePath under SCRATCH: item mode -Issue 1118 -Mode TLDR, and epic mode -EpicFolder documentation-estate-tooling -Mode TLDR, run because git rev-parse --verify --quiet origin/epic/documentation-estate-tooling-integration succeeded)
EXIT_CODE: 0
Output Summary:
- Fixture: four TL;DR lines in epic mode and four in item mode; the Full output carries the State table with a Blocked row, the Wave table in steps, the per-type table with a Total row, the default lines, the unmapped and composite line (45 min of composite remediation), and the weekly line. The Now line shows the open re-audit: #12 review (0 h 10 min of median 0 h 15 min).
- No velocity, SD, straight-line, range, or no-upper-bound line appears in either the fixture or the real output (case-insensitive search count 0).
- Real item run (exit 0): Item #1118 at 30 of 37 steps (81.1%), about 0.8 hours left on the per-type estimate.
- Real epic run (exit 0): it ran from the item worktree, whose root has no artifacts/orchestration/epic-orchestrator-state.json, so no child reads as merged; the kickoff, plans, and integration-branch texts were read through git show as designed. Neither real run resolved as NOT RESOLVABLE.
- git status --porcelain after the runs: empty; the runs wrote state only to SCRATCH/issue-1118-real-item.json and SCRATCH/issue-1118-real-epic.json.

## Fixture output

```text
### Fixture: epic mode, TLDR
**TL;DR:** Epic #42 is at 17 of 29 steps (58.6%). None of the 2 features is done yet. #12 is running (14 of 17 steps).
**Elapsed:** 3 h 00 min, with about 2.5 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.
**Now:** #12 review (0 h 10 min of median 0 h 15 min). 4 of 10 types use defaults.
**Estimated time remaining:** 2 h 32 min by type (sum); 2 h 32 min wave-parallel.

### Fixture: epic mode, Full
**TL;DR:** Epic #42 is at 17 of 29 steps (58.6%). None of the 2 features is done yet. #12 is running (14 of 17 steps).
**Elapsed:** 3 h 00 min, with about 2.5 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.
**Now:** #12 review (0 h 10 min of median 0 h 15 min). 4 of 10 types use defaults.
**Estimated time remaining:** 2 h 32 min by type (sum); 2 h 32 min wave-parallel.

## Epic #42 example-epic: status at 12:00 UTC, Jan 5

**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 17 of 29 steps complete, **58.6%**.

| State | Features |
|---|---|
| Completed | None yet |
| Running | #12 (wave 1, small): 14 of 17 steps (82%). PR #8 OPEN. |
| Blocked | None |
| Pending, wave 2 | #77 (11) |

| Wave | Children | Steps | Done |
|---|---|---|---|
| 1 | 1 | 17 | 14 |
| 2 | 1 | 11 | 3 |
| Epic | 0 | 1 | 0 |
| **Total** | **2** | **29** | **17** |

| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |
|---|---|---|---|---|---|---|---|
| research | 2 | 0 | 0 | 0 | 0 h 12 min | 1 | 0 h 00 min |
| spec | 2 | 0 | 0 | 0 | 0 h 06 min | 1 | 0 h 00 min |
| plan | 3 | 0 | 0 | 0 | 0 h 12 min | 1 | 0 h 00 min |
| preflight | 2 | 0 | 1 | 0 | 0 h 10 min | 1 | 0 h 10 min |
| execution | 6 | 0 | 3 | 0 | 0 h 10 min | 4 | 0 h 30 min |
| review | 1 | 1 | 1 | 0 | 0 h 15 min | 1 | 0 h 20 min |
| pr | 1 | 0 | 1 | 0 | 0 h 03 min (default) | 0 | 0 h 03 min |
| ci | 0 | 0 | 2 | 0 | 0 h 17 min (default) | 0 | 0 h 34 min |
| merge | 0 | 0 | 2 | 0 | 0 h 05 min (default) | 0 | 0 h 10 min |
| integration-pr | 0 | 0 | 1 | 0 | 0 h 45 min (default) | 0 | 0 h 45 min |
| **Total** | **17** | **1** | **11** | **0** | | **9** | **2 h 32 min** |

pr: no measured duration; default 3 min
ci: no measured duration; default 17 min
merge: no measured duration; default 5 min
integration-pr: no measured duration; default 45 min
**Unmapped and composite stage time:** 0 h 45 min (composite remediation 0 h 45 min, unmapped stages 0 h 00 min, approximate 0 h 00 min); it enters no median.
**Weekly quota (active account):** 42.5% used, +42.5 points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone.

### Fixture: item mode, TLDR
**TL;DR:** Item #12 is at 14 of 17 steps (82.4%). None of the 1 features is done yet. #12 is running (14 of 17 steps).
**Elapsed:** 3 h 00 min, with about 0.4 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.
**Now:** #12 review (0 h 10 min of median 0 h 15 min). 3 of 9 types use defaults.
**Estimated time remaining:** 0 h 27 min by type (sum); 0 h 27 min wave-parallel.

### Fixture: item mode, Full
**TL;DR:** Item #12 is at 14 of 17 steps (82.4%). None of the 1 features is done yet. #12 is running (14 of 17 steps).
**Elapsed:** 3 h 00 min, with about 0.4 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.
**Now:** #12 review (0 h 10 min of median 0 h 15 min). 3 of 9 types use defaults.
**Estimated time remaining:** 0 h 27 min by type (sum); 0 h 27 min wave-parallel.

## Item #12: status at 12:00 UTC, Jan 5

**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 14 of 17 steps complete, **82.4%**.

| State | Features |
|---|---|
| Completed | None yet |
| Running | #12 (wave 1): 14 of 17 steps (82%). PR #8 OPEN. |
| Blocked | None |

| Wave | Children | Steps | Done |
|---|---|---|---|
| 1 | 1 | 17 | 14 |
| **Total** | **1** | **17** | **14** |

| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |
|---|---|---|---|---|---|---|---|
| research | 1 | 0 | 0 | 0 | 0 h 12 min | 1 | 0 h 00 min |
| spec | 1 | 0 | 0 | 0 | 0 h 06 min | 1 | 0 h 00 min |
| plan | 2 | 0 | 0 | 0 | 0 h 12 min | 1 | 0 h 00 min |
| preflight | 2 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| execution | 6 | 0 | 0 | 0 | 0 h 10 min | 4 | 0 h 00 min |
| review | 1 | 1 | 0 | 0 | 0 h 15 min | 1 | 0 h 05 min |
| pr | 1 | 0 | 0 | 0 | 0 h 03 min (default) | 0 | 0 h 00 min |
| ci | 0 | 0 | 1 | 0 | 0 h 17 min (default) | 0 | 0 h 17 min |
| merge | 0 | 0 | 1 | 0 | 0 h 05 min (default) | 0 | 0 h 05 min |
| **Total** | **14** | **1** | **2** | **0** | | **9** | **0 h 27 min** |

pr: no measured duration; default 3 min
ci: no measured duration; default 17 min
merge: no measured duration; default 5 min
**Unmapped and composite stage time:** 0 h 45 min (composite remediation 0 h 45 min, unmapped stages 0 h 00 min, approximate 0 h 00 min); it enters no median.
**Weekly quota (active account):** 42.5% used, +42.5 points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone.
```

## Real runs

```text
### Real run: item mode -Issue 1118 -Mode TLDR
**TL;DR:** Item #1118 is at 30 of 37 steps (81.1%). None of the 1 features is done yet. #1118 is running (30 of 37 steps).
**Elapsed:** 8 h 07 min, with about 0.8 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 71%.
**Now:** #1118 execution (1 h 20 min of median 0 h 03 min, over median). 4 of 9 types use defaults.
**Estimated time remaining:** 0 h 45 min by type (sum); 0 h 45 min wave-parallel.
ITEM_EXIT=0
### Real run: epic mode -EpicFolder documentation-estate-tooling -Mode TLDR
**TL;DR:** Epic #1019 is at 510 of 610 steps (83.6%). None of the 11 features is done yet. #1020 (48 of 52), #1021 (48 of 52), #1022 (51 of 55), #1023 (47 of 51), #1033 (46 of 50), #1024 (45 of 49), #1031 (58 of 65), #1034 (48 of 53), #1036 (59 of 63), #1037 (57 of 61) are running.
**Elapsed:** 8 h 07 min, with about 12.6 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 71%.
**Now:** no step is in progress. 10 of 10 types use defaults.
**Estimated time remaining:** 12 h 34 min by type (sum); 9 h 14 min wave-parallel.
EPIC_EXIT=0
```

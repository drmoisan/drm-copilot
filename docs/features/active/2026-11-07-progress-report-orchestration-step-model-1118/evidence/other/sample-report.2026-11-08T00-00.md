# Sample Report (remediation cycle 1, issue #1118)

Timestamp: 2026-11-08T00-00
Command: sh SCRATCH/issue-1118-r-sample.sh (pwsh -NoProfile -File SCRATCH/issue-1118-r-sample.ps1 -Root <item worktree>: dot-sources .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1, redefines every I/O seam over in-memory fixtures, prints TL;DR and Full output, and ends with VERDICT(checks); then the two real runs with -StatePath under SCRATCH and -StartUtc 2026-11-07T15:00:00Z, the epic run after git rev-parse --verify --quiet origin/epic/documentation-estate-tooling-integration exited 0; then git status --porcelain)
EXIT_CODE: 0
Output Summary:
- Fixture checks, each True: epic TL;DR has four lines; item TL;DR has four lines; the one-feature epic output contains `The only feature is not done yet.` and `1 blocked step excluded`; the item output contains no `the epic started`, no `features is done`, and no `(wave `. VERDICT=True.
- Real item run (-Issue 1118 -Mode TLDR): exit 0, four lines, item wording (`#1118 is not done yet.`). Its Now line reads `#1118 execution (0 h 00 min of median 0 h 03 min)`: the running step is the cycle 1 execution step named by `next_step` (`remediation.cycle_1.execute`) and carries no recorded start, which is the non-blocking item already listed in the remediation inputs.
- Real epic run (-EpicFolder documentation-estate-tooling -Mode TLDR): ref resolved, exit 0, four lines.
- `git status --porcelain` after the runs: empty (no file written by the runs; state went to SCRATCH).

## Fixture output

Fixtures: a one-feature epic whose only feature (#12) is blocked (`policy_hold`) with every step done except merge, so one step is blocked; and item #1118 with the closed live stages (`S2_research`, `S3_spec`, `S4_atomic_planning`, `S4_preflight`, `atomic_execution`) and an open `feature_review` stage since 11:50. Now is 2026-01-05T12:00Z.

```text
### Fixture: one-feature epic, TLDR
**TL;DR:** Epic #42 is at 11 of 13 steps (84.6%). The only feature is not done yet. #12 is blocked (policy_hold).
**Elapsed:** 3 h 00 min, with about 0.8 hours left on the per-type estimate (1 blocked step excluded). **Weekly** quota is at 42.5%.
**Now:** no step is in progress. 2 of 10 types use defaults.
**Estimated time remaining:** 0 h 45 min by type (sum); 0 h 45 min wave-parallel.

### Fixture: one-feature epic, Full (after the four TL;DR lines)

## Epic #42 example-epic: status at 12:00 UTC, Jan 5

**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 11 of 13 steps complete, **84.6%**.

| State | Features |
|---|---|
| Completed | None yet |
| Blocked | #12 (policy_hold) |

| Wave | Children | Steps | Done |
|---|---|---|---|
| 1 | 1 | 12 | 11 |
| Epic | 0 | 1 | 0 |
| **Total** | **1** | **13** | **11** |

| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |
|---|---|---|---|---|---|---|---|
| research | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| spec | 1 | 0 | 0 | 0 | 0 h 05 min | 1 | 0 h 00 min |
| plan | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| preflight | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| execution | 4 | 0 | 0 | 0 | 0 h 15 min | 4 | 0 h 00 min |
| review | 1 | 0 | 0 | 0 | 0 h 15 min | 1 | 0 h 00 min |
| pr | 1 | 0 | 0 | 0 | 0 h 05 min | 1 | 0 h 00 min |
| ci | 1 | 0 | 0 | 0 | 0 h 20 min | 1 | 0 h 00 min |
| merge | 0 | 0 | 0 | 1 | 0 h 05 min (default) | 0 | 0 h 00 min |
| integration-pr | 0 | 0 | 1 | 0 | 0 h 45 min (default) | 0 | 0 h 45 min |
| **Total** | **11** | **0** | **1** | **1** | | **11** | **0 h 45 min** |

merge: no measured duration; default 5 min
integration-pr: no measured duration; default 45 min
**Blocked:** 1 step excluded from the estimate, about 0 h 05 min of work.
**Unmapped and composite stage time:** none.
**Weekly quota (active account):** 42.5% used, +42.5 points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone.

### Fixture: item mode, TLDR
**TL;DR:** Item #1118 is at 9 of 12 steps (75%). #1118 is not done yet. #1118 is running (9 of 12 steps).
**Elapsed:** 3 h 00 min, with about 0.4 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.
**Now:** #1118 review (0 h 10 min of median 0 h 14 min). 4 of 9 types use defaults.
**Estimated time remaining:** 0 h 26 min by type (sum); 0 h 26 min wave-parallel.

### Fixture: item mode, Full (after the four TL;DR lines)

## Item #1118: status at 12:00 UTC, Jan 5

**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 9 of 12 steps complete, **75%**.

| State | Item |
|---|---|
| Completed | None yet |
| Running | #1118: 9 of 12 steps (75%). PR #8 OPEN. |
| Blocked | None |

| Wave | Children | Steps | Done |
|---|---|---|---|
| 1 | 1 | 12 | 9 |
| **Total** | **1** | **12** | **9** |

| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |
|---|---|---|---|---|---|---|---|
| research | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| spec | 1 | 0 | 0 | 0 | 0 h 05 min | 1 | 0 h 00 min |
| plan | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| preflight | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| execution | 4 | 0 | 0 | 0 | 0 h 15 min | 4 | 0 h 00 min |
| review | 0 | 1 | 0 | 0 | 0 h 14 min (default) | 0 | 0 h 04 min |
| pr | 1 | 0 | 0 | 0 | 0 h 03 min (default) | 0 | 0 h 00 min |
| ci | 0 | 0 | 1 | 0 | 0 h 17 min (default) | 0 | 0 h 17 min |
| merge | 0 | 0 | 1 | 0 | 0 h 05 min (default) | 0 | 0 h 05 min |
| **Total** | **9** | **1** | **2** | **0** | | **8** | **0 h 26 min** |

review: no measured duration; default 14 min
pr: no measured duration; default 3 min
ci: no measured duration; default 17 min
merge: no measured duration; default 5 min
**Unmapped and composite stage time:** none.
**Weekly quota (active account):** 42.5% used, +42.5 points since the measurement started. This pool also covers the other runs in this session, so it is not this item's cost alone.
```

## Real runs

```text
### Real run: item mode -Issue 1118 -Mode TLDR
**TL;DR:** Item #1118 is at 45 of 52 steps (86.5%). #1118 is not done yet. #1118 is running (45 of 52 steps).
**Elapsed:** 9 h 00 min, with about 0.7 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 73%.
**Now:** #1118 execution (0 h 00 min of median 0 h 03 min). 3 of 9 types use defaults.
**Estimated time remaining:** 0 h 43 min by type (sum); 0 h 43 min wave-parallel.
ITEM_EXIT=0
### Real run: epic mode -EpicFolder documentation-estate-tooling -Mode TLDR
**TL;DR:** Epic #1019 is at 561 of 610 steps (92%). None of the 11 features is done yet. #1020 (48 of 52), #1021 (48 of 52), #1022 (51 of 55), #1023 (47 of 51), #1033 (46 of 50), #1024 (45 of 49), #1031 (58 of 65), #1034 (48 of 53), #1036 (59 of 63), #1037 (57 of 61), #1038 (54 of 58) are running.
**Elapsed:** 9 h 00 min, with about 8.2 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 73%.
**Now:** no step is in progress. 10 of 10 types use defaults.
**Estimated time remaining:** 8 h 14 min by type (sum); 4 h 54 min wave-parallel.
EPIC_EXIT=0
```

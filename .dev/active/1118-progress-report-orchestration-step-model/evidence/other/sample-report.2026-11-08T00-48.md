# Sample Report (remediation cycle 2, issue #1118)

Timestamp: 2026-11-08T00-47
Command: sh SCRATCH/issue-1118-c2-sample.sh (pwsh -NoProfile -File SCRATCH/issue-1118-c2-sample.ps1 -Root <item worktree>: dot-sources .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1, redefines every I/O seam over in-memory fixtures, prints TL;DR and Full output, and ends with VERDICT(checks); then the real run -Issue 1118 -Mode TLDR with -StatePath under SCRATCH and -StartUtc 2026-11-07T15:00:00Z; then git status --porcelain)
EXIT_CODE: 0
Output Summary:
- Fixture checks, each True: open-stage TL;DR has four lines; next_step TL;DR has four lines; the open-stage Now line contains `of median` and no `start not recorded`; the next_step Now line contains `start not recorded; median`. VERDICT=True.
- Both fixtures record the spec stage as `S2_feature_documents`; the spec row shows a measured 0 h 05 min median with one sample, so the alias feeds the spec type.
- Real item run (-Issue 1118 -Mode TLDR): exit 0, four lines. Its Now line reads `#1118 execution (start not recorded; median 0 h 03 min)`: the running step is the remediation execution step named by `next_step`, which has no recorded start; cycle 1 printed `0 h 00 min of median` for the same case.
- `git status --porcelain` after the runs: empty (no file written by the runs; state went to SCRATCH).

## Fixture output

Fixtures: item #1118 with the closed live stages (`S2_research`, `S2_feature_documents`, `S4_atomic_planning`, `S4_preflight`, `atomic_execution`) and an open `feature_review` stage since 11:50; item #2000 with the same closed stages, no open stage, and `next_step` `S7_feature_review`. Now is 2026-01-05T12:00Z.

```text
### Fixture: open feature_review stage (#1118), TLDR
**TL;DR:** Item #1118 is at 8 of 12 steps (66.7%). #1118 is not done yet. #1118 is running (8 of 12 steps).
**Elapsed:** 3 h 00 min, with about 0.5 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.
**Now:** #1118 review (0 h 10 min of median 0 h 14 min). 4 of 9 types use defaults.
**Estimated time remaining:** 0 h 29 min by type (sum); 0 h 29 min wave-parallel.

### Fixture: open feature_review stage (#1118), Full (after the four TL;DR lines)

## Item #1118: status at 12:00 UTC, Jan 5

**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 8 of 12 steps complete, **66.7%**.

| State | Item |
|---|---|
| Completed | None yet |
| Running | #1118: 8 of 12 steps (67%). |
| Blocked | None |

| Wave | Children | Steps | Done |
|---|---|---|---|
| 1 | 1 | 12 | 8 |
| **Total** | **1** | **12** | **8** |

| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |
|---|---|---|---|---|---|---|---|
| research | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| spec | 1 | 0 | 0 | 0 | 0 h 05 min | 1 | 0 h 00 min |
| plan | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| preflight | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| execution | 4 | 0 | 0 | 0 | 0 h 15 min | 4 | 0 h 00 min |
| review | 0 | 1 | 0 | 0 | 0 h 14 min (default) | 0 | 0 h 04 min |
| pr | 0 | 0 | 1 | 0 | 0 h 03 min (default) | 0 | 0 h 03 min |
| ci | 0 | 0 | 1 | 0 | 0 h 17 min (default) | 0 | 0 h 17 min |
| merge | 0 | 0 | 1 | 0 | 0 h 05 min (default) | 0 | 0 h 05 min |
| **Total** | **8** | **1** | **3** | **0** | | **8** | **0 h 29 min** |

review: no measured duration; default 14 min
pr: no measured duration; default 3 min
ci: no measured duration; default 17 min
merge: no measured duration; default 5 min
**Unmapped and composite stage time:** none.
**Weekly quota (active account):** 42.5% used, +42.5 points since the measurement started. This pool also covers the other runs in this session, so it is not this item's cost alone.

### Fixture: next_step without a stage (#2000), TLDR
**TL;DR:** Item #2000 is at 8 of 12 steps (66.7%). #2000 is not done yet. #2000 is running (8 of 12 steps).
**Elapsed:** 3 h 00 min, with about 0.6 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.
**Now:** #2000 review (start not recorded; median 0 h 14 min). 4 of 9 types use defaults.
**Estimated time remaining:** 0 h 39 min by type (sum); 0 h 39 min wave-parallel.

### Fixture: next_step without a stage (#2000), Full (after the four TL;DR lines)

## Item #2000: status at 12:00 UTC, Jan 5

**Elapsed:** 3 h 00 min since 09:00 UTC. **Progress:** 8 of 12 steps complete, **66.7%**.

| State | Item |
|---|---|
| Completed | None yet |
| Running | #2000: 8 of 12 steps (67%). |
| Blocked | None |

| Wave | Children | Steps | Done |
|---|---|---|---|
| 1 | 1 | 12 | 8 |
| **Total** | **1** | **12** | **8** |

| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |
|---|---|---|---|---|---|---|---|
| research | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| spec | 1 | 0 | 0 | 0 | 0 h 05 min | 1 | 0 h 00 min |
| plan | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| preflight | 1 | 0 | 0 | 0 | 0 h 10 min | 1 | 0 h 00 min |
| execution | 4 | 0 | 0 | 0 | 0 h 15 min | 4 | 0 h 00 min |
| review | 0 | 1 | 0 | 0 | 0 h 14 min (default) | 0 | 0 h 14 min |
| pr | 0 | 0 | 1 | 0 | 0 h 03 min (default) | 0 | 0 h 03 min |
| ci | 0 | 0 | 1 | 0 | 0 h 17 min (default) | 0 | 0 h 17 min |
| merge | 0 | 0 | 1 | 0 | 0 h 05 min (default) | 0 | 0 h 05 min |
| **Total** | **8** | **1** | **3** | **0** | | **8** | **0 h 39 min** |

review: no measured duration; default 14 min
pr: no measured duration; default 3 min
ci: no measured duration; default 17 min
merge: no measured duration; default 5 min
**Unmapped and composite stage time:** none.
**Weekly quota (active account):** 42.5% used, +42.5 points since the measurement started. This pool also covers the other runs in this session, so it is not this item's cost alone.
```

## Real run

```text
**TL;DR:** Item #1118 is at 60 of 66 steps (90.9%). #1118 is not done yet. #1118 is running (60 of 66 steps).
**Elapsed:** 9 h 47 min, with about 0.7 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 75%.
**Now:** #1118 execution (start not recorded; median 0 h 03 min). 3 of 9 types use defaults.
**Estimated time remaining:** 0 h 40 min by type (sum); 0 h 40 min wave-parallel.
```

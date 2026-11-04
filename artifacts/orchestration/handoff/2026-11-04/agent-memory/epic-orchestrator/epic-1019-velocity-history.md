---
name: epic-1019-velocity-history
description: Measured velocity, SD, quota burn, milestone times and per-child tail durations for epic 1019 (documentation-estate-tooling), Nov 3-4 2026; use to calibrate estimates and the progress report
metadata:
  type: project
---

Source: 106 TL;DR readings taken every 5 to 10 minutes from the coordinator session, saved raw next to this file as `velocity-readings-epic-1019.csv` (columns: ts UTC, done, total, pct, featuresDone, elapsedH since the reset baseline, weeklyPct, avgVel, recentVel, sd). Readings before the first baseline reset (11:40 UTC Nov 3) were discarded on the owner's instruction because they included the paused period.

## Reporting method (how the numbers were produced)
- Baseline reset on resume, by owner instruction: Era 1 starts 2026-11-03T18:36Z at 33 tasks done; Era 2 starts 2026-11-04T13:55Z at 261 done (Codespace restart). Elapsed and Avg Velocity count only from the active baseline.
- Avg Velocity = (done - baselineDone) / elapsed hours since the baseline. Recent Velocity = tasks per hour over the last check-in interval. SD = sample SD of the interval velocities (needs at least 3 intervals; the last 14 samples are kept). The range is average +/- 2.05 x SD; when average - 2.05 SD is at or below 0.5 tasks/hr the upper bound is reported as "no upper bound".
- Wave-parallel estimate = (sum over open waves of the largest remaining task count of any child in the wave) / average velocity + 1.25 h per open wave for review and CI.
- 5-minute readings pair into 10-minute readings (paired from the latest sample backwards): five-minute SD 31.5 became 23.2 (mean 26.2 became 27.3, n = 6). The owner moved the cadence to 10 minutes.

## Aggregate velocity (tasks per hour, all children together)
- Era 1, 21:34 Nov 3 to 04:41 Nov 4: 44 to 261 tasks, 217 tasks in 7.1 h = 30.5 tasks/hr, with up to four children in parallel.
- Era 2, 13:56 to 17:31 Nov 4: 261 to 345, 84 tasks in 3.6 h = 23.5 tasks/hr. The first hour was planner revisions and Phase 0 baselines (3 tasks); from 14:51 on it was 81 tasks in 2.7 h = 30 tasks/hr.
- Per-child execution pace while executing: about 9 to 13 tasks/hr (C3 and C4 children alike); a child alone (wave 0, #1020) ran about 4 tasks/hr including its review and PR tail.
- Interval velocities were bursty because plan checkboxes are ticked at batch boundaries: 5-minute readings ranged 0 to 154 tasks/hr, SD 31 to 46 around a mean of about 26. Flat stretches of 20 to 50 minutes recur at phase boundaries (final QA loops, feature review, PR, CI); the longest were 03:31-04:31 UTC Nov 4 (about 60 min, children in final QA and review) and 16:41-17:25 (about 45 min, PR CI and merges).

## Hourly samples (UTC)
| Time | Done | % | Weekly quota |
|---|---|---|---|
| Nov 3 21:34 | 44 | 8.5 | 19 |
| 22:35 | 84 | 16.3 | 30 |
| 23:37 | 120 | 23.2 | 41 |
| Nov 4 00:39 | 145 | 28.0 | 50 |
| 01:41 | 171 | 33.1 | 58 |
| 02:41 | 220 | 42.6 | 64 |
| 03:41 | 252 | 48.7 | 68 |
| 04:41 | 261 | 50.5 | 69 |
| 13:56 (restart) | 261 | 50.5 | 70 |
| 14:51 | 264 | 50.7 | 74 |
| 15:51 | 280 | 53.7 | 77 |
| 16:51 | 339 | 65.1 | 80 |
| 17:31 | 345 | 66.2 | 81 |

## Estimate behavior to expect
- The wave-parallel estimate swings wildly in the first hour after a baseline reset (observed 35 to 110 hours remaining at 0.5 to 1 h elapsed) because Phase 0 setup completes few tasks; do not trust it before about 2 hours of data. It overestimated at wave 1 launch: it said about 26 to 30 h and wave 1 took about 10 active hours, 19 wall hours including the 9 h outage.
- Task totals drift with planner revisions: 516 at the start, 517, 520 and 521 after the #1034 and #1031 revisions. Recompute percent from the live total.
- Throughput is limited by the tail of each child (review, remediation cycles, PR, CI, merge), not by execution. Tail from plan complete to merge: #1021 about 1 h, #1023 about 0.8 h (review passed first time), #1024 and #1033 about 3 h each after a relaunch, #1067 about 3.5 h, #1074 about 4 h. Each remediation cycle adds 45 to 90 minutes. A docs-only last push blocked PRs #1064, #1070 and #1072 and cost one extra cycle each (fixed by the single required gate in PR #1077).

## Quota burn (weekly pool, account 3 only, no failover)
- Era 1: 19 to 69 points in 7.1 h = 7.0 points/hr, peak about 10 points/hr with four wave-1 children and fable agents running. After the fable tier was disabled (about 01:40 UTC Nov 4) it fell to 3.7 points/hr.
- Era 2: 70 to 81 points in 3.6 h = 3.0 points/hr.
- Tasks per weekly point: Era 1 4.3, Era 2 7.6. The pool also paid for the standalone items (#1026, #1047, #1066, #1067, #1074). Remaining waves 3 to 5 (about 158 tasks) should cost roughly 20 to 35 points before tails; the stop line is 93%.
- Subagent token cost per item (orchestrator only, rough): 145k to 450k; relaunches after a restart cost about 100k to 300k each because the context is re-read.

## Milestones (UTC)
- Nov 3: 21:30 #1020 merged (PR #1063); 22:31 #1026 (PR #1065); 23:35 #1047 (PR #1064).
- Nov 4: 01:31 #1021 (PR #1068); 03:09 #1023 (PR #1071); 03:12 #1066 (PR #1070); 13:55 #1022 (PR #1072); 17:01 #1067 (PR #1078); 17:03 #1033 (PR #1076); 17:11 #1024 (PR #1075); 19:41 #1074 (PR #1077, `CI Required Gate`).
- State at the last reading: 6 of 11 features merged; #1031 (48 of 57) and #1034 (35 of 45) paused then resumed; #1036, #1037, #1038 (158 tasks) not started.

**Why:** the owner asked for the history to be kept so later estimates start from measured rates, not from the first-hour numbers.
**How to apply:** use 25 to 30 tasks/hr aggregate with three or four children in parallel, 9 to 13 tasks/hr per child, plus 2.5 to 4 h of tail per child, and compare quota burn to 3 to 4 points/hr with fable disabled. Reset the baseline whenever work resumes after a pause.

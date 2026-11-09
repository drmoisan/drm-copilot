# Feature Audit: Progress Report Critical Path and Velocity (Issue #1153)

- **Branch:** `feature/progress-report-critical-path` @ `afdf04d0bbb460701984b63bd00e60949ca106b2`
- **Audit date:** 2026-11-09
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`. `artifacts/pr_context.summary.txt` (generated 2026-11-09 17:03:19 UTC) names head `afdf04d0b`.
- Merge base: `bfae0c0b7`. It equals `origin/main` after fetch. `git merge-tree` against `origin/main` reports no conflict.
- Range audited: `bfae0c0b7..afdf04d0b`, 54 files.
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`). The AC sources are therefore `spec.md` (`## Acceptance Criteria`, AC-01 to AC-58) and `user-story.md` (`## Acceptance Criteria`, US-01 to US-13).
- Baseline behavior at the merge base was the #1118 step model: a four-line TL;DR, the D7 serial-sum headline with a wave-parallel secondary figure, no velocity, SD, or range, a version-2 state file, and a `*/10` cadence.
- Method: the reviewer read the executor's mapping in `evidence/qa-gates/ac-verification.2026-11-09T16-59.md`, which lists 70 rows verified and 1 pending-CI, and checked it against the gate artifacts (Pester 21204 testcases with 0 failures, pytest 16590 passed). The reviewer then independently checked the criteria marked "reviewer" below by parsing the coverage file, running the shipped script for real, running in-memory probes, comparing files, and grepping.

## Acceptance Criteria Inventory

| Group | IDs | Source |
|---|---|---|
| Report format | AC-01 to AC-10 | `spec.md` |
| Sequential velocity and default rate | AC-11 to AC-15 | `spec.md` |
| Aggregate velocity, intervals, pauses | AC-16 to AC-20 | `spec.md` |
| Remaining time | AC-21 to AC-23 | `spec.md` |
| Critical path | AC-24 to AC-37 | `spec.md` |
| Range | AC-38 to AC-40 | `spec.md` |
| State file | AC-41 to AC-44 | `spec.md` |
| Cadence and SKILL.md | AC-45 to AC-49 | `spec.md` |
| Engineering | AC-50 to AC-58 | `spec.md` (AC-58 CI-dependent) |
| User story | US-01 to US-13 | `user-story.md` |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC-01 | PASS | Render.CriticalPath five-line case; entry and item-mode goldens. Reviewer: the real item-mode run printed the five prefixes in order, followed by the Full report. |
| AC-02 | PASS | Render.CriticalPath `31 of 60 tasks, 19 of 35 steps (54.3%)`. Reviewer run: `20 of 20 tasks, 25 of 29 steps (86.2%)`. |
| AC-03 | PASS | Render.CriticalPath AC-03 case. The cswap quota cases on `$lines[1]` are unmodified and pass. |
| AC-04 | PASS | Render.CriticalPath AC-04 cases. Reviewer run: `sequential 14.1 tasks / hr per feature (own, median of 1, SD n/a); ... (aggregate, informational)`. |
| AC-05 | PASS | Render.CriticalPath AC-05 cases. Reviewer run: `serial sum 0 h 36 min (upper bound, no parallelism)`. |
| AC-06 | PASS | Render.CriticalPath AC-06 case. Reviewer grep: `Get-EpicProgressWaveParallelSecond` is not defined in the scripts folder. The two remaining `wave-parallel` mentions are help comments, not output (CR5). |
| AC-07 | PASS | Render.CriticalPath AC-07 cases. Reviewer run: the per-feature table has the eight columns, and the critical-path section and step-type table are present. |
| AC-08 | PASS | Render.CriticalPath push-notification context covers 199 versus 200 characters and the eight-feature fixture. |
| AC-09 | PASS | Render.CriticalPath AC-09 case and the Schedule.Range item case. Reviewer run: chain `#1153` with no tail and no cap, and the headline equals the remaining time (0 h 36 min). |
| AC-10 | PASS | Render.CriticalPath AC-10 case covers NaN and both infinities in every new figure. |
| AC-11 | PASS | Velocity exec-prefix and zero-seconds cases. Reviewer read: ordinal `StartsWith("<issue>|exec|")`, and NaN when seconds are 0. |
| AC-12 | PASS | Velocity qualification-boundary case. Reviewer read: `$tasks -ge 5 -and $seconds -ge 900`. |
| AC-13 | PASS | Velocity pooled cases (6, 8, 10 gives median 8, SD 2, count 3; SD n/a for 1 qualifier, finite for 2). |
| AC-14 | PASS | Velocity source-label cases (`own`, `pooled`, `default`). |
| AC-15 | PASS | Velocity default-rate cases give 12 and 10. The parameter pins are unmodified and pass. |
| AC-16 | PASS | Velocity aggregate-average and SD cases. |
| AC-17 | PASS | Velocity interval cases cover 599/600/601 s, the 0-7-20-27-40 sequence, the trailing remainder, and pause overlap. |
| AC-18 | PASS | Velocity pause-gap cases. Reviewer read: strict `-gt 3600`. |
| AC-19 | PASS | CriticalPath reset-span cases. `keeps the durations ledger and anchors with -ResetBaseline` is unmodified and passes. |
| AC-20 | PASS | Gather `tick batches exclude pause and blocked spans` context. Reviewer read: `Get-EpicProgressExcludedSecond` merges overlapping segments. |
| AC-21 | PASS | Metrics override case (44 min). |
| AC-22 | PASS | Metrics in-progress credit boundaries. |
| AC-23 | PASS | The nine existing `Get-EpicProgressTypeEstimate` cases are unmodified at the merge base and pass. Reviewer read: the override path is entered only when the type key is present. |
| AC-24 | PASS | Schedule serial-chain case (7 h, `#A -> #B -> #C -> tail`). |
| AC-25 | PASS | Schedule diamond case. Reviewer probe: 5 h at cap 4 with `#1 -> #3 -> #4 -> tail`, and 7 h at cap 1. |
| AC-26 | PASS | Schedule cap 1/2/4 case (10, 5, 4 h). |
| AC-27 | PASS | Schedule cap-boundary cases. |
| AC-28 | PASS | Schedule running-beyond-cap case. Reviewer probe: three running at cap 2, and the pending feature starts at 7200 s with predecessor `2`. |
| AC-29 | PASS | Schedule priority and tie case. |
| AC-30 | PASS | Schedule done-feature case. |
| AC-31 | PASS | Schedule cap-resolution cases and the CriticalPath cap-source case. Reviewer probe: a JSON integer (Int64) is accepted, and a string or double falls back. |
| AC-32 | PASS | Schedule dependency-source cases and the AC-55 golden (`checkpoint+manifest`). Reviewer probe: a lifecycle-prefixed folder hint and an integer reference resolve. |
| AC-33 | PASS | Schedule graph-defect cases, which give three distinct messages and the waves fallback. |
| AC-34 | PASS | Schedule and Schedule.Range blocked cases; Render.CriticalPath `excludes 2 blocked` case. |
| AC-35 | PASS | Schedule.Range tail cases. |
| AC-36 | PASS | `returns the eleven catalog types` and `returns the built-in default for every type` are unmodified and pass. |
| AC-37 | PASS | Schedule `equals the serial sum at cap 1 and never exceeds it at any cap`. Reviewer probe: the diamond at cap 1 (7 h) is at least the cap 4 figure (5 h). |
| AC-38 | PASS | Schedule.Range SD-source cases. Reviewer run: `range n/a (fewer than 2 qualifying features and fewer than 3 intervals)`. |
| AC-39 | PASS | Schedule.Range rate 8, SD 2 case (12.1 and 3.9). |
| AC-40 | PASS | Schedule.Range no-upper-bound cases. |
| AC-41 | PASS | State.V3 writer cases. Reviewer run: the scratch state file holds `"version": 3`, `baselineDoneTasks`, and samples with `tasks` and `features`, plus `durations`, `items`, and `pauses`. |
| AC-42 | PASS | State.V3 v2-migration cases. |
| AC-43 | PASS | State.V3 round-trip, v1/legacy, and v4/blank/unparseable cases. |
| AC-44 | PASS | CriticalPath AC-44 case and the State.V3 pair-samples case. |
| AC-45 | PASS | SkillContract cron cases. Reviewer grep: `*/20 * * * *` is present and no `*/10` remains in SKILL.md. |
| AC-46 | PASS | SkillContract jitter case. Reviewer grep: "0 to 10 minutes late and the hourly job 0 to 30 minutes late" is present, and `up to 5 minutes late` has 0 matches. |
| AC-47 | PASS | SkillContract cadence-change case. |
| AC-48 | PASS | SkillContract format, calculation, state, and decisions cases. |
| AC-49 | PASS | SkillContract `stays under 500 lines` (reviewer count: 497); pytest citation test passes. |
| AC-50 | PASS | Schedule no-I/O case; entry constraint cases (11 production paths, 13 scan paths). Reviewer grep: no clock or I/O call in Velocity or Schedule. |
| AC-51 | PASS | The entry function set equals the merge-base set (10 functions). Reviewer count: the largest script is 783 lines, at or below 800. |
| AC-52 | PASS | Leak scan reports 0 failures. Reviewer grep: no `TestDrive`, temp-file API, sleep, `Get-Date`, or `function global:` in the tests. |
| AC-53 | PASS | Reviewer `cmp`: all 9 skill files are byte-identical with their bundle copies, and `core.json` has one entry for each new script. The push-down pytest contracts pass. |
| AC-54 | PASS | Reviewer: no diff since the merge base for `scripts/dev-tools/Get-EpicProgressReport.ps1` or its test. The CriticalPath forwarder case passes. |
| AC-55 | PASS | CriticalPath Full golden case with hand-derived values. |
| AC-56 | PASS | The updated and replaced tests are listed in `ac-verification`. The no-velocity test is replaced by `prints the velocity and range lines in both modes`. |
| AC-57 | PASS | Format 0 changes, analyzer 0 findings, one parallel Pester run. Reviewer parse: every new and changed script is at least 96.40% lines (new files 100%). No Python file was added. |
| AC-58 | Pending-CI | No pull request exists yet, so no CI has run on the PR head. The item's orchestrator checks this criterion off at S9 after the CI green gate. This is not a blocking finding. |
| US-01 | PASS | AC-01 to AC-05. |
| US-02 | PASS | Schedule `finishes five equal running features at cap 5 together (US-02)`. |
| US-03 | PASS | AC-12 to AC-15. The per-feature table shows the source label (reviewer run: `own`). |
| US-04 | PASS | AC-24 to AC-32 and AC-35. |
| US-05 | PASS | AC-34. |
| US-06 | PASS | AC-18 and AC-19, plus the CriticalPath US-06 cases. |
| US-07 | PASS | AC-38 to AC-40. |
| US-08 | PASS | AC-10. |
| US-09 | PASS | AC-08. |
| US-10 | PASS | AC-45 to AC-47. |
| US-11 | PASS | AC-42. Reviewer run: the written file is version 3. |
| US-12 | PASS | AC-15 and AC-54. |
| US-13 | PASS | AC-06 and AC-07, plus the `-WaveOverheadHours` no-effect case. |

## Summary

- The branch delivers every non-CI criterion in both AC sources at this head. AC-58 is pending-CI.
- No blocking finding. The code review records non-blocking items: the `Schedule.ps1` 783-line Warning and CR1 to CR5.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-09-progress-report-critical-path-velocity-1153/spec.md` and `docs/features/active/2026-11-09-progress-report-critical-path-velocity-1153/user-story.md`
- Total AC items: 71 (58 in `spec.md`, 13 in `user-story.md`)
- Checked off (delivered): 70 (57 in `spec.md`, 13 in `user-story.md`)
- Remaining (unchecked): 1
- Items remaining: "AC-58 (CI-dependent): CI on the pull request head completes with `success`, including the Linux and Windows Pester shards and the push-down contract tests." This item is pending-CI.

## Acceptance Criteria Check-off

- The executor checked off AC-01 to AC-57 and US-01 to US-13 at P6-T5. This review evaluates each of them as PASS at this head, so they stay checked. None was unchecked.
- AC-58 stays unchecked as pending-CI. Its owner is the item's orchestrator run at S9.
- The `spec.md` `## Definition of Done` and `## Seeded Test Conditions` checkboxes are not acceptance criteria and were left as found. No criterion was added, and no criterion text was changed.

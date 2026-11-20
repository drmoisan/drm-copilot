# Feature Audit: Progress Report Critical Path and Velocity (Issue #1153)

- **Branch:** `feature/progress-report-critical-path` @ `693b76d4f725549a8f2858ffe6ea42b886bafd78`
- **Audit date:** 2026-11-09
- **Reviewer:** feature-review agent
- **Review type:** re-audit after remediation cycle 1 (CR1 to CR5)

## Scope and Baseline

- Resolved base branch: `main`. `artifacts/pr_context.summary.txt` (generated 2026-11-09 17:58:46 UTC) names head `693b76d4f`.
- Merge base: `bfae0c0b7`. It equals `origin/main` after fetch, and `git merge-tree` against `origin/main` reports no conflict.
- Range audited: `bfae0c0b7..693b76d4f`, 68 files. This is the full branch, not only the remediation cycle.
- Work mode: `full-feature`, per `- Work Mode: full-feature` in `issue.md`.
- AC sources:
  - `spec.md` `## Acceptance Criteria`, AC-01 to AC-58.
  - `user-story.md` `## Acceptance Criteria`, US-01 to US-13.
- Baseline behavior at the merge base was the #1118 step model:
  - a four-line TL;DR;
  - the D7 serial-sum headline with a wave-parallel secondary figure;
  - no velocity, SD, or range;
  - a version-2 state file;
  - a `*/10` cadence.
- Method:
  - Each criterion was re-evaluated at this head against the cycle gate artifacts: Pester 21216 testcases with 0 failures, and pytest 16590 passed.
  - Criteria whose code or text the cycle touched were checked independently by the reviewer: AC-16, AC-17, AC-41, AC-48, AC-49, AC-50, AC-51, AC-53, and AC-57. The reviewer used coverage parsing, mutation probes, a real-process run, `cmp`, and line counts.
  - `git diff 588e1e575 HEAD -- spec.md user-story.md` is empty, so the cycle changed no checkbox.

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
| AC-01 | PASS | Render.CriticalPath five-line case; entry and item-mode goldens. Reviewer run: five prefixes in order. |
| AC-02 | PASS | Render.CriticalPath progress case. Reviewer run: `20 of 20 tasks, 39 of 43 steps (90.7%)`. |
| AC-03 | PASS | Render.CriticalPath AC-03 case; cswap quota cases unmodified and pass. |
| AC-04 | PASS | Render.CriticalPath AC-04 cases. Reviewer run: `sequential 14.1 tasks / hr per feature (own, median of 1, SD n/a); aggregate n/a tasks / hr average ...`. |
| AC-05 | PASS | Render.CriticalPath AC-05 cases. Reviewer run: `serial sum 0 h 35 min (upper bound, no parallelism)`. |
| AC-06 | PASS | Render.CriticalPath AC-06 case. Since CR5, the only `wave-parallel` mention is the retired-figure sentence in the Metrics help, which is not output. |
| AC-07 | PASS | Render.CriticalPath AC-07 cases. |
| AC-08 | PASS | Render.CriticalPath push-notification cases (199 versus 200 characters). |
| AC-09 | PASS | Render.CriticalPath AC-09 case and the Schedule.Range item case. Reviewer run: chain `#1153`, and the headline equals the remaining time. |
| AC-10 | PASS | Render.CriticalPath AC-10 case. Since CR2, the zero-interval average also takes this path. |
| AC-11 | PASS | Velocity exec-prefix and zero-seconds cases. |
| AC-12 | PASS | Velocity qualification-boundary case. |
| AC-13 | PASS | Velocity pooled cases. |
| AC-14 | PASS | Velocity source-label cases. |
| AC-15 | PASS | Velocity default-rate cases; parameter pins unmodified. |
| AC-16 | PASS | Velocity aggregate cases. The average-since-baseline case now carries one interval, and its asserted 5 and 3.3333 are unchanged. Since CR2, the average is `n/a` with 0 intervals (code review O1, informational). SD `n/a` at 2 intervals and finite at 3 is unchanged. |
| AC-17 | PASS | Velocity interval cases (599/600/601 s, pause overlap). Reviewer mutant: removing the CR2 guard fails 4 cases. |
| AC-18 | PASS | Velocity pause-gap cases (strict `-gt 3600`). |
| AC-19 | PASS | CriticalPath reset-span cases are unchanged and pass. The reset span ends at the new start, so CR4 pruning keeps it (at-boundary case `-ge`; reviewer mutant `-gt` fails AC-44 and two CR4 cases). |
| AC-20 | PASS | Gather tick-batch exclusion cases. |
| AC-21 | PASS | Metrics override case. |
| AC-22 | PASS | Metrics in-progress credit boundaries. |
| AC-23 | PASS | The existing `Get-EpicProgressTypeEstimate` cases are unmodified and pass. |
| AC-24 | PASS | Schedule serial-chain case. Since CR1, `Get-EpicProgressCriticalChain` is defined in CriticalPath and resolved through the hub. |
| AC-25 | PASS | Schedule diamond case. |
| AC-26 | PASS | Schedule cap 1/2/4 case. |
| AC-27 | PASS | Schedule cap-boundary cases. |
| AC-28 | PASS | Schedule running-beyond-cap case. |
| AC-29 | PASS | Schedule priority and tie case. |
| AC-30 | PASS | Schedule done-feature case. |
| AC-31 | PASS | Schedule cap-resolution cases and the CriticalPath cap-source case. |
| AC-32 | PASS | Schedule dependency-source cases. CR3 documents the resolver differences in the help only; the cases are unchanged and pass. |
| AC-33 | PASS | Schedule graph-defect cases. |
| AC-34 | PASS | Schedule and Schedule.Range blocked cases. |
| AC-35 | PASS | Schedule.Range tail cases (functions now in CriticalPath). |
| AC-36 | PASS | Catalog-type cases unmodified and pass. |
| AC-37 | PASS | Schedule cap-1 equals serial sum case. |
| AC-38 | PASS | Schedule.Range SD-source cases. Reviewer run: `range n/a (fewer than 2 qualifying features and fewer than 3 intervals)`. |
| AC-39 | PASS | Schedule.Range rate 8, SD 2 case. |
| AC-40 | PASS | Schedule.Range no-upper-bound cases. |
| AC-41 | PASS | State.V3 writer cases plus the CR4 writer boundary case. Reviewer run: the scratch state holds `"version": 3`, `baselineDoneTasks`, and `"pauses": []`. |
| AC-42 | PASS | State.V3 v2-migration cases. |
| AC-43 | PASS | State.V3 round-trip, v1/legacy, and v4/blank/unparseable cases. |
| AC-44 | PASS | CriticalPath AC-44 case. Its stored span ends exactly at the start and is kept. |
| AC-45 | PASS | SkillContract cron cases. |
| AC-46 | PASS | SkillContract jitter case. |
| AC-47 | PASS | SkillContract cadence-change case. |
| AC-48 | PASS | SkillContract format, calculation, state, and decisions cases, with the cycle's n/a-average and pruning fragments added. |
| AC-49 | PASS | SkillContract `stays under 500 lines` (reviewer count: 499); pytest citation test passes. |
| AC-50 | PASS | The purity test covers Velocity, Schedule, and CriticalPath. Entry constraint pins: 12 production paths, 14 scan paths. All 13 skill files are dot-sourced with exact case. |
| AC-51 | PASS | The entry function set equals the merge-base set. Reviewer count: the largest script is 530 lines (entry). |
| AC-52 | PASS | Leak scan 0 failures. No `TestDrive`, temp file, sleep, or `function global:` in the tests. |
| AC-53 | PASS | Reviewer `cmp`: all 13 skill-folder files are byte-identical with their bundle copies. `core.json` has one entry per script, including CriticalPath. The push-down pytest contracts pass. |
| AC-54 | PASS | No diff since the merge base for `scripts/dev-tools/Get-EpicProgressReport.ps1` or its test. |
| AC-55 | PASS | CriticalPath Full golden case; its velocity value moved to `n/a` for 0 intervals (CR2). |
| AC-56 | PASS | Updated and replaced tests are listed in `ac-verification.2026-11-09T16-59.md` and in the remediation plan dispositions. |
| AC-57 | PASS | Format 0 changes, analyzer 0 findings, one parallel Pester run. Reviewer parse: every script is at least 96.40% lines, new files 100%, and 661 of 661 added executable lines are covered. No Python file was added. |
| AC-58 | Pending-CI | No pull request exists yet. The item's orchestrator checks this criterion off at S9 after the CI green gate. It is not a blocking finding. |
| US-01 | PASS | AC-01 to AC-05. |
| US-02 | PASS | Schedule `finishes five equal running features at cap 5 together (US-02)`. |
| US-03 | PASS | AC-12 to AC-15. |
| US-04 | PASS | AC-24 to AC-32 and AC-35. |
| US-05 | PASS | AC-34. |
| US-06 | PASS | AC-18 and AC-19, plus the CriticalPath US-06 cases (unchanged under CR4). |
| US-07 | PASS | AC-38 to AC-40. |
| US-08 | PASS | AC-10. |
| US-09 | PASS | AC-08. |
| US-10 | PASS | AC-45 to AC-47. |
| US-11 | PASS | AC-42. Reviewer run: the written file is version 3. |
| US-12 | PASS | AC-15 and AC-54. |
| US-13 | PASS | AC-06 and AC-07. |

## Summary

- The branch delivers every non-CI criterion in both AC sources at this head. AC-58 is pending-CI.
- Remediation cycle 1 resolved CR1 to CR5 without unchecking or changing any criterion.
- No blocking finding. The code review records two informational observations (O1, O2) that need no action.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-09-progress-report-critical-path-velocity-1153/spec.md` and `docs/features/active/2026-11-09-progress-report-critical-path-velocity-1153/user-story.md`
- Total AC items: 71 (58 in `spec.md`, 13 in `user-story.md`)
- Checked off (delivered): 70 (57 in `spec.md`, 13 in `user-story.md`)
- Remaining (unchecked): 1
- Items remaining: "AC-58 (CI-dependent): CI on the pull request head completes with `success`, including the Linux and Windows Pester shards and the push-down contract tests." This item is pending-CI.

## Acceptance Criteria Check-off

- AC-01 to AC-57 and US-01 to US-13 were checked off before this cycle. This re-audit evaluates each of them as PASS at this head, so they stay checked. None was unchecked.
- AC-58 stays unchecked as pending-CI. Its owner is the item's orchestrator run at S9.
- The `spec.md` `## Definition of Done` and `## Seeded Test Conditions` checkboxes are not acceptance criteria and were left as found.
- No criterion was added, and no criterion text was changed.

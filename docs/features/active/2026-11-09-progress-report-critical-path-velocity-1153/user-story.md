# `progress-report-critical-path-velocity` — User Story

- Issue: #1153
- Owner: drmoisan
- Status: Approved for planning
- Last Updated: 2026-11-09
- Spec: `docs/features/active/2026-11-09-progress-report-critical-path-velocity-1153/spec.md` (decisions E1 to E15)

## Story Statement

- As an epic coordinator, I want the progress report's headline to be the finish time of a dependency-aware critical path under the epic's concurrency cap, so that the estimate reflects features running in parallel instead of the serial sum.
- As an epic coordinator, I want task progress, each feature's own (sequential) velocity, and the aggregate velocity with its SD, so that I can see the pace of the work and how much it varies.
- As an epic coordinator, I want a range around the headline and the serial sum labelled as an upper bound, so that I can judge how far the estimate can move.
- As an epic coordinator, I want paused and blocked time excluded from velocity, so that an overnight pause or a blocked feature does not lower the measured rate.
- As an epic coordinator reading notifications on a phone, I want a short TL;DR every 20 minutes and a push notification under 200 characters, so that I receive fewer, still informative updates.

## Problem / Why

Observed in a live epic on 2026-11-09:

- The v2 rewrite of the `epic-progress-report` skill (typed steps) removed task-based progress and velocity. The report has no tasks per hour, no recent velocity, no SD, and no range.
- The headline "about N hours left" is the serial sum over step types (remaining steps times their median, summed), decision D7. It ignores parallelism. With 5 features running at once it read 20 to 22 h. The wave-parallel figure on the same line read 12.5 h, and measured throughput implied about 6 to 8 h.
- The wave-parallel figure takes the slowest feature in each wave. It ignores the actual dependency edges, the concurrency cap, and each feature's own pace.
- Aggregate (parallel) velocity is not a stable measure. It scales with the number of running features and drops to zero during contention or stalls. Per-step medians measured during contention, such as 100-minute test runs, inflate every estimate.

## Personas & Scenarios

- Persona: Epic coordinator (repository owner).
  - Runs epics of several features in parallel through the orchestration skills, with `max_parallel_features` set in the epic checkpoint.
  - Cares about a finish estimate that matches observed throughput, and about whether the estimate is stable.
  - Constraints: reads the TL;DR in the main session and the push notification on a phone; pauses the machine overnight and resumes with `-ResetBaseline`.
  - Frustration: the D7 serial sum read 20 to 22 h while throughput implied 6 to 8 h; the wave-parallel figure ignored dependency edges and the cap.
  - Goal: decide when to check back, whether to raise the cap, and which feature gates the finish.
- Scenario 1: Mid-epic status check.
  - Trigger: the `*/20` TL;DR job runs.
  - Steps: the report reads the epic checkpoint (`depends_on`, `max_parallel_features`), plans, and item checkpoints; computes each feature's rate, its remaining time, and a list schedule under the cap; and prints five lines.
  - Outcome: the coordinator sees "critical path about 2 h 05 min left (#12345 -> #12346 -> tail, cap 4)", the sequential and aggregate velocity, a range, and the serial sum labelled as the upper bound.
- Scenario 2: Resume after an overnight pause.
  - Trigger: the coordinator runs the script with `-ResetBaseline` the next morning.
  - Steps: the script records a pause span from the last stored sample to the resume instant and keeps the duration ledger and tick anchors.
  - Outcome: the first task batch after the resume does not include the overnight hours, so the sequential rate is unchanged by the pause.
- Scenario 3: A feature becomes blocked.
  - Trigger: a child checkpoint records `blocked_reason` other than `none` or `awaiting_ci`.
  - Steps: the report excludes that feature and every feature that depends on it from the schedule and lists them separately.
  - Outcome: the headline states that it excludes them, and the coordinator knows the figure is conditional on unblocking.
- Scenario 4: First run after the upgrade.
  - Trigger: the existing version-2 state file is read.
  - Steps: the script migrates it to version 3.
  - Outcome: the baseline start and the weekly baseline are kept; aggregate task velocity begins accumulating from that run.

## Acceptance Criteria

- [x] US-01: The TL;DR prints exactly five lines in the order `**TL;DR:**`, `**Elapsed:**`, `**Now:**`, `**Velocity:**`, `**Estimated time remaining:**`, showing task progress and step progress, the critical-path headline with its named chain and cap, sequential and aggregate velocity, the range, and the serial sum followed by `(upper bound, no parallelism)`.
- [x] US-02: For a fixture epic with five independent running features of equal remaining time at cap 5, the headline equals one feature's remaining time plus the tail and is less than the serial sum, which equals the five remaining times plus the tail.
- [x] US-03: Each feature's remaining time uses its own sequential velocity when it has at least 5 tasks and at least 15 active minutes, else the pooled median, else the default derived from the execution default (12 tasks per hour built in), and the Full report's per-feature table labels the source as `own`, `pooled`, or `default`.
- [x] US-04: The critical path respects `depends_on` edges from the epic checkpoint or `epic.md`, falls back to waves only when no `depends_on` exists, adds the predicted epic tail (one main sync and the integration-to-main PR through its merge) after the last feature finishes, and never starts a feature while `max_parallel_features` or more features are running; the serial-chain, diamond, and cap-1-versus-N fixtures produce the finish times stated in spec AC-24 to AC-27.
- [x] US-05: A blocked feature and its dependents are excluded from the headline, listed separately, and named in the `**Elapsed:**` line as excluded.
- [x] US-06: A gap longer than 3600 seconds between check-in samples, and the span covered by a `-ResetBaseline` resume, are excluded from sequential velocity, while a gap of exactly 3600 seconds is not treated as a pause.
- [x] US-07: The range uses velocity +/- 2.05 SD, prints `no upper bound` when the slow rate is at or below 0.5 tasks per hour, and prints `n/a` with a reason when neither 2 qualifying features nor 3 aggregate intervals exist.
- [x] US-08: Every figure that would be NaN or infinite prints `n/a`, and no output line contains `NaN` or `Infinity`.
- [x] US-09: The push notification text derived from the first TL;DR line is under 200 characters for a fixture with eight running features and five-digit task counts.
- [x] US-10: SKILL.md schedules the TL;DR job at cron `*/20 * * * *` and the hourly full report at cron `7 * * * *`, states that the 20-minute job runs 0 to 10 minutes late, and describes the change from 10 to 20 minutes with one `-PairSamples` run.
- [x] US-11: After the upgrade, a version-2 state file is migrated to version 3 with its baseline start (`startUnixSeconds`) and weekly baseline (`baselineWeeklyPct`) unchanged, and the next write is version 3.
- [x] US-12: The forwarder `scripts/dev-tools/Get-EpicProgressReport.ps1` runs unchanged and prints the new TL;DR and Full output, and no script parameter is added, removed, or renamed.
- [x] US-13: The Full report no longer prints a wave-parallel figure and instead prints a per-feature table and a critical-path section, while keeping the step-type table.

## Non-Goals

- Reading committed `stage-timing.*.json` evidence files of removed worktrees (excluded by D3; research section 5).
- Detecting "waiting for the machine" from any signal other than the E11 pause rules; machine contention that slows tasks without a gap is not corrected (research R2).
- Adding new epic step types for the integration PR, its CI, and its merge (E8).
- Changing `Select-EpicProgressSample`'s 90-second sample rule, the D1 blockage rules, or the D3 git-call set beyond one `git show` of `epic.md`.
- Adding a script parameter for the default rate, the pause threshold, or the interval minimum.
- Importing `.claude/lib/epic-wave/EpicWave.psm1` or any module outside the skill folder.
- Adding Python code.

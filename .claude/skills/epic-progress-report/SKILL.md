---
name: epic-progress-report
description: 'Post recurring epic progress reports from the coordinator session: a five-line TL;DR every 20 minutes and an hourly full status update with a push notification. Progress is measured in plan tasks and typed steps (research, spec, plan, preflight, execution, review, PR, CI, merge, main sync, integration PR); the time remaining is a dependency-aware critical path, list-scheduled under the parallel cap at each feature sequential task velocity, with sequential and aggregate velocity, a range, and the serial sum as the upper bound. Use when an epic or a standalone item is running and the owner wants scheduled progress and time-remaining reports, or when the reports must be started, reset after a pause, moved to a new cadence, stopped, or recreated after a restart.'
argument-hint: "[epic-folder]"
allowed-tools:
  - Read
  - Glob
  - "Bash(pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 *)"
  - "Bash(cswap list*)"
  - CronCreate
  - CronList
  - CronDelete
  - PushNotification
---

# Epic Progress Report

This skill runs the epic progress report script and schedules two recurring reports in the coordinator's main
session: a five-line TL;DR and an hourly full status update. The script is
`.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1`. It reads the epic kickoff, the
feature plans, each live item checkpoint, the epic checkpoint, the `epic.md` dependency lists, the
routing-config cap, the pull-request state, and the weekly quota, prints the report, and keeps its samples,
its duration ledger, its pause spans, and its baseline in a state file. It also reports a standalone item (`-Issue`).

## When to Use This Skill

- An epic or a standalone item is running and the owner wants scheduled progress reports.
- The reports must be started, or recreated after the session restarted.
- Work resumed after a pause or an outage and the baseline must be reset.
- The TL;DR cadence changes (for example from 10 to 20 minutes).
- The work is finished and the reports must be stopped.

## Prerequisites

- PowerShell 7 and `git`. `gh` and `cswap` are optional: without `gh` the pull-request state is empty, and
  without `cswap` (or without parseable output) the weekly quota prints `n/a`.
- Epic mode: the epic kickoff at `docs/features/epics/<epic-folder>/epic-kickoff.md` on
  `origin/epic/<epic-folder>-integration`, with a feature-summary table (header first cell `issue_num` or
  `Issue`) and an `Epic issue: #<n>` line. Pass `-EpicIssue` when the line is missing.
- The epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json` under the repository root
  (optional; without it every feature is classified from its plan and PR).
- Optional dependency and cap inputs: `docs/features/epics/<epic-folder>/epic.md` on the integration branch
  and `config/orchestration-routing.json` under the repository root.
- Item mode: a live worktree whose `artifacts/orchestration/orchestrator-state.json` carries the item's
  `issue-num` and its `plan-path`.
- Run from the repository root in the coordinator's main session. An agent-isolated worktree refuses command
  text containing `pwsh`, and the scheduled jobs and notifications belong to the main session.

## Inputs

| Parameter | Default | Meaning |
|---|---|---|
| `-EpicFolder` | (mandatory, Epic set) | Epic folder name under `docs/features/epics/`; also the epic name in the status heading. |
| `-Issue` | (mandatory, Item set) | Standalone item issue number. The worktree whose checkpoint `issue-num` equals it is reported, with no kickoff, epic checkpoint, or epic-level step. Cannot be combined with `-EpicFolder`. |
| `-StartUtc` | stored start | Start of the measurement. Resolution: the passed value, else now with `-ResetBaseline`, else the stored start. With none of these the script stops before any git call with an error naming `-StartUtc` and `-ResetBaseline`. |
| `-BaselineDone` | stored value, else 0 | Steps already complete at the start. With `-ResetBaseline`, or after a migrated state, and no passed value: the current done count. |
| `-BaselineWeeklyPct` | stored value, else 0 | Weekly quota percentage at the start. `-ResetBaseline` does not change it. |
| `-EpicIssue` | the kickoff's `Epic issue: #<n>` line | Epic issue number printed in the report. |
| `-IntegrationBranch` | `origin/epic/<epic-folder>-integration` | Branch that holds the kickoff and the plans; in item mode only a fallback for plan texts, blank by default. |
| `-KickoffPath` | `docs/features/epics/<epic-folder>/epic-kickoff.md` | Kickoff path on the integration branch. |
| `-RepositoryRoot` | current location | Repository root in which git runs. |
| `-CheckpointPath` | `artifacts/orchestration/epic-orchestrator-state.json` | Epic checkpoint under the repository root. |
| `-StatePath` | `.claude/state/epic-progress-<epic-folder>.json`, or `.claude/state/progress-item-<n>.json` in item mode | State file under the repository root; the directory is created when missing. |
| `-WaveOverheadHours` | 1.25 | Accepted for compatibility; it affects no figure (decisions D13 and E10). |
| `-SampleCap` | 14 | Maximum number of check-in samples kept; the duration ledger is not limited by it. |
| `-Mode` | `Full` | `TLDR` prints the five TL;DR lines; `Full` prints them followed by the full report. |
| `-ResetBaseline` | off | Discards the check-in samples and blocked spans and restarts the baseline now (see the reset section). |
| `-PairSamples` | off | One-shot: pairs the stored check-in samples for a cadence change (see the cadence section). Cannot be combined with `-ResetBaseline`. |
| `-StepDefaultMinutes` | built-in defaults | Hashtable of per-type default durations in minutes, for example `@{ ci = 25 }`. An unknown type or a value that is not a number above 0 stops the script before any I/O. |

A passed `-StartUtc`, `-BaselineDone`, or `-BaselineWeeklyPct` overrides the stored value and
is persisted with the next state write.

## Step Model

Every unit of work is a step with a type. Item types: `research`, `spec`, `plan`, `preflight`,
`execution` (one step per `[P#-T#]` task), `review`, `pr`, `ci`, and `merge`. Epic types:
`main-sync` (one per sync row of the epic checkpoint) and `integration-pr` (one per epic).

Done rules (primary `stage_timing` source, then the checkpoint fallback):

- research: a closed `research` stage; `completed_steps` prefix `S2_research` or `S3b_research`.
- spec: a closed `spec` stage; `S3_promotion` with `spec.md` present.
- plan: a closed `planning` or `plan` stage; `S4_atomic_planning`.
- preflight: a closed `preflight` stage; a checked task or `step5_status` past `pending`.
- execution: the task checkbox is checked.
- review: a closed `review` stage; `S7_feature_review` or a review outcome.
- pr: a closed `pr` stage; `S8_create_pr`, `pr_gate.pr_number`, or an open pull request.
- ci: a closed `ci` stage; `step9_status` `passed`.
- merge: epic row `merge_status` `merged` or `worktree_removed`, or a merged pull request.
- main-sync: the sync row `merge_status` is `merged` or `worktree_removed`.
- integration-pr: `epic_merge_pr.merge_commit_sha` is present.

Derivation per item:

- The initial run has one step of each item type plus one execution step per plan task. A type with several
  recorded attempts counts one step per attempt (decision D4).
- Each opened `remediation_loop.cycles[]` entry adds `plan` and `preflight` (unless its `remediation_path` is
  `light`; a missing key is full), one execution step per task in the file named by its `plan_path`, one
  `review` step, and one `ci` step when the cycle opened after a PR existed. Cycles not yet opened are not
  predicted, so the total grows and the percentage can fall when a cycle opens.
- The in-progress step is the open `stage_timing` entry; without one, the step named by `next_step` (an
  `S2_research` or `S3b_research` value names the research step).
- A child without a checkpoint whose plan is already written counts research, spec, and plan as done (decision
  D6); a merged child has every step done.
- Live stage names map through aliases, compared case-insensitively after trimming: `feature_review` and
  `S7_feature_review` to `review`; `atomic_execution` and `S5_atomic_execution` to `execution`; `S2_research`
  to `research`; `S3_spec` and `S2_feature_documents` to `spec`; `S4_atomic_planning` to `plan`;
  `S4_preflight` to `preflight`; `S8_create_pr` to `pr`; and `S9_ci_gate` and `S9_ci_green` to `ci`.
- Stage names `planning` and `plan` map to `plan`; names starting with `remediation` are composite remediation
  time (decision D2); any other unknown name, for example `promotion`, is unmapped time. Neither enters a median.

Default durations, used only for a type with no retained sample and labelled `default`:

| Type | Default | Basis |
|---|---|---|
| research | 13 min | #1096 and #1105 stage timing |
| spec | 6 min | #1096 and #1105 stage timing |
| plan | 11 min | #1096 and #1105 stage timing |
| preflight | 10 min | #1096 stage timing |
| execution | 5 min per task | #1096 and #1105 stage timing; measured task rates |
| review | 14 min | #1096 and #1105 stage timing |
| pr | 3 min | #1096 and #1105 stage timing |
| ci | 17 min | #1096 and #1105 stage timing, excluding a run where no CI executed |
| merge | 5 min | stated assumption |
| main-sync | 60 min | stated assumption |
| integration-pr | 45 min | stated assumption |

Blockage by recorded state (decision D1): an item is blocked when `blocked_reason` is set to a value other than
`none` or `awaiting_ci`, a `human_interaction.requirements[]` entry has `response: "halt"`, `step6_status` is
`blocked_remediation_loop_limit`, `step9_status` is `blocked_ci_loop_limit`, or the epic row `merge_status` is
`blocked_conflict_loop_limit`. Its steps that are not done are reported as blocked and excluded from the
estimate. A run with no new checked task is never treated as a blockage.

## Report Formats

Values in angle brackets are placeholders; the examples use the fictional epic folder `example-epic` and issue `42`.

TL;DR (both modes print these five lines first; decision E1):

```text
**TL;DR:** Epic #<issue> is at <tdone> of <ttotal> tasks, <sdone> of <stotal> steps (<pct>%). <done-sentence> <running-sentence>
**Elapsed:** <H h MM min>; critical path about <H h MM min> left (<chain>, cap <k>[; excludes <b> blocked: #<x>, #<y>]). **Weekly** quota is at <weekly>.
**Now:** #<i> <type> (<elapsed> of median <m>)[, ...]. <k> of <n> types use defaults.
**Velocity:** sequential <v> tasks / hr per feature (<source>, median of <n>, SD <sd>); aggregate <avg> tasks / hr average, <recent> recent, SD <isd> over <m> intervals (aggregate, informational).
**Estimated time remaining:** range <fast> to <slow> (velocity +/- 2.05 SD, <sd-source>); serial sum <H h MM min> (upper bound, no parallelism).
```

Variants:

- In item mode the subject reads `Item #<issue>`, the chain is `#<issue>` with no tail and no cap text, and the
  headline equals the item's remaining time.
- `<chain>` is `#<a> -> #<b> -> tail`, walked back from the latest-finishing feature. One excluded feature reads
  `excludes 1 blocked: #<x>`; with none the exclusion text is absent.
- `<source>` is `own` for a one-feature report, else `pooled` when a feature qualifies, else `default`.
  `<sd-source>` is `across-feature SD` or `aggregate interval SD`; the slow end can read `no upper bound` (E9),
  and without an SD the range reads `range n/a (<reason>)`.
- done-sentence: `None of the <N> features is done yet.` or `<K> of <N> features are done.`; an epic with one
  feature prints `The only feature is not done yet.` or `The only feature is done.`; item mode prints
  `#<i> is not done yet.` or `#<i> is done.`
- running-sentence: `No feature is running.`, `#<i> is running (<d> of <t> steps).`, or
  `#<a> (<d> of <t>), #<b> (<d> of <t>) are running.`; each blocked item adds `#<i> is blocked (<reason>).`
  Item mode omits `No feature is running.`
- Now line: `no step is in progress` when nothing runs; a step whose elapsed time exceeds its median reads
  `(<elapsed> of median <m>, over median)`; a step without a recorded start reads `(start not recorded; median <m>)`.
- `<pct>` and the rates are rounded to one decimal with invariant culture; an integral value prints without a
  decimal. `<weekly>` is `<value>%` or `n/a`. Any non-finite value prints `n/a`; no report prints `NaN` or `Infinity`.
- Push text: the first line with every `**` removed, without the running sentence at 200 characters or more.

Example (fictional):

```text
**TL;DR:** Epic #42 is at 31 of 60 tasks, 19 of 35 steps (54.3%). 1 of 3 features are done. #12345 is running (6 of 13 steps).
**Elapsed:** 3 h 10 min; critical path about 2 h 05 min left (#12345 -> #12346 -> tail, cap 4). **Weekly** quota is at 41%.
**Now:** no step is in progress. 10 of 10 types use defaults.
**Velocity:** sequential 8 tasks / hr per feature (pooled, median of 3, SD 2); aggregate 9.5 tasks / hr average, 7.2 recent, SD 1.8 over 6 intervals (aggregate, informational).
**Estimated time remaining:** range 1 h 40 min to 3 h 30 min (velocity +/- 2.05 SD, across-feature SD); serial sum 4 h 15 min (upper bound, no parallelism).
```

Full mode prints the TL;DR lines, then these lines:

```text

## Epic #<issue> <epic-folder>: status at <HH:mm> UTC, <MMM d>

**Elapsed:** <H h MM min> since <HH:mm> UTC. **Progress:** <done> of <total> steps complete, **<pct>%**.

| State | Features |
|---|---|
| Completed | <completed> |
| Running | #<i> (wave <w>, <band>): <d> of <t> steps (<share>%).<phase><pr> |
| Blocked | <blocked> |
| Pending, wave <w> | #<i> (<t>), #<j> (<t>) |

| Wave | Children | Steps | Done |
|---|---|---|---|
| <w> | <count> | <steps> | <done> |
| Epic | 0 | <epic steps> | <done> |
| **Total** | **<features>** | **<total>** | **<done>** |

| Feature | State | Tasks | Rate | Source | Remaining | Start | Finish |
|---|---|---|---|---|---|---|---|
| #<i> | <state> | <d> of <t> | <v> tasks / hr | <source> | <H h MM min> | <start> | <finish> |

**Critical path:** <chain>. Headline <H h MM min>: features finish in <H h MM min>, then the tail of <H h MM min> (<type> <H h MM min>, ...)[, main-sync predicted].
**Schedule inputs:** dependency source <dependency-source>; cap <k> (<cap-source>).
**Dependency graph:** <message>.
**Cross-epic:** #<i> depends on <epic>#<n> (<state>, <label>)[, ...].
**Serial sum:** <H h MM min> (upper bound, no parallelism). **Range:** <range>.
**Excluded (blocked):** #<x> (<H h MM min>), #<y> (<H h MM min>).

| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |
|---|---|---|---|---|---|---|---|
| <type> | <d> | <i> | <r> | <b> | <median> | <samples> | <H h MM min> |
| **Total** | **<d>** | **<i>** | **<r>** | **<b>** | | **<samples>** | **<H h MM min>** |

<type>: no measured duration; default <n> min
**Blocked:** <b> steps excluded from the estimate, about <H h MM min> of work.
**Unmapped and composite stage time:** <total> (composite remediation <c>, unmapped stages <u>, approximate <a>); it enters no median.
**Weekly quota (active account):** <weekly> used, <delta> points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone.
```

Full report contents:

- `<completed>` is `None yet` or the completed issues; `<blocked>` is `None` or each blocked issue with its
  reason. In item mode the heading reads `## Item #<issue>: status at ...`.
- In item mode the State header reads `| State | Item |`, the Running and Pending rows carry no wave or band
  label (`| Running | #<i>: ...` and `| Pending | #<i> (<t>) |`), and the weekly line ends `points since the
  measurement started. This pool also covers the other runs in this session, so it is not this item's cost alone.`
- One `Running` row per running feature, with ` Now at: <phase>.` and ` PR <state>.` when present and
  `(wave <w>)` when the item has no band; one `Pending, wave <w>` row per wave with pending features. The `Epic`
  wave row appears when epic-level steps exist.
- Per-feature table: one row per feature in kickoff order; start and finish are scheduled times from now, and
  an excluded (blocked or blocked-dependent) feature prints `excluded`.
- Critical-path section: `<dependency-source>` is `checkpoint`, `manifest`, `checkpoint+manifest`, or `waves`;
  `<cap-source>` is `checkpoint`, `config`, or `built-in`. The `**Dependency graph:**` line appears only for a
  self-loop, an unresolved reference, or a cycle, and `**Excluded (blocked):**` only when a feature is excluded.
  `**Cross-epic:**` appears only when a cross-epic edge exists; `<label>` is `external` or `external (default)`. In item mode it reads `**Critical path:** #<issue>. Headline <h>: the item finishes in <h>; no dependency,
  cap, or tail.` with no Schedule inputs line.
- One per-type row per type that has a step, in catalog order. `<median>` is `H h MM min`, followed by
  `(default)` for a type without samples and `(approx)` when an approximate sample is retained.
- One `<type>: no measured duration; default <n> min` line per type that uses a default; the `**Blocked:**`
  line (`1 step` when one is blocked) appears only when a step is blocked; the unmapped line reads `none.` when
  no such time was recorded. Times use invariant culture and UTC.

## Calculation Rules

- Steps: derived per the step model above; the completion percentage is done steps over total steps (decision D8).
- Feature state: Completed when merged; Blocked when blocked by recorded state; Running when a task is done, a checkpoint
  exists, the epic row is past `not_started`, or a PR exists; otherwise Pending.
- Median: over all retained samples of a type; an odd count takes the middle value and an even count averages the middle pair.
- Samples: one per closed `stage_timing` attempt (key `<issue>|<stage>|<attempt>`), one per execution task (key
  `<issue>|exec|<plan file>|<task>`), and approximate main-sync and merge samples from epic rows (decision D3). One sample per
  key is kept across runs; a `stage_timing` sample replaces a `tick` sample of the same key.
- Retention: the duration ledger keeps the newest 1000 samples per type and is not limited by `-SampleCap`; the check-in samples
  keep `-SampleCap` (default 14).
- Tick split: tasks newly checked between two runs each receive (now - last tick - excluded seconds) / (number of newly checked
  tasks); the excluded seconds are the union of the pause spans and the item's blocked span in the interval, counted once (E11).
  The first observation of a plan seeds the anchor from the execution stage start when one is recorded, otherwise from now with
  no sample. When the execution stage closes, each task's sample becomes the stage duration divided by the task count.
- Estimate per type: remaining steps x median, plus, for each in-progress step, max(0, median - elapsed in step). Blocked steps
  are excluded and their would-be subtotal is listed; elapsed time does not accrue while an item is blocked. The step-type table
  shows this sum over types; it is no longer the headline.
- Sequential velocity (E3): a feature's rate is its execution samples in the ledger (keys `<issue>|exec|...`) over their summed
  hours. A feature qualifies with at least 5 tasks and 15 active minutes (900 s). The pooled rate is the median over qualifying
  features, with the across-feature SD (n-1, `n/a` below 2 features). Each feature uses its own rate when it qualifies, else the
  pooled rate, else the default rate.
- Default rate (E2): 3600 / the execution default in seconds: 12 tasks per hour with the built-in 5 minutes, 10 with
  `-StepDefaultMinutes @{ execution = 6 }`.
- Remaining per feature (E4): remaining execution tasks x 3600 / rate, plus each remaining non-execution step at its per-type
  median, plus in-progress credit; an in-progress task's median is 3600 / rate.
- Dependencies (E5): the epic checkpoint `features[].depends_on` of a row that carries the key, else the `epic.md` inline list
  (one `git show`, only when a kickoff feature has no checkpoint key; a block-style list is not parsed). `[]` means none; a
  reference resolves by issue number or feature-folder basename; a merged feature is satisfied. Waves apply only when no feature
  has the key in either source, each feature then depending on every feature of the nearest lower wave. A self-loop, an
  unresolved reference, or a cycle prints its message and falls back to waves.
- Cap (E5): the checkpoint `max_parallel_features` when it is an integer from 1 to 8, else
  `codex_topology_policy.parallelism.default_max_parallel_features` in `config/orchestration-routing.json`, else 4. Item mode
  has one node and no cap.
- List schedule (E6): done features finish at 0 and hold no slot; running features start at 0 even beyond the cap; ready
  features start while fewer than the cap run, by descending longest remaining path, ties by ascending issue number. The
  headline is the latest finish plus the tail; the chain follows each start's delaying predecessor (the dependency that finished
  last, or the feature whose finish freed the slot).
- Blocked features (E7): a blocked feature and its transitive dependents leave the schedule and the serial sum and are listed
  with their remaining time.
- Cross-epic edges (issue #1162, D9): each `cross_epic_depends_on` prerequisite is an external node `<epic>#<n>` (no leading
  `#`): done when its checkpoint hold record shows `integrated` or `in_main`, else pending, never blocked; priced from the other
  epic's prepared plan (pooled rate, step medians), else per-type defaults with zero tasks, labeled `external (default)`.
  External nodes skip the cap, add no steps, and enter the time figures only; the `**Cross-epic:**` line appears only when an
  edge exists.
- Tail (E8): one predicted `main-sync` and one `integration-pr`, at their ledger medians or 60 and 45 minutes, with in-progress
  credit. The predicted sync is omitted when a sync row that is not done exists or `integration-pr` is in progress or done; a
  done `integration-pr` gives a tail of 0. The predicted sync enters the time figures only, not the step counts.
- Serial sum: the per-feature remaining times plus the tail, equal to the cap-1 schedule; the headline never exceeds it.
- Range (E9): the schedule re-run at rate + 2.05 x SD and rate - 2.05 x SD. SD is the across-feature SD with at least 2
  qualifying features, else the aggregate interval SD with at least 3 intervals, else the range is `n/a` with its reason. The
  slow end is `no upper bound` when a feature with remaining tasks has a slow rate at or below 0.5 tasks per hour.
- Pauses (E11): a gap longer than 3600 s between consecutive check-in samples (3 x the 20-minute cadence; a constant, not a
  parameter) is a pause span, and `-ResetBaseline` appends the span from the newest stored sample to the resume instant. Spans
  are excluded from tick batches and from the aggregate elapsed time.
- Aggregate velocity (E11): the average is (done tasks - `baselineDoneTasks`) over active hours. Intervals combine consecutive
  samples until at least 600 s have passed; a trailing remainder under 600 s is skipped, and an interval overlapping a pause
  span is dropped. Recent is the last interval; the interval SD (n-1) is `n/a` below 3 intervals. Samples without a task count,
  kept from version 2, form no interval. The average is `n/a` while no interval exists.
- Check-ins: a check-in sample (Unix epoch seconds, done steps, done tasks) is added when there is no previous sample or the
  previous one is at least 90 seconds old. Epoch seconds are used because `ConvertFrom-Json` converts ISO date strings into
  local-time values.
- Weekly quota: the seven-day percentage of the active account in `cswap list --json`; `n/a` when `cswap` is missing or prints
  nothing parseable.
- `n/a`: every printed number passes through a formatter that returns `n/a` for NaN or infinity.

## Starting the Reports

1. Run the script once from the repository root to set the baseline. Either pass the start and the steps done:

   ```text
   pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -BaselineDone 40 -Mode TLDR
   ```

   or start the measurement now:

   ```text
   pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -ResetBaseline
   ```

   For a standalone item, pass `-Issue <n>` instead of `-EpicFolder`. The start and baseline are stored in the
   state file, so later runs need no `-StartUtc`.
2. Create the two recurring jobs with `CronCreate`, using the prompts below with `<epic-folder>` replaced.
3. Confirm both jobs with `CronList`.

## Scheduling Prompts

TL;DR job: cron `*/20 * * * *`, recurring.

```text
Run `pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder <epic-folder> -Mode TLDR` from the repository root and post its output verbatim as the TL;DR epic update (no push notification). Do not add commentary unless a run is blocked or a child has finished and needs relaying.
```

Hourly job: cron `7 * * * *`, recurring.

```text
Run `pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder <epic-folder>` (full mode) from the repository root and post its output as the hourly epic update, then send a PushNotification with the TL;DR line (under 200 characters). Check `cswap list` for the weekly pool; stop and commit at 93%.
```

Notes on the prompts:

- Push-notification text: the first TL;DR output line with every `**` removed. When that text is 200
  characters or longer, drop the running-features sentence; the remaining text (prefix, task and step counts,
  percentage, and done-sentence) is under 200 characters.
- The prompts omit `-StartUtc`, `-BaselineDone`, `-ResetBaseline`, and `-PairSamples`. The baseline is read
  from the state file, so a later reset is never overridden by a stale scheduled argument, and pairing is never
  repeated by a recurring job. For a standalone item, replace `-EpicFolder <epic-folder>` with `-Issue <n>`.
- Cron times are local time, not UTC.
- Jitter (`https://code.claude.com/docs/en/scheduled-tasks`, `### Jitter`): a recurring task runs late by up to
  half the gap to its next run and at most 30 minutes, by a constant delay per job, so the 20-minute job runs
  0 to 10 minutes late and the hourly job 0 to 30 minutes late.

## Resetting the Baseline After a Pause

Whenever work resumes after a pause or an outage, run the script once with `-ResetBaseline`:

```text
pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -ResetBaseline
```

- The stored check-in samples and blocked spans are discarded, the start becomes now, and the baseline done
  count becomes the current done step count. Pass `-StartUtc` and `-BaselineDone` with `-ResetBaseline` when
  the resume instant is in the past.
- The duration ledger and the tick anchors are kept (decision D10), so the medians survive a reset; the stored
  pause spans are kept except as the pruning rule under `## State File` states, and a span from the newest
  stored sample to the resume instant is appended (decision E11), so the pause enters no velocity.
- The weekly-quota baseline is kept, so the Full report's points since the epic started stay accurate. The
  scheduled prompts are not changed.
- The first report after a reset shows `0 h 00 min` elapsed; the estimate still uses the retained medians.

## Changing the Cadence

To move the TL;DR job to a new interval (for example from 10 to 20 minutes):

1. Run the script once with `-PairSamples`; one run is enough for one doubling. It keeps the newest check-in
   sample and every second older sample, so the stored intervals match the doubled cadence. 14 samples become 7.
2. Delete the TL;DR job with `CronDelete` and create it again with `CronCreate` at the new interval.

`-PairSamples` is a one-shot command: each run halves the samples again. Never put it in a scheduled prompt.
Pairing affects only the check-in samples; the duration ledger and the estimate do not depend on the cadence.

## Stopping the Reports

1. Run `CronList` and note the IDs of the TL;DR and hourly jobs.
2. Run `CronDelete` for each report job ID.
3. Keep the state file for a later restart of the reports, or delete it.

## After a Restart

- `CronCreate` jobs are session-only: they fire only while the session runs and is idle, and a missed run fires
  once when the session becomes idle again. `claude --resume` or `claude --continue` restores jobs that have not
  expired. Recurring jobs expire 7 days after creation; recreate both before the 7-day expiry.
- Run `CronList` and recreate only the missing jobs with the prompts above. If work paused during the restart,
  reset the baseline first.
- The state file survives under `.claude/state/` wherever the checkout persists, so the baseline, samples,
  pause spans, and duration ledger are kept.

## State File

- Location: `.claude/state/epic-progress-<epic-folder>.json`, or `.claude/state/progress-item-<n>.json` in item
  mode, under the repository root. `-StatePath` overrides it. Durations are kept per state file (decision D12).
- The state is never committed: `.claude/state/` is gitignored in this repository and the push-down adds it to
  a destination's `.gitignore`. The state is per checkout: a different worktree or `-RepositoryRoot` starts a
  separate history, so run from the same root or pass `-StatePath`. `git clean -fdX` deletes it.
- A state file under the system temporary directory, written by an earlier version, is not migrated: pass its
  path once with `-StatePath`, or reset the baseline.
- The current document is version 3 (decision E12):

  ```json
  {
    "version": 3, "unit": "steps", "startUnixSeconds": 1767603600,
    "baselineDone": 0, "baselineDoneTasks": 0, "baselineWeeklyPct": 0,
    "samples": [ { "ts": 1767614400, "done": 12, "tasks": 7, "features": { "12": 7 } } ],
    "pauses": [ { "startUnixSeconds": 1767600000, "endUnixSeconds": 1767603600 } ],
    "durations": { "review": [ { "key": "12|review|1", "type": "review", "seconds": 780, "source": "stage_timing", "approx": false, "recorded": 1767614400 } ] },
    "items": { "12": { "plans": { "plan.md": { "checked": [ "P0-T1" ], "lastTickUnixSeconds": 1767614400 } }, "blockedSinceUnixSeconds": null } }
  }
  ```

- Migration: a version-2 document keeps its start, baseline done count, weekly baseline, durations, items, and
  samples; its samples carry no task count, so task velocity starts at the first version-3 run;
  `baselineDoneTasks` becomes the current done task count, `pauses` starts empty, and the step baseline is not
  reset. A version-1 document and the legacy array of samples counted tasks, so their samples and baseline
  done count are discarded, the baseline resolves to the current step count, and the start and the weekly
  baseline of a version-1 document are kept. The next write is version 3.
- Blank text, unparseable text, or version 4 or higher is read as empty state; a missing field is absent.
- The state is written when a check-in sample is added, the duration ledger or a tick anchor changes, a pause
  span is appended, or `-ResetBaseline` or `-PairSamples` is given. When an item's merge step is done, its
  `items` entry is removed; its durations stay in the ledger. A pause span that ends before the earliest
  stored instant (the start, the oldest sample, or the oldest tick anchor) is dropped when the state is written.

## Known Behaviors and Measured Rates

- Plan checkboxes tick at batch boundaries; the tick split divides a batch's interval evenly across its tasks,
  so a burst of checks no longer swings the estimate.
- Review, PR, CI, merge, and main-sync time is counted as steps with their own medians, so the estimate falls
  while those steps run instead of reading as zero progress.
- Task totals drift when planners revise plans, and the step total grows when a remediation cycle opens, so
  read the percentage against the live total.
- Until each type has a sample the estimate uses the default durations; the Now line states how many types use
  defaults. Until 2 features qualify and 3 intervals exist, the range prints `n/a` with its reason.
- Contention lowers per-feature rates, and a block-style `depends_on` list is not parsed (the waves apply).
- Durations of a child whose worktree was removed before the report first observed it are not recovered; its
  done steps count as done with no samples.
- Measured rates behind the defaults: per-feature pace is about 9 to 13 tasks per hour; review takes about 10
  to 18 minutes per attempt; CI about 17 to 28 minutes. Weekly quota burn is 3 to 7 points per hour.

## Decisions

Each decision is an orchestrator default adopted for autonomous delivery; the owner may revisit any of them.

- D1: blockage is read from recorded state only; a missed handoff is not detected.
- D2: composite remediation stages give no per-type samples and are reported as unmapped composite time;
  remaining remediation steps use the medians of the same types.
- D3: no `git log` or `git ls-tree` call is added; approximate durations come only from epic rows, review
  artifact stamps named by checkpoint paths, and cycle entry times, each marked approximate.
- D4: each recorded attempt is one step and gives one sample.
- D5: the default durations above, overridable with `-StepDefaultMinutes`.
- D6: a child with no checkpoint whose plan exists counts research, spec, and plan as done.
- D7: (superseded by #1153, E4, E6, and E10) the headline estimate is the serial sum over types; wave-parallel
  is secondary.
- D8: the completion percentage is by step count.
- D9: standalone items use the `Item` parameter set with a mandatory `-Issue`.
- D10: (amended by E11) `-ResetBaseline` keeps the duration ledger and the tick anchors.
- D11: (superseded by #1153, E8, for the predicted tail only) main syncs are counted once recorded in the epic
  checkpoint; future syncs are not predicted.
- D12: durations are kept per state file.
- D13: (superseded by #1153, E3 and E9) the velocity, SD, and range lines are dropped and their functions
  removed; `-WaveOverheadHours` stays accepted and affects no figure.

Issue #1153 decisions (the rules are stated under Calculation Rules):

- E1: the five-line TL;DR; the percentage stays by step count. E2: the default rate is 3600 / the execution
  default seconds. E3: sequential velocity, qualifying at 5 tasks and 15 active minutes, pooled by median.
- E4: per-feature remaining time prices tasks at 3600 / rate (`-MedianOverride`). E5: dependencies from the
  checkpoint, else `epic.md`, else waves; the cap from the checkpoint, else the routing config, else 4.
- E6: list scheduling gives the headline and the chain. E7: blocked features and their dependents are
  excluded and listed. E8: the tail is a predicted main sync and the integration PR.
- E9: the range at rate +/- 2.05 SD, unbounded at or below 0.5 tasks per hour. E10: the wave-parallel figure
  is retired. E11: pause spans above 3600 s and on reset are excluded; intervals combine to 600 s.
- E12: state version 3 with a version-2 migration. E13: TL;DR cron `*/20 * * * *`, hourly `7 * * * *`. E14:
  pure logic in the Velocity, Schedule, and CriticalPath files, reads in Gather, wiring in the entry. E15: this record.

## Notes

- Delivery: the push-down serves the installed extension payload, so this skill reaches a destination repository
  only after the extension is rebuilt and reinstalled.
- Quota: the 93% stop in the hourly prompt is coordinator policy. The commit-before-the-wall procedure is
  governed by `.claude/skills/quota-throttling/SKILL.md`.
- The script is read-only toward git and GitHub: it runs only `git fetch`, `git show`, `git worktree list`,
  `gh pr list`, and `cswap list --json`, and the only file it writes is the state file.
- In this repository, a repository-only wrapper forwards every argument to the canonical script; the skill
  always invokes the canonical script.

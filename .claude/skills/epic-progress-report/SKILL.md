---
name: epic-progress-report
description: 'Post recurring epic progress reports from the coordinator session: a four-line TL;DR every 10 minutes and an hourly full status update with a push notification. Progress is measured in typed steps (research, spec, plan, preflight, execution, review, PR, CI, merge, main sync, integration PR) and the time remaining is the sum over step types of remaining steps times the median measured duration. Use when an epic or a standalone item is running and the owner wants scheduled progress and time-remaining reports, or when the reports must be started, reset after a pause, moved to a new cadence, stopped, or recreated after a restart.'
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

This skill runs the epic progress report script and schedules two recurring reports in the
coordinator's main session: a four-line TL;DR and an hourly full status update. The script is
`.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1`. It reads the epic
kickoff, the feature plans, each live item checkpoint, the epic checkpoint, the pull-request
state, and the weekly quota, prints the report, and keeps its samples, its duration ledger, and
its baseline in a state file. It also reports a standalone item (`-Issue`).

## When to Use This Skill

- An epic or a standalone item is running and the owner wants scheduled progress reports.
- The reports must be started, or recreated after the session restarted.
- Work resumed after a pause or an outage and the baseline must be reset.
- The TL;DR cadence changes (for example from 5 to 10 minutes).
- The work is finished and the reports must be stopped.

## Prerequisites

- PowerShell 7 and `git`. `gh` and `cswap` are optional: without `gh` the pull-request state
  is empty, and without `cswap` (or without parseable output) the weekly quota prints `n/a`.
- Epic mode: the epic kickoff at `docs/features/epics/<epic-folder>/epic-kickoff.md` on
  `origin/epic/<epic-folder>-integration`, with a feature-summary table (header first cell
  `issue_num` or `Issue`) and an `Epic issue: #<n>` line. Pass `-EpicIssue` when the line
  is missing.
- The epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json` under the
  repository root (optional; without it every feature is classified from its plan and PR).
- Item mode: a live worktree whose `artifacts/orchestration/orchestrator-state.json` carries
  the item's `issue-num` and its `plan-path`.
- Run from the repository root in the coordinator's main session. An agent-isolated worktree
  refuses command text containing `pwsh`, and the scheduled jobs and notifications belong to
  the main session.

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
| `-WaveOverheadHours` | 1.25 | Accepted for compatibility; it affects no figure (decision D13). |
| `-SampleCap` | 14 | Maximum number of check-in samples kept; the duration ledger is not limited by it. |
| `-Mode` | `Full` | `TLDR` prints the four TL;DR lines; `Full` prints them followed by the full report. |
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

- The initial run has one step of each item type plus one execution step per plan task.
- A type with several recorded attempts counts one step per attempt (decision D4).
- Each opened `remediation_loop.cycles[]` entry adds `plan` and `preflight` (unless its
  `remediation_path` is `light`; a missing key is full), one execution step per task in the
  file named by its `plan_path`, one `review` step, and one `ci` step when the cycle opened
  after a PR existed. Cycles not yet opened are not predicted, so the total grows and the
  percentage can fall when a cycle opens.
- The in-progress step is the open `stage_timing` entry; without one, the step named by
  `next_step` (an `S2_research` or `S3b_research` value names the research step).
- A child without a checkpoint whose plan is already written counts research, spec, and plan as
  done (decision D6); a merged child has every step done.
- Live stage names map through aliases, compared case-insensitively after trimming:
  `feature_review` and `S7_feature_review` to `review`; `atomic_execution` and
  `S5_atomic_execution` to `execution`; `S2_research` to `research`; `S3_spec` to `spec`;
  `S4_atomic_planning` to `plan`; `S4_preflight` to `preflight`; `S8_create_pr` to `pr`; and
  `S9_ci_gate` and `S9_ci_green` to `ci`.
- Stage names `planning` and `plan` map to `plan`; names starting with `remediation` are
  composite remediation time (decision D2); any other unknown name, for example `promotion`, is
  unmapped time. Neither enters a median.

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

Blockage by recorded state (decision D1): an item is blocked when `blocked_reason` is set to a
value other than `none` or `awaiting_ci`, a `human_interaction.requirements[]` entry has
`response: "halt"`, `step6_status` is `blocked_remediation_loop_limit`, `step9_status` is
`blocked_ci_loop_limit`, or the epic row `merge_status` is `blocked_conflict_loop_limit`. Its
steps that are not done are reported as blocked and excluded from the estimate. A run with no
new checked task is never treated as a blockage.

## Report Formats

Values in angle brackets are placeholders; the examples use the fictional epic folder
`example-epic` and epic issue `42`.

TL;DR (both modes print these four lines first):

```text
**TL;DR:** Epic #<issue> is at <done> of <total> steps (<pct>%). <done-sentence> <running-sentence>
**Elapsed:** <H h MM min>, with about <hours> hours left on the per-type estimate (<b> blocked steps excluded). **Weekly** quota is at <weekly>.
**Now:** #<i> <type> (<elapsed> of median <m>)[, ...]. <k> of <n> types use defaults.
**Estimated time remaining:** <H h MM min> by type (sum); <H h MM min> wave-parallel.
```

Variants:

- In item mode the subject reads `Item #<issue>` and the wave-parallel figure equals the sum.
- done-sentence: `None of the <N> features is done yet.` or `<K> of <N> features are done.`;
  an epic with one feature prints `The only feature is not done yet.` or
  `The only feature is done.`; item mode prints `#<i> is not done yet.` or `#<i> is done.`
- running-sentence: `No feature is running.`, `#<i> is running (<d> of <t> steps).`, or
  `#<a> (<d> of <t>), #<b> (<d> of <t>) are running.`; each blocked item adds
  `#<i> is blocked (<reason>).` Item mode omits `No feature is running.`
- A blocked count of one prints `(1 blocked step excluded)` and
  `**Blocked:** 1 step excluded from the estimate`.
- Now line: `no step is in progress` when nothing runs; a step whose elapsed time exceeds its
  median reads `(<elapsed> of median <m>, over median)`.
- `<pct>` and `<hours>` are rounded to one decimal with invariant culture and default (to-even)
  rounding; an integral value prints without a decimal. `<weekly>` is `<value>%` or `n/a`.
- Any non-finite value prints `n/a`; no report prints `NaN` or `Infinity`.

Example (fictional):

```text
**TL;DR:** Epic #42 is at 19 of 35 steps (54.3%). 1 of 3 features are done. #12345 is running (6 of 13 steps).
**Elapsed:** 3 h 00 min, with about 2.8 hours left on the per-type estimate (0 blocked steps excluded). **Weekly** quota is at 42.5%.
**Now:** no step is in progress. 10 of 10 types use defaults.
**Estimated time remaining:** 2 h 45 min by type (sum); 2 h 45 min wave-parallel.
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

- `<completed>` is `None yet` or the completed issues; `<blocked>` is `None` or each blocked
  issue with its reason. In item mode the heading reads `## Item #<issue>: status at ...`.
- In item mode the State header reads `| State | Item |`, the Running and Pending rows carry no
  wave or band label (`| Running | #<i>: ...` and `| Pending | #<i> (<t>) |`), and the weekly
  line ends `points since the measurement started. This pool also covers the other runs in this
  session, so it is not this item's cost alone.`
- One `Running` row per running feature, with ` Now at: <phase>.` and ` PR <state>.` when
  present and `(wave <w>)` when the item has no band; one `Pending, wave <w>` row per wave
  with pending features.
- The `Epic` wave row appears when epic-level steps exist.
- One per-type row per type that has a step, in catalog order. `<median>` is `H h MM min`,
  followed by `(default)` for a type without samples and `(approx)` when an approximate sample
  is retained.
- One `<type>: no measured duration; default <n> min` line per type that uses a default; the
  `**Blocked:**` line appears only when a step is blocked; the unmapped line reads `none.`
  when no such time was recorded.
- No velocity, standard-deviation, straight-line, or range line is printed in either mode.
- Times use invariant culture and UTC.

## Calculation Rules

- Steps: derived per the step model above; the completion percentage is done steps over total
  steps (decision D8).
- Feature state: Completed when merged; Blocked when blocked by recorded state; Running when a
  task is done, a checkpoint exists, the epic row is past `not_started`, or a PR exists;
  otherwise Pending.
- Median: over all retained samples of a type; an odd count takes the middle value and an even
  count averages the middle pair.
- Samples: one per closed `stage_timing` attempt (key `<issue>|<stage>|<attempt>`), one per
  execution task (key `<issue>|exec|<plan file>|<task>`), and approximate main-sync and merge
  samples from epic rows (decision D3). One sample per key is kept across runs; a
  `stage_timing` sample replaces a `tick` sample of the same key.
- Retention: the duration ledger keeps the newest 1000 samples per type and is not limited by
  `-SampleCap`; the check-in samples keep `-SampleCap` (default 14).
- Tick split: tasks newly checked between two runs each receive (now - last tick - blocked
  seconds) / (number of newly checked tasks). The first observation of a plan seeds the anchor
  from the execution stage start when one is recorded, otherwise from now with no sample. When
  the execution stage closes, each task's sample becomes the stage duration divided by the task
  count.
- Estimate per type: remaining steps x median, plus, for each in-progress step,
  max(0, median - elapsed in step). Blocked steps are excluded and their would-be subtotal is
  listed; elapsed time does not accrue while an item is blocked. The headline is the sum over
  types (decision D7).
- Wave-parallel: the largest per-feature remaining time of each open wave, summed, plus the
  epic-level steps.
- Check-ins: a check-in sample (Unix epoch seconds, done steps) is added when there is no
  previous sample or the previous one is at least 90 seconds old. Epoch seconds are used
  because `ConvertFrom-Json` converts ISO date strings into local-time values.
- Weekly quota: the seven-day percentage of the active account in `cswap list --json`;
  `n/a` when `cswap` is missing or prints nothing parseable.
- `n/a`: every printed number passes through a formatter that returns `n/a` for NaN or
  infinity.

## Starting the Reports

1. Run the script once from the repository root to set the baseline. Either pass the start
   and the steps already done at that start:

   ```text
   pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -BaselineDone 40 -Mode TLDR
   ```

   or start the measurement now:

   ```text
   pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -ResetBaseline
   ```

   For a standalone item, pass `-Issue <n>` instead of `-EpicFolder`. The start and baseline
   are stored in the state file, so later runs need no `-StartUtc`.
2. Create the two recurring jobs with `CronCreate`, using the prompts below with
   `<epic-folder>` replaced by the epic folder name.
3. Confirm both jobs with `CronList`.

## Scheduling Prompts

TL;DR job: cron `*/10 * * * *`, recurring.

```text
Run `pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder <epic-folder> -Mode TLDR` from the repository root and post its output verbatim as the TL;DR epic update (no push notification). Do not add commentary unless a run is blocked or a child has finished and needs relaying.
```

Hourly job: cron `7 * * * *`, recurring.

```text
Run `pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder <epic-folder>` (full mode) from the repository root and post its output as the hourly epic update, then send a PushNotification with the TL;DR line (under 200 characters). Check `cswap list` for the weekly pool; stop and commit at 93%.
```

Notes on the prompts:

- Push-notification text: the first TL;DR output line with every `**` removed. When that text
  is 200 characters or longer, drop the running-features sentence; the remaining text (prefix,
  step counts, percentage, and done-sentence) is well under 200 characters.
- The prompts omit `-StartUtc`, `-BaselineDone`, `-ResetBaseline`, and `-PairSamples`. The
  baseline is read from the state file, so a later reset is never overridden by a stale
  scheduled argument, and pairing is never repeated by a recurring job.
- For a standalone item, replace `-EpicFolder <epic-folder>` with `-Issue <n>` in both prompts.
- Cron times are local time, not UTC.
- Jitter: a 10-minute job fires up to 5 minutes late and an hourly job up to 30 minutes late,
  by a constant delay per job.

## Resetting the Baseline After a Pause

Whenever work resumes after a pause or an outage, run the script once with `-ResetBaseline`:

```text
pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -ResetBaseline
```

- The stored check-in samples and blocked spans are discarded, the start becomes now, and the
  baseline done count becomes the current done step count. Pass `-StartUtc` and
  `-BaselineDone` with `-ResetBaseline` when the resume instant is in the past.
- The duration ledger and the tick anchors are kept (decision D10), so the medians survive a
  reset.
- The weekly-quota baseline is kept, so the Full report's points since the epic started stay
  accurate.
- The scheduled prompts are not changed.
- The first report after a reset shows `0 h 00 min` elapsed; the estimate still uses the
  retained medians and defaults.

## Changing the Cadence

To move the TL;DR job to a new interval (for example from 5 to 10 minutes):

1. Run the script once with `-PairSamples`. It keeps the newest check-in sample and every
   second older sample, so the stored intervals match the doubled cadence. 14 samples become 7.
2. Delete the TL;DR job with `CronDelete` and create it again with `CronCreate` at the new
   interval.

`-PairSamples` is a one-shot command: each run halves the samples again. Never put it in a
scheduled prompt. Pairing affects only the check-in samples; the duration ledger and the
estimate do not depend on the cadence.

## Stopping the Reports

1. Run `CronList` and note the IDs of the TL;DR and hourly jobs.
2. Run `CronDelete` for each report job ID.
3. Keep the state file for a later restart of the reports, or delete it.

## After a Restart

- `CronCreate` jobs are session-only: they fire only while the session runs and is idle, and a
  missed run fires once when the session becomes idle again.
- `claude --resume` or `claude --continue` restores jobs that have not expired.
- Recurring jobs expire 7 days after creation; recreate both before the 7-day expiry.
- Run `CronList` and recreate only the missing jobs with the prompts above.
- If work paused during the restart, reset the baseline first.
- The state file survives under `.claude/state/` wherever the checkout persists, so the
  baseline, samples, and duration ledger are kept.

## State File

- Location: `.claude/state/epic-progress-<epic-folder>.json`, or
  `.claude/state/progress-item-<n>.json` in item mode, under the repository root.
  `-StatePath` overrides it. Durations are kept per state file (decision D12).
- The state is never committed: `.claude/state/` is gitignored in this repository and the
  push-down adds it to a destination's `.gitignore`.
- The state is per checkout: a different worktree or `-RepositoryRoot` starts a separate
  history. Run from the same root, or pass `-StatePath`.
- `git clean -fdX` deletes it.
- A state file under the system temporary directory, written by an earlier version, is not
  migrated: pass its path once with `-StatePath`, or reset the baseline.
- The current document is version 2:

  ```json
  {
    "version": 2,
    "unit": "steps",
    "startUnixSeconds": 1767603600,
    "baselineDone": 0,
    "baselineWeeklyPct": 0,
    "samples": [ { "ts": 1767614400, "done": 12 } ],
    "durations": {
      "review": [ { "key": "12|review|1", "type": "review", "seconds": 780, "source": "stage_timing", "approx": false, "recorded": 1767614400 } ]
    },
    "items": {
      "12": { "plans": { "plan.md": { "checked": [ "P0-T1" ], "lastTickUnixSeconds": 1767614400 } }, "blockedSinceUnixSeconds": null }
    }
  }
  ```

- Migration: a version-1 document and the legacy array of samples counted tasks, so their
  samples and baseline done count are discarded, the baseline resolves to the current step
  count, the start and the weekly baseline of a version-1 document are kept, and the next write
  is version 2.
- Blank text, unparseable text, or version 3 or higher is read as empty state; a missing field
  is absent.
- The state is written when a check-in sample is added, the duration ledger or a tick anchor
  changes, or `-ResetBaseline` or `-PairSamples` is given.

## Known Behaviors and Measured Rates

- Plan checkboxes tick at batch boundaries; the tick split divides a batch's interval evenly
  across its tasks, so a burst of checks no longer swings the estimate.
- Review, PR, CI, merge, and main-sync time is counted as steps with their own medians, so the
  estimate falls while those steps run instead of reading as zero progress.
- Task totals drift when planners revise plans, and the step total grows when a remediation
  cycle opens, so read the percentage against the live total.
- Until each type has a sample the estimate uses the default durations; the Now line states how
  many types use defaults.
- Durations of a child whose worktree was removed before the report first observed it are not
  recovered; its done steps count as done with no samples.
- Measured rates behind the defaults: per-feature pace is about 9 to 13 tasks per hour; review
  takes about 10 to 18 minutes per attempt; CI about 17 to 28 minutes.
- Weekly quota burn is 3 to 7 points per hour.

## Decisions

Each decision is an orchestrator default adopted for autonomous delivery; the owner may revisit
any of them.

- D1: blockage is read from recorded state only; a missed handoff is not detected.
- D2: composite remediation stages give no per-type samples and are reported as unmapped
  composite time; remaining remediation steps use the medians of the same types.
- D3: no `git log` or `git ls-tree` call is added; approximate durations come only from epic
  rows, review artifact stamps named by checkpoint paths, and cycle entry times, each marked
  approximate.
- D4: each recorded attempt is one step and gives one sample.
- D5: the default durations above, overridable with `-StepDefaultMinutes`.
- D6: a child with no checkpoint whose plan exists counts research, spec, and plan as done.
- D7: the headline estimate is the serial sum over types; wave-parallel is secondary.
- D8: the completion percentage is by step count.
- D9: standalone items use the `Item` parameter set with a mandatory `-Issue`.
- D10: `-ResetBaseline` keeps the duration ledger and the tick anchors.
- D11: main syncs are counted once recorded in the epic checkpoint; future syncs are not
  predicted.
- D12: durations are kept per state file.
- D13: the velocity, SD, and range lines are dropped and their functions removed;
  `-WaveOverheadHours` stays accepted and affects no figure.

## Notes

- Delivery: the push-down serves the installed extension payload, so this skill reaches a
  destination repository only after the extension is rebuilt and reinstalled.
- Quota: the 93% stop in the hourly prompt is coordinator policy. The commit-before-the-wall
  procedure is governed by `.claude/skills/quota-throttling/SKILL.md`.
- The script is read-only toward git and GitHub: it runs only `git fetch`, `git show`,
  `git worktree list`, `gh pr list`, and `cswap list --json`, and the only file it writes is
  the state file.
- In this repository, `scripts/dev-tools/Get-EpicProgressReport.ps1` forwards every argument
  to the canonical script; the skill always invokes the canonical script.

---
name: epic-progress-report
description: 'Post recurring epic progress reports from the coordinator session: a four-line TL;DR every 10 minutes and an hourly full status update with a push notification. Use when an epic is running and the owner wants scheduled progress, velocity, and time-remaining reports, or when the reports must be started, reset after a pause, moved to a new cadence, stopped, or recreated after a restart.'
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
kickoff, the feature plans, the epic checkpoint, the pull-request state, and the weekly quota,
prints the report, and keeps its samples and baseline in a state file.

## When to Use This Skill

- An epic is running and the owner wants scheduled progress reports.
- The reports must be started for an epic, or recreated after the session restarted.
- Work resumed after a pause or an outage and the velocity baseline must be reset.
- The TL;DR cadence changes (for example from 5 to 10 minutes).
- The epic is finished and the reports must be stopped.

## Prerequisites

- PowerShell 7 and `git`. `gh` and `cswap` are optional: without `gh` the pull-request state
  is empty, and without `cswap` (or without parseable output) the weekly quota prints `n/a`.
- The epic kickoff at `docs/features/epics/<epic-folder>/epic-kickoff.md` on
  `origin/epic/<epic-folder>-integration`, with a feature-summary table (header first cell
  `issue_num` or `Issue`) and an `Epic issue: #<n>` line. Pass `-EpicIssue` when the line
  is missing.
- The epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json` under the
  repository root (optional; without it every feature is classified from its plan and PR).
- Run from the repository root in the coordinator's main session. An agent-isolated worktree
  refuses command text containing `pwsh`, and the scheduled jobs and notifications belong to
  the main session.

## Inputs

| Parameter | Default | Meaning |
|---|---|---|
| `-EpicFolder` | (mandatory) | Epic folder name under `docs/features/epics/`; also the epic name in the status heading. |
| `-StartUtc` | stored start | Start of the measurement. Resolution: the passed value, else now with `-ResetBaseline`, else the stored start. With none of these the script stops before any git call with an error naming `-StartUtc` and `-ResetBaseline`. |
| `-BaselineDone` | stored value, else 0 | Tasks already complete at the start. With `-ResetBaseline` and no passed value, the current done count. |
| `-BaselineWeeklyPct` | stored value, else 0 | Weekly quota percentage at the start. `-ResetBaseline` does not change it. |
| `-EpicIssue` | the kickoff's `Epic issue: #<n>` line | Epic issue number printed in the report. |
| `-IntegrationBranch` | `origin/epic/<epic-folder>-integration` | Branch that holds the kickoff and the plans. |
| `-KickoffPath` | `docs/features/epics/<epic-folder>/epic-kickoff.md` | Kickoff path on the integration branch. |
| `-RepositoryRoot` | current location | Repository root in which git runs. |
| `-CheckpointPath` | `artifacts/orchestration/epic-orchestrator-state.json` | Epic checkpoint under the repository root. |
| `-StatePath` | `.claude/state/epic-progress-<epic-folder>.json` | State file under the repository root; the directory is created when missing. |
| `-WaveOverheadHours` | 1.25 | Review and CI hours added per open wave. |
| `-SampleCap` | 14 | Maximum number of samples kept. |
| `-Mode` | `Full` | `TLDR` prints the four TL;DR lines; `Full` prints them followed by the full report. |
| `-ResetBaseline` | off | Discards the stored samples and restarts the baseline now (see the reset section). |
| `-PairSamples` | off | One-shot: pairs the stored samples for a cadence change (see the cadence section). Cannot be combined with `-ResetBaseline`. |

A passed `-StartUtc`, `-BaselineDone`, or `-BaselineWeeklyPct` overrides the stored value and
is persisted with the next state write.

## Report Formats

The wording, order, and punctuation below are the script's output and do not change. Values in
angle brackets are placeholders; the examples use the fictional epic folder `example-epic` and
epic issue `42`.

TL;DR (both modes print these four lines first):

```text
**TL;DR:** Epic #<issue> is at <done> of <total> tasks (<pct>%). <done-sentence> <running-sentence>
**Elapsed:** <H h MM min>, with about <hours> hours left on the wave-parallel estimate. **Weekly** quota is at <weekly>.
**Avg Velocity:** <avg> tasks / hr. **Recent Velocity:** <recent> tasks / hr since last check-in. (SD of recent velocity: <sd>, from <n> intervals)
**Estimated time remaining:** <range>
```

Variants:

- done-sentence: `None of the <N> features is done yet.` or `<K> of <N> features are done.`
- running-sentence: `No feature is running.`, `#<i> is running (<d> of <t>).`, or
  `#<a> (<d> of <t>), #<b> (<d> of <t>) are running.`
- range: `<HH:MM> hrs (range needs 3 or more check-in intervals)`, `<HH:MM> hrs to <HH:MM> hrs`,
  or `<HH:MM> hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`.
- `<pct>`, `<avg>`, `<recent>`, and `<sd>` are rounded to one decimal and `<hours>` to zero
  decimals, with invariant culture and default (to-even) rounding; an integral value prints
  without a decimal (`1`, not `1.0`). `<weekly>` is `<value>%` or `n/a`.
- Any non-finite value prints `n/a`; no report prints `NaN` or `Infinity`.

Example (fictional):

```text
**TL;DR:** Epic #42 is at 3 of 10 tasks (30%). 1 of 3 features are done. #12345 is running (1 of 5).
**Elapsed:** 3 h 00 min, with about 10 hours left on the wave-parallel estimate. **Weekly** quota is at 42.5%.
**Avg Velocity:** 1 tasks / hr. **Recent Velocity:** 1 tasks / hr since last check-in. (SD of recent velocity: 0, from 3 intervals)
**Estimated time remaining:** 09:22 hrs to 09:39 hrs
```

Full mode prints the TL;DR lines, then these lines:

```text

## Epic #<issue> <epic-folder>: status at <HH:mm> UTC, <MMM d>

**Elapsed:** <H h MM min> since <HH:mm> UTC. **Progress:** <done> of <total> tasks complete, **<pct>%**.

| State | Features |
|---|---|
| Completed | <completed> |
| Running | #<i> (wave <w>, <band>): <d> of <t> tasks (<share>%).<phase><pr> |
| Pending, wave <w> | #<i> (<t>), #<j> (<t>) |

| Wave | Children | Tasks | Done |
|---|---|---|---|
| <w> | <count> | <tasks> | <done> |
| **Total** | **<features>** | **<total>** | **<done>** |

**Velocity:** <avg> tasks per hour (one child's pace). **Remaining:** <remaining> tasks.
- Straight line, no parallelism: about <H h MM min> (upper bound).
- Wave-parallel (longest chain <tasks> tasks plus about <overhead> h per open wave for review and CI): about **<H h MM min>**.
**Weekly quota (active account):** <weekly> used, <delta> points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone.
```

Full report contents:

- `<completed>` is `None yet` or the completed issues as `#<i>` joined with `, `.
- One `Running` row per running feature. `<phase>` is ` Now at: <phase>.` when a current
  phase exists, else empty; `<pr>` is ` PR <state>.` when a pull request exists, else empty;
  `<share>` is the feature percentage rounded to zero decimals.
- One `Pending, wave <w>` row per wave that holds pending features, in ascending wave order.
- One Wave-table row per wave in ascending order, then the bold Total row.
- `<overhead>` is `-WaveOverheadHours` unrounded. `<delta>` is the weekly percentage minus
  the weekly baseline, with a leading `+` when it is finite and not negative, else `n/a`.
- Times use invariant culture and UTC.

## Calculation Rules

- Task counts: plan checkboxes `- [ ] [P#-T#]` and `- [x] [P#-T#]` of each feature, read from
  the feature's worktree when its branch has one, otherwise from the plan on the integration
  branch. The feature list, waves, bands, and plan paths come from the kickoff's
  feature-summary table.
- Feature state: Completed when the checkpoint's `merge_status` is `merged` or
  `worktree_removed`, or the feature PR is merged; Running when any task is done, the
  checkpoint status is past `not_started`, or a PR exists; otherwise Pending.
- Elapsed: from the start instant to now, clamped at 0; printed as `H h MM min` from rounded
  total minutes.
- Average velocity: (done now - baseline done) / elapsed hours; 0 when elapsed is not above 0.
- Straight-line estimate: remaining tasks / average velocity; `n/a` when the average is not
  above 0.
- Wave-parallel estimate: the sum, over every wave with a non-completed feature, of the largest
  remaining task count among that wave's non-completed features, divided by the average
  velocity, plus `-WaveOverheadHours` (default 1.25 hours) per open wave; `n/a` when the
  average is not above 0.
- Samples: a check-in sample (Unix epoch seconds, done count) is added when there is no
  previous sample or the previous one is at least 90 seconds old; the newest `-SampleCap`
  (default 14) samples are kept. Epoch seconds are used because `ConvertFrom-Json` converts ISO
  date strings into local-time values.
- Interval velocity: max(0, change in done) / change in hours, for consecutive samples at
  least 2 minutes apart; closer pairs are skipped.
- Recent velocity: the latest interval's value; `n/a` without intervals.
- SD: the sample standard deviation (n-1 denominator) of the interval velocities; `n/a` below
  3 intervals. The report prints the interval count.
- Range: below 3 intervals, the wave-parallel estimate followed by
  `(range needs 3 or more check-in intervals)`. With 3 or more intervals the range is the
  average velocity plus and minus 2.05 SD: fast end = critical-path tasks /
  (average + 2.05 x SD) + overhead; slow velocity = average - 2.05 x SD; when the slow
  velocity is above 0.5 tasks per hour the slow end = critical-path tasks / slow velocity +
  overhead, otherwise the slow end prints the no-upper-bound text. Hours print as `HH:MM`.
- Weekly quota: the seven-day percentage of the active account in `cswap list --json`;
  `n/a` when `cswap` is missing or prints nothing parseable.
- `n/a`: every printed number passes through a formatter that returns `n/a` for NaN or
  infinity.

## Starting the Reports

1. Run the script once from the repository root to set the baseline. Either pass the start
   and the tasks already done at that start:

   ```text
   pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -BaselineDone 40 -Mode TLDR
   ```

   or start the measurement now:

   ```text
   pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -ResetBaseline
   ```

   The start and baseline are stored in the state file, so later runs need no `-StartUtc`.
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
  task counts, percentage, and done-sentence) is well under 200 characters.
- The prompts omit `-StartUtc`, `-BaselineDone`, `-ResetBaseline`, and `-PairSamples`. The
  baseline is read from the state file, so a later reset is never overridden by a stale
  scheduled argument, and pairing is never repeated by a recurring job.
- Cron times are local time, not UTC.
- Jitter: a 10-minute job fires up to 5 minutes late and an hourly job up to 30 minutes late,
  by a constant delay per job.

## Resetting the Baseline After a Pause

Whenever work resumes after a pause or an outage, run the script once with `-ResetBaseline`:

```text
pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -ResetBaseline
```

- The stored samples are discarded, the start becomes now, and the baseline done count becomes
  the current done count. Pass `-StartUtc` and `-BaselineDone` with `-ResetBaseline` when the
  resume instant is in the past.
- The weekly-quota baseline is kept, so the Full report's points since the epic started stay
  accurate.
- The scheduled prompts are not changed.
- The first reports after a reset show `0 h 00 min` elapsed and `n/a` estimates, and the
  estimates are unreliable for about two hours.
- Reason: earlier measures include the paused time. A 9-hour outage once distorted the averages
  until the baseline was reset.

## Changing the Cadence

To move the TL;DR job to a new interval (for example from 5 to 10 minutes):

1. Run the script once with `-PairSamples`. It keeps the newest sample and every second older
   sample, so the stored intervals match the doubled cadence. 14 samples become 7.
2. Delete the TL;DR job with `CronDelete` and create it again with `CronCreate` at the new
   interval.

`-PairSamples` is a one-shot command: each run halves the samples again. Never put it in a
scheduled prompt.

Worked example from recorded samples: thirteen 5-minute intervals gave mean 26.2 and SD 31.4
tasks per hour; after pairing, six 10-minute intervals give mean 27.3 and SD 23.2. The
conversation that defined the reports quoted 31.5 for the 5-minute SD; the recorded samples
give 31.4 (unrounded 31.4495).

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
  baseline and samples are kept.

## State File

- Location: `.claude/state/epic-progress-<epic-folder>.json` under the repository root.
  `-StatePath` overrides it.
- The state is never committed: `.claude/state/` is gitignored in this repository and the
  push-down adds it to a destination's `.gitignore`.
- The state is per checkout: a different worktree or `-RepositoryRoot` starts a separate
  history. Run from the same root, or pass `-StatePath`.
- `git clean -fdX` deletes it.
- A state file under the system temporary directory, written by an earlier version, is not
  migrated: pass its path once with `-StatePath`, or reset the baseline.
- The legacy format (a JSON array of samples) is still read. The current document is:

  ```json
  {
    "version": 1,
    "startUnixSeconds": 1767603600,
    "baselineDone": 0,
    "baselineWeeklyPct": 0,
    "samples": [ { "ts": 1767614400, "done": 3 } ]
  }
  ```

- Blank text, unparseable text, or a version other than 1 is read as empty state; a missing
  field is absent.
- The state is written when a sample is added, or when `-ResetBaseline` or `-PairSamples` is
  given. A run within 90 seconds of the last sample with neither switch writes nothing.

## Known Behaviors and Measured Rates

- Plan checkboxes tick at batch boundaries, so 5-minute interval velocity is bursty: 0 to
  about 150 tasks per hour, with an SD of about 30 to 45 around a mean near 26.
- Aggregate throughput with three or four features in parallel is about 25 to 30 tasks per
  hour. Per-feature pace is about 9 to 13 tasks per hour; a lone feature, including its review
  and PR tail, about 4.
- The wave-parallel estimate is unreliable for about two hours after a baseline: it swung
  between 35 and 110 hours in the first hour, and once estimated 26 to 30 hours for about 10
  active hours.
- Task totals drift when planners revise plans, so read the percentage against the live total.
- Flat stretches of 20 to 60 minutes are normal during review, PR, CI, and merge.
- The tail from plan complete to merge is 0.8 to 4 hours per feature, and each remediation
  cycle adds 45 to 90 minutes.
- Weekly quota burn is 3 to 7 points per hour (4.3 to 7.6 tasks per point).
- The hourly Full run also records a sample when it runs more than 90 seconds after the
  previous one. This adds a shorter interval about once an hour and raises the SD.
- A negative average (done below the baseline after a plan revision) makes the straight-line
  and wave-parallel estimates `n/a`, while the range can print negative or very large values.
- Integral velocities print without a decimal (`1`, not `1.0`).

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

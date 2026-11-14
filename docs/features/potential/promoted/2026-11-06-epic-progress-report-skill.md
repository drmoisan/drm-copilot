# epic-progress-report-skill (Issue #1093)

- Date captured: 2026-11-06
- Author: drmoisan
- Status: Promoted -> docs/features/active/epic-progress-report-skill/ (Issue #1093)

- Issue: #1093
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1093
- Last Updated: 2026-11-06
## Problem / Why

While running epic 1019 the coordinator posted two recurring reports that the owner specified in detail: a four-line TL;DR every few minutes and a fuller hourly status update with a push notification. The owner's instructions on what the reports contain and how every number is calculated existed only in a conversation and in a throwaway script. The script was lost twice (container restarts) and had to be recreated from the session transcript. Issue #1080 (merged as PR #1087) put the script in the repository as `scripts/dev-tools/Get-EpicProgressReport.ps1` with `Get-EpicProgressReport.Logic.ps1`. What is still missing is the procedure: the report specification, the calculation rules, the scheduling prompts, the baseline-reset and cadence-change handling, and a copy of the script that reaches destination repositories through the push-down. Create a skill that carries all of it, so any coordinator in any repository can start the same reports without the original conversation.

## Proposed Behavior

Add a user-invocable skill `epic-progress-report` at `.claude/skills/epic-progress-report/SKILL.md` that ships its PowerShell script the way `.claude/skills/cleanup-merged-worktrees` ships `scripts/` (skill folder, listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, with the bundle mirror and parity tests the repository already uses). The skill tells a coordinator how to: start the recurring reports for an epic, read them, reset the baseline after a pause or outage, change the cadence, and stop the reports. The script is the existing `Get-EpicProgressReport` tool from #1080, extended only where this issue says so.

### Report specification (owner's requirements)

The owner's instructions, quoted from the session:

- On what the periodic update must contain: "Which features have completed, which are running, what stage is each running item at, what is to come. How many total tasks in the epic. How many tasks are complete. What is that as a percentage. How much time has passed? Based on the completion velocity, how much time remains?"
- On delivery: the full update is an hourly update, delivered "as a message and push notification". "Weekly quota points is a good add."
- On the TL;DR: "I would like to see a TL/DR version" with exactly this content: `**TL;DR:** Epic #1019 is at 20 of 516 tasks (3.9%). None of the 11 features is done yet. #1020 is running (20 of 44).` / `**Elapsed:** 1 h 52 min, with about 34 hours left on the wave-parallel estimate. **Weekly** quota is at 10%.` / `**Avg Velocity:** ##.# tasks / hr. **Recent Velocity:** ##.# tasks / hr since last check-in.` / `**Estimated time remaining:** ##:## hrs to ##:## hrs`. "The range should come from taking the standard deviation of the recent velocity and adding 2.05 x that number to the average velocity." The TL;DR was first scheduled every 5 minutes, later changed to every 10 minutes.
- On baselines: "reset your velocity metrics based on when work was resumed here. All previous velocity measures should be discarded as irrelevant."
- On cadence change: "run the tldr checkins every 10 minutes instead of every 5 minutes. Please review the history and combine the task completion of 5 minute segments in pairs and recalculate the average and standard deviation."

The wording, order and punctuation of the TL;DR block and of the Full report in the merged `Get-EpicProgressReport.ps1` are the reference output; the skill must not change them.

### Calculation rules (as implemented by the recovered script and the merged tool)

- Task counts come from the plan checkboxes of each feature (`- [ ] [P#-T#]` and `- [x] [P#-T#]`), read from the feature's worktree when its branch has one, otherwise from the plan on the integration branch. The feature list, waves, bands and plan paths come from the epic kickoff table.
- Feature state: Completed when the epic checkpoint's `merge_status` is `merged` or `worktree_removed` or the feature PR is merged; Running when any task is done, the checkpoint status is past `not_started`, or a PR exists; otherwise Pending.
- Elapsed is measured from `-StartUtc`. Average velocity = (tasks done now - `-BaselineDone`) / elapsed hours since `-StartUtc`. Straight-line estimate = remaining tasks / average velocity.
- Wave-parallel estimate = (sum, over every wave that still has a non-completed feature, of the largest remaining task count among that wave's non-completed features) / average velocity + `WaveOverheadHours` (default 1.25) per open wave.
- Samples: a check-in sample (Unix epoch seconds, done count) is saved when at least 90 seconds have passed since the previous sample; the newest 14 are kept. Epoch seconds, not ISO strings, because `ConvertFrom-Json` turns ISO strings into local-time DateTime values and the samples then never matched.
- Interval velocity = max(0, change in done) / change in hours, for sample pairs at least 2 minutes apart. Recent velocity = the latest interval's value. SD = sample standard deviation (n-1) of the interval velocities, reported only with at least 3 intervals; the report also prints the interval count.
- Range: fast end = critical-path tasks / (average + 2.05 x SD) + overhead; slow end = critical-path tasks / (average - 2.05 x SD) + overhead. When average - 2.05 x SD is at or below 0.5 tasks per hour the slow end prints `no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`. Before 3 intervals exist the line prints the single estimate and `(range needs 3 or more check-in intervals)`. Hours print as `HH:MM`; elapsed prints as `N h MM min`.
- Weekly quota is the active `cswap list --json` account's seven-day percentage; `n/a` when `cswap` is missing or prints nothing parseable. The coordinator's policy (not the report's) is to stop and commit at 93 percent.
- Known behavior to document in the skill: plan checkboxes tick at batch boundaries, so interval velocity is bursty (0 to 150 tasks per hour with SD of 30 to 45); estimates are unreliable for about the first two hours after a baseline; task totals drift when a planner revises a plan; a flat stretch of 20 to 60 minutes is normal in review, PR and CI phases. Measured values from epic 1019 are recorded in the epic-orchestrator memory `epic-1019-velocity-history.md` (gitignored local memory; summarize the useful rates in the skill instead of linking to it).

### Scheduling prompts (the skill must carry these, parameterized)

The session-scoped scheduler (CronCreate) ran two jobs, which die when the session or container ends and expire after 7 days, so the skill must tell the coordinator to recreate them after any restart:

- Every 10 minutes (was 5), no push notification: "Run `pwsh -NoProfile -File <script> -Mode TLDR ...` and post its output verbatim as the TL;DR epic update (no push notification). Do not add commentary unless a run is blocked or a child has finished and needs relaying."
- Hourly at an off-peak minute (for example :07), full mode: "Run `pwsh -NoProfile -File <script> ...` (full mode) and post its output as the hourly epic update, then send a PushNotification with the TL;DR line (under 200 characters). Check `cswap list` for the weekly pool; stop and commit at 93%."

### Script changes this issue adds to the merged tool

- `-ResetBaseline` (or equivalent): clears the saved samples and records the new `-StartUtc` and `-BaselineDone`, for the "work resumed, discard earlier measures" case.
- `-PairSamples` (or equivalent): combines consecutive samples in pairs, newest first, so the interval doubles (5 to 10 minutes) and the average and SD are recomputed from the paired intervals; the earlier session's result was mean 26.2 and SD 31.5 from thirteen 5-minute intervals becoming mean 27.3 and SD 23.2 from six 10-minute intervals.
- A default state location that survives a container stop (the system temp directory did not), is never committed, and is documented; the choice and its trade-off are the implementer's to decide in research.
- Prints `n/a` instead of NaN before any task has completed.

## Acceptance Criteria (early draft)

- [ ] The skill exists at `.claude/skills/epic-progress-report/SKILL.md` with valid frontmatter, is invocable as `/epic-progress-report`, and documents: purpose, inputs, the exact TL;DR template, the Full report contents, every calculation rule above, the two scheduling prompts, the baseline reset, the cadence change with pairing, stopping the reports, and the known behaviors.
- [ ] The script is bundled with the skill following the repository's skill-with-scripts convention, listed in the pack manifest, and reaches a destination repository after a push-down; there is one source of truth with a parity test between any two copies (including the `scripts/dev-tools` copy from #1080, whose path and tests must keep working).
- [ ] The script supports the baseline reset, sample pairing and persistent state described above, with unit tests using fixed inputs (no temp files, no network, no wall clock): average, recent, SD with 2 and 3 or more intervals, the range and no-upper-bound wording, pairing arithmetic (including the 26.2/31.5 to 27.3/23.2 example), baseline reset, n/a handling, and both modes.
- [ ] A skill contract test checks the frontmatter, that every file the skill references exists, and that the manifest lists them.
- [ ] The TL;DR and Full outputs are byte-for-byte unchanged from the merged tool for the same inputs (regression test).
- [ ] No hard-coded epic, drive, host path, account name or token appears in the skill or script; the script remains read-only toward git and GitHub.
- [ ] Any repository documentation that enumerates skills or required checks is updated; the full toolchain, coverage threshold (85 percent lines for the new and changed PowerShell) and file-size limits pass.

## Constraints & Risks

- PowerShell only for the script and tests (no new Python). The skill body is Markdown. Public repository: no host paths, tokens or account names. The current `Get-EpicProgressReport.Logic.ps1` is 688 lines, near the 700-line advisory limit: split rather than grow it.
- Do not modify the `epic-run`, `epic-plan` or `epic-orchestrate` skills or their mirrors unless research shows a cross-reference is required; if so, say why and keep it to a single line.
- Push-down delivery follows the installed extension payload, so the skill reaches a destination repository only after the extension is rebuilt and reinstalled; state that in the skill's notes, not as an acceptance criterion.
- The owner's wording "adding 2.05 x that number to the average velocity" is implemented as average plus and minus 2.05 x SD (fast and slow ends). Keep that behavior, document it in the skill, and report it as an owner confirmation item in the final report rather than changing it.
- Metrics need a reset whenever work resumes after a pause; the skill must say so, because the original 9-hour Codespace outage distorted the averages until the owner asked for a reset.

## Test Conditions to Consider

- [ ] Unit coverage areas: pairing and reset arithmetic, interval and SD math from fixed samples, range formatting, baseline handling, the persistent state path, n/a cases.
- [ ] Integration scenarios: a TLDR and a Full run against mocked git, gh and cswap output; a push-down parity test for the skill's script copies and manifest entries.
- [ ] CLI/API examples: `pwsh -NoProfile -File <script> -EpicFolder documentation-estate-tooling -StartUtc 2026-11-04T13:55:00Z -BaselineDone 261 -Mode TLDR`.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/epic-progress-report-skill/` folder from the template

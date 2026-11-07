# epic-progress-report-skill — Spec

- **Issue:** #1093
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-06
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-feature
- **Branch:** feature/epic-progress-report-skill
- **Inputs:** `issue.md`, `docs/features/potential/promoted/2026-11-06-epic-progress-report-skill.md`, `research/research.2026-11-06.md` (decisions D1 to D8), the merged tool from issue #1080 (PR #1087) and its two Pester suites.

## Overview

While epic 1019 ran, the coordinator posted two recurring reports that the owner specified in detail: a four-line TL;DR every few minutes and an hourly full status update with a push notification. The specification of those reports, the calculation rules and the scheduling prompts existed only in a conversation and in a throwaway script that was lost twice on container restarts. Issue #1080 (PR #1087) placed the script in the repository as `scripts/dev-tools/Get-EpicProgressReport.ps1` with `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`.

What is still missing is the procedure and its delivery: the report specification, the calculation rules, the scheduling prompts, baseline reset after a pause, cadence change with sample pairing, stopping and recreating the scheduled jobs, a state file that survives a container stop, and a copy of the script that reaches destination repositories through the push-down. This feature adds a user-invocable skill, `/epic-progress-report`, that carries all of it, makes the skill folder the single source of truth for the script, and adds the script features the procedure needs (`-ResetBaseline`, `-PairSamples`, a persistent default state file).

## Scope

In scope:

- A Claude-only skill at `.claude/skills/epic-progress-report/SKILL.md` that documents purpose, prerequisites, inputs, report formats, calculation rules, starting the reports, scheduling prompts, baseline reset, cadence change, stopping the reports, recovery after a restart, the state file, known behaviors and measured rates, and notes.
- Moving the merged script into `.claude/skills/epic-progress-report/scripts/`, splitting the Logic file, and leaving a forwarder at `scripts/dev-tools/Get-EpicProgressReport.ps1`.
- Script additions: `-ResetBaseline`, `-PairSamples`, `-StartUtc` no longer mandatory, a versioned state document, and a persistent default state path.
- Bundle mirror, `core.json` entries, coverage-root configuration, relocated and new Pester suites.

## Non-Goals

- No change to the wording, order or punctuation of any TL;DR or Full output line (see `## Report Formats`).
- No change to the `epic-run`, `epic-plan` or `epic-orchestrate` skills, their agents, or any of their mirrors (D7).
- No `.agents/skills` or `.github/skills` copy of the new skill; the skill depends on Claude Code tools (`CronCreate`, `CronList`, `CronDelete`, `PushNotification`).
- No registration in `.claude/settings.json` `permissions.allow`.
- No migration of an existing state file under the system temporary directory.
- No new or edited Python file; the existing Python contract tests run unchanged.
- No change to the coordinator's quota policy; the 93 percent stop rule stays coordinator policy, and the commit-before-the-wall procedure stays in `.claude/skills/quota-throttling/SKILL.md`.
- No automatic scheduling by the script; scheduling is done by the coordinator with `CronCreate` as the skill describes.

## Decisions

The orchestrator settled the following decisions. They are recorded here as decided.

### DEC-1 (research D1): single source of truth and forwarder

- The canonical entry and Logic files move with `git mv` from `scripts/dev-tools/` to `.claude/skills/epic-progress-report/scripts/`.
- `scripts/dev-tools/Get-EpicProgressReport.ps1` becomes a thin forwarder with comment-based help (synopsis states that it forwards and names the canonical path; it tells readers to dot-source the canonical file, not the forwarder). It has no `param()` block. Its executable statements are, in this order (settled by the OQ-1 probes):

  ```powershell
  $ErrorActionPreference = 'Stop'
  $global:LASTEXITCODE = 0
  & (Join-Path -Path $PSScriptRoot -ChildPath '../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1') @args
  if ($?) { exit 0 }
  exit $(if ($LASTEXITCODE) { $LASTEXITCODE } else { 1 })
  ```

- Rationale: logic exists once in the repository; the forwarder cannot drift from the canonical parameter surface because it declares none. The orchestrator confirmed by test that `@args` forwards named parameters and switches under `pwsh -File`, and that a forwarder without an explicit exit exits 0 when the target exits non-zero. A trailing `exit $LASTEXITCODE` alone is not used: it returns a leftover non-zero native exit code (for example from a failed `git show` of a missing plan) after a run that printed a report, and it returns 0 for a parameter-binding failure. The settled statements make a binding failure terminating (exit 1), return 0 after a successful run whatever native exit code is left over, and propagate an explicit non-zero exit of the target; each outcome is tested.
- `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` is removed from `scripts/dev-tools/` by the move. Outside `docs/features/**` (historical records of issues #1080 and #1093), the only references to it are the merged entry script and the two #1080 Pester suites, all of which move or are rewritten by this feature. No other production file, configuration file or manifest references it.
- The bundle mirror of the skill folder is the only byte copy of the scripts. It is pinned by the existing push-down contract tests and by the new skill contract test.
- `config/poshqc-coverage.json` currently lists the roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.github/hooks`, `.codex/scripts` and `scripts`; `.claude/skills` is absent. It is added so the canonical files are measured (Coverage Exclusion Policy).
- Alternatives rejected (research D1): byte-identical copies with a parity test (logic twice, every test run twice); a forwarder with a duplicated `param()` block (parameter surface twice); removing the `scripts/dev-tools` path (the requirement keeps it working); invoking `scripts/dev-tools` from the skill (`scripts/**` is not published, so the skill-bundle guard reports `not-in-bundle`).

### DEC-2: test suites move with the production files

- The two #1080 suites move to `tests/scripts/claude-skills/epic-progress-report/`, which mirrors the new production path as required by `.claude/rules/general-unit-test.md`.
- Every existing test case (`It` block) is preserved under its existing name. Only the assertions the research names as dependent on the move change, each for its stated reason (see `## Test Inventory`).
- A new forwarder suite stays at `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`, mirroring the forwarder's path.

### DEC-3 (research D3): persistent default state location

- Default state file: `<repository root>/.claude/state/epic-progress-<EpicFolder>.json`, built with `Join-Path`. `-StatePath` overrides it.
- The state file is a versioned JSON object (see `## State File Format`). The legacy JSON array of samples written by the merged tool is still read. An existing state file under the system temporary directory is not migrated.
- Rationale: `.claude/state/` is already gitignored in this repository, the push-down merges `.claude/state/` into a destination `.gitignore`, and the bundle contract exempts `.claude/state/**`; the location survives a container stop wherever the checkout persists. The system temporary directory did not survive (observed loss). `artifacts/` was rejected because it is the orchestration area and is not guaranteed to be gitignored in a destination.
- Trade-offs, documented in the skill: the state is per checkout, so a different worktree or `-RepositoryRoot` starts a separate history (run from the same root or pass `-StatePath`); `git clean -fdX` deletes it.

### DEC-4 (research D4): script additions

See `## Script Additions`. The parameter surface after the change is the thirteen merged parameters plus `-ResetBaseline` and `-PairSamples`; `-StartUtc` is no longer mandatory.

### DEC-5 (research D5): Logic split

- `Get-EpicProgressReport.Logic.ps1` is split into a hub plus `Get-EpicProgressReport.State.ps1`, `Get-EpicProgressReport.Metrics.ps1` and `Get-EpicProgressReport.Render.ps1`. The hub dot-sources the three files with the named form `Join-Path -Path $PSScriptRoot -ChildPath '<file>'`, so every consumer that dot-sources the hub receives every function, and the push-down dependency-closure scan recognizes each dependency.
- Moved functions are moved verbatim. `Resolve-EpicProgressSetting` moves from the entry script to the State file with `-TempRoot` removed and the new default state path.
- Every production and test file in scope stays below 700 lines; 500 lines is the target.

| File (in `.claude/skills/epic-progress-report/scripts/`) | Functions |
|---|---|
| `Get-EpicProgressReport.Logic.ps1` (hub, moved and trimmed) | dot-sources of State, Metrics, Render; `Test-EpicProgressJsonText`, `ConvertFrom-EpicProgressKickoffRow`, `Get-EpicProgressIssueFromKickoff`, `ConvertFrom-EpicProgressWorktreeList`, `ConvertFrom-EpicProgressPrList`, `Get-EpicProgressWeeklyQuota`, `Get-EpicProgressTaskCount`, `Get-EpicProgressCurrentPhase`, `Get-EpicProgressFeatureState` |
| `Get-EpicProgressReport.State.ps1` (new) | `Resolve-EpicProgressSetting` (moved from the entry script), `Select-EpicProgressSample` (moved), new `ConvertFrom-EpicProgressStateText`, `ConvertTo-EpicProgressStateJson`, `Resolve-EpicProgressBaseline`, `Merge-EpicProgressSamplePair` |
| `Get-EpicProgressReport.Metrics.ps1` (new) | `Format-EpicProgressHour`, `Format-EpicProgressClock`, `Format-EpicProgressNumber`, `Get-EpicProgressAverageVelocity`, `Get-EpicProgressRecentVelocityInterval`, `Get-EpicProgressStandardDeviation`, `Get-EpicProgressCriticalPath`, `Get-EpicProgressRangeText`, `Get-EpicProgressWeeklyText` (all moved) |
| `Get-EpicProgressReport.Render.ps1` (new) | `Get-EpicProgressSummary`, `Get-EpicProgressTldrLine`, `Get-EpicProgressFullLine` (all moved) |
| `Get-EpicProgressReport.ps1` (entry, moved) | I/O seams, `Invoke-EpicProgressReport`, entry block |

### DEC-6: zero-velocity range with three or more intervals

The orchestrator confirmed that PowerShell 7 returns positive infinity, not an error, for a `[double]` divided by zero. With three or more intervals, average velocity 0 and SD 0, the merged `Get-EpicProgressRangeText` computes a fast end of infinity (printed `n/a` by `Format-EpicProgressClock`) and a slow velocity of 0 (at or below 0.5), so the line reads `n/a hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`. This is the merged rule's output and is kept; no guard is added. A new Metrics test covers the path.

### DEC-7: pairing example values

Tests use the recorded 14-sample fixture from the research. The expected values are the recomputed ones: mean 26.2 and SD 31.4 for the thirteen 5-minute intervals; mean 27.3 and SD 23.2 for the six paired 10-minute intervals. The skill states the recomputed 31.4 and notes that the conversation quoted 31.5.

### DEC-8 (research D7): no change to the epic skills

No cross-reference is added to `epic-run`, `epic-plan` or `epic-orchestrate`, their agents or mirrors. `epic-orchestrate` and the epic-orchestrator agent are hash-pinned by the frozen-surface expectations, and each one-line addition would touch the skill, its mirrors and the Codex generator check for no functional gain. The skill is discoverable as `/epic-progress-report`.

### DEC-9 (research D8): range formula

The merged rule, average velocity plus and minus 2.05 SD, is kept and documented in the skill. The fast end uses `average + 2.05 x SD`; the slow end uses `average - 2.05 x SD`. The range applies to the wave-parallel critical path, not to the straight-line estimate. The owner's "adding" wording is listed under `## Owner Confirmation Items`.

### DEC-10: CHANGELOG

`extensions/drm-copilot/CHANGELOG.md` records notable extension changes under `## [Unreleased]`, including a core pack contents entry (issue #984), but no test or rule requires an entry for a new bundled skill and no prior skill addition is recorded there. The planner verifies the convention; if it applies, an `### Added` entry is written. It is not an acceptance criterion.

### DEC-11: CI verification

The live required check on `main` is the single context `CI Required Gate` (ruleset 15241672, read 2026-11-06). Every CI-dependent criterion is verified on the PR head by the `CI Required Gate` and the full-run jobs it aggregates.

## Owner Confirmation Items

These are not acceptance criteria. The skill and script implement the stated default for each, and the final report lists each for owner confirmation.

1. Range formula: implemented as average velocity plus and minus 2.05 SD (fast and slow ends). The owner's wording was "adding 2.05 x that number to the average velocity", which describes only the fast end.
2. SD of the 5-minute pairing example: the recorded samples give SD 31.4 (unrounded 31.4495); the conversation quoted 31.5. The skill states 31.4 and notes the quoted 31.5. Mean 26.2, paired mean 27.3 and paired SD 23.2 reproduce.
3. Push-notification text: the first TL;DR output line with every `**` removed; when that text is 200 characters or longer, the running-features sentence is dropped. The remaining text (prefix, task counts, percentage and done-sentence) is well under 200 characters.
4. `-ResetBaseline` leaves the weekly-quota baseline unchanged (passed value, else stored value, else 0), so the Full line's "points since the epic started" stays accurate.
5. The hourly Full run also records a check-in sample when it runs more than 90 seconds after the previous sample. This adds a shorter interval roughly once an hour and raises the SD. The two specified jobs are kept and the effect is documented in the skill.

## Report Formats

The merged tool's output is the reference; this feature does not change any output-producing code. The literal string expressions below are quoted unchanged from `Get-EpicProgressTldrLine`, `Get-EpicProgressFullLine` and `Get-EpicProgressRangeText` of the merged Logic file.

### TL;DR (both modes print it first)

```text
"**TL;DR:** Epic #$($Summary.EpicIssue) is at $($Summary.Done) of $($Summary.Total) tasks ($percent%). $doneSentence $runSentence"
"**Elapsed:** $(Format-EpicProgressHour -Hours $Summary.ElapsedHours), with about $hoursLeft hours left on the wave-parallel estimate. **Weekly** quota is at $weekly."
"**Avg Velocity:** $velocity tasks / hr. **Recent Velocity:** $recent tasks / hr since last check-in. (SD of recent velocity: $deviation, from $($Summary.IntervalCount) intervals)"
"**Estimated time remaining:** $($Summary.RangeText)"
```

Rendered template for the skill (placeholders in angle brackets):

```text
**TL;DR:** Epic #<issue> is at <done> of <total> tasks (<pct>%). <done-sentence> <running-sentence>
**Elapsed:** <H h MM min>, with about <hours> hours left on the wave-parallel estimate. **Weekly** quota is at <weekly>.
**Avg Velocity:** <avg> tasks / hr. **Recent Velocity:** <recent> tasks / hr since last check-in. (SD of recent velocity: <sd>, from <n> intervals)
**Estimated time remaining:** <range>
```

Variants:

- done-sentence: `None of the <N> features is done yet.` or `<K> of <N> features are done.`
- running-sentence: `No feature is running.`, `#<i> is running (<d> of <t>).`, or `#<a> (<d> of <t>), #<b> (<d> of <t>) are running.`
- range: `<HH:MM> hrs (range needs 3 or more check-in intervals)`, `<HH:MM> hrs to <HH:MM> hrs`, or `<HH:MM> hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`.
- `<pct>`, `<avg>`, `<recent>`, `<sd>` are rounded to one decimal, `<hours>` to zero decimals, all with invariant culture and default (to-even) rounding; an integral value prints without a decimal (for example `1`, not `1.0`). `<weekly>` is `<value>%` or `n/a`.
- Any non-finite value prints `n/a`.

The merged output adds the SD clause to the velocity line and prints integral values without a decimal; both differ from the owner's first draft, and the merged tool is the reference.

### Full (Full mode prints the TL;DR lines, then these lines)

```text
''
"## Epic #$($Summary.EpicIssue) $($Summary.EpicName): status at $($Summary.NowUtc.ToString('HH:mm', $culture)) UTC, $($Summary.NowUtc.ToString('MMM d', $culture))"
''
"**Elapsed:** $(Format-EpicProgressHour -Hours $Summary.ElapsedHours) since $($Summary.StartUtc.ToString('HH:mm', $culture)) UTC. **Progress:** $($Summary.Done) of $($Summary.Total) tasks complete, **$percent%**."
''
'| State | Features |'
'|---|---|'
"| Completed | $completedText |"
"| Running | #$($record.Issue) (wave $($record.Wave), $($record.Band)): $($record.Done) of $($record.Total) tasks ($share%).$phase$pullRequest |"
"| Pending, wave $($group.Name) | " + (... "#$($_.Issue) ($($_.Total))" ... -join ', ') + ' |'
''
'| Wave | Children | Tasks | Done |'
'|---|---|---|---|'
"| $($group.Name) | $($group.Count) | $waveTotal | $waveDone |"
"| **Total** | **$($Summary.Feature.Count)** | **$($Summary.Total)** | **$($Summary.Done)** |"
''
"**Velocity:** $(Format-EpicProgressNumber -Value $Summary.Velocity -Digits 1) tasks per hour (one child's pace). **Remaining:** $($Summary.Remaining) tasks."
"- Straight line, no parallelism: about $(Format-EpicProgressHour -Hours $Summary.StraightHours) (upper bound)."
"- Wave-parallel (longest chain $($Summary.CriticalPath.Tasks) tasks plus about $overhead h per open wave for review and CI): about **$(Format-EpicProgressHour -Hours $Summary.CriticalPath.Hours)**."
"**Weekly quota (active account):** $(Get-EpicProgressWeeklyText -Value $Summary.WeeklyPct) used, $delta points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone."
```

Contents and rules:

- `$completedText` is `None yet` or the completed issues as `#<i>` joined with `, `.
- One `Running` row per running feature; `$phase` is ` Now at: <phase>.` when a current phase exists, else empty; `$pullRequest` is ` PR <state>.` when a PR state exists, else empty; `$share` is the feature percentage rounded to zero decimals.
- One `Pending, wave <w>` row per wave that holds pending features, in ascending wave order.
- One Wave-table row per wave in ascending order, then the bold Total row.
- `$overhead` is `WaveOverheadHours` unrounded. `$delta` is the weekly delta (`WeeklyPct - BaselineWeeklyPct`) with a leading `+` when finite and non-negative, else `n/a`.
- Times use invariant culture.

## Calculation Rules

As implemented by the merged tool; the skill restates each rule.

- Task counts: plan checkboxes `- [ ] [P#-T#]` and `- [x] [P#-T#]` of each feature, read from the feature's worktree when its branch has one, otherwise from the plan on the integration branch. The feature list, waves, bands and plan paths come from the feature-summary table of the epic kickoff.
- Feature state: Completed when the epic checkpoint's `merge_status` is `merged` or `worktree_removed`, or the feature PR is merged; Running when any task is done, the checkpoint status is past `not_started`, or a PR exists; otherwise Pending.
- Elapsed: from the start instant to now, clamped at 0; printed as `N h MM min` from rounded total minutes.
- Average velocity: (done now - baseline done) / elapsed hours; 0 when elapsed is not above 0.
- Straight-line estimate: remaining tasks / average velocity; `n/a` when the average is not above 0.
- Wave-parallel estimate: (sum, over every wave with a non-completed feature, of the largest remaining task count among that wave's non-completed features) / average velocity + `WaveOverheadHours` (default 1.25) per open wave; `n/a` when the average is not above 0.
- Samples: a check-in sample (Unix epoch seconds, done count) is added when there is no previous sample or the previous one is at least 90 seconds old; the newest `SampleCap` (default 14) are kept. Epoch seconds are used because `ConvertFrom-Json` converts ISO strings into local-time `DateTime` values.
- Interval velocity: max(0, change in done) / change in hours, for consecutive samples at least 2 minutes apart; closer pairs are skipped.
- Recent velocity: the latest interval's value; `n/a` without intervals.
- SD: sample standard deviation (n-1 denominator) of the interval velocities; `n/a` below 3 intervals. The report prints the interval count.
- Range: below 3 intervals, `<wave-parallel HH:MM> hrs (range needs 3 or more check-in intervals)`. Otherwise fast end = critical-path tasks / (average + 2.05 x SD) + overhead; slow velocity = average - 2.05 x SD; when the slow velocity is above 0.5 tasks per hour the slow end = critical-path tasks / slow velocity + overhead, else the slow end prints `no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`. Hours print as `HH:MM`.
- Weekly quota: the seven-day percentage of the active account in `cswap list --json`; `n/a` when `cswap` is missing or prints nothing parseable.
- `n/a`: every printed number passes through a formatter that returns `n/a` for NaN or infinity.

## Script Additions

Parameter surface (canonical entry): `EpicFolder` (mandatory), `StartUtc`, `EpicIssue`, `IntegrationBranch`, `KickoffPath`, `RepositoryRoot`, `CheckpointPath`, `StatePath`, `BaselineDone`, `BaselineWeeklyPct`, `WaveOverheadHours`, `SampleCap`, `Mode`, `ResetBaseline`, `PairSamples`. Types and defaults of the merged parameters are unchanged except that `StartUtc` is no longer mandatory and the `StatePath` default changes (DEC-3). Whether a value was passed is read from `$PSBoundParameters.ContainsKey(...)`.

| Parameter | Type | Semantics |
|---|---|---|
| `-StartUtc` | `[datetime]`, optional | Start instant. Resolution: the passed value, else (with `-ResetBaseline`) now from the clock seam, else the stored value. With none of these the run stops with a terminating error that names `-StartUtc` and `-ResetBaseline`, raised before any git call. |
| `-BaselineDone` | `[int]` | Resolution: the passed value, else (with `-ResetBaseline`) the current done count, else the stored value, else 0. |
| `-BaselineWeeklyPct` | `[double]` | Resolution: the passed value, else the stored value, else 0. Not captured by `-ResetBaseline` (owner item 4). |
| `-StatePath` | `[string]` | Default `<repository root>/.claude/state/epic-progress-<EpicFolder>.json`. |
| `-ResetBaseline` | `[switch]` | Discards every stored sample, resolves the baseline as above, applies the normal sample rule (which adds the first sample `(now, done)`), and writes the state. The first reports after a reset show `0 h 00 min` elapsed and `n/a` estimates. |
| `-PairSamples` | `[switch]` | Applied after the normal sample rule. Keeps the newest sample and every second older sample (indices n-1, n-3, ...). With k intervals the result has floor(k/2) intervals, each spanning two original intervals; when k is odd the oldest interval is discarded. 14 samples become 7; 13 become 7; 2 become 1; 1 and 0 are unchanged. It rewrites the stored samples and is not idempotent: each application doubles the spacing again, so applying it twice to 14 samples leaves 4. It is a one-shot command and never appears in a scheduled prompt. |

Further rules:

- `-ResetBaseline` and `-PairSamples` in the same run raise a terminating error before any I/O.
- The state file is read before the first git call.
- A passed baseline value overrides a stored one and is persisted with the next write.
- Write rule: the state is written when the sample rule added a sample, or when `-ResetBaseline` or `-PairSamples` was given. A run within 90 seconds of the last sample with neither switch writes nothing (merged behavior).
- `Write-EpicProgressState` creates the `.claude/state` directory when missing, inside its `ShouldProcess` block. It remains the only function that writes a file.
- `n/a` instead of NaN before any task has completed: already met by the merged tool; this feature adds regression tests.
- The canonical entry block keeps the dot-source guard (`$MyInvocation.InvocationName -ne '.'`) and runs from the repository root.

Examples (fictional values):

```text
pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -BaselineDone 40 -Mode TLDR
pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -ResetBaseline
pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder example-epic -PairSamples -Mode TLDR
```

## State File Format

Written by `ConvertTo-EpicProgressStateJson`:

```json
{
  "version": 1,
  "startUnixSeconds": 1767603600,
  "baselineDone": 0,
  "baselineWeeklyPct": 0,
  "samples": [ { "ts": 1767614400, "done": 3 } ]
}
```

- `startUnixSeconds` and `ts` are integer Unix epoch seconds.
- `ConvertFrom-EpicProgressStateText` (pure) accepts the legacy JSON array (samples only, no baseline), the version-1 object, and blank or unparseable text (empty state). A version other than 1 is treated as unparseable. Missing fields in a version-1 object are treated as absent.
- The file is never committed: `.claude/state/` is in `.gitignore` here and is merged into a destination `.gitignore` by the push-down.

## Skill Content

Frontmatter: `name: epic-progress-report`; a single-quoted `description` stating what the skill does and when to use it; `argument-hint`; `allowed-tools` with `Read`, `Glob`, `Bash(pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 *)`, `Bash(cswap list*)`, `CronCreate`, `CronList`, `CronDelete`, `PushNotification`. No `context: fork` (the jobs and notifications belong to the coordinator's main session) and no `user-invocable: false`, so the skill is invocable as `/epic-progress-report`.

Required sections (headings as listed): `# Epic Progress Report`, `## When to Use This Skill`, `## Prerequisites`, `## Inputs`, `## Report Formats`, `## Calculation Rules`, `## Starting the Reports`, `## Scheduling Prompts`, `## Resetting the Baseline After a Pause`, `## Changing the Cadence`, `## Stopping the Reports`, `## After a Restart`, `## State File`, `## Known Behaviors and Measured Rates`, `## Notes`.

Content requirements:

- Prerequisites: PowerShell 7 and `git`; optional `gh` and `cswap` (without them the PR state is empty and the quota prints `n/a`); the kickoff at `docs/features/epics/<epic-folder>/epic-kickoff.md` on `origin/epic/<epic-folder>-integration` with a feature-summary table and an `Epic issue: #<n>` line (or `-EpicIssue`); the epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json`; run from the repository root in the coordinator's main session (an agent-isolated worktree refuses command text containing `pwsh`).
- Inputs: one row per parameter with its default, including the new state default and both switches.
- Report Formats and Calculation Rules: as in this spec, with fictional values (epic folder `example-epic`, epic issue `42`); the owner's example values are not restated.
- Starting the Reports: one first run (with `-StartUtc` and `-BaselineDone`, or `-ResetBaseline` to start from now), then the two `CronCreate` jobs.
- Scheduling Prompts, parameterized by `<epic-folder>`:
  - TL;DR job, cron `*/10 * * * *`, recurring: "Run `pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder <epic-folder> -Mode TLDR` from the repository root and post its output verbatim as the TL;DR epic update (no push notification). Do not add commentary unless a run is blocked or a child has finished and needs relaying."
  - Hourly job, cron `7 * * * *`, recurring: "Run `pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder <epic-folder>` (full mode) from the repository root and post its output as the hourly epic update, then send a PushNotification with the TL;DR line (under 200 characters). Check `cswap list` for the weekly pool; stop and commit at 93%."
  - The push-notification text rule (owner item 3).
  - Notes: prompts omit `-StartUtc`, `-BaselineDone`, `-ResetBaseline` and `-PairSamples` (the baseline is read from state, so a reset is never overridden by a stale scheduled argument); cron times are local time; jitter delays a 10-minute job by a constant 0 to 5 minutes and an hourly job by a constant 0 to 30 minutes.
- Resetting the Baseline After a Pause: whenever work resumes after a pause or outage, run once with `-ResetBaseline` (with `-StartUtc` and `-BaselineDone` when the resume instant is in the past); earlier measures are discarded; the scheduled prompts are not changed; estimates are unreliable for about two hours afterwards. The skill states why: a 9-hour outage distorted the averages until a reset.
- Changing the Cadence: run once with `-PairSamples`, then delete the TL;DR job with `CronDelete` and recreate it at the new interval; never put `-PairSamples` in a prompt. Worked example from the recorded samples: mean 26.2 and SD 31.4 from thirteen 5-minute intervals become mean 27.3 and SD 23.2 from six 10-minute intervals; the conversation quoted 31.5 for the 5-minute SD.
- Stopping the Reports: `CronList`, then `CronDelete` for each report job ID; the state file may be kept for a later restart or deleted.
- After a Restart: `CronCreate` jobs are session-only; they fire only while the session runs and is idle, and a missed run fires once; `claude --resume` or `--continue` restores jobs that have not expired; recurring jobs expire 7 days after creation; run `CronList` and recreate only missing jobs, and recreate both before the 7-day expiry; if work paused during the restart, reset the baseline first; the state file survives under `.claude/state/`.
- State File: location, override, never committed, per-checkout trade-offs, `git clean -fdX` deletes it, no migration of a temporary-directory file (pass `-StatePath` to it once, or reset), the document format.
- Known Behaviors and Measured Rates (no epic number or folder name): plan checkboxes tick at batch boundaries, so 5-minute interval velocity is bursty (0 to about 150 tasks per hour, SD about 30 to 45 around a mean near 26); aggregate throughput with three or four features in parallel is about 25 to 30 tasks per hour; per-feature pace about 9 to 13 tasks per hour, a lone feature including its review and PR tail about 4; the wave-parallel estimate is unreliable for about two hours after a baseline (it swung between 35 and 110 hours in the first hour, and once estimated 26 to 30 hours for about 10 active hours); task totals drift when planners revise plans, so read the percentage against the live total; flat stretches of 20 to 60 minutes are normal at review, PR, CI and merge; the tail from plan complete to merge is 0.8 to 4 hours per feature, and each remediation cycle adds 45 to 90 minutes; weekly quota burn is 3 to 7 points per hour (4.3 to 7.6 tasks per point); the hourly Full run adds a shorter interval when it runs more than 90 seconds after the last sample, which raises the SD (owner item 5); a negative average (done below baseline after a plan revision) makes the straight-line and wave-parallel estimates `n/a` while a range can print negative or very large values; integral velocities print without a decimal.
- Notes: push-down delivery serves the installed extension payload, so the skill reaches a destination only after the extension is rebuilt and reinstalled; the 93 percent stop is coordinator policy and `.claude/skills/quota-throttling/SKILL.md` governs the commit-before-the-wall procedure; the tool is read-only toward git and GitHub; `scripts/dev-tools/Get-EpicProgressReport.ps1` in this repository forwards to the canonical script.
- Text constraints: no epic number, epic folder name, host path, drive letter, account name or token; the only script invocation form is the canonical path; no `TaskMaster` or `No-COM`; under 500 lines.

## File Inventory

| Path | Action |
|---|---|
| `.claude/skills/epic-progress-report/SKILL.md` | Create |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | `git mv` from `scripts/dev-tools/`, then edit (D4 wiring, help, `Resolve-EpicProgressSetting` moved out, examples use the canonical path) |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` | `git mv` from `scripts/dev-tools/`, then trim to the hub |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | Create |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1` | Create (moved functions) |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | Create (moved functions) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/SKILL.md` | Create (byte copy) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/` (entry, Logic, State, Metrics, Render) | Create (byte copies, written after the final format stage) |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Modify: add the `SKILL.md` and each script, next to the `cleanup-merged-worktrees` entries |
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | Recreate as the forwarder after the `git mv` |
| `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | Removed (moved) |
| `config/poshqc-coverage.json` | Modify: add root `.claude/skills` |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | `git mv` to `tests/scripts/claude-skills/epic-progress-report/`, then split |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | `git mv` to `tests/scripts/claude-skills/epic-progress-report/`; a new forwarder suite is created at the old path |
| `tests/scripts/claude-skills/epic-progress-report/` (State, Metrics, Render, SkillContract suites) | Create |
| `extensions/drm-copilot/CHANGELOG.md` | Planner verifies the convention (DEC-10) |
| `.gitignore` | No change (`.claude/state/` already ignored) |
| `epic-run`, `epic-plan`, `epic-orchestrate` skills, agents and mirrors; `.agents/skills`; `.github/skills`; `.claude/settings.json`; the `execution-environment` brief and its copies | No change |
| Any Python file | No change |

## Test Inventory

Existing suites (moved to `tests/scripts/claude-skills/epic-progress-report/`; every `It` name preserved):

| Test or Describe | Disposition and reason |
|---|---|
| Kickoff, issue, worktree, PR, weekly-quota, task-count, phase and feature-state `Describe` blocks | Stay in the Logic suite; unchanged |
| `Format-EpicProgressHour, Format-EpicProgressClock, and Format-EpicProgressNumber`, `Get-EpicProgressAverageVelocity`, `Get-EpicProgressRecentVelocityInterval`, `Get-EpicProgressStandardDeviation`, `Get-EpicProgressCriticalPath`, `Get-EpicProgressRangeText` | Move unchanged to the Metrics suite |
| `Select-EpicProgressSample` | Moves unchanged to the State suite |
| `Get-EpicProgressSummary, Get-EpicProgressTldrLine, and Get-EpicProgressFullLine` (includes `composes the four TL;DR lines`, `composes the Full lines in recovered order`) | Moves unchanged to the Render suite; golden regression anchors |
| `Resolve-EpicProgressSetting` Describe | Moves to the State suite; `-TempRoot` removed from every call because the parameter no longer exists; `defaults the state path under the temporary root and outside the repository` is replaced by `defaults the state path under .claude/state of the repository root` because DEC-3 changes the default; the other cases keep their assertions |
| `reads the raw text of an existing file` | Matches `function Invoke-EpicProgressReport` instead of `function Resolve-EpicProgressSetting`, because the latter moves out of the entry script |
| `treats an unparseable state file as empty` | Asserts `samples.Count` of the written object is 1, because the written state is now an object |
| `writes only the state file at -StatePath` | Reads `samples[0].ts` and `samples[0].done` and asserts `startUnixSeconds` and `baselineDone` are persisted, because of the new state format |
| `confines file writes to Write-EpicProgressState` | Scans all five canonical files and allows `Set-Content` and `New-Item`, both inside `Write-EpicProgressState`, because of the split and directory creation |
| `confines native commands to their wrappers` | Scans all five canonical files (because of the split); the native command set is unchanged |
| `contains no recovered hardcoded value` | Scans the five canonical files, the forwarder and `SKILL.md` |
| `documents every parameter in comment-based help` | Reads the canonical entry; the expected set gains `ResetBaseline` and `PairSamples` |
| `carries at least one example` | Reads the canonical entry; assertion unchanged |
| All other entry-script tests (`warns when git fetch fails`, both golden mode tests, PR, cswap, gh, git-argument and 90-second tests) | Unchanged assertions; the explicit `-StartUtc` stays in the fixture |

New tests:

- State suite: `ConvertFrom-EpicProgressStateText` (legacy array, version-1 object, blank, unparseable, unknown version, missing fields); `ConvertTo-EpicProgressStateJson` round trip with integer epoch seconds; `Resolve-EpicProgressBaseline` (passed values win, stored values used, reset defaults to now and current done, reset keeps a passed start, missing start without reset throws, weekly baseline not captured on reset); `Merge-EpicProgressSamplePair` (14 to 7 keeps s13, s11, s9, s7, s5, s3, s1; 13 to 7; 2 to 1; 1 and 0 unchanged; twice on 14 leaves 4; the recorded fixture gives mean 26.1875 and SD 31.4495 before and mean 27.3430 and SD 23.2316 after, each within 0.001, printing `26.2`, `31.4`, `27.3`, `23.2` through `Format-EpicProgressNumber -Digits 1`).
- Metrics suite: three or more zero-rate intervals with average 0 and SD 0 give `n/a hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`; SD is NaN with exactly 2 intervals and finite with 3 or more.
- Render suite: before-first-task scenario (done equals baseline, elapsed above 0, zero-rate samples) produces no `NaN` or `Infinity` substring in TL;DR or Full lines.
- Entry suite additions: `-ResetBaseline` clears samples and writes the resolved baseline; `-PairSamples` rewrites the stored samples; both switches together throw before any git call; no `-StartUtc` and no stored start throws before any git call; no `-StartUtc` with a stored start uses it (golden TL;DR); a Full-mode golden through `Invoke-EpicProgressReport` with a legacy four-sample state (bounded range), whose expected lines are captured from the merged tool before any edit and recorded under `evidence/baseline/`; both modes with mocked git, gh and cswap.
- Forwarder suite (`tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`): target file exists; the forwarder's AST holds no `param()` block and the settled statement sequence (`$ErrorActionPreference = 'Stop'`, `$global:LASTEXITCODE = 0`, one invocation of the canonical path with `@args`, `if ($?) { exit 0 }`, and the final exit of the target's non-zero code or 1); in process, against the committed stub target `tests/fixtures/dev-tools/Get-EpicProgressReport.ForwarderTarget.Fixture.ps1` reached through a `Join-Path` mock, a normal run exits 0, a run that leaves a failed native exit code exits 0, an explicit `exit 3` propagates as 3, and a target parameter-validation error is raised; in a child process (`-NoProfile -File` with the current PowerShell executable) against the real canonical entry, `-SampleCap 0` exits 1 with the canonical `ValidateRange` error naming `SampleCap` and `-Mode Bogus` exits 1 with the canonical `ValidateSet` error naming `Mode`, both before any git call or file write.
- Skill contract suite (`EpicProgressReport.SkillContract.Tests.ps1`): frontmatter; required headings; required literal fragments; every `.claude/skills/epic-progress-report/` path named in the skill exists; every skill-folder file is listed exactly once in `core.json` and exists byte-identically in the bundle; no `scripts/dev-tools` invocation; no forbidden token; the scheduling prompts contain none of `-StartUtc`, `-BaselineDone`, `-ResetBaseline`, `-PairSamples`.

All tests use fixed inputs and injected seams (`Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Test-EpicProgressCommand`, `Test-EpicProgressPath`, `Read-EpicProgressFile`, `Write-EpicProgressState`, `Get-EpicProgressUtcNow`, `Get-EpicProgressLastExitCode`): no temporary files, no network, no wall-clock reads.

Python contract tests that run unchanged and must pass: `test_every_skill_script_reference_is_bundled`, `test_every_skill_folder_file_is_carried_by_skill_packs`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`, `test_scanned_source_floor`, and the scans in `test_push_down_issue_824_follow_ups.py`.

## Constraints

- PowerShell 7 only for the script and tests; no new or edited Python. The skill body is Markdown.
- No hard-coded epic number, epic folder name, host path, drive letter, account name or token in the skill, the canonical scripts or the forwarder. All paths are built with `Join-Path`; fixtures use no drive letter or backslash literal and use fixed epoch timestamps.
- The script stays read-only toward git and GitHub: it runs only `git fetch`, `git show`, `git worktree list` and `gh pr list`, plus `cswap list --json`, and writes only the state file.
- File size: every production and test file in scope stays below 700 lines (500 preferred), measured as a physical line count.
- Public repository: no host data, tokens or account names in any artifact.
- Coverage: at least 85 percent line coverage for each new or changed PowerShell production file (the five canonical files and the forwarder). Branch coverage does not apply to PowerShell.
- Push-down delivery follows the installed extension payload; a repository-side change reaches a destination only after rebuild and reinstall. This is documented in the skill, not tested.

## Risks

| ID | Risk | Mitigation |
|---|---|---|
| R1 | A stale native exit code: after a successful report, `$LASTEXITCODE` holds the last native exit code from git, gh or cswap (for example a failed `git show` of a missing plan), so a forwarder ending in `exit $LASTEXITCODE` could return non-zero for a run that printed a report. A parameter-binding failure inside `& ... @args` may be statement-terminating, leaving `$LASTEXITCODE` unset so that such a forwarder exits 0. | Settled (OQ-1): both cases were confirmed by probe. The forwarder sets `$ErrorActionPreference = 'Stop'` (a binding failure is terminating, exit 1), resets `$global:LASTEXITCODE` to 0, exits 0 when the invocation succeeded (`$?`), and otherwise exits with the target's non-zero exit code or 1. The canonical entry block is unchanged. The forwarder suite asserts all four outcomes. |
| R2 | Golden drift from the split. | Functions move verbatim; existing golden tests keep their expected strings; a Full-mode golden is captured from the merged tool before any edit. |
| R3 | Bundle copies diverge from the canonical files after formatting. | Copy to the bundle after the final format stage; skill contract test and Python resource-contract tests compare bytes. |
| R4 | New canonical files are outside coverage roots. | Add `.claude/skills` to `config/poshqc-coverage.json`; read per-file coverage from the branch-current coverage XML, not a summary. |
| R5 | Windows CI shards resolve the forwarder target and `.claude/state` with different separators. | `Join-Path` everywhere; expected paths built the same way. |
| R6 | Test isolation: script-scope fixtures or directory creation leak between tests. | Per-test fixtures in `BeforeEach`; `Write-EpicProgressState` mocked or run with `-WhatIf`; seeded shuffled-order runs of the touched suites. |
| R7 | A scheduled prompt that carries `-StartUtc` would override a later reset. | Prompts omit baseline arguments; the contract test forbids them. |
| R8 | `-PairSamples` placed in a recurring prompt halves the samples each run. | The skill presents it as one-shot; the contract test forbids it in prompts. |

## Acceptance Criteria

Skill:

- [x] AC-01: `.claude/skills/epic-progress-report/SKILL.md` exists with frontmatter `name: epic-progress-report`, a single-quoted non-empty `description`, `argument-hint`, and `allowed-tools` containing `Bash(pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 *)`, `CronCreate`, `CronList`, `CronDelete` and `PushNotification`; it has no `context: fork` and no `user-invocable: false`, so it is invocable as `/epic-progress-report`. Proven by the frontmatter cases of `EpicProgressReport.SkillContract.Tests.ps1`.
- [x] AC-02: The skill contains every heading listed in `## Skill Content` and is under 500 lines. Proven by the skill contract test.
- [x] AC-03: The skill's `## Report Formats` section contains the TL;DR template, every variant listed in `## Report Formats` of this spec (done-sentence, running-sentence, the three range forms, `n/a` handling) and the Full report contents, using the merged tool's literal wording. Proven by skill contract test cases that assert each literal fragment (for example `hours left on the wave-parallel estimate. **Weekly** quota is at`, `(range needs 3 or more check-in intervals)`, `no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`, `tasks per hour (one child's pace)`, `points since the epic started`).
- [x] AC-04: The skill's `## Calculation Rules` section states every rule in `## Calculation Rules` of this spec, including the range as average velocity plus and minus 2.05 SD. Proven by skill contract test cases that assert the rule values (90 seconds, the 14-sample default, 2 minutes, n-1, 3 intervals, 0.5 tasks per hour, 2.05, 1.25 hours, epoch seconds).
- [x] AC-05: The skill's `## Scheduling Prompts` section carries the TL;DR prompt with cron `*/10 * * * *` and the hourly prompt with cron `7 * * * *`, both with the wording in `## Skill Content`, parameterized by `<epic-folder>`, invoking only the canonical script path, and containing none of `-StartUtc`, `-BaselineDone`, `-ResetBaseline` or `-PairSamples`; it states the push-notification text rule, that cron times are local, and the jitter. Proven by the skill contract test.
- [x] AC-06: The skill documents baseline reset after a pause (`-ResetBaseline`, optional `-StartUtc` and `-BaselineDone`, prompts unchanged), cadence change (one-shot `-PairSamples`, then `CronDelete` and `CronCreate` at the new interval, with the worked example 26.2 and 31.4 becoming 27.3 and 23.2 and the note that the conversation quoted 31.5), stopping the reports (`CronList`, `CronDelete`), and recovery after a restart (jobs are session-only, `claude --resume` or `--continue` restores unexpired jobs, recurring jobs expire 7 days after creation, recreate missing jobs, reset first if work paused). Proven by skill contract test cases for each section's key fragments.
- [x] AC-07: The skill's `## Known Behaviors and Measured Rates` and `## Notes` sections state the behaviors and rates listed in `## Skill Content` (bursty interval velocity, unreliable estimates for about two hours after a baseline, total drift, 20-to-60-minute flat stretches, the hourly-run shorter interval and its SD effect, negative-average behavior), the push-down rebuild-and-reinstall requirement, the 93 percent coordinator policy with a reference to `.claude/skills/quota-throttling/SKILL.md`, and the state-file trade-offs. Proven by the skill contract test.
- [x] AC-08: No epic number or epic folder name from a real run, host path, drive-letter path, account name, token, `TaskMaster` or `No-COM` appears in the skill, the canonical scripts or the forwarder, and the skill names no `scripts/dev-tools` invocation. Proven by the skill contract test, the relocated `contains no recovered hardcoded value` test (extended scan), and `test_push_down_issue_824_follow_ups.py`.

Single source of truth and delivery:

- [x] AC-09: The canonical entry, Logic, State, Metrics and Render files exist in `.claude/skills/epic-progress-report/scripts/`; the entry and Logic files are recorded as renames from `scripts/dev-tools/` (`git diff --find-renames --name-status main...HEAD` shows `R` entries); `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` no longer exists, and a repository search outside `docs/features/**` finds no reference to it.
- [x] AC-10: `scripts/dev-tools/Get-EpicProgressReport.ps1` is a forwarder with no `param()` block and no report logic; its executable statements are, in order, `$ErrorActionPreference = 'Stop'`, `$global:LASTEXITCODE = 0`, the invocation of the canonical entry with `@args`, `if ($?) { exit 0 }`, and `exit $(if ($LASTEXITCODE) { $LASTEXITCODE } else { 1 })`. Proven by the forwarder suite: the AST case, the `-SampleCap 0` case (canonical `ValidateRange` error naming `SampleCap`, exit code 1), the `-Mode Bogus` case (canonical `ValidateSet` error naming `Mode`, exit code 1), and the exit-propagation cases (an explicit non-zero target exit propagates; a normal run and a run that leaves a failed native exit code give 0).
- [x] AC-11: The skill folder is mirrored byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/`, and `core.json` lists the `SKILL.md` and each script file of the skill's `scripts/` folder exactly once. Proven by the bundle and manifest cases of the skill contract test.
- [ ] AC-12 (CI-dependent): The existing Python push-down contract tests listed in `## Test Inventory` pass unchanged on the PR head, verified by the `CI Required Gate` and the full-run jobs.
- [x] AC-13: `config/poshqc-coverage.json` lists `.claude/skills` among its roots, alongside the existing roots. Verified by reading the file.

Script additions:

- [x] AC-14: `-ResetBaseline` discards every stored sample, resolves the start (passed, else now) and baseline done (passed, else the current done count), adds the first sample and writes the state; the weekly baseline is not captured. Proven by the State suite `Resolve-EpicProgressBaseline` cases and the entry-suite `-ResetBaseline` case.
- [x] AC-15: `-PairSamples` keeps the newest sample and every second older sample and writes the result. Proven by the State suite `Merge-EpicProgressSamplePair` cases: 14 samples to 7 keeping s13, s11, s9, s7, s5, s3, s1; 13 to 7; 2 to 1; 1 and 0 unchanged; twice on 14 leaves 4; and the recorded fixture giving mean 26.2 and SD 31.4 before and mean 27.3 and SD 23.2 after (unrounded values within 0.001 of 26.1875, 31.4495, 27.3430, 23.2316), plus the entry-suite `-PairSamples` case.
- [x] AC-16: `-ResetBaseline` with `-PairSamples` throws before any git call; a run with no passed and no stored start throws before any git call with a message naming `-StartUtc` and `-ResetBaseline`; a run without `-StartUtc` and with a stored start uses the stored start. Proven by the corresponding entry-suite cases (git seam asserted not called; golden TL;DR for the stored-start case).
- [x] AC-17: The default state path is `<repository root>/.claude/state/epic-progress-<EpicFolder>.json`, `-StatePath` overrides it, and `Write-EpicProgressState` creates the directory only inside its `ShouldProcess` block. Proven by the State suite `defaults the state path under .claude/state of the repository root` case and the entry-suite `writes only the state file at -StatePath` and `writes nothing when the state write runs with WhatIf` cases.
- [x] AC-18: The state file is the version-1 object in `## State File Format`; the legacy array, blank text, unparseable text, an unknown version and missing fields are handled as specified. Proven by the State suite `ConvertFrom-EpicProgressStateText` and `ConvertTo-EpicProgressStateJson` cases.
- [x] AC-19: A run within 90 seconds of the last sample with neither switch writes nothing. Proven by the unchanged entry-suite case `does not write the state file within 90 seconds of the last sample`.
- [x] AC-20: Fixed-input tests cover average velocity, recent velocity, SD with exactly 2 intervals (`n/a`) and with 3 or more (finite), the bounded range, the no-upper-bound wording, and both modes, with no temporary file, network call or wall-clock read. Proven by the Metrics suite and the entry-suite mode cases.
- [x] AC-21: With three or more zero-rate intervals, average 0 and SD 0, the range text is `n/a hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`. Proven by the new Metrics suite case.
- [x] AC-22: Before any task has completed, neither the TL;DR nor the Full lines contain `NaN` or `Infinity`, and the affected values print `n/a`. Proven by the new Render suite case and the moved `non-finite values print n/a` context.

Regression:

- [x] AC-23: The TL;DR and Full outputs are byte-for-byte unchanged from the merged tool for the same inputs. Proven by the existing golden tests (`composes the four TL;DR lines`, `composes the Full lines in recovered order`, `prints the four TL;DR lines in TLDR mode`, `prints the TL;DR block followed by the Full sections in Full mode`) passing with unchanged expected strings, and by the new Full-mode golden whose expected lines were captured from the merged tool before any edit and recorded under `evidence/baseline/`.
- [x] AC-24: Every `It` name of the two #1080 suites exists in the relocated suites under `tests/scripts/claude-skills/epic-progress-report/`, except the replaced case `defaults the state path under the temporary root and outside the repository`; only the assertions listed there change. Verified by comparing the `It` names of the merged suites on `main` with those of the relocated suites, recorded as evidence.
- [x] AC-25: The canonical entry's comment-based help documents every parameter of its `param()` block, including `ResetBaseline` and `PairSamples`, states the new `StatePath` default, and carries an example with `-EpicFolder example-epic` and the canonical path. Proven by the relocated `documents every parameter in comment-based help` and `carries at least one example` tests.

Constraints:

- [x] AC-26: The canonical scripts run only `git fetch`, `git show`, `git worktree list`, `gh pr list` and `cswap list --json`, each inside its wrapper, and write files only in `Write-EpicProgressState`. Proven by the relocated `confines native commands to their wrappers`, `passes only fetch, show and worktree list to git`, `passes only pr list to gh` and `confines file writes to Write-EpicProgressState` tests.
- [x] AC-27: Every production and test file created or changed by this feature is below 700 lines by physical line count. Verified by a recorded line count of each file.
- [x] AC-28: No change to the `epic-run`, `epic-plan` or `epic-orchestrate` skills, agents or mirrors, no `.agents/skills` or `.github/skills` copy of the new skill, and no new or edited Python file. Verified by `git diff --name-status main...HEAD`.
- [x] AC-29: The touched Pester suites pass in seeded shuffled file order with at least three seeds and in a single fresh process over `tests/scripts`. Verified by recorded run evidence.
- [ ] AC-30 (CI-dependent): Each new or changed PowerShell production file (the canonical entry, Logic, State, Metrics and Render files and the forwarder) has at least 85 percent line coverage, read per file from the coverage report of the PR head run, verified by the `CI Required Gate` and the full-run jobs.
- [ ] AC-31 (CI-dependent): The full toolchain (format, lint, tests, contract checks, file-size check) passes on the PR head, verified by the `CI Required Gate` and the full-run jobs.

## Open Questions

- OQ-1 (R1), resolved: whether the forwarder returns a non-zero exit code for a parameter-binding failure inside the canonical invocation, and whether a successful run can leave a stale non-zero `$LASTEXITCODE`. Both were confirmed by probe, and the forwarder statements in DEC-1 settle them without a change to the canonical entry block. Probe outcomes with the settled forwarder: a parameter-validation failure exits 1; a successful run that leaves a failed native exit code exits 0; an explicit `exit 3` in the target exits 3; a normal run exits 0.

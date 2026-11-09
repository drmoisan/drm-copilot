# progress-report-critical-path-velocity — Spec

- **Issue:** #1153
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09
- **Status:** Approved for planning
- **Version:** 1.0
- **Branch:** feature/progress-report-critical-path
- **Research:** `docs/features/active/2026-11-09-progress-report-critical-path-velocity-1153/research/research.2026-11-09T14-51.md`
- **Prior design:** `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/spec.md` (decisions D1 to D13, delivered by PR #1124; the orchestrator confirmed with `gh` that PR #1124 delivered #1118, which closes research question Q8)

## Overview

Observed in a live epic on 2026-11-09:

- The v2 rewrite of the `epic-progress-report` skill (typed steps) removed task-based progress and velocity. The report has no tasks per hour, no recent velocity, no SD, and no range.
- The headline "about N hours left" is the serial sum over step types (remaining steps times their median, summed), decision D7. It ignores parallelism. With 5 features running at once it read 20 to 22 h. The wave-parallel figure on the same line read 12.5 h, and measured throughput implied about 6 to 8 h.
- The wave-parallel figure takes the slowest feature in each wave. It ignores the actual dependency edges, the concurrency cap, and each feature's own pace.
- Aggregate (parallel) velocity is not a stable measure. It scales with the number of running features and drops to zero during contention or stalls. Per-step medians measured during contention, such as 100-minute test runs, inflate every estimate.

## Behavior

Revise `.claude/skills/epic-progress-report/` and its scripts (`scripts/Get-EpicProgressReport*.ps1`, and the forwarder `scripts/dev-tools/Get-EpicProgressReport.ps1`). The time estimate must account for parallelism, task-based velocity must come back, and the headline must be a dependency-aware critical path. This replaces the D7 serial sum as the primary estimate. The default TL;DR cadence becomes 20 minutes.

1. **Task progress and aggregate velocity.**
   - Report done and total `[P#-T#]` plan tasks for each feature and for the epic. Keep the typed-step totals as a second measure.
   - Report aggregate velocity: the average since the baseline, the recent value (last interval), and the SD of interval velocities with the interval count. Label it aggregate and informational.
2. **Sequential (per-branch) velocity as the primary rate.**
   - Each feature's own velocity is tasks per hour of its active execution time. Time when the feature is blocked, waiting for the machine, or not started is excluded. The sources are checkpoint `stage_timing` and plan-checkbox samples.
   - The pooled value is the median over features with enough data (at least 5 tasks and at least 15 active minutes), reported with its SD across features.
   - A feature without enough data uses the pooled value. If there is no pooled value, a configurable default applies.
3. **Per-branch remaining time.**
   - Remaining time = remaining tasks / sequential velocity + the sum of remaining non-execution steps, each at its per-type median.
   - An in-progress step counts as max(0, median - elapsed).
   - Blocked features are reported separately.
4. **Critical path.**
   - Build the dependency DAG from the kickoff or manifest: each feature's depends-on edges, with waves used only as a fallback.
   - Add the epic-level tail steps that run after every feature merges: main sync, integration-to-main PR, its CI, and the merge.
   - Simulate list scheduling under `max_parallel_features`. The headline is the resulting finish time, together with the named critical chain.
   - Also report:
     - the serial sum, labelled "upper bound, no parallelism";
     - a range at velocity plus or minus 2.05 SD, with no upper bound when the slow velocity is at or below a threshold.
5. **Report format.**
   - The TL;DR keeps its existing lines and adds one velocity line (decision E1): progress; elapsed time and headline with the chain and quota; velocity; range.
   - The full report adds a per-feature table and a critical-path section, and keeps the step-type table.
   - Push notification text is under 200 characters.
6. **Cadence.**
   - The TL;DR cron becomes `*/20 * * * *`. The hourly full report stays at `7 * * * *`.
   - Update the scheduling prompts, the jitter notes, the `-PairSamples` guidance, and any interval filters that assumed 5 or 10 minutes.
7. **Engineering.**
   - Pure calculations go in a host-neutral module, separate from I/O.
   - Pester tests use fixtures for:
     - a serial chain;
     - a diamond DAG;
     - a cap of 1 versus N;
     - a blocked feature;
     - the pooled fallback;
     - a pause;
     - non-finite inputs printing `n/a`.
   - The clock is injected, and tests use no temporary files.
   - The state file version is bumped, with a migration from v2 that keeps the baseline start and the weekly baseline and adds per-feature samples.
   - SKILL.md is updated, and the forwarder keeps working.

## Design Decisions

Decisions E1 to E15 resolve research questions Q1 to Q8 and the orchestrator's engineering constraints. Each entry states which #1118 decision it supersedes, amends, or retains. #1118 decisions not named here (D1 to D6, D9, D12) are unchanged.

- **E1 (Q1) TL;DR shape.** The TL;DR keeps its existing four lines and adds one `**Velocity:**` line, so it is exactly five lines, in this order:
  1. `**TL;DR:** <Subject> #<issue> is at <tdone> of <ttotal> tasks, <sdone> of <stotal> steps (<pct>%). <done-sentence> <running-sentence>` — task progress first, typed steps second; the percentage stays by step count (D8 retained).
  2. `**Elapsed:** <H h MM min>; critical path about <H h MM min> left (<chain>, cap <k>[; excludes <b> blocked: #x, #y]). **Weekly** quota is at <weekly>.` — the quota text stays at the end of line 2.
  3. `**Now:** ...` — unchanged content.
  4. `**Velocity:** sequential <v> tasks / hr per feature (<source>, median of <n>, SD <sd>); aggregate <avg> tasks / hr average, <recent> recent, SD <isd> over <m> intervals (aggregate, informational).`
  5. `**Estimated time remaining:** range <fast> to <slow | no upper bound> (velocity +/- 2.05 SD, <sd-source>); serial sum <H h MM min> (upper bound, no parallelism).`
  Existing tests that pin the old four-line count or line positions and must be updated (research section 2): `Get-EpicProgressReport.Render.Tests.ps1` `composes the four TL;DR lines` and `prints the done sentence about a completed item` (`$tldr.Count | Should -Be 4`); `Get-EpicProgressReport.Tests.ps1` `prints the four TL;DR lines in TLDR mode`, `prints the TL;DR block followed by the Full sections in Full mode`, and `uses -EpicIssue over the kickoff marker` (`$lines[5]` becomes `$lines[6]`); `Get-EpicProgressReport.ItemMode.Tests.ps1` `prints the four TL;DR lines in item mode` and the live-stage-name golden; `EpicProgressReport.SkillContract.Tests.ps1` `states the report format fragments`. The quota tests `prints n/a quota when cswap is not installed` and `prints n/a quota when cswap output is unparseable` keep asserting `$lines[1]` because the quota stays at the end of line 2. Supersedes the four-line TL;DR format of #1118 and the `## Report Formats` sentence that no velocity, SD, or range line is printed. Retains D8.
- **E2 (Q2) Default sequential rate.** The configurable default rate is derived from the existing execution default: `3600 / <execution default seconds per task>`. The built-in execution default of 5 minutes per task gives 12 tasks per hour; `-StepDefaultMinutes @{ execution = 6 }` gives 10 tasks per hour. No script parameter is added, removed, or renamed, so the existing parameter pins (`documents every parameter in comment-based help`, `keeps the name, type, default, mandatory status and validation of every existing parameter`) stay unchanged. Retains D5.
- **E3 Sequential velocity.** A feature's sequential velocity is `Tasks / (ActiveSeconds / 3600)`, where `Tasks` and `ActiveSeconds` are the count and the summed seconds of that feature's execution samples in the duration ledger (keys `<issue>|exec|...`). A closed execution `stage_timing` entry replaces tick samples as today. Not-started time and non-execution waits are excluded by construction; blocked and pause spans are subtracted in the tick split (E11). A feature qualifies when `Tasks >= 5` and `ActiveSeconds >= 900` (15 minutes). The pooled value is the median of qualifying features' velocities, with the across-feature SD (n-1; `n/a` below 2 qualifying features) and the qualifying count. Each feature's rate is its own when it qualifies, else the pooled value, else the E2 default; the source label is `own`, `pooled`, or `default`. Supersedes D13 (velocity part).
- **E4 Per-feature remaining time.** For each unmerged, unblocked feature: remaining execution tasks x `3600 / rate` + each remaining non-execution step at its per-type median (default when none) + `max(0, median - elapsed)` for each in-progress step, where the median of an in-progress execution task is `3600 / rate`. Implemented by an optional `-MedianOverride` on `Get-EpicProgressTypeEstimate` (default empty, existing callers unchanged). The serial sum is the sum of these per-feature figures plus the tail (E8). Supersedes D7 (the serial sum stops being the headline and is relabelled "upper bound, no parallelism").
- **E5 Dependency source and cap.** Per kickoff feature, dependencies come from the epic checkpoint `features[].depends_on` (each reference resolved as an issue number or a feature-folder hint) when the row carries the key, else from the `epic.md` frontmatter `features[].depends_on` (inline flow list, read through one `git show` on the integration branch). An explicit empty list means no dependency. Waves from the kickoff are the fallback only when no feature has a `depends_on` key in either source; each feature then depends on every feature of the nearest lower wave. A reference to a merged feature is satisfied. The source used (`checkpoint`, `manifest`, `checkpoint+manifest`, or `waves`) is printed in the critical-path section. The cap is the checkpoint `max_parallel_features` when it is an integer from 1 to 8; otherwise `parallelism.default_max_parallel_features` from `config/orchestration-routing.json`, read through the existing file seams; when that file or key is missing or invalid, the built-in 4. Item mode has one node and no cap.
- **E6 List scheduling and critical chain.** An event simulation from t = 0: done features finish at 0 and hold no slot; running features start at 0 and hold slots even when their count exceeds the cap; at each event, ready features (every dependency finished) start while fewer than `cap` features are running, ordered by descending longest remaining path to a sink, ties by ascending issue number (ordinal). The headline is the latest feature finish plus the tail. The critical chain walks back from the latest-finishing feature through the predecessor that delayed each start (the dependency, or the feature whose finish freed the slot) and prints as `#a -> #b -> #c -> tail`. A self-loop, an unresolved reference, and a cycle each produce a distinct message (re-implemented locally; the skill imports nothing outside its folder); the critical-path section prints the message and the schedule falls back to waves.
- **E7 (Q3) Blocked features.** A blocked feature (D1 rules) and every feature that depends on it, directly or transitively, are excluded from the simulation and the serial sum and listed separately with their remaining time; the headline states the exclusion (`excludes <b> blocked: #x, #y`). Retains D1.
- **E8 (Q4) Epic tail.** After the last feature finishes, the tail is predicted as: one `main-sync` step, then one `integration-pr` step, which covers the integration-to-main PR, its CI, and its merge (its done rule is already `epic_merge_pr.merge_commit_sha` present). Each is timed at its per-type ledger median when one exists, else the stated defaults (main-sync 60 min, integration-pr 45 min), with in-progress credit `max(0, median - elapsed)`. The predicted main sync is omitted when a recorded sync row that is not done exists (that row is the tail sync) and when the `integration-pr` step is in progress or done. When `integration-pr` is done the tail is 0. No new step type is added: the existing `main-sync` and `integration-pr` types already describe the tail, and separate PR, CI, and merge epic types would change the step-type catalog and default table without a measured basis. The predicted sync enters the time figures only; it is not added to the step total or the percentage. Supersedes D11 for the predicted tail only; D11 still governs step counting.
- **E9 (Q5) Range.** The range re-runs the schedule with each feature's rate at `rate + 2.05 x SD` (fast end) and `rate - 2.05 x SD` (slow end). SD is the across-feature SD of sequential velocity when at least 2 features qualify; otherwise the aggregate interval SD when at least 3 intervals exist; otherwise the range prints `n/a` with the reason. The slow end prints `no upper bound` when the slow rate of any feature with remaining tasks is at or below 0.5 tasks per hour (the #1093 threshold). Every printed figure passes through `Format-EpicProgressHour` or `Format-EpicProgressNumber`, so a non-finite value prints `n/a`. Supersedes D13 (SD and range part).
- **E10 (Q6) Wave-parallel retired.** The wave-parallel figure is removed from both formats and replaced by the critical path. `Get-EpicProgressWaveParallelSecond` and its test case `sums the largest remaining feature per open wave plus epic steps` are removed and replaced by the list-schedule tests. `-WaveOverheadHours` stays accepted with no effect. Supersedes the D7 secondary figure.
- **E11 (Q7) Pauses and intervals.** A pause span is (a) the gap between two consecutive check-in samples when it is longer than 3 x the 20-minute TL;DR cadence, that is longer than 3600 seconds, recorded as `{ startUnixSeconds: <earlier sample>, endUnixSeconds: <later sample> }`; and (b) on `-ResetBaseline`, the span from the newest stored sample to the resume instant (no span when no sample is stored). The threshold is a constant documented in SKILL.md, not a parameter. Pause spans and blocked spans are subtracted from active time in the tick split with the same overlap arithmetic as blocked seconds, and from the aggregate elapsed time. For aggregate interval velocities, consecutive samples are combined until at least 600 seconds (10 minutes) have elapsed; a trailing remainder shorter than 600 seconds is skipped; an interval that overlaps a pause span is dropped. This removes the short interval produced when the hourly `:07` run interleaves with `*/20`. The 90-second sample rule in `Select-EpicProgressSample` is unchanged. Amends D10: `-ResetBaseline` still keeps the duration ledger and the tick anchors, and additionally appends a pause span.
- **E12 State file version 3.** The writer emits version 3: every v2 field (`unit`, `startUnixSeconds`, `baselineDone`, `baselineWeeklyPct`, `samples[]`, `durations`, `items`), plus `baselineDoneTasks`, per-sample `tasks` (epic done tasks) and `features` (issue to done tasks), and `pauses[]`. A v2 document migrates by keeping `startUnixSeconds` (baseline start), `baselineWeeklyPct` (weekly baseline), `baselineDone`, `durations` (ledger), and `items` (anchors) unchanged; v2 samples are kept for the step measure but do not feed task velocity; `baselineDoneTasks` resolves to the current done task count through a `UseCurrentDoneTasks` signal on `Resolve-EpicProgressBaseline`; `pauses` starts empty; a v2 migration does not trigger the step-baseline reset that v1 triggers. A v3 document is read unchanged. Version 1 and the legacy array migrate as today. An unknown higher version (4 or above), blank text, or unparseable text is read as empty state, which is the existing rule of `ConvertFrom-EpicProgressStateText` (it accepts only listed versions; SKILL.md `## State File`: "version 3 or higher is read as empty state"), moved up by one version.
- **E13 Cadence.** TL;DR cron `*/20 * * * *`; hourly full report `7 * * * *` unchanged. Jitter, per the Claude Code scheduled-tasks page `https://code.claude.com/docs/en/scheduled-tasks` (`### Jitter`, verified 2026-11-09 in the research): a recurring task runs late by up to half the gap to the next run and at most 30 minutes, so the `*/20` job runs 0 to 10 minutes late and the hourly job 0 to 30 minutes late. The `-PairSamples` guidance uses the worked example "from 10 to 20 minutes" (one doubling, one `-PairSamples` run). Supersedes the #1118 `*/10` cadence and its jitter text ("a 10-minute job fires up to 5 minutes late").
- **E14 Engineering layout.** Pure calculations go in two new host-neutral files beside the Logic hub, dot-sourced by it: `Get-EpicProgressReport.Velocity.ps1` (E2, E3, aggregate velocity, interval combining, pause detection) and `Get-EpicProgressReport.Schedule.ps1` (E5 graph building, E6 scheduling and chain, E7 exclusion, E8 tail composition, E9 range). They read no clock, call no I/O seam, and take data in and return data. The manifest and config reads live in `Get-EpicProgressReport.Gather.ps1`; the entry script (495 lines) receives only wiring. PowerShell only; no new Python. Every changed or new file under `.claude/skills/epic-progress-report/` has its byte-identical bundle copy and, for new files, a `core.json` pack-manifest entry. The forwarder is not changed.
- **E15 Decision record in SKILL.md.** SKILL.md `## Decisions` records E1 to E15 under their E numbers and marks D7, D11, and D13 in place as superseded by #1153 (naming the E decision), and D10 as amended by E11, so the contract loop over `D1..D13` still finds every D entry.

## Superseded

This change supersedes the following parts of #1118 (`docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/spec.md`, delivered by PR #1124):

| #1118 item | Disposition | Replaced by |
|---|---|---|
| D7 serial-sum headline | Superseded. The serial sum is kept as a secondary figure labelled "upper bound, no parallelism". | E4, E6 |
| D7 secondary wave-parallel figure | Retired from both formats; `Get-EpicProgressWaveParallelSecond` removed. | E10 |
| D11 (future main syncs not predicted) | Superseded for the predicted epic tail only; step counting is unchanged. | E8 |
| D13 velocity, SD, and range removal | Superseded; sequential and aggregate velocity, SD, and range return. The `-WaveOverheadHours` compatibility part stays. | E3, E9 |
| D10 reset semantics | Amended, not superseded: ledger and anchors kept; a pause span is appended. | E11 |
| Four-line TL;DR and "No velocity, standard-deviation, straight-line, or range line is printed in either mode." | Superseded by the five-line TL;DR. | E1 |
| TL;DR cron `*/10 * * * *`, the "every 10 minutes" description, the "from 5 to 10 minutes" cadence example, and the jitter text "a 10-minute job fires up to 5 minutes late" | Superseded. | E13 |
| State file version 2 as the written version; "version 3 or higher is read as empty state" | Superseded by version 3; version 4 or higher is empty state. | E12 |

## Inputs / Outputs

- Inputs:
  - Epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json`: existing fields plus `max_parallel_features` and `features[].depends_on`.
  - `docs/features/epics/<epic-folder>/epic.md` frontmatter `features[].depends_on` on the integration branch (one `git show`, only when a kickoff feature has no `depends_on` key in the checkpoint).
  - `config/orchestration-routing.json` `parallelism.default_max_parallel_features` (optional; built-in 4 when missing).
  - Kickoff, plans, item checkpoints, `gh pr list`, `cswap list --json`, and the state file, as today.
- Outputs: the five-line TL;DR; the Full report with the per-feature table and the critical-path section; the version-3 state file.
- Config keys and defaults: no new parameter; default rate from the execution default (E2); cap default from config, else 4 (E5); pause threshold 3600 seconds and interval minimum 600 seconds as documented constants (E11); thresholds 5 tasks, 900 seconds, 2.05, and 0.5 tasks per hour (E3, E9).
- Versioning: state version 3 with migration (E12). The forwarder `scripts/dev-tools/Get-EpicProgressReport.ps1` and the canonical script path are unchanged.

## API / CLI Surface

- Parameters: unchanged in name, type, default, mandatory status, and validation.
- `-Mode TLDR` prints the five E1 lines; `-Mode Full` prints them followed by the full report.
- Full report additions:
  - Per-feature table: issue, state, tasks done of total, rate and its source (`own`, `pooled`, `default`), remaining time, scheduled start, scheduled finish; blocked and blocked-dependent features listed with `excluded`.
  - Critical-path section: dependency source, cap and its source, the chain, the feature finish, the tail steps with their times, the headline, the serial sum, the range with its SD source, and any graph error message.
- Push notification text: the first TL;DR line with every `**` removed; when it is 200 characters or longer, the running-features sentence is dropped; the result is under 200 characters.
- Example (fictional, epic folder and figures illustrative):

```text
**TL;DR:** Epic #42 is at 31 of 60 tasks, 19 of 35 steps (54.3%). 1 of 3 features are done. #12345 is running (6 of 13 steps).
**Elapsed:** 3 h 10 min; critical path about 2 h 05 min left (#12345 -> #12346 -> tail, cap 4). **Weekly** quota is at 41%.
**Now:** no step is in progress. 10 of 10 types use defaults.
**Velocity:** sequential 8.0 tasks / hr per feature (pooled, median of 3, SD 2.0); aggregate 9.5 tasks / hr average, 7.2 recent, SD 1.8 over 6 intervals (aggregate, informational).
**Estimated time remaining:** range 1 h 40 min to 3 h 30 min (velocity +/- 2.05 SD, across-feature SD); serial sum 4 h 15 min (upper bound, no parallelism).
```

## Data & State

- Data flow: Gather reads the inputs; `Get-EpicProgressStepReport` returns per-feature steps, remaining seconds, done task counts, the tail steps, the dependency inputs, and the cap; Velocity and Schedule compute the figures from that data and the injected `NowUnixSeconds`; Render formats them.
- Invariants: every printed figure is finite or `n/a`; done features hold no slot; blocked features and their dependents never enter the simulation; the headline is never greater than the serial sum computed from the same rates (the serial sum is the cap-1 schedule of the same durations).
- Persistence: state version 3 (E12) with `pauses[]` appended on gap detection and on `-ResetBaseline`; spans that end before the oldest stored anchor may be pruned.
- Migration: v2 to v3 as stated in E12; aggregate task-velocity history starts at the first v3 run.

## Constraints & Risks

- PowerShell only. No new Python.
- File-size limits apply: 800 lines is a hard block and 500 lines is guidance. Split modules as needed. The entry script is at 495 lines; new logic stays out of it (E14).
- Each `.claude` change needs its bundle copy and a manifest entry.
- The state migration must not lose the v2 baseline or weekly baseline.
- SKILL.md is pinned below 500 lines by `stays under 500 lines`; additions must be offset by removals.
- SKILL.md must not cite a repository script that `core.json` does not ship (`test_epic_skill_script_citations_shipped.py`).
- Risks (research R1 to R6): few qualifying features give a wide or `n/a` range (the reason is printed); contention still lowers per-feature rates; the 1000-sample ledger cap can drop early execution samples in large epics; a block-style YAML `depends_on` does not parse with the inline-list reader (the fallback is printed); the headline and push text change for existing users; the SKILL.md line pin.

## Implementation Strategy

- Scope: Velocity.ps1 and Schedule.ps1 (new, pure); Logic hub (two dot-source lines); Metrics (`-MedianOverride`, removal of `Get-EpicProgressWaveParallelSecond`); State (v3 reader, writer, migration, pause append, `UseCurrentDoneTasks`); Gather (manifest and config reads, extended step report); Render (five-line TL;DR, per-feature table, critical-path section); entry (wiring only); SKILL.md; bundle copies; `core.json` entries; tests.
- New functions (names from research section 9, final names at the planner's discretion): `Get-EpicProgressFeatureVelocity`, `Get-EpicProgressPooledVelocity`, `Get-EpicProgressAggregateVelocity`, `Get-EpicProgressPauseSpan`, `Get-EpicProgressDependencyGraph`, `Invoke-EpicProgressListSchedule`, `Get-EpicProgressCriticalChain`, `Get-EpicProgressScheduleRange`, `Read-EpicProgressManifestFeature`.
- Dependency changes: none.
- Logging: none beyond the printed report.
- Rollout: the new output applies on the next run after the change is pushed down; the first run migrates a v2 state file.
- Test pins to update (research section 2): the skill-folder file count and the bundle mirror count in the `epic-progress-report delivery` Describe, the `productionPaths` and `scanPaths` lists and counts in `Get-EpicProgressReport.ps1 repository constraints`, the goldens in the entry and item-mode tests, the Render tests, the State version tests, the SkillContract fragments, and `prints no velocity, SD or range line in either mode` (replaced, not deleted).

## Acceptance Criteria

### Report format

- [x] AC-01: `-Mode TLDR` prints exactly five lines whose prefixes, in order, are `**TL;DR:**`, `**Elapsed:**`, `**Now:**`, `**Velocity:**`, and `**Estimated time remaining:**`, and `-Mode Full` prints the same five lines before the full report; verified by the Render test and the entry and item-mode goldens.
- [x] AC-02: The `**TL;DR:**` line states `<tdone> of <ttotal> tasks, <sdone> of <stotal> steps (<pct>%)` for the epic, with the percentage computed from step counts (D8); a fixture with 31 of 60 tasks and 19 of 35 steps prints `31 of 60 tasks, 19 of 35 steps (54.3%)`.
- [x] AC-03: The `**Elapsed:**` line prints the elapsed time, `critical path about <H h MM min> left`, the chain in the form `#a -> #b -> tail`, and `cap <k>`, and ends with the weekly quota text, so `prints n/a quota when cswap is not installed` and `prints n/a quota when cswap output is unparseable` still pass on `$lines[1]`.
- [x] AC-04: The `**Velocity:**` line prints the sequential rate with its source (`own`, `pooled`, or `default`), the qualifying-feature count, and the across-feature SD, followed by the aggregate average, recent value, interval SD, and interval count, and contains the text `aggregate, informational`.
- [x] AC-05: The `**Estimated time remaining:**` line prints the range (`<fast> to <slow>` or `<fast> to no upper bound`) with its SD source, and the serial sum followed by the exact text `(upper bound, no parallelism)`.
- [x] AC-06: No output line in either mode contains `wave-parallel`, and `Get-EpicProgressWaveParallelSecond` is no longer defined in any script under `.claude/skills/epic-progress-report/scripts/`.
- [x] AC-07: The Full report prints a per-feature table with columns for issue, state, tasks done of total, rate, rate source, remaining time, scheduled start, and scheduled finish; a critical-path section naming the dependency source, the cap and its source, the chain, the tail steps, the headline, the serial sum, and the range SD source; and the existing step-type table.
- [x] AC-08: The push-notification rule holds on the new first line: a test with a first line of 199 characters after removing `**` keeps the running-features sentence, a first line of 200 characters drops it, and a fixture with eight running features and five-digit task counts yields text under 200 characters.
- [x] AC-09: In item mode the subject reads `Item #<n>`, the chain prints `#<n>` with no tail and no cap text, and the headline equals that item's remaining time.
- [x] AC-10: A fixture that passes NaN, positive infinity, and negative infinity into every new rendered figure (sequential rate, SD, aggregate average, recent, interval SD, headline, range ends, serial sum, per-feature remaining) prints `n/a` for each, and no output line matches `NaN|Infinity`.

### Sequential velocity and default rate

- [x] AC-11: A feature's sequential velocity equals its execution-sample count divided by the summed sample seconds in hours, using only ledger keys that start with `<issue>|exec|`; a feature with 0 active seconds yields a non-finite rate that prints `n/a`.
- [x] AC-12: Qualification boundaries: (4 tasks, 900 s) does not qualify; (5 tasks, 900 s) qualifies; (6 tasks, 900 s) qualifies; (5 tasks, 899 s) does not qualify; (5 tasks, 901 s) qualifies.
- [x] AC-13: Pooled fixture: qualifying features at 6, 8, and 10 tasks per hour give a pooled median of 8, an across-feature SD of 2 (n-1), and a qualifying count of 3; with exactly 1 qualifying feature the across-feature SD is `n/a`, and with 2 it is finite.
- [x] AC-14: Pooled fallback fixture: a feature with 4 tasks uses the pooled rate and is labelled `pooled`; a qualifying feature uses its own rate and is labelled `own`; with no qualifying feature every feature uses the default and is labelled `default`.
- [x] AC-15: The default rate is 12 tasks per hour with built-in defaults and 10 tasks per hour with `-StepDefaultMinutes @{ execution = 6 }`; the entry script's parameter set is unchanged, and `documents every parameter in comment-based help` and `keeps the name, type, default, mandatory status and validation of every existing parameter` pass without modification.

### Aggregate velocity, intervals, and pauses

- [x] AC-16: Aggregate velocity reports the average since the baseline (done tasks minus `baselineDoneTasks`, over elapsed hours minus pause spans), the recent value (last combined interval), the interval SD (n-1), and the interval count; with 2 intervals the SD prints `n/a` and with 3 it is finite.
- [x] AC-17: Interval combining boundaries: consecutive samples 599 s apart form no interval on their own, 600 s apart form one interval, and 601 s apart form one interval; a sample sequence at 0, 7, 20, 27, and 40 minutes yields exactly the intervals 0 to 20 and 20 to 40 minutes; a trailing remainder under 600 s is skipped; an interval overlapping a pause span is dropped.
- [x] AC-18: Pause-gap boundaries: a gap of 3599 s or 3600 s between consecutive samples records no pause span, and a gap of 3601 s records a span from the earlier sample to the later sample.
- [x] AC-19: `-ResetBaseline` appends a pause span from the newest stored sample to the resume instant, appends no span when no sample is stored, and keeps the duration ledger and the tick anchors (D10); `keeps the durations ledger and anchors with -ResetBaseline` passes.
- [x] AC-20: Pause fixture: a tick batch whose interval spans a stored pause span yields per-task seconds computed without the pause time, and a tick batch that spans a blocked span still excludes the blocked time, so neither paused nor blocked time enters sequential velocity.

### Remaining time

- [x] AC-21: Per-feature remaining time equals remaining execution tasks x `3600 / rate` plus each remaining non-execution step at its per-type median plus in-progress credit; a fixture with 6 remaining tasks at 12 tasks per hour and one remaining `review` step at the 14-minute default gives 44 minutes.
- [x] AC-22: In-progress credit boundaries: elapsed one second below the median contributes 1 s, elapsed equal to the median contributes 0, and elapsed one second above the median contributes 0.
- [x] AC-23: `Get-EpicProgressTypeEstimate` called without `-MedianOverride` returns the same results as before the change, so the existing Metrics test cases for it pass unmodified.

### Critical path

- [x] AC-24: Serial chain fixture: A (1 h) -> B (2 h) -> C (3 h) at cap 4 with a 1-hour tail gives a headline of 7 h and the chain `#A -> #B -> #C -> tail`.
- [x] AC-25: Diamond fixture: A (1 h) -> {B (2 h), C (3 h)} -> D (1 h) with no tail gives 5 h at cap 4 with the chain `#A -> #C -> #D -> tail`, and 7 h at cap 1.
- [x] AC-26: Cap 1 versus N fixture: four independent features of 1, 2, 3, and 4 hours with no tail give 10 h at cap 1, 5 h at cap 2, and 4 h at cap 4.
- [x] AC-27: Cap boundary fixture: three independent 1-hour features with no tail give 1 h at cap 4 (ready count below the cap), 1 h at cap 3 (equal), and 2 h at cap 2 (ready count above the cap).
- [x] AC-28: Running features beyond the cap: three running features at cap 2 keep their slots from t = 0, and a pending ready feature starts only when the running count falls below 2.
- [x] AC-29: Ready features start in descending order of longest remaining path to a sink, and two features with equal path length start in ascending issue-number order.
- [x] AC-30: Done features finish at t = 0 and hold no slot, and a dependency on a merged feature is satisfied at t = 0.
- [x] AC-31: Cap resolution: checkpoint `max_parallel_features` values 1 and 8 are used; values 0, 9, a non-integer, and a missing key fall back to `parallelism.default_max_parallel_features` from `config/orchestration-routing.json`; when that file or key is missing, the cap is 4; the cap source is printed.
- [x] AC-32: Dependency source: checkpoint `depends_on` is used when the row has the key, references resolve by issue number and by feature-folder hint, the `epic.md` inline `depends_on` list is used for a feature without a checkpoint key, an explicit empty list means no dependency, waves are used only when no feature has a `depends_on` key in either source, and the source used is printed.
- [x] AC-33: A self-loop, an unresolved reference, and a cycle each produce a distinct message in the critical-path section, and the schedule then falls back to waves.
- [x] AC-34: Blocked-feature fixture: a blocked feature and a feature that depends on it transitively are both excluded from the simulation and from the serial sum, both are listed separately with their remaining time, and the `**Elapsed:**` line contains `excludes 2 blocked: #<x>, #<y>`.
- [x] AC-35: Tail fixture: with no recorded sync row and `integration-pr` remaining, the tail is one `main-sync` plus one `integration-pr` at their ledger medians, or at 60 and 45 minutes when no median exists, added after the last feature finish; with `integration-pr` in progress the predicted sync is omitted; with `integration-pr` done the tail is 0; the predicted sync does not change the step total or the percentage.
- [x] AC-36: The step-type catalog and its default table are unchanged, so `returns the eleven catalog types` and `returns the built-in default for every type` pass unmodified.
- [x] AC-37: For the same rates and durations, the serial sum equals the cap-1 schedule finish, and the headline is never greater than the serial sum in any schedule fixture.

### Range

- [x] AC-38: SD-source boundaries: 2 qualifying features use the across-feature SD; 1 qualifying feature with 3 intervals uses the aggregate interval SD; 1 qualifying feature with 2 intervals prints the range as `n/a` with a reason; the SD source is printed.
- [x] AC-39: Range fixture: rates of 8 tasks per hour with SD 2 re-run the schedule at 12.1 (fast end) and 3.9 (slow end) tasks per hour, and the printed ends equal the schedule finishes at those rates.
- [x] AC-40: No-upper-bound boundaries: a slow rate of 0.49 or 0.5 tasks per hour for a feature with remaining tasks prints `no upper bound`, and a slow rate of 0.51 prints a finite slow end; a slow rate at or below 0.5 for a feature with no remaining tasks does not trigger `no upper bound`.

### State file

- [x] AC-41: The writer emits `"version": 3` with `startUnixSeconds`, `baselineDone`, `baselineWeeklyPct`, `baselineDoneTasks`, `samples[]` entries carrying `ts`, `done`, `tasks`, and `features`, `durations`, `items`, and `pauses[]`.
- [x] AC-42: A version-2 document migrates with `startUnixSeconds`, `baselineWeeklyPct`, `baselineDone`, `durations`, and `items` unchanged, `pauses` empty, `baselineDoneTasks` set to the current done task count through `UseCurrentDoneTasks`, and no step-baseline reset.
- [x] AC-43: A version-3 document round-trips unchanged; a version-1 document and the legacy array migrate as before; a version-4 document, blank text, and unparseable text are read as empty state.
- [x] AC-44: `-ResetBaseline` on a version-3 state discards the check-in samples and blocked spans, keeps `durations`, `items`, and `pauses`, and appends the E11 pause span; `-PairSamples` on version-3 samples keeps each kept sample's `tasks` and `features` values.

### Cadence and SKILL.md

- [x] AC-45: SKILL.md `## Scheduling Prompts` states the TL;DR job as cron `*/20 * * * *`, recurring, and the hourly job as cron `7 * * * *`, recurring, and the frontmatter `description` states a five-line TL;DR every 20 minutes; no `*/10` text remains in SKILL.md.
- [x] AC-46: The SKILL.md jitter note states that the 20-minute job runs 0 to 10 minutes late and the hourly job 0 to 30 minutes late and cites `https://code.claude.com/docs/en/scheduled-tasks`; the text `up to 5 minutes late` no longer appears.
- [x] AC-47: SKILL.md `## Changing the Cadence` uses the worked example "from 10 to 20 minutes" with one `-PairSamples` run, and the contract test assertion that this section does not contain `SD` is replaced by an assertion of the new text.
- [x] AC-48: SKILL.md `## Report Formats`, `## Calculation Rules`, and `## State File` state the E1 lines, the E2 to E11 rules with the values 5 tasks, 15 active minutes, 2.05, 0.5 tasks per hour, 3600 s, and 600 s, and the version-3 document; `## Decisions` records E1 to E15 and marks D7, D11, and D13 as superseded by #1153 and D10 as amended; the `states the step model, default durations and decisions` loop over `D1..D13` passes.
- [x] AC-49: SKILL.md stays under 500 lines (`stays under 500 lines` passes) and cites no repository script that `core.json` does not ship (`test_epic_skill_script_citations_shipped.py` passes).

### Engineering

- [x] AC-50: `Get-EpicProgressReport.Velocity.ps1` and `Get-EpicProgressReport.Schedule.ps1` exist beside the Logic hub, are dot-sourced by it with exact-case file names, call no I/O seam and do not read the clock, and are covered by the `confines file writes to Write-EpicProgressState`, `confines native commands to their wrappers`, and `contains no recovered hardcoded value` tests with their path lists and counts updated.
- [x] AC-51: The entry script defines no new calculation function, and every script in `.claude/skills/epic-progress-report/scripts/` is at or below 800 lines.
- [x] AC-52: New and changed tests mock `Get-EpicProgressUtcNow` for the clock, create no temporary files, read or write no state file on disk, define no global functions, and `Invoke-PoshQCLeakScan` reports no finding.
- [x] AC-53: Every changed or new file under `.claude/skills/epic-progress-report/` has a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/`, each new script has exactly one entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, the `epic-progress-report delivery` count pins equal the number of files in the skill folder, and `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py` pass.
- [x] AC-54: `scripts/dev-tools/Get-EpicProgressReport.ps1` is unchanged, `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` passes unmodified, and the forwarder prints the five TL;DR lines and the Full report from fixture inputs.
- [x] AC-55: Integration golden: the entry test renders the Full report from fixture checkpoints carrying `max_parallel_features` and `depends_on` and from a fixture `epic.md`, and matches a golden whose values are hand-derived in test comments.
- [x] AC-56: Each test listed in research section 2 with an "Update" or "Replace" disposition is updated with an assertion of the new behavior; `prints no velocity, SD or range line in either mode` is replaced by a test asserting that the velocity and range lines are present, not deleted.
- [x] AC-57: The PowerShell toolchain passes in a single pass (Invoke-Formatter, PSScriptAnalyzer, one `Invoke-PoshQCParallelTest` run), each new and changed script has line coverage of at least 85% read from `artifacts/pester/powershell-coverage.xml`, and no new Python file is added.
- [ ] AC-58 (CI-dependent): CI on the pull request head completes with `success`, including the Linux and Windows Pester shards and the push-down contract tests.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: velocity (per-feature, pooled, aggregate), remaining time, DAG list scheduling, range, and state migration.
- [ ] Integration scenarios: the full report rendered from fixture checkpoints and a fixture manifest.
- [ ] CLI/API examples: the TL;DR and full-report output from the forwarder script.

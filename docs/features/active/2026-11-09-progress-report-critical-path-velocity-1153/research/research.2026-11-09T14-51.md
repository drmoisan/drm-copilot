# Research: progress-report-critical-path-velocity (Issue #1153)

- Issue: #1153
- Branch: feature/progress-report-critical-path
- Feature folder: docs/features/active/2026-11-09-progress-report-critical-path-velocity-1153/
- Scope sources: `docs/features/potential/promoted/2026-11-09-progress-report-critical-path-velocity.md`, `issue.md`, `spec.md`, `user-story.md` of the feature folder.
- Timestamp source: the file-name stamp is UTC read from the public time service `timeapi.io` (`2026-11-09T14:51:29Z`) through WebFetch, because this agent has no shell clock. The orchestrator may re-stamp the file from the host clock.
- All findings below were verified by reading the files named; nothing here was executed. Every citation is a file plus a function, heading, test name, or key.

## 1. Current State: Scripts

All files are under `.claude/skills/epic-progress-report/scripts/` unless named otherwise. Line counts are logical lines (the last non-empty line of each file as read). Tiers: 500 guidance, 700 advisory, above 800 blocks.

| File | Lines | Tier status | Pure or I/O |
|---|---|---|---|
| `Get-EpicProgressReport.ps1` (entry) | 495 | 5 lines under the 500 guidance | I/O seams plus wiring |
| `Get-EpicProgressReport.Logic.ps1` (hub) | 257 | under | pure, dot-sources the other seven files |
| `Get-EpicProgressReport.Stages.ps1` | 173 | under | pure |
| `Get-EpicProgressReport.Steps.ps1` | 344 | under | pure |
| `Get-EpicProgressReport.Durations.ps1` | 386 | under | pure |
| `Get-EpicProgressReport.State.ps1` | 381 | under | pure |
| `Get-EpicProgressReport.Metrics.ps1` | 196 | under | pure |
| `Get-EpicProgressReport.Render.ps1` | 279 | under | pure |
| `Get-EpicProgressReport.Gather.ps1` | 358 | under | reading functions call the entry seams; `Get-EpicProgressStepReport` is pure |
| `scripts/dev-tools/Get-EpicProgressReport.ps1` (forwarder) | 24 | under | forwards `@args` |
| `.claude/skills/epic-progress-report/SKILL.md` | 455 | Markdown is exempt from file size, but a contract test pins it below 500 (section 2) | n/a |

### 1.1 Entry script `Get-EpicProgressReport.ps1`

- Parameter sets `Epic` (default, mandatory `-EpicFolder`) and `Item` (mandatory `-Issue`). 17 parameters: `EpicFolder`, `Issue`, `StartUtc`, `EpicIssue`, `IntegrationBranch`, `KickoffPath`, `RepositoryRoot`, `CheckpointPath`, `StatePath`, `BaselineDone`, `BaselineWeeklyPct`, `WaveOverheadHours`, `SampleCap`, `Mode`, `ResetBaseline`, `PairSamples`, `StepDefaultMinutes`.
- I/O seams (the only places that touch processes, files, or the clock): `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Test-EpicProgressCommand`, `Test-EpicProgressPath`, `Read-EpicProgressFile`, `Write-EpicProgressState` (ShouldProcess; the only writer; creates the parent directory), `Get-EpicProgressUtcNow` (returns `[datetime]::UtcNow`; this is the clock seam), `Get-EpicProgressLastExitCode`.
- `Invoke-EpicProgressReport` is the wiring: validates switch combinations and `-StepDefaultMinutes` before any I/O; resolves settings (`Resolve-EpicProgressSetting` or `Resolve-EpicProgressItemSetting`); reads the state file before the first git call; reads the clock once through `Get-EpicProgressUtcNow`; runs `git fetch -q origin` (epic mode), `git worktree list --porcelain`, and `git show` for the kickoff and plans; `gh pr list` per branch; `cswap list --json`; calls `Get-EpicProgressStepReport`, `Select-EpicProgressSample`, optionally `Merge-EpicProgressSamplePair`, `ConvertTo-EpicProgressStateJson`, `Get-EpicProgressSummary`, `Get-EpicProgressTldrLine`, `Get-EpicProgressFullLine`.
- Clock: obtained once in the entry (`Get-EpicProgressUtcNow`), converted to `NowUnixSeconds`, and passed as data to every pure function. Tests mock `Get-EpicProgressUtcNow`. Every pure file states that it does not read the clock.
- The entry-point block at the bottom is skipped when dot-sourced; it pushes `-RepositoryRoot` as the location and pops it in `finally`.

### 1.2 `Get-EpicProgressReport.Logic.ps1` (hub)

Dot-sources Stages, Steps, Durations, State, Metrics, Render, Gather (in that order, through `Join-Path -Path $PSScriptRoot`). Functions: `Test-EpicProgressJsonText`; `ConvertFrom-EpicProgressKickoffRow` (reads only the table whose header first cell is `issue_num` or `Issue`; cells 1, 3, 4, 5 are issue, wave, band, plan path; cell 2 is ignored); `Get-EpicProgressIssueFromKickoff`; `ConvertFrom-EpicProgressWorktreeList`; `ConvertFrom-EpicProgressPrList`; `Get-EpicProgressWeeklyQuota`; `Get-EpicProgressTaskCount` (counts `- [ ] [P#-T#]` and `- [x] [P#-T#]`); `Get-EpicProgressCurrentPhase`; `Get-EpicProgressFeatureState`.

### 1.3 `Get-EpicProgressReport.Stages.ps1`

`Get-EpicProgressStepTypeCatalog` (eleven types: nine item, `main-sync`, `integration-pr`), `ConvertTo-EpicProgressStepType` (alias map; `remediation*` is `composite`; unknown is `unmapped`), `ConvertTo-EpicProgressUnixSecond`, `ConvertFrom-EpicProgressStageTiming` (records `Stage`, `Type`, `Attempt`, `StartedUnixSeconds`, `EndedUnixSeconds`), `Get-EpicProgressBlockage` (decision D1; `awaiting_ci` and `none` are not blocked). The file states that it re-implements `scripts/dev-tools/StageTiming.psm1` rules so the skill imports nothing outside its own folder.

### 1.4 `Get-EpicProgressReport.Steps.ps1`

`Get-EpicProgressPlanTask`, `Get-EpicProgressStepRecord`, `Test-EpicProgressCompletedStep`, `Get-EpicProgressCycleStep`, `Get-EpicProgressItemStep`, `Get-EpicProgressEpicStep` (one `main-sync` per sync row, one `integration-pr`), `Get-EpicProgressStepCount`. Step records carry `Issue`, `Type`, `Cycle`, `Ordinal`, `Status` (`done`, `in_progress`, `remaining`, `blocked`), `Key`, `StartedUnixSeconds`.

### 1.5 `Get-EpicProgressReport.Durations.ps1`

`Get-EpicProgressMedian` (NaN for no values), `Resolve-EpicProgressStepDefault` (decision D5 defaults in seconds; `execution` = 5 min per task), `Get-EpicProgressDurationSample`, `Get-EpicProgressStageSample`, `Merge-EpicProgressDuration` (one sample per key, newest 1000 per type), `Get-EpicProgressBlockedSecond`, `Get-EpicProgressTickSample` (batched-tick split: `(now - last tick - blocked) / newly checked`; a closed execution stage replaces tick samples with stage duration / task count), `Get-EpicProgressApproximateSample`.

Fact relevant to sequential velocity: execution samples are keyed `<issue>|exec|<plan file>|<task id>` and are retained per type in the ledger after an item merges, so per-feature task durations are already available, keyed by issue.

### 1.6 `Get-EpicProgressReport.State.ps1`

`Select-EpicProgressSample` (adds a check-in sample when the last one is at least 90 seconds old; keeps `SampleCap`), `Resolve-EpicProgressSetting`, `Resolve-EpicProgressItemSetting`, `ConvertFrom-EpicProgressStateText`, `ConvertTo-EpicProgressStateJson`, `Resolve-EpicProgressBaseline` (`UseCurrentDone` signals the caller to substitute the current done count), `Merge-EpicProgressSamplePair`.

### 1.7 `Get-EpicProgressReport.Metrics.ps1`

`Format-EpicProgressHour`, `Format-EpicProgressNumber` (both return `n/a` for NaN or infinity), `Get-EpicProgressWeeklyText`, `Get-EpicProgressTypeEstimate` (per-type rows, in-progress credit `max(0, median - elapsed)`, blocked subtotal, `TotalSeconds` = D7 serial sum), `Get-EpicProgressWaveParallelSecond` (largest remaining feature per open wave, summed, plus epic seconds). The header states that the velocity, SD, critical-path, and range functions were removed by #1118 decision D13.

### 1.8 `Get-EpicProgressReport.Render.ps1`

`Get-EpicProgressSummary` (one record with every printed value), `Get-EpicProgressTldrLine` (exactly four lines: TL;DR, Elapsed, Now, Estimated time remaining), `Get-EpicProgressFullLine` (heading, Elapsed/Progress, State table, Wave table, per-type table, default lines, blocked line, unmapped line, weekly line).

### 1.9 `Get-EpicProgressReport.Gather.ps1`

Reading functions: `Read-EpicProgressItemCheckpoint`, `Read-EpicProgressText` (live worktree first, then `git show` on the integration branch), `Get-EpicProgressItemInput`, `Find-EpicProgressItemWorktree`, `Get-EpicProgressEpicCheckpointRow` (returns `Checkpoint`, `Feature` rows keyed by kickoff issue, `Sync` rows for non-kickoff issues, `MergePr`). Pure composition: `Get-EpicProgressStepReport` (steps, ledger merge, tick anchors, blocked spans, per-type estimate over all steps, per-feature estimates feeding the wave-parallel figure).

The parsed epic checkpoint object is already returned as `Checkpoint` by `Get-EpicProgressEpicCheckpointRow` and passed to `Get-EpicProgressStepReport` as `EpicCheckpoint`; neither reads `max_parallel_features` or `features[].depends_on` today.

### 1.10 Forwarder `scripts/dev-tools/Get-EpicProgressReport.ps1`

Five statements, no `param` block, no functions; forwards `@args` to `../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` and normalizes the exit code. It keeps working with no change as long as the canonical path and its parameter validation behavior (`-SampleCap 0`, `-Mode Bogus`) are unchanged.

### 1.11 `SKILL.md`

Headings pinned by test (17, in order): `# Epic Progress Report`, `## When to Use This Skill`, `## Prerequisites`, `## Inputs`, `## Step Model`, `## Report Formats`, `## Calculation Rules`, `## Starting the Reports`, `## Scheduling Prompts`, `## Resetting the Baseline After a Pause`, `## Changing the Cadence`, `## Stopping the Reports`, `## After a Restart`, `## State File`, `## Known Behaviors and Measured Rates`, `## Decisions`, `## Notes`. The frontmatter `description` says "a four-line TL;DR every 10 minutes" and "the time remaining is the sum over step types". `## Report Formats` states "No velocity, standard-deviation, straight-line, or range line is printed in either mode." `## Decisions` holds D1 to D13 (D7 serial-sum headline; D13 velocity/SD/range dropped).

## 2. Existing Pester Tests and Their Disposition

Test folder: `tests/scripts/claude-skills/epic-progress-report/` (scanned through `config/poshqc-scan.json` `tests/scripts`), plus `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`.

| Test file | Describe / It affected | Scope item | Disposition |
|---|---|---|---|
| `EpicProgressReport.SkillContract.Tests.ps1` | `epic-progress-report SKILL.md structure and content` / `states the report format fragments` | 5 | Update: the TL;DR fragments, `**Estimated time remaining:** ... by type (sum); ... wave-parallel.`, and `No velocity, standard-deviation, straight-line, or range line is printed in either mode.` change. |
| same | `states the calculation rule values` | 2, 3, 4 | Update: `sum over types` is no longer the headline rule; add velocity, pooled median, 2.05, threshold, list-scheduling values. |
| same | `carries both scheduling prompts with their cron expressions` | 6 | Update: pins `cron \`*/10 * * * *\`, recurring`. |
| same | `states the push-notification text rule, local cron time and jitter` | 6 | Update: pins `up to 5 minutes late`. |
| same | `documents reset, cadence change, stopping and restart recovery` | 6, 2 | Update: asserts the `Changing the Cadence` section does not contain `SD`; that assertion conflicts with returning SD (see section 7). |
| same | `documents known behaviors, rates, delivery and quota policy` | 7 | Update: pins `"version": 2` and `version 3 or higher` in `## State File`. |
| same | `states the step model, default durations and decisions` | 4, history | Update: loops `1..13` for `D<n>:`; new decisions (section 6) extend the range. Keep the D7 and D13 entries present but marked superseded, or change the loop. |
| same | `stays under 500 lines` | all | Risk: SKILL.md is at 455 lines. The additions must be offset by removals (section 11). |
| same | `epic-progress-report delivery` / `lists every skill-folder file exactly once in core.json` and `mirrors every skill-folder file byte-identically in the bundle` | 7 | Update: both pin `$files.Count | Should -Be 10`. |
| `Get-EpicProgressReport.Tests.ps1` | `Invoke-EpicProgressReport` / `prints the four TL;DR lines in TLDR mode`, `prints the TL;DR block followed by the Full sections in Full mode`, `treats an unparseable state file as empty`, `uses the stored start when -StartUtc is absent`, `prints the Full golden for a legacy four-sample state` | 1, 4, 5 | Update the hand-derived goldens (`$script:expectedTldr`, `$script:expectedFull`). |
| same | `uses -EpicIssue over the kickoff marker` | 5 | Update: `$lines[5]` indexes the Full heading after four TL;DR lines; a five-line TL;DR moves it. |
| same | `prints n/a quota when cswap is not installed`, `prints n/a quota when cswap output is unparseable` | 5 | Update: `$lines[1]` is asserted to end with the quota text; moves if the quota leaves line 2. |
| same | `passes only fetch, show and worktree list to git` | 4 | Update only if the manifest is read through `git show` (section 4 recommendation adds one call in the fixture, which has no `depends_on`). |
| same | `writes only the state file at -StatePath`, `prints the Full golden for a legacy four-sample state` | 7 | Update: `$written.version | Should -Be 2`. |
| same | `clears stored samples ... with -ResetBaseline`, `keeps the durations ledger and anchors with -ResetBaseline` | 7, pause | Update if v3 adds pause spans and per-feature samples; the anchor assertion stays valid under the recommended pause design (anchors kept, pause span subtracted). |
| same | `Get-EpicProgressReport.ps1 repository constraints` / `confines file writes to Write-EpicProgressState` (`productionPaths.Count | Should -Be 9`), `confines native commands to their wrappers`, `contains no recovered hardcoded value` (`scanPaths.Count | Should -Be 11`) | 7 | Update counts and the `productionPaths` list for each new file. |
| same | `documents every parameter in comment-based help` (`$parameterNames.Count | Should -Be 17`) | config default | Unchanged under the recommendation (no new parameter; section 9.6). |
| `Get-EpicProgressReport.ItemMode.Tests.ps1` | `prints the four TL;DR lines in item mode`, `counts review and ci steps ...`, `live stage names` / `prints the same TL;DR golden for the live stage names`, `reports a lower remaining estimate ...` (both) | 5 | Update goldens and line counts. |
| same | `keeps the name, type, default, mandatory status and validation of every existing parameter` (15 rows) | config default | Unchanged under the recommendation. |
| `Get-EpicProgressReport.Render.Tests.ps1` | `composes the four TL;DR lines`, `composes the Full lines in recovered order`, the `non-finite values print n/a` context, `prints Item as the subject in item mode with wave-parallel equal to the sum`, `prints the one-feature epic golden with one blocked step`, `prints the item-mode Full golden`, `prints the done sentence about a completed item` (`$tldr.Count | Should -Be 4`) | 5 | Update. |
| same | `prints no velocity, SD or range line in either mode` | 1, 4 | Replace: it asserts the absence of `Velocity|SD of|Straight line|range needs|no upper bound|tasks / hr`, which this feature reverses. |
| `Get-EpicProgressReport.Metrics.Tests.ps1` | `Get-EpicProgressTypeEstimate and Get-EpicProgressWaveParallelSecond (issue #1118)` | 3, 4 | Keep the existing cases if `Get-EpicProgressTypeEstimate` gains only an optional override parameter (section 9.3); `sums the largest remaining feature per open wave plus epic steps` is deleted or kept depending on whether the wave-parallel figure is retired (open question Q6). |
| `Get-EpicProgressReport.State.Tests.ps1` | `ConvertFrom-EpicProgressStateText and ConvertTo-EpicProgressStateJson` / `treats version 3 as empty state`, `writes version 2 with unit steps`, `reads a version-2 document with durations and items`, `round-trips integer epoch seconds` | 7 | Update: version 3 becomes valid; the "unknown version" case moves to 4; add v2-to-v3 migration cases. |
| same | `Merge-EpicProgressSamplePair` / `reproduces the recorded 5-minute to 10-minute example` | 6 | Unchanged (historical fixture of the pairing rule); optionally add a 10-to-20-minute case. |
| same | `Select-EpicProgressSample` (90-second cases) | 6 | Unchanged under the recommendation (the 90-second sample rule stays; interval coalescing happens in the velocity function). |
| `Get-EpicProgressReport.Gather.Tests.ps1` | `Gather functions` / `composes steps, ledger and estimate for gathered items` | 3, 4 | Update when `Get-EpicProgressStepReport` returns new fields (per-feature remaining, schedule input). |
| `Get-EpicProgressReport.Steps.Tests.ps1`, `Get-EpicProgressReport.Stages.Tests.ps1`, `Get-EpicProgressReport.Durations.Tests.ps1`, `Get-EpicProgressReport.Logic.Tests.ps1` | all | none | Unchanged unless the step catalog changes (Q4); `returns the eleven catalog types` and `returns the built-in default for every type` pin the catalog and defaults. |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | all | forwarder | Unchanged. |
| `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` | citation check over `.claude/skills/epic-progress-report/SKILL.md` | 5, 6 | Constraint: SKILL.md must not cite a repository script that `core.json` does not ship (for example `scripts/dev-tools/StageTiming.psm1` or `scripts/dev-tools/Get-StageTimingReport.ps1`). |

## 3. State File

- Location: `.claude/state/epic-progress-<epic-folder>.json` (epic) or `.claude/state/progress-item-<n>.json` (item) under the repository root, from `Resolve-EpicProgressSetting` / `Resolve-EpicProgressItemSetting`; `-StatePath` overrides; gitignored.
- Current version 2 (`ConvertTo-EpicProgressStateJson`): `version` 2, `unit` `steps`, `startUnixSeconds`, `baselineDone` (steps), `baselineWeeklyPct`, `samples[]` of `{ ts, done }` (done steps), `durations` (type to sample list `{ key, type, seconds, source, approx, recorded }`), `items` (issue to `{ plans: { <plan file>: { checked[], lastTickUnixSeconds } }, blockedSinceUnixSeconds }`).
- `baselineStart` is `startUnixSeconds`; the weekly baseline is `baselineWeeklyPct`.
- Migration pattern in `ConvertFrom-EpicProgressStateText`: the parser accepts versions `1` and `2` only; any other version, blank, or unparseable text is empty state. A v1 document or the legacy array sets `Migrated = $true`, keeps `StartUnixSeconds` and `BaselineWeeklyPct` (v1), discards samples and the baseline done count; `Resolve-EpicProgressBaseline` then returns `UseCurrentDone` so the entry substitutes the current done count; the next write is the current version.

Recommended v3 migration (consistent with that pattern):

- Accept `'1'`, `'2'`, `'3'`; version 4 or higher stays empty state.
- v3 document: everything in v2, plus `baselineDoneTasks` (done plan tasks at the start), `samples[]` entries gain `tasks` (epic done tasks) and `features` (issue to done tasks), and `pauses[]` of `{ startUnixSeconds, endUnixSeconds }` (section 9.4). `unit` stays `steps` for `done`.
- v2 to v3: keep `startUnixSeconds`, `baselineWeeklyPct`, `baselineDone`, `durations`, and `items` unchanged; v2 samples carry no task counts, so they are kept for the step measure but cannot feed aggregate task velocity; `baselineDoneTasks` resolves to the current done task count through a new `UseCurrentDoneTasks` flag on `Resolve-EpicProgressBaseline` (the same substitution mechanism as `UseCurrentDone`); `pauses` starts empty; a `MigratedFrom` value (`1`, `2`, legacy) replaces the boolean so v2 does not trigger the step-baseline reset that v1 needs.
- The aggregate velocity therefore restarts its interval history at the first v3 run; the baseline start and the weekly baseline are preserved, as AC and Constraints require.

## 4. Epic Kickoff and Manifest Formats

- Kickoff: `docs/features/epics/<epic-folder>/epic-kickoff.md` on `origin/epic/<epic-folder>-integration`, read by `git show` in `Invoke-EpicProgressReport` and parsed by `ConvertFrom-EpicProgressKickoffRow`. Real example in this tree: `docs/features/epics/cleanup-merged-worktrees-hardening/epic-kickoff.md`, `## Feature Summary`, columns `issue_num | feature_folder | wave | complexity | plan-path` (waves are 0-based there; the test fixture uses 1-based). The kickoff has no `depends_on` column; its `## Execution Order` table repeats the waves and the prose names `max_parallel_features` but not as a parseable field.
- Manifest: `docs/features/epics/<epic-folder>/epic.md`, YAML frontmatter `features:` list of `issue_num`, `feature_folder`, `depends_on: [<issue_num>, ...]` (inline flow list in the real example `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md` and in the schema of `.agents/skills/epic-orchestrate/SKILL.md`). No `max_parallel_features` key in that frontmatter.
- Epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json`: required keys include `max_parallel_features` (integer 1 to 8), `waves`, and `features` (`REQUIRED_EPIC_KEYS` and `_validate_route_id` in `scripts/dev_tools/validate_epic_orchestrator_state.py`); each feature carries `depends_on`, and a reference resolves either as an `issue_num` or as a feature-folder hint (`build_feature_reference_index`, `resolve_feature_reference`). The planner checkpoint `artifacts/orchestration/epic-planner-state.json` carries the same fields (`## Checkpoint Persistence` in `.claude/agents/epic-planner.md`).
- Default cap: `config/orchestration-routing.json` `parallelism.default_max_parallel_features` = 4, `hard_max_parallel_features` = 8; `.claude/rules/parallel-orchestration.md` states the epic bound `1..8`.
- Wave computation: `.claude/lib/epic-wave/EpicWave.psm1` (`Get-EpicWaveNumber`, longest-path layering; distinct `EPIC_WAVE_SELF_LOOP:`, `EPIC_WAVE_UNRESOLVED_REFERENCE:`, `EPIC_WAVE_CYCLE:` errors). The progress skill does not import it (Stages header: the skill imports nothing outside its folder), so cycle detection in the scheduler must be its own.
- How the scripts read them today: kickoff rows only (issue, wave, band, plan path); the epic checkpoint only for `features[].branch_name`, `merge_status`, `merge_confirmed_at`, `worktree_created_at`, sync rows, and `epic_merge_pr`. Neither `depends_on` nor `max_parallel_features` is read.

Recommended DAG source order: (1) epic checkpoint `features[].depends_on` for kickoff issues, resolving each reference as an issue number or a feature-folder basename against the checkpoint rows; (2) when the checkpoint is absent or a kickoff feature has no `depends_on`, the manifest `epic.md` through one `git show` on the integration branch, parsed by a narrow frontmatter reader that accepts inline `depends_on: [...]` lists only; (3) waves from the kickoff as a fallback, where each feature depends on every feature of the nearest lower wave. The source used is printed in the critical-path section. Cap: checkpoint `max_parallel_features`, else 4. Item mode: one node, no cap.

## 5. Stage Timing and Plan-Checkbox Samples

- Checkpoint shape (`.claude/skills/orchestrate/SKILL.md`, `## Checkpoint Handling` item 6): top-level `stage_timing` list of `{ stage, attempt, started_at, ended_at }`, ISO-8601 UTC, `ended_at` null while open; one clock reading per transition; tolerated and unvalidated (`.claude/rules/orchestrator-state.md`, `## Green-CI standalone merge`).
- Committed evidence: before the merge the list is written to `FEATURE/evidence/other/stage-timing.<timestamp>.json` with `issue-num` and `stage_timing`; `scripts/dev-tools/Get-StageTimingReport.ps1` reads every `stage-timing.*.json` under `docs/features` through `scripts/dev-tools/StageTiming.psm1` (`Read-StageTimingEvidence`, `Get-StageTimingSummary`, `Format-StageTimingReport`). The progress skill does not read these files: it reads only live checkpoints (`Read-EpicProgressItemCheckpoint`), and reading the evidence file would need a directory listing on the integration branch, which decision D3 excludes (`git ls-tree`). This stays out of scope; the SKILL `Known Behaviors` line about unrecovered durations of removed worktrees remains true.
- Plan-checkbox samples today: `Get-EpicProgressTickSample` splits each batch of newly checked tasks evenly over `now - last tick - blocked seconds`; a closed execution stage replaces them with stage duration / task count (`Merge-EpicProgressDuration` prefers `stage_timing` over `tick`). The anchors live in state `items[issue].plans[file]`. Blocked seconds come from `Get-EpicProgressBlockedSecond` over the stored `blockedSinceUnixSeconds`.
- Gap for AC "Paused, blocked or waiting time is excluded": blocked spans are subtracted; pauses are not. `-ResetBaseline` keeps the anchors (decision D10), so the first tick after a resume spans the pause and inflates every task sample of that batch. "Waiting for the machine" has no recorded signal in the checkpoint; `awaiting_ci` is explicitly not blocked (D1), and CI time is outside execution ticks anyway.

## 6. History: Why v2 Chose D7, and What This Supersedes

- The typed-step rewrite is issue #1118: `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/spec.md`. Its `D7 (Q7) Headline.` states: "The headline estimate is the serial sum over types, matching the owner's formula. The wave-parallel figure is secondary. Orchestrator default; the owner may revisit." D13 dropped velocity, SD, and range.
- No feature folder for #1124 exists under `docs/features/`. The only occurrence of `#1124` that names an object is `docs/features/active/2026-11-08-epic-child-pr-merges-without-ci-1130/code-review.2026-11-08T15-30.md`, which calls it "merged PR #1124". ORCHESTRATOR TO CONFIRM (needs `gh`): that PR #1124 is the pull request that delivered #1118 (the "v2" of the delegation prompt).
- The previous velocity rules this feature restores in changed form are in `docs/features/active/2026-11-06-epic-progress-report-skill-1093/spec.md`, `## Calculation Rules`: interval velocity over consecutive samples at least 2 minutes apart; SD with n-1, `n/a` below 3 intervals; range `average +/- 2.05 x SD`, slow end `no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`.
- Superseded by this feature: D7 (headline becomes the critical path; the serial sum is relabelled "upper bound, no parallelism"); D13 in its velocity/SD/range part (the `-WaveOverheadHours` part can stay); the `## Report Formats` sentence that no velocity or range line is printed; the TL;DR cadence `*/10`; possibly the wave-parallel figure (Q6). D10 is amended by the pause rule (section 9.4). Recommend recording these as new decisions D14 onward and marking D7 and D13 "superseded by #1153" in place, so the contract loop over `D1..D13` still finds them.

## 7. Cadence, Jitter, `-PairSamples`, and Interval Filters

- `SKILL.md`: frontmatter `description` ("every 10 minutes"); `## When to Use This Skill` ("for example from 5 to 10 minutes"); `## Scheduling Prompts` (`cron \`*/10 * * * *\``; jitter note "a 10-minute job fires up to 5 minutes late and an hourly job up to 30 minutes late"); `## Changing the Cadence` ("for example from 5 to 10 minutes"; "14 samples become 7").
- Jitter, verified on 2026-11-09 against the Claude Code page `https://code.claude.com/docs/en/scheduled-tasks` (`### Jitter`): a recurring task other than `*/5` runs late "by up to half the gap to the next run, and by at most 30 minutes", the same delay on every run for evenly spaced schedules. A `*/20` job therefore runs 0 to 10 minutes late, and the hourly job 0 to 30 minutes late.
- Scripts: no filter in the current scripts assumes 5 or 10 minutes. The only interval rule is the 90-second sample rule in `Select-EpicProgressSample`. The removed 2-minute interval filter (#1093) is the one to reintroduce in changed form.
- Interaction at 20 minutes: the TL;DR fires at about :00, :20, :40 plus a constant delay, and the hourly Full run at :07 plus its own delay; both add check-in samples, so intervals of about 7, 13, and 20 minutes alternate. `SampleCap` 14 then spans roughly 3.5 to 4.5 hours.
- Recommendation: keep the 90-second sample rule; compute aggregate interval velocities by coalescing consecutive samples until at least 10 minutes have elapsed (half the 20-minute cadence) and skipping a remainder shorter than that. This removes the hourly short interval without depending on job timing. `-PairSamples` guidance: the step from 10 to 20 minutes is a doubling, so one `-PairSamples` run before recreating the job is correct; update the worked example text to "from 10 to 20 minutes".

## 8. Bundle Mirrors, Pack Manifest, Coverage

- Bundle: every changed file under `.claude/skills/epic-progress-report/` needs a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/`. There is no `.agents/` or `.github/` copy of this skill (only the Claude surface and its bundle carry `name: epic-progress-report`).
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the ten skill files. A new script needs one entry; `test_push_down_pack_manifest_dependency_closure.py` requires every `$PSScriptRoot` dependency of a manifested PowerShell file (the Logic hub dot-sources each sibling) to be in core.
- Contract tests: `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_epic_skill_script_citations_shipped.py`, and the skill's own `epic-progress-report delivery` Describe.
- Coverage: `config/poshqc-coverage.json` has root `.claude/skills`, so a new script under the skill folder is measured automatically; no coverage configuration entry is needed. New test files under `tests/scripts/` are sharded automatically.
- Brief: no fact of `.claude/skills/execution-environment/SKILL.md` changes, so no brief update task is needed.

## 9. Recommended Design

### 9.1 Candidate approaches

- A. One new pure module `Get-EpicProgressReport.CriticalPath.ps1` holding velocity, remaining time, scheduling, and range. Simple to name; likely 450 to 550 lines with comment-based help at the existing density, so it starts at or above the 500 guidance.
- B. Two new pure files dot-sourced by the Logic hub: `Get-EpicProgressReport.Velocity.ps1` (rates) and `Get-EpicProgressReport.Schedule.ps1` (DAG, list scheduling, chain, range), plus small additions to State, Metrics, Gather, Render, and the entry. Each new file stays near 250 to 300 lines and follows the existing per-concern split (#1093, #1118).
- C. Extend Metrics and Gather in place. Rejected: Gather (358) and the entry (495) are the files nearest the guidance tier, and Metrics' header documents removal of exactly these functions.

Recommendation: B. Both files are host-neutral (no I/O, no clock, data in and data out), satisfy "pure calculations go in a host-neutral module" as one logical module split by concern, and keep every file under 500. Rejected alternatives: A (single file at the guidance tier from the start), C (grows the two files nearest the tier).

### 9.2 `Get-EpicProgressReport.Velocity.ps1` (pure)

- `Get-EpicProgressFeatureVelocity -Ledger -Issue`: from execution samples whose key starts `<issue>|exec|`, returns `Tasks`, `ActiveSeconds`, `TasksPerHour` (`Tasks / (ActiveSeconds / 3600)`, NaN when `ActiveSeconds` is 0), and `Qualifies` (`Tasks >= 5` and `ActiveSeconds >= 900`). Active time is execution time only, so not-started time and non-execution waits are excluded by construction; blocked and paused spans are excluded upstream in the tick split.
- `Get-EpicProgressPooledVelocity -FeatureVelocity -DefaultTasksPerHour`: median over qualifying features (reuse `Get-EpicProgressMedian`), `SD` across qualifying features (n-1; NaN below 2), `Count`, and `Source` (`pooled` or `default`). Each feature's rate: its own when it qualifies, else pooled, else the default.
- `Get-EpicProgressAggregateVelocity -Sample -BaselineDoneTasks -StartUnixSeconds -NowUnixSeconds -MinimumIntervalSeconds 600`: average since baseline, recent (last coalesced interval), interval SD (n-1, NaN below 3), interval count. Labelled aggregate and informational.
- Default rate: `3600 / Default['execution']` from `Resolve-EpicProgressStepDefault`, so the built-in default is 12 tasks per hour and `-StepDefaultMinutes @{ execution = 6 }` gives 10. This satisfies "a configurable default applies" without a new parameter, so the 17-parameter and 15-row parameter pins stay unchanged.

### 9.3 Per-feature remaining time

Add an optional `-MedianOverride` hashtable to `Get-EpicProgressTypeEstimate` (default empty; existing callers unchanged). For each unmerged, unblocked feature call it over that feature's steps with `@{ execution = 3600 / rate }`: remaining tasks / rate, plus every remaining non-execution step at its per-type median, plus `max(0, median - elapsed)` for each in-progress step, including an in-progress execution task. Blocked features keep the existing blocked subtotal and are listed separately. The serial upper bound is the sum of these per-feature figures plus the epic tail.

### 9.4 Pause handling

On `-ResetBaseline`, append a pause span `{ startUnixSeconds: <newest stored sample ts>, endUnixSeconds: <resume instant> }` to v3 `pauses[]` (no span when there is no stored sample). The tick split subtracts pause overlap with the same arithmetic as blocked seconds (`Get-EpicProgressBlockedSecond` called per span). Anchors and ledger are kept, so D10 stays true; only the pause time is removed. Spans older than the oldest anchor can be pruned.

### 9.5 `Get-EpicProgressReport.Schedule.ps1` (pure)

- `Get-EpicProgressDependencyGraph -Feature -CheckpointFeature -ManifestFeature`: builds issue-to-dependencies over kickoff issues using the source order in section 4; resolves folder references; reports `Source` (`checkpoint`, `manifest`, `waves`); rejects self-loops, unresolved references, and cycles with distinct messages (the same classes as `Get-EpicWaveNumber`, re-implemented locally).
- `Invoke-EpicProgressListSchedule -Graph -DurationSeconds -Running -Done -Cap -TailSeconds`: event simulation from t = 0. Done features finish at 0. Running features start at 0 and hold slots, even if their count exceeds the cap. At each event, ready features (all dependencies finished) start while a slot is free, in descending order of longest remaining path to a sink (critical-path priority), ties by ordinal issue number. Returns per-feature start and finish, `FinishSeconds` (latest finish plus `TailSeconds`), and the predecessor that delayed each start (a dependency, or the feature whose finish freed the slot).
- `Get-EpicProgressCriticalChain`: walks predecessors back from the latest-finishing feature; the chain prints as `#a -> #b -> #c -> tail`.
- Tail: the remaining and in-progress epic-level steps from `Get-EpicProgressEpicStep`, timed by `Get-EpicProgressTypeEstimate`, run after every feature merges. Q4 covers whether a final main sync is predicted.
- Blocked features and their transitive dependents are excluded from the simulation and listed; the headline then states that it excludes them (Q3).
- `Get-EpicProgressScheduleRange`: re-runs the schedule with each feature's execution rate at `rate + 2.05 x SD` (fast end) and `rate - 2.05 x SD` (slow end), with SD the pooled across-feature SD. When the slow rate of any feature with remaining tasks is at or below the threshold, the slow end prints `no upper bound`; the threshold keeps the #1093 value, 0.5 tasks per hour. With SD not finite, the range prints `n/a` with a reason.
- Every printed figure goes through `Format-EpicProgressHour` or `Format-EpicProgressNumber`, so non-finite values print `n/a`.

### 9.6 Wiring and file growth

- Logic hub: two more dot-source lines.
- Gather: `Get-EpicProgressStepReport` returns per-feature steps and remaining seconds (it already computes `$featureSteps`), the epic tail seconds, and done task counts; the manifest read (`Read-EpicProgressManifestFeature` through `Read-EpicProgressText`) lives here, not in the entry. If Gather approaches 500, move the new composition into a function in `Schedule.ps1` that takes the step report as data.
- Entry: pass task counts and pauses to the state writer and the new results to the summary; target net growth of a few lines, since it is at 495.
- State: v3 reader, writer, and baseline resolution; about 60 to 80 added lines (from 381).
- Render: new TL;DR composition, per-feature table, critical-path section; about 100 added lines (from 279).
- SKILL.md: rewrite `## Report Formats`, `## Calculation Rules`, `## Scheduling Prompts`, `## Changing the Cadence`, `## State File`, `## Decisions`; remove text that no longer applies to stay under 500.

### 9.7 Proposed report shape (subject to Q1)

```text
**TL;DR:** Epic #<issue> is at <done> of <total> tasks (<pct>%), <sdone> of <stotal> steps. <done-sentence> <running-sentence>
**Elapsed:** <H h MM min>; critical path about <H h MM min> left (<chain>, cap <k>). **Weekly** quota is at <weekly>.
**Velocity:** sequential <v> tasks / hr per feature (median of <n>, SD <sd>); aggregate <avg> tasks / hr average, <recent> recent (SD <isd>, <m> intervals), informational.
**Range:** <fast> to <slow | no upper bound>; serial sum <H h MM min> (upper bound, no parallelism). <b> blocked features excluded.
```

## Requirements Mapping

| Acceptance criterion | Design element | Files |
|---|---|---|
| TL;DR shows task progress, sequential and aggregate velocity, critical-path headline with chain, serial sum as upper bound | 9.2, 9.5, 9.7 | Velocity, Schedule, Render, entry, SKILL.md |
| Per-feature remaining uses own sequential velocity, falling back to pooled median | 9.2, 9.3 | Velocity, Metrics (`-MedianOverride`), Gather |
| Critical path respects depends-on, tail steps, cap | 9.5, section 4 | Schedule, Gather |
| Paused, blocked, waiting time excluded | 9.2 (execution-only active time), 9.4 (pauses), existing blocked subtraction | Durations, State, Gather |
| Default TL;DR cadence 20 minutes | section 7 | SKILL.md |
| Tests for serial chain, diamond, cap 1 vs N, blocked, pooled fallback, pause, non-finite `n/a` | Testing Implications | new test files |

State transitions: a feature moves Pending to Running to Completed or Blocked as today (`Get-EpicProgressFeatureState`, blockage override in `Get-EpicProgressStepReport`); its velocity source moves default to pooled to own as samples accumulate; the v3 state moves through `pauses[]` appends on reset and sample appends on each check-in.

## Numeric Derivation Evidence

These counts are test pins to update, not spec acceptance criteria; they are recorded so the plan can state exact values.

### Skill-folder file count (current 10)

- Complete Family: every file under `.claude/skills/epic-progress-report/`.
- Exhaustive Search Scope: the skill folder in this worktree, all extensions.
- Inclusion Rules: any file in the folder or a subfolder.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `**/*EpicProgressReport*` over the worktree, filtered to `.claude/skills/epic-progress-report/scripts/`, plus Grep `name: epic-progress-report` for `SKILL.md`.
- Primary Member Set: `SKILL.md`, `Get-EpicProgressReport.ps1`, `.Durations.ps1`, `.Gather.ps1`, `.Logic.ps1`, `.Metrics.ps1`, `.Render.ps1`, `.Stages.ps1`, `.State.ps1`, `.Steps.ps1`.
- Primary Count: 10.
- Cross-check Search Strategy or Query Expression: Grep `epic-progress-report` in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- Cross-check Member Set: the same ten paths, listed once each.
- Cross-check Count: 10.
- Member-set Comparison: identical sets. Under the recommendation the count becomes 12 (`Get-EpicProgressReport.Velocity.ps1`, `Get-EpicProgressReport.Schedule.ps1`).

### Canonical production script count (current 9) and scan count (current 11)

- Complete Family: PowerShell files in `.claude/skills/epic-progress-report/scripts/`.
- Exhaustive Search Scope: that folder.
- Inclusion Rules: `*.ps1`. Exclusion Rules: none.
- Primary Search Strategy or Query Expression: the same Glob as above, canonical folder only.
- Primary Member Set: the nine `Get-EpicProgressReport*.ps1` files. Primary Count: 9.
- Cross-check Search Strategy or Query Expression: the `productionPaths` array in `Get-EpicProgressReport.ps1 repository constraints` `BeforeAll` of `Get-EpicProgressReport.Tests.ps1`.
- Cross-check Member Set: the same nine files. Cross-check Count: 9.
- Member-set Comparison: identical. The scan list adds the forwarder and `SKILL.md` (11). Under the recommendation: 11 and 13.

### Entry parameter count (17, unchanged)

- Primary: the `param` block of `Get-EpicProgressReport.ps1` (17 names, listed in 1.1). Cross-check: the 15 rows of `keeps the name, type, default, mandatory status and validation of every existing parameter` plus the two excluded names `Issue` and `StepDefaultMinutes` = 17. Sets agree.

## Testing Implications

- New files `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Velocity.Tests.ps1` and `Get-EpicProgressReport.Schedule.Tests.ps1`, mirroring the new production files; they dot-source the Logic hub as the existing tests do.
- Schedule fixtures (in-memory hashtables): serial chain A -> B -> C (finish = sum, chain names all three); diamond A -> {B, C} -> D (finish = A + max(B, C) + D, chain through the longer branch); the same four independent features at cap 1 (finish = sum) versus cap 4 (finish = max); a blocked feature with a dependent (both excluded and listed); running features beyond the cap; a cycle, a self-loop, and an unresolved reference (three messages); wave fallback; tail added after the last finish.
- Velocity fixtures: a feature with 4 tasks or 14 active minutes does not qualify; pooled median and SD across 3 features; no qualifying feature gives the default from `-StepDefaultMinutes`; coalesced intervals over a 7/13/20-minute sample sequence; SD `n/a` below the minimum count.
- Pause fixture: a tick interval that spans a stored pause yields the per-task seconds without the pause.
- Non-finite fixture: NaN and infinity inputs to every new rendered figure print `n/a`, and no line matches `NaN|Infinity`.
- State: v2-to-v3 migration keeps `startUnixSeconds`, `baselineWeeklyPct`, `durations`, and `items`, and sets `UseCurrentDoneTasks`; version 4 is empty state.
- Integration-level: update the entry goldens (`Get-EpicProgressReport.Tests.ps1`, `Get-EpicProgressReport.ItemMode.Tests.ps1`) with hand-derived values from fixture checkpoints that carry `max_parallel_features` and `depends_on`.
- The clock stays mocked through `Get-EpicProgressUtcNow`; all fixtures are in memory; no temporary files. The gate is one `Invoke-PoshQCParallelTest` run; per-file line coverage at least 85% for each new and changed script.

## Automation Feasibility

No third-party UI is involved. Every input is a local file, a `git`/`gh`/`cswap` command behind an existing wrapper seam, or the clock seam; all behavior is testable through Pester with mocks of those seams. Scheduling uses the Claude Code `CronCreate`, `CronList`, and `CronDelete` tools, which the skill only documents; no automation of a user interface is required.

## Pre-Mortem

- Review checklists: a reviewer will flag the SKILL.md contract test, the goldens, and the `prints no velocity, SD or range line` test as weakened if they are deleted rather than replaced; the plan must name each test in section 2 with its disposition and give each removed assertion a replacement that asserts the new behavior.
- Coverage: two new pure files and an optional parameter on `Get-EpicProgressTypeEstimate` can leave branches of the scheduler (cap exhaustion, wave fallback, cycle errors) unexercised; the plan must enumerate the fixtures in Testing Implications and read per-file figures from `artifacts/pester/powershell-coverage.xml` against the 85% line threshold, with the Phase 0 baseline for the changed files.
- Mirror parity: each changed or new skill file needs its bundle copy and new files need `core.json` entries; the `files.Count` pins (10), `productionPaths` (9), and `scanPaths` (11) fail otherwise. The plan must change copies, manifest, and pins in the same task set, and run the push-down contract tests listed in section 8. No execution-environment brief change is required.
- File size: the entry is at 495 lines and Gather at 358; adding wiring to the entry crosses the 500 guidance. The plan must keep new logic in `Velocity.ps1` and `Schedule.ps1`, put the manifest read in Gather, and keep SKILL.md under 500 lines because a contract test enforces it, even though Markdown is exempt from the file-size policy.
- Test isolation: new tests must not read or write state files, must not depend on the ambient clock or `$LASTEXITCODE`, and must not define global functions; the existing pattern (dot-source the hub in `BeforeAll`, mock seams in `BeforeEach`) must be reused so `Invoke-PoshQCLeakScan` finds nothing.
- CI-only behavior: Linux shards are case-sensitive, so the new file names must match their dot-source `Join-Path` strings exactly; ordinal sorting and invariant-culture formatting must be used in the scheduler tie-break and in printed numbers; the bundle hash comparison runs on LF-normalized checkouts.
- Evidence: golden values must be hand-derived and stated in test comments (as the existing goldens are); the Phase 0 baseline and final gate artifacts go under `FEATURE/evidence/baseline/` and `FEATURE/evidence/qa-gates/` with UTC write stamps; no count from an MCP PoshQC result may be cited.

## Risks

- R1. Pooled velocity with few features: a 2-to-3-feature epic gives an SD from 2 or 3 points, so the range is wide or `n/a`; the report must say why.
- R2. Contention bias persists: task samples measured under machine contention still lower each feature's rate; sequential velocity removes the parallel-count effect, not contention.
- R3. Ledger cap: `Merge-EpicProgressDuration` keeps 1000 execution samples across all features; a large epic can drop early features' samples and change their rates.
- R4. Manifest parsing: a block-style YAML `depends_on` list would not parse with a narrow reader; the fallback to waves must be visible in the output.
- R5. Behavior changes for existing users: the headline drops from the serial sum to the critical path, and the TL;DR gains a line, which changes push-notification text; the under-200-character rule must still hold (drop the running sentence first, as today).
- R6. SKILL.md 500-line pin while adding decisions and formats.

## Open Questions

- Q1. TL;DR line count: the spec says "4 lines plus a velocity line" and then lists four items (progress; elapsed and headline with chain and quota; velocity; range). Is the target four lines with velocity as one of them, or five lines? Is the `**Now:**` line kept?
- Q2. Is the default sequential rate taken from the execution default (`3600 / execution minutes`, 12 tasks per hour built in), or is a separate parameter wanted? A new parameter changes the 17-parameter pin and the 15-row parameter test.
- Q3. Blocked features in the critical path: exclude them and their dependents (recommended, with a stated exclusion), or schedule them at their remaining time?
- Q4. Tail steps: the catalog has `main-sync` and `integration-pr` (45 min default, which would cover PR, CI, and merge). Should a final main sync be predicted (this reverses D11), and should PR, CI, and merge become separate epic step types (changes the eleven-type catalog and the default table)?
- Q5. Range SD: pooled across-feature SD (recommended, matches "velocity plus or minus 2.05 SD" of the sequential rate) or the aggregate interval SD? Minimum count for SD: 2 features or 3 as in #1093?
- Q6. Is the wave-parallel figure retired or kept in the Full report?
- Q7. "Waiting for the machine": no recorded state signals it. Is execution-only active time sufficient, or should a gap between ticks above a threshold be treated as waiting?
- Q8. ORCHESTRATOR TO CONFIRM: PR #1124 is the pull request that delivered #1118 (history reached only through a code-review mention).

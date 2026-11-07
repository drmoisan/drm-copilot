# progress-report-orchestration-step-model — Spec

- **Issue:** #1118
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07
- **Status:** Approved for planning
- **Version:** 1.0
- **Work Mode:** full-feature
- **Requirements source:** `issue.md` (authoritative)
- **Research:** `research/research.2026-11-07T20-56.md`

## Overview

`.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` measures progress only by checked plan tasks (`- [x] [P#-T#]`) in each feature's original plan. On Epic #1019 this made review, PR, CI, merge, and main-sync time read as zero progress, left remediation cycles uncounted, and produced estimates that swung between 3 and 296 hours because executors tick tasks in batches.

This feature replaces the task-velocity model with a typed-step model. Every unit of work is a step with a type. Remaining time is the sum over types of the remaining steps of that type multiplied by the median measured duration of that type. Durations persist in the state file across runs. Blocked work is excluded by recorded checkpoint state. The report covers epics and standalone items.

## Step Model

### Step types

| Type | Scope | Done when (primary source; fallback) |
|---|---|---|
| `research` | item | closed `stage_timing` `research` entry; `completed_steps` prefix `S2_research` |
| `spec` | item | closed `stage_timing` `spec` entry; `S3_promotion` present and `spec.md` exists |
| `plan` | item | closed `stage_timing` `planning` or `plan` entry; `S4_atomic_planning` |
| `preflight` | item | closed `stage_timing` `preflight` entry; first checked plan task or `step5_status` past `pending` |
| `execution` | item | one step per `[P#-T#]` checkbox in the plan or remediation plan; done when checked |
| `review` | item | closed `stage_timing` `review` entry; `S7_feature_review`, or one per `remediation_loop.review_outcomes[]` entry |
| `pr` | item | closed `stage_timing` `pr` entry; `S8_create_pr` or `pr_gate.pr_number` |
| `ci` | item | closed `stage_timing` `ci` entry; `step9_status` `passed` |
| `merge` | item | epic row `merge_status` `merged` or `worktree_removed`, a merged PR, or a recorded merge |
| `main-sync` | epic | sync row in the epic checkpoint with `merge_status` `merged` or `worktree_removed` |
| `integration-pr` | epic | `epic_merge_pr.merge_commit_sha` present |

Stage-name normalization: `planning` and `plan` map to `plan`. `remediation`, `remediation_cycle_<n>`, and similar names are composite remediation stages (Decision D2). Any other unrecognized stage name (for example `promotion`) maps to no type; its time is reported as unmapped stage time and never enters a median.

### Step derivation per item

- Initial run: one step of each item type, plus one `execution` step per plan task.
- Each opened `remediation_loop.cycles[]` entry adds: `plan` and `preflight` steps unless `remediation_path` is `light` (a missing key is treated as full); one `execution` step per task in the file named by the cycle's `plan_path` (a remediation plan, or the `## Light Fix Tasks` of a light remediation-inputs file, both counted by `Get-EpicProgressTaskCount`); one `review` step (the re-audit); and one `ci` step when the cycle opened after a PR existed.
- Cycles not yet opened are not predicted. Totals grow when a cycle opens, and the completion percentage can fall. This is intended.
- In-progress step: the open `stage_timing` entry (null `ended_at`); otherwise the step mapped from `next_step`.
- A step instance with several recorded attempts counts one step per attempt (Decision D4).

### Durations and the estimate

- Each completed step contributes duration samples to its type. Sample record: key, type, seconds, source (`stage_timing`, `tick`, `epic_row`, `artifact_stamp`, `cycle_entry`), approximate flag, recorded time. The key de-duplicates samples across runs; a `stage_timing` sample replaces a `tick` sample with the same execution-task key.
- Batched-tick split: the state keeps, per item and plan file, the set of checked task ids and the last tick time. Tasks newly checked at time `t` each receive `(t - lastTick - blocked seconds in the interval) / (number of newly checked tasks)`. The first observation of an item seeds the anchor from the `execution` stage start when recorded, otherwise from `t` with no sample. When the `execution` stage closes, per-task samples become the stage duration divided by the task count.
- Median: an odd count takes the middle value; an even count averages the middle pair. It is computed over all retained samples of a type (implemented in the skill, not imported from `scripts/dev-tools/StageTiming.psm1`).
- Retention: durations are not limited by `-SampleCap`. A per-type ceiling of the newest 1000 samples bounds the file size. The check-in `samples` array keeps `-SampleCap`.
- Remaining time per type: `remaining(T) × median(T)`, plus, for each in-progress step, `max(0, median(T) - elapsed in step)`, flagged `over median` when elapsed exceeds the median. The headline is the sum over types (Decision D7).
- Wave-parallel: a secondary figure. Per-feature remaining sums are combined with the existing wave rule (largest per open wave, summed), plus the epic-level steps.
- Completion percentage: done steps divided by total steps (Decision D8).

### Default durations

Used only when a type has no retained sample, and always labelled `default` in the output. Overridable per type with `-StepDefaultMinutes` (Decision D5).

| Type | Default | Basis |
|---|---|---|
| research | 13 min | #1096 and #1105 stage timing |
| spec | 6 min | #1096 and #1105 stage timing |
| plan | 11 min | #1096 and #1105 stage timing |
| preflight | 10 min | #1096 stage timing |
| execution | 5 min per task | #1096 and #1105 stage timing; `SKILL.md` measured rates |
| review | 14 min | #1096 and #1105 stage timing |
| pr | 3 min | #1096 and #1105 stage timing |
| ci | 17 min | #1096 and #1105 stage timing, excluding a run where no CI executed |
| merge | 5 min | stated assumption |
| main-sync | 60 min | stated assumption |
| integration-pr | 45 min | stated assumption |

### Blockage by recorded state

An item is blocked when any of the following holds (Decision D1):

- checkpoint `blocked_reason` is set to a value other than `none` or `awaiting_ci`;
- a `human_interaction.requirements[]` entry has `response: "halt"`;
- `step6_status` is `blocked_remediation_loop_limit` or `step9_status` is `blocked_ci_loop_limit`;
- the epic row `merge_status` is `blocked_conflict_loop_limit`.

Effects: the item's remaining steps are reported as blocked, excluded from the remaining-time sum, and listed with their would-be subtotal; the tick split subtracts the blocked span (tracked as `blockedSinceUnixSeconds` per item); an in-progress step accrues no elapsed time while blocked. A zero tick rate is never a blockage signal.

## Inputs / Outputs

- Inputs: the item checkpoint `artifacts/orchestration/orchestrator-state.json` in each live child worktree (located with the existing `ConvertFrom-EpicProgressWorktreeList` map and read through `Test-EpicProgressPath` and `Read-EpicProgressFile`); plan, remediation-plan, and light remediation-inputs texts (paths from the kickoff and from `cycles[].plan_path`); the epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json` (feature rows, main-sync rows, `epic_merge_pr`); the existing kickoff, PR, and quota sources.
- Outputs: TL;DR and Full reports on standard output; the version 2 state file.
- The git call set is unchanged: `fetch`, `worktree list`, and `show` only (Decision D3).

## API / CLI Surface

- `Epic` parameter set (default): all existing parameters keep their names, types, defaults, mandatory status, and validation attributes. `-EpicFolder` stays mandatory with `ValidateNotNullOrEmpty`; `-SampleCap` keeps `ValidateRange(1, 100000)` and default 14; `-Mode` keeps `ValidateSet('TLDR','Full')` and default `Full`; `-ResetBaseline` with `-PairSamples` still throws before any I/O. `-WaveOverheadHours` stays accepted; the planner documents whether it still affects any figure.
- `Item` parameter set (new, Decision D9): mandatory `-Issue <n>`. The worktree whose checkpoint `issue-num` equals `<n>` is located through the worktree map. No kickoff, epic checkpoint, or epic-level steps are used. Default state path `.claude/state/progress-item-<n>.json`. `-EpicFolder` and `-Issue` are in different parameter sets and cannot be combined.
- `-StepDefaultMinutes <hashtable>` (new, both sets): per-type override of the default durations. Unknown type keys or non-positive values fail with a clear error before any I/O.
- `scripts/dev-tools/Get-EpicProgressReport.ps1` remains a forwarder and needs no change while the canonical file name is unchanged.

### Output formats

TL;DR remains four lines in both modes:

```text
**TL;DR:** Epic #<issue> is at <done> of <total> steps (<pct>%). <done-sentence> <running-sentence>
**Elapsed:** <H h MM min>, with about <hours> hours left on the per-type estimate (<b> blocked steps excluded). **Weekly** quota is at <weekly>.
**Now:** #<i> <type> (<elapsed> of median <m>)[, ...]. <k> of <n> types use defaults.
**Estimated time remaining:** <H h MM min> by type (sum); <H h MM min> wave-parallel.
```

In item mode the subject reads `Item #<issue>` and the wave-parallel figure equals the item sum. A blocked item reads `#<i> is blocked (<reason>).`

Full mode keeps the heading, the Elapsed and Progress line (in steps), the State table (with a `Blocked` row), the Wave table (`| Wave | Children | Steps | Done |`), and the weekly-quota line. It replaces the velocity, straight-line, and range lines with a per-type table (`| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |` and a Total row), one line per type that uses a default (`<type>: no measured duration; default <n> min`), an unmapped and composite stage-time line, and a marker on medians that include approximate samples. The velocity, SD, and range lines are not printed.

## Data & State

Version 2 state document: `version: 2`, `unit: "steps"`, `startUnixSeconds`, `baselineDone`, `baselineWeeklyPct`, `samples` (check-ins in steps), `durations` (per-type sample lists), and `items` (per-item plan tick anchors and `blockedSinceUnixSeconds`). Times are epoch seconds.

- Migration: a version 1 document and the legacy bare sample array are read. Their `samples` and `baselineDone` count tasks, so they are discarded; `baselineDone` resolves to the current step count; `startUnixSeconds` and `baselineWeeklyPct` are kept; `durations` and `items` start empty. Version 3 or higher, blank text, and unparseable text give empty state, as today.
- Writing: the writer always writes version 2. The state is written when the check-in samples, the duration ledger, or the tick anchors changed, or when `-ResetBaseline` or `-PairSamples` was passed. `Write-EpicProgressState` remains the only writer.
- `-ResetBaseline` clears `samples` and blocked spans and keeps `durations` and tick anchors (Decision D10). `-PairSamples` affects `samples` only.
- Durations are kept per state file (Decision D12).

## Decisions

Each decision below is an orchestrator default, adopted for autonomous delivery. The owner may revisit any of them.

- **D1 (Q1) Missed handoff.** A missed handoff is not detected. Only recorded fields exclude time: `blocked_reason` other than `none` or `awaiting_ci`, a `human_interaction` requirement with response `halt`, `step6_status` `blocked_remediation_loop_limit`, `step9_status` `blocked_ci_loop_limit`, and epic row `merge_status` `blocked_conflict_loop_limit`. The issue's "missed handoff" wording is therefore narrowed to recorded state. Orchestrator default; the owner may revisit.
- **D2 (Q2) Composite remediation stages.** The orchestrate skill is not changed. A composite remediation `stage_timing` entry gives no per-type samples and is reported as unmapped composite time. Remaining remediation steps use the medians of the same types. Tick-observed execution samples inside a cycle are still recorded. Orchestrator default; the owner may revisit.
- **D3 (Q3) Pre-#1097 approximations.** No `git log` or `git ls-tree` call is added. Approximate durations for checkpoints without `stage_timing` come only from epic rows (`worktree_created_at` to `merge_confirmed_at`), review artifact stamps named by checkpoint paths, and `remediation_loop.cycles[].entry_timestamp` differences, each marked approximate. This is a deliberate narrowing of the issue's constraint, which mentions commit times. A consequence is that durations of a child whose worktree was removed before the report first observed it are not recovered; its done steps count as done with no samples. Orchestrator default; the owner may revisit.
- **D4 (Q4) Attempts.** Each recorded attempt is one step and gives one sample. Orchestrator default; the owner may revisit.
- **D5 (Q5) Defaults.** The default durations in `### Default durations`, overridable with `-StepDefaultMinutes`. Orchestrator default; the owner may revisit.
- **D6 (Q6) Prepared plans.** A child with no checkpoint whose plan already exists on the integration branch counts `research`, `spec`, and `plan` as done before measurement, with no samples. Orchestrator default; the owner may revisit.
- **D7 (Q7) Headline.** The headline estimate is the serial sum over types, matching the owner's formula. The wave-parallel figure is secondary. Orchestrator default; the owner may revisit.
- **D8 (Q8) Percentage.** Completion percentage is by step count. Orchestrator default; the owner may revisit.
- **D9 (Q9) Standalone items.** A new `Item` parameter set with mandatory `-Issue <n>`. Orchestrator default; the owner may revisit.
- **D10 (Q10) Reset.** `-ResetBaseline` keeps the duration history and the tick anchors. Orchestrator default; the owner may revisit.
- **D11 (Q11) Main syncs.** Main syncs are counted only once recorded in the epic checkpoint; future syncs are not predicted. Orchestrator default; the owner may revisit.
- **D12 (Q12) Durations pool.** Durations are kept per state file, not in a shared ledger. Orchestrator default; the owner may revisit.
- **D13 Velocity output.** The velocity, SD, and range lines are dropped from both formats. The planner decides whether `Get-EpicProgressRecentVelocityInterval`, `Get-EpicProgressStandardDeviation`, and `Get-EpicProgressRangeText` are removed; removal includes their tests. Orchestrator default; the owner may revisit.

## Constraints & Risks

- PowerShell only. No Python is added to the skill; `pytest` runs only the existing push-down contract tests.
- Logic stays pure; all I/O goes through seams in the entry script. Write commands stay inside `Write-EpicProgressState`, and native calls stay inside `Invoke-GitExe`, `Invoke-GhExe`, and `Invoke-CswapExe`.
- Tests use in-memory fixtures and mocked seams. No test creates a temporary file, reads gitignored `artifacts/` state, or writes `$global:` state. Fixtures use the `example-epic` name and `/fixture-repo` roots.
- The parallel gates are one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run.
- `stage_timing` names are not a closed vocabulary; unrecognized names must not fail the report.
- The entry script is close to the 500-line guidance tier; gathering logic goes into new dot-sourced files (research section 6.11 proposes `Steps`, `Durations`, and `Gather` files).
- Every new skill file must be byte-identical in the Claude bundle and listed once in `pack-manifests/core.json`, or the push-down contract tests fail.
- Risk: the defaults rest on two committed stage-timing records. They are labelled as defaults in every report line that uses them.

## Implementation Strategy

- Add pure functions for the step catalog, stage-name normalization, `stage_timing` parsing, checkpoint-to-steps derivation, cycle expansion, and blocked classification.
- Add pure functions for the median, sample keys and merge, tick split, defaults, the per-type estimate, and the wave-parallel combination.
- Add gathering helpers that read item checkpoints and remediation texts through the existing seams, keeping `Invoke-EpicProgressReport` near its current size.
- Extend `Get-EpicProgressReport.State.ps1` with the version 2 reader, writer, and migration.
- Update `Get-EpicProgressReport.Render.ps1` (or add a step-render file) for the new formats.
- Update the hub to dot-source new files; update `SKILL.md`, the bundle mirror, `core.json`, and `extensions/drm-copilot/CHANGELOG.md`.
- Every test disposition listed in research section 2 is named in the plan.
- No new dependency.

## Acceptance Criteria

- [ ] Every counted step carries a type from the `## Step Model` catalog; each plan task is one `execution` step; each opened remediation cycle adds its `plan` and `preflight` steps (full cycles only), one `execution` step per task in its `plan_path` file, a `review` step, and a `ci` step when opened after a PR existed. A unit test shows the total growing and the completion percentage falling when a cycle opens, and a light cycle adding no `plan` or `preflight` step.
- [ ] The headline estimate equals the sum over types of remaining steps multiplied by that type's median (with in-progress credit as specified), and the Full report shows a per-type table with done, in-progress, remaining, blocked, median, sample count, and subtotal columns. Verified by unit tests with known samples and by the Full golden.
- [ ] A type with no retained sample is reported as `<type>: no measured duration; default <n> min` and marked `default` in the per-type table; the value comes from the default table or `-StepDefaultMinutes`, never a silent zero. Verified by unit tests for both the built-in default and an override.
- [ ] Blocked time is excluded by recorded state only: a unit test per recorded field in Decision D1 shows the item's remaining steps excluded from the headline sum and listed as blocked, the blocked span subtracted from the tick split, and no elapsed accrual while blocked; `awaiting_ci` and a zero tick rate do not mark an item blocked.
- [ ] An in-progress `review`, `ci`, or `main-sync` step appears on the TL;DR `**Now:**` line with its elapsed time against its median, and two runs at different times with no new checked tasks produce a lower remaining estimate on the later run. Verified by unit tests.
- [ ] Batched ticks are split: tasks newly checked between two runs each receive the interval (less blocked seconds) divided by the number of tasks checked, and a closed `execution` stage replaces those tick samples with stage-duration-per-task samples. Verified by unit tests.
- [ ] Durations persist across runs beyond the sample cap: the version 2 `durations` ledger retains more samples per type than `-SampleCap`, de-duplicates by sample key across runs, and is kept by `-ResetBaseline`. Verified by unit tests.
- [ ] A version 1 state document and the legacy bare sample array are read and migrated to version 2: task-count samples are discarded, `baselineDone` resolves to the current step count, `startUnixSeconds` and `baselineWeeklyPct` are kept, and the next write is version 2 with `unit: "steps"`. Version 3 or higher, blank, and unparseable text give empty state. Verified by unit tests.
- [ ] CLI backward compatibility: `-EpicFolder documentation-estate-tooling -Mode TLDR` and `-EpicFolder <folder>` (Full) bind and run; every existing parameter keeps its name, type, default, mandatory status, and validation attribute; `-ResetBaseline` with `-PairSamples` still throws before I/O; the forwarder tests in `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` pass unchanged.
- [ ] Standalone item mode: the `Item` parameter set with mandatory `-Issue <n>` reports one item from its worktree checkpoint without reading a kickoff or epic checkpoint, includes no epic-level steps, uses `.claude/state/progress-item-<n>.json` by default, and rejects a combination with `-EpicFolder`. Verified by unit tests with mocked seams.
- [ ] The TL;DR output stays four lines in epic and item mode, verified by the TL;DR goldens, and the velocity, SD, and range lines no longer appear in either format.
- [ ] Composite remediation stage time and unrecognized stage names are reported as unmapped time in the Full report and contribute no samples; approximate samples (Decision D3) are marked approximate. Verified by unit tests.
- [ ] The git call set stays `fetch`, `worktree list`, and `show`; write commands remain only in `Write-EpicProgressState`; native calls remain only in `Invoke-GitExe`, `Invoke-GhExe`, and `Invoke-CswapExe`. Verified by the repository-constraints tests.
- [ ] `.claude/skills/epic-progress-report/SKILL.md` describes the step model, the default durations and their basis, the decisions, the new parameters, the new report formats, and the version 2 state file, no longer states that the report wording does not change, and stays under 500 lines; its bundle copy under `extensions/drm-copilot/resources/claude-customizations/` is byte-identical; `EpicProgressReport.SkillContract.Tests.ps1` is updated to match.
- [ ] Every new script file is listed once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, has a byte-identical bundle copy, and is included in the repository-constraints `productionPaths` and forbidden-token scan list; the push-down contract tests pass.
- [ ] No production file added or changed by this feature exceeds 500 logical lines where a logical split exists, and none exceeds 800 logical lines, measured with `@(Get-Content -LiteralPath <path>).Count` and recorded under `evidence/`.
- [ ] Unit tests use in-memory fixtures with no temporary files, and `Invoke-PoshQCLeakScan` reports no leak for the skill's test files.
- [ ] One `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run pass with zero failures, and each new or changed production file under the skill meets 85% line coverage.

## Definition of Done

- [ ] All acceptance criteria above are checked off with evidence.
- [ ] Toolchain loop passes (format, lint, tests, contract checks).
- [ ] `extensions/drm-copilot/CHANGELOG.md` records the change.

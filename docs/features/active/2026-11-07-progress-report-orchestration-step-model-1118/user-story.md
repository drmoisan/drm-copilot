# `progress-report-orchestration-step-model` — User Story

- Issue: #1118
- Owner: drmoisan
- Status: Approved for planning
- Last Updated: 2026-11-07
- Spec: `spec.md` (design, decisions, and formats)

## Story Statement

- As the repository owner running an epic, I want the progress report to count review, PR, CI, merge, main-sync, and remediation work as typed steps, so that the report shows progress while that work runs instead of appearing stalled.
- As the repository owner, I want the remaining-time estimate to be the per-type median duration multiplied by the remaining steps of each type, with the breakdown visible, so that I can judge the estimate and see which step types drive it.
- As the repository owner, I want blocked work excluded only when the checkpoint records it, so that the estimate does not change because executors tick tasks in batches.
- As the repository owner running a single item outside an epic, I want the same report for that item, so that I do not need an epic folder to track it.

## Problem / Why

`.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` measures only checked plan tasks in each feature's original plan. On Epic #1019 on 2026-11-07, review, PR, CI, merge, and main-sync time read as zero progress (for example, nine zero intervals from 18:09Z to 20:20Z while #1037 was in review and CI and a main sync ran); #1034's four remediation cycles were never counted; and batched ticks made ten-minute rates swing between 0 and 161 tasks per hour, with estimates from 3 to 296 hours.

## Personas & Scenarios

- Persona: repository owner and epic operator.
  - Runs several orchestrated children in parallel and receives the TL;DR on a schedule as a push notification.
  - Cares about an estimate that moves in the right direction and about seeing when work is blocked on a decision.
  - Constraint: the report must keep working with the existing scheduling prompts (`-EpicFolder <folder> -Mode TLDR`) and the existing state file.
- Scenario: review and CI in progress.
  - Child #A has finished execution and is in review, then CI. No plan task changes for two hours.
  - The scheduled TL;DR shows `#A review (12 min of median 14 min)`, then `#A ci (...)`, and the remaining estimate falls between runs.
  - Outcome: the owner sees the epic advancing without opening the checkpoint.
- Scenario: a remediation cycle opens.
  - The review on child #B returns blocking findings and a full remediation cycle opens with an eleven-task remediation plan.
  - The next report adds the cycle's plan, preflight, execution, review, and CI steps; the step total grows and the percentage falls.
  - Outcome: the owner sees the added work and its estimated time.
- Scenario: a blocked item.
  - Child #C records `blocked_reason: human_decision_required`.
  - The report lists #C as blocked with its reason, excludes its remaining steps from the headline, and shows their would-be subtotal.
  - Outcome: the owner knows a decision is pending and the estimate does not include time that cannot proceed.
- Scenario: a standalone item.
  - The owner runs the report with `-Issue <n>` for an item outside any epic.
  - The report reads that item's worktree checkpoint and prints the same TL;DR and Full formats with no epic-level steps.

## Acceptance Criteria

- [x] Every counted step carries a type from the `spec.md` `## Step Model` catalog; each plan task is one `execution` step; each opened remediation cycle adds its `plan` and `preflight` steps (full cycles only), one `execution` step per task in its `plan_path` file, a `review` step, and a `ci` step when opened after a PR existed. A unit test shows the total growing and the completion percentage falling when a cycle opens, and a light cycle adding no `plan` or `preflight` step.
- [x] The headline estimate equals the sum over types of remaining steps multiplied by that type's median (with in-progress credit as specified in `spec.md`), and the Full report shows a per-type table with done, in-progress, remaining, blocked, median, sample count, and subtotal columns. Verified by unit tests with known samples and by the Full golden.
- [x] A type with no retained sample is reported as `<type>: no measured duration; default <n> min` and marked `default` in the per-type table; the value comes from the default table or `-StepDefaultMinutes`, never a silent zero. Verified by unit tests for both the built-in default and an override.
- [x] Blocked time is excluded by recorded state only: a unit test per recorded field in `spec.md` Decision D1 shows the item's remaining steps excluded from the headline sum and listed as blocked, the blocked span subtracted from the tick split, and no elapsed accrual while blocked; `awaiting_ci` and a zero tick rate do not mark an item blocked.
- [x] An in-progress `review`, `ci`, or `main-sync` step appears on the TL;DR `**Now:**` line with its elapsed time against its median, and two runs at different times with no new checked tasks produce a lower remaining estimate on the later run. Verified by unit tests.
- [x] Batched ticks are split: tasks newly checked between two runs each receive the interval (less blocked seconds) divided by the number of tasks checked, and a closed `execution` stage replaces those tick samples with stage-duration-per-task samples. Verified by unit tests.
- [x] Durations persist across runs beyond the sample cap: the version 2 `durations` ledger retains more samples per type than `-SampleCap`, de-duplicates by sample key across runs, and is kept by `-ResetBaseline`. Verified by unit tests.
- [x] A version 1 state document and the legacy bare sample array are read and migrated to version 2: task-count samples are discarded, `baselineDone` resolves to the current step count, `startUnixSeconds` and `baselineWeeklyPct` are kept, and the next write is version 2 with `unit: "steps"`. Version 3 or higher, blank, and unparseable text give empty state. Verified by unit tests.
- [x] CLI backward compatibility: `-EpicFolder documentation-estate-tooling -Mode TLDR` and `-EpicFolder <folder>` (Full) bind and run; every existing parameter keeps its name, type, default, mandatory status, and validation attribute; `-ResetBaseline` with `-PairSamples` still throws before I/O; the forwarder tests in `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` pass unchanged.
- [x] Standalone item mode: the `Item` parameter set with mandatory `-Issue <n>` reports one item from its worktree checkpoint without reading a kickoff or epic checkpoint, includes no epic-level steps, uses `.claude/state/progress-item-<n>.json` by default, and rejects a combination with `-EpicFolder`. Verified by unit tests with mocked seams.
- [x] The TL;DR output stays four lines in epic and item mode, verified by the TL;DR goldens, and the velocity, SD, and range lines no longer appear in either format.
- [x] Composite remediation stage time and unrecognized stage names are reported as unmapped time in the Full report and contribute no samples; approximate samples (`spec.md` Decision D3) are marked approximate. Verified by unit tests.
- [x] The git call set stays `fetch`, `worktree list`, and `show`; write commands remain only in `Write-EpicProgressState`; native calls remain only in `Invoke-GitExe`, `Invoke-GhExe`, and `Invoke-CswapExe`. Verified by the repository-constraints tests.
- [x] `.claude/skills/epic-progress-report/SKILL.md` describes the step model, the default durations and their basis, the decisions, the new parameters, the new report formats, and the version 2 state file, no longer states that the report wording does not change, and stays under 500 lines; its bundle copy under `extensions/drm-copilot/resources/claude-customizations/` is byte-identical; `EpicProgressReport.SkillContract.Tests.ps1` is updated to match.
- [x] Every new script file is listed once in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, has a byte-identical bundle copy, and is included in the repository-constraints `productionPaths` and forbidden-token scan list; the push-down contract tests pass.
- [x] No production file added or changed by this feature exceeds 500 logical lines where a logical split exists, and none exceeds 800 logical lines, measured with `@(Get-Content -LiteralPath <path>).Count` and recorded under `evidence/`.
- [x] Unit tests use in-memory fixtures with no temporary files, and `Invoke-PoshQCLeakScan` reports no leak for the skill's test files.
- [x] One `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run pass with zero failures, and each new or changed production file under the skill meets 85% line coverage.

## Non-Goals

- No change to the orchestrate skill or to the `stage_timing` format (typed remediation sub-stages are not added).
- No `git log` or `git ls-tree` call; no commit-time duration derivation.
- No detection of missed handoffs beyond recorded checkpoint fields.
- No prediction of future remediation cycles or main syncs.
- No shared duration ledger across epics and standalone items.
- No import of `scripts/dev-tools/StageTiming.psm1` into the skill.
- No Python in the skill.

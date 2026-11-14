# Research: progress report orchestration step model (Issue #1118)

- Issue: #1118
- Branch: feature/progress-orchestration-step-model
- Requirements source: `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/issue.md`
- Timestamp: 2026-11-07T20-56 (UTC; read from the `timeapi.io` UTC endpoint because the researcher has no shell clock route)
- Scope: research only; no source, configuration, or test file was changed.

## 1. Current State

### 1.1 Script set and functions

All five production files live in `.claude/skills/epic-progress-report/scripts/`. The entry script dot-sources the Logic hub, and the hub dot-sources State, Metrics, and Render. Every logic function is pure. Every I/O call goes through a wrapper in the entry script.

| File | Size (as read) | Functions |
|---|---|---|
| `Get-EpicProgressReport.ps1` (entry) | about 475 lines, close to the 500-line guidance tier | `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Test-EpicProgressCommand`, `Test-EpicProgressPath`, `Read-EpicProgressFile`, `Write-EpicProgressState` (the only writer, `SupportsShouldProcess`), `Get-EpicProgressUtcNow`, `Get-EpicProgressLastExitCode`, `Invoke-EpicProgressReport` (wiring), and the entry-point block, which is skipped when the file is dot-sourced |
| `Get-EpicProgressReport.Logic.ps1` (hub) | about 248 | `Test-EpicProgressJsonText`, `ConvertFrom-EpicProgressKickoffRow`, `Get-EpicProgressIssueFromKickoff`, `ConvertFrom-EpicProgressWorktreeList`, `ConvertFrom-EpicProgressPrList`, `Get-EpicProgressWeeklyQuota`, `Get-EpicProgressTaskCount`, `Get-EpicProgressCurrentPhase`, `Get-EpicProgressFeatureState` |
| `Get-EpicProgressReport.State.ps1` | about 286 | `Select-EpicProgressSample`, `Resolve-EpicProgressSetting`, `ConvertFrom-EpicProgressStateText`, `ConvertTo-EpicProgressStateJson`, `Resolve-EpicProgressBaseline`, `Merge-EpicProgressSamplePair` |
| `Get-EpicProgressReport.Metrics.ps1` | about 232 | `Format-EpicProgressHour`, `Format-EpicProgressClock`, `Format-EpicProgressNumber`, `Get-EpicProgressAverageVelocity`, `Get-EpicProgressRecentVelocityInterval`, `Get-EpicProgressStandardDeviation`, `Get-EpicProgressCriticalPath`, `Get-EpicProgressRangeText`, `Get-EpicProgressWeeklyText` |
| `Get-EpicProgressReport.Render.ps1` | about 196 | `Get-EpicProgressSummary`, `Get-EpicProgressTldrLine`, `Get-EpicProgressFullLine` |

The sizes were read from the Read tool view, which shows a final empty row. The planner should confirm logical line counts with `@(Get-Content -LiteralPath <path>).Count` before sizing tasks. The entry file has about 25 lines of headroom under the 500-line guidance tier. It must not take the new gathering logic.

`scripts/dev-tools/Get-EpicProgressReport.ps1` is a parameterless forwarder that passes `@args` to the canonical script. It needs no change as long as the canonical script keeps its file name.

### 1.2 CLI parameters (backward-compatibility surface)

The `param()` block of the entry script declares 15 parameters: `EpicFolder` (mandatory, `ValidateNotNullOrEmpty`), `StartUtc`, `EpicIssue`, `IntegrationBranch`, `KickoffPath`, `RepositoryRoot`, `CheckpointPath`, `StatePath`, `BaselineDone`, `BaselineWeeklyPct`, `WaveOverheadHours` (default 1.25), `SampleCap` (`ValidateRange(1, 100000)`, default 14), `Mode` (`ValidateSet('TLDR','Full')`, default `Full`), `ResetBaseline`, `PairSamples`. `-ResetBaseline` and `-PairSamples` together throw before any I/O.

The required compatible invocations are `-EpicFolder <folder> -Mode TLDR` and `-EpicFolder <folder>` (Full). The scheduling prompts in `SKILL.md` (`## Scheduling Prompts`) pass only `-EpicFolder` and `-Mode TLDR`, so these two forms are the compatibility contract. The forwarder child-process tests depend on the `SampleCap` `ValidateRange` and the `Mode` `ValidateSet` (section 2).

### 1.3 Discovery of features and plans (`Invoke-EpicProgressReport`)

1. `Resolve-EpicProgressSetting` applies these defaults: integration branch `origin/epic/<EpicFolder>-integration`, kickoff `docs/features/epics/<EpicFolder>/epic-kickoff.md`, epic checkpoint `<root>/artifacts/orchestration/epic-orchestrator-state.json`, and state file `<root>/.claude/state/epic-progress-<EpicFolder>.json`.
2. The state file is read before the first git call. The start is resolved and throws when no start is found.
3. Git calls, in order: `fetch -q origin` (a non-zero exit code produces a warning), `worktree list --porcelain` (parsed into a branch-to-path map), and `show <integration>:<kickoff>`.
4. The feature list, waves, bands, and plan paths come from the kickoff feature-summary table (`ConvertFrom-EpicProgressKickoffRow`). The epic issue comes from `-EpicIssue` or from the kickoff `Epic issue: #<n>` line.
5. For each epic checkpoint `features[]` entry keyed by `issue_num`, the script reads `branch_name` and `merge_status` (default `not_started`).
6. `gh pr list --head <branch> --state all --json number,state` runs only when gh is installed.
7. Plan text is read from `<worktree of branch>/<PlanPath>` when that branch has a live worktree, and otherwise through `git show <integration>:<PlanPath>`. Only the original plan path from the kickoff is read. Remediation plans, light-fix tasks, and item checkpoints are never read.
8. `cswap list --json` runs when cswap is installed and supplies the weekly quota.
9. Sampling: `Select-EpicProgressSample` adds `{ts, done}` when the last sample is 90 seconds old or older and keeps the newest `SampleCap`. The state is written only when the sample set changed or when `-ResetBaseline` or `-PairSamples` was passed.

The script does not read item checkpoints (`artifacts/orchestration/orchestrator-state.json` inside child worktrees) or `stage_timing`. It has no standalone-item mode, because `-EpicFolder` and the kickoff are required.

### 1.4 Version 1 state file

- Path: `.claude/state/epic-progress-<EpicFolder>.json`, gitignored and kept per checkout. It can be overridden with `-StatePath`.
- Document written by `ConvertTo-EpicProgressStateJson`: `{ version: 1, startUnixSeconds, baselineDone, baselineWeeklyPct, samples: [ {ts, done} ] }`. Epoch seconds are used because `ConvertFrom-Json` turns ISO strings into local `DateTime` values.
- Reader (`ConvertFrom-EpicProgressStateText`): accepts version 1 and the legacy bare sample array. Any other version, blank text, or unparseable text gives empty state. A missing field reads as `$null`.
- Sample cap: `-SampleCap`, default 14. History beyond the cap is discarded. The issue names this cap as the history-loss problem.

### 1.5 Current output formats

The TL;DR block has four lines: `**TL;DR:** Epic #<issue> is at <done> of <total> tasks (<pct>%). <done-sentence> <running-sentence>`, the `**Elapsed:** ... hours left on the wave-parallel estimate. **Weekly** quota ...` line, the `**Avg Velocity:** ... **Recent Velocity:** ... (SD of recent velocity: ...)` line, and the `**Estimated time remaining:** <range>` line. Full mode adds the status heading, the Elapsed and Progress line, the State table (`Completed`, `Running` with phase and PR, `Pending, wave <w>`), the Wave table with its Total row, the Velocity and Remaining line, the straight-line and wave-parallel lines, and the weekly-quota line. `SKILL.md` `## Report Formats` states that the wording "does not change". This feature must update that statement.

## 2. Existing Tests and the Behavior Changes They Pin

Location: `tests/scripts/claude-skills/epic-progress-report/` (six files) and `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (the forwarder). The tests use only in-memory fixtures. The entry script is dot-sourced with `-EpicFolder 'example-epic' -StartUtc ...`, which skips the entry-point block. Every seam is mocked with a matching signature: `Invoke-GitExe` returns kickoff and plan lines from hashtables, `Test-EpicProgressPath` and `Read-EpicProgressFile` read a `$script:fileText` map, `Write-EpicProgressState` records to a list, and `Get-EpicProgressUtcNow` and `Get-EpicProgressLastExitCode` return fixed values. Two tests read the committed script file itself, and one runs `-WhatIf` against an absent path. No temporary file is created.

| Test file | What it pins | Disposition under this feature |
|---|---|---|
| `Get-EpicProgressReport.Tests.ps1` `Describe 'Invoke-EpicProgressReport'` | Exact TL;DR and Full goldens (`expectedTldr`, `expectedFull`, `prints the Full golden for a legacy four-sample state` with 26 lines); `passes only fetch, show and worktree list to git` (the exact git call list); `passes only pr list to gh`; the state-write content (`samples`, `startUnixSeconds`, `baselineDone`); reset and pairing writes; `treats an unparseable state file as empty` | **Changes.** The goldens change with the new wording. The git call list changes if item checkpoints or stage-timing files are read through `git show` or `git ls-tree`, or if `git log` is added. The state-write assertions change with version 2. Reset and pairing tests change if the samples change meaning (tasks to steps). |
| Same file, `Describe 'Get-EpicProgressReport.ps1 repository constraints'` | `$script:productionPaths.Count` is 5; exactly 2 write commands (`New-Item`, `Set-Content`), both in `Write-EpicProgressState`; exactly 3 native calls in their wrappers; the forbidden tokens `documentation-estate-tooling`, `1019`, `/workspaces`, and `2026-11-04T13:55`, plus no drive-letter path, over 7 scan paths; the param block holds 15 parameters, all documented; the first example uses `-EpicFolder example-epic` | **Changes.** Every new dot-sourced file must be added to `productionPaths` (count 5 becomes 5 + N) and to the scan list (7 becomes 7 + N). The parameter count changes if any parameter is added (section 6.9). The write and native counts must stay 2 and 3. A new read seam is not a write. |
| `Get-EpicProgressReport.Logic.Tests.ps1` | Kickoff parsing, issue marker, worktree map, PR list, weekly quota, `Get-EpicProgressTaskCount`, `Get-EpicProgressCurrentPhase`, `Get-EpicProgressFeatureState` | Unaffected if these functions are kept unchanged and only new functions are added. |
| `Get-EpicProgressReport.State.Tests.ps1` | Sample rule, settings defaults, v1 read and write (`reads a version-1 document`, `treats an unknown version as empty state`, `round-trips integer epoch seconds`), baseline resolution, pairing | **Changes** where version 2 is introduced. `treats an unknown version as empty state` must use a version other than 1 or 2. The writer test changes if `ConvertTo-EpicProgressStateJson` writes version 2. The alternative is a new writer function, with the v1 writer kept only for its tests or removed together with its tests. |
| `Get-EpicProgressReport.Metrics.Tests.ps1` | Formatters, velocity, SD, critical path, range text | Unaffected if the functions are kept. They become dead code if the step model removes the velocity lines (section 6.8). Dead code that stays under coverage is acceptable, and removing it requires removing its tests too. |
| `Get-EpicProgressReport.Render.Tests.ps1` | TL;DR and Full composition goldens, n/a handling | **Changes** with the new formats. |
| `EpicProgressReport.SkillContract.Tests.ps1` | Required headings (exact list and order), fewer than 500 lines in `SKILL.md`, report-format fragments (for example `tasks / hr`, `wave-parallel estimate`, `(range needs 3 or more check-in intervals)`, `| Wave | Children | Tasks | Done |`), calculation-rule values (`90 seconds`, `(default 14)`, `2.05`, `1.25 hours`, `epoch seconds`, and others), scheduling prompts, the State File fragments (`not migrated` and others), delivery (`$files.Count` is 6 in the skill folder; each file is listed once in `pack-manifests/core.json` and is byte-identical in the bundle) | **Changes.** The fragment lists follow the new `SKILL.md` text. A new heading (for example `## Step Model`) changes the exact heading list. The file count 6 becomes 6 + N. |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | Forwarder structure, exit handling, child-process `-SampleCap 0` and `-Mode Bogus` validation errors | Unaffected if `SampleCap` keeps its `ValidateRange` and `Mode` keeps its `ValidateSet`. |

## 3. Mirrors, Manifests, Coverage, and File-Size Configuration

- Mirrors: the only copy is the Claude bundle at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/`, which holds all six files. A grep for `epic-progress|EpicProgressReport` over `.agents/`, `.github/`, and `.codex/` found no copy. The skill is Claude-only.
- Manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the six paths. A new script file must be added to it, because `test_push_down_claude_pack_manifest_completeness.py` requires every bundled file to be listed, `test_push_down_pack_manifest_dependency_closure.py` requires every `$PSScriptRoot` dot-source of a manifested PowerShell file to be in core, and `test_push_down_claude_resource_contracts.py` requires equal bundle text.
- Batch budget: the bundle copies count as production PowerShell files (`.claude/skills/execution-environment/SKILL.md` `## Batch Budget`). New modules plus their bundle copies exceed the direct-mode cap of three production PowerShell files, so the work belongs on the orchestrated large path.
- Coverage: `config/poshqc-coverage.json` roots include `.claude/skills`, so every new `.ps1` under the skill folder is measured automatically (85% line). `config/poshqc-scan.json` scans `tests/scripts`, so new test files under `tests/scripts/claude-skills/epic-progress-report/` are discovered and assigned to shards automatically. No hand-maintained path list exists.
- File-size baseline: `config/file-size-baseline.json` has no entry for these files (a grep for `EpicProgress|epic-progress` under `config/` returned nothing).
- Changelog: `extensions/drm-copilot/CHANGELOG.md` already mentions this skill. A delivery note is expected because a push-down serves the installed extension payload.

## 4. Data Sources

### 4.1 Item checkpoint `artifacts/orchestration/orchestrator-state.json`

The file is gitignored and exists only inside a live worktree. Fields relevant to steps:

- `completed_steps`: the canonical prefixes in `$script:CanonicalStepPrefixes` of `.claude/hooks/enforce-checkpoint-monotonic.ps1` are `S0_startup_checks`, `S1_change_budget_estimation`, `S2_research`, `S3_promotion`, `S4_atomic_planning`, `S5_atomic_execution`, `S6_pre_review_commit`, `S7_feature_review`, `S8_create_pr`, `S9_remediation_loop`, `S10_post_pr`, and `S12_complete`. A variant suffix with `_`, `.`, or `-` matches its prefix (`Get-CanonicalStepIndex`). No canonical prefix exists for spec or preflight.
- `next_step`: uses the S-names above plus `S9_ci_green`, and inside the loop `remediation.cycle_N.{plan,preflight,execute,reaudit,exit_check}` (`.claude/agents/orchestrator.md` `### Remediation Loop Checkpoint Shape`).
- `step5_status` to `step10_status`: `VALID_STEP_STATUS` in `.claude/lib/orchestrator-state/OrchestratorState.psm1` is `not-applicable`, `pending`, `delegated`, `verified`, `blocked`, `not_started`, `in_progress`, `completed`. Additional values are allowed on two keys only: `step6_status` accepts `blocked_remediation_loop_limit`, and `step9_status` accepts `passed`, `failed_remediation_required`, and `blocked_ci_loop_limit`. A checkpoint without `step9_status` is treated as `pending` (`.claude/skills/orchestrate/SKILL.md` `### Backward compatibility`).
- `blocked_reason` (`.claude/rules/orchestrator-state.md` `## Blocked-Reason Vocabulary`): `none` or null means not blocked. The mechanical values are `spawn_agent_unavailable`, `delegation_launch_failed`, `delegate_no_receipt`, `delegate_contract_incomplete`, `validator_failed`, and `user_requested_stop`. The non-mechanical values are `premise_falsified`, `external_dependency`, `policy_hold`, `awaiting_ci`, and `human_decision_required`.
- `human_interaction.requirements[].response` is one of `scope_change`, `exception`, or `halt`.
- `remediation_loop`: `current_cycle`, `completed_attempts`, `review_outcomes[]` (`verdict`, `findings[].remediability`, optional `scope`, optional `inputs_path`, and `head_sha` under concurrent review), and `cycles[]` with `entry_timestamp`, `inputs_path`, `plan_path`, `remediation_path` (`light` or `full`), `preflight {iterations, final_status}` (absent for light cycles), `execution_status` (`in_progress`, `complete`, `failed`), `audit_paths`, `blocking_count`, `exit_condition_met`, `candidate_applied`, and `opened_by_review`.
- `stage_timing` (#1097): a top-level list of `{stage, attempt, started_at, ended_at}` with ISO-8601 UTC strings. `ended_at` is null while a stage is open. The key is tolerated and unvalidated, and the merge stage is not captured (`.claude/skills/orchestrate/SKILL.md` `## Checkpoint Handling` item 6). In the last commit before the merge, the same list is written to `<feature-folder>/evidence/other/stage-timing.<UTC stamp>.json` as `{ "issue-num", "stage_timing" }`, and the greatest stamp wins. A portable handoff drops the key from the projection, so the committed evidence file is the record that survives a handoff.
- `epic_mode`, `epic_context`, `epic_merge {merge_commit_sha, target_branch, merged_at}`, `pr_gate.pr_number`, and `ci_gate`.

**Stage names are not a closed vocabulary.** Observed in committed evidence:

- `docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/other/stage-timing.2026-11-07T19-17.json`: `research`, `spec`, `planning` (3 attempts), `preflight` (4 attempts), `execution`, `review` (3 attempts), `remediation_cycle_1` (2 attempts), `remediation_cycle_2`, `pr`, `ci` (2 attempts). There is a gap from 08:12Z to 13:40Z that no stage covers.
- `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/evidence/other/stage-timing.2026-11-07T17-56.json`: `promotion`, `research`, `spec`, `planning`, `execution`, `review`, `remediation` (one composite entry that also contains the re-review), `pr`, `ci` (attempt 2 still open). There is no `preflight` entry.

A remediation entry is therefore a composite of plan, preflight, execution, and sometimes re-review. It cannot be split into the per-type steps the owner's model asks for. The existing reader `scripts/dev-tools/StageTiming.psm1` (`ConvertFrom-StageTimingText`, `ConvertTo-StageTimingRecord`, `Get-StageTimingMedian`) already parses these files. It is a module under `scripts/`, not part of the pushed-down skill, so the skill cannot import it without adding a cross-folder dependency to the push-down closure. The parsing logic should be re-implemented in the skill (it is small) or the module moved. Re-implementing it is recommended (section 6).

### 4.2 Epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json`

- `features[]`: `issue_num`, `branch_name`, `worktree_path`, `pr_number`, `pr_url`, `merge_status`, `merge_commit_sha`, `depends_on`, and lifecycle timestamps. `worktree_created_at` and `merge_confirmed_at` were verified in `tests/fixtures/epic_wave_barrier/`, and `worktree_removed_at` in `.claude/skills/epic-orchestrate/SKILL.md` `## Worktree Cleanup`. The skill names "the four lifecycle timestamps", but the fourth name was not verified.
- `merge_status` enum (`VALID_MERGE_STATUS` in `scripts/dev_tools/validate_epic_orchestrator_state.py`): `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merge_conflict`, `blocked_conflict_loop_limit`, `merged`, `worktree_removed`.
- Main sync: each sync is a dedicated chore child with its own `features[]` row and `waves[]` entry, written before delegation. It uses the epic issue number or a chore issue number, never a manifest child's number (`.claude/skills/epic-orchestrate/SKILL.md`, the numbered wave-launch procedure item that runs `git rev-list --count` against `origin/main`). At most one runs per wave. The sync rows are not in the kickoff table, and the current script ignores them.
- Integration PR: the `epic_merge_pr` object. The CI result is recorded there, and `merge_commit_sha` is recorded only after a confirmed merge. No start time field for the integration PR was verified.
- The parallel checkpoint (`artifacts/orchestration/parallel-orchestrator-state.json`) is not needed for the epic or standalone scope of this issue.

### 4.3 Locating child checkpoints

Children run in worktrees under `.claude/worktrees/` on `branch_name`. The existing `ConvertFrom-EpicProgressWorktreeList` map (branch to worktree path) already locates each child worktree, so the item checkpoint is `<worktree>/artifacts/orchestration/orchestrator-state.json`, read through the existing `Test-EpicProgressPath` and `Read-EpicProgressFile` seams. After the worktree is removed (merged children), the checkpoint is gone. The committed `stage-timing.*.json` under the feature folder on the integration branch is the only remaining duration record. Its exact file name is unknown to the script, so the name must be listed with `git ls-tree --name-only <integration>:<feature-folder>/evidence/other`, and the file read with `git show`. The feature folder is the parent folder of the kickoff `PlanPath`.

### 4.4 Remediation plans and light-fix tasks

- Full cycle: `remediation-plan.<ts>.md` in the feature folder, with the same `- [ ] [P#-T#]` checkbox form, so `Get-EpicProgressTaskCount` counts it unchanged. The cycle's `plan_path` names it.
- Light cycle: `plan_path` names `remediation-inputs.<ts>.md`, whose `## Light Fix Tasks` holds canonical `- [ ] [P0-T1] ...` lines, and no checkbox appears elsewhere in that file (`.claude/agents/feature-review.md`, `.claude/skills/feature-review-workflow/SKILL.md`). `Get-EpicProgressTaskCount` therefore counts light tasks correctly from the whole file.
- Observed task counts: #1096 plan 22, remediation plans 16 and 13; #1105 plan 21, remediation plan 11 (counted with the `Get-EpicProgressTaskCount` regex through Grep).
- Stamp caveat: plan files are stamped in America/New_York (for example, the #1096 `plan.2026-11-07T02-06.md` precedes its `planning` stage start of 07:29Z). The #1096 remediation-plan stamps (`16-07`, `17-35`) match the UTC stage starts (16:08Z, 17:35Z). Filename stamps are therefore an approximate source with a time-zone ambiguity.

### 4.5 Pre-#1097 checkpoints (no `stage_timing`)

What remains available: `completed_steps`, `next_step`, `step*_status`, the `remediation_loop.cycles[].entry_timestamp` values (ISO, when present), the epic-row `worktree_created_at` and `merge_confirmed_at`, artifact filename stamps (research, plan in NY time, `code-review`, `feature-audit`, `policy-audit`, and `remediation-inputs` sharing one stamp per review, `remediation-plan`), and git commit times of the feature folder. Commit times need `git log` and file listings need `git ls-tree`. Both are read-only, but both break the exact git call list pinned by `passes only fetch, show and worktree list to git`, and they change the `Notes` statement in `SKILL.md`. A single pre-review commit often bundles research, spec, and plan, so commit times frequently cannot separate those steps.

## 5. Real Epic Folder

`docs/features/epics/` is absent from this worktree: no file matched under it.

- SearchScope: `docs/features/epics/` of the item worktree (the worktree only, as instructed)
- SearchPatterns: `docs/features/epics/**/*`, `docs/features/epics/*/epic-kickoff.md`, `docs/features/epics/documentation-estate-tooling/**`
- SearchResult: none

The script reads the kickoff from the integration branch through `git show`, not from the working tree, so its absence on `main` is expected. Its shape is known from the parser and the test fixture: a feature-summary table with the header `issue_num` or `Issue` and the cells issue, title, wave, band, and plan path. **Orchestrator to confirm:** `git show origin/epic/documentation-estate-tooling-integration:docs/features/epics/documentation-estate-tooling/epic-kickoff.md`, and whether its plans existed before the children ran (prepared plans), which decides how research, spec, and plan count for children without a checkpoint (Q6). The researcher has no `git show` route.

## 6. Recommended Design

### 6.1 Step-type catalog (11 types)

| Type | Scope | Source of done state | Duration sample source |
|---|---|---|---|
| `research` | item | `stage_timing` `research` closed; else `completed_steps` prefix `S2_research` | `stage_timing` entry |
| `spec` | item | `stage_timing` `spec` closed; else `S3_promotion` present and `spec.md` exists | `stage_timing` |
| `plan` | item | `stage_timing` `planning` or `plan`; else `S4_atomic_planning` | `stage_timing` (sum of attempts per step instance; see 6.4) |
| `preflight` | item | `stage_timing` `preflight`; else first checked plan task or `step5_status` past `pending` | `stage_timing` |
| `execution` | item | one step per plan `[P#-T#]` checkbox; done when checked | tick split (6.4) or the `execution` stage duration divided by task count |
| `review` | item | `stage_timing` `review`; else `S7_feature_review`, or one per `review_outcomes[]` entry | `stage_timing` |
| `pr` | item | `stage_timing` `pr`; else `S8_create_pr` or `pr_gate.pr_number` | `stage_timing` |
| `ci` | item | `stage_timing` `ci`; else `step9_status` `passed` | `stage_timing` |
| `merge` | item | epic `merge_status` in {`merged`, `worktree_removed`}, a MERGED PR, or `epic_merge` / `pr_merge` recorded | not captured by `stage_timing`; from the last `ci` end to `merge_confirmed_at` when both exist, else none |
| `main-sync` | epic | sync row `merge_status` merged or removed | row `worktree_created_at` to `merge_confirmed_at` |
| `integration-pr` | epic | `epic_merge_pr.merge_commit_sha` present | none verified; observed by the report across runs (6.4) |

Unknown stage names (for example `promotion`) map to no type. They are counted in the Full report as "unmapped stage time" and never enter a median. The name normalization is: `planning`/`plan` to `plan`; `remediation`, `remediation_cycle_<n>`, and similar names are composite (6.3).

### 6.2 Item step derivation (pure function, in-memory testable)

Input: one item record holding the parsed checkpoint (or null), the plan text, the remediation-plan and light-inputs texts keyed by `cycles[].plan_path`, the epic row, and the PR state. Output: a list of step records `{Issue, Type, Cycle (0 for the initial run), Ordinal, Status (done | in_progress | remaining | blocked), Key}`.

- Initial run: one step of each item type, plus one `execution` step per plan task.
- Each `cycles[]` entry adds: `plan` and `preflight` when `remediation_path` is not `light` (a missing key is treated as full); one `execution` step per task in the cycle's `plan_path` file; one `review` step (the re-audit); and one `ci` step when the cycle was opened after a PR existed (`S8_create_pr` precedes the cycle, or `step9_status` is `failed_remediation_required`). Cycles not yet opened are not predicted, so totals grow when a cycle opens. This is the intended behavior.
- In-progress step: the open `stage_timing` entry (null `ended_at`) when present; otherwise the step mapped from `next_step`.
- An item with no checkpoint and no worktree has all its steps remaining, or steps done before measurement when the plan already exists (Q6).

### 6.3 Remediation durations from composite stages

Composite remediation entries cannot be divided by type. Default: a composite remediation entry gives no per-type samples. Its time is shown as an unmapped composite in the Full report. Remaining remediation steps are estimated with the medians of the same types from initial runs. Tick-observed `execution` samples inside a cycle are still recorded (6.4). Q2 asks the owner whether the orchestrate skill should emit typed sub-stages (`remediation_plan`, `remediation_preflight`, `remediation_execution`, `remediation_review`). That would change a mirrored orchestration surface, which is outside this issue's file scope.

### 6.4 Durations, the batched-tick split, and the median

- Sample record: `{key, type, seconds, source (stage_timing | tick | epic_row | commit), approx (bool), recordedUnixSeconds}`. The key de-duplicates across runs: `<issue>|<stage>|<attempt>` for `stage_timing` samples; `<issue>|exec|<plan file name>|<task id>` for execution tasks; `<epic issue>|main-sync|<row issue>|<worktree_created_at>` for syncs. One sample per key. A `stage_timing` sample replaces a `tick` sample for the same execution task key, because the closed stage is the authoritative wall-clock record.
- A step instance with several attempts (for example `planning` attempts 1 to 3, or `preflight` attempts 1 to 4 in #1096) contributes one sample per attempt. The alternative is one summed sample per step instance (Q4). Default: one sample per attempt, because the remaining-step counts also count one step per re-run that the checkpoint records.
- Batched-tick split: the version 2 state keeps, per item and plan file, the set of checked task ids and `lastTickUnixSeconds`. On a run, the newly checked ids `N` at time `t` each receive `(t - lastTick - blockedSecondsInInterval) / |N|` seconds with `source: tick`. `lastTick` is then set to `t`. The first observation of an item seeds `lastTick` with the execution stage start when `stage_timing` has one, and otherwise with `t` itself, with no sample (no back-dating). When the `execution` stage closes, the samples become `(ended_at - started_at) / taskCount` per task id, with `source: stage_timing`. That is the issue's "divide the batch's elapsed time across the tasks ticked" at stage granularity.
- Median: the existing `Get-StageTimingMedian` rule (an even count averages the middle pair) is re-implemented in the skill as `Get-EpicProgressMedian`. It is computed over all retained samples of a type.
- Retention: no 14-sample cap applies to durations. A per-type retention ceiling of 1000 newest samples is the stated default, to bound the file size. The `samples` array (check-ins) keeps `-SampleCap`.
- Pre-#1097 approximations (`approx: true`): epic-row sync spans; review end from the `code-review.<ts>` stamp; `remediation_loop.cycles[].entry_timestamp` differences. Commit-time derivation (`git log`) is optional (Q3). Default: not implemented, because it changes the read-only git surface and bundled commits rarely separate steps.

### 6.5 Default durations (stated, used when a type has no sample)

These are derived from the two committed stage-timing files (#1096 and #1105) and the measured rates in `SKILL.md` `## Known Behaviors and Measured Rates`. They are printed with the label `default` and appear in `SKILL.md`.

| Type | Default | Derivation |
|---|---|---|
| research | 13 min | 13.6 (#1096), 12.6 (#1105) |
| spec | 6 min | 7.7, 3.3 |
| plan | 11 min | attempts 12.1, 9.2, 10.6 (#1096) and 25.4 (#1105); median 11.4 |
| preflight | 10 min | 14.7, 7.1, 12.3, 2.0 (#1096); median 9.7 |
| execution | 5 min per task | 104.8 min / 22 tasks = 4.8 (#1096); 57.2 / 21 = 2.7 (#1105); SKILL rate 9 to 13 tasks per hour = 4.6 to 6.7 |
| review | 14 min | 18.3, 10.4, 12.9, 14.9; median 13.9 |
| pr | 3 min | 3.2, 3.1 |
| ci | 17 min | 28.4, 16.9; the 0.85-minute #1096 attempt (no CI ran, CONFLICTING) is excluded from the derivation |
| merge | 5 min | not captured anywhere; a stated assumption |
| main-sync | 60 min | no sample; a stated assumption based on a child run of PR, CI, and merge |
| integration-pr | 45 min | no sample; a stated assumption (PR plus CI on `main`) |

The defaults can be overridden with a configured value through an optional hashtable parameter `-StepDefaultMinutes` (Q5). The report prints, for example, `ci: no measured duration; default 17 min`.

### 6.6 Blockage by recorded state

An item is blocked when any of the following holds:

- its checkpoint `blocked_reason` is a non-`none`, non-null member other than `awaiting_ci` (`awaiting_ci` is progress on the `ci` or `review` step, not owner waiting);
- a `human_interaction.requirements[]` entry has `response: "halt"`;
- `step6_status` is `blocked_remediation_loop_limit` or `step9_status` is `blocked_ci_loop_limit`;
- its epic row `merge_status` is `blocked_conflict_loop_limit`.

Effects:

1. The item's remaining steps are reported as `blocked` and excluded from the remaining-time sum. They are listed with their would-be subtotal.
2. The tick split subtracts the blocked span. Version 2 state keeps `blockedSinceUnixSeconds` per item, and the span is resolved at the next unblocked observation.
3. The in-progress step's elapsed time does not accrue while the item is blocked.

A zero tick rate is never used as a blockage signal. A "missed handoff" has no recorded field (Q1).

### 6.7 Remaining-time estimate

- Per type `T`: `remaining(T) × median(T)`. When the type has no sample, the default is used and the report says so. The headline is the sum over types (the owner's definition, AC2).
- In-progress credit: an in-progress step contributes `max(0, median(T) - elapsed in step)` and is flagged `over median` when the elapsed time is greater than the median. Review, CI, and main-sync periods then reduce the estimate as they run, instead of showing zero velocity (AC5).
- Wave-parallel: a secondary figure. The per-feature remaining sums are combined with the existing wave rule (the largest per open wave, summed), plus the epic-level steps. The existing `-WaveOverheadHours` becomes unnecessary for this figure, because review and CI are now explicit steps. It stays accepted for compatibility but is unused, or it is documented as applying only when a type has no data (Q7).
- Completion percentage: by step count (`done / total` steps). It can fall when a cycle opens. A time-weighted alternative is Q8.

### 6.8 Output (as close to the current format as the model allows)

TL;DR, four lines (the four-line contract and the push-notification rule stay intact):

```text
**TL;DR:** Epic #<issue> is at <done> of <total> steps (<pct>%). <done-sentence> <running-sentence>
**Elapsed:** <H h MM min>, with about <hours> hours left on the per-type estimate (<b> blocked steps excluded). **Weekly** quota is at <weekly>.
**Now:** #<i> <type> (<elapsed> of median <m>)[, #<j> <type> (...)]. <k> of <n> types use defaults.
**Estimated time remaining:** <H h MM min> by type (sum); <H h MM min> wave-parallel.
```

- Running sentence: `#<i> is running (<d> of <t> steps, at <type>).`. A blocked item is shown as `#<i> is blocked (<blocked_reason>).`.
- Full mode keeps the heading, the Elapsed and Progress line (`steps`), the State table (adding a `Blocked` row), and the Wave table (`| Wave | Children | Steps | Done |`). It replaces the Velocity, straight-line, and wave-parallel lines with a per-type table:

```text
| Type | Done | In progress | Remaining | Blocked | Median | Samples | Subtotal |
|---|---|---|---|---|---|---|---|
| execution | 61 | 0 | 40 | 0 | 4 min 30 s | 88 | 3 h 00 min |
| merge | 2 | 0 | 3 | 0 | default 5 min (no samples) | 0 | 0 h 15 min |
| **Total** | ... | ... | ... | ... | | | **<H h MM min>** |
```

  The Full report also prints the unmapped composite stage time line (6.3) and the weekly-quota line unchanged.
- The velocity, SD, and range lines are dropped. The batched-tick problem made them misleading, which is the problem the issue states. `Get-EpicProgressRecentVelocityInterval`, `Get-EpicProgressStandardDeviation`, and `Get-EpicProgressRangeText` then have no caller. They can be removed together with their tests, or kept. Removing them keeps the Metrics file small and avoids dead code. The planner should decide this in the plan and list the matching test disposition.

### 6.9 Standalone items

Add a second parameter set, `Item`, with a mandatory `-Issue <n>` (or `-ItemBranch`). The `Epic` set keeps `-EpicFolder` mandatory. In the `Item` set, the worktree whose checkpoint `issue-num` equals the number is found through the worktree map. No kickoff, epic checkpoint, or epic-level steps are used. The state path is `.claude/state/progress-item-<n>.json`. Both compatible epic invocations stay byte-compatible at the CLI. The help test pins 15 parameters, so adding `-Issue` and `-StepDefaultMinutes` makes 17. That test and `SKILL.md` `## Inputs` change (Q9 asks how a standalone item is named).

### 6.10 Version 2 state file and v1 migration

```json
{
  "version": 2,
  "startUnixSeconds": 1767603600,
  "baselineDone": 0,
  "baselineWeeklyPct": 0,
  "unit": "steps",
  "samples": [ { "ts": 1767614400, "done": 12 } ],
  "durations": {
    "review": [ { "key": "12|review|1", "seconds": 780, "source": "stage_timing", "approx": false, "recorded": 1767614400 } ]
  },
  "items": {
    "12": {
      "plans": { "plan.2026-01-05T09-00.md": { "checked": [ "P0-T1", "P1-T2" ], "lastTickUnixSeconds": 1767614400 } },
      "blockedSinceUnixSeconds": null
    }
  }
}
```

- Reader: version 1 and the legacy array are accepted. Their `samples` and `baselineDone` count tasks, not steps, so on migration they are discarded, `baselineDone` resolves to the current step count (the same path as `UseCurrentDone`), and `startUnixSeconds` and `baselineWeeklyPct` are kept. `durations` and `items` start empty. The first v2 write records the migration. Version 3 or higher, blank text, and unparseable text give empty state, as today.
- The writer always writes version 2. A run that changes no sample but adds a duration or a tick record also writes. The write condition becomes "sample changed, ledger changed, reset, or pair".
- `-ResetBaseline` keeps `durations` (history is the point of AC6) and clears `samples`. Whether a reset should also clear `items` tick anchors is Q10. Default: anchors are kept, and blocked spans are reset.
- `-PairSamples` affects `samples` only.
- The `unit` field avoids confusing old task-count samples with step counts.

### 6.11 File placement (each new file under 500 lines)

| File | Content |
|---|---|
| `Get-EpicProgressReport.Steps.ps1` (new) | catalog, stage-name normalization, `stage_timing` parsing (port of the `StageTiming.psm1` record rules), checkpoint-to-steps derivation, cycle expansion, blocked classification |
| `Get-EpicProgressReport.Durations.ps1` (new) | median, sample keys and merge, tick split, defaults, per-type estimate and wave-parallel combination |
| `Get-EpicProgressReport.Gather.ps1` (new) | I/O wiring helpers that call the existing seams to read item checkpoints, the light-inputs and remediation-plan texts, and stage-timing files per feature. This keeps `Invoke-EpicProgressReport` near its current size. |
| `Get-EpicProgressReport.State.ps1` (existing) | v2 reader and writer and migration; about 286 lines now, expected to stay under 500 |
| `Get-EpicProgressReport.Render.ps1` (existing) | new summary and TL;DR/Full composition, or a new `Get-EpicProgressReport.StepRender.ps1` if the file approaches 500 lines |
| `Get-EpicProgressReport.Logic.ps1` (hub) | dot-sources the new files |

The native wrappers stay in the entry script. If `git ls-tree` is used, the `Invoke-GitExe` argument list grows, but the native-call count (3) and the write count (2) are unchanged. Every new file is added to `core.json`, the bundle, `productionPaths`, and the forbidden-token scan list.

### 6.12 Rejected alternatives

- **Keep checkbox velocity and add an overhead constant per stage.** The batched-tick variance and the remediation invisibility both remain. Rejected.
- **Import `scripts/dev-tools/StageTiming.psm1` from the skill.** This adds a non-skill dependency to the pushed-down skill, and that module rejects open entries and reads the file system itself. Rejected in favor of a small in-skill port.
- **Derive pre-#1097 durations from `git log`.** This widens the read-only git surface. Commits are batched, so the result is mostly approximate or absent. Deferred to Q3.

## 7. Open Questions

### 7.1 Need the owner's decision

- **Q1 Missed handoff.** No checkpoint field records a missed handoff (for example, a dead background child). The issue requires exclusion by recorded state, not inference. Should a stale `last_updated` (inference) count, or should a new recorded marker be defined elsewhere? Default if no answer: a missed handoff is not detected, and only the recorded fields in 6.6 count.
- **Q2 Composite remediation stages.** `stage_timing` records a cycle as one composite entry, so plan, preflight, execution, and re-review durations inside a cycle cannot be typed. Should the orchestrate skill write typed remediation sub-stages (a separate change to mirrored orchestration surfaces), or is the 6.3 fallback acceptable?
- **Q3 Pre-#1097 commit times.** Is adding `git log` (and `git ls-tree`) to the report's read-only git surface acceptable for approximate durations?
- **Q7 Headline estimate.** The owner's definition is a serial sum over types. For a multi-child epic this overstates wall-clock time. Should the TL;DR headline be the serial sum (AC2 literal) with wave-parallel as the secondary figure (the 6.7 default), or the reverse?
- **Q8 Percentage basis.** Should the percentage be a step count (the default), or time-weighted (expected time done divided by expected total)?
- **Q9 Standalone identification.** Should a standalone item be named by `-Issue <n>` (the default), by branch, or by feature folder? Is the new parameter set acceptable (the help test count goes from 15 to 17)?
- **Q11 Main-sync prediction.** Should future main syncs be predicted (one per unlaunched wave) or counted only once recorded (the default, since a sync runs only when `main` moved)?
- **Q12 Durations pool.** Should durations be kept per epic state file (the default) or in one shared ledger across epics and standalone items, so that medians carry history between epics?

### 7.2 Resolvable with the stated defaults

- **Q4** Multiple attempts give one sample each (6.4).
- **Q5** Defaults in 6.5, overridable through `-StepDefaultMinutes`.
- **Q6** A child without a checkpoint whose plan already exists on the integration branch counts research, spec, and plan as done before measurement, with no samples. The orchestrator should confirm that epic plans are prepared before children run (section 5).
- **Q10** A reset keeps the duration history and the tick anchors.
- `awaiting_ci` is not blocked (6.6).
- Velocity, SD, and range functions are removed together with their tests (6.8). This is the planner's call, recorded in the plan.

## 8. Testing Implications

- Pure-function tests per new file (`Get-EpicProgressReport.Steps.Tests.ps1`, `Get-EpicProgressReport.Durations.Tests.ps1`, and a Gather test with mocked seams), in `tests/scripts/claude-skills/epic-progress-report/`. Fixtures are in-memory JSON strings: an item checkpoint with `stage_timing`, an open entry, a light cycle, a full cycle with `plan_path`, a pre-#1097 checkpoint, and a blocked checkpoint for each recorded field.
- Required scenarios: totals grow when a cycle opens and the percentage falls; a light cycle adds no plan or preflight step; batch split across 3 tasks; blocked span subtracted; a type without samples prints `default`; medians for even and odd counts; v1 and legacy migration; version 3 gives empty state; durations persist beyond 14 samples; tick samples are de-duplicated across runs; a `stage_timing` sample replaces a tick sample.
- Integration-level `Invoke-EpicProgressReport` goldens are regenerated for TL;DR and Full. The git call list test is updated to the new exact list.
- Every test disposition in section 2 is named in the plan (preflight defect class "behavior change with asserting tests outside the task").
- Gates: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run (the push-down contract tests are pytest), plus `Invoke-PoshQCLeakScan`.

## Numeric Derivation Evidence

### Claim N1: the entry script declares 15 parameters

- Complete Family: parameters of the `param()` block of `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1`.
- Exhaustive Search Scope: the whole script-level `param()` block. Function-level param blocks are excluded.
- Inclusion Rules: each `[type] $Name` declaration directly in the script `param()` block.
- Exclusion Rules: the parameters of `Invoke-EpicProgressReport` and of the wrappers.
- Primary Search Strategy or Query Expression: read the script `param()` block with the Read tool.
- Primary Member Set: EpicFolder, StartUtc, EpicIssue, IntegrationBranch, KickoffPath, RepositoryRoot, CheckpointPath, StatePath, BaselineDone, BaselineWeeklyPct, WaveOverheadHours, SampleCap, Mode, ResetBaseline, PairSamples.
- Primary Count: 15.
- Cross-check Search Strategy or Query Expression: read the `## Inputs` table rows of `.claude/skills/epic-progress-report/SKILL.md`.
- Cross-check Member Set: EpicFolder, StartUtc, BaselineDone, BaselineWeeklyPct, EpicIssue, IntegrationBranch, KickoffPath, RepositoryRoot, CheckpointPath, StatePath, WaveOverheadHours, SampleCap, Mode, ResetBaseline, PairSamples.
- Cross-check Count: 15.
- Member-set Comparison: the normalized sets are identical (order differs only). The count also matches the `$parameterNames.Count | Should -Be 15` assertion in `documents every parameter in comment-based help`.

### Claim N2: the skill folder holds 6 files, each with one bundle copy and one `core.json` entry

- Complete Family: files under `.claude/skills/epic-progress-report/`.
- Exhaustive Search Scope: recursive, all file types.
- Inclusion Rules: any file.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `**/epic-progress-report/**` over the worktree, filtered to the `.claude/skills/` prefix.
- Primary Member Set: SKILL.md, Get-EpicProgressReport.ps1, Get-EpicProgressReport.Logic.ps1, Get-EpicProgressReport.Metrics.ps1, Get-EpicProgressReport.Render.ps1, Get-EpicProgressReport.State.ps1.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: Grep `epic-progress` in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- Cross-check Member Set: the same six repository-relative paths.
- Cross-check Count: 6.
- Member-set Comparison: identical. The same Glob also found exactly six bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/`, and no `.agents`, `.github`, or `.codex` copy.

### Claim N3: the step-type catalog has 11 types

- Complete Family: step types named by the owner's model in `issue.md` `### Unit of work: typed steps`.
- Exhaustive Search Scope: the issue `## Proposed Behavior` section.
- Inclusion Rules: every orchestration step type and the `execution` type.
- Exclusion Rules: data fields that are not step types.
- Primary Search Strategy or Query Expression: read the bullet listing "research, spec, plan, preflight, review, PR, CI, merge, and, at epic level, main sync and the integration PR", plus the `execution` bullet.
- Primary Member Set: research, spec, plan, preflight, review, pr, ci, merge, main-sync, integration-pr, execution.
- Primary Count: 11.
- Cross-check Search Strategy or Query Expression: read the same list in `spec.md` `### Unit of work: typed steps` (the draft spec carries the issue text).
- Cross-check Member Set: research, spec, plan, preflight, review, PR, CI, merge, main sync, integration PR, execution.
- Cross-check Count: 11.
- Member-set Comparison: identical after case and spelling normalization.

## Pre-Mortem

- **Review checklists:** A reviewer could flag dead velocity functions, an unrecorded test disposition, or `SKILL.md` text that still says the format "does not change". Mitigation: the plan names the disposition of every test in section 2, removes or keeps the Metrics velocity functions explicitly, and rewrites `## Report Formats`, `## Calculation Rules`, `## State File`, and `## Known Behaviors and Measured Rates` with the contract-test fragment lists updated in the same task.
- **Coverage:** New files under `.claude/skills` are measured automatically. A gathering file whose functions are tested only through mocked integration paths could fall below 85% line coverage. Mitigation: each new file gets its own test file with direct function tests, and per-file line coverage is read from `artifacts/pester/powershell-coverage.xml` after the parallel gate.
- **Mirror parity:** Each new or changed skill file must be byte-identical in `extensions/drm-copilot/resources/claude-customizations/` and listed once in `core.json`. Otherwise `EpicProgressReport.SkillContract.Tests.ps1`, the manifest completeness test, the dependency-closure test, and the resource contract test fail. Mitigation: one task copies all files to the bundle and updates `core.json` and the file count (6 + N) together. The task runs the pytest push-down contract tests. The execution-environment brief is unaffected because no CI job, tool route, or budget rule changes.
- **File size:** The entry script is about 475 lines. Adding gathering code to it would cross the 500 guidance tier. Mitigation: gathering goes to the new `Gather` file, and `Steps` and `Durations` are separate files. Each file's logical lines are checked against 500 with `@(Get-Content).Count` before handoff.
- **Test isolation:** New tests must not create temporary files or leak script-scope functions or globals (`Invoke-PoshQCLeakScan`). Mitigation: in-memory JSON fixtures through the existing `Read-EpicProgressFile` and `Test-EpicProgressPath` mocks, `$script:` variables reset in `BeforeEach`, and no `$global:` writes. The forwarder test already restores `LASTEXITCODE` and is unchanged.
- **CI-only behavior:** The skill tests run in the Windows shards. Fixture paths are already forward-slash and drive-free (`/fixture-repo/...`), and the forbidden-token test rejects drive-letter paths and the real epic folder name in production files. Mitigation: new fixtures use the `example-epic` name and `/fixture-repo` roots, and no test reads gitignored `artifacts/` state or diffs against `origin/main`.
- **Evidence:** The defaults in 6.5 rest on two committed stage-timing files, and the real kickoff shape was not read (section 5). Mitigation: `SKILL.md` labels the defaults as stated assumptions with their derivation, and the orchestrator confirms the kickoff and the prepared-plan question with `git show` before the spec fixes Q6.

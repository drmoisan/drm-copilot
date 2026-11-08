# Code Review: Progress Report Orchestration Step Model (Issue #1118)

**Review Date:** 2026-11-08
**Branch:** `feature/progress-orchestration-step-model` @ `b82381ed282445648ee6a9e95f106778999e9f85`
**Diff:** merge base `12825cb00` (with `origin/main`) to head; 72 files. Cycle-1 delta `84a25a90a..b82381ed2`, 33 files.
**Review type:** Re-audit after remediation cycle 1 (RF1, RF2, RF3 of `remediation-inputs.2026-11-07T23-18.md`).
**Companion artifacts:** `policy-audit.2026-11-08T00-12.md`, `feature-audit.2026-11-08T00-12.md`.

## Executive Summary

The cycle-1 changes are small, located where the remediation plan placed them, and documented in each function's help. The entry script (495 lines) is unchanged. All three prior findings are resolved, and no new blocking defect was found in the full branch.

**RF1, live stage vocabulary: resolved.** `ConvertTo-EpicProgressStepType` (`Get-EpicProgressReport.Stages.ps1`) checks an eleven-entry alias hashtable after trimming and lower-casing and before the catalog lookup. `promotion` and unknown names still map to `unmapped`. `Test-EpicProgressCompletedStep` now takes `[string[]] $Prefix`, and the research fallback passes `S2_research` and `S3b_research`. The `next_step` prefix map adds `S3b_research`. The `pr` record lookup in `Get-EpicProgressCycleStep` sees the aliased `S8_create_pr` because the lookup runs on normalized types.

Live-data check: #1038 merged after the prior review (epic row `worktree_removed`), so its open review cannot be observed any more. The reviewer used the real checkpoint file of #1114 (`bug-codex-coverage` worktree), which records `S2_research`, `S3_spec`, `S4_atomic_planning` (two attempts), `S4_preflight` (two attempts), `S5_atomic_execution`, and `S7_feature_review`. The probe reopened `S7_feature_review`, served the files through the real `Test-EpicProgressPath` and `Read-EpicProgressFile` seams, and called `Invoke-EpicProgressReport -Issue 1114` at three times:

```text
+10 min  **Now:** #1114 review (0 h 10 min of median 0 h 14 min). 4 of 9 types use defaults.   about 0.5 hours left
+15 min  **Now:** #1114 review (0 h 15 min of median 0 h 14 min, over median). ...           about 0.4 hours left
+20 min  **Now:** #1114 review (0 h 20 min of median 0 h 14 min, over median). ...           about 0.4 hours left
```

The per-type subtotals give 29, 25, and 25 minutes. Every aliased type received samples from real stage records: research 1, spec 1, plan 2, preflight 2, and execution 19 (from `S5_atomic_execution`).

**RF2, in-progress execution start: resolved.** After each plan file's tick split, `Get-EpicProgressStepReport` (`Get-EpicProgressReport.Gather.ps1`) raises the start of an in-progress execution step of that plan file to the anchor's `LastTickUnixSeconds` when the tick is later. The match uses the key prefix `<issue>|exec|<plan file>|`. On the first observation, the start stays at the stage start when no task is checked yet, which is correct because the first task began with the stage. When tasks are already checked, the anchor is the current run, so that run reads `0 h 00 min`; this lasts one run only.

**RF3, wording: resolved.** `Get-EpicProgressTldrLine` and `Get-EpicProgressFullLine` (`Get-EpicProgressReport.Render.ps1`) now print the item and singular forms. Real `-Issue 1118` run at this head:

```text
**TL;DR:** Item #1118 is at 48 of 52 steps (92.3%). #1118 is not done yet. #1118 is running (48 of 52 steps).
| State | Item |
| Running | #1118: 48 of 52 steps (92%). |
**Weekly quota (active account):** 73% used, +73 points since the measurement started. This pool also covers the other runs in this session, so it is not this item's cost alone.
```

Test discrimination: the reviewer copied the skill and its tests to a scratch tree and applied ten mutants that each revert part of a fix. These were the alias lookup removed; only `feature_review` removed; the `S3b_research` fallback and `next_step` entries each removed; the RF2 rule removed or changed to `Min`; and the item done sentence, singular blocked text, item weekly line, and item wave label each reverted. Every mutant failed at least one named cycle-1 test, and the unmutated copy passed 81 of 81.

**Caller observation (a).** The run from the item worktree printed `10 of 10 types use defaults` and no step in progress. This comes from where the script runs, not from the code. `artifacts/orchestration/epic-orchestrator-state.json` is gitignored and exists only in the main checkout. Without it, no feature has a branch name, so no worktree, checkpoint, or PR state is found, and every child reads as running. The reviewer ran it three ways. From the main checkout, the scheduled job's location: `11 of 11 features are done`, `#1019 integration-pr (0 h 00 min of median 0 h 45 min)`, `10 of 11 types use defaults`. From the item worktree: the observed output, with all 11 features shown as running. From the item worktree with `-CheckpointPath` set to the main checkout's file: identical to the main-checkout run. `10 of 11 types use defaults` in the main checkout is correct under Decision D3: every child worktree was removed before the version 2 ledger first observed it, so only the approximate main-sync samples exist. The silent fallback when the checkpoint file is absent predates the branch (the merge-base script also read branch names and merge status only from that file). Recorded as NB2.

**Caller observation (b).** Reproduced at this head as `**Now:** #1118 review (0 h 00 min of median 0 h 09 min)` while this re-audit runs. During a remediation cycle the orchestrator records only the composite `remediation_cycle_<n>` stage (Decision D2), so the cycle's plan, preflight, execution, and re-audit steps come from `next_step` with no start. The same holds for the epic `integration-pr` step. The output is consistent with the spec: the in-progress rule names `next_step` as the fallback and defines no start for it. AC5 covers a review with a recorded stage, which the tests and the #1114 probe confirm. The printed `0 h 00 min` nevertheless reads as a measured value, and the estimate stays flat for the whole re-audit. Recorded as NB1 (non-blocking) with a contained recommendation.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (non-blocking, NB1) | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1`; `Get-EpicProgressReport.Steps.ps1` | Now-line text in `Get-EpicProgressTldrLine`; `next_step` fallback in `Get-EpicProgressItemStep` | A step in progress without a recorded start prints `0 h 00 min of median <m>`, which reads as a measured elapsed time. This occurs for every step of a remediation cycle (only a composite stage is recorded), for the epic `integration-pr` step, and on the first observation of a partly ticked plan | Print `start not recorded` instead of an elapsed figure when `StartedUnixSeconds` is null; optionally start a cycle's re-audit step at the cycle plan's last tick | Follows spec D2 and the in-progress rule, so no criterion fails; the figure is not measured and the estimate does not fall during a re-audit | Real `-Issue 1118` run: `#1118 review (0 h 00 min of median 0 h 09 min)`; main-checkout epic run: `#1019 integration-pr (0 h 00 min of median 0 h 45 min)`; executor `sample-report.2026-11-08T00-00.md` |
| Low (non-blocking, NB2) | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Gather.ps1` | `Get-EpicProgressEpicCheckpointRow` (absent file) | In epic mode, an absent epic checkpoint gives empty rows with no warning, so every child reads as running and nothing as done (observation a) | Write a warning naming `-CheckpointPath` when the file is absent in epic mode | Behavior predates the branch; affects only runs outside the main checkout; the scheduled location is correct | Reviewer runs from the item worktree with and without `-CheckpointPath`; merge-base script read the same file only |
| Low (non-blocking, NB3) | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Stages.ps1` | alias table in `ConvertTo-EpicProgressStepType` | `S2_feature_documents` (the spec-writing stage in the live #1106 checkpoint) maps to `unmapped`; the spec step is still counted done through the `S3_promotion` fallback, so only its 3-minute sample is lost | Add `S2_feature_documents` to `spec` when the alias table is next extended | Sample loss only; no step count or in-progress error | Reviewer inventory of stage names in live worktree checkpoints |
| Low (non-blocking, NB4, carried) | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Gather.ps1` | `Get-EpicProgressStepReport` item anchor retention | Plan anchors of a merged item remain in the state file | Drop the `items` entry of a merged item | Bounded growth only; no correctness impact | Code inspection (unchanged since the prior review) |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | whole file | 495 logical lines, unchanged in cycle 1, just under the 500-line guidance tier | Keep further changes in the dot-sourced files | Guidance tier only; no gate | Reviewer `@(Get-Content).Count` |

No covered file in the branch diff is at or above 700 logical lines (largest 656, `Get-EpicProgressReport.Tests.ps1`), so no file-size Warning row applies. `config/file-size-baseline.json` is unchanged.

## Prior Findings Disposition

| Finding | Status | Verification |
|---|---|---|
| RF1 live stage and step vocabulary | Resolved | Alias table and fallbacks at head; #1114 real-file probe (elapsed shown, estimate 29 to 25 min, samples from every aliased type); 4 alias mutants caught |
| RF2 in-progress execution start | Resolved | Max-of-start-and-tick rule at head; 2 mutants caught by 'starts the in-progress execution step at a later plan tick' and 'keeps the execution stage start when the last tick is earlier' |
| RF3 item-mode and singular wording | Resolved | Real `-Issue 1118` run; one-feature and item goldens; 4 wording mutants caught |
| Low: step without a recorded start prints `0 h 00 min` | Open, non-blocking (NB1) | Now shown to cover every remediation-cycle step, not only `integration-pr` |
| Low: merged-item anchors retained | Open, non-blocking (NB4) | Unchanged |

## Positive Observations

- Each fix is small and located where the plan placed it, with help text describing the new rule.
- The live-vocabulary fixtures (`S2_research` through `feature_review`, `S8_create_pr`, `S3b_research`) close the test-data gap that hid RF1.
- The two-run ItemMode test pins the AC5 behavior with the live stage name and hand-derived figures (29 and 25 minutes) that the reviewer's real-file probe reproduced.
- Bundle copies stay byte-identical, and `core.json` needed no change because no file was added.
- The entry script was not touched, keeping it under the 500-line guidance tier.

# Code Review: Progress Report Orchestration Step Model (Issue #1118)

**Review Date:** 2026-11-07
**Branch:** `feature/progress-orchestration-step-model` @ `84a25a90a17f38e31a90b7e81ce3461d91e96ddb`
**Diff:** merge base `12825cb00` (with `origin/main`) to head; 57 files.
**Companion artifacts:** `policy-audit.2026-11-07T23-18.md`, `feature-audit.2026-11-07T23-18.md`, `remediation-inputs.2026-11-07T23-18.md`.

## Executive Summary

The code is well structured. Pure logic sits in seven dot-sourced files behind the Logic hub, I/O stays in the entry seams, `Write-EpicProgressState` is the only writer, and every function carries help and `CmdletBinding`. Coverage of every skill script is at or above 95.56%, PSScriptAnalyzer reports nothing, and the bundle copy is byte-identical.

Backward compatibility holds. The `Epic` parameter set is the default; every existing parameter keeps its name, type, default, mandatory status, and validation attribute (reviewer diff of the param block against the merge base). The scheduled invocation `-EpicFolder documentation-estate-tooling -Mode TLDR`, and the same in Full mode, ran from the main checkout against a copy of the live version 1 state and exited 0. The state was rewritten as version 2 (`unit: "steps"`, `startUnixSeconds` 1794047491 and `baselineWeeklyPct` 13 kept, `baselineDone` set to the current 638 steps, one check-in sample, a `main-sync` duration list of six approximate samples).

The same real run, plus probes of the pure functions, found three blocking defects. The unit tests cannot catch them because every fixture uses the catalog stage names.

**RF1, stage and step vocabulary (High).** `ConvertTo-EpicProgressStepType` maps only `plan`/`planning`, names starting with `remediation`, and the eleven catalog names. Reviewer probe results:

```text
feature_review -> unmapped        S7_feature_review   -> unmapped
atomic_execution -> unmapped      S5_atomic_execution -> unmapped
S2_research -> unmapped           S4_atomic_planning  -> unmapped
S4_preflight -> unmapped          S8_create_pr        -> unmapped
S9_ci_gate -> unmapped            S9_ci_green         -> unmapped
S3_spec -> unmapped
```

These names occur in the live #1038 checkpoint (`atomic_execution`, `feature_review`) and in the committed #1106 record on `main` (`S2_research` through `S9_ci_gate`, `feature_review`, `atomic_execution`). The `completed_steps` fallback checks the prefix `S2_research`, but the live #1038 checkpoint records `S3b_research`. Consequences on the live epic (reviewer real run, Full mode):

- `#1038 review (0 h 00 min of median 0 h 14 min)` while its `feature_review` stage had been open since 22:05Z. The step is in progress only through `next_step`, with no start.
- Probe with a `feature_review` stage open: the total stays 39 min at +10 min and +15 min. With the stage named `review` it falls from 29 to 25 min. The issue's first problem (review time read as zero progress) therefore persists for this vocabulary.
- `research | 10 | 0 | 1` remaining for #1038, a phantom 13-minute step that stays until merge.
- `unmapped stages 1 h 38 min`: #1038's `atomic_execution` stage gives no per-task samples.
- The remediation-cycle `ci` rule looks for a `pr` stage record, so with `S8_create_pr` it falls back to `step9_status` only.

The spec's normalization rule ("any other unrecognized stage name maps to no type") is followed literally, so the fix extends a spec rule. That makes it a design-scope change. It is still autonomous: the alias set is observable in committed records and live checkpoints, and the issue already names `stage_timing` and `completed_steps` as the data sources.

**RF2, in-progress execution elapsed (Medium).** `Get-EpicProgressItemStep` gives the first unchecked task the `StartedUnixSeconds` of the open `execution` stage. `Get-EpicProgressTypeEstimate` then measures elapsed time from that start and compares it with the per-task median. Probe: 10 of 12 tasks checked, stage open 80 minutes, median 3 minutes, result `elapsed=80m median=3m over=True`. The executor's own real run printed `#1118 execution (1 h 20 min of median 0 h 03 min, over median)`. Every scheduled report during an item's execution phase will read `over median`, and the in-progress task's credit is always 0. The per-plan tick anchor (`LastTickUnixSeconds`) is the start of the current task and is already available in `Get-EpicProgressStepReport`.

**RF3, report wording (Medium).** `Get-EpicProgressTldrLine` and `Get-EpicProgressFullLine` do not adapt to item mode or to a count of one. Probe and sample output:

- `None of the 1 features is done yet.` (item mode, and epic mode with one feature)
- `1 of 1 features are done.` and `(1 blocked steps excluded)`
- Item mode Full: `+42.5 points since the epic started. ... so it is not the epic's cost alone.`
- Item mode State table: `| State | Features |` and `#12 (wave 1): ...`

The spec states only that "the subject reads `Item #<issue>`" in item mode. Rendering the epic-only phrases there is factually wrong ("the epic started" when no epic exists), and the plural errors fall short of the professional-tone standard for an output the owner receives as a push notification every 10 minutes.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| High (blocking, RF1) | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Stages.ps1`; `Get-EpicProgressReport.Steps.ps1` | `ConvertTo-EpicProgressStepType`; `$fallback` table in `Get-EpicProgressItemStep`; `Get-EpicProgressCycleStep` `pr` lookup | Live stage names (`feature_review`, `atomic_execution`, the `S2_` to `S9_` forms) and `completed_steps` variants (`S3b_research`) map to no type, so review and execution time is invisible and a phantom research step remains | Add an alias table mapping each observed name to its type (for example `S2_research` to research, `S3_spec` to spec, `S4_atomic_planning` to plan, `S4_preflight` and `S4b_preflight` to preflight, `atomic_execution` and `S5_atomic_execution` to execution, `feature_review` and `S7_feature_review` to review, `S8_create_pr` to pr, `S9_ci_gate` and `S9_ci_green` to ci); let the research fallback accept `S3b_research`; update spec, SKILL.md, and add fixtures with the live names | Defeats the issue's first problem statement on real data; spec normalization rule is narrower than the recorded vocabulary | Reviewer real run (Now line `#1038 review (0 h 00 min ...)`, research remaining 1, unmapped 1 h 38 min); probe totals 39/39 vs 29/25 min; #1038 and #1106 records |
| Medium (blocking, RF2) | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Steps.ps1`; `Get-EpicProgressReport.Gather.ps1` | `$openExecution` block in `Get-EpicProgressItemStep`; `Get-EpicProgressStepReport` | In-progress execution step elapsed is measured from the stage start and compared with the per-task median | Start the in-progress execution step at the later of the stage start and the plan anchor's `LastTickUnixSeconds`; add a test with an open stage and a recent tick | The Now line reads `over median` for nearly the whole execution phase and the in-progress credit is always 0 | Probe `elapsed=80m median=3m over=True`; `sample-report.2026-11-07T23-07.md` real item run |
| Medium (blocking, RF3) | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | `Get-EpicProgressTldrLine` done sentence and Elapsed line; `Get-EpicProgressFullLine` State header, Running row, weekly line | Item-mode text names an epic and features; singular counts use plural forms | In item mode, phrase the done sentence about the item (for example `#12 is not done yet.` / `#12 is done.`), drop `wave 1`, use `since the measurement started` and `not this item's cost alone`; use singular forms for a count of one (`1 blocked step`, `1 of 1 features is done`); update goldens | User-facing output received every 10 minutes and hourly; wrong statements and grammar | `sample-report.2026-11-07T23-07.md`; reviewer probe output |
| Low | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Steps.ps1` | `next_step` fallback and `Get-EpicProgressEpicStep` integration-pr | A step marked in progress without a recorded start prints `0 h 00 min of median ...`, which reads as just started | Print `started, start not recorded` (or omit the elapsed figure) when no start exists | Clarity of the Now line; partly resolved by RF1 | Reviewer real run: `#1019 integration-pr (0 h 00 min of median 0 h 45 min)` |
| Low | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Gather.ps1` | `Get-EpicProgressStepReport` item anchor retention | Plan anchors of a merged item are kept in the state file indefinitely | Drop the `items` entry of a merged item | Bounded growth only; no correctness impact | Code inspection |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | whole file | 495 logical lines, just under the 500-line guidance tier | Put RF1 to RF3 changes in the dot-sourced files, not the entry script | Guidance tier only; no gate | Reviewer `@(Get-Content).Count` |

No covered file in the branch diff is at or above 700 logical lines (largest 656, `Get-EpicProgressReport.Tests.ps1`), so no file-size Warning row applies. `config/file-size-baseline.json` is unchanged.

## Positive Observations

- Version 1 and legacy-array migration is explicit and tested, and the real live file migrated cleanly.
- `-StepDefaultMinutes` and `-ResetBaseline` with `-PairSamples` are validated before any I/O.
- The duration ledger is keyed and merged with a stage_timing-replaces-tick rule, and the 1000-sample ceiling is tested.
- Blockage depends only on recorded fields; `awaiting_ci` is excluded, as specified.
- The git call set is unchanged (`fetch`, `worktree list`, `show`), and item mode skips the fetch.

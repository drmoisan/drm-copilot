# Feature Audit: Progress Report Orchestration Step Model (Issue #1118)

**Audit Date:** 2026-11-08
**Branch:** `feature/progress-orchestration-step-model` @ `b82381ed282445648ee6a9e95f106778999e9f85`
**Review type:** Re-audit after remediation cycle 1.
**Companion artifacts:** `policy-audit.2026-11-08T00-12.md`, `code-review.2026-11-08T00-12.md`.

## Scope and Baseline

- Work mode: `full-feature` (`issue.md` marker), so the AC sources are `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`. The two lists hold the same 18 criteria with the same wording, apart from `spec.md` references in the user story.
- Baseline: merge base `12825cb00` with `origin/main`. At the baseline the report counted only checked plan tasks, with velocity, SD, and range lines, and a version 1 state file.
- Diff: `12825cb00..b82381ed2`, 72 files. PR context `artifacts/pr_context.summary.txt` is fresh at this head (generated 2026-11-08 00:04:26 UTC).
- Prior review: `feature-audit.2026-11-07T23-18.md` graded AC5 PARTIAL (RF1) and the other 17 PASS. Cycle 1 re-checked AC5 (`evidence/qa-gates/ac-checkoff.2026-11-08T00-01.md`).
- Evidence used: cycle-1 executor evidence under `evidence/`, plus reviewer runs at this head. These were scoped Pester (262 of 262 passed); PSSA (0 findings); `cmp` of ten bundle copies; a parse of the coverage XML and junit; ten reverted-fix mutants (each caught); a real-file probe of the live #1114 checkpoint with `S7_feature_review` reopened; real epic runs from the main checkout and from the item worktree; and a real `-Issue 1118` run. Every run used a scratch `-StatePath`.

## Acceptance Criteria Inventory

| ID | Criterion (short form) |
|---|---|
| AC1 | Every step typed; plan tasks are execution steps; cycles add plan/preflight (full only), execution per task, review, and ci after a PR; test shows total growing and percentage falling, and a light cycle adding no plan or preflight |
| AC2 | Headline equals the per-type sum with in-progress credit; Full per-type table with all columns; unit tests and Full golden |
| AC3 | No-sample type reported as `<type>: no measured duration; default <n> min` and marked `default`; built-in and override tests |
| AC4 | Blocked by recorded state only, one test per D1 field; span subtracted from tick split; no elapsed accrual; `awaiting_ci` and zero tick rate not blocked |
| AC5 | In-progress review, ci, or main-sync on the Now line with elapsed against median; two runs without new ticks give a lower estimate |
| AC6 | Batched ticks split; closed execution stage replaces tick samples |
| AC7 | Ledger retains more than `-SampleCap`, de-duplicates by key, kept by `-ResetBaseline` |
| AC8 | Version 1 and legacy array migrated; version 3, blank, unparseable give empty state |
| AC9 | CLI backward compatibility, including the forwarder tests unchanged |
| AC10 | `Item` parameter set with `-Issue`, no kickoff or epic checkpoint, default state path, rejects `-EpicFolder` |
| AC11 | TL;DR four lines in both modes; no velocity, SD, or range line |
| AC12 | Composite and unrecognized stage time reported as unmapped with no samples; approximate samples marked |
| AC13 | Git call set and write and native-call seams unchanged |
| AC14 | SKILL.md updated, under 500 lines, byte-identical bundle, contract test updated |
| AC15 | New scripts in `core.json` once, byte-identical bundle, in `productionPaths` and the forbidden-token scan |
| AC16 | No production file above 500 lines where a split exists, none above 800, recorded under `evidence/` |
| AC17 | In-memory fixtures, no temporary files, leak scan clean |
| AC18 | One parallel Pester run and one `pytest -n auto` run with zero failures; each skill file at or above 85% line coverage |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC1 | PASS | `Get-EpicProgressCycleStep` and its Steps tests (total growth, light cycle); the new test 'adds a ci step to a cycle opened after an S8_create_pr stage' covers the aliased PR stage. Real `-Issue 1118` run counts cycle 1: 41 execution steps (27 plan tasks plus the 14 tasks of `remediation-plan.2026-11-07T23-18.md`) and a second review step, 52 steps in total. |
| AC2 | PASS | `Get-EpicProgressTypeEstimate` sums `remaining x median` plus `max(0, median - elapsed)`; Full golden in Render tests; the real `-Issue 1118` Full output shows all eight columns and a Total row (`0 h 34 min`) equal to the headline. RF2 now gives the in-progress execution step its tick-anchored elapsed time (Gather tests). |
| AC3 | PASS | Real runs print `pr: no measured duration; default 3 min` and `(default)` markers; override tests in Durations tests. |
| AC4 | PASS | Unchanged in cycle 1. `Get-EpicProgressBlockage` checks only the five D1 fields and excludes `awaiting_ci`; the blocked span feeds the tick split; the one-feature golden shows a blocked step excluded (`1 blocked step excluded`). |
| AC5 | PASS | Unit tests: 'reports a lower remaining estimate with an open feature_review stage' (Now `#1118 review (0 h 10 min of median 0 h 14 min)`, 29 then 25 min), 'prints the same TL;DR golden for the live stage names', 'reports a lower remaining estimate on a later run with no new checked task', 'shows an in-progress review on the Now line', and 'prints the Now line with elapsed against median for review, ci and main-sync', all passed in `pester-parallel-final.2026-11-07T23-53.md` and in the reviewer's run. Live data: #1038 merged before this re-audit, so the reviewer probed the real #1114 checkpoint (live alias names) with `S7_feature_review` open. The Now line showed 10, 15, then 20 minutes elapsed, and the estimate fell from 29 to 25 minutes. Removing the alias lookup (mutant) fails the two live-name tests. Non-blocking note: a re-audit inside a remediation cycle has only a composite stage and prints `0 h 00 min` (code review NB1, consistent with Decision D2). |
| AC6 | PASS | `Get-EpicProgressTickSample` divides `(now - lastTick - blocked) / newly checked`; the closed-stage branch emits `stage_timing` samples that replace tick samples. The #1114 probe drew 19 execution samples from a closed `S5_atomic_execution` stage. |
| AC7 | PASS | Ledger cap 1000 per type, independent of `-SampleCap`; key de-duplication; reset keeps the ledger (Gather and Durations tests). |
| AC8 | PASS | Reviewer real epic run against a scratch copy of the live version 1 file exited 0. State tests cover the legacy array, version 3, blank, and unparseable text. |
| AC9 | PASS | CLI parameters are unchanged in cycle 1 (the entry script is untouched). `-EpicFolder documentation-estate-tooling` in Full mode (reviewer) and `-Mode TLDR` (executor `sample-report.2026-11-08T00-00.md`) exit 0. Forwarder test file unchanged and passing in the reviewer's run. |
| AC10 | PASS | `ItemMode` tests (parameter sets, `-EpicFolder` with `-Issue` rejected, default state path). The reviewer's real `-Issue 1118` run exits 0 and uses item wording throughout (RF3). |
| AC11 | PASS | Four TL;DR lines in epic, one-feature epic, and item mode (goldens; reviewer real runs). No velocity, SD, or range line in the reviewer's Full outputs. |
| AC12 | PASS | Composite and unrecognized names go to the unmapped line and give no sample. The real `-Issue 1118` run shows `unmapped stages 0 h 22 min` (the `promotion` stage) and composite remediation time. Approximate samples are marked `(approx)` on `main-sync` in the main-checkout epic run. |
| AC13 | PASS | Entry script unchanged in cycle 1; it runs only `fetch -q origin`, `worktree list --porcelain`, and `show`; the repository-constraints tests passed in the reviewer's run. |
| AC14 | PASS | SKILL.md 453 lines, lists the aliases and the item and singular wording; byte-identical bundle (`cmp`); SkillContract tests 'lists the live stage-name aliases' and 'states the item-mode and singular report wording' pass. |
| AC15 | PASS | `core.json` adds the four paths once each (no file added in cycle 1); bundle copies identical; `productionPaths` includes them. |
| AC16 | PASS | Reviewer logical counts: largest production file 495, all below 500; `evidence/qa-gates/file-size.2026-11-07T23-44.md`. |
| AC17 | PASS | Reviewer grep of the test files found no temporary-file API; `leak-scan-final.2026-11-07T23-44.md` reports 0 findings for the eleven test files and no allowlist change. |
| AC18 | PASS | junit 16092 tests, 0 failures, 0 errors; pytest 16213 passed, 0 failed; reviewer parse of the coverage XML: 95.56% to 100% for the nine skill files; coverage written after the last code commit. |

User-facing wording (prior RF3): the reviewer's real item run and the one-feature fixture output print `#1118 is not done yet.`, `| State | Item |`, a Running row without a wave label, `points since the measurement started`, `not this item's cost alone`, `The only feature is not done yet.`, and `1 blocked step excluded`. No epic or plural phrase remains in item or single-count output.

Caller observations: (a) is a run-location effect. The epic checkpoint is gitignored and present only in the main checkout; from there, or with `-CheckpointPath`, the output is correct, and the silent fallback predates the branch (non-blocking NB2). (b) is consistent with Decision D2 and the in-progress rule (non-blocking NB1). See `code-review.2026-11-08T00-12.md`.

## Summary

18 of 18 criteria pass. RF1, RF2, and RF3 are resolved. Four non-blocking items (NB1 to NB4) are recorded in the code review. No blocking finding remains. Verdict: PASS. No remediation-inputs file is written for this review.

## Acceptance Criteria Check-off

- Newly checked by this review: none. The cycle-1 executor re-checked AC5 in both files (`ac-checkoff.2026-11-08T00-01.md`); this review confirms AC5 as PASS, and it stays checked.
- Unchecked by this review: none.
- All 18 criteria are checked in `spec.md` and in `user-story.md` (reviewer read of both files at this head).
- The `## Definition of Done` items in `spec.md` are not acceptance criteria and were not changed.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/spec.md`, `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/user-story.md`
- Total AC items: 18 per file
- Checked off (delivered): 18 per file
- Remaining (unchecked): 0 per file
- Items remaining: none

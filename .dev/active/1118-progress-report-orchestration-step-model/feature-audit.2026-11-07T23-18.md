# Feature Audit: Progress Report Orchestration Step Model (Issue #1118)

**Audit Date:** 2026-11-07
**Branch:** `feature/progress-orchestration-step-model` @ `84a25a90a17f38e31a90b7e81ce3461d91e96ddb`
**Companion artifacts:** `policy-audit.2026-11-07T23-18.md`, `code-review.2026-11-07T23-18.md`, `remediation-inputs.2026-11-07T23-18.md`.

## Scope and Baseline

- Work mode: `full-feature` (`issue.md` marker), so the AC sources are `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`. The two lists hold the same 18 criteria with the same wording, apart from `spec.md` references in the user story.
- Baseline: merge base `12825cb00` with `origin/main`. At the baseline the report counted only checked plan tasks, with velocity, SD, and range lines, and a version 1 state file.
- Diff: `12825cb00..84a25a90a`, 57 files. PR context `artifacts/pr_context.summary.txt` is fresh at this head.
- Evidence used: the executor's evidence under `evidence/`, plus reviewer runs at this head: scoped Pester (247 of 247 passed), PSSA (0 findings), `cmp` of ten bundle copies, coverage XML parse, real epic runs in TLDR and Full mode from the main checkout against a copy of the live version 1 state, and pure-function probes with live stage names.
- The executor had checked off all 18 criteria before this review.

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
| AC1 | PASS | `Get-EpicProgressCycleStep` and its Steps tests (total growth, light cycle). Reviewer read of the code matches the spec rule. |
| AC2 | PASS | `Get-EpicProgressTypeEstimate` sums `remaining x median` plus `max(0, median - elapsed)`; Full golden in Render tests; the reviewer's Full run shows all eight columns and a Total row. RF2 affects the value of `elapsed` for execution, not the formula. |
| AC3 | PASS | Real run prints `research: no measured duration; default 13 min` and `(default)` markers; override tests in Durations tests. |
| AC4 | PASS | `Get-EpicProgressBlockage` checks only the five D1 fields and excludes `awaiting_ci`; `Get-EpicProgressBlockedSecond` feeds the tick split; blocked steps accrue elapsed time only up to `BlockedSince`. |
| AC5 | PARTIAL | The unit tests pass with the catalog stage name `review`. On real data the criterion fails: live and committed checkpoints name the stage `feature_review` or `S7_feature_review`, which maps to `unmapped`. The reviewer's real run printed `#1038 review (0 h 00 min of median 0 h 14 min)` while the stage had been open about 70 minutes, and a probe with `feature_review` gives the same 39-minute estimate at +10 and +15 minutes (29 and 25 minutes with `review`). See RF1. Unchecked by this review. |
| AC6 | PASS | `Get-EpicProgressTickSample` divides `(now - lastTick - blocked) / newly checked`; the closed-stage branch emits `stage_timing` samples that `Merge-EpicProgressDuration` lets replace tick samples. |
| AC7 | PASS | Ledger cap 1000 per type, independent of `-SampleCap`; key de-duplication; reset keeps the ledger (Gather and Durations tests). |
| AC8 | PASS | Reviewer real run against a copy of the live version 1 file: output state `version=2 unit=steps start=1794047491 baselineDone=638 weekly=13 samples=1`. State tests cover the legacy array, version 3, blank, and unparseable text. |
| AC9 | PASS | Param block diff against the merge base: no existing attribute changed; `-EpicFolder documentation-estate-tooling -Mode TLDR` and Full both exit 0 (reviewer runs); forwarder test file unchanged and passing in the reviewer's run. |
| AC10 | PASS | `ItemMode` tests (parameter sets, `-EpicFolder` with `-Issue` rejected, default state path); executor real item run exit 0. Wording defects in item mode are tracked as RF3, which this criterion does not cover. |
| AC11 | PASS | Four TL;DR lines in both modes (goldens; reviewer runs); no velocity, SD, or range line in the reviewer's Full output. |
| AC12 | PASS | Composite and unrecognized names go to the unmapped line and give no sample (`Get-EpicProgressStageSample`); approximate samples marked `(approx)`, visible on `main-sync` in the reviewer's Full run. The criterion holds as written. RF1 concerns names that should not be unrecognized. |
| AC13 | PASS | Entry script runs only `fetch -q origin`, `worktree list --porcelain`, and `show`; the repository-constraints tests (`Get-EpicProgressReport.Tests.ps1` lines 547-558) list the four new files. |
| AC14 | PASS | SKILL.md 440 lines; byte-identical bundle (`cmp`); the old "wording does not change" statement is gone (grep); SkillContract tests pass. |
| AC15 | PASS | `core.json` diff adds the four paths once each; bundle copies identical; `productionPaths` includes them. |
| AC16 | PASS | Reviewer logical counts: largest production file 495, all below 500; `evidence/qa-gates/file-size.2026-11-07T23-06.md`. |
| AC17 | PASS | Reviewer grep of the test files found no temporary-file API; `leak-scan-final.2026-11-07T23-05.md` reports 0 findings in the folder. |
| AC18 | PASS | junit 16077 tests, 0 failures, 0 errors; pytest 16213 passed, 0 failed; reviewer parse of coverage XML: 95.56% to 100% for the nine skill files. |

User-facing wording (caller request): `evidence/other/sample-report.2026-11-07T23-07.md` and reviewer probes show `None of the 1 features is done yet.`, `1 of 1 features are done.`, `(1 blocked steps excluded)`, and, in item mode, `points since the epic started` and `it is not the epic's cost alone`. These are recorded as RF3 (blocking). The item-mode execution Now line `1 h 20 min of median 0 h 03 min, over median` is recorded as RF2 (blocking).

## Summary

17 of 18 criteria pass; AC5 is PARTIAL. Three blocking findings require remediation: RF1 (High, `autonomous`, design scope) for the stage and step vocabulary, RF2 (Medium, `autonomous`, contained) for the in-progress execution elapsed time, and RF3 (Medium, `autonomous`, contained) for report wording. Because RF1 changes the spec's normalization rule, the remediation path is full. Verdict: REMEDIATION_REQUIRED.

## Acceptance Criteria Check-off

- Newly checked by this review: none. The executor had already checked all 18 criteria; the 17 graded PASS stay checked.
- Unchecked by this review: AC5 (`An in-progress review, ci, or main-sync step appears on the TL;DR Now line ...`), in both `spec.md` and `user-story.md`, because it is PARTIAL.
- The `## Definition of Done` items in `spec.md` are not acceptance criteria and were not changed.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/spec.md`, `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/user-story.md`
- Total AC items: 18 per file
- Checked off (delivered): 17 per file
- Remaining (unchecked): 1 per file
- Items remaining: "An in-progress `review`, `ci`, or `main-sync` step appears on the TL;DR `**Now:**` line with its elapsed time against its median, and two runs at different times with no new checked tasks produce a lower remaining estimate on the later run. Verified by unit tests."

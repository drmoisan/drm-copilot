# Feature Audit: Progress Report Orchestration Step Model (Issue #1118)

**Audit Date:** 2026-11-08
**Branch:** `feature/progress-orchestration-step-model` @ `d5f4ff971160186c29d794422098f6314e7b8268`
**Review type:** Re-audit after remediation cycle 2.
**Companion artifacts:** `policy-audit.2026-11-08T01-07.md`, `code-review.2026-11-08T01-07.md`.

## Scope and Baseline

- Work mode: `full-feature` (`issue.md` marker), so the AC sources are `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`. The two lists hold the same 18 criteria with the same wording, apart from `spec.md` references in the user story.
- Baseline: merge base `12825cb00` with `origin/main`. At the baseline the report counted only checked plan tasks, printed velocity, SD, and range lines, and kept a version 1 state file.
- Diff: `12825cb00..d5f4ff971`, 92 files. PR context `artifacts/pr_context.summary.txt` is fresh at this head (generated 2026-11-08 01:01:33 UTC).
- Prior review: `feature-audit.2026-11-08T00-12.md` graded 18 of 18 PASS with non-blocking NB1 to NB4. Cycle 2 addressed NB1, NB3, and NB4 without editing any criterion text. The reviewer's diff of both files over `b82381ed2..d5f4ff971` shows no checkbox line changed.
- Evidence used: cycle-2 executor evidence under `evidence/`, plus reviewer runs at this head:
  - scoped Pester (268 of 268 passed) and PSSA (0 findings);
  - `cmp` of ten bundle copies, and a parse of the coverage XML and junit;
  - four reverted-fix mutants, each caught;
  - a real-file parse of the `policy-consistency` checkpoint;
  - real epic TL;DR and Full runs from the main checkout against a scratch copy of the live version 1 state;
  - a real `-Issue 1118` run and the two CLI rejection paths.

  Every run used a scratch `-StatePath`.

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
| AC1 | PASS | Unchanged in cycle 2. `Get-EpicProgressCycleStep` and its Steps tests (total growth, light cycle) pass. The real `-Issue 1118` run counts both cycles: 66 steps in total, 62 done. |
| AC2 | PASS | `Get-EpicProgressTypeEstimate` arithmetic is unchanged; cycle 2 adds only the `StartRecorded` property. The Full golden passes. The reviewer's real epic Full run shows all eight columns and a Total row (`0 h 45 min`) equal to the headline. |
| AC3 | PASS | The real epic Full run prints ten `<type>: no measured duration; default <n> min` lines and `(default)` markers. The override tests in the Durations tests pass. |
| AC4 | PASS | Unchanged in cycle 2. The Blockage tests for each D1 field, `awaiting_ci`, and the blocked-span split pass in the reviewer's run. |
| AC5 | PASS | Steps with a recorded start keep the elapsed form: 'prints the Now line with elapsed against median for review, ci and main-sync' and the ItemMode cases 'reports a lower remaining estimate with an open feature_review stage' (29 then 25 min), 'shows an in-progress review on the Now line', and 'reports a lower remaining estimate on a later run with no new checked task' pass unchanged in the reviewer's run and in `pester-parallel-final.2026-11-08T00-55.md`. The NB1 change affects only steps with no recorded start, which the criterion does not cover. Those steps now read `start not recorded` instead of a zero elapsed figure. |
| AC6 | PASS | Unchanged in cycle 2; Durations and Gather tick-split tests pass. |
| AC7 | PASS | Unchanged in cycle 2. NB4 removes only `items` entries, and the ledger is kept: the 'drops the stored anchor' test leaves `Ledger` untouched, and the live run kept the six `main-sync` samples. |
| AC8 | PASS | Real run on a scratch copy of the live version 1 file (`baselineDone` 404, 14 task-count samples). The written state has `version` 2, `unit` `steps`, `baselineDone` 615 (the current step count), the original `startUnixSeconds` 1794047491, `baselineWeeklyPct` 13, and one new check-in sample, so the task-count samples were discarded. The State tests cover the legacy array, version 3, blank, and unparseable text. |
| AC9 | PASS | The entry script is unchanged in cycles 1 and 2. Reviewer real runs from the main checkout: `-EpicFolder documentation-estate-tooling -Mode TLDR` exits 0 with four lines, and `-EpicFolder documentation-estate-tooling` (Full) exits 0 with 52 lines, twice. `-ResetBaseline -PairSamples` throws before I/O. The forwarder test file `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` is unchanged and passes. |
| AC10 | PASS | The ItemMode tests pass. The real `-Issue 1118 -Mode TLDR` run exits 0 with item wording. `-EpicFolder` with `-Issue` fails parameter-set binding. |
| AC11 | PASS | Four TL;DR lines in the real epic and item runs and in the new Render golden ('prints start not recorded ...' asserts `$lines.Count` 4). No velocity, SD, or range line appears in the real Full output. |
| AC12 | PASS | Composite and unrecognized names give no sample. The `policy-consistency` parse leaves `S3_promotion` unmapped. `main-sync` reads `(approx)` in the real epic Full run. NB3 moves `S2_feature_documents` from unmapped to `spec`, as the amended spec normalization paragraph states. |
| AC13 | PASS | Entry script unchanged; the repository-constraints tests pass in the reviewer's run. |
| AC14 | PASS | SKILL.md is 455 lines and states the alias, the Now-line form, and the merged-item anchor removal. Its bundle copy is byte-identical (`cmp`). SkillContract 'lists the live stage-name aliases' and 'states the Now line form without a recorded start and the merged-item anchor removal' pass. |
| AC15 | PASS | No file added in cycle 2; `core.json` keeps its four entries once each; bundle copies identical; the push-down contract tests pass in `pytest-parallel-final.2026-11-08T00-58.md`. |
| AC16 | PASS | Reviewer logical counts: largest production file 495, all below 500; `evidence/qa-gates/file-size.2026-11-08T00-49.md`. |
| AC17 | PASS | The cycle-2 test additions use only in-memory fixtures. `leak-scan-final.2026-11-08T00-49.md` reports 0 findings with no allowlist change. |
| AC18 | PASS | junit: 16098 tests, 0 failures, 0 errors. pytest: 16213 passed, 0 failed. The reviewer's parse of the coverage XML gives 95.56% to 100% for the nine skill files. The coverage file was written after the last code commit. |

Prior non-blocking items: NB1, NB3, and NB4 are resolved (see `code-review.2026-11-08T01-07.md`). NB2 remains non-blocking and outside cycle 2 scope.

## Summary

18 of 18 criteria pass. No blocking finding remains. Verdict: PASS. No remediation-inputs file is written for this review.

## Acceptance Criteria Check-off

- Newly checked by this review: none (all 18 were already checked).
- Unchecked by this review: none.
- All 18 criteria are checked in `spec.md` and in `user-story.md` (reviewer count of both `## Acceptance Criteria` sections at this head). Cycle 2 changed no criterion text or checkbox.
- The `## Definition of Done` items in `spec.md` are not acceptance criteria and were not changed.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/spec.md`, `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/user-story.md`
- Total AC items: 18 per file
- Checked off (delivered): 18 per file
- Remaining (unchecked): 0 per file
- Items remaining: none

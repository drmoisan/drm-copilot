# Feature Audit — Issue #935 (hook-test-isolation-737-remainder), re-audit after remediation cycle 3

**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Head reviewed:** `ddadd0835e302f3e45cd60808356e7cb5872ca3e` (PR #956)

## Total Blocking Findings: 1

There is one blocking finding: COV-1 (`external_dependency`), and AC-24 is FAIL.

- The PR CI coverage file of run 38922641167 (head `3ab81c26f`, code identical to HEAD) reports 89.66% line coverage, below the 90.42% baseline.
- Against main at the same population (`5d2d9a972`, 90.23%) the PR is 105 covered lines lower, all in unchanged production modules under `.claude/lib/orchestrator-state/` and `EpicScopeResolution.psm1`.
- Cycle 3 found no Write Set change that restores the attribution. The recorded decision (`evidence/other/cov1-decision.2026-10-16T15-56.md`) selects Pester profiler mode, delivered by issue #953 / PR #959 outside this item. PR #959 is treated as not yet merged, so AC-24 cannot be settled within this item yet.

All other CI-dependent criteria were satisfied in run 38922641167. Their confirmation on the final head is pending-CI item PC-1, which is non-blocking. No other criterion is FAIL or PARTIAL.

## Scope and Baseline

- Baseline: `origin/main` (resolved base `main`) at merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`. `origin/main` has since advanced to `d72ec6a10`; the range `5bdf22d0f..origin/main` changes no file under `.claude/lib/worktree-resolution`, `scripts/powershell/PoshQC` or `config/` and contains no #953 or #959 commit.
- CI coverage baseline: run 38730332356 at `adb9aa5f0` (90.42%). Main at the merge-base `5bdf22d0f`: 90.45% (run 38885440106).
- Work mode: `full-bug` (`issue.md`). AC source: `spec.md` `## Acceptance Criteria` only; `user-story.md` is absent by design.
- Scope: the full branch diff `origin/main...HEAD`.
- CI evidence used by this review: run 38922641167 (pull_request event, head `3ab81c26f`; `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` both success).
  - This review downloaded `poshqc-test-results` (Windows JUnit: 10793 testcases, 0 failures; coverage file) and read it directly.
  - `git diff --stat 3ab81c26f HEAD` over `tests`, `.claude`, `.codex`, `.github`, `scripts`, `config` and `extensions` is empty; the later commits changed only feature-folder documents.
  - Run 38928004778 on HEAD was queued at review time.

## Acceptance Criteria Inventory

There are 26 criteria (AC-1..AC-26), all in checkbox format.

- Checked before this review: 7 (AC-9, AC-13, AC-20, AC-21, AC-22, AC-25, AC-26).
- Newly checked off by this review: none.
- Classification:
  - 7 verified locally or from the PR body.
  - 18 CI-dependent: 17 satisfied at `3ab81c26f` and awaiting final-head confirmation; 1 FAIL (AC-24).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC-1 | UNVERIFIED (pending final-head CI) | Branches suite 16 testcases, 0 failures in run 38922641167; both jobs success. Fail-before `regression-testing/fail-before-ac1-ac2.2026-10-16T01-54.md`. |
| AC-2 | UNVERIFIED (pending final-head CI) | Row `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` in the Branches suite, 0 failures in run 38922641167. |
| AC-3 | UNVERIFIED (pending final-head CI) | Branches 16, Predicate 10 and legacy guard 25 testcases, 0 failures in run 38922641167; no pre-existing row renamed. |
| AC-4 | UNVERIFIED (pending final-head CI) | HookReference suite 41 testcases, 0 failures in run 38922641167; fail-before `fail-before-exception.r1-r2.2026-10-16T01-59.md`. |
| AC-5 | UNVERIFIED (pending final-head CI) | R2 (a)-(d) rows in the HookReference suite, 0 failures in run 38922641167. |
| AC-6 | UNVERIFIED (pending final-head CI) | `regression-testing/fail-before-ac6.2026-10-16T01-54.md` present. CI-artifact provenance is confirmed by the orchestrator at S9. |
| AC-7 | UNVERIFIED (pending final-head CI) | Discovery suite 365 testcases, 0 failures in run 38922641167, which includes the `AC-4` rows for the seven AC-6 suites. None of the seven is in the diff. |
| AC-8 | UNVERIFIED (pending final-head CI) | Discovery suite 0 failures in run 38922641167, including the `AC-5b` and `F-3 non-vacuity` rows. |
| AC-9 | PASS | Header of `EpicStateIsolation.Helpers.ps1` records the shape-B residual limit and the R2 relaxation; file unchanged in cycle 3. |
| AC-10 | UNVERIFIED (pending final-head CI) | `F-3 detects <Form>` and `F-3 ignores ...` rows in the HookReference suite, 0 failures in run 38922641167; fail-before `fail-before-exception.f3.2026-10-16T02-21.md`. |
| AC-11 | UNVERIFIED (pending final-head CI) | Row `F-3 process-spawning report includes a variable-built hook path` and the existing `AC-5` rows, 0 failures in run 38922641167. |
| AC-12 | UNVERIFIED (pending final-head CI) | `AC-5b` and `F-3 non-vacuity` rows, 0 failures in run 38922641167; the CI-log extract under `evidence/other/` is still to be recorded at S9. |
| AC-13 | PASS | `Get-EpicStateLoadedSourceClosure` seeds only from `Get-EpicStateHookLiteral`. The cycle-3 CR-R4 change replaces two ordinal checks with `Test-EpicStateIsolationExcludedHookName`, which applies the same two checks, so the seed set is unchanged. The Discovery header still states that variable-built loads are reported, not added to the closure. |
| AC-14 | UNVERIFIED (pending final-head CI) | Original 428 lines. CI run 38922641167: 47 + 5 = 52 = baseline 51 + 1. |
| AC-15 | UNVERIFIED (pending final-head CI) | Original 418 lines. CI run 38922641167: 20 + 6 = 26 = baseline 25 + 1. |
| AC-16 | UNVERIFIED (pending final-head CI) | Original 271 lines. CI run 38922641167: 60 + 61 = 121 = baseline 120 + 1. |
| AC-17 | UNVERIFIED (pending final-head CI) | Original 402 lines; consumers not in the diff. CI run 38922641167: `enforcement-hooks-no-python-invocation` 32 = baseline 32; epic-scope 54 = baseline 54. |
| AC-18 | UNVERIFIED (pending final-head CI) | Baseline half in `evidence/baseline/ci-baseline.2026-10-16T00-11.md`; post-split CI half to be recorded under `evidence/qa-gates/` at S9. |
| AC-19 | UNVERIFIED (pending final-head CI) | `test-name-uniqueness` (5) and `BlastRadius.HistoricalRuns` (9) passed in run 38922641167; `test_blast_radius_historical_runs.py` is in the Python jobs of the final-head run. None of the three files is in the diff. |
| AC-20 | PASS | Recomputed at HEAD with `wc -l`: all 18 code files at or below 500 lines (maximum 454). |
| AC-21 | PASS | `git diff --name-only origin/main...HEAD` lists only the 18 `tests/` Write Set paths and feature-folder paths. The COV-1 decision keeps the PoshQC settings change in #953, so this criterion stays satisfied. |
| AC-22 | PASS | The same diff lists none of the AC-6 suites or the concurrent-item files. |
| AC-23 | UNVERIFIED (pending final-head CI) | Local half: R3 single clean pass (`r3-loop-status.2026-10-16T15-50.md`). Both PoshQC jobs success at `3ab81c26f`; final-head run 38928004778 queued. |
| AC-24 | FAIL | PR CI coverage 89.66% (16531/18437, run 38922641167) is below the 90.42% baseline, though not below 85%. Main at the same population (`5d2d9a972`) reads 90.23%. No production file is excluded. Settlement depends on #953 / PR #959. See COV-1. |
| AC-25 | PASS | `r3-determinism-search.2026-10-16T15-52.md`; the cycle-3 code delta (two lines) adds no banned API. |
| AC-26 | PASS | `spec.md` `## Decisions` D1-D6 present; the PR #956 description section `## Follow-ups and Operator Decisions (AC-26)` lists N-2, F-6, F-3, shape-B and I-3. |

## Summary

- PASS: 7 (AC-9, AC-13, AC-20, AC-21, AC-22, AC-25, AC-26).
- UNVERIFIED pending final-head CI: 18 (AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23). Each was satisfied in CI run 38922641167, whose code equals HEAD.
- FAIL: 1 (AC-24).
- PARTIAL: 0.

## Acceptance Criteria Check-off

- Newly checked off by this review in `spec.md`: none.
- Already checked and re-confirmed: AC-9, AC-13, AC-20, AC-21, AC-22, AC-25, AC-26.
- Left unchecked:
  - AC-1..AC-8, AC-10..AC-12, AC-14..AC-19 and AC-23 are pending final-head CI. Per `acceptance-criteria-tracking` `### CI-Dependent Criteria`, the item's orchestrator checks them off at S9. The planned merge of `origin/main` after PR #959 will produce a new final head.
  - AC-24 is FAIL (COV-1).

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
- Total AC items: 26
- Checked off (delivered): 7
- Remaining (unchecked): 19
- Items remaining: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-23, AC-24

## Findings

### Blocking

- COV-1 (`external_dependency`): AC-24 FAIL. PR CI line coverage is 89.66%, below the 90.42% baseline.
  - The same-population loss against main (`5d2d9a972`) is 105 covered lines in unchanged production modules: `.claude/lib/orchestrator-state/` (104) and `EpicScopeResolution.psm1` (1). `WorktreeResolution.psm1` is 112/144 in both the PR and main at `5d2d9a972`.
  - Cycle 3 established that no Write Set change restores the attribution at the merged head (`T-U4-NO-LONGER`; FX-1, FX-2, FX-23 not restored).
  - The recorded decision selects profiler mode through issue #953 / PR #959, and #935 must not make that change. Settlement waits for PR #959 to merge, followed by the merge of `origin/main` and the final-head CI coverage comparison. If the root figure remains below the baseline under profiler mode, the decision record's option-1 acceptance applies.

### Pending CI (non-blocking)

- PC-1: final-head confirmation of AC-1..AC-8, AC-10..AC-12, AC-14..AC-19 and AC-23 (run 38928004778, or the head after the post-#959 merge). Owner: orchestrator at S9.

### Non-blocking

- DOC-1 (Low, carried): the PR #956 description covers cycle 1 only and describes COV-1 as a denominator mismatch. Update it with cycles 2 and 3, the decision record and the dependency on PR #959.
- EV-2 (Low): the decision record's settlement procedure targets only `WorktreeResolution.psm1` = 142. Main's own CI now reads 112 for that file, and the PR's remaining loss is in other modules. Decide AC-24 from the root counter against the baseline and against main at the same population, with a full per-file diff.
- SYNC-1 (Info): the branch is behind `origin/main` (`d72ec6a10`); the merge planned after PR #959 resolves it. PR CI already builds the pull_request merge ref, so the CI figures above include current main.

## Assumptions

- The stamp `2026-10-16T16-02` was read from the UTC host clock (`date -u`).
- PoshQC was not re-run by this review. Local results come from the executor's evidence and the on-disk files; CI results come from the downloaded artifacts of runs 38922641167, 38915587310, 38914467202, 38911869997, 38907131337 and 38885440106.
- PR #959 is treated as not merged, as instructed; `origin/main` at `d72ec6a10` contains no #953 or #959 commit.
- The PR run 38922641167 and main run 38911869997 are treated as the same population because their root totals are equal (18437) and the pull_request merge ref was built after `5d2d9a972` became main. This was not confirmed from the merge-ref SHA.
- The Linux job's per-row results were not downloaded; its conclusion (`success`) is taken from the run record.

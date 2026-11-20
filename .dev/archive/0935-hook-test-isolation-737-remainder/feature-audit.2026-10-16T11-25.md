# Feature Audit — Issue #935 (hook-test-isolation-737-remainder), re-audit after remediation cycle 2

**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Head reviewed:** `1d364d0c16fa77a1ed38ce16c5506ee55b5bf38c` (PR #956)

## Total Blocking Findings: 1

There is one blocking finding: COV-1 (`autonomous`), and AC-24 is FAIL.

- The PR CI coverage file of run 38890188058 reports 90.17% line coverage. Its isolation-guard code is identical to HEAD.
- That figure is below the 90.42% baseline, and the loss is in the attribution of `WorktreeResolution.psm1` (112 vs 142 covered lines).
- The cycle-2 investigation located the trigger in the Write Set unit U4.

All other CI-dependent criteria were satisfied in run 38890188058. Their confirmation on the final head (run 38893096135, in progress) is pending-CI item PC-1, which is non-blocking. No other criterion is FAIL or PARTIAL.

## Scope and Baseline

- Baseline: `origin/main` (resolved base `main`) at merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`.
- CI coverage baseline: run 38730332356 at `adb9aa5f0` (90.42%). Main at the previous merge-base `b6be46b5e` is 90.44%. The `b6be46b5e..5bdf22d0f` range changes no file under `.claude/lib/worktree-resolution`, `scripts/powershell/PoshQC` or `config/`.
- Work mode: `full-bug` (`issue.md`). AC source: `spec.md` `## Acceptance Criteria` only; `user-story.md` is absent by design.
- Scope: the full branch diff `origin/main...HEAD`.
- CI evidence used by this review: run 38890188058 (head `988ed2210`; `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` both success).
  - This review downloaded `poshqc-test-results` (Windows JUnit: 10537 testcases, 0 failures; coverage file) and read it directly.
  - `git diff --stat 988ed2210 HEAD` over the five isolation-guard files is empty. Between `988ed2210` and HEAD the branch changed only feature-folder documents and merged `origin/main`.

## Acceptance Criteria Inventory

There are 26 criteria (AC-1..AC-26), all in checkbox format.

- Checked before this review: 6 (AC-9, AC-13, AC-20, AC-21, AC-22, AC-25).
- Newly checked off by this review: AC-26.
- Classification:
  - 7 verified locally or from the PR body.
  - 18 CI-dependent: 17 satisfied at `988ed2210` and awaiting final-head confirmation; 1 FAIL (AC-24).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC-1 | UNVERIFIED (pending final-head CI) | CI run 38890188058: the three `F-1 non-compliant` and two `F-1 compliant` rows Passed; both jobs success. Fail-before `regression-testing/fail-before-ac1-ac2.2026-10-16T01-54.md`. |
| AC-2 | UNVERIFIED (pending final-head CI) | Row `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` Passed in run 38890188058; `Get-EpicStateIsolationHookDotSource` ends with `return $null`. |
| AC-3 | UNVERIFIED (pending final-head CI) | Branches, Predicate and legacy guard suites: 0 failures in run 38890188058; no pre-existing row renamed. |
| AC-4 | UNVERIFIED (pending final-head CI) | R1 rows in the HookReference suite Passed in run 38890188058; fail-before `fail-before-exception.r1-r2.2026-10-16T01-59.md`. |
| AC-5 | UNVERIFIED (pending final-head CI) | R2 (a)-(d) rows Passed in run 38890188058. |
| AC-6 | UNVERIFIED (pending final-head CI) | `regression-testing/fail-before-ac6.2026-10-16T01-54.md` present. The criterion's CI-artifact provenance is confirmed by the orchestrator at S9. |
| AC-7 | UNVERIFIED (pending final-head CI) | Run 38890188058: the `AC-4 ... complies with the baseline isolation form for every closure seam` row Passed for all seven AC-6 suites (read by this review from the JUnit). None of the seven is in the diff. |
| AC-8 | UNVERIFIED (pending final-head CI) | Discovery suite 0 failures in run 38890188058, including both `AC-5b` rows and both `F-3 non-vacuity` rows. |
| AC-9 | PASS | Header of `EpicStateIsolation.Helpers.ps1` records the shape-B residual limit and the R2 relaxation (lines 20-28, re-read at HEAD). |
| AC-10 | UNVERIFIED (pending final-head CI) | `F-3 detects <Form>` and `F-3 ignores ...` rows Passed in run 38890188058; fail-before `fail-before-exception.f3.2026-10-16T02-21.md`. |
| AC-11 | UNVERIFIED (pending final-head CI) | Row `F-3 process-spawning report includes a variable-built hook path` and the existing `AC-5` rows Passed in run 38890188058. |
| AC-12 | UNVERIFIED (pending final-head CI) | `AC-5b` and `F-3 non-vacuity` rows Passed for both surfaces in run 38890188058; the CI-log extract under `evidence/other/` is still to be recorded at S9. |
| AC-13 | PASS | `Get-EpicStateLoadedSourceClosure` seeds only from `Get-EpicStateHookLiteral`; the Discovery header states that variable-built loads are reported, not added to the closure. |
| AC-14 | UNVERIFIED (pending final-head CI) | Original 428 lines. CI run 38890188058: 47 + 5 = 52 = baseline 51 + 1. |
| AC-15 | UNVERIFIED (pending final-head CI) | Original 418 lines. CI run 38890188058: 20 + 6 = 26 = baseline 25 + 1. |
| AC-16 | UNVERIFIED (pending final-head CI) | Original 271 lines. CI run 38890188058: 60 + 61 = 121 = baseline 120 + 1. |
| AC-17 | UNVERIFIED (pending final-head CI) | Original 402 lines; consumers not in the diff. CI run 38890188058: `enforcement-hooks-no-python-invocation` 32 = baseline 32; epic-scope 54 = baseline 54. |
| AC-18 | UNVERIFIED (pending final-head CI) | Baseline half in `evidence/baseline/ci-baseline.2026-10-16T00-11.md`; post-split CI half to be recorded under `evidence/qa-gates/` at S9. |
| AC-19 | UNVERIFIED (pending final-head CI) | `test-name-uniqueness` (5) and `BlastRadius.HistoricalRuns` (9) passed in run 38890188058; `test_blast_radius_historical_runs.py` result is in the Python jobs of the final-head run. None of the three files is in the diff. |
| AC-20 | PASS | Recomputed at HEAD: all 18 code files at or below 500 lines (maximum 454). |
| AC-21 | PASS | `git diff --name-only origin/main...HEAD` at `1d364d0c1` lists only `tests/` Write Set paths and feature-folder paths. |
| AC-22 | PASS | The same diff lists none of the AC-6 suites or the concurrent-item files. |
| AC-23 | UNVERIFIED (pending final-head CI) | Local half: R2 single clean pass (`r2-loop-status.2026-10-16T11-05.md`). Both PoshQC jobs success at `988ed2210`; final-head run 38893096135 in progress. |
| AC-24 | FAIL | PR CI coverage 90.17% (16383/18170, run 38890188058) is below the 90.42% baseline, though not below 85%. The prior head `da4ccf4f0` measured 90.27%. No production file is excluded. See COV-1. |
| AC-25 | PASS | This review's grep over the cycle-2 delta found no new banned API; `r2-determinism-search.2026-10-16T11-07.md`. |
| AC-26 | PASS | `spec.md` `## Decisions` D1-D6 present. The PR #956 description, section `## Follow-ups and Operator Decisions (AC-26)`, lists N-2, F-6, F-3, shape-B and I-3. |

## Summary

- PASS: 7 (AC-9, AC-13, AC-20, AC-21, AC-22, AC-25, AC-26).
- UNVERIFIED pending final-head CI: 18 (AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23). Each was satisfied in CI run 38890188058, whose isolation-guard code equals HEAD.
- FAIL: 1 (AC-24).
- PARTIAL: 0.

## Acceptance Criteria Check-off

- Newly checked off by this review in `spec.md`: AC-26.
- Already checked and re-confirmed: AC-9, AC-13, AC-20, AC-21, AC-22, AC-25.
- Left unchecked:
  - AC-1..AC-8, AC-10..AC-12, AC-14..AC-19 and AC-23 are pending final-head CI. Per `acceptance-criteria-tracking` `### CI-Dependent Criteria`, the item's orchestrator checks them off at S9.
  - AC-24 is FAIL (COV-1).

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
- Total AC items: 26
- Checked off (delivered): 7
- Remaining (unchecked): 19
- Items remaining: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-23, AC-24

## Findings

### Blocking

- COV-1 (`autonomous`): AC-24 FAIL. PR CI line coverage is 90.17%, below the 90.42% baseline. The cause is `.claude/lib/worktree-resolution/WorktreeResolution.psm1` attribution: 112/144 on the PR against 142/144 on main.
  - The cycle-2 isolation runs reproduced the loss locally, and reverting unit U4 alone restored it. U4 is the nine isolation-guard paths, all in spec `## Write Set`.
  - The BLOCKED record's phrase "root cause outside the write set" refers to the suspected Pester breakpoint mechanism, not to the trigger. Bisection inside U4 and a change in the identified write-set file are executable without an external decision.
  - Escalate as a human decision only if no change inside the Write Set restores the attribution.

### Pending CI (non-blocking)

- PC-1: final-head confirmation of AC-1..AC-8, AC-10..AC-12, AC-14..AC-19 and AC-23 on run 38893096135. Owner: orchestrator at S9.

### Non-blocking

- DOC-1 (Low): the PR #956 description covers cycle 1 only and describes COV-1 as a denominator mismatch, which the CI evidence supersedes. Update it with cycle 2 and the final COV-1 state.
- EV-1 (Low): `evidence/qa-gates/r2-cov-blocked.2026-10-16T10-52.md` says "root cause outside the write set" while naming trigger unit U4, which is inside the Write Set. The next cycle's evidence should state the trigger location and the mechanism separately.
- CR-R4 (Info) and CR-R5 (Info): see `code-review.2026-10-16T11-25.md`.

## Assumptions

- The stamp `2026-10-16T11-25` was read from the UTC host clock (`date -u`).
- PoshQC was not re-run by this review. Local results come from the executor's evidence and the on-disk files; CI results come from the downloaded artifact of run 38890188058.
- Run 38890188058 is treated as representative of HEAD for the isolation-guard rows because the guard files are identical. The coverage population there is 18170 lines, against 18162 at `da4ccf4f0`. The merge of `origin/main` into HEAD may shift the population again, and the final-head coverage file decides AC-24.
- The Linux job's per-row results were not downloaded; its conclusion (`success`) is taken from the run record.

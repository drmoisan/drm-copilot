# Feature Audit — Issue #935 (hook-test-isolation-737-remainder), final-pass review after the option 1 decision and the main merge

**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Head reviewed:** `a266488308a85e5febb828ca8cdde7a98a84fa4c` (local; one docs-only commit ahead of the pushed `048d76cd8`, PR #956)

## Total Blocking Findings: 3

- TEST-1 (autonomous): the spec Test Strategy edge cases for the F-1 predicate (`switch`, loop, `trap`, `else`, multi-clause `if`) have no rows. Detail in `code-review.2026-10-16T20-56.md`.
- AC-CHK-1 (autonomous): AC-24 is checked (`- [x]`) in `spec.md` although the amendment beneath it states that the criterion is not met as written, and its remaining clauses (85% floor and no exclusion on the final PR head) depend on CI on a final head that does not exist yet.
- COV-2 (autonomous): the on-disk PowerShell coverage file `artifacts/pester/powershell-coverage.xml` was overwritten by the 13-suite shuffled run and reads 10.82% (1994 / 18437 lines). The review contract treats that file as the repo-wide figure, which is below the 85% floor. Detail in `policy-audit.2026-10-16T20-56.md`.

COV-1 is no longer blocking: the option 1 decision record accepts the baseline gap for AC-24, and the PR changes no production line.

## Scope and Baseline

- Baseline: `origin/main` at merge-base `fa27cd5edcb39a5d5f63054c3e38cefef18ab316` (equal to `origin/main`; the branch merged it at `048d76cd8`).
- CI coverage baseline for AC-24: run 38730332356 at `adb9aa5f0`, 90.42% (`evidence/baseline/ci-baseline.2026-10-16T00-11.md`).
- Work mode: `full-bug` (`issue.md` line 12). AC source: `spec.md` `## Acceptance Criteria` only; `user-story.md` is absent by design.
- Scope: the full branch diff `origin/main...HEAD` (170 paths: 18 code paths under `tests/scripts/` and feature-folder documents).
- Code identity: none of the 18 code files changed between `ddadd0835` (cycle-3 head) and HEAD, and main changed none of them between `5bdf22d0f` and `fa27cd5ed`. The only commits after `048d76cd8` are documents.
- CI on the pushed head `048d76cd8` (code identical to HEAD): run 38963921545 (pull_request event) concluded `success` during this review; every job succeeded, including `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)` and the four `quality-checks7` Python jobs. This review downloaded `poshqc-test-results`: Windows JUnit 10793 testcases, 0 failures; root LINE coverage 16531 / 18437 = 89.66%.
- HEAD `a26648830` is not pushed, and the fixes required by this review change code, so the final PR head will differ from both. The CI-dependent criteria below therefore remain pending-CI on that final head, with run 38963921545 as the latest code-identical evidence.

## Acceptance Criteria Inventory

There are 26 criteria (AC-1..AC-26), all in checkbox format.

- Checked before this review: 8 (AC-9, AC-13, AC-20, AC-21, AC-22, AC-24, AC-25, AC-26).
- Newly checked off by this review: none.
- Classification:
  - 7 verified locally or from the PR body (AC-9, AC-13, AC-20, AC-21, AC-22, AC-25, AC-26).
  - 19 CI-dependent: 18 satisfied on code-identical heads in earlier PR runs and awaiting final-head confirmation; AC-24 accepted for its baseline clause by the option 1 decision, with its 85% floor clause awaiting final-head CI.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC-1 | UNVERIFIED (pending final-head CI) | Branches suite 16 / 16 in the seeded shuffled run on the merged tree and 0 failures in run 38922641167 (code identical). Fail-before `regression-testing/fail-before-ac1-ac2.2026-10-16T01-54.md`. Linux job of run 38963921545: success. |
| AC-2 | UNVERIFIED (pending final-head CI) | Row `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` (Branches line 314); `Get-EpicStateIsolationHookDotSource` returns `$null` at the end (HookReference helper line 298). |
| AC-3 | UNVERIFIED (pending final-head CI) | Branches 16, Predicate 10, legacy guard 25 in the shuffled run; no pre-existing row renamed (diffs add only `$script:UnderTest` lines and new rows). |
| AC-4 | UNVERIFIED (pending final-head CI) | HookReference suite 41 / 41 in the shuffled run; R1 positive and negative rows at lines 48-148; fail-before `fail-before-exception.r1-r2.2026-10-16T01-59.md`. |
| AC-5 | UNVERIFIED (pending final-head CI) | R2 (a)-(d) rows at HookReference suite lines 152-237. |
| AC-6 | UNVERIFIED (pending final-head CI) | `regression-testing/fail-before-ac6.2026-10-16T01-54.md` present; CI provenance confirmed by the orchestrator at S9. |
| AC-7 | UNVERIFIED (pending final-head CI) | Discovery suite 365 / 365 in the shuffled run on the merged tree; none of the seven suites is in the diff. |
| AC-8 | UNVERIFIED (pending final-head CI) | Discovery suite 365 / 365 in the shuffled run, including rows for suites merged from main; per-suite CI record due at S9. |
| AC-9 | PASS | `EpicStateIsolation.Helpers.ps1` header lines 22-28 record the shape-B limit and the R2 relaxation. |
| AC-10 | UNVERIFIED (pending final-head CI) | `F-3 detects <Form>` (five forms) and `F-3 ignores a Join-Path used only by <Reader>` (three readers) at HookReference suite lines 241-316; fail-before `fail-before-exception.f3.2026-10-16T02-21.md`. |
| AC-11 | UNVERIFIED (pending final-head CI) | Row `F-3 process-spawning report includes a variable-built hook path` (line 318); existing `AC-5` rows in the Discovery suite. |
| AC-12 | UNVERIFIED (pending final-head CI) | `AC-5b` and `F-3 non-vacuity` rows (Discovery suite lines 164-185); the CI-log extract under `evidence/other/` is still to be recorded at S9 (no such record exists yet). |
| AC-13 | PASS | `Get-EpicStateLoadedSourceClosure` seeds from `Get-EpicStateHookLiteral` only; row `F-3 closure stays literal-seeded` (HookReference suite line 339); Discovery header lines 21-24 state the rule. |
| AC-14 | UNVERIFIED (pending final-head CI) | Original 428 lines; pure move confirmed; shuffled run 47 + 5 = 52 = baseline 51 + 1. |
| AC-15 | UNVERIFIED (pending final-head CI) | Original 418 lines; pure move confirmed; shuffled run 20 + 6 = 26 = baseline 25 + 1. |
| AC-16 | UNVERIFIED (pending final-head CI) | Original 271 lines; pure move confirmed; shuffled run 60 + 61 = 121 = baseline 120 + 1. |
| AC-17 | UNVERIFIED (pending final-head CI) | Original helper 402 lines; consumers not in the diff; shuffled run 32 = 32 and 54 = 54. |
| AC-18 | UNVERIFIED (pending final-head CI) | Baseline half in `evidence/baseline/ci-baseline.2026-10-16T00-11.md`; the post-split CI half is recorded at S9 (P7-T5). |
| AC-19 | UNVERIFIED (pending final-head CI) | The three files are not in the diff; in run 38963921545 the four Python jobs concluded success, and the Windows JUnit reports `test-name-uniqueness` 5 and `BlastRadius.HistoricalRuns` 9 testcases with 0 failures. |
| AC-20 | PASS | `wc -l` at HEAD: all 18 code files at or below 500 lines (maximum 454). |
| AC-21 | PASS | `git diff --name-only origin/main...HEAD`: 170 paths, the 18 Write Set code paths plus feature-folder paths only. |
| AC-22 | PASS | The same diff lists none of the AC-6 suites or the concurrent-item files. |
| AC-23 | UNVERIFIED (pending final-head CI) | Local half: R3 single clean pass; no code change since. Both PoshQC jobs success in run 38963921545 on `048d76cd8` (code identical to HEAD). The fixes in this pass require a new local loop and a new final-head run. |
| AC-24 | UNVERIFIED (pending final-head CI); baseline clause accepted under option 1 | The amendment line (spec line 215) accepts the baseline gap and keeps the 85% floor and no-exclusion clauses. Run 38963921545 on `048d76cd8` (code identical to HEAD) reads 89.66% (16531/18437), above 85% and below the 90.42% baseline; no production file is excluded. The final-head root figure is recorded by P7-T6. The checkbox is already checked; see AC-CHK-1. |
| AC-25 | PASS | Grep over the 18 files for the seven banned APIs: matches only in comments, string fixtures and a pre-existing string comparison. |
| AC-26 | PASS | `spec.md` `## Decisions` D1-D6; PR #956 section `## Follow-ups and Operator Decisions (AC-26)` lists N-2, F-6, F-3, shape-B and I-3. |

## Summary

- PASS: 7 (AC-9, AC-13, AC-20, AC-21, AC-22, AC-25, AC-26).
- UNVERIFIED pending final-head CI: 19 (AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24).
- FAIL: 0.
- PARTIAL: 0.

## Acceptance Criteria Check-off

- Newly checked off by this review in `spec.md`: none.
- Already checked and re-confirmed: AC-9, AC-13, AC-20, AC-21, AC-22, AC-25, AC-26.
- Already checked but not verifiable at review time: AC-24 (AC-CHK-1). This review did not modify `spec.md`.
- Left unchecked: AC-1..AC-8, AC-10..AC-12, AC-14..AC-19 and AC-23, pending final-head CI. Per `acceptance-criteria-tracking` `### CI-Dependent Criteria`, the item's orchestrator checks them off at S9.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
- Total AC items: 26
- Checked off (delivered): 8 (includes AC-24, checked ahead of verification; see AC-CHK-1)
- Remaining (unchecked): 18
- Items remaining: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-23

## Findings

### Blocking

- AC-CHK-1 (Medium): `spec.md` line 214 shows `- [x] AC-24`. The amendment on line 215 states that AC-24 is "not met as written for the baseline comparison", and the remaining clauses refer to the final PR head. Run 38963921545 on `048d76cd8` meets the floor (89.66%), but the final head will change with the fixes in this pass and has no CI yet. `acceptance-criteria-tracking` rule 4 (non-negotiable) requires an item that cannot be fully delivered or verified to stay `- [ ]`, and `### CI-Dependent Criteria` requires CI-dependent items to stay unchecked until S9. Fix: change line 214 to `- [ ] AC-24:` (criterion text unchanged); append to the amendment line: "Left unchecked under acceptance-criteria-tracking rule 4; the accepted state is recorded in the P7-T10 ledger as ACCEPTED-OPTION-1 once P7-T6 confirms the 85% floor and no exclusion on the final head." Record the change in a new note under `evidence/other/` that cites `cov1-decision-option1.2026-10-16T20-38.md` line 19 as the superseded instruction, without editing that record.
- TEST-1 (Medium): see the code review.
- COV-2 (Medium): see the policy audit.

### Pending CI (non-blocking)

- PC-1: final-head confirmation of AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23 and the AC-24 floor clause, on the head pushed after the fixes in this pass. Owner: orchestrator at S9 (P7-T2..P7-T10).

### Non-blocking

- PLAN-1 (Low): `plan.2026-10-15T17-44.md` P7-T6 (line 205) accepts only "post-change percent is not lower than baseline and is at least 85.00", and P7-T10 (line 209) accepts only "every AC is `PASS` ... or the item routes to remediation". Under the option 1 decision both acceptance rules route the item to remediation even when the floor holds. Fix: amend P7-T6 acceptance to "post-change percent is at least 85.00; the baseline comparison, the same-population main figure and the per-file diff are recorded (AC-24 baseline clause accepted under `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`)", and amend P7-T10 to allow `ACCEPTED-OPTION-1` for AC-24 with that record name; P7-T10 then checks AC-24 only in that state.
- EV-3 (Info): `evidence/other/cov1-decision-option1.2026-10-16T20-38.md` line 15 cites "`evidence/qa-gates/` cycle 3 final repo-scope run" without a file name. Fix: in the new AC-CHK-1 note, cite `evidence/qa-gates/r3-ps-test-repo.2026-10-16T15-50.md` line 14 (covered 11602, missed 697, 94.33%) as the source.
- DOC-2, DOC-3, DOC-4: see the code review.

## Assumptions

- The stamp `2026-10-16T20-56` was read from the UTC host clock (`date -u`).
- PoshQC was not re-run by this review. Local results come from the executor and orchestrator evidence and the on-disk `artifacts/pester/` files; CI results come from run records and downloaded artifacts.
- The option 1 decision record is taken as the authoritative disposition of the AC-24 baseline clause, as instructed. This review does not assess the coordinator's authority.
- The shuffled-run counts are taken from the record, which reads them from the local `artifacts/pester/pester-junit.xml` written by the same call (file time 16:48 local).

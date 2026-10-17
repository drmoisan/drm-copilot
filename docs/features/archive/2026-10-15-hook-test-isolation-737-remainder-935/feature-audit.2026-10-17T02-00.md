# Feature Audit — Issue #935 (hook-test-isolation-737-remainder), cycle R4 pre-push full-diff review

**Branch:** `bug/hook-test-isolation-737-remainder-935-r4` (no PR yet)
**Head reviewed:** `e93227f7584e79837334fe3d463fafcf11159993` (local, not pushed) plus the uncommitted P5-T12 check-off in `remediation-plan.2026-10-16T20-56.md`

## Total Blocking Findings: 1

- AC-CHK-2 (autonomous): 17 acceptance criteria are checked in `spec.md` on the strength of CI run 38963921545 on the former PR #956 head `048d76cd8`, while cycle R4 has changed the suites and helpers they name and the plan itself waits for the follow-on PR CI to confirm them on the final head. Detail and fix below.

## Scope and Baseline

- Baseline: merge-base `cdc7bbc9945263f791c5627fea339e31ab53b21f` (the PR #956 merge). `origin/main` has moved to `b8fcd7790` (PC-2).
- CI coverage baseline for AC-24: run 38730332356 at `adb9aa5f0`, 90.42% (`evidence/baseline/ci-baseline.2026-10-16T00-11.md`).
- Work mode: `full-bug` (`issue.md` `- Work Mode: full-bug`). AC source: `spec.md` `## Acceptance Criteria` only.
- Scope: the full branch diff `origin/main...HEAD` (54 paths: 8 code paths under `tests/scripts/claude-hooks/`, all in the spec `## Write Set`, and 46 feature-folder paths).
- CI: the branch head has no CI run (no PR). The latest CI evidence is run 38963921545 on `048d76cd8`, whose code differs from HEAD in the eight files above. Local evidence for this head: repository-scope run 10806 testcases, 0 failures, root line coverage 89.67% (report `Pester (10/17/2026 01:37:47)`).

## Acceptance Criteria Inventory

There are 26 criteria (AC-1..AC-26), all in checkbox format.

- Checked at HEAD: 25 (all except AC-24). AC-1..AC-23 and AC-26 were checked by `c5e9a77d3` from run 38963921545; AC-24 was unchecked by `306c798de` (AC-CHK-1).
- Newly checked off by this review: none.
- Classification at HEAD:
  - 8 verified at this head without new CI (AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22, AC-25).
  - 18 depend on CI on the follow-on PR head or on its description (AC-1..AC-5, AC-7, AC-8, AC-10..AC-12, AC-14..AC-17, AC-19, AC-23, AC-24, AC-26).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC-1 | UNVERIFIED (pending final-head CI) | Branches suite changed in R4 (six rows added). Local: Branches 22/22 in the co-run and in the isolated run. Fail-before `regression-testing/fail-before-ac1-ac2.2026-10-16T01-54.md`. Checked in `spec.md` (AC-CHK-2). |
| AC-2 | UNVERIFIED (pending final-head CI) | Row `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` passes locally; the Branches suite changed in R4. Checked (AC-CHK-2). |
| AC-3 | UNVERIFIED (pending final-head CI) | Local: Branches 22, Predicate 10, legacy guard 25; no existing row renamed (the R4 diff adds rows only). Checked (AC-CHK-2). |
| AC-4 | UNVERIFIED (pending final-head CI) | HookReference suite changed in R4 (CR-F4 row, header); local 42/42. Checked (AC-CHK-2). |
| AC-5 | UNVERIFIED (pending final-head CI) | R2 rows unchanged; the HookReference suite and helper changed in R4 (CR-F2 attributes). Local 42/42. Checked (AC-CHK-2). |
| AC-6 | PASS | `regression-testing/fail-before-ac6.2026-10-16T01-54.md`, confirmed from run 38404520141 in `qa-gates/s9-ac-verification.2026-10-16T21-46.md` (P7-T8). The record is historical and unaffected by R4. |
| AC-7 | UNVERIFIED (pending final-head CI) | Discovery suite and helpers changed in R4 (PERF-1, PERF-2). Local: Discovery 371/371; none of the seven AC-6 suites is in the diff. Checked (AC-CHK-2). |
| AC-8 | UNVERIFIED (pending final-head CI) | Discovery suite restructured in R4 (Describe `-ForEach` data, BeforeAll report, six PERF rows). Local 371/371; the 365 pre-existing row names hash identically before and after. Checked (AC-CHK-2). |
| AC-9 | PASS | `EpicStateIsolation.Helpers.ps1` header still records the shape-B limit and the R2 relaxation; R4 changed only its consumer sentence. |
| AC-10 | UNVERIFIED (pending final-head CI) | F-3 detector rows unchanged; the detector's helper changed in R4 (CR-F2, CR-F4). Checked (AC-CHK-2). |
| AC-11 | UNVERIFIED (pending final-head CI) | `Get-EpicStateProcessSpawningHook` depends on `Get-EpicStateVariableHookLoad`, whose emission changed in R4 (CR-F2). The AC-5 rows now read discovery-time suite lists. Checked (AC-CHK-2). |
| AC-12 | UNVERIFIED (pending final-head CI) | The AC-5b and F-3 non-vacuity rows changed in R4 (PERF-3); the CI-log extract recorded for PR #956 (`s9-ac-verification`, P7-T7) predates the change. Checked (AC-CHK-2). See also CR-G1. |
| AC-13 | PASS | `Get-EpicStateLoadedSourceClosure` still seeds only from `Get-EpicStateHookLiteral` (Discovery helper line 233); the header paragraph (lines 23-26) states the rule; row `F-3 closure stays literal-seeded` passes locally. |
| AC-14 | UNVERIFIED (pending final-head CI) | ManifestBranch comment changed in R4. Local repository-scope JUnit: 47 + 5 = 52. Checked (AC-CHK-2). |
| AC-15 | UNVERIFIED (pending final-head CI) | Files unchanged in R4; local JUnit 20 + 6 = 26. CI Passed counts on the follow-on PR head are re-read at P7-T5. Checked (AC-CHK-2). |
| AC-16 | UNVERIFIED (pending final-head CI) | Files unchanged in R4; local JUnit 60 + 61 = 121. Checked (AC-CHK-2). |
| AC-17 | UNVERIFIED (pending final-head CI) | Files unchanged in R4; local JUnit 32 and 54. Checked (AC-CHK-2). |
| AC-18 | PASS | Baseline counts in `evidence/baseline/ci-baseline.2026-10-16T00-11.md`; post-split CI counts in `qa-gates/s9-ac-verification.2026-10-16T21-46.md` (P7-T5). Both records exist from CI artifacts. |
| AC-19 | UNVERIFIED (pending final-head CI) | `test-name-uniqueness` reads the test names that R4 extends by 13 rows; local 5/5. Checked (AC-CHK-2). |
| AC-20 | PASS | `wc -l` at HEAD: all eight code files at or below 500 (maximum 466). |
| AC-21 | PASS | `git diff --name-only origin/main...HEAD`: 54 paths, the eight code paths (each listed in `spec.md` `## Write Set`) and feature-folder paths; none under `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/` or `config/`. |
| AC-22 | PASS | The same diff lists none of the AC-6 suites or the concurrent-item files. |
| AC-23 | UNVERIFIED (pending final-head CI) | Local half: R4 P5-T1..P5-T5 single clean pass. CI half: both PoshQC jobs on the follow-on PR head. Checked (AC-CHK-2). |
| AC-24 | UNVERIFIED (pending final-head CI); baseline clause accepted under option 1 | Unchecked, with the S9 sentence on the amendment line (`spec.md` lines 214-215). Local repository-scope 89.67% meets the 85% floor; `config/poshqc-coverage.json` is not in the diff. The final-head CI figure is recorded by P7-T6. |
| AC-25 | PASS | `grep` over the eight files for the seven banned APIs, re-run by this review: six matches, all comments, detection tokens or string fixtures. |
| AC-26 | UNVERIFIED (pending the follow-on PR description) | `## Decisions` D1-D6 are present. The criterion's PR-description clause is confirmed by P7-T9 on the follow-on PR, whose body pr-author writes after S9 (DOC-2); PR #956's body satisfied it for that PR. Checked (AC-CHK-2). |

## Summary

- PASS: 8 (AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22, AC-25).
- UNVERIFIED pending final-head CI or the follow-on PR description: 18 (AC-1..AC-5, AC-7, AC-8, AC-10..AC-12, AC-14..AC-17, AC-19, AC-23, AC-24, AC-26).
- FAIL: 0.
- PARTIAL: 0.

## Acceptance Criteria Check-off

- Newly checked off by this review: none. This review did not modify `spec.md`.
- Already checked and re-confirmed at this head: AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22, AC-25.
- Already checked but not verifiable at this head: AC-1, AC-2, AC-3, AC-4, AC-5, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-19, AC-23, AC-26 (AC-CHK-2).
- Left unchecked: AC-24, pending S9.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
- Total AC items: 26
- Checked off (delivered): 25 (17 of them checked ahead of verification on the final change; see AC-CHK-2)
- Remaining (unchecked): 1
- Items remaining: AC-24

## Findings

### Blocking

- AC-CHK-2 (Medium): `spec.md` lines 191-195, 197-198, 200-202, 204-207, 209, 213 and 217 show `- [x]` for AC-1, AC-2, AC-3, AC-4, AC-5, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-19, AC-23 and AC-26. Commit `c5e9a77d3` checked them from CI run 38963921545 on `048d76cd8` (`evidence/qa-gates/s9-ac-verification.2026-10-16T21-46.md`, titled for PR #956). Cycle R4 then changed the Branches, HookReference and Discovery suites and all four EpicStateIsolation helpers, and the follow-on PR will be built against a `main` that has moved (PC-2). The remediation plan's orchestrator note (1) states that CI on the follow-on PR head supplies the final-head confirmations, and main-plan P7-T10 checks off every AC it records `PASS`. `acceptance-criteria-tracking` rule 4 (non-negotiable) and `### CI-Dependent Criteria` require such criteria to stay `- [ ]` until S9; this is the same rule that AC-CHK-1 applied to AC-24. Fix:
  1. In `spec.md`, change `- [x]` to `- [ ]` on the 17 lines listed above, without changing any criterion text. Leave AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22 and AC-25 checked; they are verified at this head.
  2. Write `evidence/other/r4-ac-recheck-note.<timestamp>.md` stating the change, citing `c5e9a77d3` and run 38963921545 on `048d76cd8` as the superseded basis, and naming the R4 commits (`f96b623ea`, `08130a03e`, `58a355c8a`) that changed the files these criteria name. Do not edit `s9-ac-verification.2026-10-16T21-46.md`.
  3. In the planner revision, update any P0-T3/P3-T1-style spec checkbox counts that the remaining tasks use (25 checked and 1 unchecked become 8 and 18).
  At S9, P7-T2..P7-T9 on the follow-on PR head and P7-T10 re-check the 17 lines.
  Remediability: autonomous; `spec.md` is in the cycle write set (`P_SPEC`) and the fix needs no external input.

### Pending CI and pre-push items (no finding)

- PC-1: final-head confirmation on the follow-on PR of the 18 UNVERIFIED criteria above, the CI results of the 13 new rows (orchestrator notes (2) and (4)), the PERF-5 CI time (note (6)) and the direct timing and shuffle runs or `PERF-DIRECT-UNAVAILABLE` (note (7)). Owner: orchestrator at S9.
- PC-2: `origin/main` moved from `cdc7bbc99` to `b8fcd7790` (about 20 commits, including PR #959's PoshQC shard and coverage-merge modules and new hook suites such as `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`). P6-T2 merges it, re-runs the Discovery suite (the guard judges the new suites) and repeats the repository-scope run before the push. All local evidence of this cycle predates that merge.

### Non-blocking

- CR-G1 (Medium), CR-G2, CR-G3, TEST-2, TEST-3, TEST-4, DOC-5 (Low), DOC-6, CR-G4, CR-G5, CR-G6, CR-G7, PLAN-2, EV-4 (Info): see `code-review.2026-10-17T02-00.md`.

## Assumptions

- The stamp `2026-10-17T02-00` was read from the UTC host clock (`date -u`).
- PoshQC was not re-run by this review. Local results come from the executor evidence and the on-disk `artifacts/pester/` files (coverage report `Pester (10/17/2026 01:37:47)`, file time 21:38 local; JUnit 10806 testcases, file time 21:40 local), which this review read directly.
- The option 1 decision record and the PERF-3 operator direction are taken as authoritative dispositions, as instructed; this review does not assess the authority behind them.
- The orchestrator's earlier plan validation is taken from the delegation prompt; this review re-ran the validator on both plans (`ok: true`).

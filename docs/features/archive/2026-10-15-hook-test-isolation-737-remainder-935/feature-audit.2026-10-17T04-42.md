# Feature Audit — Issue #935 (hook-test-isolation-737-remainder), cycle R4 confirming pre-push full-diff review

**Branch:** `bug/hook-test-isolation-737-remainder-935-r4` (no PR yet)
**Head reviewed:** `ae0d3a03b8c26879bb7ab67be37a149930f7669a` (local, not pushed) plus the uncommitted P6-T30 check-off in `remediation-plan.2026-10-16T20-56.md`

## Total Blocking Findings: 0

No acceptance-criteria state, scope or evidence defect blocks the push. Four non-blocking documentation and evidence findings are listed below (DOC-7, DOC-8, DOC-9, EV-5); the operator ruling requires them to be fixed before the single push.

## Scope and Baseline

- Baseline: merge-base `7516050be5d03293f8964eb54e7bea9951d726ab` (brought in by the P6-T2 merge `009f7d0c7`). `origin/main` has moved to `87f3d8996` (PC-3).
- CI coverage baseline for AC-24: run 38730332356 at `adb9aa5f0`, 90.42% (`evidence/baseline/ci-baseline.2026-10-16T00-11.md`).
- Work mode: `full-bug` (`issue.md` `- Work Mode: full-bug`). AC source: `spec.md` `## Acceptance Criteria` only.
- Scope: the full branch diff `origin/main...HEAD` (78 paths: 9 code paths under `tests/scripts/claude-hooks/`, all in the spec `## Write Set`, and 69 feature-folder paths).
- CI: the branch head has no CI run (no PR). Local evidence for this head: repository-scope run 11149 testcases, 0 failures, root line coverage 89.61% (report `Pester (10/17/2026 04:22:37)`), read from the on-disk files by this review.

## Acceptance Criteria Inventory

There are 26 criteria (AC-1..AC-26), all in checkbox format.

- Checked at HEAD: 8 (AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22, AC-25). Unchecked: 18 (17 unchecked by AC-CHK-2 in `496e7e622`, plus AC-24).
- Newly checked off by this review: none.
- Classification at HEAD:
  - 8 verified at this head without new CI (the checked set above).
  - 18 depend on CI on the follow-on PR head or on its description (AC-1..AC-5, AC-7, AC-8, AC-10..AC-12, AC-14..AC-17, AC-19, AC-23, AC-24, AC-26).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC-1 | UNVERIFIED (pending final-head CI) | Local: Branches 22/22 in the co-run. Unchecked pending S9 (AC-CHK-2). |
| AC-2 | UNVERIFIED (pending final-head CI) | Row passes locally. Unchecked pending S9. |
| AC-3 | UNVERIFIED (pending final-head CI) | Local: Branches 22, Predicate 10, legacy guard 25; no existing row renamed. Unchecked pending S9. |
| AC-4 | UNVERIFIED (pending final-head CI) | HookReference 44/44 locally, including the two TEST-2 braced rows. Unchecked pending S9. |
| AC-5 | UNVERIFIED (pending final-head CI) | R2 rows unchanged; HookReference 44/44 locally. Unchecked pending S9. |
| AC-6 | PASS | `regression-testing/fail-before-ac6.2026-10-16T01-54.md`, confirmed from run 38404520141 in `qa-gates/s9-ac-verification.2026-10-16T21-46.md`. Historical record; unaffected by R4. |
| AC-7 | UNVERIFIED (pending final-head CI) | Discovery 372/372 locally on the merged tree; none of the seven AC-6 suites is in the diff. Unchecked pending S9. |
| AC-8 | UNVERIFIED (pending final-head CI) | Discovery 372/372 locally; the six PERF rows now run in the Memo suite (10/10). The criterion text lists the Discovery rows by prefix (`AC-2`..`AC-6`, `AC-5b`), none of which moved. Unchecked pending S9. |
| AC-9 | PASS | `EpicStateIsolation.Helpers.ps1` header lines 23-29 record the shape-B limit and the R2 relaxation; Phase 6 changed only the consumer list (line 7). |
| AC-10 | UNVERIFIED (pending final-head CI) | F-3 detector rows unchanged; local pass. Unchecked pending S9. |
| AC-11 | UNVERIFIED (pending final-head CI) | Local pass. Unchecked pending S9. |
| AC-12 | UNVERIFIED (pending final-head CI) | `AC-5b` now fails when building its surface report throws (CR-G1; D7 records this as replacing the earlier semantics); it never fails on a report entry. The CI-log extract is re-read at P7-T7. Unchecked pending S9. See DOC-7. |
| AC-13 | PASS | `Get-EpicStateLoadedSourceClosure` still seeds only from `Get-EpicStateHookLiteral` (Discovery helper line 240); the header paragraph at lines 26-29 states that variable-built loads are reported, not added to the closure; row `F-3 closure stays literal-seeded` passes locally. |
| AC-14 | UNVERIFIED (pending final-head CI) | Local repository-scope JUnit: ManifestBranch 5. Unchecked pending S9. |
| AC-15 | UNVERIFIED (pending final-head CI) | Files unchanged in R4. Unchecked pending S9. |
| AC-16 | UNVERIFIED (pending final-head CI) | Files unchanged in R4. Unchecked pending S9. |
| AC-17 | UNVERIFIED (pending final-head CI) | Files unchanged in R4; local 32 and 54 in the co-run. Unchecked pending S9. |
| AC-18 | PASS | Baseline counts in `evidence/baseline/ci-baseline.2026-10-16T00-11.md`; post-split CI counts in `qa-gates/s9-ac-verification.2026-10-16T21-46.md` (P7-T5). Both records exist from CI artifacts; R4 changed only a comment in one split suite. |
| AC-19 | UNVERIFIED (pending final-head CI) | `test-name-uniqueness` reads the test names that R4 extends; local repository-scope run 0 failures. Unchecked pending S9. |
| AC-20 | PASS | `wc -l` at HEAD, re-run by this review: all nine code files at or below 500 (maximum 478); recorded in `qa-gates/r4-rf-line-counts.2026-10-17T04-26.md`. |
| AC-21 | PASS | `git diff --name-only origin/main...HEAD`: 78 paths, the nine code paths (each in spec `## Write Set`, the Memo suite at line 237) and feature-folder paths; none under `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/` or `config/`. |
| AC-22 | PASS | The same diff lists none of the AC-6 suites or the concurrent-item files. |
| AC-23 | UNVERIFIED (pending final-head CI) | Local half: P6-T20..P6-T24 single clean pass. CI half: both PoshQC jobs on the follow-on PR head. Unchecked pending S9. |
| AC-24 | UNVERIFIED (pending final-head CI); baseline clause accepted under option 1 | Unchecked, with the S9 sentence on the amendment line (`spec.md` lines 214-215). Local repository-scope 89.61% meets the 85% floor; `config/poshqc-coverage.json` is not in the diff. The final-head CI figure is recorded by P7-T6. |
| AC-25 | PASS | Grep over the nine files for the seven banned APIs, re-run by this review: six matches, all comments, a detection token or string fixtures; none in the Memo suite. |
| AC-26 | UNVERIFIED (pending the follow-on PR description) | `## Decisions` D1-D7 are present. The PR-description clause is confirmed by P7-T9 after pr-author writes the follow-on PR body (DOC-2). Unchecked pending S9. |

## Summary

- PASS: 8 (AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22, AC-25).
- UNVERIFIED pending final-head CI or the follow-on PR description: 18 (AC-1..AC-5, AC-7, AC-8, AC-10..AC-12, AC-14..AC-17, AC-19, AC-23, AC-24, AC-26).
- FAIL: 0.
- PARTIAL: 0.

## Acceptance Criteria Check-off

- Newly checked off by this review: none. This review did not modify `spec.md`.
- Already checked and re-confirmed at this head: AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22, AC-25.
- Left unchecked pending S9 (main-plan P7-T10): AC-1, AC-2, AC-3, AC-4, AC-5, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-19, AC-23, AC-24, AC-26.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
- Total AC items: 26
- Checked off (delivered): 8
- Remaining (unchecked): 18
- Items remaining: AC-1, AC-2, AC-3, AC-4, AC-5, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-19, AC-23, AC-24, AC-26 (all CI-dependent or PR-description-dependent; owner: orchestrator at S9)

## Findings

### Blocking

None.

### Non-blocking

- DOC-7 (Low): `spec.md` line 178 (`## Test Strategy`, "Error handling and logging verification") reads "`AC-5b` never fails". After CR-G1 the `AC-5b` row fails when building its surface report throws, as D7 (line 226) states. Fix: replace the line with `- Error handling and logging verification: missing and unparseable suite rows keep passing; `AC-5b` never fails on a report entry and fails only when building the surface report throws (D7).` Do not edit the AC-12 criterion text; D7 records the replacement semantics.
- DOC-8 (Info): `spec.md` line 124 (`#### Error handling and logging updates`) cites "`EpicStateIsolation.Discovery.Helpers.ps1` header (lines 16-19)"; the paragraph stating that variable-built loads are reported, not added to the closure, is at lines 26-29 at HEAD. This is the DOC-6 class at a second location. Fix: replace "header (lines 16-19)" with "header (the paragraph beginning `The closure is seeded only from hooks/<name>.ps1 string literals`)".
- DOC-9 (Info): `spec.md` `## Test Strategy`, "Regression tests to add or update" (lines 170-175), lists the Discovery suite only for the `AC-5b` report row and does not name the Memo suite or the PERF memo rows that D7 introduces. Fix: after line 174 add `  - New `enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1`: the ten PERF memo rows (D7), including `PERF parse memo keeps texts that differ only in letter case apart` with its fail-before record `evidence/regression-testing/r4-rf-cr-g3-fail-before.2026-10-17T03-46.md`.` and extend line 174 to `- `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`: `AC-5b` report row and its per-surface build-error capture (D7).`
- EV-5 (Info): `evidence/qa-gates/r4-plan-validation.2026-10-17T03-55.md`, `ORCHESTRATOR-VALIDATION:` line, states that "revision 5 of remediation-plan.2026-10-16T20-56.md is validated by the orchestrator before Phase 6 is delegated"; Phase 6 ran on revision 7 (`d48f58cf8`; `r4-rf-prestate.2026-10-17T03-24.md` records revisions 5 to 7), and the record holds no validator result of its own. Fix: do not edit the existing record; write `evidence/qa-gates/r4-plan-validation.<timestamp>.md` recording `mcp__drm-copilot__validate_orchestration_artifacts` (artifact_type `plan`) `ok: true` for `remediation-plan.2026-10-16T20-56.md` revision 7 (with the P6-T30 check-off) and for `plan.2026-10-15T17-44.md`, run by this review at 2026-10-17T04-42 UTC (policy-audit.2026-10-17T04-42.md section 7), together with the orchestrator's revision 7 pass and the validation of the next revision; reference it from the next findings ledger.
- Code findings TEST-5 (Low), TEST-6, CR-H1, CR-H2 (Info): see `code-review.2026-10-17T04-42.md`.

### Pending CI and pre-push items (no finding)

- PC-1: final-head confirmation on the follow-on PR of the 18 UNVERIFIED criteria above, the CI results of the 19 new rows and the Memo-suite `AC-4` row (orchestrator notes (2) and (4)), the PERF-5 CI time (note (6)) and the direct timing and shuffle runs or `PERF-DIRECT-UNAVAILABLE` (note (7)), with CI reads taken from the newest PR run whose `CI full run` job succeeded (note (8); a docs-only head such as the AC check-off commit runs no PoshQC heavy step). Owner: orchestrator at S9.
- PC-3: `origin/main` moved from `7516050be` to `87f3d8996` (PR #968: three commits; evidence and plan documents of issue #962 and one comment line appended to `scripts/ci/CiChangeScope.psm1`; no path under `tests/scripts/`, `.claude/hooks/` or `.codex/hooks/`). P7-T2 merges it, re-runs the Discovery suite and repeats the repository-scope run before the push; the branch is not yet up to date with `main`.
- DOC-2: the follow-on PR description, written by pr-author after S9 (orchestrator).

## Assumptions

- The stamp `2026-10-17T04-42` was read from the UTC host clock (`date -u`).
- PoshQC was not re-run by this review. Local results come from the executor evidence and the on-disk `artifacts/pester/` files (coverage report `Pester (10/17/2026 04:22:37)`, file time 00:23 local; JUnit 11149 testcases, 0 failures, file time 00:25 local), which this review read directly.
- The option 1 decision record and the PERF-3 operator direction are taken as authoritative dispositions, as instructed; this review does not assess the authority behind them.
- The operator ruling (every finding fixed before the single push) is taken from the delegation prompt.

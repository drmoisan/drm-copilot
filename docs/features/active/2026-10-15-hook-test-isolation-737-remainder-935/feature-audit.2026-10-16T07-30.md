# Feature Audit — Issue #935 (hook-test-isolation-737-remainder), re-audit after remediation cycle 1

**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Head reviewed:** `ef9b856982dc373f871103121ffef6999cbff7c5`

## Total Blocking Findings: 1

One blocking finding: COV-1 (`awaiting_ci`), carried from the policy audit. The on-disk PowerShell coverage artifact reads 66.04%; the R1 full-scan local figure (94.45%) uses a 12280-line population that differs from CI's 18116, so only the PR CI coverage file can settle AC-24. Pending-CI item PC-1 (non-blocking) lists the 19 CI-dependent criteria. No criterion is FAIL or PARTIAL.

## Scope and Baseline

- Baseline: `origin/main` (resolved base `main`) at merge-base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`. CI baseline run 38730332356 is at `adb9aa5f0`; the intervening main changes add no file to the PowerShell coverage roots used by this branch's figures, and the coverage roots configuration is unchanged.
- `origin/main` has since advanced to `b6be46b5e` (PR #948, issue #931); no overlap with this branch's files.
- Work mode: `full-bug` (`issue.md` line 12). AC source: `spec.md` `## Acceptance Criteria` only; `user-story.md` is absent by design.
- Scope: the full branch diff (86 files). The caller's Phase 7 note was treated as context, not a scope limit.
- Additional local evidence used by this re-audit: the on-disk `artifacts/pester/pester-junit.xml` (post-merge run over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, 6342 testcases, 0 failures). It corroborates several criteria but is not the CI artifact the criteria name.

## Acceptance Criteria Inventory

26 criteria (AC-1..AC-26), all in checkbox format. Checked before this review: 6 (AC-9, AC-13, AC-20, AC-21, AC-22, AC-25). This review checked off none; it re-verified the six. Classification: 6 locally verifiable and verified; 19 CI-dependent; 1 split (AC-26: spec half verified, PR-description half requires the PR).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC-1 | UNVERIFIED (pending CI, P7-T3) | Five `F-1 ...` rows passed in the local post-merge JUnit; fail-before `regression-testing/fail-before-ac1-ac2.2026-10-16T01-54.md`. Both CI jobs pending. |
| AC-2 | UNVERIFIED (pending CI, P7-T3) | Row `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` passed locally; `Get-EpicStateIsolationHookDotSource` ends with `return $null` (HookReference helper line 257). |
| AC-3 | UNVERIFIED (pending CI, P7-T3) | Branches 16, Predicate 10, legacy guard 25 testcases passed locally; R1 changed only fixture indentation (CR-N6), no row name. |
| AC-4 | UNVERIFIED (pending CI, P7-T3) | R1 rows unchanged by cycle R1; HookReference suite 33 testcases passed locally. |
| AC-5 | UNVERIFIED (pending CI, P7-T3) | R2 (a)-(d) rows present and passed locally. |
| AC-6 | UNVERIFIED (pending CI, P7-T8) | `fail-before-ac6.2026-10-16T01-54.md` present; the AC requires the CI JUnit artifact of run 38404520141 (P7-T8). |
| AC-7 | UNVERIFIED (pending CI, P7-T4) | All seven AC-6 suites' `AC-4 ... complies with the baseline isolation form` rows passed locally; none of the seven is in the diff. |
| AC-8 | UNVERIFIED (pending CI, P7-T4) | Discovery suite 353 testcases passed locally, including `AC-2 no hard-coded suite list in N2`, the legacy-guard `AC-2` row, both `AC-5b` rows and both `F-3 non-vacuity` rows. |
| AC-9 | PASS | `EpicStateIsolation.Helpers.ps1` header records the shape-B residual limit and the R2 helper-only relaxation (re-read at HEAD). |
| AC-10 | UNVERIFIED (pending CI, P7-T3) | `F-3 detects <Form>` and `F-3 ignores ...` rows present and passed locally; fail-before dossier `fail-before-exception.f3.2026-10-16T02-21.md`. |
| AC-11 | UNVERIFIED (pending CI, P7-T3) | Row `F-3 process-spawning report includes a variable-built hook path` present; AC-5 rows unchanged. |
| AC-12 | UNVERIFIED (pending CI, P7-T3, P7-T7) | `AC-5b` and `F-3 non-vacuity` rows passed locally for both surfaces; the CI log extract under `evidence/other/` is pending P7-T7. |
| AC-13 | PASS | `Get-EpicStateLoadedSourceClosure` still seeds only from `Get-EpicStateHookLiteral`; Discovery header lines 21-24 state that variable-built loads are reported, not added to the closure. |
| AC-14 | UNVERIFIED (pending CI, P7-T5) | Original 428 lines. Local counts 47 + 5 = 52 = baseline 51 + 1. CI counts pending. |
| AC-15 | UNVERIFIED (pending CI, P7-T5) | Original 418 lines. Local counts 20 + 6 = 26 = baseline 25 + 1. |
| AC-16 | UNVERIFIED (pending CI, P7-T5) | Original 271 lines. Local counts 60 + 61 = 121 = baseline 120 + 1. |
| AC-17 | UNVERIFIED (pending CI, P7-T5) | Original 402 lines; consumers not in the diff. Local epic-scope count 54 = baseline 54; `enforcement-hooks-no-python-invocation.Tests.ps1` (claude-runtime) is not in the on-disk run. |
| AC-18 | UNVERIFIED (pending CI, P7-T5) | Baseline half present (`evidence/baseline/ci-baseline.2026-10-16T00-11.md`); post-split CI half pending. |
| AC-19 | UNVERIFIED (pending CI, P7-T9) | The three files are not in the diff; CI results pending. |
| AC-20 | PASS | Recomputed at HEAD: all 18 code files at or below 500 lines (maximum 433); `evidence/qa-gates/r1-line-counts.2026-10-16T06-27.md`. |
| AC-21 | PASS | `git diff --name-only origin/main...HEAD` at `ef9b85698` lists only `tests/` Write-Set paths and feature-folder paths. |
| AC-22 | PASS | Same diff lists none of the AC-6 suites or the concurrent-item files (Grep over the file list returned no match). |
| AC-23 | UNVERIFIED (pending CI, P7-T2) | Local half: R1 single clean pass (`r1-loop-status.2026-10-16T06-26.md`). CI job conclusions pending. |
| AC-24 | UNVERIFIED (pending CI, P7-T6) | Baseline 90.42% recorded. Local figures (66.04% on disk; 94.45% R1 full scan) use a 12280-line population, not CI's 18116. No production file excluded (`config/` not in the diff). See COV-1. |
| AC-25 | PASS | This review's grep over the 18 files found only comments, detection tokens and string fixtures. |
| AC-26 | UNVERIFIED (spec half PASS; PR-description half pending PR creation, P7-T9) | `spec.md` `## Decisions` D2-D6 present; the PR description does not exist yet. |

## Summary

- PASS: 6 (AC-9, AC-13, AC-20, AC-21, AC-22, AC-25); the spec half of AC-26 also passes.
- UNVERIFIED pending CI: 19 (AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24). Local post-merge JUnit results are consistent with every one of them that a local run can observe.
- UNVERIFIED pending PR: AC-26 PR-description half.
- FAIL: 0. PARTIAL: 0.

Remediation cycle R1 closed or dispositioned all nine prior findings. COV-1 remains as a blocking finding classified `awaiting_ci`, tied to AC-24 and P7-T6.

## Acceptance Criteria Check-off

- Newly checked off by this review in `spec.md`: none.
- Already checked and re-confirmed: AC-9, AC-13, AC-20, AC-21, AC-22, AC-25.
- Left unchecked: AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24 (pending CI) and AC-26 (PR description). Per `acceptance-criteria-tracking` `### CI-Dependent Criteria`, the item's orchestrator checks these off at S9 after `ci_gate.conclusion` is `success`, then re-runs the CI gate on the new head.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
- Total AC items: 26
- Checked off (delivered): 6
- Remaining (unchecked): 20
- Items remaining: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-23, AC-24, AC-26

## Findings

### Blocking

- COV-1 (`awaiting_ci`): PowerShell coverage FAIL in `policy-audit.2026-10-16T07-30.md` (on-disk artifact 66.04%; local population 12280 lines against CI 18116). Resolution: P7-T6 reads the `poshqc / PowerShell QC` coverage file on the final PR head.

### Pending CI (non-blocking)

- PC-1: AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24. Owner: orchestrator, plan Phase 7 (P7-T2..P7-T10) at S9.

### Non-blocking

- O-1: AC-26 PR-description half. The PR body must list the operator follow-ups from spec `## Rollout & Follow-up` and the N-2/F-6 decisions.
- O-2: `origin/main` advanced to `b6be46b5e` after the merge-base; update the branch before opening the PR so the PR diff and CI run reflect current main.
- O-3: The on-disk `artifacts/pester/powershell-coverage.xml` was overwritten after the R1 measurement by a two-folder run (66.04%). It should not be cited as the R1 figure; the R1 figure is recorded only in `coverage-comparison.2026-10-16T06-56.md`.
- O-4: CI baseline `B` (`adb9aa5f0`) differs from the current merge-base; P7 artifacts should record both SHAs.
- Code-review observations CR-R1 (Low), CR-R2 (Info), CR-R3 (Info) in `code-review.2026-10-16T07-30.md`.

## Assumptions

- The stamp `2026-10-16T07-30` was read from the UTC host clock (`date -u`).
- PoshQC was not re-run by this review (the MCP PoshQC tools are not in this agent's tool set). Local results come from the executor's evidence and the on-disk JUnit and coverage files, which this review read directly.
- The on-disk JUnit was produced after the merge `ef9b85698` (commit time 03:00:24 -0400; report stamp 03:22:55 local) and reflects the HEAD tree; `git status --porcelain` was empty.
- CI status at HEAD is not available because no pull request exists yet.

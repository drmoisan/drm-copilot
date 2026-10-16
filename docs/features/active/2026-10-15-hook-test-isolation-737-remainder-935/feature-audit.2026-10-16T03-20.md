# Feature Audit — Issue #935 (hook-test-isolation-737-remainder)

**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Head reviewed:** `79386619519d99cb0fed56b5f4b41e42837903d3`

## Total Blocking Findings: 1

One blocking finding: COV-1 (`autonomous`), carried from the policy audit. The only post-change PowerShell coverage artifact reports 66.04%, below the 85% floor, and no repo-wide post-change measurement exists yet. Pending-CI item PC-1 (non-blocking) lists the 19 CI-dependent criteria that cannot be verified before the pull request exists. PR Creation Gate condition 2 accepts criteria listed as pending-CI, and the orchestrator checks them off at S9.

## Scope and Baseline

- Baseline: `origin/main` (resolved base `main`) at merge-base `97559c3e0dcfceb807ae330d3c9e6ae4c5d67964`. The CI baseline run used by the plan (run 38730332356) is at `adb9aa5f0`; `git diff --stat adb9aa5f0 97559c3e0` shows only `.github/dependabot.yml`, one Python test module and Markdown, so the PowerShell baseline counts and the 90.42% coverage baseline still apply.
- Work mode: `full-bug` (`issue.md` line 12). AC source: `spec.md` `## Acceptance Criteria` only; `user-story.md` is absent by design.
- Pre-change state was taken from the diff base (`git diff origin/main...HEAD`) and from the cited commits (`4e8d9f92d`, `a255192220df`, `ae0204c6e58b`), not from executor claims alone.
- Scope: the full branch diff (55 files). The caller's Phase 7 note was treated as context, not a scope limit.

## Acceptance Criteria Inventory

26 criteria (AC-1..AC-26), all in checkbox format. Before this review: 5 checked (AC-9, AC-20, AC-21, AC-22, AC-25). This review checked off AC-13. Classification: 6 locally verifiable and verified; 19 CI-dependent (PR JUnit artifacts, job conclusions, CI coverage file, or the JUnit artifact of run 38404520141); 1 split criterion (AC-26: spec half verified, PR-description half requires the PR).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC-1 | UNVERIFIED (pending CI, P7-T3) | Rows present in Branches suite (`Describe 'issue #903 F-1 conditional ancestors'`, 3 non-compliant and 2 compliant rows with the required finding text). Fail-before: `regression-testing/fail-before-ac1-ac2.2026-10-16T01-54.md` (run 38392312722; helper identity `git diff --stat ae0204c6e HEAD` EMPTY). Per-row results in both CI jobs are not yet available. |
| AC-2 | UNVERIFIED (pending CI, P7-T3) | Row `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` present (fixture dot-sources `Helper.ps1`). `Get-EpicStateIsolationHookDotSource` ends with `return $null` (HookReference helper line 221). Same fail-before record. |
| AC-3 | UNVERIFIED (pending CI, P7-T3) | Recovered `$script:UnderTest = Join-Path $PSScriptRoot 'hooks/enforce-x.ps1'` bindings added in Branches (6), Predicate (8) and legacy guard (12) fixtures; diffs add lines only, so no row name changed. Local test disposition green. |
| AC-4 | UNVERIFIED (pending CI, P7-T3) | 11 `R1 identifies <Case>` rows cover (a)-(d) with assignment and hashtable bindings; 3 negative rows (non-hooks segment by assignment and by hashtable; unbound). Fail-before dossier `fail-before-exception.r1-r2.2026-10-16T01-59.md` (function absent at the F-2-only state). |
| AC-5 | UNVERIFIED (pending CI, P7-T3) | Rows `R2 (a)`..`R2 (d)` present with the required assertions; same dossier explains (a) and (b) failing at the F-2-only state. |
| AC-6 | UNVERIFIED (pending CI, P7-T8) | `fail-before-ac6.2026-10-16T01-54.md` lists the seven suites and "no other failing Discovery row" from the in-tree #903 records, with code identity proven by `git diff --stat a255192 4e8d9f92d~1` EMPTY. The AC requires the record to be taken from the CI JUnit artifact; P7-T8 downloads it. |
| AC-7 | UNVERIFIED (pending CI, P7-T4) | No AC-6 suite is in the diff (verified). Local test disposition green after R1/R2 (`p4-ps-test.2026-10-16T02-18.md`). |
| AC-8 | UNVERIFIED (pending CI, P7-T4) | Local disposition green (`p5-ps-test`, final `ps-test`). Per-suite CI results not yet available. |
| AC-9 | PASS | `EpicStateIsolation.Helpers.ps1` header (lines 18-28) records the shape-B residual limit and the R2 helper-only relaxation. |
| AC-10 | UNVERIFIED (pending CI, P7-T3) | `F-3 detects <Form>` rows for RootVariable bare, RootVariable expandable, two-level binding, Segment, Dynamic spawn; `F-3 ignores ... <Reader>` for Get-FileHash, Get-Content, ParseFile. Fail-before dossier `fail-before-exception.f3.2026-10-16T02-21.md`. |
| AC-11 | UNVERIFIED (pending CI, P7-T3) | Row `F-3 process-spawning report includes a variable-built hook path` asserts `gate.ps1` and `*(.codex/hooks)`; existing AC-5 rows unchanged in the diff. |
| AC-12 | UNVERIFIED (pending CI, P7-T3, P7-T7) | Discovery rows `AC-5b variable-built hook-load report <Surface>` and `F-3 non-vacuity <Surface> ...` present; `evidence/other/` report pending P7-T7. |
| AC-13 | PASS | `Get-EpicStateLoadedSourceClosure` (Discovery helper line 142) is not in any diff hunk and seeds only from `Get-EpicStateHookLiteral` (line 158). Header lines 16-19 state the new detection and that variable-built loads are reported, not added to the closure. Corroborated by row `F-3 closure stays literal-seeded`. |
| AC-14 | UNVERIFIED (pending CI, P7-T5) | Original 428 lines; Describe `manifest branch` moved verbatim (pure-move comparison); new suite has 5 `It` lines including one probe. Baseline Passed 51; post-split counts pending. |
| AC-15 | UNVERIFIED (pending CI, P7-T5) | Original 418 lines, retains `Context 'target resolution matrix'` and the N-2 `Register-EpicStateBaselineMock ... -Surface 'Codex'` call (line 101); two Contexts moved verbatim to CallTarget suite with one probe row. Baseline Passed 25. |
| AC-16 | UNVERIFIED (pending CI, P7-T5) | Original 271 lines; helpers moved to `...command-exemption.Helpers.ps1` and dot-sourced after the hook, the Baseline helper and the epic-scope mock (line 32); #671/#663 Contexts moved to Selectors suite with one probe row. Baseline Passed 120. |
| AC-17 | UNVERIFIED (pending CI, P7-T5) | Original 402 lines; allowlist declaration, policy paragraph and four functions moved to `EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1`, dot-sourced at line 56; the two consumer suites are not in the diff. Passed-count equality (32, 54) pending. |
| AC-18 | UNVERIFIED (pending CI, P7-T5) | Baseline half present: `evidence/baseline/ci-baseline.2026-10-16T00-11.md` (from JUnit of run 38730332356, before the split commit `44a48200c`). Post-split half pending. |
| AC-19 | UNVERIFIED (pending CI, P7-T9) | The three files are not in the diff (verified); CI results pending. |
| AC-20 | PASS | Recomputed by this review: all 18 changed code files at or below 500 lines (maximum 428); `evidence/qa-gates/line-counts.2026-10-16T03-10.md`. |
| AC-21 | PASS | Recomputed at HEAD `793866195`: `git diff --name-only origin/main...HEAD` lists only `tests/` Write-Set paths and feature-folder paths; none under `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`. |
| AC-22 | PASS | Same diff lists none of the AC-6 suites, `validate-*` suites, `hook-dependency-failure*` suites, SubagentStop validators, or the preimplementation-gate modes and epic-scope suites. |
| AC-23 | UNVERIFIED (pending CI, P7-T2) | Local half verified: single clean pass (`loop-status.2026-10-16T03-10.md`; format no change, analyze and test returned without error). CI job conclusions on the final PR head pending. |
| AC-24 | UNVERIFIED (pending CI, P7-T6) | Baseline 90.42% recorded; post-change CI coverage pending. The local post-change artifact (66.04%, scoped run) does not satisfy the criterion; see COV-1. `config/poshqc-coverage.json` is not in the diff, so no production file is excluded. |
| AC-25 | PASS | This review's grep over the 18 files found 9 matches, all comments, detection tokens or string fixtures; none executable. |
| AC-26 | UNVERIFIED (spec half PASS; PR-description half pending PR creation, P7-T9) | `spec.md` `## Decisions` holds D2 (shape-B), D3 (F-3 deferred), D4 (I-3 residue), D5 (N-2 closed), D6 (F-6 mirror drift); `decisions-present.2026-10-16T03-10.md`. The PR description does not exist yet. |

## Summary

- PASS: 6 (AC-9, AC-13, AC-20, AC-21, AC-22, AC-25); the spec half of AC-26 also passes.
- UNVERIFIED pending CI: 19 (AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24). For each, the code, rows and local evidence required before CI are present and consistent with the criterion; only the CI-sourced results are absent.
- UNVERIFIED pending PR: AC-26 (spec half passes; the PR-description half is produced when the PR is authored and checked by P7-T9).
- FAIL: 0.

Pending-CI item PC-1 (non-blocking) covers the 19 CI-dependent criteria; no criterion is FAIL or PARTIAL. Remediation is triggered by COV-1 (policy-audit coverage FAIL), which also bears on AC-24. AC-26's PR half is an action at PR authoring, recorded as a non-blocking observation rather than a remediation item, because no branch change can satisfy it before the PR exists.

## Acceptance Criteria Check-off

- Newly checked off by this review in `spec.md`: AC-13 (verified by code inspection of `Get-EpicStateLoadedSourceClosure` and the Discovery helper header; its criterion text has no CI clause).
- Already checked and confirmed: AC-9, AC-20, AC-21, AC-22, AC-25.
- Left unchecked: AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24 (pending CI) and AC-26 (PR description). Per `acceptance-criteria-tracking` `### CI-Dependent Criteria`, the item's orchestrator checks these off at S9 after `ci_gate.conclusion` is `success`, then re-runs the CI gate on the new head.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
- Total AC items: 26
- Checked off (delivered): 6
- Remaining (unchecked): 20
- Items remaining: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-23, AC-24, AC-26

## Findings

### Blocking

- COV-1 (`autonomous`): PowerShell coverage FAIL in `policy-audit.2026-10-16T03-20.md` (artifact 66.04% against the 85% floor; scoped three-folder run with denominator 12280 against the CI 18116). Remedy: full-population PoshQC test run and coverage comparison recorded under `evidence/qa-gates/`.

### Pending CI (non-blocking)

- PC-1: CI-dependent criteria AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24 have no CI result because no PR exists. Owner: orchestrator, plan Phase 7 (P7-T2..P7-T10) at S9.

### Non-blocking

- O-1: AC-26 PR-description half. The PR body must list the operator follow-ups from spec `## Rollout & Follow-up` (F-3 enforcement using the AC-5b report after splitting `legacy-codex-hook-contracts.Tests.ps1`; shape-B limit for hook-local seams; F-6 mirror drift in `.claude/rules/powershell.md` line 31; I-3 residue of 13 files at 490-499 lines and `BlastRadiusConfig.Tests.ps1`) and the N-2/F-6 decisions.
- O-2: Phase 6 evidence was recorded at `4c9d38da0`/`5eb283c7e`; HEAD adds the merge `793866195`, whose incoming changes touch no PowerShell suite or coverage root. The final-head CI run (D-FINAL) covers the merged state.
- O-3: The CI baseline `B` (`adb9aa5f0`) now differs from the current merge-base (`97559c3e0`). The drift touches no path under `tests/scripts`, `.claude`, `.codex`, `scripts` or `config` that PowerShell tests or coverage use; P7 artifacts should record both SHAs.
- O-4: The local `artifacts/pester/powershell-coverage.xml` (66.04%, denominator 12280) comes from a scoped run and is not comparable with the CI figure (denominator 18116). AC-24 must use the CI artifact as the plan specifies.
- Code-review findings CR-N1..CR-N8 (see `code-review.2026-10-16T03-20.md`).

## Assumptions

- The stamp `2026-10-16T03-20` was read from the UTC host clock (`date -u`).
- PoshQC was not re-run by this review (the MCP PoshQC tools were not in this agent's tool set); local toolchain results come from the executor's evidence, and this review re-ran the static checks (line counts, scope, determinism grep, pure-move comparison, evidence-location validator).
- Coverage was assessed from existing artifacts; coverage generation was not rerun.
- CI status at HEAD is not available because no pull request exists yet.

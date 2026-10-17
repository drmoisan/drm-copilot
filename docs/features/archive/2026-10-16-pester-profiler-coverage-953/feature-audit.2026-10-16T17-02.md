# Feature Audit: pester-profiler-coverage (Issue #953) - Remediation Cycle 2 Re-Audit

- Timestamp: 2026-10-16T17-02
- Reviewer: feature-review agent (full feature-vs-base review)
- Companion artifacts: `policy-audit.2026-10-16T17-02.md`, `code-review.2026-10-16T17-02.md`

## Scope and Baseline

- Branch: `bug/pester-profiler-coverage-953`, HEAD `44fb400970655d1eb5838b1f4ae88568f9481e74`, PR #959 open against `main` (mergeable). CI run 38936152953 for HEAD completed during this review with `failure`: shard 1 failed on `session-root-reads-850.Constraints.Tests.ps1:80`, an existing suite the branch does not modify, and the `poshqc` job failed at its result-gate step. Run 38935591244 (`8acac63e7`, same PowerShell tree) failed identically; run 38929655043 (`1f208b4e5`) failed on TS04, which `8acac63e7` fixed.
- Base: `origin/main` @ `d72ec6a1010223f7036b9c3d15dad102ae262f98` (merge-base). Diff `git diff d72ec6a10..HEAD`: 32 files outside `docs/features/` (+2377/-335): runsettings (2), PoshQC modules (4 new including bundle copies, 4 modified including bundle copies), module manifests (2), README (2), CHANGELOG (1), workflow `_poshqc.yml` (1), JSON manifest (1), shell scripts (2), PowerShell tests (11), Python parity test (1).
- Work mode: `full-bug` (`issue.md`). AC source: `spec.md` `## Acceptance Criteria` (AC-01 to AC-16).
- Baseline behavior on `origin/main`: breakpoint-mode coverage; Pester minimum 5.6.1 at eight sites; no Pester ceiling; one Windows `poshqc` job running the full suite. CI baseline run 38846579572: `Test PowerShell` 15.5 minutes, job 18.6 minutes (`evidence/baseline/ci-baseline-timing.2026-10-16T06-40.md`).
- Round history: round 1 `*.2026-10-16T10-17.md`; remediation cycle 1 (CR-1 to CR-3); sharding phase P8 (`T = 1141` s, TRIGGERED); round 2 `*.2026-10-16T14-11.md` (PA-3 / CR-7 `autonomous`); remediation cycle 2 (`remediation-plan.2026-10-16T14-19.md`, CR-7 to CR-13 and CR-17; D17 keeps `if: always()`).

## Acceptance Criteria Inventory

| ID | Criterion (short form) | State before review |
|---|---|---|
| AC-01 | Both runsettings copies set `UseBreakpoints = $false`; other `CodeCoverage` keys unchanged | checked |
| AC-02 | Bundled parity pytest exits 0 | checked |
| AC-03 | `PoshQC.RunSettings.Tests.ps1` asserts profiler config and installer 5.9.0; fail-before/pass-after; no temp files | checked |
| AC-04 | `5.6.1` replaced by `5.9.0` at the eight research sites | checked |
| AC-05 | Committed-manifest tests carry no `5.6.1` expectation and pass | checked |
| AC-06 | CHANGELOG `[Unreleased]` names profiler coverage and Pester 5.9.0 | checked |
| AC-07 | PoshQC Format/Analyze/Test pass in a single pass; evidence under `qa-gates/` | checked |
| AC-08 | PR-head CI LINE total equals baseline; no baseline sourcefile absent; repo-wide >= 85% | unchecked (CI-dependent) |
| AC-09 | Per-file covered-LINE diff table between baseline and PR-head artifacts | unchecked (CI-dependent) |
| AC-10 | Raw `gh run view --json jobs` and seconds for baseline and PR-head runs | unchecked (CI-dependent) |
| AC-11 | Sharding trigger `T` and decision recorded; sharding implemented as specified when `T > 480` | unchecked (CI-dependent) |
| AC-12 | #936 line `ci`/`mi` values from the PR-head artifact recorded; no #936 test file modified | unchecked (CI-dependent) |
| AC-13 | No change to `ci.yml`; no `on:` block differs | checked |
| AC-14 | No path under `.claude/rules/` or `.github/instructions/` | checked |
| AC-15 | No changed or added production/test/script file exceeds 500 lines | checked |
| AC-16 | Pester ceiling below 6.0 at all D8 sites; RS05-RS07 fail-before/pass-after | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-01 | PASS | Both runsettings copies byte-identical (reviewer `cmp`); unchanged in cycle 2; RS01, RS02, RS04 PASS in the cycle 2 final full run (`r2-final-poshqc-test-coverage.2026-10-16T16-50.md`). |
| AC-02 | PASS | Reviewer run at HEAD: parity pytest 1 passed; all seven repo/bundle pairs identical (reviewer `cmp`). |
| AC-03 | PASS | File unchanged in cycle 2 (233 lines, RS01-RS10); fail-before/pass-after evidence from round 1 and cycle 1; RS tokens PASS in the cycle 2 final full run. |
| AC-04 | PASS | Reviewer `grep -c "5\.6\.1"`: 0 at all eight paths. |
| AC-05 | PASS | 0 matches in `host-tools.manifest.Tests.ps1`; the one match in `HostBootstrap.Invoke.Tests.ps1` is a synthetic in-test manifest. Both files pass in the cycle 2 final full run (10784 tests, 0 failures). |
| AC-06 | PASS | CHANGELOG `[Unreleased]` names the profiler-based tracer and Pester 5.9.0; cycle 2 added the sharding entry without changing the AC-06 text (reviewer diff; `r2-final-docs.2026-10-16T16-52.md`). |
| AC-07 | PASS | Cycle 2 single pass (loop pass 2): `r2-final-poshqc-format.2026-10-16T16-34.md` (no change), `r2-final-poshqc-analyze.2026-10-16T16-36.md` (no findings), `r2-final-poshqc-test-coverage.2026-10-16T16-50.md` (10784 tests, 0 failed), `r2-final-loop-closure.2026-10-16T16-53.md` (`LOOP_CLEAN_PASS: YES`). AC-07 is defined on the local self-hosted toolchain and is met; the sharded CI run fails separately (policy audit PA-3), which is evaluated under AC-11 and PA-1. |
| AC-08 | PENDING-CI | Local cycle 2 final: 17123/18594 = 92.09% (>= 85%), 208 sourcefiles, key set equal to the cycle baseline, no per-file total change outside the three changed PoshQC modules (`r2-final-coverage-delta.2026-10-16T16-51.md`). The CI-dependent evaluation requires the merged artifact of the final head's run (38936152953 in progress) and a baseline reselected at merge base `d72ec6a10` (PA-N1). Left unchecked (S9, P8-T19). |
| AC-09 | PENDING-CI | Requires the final head's merged artifact. Left unchecked (S9, P8-T19). |
| AC-10 | PENDING-CI | Baseline half present (`evidence/baseline/ci-baseline-run-jobs.2026-10-16T06-40.md`, `ci-baseline-timing.2026-10-16T06-40.md`). The PR-head half must come from the final head's run; per-shard `Test PowerShell` steps replace the single step (PA-N5). Latest sample (run 38929655043, head `1f208b4e5`): 374 s, 283 s, 396 s. Left unchecked (S9, P8-T19). |
| AC-11 | PENDING-CI | `T = 1141`, `TRIGGERED` recorded (`sharding-trigger.2026-10-16T10-54.md`). Sharding implemented per spec and refined in cycle 2 (size-balanced slices, single shard-count source, empty-slice guard, CLASS/METHOD omission); check name unchanged; no coverage threshold added (`r2-final-d3-ceiling.2026-10-16T16-52.md`); the result-gate step is now tested (WF01 to WF03). A passing completeness guard on the final head's run is still required. None of runs 38929655043, 38935591244, or 38936152953 reached the completeness step, because the gate step stopped the `poshqc` job after shard 1 failed; the HEAD failure is the order-dependent suite of PA-3 / CR-21, which must be fixed first. Left unchecked (S9, P8-T20). |
| AC-12 | PENDING-CI | Previous preliminary values from run 38909263798: `.codex/hooks` modes line 41 `ci=1 mi=0`; epic-scope lines 206 and 207 `ci=1 mi=0`. No #936-owned test file in the diff (reviewer diff listing). The final values come from the final head's artifact. Left unchecked (S9, P8-T19). |
| AC-13 | PASS | Reviewer: `git diff --name-only d72ec6a10..HEAD -- .github/workflows/ci.yml` zero paths; the `_poshqc.yml` diff touches no `on:` line; `r2-final-scope-ac13.2026-10-16T16-52.md`. |
| AC-14 | PASS | Reviewer: `git diff --name-only d72ec6a10..HEAD -- .claude/rules .github/instructions` zero paths. |
| AC-15 | PASS | Reviewer `wc -l`: largest changed non-Markdown file `PoshQC.Testing.psm1` at 479 lines; `.github/codex/codex-web-setup.sh` 331; all others lower. |
| AC-16 | PASS | Ceiling sites unchanged in cycle 2; `_poshqc.yml` Linux job and the merge job import with `-MinimumVersion 5.9.0 -MaximumVersion 5.99.99`; RS05-RS07 PASS in the cycle 2 final full run. |

## Summary

- AC verdicts: 11 PASS (AC-01 to AC-07, AC-13 to AC-16), 5 PENDING-CI (AC-08 to AC-12), 0 FAIL, 0 PARTIAL.
- Relative to `origin/main`, the branch delivers profiler-mode coverage, the Pester 5.9.0 minimum with a ceiling below 6.0, and a sharded Windows PowerShell QC job whose merge job fails the required check when any upstream job fails. Cycle 2 resolved the previous `autonomous` finding (CR-7) and the related findings CR-8 to CR-13 and CR-17.
- Speedup evidence (single sample, run 38929655043): the slowest shard's `Test PowerShell` step took 396 s, against 603 s with round-robin shards, 1141 s unsharded on the PR head, and 930 s at the breakpoint-mode baseline. The measured gain is attributable to sharding (policy audit PA-N6, PA-N7).
- Blocking findings: 3. PA-3 / CR-21 (`autonomous`, HEAD CI shard 1 fails on the order-dependent existing suite `session-root-reads-850.Constraints.Tests.ps1` after the cycle 2 shard reshuffle), PA-1 (`awaiting_ci`, modified workflow without a green run on the final head), PA-2 (`awaiting_ci`, AC-08 to AC-12 and plan tasks P8-T19/P8-T20 pending).
- Non-blocking: PA-N1 to PA-N7; CR-15, CR-16, CR-18, CR-19, CR-20 (Info).
- Overall review verdict: **REMEDIATION_REQUIRED**.

## Acceptance Criteria Check-off

- AC-01 to AC-07 and AC-13 to AC-16 were already checked in `spec.md`; each is evaluated PASS above, so `spec.md` was not changed.
- AC-08 to AC-12 remain unchecked. They are CI-dependent and owned by the item's orchestrator run at S9 (plan P8-T19 and P8-T20).
- No AC text was modified and no criterion was added.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md`
- Total AC items: 16
- Checked off (delivered): 11
- Remaining (unchecked): 5
- Items remaining: AC-08 (CI-dependent) PR-head LINE total versus baseline, no baseline sourcefile absent, repo-wide >= 85%; AC-09 (CI-dependent) per-file covered-LINE diff table; AC-10 (CI-dependent) baseline and PR-head timing JSON and seconds; AC-11 (CI-dependent) sharding trigger, decision, and sharding closure with a passing completeness guard; AC-12 (CI-dependent) #936 line values from the PR-head artifact.

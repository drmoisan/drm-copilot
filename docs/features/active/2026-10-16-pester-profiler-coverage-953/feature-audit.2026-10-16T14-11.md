# Feature Audit: pester-profiler-coverage (Issue #953) - Remediation Cycle 1 Re-Audit and Sharding Phase Review

- Timestamp: 2026-10-16T14-11
- Reviewer: feature-review agent (full feature-vs-base review)
- Companion artifacts: `policy-audit.2026-10-16T14-11.md`, `code-review.2026-10-16T14-11.md`

## Scope and Baseline

- Branch: `bug/pester-profiler-coverage-953`, HEAD `c1dab385e30b20bda8de77e11f848c3b48ec1e58`, PR #959 open against `main`. CI run 38912409726 for HEAD is queued; the latest completed CI run on the sharded workflow is 38909263798 (head `9f822f1cb`, success).
- Base: `origin/main` @ `5d2d9a9728b3763cb4398bdae1e54ef84ee98936` (merge-base). Diff `git diff 5d2d9a972..HEAD`: 32 files outside `docs/features/` (+1967/-335): runsettings (2), PoshQC modules (4 new including bundle copies, 4 modified including bundle copies), module manifests (2), README (2), CHANGELOG (1), workflow `_poshqc.yml` (1), JSON manifest (1), shell scripts (2), PowerShell tests (11), Python parity test (1).
- Work mode: `full-bug` (`issue.md`). AC source: `spec.md` `## Acceptance Criteria` (AC-01 to AC-16).
- Baseline behavior on `origin/main`: breakpoint-mode coverage; Pester minimum 5.6.1 at eight sites; no Pester ceiling; one Windows `poshqc` job running the full suite. CI baseline run 38846579572: `Test PowerShell` 15.5 minutes, job 18.6 minutes (`evidence/baseline/ci-baseline-timing.2026-10-16T06-40.md`).
- Baseline coverage: CI run 38885440106 (main at the earlier merge base), LINE total 18170, 90.45%.
- Round history: round-1 review `*.2026-10-16T10-17.md` (AWAITING_CI); remediation cycle 1 (`remediation-inputs.2026-10-16T10-24.md`, CR-1 to CR-3); sharding phase P8 executed after `T = 1141` s (`evidence/qa-gates/sharding-trigger.2026-10-16T10-54.md`).

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
| AC-01 | PASS | Both runsettings copies byte-identical (reviewer `cmp`); diff adds `UseBreakpoints = $false` inside `CodeCoverage` only; RS01/RS02/RS04 pass in the final full run (`final-poshqc-test-coverage.2026-10-16T13-57.md`, 18 token checks PASS). |
| AC-02 | PASS | Reviewer run at HEAD: parity pytest 1 passed; `POSHQC_PARITY_PATHS` includes `PoshQC.Shard.psm1` and `PoshQC.CoverageMerge.psm1`. |
| AC-03 | PASS | File exists (233 lines, RS01-RS10); RS02 and RS03 present; fail-before/pass-after evidence under `evidence/regression-testing/` for RS01-RS07 (round 1) and RS08-RS10 (cycle 1); no temp-file construct (reviewer search). |
| AC-04 | PASS | Reviewer `grep -c "5\.6\.1"`: 0 at all eight paths. |
| AC-05 | PASS | 0 matches in `host-tools.manifest.Tests.ps1`; the one match in `HostBootstrap.Invoke.Tests.ps1:202` is a synthetic in-test manifest, not the committed manifest. Both files pass in the final full run (AC07-DRYRUN-COMMITTED-MANIFEST token PASS). |
| AC-06 | PASS | CHANGELOG `[Unreleased]` names the profiler-based tracer and Pester 5.9.0 (reviewer diff). |
| AC-07 | PASS | Sharding-path single pass: `final-poshqc-format.2026-10-16T13-34.md` (no change), `final-poshqc-analyze.2026-10-16T13-36.md` (no findings), `final-poshqc-test-coverage.2026-10-16T13-57.md` (10516 tests, 0 failed), `final-loop-closure.2026-10-16T13-57.md` (`LOOP_CLEAN_PASS: YES`). |
| AC-08 | PENDING-CI | Preliminary from CI run 38909263798 (head `9f822f1cb`, not the final head): merged LINE 16830/18302 = 91.96% (>= 85%); 206 sourcefiles, every one of the 204 sourcefiles of the unsharded PR-head run 38887178530 is present. Literal total equality with the baseline does not hold on the sharding path: the branch adds `PoshQC.Shard.psm1` (+49), `PoshQC.CoverageMerge.psm1` (+70), and 7 lines to `PoshQC.Testing.psm1`; plan P8-T19 evaluates `TOTAL_EQUAL` over every key except the four PoshQC keys. Reviewer comparison also found +3 lines in each `enforce-orchestration-preimplementation-gate-targets.ps1` copy from `main` commit `d9ce4757e`; the baseline must be reselected at the current merge base `5d2d9a972` (policy audit PA-N1). Left unchecked (S9). |
| AC-09 | PENDING-CI | Preliminary per-file comparison (unsharded run 38887178530 vs sharded run 38909263798): covered counts differ only for the four PoshQC keys and the two gate-targets hooks; all other 200 sourcefiles are identical. The AC-09 table must be produced from the final head's artifact against the reselected baseline (P8-T19). Left unchecked (S9). |
| AC-10 | PENDING-CI | Baseline half present (`evidence/baseline/ci-baseline-run-jobs.2026-10-16T06-40.md`, `ci-baseline-timing.2026-10-16T06-40.md`). Pre-sharding PR-head half present (`ci-prhead-*.2026-10-16T10-54.md`). Sharded run 38909263798: shard `Test PowerShell` steps 214 s, 340 s, 603 s; merge job 94 s. P8-T19 re-records per-shard step timings for the final head; the evidence should state that the `poshqc / PowerShell QC` job no longer has a `Test PowerShell` step (PA-N5). Left unchecked (S9). |
| AC-11 | PENDING-CI | `T = 1141`, `TRIGGERED` recorded (`sharding-trigger.2026-10-16T10-54.md`). Sharding implemented per spec: static job, `fail-fast: false` three-shard matrix with unique `if: always()` uploads, retained `poshqc` / `PowerShell QC` merge job with completeness guard, LINE-granularity merge, Koverage copy, `poshqc-test-results` upload; new logic in two new modules mirrored and added to the parity list and load list. CI run 38909263798: completeness guard passed (`3 shards, 382 test files ... = discovery 10601`); no coverage threshold added (`sharding-no-threshold.2026-10-16T13-59.md`); check name unchanged (`sharding-check-name.2026-10-16T13-59.md`). Closure task P8-T20 is open and the final head's CI run is queued. Code review CR-7 (untested result-check step) is a test gap, not a deviation from the specified design. Left unchecked (S9). |
| AC-12 | PENDING-CI | Preliminary from run 38909263798: `.codex/hooks` modes line 41 `ci=1 mi=0`; epic-scope lines 206 and 207 `ci=1 mi=0` each. No #936-owned test file in the diff (reviewer diff listing). Left unchecked (S9). |
| AC-13 | PASS | Reviewer: `git diff --name-only 5d2d9a972..HEAD -- .github/workflows/ci.yml` zero paths; the `_poshqc.yml` diff touches no `on:` line; `final-scope-ac13.2026-10-16T13-57.md`. |
| AC-14 | PASS | Reviewer: `git diff --name-only 5d2d9a972..HEAD -- .claude/rules .github/instructions` zero paths. |
| AC-15 | PASS | Reviewer `wc -l`: largest changed non-Markdown file `PoshQC.Testing.psm1` at 484 lines; all others lower. |
| AC-16 | PASS | Ceiling present at all D8 sites (reviewer diff); `_poshqc.yml` Linux job and the merge job import with `-MinimumVersion 5.9.0 -MaximumVersion 5.99.99`; the `EnsureModule` seam passes both bounds (CR-2); RS05-RS07 fail-before/pass-after evidence from round 1, RS05-RS07 PASS in the final full run. |

## Summary

- AC verdicts: 11 PASS (AC-01 to AC-07, AC-13 to AC-16), 5 PENDING-CI (AC-08 to AC-12), 0 FAIL, 0 PARTIAL.
- Relative to `origin/main`, the branch delivers profiler-mode coverage, the Pester 5.9.0 minimum with a ceiling below 6.0, and a sharded Windows PowerShell QC job whose merged coverage reproduces the unsharded coverage profile. Remediation cycle 1 findings CR-1 to CR-3 are resolved.
- Speedup evidence (preliminary, run 38909263798): the slowest shard's `Test PowerShell` step took 603 s against 1141 s unsharded on the PR head and 930 s (15.5 minutes) at baseline; the `poshqc` check's critical path is about 12 minutes (shard 3 job 641 s plus merge job 94 s). Shard balance is uneven (code review CR-10). The unsharded profiler-mode step (1141 s, 10488 tests) was slower than the breakpoint-mode baseline (930 s, 10407 tests) in the single samples available, so the measured gain is attributable to sharding rather than to profiler mode (policy audit PA-N6).
- Blocking findings: 3. PA-1 (`awaiting_ci`, modified workflow without a green run on the final head), PA-2 (`awaiting_ci`, AC-08 to AC-12 and plan tasks P8-T19/P8-T20 pending), PA-3 / CR-7 (`autonomous`, the required-check result step of the `poshqc` merge job has no test).
- Non-blocking: PA-N1 to PA-N6; CR-8 to CR-13 (Minor) and CR-14 to CR-17 (Info). CR-8, CR-9, CR-11, CR-12, and CR-13 are in files this item changes and are suitable for inclusion in the same remediation cycle.
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
- Items remaining: AC-08 (CI-dependent) PR-head LINE total versus baseline, no baseline sourcefile absent, repo-wide >= 85%; AC-09 (CI-dependent) per-file covered-LINE diff table; AC-10 (CI-dependent) baseline and PR-head timing JSON and seconds; AC-11 (CI-dependent) sharding trigger, decision, and sharding closure; AC-12 (CI-dependent) #936 line values from the PR-head artifact.

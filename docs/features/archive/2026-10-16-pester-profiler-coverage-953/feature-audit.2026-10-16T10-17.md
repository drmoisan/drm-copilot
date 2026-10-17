# Feature Audit: pester-profiler-coverage (Issue #953)

- Timestamp: 2026-10-16T10-17
- Reviewer: feature-review agent (full feature-vs-base review, pre-PR)
- Companion artifacts: `policy-audit.2026-10-16T10-17.md`, `code-review.2026-10-16T10-17.md`

## Scope and Baseline

- Branch: `bug/pester-profiler-coverage-953`, HEAD `0087d2bc2514721a0a89b1032010e95afb6c21ec` (pushed; no PR yet; CI has not run on this head).
- Base: `origin/main` @ `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea` (merge-base). Diff: `git diff 5bdf22d0f...HEAD`, 84 files (+3813/-319): 2 runsettings data files, 4 PoshQC module files (2 sources, 2 byte-identical bundle copies), 2 README copies, 1 CHANGELOG, 1 workflow (`_poshqc.yml`, one job-body line), 1 JSON manifest, 2 shell scripts, 7 PowerShell test files (3 new), and the feature folder plus lifecycle record.
- Work mode: `full-bug` (`issue.md`). AC source: `spec.md` `## Acceptance Criteria` (AC-01 to AC-16). `user-story.md` is absent by design.
- Baseline behavior on `origin/main`: shipped runsettings had no `UseBreakpoints` key, so Pester used breakpoint coverage; the declared Pester minimum was 5.6.1 at eight sites while CI ran 5.9.0; no Pester major-version ceiling existed; CI baseline run 38846579572 took 15.5 minutes in `Test PowerShell` (spec "Timing Requirements").
- Baseline coverage: CI run 38846579572 LINE 16417/18154 = 90.43%, 203 sourcefiles; local breakpoint-mode baseline 16387/18116 = 90.46%.

## Acceptance Criteria Inventory

| ID | Criterion (short form) | State before review |
|---|---|---|
| AC-01 | Both runsettings copies set `UseBreakpoints = $false`; other `CodeCoverage` keys unchanged | checked |
| AC-02 | Bundled parity pytest exits 0 | checked |
| AC-03 | `PoshQC.RunSettings.Tests.ps1` asserts profiler config and installer 5.9.0; fail-before/pass-after evidence; no temp files | checked |
| AC-04 | `5.6.1` replaced by `5.9.0` at the eight research §2.3 sites | checked |
| AC-05 | Committed-manifest tests carry no `5.6.1` expectation and pass | checked |
| AC-06 | CHANGELOG `[Unreleased]` names profiler coverage and Pester 5.9.0 | checked |
| AC-07 | PoshQC Format/Analyze/Test pass in a single pass; evidence under `qa-gates/` | checked |
| AC-08 | PR-head CI LINE total equals baseline; no baseline sourcefile absent; repo-wide >= 85% | unchecked (CI-dependent) |
| AC-09 | Per-file covered-LINE diff table between baseline and PR-head artifacts | unchecked (CI-dependent) |
| AC-10 | Raw `gh run view --json jobs` and seconds for baseline and PR-head runs | unchecked (CI-dependent) |
| AC-11 | Sharding trigger `T` and decision recorded; sharding implemented only if `T > 480` | unchecked (CI-dependent) |
| AC-12 | #936 line `ci`/`mi` values from the PR-head artifact recorded; no #936 test file modified | unchecked (CI-dependent) |
| AC-13 | No change to `ci.yml`; no `on:` block differs | checked |
| AC-14 | No path under `.claude/rules/` or `.github/instructions/` | checked |
| AC-15 | No changed or added production/test/script file exceeds 500 lines | checked |
| AC-16 | Pester ceiling below 6.0 at all D8 sites; RS05-RS07 fail-before/pass-after | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-01 | PASS | Reviewer diff: one `UseBreakpoints = $false` line added inside `CodeCoverage` in both copies (byte-identical, `cmp`). `evidence/other/runsettings-load-check.2026-10-16T08-17.md` shows `Import-PowerShellDataFile` returns `UseBreakpoints=False` with `Enabled`, `OutputFormat`, `OutputPath`, `CoveragePercentTarget` unchanged; RS01 asserts the same at HEAD. |
| AC-02 | PASS | Reviewer run at HEAD: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` 1 passed, exit 0. |
| AC-03 | PASS | File exists (163 lines). RS02 asserts `CodeCoverage.UseBreakpoints.Value -eq $false` on `New-PesterConfiguration -Hashtable`; RS03 asserts the injected `InstallModule` received `5.9.0` for Pester. Fail-before 7/7 failed (`runsettings-regression-fail-before.2026-10-16T08-15.md`), pass-after 7/7 passed (`runsettings-regression-pass-after.2026-10-16T08-20.md`). No temp-file construct in the file (reviewer read). |
| AC-04 | PASS | Reviewer diff shows each of the eight sites changed from `5.6.1` to `5.9.0`; `evidence/qa-gates/final-pin-sweep.2026-10-16T10-00.md` records zero `5.6.1` matches at the eight paths. |
| AC-05 | PASS | Reviewer diff: `host-tools.manifest.Tests.ps1` (3 lines) and `HostBootstrap.Invoke.Tests.ps1` (1 line) now expect `5.9.0`. Both pass (`evidence/qa-gates/host-tools-tests-after.2026-10-16T08-23.md`; full run 0 failures). |
| AC-06 | PASS | Reviewer diff of `extensions/drm-copilot/CHANGELOG.md`: `[Unreleased]` bullet names "profiler-based tracer" and "Pester 5.9.0". |
| AC-07 | PASS | `final-poshqc-format.2026-10-16T09-37.md` (no diff), `final-poshqc-analyze.2026-10-16T09-38.md` (zero findings), `final-poshqc-test-coverage.2026-10-16T09-55.md` (10388 tests, 0 failed), all after the D9 split. The later merge of `origin/main` touched none of this branch's changed paths. |
| AC-08 | PENDING-CI | Needs the PR-head CI artifact. Local profiler-mode figures: 16647/18116 = 91.89%, total equal to the local baseline, 203 sourcefiles, none dropped. Risk recorded as PA-N1: `origin/main` changed 13 production PowerShell files (including one new file) between the baseline run head `072df404` and the merge base, so literal equality with run 38846579572 (18154) is unlikely for reasons unrelated to this branch. Left unchecked. |
| AC-09 | PENDING-CI | Local delta shows two changed files (`PoshQC.psm1` 40/20 to 53/7; `PoshQC.Testing.psm1` 200/0 to 187/13). The CI-artifact table is not yet produced. Left unchecked. |
| AC-10 | PENDING-CI | Baseline half present (`evidence/baseline/ci-baseline-run-jobs.2026-10-16T06-40.md`, `ci-baseline-timing.2026-10-16T06-40.md`); PR-head half needs a CI run. Left unchecked. |
| AC-11 | PENDING-CI | `T` is computed from the PR-head run. No sharding-only file is changed on the branch (reviewer diff: `PoshQcWorkflow.Tests.ps1`, `PoshQC.psd1`, `test_poshqc_bundled_parity.py` absent from the diff). Local full-run wall time was 942 s, which includes discovery and is not the CI step time. Left unchecked. |
| AC-12 | PENDING-CI | Baseline values recorded (`ci=0 mi=1` for all three lines, `ci-baseline-coverage-figures.2026-10-16T06-40.md`); PR-head values need the CI artifact. No #936-owned test file is in the diff (`final-scope-ac14.2026-10-16T10-00.md`). Left unchecked. |
| AC-13 | PASS | Reviewer: `git diff --name-only 5bdf22d0f...HEAD -- .github/workflows/ci.yml` returned zero paths; the only workflow change is `_poshqc.yml` line 73 inside a job body. `final-scope-ac13.2026-10-16T10-00.md` compares every `on:` block. |
| AC-14 | PASS | Reviewer: `git diff --name-only 5bdf22d0f...HEAD -- .claude/rules .github/instructions` returned zero paths. |
| AC-15 | PASS | Reviewer `wc -l`: largest changed non-Markdown file is `PoshQC.Testing.psm1` at 461 lines; `final-file-size-ac15.2026-10-16T10-00.md`. |
| AC-16 | PASS | Reviewer diff: `UpperBound = '6.0.0'` and the `-lt` filter in both `PoshQC.psm1` copies and both shell present-checks; `-MaximumVersion` passed as `'5.99.99'` from `Invoke-PoshQCTest` in both `PoshQC.Testing.psm1` copies; `_poshqc.yml:73` imports with `-MinimumVersion 5.9.0 -MaximumVersion 5.99.99`; both READMEs state "below 6.0" and the CHANGELOG states "bounded below Pester 6.0". RS05, RS06, RS07 failed before and passed after (`evidence/regression-testing/`). No temp files. |

## Summary

- AC verdicts: 11 PASS (AC-01 to AC-07, AC-13 to AC-16), 5 PENDING-CI (AC-08 to AC-12), 0 FAIL, 0 PARTIAL.
- Relative to the `origin/main` baseline, the branch delivers profiler-mode coverage through shipped data, a reconciled Pester 5.9.0 minimum, and a Pester ceiling below 6.0, with regression tests that fail on the pre-fix tree. Locally the coverage denominator is unchanged and repo-wide PowerShell line coverage rose to 91.89%.
- The speedup itself (G1) is not yet measured; it is established by AC-10 and AC-11 from the PR-head CI run.
- Blocking findings: 3, all `awaiting_ci` (policy audit PA-1 modified workflow without a green run, PA-2 CI-dependent AC-08 to AC-12, PA-3 bash coverage artifact absent). Non-blocking: PA-N1 to PA-N4 and code review CR-1 to CR-6.
- Overall review verdict: **AWAITING_CI**.

## Acceptance Criteria Check-off

- AC-01 to AC-07 and AC-13 to AC-16 were already checked in `spec.md`; each is evaluated PASS above, so no change to `spec.md` was required.
- AC-08 to AC-12 remain unchecked (CI-dependent; owned by the item's orchestrator run at S9).
- No AC text was modified and no criterion was added.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-16-pester-profiler-coverage-953/spec.md`
- Total AC items: 16
- Checked off (delivered): 11
- Remaining (unchecked): 5
- Items remaining: AC-08 (CI-dependent) PR-head LINE total equals baseline, no baseline sourcefile absent, repo-wide >= 85%; AC-09 (CI-dependent) per-file covered-LINE diff table; AC-10 (CI-dependent) baseline and PR-head timing JSON and seconds; AC-11 (CI-dependent) sharding trigger `T` and decision; AC-12 (CI-dependent) #936 line values from the PR-head artifact.

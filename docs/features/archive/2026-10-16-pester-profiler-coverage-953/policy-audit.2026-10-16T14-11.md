# Policy Audit: pester-profiler-coverage (Issue #953) - Remediation Cycle 1 Re-Audit and Sharding Phase Review

- Timestamp: 2026-10-16T14-11
- Reviewer: feature-review agent (full feature-vs-base review; re-audit of remediation cycle 1 findings CR-1 to CR-3 combined with the review of the conditional sharding phase, FR-09)
- Branch: `bug/pester-profiler-coverage-953`, HEAD `c1dab385e30b20bda8de77e11f848c3b48ec1e58` (pushed; PR #959 open against `main`)
- Base: `origin/main` @ `5d2d9a9728b3763cb4398bdae1e54ef84ee98936` (merge-base `5d2d9a9728b3763cb4398bdae1e54ef84ee98936`)
- Diff command: `git diff 5d2d9a9728b3763cb4398bdae1e54ef84ee98936..HEAD`. Outside `docs/features/`: 32 files (+1967/-335).
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-10-16 14:01:28 UTC for head `c1dab385e` and merge base `5d2d9a972`; both match the branch state, so no refresh was needed.
- CI status at HEAD: CI run 38912409726 for head `c1dab385e` is queued (reviewer `gh run list`, 14:11 UTC). The most recent completed CI run on the sharded workflow is 38909263798 (head `9f822f1cb`, conclusion `success`).
- Work mode: `full-bug` (`issue.md`). AC source: `spec.md` only; `user-story.md` is absent by design.
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/tonality.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/shell.md`, `.claude/rules/python.md`.
- Coverage thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults govern (line >= 85%; branch >= 75% for branch-capable languages; PowerShell and bash have no branch threshold).
- Tiers: `quality-tiers.yml` exists at the repository root; `scripts/powershell/PoshQC` is T3 (plan P0-T10). No property-test or mutation obligation applies.

## Executive Summary

Since the round-1 review (2026-10-16T10-17) the branch has (a) fixed CR-1 to CR-3 in remediation cycle 1 and (b) executed the conditional sharding phase after the PR-head `Test PowerShell` step measured `T = 1141` seconds (> 480, `TRIGGERED`). The sharding phase splits `_poshqc.yml` into a static job, a three-shard matrix job, and a retained `poshqc` / `PowerShell QC` merge job; it adds two new PoshQC sub-modules (`PoshQC.Shard.psm1`, `PoshQC.CoverageMerge.psm1`) with byte-identical bundle copies, shard parameters on `Invoke-PoshQCTest`, and four new or updated test files.

Remediation cycle 1 is verified: CR-1 (range-aware presence check), CR-2 (`-MinimumVersion 5.9.0` on the seam import), and CR-3 (single version predicate) are implemented in both module copies, and RS08 to RS10 failed on the pre-fix tree and pass after.

The sharded workflow ran green in CI run 38909263798: the completeness guard reported `3 shards, 382 test files, shard tests 3203 + 4092 + 3306 = discovery 10601`, and the merged coverage reported 16830 of 18302 lines (91.96%). The reviewer compared the merged artifact with the unsharded PR-head artifact of run 38887178530 per `sourcefile`: covered and total counts are identical for every file except the four the branch changed or added and two hook files changed on `main` between the two runs, which shows that the merge reproduces the unsharded coverage profile.

Overall verdict: **REMEDIATION_REQUIRED**. Blocking findings: 3.

- PA-1 (`awaiting_ci`): `.github/workflows/_poshqc.yml` is modified; no green run exists for head `c1dab385e` (run 38912409726 queued), and the green run 38909263798 on `9f822f1cb` does not qualify as a predecessor because the later merge of `origin/main` changes paths outside the feature folder.
- PA-2 (`awaiting_ci`): AC-08 to AC-12 remain unchecked; plan tasks P8-T19 and P8-T20 (sharded-run evidence and closure) are open and depend on CI for the final head.
- PA-3 (`autonomous`, code review CR-7): no test guards the `poshqc` merge job's step that fails the required check when the static or shard jobs fail. With `if: always()` on the job, removing or weakening that step would let a failing shard produce a green `poshqc / PowerShell QC` check.

The round-1 bash finding (former PA-3, bash coverage artifact absent) is resolved: the CI `shell-coverage` artifact of run 38909263798 reports 95.2% line coverage.

## Rejected Scope Narrowing

No scope narrowing was detected. The caller prompt describes the review as "the re-audit for remediation cycle 1 (CR-1..CR-3) combined with the review of the conditional sharding phase" and supplies the base branch, merge base, head, feature folder, PR-context paths, AC source, plan and evidence paths, and CI run identifiers. None of these statements removes a file, language, or check from the audit. The audit covers every changed file in `git diff 5d2d9a972..HEAD`, including the workflow, both module copies, the two shell scripts, the JSON manifest, the Python parity test, and all PowerShell test files.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- Branch-diff scan: `git diff --name-only 5d2d9a972..HEAD -- artifacts` returned zero paths. No file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence is under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | New shard and merge tests build their inputs per `It` (`PoshQC.Shard.Tests.ps1`, `PoshQC.CoverageMerge.Tests.ps1`); `PoshQC.TestingShard.Tests.ps1` creates a fresh capture table and seam splat per `It`. |
| Isolation | PASS | Each `It` targets one function behavior (slice selection, manifest shape, completeness guard rule, count guard, merge rule, counter recomputation, one `Invoke-PoshQCTest` shard path). |
| Fast execution | PASS | Targeted runs: `sharding-unit-shard.2026-10-16T13-25.md` (10 tests), `sharding-unit-merge.2026-10-16T13-27.md` (8 tests), `sharding-unit-testing.2026-10-16T13-29.md` (4 tests), `sharding-workflow-tests.2026-10-16T13-33.md` (10 tests). |
| Determinism | PASS | Merge tests use in-memory XML strings; every `Invoke-PoshQCTest` seam is injected in `PoshQC.TestingShard.Tests.ps1`; no clock, RNG, or network use. |
| Readability | PASS | Token-prefixed titles (`TS01`..`TS03`, `RS08`..`RS10`), Arrange/Act/Assert comments, `-Because` messages. |

### 1.2 Coverage requirements

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- Python baseline coverage artifact: none exists for this branch; the only changed Python file is the test module `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`; no production Python file changed.
- C# baseline and post-change coverage artifact: N/A - no C# file changed on the branch.
- PowerShell baseline coverage artifact: CI run 38885440106 `poshqc-test-results` (main at the earlier merge base, breakpoint mode), LINE 18170 total, 90.45% (`evidence/qa-gates/ci-coverage-comparison.2026-10-16T10-54.md`); round-1 local baseline 16387/18116 = 90.46%.
- PowerShell post-change coverage artifact: merged `poshqc-test-results` of CI run 38909263798 (sharded workflow, head `9f822f1cb`), reviewer download and parse: report-level `LINE missed="1472" covered="16830"` (91.96%), 206 `sourcefile` elements. Local unsharded sharding-path run: 16827/18296 = 91.97%, 206 sourcefiles (`evidence/qa-gates/final-poshqc-test-coverage.2026-10-16T13-57.md`).
- Bash coverage artifact: CI run 38909263798 `shell-coverage` (kcov `cov.xml`), reviewer download and parse: `line-rate="0.952"`, 3256 of 3421 lines.
- Per-language comparison summary: PowerShell repo-wide line coverage is 91.96% on the merged CI artifact against a 90.45% baseline; every new or modified PoshQC module is at or above 88.33%. Bash repo-wide line coverage is 95.2%. Python has no production change. Every language with changed files is at or above the governing thresholds.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 4 production modules (2 new: `PoshQC.Shard.psm1`, `PoshQC.CoverageMerge.psm1`; 2 modified: `PoshQC.psm1`, `PoshQC.Testing.psm1`) plus byte-identical bundle copies, 2 manifests (`PoshQC.psd1`), 2 runsettings data files, 12 test files | full repository Pester suite | local 10516 passed, 0 failed (`final-poshqc-test-coverage.2026-10-16T13-57.md`); CI run 38909263798 shards 3203 + 4092 + 3306 = 10601, 0 failures | 90.45% line (CI run 38885440106, 18170 lines) | 91.96% line (CI run 38909263798 merged, 16830/18302) | every changed executable line covered except `PoshQC.Testing.psm1:174` (default `WriteShardFileList` seam body, `ci=0`); `PoshQC.Shard.psm1` 100% (49/49), `PoshQC.CoverageMerge.psm1` 100% (70/70), `PoshQC.Testing.psm1` 93.24% (193/207), `PoshQC.psm1` 88.33% (53/60) |
| Bash | 2 (`.devcontainer/post-create.sh`, `.github/codex/codex-web-setup.sh`) | 7 `codex_web_setup` bats files | 75 ok, 0 not ok (`final-shell-bats.2026-10-16T13-57.md`) | N/A - no baseline kcov artifact was retrieved; the changed lines are pwsh heredoc text outside the kcov roots | 95.2% line (CI run 38909263798 `shell-coverage`, 3256/3421) | N/A - the four changed lines are pwsh heredoc content in files outside the kcov include roots (pre-existing, PA-N4) |
| Python | 1 test file (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py`) | parity pytest | 1 passed (reviewer run at HEAD) | N/A - no production Python file changed | N/A - test modules are excluded from measurement by policy | N/A - no production Python line changed |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.45% line (CI run 38885440106, 18170 lines, breakpoint mode). Post-change: 91.96% line (CI run 38909263798 merged artifact, 16830/18302). Change: +1.51 points. Denominator change +132 lines, fully attributed by a per-sourcefile comparison of run 38887178530 (unsharded PR head) with run 38909263798 (sharded): `PoshQC.Shard.psm1` +49 (new), `PoshQC.CoverageMerge.psm1` +70 (new), `PoshQC.Testing.psm1` +7 (200 to 207), and `.claude/hooks` and `.codex/hooks` `enforce-orchestration-preimplementation-gate-targets.ps1` +3 each (main commit `d9ce4757e`, not a branch change). All other 200 sourcefiles have identical covered and total counts in both runs. New/changed-code coverage: the two new modules are at 100%; in the modified modules every changed executable line has `ci > 0` except `PoshQC.Testing.psm1:174`, the body of the new default `WriteShardFileList` seam (`ci=0 mi=1`), which no test invokes (code review CR-12). Both modified files remain above 85% and no previously covered changed line lost coverage. Disposition: PASS. Evidence: reviewer per-file comparison script over both downloaded artifacts; `evidence/qa-gates/final-coverage-delta.2026-10-16T13-57.md`.
- Bash: Baseline: no baseline kcov figure was retrieved for this review. Post-change: 95.2% line (3256/3421, CI run 38909263798 `shell-coverage`). Change: not computed. New/changed-code coverage: the changed lines are PowerShell statements inside a `pwsh -Command -` heredoc in two files outside the kcov include roots, so kcov has no line for them (pre-existing population boundary, PA-N4). Disposition: PASS (repo-wide figure above 85%; no branch change alters the kcov population). Evidence: reviewer parse of `cov.xml` from the downloaded artifact.
- Python: Baseline: none (no production Python file is in the diff). Post-change: none (no production Python file is in the diff). Change: two tuple entries added to `POSHQC_PARITY_PATHS` in a test module. New/changed-code coverage: no production Python line changed; test modules are outside the coverage denominator per `.claude/rules/general-unit-test.md`. Disposition: PASS (see assumption PA-N2). Evidence: reviewer `git diff --name-only 5d2d9a972..HEAD -- '*.py'`; parity pytest 1 passed; `final-python-toolchain.2026-10-16T13-57.md` (black, ruff, pyright clean).

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell | PASS | Repo-wide line 91.96% on the merged CI artifact (threshold 85%); new `PoshQC.Shard.psm1` 100% and `PoshQC.CoverageMerge.psm1` 100%; modified `PoshQC.Testing.psm1` 93.24% and `PoshQC.psm1` 88.33%; one new changed line (`PoshQC.Testing.psm1:174`, default seam body) is not executed by tests, with no regression of a previously covered line. Pester reports no branch figure; no branch threshold applies. |
| Bash | PASS | Repo-wide line 95.2% from the CI `shell-coverage` artifact (threshold 85%). kcov reports no branch figure; no branch threshold applies. |
| Python | PASS | The only changed Python file is a test module; zero production Python lines changed, so no coverage figure is attributable to the branch (assumption PA-N2). |
| TypeScript | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

### 1.3 Scenario completeness

| Area | Verdict | Evidence |
|---|---|---|
| CR-1: presence check honors the supported range | PASS | RS09 (Pester 6.0.0 only) and RS10 (inbox 3.4.0 only) assert the actionable `Run Install-PoshQCTool` message; both failed before and pass after (`r1-cr-regression-*`). |
| CR-2: import passes both bounds | PASS | RS08 asserts `Import-Module` with `MinimumVersion 5.9.0` and `MaximumVersion 5.99.99`. |
| CR-3: single predicate, behavior unchanged | PASS | RS03, RS05, MC01-MC05 pass after the refactor (`r1-cr3-installer-tests-after.2026-10-16T11-53.md`). |
| Shard slice selection | PASS | `PoshQC.Shard.Tests.ps1`: round-robin selection, index and count validation, manifest shape, relative-path mapping. |
| Completeness guard | PASS | `PoshQC.Shard.Tests.ps1` SH04-SH09: complete set, dropped file, overlapping selection, repeated index, divergent `all` list, count mismatch and match. |
| Coverage merge | PASS | `PoshQC.CoverageMerge.Tests.ps1` CM01-CM07: max-ci rule, counter recomputation, denominator preservation, line-set mismatch, single-report identity, empty input, LINE summary; the module is at 100% line coverage. |
| Shard plumbing in `Invoke-PoshQCTest` | PASS | TS01-TS03 and the out-of-range index case. |
| Merge job fails when a needed job fails | FAIL | No test asserts the `poshqc` job's needs-result step (`_poshqc.yml:82-90`); see PA-3 / CR-7. |
| Empty shard slice | PARTIAL | No guard or test for `ShardCount` larger than the number of test files (code review CR-13); not reachable with 3 shards and 382 files. |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity | PASS | Selector and merge logic are pure functions over string arrays and XML text; the workflow calls them with file I/O kept in the workflow steps. |
| Reusability | PASS | CR-3 resolved: one `$isSupportedVersion` scriptblock serves both installer checks (`PoshQC.psm1:63,66,79`). |
| Separation of concerns / I/O boundaries | PASS | `Merge-PoshQCCoverageReport` and `Get-PoshQCCoverageLineSummary` take XML text only; manifest writing goes through the injectable `WriteShardFileList` seam. |
| Public API compatibility | PASS | `Invoke-PoshQCTest` gains optional parameters with defaults (`ShardIndex = 0`, `ShardCount = 0`); existing callers are unaffected. Six new functions are exported from both manifests. |
| File size (500 lines) | PASS | Largest changed non-Markdown file: `PoshQC.Testing.psm1` 484 lines; `_poshqc.yml` 185; `PoshQC.Shard.psm1` 165; `PoshQC.CoverageMerge.psm1` 156 (reviewer `wc -l`). |
| Bundle parity | PASS | Reviewer `cmp`: `PoshQC.Shard.psm1`, `PoshQC.CoverageMerge.psm1`, `PoshQC.Testing.psm1`, `PoshQC.psm1`, `PoshQC.psd1`, `README.md`, `settings/pester.runsettings.psd1` identical between repo and bundle; parity pytest 1 passed; `POSHQC_PARITY_PATHS` includes both new modules. |
| Policy files unchanged | PASS | `git diff --name-only 5d2d9a972..HEAD -- .claude/rules .github/instructions .github/workflows/ci.yml` returned zero paths. |
| Workflow `on:` blocks unchanged | PASS | `_poshqc.yml` diff touches no `on:` line (reviewer grep of the diff); `sharding-check-name.2026-10-16T13-59.md`. |
| No failing coverage threshold added (D3) | PASS | `sharding-no-threshold.2026-10-16T13-59.md`; reviewer read of the merge step (summary is logged, not enforced). |
| Error handling | PASS | Selector, guard, and merge functions throw specific messages on invalid input. |
| Dependencies | PASS | No new dependency; `actions/download-artifact@v7` matches the existing `upload-artifact@v7` major (`evidence/other/download-artifact-tag.2026-10-16T10-55.md`). |
| Documentation of public surface | PARTIAL | README and CHANGELOG do not describe the new shard parameters or the six new exported functions of the bundled module (code review CR-9, Minor). |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Format (`Invoke-PoshQCFormat`) | PASS | `final-poshqc-format.2026-10-16T13-34.md`: 0 `Formatted:` lines. |
| PowerShell | Analyze (`Invoke-PoshQCAnalyze`) | PASS | `final-poshqc-analyze.2026-10-16T13-36.md`: no findings. |
| PowerShell | Tests (`Invoke-PoshQCTest`) | PASS | `final-poshqc-test-coverage.2026-10-16T13-57.md`: 10516 tests, 0 failures, 0 errors. |
| PowerShell | Loop closure | PASS | `final-loop-closure.2026-10-16T13-57.md`: 32 file hashes unchanged across the pass; `LOOP_CLEAN_PASS: YES`. |
| Bash | shfmt / shellcheck / bats | PASS | `final-shell-format.2026-10-16T13-57.md`, `final-shell-lint.2026-10-16T13-57.md`, `final-shell-bats.2026-10-16T13-57.md`. |
| Python | black / ruff / pyright | PASS | `final-python-toolchain.2026-10-16T13-57.md`. |
| GitHub Actions | actionlint | PASS | `final-actionlint.2026-10-16T13-57.md`. |
| GitHub Actions | CI execution of the modified workflow | PASS on `9f822f1cb`; pending on HEAD | Run 38909263798 success for every `poshqc` job; run 38912409726 for HEAD queued (PA-1). |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Location mirrors source under `tests/` | PASS | New files under `tests/scripts/powershell/PoshQC/` and `tests/scripts/workflows/`. |
| PowerShell | No temporary files | PASS | Reviewer search of the seven new or changed PoshQC and workflow test files for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `Out-File`, `Set-Content`, `New-Item`: zero matches. |
| PowerShell | Mocks instead of real installs, imports, or file writes | PASS | `PoshQC.TestingShard.Tests.ps1` injects every seam including `WriteShardFileList`; `PoshQC.TestingSeamDefaults.Tests.ps1` mocks `Get-Module` so the result does not depend on host modules. |
| PowerShell | Critical behavior tested | FAIL | The required-check gating step of the `poshqc` merge job has no test (PA-3). |
| Python | Test-only change passes | PASS | Parity pytest 1 passed. |

## 5. Test Coverage Detail

| File | Status | Line Coverage | Changed Executable Lines | Verdict |
|---|---|---|---|---|
| `scripts/powershell/PoshQC/PoshQC.Shard.psm1` | New | 100% (49/49), CI merged artifact | all | PASS |
| `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1` | New | 100% (70/70), CI merged artifact | all | PASS |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | Modified | 93.24% (193/207); baseline 100% (200/200, breakpoint mode) | CR-1/CR-2 lines 179, 183, 320 and shard block 411-417 have `ci > 0`; line 174 (default `WriteShardFileList` body) `ci=0` | PASS (CR-12) |
| `scripts/powershell/PoshQC/PoshQC.psm1` | Modified | 88.33% (53/60); baseline 66.67% (40/60) | lines 63, 66, 79 and load-list entries, all `ci > 0` | PASS |
| `extensions/drm-copilot/resources/powershell/PoshQC/*.psm1` | New/modified bundle copies | outside the coverage population; byte-identical to the measured sources | - | PASS (PA-N3) |
| `scripts/powershell/PoshQC/PoshQC.psd1` (and bundle) | Modified manifest | not measured (`.psd1`) | export list | PASS |
| `.devcontainer/post-create.sh`, `.github/codex/codex-web-setup.sh` | Modified bash | outside kcov roots | PowerShell heredoc lines | PASS (PA-N4) |

## 6. Test Execution Metrics

| Suite | Runner | Result | Source |
|---|---|---|---|
| Full repository Pester suite, unsharded, sharding-path tree | `Invoke-PoshQCTest` (executor) | 10516 tests, 0 failures, 0 errors; 995 s wall | `final-poshqc-test-coverage.2026-10-16T13-57.md` |
| Sharded CI suite | CI run 38909263798 | shards 3203 + 4092 + 3306 = 10601 tests, 0 failures; completeness step success | reviewer `gh run view --log` of job 117009273642 |
| CI step timings (sharded) | CI run 38909263798 | `Test PowerShell` shard 1 214 s, shard 2 340 s, shard 3 603 s; static job 174 s; merge job 94 s | reviewer `gh run view --json jobs` |
| CR-1/CR-2 regression (pre-fix) | Pester targeted | 10 tests, 3 failures (RS08-RS10, expected) | `r1-cr-regression-fail-before.2026-10-16T11-47.md` |
| CR-1/CR-2 regression (post-fix) | Pester targeted | 10 tests, 0 failures | `r1-cr-regression-pass-after.2026-10-16T11-49.md` |
| Sharding unit tests | Pester targeted | 10 + 8 + 4 + 10 tests, 0 failures | `sharding-unit-shard`, `sharding-unit-merge`, `sharding-unit-testing`, `sharding-workflow-tests` evidence |
| Bundled parity | pytest (reviewer, HEAD) | 1 passed | reviewer run 2026-10-16 |
| bats `codex_web_setup` | bats | 75 ok | `final-shell-bats.2026-10-16T13-57.md` |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| `5.6.1` absent at the AC-04 sites and committed-manifest tests | reviewer `grep -c`: 0 at all ten paths; the one remaining match (`HostBootstrap.Invoke.Tests.ps1:202`) is a synthetic manifest, which AC-05 permits |
| Check name `poshqc / PowerShell QC` retained | `_poshqc.yml:75-76`; `sharding-check-name.2026-10-16T13-59.md` |
| Merged artifact equals unsharded profile | reviewer per-sourcefile comparison (section 1.2.1) |
| #936 lines in the merged artifact | `.codex/hooks` modes line 41 `ci=1 mi=0`; epic-scope lines 206 and 207 `ci=1 mi=0` (reviewer parse, run 38909263798) |

## 8. Gaps and Exceptions

- PA-1 (Blocking, `awaiting_ci`): rule `modified-workflow-needs-green-run`. `.github/workflows/_poshqc.yml` is modified (job split, shard matrix, merge job, Linux import range). Run 38909263798 (head `9f822f1cb`) is green, but condition (b)(2) fails for it: `git log 9f822f1cb..HEAD` includes merge commit `c1dab385e`, which brings `origin/main` changes outside the feature folder. Run 38912409726 for HEAD is queued. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.
- PA-2 (Blocking, `awaiting_ci`): AC-08 to AC-12 are unchecked. Plan tasks P8-T19 (re-record PR-head evidence from the sharded run) and P8-T20 (sharding closure and check-off) are open and must run against the final head's CI run.
- PA-3 (Blocking, `autonomous`): untested critical behavior. The `poshqc` job runs with `if: always()` (`_poshqc.yml:79`) and relies on its first step (`_poshqc.yml:82-90`) to exit 1 when `needs.poshqc-static.result` or `needs.poshqc-shard.result` is not `success`. `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` asserts the job's `needs:` list but not the `if: always()` condition or the result check. `.claude/rules/general-unit-test.md` states that untested critical behavior is not acceptable; this step determines whether failing PowerShell tests can produce a green required check. Remediation: add a workflow test asserting the result-check step (both `needs.<job>.result` comparisons and a non-zero exit) and its position before the merge steps. Code review CR-7.
- PA-N1 (Non-blocking risk for AC-08 at S9): `origin/main` commit `d9ce4757e` (11:41 UTC) added 3 lines to each `enforce-orchestration-preimplementation-gate-targets.ps1` copy after the baseline run 38885440106 used in `ci-coverage-comparison.2026-10-16T10-54.md`. If P8-T19 reuses that baseline, `TOTAL_EQUAL` over the non-PoshQC keys will report two differing keys for a reason outside this branch. Reselect the baseline at the current merge base `5d2d9a972` (P7-T5 procedure) before evaluating AC-08.
- PA-N2 (Assumption): Python coverage verdict. The verification procedure flags an absent coverage artifact as FAIL for a language with changed files. The only changed Python file is a test module, which `.claude/rules/general-unit-test.md` requires coverage tooling to exclude, so no Python coverage artifact could contain a line attributable to this branch, and no CI run produces a Python coverage artifact for this PR (reviewer artifact listing of run 38909263798). The reviewer records PASS on that basis. If the orchestrator applies the absent-artifact rule literally, this becomes an `autonomous` finding resolved by recording `poetry run pytest --cov` figures in the evidence tree.
- PA-N3 (Non-blocking, pre-existing): bundled PoshQC copies are outside `config/poshqc-coverage.json` roots; they are byte-identical to the measured sources.
- PA-N4 (Non-blocking, pre-existing): `.devcontainer/` and `.github/codex/` are outside the kcov include roots.
- PA-N6 (Non-blocking observation on goal G1): the one CI sample of profiler mode did not shorten the unsharded step. Baseline run 38846579572 (breakpoint mode, 10407 tests) took 930 s in `Test PowerShell`; PR-head run 38887178530 (profiler mode, 10488 tests) took 1141 s (`ci-baseline-timing.2026-10-16T06-40.md`, `ci-prhead-timing.2026-10-16T10-54.md`). The test count differs by 0.8%; runner variance across single samples is not quantified. The measured reduction in the `poshqc` critical path comes from sharding. No acceptance criterion sets a speed target for the primary path, so this is not a finding against an AC, but the rationale for keeping the experimental profiler mode (spec Risks) now rests on an unconfirmed benefit. Recommend that the orchestrator report this to the user and, if wanted, measure one sharded run in breakpoint mode before or after merge.
- PA-N5 (Non-blocking observation for AC-10): after sharding, the `poshqc / PowerShell QC` job no longer contains a `Test PowerShell` step; the spec timing command for the step returns no value for that job name. P8-T19 already substitutes per-shard step timings; the AC-10 evidence should state that substitution.

## 9. Summary of Changes

- Remediation cycle 1: range-aware `EnsureModule` presence check and two-sided import (`PoshQC.Testing.psm1`), single installer version predicate (`PoshQC.psm1`), RS08-RS10 regression tests, `Get-Module` mock in `PoshQC.TestingSeamDefaults.Tests.ps1`.
- Sharding phase: `_poshqc.yml` split into `poshqc-static`, `poshqc-shard` (matrix 1..3, `fail-fast: false`, per-shard artifacts with `if: always()`), and `poshqc` (needs-result check, completeness guard, coverage merge, Koverage copy, `poshqc-test-results` upload); new `PoshQC.Shard.psm1` and `PoshQC.CoverageMerge.psm1` (repo and bundle); `-ShardIndex`, `-ShardCount`, `-ShardFileListPath`, `-WriteShardFileList` on `Invoke-PoshQCTest`; six new exports; parity list updated; new tests `PoshQC.Shard.Tests.ps1`, `PoshQC.CoverageMerge.Tests.ps1`, `PoshQC.TestingShard.Tests.ps1`; workflow test updated.
- Unchanged from round 1: profiler-mode runsettings, Pester 5.9.0 minimum and < 6.0 ceiling, CHANGELOG and README entries, D9 test split.

## 10. Compliance Verdict

**REMEDIATION_REQUIRED** - 3 Blocking findings: PA-1 (`awaiting_ci`), PA-2 (`awaiting_ci`), PA-3 (`autonomous`). Non-blocking: PA-N1 to PA-N6.

## Appendix A: Test Inventory

- `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1` (new, 137 lines): slice selection, manifest, completeness guard, test-count guard.
- `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1` (new, 171 lines): merge rules, counter recomputation, input validation, LINE summary.
- `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1` (new, 115 lines): TS01-TS03 and out-of-range index.
- `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` (new, 233 lines): RS01-RS10.
- `tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1` (new, 103 lines): MC01-MC05.
- `tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1` (new, 295 lines): D9 split.
- Modified: `PoshQcWorkflow.Tests.ps1` (job set and shard/static jobs), `PoshQC.TestingSeamDefaults.Tests.ps1` (`Get-Module` mock), `PoshQC.Tests.ps1`, `PoshQC.EntryPoints.Tests.ps1`, `host-tools.manifest.Tests.ps1`, `HostBootstrap.Invoke.Tests.ps1`, `test_poshqc_bundled_parity.py`.

## Appendix B: Toolchain Commands Reference

- `git diff --stat=200 5d2d9a9728b3763cb4398bdae1e54ef84ee98936..HEAD -- . ':!docs/features'`; `git diff --name-status` over the same range
- `git diff 5d2d9a972..HEAD -- .github/workflows/_poshqc.yml scripts/powershell/PoshQC/PoshQC.Testing.psm1 scripts/powershell/PoshQC/PoshQC.psm1 scripts/powershell/PoshQC/PoshQC.psd1 tests/scripts/dev_tools/test_poshqc_bundled_parity.py`
- `git diff --name-only 5d2d9a972..HEAD -- artifacts .claude/rules .github/instructions .github/workflows/ci.yml` (zero paths)
- `git diff --stat 9f822f1cb HEAD -- . ':!docs'`; `git log --oneline 9f822f1cb..HEAD`
- `git log -3 origin/main -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1`
- `wc -l` on changed PoshQC modules, tests, workflow, and shell scripts; `cmp -s` for seven repo/bundle pairs
- `grep -c "5\.6\.1"` on the AC-04 and AC-05 paths
- `gh run list --branch bug/pester-profiler-coverage-953 --limit 8`; `gh run view 38909263798 --json jobs` (job and step durations); `gh run view 38909263798 --job 117009273642 --log` (completeness and merge summary lines)
- `gh run download 38909263798 -n poshqc-test-results`; `gh run download 38887178530 -n poshqc-test-results`; `gh run download 38909263798 -n shell-coverage` (session scratchpad)
- `pwsh -NoProfile -File <scratchpad>/r2-perfile.ps1` (per-sourcefile LINE comparison of the two coverage artifacts)
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0)
- `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` (1 passed)

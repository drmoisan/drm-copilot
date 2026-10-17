# Policy Audit: pester-profiler-coverage (Issue #953)

- Timestamp: 2026-10-16T10-17
- Reviewer: feature-review agent (full feature-vs-base review, pre-PR)
- Branch: `bug/pester-profiler-coverage-953`, HEAD `0087d2bc2514721a0a89b1032010e95afb6c21ec` (pushed; no pull request exists yet)
- Base: `origin/main` @ `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea` (merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`)
- Diff command: `git diff 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea...HEAD` (84 files, +3813/-319). Outside the feature folder and the lifecycle record: 21 files.
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-10-16 10:12:24 UTC with head `0087d2bc2514721a0a89b1032010e95afb6c21ec` and merge base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`; both match the branch state, so no refresh was needed. CI status at HEAD: not available (no PR).
- Work mode: `full-bug` (`issue.md` line 12). AC source: `spec.md` only; `user-story.md` is absent by design.
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/tonality.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/shell.md`, `.claude/rules/python.md` (no Python file changed).
- Coverage thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults govern (line >= 85%; branch >= 75% for branch-capable languages; PowerShell and bash are exempt from the branch threshold).
- Tiers: `quality-tiers.yml` exists at the repository root; `scripts/powershell/PoshQC` is classified T3 (plan P0-T10). No T1/T2 property-test or mutation obligation applies.

## Executive Summary

The branch switches Pester code coverage to profiler mode through data (`CodeCoverage.UseBreakpoints = $false` in both runsettings copies), raises the declared Pester minimum from 5.6.1 to 5.9.0 at every listed site, adds a Pester major-version ceiling below 6.0 (decision D8), adds a seven-case regression test file and a five-case module coverage test file, splits `PoshQC.Tests.ps1` (579 lines at base) into two files under the 500-line limit (decision D9), and records baseline and local QA evidence.

Local toolchain evidence is complete and consistent: format produced no diff, the analyzer reported zero findings, the full Pester run passed 10388 tests with 0 failures, and repo-wide PowerShell LINE coverage is 91.89% (16647/18116) with the denominator equal to the local baseline. The reviewer re-parsed the on-disk `artifacts/pester/powershell-coverage.xml` and confirmed the report-level and per-file figures.

Overall verdict: **AWAITING_CI**. Blocking findings: 3, all classified `awaiting_ci`:

- PA-1: `.github/workflows/_poshqc.yml` is modified and no green run of it against the branch head exists (rule `modified-workflow-needs-green-run`).
- PA-2: CI-dependent acceptance criteria AC-08 to AC-12 cannot be evaluated until CI runs on the PR head.
- PA-3: bash has changed files (`.devcontainer/post-create.sh`, `.github/codex/codex-web-setup.sh`) and no bash kcov coverage artifact exists locally; the canonical artifact is the CI `shell-coverage` upload.

No autonomous finding exists. Non-blocking observations: PA-N1 to PA-N4 (section 8).

## Rejected Scope Narrowing

No scope narrowing was detected. The caller prompt supplies the base branch, merge base, feature folder, PR-context paths, AC source, and plan path, and states that the PR does not exist and CI has not run. None of these statements removes a file, language, or check from the audit. The audit covers every changed file in `git diff 5bdf22d0f...HEAD`, including the two shell scripts, the workflow file, the JSON manifest, the bundled copies, and all test files.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- Branch-diff scan: `git diff --name-only 5bdf22d0f...HEAD -- artifacts` returned zero paths. No file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence is under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | `PoshQC.RunSettings.Tests.ps1` and `PoshQC.ModuleCoverage.Tests.ps1` build their seams per `It`. MC05 saves and restores the AppDomain cache slot in `BeforeEach`/`AfterEach` and re-imports the module. |
| Isolation | PASS | Each `It` targets one behavior (one runsettings key group, one installer path, one import seam, one workflow line). |
| Fast execution | PASS | Targeted run of the seven RS cases and five MC cases recorded in `evidence/regression-testing/runsettings-regression-pass-after.2026-10-16T08-20.md` and `evidence/qa-gates/module-coverage-tests.2026-10-16T08-26.md`. |
| Determinism | PASS | No network, no real install (every installer seam injected), `Import-Module` mocked in RS06, no clock or RNG use. |
| Readability | PASS | Token-prefixed titles (`RS01`..`RS07`, `MC01`..`MC05`), Arrange/Act/Assert comments, and `-Because` messages. |

### 1.2 Coverage requirements

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- Python baseline coverage artifact: N/A - no Python file changed on the branch (`evidence/qa-gates/final-python-toolchain.2026-10-16T09-55.md`; reviewer `git diff --name-only 5bdf22d0f...HEAD -- '*.py'` returned zero paths).
- C# baseline and post-change coverage artifact: N/A - no C# file changed on the branch.
- PowerShell baseline coverage artifact: CI run 38846579572 `poshqc-test-results` (`evidence/baseline/ci-baseline-coverage-figures.2026-10-16T06-40.md`, LINE 16417/18154 = 90.43%) and the local breakpoint-mode baseline (`evidence/qa-gates/final-coverage-delta.2026-10-16T09-55.md`, LINE 16387/18116 = 90.46%).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-10-16 09:52 UTC by the final full run that started 09:39:03 UTC). Reviewer parse: report-level `LINE missed="1469" covered="16647"` (91.89%), 203 `sourcefile` elements.
- Bash coverage artifact: absent. `artifacts/pester/kcov/` does not exist in the worktree; the canonical artifact is the `shell-coverage` upload of `.github/workflows/_shell-coverage.yml`, which `ci.yml` calls on every PR.
- Per-language comparison summary: PowerShell repo-wide line rose from 90.46% to 91.89% on an equal local denominator; both modified production modules exceed 85% and every changed executable line is covered. Bash coverage cannot be evaluated before CI; its verdict is FAIL (PA-3).

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 2 production modules (+2 byte-identical bundle copies), 2 runsettings data files, 7 test files (2 new, 1 new from the D9 split) | full repository Pester suite | 10388 passed, 0 failed, 0 errors (`final-poshqc-test-coverage.2026-10-16T09-55.md`) | 90.46% line local (16387/18116); 90.43% line CI run 38846579572 (16417/18154) | 91.89% line (16647/18116) | 7 of 7 changed executable lines covered (`ci > 0`); `PoshQC.psm1` 88.33%, `PoshQC.Testing.psm1` 93.50% |
| Bash | 2 (`.devcontainer/post-create.sh`, `.github/codex/codex-web-setup.sh`) | 7 `codex_web_setup` bats files | pass (`final-shell-bats.2026-10-16T09-58.md`) | N/A - no kcov artifact exists; coverage verdict FAIL (PA-3) | N/A - no kcov artifact exists; coverage verdict FAIL (PA-3) | N/A - changed lines are outside the kcov roots; coverage verdict FAIL (PA-3) |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| Python | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.46% line (16387/18116, local breakpoint mode at base). Post-change: 91.89% line (16647/18116, profiler mode). Change: +1.43 points; denominator unchanged (18116 = 18116), 203 sourcefiles in both, 0 keys dropped, 0 keys added. New/changed-code coverage: 100% of changed executable lines (`PoshQC.psm1` lines 56, 58, 62, 75 and `PoshQC.Testing.psm1` lines 169, 306 each `ci >= 1`, reviewer-verified). Disposition: PASS. Evidence: reviewer `grep` of `artifacts/pester/powershell-coverage.xml`; `evidence/qa-gates/final-coverage-delta.2026-10-16T09-55.md`.
- Bash: Baseline: no artifact. Post-change: no artifact. Change: not computable. New/changed-code coverage: not computable; both changed files are outside the kcov include roots (`tools/`, `scripts/`, `.claude/lib/bash/`, `.claude/skills/`, `.codex/`) per `.claude/rules/shell.md`, and the changed lines are PowerShell text inside a heredoc passed to `pwsh -Command -`. Disposition: FAIL (artifact absent; PA-3, `awaiting_ci`). Evidence: directory listing of `artifacts/pester/` (no `kcov/`); `.github/workflows/ci.yml:26-27`.

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell | PASS | Repo-wide line 91.89% (threshold 85%); modified `scripts/powershell/PoshQC/PoshQC.psm1` 88.33% (53/60, baseline 66.67%); modified `scripts/powershell/PoshQC/PoshQC.Testing.psm1` 93.50% (187/200); no changed line regressed. Pester measures no branch figure; the branch threshold is not evaluated. |
| Bash | FAIL | Coverage artifact absent for bash; coverage verification is mandatory for all languages with changed files. Classified `awaiting_ci` (PA-3). |
| TypeScript | N/A | Zero changed files. |
| Python | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

### 1.3 Scenario completeness

| Area | Verdict | Evidence |
|---|---|---|
| Runsettings profiler key (repo and bundle copies) | PASS | RS01, RS02 (`New-PesterConfiguration -Hashtable`), RS04. |
| Installer minimum 5.9.0 (install path) | PASS | RS03 records the `InstallModule` call with `5.9.0`. |
| Installer ceiling (only Pester 6.0.0 present) | PASS | RS05 asserts one Pester install call with `5.9.0` and no PSScriptAnalyzer call. |
| Import ceiling in `Invoke-PoshQCTest` | PASS | RS06 asserts `Import-Module` with `Name Pester`, `-Global`, `MaximumVersion 5.99.99`. |
| Linux workflow range | PASS | RS07 asserts both bounds on the single `Import-Module Pester` line of the `poshqc-linux-hooks` job. |
| Negative / error paths in `Install-PoshQCTool` | PASS | MC01 (trust failure warning), MC02 (TLS failure verbose), MC04 (post-install check throws). |
| Fail-before / pass-after | PASS | 7 of 7 RS cases failed on the pre-fix tree and passed after (`evidence/regression-testing/`). |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity | PASS | The speedup is one data key per runsettings copy; the ceiling is one `UpperBound` entry plus one filter clause. |
| Reusability | PASS (observation) | The version predicate is repeated on `PoshQC.psm1` lines 62 and 75 (code review CR-2, Minor). |
| Public API compatibility | PASS | `EnsureModule` gains a third positional parameter; a caller-supplied two-parameter scriptblock receives it in `$args` and is not broken. `Invoke-PoshQCTest` and `Install-PoshQCTool` signatures are unchanged. |
| File size (500 lines) | PASS | Largest changed non-Markdown files: `PoshQC.Testing.psm1` 461, `HostBootstrap.Invoke.Tests.ps1` 348, `post-create.sh` 323, `PoshQC.TestingCommands.Tests.ps1` 295, `PoshQC.Tests.ps1` 289 (reviewer `wc -l`). The base `PoshQC.Tests.ps1` was 579 lines; the D9 split resolves that. |
| Test split fidelity (D9) | PASS | Reviewer: base lines 291-579 of `PoshQC.Tests.ps1` are byte-identical to lines 7-295 of `PoshQC.TestingCommands.Tests.ps1` (`diff` exit 0); the new file's lines 1-6 repeat the original `Set-StrictMode`/`BeforeAll` header. |
| Bundle parity | PASS | Reviewer `cmp`: `PoshQC.psm1`, `PoshQC.Testing.psm1`, `README.md`, `settings/pester.runsettings.psd1` identical between `scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/`; `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` 1 passed. |
| Policy files unchanged | PASS | `git diff --name-only 5bdf22d0f...HEAD -- .claude/rules .github/instructions .github/workflows/ci.yml` returned zero paths. |
| Workflow `on:` blocks unchanged | PASS | `_poshqc.yml` diff is one line in the `poshqc-linux-hooks` job body (line 73). |
| Error handling | PASS (observation) | Installer errors are unchanged. See code review CR-1 for the message shown when only Pester 6 is installed. |
| Dependencies | PASS | No new dependency; Pester 5.9.0 is the version already on the CI image. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Format (`Invoke-PoshQCFormat`) | PASS | `evidence/qa-gates/final-poshqc-format.2026-10-16T09-37.md`: 0 `Formatted:` lines, `git status` unchanged. |
| PowerShell | Analyze (`Invoke-PoshQCAnalyze`) | PASS | `evidence/qa-gates/final-poshqc-analyze.2026-10-16T09-38.md`: `PSScriptAnalyzer passed: no findings`. |
| PowerShell | Tests (`Invoke-PoshQCTest`) | PASS | `evidence/qa-gates/final-poshqc-test-coverage.2026-10-16T09-55.md`: 10388 tests, 0 failures, 0 errors. |
| Bash | shfmt | PASS | `evidence/qa-gates/final-shell-format.2026-10-16T09-58.md`: the `shfmt -d` output equals the base-commit output after substituting the four changed lines (no new formatting diff). Expected exit 1 reflects pre-existing diffs. |
| Bash | shellcheck | PASS | `evidence/qa-gates/final-shell-lint.2026-10-16T09-58.md`: output identical to baseline. |
| Bash | bats | PASS | `evidence/qa-gates/final-shell-bats.2026-10-16T09-58.md`: 7 `codex_web_setup` bats files pass. |
| GitHub Actions | actionlint | PASS | `evidence/qa-gates/final-actionlint.2026-10-16T09-58.md`: exit 0. |
| JSON | Manifest shape | PASS | `tests/scripts/host-tools.manifest.Tests.ps1` passes (`evidence/qa-gates/host-tools-tests-after.2026-10-16T08-23.md`). |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Location mirrors source under `tests/` | PASS | New files under `tests/scripts/powershell/PoshQC/`. |
| PowerShell | No temporary files | PASS | Tests read checked-in files only (runsettings, `_poshqc.yml`, module folder listing); no `New-Item`, `TestDrive`, or temp path in the new files. |
| PowerShell | Mocks instead of real installs or network | PASS | All `Install-PoshQCTool` seams injected; `Import-Module` mocked in module scope in RS06. |
| PowerShell | `#Requires` Pester 5.4 or later | PASS | Both new files declare `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.4.0' }`. |

## 5. Test Coverage Detail

| File | Status | Line Coverage | Changed Executable Lines | Verdict |
|---|---|---|---|---|
| `scripts/powershell/PoshQC/PoshQC.psm1` | Modified | 88.33% (53/60); baseline 66.67% (40/60) | 4 (56, 58, 62, 75), all covered | PASS |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | Modified | 93.50% (187/200); baseline 100.00% (200/200) | 2 (169, 306), both covered | PASS (see PA-N2) |
| `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` | Modified bundle copy | not in the coverage population; byte-identical to the measured source | - | PASS (see PA-N3) |
| `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` | Modified bundle copy | not in the coverage population; byte-identical to the measured source | - | PASS (see PA-N3) |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (and bundle) | Modified data file | not measured (`.psd1` is outside the measured `.ps1`/`.psm1` set) | 1 data key | PASS |
| `.devcontainer/post-create.sh` | Modified bash | not measured (outside kcov roots) | 2 (PowerShell heredoc lines 246, 262) | FAIL (PA-3, artifact absent) |
| `.github/codex/codex-web-setup.sh` | Modified bash | not measured (outside kcov roots) | 2 (PowerShell heredoc lines 226, 231) | FAIL (PA-3, artifact absent) |

## 6. Test Execution Metrics

| Suite | Runner | Result | Source |
|---|---|---|---|
| Full repository Pester suite with coverage | `Invoke-PoshQCTest` (executor, pre-merge tree `add057da8`) | 10388 tests, 0 failures, 0 errors; 942 s wall | `evidence/qa-gates/final-poshqc-test-coverage.2026-10-16T09-55.md` |
| RunSettings regression (pre-fix) | Pester targeted | 7 tests, 7 failures (expected) | `evidence/regression-testing/runsettings-regression-fail-before.2026-10-16T08-15.md` |
| RunSettings regression (post-fix) | Pester targeted | 7 tests, 0 failures | `evidence/regression-testing/runsettings-regression-pass-after.2026-10-16T08-20.md` |
| D9 split before/after | Pester targeted | pass; test count unchanged | `evidence/other/poshqc-tests-split-before.2026-10-16T09-32.md`, `evidence/qa-gates/poshqc-tests-split-after.2026-10-16T09-35.md` |
| Bundled parity | pytest (reviewer, HEAD) | 1 passed | reviewer run 2026-10-16 |
| bats `codex_web_setup` | bats | pass | `evidence/qa-gates/final-shell-bats.2026-10-16T09-58.md` |

The merge commit `0087d2bc2` brought 996 files from `origin/main`, none under `scripts/powershell/PoshQC`, `tests/scripts/powershell/PoshQC`, or the other changed paths of this branch (reviewer `git diff --stat add057da8 0087d2bc2`). The local Pester evidence therefore still describes the branch's own changes; the PR-head CI run is the authoritative post-merge result.

## 7. Code Quality Checks

| Check | Result |
|---|---|
| `5.6.1` absent at the eight AC-04 sites | `evidence/qa-gates/final-pin-sweep.2026-10-16T10-00.md` |
| `UseBreakpoints = $false` in both runsettings copies; other `CodeCoverage` keys unchanged | `evidence/other/runsettings-load-check.2026-10-16T08-17.md`; `evidence/qa-gates/final-runsettings-diff.2026-10-16T09-59.md` |
| CHANGELOG `[Unreleased]` entry names profiler mode, 5.9.0, and the ceiling | `evidence/qa-gates/final-changelog.2026-10-16T10-00.md`; reviewer diff read |
| `ci.yml` and `on:` blocks unchanged | `evidence/qa-gates/final-scope-ac13.2026-10-16T10-00.md` |

## 8. Gaps and Exceptions

- PA-1 (Blocking, `awaiting_ci`): Rule `modified-workflow-needs-green-run`. `.github/workflows/_poshqc.yml` is modified (line 73, Linux job `Import-Module Pester -MinimumVersion 5.9.0 -MaximumVersion 5.99.99`). No green run of `_poshqc.yml` (through `ci.yml` or `workflow_dispatch`) exists for head `0087d2bc2` or a qualifying predecessor. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.
- PA-2 (Blocking, `awaiting_ci`): AC-08, AC-09, AC-10, AC-11, AC-12 are CI-dependent per `spec.md` and need the PR-head `poshqc-test-results` artifact and job timings.
- PA-3 (Blocking, `awaiting_ci`): Bash coverage artifact absent. After CI, confirm the `shell-coverage` artifact reports repo-wide bash line coverage >= 85%. Per-file figures for the two changed scripts will not appear in it (see PA-N4).
- PA-N1 (Non-blocking risk for AC-08): AC-08 requires the PR-head LINE total to equal the total of baseline run 38846579572 (head `072df404`, 18154 lines). `origin/main` has moved since that run: between `072df404` and the merge base `5bdf22d0f`, 13 production PowerShell files in the coverage roots changed, including the new `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` (+116 lines). The PR-head report will therefore probably differ in total and in sourcefile count from run 38846579572 for reasons unrelated to this branch. Recommended handling at S9: compare the PR-head artifact against a CI run whose head is the merge base `5bdf22d0f` (or record both comparisons), and escalate the interpretation of AC-08 to the user if equality against run 38846579572 fails only because of base drift.
- PA-N2 (Non-blocking observation): Under profiler mode `PoshQC.Testing.psm1` reports 13 missed lines (53, 54, 57, 58, 62, 63, 64, 204, 213, 251, 252, 253, 255) that were covered under breakpoint mode. They are bodies of default seam scriptblocks and a `Where-Object` filter scriptblock. The file stays above 85% and no changed line regressed, but this is the per-file attribution shift the spec anticipates; AC-09 must list it from the CI artifacts.
- PA-N3 (Non-blocking, pre-existing): the bundled `extensions/drm-copilot/resources/powershell/PoshQC/*.psm1` copies are outside `config/poshqc-coverage.json` roots. They are byte-identical to the measured sources (parity test enforced), so the measured figures apply to their content.
- PA-N4 (Non-blocking, pre-existing): `.devcontainer/` and `.github/codex/` are outside the kcov include roots defined in `.claude/rules/shell.md`, so per-file bash coverage of the two changed scripts is not measurable by the repository toolchain. This condition predates the branch and no branch change introduces an exclusion. Follow-up candidate: decide whether these two production scripts belong in the kcov population.

## 9. Summary of Changes

- Profiler-mode coverage: `UseBreakpoints = $false` in both `pester.runsettings.psd1` copies.
- Pester minimum 5.9.0: `PoshQC.psm1` (both copies), README (both copies), `_poshqc.yml` Linux job, `scripts/host-tools.manifest.json`, `.devcontainer/post-create.sh`, `.github/codex/codex-web-setup.sh`, and the two committed-manifest tests.
- Pester ceiling below 6.0 (D8): exclusive `UpperBound = '6.0.0'` in the installer and both shell present-checks; `-MaximumVersion 5.99.99` in the `Invoke-PoshQCTest` default `EnsureModule` seam and the Linux job; fixture versions `9.9.9` changed to `5.9.5`.
- Tests: new `PoshQC.RunSettings.Tests.ps1` (RS01-RS07), new `PoshQC.ModuleCoverage.Tests.ps1` (MC01-MC05, decision D6), D9 split of `PoshQC.Tests.ps1` into `PoshQC.Tests.ps1` and `PoshQC.TestingCommands.Tests.ps1`.
- Documentation: CHANGELOG `[Unreleased]` entry; README profiler-mode note.

## 10. Compliance Verdict

**AWAITING_CI** - 3 Blocking findings (PA-1, PA-2, PA-3), all `awaiting_ci`; 0 autonomous findings. 4 non-blocking observations (PA-N1 to PA-N4).

## Appendix A: Test Inventory

- `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` (new, 163 lines): RS01, RS02, RS04 (runsettings), RS03, RS05 (installer), RS06 (import seam), RS07 (workflow).
- `tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1` (new, 103 lines): MC01-MC04 (default Logger and post-install check), MC05 (sub-module cache miss).
- `tests/scripts/powershell/PoshQC/PoshQC.TestingCommands.Tests.ps1` (new, 295 lines): moved verbatim from `PoshQC.Tests.ps1` (`Convert-PoshQCCoverageToRelative` and subsequent `Describe` blocks).
- Modified: `PoshQC.Tests.ps1`, `PoshQC.EntryPoints.Tests.ps1` (fixture `9.9.9` to `5.9.5`), `host-tools.manifest.Tests.ps1`, `HostBootstrap.Invoke.Tests.ps1` (`5.6.1` to `5.9.0`).

## Appendix B: Toolchain Commands Reference

- `git diff --stat 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea...HEAD`; `git diff 5bdf22d0f...HEAD -- <paths>`; `git log --oneline 5bdf22d0f..HEAD`
- `git diff --name-only 5bdf22d0f...HEAD -- artifacts .claude/rules .github/instructions .github/workflows/ci.yml`
- `git diff --stat add057da8 0087d2bc2`; `git diff --stat 072df404177564ff9f247fd422cce69bb6136ad6 5bdf22d0f -- '*.ps1' '*.psm1' ':(exclude)tests' ':(exclude)extensions'`
- `git show 5bdf22d0f:tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` to the session scratchpad; `tail -n +291` and `tail -n +7` piped to `diff` (exit 0)
- `cmp scripts/powershell/PoshQC/<file> extensions/drm-copilot/resources/powershell/PoshQC/<file>` for four files
- `wc -l` on every changed non-Markdown file
- `grep` of `artifacts/pester/powershell-coverage.xml` for report-level and per-file `LINE` counters and changed-line `ci` values
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0)
- `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` (1 passed)

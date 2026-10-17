# Policy Audit: pester-profiler-coverage (Issue #953) - Remediation Cycle 2 Re-Audit

- Timestamp: 2026-10-16T17-02
- Reviewer: feature-review agent (full feature-vs-base review; re-audit of remediation cycle 2, which addressed CR-7 to CR-13 and CR-17 of `code-review.2026-10-16T14-11.md`)
- Branch: `bug/pester-profiler-coverage-953`, HEAD `44fb400970655d1eb5838b1f4ae88568f9481e74` (pushed; PR #959 open against `main`, mergeable)
- Base: `origin/main` @ `d72ec6a1010223f7036b9c3d15dad102ae262f98` (merge-base `d72ec6a1010223f7036b9c3d15dad102ae262f98`)
- Diff command: `git diff d72ec6a10..HEAD`. Outside `docs/features/`: 32 files (+2377/-335).
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-10-16 16:59:05 UTC for head `44fb40097` and merge base `d72ec6a10`; both match the branch state, so no refresh was needed.
- CI status at HEAD (reviewer `gh run watch`, completed during this review): CI run 38936152953 (head `44fb40097`) concluded `failure`. Shard 1 `Test PowerShell` reported 3443 passed and 1 failed: `issue #850 changed-file constraints.baseline mock interception probe` (`tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1:80`, "Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times"). The `poshqc` merge job then failed at its result-gate step. Run 38935591244 (head `8acac63e7`, identical PowerShell tree) failed with the same test and message. The earlier run 38929655043 (head `1f208b4e5`) failed on TS04 instead, which `8acac63e7` fixed. Every other CI job in run 38936152953 succeeded.
- Work mode: `full-bug` (`issue.md`). AC source: `spec.md` only; `user-story.md` is absent by design.
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/tonality.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/shell.md`, `.claude/rules/python.md`.
- Coverage thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults govern (line >= 85%; branch >= 75% for branch-capable languages; PowerShell and bash have no branch threshold).
- Tiers: `quality-tiers.yml` exists at the repository root; `scripts/powershell/PoshQC` is T3. No property-test or mutation obligation applies.

## Executive Summary

Remediation cycle 2 (`remediation-plan.2026-10-16T14-19.md`) resolved the single `autonomous` finding of the previous round (PA-3 / CR-7) and the related Minor findings CR-8 to CR-13 and CR-17:

- CR-7: `PoshQcWorkflow.Tests.ps1` now asserts the job-level `if: always()` of the `poshqc` merge job (WF01), the result-gate step content and its position before the completeness and merge steps (WF02), and that four in-memory mutations of that step are detected (WF03). CI run 38929655043 also showed the gate working in practice: a failing shard 1 caused the `poshqc` job to fail at `Require the static and shard jobs to succeed`.
- CR-8: the merged coverage report omits `class` and `method` elements and every counter other than LINE and INSTRUCTION (CM02, CM08).
- CR-9: CHANGELOG and both README copies describe the shard parameters, the six exports, and the merged-report counters.
- CR-10: shards are balanced by file size with a longest-processing-time assignment (SH10, SH11, SH12, TS06). In CI run 38929655043 the shard `Test PowerShell` steps took 374 s, 283 s, and 396 s, against 214 s, 340 s, and 603 s with the previous round-robin assignment (single samples).
- CR-11: the matrix is the only place the shard count is written (WF04, WF05).
- CR-12: the default `WriteShardFileList` seam body is now executed (`PoshQC.Testing.psm1:174` `ci=1`, TS04).
- CR-13: an empty shard slice throws before Pester runs (TS05).
- CR-17: `PoshQC.Testing.psm1` is 479 lines (was 484).

Decision D17 (CR-14 not applied; `if: always()` retained) is recorded in the cycle 2 plan; the reviewer agrees with its reasoning (a skipped required check does not block a merge).

Overall verdict: **REMEDIATION_REQUIRED**. Blocking findings: 3.

- PA-3 (`autonomous`, code review CR-21): the PR-head CI run fails. The cycle 2 TS04 edit changed the size of `PoshQC.TestingShard.Tests.ps1`, and the size-weighted assignment then moved 20 of the 130 shard 1 files (reviewer comparison of the `shard-files.json` manifests of runs 38929655043 and 38935591244). `session-root-reads-850.Constraints.Tests.ps1` moved into shard 1 and its baseline mock interception probe fails there in two consecutive runs, while it passed in shard 2 or 3 before and in the local unsharded run. The suite is not independent of the files that run before it in the same Pester process; the branch's sharding exposes that dependency. This violates the Independence principle of `.claude/rules/general-unit-test.md` and leaves the required check red.
- PA-1 (`awaiting_ci`): `.github/workflows/_poshqc.yml` is modified, and no green CI run exists for the final head. It is resolved by a green run after PA-3 is fixed.
- PA-2 (`awaiting_ci`): AC-08 to AC-12 remain unchecked; plan tasks P8-T19 and P8-T20 depend on the final head's CI artifacts and timings.

## Rejected Scope Narrowing

No scope narrowing was detected. The caller prompt describes the review as "the re-audit for remediation cycle 2" and supplies the base branch, merge base, head, feature folder, PR-context paths, AC source, plan and evidence paths, and orchestrator decision D17. None of these statements removes a file, language, or check from the audit. The audit covers every changed file in `git diff d72ec6a10..HEAD`, including the workflow, all PoshQC module copies, the two shell scripts, the JSON manifest, the Python parity test, and all PowerShell test files.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- Branch-diff scan: `git diff --name-only d72ec6a10..HEAD -- artifacts` returned zero paths. No file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence is under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/{baseline,other,qa-gates,regression-testing,remediation-baseline}/`.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | FAIL | Cycle 2 cases build their inputs per `It`; TS04 to TS06 create a fresh capture table and seam splat; WF03 mutates in-memory copies of the job text. However, the existing suite `session-root-reads-850.Constraints.Tests.ps1` fails in the cycle 2 shard 1 composition (CI runs 38935591244 and 38936152953) and passes in other compositions, so its result depends on which files precede it in the same process (PA-3). |
| Isolation | PASS | Each new case targets one behavior: job condition (WF01), gate content and order (WF02), helper sensitivity (WF03), shard-count source (WF04, WF05), weighted slice (SH10 to SH12), counter omission (CM08), default seam (TS04), empty slice (TS05), size weighting (TS06). |
| Fast execution | PASS | Targeted R2 set: 44 tests (`r2-regression-pass-after.2026-10-16T16-07.md`). |
| Determinism | PASS | Weights are supplied in memory (`-Weight` or a `Length` property on injected objects); ties break by ordinal path order; `Set-Content` is mocked in TS04; no clock, RNG, or network use. |
| Readability | PASS | Token-prefixed titles, Arrange/Act/Assert comments, `-Because` messages that state the reason for each assertion. |

### 1.2 Coverage requirements

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- Python baseline coverage artifact: none exists for this branch; the only changed Python file is the test module `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`; no production Python file changed.
- C# baseline and post-change coverage artifact: N/A - no C# file changed on the branch.
- PowerShell baseline coverage artifact: cycle 2 local baseline FULL_RUN at `136d02fcb` (`evidence/remediation-baseline/r2-poshqc-test-coverage.2026-10-16T15-56.md`): 17091 of 18563 lines, 92.07%, 208 sourcefiles. Branch-level baseline from `main`: CI run 38885440106, 90.45% (`evidence/qa-gates/ci-coverage-comparison.2026-10-16T10-54.md`).
- PowerShell post-change coverage artifact: cycle 2 local final FULL_RUN on the cycle 2 tree (`evidence/qa-gates/r2-final-poshqc-test-coverage.2026-10-16T16-50.md`): 17123 of 18594 lines, 92.09%, 208 sourcefiles. Most recent merged CI artifact: run 38909263798 (head `9f822f1cb`, earlier tree), 16830 of 18302 lines, 91.96%. A merged CI artifact for the cycle 2 tree is produced by run 38936152953, which is in progress.
- Bash coverage artifact: CI `shell-coverage` job of run 38929655043 completed with success; the previous reviewer parse of run 38909263798 `cov.xml` reported 95.2% (3256 of 3421 lines). Cycle 2 changed no shell file.
- Per-language comparison summary: PowerShell repo-wide line coverage is 92.09% on the cycle 2 local artifact against a 92.07% cycle baseline and a 90.45% `main` baseline; the three modules changed in cycle 2 are at 100%, 100%, and 93.6%. Bash is at 95.2% and unchanged by cycle 2. Python has no production change. Every language with changed files is at or above the governing thresholds.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 4 production modules (2 new: `PoshQC.Shard.psm1`, `PoshQC.CoverageMerge.psm1`; 2 modified: `PoshQC.psm1`, `PoshQC.Testing.psm1`) plus byte-identical bundle copies, 2 manifests, 2 runsettings data files, 12 test files | full repository Pester suite | local unsharded 10784 passed, 0 failed (`r2-final-poshqc-test-coverage.2026-10-16T16-50.md`); CI run 38936152953 (HEAD) shard 1: 3443 passed, 1 failed (`session-root-reads-850.Constraints.Tests.ps1:80`, PA-3); shards 2 and 3 passed | 90.45% line (CI run 38885440106, `main`); 92.07% line (cycle 2 local baseline) | 92.09% line (cycle 2 local final, 17123/18594) | 100% of cycle 2 changed executable lines covered (38 of 38: `PoshQC.Shard.psm1` 35, `PoshQC.CoverageMerge.psm1` 2, `PoshQC.Testing.psm1` 1); `PoshQC.Shard.psm1` 100% (82/82), `PoshQC.CoverageMerge.psm1` 100% (72/72), `PoshQC.Testing.psm1` 93.6% (190/203), `PoshQC.psm1` 88.33% (53/60, unchanged in cycle 2) |
| Bash | 2 (`.devcontainer/post-create.sh`, `.github/codex/codex-web-setup.sh`) | 7 `codex_web_setup` bats files | 75 ok, 0 not ok (`final-shell-bats.2026-10-16T13-57.md`); CI `shell-coverage` success in run 38929655043 | N/A - no baseline kcov artifact was retrieved; the changed lines are pwsh heredoc text outside the kcov roots | 95.2% line (CI run 38909263798 `shell-coverage`, 3256/3421) | N/A - the four changed lines are pwsh heredoc content in files outside the kcov include roots (pre-existing, PA-N4) |
| Python | 1 test file (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py`) | parity pytest | 1 passed (reviewer run at HEAD) | N/A - no production Python file changed | N/A - test modules are excluded from measurement by policy | N/A - no production Python line changed |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 92.07% line (cycle 2 local baseline, 17091/18563, 208 sourcefiles); 90.45% line at `main` (CI run 38885440106). Post-change: 92.09% line (cycle 2 local final, 17123/18594, 208 sourcefiles). Change: +0.02 points against the cycle baseline. The denominator change of +31 lines is confined to the three modules changed in cycle 2 (`PoshQC.Shard.psm1` 49 to 82, `PoshQC.CoverageMerge.psm1` 70 to 72, `PoshQC.Testing.psm1` 207 to 203); the executor's key-set comparison reports `KEYSET_EQUAL=True` and `NON_MOD_TOTAL_CHANGES=0`. New/changed-code coverage: 100% (all 38 executable lines added in cycle 2 have `ci > 0`; new modules `PoshQC.Shard.psm1` and `PoshQC.CoverageMerge.psm1` at 100%), and `PoshQC.Testing.psm1:174` (default `WriteShardFileList` seam body) moved from `ci=0` to `ci=1`. Disposition: PASS. Evidence: `evidence/qa-gates/r2-final-coverage-delta.2026-10-16T16-51.md`; the merged CI artifact for this tree is produced by run 38936152953 and is evaluated at S9 (P8-T19).
- Bash: Baseline: no baseline kcov figure was retrieved for this review. Post-change: 95.2% line (3256/3421, CI run 38909263798 `shell-coverage`); the `shell-coverage` job of run 38929655043 also completed with success. Change: not computed; no shell file changed in cycle 2. New/changed-code coverage: the changed lines are PowerShell statements inside a `pwsh -Command -` heredoc in two files outside the kcov include roots (pre-existing population boundary, PA-N4). Disposition: PASS. Evidence: previous reviewer parse of `cov.xml`; `git diff --stat c1dab385e..HEAD` lists no `.sh` file.
- Python: Baseline: none (no production Python file is in the diff). Post-change: none (no production Python file is in the diff). Change: two tuple entries added to `POSHQC_PARITY_PATHS` in a test module before cycle 2; cycle 2 changed no Python file. New/changed-code coverage: no production Python line changed; test modules are outside the coverage denominator per `.claude/rules/general-unit-test.md`. Disposition: PASS (assumption PA-N2). Evidence: parity pytest 1 passed at HEAD; `r2-final-blast-radius.2026-10-16T16-52.md` (`PYTHON_FILES_CHANGED_THIS_CYCLE: NONE`).

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell | PASS | Repo-wide line 92.09% on the cycle 2 local artifact (threshold 85%); new `PoshQC.Shard.psm1` 100% and `PoshQC.CoverageMerge.psm1` 100%; modified `PoshQC.Testing.psm1` 93.6% and `PoshQC.psm1` 88.33%; every cycle 2 changed executable line covered; no regression of a previously covered line. Pester reports no branch figure; no branch threshold applies. |
| Bash | PASS | Repo-wide line 95.2% from the CI `shell-coverage` artifact (threshold 85%). kcov reports no branch figure; no branch threshold applies. |
| Python | PASS | The only changed Python file is a test module; zero production Python lines changed (assumption PA-N2). |
| TypeScript | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

### 1.3 Scenario completeness

| Area | Verdict | Evidence |
|---|---|---|
| Merge job fails when a needed job fails (CR-7) | PASS | WF01 (job-level `if: always()`), WF02 (gate content, `exit 1`, no step-level `if:`, order), WF03 (removed, weakened, non-exiting, and moved gate each detected). CI run 38929655043: failing shard 1 caused the `poshqc` job to fail at the gate step. |
| Merged counters (CR-8) | PASS | CM02 asserts no METHOD counter; CM05 compares LINE and INSTRUCTION; CM08 covers `class`, `method`, and `CLASS` input. CM02 and CM08 failed before the fix. |
| Weighted shard assignment (CR-10) | PASS | SH10 (LPT), SH11 (ordinal tie order), SH12 (length mismatch), TS06 (size from `Length`); all four failed before the fix. |
| Single shard-count source (CR-11) | PASS | WF04 and WF05 failed before the fix and pass after. |
| Default file-list seam (CR-12) | PASS | TS04 with `Set-Content` mocked inside `InModuleScope PoshQC`; line 174 `ci=1`. |
| Empty shard slice (CR-13) | PASS | TS05 asserts the throw, no `Run.Path`, and no manifest write. |
| Shard-composition independence | FAIL | A change in shard composition caused by a test-file size change makes an unrelated existing suite fail in CI (PA-3). No local check reproduces a CI shard's composition before push; the unsharded local run did not detect it. |
| Negative weight input | PARTIAL | `Get-PoshQCShardSlice` help states non-negative weights but the function does not reject a negative value; no caller supplies one (code review CR-18, Info). |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity | PASS | The shard block in `Invoke-PoshQCTest` is one call to `Select-PoshQCShardTestFile`; selection and merge remain pure functions. |
| Reusability | PASS | Weighting, manifest construction, empty-slice check, and manifest write are consolidated in `Select-PoshQCShardTestFile` (`PoshQC.Shard.psm1:234-256`). |
| Separation of concerns / I/O boundaries | PASS | File I/O stays behind the `WriteShardFileList` seam; `Merge-PoshQCCoverageReport` operates on XML text only. |
| Public API compatibility | PASS | `Get-PoshQCShardSlice` and `New-PoshQCShardManifest` gain an optional `-Weight`; without it, files are assigned round-robin in ordinal path order, and SH01, SH03, TS01, TS02 pass unchanged. `Select-PoshQCShardTestFile` is internal (not in `FunctionsToExport`). |
| File size (500 lines) | PASS | Reviewer `wc -l`: `PoshQC.Testing.psm1` 479, `PoshQC.Shard.psm1` 256, `PoshQC.CoverageMerge.psm1` 163, `_poshqc.yml` 186, `.github/codex/codex-web-setup.sh` 331, largest test file `PoshQC.TestingCommands.Tests.ps1` 295. |
| Bundle parity | PASS | Reviewer `cmp`: all seven repo/bundle pairs identical (`PoshQC.Shard.psm1`, `PoshQC.CoverageMerge.psm1`, `PoshQC.Testing.psm1`, `PoshQC.psm1`, `PoshQC.psd1`, `README.md`, `settings/pester.runsettings.psd1`); parity pytest 1 passed. |
| Policy files unchanged | PASS | `git diff --name-only d72ec6a10..HEAD -- .claude/rules .github/instructions .github/workflows/ci.yml` returned zero paths. |
| Workflow `on:` blocks unchanged | PASS | Reviewer grep of the `_poshqc.yml` diff for `on:`, `workflow_call`, `workflow_dispatch`, and the `name:` header: zero matches; `r2-final-scope-ac13.2026-10-16T16-52.md`. |
| No failing coverage threshold added (D3) | PASS | Merge step logs the LINE summary only (`_poshqc.yml:137-138`); `r2-final-d3-ceiling.2026-10-16T16-52.md`. |
| Error handling | PASS | Empty slice, weight-length mismatch, invalid index, and invalid count throw specific messages. |
| Dependencies | PASS | No new dependency. The merge commit `44fb40097` brings `extensions/drm-copilot/package.json` and `package-lock.json` changes from `main` (PR #946); these are not in the branch diff against the merge base. |
| Documentation of public surface | PASS | CHANGELOG `[Unreleased]` and both README copies name the shard parameters, the six exports, the size-based assignment, the empty-shard error, and the merged-report counters (CR-9). |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Format (`Invoke-PoshQCFormat`) | PASS | `r2-final-poshqc-format.2026-10-16T16-34.md`: 0 `Formatted:` lines, porcelain unchanged. |
| PowerShell | Analyze (`Invoke-PoshQCAnalyze`) | PASS | `r2-final-poshqc-analyze.2026-10-16T16-36.md`: no findings. |
| PowerShell | Tests (`Invoke-PoshQCTest`) | PASS | `r2-final-poshqc-test-coverage.2026-10-16T16-50.md`: 10784 tests, 0 failures, 0 errors. |
| PowerShell | Loop closure | PASS | `r2-final-loop-closure.2026-10-16T16-53.md`: loop pass 1 abandoned after TS04 failed in the full run; pass 2 clean, 14 file hashes unchanged, `LOOP_CLEAN_PASS: YES`. |
| Bash | shfmt / shellcheck / bats | PASS | No shell file changed in cycle 2; `final-shell-*.2026-10-16T13-57.md` remain current. |
| Python | black / ruff / pyright | PASS | No Python file changed in cycle 2; `final-python-toolchain.2026-10-16T13-57.md` remains current. |
| GitHub Actions | actionlint | PASS | `r2-final-actionlint.2026-10-16T16-52.md`. |
| GitHub Actions | CI execution of the modified workflow | FAIL | Run 38936152953 (HEAD) and run 38935591244 (`8acac63e7`) failed in shard 1 on `session-root-reads-850.Constraints.Tests.ps1:80` (PA-3); run 38929655043 (`1f208b4e5`) failed on TS04. The result-gate step correctly failed the `poshqc` job in all three runs. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Location mirrors source under `tests/` | PASS | All cycle 2 test edits are under `tests/scripts/powershell/PoshQC/` and `tests/scripts/workflows/`. |
| PowerShell | No temporary files | PASS | Reviewer search of the added lines in the four cycle 2 test files for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `Out-File`, `New-Item`: zero matches. `Set-Content` appears only as a mocked command in TS04. |
| PowerShell | Mocks instead of real file writes | PASS | TS04 mocks `Set-Content` in the PoshQC module scope and asserts the path, encoding, and JSON content. |
| PowerShell | Critical behavior tested | PASS | The result-gate step and the job condition are asserted (WF01 to WF03). |
| PowerShell | Suite passes in CI as configured | FAIL | Shard 1 fails on an order-dependent existing suite in the cycle 2 composition (PA-3). |
| PowerShell | Fail-before / pass-after | PASS | `r2-regression-fail-before.2026-10-16T15-59.md`: exactly the nine FAIL_BEFORE_TOKENS failed; `r2-regression-pass-after.2026-10-16T16-07.md`: 44 tests, 0 failures. WF01 to WF03 and TS04 pass on the pre-fix tree by design; `fail-before-exception.2026-10-16T16-07.md` records the absence-of-test and mutation proofs. |
| Python | Test-only change passes | PASS | Parity pytest 1 passed. |

## 5. Test Coverage Detail

| File | Status | Line Coverage | Changed Executable Lines | Verdict |
|---|---|---|---|---|
| `scripts/powershell/PoshQC/PoshQC.Shard.psm1` | New | 100% (82/82), cycle 2 local final | 35 cycle 2 executable lines, all `ci > 0` | PASS |
| `scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1` | New | 100% (72/72), cycle 2 local final | lines 92-93 `ci > 0` | PASS |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | Modified | 93.6% (190/203); `main` baseline 100% (200/200, breakpoint mode) | line 413 `ci=3`; line 174 now `ci=1` | PASS |
| `scripts/powershell/PoshQC/PoshQC.psm1` | Modified (not in cycle 2) | 88.33% (53/60); `main` baseline 66.67% (40/60) | lines 63, 66, 79 and load-list entries `ci > 0` | PASS |
| `extensions/drm-copilot/resources/powershell/PoshQC/*.psm1` | New/modified bundle copies | outside the coverage population; byte-identical to the measured sources | - | PASS (PA-N3) |
| `.devcontainer/post-create.sh`, `.github/codex/codex-web-setup.sh` | Modified bash | outside kcov roots | PowerShell heredoc lines | PASS (PA-N4) |

## 6. Test Execution Metrics

| Suite | Runner | Result | Source |
|---|---|---|---|
| Full repository Pester suite, unsharded, cycle 2 tree | `Invoke-PoshQCTest` (executor) | 10784 tests, 0 failures, 0 errors; 858 s wall | `r2-final-poshqc-test-coverage.2026-10-16T16-50.md` |
| R2 targeted set, pre-fix | Pester targeted | 44 tests, 9 failures (expected) | `r2-regression-fail-before.2026-10-16T15-59.md` |
| R2 targeted set, post-fix | Pester targeted | 44 tests, 0 failures | `r2-regression-pass-after.2026-10-16T16-07.md` |
| Sharded CI suite, head `1f208b4e5` | CI run 38929655043 | shard 1: 3450 passed, 1 failed (TS04), 2 skipped; shards 2 and 3 success; `poshqc` job failed at the gate step | reviewer `gh run view --log-failed` |
| Sharded CI suite, head `8acac63e7` | CI run 38935591244 | shard 1: 3443 passed, 1 failed (`session-root-reads-850.Constraints.Tests.ps1:80`), 2 skipped; `poshqc` job failed at the gate step | reviewer `gh run view --log-failed` |
| Sharded CI suite, HEAD `44fb40097` | CI run 38936152953 | shard 1: 3443 passed, 1 failed (same test and message), 2 skipped; shards 2 and 3 success; `poshqc` job failed at the gate step | reviewer `gh run watch`, `gh run view --log-failed` |
| Shard 1 composition change | reviewer comparison of `shard-files.json` (runs 38929655043 and 38935591244) | 130 files each; 110 in common; 20 moved in, including `session-root-reads-850.Constraints.Tests.ps1`, `EpicScopeResolution.RunTarget.Tests.ps1`, and `enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` | `gh run download <id> -n poshqc-test-results-shard-1` (session scratchpad) |
| CI shard step timings, size-balanced | CI run 38929655043 | `Test PowerShell` shard 1 374 s, shard 2 283 s, shard 3 396 s | reviewer `gh run view --json jobs` |
| Projected byte balance | executor (P4-T5) | LPT bytes 1727855 / 1727374 / 1727666 (spread 481); round-robin spread 169788 | `evidence/other/r2-shard-balance.2026-10-16T16-08.md` |
| Bundled parity | pytest (reviewer, HEAD) | 1 passed | reviewer run 2026-10-16 |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| `5.6.1` absent at the AC-04 sites and committed-manifest tests | reviewer `grep -c`: 0 at nine paths; the one remaining match (`HostBootstrap.Invoke.Tests.ps1`) is a synthetic manifest, which AC-05 permits |
| Check name `poshqc / PowerShell QC` retained | `_poshqc.yml:75-76` |
| Shard count written once | `_poshqc.yml:46` matrix; `:62` `${{ strategy.job-total }}`; `:129-134` derived from the shard 1 manifest |
| Merge job condition | `_poshqc.yml:79` `if: always()` (D17) |

## 8. Gaps and Exceptions

- PA-3 (Blocking, `autonomous`, code review CR-21): the HEAD CI run 38936152953 fails in shard 1 on `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1:80` (`baseline mock interception probe`: "Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times"). Run 38935591244 on the same PowerShell tree failed identically, so the failure is deterministic for this composition. The branch does not modify that suite. The reviewer compared the shard 1 manifests of runs 38929655043 and 38935591244: the TS04 edit changed one test file's size, the size-weighted assignment moved 20 files into shard 1, and among them are `session-root-reads-850.Constraints.Tests.ps1`, `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1` (imports `EpicScopeResolution.psm1` with `-Force` and mocks `Get-EpicScopeCheckpointText` in that module), and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`. The 850 suite's baseline helper imports `EpicScopeResolution` without `-Force` and registers its mock by module name, so its result appears to depend on which module instance an earlier file in the same process left loaded; the exact predecessor has not been isolated. Rules: `.claude/rules/general-unit-test.md` Independence ("Tests must be able to run in any order without impacting each other"); the required check `poshqc / PowerShell QC` is red. Remediation: reproduce locally with `Invoke-PoshQCTest -ShardIndex 1 -ShardCount 3` on a Windows checkout, isolate the predecessor, and fix the isolation defect so the suite passes regardless of predecessors; then confirm all three shards pass locally before pushing. Do not change shard weights or the matrix length to move the suite elsewhere, because any later test-file size change reshuffles the shards and re-exposes the defect.
- PA-1 (Blocking, `awaiting_ci`): rule `modified-workflow-needs-green-run`. `.github/workflows/_poshqc.yml` is modified, and no green CI run exists for the final head. Runs 38936152953 (HEAD), 38935591244 (`8acac63e7`), and 38929655043 (`1f208b4e5`) all failed in shard 1. After PA-3 is fixed and pushed, the orchestrator's S9 CI green gate records `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.
- PA-2 (Blocking, `awaiting_ci`): AC-08 to AC-12 are unchecked. Plan tasks P8-T19 and P8-T20 (`plan.2026-10-16T00-16.md`) must run against the final head's CI run.
- PA-N1 (Non-blocking, carried forward for AC-08): select the AC-08 baseline at the current merge base `d72ec6a10` rather than reuse run 38885440106, because `main` has changed hook files since that run.
- PA-N2 (Assumption): Python coverage verdict recorded as PASS because the only changed Python file is a test module; no Python coverage artifact could contain a line attributable to this branch.
- PA-N3, PA-N4 (Non-blocking, pre-existing): bundled PoshQC copies are outside the PowerShell coverage roots; `.devcontainer/` and `.github/codex/` are outside the kcov include roots.
- PA-N5 (Non-blocking, carried forward for AC-10): the `poshqc / PowerShell QC` job no longer contains a `Test PowerShell` step; the AC-10 evidence should state that per-shard step timings replace it.
- PA-N6 (Non-blocking observation on goal G1, carried forward): in the single samples available, the unsharded profiler-mode step (1141 s) was not faster than the breakpoint-mode baseline (930 s). The measured reduction comes from sharding. Report to the user.
- PA-N7 (Non-blocking observation): size-based balancing reduced the slowest shard step from 603 s to 396 s in one CI sample (run 38929655043), with a remaining spread of 113 s between shards. File size is a proxy for duration; the authoritative timing is recorded at P8-T19.

## 9. Summary of Changes

- Cycle 2 production changes: `Get-PoshQCShardSlice` longest-processing-time assignment with optional `-Weight`; `New-PoshQCShardManifest` passes `-Weight`; new internal `Select-PoshQCShardTestFile` (size weights, empty-slice throw, manifest write); `Invoke-PoshQCTest` shard block reduced to one call; `Merge-PoshQCCoverageReport` removes `class` elements and non-LINE/INSTRUCTION counters; `_poshqc.yml` derives the shard count from `strategy.job-total` and the shard 1 manifest.
- Cycle 2 tests: WF01 to WF05, SH10 to SH12, CM08, TS04 to TS06; CM02, CM05, SH01 description, and the `-ShardCount` workflow assertion updated.
- Cycle 2 documentation: CHANGELOG `[Unreleased]` sharding entry; README command list and sharded-run section in both copies.
- Earlier rounds: profiler-mode runsettings, Pester 5.9.0 minimum and < 6.0 ceiling, cycle 1 fixes CR-1 to CR-3, sharding phase.

## 10. Compliance Verdict

**REMEDIATION_REQUIRED** - 3 Blocking findings: PA-3 (`autonomous`, shard 1 fails on an order-dependent existing suite), PA-1 (`awaiting_ci`), PA-2 (`awaiting_ci`). Non-blocking: PA-N1 to PA-N7. The previous round's `autonomous` finding (CR-7, untested result-gate step) is resolved; the PA-3 identifier is reused here for the new finding.

## Appendix A: Test Inventory

- `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (217 lines): gate helper `$script:GetResultGateViolation`, WF01 to WF05.
- `tests/scripts/powershell/PoshQC/PoshQC.Shard.Tests.ps1` (172 lines): SH01 to SH12.
- `tests/scripts/powershell/PoshQC/PoshQC.CoverageMerge.Tests.ps1` (189 lines): CM01 to CM08.
- `tests/scripts/powershell/PoshQC/PoshQC.TestingShard.Tests.ps1` (162 lines): TS01 to TS06 and the out-of-range index case.
- Unchanged in cycle 2: `PoshQC.RunSettings.Tests.ps1` (RS01 to RS10), `PoshQC.ModuleCoverage.Tests.ps1` (MC01 to MC05), `PoshQC.TestingCommands.Tests.ps1`, and the other modified test files.

## Appendix B: Toolchain Commands Reference

- `git log --oneline c1dab385e..HEAD`; `git diff --stat c1dab385e..HEAD -- . ':!docs/features'`; `git diff --stat 8acac63e7 HEAD`
- `git diff --stat=200 d72ec6a10..HEAD -- . ':!docs/features'`; `git diff --name-status d72ec6a10..HEAD -- . ':!docs/features'`
- `git diff --name-only d72ec6a10..HEAD -- artifacts .claude/rules .github/instructions .github/workflows/ci.yml` (zero paths)
- `cmp` for seven repo/bundle pairs; `wc -l` on changed modules, tests, workflow, and shell scripts; `grep -c "5\.6\.1"` on the AC-04 and AC-05 paths
- `gh run list --branch bug/pester-profiler-coverage-953 --workflow CI --limit 4 --json databaseId,headSha,status,conclusion`
- `gh run view 38929655043 --json jobs` (job conclusions and shard step seconds); `gh run view 38929655043 --log-failed` (TS04 failure line)
- `gh pr view 959 --json headRefOid,state,mergeable,statusCheckRollup`
- `gh run watch 38936152953 --exit-status`; `gh run view 38936152953 --log-failed`; `gh run view 38935591244 --log-failed`
- `gh run download 38929655043 -n poshqc-test-results-shard-1`; `gh run download 38935591244 -n poshqc-test-results-shard-1`; `poetry run python -I <scratchpad>/cmp_shards.py` (shard 1 `selected` set comparison)
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0)
- `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` (1 passed)

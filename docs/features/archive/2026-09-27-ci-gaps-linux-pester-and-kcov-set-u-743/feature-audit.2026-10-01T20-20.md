# Feature Audit: CI gaps - Linux Pester hook-suite job and kcov set -u trace simulation (#743)

---

**Audit Date:** 2026-10-01
**Feature Folder:** `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743`
**Base Branch:** `main`
**Head Branch:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1 (prior audit `feature-audit.2026-10-01T18-07.md`)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md`

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `41217012d31d35c2ee33a50be50684affd2f5f43`)
- **Head branch/commit:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743` (commit `acb17443e5c7bf3c8a51ffb328fd1780190d612c`)
- **Merge base:** `41217012d31d35c2ee33a50be50684affd2f5f43`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-01 20:17:48 UTC for head `acb17443`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/{baseline,remediation-baseline,regression-testing,qa-gates,other}/`, indexed by `evidence/other/ac-evidence-index.2026-10-01T20-30.md`
  - Additional evidence: direct `gh run view 36918378249` queries (job conclusions and log totals); `git diff 41217012..HEAD`; `git diff 630237f4..HEAD -- tests/`; `cmp` of the two skill copies; this review's scope, skip, temp-file, and line-count checks
- **Feature folder used:** `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743`
- **Requirements source:** `spec.md` (section `## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` declares `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** This audit covers the full branch diff against `main` and all 22 criteria. CI verification ran on `42db4491a6a7af4d0a876bf4022f7153e66f5c88` (run 36918378249). This review ran `git diff --name-only 42db4491..acb17443`, and it lists only documents in this feature folder. The CI evidence therefore applies to every code, test, workflow, and skill file at the branch head. CI-dependent ACs that name "the branch head" are evaluated on that basis, as in the prior audit.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md` - only source (full-bug)

### Acceptance criteria

1. AC-1: `.github/workflows/_poshqc.yml` contains a job `poshqc-linux-hooks` named `PowerShell hook suites (Linux)` with `runs-on: ubuntu-latest` and `permissions: contents: read`.
2. AC-2: The `poshqc-linux-hooks` job runs `Invoke-Pester` with `Run.Path` naming `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` and no other path, `Run.Exit = $true`, and `CodeCoverage.Enabled = $false`.
3. AC-3: The `poshqc-linux-hooks` job uploads its JUnit result under an artifact name other than `poshqc-test-results` (`poshqc-linux-hook-test-results`).
4. AC-4: The existing `poshqc` job is unchanged, and the workflow suite asserts that `poshqc` still uses `windows-latest` and `Invoke-PoshQCTest`.
5. AC-5: `scripts/dev-tools/run-actionlint.ps1` reports no findings for `.github/workflows/_poshqc.yml`.
6. AC-6: The CI check `poshqc / PowerShell hook suites (Linux)` completes with conclusion `success` on the feature branch head, with no failed Pester tests; the run ID is recorded in `<FEATURE>/evidence/qa-gates/`.
7. AC-7: The CI check `poshqc / PowerShell QC` completes with conclusion `success` on the same branch head.
8. AC-8: `epic-child-launch-hardening.Tests.ps1` asserts `windows.sandbox="elevated"` only when `$IsWindows` is true and asserts its absence otherwise (S1).
9. AC-9: `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` no longer depends on a drive-letter root being absolute on non-Windows hosts (S2 to S4), and its premise comment is accurate.
10. AC-10: Every Linux-only failure reported by the first CI run of the Linux job is listed, with its fix, in `<FEATURE>/evidence/qa-gates/`, and each is fixed in the test file concerned without adding an unconditional skip.
11. AC-11: `scripts/bash/kcov_trace_env.sh` exists, sets the kcov PS4 and `set -x`, and passes `shell-qc.sh check`.
12. AC-12: `run_test` invokes bats with `BASH_ENV` set to `kcov_trace_env.sh` and `BASH_XTRACEFD` on a `/dev/null` descriptor; `run_test_coverage` is unchanged.
13. AC-13: The bats test "test fails when a bats child sources a nounset library inside bash -c" passes, and it fails against the pre-change `run_test`.
14. AC-14: The bats test "test passes when a bats child resets nounset after sourcing" passes with no `kcov@` lines in output.
15. AC-15: Existing skip-marker and exit-code tests pass, and the full `shell-qc.sh test` run passes with the simulation active.
16. AC-16: `_shell-coverage.yml` is unchanged, and its CI run on the branch head succeeds with bash line coverage >= 85% and the changed lines covered.
17. AC-17: The Wrap-Tolerant section of `.claude/skills/atomic-plan-contract/SKILL.md` contains the runner/job guidance bullet.
18. AC-18: The same section contains the `grep -F` backslash guidance bullet with the three alternatives.
19. AC-19: The bundle mirror of `atomic-plan-contract/SKILL.md` is byte-identical.
20. AC-20: No file owned by concurrent items or read-only policy is modified.
21. AC-21: The full toolchain passes in a single pass for touched languages, including actionlint, with evidence under `<FEATURE>/evidence/qa-gates/`.
22. AC-22: No new or modified file exceeds 500 lines, and no test creates temporary files.

(The full criterion text is in `spec.md` lines 234-255.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Linux job, name, runner, permissions | PASS | `_poshqc.yml` job `poshqc-linux-hooks`. `PoshQcWorkflow.Tests.ps1` suite `tests=7 failures=0` on Windows (`qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md`). | `gh run view 36918378249 --json jobs` | Workflow unchanged since the prior PASS |
| 2 | AC-2 Invoke-Pester, Run.Path two folders only, Run.Exit, coverage off | PASS | Workflow-suite It "limits ... Run.Path to the two hook-suite folders" passes. The Linux JUnit contains only suites under the two folders (135 suites). | as AC-1 | - |
| 3 | AC-3 distinct artifact name | PASS | `poshqc-linux-hook-test-results` downloaded from run 36918378249 (`qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md`) | `gh run download 36918378249 -n poshqc-linux-hook-test-results` (executor) | - |
| 4 | AC-4 existing poshqc job unchanged | PASS | One hunk `@@ -52,0 +53,38 @@` with no removed lines (this review). The It "keeps the poshqc job on windows-latest running Invoke-PoshQCTest" passes. | `git diff -U0 41217012..HEAD -- .github/workflows/_poshqc.yml` | Verified directly |
| 5 | AC-5 run-actionlint.ps1 no findings | PARTIAL | Direct `actionlint .github/workflows/_poshqc.yml` exit 0, no output (`qa-gates/qc-actionlint-direct.2026-10-01T19-58.md` and three earlier runs). The wrapper run is recorded as operator-run (`other/operator-run-items.2026-10-01T20-27.md`). | operator-run: `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` | The criterion names the wrapper, and no wrapper output is recorded. Agents may not run pwsh (operator decision 2026-10-01). |
| 6 | AC-6 Linux check success on branch head | PASS | Job 110557965901 `success`. Log `Tests Passed: 3412, Failed: 0, Skipped: 0` (read by this review). JUnit `tests=3412 failures=0 errors=0`. Run ID recorded in `qa-gates/ac-6-run-record.2026-10-01T20-28.md`. | `gh run view 36918378249 --json headSha,conclusion,jobs`; `gh run view 36918378249 --log --job 110557965901 \| grep -F 'Tests Passed:'` | Head `42db4491`; later commits are docs-only (verified) |
| 7 | AC-7 Windows check success on same head | PASS | Job 110557965705 `success`. Log `Tests Passed: 6091, Failed: 0, Skipped: 10` (read by this review). | `gh run view 36918378249 --log --job 110557965705 \| grep -F 'Tests Passed:'` | The modified Codex and Claude hook suites pass on Windows |
| 8 | AC-8 S1 elevated sandbox only on Windows | PASS | `epic-child-launch-hardening.Tests.ps1` suite `tests=19 failures=0` on both Windows and Linux in run 36918378249 | `qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md`; `qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md` | - |
| 9 | AC-9 decision surface no drive-letter dependency; premise comment | PASS | Suite `tests=20 failures=0` on both runners in run 36918378249 | as AC-8 | Unchanged since the prior PASS |
| 10 | AC-10 every first-run Linux failure listed and fixed without unconditional skip | PASS | `qa-gates/linux-first-run-failures.2026-10-01T20-26.md`: 21 rows, each with a named fix and status PASSING on run 36918378249. Fail-before: `regression-testing/linux-baseline-junit.2026-10-01T19-01.md`. This review counted added `-Skip` and `Set-ItResult` lines: 0. | `git diff -U0 41217012..HEAD -- tests/scripts/codex-hooks/ tests/scripts/claude-hooks/ \| grep -c -E '^\+.*(-Skip([[:space:]]\|$\|:\$true)\|Set-ItResult)'` | Further-failure set empty (`qa-gates/ci-remediation-further-failures.2026-10-01T20-24.md`) |
| 11 | AC-11 kcov_trace_env.sh content and check | PASS | `scripts/bash/kcov_trace_env.sh:8-9`; `shell-qc.sh check` exit 0 (`qa-gates/qc-bash-check.2026-10-01T19-25.md`) | `sh scripts/bash/shell-qc.sh check` | - |
| 12 | AC-12 run_test sets BASH_ENV and BASH_XTRACEFD; run_test_coverage unchanged | PASS | Code inspection of `shell_qc_lib.sh` (prior review). No Bash file changed after `630237f4`. | `git diff 41217012..HEAD -- scripts/bash/shell_qc_lib.sh` | - |
| 13 | AC-13 nounset failure test passes; expect-fail before change | PASS | Fail-before exit 1, pass-after exit 0. Full local run 501 ok (`qa-gates/qc-shell-qc-test-full.2026-10-01T19-57.md`). | `regression-testing/fail-before-bats.2026-10-01T16-32.md`; `regression-testing/pass-after-bats.2026-10-01T16-34.md` | - |
| 14 | AC-14 reset test passes, no kcov@ in output | PASS | Negative control shows the assertion can fail. Full run passes. | `regression-testing/trace-discard-negative-control.2026-10-01T16-35.md` | - |
| 15 | AC-15 existing tests pass; full shell-qc.sh test passes with simulation | PASS | `SHELL_QC_BATS_BIN=<npm-cache>/.../bats sh scripts/bash/shell-qc.sh test`: exit 0, TAP `1..501`, 0 `not ok` | `qa-gates/qc-shell-qc-test-full.2026-10-01T19-57.md`; `qa-gates/qc-shell-qc-test-not-ok.2026-10-01T19-57.md` | Prior Minor resolved: the command line is now recorded |
| 16 | AC-16 _shell-coverage.yml unchanged; CI success, >= 85%, changed lines covered | PASS | Job 110557965675 `success`. Log `Bash coverage (lines): 93.7%` (read by this review). Changed lines 8 of 8 hit (`qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md`; Bash files unchanged since). | `gh run view 36918378249 --log --job 110557965675 \| grep -E 'Bash coverage \(lines\): [0-9]'` | `_shell-coverage.yml` absent from the branch name list |
| 17 | AC-17 runner/job guidance bullet | PASS | Bullet present in the Wrap-Tolerant section (`qa-gates/skill-guidance.2026-10-01T17-13.md`) | `git diff 41217012..HEAD -- .claude/skills/atomic-plan-contract/SKILL.md` | - |
| 18 | AC-18 backslash grep -F guidance bullet | PASS | Bullet names Git for Windows grep 3.0 and the three alternatives | as AC-17 | - |
| 19 | AC-19 bundle mirror byte-identical | PASS | `cmp` reports identical (this review); pytest parity passed (`qa-gates/qc-pytest-claude-resource-contracts.2026-10-01T19-58.md`) | `cmp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | - |
| 20 | AC-20 no concurrent-owner or policy file modified | PASS | Scope grep count 0, rerun by this review against `41217012..HEAD` | `git diff --name-only 41217012..HEAD \| grep -c -E '^(\.github/workflows/(_quality-checks\|_drm-copilot-extension-tests\|ci\|_shell-coverage)\.yml\|scripts/powershell/PoshQC/settings/pester\.runsettings\.psd1\|\.claude/rules/\|\.github/instructions/)'` | - |
| 21 | AC-21 full toolchain single pass | PARTIAL | Loop pass 1 after remediation (`qa-gates/qc-loop-pass.2026-10-01T20-00.md`): PoshQC format and analyze clean, Pester green (Windows 96.31% lines in CI), `shell-qc.sh` format/check/test clean, pytest parity green, direct actionlint clean. The `run-actionlint.ps1` step is operator-run. | `qa-gates/qc-loop-pass.2026-10-01T20-00.md`; `other/operator-run-items.2026-10-01T20-27.md` | No workflow file changed in cycle 1, so one operator run closes both AC-5 and this item |
| 22 | AC-22 <= 500 lines; no temp files | PASS | Largest changed code file 495 lines (`epic-child-worktree-launcher.Tests.ps1`). Temp-file pattern count 0 (this review). | `wc -l` per changed file; `git diff -U0 41217012..HEAD -- tests/ \| grep -c -E 'mktemp\|TMPDIR\|New-TemporaryFile\|GetTempFileName\|GetTempPath\|TestDrive'` | - |

---

## Summary

**Overall Feature Readiness:** READY AFTER OPERATOR ACTION. All code, test, CI, and coverage criteria pass. The operator-run actionlint wrapper record is outstanding.

**Criteria summary:**
- **PASS:** 20 criteria
- **PARTIAL:** 2 criteria (AC-5, AC-21)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-5 and AC-21: `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` has not been run or recorded. Direct `actionlint` is clean, and no workflow file changed in remediation cycle 1.

**Recommended follow-up verification steps:**

1. Operator: run the wrapper command above from the item worktree root, then record the command, exit code, and output in a new timestamped file under `evidence/qa-gates/`.
2. If exit 0 with no findings, check off AC-5 and AC-21 in `spec.md`. A full re-review is not needed for that change alone, because it adds no code.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 20 PASS criteria (AC-1 to AC-4, AC-6 to AC-20, AC-22) were already checked in `spec.md`. The executor checked AC-6 and AC-10 in commit `7353118d`, and this review's evaluation agrees with each. No checkbox was changed in this review. AC-5 and AC-21 are unchecked and remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md`
- Total AC items: 22
- Checked off (delivered): 20
- Remaining (unchecked): 2
- Items remaining:
  - AC-5: `scripts/dev-tools/run-actionlint.ps1` reports no findings for `.github/workflows/_poshqc.yml`.
  - AC-21: The full toolchain passes in a single pass for touched languages: PoshQC format and analyze clean, Pester (Windows) green with PowerShell line coverage >= 85%, `shell-qc.sh format`/`check`/`test` clean, actionlint clean, and the pytest parity test green. Evidence is recorded under `<FEATURE>/evidence/qa-gates/`.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md` | 22 | 20 | 2 | Checkbox-backed; no change made by this review |

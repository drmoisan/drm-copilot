# Feature Audit: CI gaps - Linux Pester hook-suite job and kcov set -u trace simulation (#743)

---

**Audit Date:** 2026-10-01
**Feature Folder:** `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743`
**Base Branch:** `main`
**Head Branch:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md`

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `41217012d31d35c2ee33a50be50684affd2f5f43`)
- **Head branch/commit:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743` (commit `630237f4bf081ed117253e44a7f3d3780bb19368`)
- **Merge base:** `41217012d31d35c2ee33a50be50684affd2f5f43`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-01 18:03:14 UTC for head `630237f4`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/{baseline,regression-testing,qa-gates,other}/`
  - Additional evidence: direct inspection of `git diff 41217012..HEAD`; `artifacts/pester/powershell-coverage.xml`; `cmp` of the two `atomic-plan-contract/SKILL.md` copies; the scope-path grep run by this review
- **Feature folder used:** `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743`
- **Requirements source:** `spec.md` (section `## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` line 12 reads `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** The audit covers the full branch diff against `main`. CI verification was performed on `ecba8829604f6265dc491c74cf42546f9d5aab57` (run 36901896617). `git diff --name-only ecba8829..630237f4` lists only documents in this feature folder, so the CI evidence applies to every code, test, workflow, and skill file at the branch head. CI-dependent ACs that name "the branch head" are evaluated on that basis. The plan's statement that the remaining Linux failures are "outside this plan's file list" is not accepted as a scope limit, because `spec.md` puts every reported Linux-only failure in scope (see `policy-audit.2026-10-01T18-07.md`, Rejected Scope Narrowing).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md` - only source (full-bug)

### Acceptance criteria

1. AC-1: `.github/workflows/_poshqc.yml` contains a job `poshqc-linux-hooks` named `PowerShell hook suites (Linux)` with `runs-on: ubuntu-latest` and `permissions: contents: read`. Verified by `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`.
2. AC-2: The `poshqc-linux-hooks` job runs `Invoke-Pester` with `Run.Path` naming `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` and no other path, `Run.Exit = $true`, and `CodeCoverage.Enabled = $false`. Verified by `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`.
3. AC-3: The `poshqc-linux-hooks` job uploads its JUnit result under an artifact name other than `poshqc-test-results` (`poshqc-linux-hook-test-results`). Verified by `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`.
4. AC-4: The existing `poshqc` job is unchanged: `git diff origin/main -- .github/workflows/_poshqc.yml` shows only added lines outside the `poshqc` job, and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` asserts that `poshqc` still uses `windows-latest` and `Invoke-PoshQCTest`.
5. AC-5: `scripts/dev-tools/run-actionlint.ps1` reports no findings for `.github/workflows/_poshqc.yml`.
6. AC-6: The CI check `poshqc / PowerShell hook suites (Linux)` completes with conclusion `success` on the feature branch head, with no failed Pester tests; the run ID is recorded in `<FEATURE>/evidence/qa-gates/`. Verified by `gh run view <run-id>`.
7. AC-7: The CI check `poshqc / PowerShell QC` completes with conclusion `success` on the same branch head, showing the modified Codex hook tests still pass on Windows. Verified by `gh run view <run-id>`.
8. AC-8: `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` asserts `windows.sandbox="elevated"` only when `$IsWindows` is true and asserts its absence otherwise (S1). Verified by the Windows and Linux CI runs in AC-6 and AC-7.
9. AC-9: `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` no longer depends on a drive-letter root being absolute on non-Windows hosts (S2 to S4), and its premise comment at the former `:45` states the OS-specific behavior accurately. Verified by the CI runs in AC-6 and AC-7.
10. AC-10: Every Linux-only failure reported by the first CI run of `poshqc / PowerShell hook suites (Linux)` on this feature's PR is listed, with its fix, in `<FEATURE>/evidence/qa-gates/`, and each is fixed in the test file concerned without adding an unconditional skip. Verified by the evidence file and AC-6.
11. AC-11: `scripts/bash/kcov_trace_env.sh` exists, sets `PS4='kcov@${BASH_SOURCE}@${LINENO}@'` and `set -x`, and passes `bash scripts/bash/shell-qc.sh check`. Verified by the bats test "kcov_trace_env.sh sets the kcov PS4 format" and the check command.
12. AC-12: `run_test` in `scripts/bash/shell_qc_lib.sh` invokes bats with `BASH_ENV` set to `scripts/bash/kcov_trace_env.sh` and `BASH_XTRACEFD` set to a descriptor opened on `/dev/null`; `run_test_coverage` is unchanged. Verified by code review of the diff and by AC-13 and AC-14.
13. AC-13: The bats test "test fails when a bats child sources a nounset library inside bash -c" in `tests/shell/test_shell_qc_commands.bats` passes: `shell-qc.sh test` with the `tests/fixtures/shell_qc/stub-bin/bats-nounset-source` stub exits non-zero and its output contains `BASH_SOURCE`. The same test fails (expect-fail) against the pre-change `run_test`.
14. AC-14: The bats test "test passes when a bats child resets nounset after sourcing" in `tests/shell/test_shell_qc_commands.bats` passes: `shell-qc.sh test` with the `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset` stub exits 0 and its output contains no `kcov@` trace lines.
15. AC-15: The existing skip-marker and exit-code tests in `tests/shell/test_shell_qc_commands.bats` still pass, and the full `bash scripts/bash/shell-qc.sh test` run (WSL or CI) passes with the simulation active, showing no existing bats test regresses.
16. AC-16: `.github/workflows/_shell-coverage.yml` is unchanged (`git diff origin/main -- .github/workflows/_shell-coverage.yml` is empty), and its CI run on the branch head succeeds with bash line coverage >= 85% and changed lines in `scripts/bash/shell_qc_lib.sh` and `scripts/bash/kcov_trace_env.sh` covered.
17. AC-17: The "Wrap-Tolerant Assertion Authoring (Mandatory)" section of `.claude/skills/atomic-plan-contract/SKILL.md` contains a bullet stating that Pester acceptance criteria may cite `ubuntu-latest` only for suites under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks`, never for coverage, and must name the job (`poshqc / PowerShell QC` or `poshqc / PowerShell hook suites (Linux)`).
18. AC-18: The same section contains a bullet stating that plan checks must not assert a `grep -F` literal containing a backslash, because Git for Windows grep 3.0 reads a doubled backslash in a fixed-string pattern as one backslash, and naming the alternatives (backslash-free substring, named test, or hash/byte-identity check).
19. AC-19: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` is byte-identical to `.claude/skills/atomic-plan-contract/SKILL.md`. Verified by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
20. AC-20: No file owned by concurrent items or read-only policy is modified: `git diff --name-only origin/main` lists none of `.github/workflows/_quality-checks.yml`, `.github/workflows/_drm-copilot-extension-tests.yml`, `.github/workflows/ci.yml`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, or any path under `.claude/rules/` or `.github/instructions/`.
21. AC-21: The full toolchain passes in a single pass for touched languages: PoshQC format and analyze clean, Pester (Windows) green with PowerShell line coverage >= 85%, `shell-qc.sh format`/`check`/`test` clean, actionlint clean, and the pytest parity test green. Evidence is recorded under `<FEATURE>/evidence/qa-gates/`.
22. AC-22: No new or modified file exceeds 500 lines, and no test creates temporary files. Verified by a line count of each changed file and code review of the new tests.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Linux job, name, runner, permissions | PASS | `_poshqc.yml:54-58`; It blocks "runs the poshqc-linux-hooks job on ubuntu-latest under its check name" and "grants ... read-only repository contents" pass (CI Windows `PoshQcWorkflow.Tests.ps1 tests=7 failures=0`) | `gh run view 36901896617 --log --job 110502826187`; diff inspection | Fail-before evidence: `regression-testing/fail-before-poshqc-workflow.2026-10-01T16-45.md` |
| 2 | AC-2 Invoke-Pester, Run.Path two folders only, Run.Exit, coverage off | PASS | `_poshqc.yml:76-78,82`; It "limits ... Run.Path to the two hook-suite folders" asserts exactly one assignment and exactly `tests/scripts/claude-hooks,tests/scripts/codex-hooks` | as AC-1 | - |
| 3 | AC-3 distinct artifact name | PASS | `_poshqc.yml:88` `name: poshqc-linux-hook-test-results`; It "uploads ... under a distinct artifact name" asserts presence and `-Not -Match poshqc-test-results` | as AC-1 | The artifact was downloaded successfully in `qa-gates/ci-final-linux.2026-10-01T17-57.md` |
| 4 | AC-4 existing poshqc job unchanged | PASS | One hunk `@@ -50,3 +50,41 @@`, additions only, starting after the last line of the `poshqc` job; It "keeps the poshqc job on windows-latest running Invoke-PoshQCTest" passes | `git diff 41217012..HEAD -- .github/workflows/_poshqc.yml` | Verified directly by this review |
| 5 | AC-5 run-actionlint.ps1 no findings | PARTIAL | Direct `actionlint .github/workflows/_poshqc.yml` (1.7.11) exit 0, no output: `baseline/actionlint-poshqc.2026-10-01T16-13.md`, `regression-testing/actionlint-poshqc.2026-10-01T16-37.md`, `qa-gates/qc-actionlint.2026-10-01T17-23.md` | operator-pending: `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` | The wrapper resolves `actionlint` from PATH and passes its arguments through (`run-actionlint.ps1:143,159`), so the direct run is equivalent in practice. The criterion names the wrapper, which has not been run (B1-B3). |
| 6 | AC-6 Linux check success on branch head | FAIL | Job `poshqc / PowerShell hook suites (Linux)` (110502826491) conclusion `failure`; `Tests Passed: 3400, Failed: 12`; JUnit `failures=12` | `gh run view 36901896617 --json jobs,headSha`; `gh run view 36901896617 --log --job 110502826491 \| grep -F 'Tests Passed:'` | The 12 failures are in 5 hook-suite files not edited by this branch (`DriveNotFoundException` on drive `C`). The spec puts them in scope. |
| 7 | AC-7 Windows check success on same head | PASS | Job `poshqc / PowerShell QC` (110502826187) `success`; `Tests Passed: 6091, Failed: 0, Skipped: 10`; three modified Codex suites `failures=0` | `gh run view 36901896617 --log --job 110502826187 \| grep -F 'Tests Passed:'` | Run head `ecba8829`; the later commit `630237f4` changes documents only |
| 8 | AC-8 S1 elevated sandbox only on Windows | PASS | `epic-child-launch-hardening.Tests.ps1:245,346` `($arguments -contains 'windows.sandbox="elevated"') \| Should -Be $IsWindows`; suite `tests=19 failures=0` on both Windows and Linux | `qa-gates/ci-final-windows.2026-10-01T17-57.md`; `qa-gates/ci-final-linux.2026-10-01T17-57.md` | One assertion covers the presence (Windows) and absence (non-Windows) cases. The same form is applied in `epic-child-worktree-launcher.Tests.ps1:315`. |
| 9 | AC-9 decision surface no drive-letter dependency; premise comment | PASS | `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1:43-51` OS-derived roots and corrected comment; all `C:/repo` literals replaced; suite `tests=20 failures=0` on both runners | as AC-8; diff inspection | - |
| 10 | AC-10 every first-run Linux failure listed and fixed without unconditional skip | PARTIAL | Inventory of 21 rows (`qa-gates/linux-first-run-failures.2026-10-01T17-57.md`): rows 13-21 fixed and passing; rows 1-12 listed with fix `none` and status REMEDIATION-REQUIRED. No `-Skip` added (`qa-gates/no-unconditional-skip.2026-10-01T17-57.md`, count 0) | `git diff -U0 41217012 -- tests/scripts/codex-hooks/ tests/scripts/claude-hooks/ \| grep -c -E '^\+.*-Skip([[:space:]]\|$\|:\$true)'` | The listing and no-skip clauses are met. The "each is fixed" clause is unmet for 12 of 21 failures. |
| 11 | AC-11 kcov_trace_env.sh content and check | PASS | `scripts/bash/kcov_trace_env.sh:8-9`; bats `ok 488 kcov_trace_env.sh sets the kcov PS4 format` (CI); `sh scripts/bash/shell-qc.sh check` exit 0 | `qa-gates/qc-bash-check.2026-10-01T17-23.md`; `qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md` | - |
| 12 | AC-12 run_test sets BASH_ENV and BASH_XTRACEFD; run_test_coverage unchanged | PASS | `shell_qc_lib.sh:253-267`: `trace_env="$lib_dir/kcov_trace_env.sh"`, `exec {trace_fd}>/dev/null`, `BASH_ENV="$trace_env" BASH_XTRACEFD="$trace_fd" "$bats_bin"`. All five diff hunks are inside `run_test` (last changed line 267); `run_test_coverage` (from line 309) is not in the diff | `git diff 41217012..HEAD -- scripts/bash/shell_qc_lib.sh` | Verified by this review's code inspection |
| 13 | AC-13 nounset failure test passes; expect-fail before change | PASS | CI `ok 486`; local pass-after exit 0; fail-before exit 1 against pre-change `run_test` | `regression-testing/fail-before-bats.2026-10-01T16-32.md`; `regression-testing/pass-after-bats.2026-10-01T16-34.md` | - |
| 14 | AC-14 reset test passes, no kcov@ in output | PASS | CI `ok 487`; negative control shows the assertion fails when the discard is removed | `regression-testing/trace-discard-negative-control.2026-10-01T16-35.md`; `regression-testing/trace-discard-restored.2026-10-01T16-35.md` | - |
| 15 | AC-15 existing tests pass; full shell-qc.sh test passes with simulation | PASS | Local full run: TAP `1..501`, 501 ok, 0 not ok, `SIMULATION-EXPOSED: none`; targeted bats 35 ok | `qa-gates/qc-shell-qc-test-full.2026-10-01T17-45.md`; `qa-gates/qc-bats-shell-qc.2026-10-01T17-23.md` | The run used an uncommitted scratchpad wrapper through the `SHELL_QC_BATS_BIN` seam (code review, Minor). CI `shell-coverage` uses `run_test_coverage`, not the simulation. |
| 16 | AC-16 _shell-coverage.yml unchanged; CI success, >= 85%, changed lines covered | PASS | `git diff --exit-code` exit 0; job 110502826537 `success`; `Bash coverage (lines): 93.7%`; changed instrumented lines 8 of 8 `hits=1` | `qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md` | - |
| 17 | AC-17 runner/job guidance bullet | PASS | `.claude/skills/atomic-plan-contract/SKILL.md` bullet "Name the runner and job for a Pester acceptance criterion." contains every required element | `git diff 41217012..HEAD -- .claude/skills/atomic-plan-contract/SKILL.md` | The bullet is in the Wrap-Tolerant section, directly before `## Plan-Path Continuity Contract` |
| 18 | AC-18 backslash grep -F guidance bullet | PASS | Bullet "Do not assert a fixed-string search literal that contains a backslash." names Git for Windows grep 3.0, the doubled-backslash behavior, and all three alternatives | as AC-17 | - |
| 19 | AC-19 bundle mirror byte-identical | PASS | `cmp` exit 0 (this review); pytest parity 14 passed | `cmp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | - |
| 20 | AC-20 no concurrent-owner or policy file modified | PASS | Scope grep count 0 (exit 1), rerun by this review against `41217012..HEAD` | `git diff --name-only 41217012..HEAD \| grep -c -E '^(\.github/workflows/(_quality-checks\|_drm-copilot-extension-tests\|ci\|_shell-coverage)\.yml\|scripts/powershell/PoshQC/settings/pester\.runsettings\.psd1\|\.claude/rules/\|\.github/instructions/)'` | - |
| 21 | AC-21 full toolchain single pass | PARTIAL | Loop pass 1: format, analyze, Windows Pester (96.31% lines), shfmt, shellcheck, bats, and pytest parity all clean. The actionlint step through `run-actionlint.ps1` is operator-pending (B3) | `qa-gates/qc-loop-pass.2026-10-01T17-23.md`; `qa-gates/qc-ps-pester-full.2026-10-01T17-57.md` | It will also need re-running after the AC-6 remediation edits |
| 22 | AC-22 <= 500 lines; no temp files | PASS | Max 495 lines (`epic-child-worktree-launcher.Tests.ps1`); temp-file pattern count 0 | `wc -l` (this review); `qa-gates/no-temp-files.2026-10-01T17-25.md` | - |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 18 criteria
- **PARTIAL:** 3 criteria (AC-5, AC-10, AC-21)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (AC-6)

**Top gaps preventing PASS:**

1. AC-6 / AC-10: 12 Linux-only failures in `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` (8), `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`, `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`, and `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` (1 each). All come from drive-letter `C:/` literals.
2. The `modified-workflow-needs-green-run` rule: no green `_poshqc.yml` run on the branch head. This resolves with gap 1.
3. AC-5 / AC-21: the operator-run `scripts/dev-tools/run-actionlint.ps1` step.

**Recommended follow-up verification steps:**

1. After the fixes, run `gh run view <run-id> --json jobs,headSha` on a new `_poshqc.yml` or `ci.yml` run. Confirm `headSha` equals the branch head and both `poshqc` jobs are `success`. Then read `Tests Passed:` from the Linux job log and confirm `Failed: 0`.
2. Re-run the Windows Pester coverage check and confirm PowerShell line coverage remains >= 85%. Record the `run-actionlint.ps1` output under `evidence/qa-gates/`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 18 PASS criteria (AC-1 to AC-4, AC-7 to AC-9, AC-11 to AC-20, AC-22) were already checked in `spec.md` by the executor, and this review's evaluation agrees with each. No checkbox was changed in this review. AC-5, AC-6, AC-10, and AC-21 are unchecked in `spec.md` and remain unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md`
- Total AC items: 22
- Checked off (delivered): 18
- Remaining (unchecked): 4
- Items remaining:
  - AC-5: `scripts/dev-tools/run-actionlint.ps1` reports no findings for `.github/workflows/_poshqc.yml`.
  - AC-6: The CI check `poshqc / PowerShell hook suites (Linux)` completes with conclusion `success` on the feature branch head, with no failed Pester tests; the run ID is recorded in `<FEATURE>/evidence/qa-gates/`. Verified by `gh run view <run-id>`.
  - AC-10: Every Linux-only failure reported by the first CI run of `poshqc / PowerShell hook suites (Linux)` on this feature's PR is listed, with its fix, in `<FEATURE>/evidence/qa-gates/`, and each is fixed in the test file concerned without adding an unconditional skip. Verified by the evidence file and AC-6.
  - AC-21: The full toolchain passes in a single pass for touched languages: PoshQC format and analyze clean, Pester (Windows) green with PowerShell line coverage >= 85%, `shell-qc.sh format`/`check`/`test` clean, actionlint clean, and the pytest parity test green. Evidence is recorded under `<FEATURE>/evidence/qa-gates/`.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md` | 22 | 18 | 4 | Checkbox-backed; no change made by this review |

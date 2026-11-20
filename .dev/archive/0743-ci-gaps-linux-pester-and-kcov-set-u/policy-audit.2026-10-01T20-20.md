# Policy Compliance Audit: CI gaps - Linux Pester hook-suite job and kcov set -u trace simulation (#743)

---

**Audit Date:** 2026-10-01
**Audit Type:** Re-audit after remediation cycle 1 (prior audit `policy-audit.2026-10-01T18-07.md`; remediation plan `remediation-plan.2026-10-01T18-07.md`)
**Branch:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743` @ `acb17443e5c7bf3c8a51ffb328fd1780190d612c`
**Base:** `main` (resolved `origin/main` @ `41217012d31d35c2ee33a50be50684affd2f5f43`; merge base `41217012d31d35c2ee33a50be50684affd2f5f43`)
**CI verification SHA:** `42db4491a6a7af4d0a876bf4022f7153e66f5c88` (CI run 36918378249). This review ran `git diff --name-only 42db4491..acb17443`, and every listed path is under `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/`. The CI run therefore covers every code, test, workflow, and skill file at the branch head.
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`. The MCP template tool is not in this agent's tool list, so the bundled file was read directly.

**Code Under Test (full branch diff, excluding feature-folder documentation; 18 files, +272/-35):**
- `.github/workflows/_poshqc.yml` (MODIFIED, +38)
- `scripts/bash/kcov_trace_env.sh` (NEW, 9 lines)
- `scripts/bash/shell_qc_lib.sh` (MODIFIED, +17/-2)
- `tests/shell/test_shell_qc_commands.bats` (MODIFIED, +34)
- `tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh` (NEW)
- `tests/fixtures/shell_qc/stub-bin/bats-nounset-source` (NEW)
- `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset` (NEW)
- `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (NEW, 95 lines)
- `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` (MODIFIED)
- `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` (MODIFIED)
- `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` (MODIFIED)
- `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` (MODIFIED in remediation cycle 1, +8/-6)
- `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` (MODIFIED in remediation cycle 1, +2/-1)
- `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` (MODIFIED in remediation cycle 1, +2/-1)
- `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` (MODIFIED in remediation cycle 1, +2/-1)
- `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` (MODIFIED in remediation cycle 1, +2/-1)
- `.claude/skills/atomic-plan-contract/SKILL.md` (MODIFIED, +2)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` (MODIFIED, +2, byte-identical mirror)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 files (test files only; 0 production files) | 7 new It blocks; 8 modified suites | ✅ Windows 6091 pass, 0 fail, 10 skipped; ✅ Linux 3412 pass, 0 fail | 96.31% lines (CI run 36890793420) | 96.31% lines (CI run 36918378249); 96.25% lines (local `artifacts/pester/powershell-coverage.xml`) | N/A - no production PowerShell file added or modified |
| Bash | 2 production files (+1 bats file, 3 fixtures) | 3 new bats tests | ✅ 501 ok, 0 not ok (local, simulation active); ✅ CI kcov job success | 93.4% lines (CI run 36890790108) | 93.7% lines (CI run 36918378249) | 100.0% of instrumented changed lines (8 of 8 hit) |
| Python | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| C# | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: CI run 36890793420 `poshqc-test-results` artifact `powershell-coverage.xml`, recorded in `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/baseline/ps-coverage.2026-10-01T16-28.md`
- PowerShell post-change coverage artifact: CI run 36918378249 `powershell-coverage.xml` (LINE covered 11236, missed 430), recorded in `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md`; local `artifacts/pester/powershell-coverage.xml` (LINE covered 10688, missed 416)
- Per-language comparison summary: Section 1.2.1 of this audit and `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/qa-gates/coverage-comparison.2026-10-01T20-27.md`

---

## Executive Summary

This re-audit covers the full branch diff of `bug/ci-gaps-linux-pester-and-kcov-set-u-743` against `main`. Since the prior audit, the branch made the remaining five hook-suite test files portable to Linux. Each now chooses its synthetic root from `$IsWindows` (`C:/...` on Windows, `/...` elsewhere). The branch also re-ran the local QC loop and obtained a fully green CI run (36918378249, all 17 jobs `success`) on `42db4491`.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (uniform coverage thresholds)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (test files only)
- ✅ Bash: shfmt + shellcheck + bats
- ✅ GitHub Actions: `.github/instructions/github-actions.instructions.md` and the `modified-workflow-needs-green-run` rule

Prior findings R1 to R3 are resolved. This review verified directly with `gh run view 36918378249` that `poshqc / PowerShell hook suites (Linux)` reports `Tests Passed: 3412, Failed: 0`, `poshqc / PowerShell QC` reports `Tests Passed: 6091, Failed: 0, Skipped: 10`, and `shell-coverage` reports `Bash coverage (lines): 93.7%`. All three jobs concluded `success`.

The audit remains **PARTIALLY COMPLIANT** on one item, carried from R4. AC-5 and AC-21 name the repository wrapper `scripts/dev-tools/run-actionlint.ps1`, which has not been run, because under the 2026-10-01 operator decision agents may not run pwsh in agent worktrees. A direct `actionlint` run reports no findings. The wrapper run is an operator-run item and blocks only AC completion; no code change is required.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed. The executor's helper scripts (`pester_xml_summary.py` and others) live in the session scratchpad.
- ✅ This review accidentally wrote three scratch files into the worktree root (`names.txt`, `hookdiff.txt`, `testdiff.txt`) through a scratchpad check script. It deleted them before writing the artifacts, and they were never staged.

---

## Rejected Scope Narrowing

No caller-prompt narrowing was detected. The delegation prompt names the base branch, merge-base SHA, head SHA, PR-context artifacts, AC source, and remediation plan. It asks for "the full feature-review-workflow skill contract end to end". The label "Re-audit (remediation cycle 1, R4)" was read as a cycle label, not as a scope limit. This audit evaluates the full branch diff and all 22 acceptance criteria, not only finding R4.

The prompt section "Context facts for evaluating evidence (not scope instructions)" states the operator decision that pwsh may not be run in agent worktrees. This audit treats that as an evidence-route constraint, not as a narrowing. It does not waive any toolchain step for PowerShell.

The plan-scoped framing in the prior cycle's executor evidence ("outside this plan's file list") does not recur in the remediation-cycle evidence. The new inventory `evidence/qa-gates/linux-first-run-failures.2026-10-01T20-26.md` closes all 21 rows.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` (with `PYTHONPATH=<worktree>`): exit 0, no violations reported.
- Command: `git diff --name-only 41217012..HEAD | grep -c -E '^artifacts/(baselines|qa|evidence|coverage)/'`: `0`. No file in the branch diff is under a non-canonical evidence path.
- All executor evidence is under `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/{baseline,remediation-baseline,qa-gates,regression-testing,other}/`.
- Result: ✅ PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred during this review.

## Workflow Rule: modified-workflow-needs-green-run

| Requirement | Status | Evidence |
|------------|--------|----------|
| Green run of each modified workflow against the branch head | ✅ PASS | `.github/workflows/_poshqc.yml` is modified. Run 36918378249 (`CI`, which calls `_poshqc.yml`) on `42db4491` concluded `success`. Job `poshqc / PowerShell QC` (110557965705) and job `poshqc / PowerShell hook suites (Linux)` (110557965901) both concluded `success`. This review confirmed this with `gh run view 36918378249 --json headSha,conclusion,jobs`. The branch head `acb17443` differs from `42db4491` only in feature-folder documents. |
| `_shell-coverage.yml` unchanged | ✅ PASS | It is absent from `git diff --name-only 41217012..HEAD`, and the scope grep count is 0. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The remediation edits assign `$script:SyntheticWorktree` once in `BeforeAll` and `$absentRoot` locally inside each `It`. No test mutates shared state. |
| **Isolation** - Each test targets single behavior | ✅ PASS | The remediation edits change only the synthetic inputs. No assertion changed. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The edits are text-only. The Linux job ran 3412 tests in one step. |
| **Determinism** - Consistent results | ✅ PASS | The OS-dependent inputs derive from `$IsWindows`, so each host has one fixed value. There is no clock, randomness, or network. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | A comment at `enforce-parallel-drift-gate.Tests.ps1:29` states why the root is OS-derived (`Join-Path` raises `DriveNotFoundException` on Linux). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | PowerShell 96.31% lines (CI run 36890793420); Bash 93.4% lines (CI run 36890790108). |
| **No Coverage Regression** | ✅ PASS | PowerShell 96.31% -> 96.31% (covered 11236, missed 430 in both runs 36901896617 and 36918378249). Bash 93.4% -> 93.7%. |
| **New Code Coverage ≥90%** | ✅ PASS | `kcov_trace_env.sh` 2 of 2 instrumented lines hit. `shell_qc_lib.sh` changed instrumented lines 6 of 6 hit (`evidence/qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md`). Neither Bash file changed after `ecba8829`, so that per-line record still applies. |
| **Comprehensive Coverage** | ✅ PASS | `run_test` is reached by the 3 new bats tests and the existing skip-marker and max-exit tests. |
| **Positive Flows** - Valid inputs | ✅ PASS | The routing suites' "default reader yields direct mode when the checkpoint file is absent" now exercises the absent-file path on both hosts. |
| **Negative Flows** - Invalid inputs | ✅ PASS | The nounset regression test asserts a non-zero exit. The drift-gate deny cases (rows 1, 4, 5 of the inventory) pass on Linux. |
| **Edge Cases** - Boundary conditions | ✅ PASS | The drift-gate `-ForEach` row "a blank feature folder" keeps its OS-derived worktree path, which is evaluated during Pester discovery. |
| **Error Handling** - Error paths | ✅ PASS | Before the fix, the routing tests threw `DriveNotFoundException` on Linux before reaching the absence check. They now reach the intended path. |
| **Concurrency** - If applicable | N/A | No concurrent behavior is introduced. |
| **State Transitions** - If applicable | N/A | No stateful component is introduced. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.31% lines -> Post-change: 96.31% lines. Change: 0.00% lines (covered 11236 of 11666 in CI runs 36901896617 and 36918378249; local artifact 96.25%, covered 10688 of 11104). New/changed-code coverage: N/A - no production PowerShell file changed. Disposition: PASS. Evidence: `evidence/qa-gates/coverage-comparison.2026-10-01T20-27.md`, `evidence/qa-gates/ci-remediation-windows-results.2026-10-01T20-23.md`, `artifacts/pester/powershell-coverage.xml`.
- Bash: Baseline: 93.4% lines -> Post-change: 93.7% lines. Change: +0.3% lines. New/changed-code coverage: 100.0% (8 of 8 instrumented changed lines hit; `kcov_trace_env.sh` line-rate 1.000; `shell_qc_lib.sh` line-rate 0.905). Disposition: PASS. Evidence: CI run 36918378249 job 110557965675 log line `Bash coverage (lines): 93.7%` (read by this review); `evidence/qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md`.
- Python, TypeScript, C#: zero changed files on the branch; no coverage verdict applies.

Verdict per language with changed files (threshold: line >= 85%; no branch gate for Pester or kcov, per `.claude/rules/quality-tiers.md`):
- PowerShell coverage verdict = **PASS**. Repo-wide coverage is 96.31% in CI and 96.25% in the local artifact, both at least 85%. No new or modified production file exists. The two denominators differ (11666 and 11104 lines), which matches open issue #527. This is a non-blocking observation.
- Bash coverage verdict = **PASS**. Repo-wide 93.7%. New file `kcov_trace_env.sh` 100.0%. Modified file `shell_qc_lib.sh` 90.5%, with no changed-line regression.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions are unchanged and keep their existing messages. The S1 assertions carry `-Because`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | The routing tests arrange `$absentRoot` and the seams, then act (`Invoke-*BatchBudgetHook`) and assert. |
| **Document Intent** | ✅ PASS | The intent comment is in the drift-gate `BeforeAll`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The synthetic roots are never created on disk. `Test-Path` and `Get-ChildItem` are mocked in the drift-gate presence tests. |
| **Use Mocks/Stubs** | ✅ PASS | Existing seams (`Get-RoutingStateSeam`, `Get-CodexRoutingSeam`) are reused unchanged. |
| **Environment Stability** | ✅ PASS | This review scanned `git diff -U0 41217012..HEAD -- tests/` for `mktemp`, `BATS_*TMPDIR`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, and `TestDrive`: count 0. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document. The outstanding operator-run item is listed in Section 8 and in `remediation-inputs.2026-10-01T20-20.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-10-01T18-07.md` enumerates R1 to R4 and fix sets F1 to F3. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-10-01T18-07.md` and `evidence/remediation-baseline/phase0-instructions-read.md`. |
| **Document the plan** | ✅ PASS | `remediation-plan.2026-10-01T18-07.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Each fix is a one-line OS-conditioned expression. No helper function was added. |
| **Reusability** | ✅ PASS | The fix follows the pattern already merged at `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1:47-51`. The drift-gate file defines `$script:SyntheticWorktree` once and reuses it at five call sites. |
| **Extensibility** | ✅ PASS | No API change. |
| **Separation of concerns** | ✅ PASS | No production hook script was edited, as the remediation do-not-do list requires. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Edits stay in the test file of each affected hook. |
| **Under 500 lines** | ✅ PASS | `wc -l` by this review: largest code file `epic-child-worktree-launcher.Tests.ps1` 495; `epic-child-launch-hardening.Tests.ps1` 469; `enforce-parallel-drift-gate.Tests.ps1` 440; `shell_qc_lib.sh` 394; `codex-python-batch-budget-routing.Tests.ps1` 390; all others lower. |
| **Public vs internal** | ✅ PASS | The `shell-qc.sh` CLI surface and the `poshqc` job are unchanged. |
| **No circular dependencies** | ✅ PASS | No new references. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `$script:SyntheticWorktree`, `$absentRoot`. |
| **Docs/docstrings** | ✅ PASS | The `run_test` header comment describes the simulation. |
| **Comment why, not what** | ✅ PASS | The drift-gate comment states the Linux exception that motivates the change. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` (`evidence/qa-gates/qc-ps-format.2026-10-01T19-23.md`). CI step `Format PowerShell` `success` on `42db4491`. `shell-qc.sh format`: no change (`qc-bash-format.2026-10-01T19-25.md`). |
| **2. Linting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze` (`qc-ps-analyze.2026-10-01T19-23.md`). CI log `PSScriptAnalyzer passed: no findings` (read by this review). `shell-qc.sh check` exit 0 (`qc-bash-check.2026-10-01T19-25.md`). |
| **3. Type checking** | N/A | No Python, TypeScript, or C# changes. Not applicable to PowerShell or Bash. |
| **4. Testing** | ✅ PASS | **Windows Pester:** 6091 pass, 0 fail. **Linux Pester (hook suites):** 3412 pass, 0 fail. **Bats:** 501 ok, 0 not ok locally; CI `shell-coverage` `success`. **pytest parity:** passed (`qc-pytest-claude-resource-contracts.2026-10-01T19-58.md`). |
| **Full toolchain loop** | ⚠️ PARTIAL | Loop pass 1 completed every agent-runnable step without a file change (`qc-loop-pass.2026-10-01T20-00.md`). The actionlint step through `run-actionlint.ps1` is operator-run. Direct `actionlint` exit 0 is supplementary (`qc-actionlint-direct.2026-10-01T19-58.md`). |
| **Explicit reporting** | ✅ PASS | Commands, exit codes, and outputs are recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commits `19bb587a` and `463d8791` are scoped `test(743)`, with descriptive subjects. |
| **Design choices explained** | ✅ PASS | The remediation inventory gives the fix applied for each row. |
| **Update supporting documents** | ✅ PASS | `evidence/other/ac-evidence-index.2026-10-01T20-30.md` maps each AC to evidence. |
| **Provide next steps** | ✅ PASS | `evidence/other/operator-run-items.2026-10-01T20-27.md` and `remediation-inputs.2026-10-01T20-20.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format`; CI `Format PowerShell` `success` (run 36918378249). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`; CI `Analyze PowerShell` `success`, no findings. |
| **Fix all findings** | ✅ PASS | The analyzer finding set is empty. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The tests use `$IsWindows`, as the production code under test does. Both CI jobs run pwsh 7. On Windows PowerShell 5.1, `$IsWindows` is undefined and the condition takes the non-Windows branch. That matches the precedent already accepted for S1 to S5 on this branch. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | N/A | Test files only. |
| **Parameter validation** | N/A | Test files only. |
| **Avoid global state** | ✅ PASS | Script-scope variables are confined to `BeforeAll`; `$absentRoot` is local to each `It`. |
| **Error handling** | ✅ PASS | No error handling was altered. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | See 2.3. |
| **Approved verbs** | ✅ PASS | No new functions. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 3B.1. |
| **Step 2: Analyze** | ✅ PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Windows `poshqc / PowerShell QC` and Linux `poshqc / PowerShell hook suites (Linux)` both `success` on `42db4491`. Linux JUnit `tests=3412 failures=0 errors=0` (`ci-remediation-linux-junit.2026-10-01T20-22.md`). |
| **Rerun loop if needed** | ✅ PASS | One clean pass with no file change after the remediation edits (`qc-loop-pass.2026-10-01T20-00.md`). |

---

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** `sh scripts/bash/shell-qc.sh format`; no change (`qc-bash-format.2026-10-01T19-25.md`). |
| **Linting with shellcheck** | ✅ PASS | **Command:** `sh scripts/bash/shell-qc.sh check`; exit 0 (`qc-bash-check.2026-10-01T19-25.md`). |
| **Testing with bats** | ✅ PASS | **Command:** `SHELL_QC_BATS_BIN=<npm-cache>/.../bats sh scripts/bash/shell-qc.sh test`; exit 0, TAP `1..501`, 0 `not ok` (`qc-shell-qc-test-full.2026-10-01T19-57.md`). |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | `#!/usr/bin/env bash` in all new scripts and stubs. |
| **Error handling** | ✅ PASS | `run_test` keeps `|| rc=$?` max-exit semantics. |
| **Under 500 lines** | ✅ PASS | 394 and 9 lines. |

---

### Section 3E: GitHub Actions Workflow Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **actionlint clean** | ⚠️ PARTIAL | Direct `actionlint .github/workflows/_poshqc.yml` exit 0 with no output, in four recorded runs (latest `qc-actionlint-direct.2026-10-01T19-58.md`). The wrapper `scripts/dev-tools/run-actionlint.ps1` named by AC-5 has not been run and is recorded as an operator-run item (`evidence/other/operator-run-items.2026-10-01T20-27.md`). No workflow file changed in remediation cycle 1. |
| **Least-privilege permissions** | ✅ PASS | The new job declares `permissions: contents: read`. |
| **Small, focused jobs** | ✅ PASS | Four steps; coverage disabled; distinct artifact name. |
| **Existing job unchanged** | ✅ PASS | `git diff -U0 41217012..HEAD -- .github/workflows/_poshqc.yml` has one hunk, `@@ -52,0 +53,38 @@`, with no removed lines. |
| **Green run on branch head** | ✅ PASS | See "Workflow Rule: modified-workflow-needs-green-run". |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester 5 constructs throughout. The OS-derived `-ForEach` value is computed inline because `-ForEach` data is evaluated during discovery, before `BeforeAll` runs. |
| **Use PoshQC Configuration** | ✅ PASS | The Windows job still uses `Invoke-PoshQCTest`; `pester.runsettings.psd1` is unchanged. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | See 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Only the synthetic inputs changed. |
| **Test Behavior Over Implementation** | ✅ PASS | The same assertion (deny or allow; direct mode when the checkpoint is absent) runs on both hosts. The production hooks do not branch on OS for these outcomes. |
| **Mocking Used Sparingly** | ✅ PASS | No new mocks. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`. **Code file:** `.claude/hooks/enforce-parallel-drift-gate.ps1`. Test paths are unchanged and mirror the hook locations. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Unchanged file names. |
| **Describe/Context/It Structure** | ✅ PASS | Unchanged. |
| **Logical Grouping** | ✅ PASS | Unchanged. |
| **Docstrings/Comments** | ✅ PASS | See 1.1. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` (`qc-ps-test.2026-10-01T19-24.md`) and CI `Invoke-PoshQCTest` (6091 pass, 0 fail). |
| **No Alternative Test Runners** | ✅ PASS | Pester only. The Linux job uses `Invoke-Pester` directly, as the spec requires. |

### Section 4C: Bash Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **bats via shell-qc** | ✅ PASS | Tests in `tests/shell/test_shell_qc_commands.bats`; fixtures under `tests/fixtures/shell_qc/`. |
| **Fail-before / pass-after** | ✅ PASS | `evidence/regression-testing/fail-before-bats.2026-10-01T16-32.md` and `pass-after-bats.2026-10-01T16-34.md`. For the Linux fixes: `regression-testing/linux-baseline-junit.2026-10-01T19-01.md` (fail-before) and `qa-gates/ci-remediation-linux-junit.2026-10-01T20-22.md` (pass-after). |

---

## 5. Test Coverage Detail

### Linux portability fixes (remediation cycle 1)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| drift gate: denies when the only finding file predates the latest drift event (and 4 sibling checkpoint cases) | Negative / Positive | hook checkpoint path | ✅ |
| drift gate: Test-ParallelDriftFindingPresent absence and presence cases (3) | Edge Case | `Test-ParallelDriftFindingPresent` | ✅ |
| four routing suites: the default reader yields direct mode when the checkpoint file is absent | Edge Case | default checkpoint reader | ✅ |

**Coverage:** Test files are outside the coverage denominator. PowerShell repo-wide coverage is unchanged at 96.31%.

### `run_test` in `scripts/bash/shell_qc_lib.sh` and `kcov_trace_env.sh`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test fails when a bats child sources a nounset library inside bash -c | Negative / Error Handling | 253-257, 262, 267 | ✅ |
| test passes when a bats child resets nounset after sourcing | Positive / Edge Case | 253-257, 262, 267 | ✅ |
| kcov_trace_env.sh sets the kcov PS4 format | Positive | `kcov_trace_env.sh` 8-9 | ✅ |

**Coverage:** changed instrumented lines 8 of 8 hit.

**Not covered:** None among changed lines.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (Windows Pester) | 6101 | ✅ |
| Tests Passed (Windows Pester) | 6091 (10 skipped) | ✅ |
| Tests Failed (Windows Pester) | 0 | ✅ |
| Total Tests (Linux hook suites) | 3412 | ✅ |
| Tests Failed (Linux hook suites) | 0 | ✅ |
| Bats (local, simulation active) | 501 ok, 0 not ok | ✅ |
| Bats under kcov (CI) | job `success` | ✅ |
| Code Coverage | PowerShell 96.31% lines; Bash 93.7% lines (no branch metric for Pester or kcov) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format`; CI `Format PowerShell` | no change | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze`; CI `Analyze PowerShell` | no findings | ✅ |
| Pester Tests (Windows) | CI `poshqc / PowerShell QC` | 6091 pass, 0 fail | ✅ |
| Pester Tests (Linux hooks) | CI `poshqc / PowerShell hook suites (Linux)` | 3412 pass, 0 fail | ✅ |

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt | `shell-qc.sh format` | no change | ✅ |
| shellcheck | `shell-qc.sh check` | exit 0 | ✅ |
| bats | `shell-qc.sh test` | 501 ok | ✅ |
| kcov | CI `shell-coverage` | 93.7% | ✅ |

**For GitHub Actions and Python parity:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| actionlint (direct) | `actionlint .github/workflows/_poshqc.yml` | exit 0, no output | ✅ |
| actionlint (wrapper) | `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` | not run (operator-run item) | ⚠️ |
| pytest parity | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | passed | ✅ |
| Skill mirror identity | `cmp` of the two `atomic-plan-contract/SKILL.md` copies (this review) | identical | ✅ |

**Notes:**
This review counted 67 lines in `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/` that hold a quoted `C:/` or `C:\` literal without `IsWindows` on the same line. Their suites pass on Linux (3412 pass, 0 fail), so these literals are string data that never reaches a drive lookup. The finding is informational (see code review).

---

## 8. Gaps and Exceptions

### Identified Gaps
- **AC-5 / AC-21 (blocking for AC completion; operator action):** `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` has not been run or recorded. No code change is required.

### Resolved Since Prior Audit
- R1 (AC-6): resolved. The Linux job reports `success` with 3412 passed and 0 failed.
- R2 (AC-10): resolved. All 21 inventory rows have a fix and status PASSING (`linux-first-run-failures.2026-10-01T20-26.md`), and no skip was added.
- R3 (`modified-workflow-needs-green-run`): resolved. Run 36918378249 is green.
- Prior Minor (AC-15 reproducibility): resolved. The full command line is now recorded in `qc-shell-qc-test-full.2026-10-01T19-57.md`.

### Approved Exceptions
- Operator decision of 2026-10-01: pwsh is not run in agent worktrees. PowerShell format, analyze, and test evidence comes from the PoshQC MCP tools plus CI logs and artifacts. This audit accepts that route for those steps. It does not accept the route as a substitute for the explicitly named `run-actionlint.ps1` command in AC-5.

### Removed/Skipped Tests
**None.** This review counted added lines matching `-Skip` or `Set-ItResult` in `git diff -U0 41217012..HEAD -- tests/scripts/codex-hooks/ tests/scripts/claude-hooks/`: 0.

---

## 9. Summary of Changes

### Commits in This PR/Branch (since the prior audit)

1. **dcb2abf1** - feature-review artifacts and remediation inputs (cycle 0)
2. **a07fb047** - remediation cycle 1 baseline and anchors
3. **19bb587a** - `test(743)`: derive the drift-gate synthetic worktree root from the host OS
4. **463d8791** - `test(743)`: derive the absent routing root from the host OS in four routing suites
5. **42db4491** - final QC loop evidence (CI verification SHA)
6. **bc4e5d0e, 7353118d, acb17443** - CI verification evidence, AC-6 and AC-10 check-off, final commit evidence

Earlier commits are listed in `policy-audit.2026-10-01T18-07.md` Section 9.

### Files Modified

1. **`.github/workflows/_poshqc.yml`** (MODIFIED) - new `poshqc-linux-hooks` job; `poshqc` job unchanged.
2. **`scripts/bash/kcov_trace_env.sh`** (NEW) and **`scripts/bash/shell_qc_lib.sh`** (MODIFIED) - kcov trace simulation in `run_test`.
3. **`tests/shell/test_shell_qc_commands.bats`** and three fixtures - regression tests.
4. **`tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`** (NEW) - workflow invariants.
5. **Eight hook-suite test files** (MODIFIED) - OS-derived synthetic roots and `$IsWindows`-conditioned assertions.
6. **`atomic-plan-contract/SKILL.md`** and its bundle mirror (MODIFIED) - two guidance bullets.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

All code, test, coverage, scope, and CI requirements pass on the branch head. The only open item is the operator-run actionlint wrapper named by AC-5 and AC-21.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation inputs and plan present
- ✅ Design Principles: minimal, pattern-consistent edits
- ✅ Module & File Structure: all files under 500 lines
- ✅ Naming, Docs, Comments: compliant
- ⚠️ Toolchain Execution: every agent-runnable step clean; actionlint wrapper operator-run
- ✅ Summarize & Document: commits and evidence present

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean
- ✅ PowerShell Design & Safety: test-only changes
- ✅ Structure & Naming: compliant
- ✅ Toolchain: Windows and Linux test steps green

**For Bash:**
- ✅ Tooling, design, and tests compliant

**For GitHub Actions:**
- ⚠️ actionlint wrapper operator-run; ✅ green run on branch head

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ✅ Coverage & Scenarios: PowerShell 96.31%, Bash 93.7%, changed lines 8 of 8
- ✅ Test Structure: compliant
- ✅ External Dependencies: no temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: Linux hook suites 0 failures

---

### Metrics Summary

- ✅ Windows Pester 6091 of 6101 passing (10 skipped, 0 failed)
- ✅ Linux hook suites 3412 of 3412 passing
- ✅ Bats 501 of 501 passing locally under the simulation
- ✅ PowerShell 96.31% line coverage; Bash 93.7% line coverage
- ✅ Proper file organization: tests under `tests/`, fixtures under `tests/fixtures/shell_qc/`
- ⚠️ Code quality checks: all clean except the operator-run actionlint wrapper

---

### Recommendation

**Ready for merge after one operator action**

1. The operator runs `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` from the item worktree root. The command, exit code, and output are then recorded under `evidence/qa-gates/` with a new timestamp.
2. On exit 0 with no findings, AC-5 and AC-21 can be checked off in `spec.md`.

---

## Appendix A: Test Inventory

### Complete Test List

1. `_poshqc.yml workflow invariants` - 7 It blocks (see `policy-audit.2026-10-01T18-07.md` Appendix A)
2. `test_shell_qc_commands.bats` - 3 new tests (nounset failure, nounset reset, PS4 format)
3. Modified (cycle 0): 3 Codex suites - `epic-child-launch-hardening`, `epic-child-worktree-launcher`, `enforce-epic-worktree-removal-gate-decision-surface`
4. Modified (cycle 1): `enforce-parallel-drift-gate.Tests.ps1` - 8 It cases (inventory rows 1-8)
5. Modified (cycle 1): four routing suites - "the default reader yields direct mode when the checkpoint file is absent" (inventory rows 9-12)

---

## Appendix B: Toolchain Commands Reference

```bash
# Run by this review
gh run view 36918378249 -R drmoisan/drm-copilot --json headSha,conclusion,status,jobs
gh run view 36918378249 -R drmoisan/drm-copilot --log --job 110557965901 | grep -F 'Tests Passed:'
gh run view 36918378249 -R drmoisan/drm-copilot --log --job 110557965705 | grep -F -e 'Tests Passed:' -e 'PSScriptAnalyzer passed'
gh run view 36918378249 -R drmoisan/drm-copilot --log --job 110557965675 | grep -E 'Bash coverage \(lines\): [0-9]'
gh run list -R drmoisan/drm-copilot --branch bug/ci-gaps-linux-pester-and-kcov-set-u-743 --limit 8
git diff --name-only 42db4491a6a7af4d0a876bf4022f7153e66f5c88..HEAD
git diff 630237f4..HEAD -- tests/
git diff --name-only 41217012..HEAD | grep -c -E '^(\.github/workflows/(_quality-checks|_drm-copilot-extension-tests|ci|_shell-coverage)\.yml|scripts/powershell/PoshQC/settings/pester\.runsettings\.psd1|\.claude/rules/|\.github/instructions/)'
git diff -U0 41217012..HEAD -- tests/scripts/codex-hooks/ tests/scripts/claude-hooks/ | grep -c -E '^\+.*(-Skip([[:space:]]|$|:\$true)|Set-ItResult)'
cmp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# Operator-run (outstanding)
pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml
```

**For PowerShell (MCP route per operator decision):**
```powershell
# mcp__drm-copilot__run_poshqc_format   (workspace_root = <REPO_ROOT>)
# mcp__drm-copilot__run_poshqc_analyze  (workspace_root = <REPO_ROOT>)
# mcp__drm-copilot__run_poshqc_test     (workspace_root = <REPO_ROOT>)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-01
**Policy Version:** Current (as of audit date)

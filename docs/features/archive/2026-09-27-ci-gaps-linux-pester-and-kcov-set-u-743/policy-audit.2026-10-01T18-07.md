# Policy Compliance Audit: CI gaps - Linux Pester hook-suite job and kcov set -u trace simulation (#743)

---

**Audit Date:** 2026-10-01
**Branch:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743` @ `630237f4bf081ed117253e44a7f3d3780bb19368`
**Base:** `main` (resolved `origin/main` @ `41217012d31d35c2ee33a50be50684affd2f5f43`; merge base `41217012d31d35c2ee33a50be50684affd2f5f43`)
**CI verification SHA:** `ecba8829604f6265dc491c74cf42546f9d5aab57` (run 36901896617). `git diff --name-only ecba8829..630237f4` lists only files under `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/`, so the CI run covers every code, test, workflow, and skill file on the branch.
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (the file served for the `template` selector). The MCP template tool was not in this agent's tool list, so the bundled file was read directly.

**Code Under Test (full branch diff, excluding feature-folder documentation):**
- `.github/workflows/_poshqc.yml` (MODIFIED, +38)
- `scripts/bash/kcov_trace_env.sh` (NEW, 9 lines)
- `scripts/bash/shell_qc_lib.sh` (MODIFIED, +17/-2)
- `tests/shell/test_shell_qc_commands.bats` (MODIFIED, +34)
- `tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh` (NEW)
- `tests/fixtures/shell_qc/stub-bin/bats-nounset-source` (NEW)
- `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset` (NEW)
- `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (NEW, 95 lines)
- `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` (MODIFIED, +26/-19)
- `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` (MODIFIED, +3/-3)
- `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` (MODIFIED, +1/-1)
- `.claude/skills/atomic-plan-contract/SKILL.md` (MODIFIED, +2)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` (MODIFIED, +2, byte-identical mirror)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 files (test files only; 0 production files) | 7 new It blocks; 3 modified suites (61 tests) | ✅ Windows 6091 pass, 0 fail, 10 skipped; ❌ Linux 3400 pass, 12 fail | 96.31% lines (CI run 36890793420) | 96.31% lines (CI run 36901896617); 96.25% lines (local `artifacts/pester/powershell-coverage.xml`) | N/A - no production PowerShell file added or modified |
| Bash | 2 production files (+1 bats file, 3 fixtures) | 3 new bats tests | ✅ 501 ok, 0 not ok (local, simulation active); ✅ CI kcov job success | 93.4% lines (CI run 36890790108) | 93.7% lines (CI run 36901896617) | 100.0% of instrumented changed lines (8 of 8 hit) |
| Python | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |
| C# | 0 files | N/A | N/A | N/A - zero changed files | N/A - zero changed files | N/A - zero changed files |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: CI run 36890793420 `poshqc-test-results` artifact `powershell-coverage.xml`, recorded in `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/baseline/ps-coverage.2026-10-01T16-28.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (local, LINE covered 10688 of 11104) and CI run 36901896617 `powershell-coverage.xml` (LINE covered 11236 of 11666), recorded in `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/qa-gates/qc-ps-pester-full.2026-10-01T17-57.md`
- Per-language comparison summary: Section 1.2.1 of this audit and `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/qa-gates/coverage-comparison.2026-10-01T17-58.md`

---

## Executive Summary

This audit covers the full branch diff of `bug/ci-gaps-linux-pester-and-kcov-set-u-743` against `main`. The branch adds a Linux Pester job for the Claude and Codex hook suites, a kcov-equivalent xtrace simulation for `shell-qc.sh test`, portable fixes to three Codex hook test files, a workflow-invariant Pester suite, three bats regression tests, and two planner-guidance bullets in `atomic-plan-contract`.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (uniform coverage thresholds)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (test files only)
- ✅ Bash: shfmt + shellcheck + bats
- ✅ GitHub Actions: `.github/instructions/github-actions.instructions.md` and the `modified-workflow-needs-green-run` rule of the feature-review workflow

Coverage is above threshold for both languages with changed files (PowerShell 96.31% lines, Bash 93.7% lines, Bash changed lines 8 of 8 hit). Formatting, linting, Windows Pester, bats, shellcheck, shfmt, and the pytest parity test pass. The audit is **NON-COMPLIANT** for three reasons:

1. The new CI check `poshqc / PowerShell hook suites (Linux)` fails on the branch head: 12 failing tests in 5 hook-suite files (`DriveNotFoundException` for drive `C`). AC-6 and AC-10 are not met.
2. The branch modifies `.github/workflows/_poshqc.yml`, and no green run of that workflow exists for the branch head. The `modified-workflow-needs-green-run` rule therefore yields a Blocking finding.
3. `scripts/dev-tools/run-actionlint.ps1`, which AC-5 and AC-21 name, has not been run. A direct `actionlint` 1.7.11 run reports no findings. The wrapper resolves `actionlint` from PATH and passes its arguments through unchanged, but the named command still awaits an operator run.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed. `git status --porcelain` in this worktree is clean.
- ✅ The executor's helper scripts (`pester_xml_summary.py`, `kcov-changed-lines.sh`, `shell-qc-test-local.sh`) lived in the session scratchpad and are not part of the branch.
- No ongoing tooling script was added apart from `scripts/bash/kcov_trace_env.sh`. It is production and is covered by bats and kcov.

---

## Rejected Scope Narrowing

No caller-prompt narrowing was detected. The delegation prompt names the base branch, merge-base SHA, PR-context artifacts, the AC source, and the executed plan. It does not limit the audit to a plan, phase, file subset, or language.

The executor's evidence contains plan-scoped framing, which this audit does not accept as a scope limit. It is recorded verbatim here:

- `evidence/other/ac-evidence-index.2026-10-01T18-00.md`: "12 Linux failures remain in 5 hook-suite files outside this plan's file list"
- `evidence/qa-gates/ci-final-linux.2026-10-01T17-57.md`: "Every remaining failure is in a file outside this plan's file list."

Justification: `spec.md` (Implementation strategy; Files/modules table row "Other files under `tests/scripts/claude-hooks/` or `tests/scripts/codex-hooks/` | Modify (conditional)") puts every Linux-only failure the CI run reports in scope for this feature before merge. The 12 failures are therefore audited as in-scope, unmet requirements.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` -> exit 0, no violations reported.
- Command: `git diff --name-only 41217012..HEAD | grep -c -E '^artifacts/(baselines|qa|evidence|coverage)/'` -> `0` (exit 1). No file in the branch diff is under a non-canonical evidence path.
- All executor evidence is under `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Result: ✅ PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred during this review.

## Workflow Rule: modified-workflow-needs-green-run

| Requirement | Status | Evidence |
|------------|--------|----------|
| Green run of each modified workflow against the branch head | ❌ FAIL (Blocking) | `.github/workflows/_poshqc.yml` is modified. Run 36901896617 (`ci.yml` dispatch, head `ecba8829`) concluded `failure`: job `poshqc / PowerShell hook suites (Linux)` (databaseId 110502826491) failed, while job `poshqc / PowerShell QC` (110502826187) succeeded. No green `_poshqc.yml` run exists on `ecba8829` or `630237f4`. Evidence: `evidence/qa-gates/ci-final-conclusions.2026-10-01T17-57.md`. |
| `_shell-coverage.yml` unchanged | ✅ PASS | `git diff --exit-code 41217012 -- .github/workflows/_shell-coverage.yml` exit 0 (`evidence/qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md`); it is also absent from the branch name list. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The `PoshQcWorkflow.Tests.ps1` It blocks read the shared `$script:JobText` built once in `BeforeAll` and never mutate it. Each new bats test sets its own `SHELL_QC_BATS_BIN` through `run env` and depends on no other test. |
| **Isolation** - Each test targets single behavior | ✅ PASS | The 7 Pester It blocks each assert one invariant group (job set, poshqc job, Linux job runner, permissions, Run.Path, exit/coverage, artifact). The 3 bats tests separately cover the failing pattern, the passing reset pattern, and the PS4 contract. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The Pester workflow suite does text parsing only. Local full bats wall time was 20.02 minutes against a 21.47-minute baseline (`evidence/qa-gates/qc-shell-qc-test-full.2026-10-01T17-45.md`), so the simulation shows no measurable slowdown. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, or network. The OS-dependent expectations derive from `$IsWindows`, so each host has one deterministic expected value. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive It and @test names, plus comments that cite issue #743 and explain the kcov mechanism. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | PowerShell 96.31% lines (CI run 36890793420, `evidence/baseline/ps-coverage.2026-10-01T16-28.md`). Bash 93.4% lines (CI run 36890790108, `evidence/baseline/ci-baseline-results.2026-10-01T16-28.md`). |
| **No Coverage Regression** | ✅ PASS | PowerShell 96.31% -> 96.31% (0.00). Bash 93.4% -> 93.7% (+0.3). `shell_qc_lib.sh` line-rate 0.865 -> 0.905. |
| **New Code Coverage ≥90%** | ✅ PASS | `scripts/bash/kcov_trace_env.sh`: 2 of 2 instrumented lines hit (100.0%). `scripts/bash/shell_qc_lib.sh` changed instrumented lines 253, 254, 255, 257, 262, 267: 6 of 6 hit. The remaining changed lines are comments or blanks (NOT-INSTRUMENTED). Method: per-line kcov `cov.xml` records filtered to the diff hunks (`evidence/qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md`). |
| **Comprehensive Coverage** | ✅ PASS | `run_test` is reached by the 3 new bats tests and the existing skip-marker and max-exit tests. `kcov_trace_env.sh` is sourced and executed by the PS4 test. |
| **Positive Flows** - Valid inputs | ✅ PASS | "test passes when a bats child resets nounset after sourcing"; "kcov_trace_env.sh sets the kcov PS4 format"; the Pester It blocks for both jobs. |
| **Negative Flows** - Invalid inputs | ✅ PASS | "test fails when a bats child sources a nounset library inside bash -c" asserts a non-zero exit and `BASH_SOURCE` in the output. The Pester assertions `Should -Not -Match 'Invoke-PoshQCTest'` and `Should -Not -Match ... poshqc-test-results` guard the Linux job. |
| **Edge Cases** - Boundary conditions | ✅ PASS | The trace never reaches output (`[[ "$output" != *"kcov@"* ]]`). The negative control `evidence/regression-testing/trace-discard-negative-control.2026-10-01T16-35.md` shows that test fails when the discard is removed. The Run.Path test asserts exactly one assignment line and exactly two folders. |
| **Error Handling** - Error paths | ✅ PASS | The nounset regression test asserts that the error text is surfaced and the exit code is non-zero. The existing skip-marker tests still pass. |
| **Concurrency** - If applicable | N/A | No concurrent behavior is introduced. |
| **State Transitions** - If applicable | N/A | No stateful component is introduced. The fd opened by `exec {trace_fd}>/dev/null` is closed after the loop. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.31% lines -> Post-change: 96.31% lines. Change: 0.00% lines (covered 11236 of 11666 in both CI runs; local artifact 96.25%, covered 10688 of 11104). New/changed-code coverage: N/A - no production PowerShell file changed. Disposition: PASS. Evidence: `evidence/qa-gates/coverage-comparison.2026-10-01T17-58.md`, `evidence/qa-gates/qc-ps-pester-full.2026-10-01T17-57.md`, `artifacts/pester/powershell-coverage.xml`.
- Bash: Baseline: 93.4% lines -> Post-change: 93.7% lines. Change: +0.3% lines. New/changed-code coverage: 100.0% (8 of 8 instrumented changed lines hit; `kcov_trace_env.sh` line-rate 1.000; `shell_qc_lib.sh` line-rate 0.905). Disposition: PASS. Evidence: `evidence/qa-gates/ci-final-shell-coverage.2026-10-01T17-57.md`, `evidence/qa-gates/coverage-comparison.2026-10-01T17-58.md`.
- Python, TypeScript, C#: zero changed files on the branch; no coverage verdict applies.

Verdict per language with changed files (threshold: line >= 85%; no branch gate for Pester or kcov, per `.claude/rules/quality-tiers.md`):
- PowerShell coverage verdict = **PASS**. Repo-wide 96.31% (CI) and 96.25% (local artifact) are both at least 85%. No new or modified production file exists, so no per-file gate applies. The two denominators differ (11666 vs 11104 lines). This matches open issue #527, is recorded as a non-blocking observation, and does not change the verdict because both values are above threshold.
- Bash coverage verdict = **PASS**. Repo-wide 93.7%; new file `kcov_trace_env.sh` 100.0%; modified file `shell_qc_lib.sh` 90.5% with no changed-line regression.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | The OS-dependent assertions carry `-Because 'Codex receives the elevated sandbox argument only on Windows hosts'`. `Should -BeExactly 'poshqc,poshqc-linux-hooks'` reports the actual job set on failure. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Pester: arrange in `BeforeAll`, act and assert in each It. Bats: `run env ...` followed by `[ ... ]` assertions. |
| **Document Intent** | ✅ PASS | Each new bats test and the Pester file header carry an intent comment that cites #743. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | `PoshQcWorkflow.Tests.ps1` reads a tracked repository file only. The bats tests use stub binaries through the `SHELL_QC_BATS_BIN` seam. |
| **Use Mocks/Stubs** | ✅ PASS | The `bats-nounset-source` and `bats-nounset-source-reset` stubs replace bats. The fixture library `nounset_lib.sh` sits outside the `shell-qc.sh check` discovery roots. |
| **Environment Stability** | ✅ PASS | No temporary files: the `git diff -U0 41217012 -- tests/` scan for `mktemp`, `BATS_*TMPDIR`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, and `TestDrive` returned a count of 0 (`evidence/qa-gates/no-temp-files.2026-10-01T17-25.md`). The stubs are mode 100644 and rely on the existing `setup()` `chmod +x "${STUB_DIR}"/*` (bats line 21), the same as the pre-existing stubs. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the policy review for the branch. Outstanding items are listed in Section 8 and in `remediation-inputs.2026-10-01T18-07.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #743 and `spec.md` (full-bug) define three gaps and 22 acceptance criteria. |
| **Read existing change plans** | ✅ PASS | `research/research.2026-09-30T07-20.md` and `plan.2026-09-30T03-15.md` (preflight rounds 1 to 4). |
| **Document the plan** | ✅ PASS | `plan.2026-09-30T03-15.md` with an `## Execution Deviations` section (D1 to D14, B1 to B3). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | `kcov_trace_env.sh` has two executable lines. `run_test` adds two environment assignments and one fd open/close. The Linux job is a separate four-step job rather than a matrix leg, which the spec justifies as avoiding format, analyze, and coverage on Linux. |
| **Reusability** | ✅ PASS | It reuses the existing `SHELL_QC_BATS_BIN` seam and stub-bin fixture convention, and models the workflow suite on `VerifyPublishedReleasesWorkflow.Tests.ps1`. |
| **Extensibility** | ✅ PASS | `Run.Path` is a single list. The trace environment is isolated in one file that kcov version changes can update. |
| **Separation of concerns** | ✅ PASS | The trace environment definition (`kcov_trace_env.sh`) is separate from the runner (`run_test`). `run_test_coverage` is unchanged. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Each new file has one purpose and a header comment stating it. |
| **Under 500 lines** | ✅ PASS | `wc -l`: `_poshqc.yml` 90, `shell_qc_lib.sh` 394, `kcov_trace_env.sh` 9, `test_shell_qc_commands.bats` 203, `PoshQcWorkflow.Tests.ps1` 95, `epic-child-launch-hardening.Tests.ps1` 469, `epic-child-worktree-launcher.Tests.ps1` 495, `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` 258, `atomic-plan-contract/SKILL.md` 247 (Markdown, exempt). |
| **Public vs internal** | ✅ PASS | The `shell-qc.sh` CLI surface, flags, skip markers, and exit codes are unchanged. |
| **No circular dependencies** | ✅ PASS | `shell_qc_lib.sh` references `kcov_trace_env.sh` by path only, and that file sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `trace_env`, `trace_fd`, `poshqc-linux-hooks`, `poshqc-linux-hook-test-results`, `$script:SyntheticRoot`, `$script:SyntheticElsewhere`. |
| **Docs/docstrings** | ✅ PASS | The `run_test` header comment explains the simulation and why `run_test_coverage` does not use it. |
| **Comment why, not what** | ✅ PASS | The decision-surface premise comment now explains why `IsPathRooted` differs by OS. The kcov comment explains why `BASH_SOURCE` is unset at the top level of `bash -c`. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` (ok) with an unchanged `git status --porcelain`; CI `Format PowerShell` step success (596 `Already formatted:`). `shell-qc.sh format`: hashes unchanged (`evidence/qa-gates/qc-bash-format.2026-10-01T17-23.md`). |
| **2. Linting** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze` (ok); CI `PSScriptAnalyzer passed: no findings`. `sh scripts/bash/shell-qc.sh check` exit 0; `shellcheck -f gcc scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh` exit 0. |
| **3. Type checking** | N/A | No Python, TypeScript, or C# changes. Not applicable to PowerShell or Bash. |
| **4. Testing** | ❌ FAIL | **Windows Pester:** 6091 pass, 0 fail. **Linux Pester (hook suites):** 3400 pass, 12 fail. **Bats:** 501 ok locally, CI `not ok` set empty. **pytest parity:** 14 passed. |
| **Full toolchain loop** | ⚠️ PARTIAL | Loop pass 1 passed for nine of ten steps without file changes. Step 9 (`run-actionlint.ps1`) is operator-pending (B3), with direct `actionlint` exit 0 as supplementary evidence (`evidence/qa-gates/qc-loop-pass.2026-10-01T17-23.md`). |
| **Explicit reporting** | ✅ PASS | Commands, exit codes, and outputs are recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages are scoped `fix(743)`, `ci(743)`, `test(743)`, `docs(743)`. |
| **Design choices explained** | ✅ PASS | `spec.md` "Resolution of the seeded items" records why a separate job was chosen over a matrix leg and a trace simulation over a static lint rule. |
| **Update supporting documents** | ✅ PASS | The `atomic-plan-contract` skill and its bundle mirror are updated and byte-identical (`cmp` exit 0). |
| **Provide next steps** | ✅ PASS | See `remediation-inputs.2026-10-01T18-07.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format`; CI `Format PowerShell` success on `ecba8829`. Per the operator decision of 2026-10-01, pwsh is not run in agent worktrees. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`; CI `PSScriptAnalyzer passed: no findings under <RUNNER_ROOT>`. |
| **Fix all findings** | ✅ PASS | The analyzer finding set is empty. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The modified tests use `$IsWindows`. That variable is undefined on 5.1, but the production code under test (`.codex/scripts/epic-child-sandbox-preflight.ps1:16,33`) uses the same variable, so test and production branch identically. CI runs the suites under pwsh 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | N/A | Test files only. |
| **Parameter validation** | N/A | Test files only. |
| **Avoid global state** | ✅ PASS | Script-scope variables are confined to the Describe `BeforeAll` blocks. |
| **Error handling** | ✅ PASS | `Set-StrictMode -Version Latest` is used in `PoshQcWorkflow.Tests.ps1`. `Resolve-Path` fails fast if the workflow file is absent. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 95, 469, 495, 258 lines. `epic-child-worktree-launcher.Tests.ps1` is 5 lines below the limit (see code review, Info). |
| **Approved verbs** | ✅ PASS | No new functions. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 3B.1. |
| **Step 2: Analyze** | ✅ PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ❌ FAIL | Windows `poshqc / PowerShell QC` success. Linux `poshqc / PowerShell hook suites (Linux)` failure, with 12 failures in `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` (8), `enforce-powershell-batch-budget-routing.Tests.ps1` (1), `enforce-python-batch-budget-routing.Tests.ps1` (1), `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` (1), and `codex-python-batch-budget-routing.Tests.ps1` (1). |
| **Rerun loop if needed** | ⚠️ PARTIAL | The loop was not rerun after the final CI run, because the remaining failures were classified as outside the plan's file list. See Rejected Scope Narrowing. |

---

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** `bash scripts/bash/shell-qc.sh format` (run via `sh`); hashes unchanged after the run. |
| **Linting with shellcheck** | ✅ PASS | **Command:** `sh scripts/bash/shell-qc.sh check` exit 0, no output. The single-quoted PS4 produced no SC2016 finding (`evidence/regression-testing/shellcheck-trace-env-final.2026-10-01T16-33.md`). |
| **Testing with bats** | ✅ PASS | **Command:** `shell-qc.sh test` via the `SHELL_QC_BATS_BIN` seam: 501 ok, 0 not ok. CI `shell-coverage` job success with an empty `not ok` set. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | `#!/usr/bin/env bash` in all new scripts and stubs. |
| **Error handling** | ✅ PASS | `run_test` keeps `|| rc=$?` max-exit semantics. `kcov_trace_env.sh` intentionally defines no strict mode, because it is sourced into arbitrary child shells and must not change their options beyond xtrace. |
| **Under 500 lines** | ✅ PASS | 394 and 9 lines. |

---

### Section 3E: GitHub Actions Workflow Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **actionlint clean** | ⚠️ PARTIAL | Direct `actionlint .github/workflows/_poshqc.yml` (1.7.11) exit 0 with no output, in three runs (baseline, regression-testing, qa-gates). The repository wrapper `scripts/dev-tools/run-actionlint.ps1` named by AC-5 has not been run (operator blockers B1 to B3). |
| **Least-privilege permissions** | ✅ PASS | The new job declares `permissions: contents: read`. |
| **Small, focused jobs** | ✅ PASS | Four steps; coverage disabled; distinct artifact name. |
| **Existing job unchanged** | ✅ PASS | One diff hunk `@@ -50,3 +50,41 @@` adds lines after the end of the `poshqc` job only. |
| **Green run on branch head** | ❌ FAIL | See "Workflow Rule: modified-workflow-needs-green-run". |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, `Describe`, `Context`, `It`, `Should -BeExactly`, `-Match`, `-Be ... -Because`. The Linux job imports Pester `-MinimumVersion 5.6.1`. |
| **Use PoshQC Configuration** | ✅ PASS | The Windows job still uses `Invoke-PoshQCTest`. `pester.runsettings.psd1` is unchanged (AC-20 scope check count 0). The Linux job uses `Invoke-Pester` directly by design (spec). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | See 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 7 It blocks in the workflow suite. The Codex fixes change single assertions or the synthetic inputs only. |
| **Test Behavior Over Implementation** | ✅ PASS | The S1 assertions now encode the production rule: the argument is present if and only if the host is Windows. |
| **Mocking Used Sparingly** | ✅ PASS | No new mocks. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`. **Code file:** `.github/workflows/_poshqc.yml`. It follows the `tests/scripts/workflows/` precedent for workflow-invariant suites. The Codex test paths are unchanged. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `PoshQcWorkflow.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe and 7 It blocks in the new suite. |
| **Logical Grouping** | ✅ PASS | One Describe per workflow. |
| **Docstrings/Comments** | ✅ PASS | The header comment documents the location rule and the parsing method. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_test` (ok) and CI `Invoke-PoshQCTest` (6091 pass, 0 fail). |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

### Section 4C: Bash Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **bats via shell-qc** | ✅ PASS | Tests are in `tests/shell/test_shell_qc_commands.bats`; fixtures under `tests/fixtures/shell_qc/`. |
| **Fail-before / pass-after** | ✅ PASS | `evidence/regression-testing/fail-before-bats.2026-10-01T16-32.md` (exit 1 as expected) and `pass-after-bats.2026-10-01T16-34.md` (exit 0). |

---

## 5. Test Coverage Detail

### `run_test` in `scripts/bash/shell_qc_lib.sh` (3 new tests + existing)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test fails when a bats child sources a nounset library inside bash -c | Negative / Error Handling | 253-257, 262, 267 | ✅ |
| test passes when a bats child resets nounset after sourcing | Positive / Edge Case (trace discarded) | 253-257, 262, 267 | ✅ |
| existing skip-marker and max-exit tests | Edge Case | 242-251 | ✅ |

**Coverage:** `shell_qc_lib.sh` line-rate 0.905. Changed instrumented lines 6 of 6 hit.

**Not covered:** None among changed lines.

### `scripts/bash/kcov_trace_env.sh` (1 test)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| kcov_trace_env.sh sets the kcov PS4 format | Positive | 8-9 | ✅ |

**Coverage:** 100.0% (2 of 2 instrumented lines).

### `.github/workflows/_poshqc.yml` invariants (7 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| declares exactly the poshqc and poshqc-linux-hooks jobs | Positive | job keys | ✅ |
| keeps the poshqc job on windows-latest running Invoke-PoshQCTest | Regression guard | poshqc job | ✅ |
| runs the poshqc-linux-hooks job on ubuntu-latest under its check name | Positive | 54-56 | ✅ |
| grants the poshqc-linux-hooks job read-only repository contents | Positive | 57-58 | ✅ |
| limits the poshqc-linux-hooks Run.Path to the two hook-suite folders | Edge Case | 76 | ✅ |
| fails the poshqc-linux-hooks job on a failed test and collects no coverage | Positive / Negative | 77-78, 82 | ✅ |
| uploads the poshqc-linux-hooks JUnit result under a distinct artifact name | Positive / Negative | 81, 88 | ✅ |

**Coverage:** Not a coverage-measured file type (YAML). All seven tests pass on Windows (`SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | tests=7 | failures=0`).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (Windows Pester) | 6101 | ✅ |
| Tests Passed (Windows Pester) | 6091 (10 skipped) | ✅ |
| Tests Failed (Windows Pester) | 0 | ✅ |
| Total Tests (Linux hook suites) | 3412 | ❌ |
| Tests Failed (Linux hook suites) | 12 | ❌ |
| Bats (local, simulation active) | 501 ok, 0 not ok, 20.02 min | ✅ |
| Bats under kcov (CI) | `not ok` set empty | ✅ |
| pytest parity | 14 passed | ✅ |
| Code Coverage | PowerShell 96.31% lines; Bash 93.7% lines (no branch metric for Pester or kcov) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format`; CI `Format PowerShell` | no change | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze`; CI `Analyze PowerShell` | no findings | ✅ |
| Pester Tests (Windows) | CI `poshqc / PowerShell QC` | 6091 pass, 0 fail | ✅ |
| Pester Tests (Linux hooks) | CI `poshqc / PowerShell hook suites (Linux)` | 3400 pass, 12 fail | ❌ |

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
| actionlint (wrapper) | `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` | not run (operator-pending) | ⚠️ |
| pytest parity | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 14 passed | ✅ |

**Notes:**
The 12 Linux failures are not pre-existing in CI terms, because the Linux job did not exist before this branch. They are pre-existing Windows-only path assumptions in hook test files that this branch is the first to expose. The spec makes fixing them a merge requirement.

---

## 8. Gaps and Exceptions

### Identified Gaps
- **AC-6 / AC-10 (Blocking):** 12 Linux-only failures remain. All raise `DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.` They come from drive-letter literals at `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1:46,338,345,351,357,365`, `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1:303`, `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1:304`, `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1:301`, and `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1:298`.
- **modified-workflow-needs-green-run (Blocking):** no green `_poshqc.yml` run on the branch head. This resolves with the gap above.
- **AC-5 / AC-21 (Blocking for AC completion; operator action):** `scripts/dev-tools/run-actionlint.ps1` has not been run.

### Approved Exceptions
- Operator decision of 2026-10-01: pwsh is not run in agent worktrees. PowerShell format, analyze, and test evidence comes from the PoshQC MCP tools plus CI logs and artifacts (plan deviations D1 to D14). This audit accepts that evidence route for format, analyze, and Pester. It does not accept it as a substitute for the explicitly named `run-actionlint.ps1` command in AC-5.

### Removed/Skipped Tests
**None.** No unconditional skip was added: the `-Skip` scan of the hook-suite diff returned a count of 0 (`evidence/qa-gates/no-unconditional-skip.2026-10-01T17-57.md`).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **6e3dc26c, 4d1e005e, 049982e6, 4212bdec, 0c18afaf, 81b61249, d99942a4** - research, spec, plan, and preflight revisions
2. **7282fb31** - merge `origin/main`
3. **b4ba5b30** - Phase 0 baseline evidence
4. **10d71c99** - fail-before regression tests (Linux job and kcov trace)
5. **0285440a** - `fix(743)`: kcov trace environment in `run_test`
6. **90b6bd4a** - `ci(743)`: Linux hook-suite job
7. **4392b930** - first Linux run evidence and AC-10 inventory
8. **3f85b23d** - out-of-band WIP checkpoint (plan deviation D13)
9. **a412698b** - portable Codex hook suites
10. **575fff5f, df68a0cf, ecba8829, 630237f4** - evidence, skill guidance, final QC, and CI evidence

### Files Modified

1. **`.github/workflows/_poshqc.yml`** (MODIFIED) - new `poshqc-linux-hooks` job; `poshqc` job unchanged.
2. **`scripts/bash/kcov_trace_env.sh`** (NEW) - kcov v43 PS4 and `set -x`.
3. **`scripts/bash/shell_qc_lib.sh`** (MODIFIED) - `run_test` sets `BASH_ENV` and `BASH_XTRACEFD`.
4. **`tests/shell/test_shell_qc_commands.bats`** and three fixtures (NEW/MODIFIED) - regression tests.
5. **`tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`** (NEW) - workflow invariants.
6. **Three Codex hook test files** (MODIFIED) - OS-derived roots and `$IsWindows`-conditioned sandbox assertions.
7. **`atomic-plan-contract/SKILL.md`** and its bundle mirror (MODIFIED) - two guidance bullets.

---

## 10. Compliance Verdict

### Overall Status: ❌ NON-COMPLIANT

The implementation quality of the delivered changes is sound and coverage is above threshold. The branch does not meet its own merge criteria: the new Linux check is red on the branch head, so the modified workflow has no green run, and the actionlint wrapper named by AC-5 has not been run.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: research, spec, and plan present
- ✅ Design Principles: simple, isolated changes
- ✅ Module & File Structure: all files under 500 lines
- ✅ Naming, Docs, Comments: descriptive; rationale comments
- ❌ Toolchain Execution: Linux Pester fails; actionlint wrapper operator-pending
- ✅ Summarize & Document: commits and evidence present

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean
- ✅ PowerShell Design & Safety: test-only changes
- ✅ Structure & Naming: compliant
- ❌ Toolchain: Linux test step fails

**For Bash:**
- ✅ Tooling, design, and tests compliant

**For GitHub Actions:**
- ⚠️ actionlint wrapper pending; ❌ no green run on branch head

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ✅ Coverage & Scenarios: PowerShell 96.31%, Bash 93.7%, changed lines 8 of 8
- ✅ Test Structure: compliant
- ✅ External Dependencies: no temp files, stubs via seam
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ❌ Toolchain: Linux hook suites 12 failures

---

### Metrics Summary

- ✅ Windows Pester 6091 of 6101 passing (10 skipped, 0 failed)
- ❌ Linux hook suites 3400 of 3412 passing (12 failed)
- ✅ Bats 501 of 501 passing locally under the simulation
- ✅ PowerShell 96.31% line coverage; Bash 93.7% line coverage
- ✅ Proper file organization: tests under `tests/`, fixtures under `tests/fixtures/shell_qc/`
- ⚠️ Code quality checks: all clean except the operator-pending actionlint wrapper

---

### Recommendation

**Needs revision**

1. Replace the drive-letter literals at the 10 sites listed in Section 8 with OS-derived synthetic roots, following the pattern already applied in `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1:47-51`. Keep the Windows cases passing and add no unconditional skip.
2. Push, then obtain a run in which both `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` conclude `success` with `headSha` equal to the branch head. Record the run ID under `evidence/qa-gates/`.
3. Have the operator run `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` and record the output under `evidence/qa-gates/`.

---

## Appendix A: Test Inventory

### Complete Test List

1. `_poshqc.yml workflow invariants` › declares exactly the poshqc and poshqc-linux-hooks jobs
2. `_poshqc.yml workflow invariants` › keeps the poshqc job on windows-latest running Invoke-PoshQCTest
3. `_poshqc.yml workflow invariants` › runs the poshqc-linux-hooks job on ubuntu-latest under its check name
4. `_poshqc.yml workflow invariants` › grants the poshqc-linux-hooks job read-only repository contents
5. `_poshqc.yml workflow invariants` › limits the poshqc-linux-hooks Run.Path to the two hook-suite folders
6. `_poshqc.yml workflow invariants` › fails the poshqc-linux-hooks job on a failed test and collects no coverage
7. `_poshqc.yml workflow invariants` › uploads the poshqc-linux-hooks JUnit result under a distinct artifact name
8. `test_shell_qc_commands.bats` › test fails when a bats child sources a nounset library inside bash -c
9. `test_shell_qc_commands.bats` › test passes when a bats child resets nounset after sourcing
10. `test_shell_qc_commands.bats` › kcov_trace_env.sh sets the kcov PS4 format
11. Modified: `Codex epic-child launcher hardening` › uses inline project trust, ignores user config, and denies Codex install paths
12. Modified: `Codex epic-child launcher hardening` › preflights the elevated Windows sandbox from an isolated CODEX_HOME
13. Modified: `Codex epic-child launcher hardening` › repeats the exact terminal receipt timestamp under the matching status key
14. Modified: `epic-child-worktree-launcher` › builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree
15. Modified: `Codex enforce-epic-worktree-removal-gate decision surface (issue #545)` › 9 It blocks using `$script:SyntheticRoot` / `$script:SyntheticTarget`

---

## Appendix B: Toolchain Commands Reference

```bash
# Scope and evidence location (run by this review)
git diff --stat 41217012d31d35c2ee33a50be50684affd2f5f43..HEAD -- . ':!docs'
git diff --name-only ecba8829604f6265dc491c74cf42546f9d5aab57..HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
git diff --name-only 41217012..HEAD | grep -c -E '^(\.github/workflows/(_quality-checks|_drm-copilot-extension-tests|ci|_shell-coverage)\.yml|scripts/powershell/PoshQC/settings/pester\.runsettings\.psd1|\.claude/rules/|\.github/instructions/)'
cmp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md
grep -o '<counter type="LINE"[^>]*>' artifacts/pester/powershell-coverage.xml | tail -1

# Bash (executor evidence)
sh scripts/bash/shell-qc.sh format
sh scripts/bash/shell-qc.sh check
shellcheck -f gcc scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh
npx --yes bats tests/shell/test_shell_qc_commands.bats tests/shell/test_shell_qc_discovery.bats

# Workflow
actionlint .github/workflows/_poshqc.yml
# operator-pending:
pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml

# CI evidence
gh run view 36901896617 --json jobs,headSha
gh run view 36901896617 --log --job 110502826491 | grep -F 'Tests Passed:'
gh run view 36901896617 --log --job 110502826187 | grep -F 'Tests Passed:'
gh run view 36901896617 --log --job 110502826537 | grep -F 'Bash coverage (lines):'

# Python parity
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
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

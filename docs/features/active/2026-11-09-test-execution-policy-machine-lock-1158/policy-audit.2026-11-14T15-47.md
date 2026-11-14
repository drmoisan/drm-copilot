# Policy Compliance Audit: Test-execution policy and machine test-suite lock (issue #1158), re-audit after remediation cycle 1

---

**Audit Date:** 2026-11-14  
**Code Under Test:** merge base `add7d747886ce893356b63de2941435f2895b345` of the base branch `origin/main` and reviewed head `6a6a85a23701f4413349fad33f59663e09314757`; the diff between them lists the changed files (364 files, 24564 insertions, 510 deletions)

Review context: re-audit at the exit of remediation cycle 1 (findings F1 and F2 of `remediation-inputs.2026-11-14T11-44.md`, and the coordinator-directed item C1). Scope is the full branch diff against the merge base, not the remediation plan. Scope sources: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-11-14 15:37:41 UTC at the reviewed head) and `git diff --name-status add7d7478..6a6a85a23`. `origin/main` was fetched and still equals the merge base, so no main sync was needed. No pull request exists for the branch yet, so no CI run exists for the reviewed head.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 58 files (hooks, launcher scripts, PoshQC modules, templates, bundle mirrors and tests) | 26420 tests | ✅ 26402 pass, 0 fail, 18 skipped | 95.80% lines (37558/39203) | 95.95% lines (43560/45399) | 91.07% to 100% per new production file (lowest `scripts/dev-tools/run-poshqc-suite.ps1` 91.07%); `PoshQC.Parallel.psm1` 97.74% with all 23 lines added this cycle covered |
| Python | 17 files (7 production modules, 10 test files); none changed this cycle | 16933 items | ✅ 16927 pass, 0 fail, 6 skipped | 72.91% lines, 65.44% branches (the seven changed modules) | 98.83% lines, 96.41% branches (the seven changed modules); repo-wide 97.74% lines, 95.13% branches | 93.58% lines minimum per changed module |
| Bash | 4 files (`run-test-suite.sh` and its bundle copies, `tests/shell/test_run_test_suite.bats`, two stub fixtures); none changed this cycle | 803 tests | ✅ 803 pass, 0 fail | N/A - no pre-change run | 95.0% lines (3460/3643, kcov) | 100% (`run-test-suite.sh`, kcov) |
| TypeScript | 0 files | 5616 tests (regression run) | ✅ 5616 pass, 0 fail | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |
| JSON / TOML | 12 files | N/A | ✅ registry, config, settings, tasks and manifest tests pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - zero changed TypeScript files`
- TypeScript post-change coverage artifact: `N/A - zero changed TypeScript files`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/baseline/pester-suite.2026-11-10T04-17.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (recorded in `evidence/qa-gates/pester-suite.2026-11-14T15-28.md`)
- Python baseline coverage artifact: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/baseline/pytest-suite.2026-11-10T04-23.md`
- Python post-change coverage artifact: JSON report recorded in `evidence/qa-gates/pytest-suite.2026-11-14T15-28.md`; earlier `artifacts/python/lcov.info` recorded in `evidence/qa-gates/pytest-suite.2026-11-14T11-27.md` (no Python file changed after it)
- Bash post-change coverage artifact: `evidence/qa-gates/bats-suite.2026-11-14T10-59.md` (kcov); no shell file changed after it
- Per-language comparison summary: section 1.2.1 of this audit and `evidence/qa-gates/coverage-comparison.2026-11-14T15-30.md`

The reviewer parsed `artifacts/pester/powershell-coverage.xml` directly (written 15:21 UTC, before the evidence-only commits `00ff6e290`, `634d2319f` and `6a6a85a23`): the root LINE counter is 43560 covered and 1839 missed (95.95%). The `PoshQC.Parallel.psm1` LINE counter is 173 covered and 4 missed; the missed lines (322, 323, 325, 326) are the unchanged default `StartShardProcess` body, so every line added this cycle (`TestPath`, `ResolveTestFile`, `Resolve-PoshQCParallelTestFile`) is covered. The commits after the 15:21 Pester run add only evidence records, so the artifact describes the production code at the reviewed head. The reviewer did not rerun any suite (owner directive OD-5; evidence model).

---

## Executive Summary

The branch adds a configurable test-execution policy, a launcher with a POSIX shim and a Pester suite entry, a machine-wide advisory lock outside every worktree, a PreToolUse hook (Claude and Codex twins) that denies direct runners, hidden wrapper launches, lane selections, worker-reduction tokens and launcher seam overrides, PoshQC lane-exclusion parameters, launcher routing in `fix_all`, the atomic-executor QC runner and the VS Code tasks, skill and agent text, and ledger entry `0012`.

Remediation cycle 1 resolved both blocking findings of the first review and the coordinator-directed item:

1. F1 resolved: the atomic-executor `## Toolchain Commands` Python and PowerShell bullets (Claude, bundle, Codex base and five variants with bundle copies), `python-qa-gate` step 4 (four copies) and the Copilot `python-atomic-executor` step 4 (two copies) name the launcher suites. New `PGW-LAUNCHER-*` wording rows forbid the direct forms and were recorded failing on the pre-edit text. Ledger entries `0001`, `0006` and `0011` were regenerated, and the ledger chain suites pass.
2. F2 resolved: user-story AC4 was rewritten to spec D31 branch B under orchestrator decision ORCH-D7 and checked off against the Registration, guard-completeness, no-Python and pack-manifest test evidence; spec AC5 and D30 now name entry `0012`.
3. C1 delivered: `Invoke-PoshQCParallelTest -TestPath` with the `ResolveTestFile` seam provides a scoped parallel Pester entry reachable through the launcher; the policy text in the test-execution-policy skill, the execution-environment brief and the atomic-plan-contract task-check bullet (all copies) names it.

Local gate evidence at the final cycle-1 run is green: Pester 26420 tests with 0 failures, pytest 16927 passed, extension Jest 5616 passed, and a clean PowerShell static loop. Coverage meets every governing threshold with no regression. No blocking finding remains.

Verdict: PASS.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md`
- ✅ `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ Bash: shfmt and shellcheck through `scripts/bash/shell-qc.sh check`; bats with kcov
- N/A `typescript-code-change.instructions.md`: no TypeScript file in the branch diff
- ✅ JSON: config, registries, tasks and manifests parsed by their contract tests

**Temporary artifacts cleanup:**
- ✅ Scratch scripts named in evidence (`SCRATCH/issue-1158-*`) live in the issue scratch directory, outside the repository; none is in the branch diff.
- ✅ `git status --porcelain` at the reviewed head was empty before this review wrote its artifacts.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Pester ran in 8 parallel shards and pytest under 24 xdist workers with 0 failures (`pester-suite.2026-11-14T15-28.md`, `pytest-suite.2026-11-14T15-28.md`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | The new `PoshQC.ParallelScoped.Tests.ps1` has one behavior per `It` (PS01 to PS12). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 918.69 s on 8 workers; pytest 205.50 s; the new scoped suite runs with seams and starts no process. |
| **Determinism** - Consistent results | ✅ PASS | Process start, wait, reset, read, write, clock and logger are injected; the default seam's `Test-Path` and `Get-ChildItem` are mocked in module scope. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Test ids and names state scenario and outcome; the file header names the seams. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 95.80% lines; Python 72.91% lines, 65.44% branches over the seven modules<br>**Command:** `Invoke-PoshQCParallelTest`; scoped `poetry run pytest -n auto --cov=...`<br>**Artifact:** `evidence/baseline/pester-suite.2026-11-10T04-17.md`, `evidence/baseline/pytest-suite.2026-11-10T04-23.md`<br>**Timestamp:** 2026-11-10 04:17, 04:23 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.95% lines; Python 98.83% lines, 96.41% branches over the changed modules<br>**Change:** +0.15 pt PowerShell; +25.92 pt Python lines, +30.97 pt branches<br>**Status:** no per-file drop (`coverage-comparison.2026-11-14T15-30.md`; `PoshQC.Parallel.psm1` 97.37% to 97.74%, verified by the reviewer's parse) |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest PowerShell `scripts/dev-tools/run-poshqc-suite.ps1` 91.07%; lowest Python `qc_runner.py` 93.58% lines, 81.82% branches<br>**Thresholds:** 85% line; 75% branch for Python; no PowerShell or bash branch threshold<br>**Status:** all changed production files meet the thresholds |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** 13 new production files; `PoshQC.Parallel.psm1` modified this cycle<br>**New code coverage:** 91.07% to 100% per new file; 23 of 23 lines added this cycle covered<br>**Calculation method:** per-file LINE counters and per-line `mi`/`ci` values from `artifacts/pester/powershell-coverage.xml`; kcov for `run-test-suite.sh` |
| **Comprehensive Coverage** | ✅ PASS | Hook helpers 96.74% to 100% in both twins; Claude hook entry 91.67%, Codex hook entry 98.54%; launcher 92.93%; `Invoke-PesterSuite.ps1` 94.74%. Uncovered lines are default seam bodies. |
| **Positive Flows** - Valid inputs | ✅ PASS | Scoped run with two resolved files starts two shards bound to the resolved list (PS03); free-lock launcher runs; allowed launcher commands including the scoped `pester -TestPath` row. |
| **Negative Flows** - Invalid inputs | ✅ PASS | No resolved file returns `ExitCode` 1 and names each path (PS06); absent and non-test paths dropped (PS11); the hook denies a lane path after `-TestPath`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Folder plus a file inside it yields the file once (PS08, PS10); a quote inside a path parses (PS01); worker count capped by file count (PS03, PS04); mixed-case lane suffix (PS12). |
| **Error Handling** - Error paths | ✅ PASS | Zero-file scoped run returns before any shard starts; dependency-guard failure, throwing suite, unreadable holder and script cases from earlier cycles remain green. |
| **Concurrency** - If applicable | ✅ PASS | Lock state model rows, `run_fix_all` no-overlap case, and the live Linux two-process proof (`evidence/other/lock-two-process-proof.2026-11-11T05-21.md`). |
| **State Transitions** - If applicable | ✅ PASS | Driver loop under an injected clock: each decision before 90000 ms is `Wait`, the decision at 90000 ms is `Timeout`. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.95% lines. Change: +0.15 pt lines. New/changed-code coverage: 91.07% lines (lowest new production file). Disposition: PASS. Evidence: `evidence/baseline/pester-suite.2026-11-10T04-17.md`, `evidence/qa-gates/pester-suite.2026-11-14T15-28.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 72.91% lines (from the `Phase 0 baseline` artifact) -> Post-change: 98.83% lines. Change: +25.92 pt lines, branches 65.44% to 96.41%. New/changed-code coverage: 93.58% lines (lowest changed module). Disposition: PASS. Evidence: `evidence/baseline/pytest-suite.2026-11-10T04-23.md`, `evidence/qa-gates/pytest-suite.2026-11-14T15-28.md`.
- Bash: Baseline: N/A - no pre-change run -> Post-change: 95.0% lines. Change: none computable. New/changed-code coverage: 100% lines (`run-test-suite.sh`). Disposition: PASS. Evidence: `evidence/other/bats-deviation.2026-11-10T04-26.md`, `evidence/qa-gates/bats-suite.2026-11-14T10-59.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact-text assertions with `-Because` text in PS03 and the wording rows. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New `It` blocks carry Arrange, Act and Assert sections. |
| **Document Intent** | ✅ PASS | File and block comments name issue #1158 and C1 or F1. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The scoped suite uses a synthetic root (`parallel-scoped-root`) and recording seams; no process starts. |
| **Use Mocks/Stubs** | ✅ PASS | Recording seams for shard start, resolver and logger; module-scope mocks for `Test-Path` and `Get-ChildItem`. |
| **Environment Stability** | ✅ PASS | `Invoke-PoshQCLeakScan` 0 failures (`powershell-static.2026-11-14T15-29.md`); no temporary file. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-14T15-32.md` and this audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1158; `spec.md` decisions D1-D33; remediation inputs F1, F2 and C1. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-14T11-44.md`; main-sync and ledger-region records under `evidence/other/`. |
| **Document the plan** | ✅ PASS | All 19 remediation tasks are checked; commits carry `(#1158)` and the `reduction:` tokens of the regenerated entries. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The scoped entry is one optional parameter and one seam on the existing runner; the launcher reaches it with no code change. |
| **Reusability** | ✅ PASS | The resolver reuses `Select-PoshQCLaneTestFile` for the lane suffix rule and the existing `ScanFolders` route in each shard. |
| **Extensibility** | ✅ PASS | Omitting `-TestPath` keeps today's command text, worker count and seam calls (PS02, PS07). |
| **Separation of concerns** | ✅ PASS | File resolution is a seam; the runner logic is unchanged apart from the worker cap. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One concern per helper file; the resolver sits in the parallel module it serves and is not exported. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest covered file in the diff is `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` at 689 logical lines; `PoshQC.Parallel.psm1` 543; `PoshQC.ParallelScoped.Tests.ps1` 270; no covered file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | `Resolve-PoshQCParallelTestFile` is not in the module export list. |
| **No circular dependencies** | ✅ PASS | No new import. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `TestPath`, `ResolveTestFile`, `Resolve-PoshQCParallelTestFile`. |
| **Docs/docstrings** | ✅ PASS | `.PARAMETER` help for both new parameters; the PoshQC README states the scoped route; the stale direct-runner instructions of F1 are replaced in every copy. |
| **Comment why, not what** | ✅ PASS | The comment explaining why shards receive the resolved list and why the worker count is capped. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` check form; `black --check`; shfmt; Prettier<br>**Result:** 0 changes (`powershell-static.2026-11-14T15-29.md`, `phase-gate.P2.2026-11-14T15-00.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` over 1742 files; `ruff check`; shellcheck; ESLint<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`; `tsc`<br>**Result:** 0 errors; N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** the launcher `pester`, `pytest` and `jest-extension` suites<br>**Result:** 0 failures in each |
| **Full toolchain loop** | ✅ PASS | Phase gates P1 and P2 and the final loop are clean; the Codex generator `--check` passed. The reviewer ran `check_quality_tiers` at the reviewed head: `quality-tiers: OK (35 entries, 35 discovered projects)`. |
| **Explicit reporting** | ✅ PASS | Each gate has an append-only record with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`. The PSScriptAnalyzer tool fault on an unchanged file in the first final static run is disclosed in `powershell-static.2026-11-14T15-29.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages and the executor self-review. |
| **Design choices explained** | ✅ PASS | Remediation plan execution constraints and the ledger-region inventory `ledger-regions.2026-11-14T12-51.md`. |
| **Update supporting documents** | ✅ PASS | Executor toolchain lists, `python-qa-gate` step 4, the Copilot Python executor, the test-execution-policy skill, the brief and the plan contract updated in every copy; ledger entries regenerated. |
| **Provide next steps** | ✅ PASS | CI on the pull-request head (S348) is the remaining step. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** 1070 files unchanged (`phase-gate.P2.2026-11-14T15-00.md`) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check --no-fix`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors |
| **Testing with Pytest** | ✅ PASS | **Command:** launcher `pytest` suite with coverage extras<br>**Result:** 16927 passed, 6 skipped |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Unchanged since the first review; pyright clean. |
| **Dataclasses for value objects** | ✅ PASS | `PreflightQCResult` frozen dataclass carries the launcher outcome. |
| **Protocols/ABCs for interfaces** | N/A | No new interface with multiple implementations. |
| **Avoid utility classes** | ✅ PASS | Module-level functions. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `LauncherRefusedError`; `RuntimeError` only for a classified test-step exit. |
| **Logging over print** | ✅ PASS | No `print` added. |
| **Invariants at construction** | ✅ PASS | Launcher exits are classified once, before early returns (D28). |

---

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .` with a no-op writer<br>**Result:** 0 `Formatted:` lines over 1742 files |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** 0 findings over 1742 files |
| **Fix all findings** | ✅ PASS | None open. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Repository targets PowerShell 7+; `[IO.Path]::GetRelativePath` is available in PowerShell 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `Resolve-PoshQCParallelTestFile` has `[CmdletBinding()]` and `[OutputType([string[]])]`. |
| **Parameter validation** | ✅ PASS | `Mandatory` and `AllowEmptyCollection` on the resolver parameters. |
| **Avoid global state** | ✅ PASS | No new script or global state; the resolver seam is a parameter. |
| **Error handling** | ✅ PASS | A zero-file scoped run logs the paths and returns `ExitCode` 1 without starting a shard. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | `PoshQC.Parallel.psm1` 543 logical lines; largest production PowerShell file 632. |
| **Approved verbs** | ✅ PASS | `Resolve` is approved; PSScriptAnalyzer clean. |
| **Comment why** | ✅ PASS | Rationale comments for the resolved list and the worker cap. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 changes. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 26420 tests, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | Final pass clean after the phase gates. |

---

### Section 3C: Bash Script Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | `scripts/bash/shell-qc.sh check` exit 0 (`phase-gate.P2.2026-11-14T15-00.md`). |
| **Linting with shellcheck** | ✅ PASS | Same run, 0 findings. |
| **Testing with bats** | ✅ PASS | 803 tests, 0 failures; kcov 95.0%; `run-test-suite.sh` 100% (`bats-suite.2026-11-14T10-59.md`); no shell file changed afterwards. |
| **Portable shebang and error handling** | ✅ PASS | `#!/bin/sh`, `set -eu`, `exec` passes the `pwsh` exit status through. |

---

### Section 3D: JSON Configuration Policy Compliance (if applicable)

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | N/A | No changed JSON file is governed by `scripts/dev_tools/json_config.py`. |
| **Schema validation** | ✅ PASS | `config/test-execution-policy.json` validated by `test-execution-policy.RepoConfig.Tests.ps1`; registries by the Registration and dispatcher tests. |
| **Required $schema** | N/A | Not governed by a `$schema` rule. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Parsed by `ConvertFrom-Json` in the tests; `.vscode/tasks.json` keeps its existing JSONC form. |
| **Deterministic key order** | ✅ PASS | Registry order is semantic (hook order). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | pytest with xdist through the launcher. |
| **Coverage expectation** | ✅ PASS | Seven changed modules at 98.83% lines and 96.41% branches; the local JSON report gives repo-wide 97.74% lines and 95.13% branches. The CI step `Enforce Python coverage thresholds` has not run (no pull request) and is recorded in `## CI Cross-check`. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One test file per changed module. |
| **Mocking sparingly** | ✅ PASS | `monkeypatch` for `subprocess.run` and `shutil.which`. |
| **Organization** | ✅ PASS | Mirrors `scripts/dev_tools/` under `tests/scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<behavior>` names. |
| **Docstrings/comments** | ✅ PASS | Unchanged since the first review. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** launcher `pytest` suite<br>**Result:** 16927 passed |
| **No Alternative Test Runners** | ✅ PASS | pytest only. |

---

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Pester through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** launcher `pester` suite, which calls `Invoke-PoshQCParallelTest`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions on bound `ScanFolders` constants (AST binding), worker counts, exit codes and log text. |
| **Mocking Used Sparingly** | ✅ PASS | Seams; `Mock` only for `Test-Path` and `Get-ChildItem` in the resolver cases. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/powershell/PoshQC/PoshQC.ParallelScoped.Tests.ps1`<br>**Code file:** `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites. |
| **Describe/Context/It Structure** | ✅ PASS | Describe per function. |
| **Logical Grouping** | ✅ PASS | Shard text, runner, default resolver. |
| **Docstrings/Comments** | ✅ PASS | Header comment per suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`<br>**Result:** 26420 tests, 0 failures, 18 skipped |
| **No Alternative Test Runners** | ✅ PASS | Task checks used the scoped launcher route (`-TestPath`) from P1-T2 on, in place of one-process Pester runs. |

---

## 5. Test Coverage Detail

### Scoped parallel entry (`PoshQC.Parallel.psm1`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| PS01, PS02 shard text with and without `TestPath` | Positive, Edge Case | `Get-PoshQCParallelShardArgument` | ✅ |
| PS03 to PS08 runner worker cap, seam call, zero files, no `TestPath`, de-duplication | Positive, Negative, Edge Case | `Invoke-PoshQCParallelTest` scoped branch | ✅ |
| PS09 to PS12 default resolver | Positive, Negative, Edge Case | `Resolve-PoshQCParallelTestFile` | ✅ |

**Coverage:** 97.74% (173/177); every line added this cycle covered

**Not covered:** lines 322, 323, 325, 326 (unchanged default `StartShardProcess` body)

### Hook helpers, launcher and hook entry

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| policy defaults and validation; lock decision rows; command forms | Positive, Negative, State Transition | helper modules | ✅ |
| launcher lock, exit propagation, cleanup; hook deny and allow rows including the scoped rows | Positive, Negative, Error Handling | launcher and hook entry | ✅ |

**Coverage:** 91.67% to 100% per file (see `pester-suite.2026-11-14T15-28.md`)

**Not covered:** default seam bodies (process start, real lock directory, stderr writer).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 26420 Pester; 16933 pytest items; 5616 Jest; 803 bats | ✅ |
| Tests Passed | 26402 Pester (18 skipped); 16927 pytest (6 skipped); 5616 Jest; 803 bats | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 918.69 s Pester; 205.50 s pytest | ✅ Fast |
| Average Time per Test | about 35 ms Pester per test on 8 workers | ✅ Fast |
| Discovery Time | not separately recorded by the gates | ✅ |
| Functions/Classes Tested | every function of the hook helper files, the launcher, and the scoped entry | ✅ |
| Test File Size | 689 logical lines largest | ✅ PASS at or below 800 lines |
| Code Coverage (if applicable) | 95.95% PowerShell lines; 98.83% Python lines and 96.41% branches over the changed modules; 95.0% bash lines | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 1070 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check --no-fix` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | launcher `pytest` suite | 16927 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` check form | 0 changes | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings | ✅ |
| Pester Tests | launcher `pester` suite | 26420 tests, 0 failures | ✅ |

**Notes:**
- Reviewer real-process probe of `Resolve-PoshQCParallelTestFile` (imported from the worktree module; no suite run): a non-test file yields no entry; a path that leaves and re-enters the root through `..` resolves to the root-relative file; a folder with lane files and the suffix `integration.tests.ps1` yields 110 files with no lane file. Two spellings of one file that differ only in letter case (`PoshQC` and `poshqc`) are returned as two entries on Windows; recorded as an informational residual in the code review.
- Reviewer search of agent and skill surfaces for direct runner commands at the reviewed head: the F1 lines are gone. The remaining direct commands are in `.agents/skills/python/SKILL.md`, `.agents/skills/typescript/SKILL.md` (policy-mirror skills that spec D23 leaves unedited by design) and Copilot-only `.github/agents` and `.github/prompts` surfaces outside the hook's runtimes; none is in the branch diff. Recorded as informational.
- Mirror parity verified by the reviewer with `md5sum`: the six execution-environment copies, the six test-execution-policy copies, the three atomic-plan-contract pairs, the two python-qa-gate pairs, the atomic-executor pair, the Copilot python-atomic-executor pair, and both PoshQC module and README pairs are byte-identical.

---

## CI Cross-check

No pull request exists for the branch, so CI has not run on the reviewed head. Each row records the outcome claimed from the local evidence; the CI result is pending and is compared at S9.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC | pass | 26420 tests, 0 failures, 95.95% lines | 6a6a85a23701f4413349fad33f59663e09314757 | `evidence/qa-gates/pester-suite.2026-11-14T15-28.md`; CI pending (no PR) |
| poshqc / PowerShell hook suites (Linux) | pass | Windows run green; Linux run CI-dependent | 6a6a85a23701f4413349fad33f59663e09314757 | `evidence/qa-gates/pester-suite.2026-11-14T15-28.md`; CI pending (no PR) |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 16927 passed; `check_quality_tiers` OK (reviewer run) | 6a6a85a23701f4413349fad33f59663e09314757 | `evidence/qa-gates/pytest-suite.2026-11-14T15-28.md`; CI pending (no PR) |
| Enforce Python coverage thresholds | pass | repo-wide 97.74% lines, 95.13% branches (local JSON report) | 6a6a85a23701f4413349fad33f59663e09314757 | `evidence/qa-gates/pytest-suite.2026-11-14T15-28.md`; CI pending (no PR) |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | pass | 5616 passed, integration suites excluded locally | 6a6a85a23701f4413349fad33f59663e09314757 | `evidence/qa-gates/jest-extension-suite.2026-11-14T15-28.md`; CI pending (no PR) |
| shell-coverage / Shell Coverage (Bats + kcov) | pass | 803 tests, kcov 95.0% | 6a6a85a23701f4413349fad33f59663e09314757 | `evidence/qa-gates/bats-suite.2026-11-14T10-59.md`; CI pending (no PR) |

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <worktree>` exited 0 at the reviewed head. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. All evidence is under `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/<kind>/`, and the cycle-1 records are new stamped files; no earlier evidence file was edited or deleted in the cycle-1 commits.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists at the repository root and CI runs the `tier-classification` stage, so tiers are adopted. The reviewer ran `python -m scripts.dev_tools.check_quality_tiers` in the worktree at the reviewed head: `quality-tiers: OK (35 entries, 35 discovered projects)`. The new test file lives under an existing classified folder.

## Rejected Scope Narrowing

None. The caller prompt did not narrow the scope; the audit covers the full branch diff.

## Owner Directives

The caller relayed directives OD-1 to OD-9. This review honored OD-3 (existing worktree and branch, no new worktree), OD-4 (command shapes), OD-5 (no local suite run), OD-6 (append-only evidence; no evidence edited), OD-7 (`origin/main` fetched; it equals the merge base, so no merge was needed) and OD-8 (no related finding left for a separate issue). OD-1, OD-2 and OD-9 concern scheduling and merge steps that this review does not perform. Decision lines are in the final report.

---

## 8. Gaps and Exceptions

### Identified Gaps
- None blocking. F1 and F2 of the first review are resolved; C1 is delivered.

### Approved Exceptions
- Local gates exclude the integration and golden lanes by design (ledger entry `0012`, `evidence/other/lane-deviation.2026-11-14T15-30.md`); CI runs them.
- The bats baseline was not run on the host (`evidence/other/bats-deviation.2026-11-10T04-26.md`); the final bats gate ran on a WSL copy of the head.
- Ledger entry number `0012` instead of the spec's original `0011`; the spec text now names `0012`.
- User-story AC4 text changed under orchestrator decision ORCH-D7 to match spec D31 branch B.

### Removed/Skipped Tests
1. **Integration-named tests** - 41 Pester, 11 pytest and 16 Jest tests no longer run locally
   - **Reason:** the local lane exclusion is the feature under review.
   - **Impact:** CI jobs `poshqc`, `quality-checks7` and `drm-copilot-extension-tests` still run them.
   - **Justification:** spec D13 and D30; no coverage drop is attributable (`coverage-comparison.2026-11-14T15-30.md`).

---

## 9. Summary of Changes

The branch serializes local test suites through one launcher under a per-user machine lock, excludes the integration and golden lanes locally, enforces both through a PreToolUse hook on Bash and the two PoshQC MCP test tools in both runtimes, and (cycle 1) adds a scoped parallel Pester route for task checks and fail-before proofs.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

Code, tests, coverage, file size, evidence location, tier classification, documentation-surface and instruction-surface checks comply. No blocking finding remains. CI on the pull-request head is pending and is checked at S9.

**Fail-closed reminder:** merge readiness still depends on CI green on the pull-request head.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan, remediation plan and spec present
- ✅ Design Principles: compliant
- ✅ Module & File Structure: no covered file at or above 700 lines
- ✅ Naming, Docs, Comments: instruction surfaces name the launcher
- ✅ Toolchain Execution: clean
- ✅ Summarize & Document: user story aligned with D31

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean
- ✅ Python Design & Typing: typed
- ✅ Error Handling: specific exceptions

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: seams, explicit zero-file failure
- ✅ Structure & Naming: compliant
- ✅ Toolchain: green

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ✅ Coverage & Scenarios: thresholds met, no regression
- ✅ Test Structure: AAA
- ✅ External Dependencies: seams and stubs
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: pytest
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: green

**For PowerShell:**
- ✅ Framework & Scope: Pester via PoshQC
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: green

---

### Metrics Summary

- ✅ 26420 Pester tests, 0 failures; 16927 pytest passed; 5616 Jest passed; 803 bats passed
- ✅ 95.95% PowerShell line coverage; new production files 91.07% to 100%
- ✅ Changed Python modules 98.83% lines, 96.41% branches
- ✅ Test files mirror source layout
- ✅ Direct-runner instructions replaced in every copy (F1)
- ✅ User-story AC4 aligned and checked off (F2)

---

### Recommendation

**Ready for PR**

Open the pull request and confirm CI green on its head, including `poshqc / PowerShell hook suites (Linux)` and the CI integration lanes; then check off spec S348 at S9.

---

## Appendix A: Test Inventory

### Complete Test List

New or extended suites in this cycle (individual cases are enumerated in `artifacts/pester/pester-junit.xml`, 26420 test cases):

1. `tests/scripts/powershell/PoshQC/PoshQC.ParallelScoped.Tests.ps1` › PS01 to PS12 (12 cases)
2. `tests/scripts/claude-skills/test-execution-policy/Invoke-PesterSuite.Tests.ps1` › TestPath reach through the default `GetParameterName` (one case per copy)
3. `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` › scoped allow row and scoped lane-path deny row
4. `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` › `PGW-LAUNCHER-*` (14 rows) and `PGW-SCOPED-*` (6 rows)
5. `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` › `BRIEF` and `CANONICAL` rows requiring `-TestPath`

Suites from earlier cycles are listed in `policy-audit.2026-11-14T11-44.md` Appendix A.

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
env -u VIRTUAL_ENV poetry run black --check .
env -u VIRTUAL_ENV poetry run ruff check --no-fix
env -u VIRTUAL_ENV poetry run pyright
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov-branch --cov-report=term-missing --cov
```

**For PowerShell:**
```bash
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <test files or folders>
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-14  
**Policy Version:** Current (as of audit date)

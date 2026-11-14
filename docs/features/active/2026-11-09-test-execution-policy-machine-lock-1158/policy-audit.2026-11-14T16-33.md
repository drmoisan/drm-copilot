# Policy Compliance Audit: Test-execution policy and machine test-suite lock (issue #1158), review at the PR #1184 head

---

**Audit Date:** 2026-11-14  
**Code Under Test:** merge base `add7d747886ce893356b63de2941435f2895b345` of the base branch `origin/main` and reviewed head `9262895e3b135d1daee942f3239fe9b926a127ef` (PR #1184); the diff between them lists the changed files (370 files, 25612 insertions, 510 deletions)

Review context: review at the live pull-request head after the S9 check-off commit. Scope is the full branch diff against the merge base. Scope sources: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (refreshed at the reviewed head) and `git diff --name-status add7d7478..9262895e3`. `origin/main` was fetched during this review and still equals the merge base, so no main sync was needed.

Delta since the previous PASS review (`policy-audit.2026-11-14T15-47.md` at `6a6a85a23`): commits `250309516`, `171fa263c` and `9262895e3` change only Markdown and JSON documentation: the four review records of the previous review, the `Merge commit:` line of ledger entry `0012` (`PR #1158` replaced by `PR #1184`), a new stage-timing record, a new CI check-off record, and the spec Definition of Done line 348 check-off. No production, test, configuration or script file changed after `6a6a85a23`, so the local gate evidence recorded at `6a6a85a23` and the full CI run on `171fa263c` both describe the code at the reviewed head.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 58 files (hooks, launcher scripts, PoshQC modules, templates, bundle mirrors and tests) | 26420 tests | ✅ 26402 pass, 0 fail, 18 skipped; CI `poshqc` shards 1-3, static and Linux hook suites success | 95.80% lines (37558/39203) | 95.95% lines (43560/45399) | 91.07% to 100% per new production file (lowest `scripts/dev-tools/run-poshqc-suite.ps1` 91.07%) |
| Python | 17 files (7 production modules, 10 test files) | 16933 items | ✅ 16927 pass, 0 fail, 6 skipped; CI `quality-checks7` on 3.11, 3.12 and 3.13 success | 72.91% lines, 65.44% branches (the seven changed modules) | 98.83% lines, 96.41% branches (the seven changed modules); CI `Enforce Python coverage thresholds` success | 93.58% lines minimum per changed module |
| Bash | 4 files (`run-test-suite.sh` and its bundle copies, `tests/shell/test_run_test_suite.bats`, two stub fixtures) | 803 tests | ✅ 803 pass, 0 fail; CI `shell-coverage` success | N/A - no pre-change run | 95.0% lines (3460/3643, kcov) | 100% (`run-test-suite.sh`, kcov) |
| TypeScript | 0 files | 5616 tests (regression run) | ✅ 5616 pass, 0 fail; CI extension and root TypeScript tests success | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |
| JSON / TOML | 12 files plus one new stage-timing record | N/A | ✅ registry, config, settings, tasks and manifest tests pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - zero changed TypeScript files`
- TypeScript post-change coverage artifact: `N/A - zero changed TypeScript files`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/baseline/pester-suite.2026-11-10T04-17.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (present in the worktree, written 2026-11-14 15:21 UTC; recorded in `evidence/qa-gates/pester-suite.2026-11-14T15-28.md`)
- Python baseline coverage artifact: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/baseline/pytest-suite.2026-11-10T04-23.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (present in the worktree, written 2026-11-14 15:24 UTC) and the JSON report recorded in `evidence/qa-gates/pytest-suite.2026-11-14T15-28.md`
- Bash post-change coverage artifact: `evidence/qa-gates/bats-suite.2026-11-14T10-59.md` (kcov); no shell file changed after it
- Per-language comparison summary: section 1.2.1 of this audit and `evidence/qa-gates/coverage-comparison.2026-11-14T15-30.md`

Both coverage artifacts predate the reviewed head, and every commit after them changes documentation only, so they describe the production code at the reviewed head. The reviewer did not rerun any suite (owner directive OD-5; evidence model). The previous review parsed `artifacts/pester/powershell-coverage.xml` directly (root LINE counter 43560 covered, 1839 missed); the file is unchanged since then.

---

## Executive Summary

The branch adds a configurable test-execution policy, a launcher with a POSIX shim and a Pester suite entry, a machine-wide advisory lock outside every worktree, a PreToolUse hook (Claude and Codex twins) that denies direct runners, hidden wrapper launches, lane selections, worker-reduction tokens and launcher seam overrides, PoshQC lane-exclusion parameters including a scoped parallel Pester entry, launcher routing in `fix_all`, the atomic-executor QC runner and the VS Code tasks, skill and agent text, and ledger entry `0012`.

Both findings of the first review (F1, F2) were resolved in remediation cycle 1 and verified by the previous review. Since that review the branch gained only documentation commits. PR #1184 now exists: the full CI run 43613054239 on `171fa263c` concluded success with every job green, including `poshqc / PowerShell hook suites (Linux)`, the three PowerShell QC shards, Python 3.11 to 3.13 with `Enforce Python coverage thresholds` and `tier-classification`, root TypeScript and extension tests on Windows and Linux, and shell coverage. The docs-only run 43615712466 on the reviewed head concluded success with `CI Required Gate` passing. The PR is `MERGEABLE` with merge state `CLEAN`.

No blocking finding exists.

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
- ✅ Scratch scripts named in evidence live in the issue scratch directory, outside the repository; none is in the branch diff.
- ✅ `git status --short` at the reviewed head was empty before this review wrote its artifacts and its owner-directive decision file.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Pester ran in 8 parallel shards and pytest under xdist workers with 0 failures locally; CI ran Pester in three shards plus the Linux hook job with 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | New suites hold one behavior per `It` or test function (for example PS01 to PS12 in `PoshQC.ParallelScoped.Tests.ps1`). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 918.69 s on 8 workers; pytest 205.50 s; the hook and lock suites run on seams and start no process. |
| **Determinism** - Consistent results | ✅ PASS | Process start, wait, clock, logger and lock I/O are injected; local and CI runs agree. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Test ids and names state scenario and outcome; file headers name the seams. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 95.80% lines; Python 72.91% lines, 65.44% branches over the seven modules<br>**Command:** `Invoke-PoshQCParallelTest`; scoped `poetry run pytest -n auto --cov=...`<br>**Artifact:** `evidence/baseline/pester-suite.2026-11-10T04-17.md`, `evidence/baseline/pytest-suite.2026-11-10T04-23.md`<br>**Timestamp:** 2026-11-10 04:17, 04:23 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.95% lines; Python 98.83% lines, 96.41% branches over the changed modules<br>**Change:** +0.15 pt PowerShell; +25.92 pt Python lines, +30.97 pt branches<br>**Status:** no per-file drop (`coverage-comparison.2026-11-14T15-30.md`) |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest PowerShell `scripts/dev-tools/run-poshqc-suite.ps1` 91.07%; lowest Python `qc_runner.py` 93.58% lines, 81.82% branches<br>**Thresholds:** 85% line; 75% branch for Python; no PowerShell or bash branch threshold<br>**Status:** all changed production files meet the thresholds |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** 13 new production files<br>**New code coverage:** 91.07% to 100% per new file<br>**Calculation method:** per-file LINE counters from `artifacts/pester/powershell-coverage.xml`; kcov for `run-test-suite.sh`; per-module figures from the pytest JSON report |
| **Comprehensive Coverage** | ✅ PASS | Hook helpers 96.74% to 100% in both twins; Claude hook entry 91.67%, Codex hook entry 98.54%; launcher 92.93%; `Invoke-PesterSuite.ps1` 94.74%. Uncovered lines are default seam bodies. |
| **Positive Flows** - Valid inputs | ✅ PASS | Free-lock launcher runs; allowed launcher commands including the scoped `pester -TestPath` row; scoped run with two resolved files starts two shards. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Busy lock exits 75; direct runners, hidden wrappers, lane selections and worker tokens denied; zero resolved files returns `ExitCode` 1. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Quote inside a path; folder plus a file inside it de-duplicated; worker count capped; mixed-case lane suffix. |
| **Error Handling** - Error paths | ✅ PASS | Throwing suite releases the lock; unreadable holder; dependency-guard failure; classified launcher exits in Python callers. |
| **Concurrency** - If applicable | ✅ PASS | Lock state-model rows, `run_fix_all` no-overlap case, and the live Linux two-process proof (`evidence/other/lock-two-process-proof.2026-11-11T05-21.md`). |
| **State Transitions** - If applicable | ✅ PASS | Driver loop under an injected clock: each decision before 90000 ms is `Wait`, the decision at 90000 ms is `Timeout`. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.95% lines. Change: +0.15 pt lines. New/changed-code coverage: 91.07% lines (lowest new production file). Disposition: PASS. Evidence: `evidence/baseline/pester-suite.2026-11-10T04-17.md`, `evidence/qa-gates/pester-suite.2026-11-14T15-28.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 72.91% lines (from the `Phase 0 baseline` artifact) -> Post-change: 98.83% lines. Change: +25.92 pt lines, branches 65.44% to 96.41%. New/changed-code coverage: 93.58% lines (lowest changed module). Disposition: PASS. Evidence: `evidence/baseline/pytest-suite.2026-11-10T04-23.md`, `evidence/qa-gates/pytest-suite.2026-11-14T15-28.md`, CI run 43613054239 step `Enforce Python coverage thresholds` success.
- Bash: Baseline: N/A - no pre-change run -> Post-change: 95.0% lines. Change: none computable. New/changed-code coverage: 100% lines (`run-test-suite.sh`). Disposition: PASS. Evidence: `evidence/other/bats-deviation.2026-11-10T04-26.md`, `evidence/qa-gates/bats-suite.2026-11-14T10-59.md`, CI `shell-coverage` success.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact-text assertions with `-Because` text in the scoped and wording rows; pytest assertion messages name the expected exit class. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New `It` blocks and test functions carry Arrange, Act and Assert sections. |
| **Document Intent** | ✅ PASS | File and block comments name issue #1158 and the spec decision or finding they cover. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Hook, lock and scoped suites use synthetic roots and recording seams; no network or real process in unit tests. |
| **Use Mocks/Stubs** | ✅ PASS | Recording seams; `monkeypatch` for `subprocess.run` and `shutil.which`; `pwsh` stub fixtures for bats. |
| **Environment Stability** | ✅ PASS | `Invoke-PoshQCLeakScan` 0 failures (`powershell-static.2026-11-14T15-29.md`); no temporary file. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-14T15-32.md`, the previous review records, and this audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1158; `spec.md` decisions D1-D33. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-09T16-31.md`, `remediation-plan.2026-11-14T11-44.md`. |
| **Document the plan** | ✅ PASS | Plan and remediation tasks checked; commits carry `(#1158)` and the `reduction:` tokens of the touched ledger entries, including `171fa263c` for entry `0012`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One launcher, one lock helper, one policy reader; the scoped entry is one optional parameter and one seam. |
| **Reusability** | ✅ PASS | Hook helpers shared between the Claude and Codex twins by mirrored files; lane rule shared by the full and scoped routes. |
| **Extensibility** | ✅ PASS | Policy keys in `config/test-execution-policy.json` with defaults; omitting new parameters keeps prior behavior. |
| **Separation of concerns** | ✅ PASS | Pure decision modules (`test-execution-lock-decision.ps1`, `test-execution-command-form.ps1`) are separate from the I/O lock helper and the hook entry. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One concern per helper file. |
| **At or below the 800-line hard limit** | ✅ PASS | Reviewer logical line count (`awk 'END{print NR}'`) of all 80 added or modified covered files: largest `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` 689; largest production file `test-execution-command-form.ps1` 632 (four copies); no covered file at or above 700 lines; `config/file-size-baseline.json` not in the diff. |
| **Public vs internal** | ✅ PASS | Module-private helpers are not exported. |
| **No circular dependencies** | ✅ PASS | Helpers are dot-sourced by the hook entry only. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Invoke-TestSuite`, `Get-TestExecutionRunnerMatch`, `classify_launcher_exit`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help and Python docstrings; the test-execution-policy skill documents keys, lock, exit codes and the scoped route. |
| **Comment why, not what** | ✅ PASS | Rationale comments on lock placement outside worktrees and on the worker cap. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` check form; `black --check`; shfmt<br>**Result:** 0 changes locally; CI Black step success |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer`; `ruff check`; shellcheck<br>**Result:** 0 findings locally; CI Ruff and `PowerShell QC static` success |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`<br>**Result:** 0 errors locally; CI Pyright step success; N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** the launcher `pester`, `pytest` and `jest-extension` suites; CI jobs<br>**Result:** 0 failures locally and in CI run 43613054239 |
| **Full toolchain loop** | ✅ PASS | Phase gates and the final loop clean; CI integration lanes (excluded locally by design) ran in run 43613054239 and passed. `tier-classification` step success in CI on Python 3.11 to 3.13. |
| **Explicit reporting** | ✅ PASS | Each gate has an append-only record with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`; the S9 record `evidence/qa-gates/ci-dependent-ac-checkoff.2026-11-14T16-26.md` carries the same fields. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages, the PR #1184 description and the executor self-review. |
| **Design choices explained** | ✅ PASS | `spec.md` decisions; ledger entry `0012`. |
| **Update supporting documents** | ✅ PASS | Ledger entry `0012` now names PR #1184; the README row is unchanged and still names issue #1158. |
| **Provide next steps** | ✅ PASS | Merge at S9 under the item's orchestrator run. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** unchanged locally; CI step `Check formatting with Black` success |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check --no-fix`<br>**Result:** All checks passed; CI step success |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors; CI step success |
| **Testing with Pytest** | ✅ PASS | **Command:** launcher `pytest` suite with coverage extras<br>**Result:** 16927 passed, 6 skipped; CI `Run tests with Pytest and coverage` success |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Annotated signatures; pyright clean. |
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
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** 0 findings over 1742 files; CI `PowerShell QC static` success |
| **Fix all findings** | ✅ PASS | None open. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Repository targets PowerShell 7+; CI ran the hook suites on Linux and the shards on Windows with 0 failures. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on new functions. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyCollection` and validated policy keys. |
| **Avoid global state** | ✅ PASS | Seams are parameters; no new global state. |
| **Error handling** | ✅ PASS | Busy lock exit 75; zero-file scoped run returns `ExitCode` 1; lock released in `finally`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest production PowerShell file 632 logical lines. |
| **Approved verbs** | ✅ PASS | PSScriptAnalyzer clean. |
| **Comment why** | ✅ PASS | Rationale comments present. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 changes. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 26420 tests, 0 failures locally; CI shards and Linux hook suites success. |
| **Rerun loop if needed** | ✅ PASS | Final pass clean after the phase gates. |

---

### Section 3C: Bash Script Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | `scripts/bash/shell-qc.sh check` exit 0 (`phase-gate.P2.2026-11-14T15-00.md`). |
| **Linting with shellcheck** | ✅ PASS | Same run, 0 findings. |
| **Testing with bats** | ✅ PASS | 803 tests, 0 failures; kcov 95.0%; CI `shell-coverage` success on `171fa263c`. |
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
| **Strict JSON only** | ✅ PASS | Parsed by `ConvertFrom-Json` in the tests; the new `stage-timing.2026-11-14T16-26.json` is strict JSON. |
| **Deterministic key order** | ✅ PASS | Registry order is semantic (hook order). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | pytest with xdist through the launcher; CI pytest with coverage. |
| **Coverage expectation** | ✅ PASS | Seven changed modules at 98.83% lines and 96.41% branches; CI `Enforce Python coverage thresholds` success on `171fa263c` (recorded in `## CI Cross-check`). |

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
| **Docstrings/comments** | ✅ PASS | Docstrings on new tests. |

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
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7 on Windows and Linux. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions on exit codes, deny reasons, bound command text and log text. |
| **Mocking Used Sparingly** | ✅ PASS | Seams first; `Mock` only for filesystem probes in resolver cases. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/*.Tests.ps1`, `tests/scripts/codex-hooks/*.Tests.ps1`, `tests/scripts/powershell/PoshQC/*.Tests.ps1`<br>**Code file:** `.claude/hooks/*.ps1`, `.codex/hooks/*.ps1`, `scripts/powershell/PoshQC/*.psm1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites. |
| **Describe/Context/It Structure** | ✅ PASS | Describe per function or contract. |
| **Logical Grouping** | ✅ PASS | Grouped by helper and by deny class. |
| **Docstrings/Comments** | ✅ PASS | Header comment per suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`<br>**Result:** 26420 tests, 0 failures, 18 skipped |
| **No Alternative Test Runners** | ✅ PASS | Task checks used the scoped launcher route (`-TestPath`). |

---

## 5. Test Coverage Detail

### Hook helpers, launcher and hook entry

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| policy defaults and validation; lock decision rows; command forms | Positive, Negative, State Transition | helper modules | ✅ |
| launcher lock, exit propagation, cleanup; hook deny and allow rows including the scoped rows | Positive, Negative, Error Handling | launcher and hook entry | ✅ |

**Coverage:** 91.67% to 100% per file (see `pester-suite.2026-11-14T15-28.md`)

**Not covered:** default seam bodies (process start, real lock directory, stderr writer).

### Scoped parallel entry (`PoshQC.Parallel.psm1`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| PS01 to PS12 | Positive, Negative, Edge Case | `Get-PoshQCParallelShardArgument`, `Invoke-PoshQCParallelTest` scoped branch, `Resolve-PoshQCParallelTestFile` | ✅ |

**Coverage:** 97.74% (173/177)

**Not covered:** lines 322, 323, 325, 326 (unchanged default `StartShardProcess` body)

### Python callers

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_cli_preflight.py`, `test_cli_task_runtime.py`, `test_qc_runner_expectations.py`, `test_qc_runner_launcher.py`, `test_fix_all_launcher_steps.py` | Positive, Negative, Error Handling | launcher routing and exit classification | ✅ |

**Coverage:** 93.58% to 100% lines per changed module

**Not covered:** none material; see `coverage-comparison.2026-11-14T15-30.md`.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 26420 Pester; 16933 pytest items; 5616 Jest; 803 bats | ✅ |
| Tests Passed | 26402 Pester (18 skipped); 16927 pytest (6 skipped); 5616 Jest; 803 bats | ✅ |
| Tests Failed | 0 locally; 0 in CI run 43613054239 | ✅ |
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
| Black Formatting | `poetry run black --check .` | unchanged; CI success | ✅ |
| Ruff Linting | `poetry run ruff check --no-fix` | All checks passed; CI success | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors; CI success | ✅ |
| Pytest Tests | launcher `pytest` suite | 16927 passed; CI success | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` check form | 0 changes | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings; CI static success | ✅ |
| Pester Tests | launcher `pester` suite | 26420 tests, 0 failures; CI shards and Linux hook suites success | ✅ |

**Notes:**
- The reviewer ran `validate_evidence_locations.py --root <worktree>` (exit 0) and `check_quality_tiers` (`quality-tiers: OK (35 entries, 35 discovered projects)`); the authoritative tier result is the CI `tier-classification` step, which succeeded on `171fa263c`.
- The reviewer did not rerun any suite (owner directive OD-5 and the evidence model).

---

## CI Cross-check

Head of the reviewed branch from `git log`: `9262895e3b135d1daee942f3239fe9b926a127ef`. Full CI run 43613054239 ran on `171fa263c499a2e2437702903f4648a6027d7417`; `git diff --name-only 171fa263c..9262895e3` lists only the stage-timing record, the CI check-off record and `spec.md`, so the code under that run equals the code at the reviewed head. Run 43615712466 on the reviewed head is a docs-only run (heavy jobs skipped by change scope) and concluded success.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC (shards 1-3 and static) | pass | 26420 tests, 0 failures locally; 95.95% lines | 9262895e3b135d1daee942f3239fe9b926a127ef | `evidence/qa-gates/pester-suite.2026-11-14T15-28.md`; CI run 43613054239 success on `171fa263c` |
| poshqc / PowerShell hook suites (Linux) | pass | 0 failures | 9262895e3b135d1daee942f3239fe9b926a127ef | CI run 43613054239 success on `171fa263c` |
| quality-checks7 / Code Quality & Tests (3.11, 3.12, 3.13) | pass | 16927 passed locally; `tier-classification` success | 9262895e3b135d1daee942f3239fe9b926a127ef | `evidence/qa-gates/pytest-suite.2026-11-14T15-28.md`; CI run 43613054239 success |
| Enforce Python coverage thresholds | pass | changed modules 98.83% lines, 96.41% branches (local) | 9262895e3b135d1daee942f3239fe9b926a127ef | CI run 43613054239, job `quality-checks7 / Code Quality & Tests (3.13)`, step success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest, ubuntu-latest) | pass | 5616 passed locally | 9262895e3b135d1daee942f3239fe9b926a127ef | `evidence/qa-gates/jest-extension-suite.2026-11-14T15-28.md`; CI run 43613054239 success |
| root-typescript-tests (ubuntu-latest, windows-latest) | pass | no TypeScript file changed | 9262895e3b135d1daee942f3239fe9b926a127ef | CI run 43613054239 success |
| shell-coverage / Shell Coverage (Bats + kcov) | pass | 803 tests, kcov 95.0% | 9262895e3b135d1daee942f3239fe9b926a127ef | `evidence/qa-gates/bats-suite.2026-11-14T10-59.md`; CI run 43613054239 success |
| CI Required Gate | pass | all required jobs success | 9262895e3b135d1daee942f3239fe9b926a127ef | CI run 43615712466 on the reviewed head success; `gh pr view 1184`: `MERGEABLE`, `CLEAN` |

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <worktree>` exited 0 at the reviewed head. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/` (reviewer `git diff --name-only` filter returned no path). All evidence is under `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/<kind>/`. `git diff --name-status --diff-filter=MDR` over the evidence folder against the merge base returned no entry, so no evidence file was edited, deleted or renamed on the branch.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists at the repository root and CI runs the `tier-classification` stage, so tiers are adopted. The CI step succeeded on `171fa263c` for Python 3.11, 3.12 and 3.13; the reviewer's local run reported `quality-tiers: OK (35 entries, 35 discovered projects)`.

## Rejected Scope Narrowing

None. The caller prompt did not narrow the scope; the audit covers the full branch diff.

## Owner Directives

The caller relayed directives OD-1 to OD-9. The pass-down hook held this review for OD-9 only; its decision file records `refused` because merging is outside the review role. This review followed OD-3 (existing worktree and branch), OD-4 (command shapes), OD-5 (no local suite run), OD-6 (no evidence edited; new review records only), OD-7 (`origin/main` fetched; equals the merge base) and OD-8 (no related finding deferred to a separate issue). Decision lines are in the final report.

---

## 8. Gaps and Exceptions

### Identified Gaps
- None blocking.

### Approved Exceptions
- Local gates exclude the integration and golden lanes by design (ledger entry `0012`, `evidence/other/lane-deviation.2026-11-14T15-30.md`); CI ran them in run 43613054239 and they passed.
- The bats baseline was not run on the host (`evidence/other/bats-deviation.2026-11-10T04-26.md`); the final bats gate ran on a WSL copy and CI `shell-coverage` passed.
- Ledger entry number `0012` instead of the spec's original `0011`; the spec text names `0012`.
- User-story AC4 text changed under orchestrator decision ORCH-D7 to match spec D31 branch B.
- Ledger entry `0012` line `Merge commit:` was corrected from `pending (PR #1158)` to `pending (PR #1184)` in `171fa263c`; the entry is a ledger document, not evidence, and the commit carries the `reduction: 0012` token.

### Removed/Skipped Tests
1. **Integration-named tests** - 41 Pester, 11 pytest and 16 Jest tests no longer run locally
   - **Reason:** the local lane exclusion is the feature under review.
   - **Impact:** CI jobs `poshqc`, `quality-checks7` and `drm-copilot-extension-tests` still run them; all passed in run 43613054239.
   - **Justification:** spec D13 and D30; no coverage drop is attributable (`coverage-comparison.2026-11-14T15-30.md`).

---

## 9. Summary of Changes

The branch serializes local test suites through one launcher under a per-user machine lock, excludes the integration and golden lanes locally, enforces both through a PreToolUse hook on Bash and the two PoshQC MCP test tools in both runtimes, and adds a scoped parallel Pester route for task checks. Since the previous review, only documentation records changed.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

Code, tests, coverage, file size, evidence location, tier classification, documentation-surface and CI checks comply. No blocking finding exists.

**Fail-closed reminder:** merge readiness depends on CI green on the final PR head; it is green on `9262895e3` (run 43615712466) with the full code run green on `171fa263c` (run 43613054239).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan, remediation plan and spec present
- ✅ Design Principles: compliant
- ✅ Module & File Structure: no covered file at or above 700 lines
- ✅ Naming, Docs, Comments: instruction surfaces name the launcher
- ✅ Toolchain Execution: clean locally and in CI
- ✅ Summarize & Document: ledger entry names PR #1184

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean
- ✅ Python Design & Typing: typed
- ✅ Error Handling: specific exceptions

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: seams, explicit failures
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
- ✅ Changed Python modules 98.83% lines, 96.41% branches; CI coverage thresholds enforced and passed
- ✅ Test files mirror source layout
- ✅ Full CI run green on the code at the reviewed head; CI Required Gate green on the reviewed head

---

### Recommendation

**Ready for merge**

The PR head `9262895e3` is green and `CLEAN`; merge timing belongs to the item's orchestrator run at S9.

---

## Appendix A: Test Inventory

### Complete Test List

New or extended suites on the branch (individual cases are enumerated in `artifacts/pester/pester-junit.xml` and the pytest report):

1. `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1`, `test-execution-lock.Tests.ps1`, `test-execution-lock-decision.Tests.ps1`, `test-execution-command-form.Tests.ps1`, `enforce-test-execution-policy.Tests.ps1`, `test-execution-policy.Registration.Tests.ps1`, `test-execution-policy.RepoConfig.Tests.ps1`
2. `tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1`
3. `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1`, `Invoke-PesterSuite.Tests.ps1`
4. `tests/scripts/powershell/PoshQC/PoshQC.ParallelScoped.Tests.ps1`, `PoshQC.TestingLaneExclusion.Tests.ps1`, `PoshQC.McpTemplateLock.Tests.ps1`
5. `tests/scripts/dev_tools/atomic_executor/test_cli_preflight.py`, `test_cli_task_runtime.py`, `test_qc_runner_expectations.py`, `test_qc_runner_launcher.py`; `tests/scripts/dev_tools/test_fix_all_launcher_steps.py`
6. `tests/shell/test_run_test_suite.bats`
7. Wording rows in `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` and `test-cadence-wording.Tests.ps1`

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

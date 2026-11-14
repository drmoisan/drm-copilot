# Policy Compliance Audit: Test-execution policy and machine test-suite lock (issue #1158)

---

**Audit Date:** 2026-11-14  
**Code Under Test:** merge base `add7d747886ce893356b63de2941435f2895b345` of the base branch `origin/main` and reviewed head `c03f350da362989a3eb4b2153ec9cff5fef45447`; the diff between them lists the changed files (334 files, 22029 insertions, 423 deletions)

Review context: first feature review (S7) of the branch. Scope is the full branch diff against the merge base. Scope sources: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-11-14 11:35:30 UTC at the reviewed head) and `git diff --name-status add7d7478..c03f350da`. No pull request exists for the branch yet, so no CI run exists for the reviewed head.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 55 files (hooks, launcher scripts, PoshQC modules, templates, bundle mirrors and tests) | 26384 tests | ✅ 26366 pass, 0 fail, 18 skipped | 95.80% lines (37558/39203) | 95.95% lines (43537/45376) | 91.07% to 100% per new production file (lowest `scripts/dev-tools/run-poshqc-suite.ps1` 91.07%) |
| Python | 17 files (7 production modules, 10 test files) | 16933 items | ✅ 16927 pass, 0 fail, 6 skipped | 72.91% lines, 65.44% branches (the seven changed modules) | 98.83% lines, 96.41% branches (the seven changed modules) | 93.58% lines minimum per changed module; no missed line on a changed line |
| Bash | 4 files (`run-test-suite.sh` and its bundle copies, `tests/shell/test_run_test_suite.bats`, two stub fixtures) | 803 tests | ✅ 803 pass, 0 fail | N/A - no pre-change run | 95.0% lines (3460/3643, kcov) | 100% (`run-test-suite.sh`, kcov) |
| TypeScript | 0 files | 5616 tests (regression run) | ✅ 5616 pass, 0 fail | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |
| JSON / TOML | 12 files | N/A | ✅ registry, config, settings, tasks and manifest tests pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - zero changed TypeScript files`
- TypeScript post-change coverage artifact: `N/A - zero changed TypeScript files`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/baseline/pester-suite.2026-11-10T04-17.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (recorded in `evidence/qa-gates/pester-suite.2026-11-14T11-16.md`)
- Python baseline coverage artifact: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/baseline/pytest-suite.2026-11-10T04-23.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (recorded in `evidence/qa-gates/pytest-suite.2026-11-14T11-27.md`)
- Bash post-change coverage artifact: `evidence/qa-gates/bats-suite.2026-11-14T10-59.md` (kcov), confirmed current by `evidence/qa-gates/bats-suite.2026-11-14T11-20.md`
- Per-language comparison summary: section 1.2.1 of this audit and `evidence/qa-gates/coverage-comparison.2026-11-14T11-21.md`

The reviewer parsed `artifacts/pester/powershell-coverage.xml` directly (written 11:16 UTC): the root LINE counter is 43537 covered and 1839 missed (95.95%), and the per-file LINE counters of the 15 changed or new production PowerShell files under the coverage roots match the comparison record exactly (for example `.claude/hooks/test-execution-policy.ps1` 170/170, `.claude/hooks/test-execution-lock.ps1` 42/46, `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` 92/99). The reviewer parsed `artifacts/python/lcov.info` (written 11:27 UTC): 846/856 lines and 295/306 branches over the seven changed modules, matching the record. Commits after the 11:16 Pester run add only evidence records and one comment line in a Python test file, so the Pester artifact describes the production code at the reviewed head. The reviewer did not rerun any suite (owner directive: one suite at a time on this machine; evidence model).

---

## Executive Summary

The branch adds a configurable test-execution policy (`config/test-execution-policy.json`, validated defaults), a launcher (`Invoke-TestSuite.ps1` with the POSIX shim `run-test-suite.sh` and the `Invoke-PesterSuite.ps1` entry), a machine-wide advisory lock outside every worktree (`test-execution-lock.ps1`, pure decision module `test-execution-lock-decision.ps1`), a PreToolUse hook that denies direct runners, hidden wrapper launches, lane selections, worker-reduction tokens and launcher seam overrides (`enforce-test-execution-policy.ps1`, `test-execution-command-form.ps1`, Claude and Codex twins), PoshQC lane-exclusion parameters, launcher routing in `fix_all`, the atomic-executor QC runner and the VS Code tasks, skill and agent text, and ledger entry `0012`.

Local gate evidence is green for every language: Pester 26384 tests with 0 failures, pytest 16927 passed, bats 803 with 0 failures, extension Jest 5616 passed, and clean static loops. Coverage meets the 85% line threshold for every changed production file and the 75% branch threshold for every changed Python module, with no regression against the Phase 0 baseline. A real-process probe of the hook with 39 command shapes matched the specified deny and allow decisions.

Two blocking findings remain:

1. F1: instruction surfaces that agents follow still direct the direct runner commands that the new hook denies and that the atomic executor's tool allowlist no longer permits: the `## Toolchain Commands` Python line of the atomic-executor agent (Claude, bundle, and six Codex variants) and step 4 of the `python-qa-gate` toolchain loop (all copies).
2. F2: the user-story AC4 registration criterion is unchecked; its wording names direct registration in `.claude/settings.json` and `.codex/config.toml`, while the delivered registration follows spec decision D31 branch B (dispatcher registries). The user story was not aligned with D31.

Verdict: REMEDIATION_REQUIRED.

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
- ✅ Scratch scripts named in evidence (`SCRATCH/issue-1158-*.sh`) live in the issue scratch directory, outside the repository; none is in the branch diff.
- ✅ `git status --porcelain` at the reviewed head is empty.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Pester ran in 8 parallel shards and pytest under 24 xdist workers with 0 failures. An order dependence found at the Phase 5 gate was fixed in both leaker and victim (`phase-gate.P5.2026-11-14T07-24.md`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One suite per unit: policy, command form, lock decision, lock adapter, hook entry (Claude and Codex), launcher, Pester suite entry, PoshQC lane exclusion, MCP templates, Python launcher classification. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 730.75 s on 8 workers; pytest 132.97 s; the new helper suites run in seconds. |
| **Determinism** - Consistent results | ✅ PASS | Clock, sleep, lock, holder, process and file seams are injected; the driver-loop test advances an injected clock to 90000 ms. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Test names state scenario and outcome; file headers name the seams. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 95.80% lines; Python 72.91% lines, 65.44% branches over the seven modules<br>**Command:** `Invoke-PoshQCParallelTest`; scoped `poetry run pytest -n auto --cov=...`<br>**Artifact:** `evidence/baseline/pester-suite.2026-11-10T04-17.md`, `evidence/baseline/pytest-suite.2026-11-10T04-23.md`<br>**Timestamp:** 2026-11-10 04:17, 04:23 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 95.95% lines; Python 98.83% lines, 96.41% branches<br>**Change:** +0.15 pt PowerShell; +25.92 pt Python lines, +30.97 pt branches<br>**Status:** no per-file drop for any changed file (`coverage-comparison.2026-11-14T11-21.md`, verified by the reviewer's parse) |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest PowerShell `scripts/dev-tools/run-poshqc-suite.ps1` 91.07%; lowest Python `qc_runner.py` 93.58% lines, 81.82% branches<br>**Thresholds:** 85% line; 75% branch for Python; no PowerShell or bash branch threshold<br>**Status:** all changed production files meet the thresholds |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** 13 new production files<br>**New code coverage:** 91.07% to 100% per file<br>**Calculation method:** per-file LINE counters from `artifacts/pester/powershell-coverage.xml`; kcov for `run-test-suite.sh` |
| **Comprehensive Coverage** | ✅ PASS | `test-execution-policy.ps1` and `test-execution-lock-decision.ps1` 100% in both twins; `test-execution-command-form.ps1` 96.74%; Claude hook entry 91.67%, Codex hook entry 98.54%; launcher 92.93%. Uncovered lines are default seam bodies. |
| **Positive Flows** - Valid inputs | ✅ PASS | Free-lock launcher runs, allowed launcher commands, allowed non-runner commands, valid committed config. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Direct runners, wrappers, encoded payloads, invalid config fields, worker tokens and lane tokens denied or refused with `TEST_EXECUTION_POLICY_BLOCKED:`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | 262144-byte script boundary, mixed-case suffixes, `-m` with `not`, `waitMilliseconds` 0, empty Codex stdin, child exit 75 reported as 1. |
| **Error Handling** - Error paths | ✅ PASS | Dependency-guard failure, throwing suite (lock released, record removed), unreadable holder and script, pytest exit 2 with and without the refusal line. |
| **Concurrency** - If applicable | ✅ PASS | Lock state model rows, `run_fix_all` no-overlap case, and the live Linux two-process proof (`evidence/other/lock-two-process-proof.2026-11-11T05-21.md`, second launcher exit 75). |
| **State Transitions** - If applicable | ✅ PASS | Driver loop under an injected clock: each decision before 90000 ms is `Wait`, the decision at 90000 ms is `Timeout`. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% lines (from the `Phase 0 baseline` artifact) -> Post-change: 95.95% lines. Change: +0.15 pt lines. New/changed-code coverage: 91.07% lines (lowest new production file). Disposition: PASS. Evidence: `evidence/baseline/pester-suite.2026-11-10T04-17.md`, `evidence/qa-gates/pester-suite.2026-11-14T11-16.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 72.91% lines (from the `Phase 0 baseline` artifact) -> Post-change: 98.83% lines. Change: +25.92 pt lines, branches 65.44% to 96.41%. New/changed-code coverage: 93.58% lines (lowest changed module). Disposition: PASS. Evidence: `evidence/baseline/pytest-suite.2026-11-10T04-23.md`, `evidence/qa-gates/pytest-suite.2026-11-14T11-27.md`, `artifacts/python/lcov.info`.
- Bash: Baseline: N/A - no pre-change run -> Post-change: 95.0% lines. Change: none computable. New/changed-code coverage: 100% lines (`run-test-suite.sh`). Disposition: PASS. Evidence: `evidence/other/bats-deviation.2026-11-10T04-26.md`, `evidence/qa-gates/bats-suite.2026-11-14T10-59.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact-text assertions on deny and queue lines; `-Because` text on registry and parity assertions. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New `It` blocks and Python tests carry Arrange, Act and Assert sections. |
| **Document Intent** | ✅ PASS | File headers name issue #1158 and the spec decision each suite proves. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Python tests replace `subprocess.run` and `shutil.which`; the bats shim test uses the `TEST_SUITE_PWSH_BIN` stub. |
| **Use Mocks/Stubs** | ✅ PASS | Recording seams for lock, holder, process, clock and sleep. |
| **Environment Stability** | ✅ PASS | The AC3 search of the six named test files found no temporary-file, wait or write token; `Invoke-PoshQCLeakScan` passed (`powershell-static.2026-11-14T11-03.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-14T11-28.md` and this audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1158; `spec.md` v0.8 decisions D1-D33. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-09T16-31.md`; sibling reconciliation and pre-gate sync records under `evidence/other/`. |
| **Document the plan** | ✅ PASS | All plan tasks are checked; commits carry `(#1158)`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One launcher, one lock adapter, one pure decision module; registration as one dispatcher group per runtime. |
| **Reusability** | ✅ PASS | The helper files serve the hook, the launcher and the MCP templates. |
| **Extensibility** | ✅ PASS | Suites and lanes come from a validated repository config merged over built-in defaults. |
| **Separation of concerns** | ✅ PASS | Pure decision, command-form and policy logic are separate from the lock I/O adapter and entry wiring. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One concern per helper file. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest covered file in the diff is `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` at 689 logical lines; largest production file `test-execution-command-form.ps1` at 632; no covered file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | Python internal helpers are `_`-prefixed; consumers dot-source only the documented helpers. |
| **No circular dependencies** | ✅ PASS | Helpers load in a fixed order with no back-references. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Invoke-TestSuiteLauncher`, `Get-TestExecutionLockDecision`, `classify_launcher_exit`, `run_launcher_test_step`. |
| **Docs/docstrings** | ⚠️ PARTIAL | Code documentation is complete (comment-based help, docstrings). Agent and skill instructions are partly stale: see finding F1. |
| **Comment why, not what** | ✅ PASS | For example the comment explaining why the holder record is removed before the lock stream is released. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` check form; `black --check`; shfmt; Prettier<br>**Result:** 0 changes (`powershell-static.2026-11-14T11-03.md`, `python-static.2026-11-14T11-27.md`, `shell-static.2026-11-14T11-03.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` over 1741 files; `ruff check`; shellcheck; ESLint<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `pyright`; `tsc`<br>**Result:** 0 errors; N/A for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** the launcher `pester`, `pytest`, `jest-extension` and `bats` suites<br>**Result:** 0 failures in each |
| **Full toolchain loop** | ✅ PASS | The final loop restarted after each main merge and after the comment fix; the final pass is clean. The reviewer also ran `check_quality_tiers` at the reviewed head: `quality-tiers: OK (35 entries, 35 discovered projects)`. |
| **Explicit reporting** | ✅ PASS | Each gate has an append-only record with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages and the executor self-review. |
| **Design choices explained** | ✅ PASS | Spec decisions D1-D33; branch B registration record `pre-gate-sync.2026-11-14T10-11.md`. |
| **Update supporting documents** | ⚠️ PARTIAL | Briefs, plan contract, QA-gate and invoke skills, executor tool lists and ledger entry `0012` updated; the executor `## Toolchain Commands` Python line and the `python-qa-gate` toolchain step 4 were not (F1). |
| **Provide next steps** | ✅ PASS | Remediation inputs list F1 and F2. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** 1070 files unchanged |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check --no-fix`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors, 0 warnings |
| **Testing with Pytest** | ✅ PASS | **Command:** launcher `pytest` suite (`poetry run pytest -n auto`) with coverage extras<br>**Result:** 16927 passed, 6 skipped |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Full annotations on `classify_launcher_exit`, `launcher_refusal_message`, `run_launcher_test_step` and the `suite_lock` parameters; pyright clean. |
| **Dataclasses for value objects** | ✅ PASS | `PreflightQCResult` frozen dataclass carries the launcher outcome. |
| **Protocols/ABCs for interfaces** | N/A | No new interface with multiple implementations. |
| **Avoid utility classes** | ✅ PASS | Module-level functions. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `LauncherRefusedError`; the QC runner raises `RuntimeError` with the launcher message only for a classified test-step exit. |
| **Logging over print** | ✅ PASS | Existing logger callbacks; no `print` added. |
| **Invariants at construction** | ✅ PASS | Launcher exits are classified once, before early returns (D28). |

---

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .` with a no-op writer<br>**Result:** 0 `Formatted:` lines over 1741 files |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with `pssa.settings.psd1`<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | None open. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Repository targets PowerShell 7+; hooks and launcher run under `pwsh`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on new functions. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyString`, `AllowNull`, `ValidateSet`, `ValidateRange` on seams and inputs. |
| **Avoid global state** | ✅ PASS | Script-scope constants only. The launcher reads `TestSuiteLauncherSeams` from the caller scope by design (D18); the hook denies commands naming it (D33). |
| **Error handling** | ✅ PASS | `TEST_EXECUTION_POLICY_BLOCKED:` throws, fail-closed dependency guard, `finally` releases the lock. `SupportsShouldProcess` on the lock and holder writes was checked by hand, since PSSA does not flag the `Write` verb. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest production PowerShell file 632 logical lines. |
| **Approved verbs** | ✅ PASS | PSScriptAnalyzer `PSUseApprovedVerbs` clean. |
| **Comment why** | ✅ PASS | Seam and ordering rationale comments. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 changes. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 26384 tests, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | Loop restarted after main merges; final pass clean. |

---

### Section 3C: Bash Script Policy Compliance (if applicable)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | `scripts/bash/shell-qc.sh check` exit 0 (`shell-static.2026-11-14T11-03.md`). |
| **Linting with shellcheck** | ✅ PASS | Same run, 0 findings. |
| **Testing with bats** | ✅ PASS | 803 tests, 0 failures; kcov 95.0%; `run-test-suite.sh` 100%. bats ran on a WSL copy of the head (`evidence/other/bats-worktree-host-deviation.2026-11-14T10-03.md`). |
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
| **Coverage expectation** | ✅ PASS | Seven changed modules at 98.83% lines and 96.41% branches. The repo-wide figure comes from the CI step `Enforce Python coverage thresholds`, which has not run (no pull request); because every changed module rose and no module lost covered lines, the repo-wide ratio cannot fall. Recorded as pending-CI in `## CI Cross-check`. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One test file per changed module (`test_qc_runner_launcher.py`, `test_fix_all_launcher_steps.py`, `test_cli_preflight.py`, `test_cli_task_runtime.py`, `test_qc_runner_expectations.py`). |
| **Mocking sparingly** | ✅ PASS | `monkeypatch` for `subprocess.run` and `shutil.which`. |
| **Organization** | ✅ PASS | Mirrors `scripts/dev_tools/` under `tests/scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<behavior>` names. |
| **Docstrings/comments** | ✅ PASS | Executor AST audit clean on changed lines after the comment fix. |

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
| **Test Behavior Over Implementation** | ✅ PASS | Assertions on decisions, exit codes, stderr lines and recorded seam events. |
| **Mocking Used Sparingly** | ✅ PASS | Seams; `Mock` only for the entry-point decision and template commands. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1`<br>**Code file:** `.claude/hooks/test-execution-policy.ps1`<br>Launcher tests under `tests/scripts/claude-skills/test-execution-policy/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new suites. |
| **Describe/Context/It Structure** | ✅ PASS | Describe per surface. |
| **Logical Grouping** | ✅ PASS | Lock, discovery, refusals, argument reach, registry membership. |
| **Docstrings/Comments** | ✅ PASS | Header help per suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`<br>**Result:** 26384 tests, 0 failures, 18 skipped |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### Hook helpers (`test-execution-policy.ps1`, `test-execution-lock-decision.ps1`, `test-execution-command-form.ps1`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| defaults with no config text; one case per validation rule | Positive and Negative | policy loader and validator | ✅ |
| one case per lock-decision row; driver loop to 90000 ms | State Transition | decision and wait loop | ✅ |
| prefix, wrapper, chained and quoted command forms | Edge Case | normalization | ✅ |

**Coverage:** 100%, 100%, 96.74% (both twins)

**Not covered:** 9 lines of `test-execution-command-form.ps1` (rare option paths).

### Launcher and hook entry

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| busy lock exits 75 with the holder named | Negative | step 5 | ✅ |
| free lock writes holder, propagates exit, releases on throw | Positive, Error Handling | steps 5-6 | ✅ |
| deny per runner word, wrapper, MCP busy and free | Positive and Negative | hook decision | ✅ |

**Coverage:** launcher 92.93%; Claude hook 91.67%; Codex hook 98.54%

**Not covered:** default seam bodies (process start, real lock directory, stderr writer).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 26384 Pester; 16933 pytest items; 5616 Jest; 803 bats | ✅ |
| Tests Passed | 26366 Pester (18 skipped); 16927 pytest (6 skipped); 5616 Jest; 803 bats | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 730.75 s Pester; 132.97 s pytest | ✅ Fast |
| Average Time per Test | about 28 ms Pester per test on 8 workers | ✅ Fast |
| Discovery Time | not separately recorded by the gates | ✅ |
| Functions/Classes Tested | every function of the five hook helper files and the launcher | ✅ |
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
| Pester Tests | launcher `pester` suite | 26384 tests, 0 failures | ✅ |

**Notes:**
- Reviewer real-process probe: the worktree hook was run as a `pwsh -File` process on 39 Bash payloads. It allowed the launcher, `grep`, `git log --grep pytest`, `python -m pytest --version`, `npm run build`, `npm run lint`, `dotnet build`, and the launcher with `-m 'not integration'`; it denied `poetry -C` and `--directory` forms, `npm --prefix` and `npm -w` test scripts, `cd ... && npx jest`, `bash -lc`, `pwsh -Command Invoke-Pester`, `uv run`, `xargs`, `find -exec`, a variable-held runner, `time`, `nice`, `/usr/bin/env`, `coverage run -m pytest`, `node node_modules/jest/...`, and the launcher with `-n 2`, an `_integration.py` path, or `-m integration`.
- The probe also allowed `watch -n 5 pytest`, `ionice -c3 pytest`, `pnpm test`, `yarn test`, `make test`, `tox` and `nox`. None of these forms is in the spec's runner or prefix list, so they are outside the specified scope; recorded as an informational residual in the code review.

---

## CI Cross-check

No pull request exists for the branch, so CI has not run on the reviewed head. Each row records the outcome claimed from the local evidence; the CI result is pending and is compared at S9.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC | pass | 26384 tests, 0 failures, 95.95% lines | c03f350da362989a3eb4b2153ec9cff5fef45447 | `evidence/qa-gates/pester-suite.2026-11-14T11-16.md`; CI pending (no PR) |
| poshqc / PowerShell hook suites (Linux) | pass | Windows run green; Linux run CI-dependent | c03f350da362989a3eb4b2153ec9cff5fef45447 | `evidence/qa-gates/pester-suite.2026-11-14T11-16.md`; CI pending (no PR) |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 16927 passed; `check_quality_tiers` OK (reviewer run) | c03f350da362989a3eb4b2153ec9cff5fef45447 | `evidence/qa-gates/pytest-suite.2026-11-14T11-27.md`; CI pending (no PR) |
| Enforce Python coverage thresholds | pass | changed modules 98.83% lines, 96.41% branches | c03f350da362989a3eb4b2153ec9cff5fef45447 | `artifacts/python/lcov.info`; CI pending (no PR) |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | pass | 5616 passed, integration suites excluded locally | c03f350da362989a3eb4b2153ec9cff5fef45447 | `evidence/qa-gates/jest-extension-suite.2026-11-14T11-20.md`; CI pending (no PR) |
| shell-coverage / Shell Coverage (Bats + kcov) | pass | 803 tests, kcov 95.0% | c03f350da362989a3eb4b2153ec9cff5fef45447 | `evidence/qa-gates/bats-suite.2026-11-14T10-59.md`; CI pending (no PR) |

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. All evidence is under `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/evidence/<kind>/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists at the repository root and CI runs the `tier-classification` stage, so tiers are adopted. The reviewer ran `python -m scripts.dev_tools.check_quality_tiers` in the worktree at the reviewed head: `quality-tiers: OK (35 entries, 35 discovered projects)`. The new files live under existing classified folders (`.claude/hooks`, `.codex/hooks`, `.claude/skills`).

## Owner Directives

The caller relayed directives OD-1 to OD-9. This review honored OD-3 (existing worktree, no new branch), OD-4 (command shapes), OD-5 (no local suite run), OD-6 (append-only evidence; no evidence edited), and OD-8 (related findings F1 and F2 classified for remediation inside this item). OD-1, OD-2, OD-7 and OD-9 concern scheduling, main sync and merge steps that this review does not perform. Decision lines are in the final report.

---

## 8. Gaps and Exceptions

### Identified Gaps
- F1 (Blocking): stale direct-runner instructions in the atomic-executor `## Toolchain Commands` Python line (Claude, bundle, six Codex variants) and in `python-qa-gate` step 4 (all copies).
- F2 (Blocking): user-story AC4 registration criterion unmet as worded; the user story was not aligned with spec decision D31.

### Approved Exceptions
- Local gates exclude the integration and golden lanes by design (ledger entry `0012`, `evidence/other/lane-deviation.2026-11-14T11-21.md`); CI runs them.
- The bats baseline was not run on the host (no bats or kcov on PATH; `evidence/other/bats-deviation.2026-11-10T04-26.md`); the final bats gate ran on a WSL copy of the head.
- Ledger entry number `0012` instead of the spec's `0011`, authorized by plan task P6-T9 because #1167 took `0011`.

### Removed/Skipped Tests
1. **Integration-named tests** - 41 Pester, 11 pytest and 16 Jest tests no longer run locally
   - **Reason:** the local lane exclusion is the feature under review.
   - **Impact:** CI jobs `poshqc`, `quality-checks7` and `drm-copilot-extension-tests` still run them.
   - **Justification:** spec D13 and D30; no coverage drop is attributable (`coverage-comparison.2026-11-14T11-21.md`).

---

## 9. Summary of Changes

The branch serializes local test suites through one launcher under a per-user machine lock, excludes the integration and golden lanes locally, and enforces both through a PreToolUse hook on Bash and the two PoshQC MCP test tools in both runtimes.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Code, tests, coverage, file size, evidence location, tier classification and documentation-surface checks comply. Two blocking findings (F1 stale runner instructions, F2 user-story AC4 alignment) remain.

**Fail-closed reminder:** The audit is not marked ready for merge.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and spec present
- ✅ Design Principles: compliant
- ✅ Module & File Structure: no covered file at or above 700 lines
- ⚠️ Naming, Docs, Comments: stale agent and skill instructions (F1)
- ✅ Toolchain Execution: clean
- ⚠️ Summarize & Document: user story not aligned with D31 (F2)

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean
- ✅ Python Design & Typing: typed
- ✅ Error Handling: specific exceptions

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: seams, fail-closed guard, lock released in `finally`
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

- ✅ 26384 Pester tests, 0 failures; 16927 pytest passed; 5616 Jest passed; 803 bats passed
- ✅ 95.95% PowerShell line coverage; new production files 91.07% to 100%
- ✅ Changed Python modules 98.83% lines, 96.41% branches
- ✅ Test files mirror source layout
- ❌ Stale direct-runner instructions remain (F1)
- ❌ User-story AC4 unmet as worded (F2)

---

### Recommendation

**Needs revision**

Replace the direct `poetry run pytest` instructions in the atomic-executor toolchain list and in `python-qa-gate` step 4 with the launcher command, in every mirror, bundle and Codex variant, and regenerate the affected process-reduction ledger records (F1). Align the user-story AC4 registration criterion with spec D31 through a planner revision and check it off against the existing Registration test evidence (F2).

---

## Appendix A: Test Inventory

### Complete Test List

New suites on the branch (individual cases are enumerated in `artifacts/pester/pester-junit.xml`, 26384 test cases, and in the pytest gate record):

1. `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` › defaults, validation rules, lane classification, worker tokens (511 cases)
2. `tests/scripts/claude-hooks/test-execution-command-form.Tests.ps1` › D25 forms (327 cases)
3. `tests/scripts/claude-hooks/test-execution-lock-decision.Tests.ps1` › state model and driver loop (47 cases)
4. `tests/scripts/claude-hooks/test-execution-lock.Tests.ps1` › lock directory and file names (43 cases)
5. `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` and `tests/scripts/codex-hooks/enforce-test-execution-policy.Tests.ps1` › hook decisions (376 cases combined)
6. `tests/scripts/claude-hooks/test-execution-policy.Registration.Tests.ps1` (19) and `test-execution-policy.RepoConfig.Tests.ps1` (10)
7. `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` (37) and `Invoke-PesterSuite.Tests.ps1` (18)
8. `tests/scripts/powershell/PoshQC/PoshQC.TestingLaneExclusion.Tests.ps1` (10) and `PoshQC.McpTemplateLock.Tests.ps1` (24)
9. `tests/shell/test_run_test_suite.bats`
10. `tests/scripts/dev_tools/atomic_executor/test_qc_runner_launcher.py`, `test_qc_runner_expectations.py`, `test_cli_preflight.py`, `test_cli_task_runtime.py`, `tests/scripts/dev_tools/test_fix_all_launcher_steps.py`

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
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-14  
**Policy Version:** Current (as of audit date)

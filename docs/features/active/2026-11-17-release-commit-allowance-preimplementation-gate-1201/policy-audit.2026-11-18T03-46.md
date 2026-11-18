# Policy Compliance Audit: Release-commit allowance leg of the preimplementation gates (#1201), cycle 1 re-audit

**Audit Date:** 2026-11-18  
**Code Under Test:** merge base `1b9e5746eaa5e32366de695e3f511dbc28700b08` of the base branch (`origin/main`, equal to the fetched tip) and reviewed head `4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a`; the diff between them lists the changed files. Cycle-1 delta: `89d0e58610eac3b66504ca2ba27a6d22a8f15312..4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 12 production files (8 new, 4 edited); 6 new test files and 18 edited test files (cycle 1, teardown only) | 600 new tests | ✅ 28087 pass, 0 fail | 96.05% lines (44864/46711) | 96.08% lines (45276/47121) | 100% (both new files, 171/171 and 32/32 per copy) |
| TypeScript | 1 production file edited, 1 new test file | 3 new tests | ✅ 5717 pass, 0 fail | 97.19% lines, 94% branches | 97.19% lines, 94% branches (extension scope); 98.3% lines, 93.78% branches (root scope) | 100% (the added line in `claude-customizations.ts` is covered) |
| Python | 1 production file edited (one tuple entry), 0 test files | 0 new tests | ✅ 16957 pass, 0 fail | 97.74% lines, 95.15% branches | 97.74% lines, 95.15% branches | 100% (the added tuple entry is part of an executed statement) |
| JSON | 2 pack manifests edited | N/A | ✅ parsed by the pack-manifest completeness and dependency-closure tests | N/A (config files) | N/A (config files) | N/A |

Markdown documentation and evidence files changed as well; they carry no coverage requirement. Bash and C# have zero changed files on the branch. Cycle 1 changed only PowerShell test files and feature-folder documents; no production, bundle, TypeScript, Python, or JSON file changed between `89d0e5861` and `4140c7bb5`.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/evidence/baseline/jest-extension.2026-11-17T21-03.md`
- TypeScript post-change coverage artifact: `coverage/lcov.info` (worktree root, written 2026-11-18T01-22 UTC, after the newest commit touching TypeScript files, `db46ac6ad` at 2026-11-18T00-49 UTC) and `evidence/qa-gates/final-qc-jest.2026-11-18T01-10.md`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/evidence/baseline/pester.2026-11-17T20-55.md` (Phase 0) and `evidence/remediation-baseline/pester.2026-11-18T02-04.md` (cycle 1)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (rewritten by the reviewer gate run recorded in `evidence/qa-gates/review-pester.2026-11-18T03-46.md`, after the head commit) and `evidence/qa-gates/final-qc-pester.2026-11-18T03-14.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (written 2026-11-18T01-09 UTC, after the newest commit touching Python files, `db46ac6ad`)
- Per-language comparison summary: section 1.2.1 of this audit, `evidence/qa-gates/coverage-comparison.2026-11-18T01-10.md`, and `evidence/qa-gates/coverage-comparison.2026-11-18T03-14.md`

Baseline coverage is read from the plan's `Phase 0 baseline` artifacts, one run of each language's gate.

**CI-proven checks:** Format, lint, and type-check results are read from the final-QC static artifact of each language. Each CI check the review relies on is recorded in `## CI Cross-check`, which the orchestrator compares with CI at the reviewed head.

**Disclosed deviation (coverage re-run):** the executor's PowerShell report was written at 2026-11-18T03-14 UTC, three minutes before head commit `4140c7bb5`, which touches `*.ps1` test files. The coverage freshness Stop hook compares the report time with that commit time, so the reviewer re-ran the PowerShell gate once in the item worktree (parallel launcher, 8 workers). The figures match the executor's recorded figures exactly (28105 tests, 0 failures, 45276/47121 lines). No other gate was re-run.

---

## Executive Summary

The branch adds an allow-side release-commit allowance leg to the Claude and Codex preimplementation gates (cycle 0, reviewed PASS at `89d0e5861`). CI on that head then failed in two places: one probe row in `poshqc / PowerShell hook suites (Linux)` (Finding CI-1) and both NPM Audit Gate jobs (Finding CI-2, advisory GHSA-fc5q-39xc-vjpf).

Cycle 1 addresses CI-1 with test-only changes. The root cause is a module-table leak: suites that run `validate-orchestrator-output.ps1` in-process (which force-imports `WorktreeRunResolution.psm1`), or force-import that module directly, leave a loaded `EpicScopeResolution` bound to a removed `WorktreeRunResolution` instance. A later suite's `-ModuleName WorktreeRunResolution` mocks then bind to the new instance while `EpicScopeResolution` calls the stale one, so the probe sees zero calls of `Get-EpicScopeCheckpointText`. The fix adds a `Reset-EpicStateProbeModuleBinding` call in the victim's `BeforeAll` and a teardown in each of the 18 leaker suites. The reviewer reproduced the mechanism in one process (fresh, then stale after a `-Force` import, then removed by the reset, then fresh after re-import, and unchanged by a second reset). `poshqc / PowerShell hook suites (Linux)` passed at head `4140c7bb5`.

CI-2 still fails at head `4140c7bb5`: both NPM Audit Gate jobs report GHSA-fc5q-39xc-vjpf, the advisory still lists picomatch `<= 4.0.7` with no patched version, and `origin/main` does not yet carry the coordinator's scoped exception. The finding is carried as blocking with class `external_dependency`, so the verdict is `HALT_NON_REMEDIABLE`.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (mirrored by `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (mirrored by `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (one tuple entry in cycle 0; reviewed under section 3A)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md`
- N/A Bash: zero changed shell files
- ✅ JSON: two pack manifests

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted (executor scripts lived under the scratch directory outside the repository; no scratch file is in the branch diff)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (no new tooling script was added)
- The reviewer wrote a module-binding probe, a parse script, and three `sh` launchers in the session scratch directory outside the repository; none is tracked.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The order dependence behind CI-1 is removed on both sides: the victim resets a stale binding before it registers mocks, and every suite in the Linux job's file set that runs `validate-orchestrator-output.ps1` in-process or force-imports `WorktreeRunResolution.psm1` now carries a reset teardown (reviewer grep of `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, `tests/scripts/claude-runtime`). The remaining matches of those names are text-only fixtures or suites that remove all six worktree-resolution modules. |
| **Isolation** - Each test targets single behavior | ✅ PASS | No test body changed in cycle 1; the reset removes only a fixture-root `EpicScopeResolution` instance whose bound run module is not the current one. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer gate run wall-clock 755.55 s against the executor's 721.33 s and the baseline 732.5 s. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, network, or file access added. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Each teardown carries a one-line comment naming the force-import cause. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** PowerShell 96.05% lines; TypeScript 97.19% lines, 94% branches; Python 97.74% lines, 95.15% branches, read from the `Phase 0 baseline` artifacts; cycle-1 PowerShell baseline 96.08%<br>**Command:** `Invoke-PoshQCParallelTest`, `pytest -n auto`, Jest with workers (one run of each gate)<br>**Artifact:** `evidence/baseline/pester.2026-11-17T20-55.md`, `evidence/baseline/jest-extension.2026-11-17T21-03.md`, `evidence/baseline/pytest.2026-11-17T21-03.md`, `evidence/remediation-baseline/pester.2026-11-18T02-04.md`<br>**Timestamp:** 2026-11-17 20:38 to 21:03 UTC; 2026-11-18 02:04 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** PowerShell 96.08%; TypeScript 97.19% / 94%; Python 97.74% / 95.15%<br>**Change:** +0.03% PowerShell lines against Phase 0, 0.00% against the cycle-1 baseline; 0.00% TypeScript and Python<br>**Status:** No regression. |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** Claude gate 96.61% (171/177), Codex gate 100% (182/182), `claude-customizations.ts` 100% lines / 96.82% branches, `push_down_claude_customizations.py` 93.67% lines / 87.50% branches<br>**Thresholds:** 85% line; 75% branch for TypeScript and Python; no PowerShell branch gate<br>**Status:** All changed production files meet the thresholds; cycle-1 test files are outside the coverage population |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** `hook-release-allowance-context.ps1` and `enforce-orchestration-preimplementation-gate-release.ps1` (both measured copies)<br>**New code coverage:** 100% (171/171 and 32/32 per copy)<br>**Calculation method:** per-file JaCoCo `LINE` counters of `artifacts/pester/powershell-coverage.xml` parsed by the reviewer after the review gate run |
| **Comprehensive Coverage** | ✅ PASS | **All functions tested:** every function of both new files is reached (100% line coverage).<br>**Untested code:** none in the new files. |
| **Positive Flows** - Valid inputs | ✅ PASS | AC-8 to AC-11 rows (unchanged in cycle 1). |
| **Negative Flows** - Invalid inputs | ✅ PASS | AC-12 to AC-17 rows (unchanged in cycle 1). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Unchanged in cycle 1. |
| **Error Handling** - Error paths | ✅ PASS | Unchanged in cycle 1. |
| **Concurrency** - If applicable | N/A | The leg is a synchronous pure decision with no shared state. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.05% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.08% lines. Change: +0.03% lines. New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `evidence/baseline/pester.2026-11-17T20-55.md`, `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/review-pester.2026-11-18T03-46.md`, `evidence/qa-gates/coverage-comparison.2026-11-18T03-14.md`.
- TypeScript: Baseline: 97.19% lines (from the `Phase 0 baseline` artifact) -> Post-change: 97.19% lines. Change: 0.00% lines, 0.00% branches (94% to 94%). New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `evidence/baseline/jest-extension.2026-11-17T21-03.md`, `evidence/qa-gates/final-qc-jest.2026-11-18T01-10.md`, `coverage/lcov.info` with `evidence/qa-gates/jest-gate.2026-11-18T01-22.md` (root scope 98.3% lines, 93.78% branches).
- Python: Baseline: 97.74% lines (from the `Phase 0 baseline` artifact) -> Post-change: 97.74% lines. Change: 0.00% lines, 0.00% branches (95.15% to 95.15%). New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `evidence/baseline/pytest.2026-11-17T21-03.md`, `artifacts/python/lcov.info`, `evidence/qa-gates/final-qc-pytest.2026-11-18T01-10.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | No assertion changed in cycle 1. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Unchanged. |
| **Document Intent** | ✅ PASS | Teardown comments name the cause. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No process, network, or git call added. |
| **Use Mocks/Stubs** | ✅ PASS | The victim fix keeps mock registration unchanged and only makes it bind to a fresh module instance. |
| **Environment Stability** | ✅ PASS | The fix removes cross-file module-table state. Leak scan 0 failures (`final-qc-static-powershell.2026-11-18T03-02.md`). The leak scan has no module-table kind, recorded as an Info item in the code review. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, the code review, and the feature audit with timestamp 2026-11-18T03-46 form the review set. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-11-18T01-37.md` (CI-1 required outcome). |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-18T01-37.md`, `evidence/other/preflight-fixes.2026-11-18T01-50.md`. |
| **Document the plan** | ✅ PASS | Diagnosis `evidence/other/ci1-diagnosis.2026-11-18T02-06.md` and supplement `ci1-diagnosis.2026-11-18T02-52.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One call per suite, reusing an existing helper. |
| **Reusability** | ✅ PASS | `Reset-EpicStateProbeModuleBinding` exists on the merge base (`EpicStateIsolation.Baseline.Helpers.ps1` line 100) and is already used in `AfterAll` by `validate-orchestrator-output.Envelope.Tests.ps1` and `validate-orchestrator-output.TargetWorktree.Tests.ps1`. |
| **Extensibility** | N/A | No API change. |
| **Separation of concerns** | ✅ PASS | Test-only fix; no production file changed (production defect: none, since the hook runs in its own `pwsh -File` process). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Unchanged. |
| **At or below the 800-line hard limit** | ✅ PASS | Reviewer logical line count (`@(Get-Content).Count`) over every changed covered file: the largest is `hook-import-failure-exemptions.FailClosed.Tests.ps1` at 539 (guidance tier only, no finding); all others are at or below 497. No file reaches 700; `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | ✅ PASS | Unchanged. |
| **No circular dependencies** | ✅ PASS | Unchanged. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | No new symbol. |
| **Docs/docstrings** | ✅ PASS | Unchanged. |
| **Comment why, not what** | ✅ PASS | Each teardown comment states why the binding is stale. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** check-only Invoke-Formatter compare on the 19 cycle-1 test files<br>**Result:** 0 drift (`evidence/qa-gates/final-qc-static-powershell.2026-11-18T03-02.md`) |
| **2. Linting** | ✅ PASS | **Command:** PSScriptAnalyzer with repository settings<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | Not applicable for PowerShell; TypeScript and Python unchanged since the cycle-0 clean runs |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (executor, 03-14; reviewer, 03-46)<br>**Result:** 0 failures in each run |
| **Full toolchain loop** | ✅ PASS | The loop restarted from format after the leaker supplement and passed in one pass; integration runs in CI. |
| **Explicit reporting** | ✅ PASS | Commands, exit codes, and figures are recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `4140c7bb5`; `evidence/qa-gates/self-review.2026-11-18T03-15.md`. |
| **Design choices explained** | ✅ PASS | Diagnosis sections 1 to 6. |
| **Update supporting documents** | ✅ PASS | No documentation surface changed in cycle 1. |
| **Provide next steps** | ✅ PASS | CI-2 resolution through the main-side scoped exception and a main sync. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** 1070 files unchanged (cycle 0; no Python change since) |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check .`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors |
| **Testing with Pytest** | ✅ PASS | **Command:** `pytest -n auto --cov --cov-branch`<br>**Result:** 16957 passed, 0 failed |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | The entry joins the existing `tuple[Path, ...]` constant. |
| **Dataclasses for value objects** | N/A | No new value object. |
| **Protocols/ABCs for interfaces** | N/A | No new interface. |
| **Avoid utility classes** | N/A | No new class. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No new control flow. |
| **Logging over print** | N/A | No new output. |
| **Invariants at construction** | N/A | No new construction. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** check-only Invoke-Formatter comparison with `pssa.settings.psd1` on the 19 cycle-1 files<br>**Result:** `format_drift=0` |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** PSScriptAnalyzer with repository settings on the same files<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | No findings to fix; leak scan 0 failures. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The hooks and suites target PowerShell 7+, consistent with `.claude/rules/powershell.md`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | The reused helper is `[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]`. |
| **Parameter validation** | ✅ PASS | No new parameter. |
| **Avoid global state** | ✅ PASS | The fix removes stale module-table state left across files. |
| **Error handling** | ✅ PASS | `Remove-Module -ErrorAction Stop`; no catch added. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | All changed files below 700 logical lines. |
| **Approved verbs** | ✅ PASS | No new function. |
| **Comment why** | ✅ PASS | Teardown comments. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 drift (`evidence/qa-gates/final-qc-static-powershell.2026-11-18T03-02.md`). |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 28105 tests, 28087 passed, 0 failed, 18 skipped (`evidence/qa-gates/final-qc-pester.2026-11-18T03-14.md`, `evidence/qa-gates/review-pester.2026-11-18T03-46.md`). |
| **Rerun loop if needed** | ✅ PASS | The loop restarted after the leaker supplement and the final pass is clean. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | Unchanged since cycle 0; `prettier --check "*.json"` passed for the extension scope. |
| **Schema validation** | ✅ PASS | The pack-manifest completeness, dependency-closure, and resource-contract pytest suites passed. |
| **Required $schema** | N/A | The pack manifests are not `$schema`-governed files. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | Plain string entries. |
| **Deterministic key order** | N/A | Only array entries were added. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | The existing Python suites ran under `pytest -n auto`; no Python test was added. |
| **Coverage expectation** | ✅ PASS | Python total 97.74% lines and 95.15% branches in `artifacts/python/lcov.info`; the CI result of `Enforce Python coverage thresholds` is recorded in `## CI Cross-check`. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | N/A | No Python test was added. |
| **Mocking sparingly** | N/A | No Python test was added. |
| **Organization** | N/A | No Python test was added. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | N/A | No Python test was added. |
| **Docstrings/comments** | N/A | No Python test was added. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `pytest -n auto --cov --cov-branch`<br>**Result:** 16957 passed |
| **No Alternative Test Runners** | ✅ PASS | Only pytest. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | File-level and Describe-level `AfterAll` blocks follow Pester 6 block semantics. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through `run-test-suite.sh pester`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `config/poshqc-coverage.json` (unchanged) |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | `#Requires -Version 7.0` on each new suite. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Unchanged. |
| **Test Behavior Over Implementation** | ✅ PASS | Unchanged. |
| **Mocking Used Sparingly** | ✅ PASS | No mock added in cycle 1. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1`<br>**Code file:** `.claude/hooks/hook-release-allowance-context.ps1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Unchanged. |
| **Describe/Context/It Structure** | ✅ PASS | Teardowns sit at file level or in the Describe that loads the hook. |
| **Logical Grouping** | ✅ PASS | Unchanged. |
| **Docstrings/Comments** | ✅ PASS | Teardown comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` (8 workers)<br>**Result:** 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Only Pester through PoshQC; the reviewer's module-binding probe is a diagnostic script, not a test run. |

---

## 5. Test Coverage Detail

### hook-release-allowance-context.ps1 (314 tests across both surface copies)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Parser rows for the example document and each AC-1 invalid row | Positive/Negative | 186-240, 109-184 | ✅ |
| Branch match rows (AC-2) | Positive/Negative | 242-259 | ✅ |
| Relevance and segment-shape rows | Positive/Negative/Edge Case | 261-408 | ✅ |
| Command decision rows | Positive/Negative | 410-495 | ✅ |
| Baseline mock interception probe (the CI-1 row, both surfaces) | Contract | n/a | ✅ |

**Coverage:** 100% (171/171 per copy)

**Not covered:** None.

### enforce-orchestration-preimplementation-gate-release.ps1 (44 tests across both surface copies)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Config seam: absent, file, non-file, read failure | Positive/Error Handling | 45-65 | ✅ |
| Container seam: true and false | Positive | 67-83 | ✅ |
| Leg entry declines, config failures, catch path, call counts | Negative/Error Handling | 103-166 | ✅ |

**Coverage:** 100% (32/32 per copy)

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 28105 Pester; 5717 Jest (root); 16963 pytest collected | ✅ |
| Tests Passed | 28087 Pester (18 skipped); 5717 Jest; 16957 pytest (6 skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 755.55 s Pester wall-clock (reviewer run); 23 s Jest root; 198.88 s pytest | ✅ Fast |
| Average Time per Test | About 35 ms for the 600 new Pester tests | ✅ Fast |
| Discovery Time | Included in the parallel shard times | ✅ |
| Functions/Classes Tested | 17/17 functions of the two new files (100%) | ✅ |
| Test File Size | 96 to 539 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 100% lines for both new files | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 1070 unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 16957 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | check-only formatter comparison on changed files | 0 drift | ✅ |
| PSScriptAnalyzer | repository settings on changed files | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 28087 passed, 0 failed | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check` | 0 findings | ✅ |
| ESLint | `npx eslint src test` | 0 findings | ✅ |
| TSC | `npx tsc --noEmit` (two configs) | 0 errors | ✅ |
| Jest | `node run-jest.cjs --coverage` (root) | 5717 passed | ✅ |

**Notes:**
Python and TypeScript figures are from cycle 0; no Python or TypeScript file changed in cycle 1, and both reports post-date the newest commit touching their files. Architecture boundaries: no `.dependency-cruiser.cjs` exists, so that stage has no command.

---

## CI Cross-check

CI run 44229371033 on PR #1202 was in progress at head `4140c7bb5` during the review (concurrent review mode). Claimed outcomes come from local evidence; the Source column also records the CI state the reviewer read with `gh pr checks` at 2026-11-18T03-46 UTC. The orchestrator compares these with CI at the join.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| CI Required Gate | fail | pending at review time; expected to fail while both NPM Audit Gate jobs fail (Finding CI-2) | 4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a | local evidence `evidence/qa-gates/final-qc-*.md`; CI state not yet reported |
| CI full run | pass | pending for the orchestrator join; CI reported pass at review time | 4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a | `evidence/qa-gates/review-pester.2026-11-18T03-46.md` |
| poshqc / PowerShell hook suites (Linux) | pass | 15526 tests, 0 failures in the local folder proof; pending for the orchestrator join; CI reported pass at review time | 4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a | `evidence/regression-testing/ci1-folder-proof.2026-11-18T03-02.md` |
| NPM Audit Gate / npm audit (.) | fail | GHSA-fc5q-39xc-vjpf, picomatch `<= 4.0.7`, no patched version; pending for the orchestrator join; CI reported fail at review time | 4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a | job log of run 44229371033 and the GitHub advisory record |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | fail | same advisory; pending for the orchestrator join; CI reported fail at review time | 4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a | job log of run 44229371033 |
| quality-checks7 / Code Quality & Tests (3.13) (Enforce Python coverage thresholds) | pass | 97.74% lines, 95.15% branches locally; CI reported pass at review time | 4140c7bb54c3126bb5a35da0cfcb0f7b4bf53b6a | `artifacts/python/lcov.info`, `evidence/qa-gates/final-qc-pytest.2026-11-18T01-10.md` |

Additional CI observation: the first attempt of `poshqc / PowerShell QC shard 5` failed in its `Install PoshQC tooling` step with `Failed to install Pester 6.2.0: Package 'Pester' failed to download` before any test ran. This is a package-download failure outside the branch; a new attempt of the job was pending at review time.

---

## Evidence Location Compliance

`git diff --name-only <merge-base>..HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `scripts/dev_tools/validate_evidence_locations.py --root .` (run in the item worktree) exited 0 with no output. All branch evidence is under `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201/evidence/<kind>/`; the reviewer's gate record is `evidence/qa-gates/review-pester.2026-11-18T03-46.md`.

## Rejected Scope Narrowing

None detected. The caller prompt asks for the full branch diff from the merge base with focus on the cycle-1 delta; this audit covers the full diff.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check is not applicable and produces no finding.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds files only under existing directories; no new project folder needs a tier entry.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **CI-2 (blocking, `external_dependency`):** both NPM Audit Gate jobs fail at head `4140c7bb5` on GHSA-fc5q-39xc-vjpf. No patched picomatch exists, `origin/main` fails the same way, and the branch changes no manifest, lockfile, or audit configuration. The coordinator is shipping a scoped exception on `main`; the branch then needs a main sync. Recorded in `remediation-inputs.2026-11-18T03-46.md`.
2. **AC-7 wording (non-blocking, recorded deviation):** 18 pre-existing hook suites now carry additive teardowns, which contradicts the parenthetical "no diff to any pre-existing test file" in AC-7. See the feature audit for the judgment.

### Approved Exceptions

**None.** The CI-2 advisory exception is a `main`-side change outside this branch.

### Removed/Skipped Tests

**None.** The probe is unchanged; the 18 skipped Pester tests are pre-existing and outside the branch diff.

---

## 9. Summary of Changes

Cycle 1 repairs a cross-file module-table leak in the hook test suites that made the new probe row fail on the single-process Linux job, with a victim-side reset and leaker-side teardowns. No production file changed.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ COMPLIANT WITH AN EXTERNAL CI BLOCKER

The branch code and tests meet every evaluated policy, with numeric baseline and post-change coverage for PowerShell, TypeScript, and Python. Merge is blocked by Finding CI-2, an external advisory with no in-branch remedy that keeps the audit gate intact.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is absent.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: remediation inputs, plan, diagnosis present
- ✅ Design Principles: existing helper reused
- ✅ Module & File Structure: all files below 700 logical lines
- ✅ Naming, Docs, Comments: teardown comments name the cause
- ✅ Toolchain Execution: single clean final pass recorded
- ✅ Summarize & Document: diagnosis, proofs, and self-review recorded

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright clean
- ✅ Python Design & Typing: one typed tuple entry
- ✅ Error Handling: no new control flow

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyzer clean
- ✅ PowerShell Design & Safety: path-scoped `ShouldProcess` reset helper
- ✅ Structure & Naming: no new symbol
- ✅ Toolchain: Pester parallel run clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: order dependence removed on victim and leaker sides
- ✅ Coverage & Scenarios: 100% on new files, no regression
- ✅ Test Structure: no assertion changed
- ✅ External Dependencies: no new dependency
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: existing suites unchanged and passing
- ✅ Test Style & Structure: no new Python test
- ✅ Naming & Readability: no new Python test
- ✅ Toolchain: pytest parallel run clean

**For PowerShell:**
- ✅ Framework & Scope: Pester 6 block semantics
- ✅ Test Style & Structure: teardown-only edits
- ✅ Naming & Readability: unchanged
- ✅ Toolchain: PoshQC parallel run

---

### Metrics Summary

- ✅ 28087/28105 Pester tests passing (18 pre-existing skips), 5717/5717 Jest, 16957 pytest
- ✅ 17/17 functions of the new files tested (100%)
- ✅ 100% line coverage on both new PowerShell files; repo-wide PowerShell 96.08%
- ✅ Proper file organization: tests mirror `.claude/hooks` and `.codex/hooks`
- ✅ All local code quality checks passing
- ✅ Linux hook-suite job passed in CI at head `4140c7bb5`

---

### Recommendation

**Hold for CI-2.** Merge after the scoped audit exception lands on `main`, the branch is synced with `main`, and CI is green on the final head (AC-31, checked off at S9 by the item orchestrator).

---

## Appendix A: Test Inventory

### Complete Test List

1. `hook-release-allowance-context.Tests.ps1` › Describe per surface (Claude, Codex) › parser, branch-match, relevance, segment-shape, and decision rows plus the baseline mock interception probe (314)
2. `enforce-orchestration-preimplementation-gate-release.Tests.ps1` › Describe per surface › interception probe, config seam, container seam, leg entry (44)
3. `enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1` › baseline mock interception probe; `decides release-allowance row <Id>` for 101 rows (102)
4. `enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1` (Codex) › same rows through the Codex gate (102)
5. `hook-release-allowance-context.Parity.Tests.ps1` › byte identity, line bounds, gate wiring, manifests, absence, exclusion tuple, documentation tokens, no-Python (38)
6. `claude-customizations-release-allowance.test.ts` › three push-down exclusion tests (3)
7. Cycle 1 teardown edits (no new tests): 18 pre-existing suites under `tests/scripts/claude-hooks` listed in `evidence/other/ci1-diagnosis.2026-11-18T02-52.md`

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
env -u VIRTUAL_ENV poetry run black --check .
env -u VIRTUAL_ENV poetry run ruff check .
env -u VIRTUAL_ENV poetry run pyright
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch
```

**For PowerShell:**
```bash
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
```

**For TypeScript:**
```bash
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
npx eslint --no-error-on-unmatched-pattern src test
npx tsc -p ./ --noEmit
node run-jest.cjs --coverage
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-18  
**Policy Version:** Current (as of audit date)

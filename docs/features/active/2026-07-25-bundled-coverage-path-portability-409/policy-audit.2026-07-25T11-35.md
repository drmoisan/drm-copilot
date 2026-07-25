# Policy Compliance Audit: Bundled Coverage Path Portability Fix (Issue #409)

---

**Audit Date:** 2026-07-25
**Code Under Test:**
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (MODIFIED, PowerShell)
- `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` (MODIFIED, PowerShell, byte-identical mirror)
- `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` (NEW, PowerShell test)
- 34 documentation/evidence files under `docs/features/` (NEW, Markdown/XML evidence — not production code)

**Baseline:** feature branch `bug/bundled-coverage-path-portability-409` @ `dbf2e3f591e22c02013e90f764f278de713a2aac` vs. base `main`, merge-base `036daf8d5fa36a6655078f33e4313b0d2df9590b`. Scope is the full branch diff against the merge-base (37 files, +9050/-2). Work mode: `full-bug` (persisted marker in `issue.md`).

**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, the same asset the MCP resolver selector `template` targets; the MCP tool surface was unavailable in this review session, so the identical bundled asset was read directly from its packaged location.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 files | 1354 tests | ✅ 1354 run, 0 fail, 9 skipped | 90.19% lines, 89.64% instructions | 90.22% lines, 89.68% instructions | 100% |
| Python | 0 files | 2084 tests | ✅ 2084 pass, 0 fail | 90.99% lines, 81.83% branches | 90.99% lines, 81.83% branches | N/A - no Python source changed |
| TypeScript | 0 files | N/A | N/A | N/A - out of scope | N/A - out of scope | N/A - out of scope |
| C# | 0 files | N/A | N/A | N/A - out of scope | N/A - out of scope | N/A - out of scope |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on this branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on this branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/powershell-coverage.baseline.xml`
- PowerShell post-change coverage artifact: `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/powershell-coverage.post-change.xml` (workspace copy: `artifacts/pester/powershell-coverage.xml`, verified byte-equivalent counters by independent parse)
- Per-language comparison summary: section 1.2.1 of this document

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required. This audit includes them for PowerShell (the only language with changed files) and, informationally, for Python.

---

## Executive Summary

This branch fixes a cross-repository portability defect in `Invoke-PoshQCTest` (issue #409): configured `CodeCoverage.Path` entries were forwarded to Pester without an existence check, and Pester's `Resolve-CoverageInfo` aborts the run at RunStart on the first unresolvable entry in any consumer workspace lacking this repository's coverage layout. The fix prunes nonexistent resolved coverage paths through the existing injectable `$TestPathExists` seam, logs every pruned path individually through the `$Logger` seam, and disables coverage (with one logged explanation) when no configured path survives, then proceeds with the test run. The edit is a single 20-line hunk applied byte-identically to the canonical module and its bundled mirror, plus one new 259-line seam-injected Pester test file with four scenarios.

The reviewer independently verified: mirror byte-identity (identical git blob `e8d9a396aae9ed36645239f98ea08b62fd0bee93`), the bundled-parity pytest (1 passed), the new Pester test file (4/4 passed), PSScriptAnalyzer on all three changed PowerShell files with repo settings (0 diagnostics), Invoke-Formatter check-only comparison (0 files would be reformatted), coverage-artifact parsing (repo-wide PowerShell line coverage 90.22%, changed file `PoshQC.Testing.psm1` at 100% line coverage, 8/8 instrumented changed lines covered), per-file coverage entry-set invariance (31 entries baseline and post-change, set difference empty), and the evidence-locations validator (exit 0, clean).

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md` (PowerShell code change + unit test rules)
- ✅ `.claude/rules/python.md` (informational: Python toolchain re-verified though zero Python files changed)
- N/A TypeScript, C#, Bash, JSON (zero changed files in those languages)

**Temporary artifacts cleanup:**
- ✅ Consumer-scenario tool output (`tests/artifacts/`) was removed after evidence capture (`evidence/other/consumer-scenario-cleanup.2026-07-25T11-18.md`); reviewer confirmed `tests/artifacts` does not exist and `git status --porcelain` is empty.
- ✅ No temporary scripts remain in the branch diff.

**Rejected scope narrowing:** none detected. The caller instructed a full feature-vs-base audit; the scope exclusions recorded in `spec.md` (SD1 `Run.Path` latent risk, no version bump/publish, `pester.runsettings.psd1` unchanged) are documented feature-scope decisions in the authoritative spec, not caller-imposed narrowing of this audit, and the audit still covered the full branch diff.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each `It` block in `PoshQC.TestingCoveragePruning.Tests.ps1` re-arranges its own `$script:` capture state and injects all seams per invocation; no cross-test state. The file passed both standalone (reviewer run: 4/4) and inside the full 1354-test suite. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Four `It` blocks map one-to-one to the four required scenarios (all-exist pass-through, mixed set, empty surviving set, rooted absolute entry). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer standalone run: 4 tests in 705 ms. Full-suite discovery and execution unchanged in character (executor: full suite in ~36.5 s for 1345 tests, direct run). |
| **Determinism** - Consistent results | ✅ PASS | All filesystem, settings, Pester, and logging interactions go through injected scriptblock seams; `New-Item` is mocked inside `InModuleScope`; no wall-clock, RNG, sleeps, or subprocesses. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange/Act/Assert comments in every test; descriptive `It` names; header comment explains the path-discriminating `$TestPathExists` predicate rationale. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Baseline: 90.19% lines (2143/2376), 89.64% instructions. Command: direct repo-root module run `pwsh -NoLogo -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest"` (pre-fix blob `53756b61`). Artifact: `evidence/baseline/powershell-coverage.baseline.xml`, captured 2026-07-25T10-52. Reviewer re-parsed the XML and confirmed the numbers. |
| **No Coverage Regression** | ✅ PASS | Post-change: 90.22% lines (2150/2383), 89.68% instructions. Change: +0.03% lines. Reviewer re-parsed both XMLs independently; missed-line count unchanged at 233. |
| **New Code Coverage ≥90%** | ✅ PASS | Changed region `PoshQC.Testing.psm1` lines 346-366: 8/8 instrumented lines covered = 100% (reviewer re-parsed: lines 352, 353, 355, 358, 359, 363, 364, 365 all `ci>0`). File-level: 202/202 lines = 100%. |
| **Comprehensive Coverage** | ✅ PASS | The pruning block is exercised by all four scenarios; both branches of the surviving-set conditional are executed (scenarios 1/2/4 take the non-empty branch, scenario 3 takes the disable branch). |
| **Positive Flows** - Valid inputs | ✅ PASS | Scenario 1: all configured paths exist → full resolved set forwarded, coverage stays enabled, zero prune lines. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Scenario 3: no configured path exists → `CodeCoverage.Enabled` false at `$InvokePester`, disable message logged exactly once, run proceeds, coverage copy skipped. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Scenario 2 (mixed set, order preserved) and scenario 4 (rooted absolute entry evaluated as-is, never re-joined to `-Root`). |
| **Error Handling** - Error paths | ✅ PASS | The defect's error path (terminating RunStart abort) is eliminated by construction; the fail-before artifact (`evidence/regression-testing/fail-before.2026-07-25T11-05.md`) proves pre-fix code forwarded nonexistent paths (3 expected failures against blob `53756b61`, quoted assertion output). |
| **Concurrency** - If applicable | N/A | No concurrent behavior in scope. |
| **State Transitions** - If applicable | N/A | No stateful component in scope. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.19% lines -> Post-change: 90.22% lines. Change: +0.03% lines (instructions 89.64% -> 89.68%). New/changed-code coverage: 100% (8/8 instrumented changed lines; changed file 202/202 lines). Disposition: PASS. Evidence: `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/powershell-coverage.baseline.xml`; `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/powershell-coverage.post-change.xml`; reviewer independent XML parse.
- Python: Baseline: 90.99% lines, 81.83% branches -> Post-change: 90.99% lines, 81.83% branches. Change: 0.00% (no Python source file changed on this branch; thresholds 85%/75% both satisfied). New/changed-code coverage: N/A - no Python source file changed. Disposition: PASS. Evidence: `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/final-python-pytest.2026-07-25T11-38.md`; workspace artifact `artifacts/python/lcov.info` present.

PowerShell branch coverage is not separately measurable in this toolchain: Pester 5.6.1's JaCoCo output emits `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters only, with no `BRANCH` counter. Reviewer confirmed the counter-type set by parsing all three coverage XMLs. This is the documented limitation recorded in `spec.md` Test Strategy and predates this change; both branches of the new conditional are nonetheless demonstrably executed by the four seam tests. TypeScript and C# have zero changed files on this branch, so their coverage checks are out of scope for this audit.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `Should -Be` on full expected arrays and exact log-line strings; the fail-before artifact shows the produced diagnostics name the offending path (`Expected @(...), but got @(... '/prune-root/missing-b.ps1' ...)`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit `# Arrange` / `# Act` / `# Assert` comments in each `It` block. |
| **Document Intent** | ✅ PASS | Describe-level comment explains the seam strategy and why `$TestPathExists` must be path-discriminating; each assertion group carries an intent comment. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, no live Pester subprocess for the code under test, no databases. `Invoke-PoshQCTest` is driven entirely through injected seams. |
| **Use Mocks/Stubs** | ✅ PASS | `New-Item` mocked inside `InModuleScope PoshQC` (prevents coverage-output directory creation); `$LoadSettings`, `$BuildConfiguration`, `$EnsureModule`, `$ResolveScanConfig`, `$EnumerateTests`, `$InvokePester`, `$CopyCoverage`, `$Logger`, `$TestPathExists`, `$ExpandCoveragePaths` all injected. |
| **Environment Stability** | ✅ PASS | No temporary files created by the new tests (temp files in tests are prohibited); reviewer confirmed the working tree is clean after running the file. Consumer-scenario tool output was cleaned up per `evidence/other/consumer-scenario-cleanup.2026-07-25T11-18.md`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required policy review, produced during feature review against the full branch diff. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #409; `issue.md` and `spec.md` in the feature folder define the defect, expected behavior, and approved approach (research option (a)). |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md` records the policy reading order; the plan `plan.2026-07-25T09-58.md` cites the research artifact. |
| **Document the plan** | ✅ PASS | `plan.2026-07-25T09-58.md` and `research/2026-07-25T10-20-bundled-coverage-path-portability-409-research.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The fix is one contiguous block at the final authoritative coverage-path resolution site; no new parameters, no new abstractions. |
| **Reusability** | ✅ PASS | Reuses the existing `$TestPathExists` and `$Logger` seams rather than introducing new ones. |
| **Extensibility** | ✅ PASS | Public parameter surface of `Invoke-PoshQCTest` unchanged; behavior remains overridable via the existing seams. |
| **Separation of concerns** | ✅ PASS | Existence checking is delegated to the injectable predicate; logging to the injectable logger; no I/O added inline. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Change confined to the coverage-enabled block of one function, mirrored byte-identically. |
| **Under 500 lines** | ✅ PASS | Reviewer measured: `PoshQC.Testing.psm1` 463 lines (was 443); mirror identical; new test file 259 lines. All under the 500-line cap. |
| **Public vs internal** | ✅ PASS | No public surface change. |
| **No circular dependencies** | ✅ PASS | No new imports or module relationships. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `$survivingCoveragePaths`, `$prunedPath` are literal and unambiguous. |
| **Docs/docstrings** | ✅ PASS | Block comment explains the Pester `Resolve-CoverageInfo` failure mechanism and cites issue #409; the disable branch documents the enabled-but-empty `Run.Path` instrumentation hazard. |
| **Comment why, not what** | ✅ PASS | Comments state rationale (why pruning is logged, why coverage is disabled) rather than narrating statements. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Executor: `mcp__drm-copilot__run_poshqc_format`, EXIT_CODE 0, no files reformatted (`evidence/qa-gates/final-poshqc-format.2026-07-25T11-22.md`). Reviewer check-only re-verification: `Invoke-Formatter -ScriptDefinition` comparison on all three changed files with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` — 0 files would be reformatted. |
| **2. Linting** | ✅ PASS | Executor: `mcp__drm-copilot__run_poshqc_analyze`, EXIT_CODE 0 (`evidence/qa-gates/final-poshqc-analyze.2026-07-25T11-23.md`). Reviewer: `Invoke-ScriptAnalyzer` per changed file with repo settings — no diagnostics. |
| **3. Type checking** | N/A | Not applicable for PowerShell per `.claude/rules/powershell.md`. Python informational: `poetry run pyright` EXIT_CODE 0 (`evidence/qa-gates/final-python-pyright.2026-07-25T11-37.md`). |
| **4. Testing** | ✅ PASS | Executor: `mcp__drm-copilot__run_poshqc_test` — 1354 tests, 0 failures, 9 skipped (`evidence/qa-gates/final-poshqc-test.2026-07-25T11-26.md`). Reviewer re-ran the new test file (4/4) and the parity pytest (1 passed). Python informational: 2084 passed (`evidence/qa-gates/final-python-pytest.2026-07-25T11-38.md`). |
| **Full toolchain loop** | ✅ PASS | Final chain 11-22 (format) → 11-23 (analyze) → 11-26 (test) all clean in a single pass; no stage changed files, so no restart was required. |
| **Explicit reporting** | ✅ PASS | Every stage has a timestamped evidence artifact with `Command:`, `EXIT_CODE:`, and `Output Summary:` fields. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `dbf2e3f5` `fix(poshqc): prune nonexistent bundled coverage paths before Pester run`; spec Proposed Fix section. |
| **Design choices explained** | ✅ PASS | Spec records the SD2 empty-set decision and rejection of research options (b) and (c) with rationale. |
| **Update supporting documents** | ✅ PASS | Feature folder contains issue, spec, plan, research, and complete evidence tree. |
| **Provide next steps** | ✅ PASS | Spec Rollout section: separate release action for consumer delivery; separate issue for the SD1 `Run.Path` latent risk. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | Baseline (`evidence/baseline/baseline-poshqc-format.2026-07-25T10-40.md`) and final (`...T11-22.md`) both EXIT_CODE 0; reviewer check-only comparison clean. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | Baseline (`...T10-41.md`) and final (`...T11-23.md`) EXIT_CODE 0; reviewer per-file run with `pssa.settings.psd1`: no diagnostics. |
| **Fix all findings** | ✅ PASS | Zero findings to fix. |
| **PowerShell 7+ compatible** | ✅ PASS | The new block uses `Where-Object`, `foreach`, `-notcontains`, and string interpolation only; PSSA compatibility rules produced no diagnostics. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `Invoke-PoshQCTest` is an existing advanced function; no signature change. |
| **Parameter validation** | ✅ PASS | No new parameters; existing seam parameters reused. |
| **Avoid global state** | ✅ PASS | All state is function-local (`$survivingCoveragePaths`, `$prunedPath`). |
| **Error handling** | ✅ PASS | No catch-alls introduced; the change removes an abort path by preventing invalid input from reaching Pester, and every removal is logged. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 463 / 463 (mirror) / 259 lines, reviewer-measured. |
| **Approved verbs** | ✅ PASS | No new functions added. |
| **Comment why** | ✅ PASS | Rationale comments cite the Pester failure mechanism and issue #409. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | EXIT_CODE 0, no reformats. |
| **Step 2: Analyze** | ✅ PASS | EXIT_CODE 0, no diagnostics. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 1354 tests, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | Single pass; no stage mutated files. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester 5.6.1; `Describe`/`It`, `BeforeAll`, `InModuleScope`, modern `Should` syntax. |
| **Use PoshQC Configuration** | ✅ PASS | Suite runs under `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged on this branch); the new file was discovered and passed inside the gated run (JUnit suite entry `tests=4 failures=0`). |
| **PowerShell 7+ Compatible** | ✅ PASS | Reviewer ran the file under pwsh 7; 4/4 passed. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One scenario per `It`; all four spec-required scenarios present. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions verify the config handed to `$InvokePester`, the logged messages, and the copy-step behavior — the observable contract, not internals. |
| **Mocking Used Sparingly** | ✅ PASS | Only `New-Item` is mocked (to keep the tests free of filesystem writes); everything else uses the module's designed injection seams. |
| **Organization** | ✅ PASS | Test file `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` mirrors code file `scripts/powershell/PoshQC/PoshQC.Testing.psm1` per the tests-mirror-source layout rule. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `PoshQC.TestingCoveragePruning.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe, 4 It blocks (Context not needed at this size). |
| **Logical Grouping** | ✅ PASS | All pruning scenarios grouped under one Describe named for the behavior and issue. |
| **Docstrings/Comments** | ✅ PASS | Self-documenting It names plus intent comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | Gated run via `mcp__drm-copilot__run_poshqc_test`; invariance harness via direct repo-root `Invoke-PoshQCTest` (documented harness-parity rationale in `evidence/qa-gates/direct-module-post-change-run.2026-07-25T11-30.md`). |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### Invoke-PoshQCTest coverage-path pruning block (4 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| passes the full resolved coverage set through and logs no prune lines when every configured path exists | Positive | 352, 353, 358, 359 | ✅ |
| keeps only the existing paths and logs each pruned path with its resolved value for a mixed set | Edge Case | 352, 353, 355, 358, 359 | ✅ |
| disables coverage at the $InvokePester boundary, logs one explanation, proceeds with the run, and skips the coverage copy when no configured path exists | Negative / Error Handling | 352, 353, 355, 358, 363, 364, 365 | ✅ |
| evaluates a rooted absolute entry with the same predicate and never re-joins it to -Root | Edge Case | 352, 353, 355, 358, 359 | ✅ |

**Coverage:** 100% of the changed region (`PoshQC.Testing.psm1` lines 346-366; 8/8 instrumented lines: 352, 353, 355, 358, 359, 363, 364, 365 — reviewer re-parsed `powershell-coverage.post-change.xml`).

**Not covered:** None in the changed region. File-level: 202/202 lines covered; 4 missed instructions are pre-existing (unchanged from baseline).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (PowerShell gated run) | 1354 | ✅ |
| Tests Passed | 1354 run, 0 failures, 9 skipped | ✅ |
| Tests Failed | 0 | ✅ |
| New-file standalone execution time | 705 ms for 4 tests (reviewer run) | ✅ Fast |
| Full direct-module run time | 36.51 s for 1345 executed tests | ✅ |
| Parity pytest | 1 passed in 0.02 s (reviewer run) | ✅ Fast |
| Python full suite (informational) | 2084 passed | ✅ |
| Test File Size | 259 lines | ✅ Maintainable |
| Code Coverage (PowerShell) | 90.22% lines; branch counter not emitted by toolchain (documented limitation) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` (executor); `Invoke-Formatter -ScriptDefinition` check-only comparison (reviewer) | No reformats; 0 files would change | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` (executor); `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (reviewer, per changed file) | 0 diagnostics | ✅ |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` (executor); `Invoke-Pester -Path tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` (reviewer) | 1354/0 failures; 4/4 | ✅ |

**For Python (informational — zero Python files changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black .` | Clean | ✅ |
| Ruff | `poetry run ruff check .` | Clean | ✅ |
| Pyright | `poetry run pyright` | 0 errors | ✅ |
| Pytest | `poetry run pytest --cov --cov-branch --cov-report=term-missing`; reviewer re-ran `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q` | 2084 passed; parity 1 passed | ✅ |

**Evidence-location compliance:** `python scripts/dev_tools/validate_evidence_locations.py --root .` — EXIT_CODE 0, no violations. Reviewer also scanned the branch diff name-status list: no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`; all evidence resolves under `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/<kind>/`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no caller supplied a non-canonical evidence path.

**Policy rule `modified-workflow-needs-green-run`:** not triggered. The branch diff contains no paths under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (verified via `git diff --name-status 036daf8d..dbf2e3f5`).

**Notes:**
No pre-existing failures were observed in any stage.

---

## 8. Gaps and Exceptions

### Identified Gaps
- PowerShell branch coverage cannot be numerically evaluated: Pester 5.6.1's JaCoCo output emits no `BRANCH` counter (reviewer verified the counter-type set in all three coverage XMLs). This is a toolchain limitation documented in `spec.md` Test Strategy, not a gap introduced by this change; both branches of the new conditional are demonstrably executed by the seam tests. Severity: Informational; no remediation required for this branch.

### Approved Exceptions
- **None.** No policy exceptions were needed.

### Removed/Skipped Tests
- **None removed.** The 9 skipped tests in the gated run are pre-existing suite skips, unchanged from the baseline run (baseline also reported 9 skipped).

### Recorded anomalies (informational, from orchestrator state)
- The promotion audit-trail file `docs/features/potential/promoted/2026-07-25-bundled-coverage-path-portability.md` disappeared from disk mid-run by an unidentified mechanism and was restored by the orchestrator as a faithful reconstruction. Reviewer confirmed the file exists on disk and in the branch diff. Content provenance is reconstruction rather than byte-exact recovery; this does not affect production code or acceptance criteria.
- Both complexity-floor reference implementations reportedly return `C3` for any non-empty signal list, diverging from the documented contract. Out of scope for this branch (no related file changed here); noted for separate tracking.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **dbf2e3f5** - `fix(poshqc): prune nonexistent bundled coverage paths before Pester run` (single commit; range `036daf8d..dbf2e3f5`)

### Files Modified

1. **scripts/powershell/PoshQC/PoshQC.Testing.psm1** (MODIFIED, +22/-2)
   - Added the coverage-path pruning block in the coverage-enabled section of `Invoke-PoshQCTest` (lines 346-366): existence filter via `$TestPathExists`, per-path prune logging via `$Logger`, and coverage disable with logged explanation when no path survives.
2. **extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1** (MODIFIED, +22/-2)
   - Byte-identical mirror of the above (git blob `e8d9a396` both, reviewer-verified).
3. **tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1** (NEW, 259 lines)
   - Four deterministic seam-injected scenarios covering pass-through, mixed set, empty surviving set, and rooted absolute entries.
4. **34 documentation/evidence files** (NEW) under `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/` and `docs/features/potential/promoted/` — issue, spec, plan, research, and the baseline/qa-gates/regression-testing/other evidence tree, including both preserved coverage XMLs.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All applicable policy requirements are met. The production change is minimal, seam-based, mirrored byte-identically, fully covered by new deterministic tests, and verified against both this repository (behavioral invariance: identical 31-file coverage set, zero prunes, +0.03% line coverage) and the consumer-repository failure scenario (run completes instead of aborting at RunStart).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objective, plan, and research documented
- ✅ Design Principles: minimal seam-based change
- ✅ Module & File Structure: all files under 500 lines
- ✅ Naming, Docs, Comments: rationale comments present
- ✅ Toolchain Execution: single clean pass, evidence per stage
- ✅ Summarize & Document: complete feature folder

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format/analyze clean (executor and reviewer)
- ✅ PowerShell Design & Safety: no new parameters, no global state
- ✅ Structure & Naming: 463/259 lines, descriptive names
- ✅ Toolchain: single pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, fast, deterministic
- ✅ Coverage & Scenarios: 100% changed-line coverage; 90.22% repo-wide line coverage
- ✅ Test Structure: AAA with intent comments
- ✅ External Dependencies: none; no temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5.6.1 under PoshQC config
- ✅ Test Style & Structure: behavior-focused, seams over mocks
- ✅ Naming & Readability: conforming file name and structure
- ✅ Toolchain: PoshQC gated run plus documented direct-run invariance harness

---

### Metrics Summary

- ✅ 1354/1354 PowerShell tests passing (0 failures, 9 pre-existing skips)
- ✅ 2084/2084 Python tests passing (informational)
- ✅ 90.22% PowerShell line coverage (baseline 90.19%, no regression)
- ✅ 100% changed-line coverage (8/8 instrumented lines)
- ✅ Byte-identical bundled mirror (blob `e8d9a396`)
- ✅ All code quality checks passing (format, analyze, tests, parity)
- ✅ Evidence locations canonical (validator exit 0)

---

### Recommendation

**Ready for merge.**

Blocking findings: 0. No remediation plan is required. Delivery to consumers requires the separate, explicitly out-of-scope release action (version bump and npm publish of `@danmoisan/drm-copilot-mcp` > 1.0.18).

---

## Appendix A: Test Inventory

New tests added by this branch (`tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1`):

1. Invoke-PoshQCTest coverage-path pruning (issue #409) › passes the full resolved coverage set through and logs no prune lines when every configured path exists
2. Invoke-PoshQCTest coverage-path pruning (issue #409) › keeps only the existing paths and logs each pruned path with its resolved value for a mixed set
3. Invoke-PoshQCTest coverage-path pruning (issue #409) › disables coverage at the $InvokePester boundary, logs one explanation, proceeds with the run, and skips the coverage copy when no configured path exists
4. Invoke-PoshQCTest coverage-path pruning (issue #409) › evaluates a rooted absolute entry with the same predicate and never re-joins it to -Root

Pre-existing suites relevant to the changed surface (all passing, unchanged): `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, `PoshQC.TestingInvokeSummary.Tests.ps1`, `PoshQC.TestingSeamDefaults.Tests.ps1`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_bundled_poshqc_files_match` (parity contract).

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting (gated)
# MCP tool: mcp__drm-copilot__run_poshqc_format (workspace_root = repo root)
# Reviewer check-only equivalent:
Invoke-Formatter -ScriptDefinition (Get-Content -Raw <file>) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting (gated)
# MCP tool: mcp__drm-copilot__run_poshqc_analyze (workspace_root = repo root)
# Reviewer equivalent:
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing (gated)
# MCP tool: mcp__drm-copilot__run_poshqc_test (workspace_root = repo root)
# Direct invariance harness:
pwsh -NoLogo -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest"
# Targeted new-file run:
pwsh -NoLogo -NoProfile -Command "Invoke-Pester -Path tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 -Output Normal"
```

**For Python:**
```bash
# Formatting
poetry run black .
# Linting
poetry run ruff check .
# Type checking
poetry run pyright
# Testing with coverage
poetry run pytest --cov --cov-branch --cov-report=term-missing
# Parity contract only
poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
```

**Cross-cutting:**
```bash
# Evidence-location compliance
python scripts/dev_tools/validate_evidence_locations.py --root .
# Mirror byte-identity
git hash-object scripts/powershell/PoshQC/PoshQC.Testing.psm1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-07-25
**Policy Version:** Current (as of audit date)

# Policy Compliance Audit: PoshQC Bundled Mock-Scope Failure Fix (Issue #392)

**Audit Date:** 2026-07-21
**Code Under Test:**
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (MODIFIED, production)
- `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` (MODIFIED, production mirror, byte-identical)
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (MODIFIED, coverage settings)
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (MODIFIED, settings mirror, byte-identical)
- `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` (NEW, test)
- `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` (MODIFIED, test, +3/-3)
- 32 documentation/evidence Markdown files under `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/`

**Baseline:** base branch `main`, merge-base `193864d87f3dfcc2e2a18987ec2ecc592dfea93b`; head `drm-copilot-wt-2026-07-21T17-18` @ `92bf1f29659da829e4cbf4d0bcc4af2182d87b06`. Scope is the full branch diff against the merge base.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 6 files | 1341 tests | 1332 pass, 0 fail, 9 skipped | 89.41% lines | 88.26% lines | N/A (no new production files) |
| Python | 0 files | N/A | N/A (no changed files on branch) | N/A (no changed files on branch) | N/A (no changed files on branch) | N/A |
| TypeScript | 0 files | N/A | N/A (no changed files on branch) | N/A (no changed files on branch) | N/A (no changed files on branch) | N/A |
| C# | 0 files | N/A | N/A (no changed files on branch) | N/A (no changed files on branch) | N/A (no changed files on branch) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/evidence/baseline/poshqc-test-baseline.2026-07-21T18-01.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (regenerated 2026-07-21T19-23 by the reviewer via `pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1`, exit 0), summarized in `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/evidence/qa-gates/final-test-coverage.2026-07-21T18-01.md`
- Per-language comparison summary: section 1.2.1 of this audit

**Template source note:** MCP tools are unavailable in this review session, so the `resolve_policy_audit_template_asset` resolver could not be invoked. The template was read directly from the bundled asset source file `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the same file the resolver returns for the `template` selector (asset map: `extensions/drm-copilot/src/policy-audit-template-assets.ts`).

---

## Rejected Scope Narrowing

None detected. The caller prompt requested a full feature-vs-base review of the branch against `main` at merge-base `193864d8` and did not attempt to narrow scope to a plan subset, a file subset, or to mark any language's coverage as out of scope. The audit scope is the full branch diff.

---

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` — EXIT_CODE: 0 (no violations).
- Branch diff scan: zero files in the diff are located under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 20 evidence artifacts in the diff are under the canonical `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/evidence/<kind>/` tree.
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events; no caller instruction supplied a non-canonical evidence path.

---

## Executive Summary

This audit covers the fix for issue #392: 31 Pester failures (`Mock data are not setup for this scope`) that occurred only when the PoshQC suite was run through the bundled entry point. The fix changes two default seam scriptblocks in `Invoke-PoshQCTest` (`$EnsureModule` gains `-Global`; `$InvokePester` becomes a global-session-state trampoline with try/finally removal), adds the changed module to the Pester coverage measurement set, adds a new seam-default regression test file, and injects an explicit `-InvokePester` stub into 3 pre-existing Koverage tests.

The reviewer independently re-ran the PowerShell toolchain (format check, analyzer, full test suite with coverage) and the production reproduction path. All checks pass: 0 analyzer findings, 0 format diffs, 1332 passed / 0 failed / 9 skipped, and the previously failing bundled-manifest invocation now exits 0 with no trampoline leak.

One policy FAIL remains: the modified production file `scripts/powershell/PoshQC/PoshQC.Testing.psm1` has 76.41% per-file line coverage, below the 85% line floor required for modified files (all changed lines are covered; the shortfall is in pre-existing seam code paths that entered the measured set with this change). This triggers remediation per the feature-review workflow thresholds.

**Policy documents evaluated:**
- [x] `general-code-change` policy (`.claude/rules/general-code-change.md`)
- [x] `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- [x] PowerShell: `.claude/rules/powershell.md` (plus `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`)
- N/A Python, TypeScript, C#, Bash, JSON: zero changed files of these languages on the branch (the Python parity gate `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` was executed as a gate but no Python file changed)

**Temporary artifacts cleanup:**
- [x] No temporary or one-time scripts remain in the branch diff; `git status --porcelain` is clean after all reviewer re-runs
- [x] The E3 instrumentation (plan P0-T10) was reverted within its task; `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` contains only the 3 planned seam-injection edits

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | New tests in `PoshQC.TestingSeamDefaults.Tests.ps1` use `BeforeAll` module-collision guard plus `AfterEach` cleanup of `Function:\Invoke-PoshQCPesterRun` and the stub `Function:\Invoke-Pester`, so no state crosses tests. Full suite passes when the file runs inside the complete 1341-test run. |
| **Isolation** - Each test targets single behavior | PASS | 3 new `It` blocks: trampoline lifecycle + PassThru, `-Global` import, throw-on-unavailable. One behavior each. |
| **Fast Execution** - Tests complete quickly | PASS | Full suite 45.72s for 1341 tests (reviewer run 2026-07-21T19-23); the new file completes in under 300ms per the per-file Pester timing output. |
| **Determinism** - Consistent results | PASS | New tests stub `Invoke-Pester` (no real nested Pester run), use in-process AST extraction of the default seam, and no network/clock/random dependencies. Reviewer re-runs reproduced identical counts to the executor evidence. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `Describe`/`It` names citing issue #392; Arrange/Act/Assert comments present in the trampoline test. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline (pre-change measured set): 89.41% lines (covered=1849, total=2068). Command: `mcp__drm-copilot__run_poshqc_test` (executor P0-T5). Artifact: `evidence/baseline/poshqc-test-baseline.2026-07-21T18-01.md`. |
| **No Coverage Regression on changed lines** | PASS | All 5 changed executable lines in `PoshQC.Testing.psm1` (165, 271, 272, 274, 279) show `ci>=1, mi=0` in `artifacts/pester/powershell-coverage.xml` (reviewer re-parsed 2026-07-21T19-23). No previously covered line lost coverage; the aggregate moved 89.41% -> 88.26% solely from adding the 195-executable-line file to the denominator. |
| **Modified-file coverage >= 85% lines** | FAIL | `scripts/powershell/PoshQC/PoshQC.Testing.psm1`: 76.41% lines (149/195 covered). Below the 85% modified-file line floor (`.claude/rules/quality-tiers.md` uniform gates; feature-review workflow step 5 thresholds), and below the 80% remediation trigger. Uncovered lines are pre-existing seam bodies that entered measurement with this change: 98, 291, 309, 314-316, 322, 332, 340-342, 346, 350-354, 356-357, 359, 368-369, 401-403, 410-415, 417-420, 423-424, 427-428, 433-439. Remediation required. |
| **New Code Coverage** | N/A | No new production files. The new file is a test file, excluded from coverage measurement per policy. |
| **Positive Flows** | PASS | Trampoline test asserts the result object round-trips (`Marker`, `Config.Marker`) and the trampoline exists during the call; `-Global` import test asserts `Import-Module -Name Pester -Global`. |
| **Negative Flows** | PASS | `throws the supplied error when the module is unavailable` (Get-Module stubbed to `$null` -> `*Pester is not installed*`); settings-not-found throw exercised as the isolation cutoff in the `-Global` test. |
| **Edge Cases** | PASS | Trampoline leak checked after the call (`Test-Path` false); `finally` removal verified under normal return. |
| **Error Handling** | PASS | Throw-on-unavailable and throw-on-settings-not-found paths asserted; preserved behaviors re-verified by the full suite. |
| **Concurrency** | N/A | Single-session Pester host; no concurrent execution paths changed. |
| **State Transitions** | PASS | Global function create -> invoke -> remove lifecycle asserted in one test, including the removed end state. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 89.41% lines -> Post-change: 88.26% lines. Change: -1.15% lines, caused by adding `PoshQC.Testing.psm1` (195 executable lines) to the measured set rather than by any lost line coverage. New/changed-code coverage: 100.00% of the 5 changed executable lines; the modified file itself sits at 76.41% lines, below the 85% modified-file floor. Disposition: FAIL. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/evidence/qa-gates/coverage-delta.2026-07-21T18-01.md`.
- Python: no changed files on the branch; no coverage obligation. Disposition: N/A.
- TypeScript: no changed files on the branch; no coverage obligation. Disposition: N/A.
- C#: no changed files on the branch; no coverage obligation. Disposition: N/A.

Branch-coverage note: the Pester/JaCoCo output emits only INSTRUCTION, LINE, METHOD, and CLASS counters (verified by parsing `artifacts/pester/powershell-coverage.xml`; no BRANCH counter exists in the report). A numeric branch percentage therefore cannot be computed from the toolchain output for any PowerShell run in this repository. The changed code contains one `try/finally` and one guard conditional; per-line inspection shows both the `try` body (line 274) and the `finally` body (line 279) plus the guard's throw path are executed. This limitation is recorded in section 8 and supports the non-PASS overall verdict under the fail-closed rule.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `Should -BeTrue/-BeFalse/-Be/-Throw` with expected literals (`'*Settings not found*'`, `'*Pester is not installed*'`) produce actionable Pester diagnostics. |
| **Arrange-Act-Assert Pattern** | PASS | Explicit Arrange/Act/Assert comments in the trampoline test; the other tests follow the same shape with mock arrangement then assertion. |
| **Document Intent** | PASS | Each `Describe`/`It` names the seam and behavior; comments explain why the AST extraction and the settings-path cutoff are used. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or external process use. No nested real `Invoke-Pester` run (stubbed). |
| **Use Mocks/Stubs** | PASS | `Import-Module`, `Get-Module`, and `Invoke-Pester` are stubbed/mocked at the narrowest scope (`InModuleScope PoshQC` or a temporary global function removed in `AfterEach`). |
| **Environment Stability** | PASS | No temporary files created by tests; paths resolved from `$PSScriptRoot`; no reliance on ambient PATH or working directory. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy review for the branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #392; `issue.md` (Work Mode: full-bug), `spec.md` with confirmed empirical root cause (experiments E1a/E1b/E2/E3/E4). |
| **Read existing change plans** | PASS | `plan.2026-07-21T17-26.md` (v1.1) governs the change; executed phases recorded in the PR context summary. |
| **Document the plan** | PASS | Plan file plus research doc `research/2026-07-21T18-05-poshqc-bundled-mock-scope-failure-392-research.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Fix is confined to two default seam scriptblocks; no signature, caller, or architecture changes. |
| **Reusability** | PASS | Existing seam-injection pattern reused; injected-seam callers bypass the new defaults unchanged. |
| **Extensibility** | PASS | Seam parameters remain injectable; defaults changed without altering names, positions, or contracts. |
| **Separation of concerns** | PASS | Hosting concern (session state of the Pester run) isolated at the `$InvokePester` seam; configuration, scan resolution, and coverage handling untouched. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Changes stay within the testing seam layer (`PoshQC.Testing.psm1`) and its settings file. |
| **Under 500 lines** | PARTIAL | `PoshQC.Testing.psm1` 443 lines, `pester.runsettings.psd1` 110, new test file 100 — all compliant. `PoshQC.Comprehensive.Tests.ps1` is 766 lines, over the 500-line limit, but it was already 766 lines at the merge base and this diff is +3/-3 (net zero). Pre-existing condition, not introduced by this branch; recorded in section 8. |
| **Public vs internal** | PASS | No public API surface change; `Invoke-PoshQCTest` signature unchanged. The temporary global function `Invoke-PoshQCPesterRun` exists only for the duration of the Pester call. |
| **No circular dependencies** | PASS | No import graph change beyond `-Global` placement of Pester. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Invoke-PoshQCPesterRun` uses an approved verb and a descriptive noun. |
| **Docs/docstrings** | PASS | `spec.md` Proposed Fix and Root Cause Analysis updated; `pester.runsettings.psd1` addition carries an issue-#392 rationale comment. |
| **Comment why, not what** | PASS | The trampoline block documents why an unbound scriptblock is required and why removal must use the `Function:\` provider path (a `function:global:`-qualified path silently no-ops on `Remove-Item`). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Executor: `mcp__drm-copilot__run_poshqc_format` exit 0 (`evidence/qa-gates/final-format.2026-07-21T18-01.md`). Reviewer re-verification (check-only): `Invoke-Formatter` output equals file content for all 6 changed PowerShell files (0 diffs), settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. |
| **2. Linting** | PASS | Executor: `mcp__drm-copilot__run_poshqc_analyze` exit 0, 0 findings (`evidence/qa-gates/final-analyze.2026-07-21T18-01.md`). Reviewer re-verification: `Invoke-ScriptAnalyzer` on all 6 changed files with repo settings — 0 findings. |
| **3. Type checking** | N/A | Not applicable for PowerShell per `.claude/rules/powershell.md`. |
| **4. Testing** | PASS | Reviewer: `pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1` — exit 0; 1332 passed, 0 failed, 9 skipped; coverage recorded. Matches executor evidence `evidence/qa-gates/final-test-coverage.2026-07-21T18-01.md`. Environment note: `mcp__drm-copilot__run_poshqc_test` exits 33 because the installed MCP extension loads a pre-fix bundled module snapshot from the main-repo install (reviewer verified 0 `Invoke-PoshQCPesterRun` references in the installed copy vs 3 in this worktree); this is not a defect in the branch and resolves when the extension is repackaged from merged main. Recorded in section 8. |
| **Full toolchain loop** | PASS | Format -> analyze -> test completed with no file changes and no failures in a single reviewer pass; `git status --porcelain` clean afterward. |
| **Explicit reporting** | PASS | Commands and exit codes recorded here and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Section 9 of this audit; `spec.md` design summary. |
| **Design choices explained** | PASS | Global-session-state hosting rationale and the rejected alternatives are documented in `spec.md` and the research doc. |
| **Update supporting documents** | PASS | `spec.md`, `issue.md`, plan, and 20 evidence artifacts updated/added. |
| **Provide next steps** | PASS | Remediation inputs and plan target created (coverage floor); post-merge extension repackage noted. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | Reviewer check-only run: 0 diffs across the 6 changed PowerShell files; executor gate exit 0. |
| **Linting with PSScriptAnalyzer** | PASS | Reviewer run: 0 findings on the 6 changed files with `pssa.settings.psd1`; executor gate exit 0. |
| **Fix all findings** | PASS | Zero findings to fix. |
| **PowerShell 7+ compatible** | PASS | Uses `[scriptblock]::Create`, `New-Item function:` provider, `Remove-Item Function:\` — all PowerShell 7-safe; analyzer compatibility rules produced no findings. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `Invoke-PoshQCTest` retains `CmdletBinding()`; changed code is default values of existing `[scriptblock]` parameters. |
| **Parameter validation** | PASS | No parameter contract changes; existing validation preserved (missing Pester/settings/scan-folder throws re-verified by tests). |
| **Avoid global state** | PASS with justification | The fix deliberately installs one temporary global function to host the Pester run in the global session state (the root-cause requirement). It is created immediately before `Invoke-Pester`, removed in `finally`, and the no-leak end state is asserted by a regression test and by the reviewer's repro run (`TRAMPOLINE-LEAK: False`). |
| **Error handling** | PASS | try/finally guarantees cleanup; `-ErrorAction SilentlyContinue` on the `Remove-Item` is a narrow idempotent-cleanup guard, not a silent catch-all on the run itself. Throw paths unchanged. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PARTIAL | Changed production files compliant (443/110 lines). Pre-existing 766-line `PoshQC.Comprehensive.Tests.ps1` exceeds the limit at baseline and head (net-zero size change in this diff); see section 8. |
| **Approved verbs** | PASS | `Invoke-PoshQCPesterRun` (Invoke is approved); no other new names. |
| **Comment why** | PASS | Rationale comments cite issue #392 and the `Remove-Item` provider-path behavior. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Check-only re-verification, 0 diffs. |
| **Step 2: Analyze** | PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | Full suite exit 0 (1332/0/9). |
| **Rerun loop if needed** | PASS | Single pass; no files changed by any stage. |

Change budget note: 4 production files changed = 2 logical production files x 2 parity mirrors, executed via orchestrated batches within the 3-production/3-test per-batch cap per the plan's Scope Constraints. Compliant with `.claude/rules/powershell.md`.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `BeforeAll`/`AfterEach`/`Describe`/`It`, `Should -Invoke`, `InModuleScope` — Pester v5 idioms throughout the new file. |
| **Use PoshQC Configuration** | PASS | Suite runs through `Invoke-PoshQCTest` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; this change adds `PoshQC.Testing.psm1` to `CodeCoverage.Path` following the established per-issue convention in that file. |
| **PowerShell 7+ Compatible** | PASS | Suite executed under pwsh 7 in this review. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 3 new tests, one seam behavior each. |
| **Test Behavior Over Implementation** | PASS with note | The tests extract the real default seam via AST rather than re-typing it, then assert observable behavior (global function lifecycle, PassThru integrity, `-Global` flag, throw message). AST extraction is implementation-coupled by nature but is the only way to exercise the true default value without a full run; the coupling is documented in the file. |
| **Mocking Used Sparingly** | PASS | Only the three boundary commands are stubbed (`Invoke-Pester`, `Import-Module`, `Get-Module`); mock signatures match production named parameters. |
| **Organization** | PASS | Test file `tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` mirrors production tree `scripts/powershell/PoshQC/` per the repository layout rule; no colocation. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | `PoshQC.TestingSeamDefaults.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | 2 Describe blocks, 3 It blocks; issue reference in Describe names. |
| **Logical Grouping** | PASS | One Describe per seam (`$InvokePester`, `$EnsureModule`). |
| **Docstrings/Comments** | PASS | Intent comments on the guard, AST extraction, and each mock. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Reviewer executed `scripts/dev-tools/run-poshqc-suite.ps1` (which calls `Invoke-PoshQCSuite` -> `Invoke-PoshQCTest`); also re-ran the bundled-manifest path `Import-Module ./extensions/.../PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'` — 98 passed, 0 failed, 7 skipped, exit 0. |
| **No Alternative Test Runners** | PASS | Pester via PoshQC only. |

---

## 5. Test Coverage Detail

### `Invoke-PoshQCTest` default `$InvokePester` seam (1 test)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| defines function:global:Invoke-PoshQCPesterRun during the run, removes it after, and returns the result unmodified | Positive + state transition | `PoshQC.Testing.psm1` 271-279 | PASS |

**Coverage:** changed trampoline lines 271, 272, 274, 279 all covered (`ci>=1, mi=0` in the JaCoCo per-line data).

### `Invoke-PoshQCTest` default `$EnsureModule` seam (2 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| imports the requested module with -Global | Positive | `PoshQC.Testing.psm1` 165 | PASS |
| throws the supplied error when the module is unavailable | Negative / error handling | `PoshQC.Testing.psm1` 163 throw path | PASS |

### Koverage-copy seam injections in `PoshQC.Comprehensive.Tests.ps1` (3 modified tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Should generate Koverage copy by default when coverage is enabled | Positive | seam bypass via injected `-InvokePester` | PASS |
| Should skip Koverage copy when DisableKoverageCopy is set | Negative | seam bypass via injected `-InvokePester` | PASS |
| Should use custom KoverageOutputPath when provided | Edge case | seam bypass via injected `-InvokePester` | PASS |

**Not covered:** 46 lines of `PoshQC.Testing.psm1` (pre-existing seam bodies newly added to measurement; enumerated in section 1.2). This is the FAIL driver for this audit.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 1341 | PASS |
| Tests Passed | 1332 (99.3%; remainder skipped) | PASS |
| Tests Failed | 0 | PASS |
| Tests Skipped | 9 | PASS (pre-existing skips) |
| Execution Time | 45.72s total (full suite) | PASS |
| Code Coverage (PowerShell, repo measured set) | 88.26% lines; branch counters not emitted by the toolchain | PARTIAL (repo-wide line floor met; per-file floor for the modified file not met — see 1.2) |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter (check-only) | `Invoke-Formatter -ScriptDefinition <content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` compared to file content, all 6 changed files | 0 diffs | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`, all 6 changed files | 0 findings | PASS |
| Pester full suite + coverage | `pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1` | exit 0; 1332/0/9; coverage XML regenerated | PASS |
| Bundled-manifest repro (E1b path) | `pwsh -NoProfile -Command "Import-Module ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'"` | 98 passed, 0 failed, 7 skipped; `TRAMPOLINE-LEAK: False`; exit 0 | PASS |
| Bundled/repo-root parity | `cmp` on both parity pairs | byte-identical | PASS |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

**Notes:**
`mcp__drm-copilot__run_poshqc_test` exits 33 in this environment because the installed extension bundles a pre-fix module snapshot from the main repo; the failure list is exactly the pre-fix defect signature plus the 2 new `InModuleScope` seam tests under stale hosting. Not attributable to this branch; resolves on extension repackage after merge. The `modified-workflow-needs-green-run` policy rule does not fire: the diff touches no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Modified-file line coverage below floor (FAIL, remediation trigger):** `scripts/powershell/PoshQC/PoshQC.Testing.psm1` at 76.41% lines vs the 85% floor (and below the 80% remediation threshold). All changed lines are covered; the uncovered lines are pre-existing default seam bodies that this change added to the measured set. Remediation inputs: `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/remediation-inputs.2026-07-21T19-23.md`.
- **Branch coverage metric not computable:** the Pester/JaCoCo report contains no BRANCH counter, so the >= 75% branch floor cannot be numerically verified for PowerShell in this repository. Per-line inspection of the changed code shows all changed conditional/finally paths executed. Toolchain capability limitation, repo-wide and pre-existing; flagged for follow-up in the remediation inputs (informational item).
- **MCP test gate stale-bundle failure (environmental):** `mcp__drm-copilot__run_poshqc_test` exit 33 against the pre-fix installed bundle. Follow-up: repackage the extension from merged main, then re-run the MCP gate.

### Approved Exceptions

- **Pre-existing over-limit test file:** `PoshQC.Comprehensive.Tests.ps1` (766 lines) exceeded the 500-line limit before this branch; the plan constrained edits to 3 `It` blocks (+3/-3, net zero). Decomposition is out of scope for this bugfix and is noted as follow-up debt, not a finding introduced by this change.
- **Performance criterion waived with rationale** per `spec.md` AC: one global function create/remove per Pester invocation; full suite runtime consistent with baseline (45.72s observed by the reviewer).

### Removed/Skipped Tests

**None removed.** 9 skips are pre-existing and unchanged (baseline run also reported 9 skipped).

---

## 9. Summary of Changes

### Commits in This PR/Branch

Branch `drm-copilot-wt-2026-07-21T17-18`, range `193864d8..92bf1f29` (see `artifacts/pr_context.appendix.txt` for the full diff). 38 files changed: +1201/-7.

### Files Modified

1. **scripts/powershell/PoshQC/PoshQC.Testing.psm1** (MODIFIED) + bundled mirror — `$EnsureModule` default gains `-Global`; `$InvokePester` default becomes a global-session-state trampoline (`[scriptblock]::Create` unbound scriptblock, `New-Item function:global:`, try/finally `Remove-Item 'Function:\...'`).
2. **scripts/powershell/PoshQC/settings/pester.runsettings.psd1** (MODIFIED) + bundled mirror — adds `PoshQC.Testing.psm1` to `CodeCoverage.Path` with an issue-#392 rationale comment.
3. **tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1** (NEW) — 3 regression tests for the two changed seam defaults.
4. **tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1** (MODIFIED, +3/-3) — injects `-InvokePester { param($Config) Invoke-Pester -Configuration $Config }` into the 3 Koverage-copy tests so their module-scope `Mock Invoke-Pester` still intercepts.
5. **Feature docs and evidence** (32 Markdown files) — issue, spec, plan, research, and 20 evidence artifacts under the canonical feature-folder evidence tree.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

The defect fix is correct, minimal, verified end-to-end by the reviewer (direct, bundled-narrowed, and full-suite runs all pass; no trampoline leak; parity intact; analyzer and formatter clean). One coverage gate fails: the modified production file `PoshQC.Testing.psm1` is at 76.41% line coverage against the 85% modified-file floor, which is below the 80% remediation trigger. Remediation is required before merge.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PARTIAL Module & File Structure (pre-existing 766-line test file)
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3, PowerShell)
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety (temporary global function justified and leak-tested)
- PARTIAL Structure & Naming (pre-existing over-limit file)
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- FAIL Coverage & Scenarios (modified-file line floor; scenarios themselves PASS)
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4, PowerShell)
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

### Metrics Summary

- 1332/1341 tests passing, 0 failed, 9 pre-existing skips
- 88.26% PowerShell line coverage repo measured set (>= 85% floor met)
- 76.41% line coverage on the modified `PoshQC.Testing.psm1` (85% floor NOT met — FAIL)
- 100% of changed executable lines covered; no changed-line regression
- 0 analyzer findings; 0 format diffs; parity byte-identical

### Recommendation

**Needs revision.** Complete the coverage remediation defined in `remediation-inputs.2026-07-21T19-23.md` (raise `PoshQC.Testing.psm1` to >= 85% line coverage via additional seam-default unit tests), then re-audit. No production-code defect was found.

---

## Appendix A: Test Inventory

New and modified tests in this branch (full 1341-test inventory unchanged otherwise):

1. Invoke-PoshQCTest default $InvokePester seam (issue #392) › defines function:global:Invoke-PoshQCPesterRun during the run, removes it after, and returns the result unmodified
2. Invoke-PoshQCTest default $EnsureModule seam (issue #392) › imports the requested module with -Global
3. Invoke-PoshQCTest default $EnsureModule seam (issue #392) › throws the supplied error when the module is unavailable
4. Invoke-PoshQCTest › When coverage is enabled › Should generate Koverage copy by default when coverage is enabled (modified: injected `-InvokePester` stub)
5. Invoke-PoshQCTest › When coverage is enabled › Should skip Koverage copy when DisableKoverageCopy is set (modified: injected `-InvokePester` stub)
6. Invoke-PoshQCTest › When coverage is enabled › Should use custom KoverageOutputPath when provided (modified: injected `-InvokePester` stub)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (as executed in this review):**
```powershell
# Formatting (check-only comparison per changed file)
Invoke-Formatter -ScriptDefinition (Get-Content <file> -Raw) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Full suite with coverage (authoritative worktree run)
pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1

# Bundled-manifest reproduction path (previously failing, now passing)
pwsh -NoProfile -Command "Import-Module ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'"

# Parity verification
cmp scripts/powershell/PoshQC/PoshQC.Testing.psm1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1
cmp scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1

# Evidence-location compliance
python scripts/dev_tools/validate_evidence_locations.py --root .

# Coverage parsing (JaCoCo)
python - # parse artifacts/pester/powershell-coverage.xml REPORT and sourcefile counters
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-07-21
**Policy Version:** Current (as of audit date)

# Policy Compliance Audit: Hook pre-existing imports fail open (#786, bundled #792)

---

**Audit Date:** 2026-10-10
**Audit Type:** Re-audit at the exit of remediation cycle 2 (inputs `remediation-inputs.2026-10-10T19-25.md`, plan `remediation-plan.2026-10-10T19-25.md`; prior re-audit `*.2026-10-10T18-34.md`)
**Code Under Test:** 57 PowerShell production files under `.claude/hooks/` and `.codex/hooks/` (55 modified, 2 new: both `hook-dependency-guard.ps1` copies), their 57 byte-identical bundle mirrors under `extensions/drm-copilot/resources/`, 2 pack manifests (`core.json`, both bundles), 35 PowerShell test and test-support files under `tests/scripts/`, and feature-folder documentation. Branch diff `origin/epic/enforcement-hook-precision-integration...HEAD` (217 added, 125 modified paths), HEAD `0dd3e5067`, merge base `86e457a003be0c60b65e01156e4cccd6495dfd1a` (equal to the current tip of the PR base). Cycle 2 changed six test files under `tests/scripts/codex-hooks/` and feature-folder documents only.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 57 production files (plus 57 mirrors and 35 test files) | 9495 tests (Windows combined); 5700 tests (Linux hook-suite job) | ✅ 9495 pass, 0 fail (Windows); ✅ Linux hook-suite job pass on `d83e7af61` | 88.78% lines on the 54 pre-existing changed files with a `p0-pester-coverage.md` row (combined run) | Every changed file at or above 85% on its AC-24 route: 51 files from the combined run (lowest 90.41%), 6 PS-SET Codex files from the per-surface run (lowest 95.78%); cycle-2 values identical to cycle 1 | Helper copies: Claude 100.00% (combined), Codex 100.00% (per-surface); changed lines covered on every judged file except the recorded bootstrap tail lines |
| JSON | 2 files | N/A | ✅ pack-manifest pytest suites pass (33 passed) | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pester-coverage.md (combined run), docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-pester-coverage.md (cycle-2 pre-change combined run), and docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/r2-ac24-baseline.md (cycle-2 pre-change per-surface values)
- PowerShell post-change coverage artifact: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-pester-coverage.md (combined R-PESTER run, 9495 passed) and docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-ac24-per-surface.md (Codex suites alone, 61 containers, 1652 passed)
- Per-language comparison summary: Section 1.2.1 and docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-coverage-comparison.md

---

## Executive Summary

Remediation cycle 2 addressed the single blocking finding CI-1 of `remediation-inputs.2026-10-10T19-25.md`: 18 Linux-only Pester failures in suites this branch added under `tests/scripts/codex-hooks/`. The diagnosis (`evidence/other/r2-ci-diagnosis.md`, `## Verdict`) classifies 17 rows as drive-letter fixture literals (`C:\...`, `C:/...`) that do not resolve on Linux, and row 6 as a stale module instance left by an earlier suite in the same Pester session (`R6-CAUSE: module-instance`). The production review recorded `PRODUCTION-DEFECT: none`: every affected hook path argument derives from `$PSScriptRoot` or runtime output, and the five hook files contain no drive-letter literal.

The fixes are test-only: drive-letter fixture paths replaced with `/synthetic-root/...` in five Coverage suites (31 lines), and three lines in `hook-dependency-failure.Codex.Tests.ps1` that unload the worktree-resolution module family before mock registration. The required Linux check `CI / poshqc / PowerShell hook suites (Linux)` and all 19 other PR checks pass on `d83e7af61`; the later commits through `0dd3e5067` change only feature-folder documents (reviewer `git diff --name-only d83e7af61 HEAD`).

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (mirrored by `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (mirrored by `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (uniform coverage thresholds)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (zero Python files changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash (zero bash files changed)
- ✅ JSON: two pack manifests changed; validated through the push-down pack-manifest pytest suites

Outcome: COMPLIANT. Format, analyze, Pester (Windows combined and Linux CI), mirror parity, pack manifests, the no-Python guard, the 500-line cap, test location, the no-temporary-file rule, the #737 isolation guard, and evidence locations pass. The PowerShell coverage gate passes on the AC-24 routes recorded in `r2-coverage-comparison.md`.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts are committed; the cycle-2 route scripts (`r2-ciparity.ps1`, `r2-drivesim.ps1`, `r2-census.Tests.ps1`, `r2-ciwait.ps1`) lived in the executor's session scratchpad; their bodies are recorded in `r2-ci-diagnosis.md`.
- ✅ No new tooling scripts were added to the repository in this cycle.
- Review-time scripts (`r2checks.sh`, `r2mirror.sh`) were written to the reviewer's session scratchpad only.

---

## Rejected Scope Narrowing

The caller prompt asked the review to "re-verify the cycle-2 changes: portability, no temp files, #737 isolation compliance, no production change, AC-17/AC-24/AC-27 still hold" and to "carry forward prior conclusions where unchanged". The same prompt requires the artifacts to cover "the whole branch diff", so the list is a set of emphasis points, not a narrowing. No narrowing was applied. The audit scope is the full branch diff `git diff origin/epic/enforcement-hook-precision-integration...HEAD`; the PR context was regenerated for HEAD `0dd3e5067eb5ec3f93ae3459aa70c7602858ce71`. Carried conclusions were re-checked where a reviewer command could re-run them cheaply (line cap, mirror parity, helper identity, test location, evidence locations, AC checkbox state).

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- `git diff --name-only origin/epic/enforcement-hook-precision-integration...HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` returned no paths.
- All cycle-2 evidence (37 `r2-*` files) is under `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/{baseline,regression-testing,qa-gates,other}/`.
- No absolute host path appears in the feature folder (reviewer grep for `<drive>:/Users` and `<drive>:\Users`: 0 matches); executor output uses `<WORKSPACE_ROOT>` and `<SCRATCHPAD>` placeholders.
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Cycle 2 removed an order dependency: row 6 passed alone and in a pair but failed in the 200-container Linux order (`r2-ci-diagnosis.md` [P1-T3]); after the E-HDF fix the same 200-container order passes 5700/5700 (`r2-final-ciparity.md`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | Unchanged: one B1 row per (hook, direct edge), one B2 row per hook, one S row per structural rule, one N row per #792 form. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Combined Windows run 9495 tests; cycle-2 suites run 167 tests across six containers (`r2-scoped-baseline.md`). |
| **Determinism** - Consistent results | ✅ PASS | Fixture paths are now host-neutral (`/synthetic-root/...`), so results no longer depend on the presence of drive `C:`; the drive simulation (`r2-drive-simulation.md`) reproduced the 17 Linux failures on Windows before the fix and `r2-postfix-local.md` (a) shows 0 replacements and 0 failures after it. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | The E-HDF insertion carries a two-line comment that states why the module family is unloaded. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** 88.78% lines aggregate on the 54 pre-existing changed files with a P0 row (`evidence/baseline/p0-pester-coverage.md`); cycle-2 pre-change run `r2-pester-coverage.md` (87.07% commands, 9495 passed) and per-surface `r2-ac24-baseline.md`<br>**Command:** `Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>**Timestamp:** 2026-10-09 22:11 (P0 combined); 2026-10-10 cycle-2 baseline |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** `r2-final-pester-coverage.md` reports the same command coverage (87.07%, 25,713 commands in 192 files) and the same PS-SET combined figures as the cycle-2 baseline; per-surface PS-SET figures are unchanged (95.78, 95.86, 100.00, 100.00, 100.00, 98.73)<br>**Change:** 0.00 points on every judged file; cycle 2 changed no production line<br>**Status:** No regression (`r2-coverage-comparison.md`: every POST at least 85.00, every NO-REGRESSION met or n/a). |
| **New Code Coverage ≥85% (uniform threshold, quality-tiers.md)** | ✅ PASS | `.claude/hooks/hook-dependency-guard.ps1` 100.00% (19/19, combined run); `.codex/hooks/hook-dependency-guard.ps1` 100.00% (19/19, per-surface; 57.89% in the combined run, recorded). The two copies are byte-identical (reviewer `cmp`). |
| **Comprehensive Coverage** | ✅ PASS | 57 of 57 changed production files at or above 85% on their AC-24 route; lowest combined-route file `.claude/hooks/enforce-epic-invocation-origin.ps1` 90.41%; lowest per-surface file `.codex/hooks/enforce-epic-child-worktree-binding.ps1` 95.78%. |
| **Positive Flows** - Valid inputs | ✅ PASS | AC-17: pre-existing suites pass (`r2-preexisting-tests.md`, AC17-RESULT pass). |
| **Negative Flows** - Invalid inputs | ✅ PASS | B1 rows fail each direct edge and assert deny or exit 2, the leading token, and the dependency name; Codex B1 suite passes 75/75 after the E-HDF fix (`r2-fix-e-hdf.md`). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Unchanged: nested failure (AC-9), bootstrap failure (B2, C8), D3 absent versus present, D2 MermaidValidation absence. |
| **Error Handling** - Error paths | ✅ PASS | Unchanged: SubagentStop exit 2 with stderr reason (AC-8); H12 asserts the `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` leading token. |
| **Concurrency** - If applicable | N/A | Hooks are single-invocation processes; no shared mutable state across invocations. |
| **State Transitions** - If applicable | ✅ PASS | Helper state (empty, recorded, preserved on re-dot-source) tested in both helper suites. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 88.78% lines (aggregate of the 54 pre-existing changed files with a P0 row, combined run) -> Post-change: 95.21% lines (same files, combined run). Change: +6.43 points aggregate versus the development baseline and 0.00 points versus the cycle-2 baseline; on the AC-24 routes every changed file is at or above 85.00 and no judged file regresses. New/changed-code coverage: 100.00% lines on both helper copies (Claude combined, Codex per-surface). Repo-wide command coverage of the in-repo combined run: 87.07%. Disposition: PASS. Evidence: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-coverage-comparison.md, docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-ac24-per-surface.md, docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-pester-coverage.md.
- JSON: not a coverage language; validated by the pack-manifest pytest suites (`evidence/qa-gates/r2-final-pytest-guards.md`, 33 passed).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions use `-Because $result.Reason` / `-Because $result.Stderr`; cycle 2 changed fixture values only, not assertions. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Rows mock (Arrange), invoke the hook (Act), then assert. |
| **Document Intent** | ✅ PASS | Row names and file headers cite the requirement (FR/AC id); the E-HDF insertion cites the #737 probe harness. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or external process in unit rows. |
| **Use Mocks/Stubs** | ✅ PASS | `Get-ChildItem`, `Get-Content`, `Test-Path`, `Import-Module`, and checkpoint readers are mocked; `/synthetic-root/...` values are never read from disk because the readers that receive them are mocked. |
| **Environment Stability** | ✅ PASS | No temporary files: reviewer grep for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `$env:TMP`, `Set-Content`, `Out-File`, `New-Item`, `WriteAllText` over the six cycle-2 files returned no matches, and no added line of the cycle-2 test diff matches those APIs. Drive-letter literals: 0 in each of the six files and 0 in every test file added or modified on the branch (reviewer grep). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document. Non-blocking items: Section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` (full-bug), issues #786 and #792, epic #852 child C4; remediation inputs CI-1. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/r2-inputs-read.md`, `r2-phase0-instructions-read.md`. |
| **Document the plan** | ✅ PASS | `remediation-plan.2026-10-10T19-25.md`, with preflight deltas applied in `4b22c4959`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Cycle-2 fixes are literal substitutions and one `Remove-Module` statement. |
| **Reusability** | ✅ PASS | Unchanged: the #690 per-hook guards are replaced by the shared helper. |
| **Extensibility** | ✅ PASS | Structural and #792 tests discover hooks from the registrations. |
| **Separation of concerns** | ✅ PASS | The helper performs no I/O; the discovery helper accepts an injectable text reader. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Helper, discovery helper, shape helper, exemption helper. |
| **Under 500 lines** | ✅ PASS | Reviewer `wc -l` over all 149 added or modified `.ps1`/`.psm1`/`.psd1` files: maximum 500 (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and mirror); next 497, 495. Cycle-2 files: 128, 94, 181, 213, 113, 199. |
| **Public vs internal** | ✅ PASS | Helper exposes four approved-verb functions. |
| **No circular dependencies** | ✅ PASS | The helper imports nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Add-HookDependencyFailure`, `Test-HookDependencyFailure`, `Get-HookDependencyFailureReason`, `Get-HookDependencyFailureDecision`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on the helper and its functions. |
| **Comment why, not what** | ⚠️ PARTIAL | Carried Nit: three exempt hooks (H4, H5, H6) keep an always-true conditional and the comment "an earlier recorded failure is kept". Non-blocking; outside cycle-2 scope. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** R-FORMAT-GUARDED (`Invoke-PoshQCFormat`)<br>**Result:** 0 `Formatted:` lines; 469 `Already formatted:`; 149 SHA pairs equal (`r2-final-poshqc-format.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze` plus per-file PSScriptAnalyzer<br>**Result:** `PSScriptAnalyzer passed: no findings`; 149 files with 0 findings (`r2-final-poshqc-analyze.md`) |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>**Result:** 9495 passed, 0 failed; JUnit 9505, 0 failures, 0 errors (`r2-final-pester-coverage.md`); Linux CI-parity order 5700 passed, 0 failed (`r2-final-ciparity.md`); PR check `CI / poshqc / PowerShell hook suites (Linux)` pass (`r2-pr-checks.md`) |
| **Full toolchain loop** | ✅ PASS | Pass 1 closed with every step GREEN ([P3-T1] to [P3-T10], `r2-final-qc-loop.md`). |
| **Explicit reporting** | ✅ PASS | Every stage is recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | `evidence/other/commits.md`; cycle-2 commits `f72a63752` to `0dd3e5067`. |
| **Design choices explained** | ✅ PASS | `r2-ci-diagnosis.md` (per-row cause table and `## Verdict`); `deviations.md` "Remediation cycle 2" sections. |
| **Update supporting documents** | ✅ PASS | `ac-status.md` carries one `Remediation cycle 2 note:` line (`r2-ac-confirm.md`). |
| **Provide next steps** | ✅ PASS | Section 8 and the code review list the follow-ups. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .` and `mcp__drm-copilot__run_poshqc_format`<br>**Result:** no file changed (`r2-final-poshqc-format.md`, `r2-final-mcp-poshqc.md`) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** no findings |
| **Fix all findings** | ✅ PASS | None reported in cycle 2. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Hooks target PowerShell 7 (`pwsh -File`); suites now pass on both the Windows and the Linux PowerShell 7 runners. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Helper functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `[ValidateSet('PreToolUse','SubagentStop')]` on `-HookEvent`. |
| **Avoid global state** | ⚠️ PARTIAL | Carried: seven runtime pre-loads use `Import-Module -Global` (RS-10), and `validate-orchestrator-output.ps1` imports `OrchestratorState.psm1` twice (lines 51 and 59). Cycle 2 adds a test-session `Remove-Module` of six worktree-resolution modules in one suite's `BeforeAll`; it acts on session state shared with later suites, and both full runs (Windows 9495, Linux 5700) pass after it. Non-blocking. |
| **Error handling** | ✅ PASS | Single-statement `try` per edge; every guarded `Import-Module` uses `-ErrorAction Stop`. The cycle-2 `Remove-Module ... -ErrorAction SilentlyContinue` suppresses only the expected "module not loaded" condition in test setup; the following `Register-EpicStateBaselineMock` imports each module with `-ErrorAction Stop`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | Max 500 (Section 2.3). |
| **Approved verbs** | ✅ PASS | Add, Test, Get; analyzer clean. |
| **Comment why** | ⚠️ PARTIAL | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 files formatted. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 9495 passed, 0 failed (Windows); Linux CI job pass. |
| **Rerun loop if needed** | ✅ PASS | Loop closed on pass 1. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | N/A | Two `core.json` manifests carry one added entry each; not changed in cycle 2. |
| **Schema validation** | ✅ PASS | **Command:** `poetry run pytest <four push-down parity and manifest suites> -q`<br>**Result:** 33 passed (`r2-final-pytest-guards.md`) |
| **Required $schema** | N/A | Pack manifests are not governed schema files. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | Pester 5.6.1 (`r2-ci-diagnosis.md` `PESTER-VERSION`). |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; PoshQC sources, bundle copy, and `config/poshqc-*.json` unchanged from the merge base (`r2-final-isolation-scope.md`, `MEASUREMENT-ROUTE-UNCHANGED: yes`). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Suites run under PowerShell 7 with Pester 5 on Windows and Linux. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One behaviour per row. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert the emitted decision, exit code, and reason text. |
| **Mocking Used Sparingly** | ✅ PASS | C3 seams, filesystem readers, and checkpoint readers only. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1`, `tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1`, and the six cycle-2 files under `tests/scripts/codex-hooks/`<br>**Code files:** `.claude/hooks/hook-dependency-guard.ps1`, `.codex/hooks/hook-dependency-guard.ps1`<br>Reviewer check: no `*.Tests.ps1` file outside `tests/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All new test files end in `.Tests.ps1`; support files end in `.Helpers.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per concern with data-driven `It -ForEach`. |
| **Logical Grouping** | ✅ PASS | B, S/F, N, H row families; Coverage suites grouped by readers, parsers, and entry point. |
| **Docstrings/Comments** | ✅ PASS | File headers cite issue and FR/AC ids. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** 9495 passed, 0 failed |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC (R-PESTER), the PoshQC MCP route, and a CI-parity diagnostic route (`r2-ciparity.ps1`) that reproduces the Linux job's Pester configuration (`_poshqc.yml`) for diagnosis only; the gate result is the PoshQC run and the CI job. |

---

## 5. Test Coverage Detail

### `hook-dependency-guard.ps1` (Claude and Codex copies; helper suites)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| records a failure and Test-HookDependencyFailure returns true | Positive | 22-58 | ✅ |
| returns $null when nothing failed | Edge Case | 100-102 | ✅ |
| PreToolUse deny shape and reason text | Positive | 103, 107-111 | ✅ (Claude combined; Codex per-surface) |
| SubagentStop result carries ExitCode 2 and Reason | Positive | 104-105 | ✅ (Claude combined; Codex per-surface) |
| preserves earlier records on re-dot-source | State Transition | 22, 42 | ✅ |
| writes nothing to any output stream | Negative | whole file | ✅ |

**Coverage:** Claude copy 100.00% (19/19, combined); Codex copy 100.00% (19/19, per-surface), 57.89% (11/19) in the combined run.

**Not covered:** none on the judged route.

### Registered hooks (55 hook and sibling files)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| B1 per direct edge (Claude, Codex) | Error Handling | guard catch lines, decision-function first statement, tail lines | ✅ |
| B2 bootstrap flag per hook | Error Handling | bootstrap line | ✅ |
| C8 fresh-runspace bootstrap exit 2 | Error Handling | tail `exit 2` | ✅ (process-level row) |
| Pre-existing suites (AC-17) | Positive | existing decision paths | ✅ |
| Codex Coverage suites (five edited in cycle 2) | Positive / Negative | readers, parsers, entry points | ✅ (passed counts equal to the cycle-2 baseline: 29, 17, 14, 11, 21) |

**Coverage:** 57 of 57 changed production files at or above 85% on their AC-24 route.

**Not covered:** bootstrap `exit 2` statements, listed as KNOWN-UNCOVERED in `r2-final-pester-coverage.md` (spec Test Strategy).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 9495 run on Windows (JUnit 9505 including 10 skipped); 5700 in the Linux hook-suite order | ✅ |
| Tests Passed | 9495 (100%); 5700 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Not re-measured by this review; combined run comparable to cycle 1 (533.53s) | ✅ |
| Average Time per Test | About 56ms (cycle-1 measurement) | ✅ Fast |
| Discovery Time | 33.95s for 5700 tests in the CI-parity order (`r2-ci-diagnosis.md`) | ✅ |
| Functions/Classes Tested | 4/4 helper functions | ✅ |
| Test File Size | Largest changed test file 497 lines | ✅ Maintainable |
| Code Coverage (if applicable) | 57/57 changed production files >= 85% on the AC-24 route; no branch metric for PowerShell | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | 0 formatted | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 9495 passed, 0 failed | ✅ |
| Linux hook-suite CI | PR #881 check on `d83e7af61` | pass (20 of 20 checks pass) | ✅ |
| Pester coverage gate | per-file line coverage, AC-24 routes (`r2-coverage-comparison.md`) | 57/57 at or above 85; no regression on the judged route | ✅ |
| #737 isolation guard | `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (R-ISOLATION) | 315 passed, 0 failed; AC-4 rows pass for all six cycle-2 files; AC-6 probe rows pass for the two probe suites | ✅ |
| Mirror parity | reviewer `cmp` of each changed `.claude`/`.codex` hook file against its bundle mirror | 57 equal, 0 unequal; Claude and Codex helper copies identical | ✅ |
| Push-down parity and manifests | `poetry run pytest <four suites> -q` | 33 passed | ✅ |
| No-Python guard | reviewer grep of added hook lines for Python invocation forms | 0 invocations (three matches are the reason-prefix string `Python unit test purity hook:`, not invocations) | ✅ |

**Notes:**
- Cycle 2 changed no file under `.claude/`, `.codex/`, `extensions/`, `scripts/`, or `config/` (reviewer `git diff --name-only f72a63752 HEAD -- .claude .codex extensions scripts config`: 0 paths).
- PoshQC's `CoveragePercentTarget` is 0 in `pester.runsettings.psd1`, so the combined-run per-file figures do not fail the CI test step.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Row 6 culprit not isolated (informational, non-blocking).** The diagnosis recorded `R6-CULPRIT: not isolated (ciorder prefix)`: the suite that leaves `EpicScopeResolution` bound to a replaced sibling-module instance is not named. The E-HDF fix protects this suite only; another suite that registers module-scoped baseline mocks after the same prefix could fail the same way. Recommendation: record a potential issue for the #737 harness (stale worktree-resolution module instances across suites).
- **Combined-run attribution loss (informational, carried).** In the standard combined run, five PS-SET Codex files report lower values than their baselines and four are below 85% (`r2-final-pester-coverage.md`); AC-24 is judged on the per-surface route (orchestrator decision 2026-10-10). Recommendation carried: record a potential issue for the Pester coverage attribution loss.
- **Decision provenance (informational, carried).** The AC-24 route and the AC-6 amendment were decided by the orchestrator, not by the human operator directly; both are disclosed in `r1-pr-body-notes.md`.
- **Evidence hygiene (Minor, carried).** `evidence/other/handler-conversions.md:27` still reads `AC-6 GAP: ... the 2026-10-09 amendment did not extend to AC-6`, which no longer reflects the amended AC-6; `evidence/other/r1-coverage-diagnosis.md` remains 4.7 MB.
- **PR context metadata (informational).** The worktree's local branch is `bug/hook-preexisting-imports-fail-open-resume-786`, while PR #881's head is `bug/hook-preexisting-imports-fail-open-exec-786` at the same SHA; the regenerated `artifacts/pr_context.summary.txt` therefore reports "no PR exists yet for this branch". The diff range is correct (`86e457a0..0dd3e506`).

### Approved Exceptions

- D2 (`enforce-mermaid-validation.ps1` designed fail-open on a missing `MermaidValidation` module) and the D3 absence path (spec Operator Decisions).
- Named handler exemptions H1 to H6 under the 2026-10-09 operator decision, each with a fail-closed proof and an entry in `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`.
- AC-6 exception for the `feature-folder-resolution.ps1` edges of H1, H4, H5, and H6 (Change Log 2026-10-10).
- AC-24 per-surface route for the six PS-SET Codex files (orchestrator decision 2026-10-10, `r1-ac24-decision.md`); no production file excluded, thresholds and gate route unchanged.
- Bootstrap `exit 2` tail statements are known uncovered in-process (spec Test Strategy).

### Removed/Skipped Tests

**None.** The 10 skipped JUnit cases pre-date the branch. Cycle 2 removed no test row: per-container passed counts after the fixes equal the cycle-2 baseline (29, 17, 14, 11, 21, 75; `r2-postfix-local.md` (b)).

---

## 9. Summary of Changes

### Commits in This PR/Branch

Commits from `86e457a00` (merge base) to `0dd3e5067` (HEAD). Cycle-2 commits (after `a9e8e88fe`) are documentation and evidence only, except:
1. **b054e8a59** - test(786): use drive-free fixture roots and isolate the module family for Linux CI

### Files Modified

1. **`.claude/hooks/hook-dependency-guard.ps1`, `.codex/hooks/hook-dependency-guard.ps1`** (NEW, plus 2 mirrors) - shared recording and decision helper; unchanged in cycle 2.
2. **35 `.claude/hooks/*.ps1` and 20 `.codex/hooks/*.ps1`** (MODIFIED, plus mirrors) - bootstrap, per-edge guards, decision-first check, tail check; unchanged in cycle 2.
3. **2 `pack-manifests/core.json`** (MODIFIED) - helper listed.
4. **24 new and 11 modified test files under `tests/scripts/`** - cycle 2 edits six branch-added files: `enforce-codex-model-routing.Coverage.Tests.ps1` (7 lines), `enforce-epic-root-invocation.Coverage.Tests.ps1` (3), `enforce-epic-wave-barrier.Coverage.Tests.ps1` (6), `validate-codex-subagent-routing.Coverage.Tests.ps1` (5), `validate-feature-review-coverage.Coverage.Tests.ps1` (9), `hook-dependency-failure.Codex.Tests.ps1` (+3).
5. **`spec.md`, plans, `evidence/**`** - cycle-2 remediation inputs, plan, and 37 `r2-*` evidence files.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

All structural, toolchain, mirror, cap, test-hygiene, isolation-guard, and evidence-location policies pass. The Linux CI blocker CI-1 is resolved with test-only changes, and the PowerShell coverage gate passes on the AC-24 routes recorded in `r2-coverage-comparison.md`.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, remediation inputs, and remediation plan present
- ✅ Design Principles: shared helper; cycle-2 fixes minimal
- ✅ Module & File Structure: all files at or below 500 lines
- ⚠️ Naming, Docs, Comments: carried Nit on three exempt hooks
- ✅ Toolchain Execution: pass 1 GREEN
- ✅ Summarize & Document: diagnosis and deviations recorded

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean
- ⚠️ PowerShell Design & Safety: carried `-Global` pre-loads and duplicate import
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: loop closed on pass 1

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: met; one order dependency removed
- ✅ Coverage & Scenarios: 57/57 at or above 85% on the AC-24 route, no regression
- ✅ Test Structure: met
- ✅ External Dependencies: no temporary files, host-neutral fixture paths
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC
- ✅ Test Style & Structure: tests under `tests/scripts/`
- ✅ Naming & Readability: met
- ✅ Toolchain: 9495 passed (Windows); Linux CI pass

---

### Metrics Summary

- ✅ 9495/9495 tests passing on Windows; 5700/5700 in the Linux CI order
- ✅ 4/4 helper functions tested
- ✅ 57/57 changed production files at or above 85% line coverage on their AC-24 route
- ✅ Proper file organization: tests under `tests/scripts/` mirroring source
- ✅ Format, analyze, mirror parity, manifests, no-Python guard, #737 isolation guard passing
- ✅ 20/20 PR checks pass on `d83e7af61`

---

### Recommendation

**Ready for merge**

1. Non-blocking: carry the `r1-pr-body-notes.md` notes into the PR body and add one line stating that cycle 2 made test-only portability fixes for the Linux hook-suite job.
2. Non-blocking: record potential issues for the unisolated row-6 culprit (stale module instances in the #737 harness) and for the Pester combined-run attribution loss.
3. Non-blocking: correct the stale `AC-6 GAP` line in `handler-conversions.md`; address the carried Minor and Nit code-review items in a follow-up.

---

## Appendix A: Test Inventory

### Complete Test List

New suites (21 files), unchanged in composition; cycle 2 edits six of them:
1. `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1` › helper unit rows (Claude copy)
2. `tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1` › helper unit rows (Codex copy)
3. `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` › baseline probe, B1 per edge, B2 per hook
4. `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` › B1, B2, X rows (cycle 2: module-family unload before mock registration)
5. `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` › nested, runtime, D2, D3, merge-gate, C8
6. `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` › H1 to H8 proofs
7. `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` › H2 Codex proofs
8. `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` › S1 to S8, F1 to F8
9. `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` › N1 to N8
10. `tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1` › exemption guard
11. Eleven `*.Coverage.Tests.ps1` suites for below-floor baseline hooks (cycle 2: five Codex suites use `/synthetic-root/...` fixture paths)

Support files: `HookDependencyGraph.Helpers.ps1`, `HookGuardShape.Helpers.ps1`, `HookImportFailureExemptions.Helpers.ps1`.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

**Reviewer commands (check-only):**
```bash
git diff --name-status origin/epic/enforcement-hook-precision-integration...HEAD
git diff a9e8e88fe HEAD -- tests/
git diff --name-only f72a63752 HEAD -- .claude .codex extensions scripts config
git diff --name-only d83e7af61 HEAD
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/enforcement-hook-precision-integration --head HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
sh <SCRATCHPAD>/r2checks.sh   # wc -l cap, drive-letter grep, temp-file grep, test location, helper identity, evidence paths, Python grep
sh <SCRATCHPAD>/r2mirror.sh   # cmp mirror parity for the 57 changed hook files
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-10
**Policy Version:** Current (as of audit date)

# Policy Compliance Audit: Issue #847 — PowerShell host-script module extraction (aggregate line coverage below floor)

---

**Audit Date:** 2026-10-10 (timestamp 2026-10-10T01-41)
**Branch:** `bug/powershell-aggregate-line-coverage-below-floor-847`
**Base:** `main`; merge-base `460cd755de560b733be0c471d1d144e553fbe0e5`
**Head reviewed:** `d2224baa86700fe445c87008228bd3efe56dd6f8`
**Review scope:** full branch diff `git diff 460cd755de560b733be0c471d1d144e553fbe0e5...HEAD` (51 files, +6360/-1367)
**Work mode:** `full-bug` (AC source: `spec.md` only)
**Code Under Test:** `scripts/dev-tools/HostTooling.psm1` (new), `scripts/dev-tools/HostBootstrap.psm1` (new), `scripts/dev-tools/HostBootstrapWorkspace.psm1` (new), `scripts/dev-tools/HostVerification.psm1` (new), `scripts/dev-tools/SideloadedExtensionPublish.psm1` (new), `scripts/dev-tools/bootstrap-host.ps1` (modified), `scripts/dev-tools/verify-host.ps1` (modified), `scripts/dev-tools/publish-sideloaded-extension.ps1` (modified), `scripts/dev-tools/bootstrap-host.helpers.ps1` (deleted), plus 11 test files under `tests/scripts/dev-tools/`.

## Total Blocking Findings: 0

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 20 files (8 production changed, 1 production deleted, 11 test) | 6709 tests (182 in changed suites) | PASS: 6709 pass, 0 fail, 10 disabled | 84.69% lines (13328/15738) | 88.0% lines (13918/15816) | 99.15% (584/589 over the 8 changed production files) |
| TypeScript | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Python | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 31 files | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `artifacts/ci/run-38005028184/powershell-coverage.xml` (CI run 38005028184 at `460cd755`), summarized in `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/baseline/pwsh-test-coverage-baseline.2026-10-09T23-46.md`
- PowerShell post-change coverage artifact: `artifacts/ci/run-38011932558/powershell-coverage.xml` (CI run 38011932558 at `1c3d1a4c6`, PowerShell-identical to `d2224baa8`), reduced in `artifacts/ci/run-38011932558/reduction.txt` and summarized in `evidence/qa-gates/coverage-aggregate.2026-10-10T01-18.md` and `evidence/qa-gates/coverage-per-file.2026-10-10T01-18.md`
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch extracts the logic of three host-bound scripts (`bootstrap-host.ps1`, `verify-host.ps1`, `publish-sideloaded-extension.ps1`) into five modules, reduces the scripts to entry-point wiring, deletes `bootstrap-host.helpers.ps1`, and adds 11 Pester suites. Repository-wide PowerShell line coverage moves from 84.69% to 88.0% with every production file in the denominator. All eight changed production files are at or above 85% (lowest: `HostTooling.psm1` 94.74%). Format, PSScriptAnalyzer, and the full Pester suite are clean in CI run 38011932558. No blocking finding was identified.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (PowerShell code change and unit test)
- N/A Python, TypeScript, C# (no changed files)

**Context sources:**
- `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent at review start and were regenerated with `poetry run python -m scripts.dev_tools.pr_context.collector --base 460cd755de560b733be0c471d1d144e553fbe0e5 --head HEAD --repo-root .` (exit 0; summary head SHA `d2224baa8`, merge base `460cd755`).
- Operator execution amendment `evidence/other/execution-amendment.2026-10-09T23-50.md`: verification through PoshQC MCP tools and CI artifacts instead of local `pwsh`. This route substitution is operator-imposed and is not evaluated as a defect.

**Temporary artifacts cleanup:**
- PASS No temporary scripts are committed; the executor's reduction scripts lived in the session scratchpad. CI downloads under `artifacts/ci/` are gitignored (`git status --ignored` reports `!! artifacts/`).

---

## Rejected Scope Narrowing

None detected. The caller prompt directs evaluation of AC-14 and AC-15 as later-stage criteria and records an operator-imposed verification route; neither narrows the file or language scope of the audit. The full branch diff was reviewed.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exit code 0 (no violations reported).
- Branch diff scanned for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: no such paths in `git diff --name-status`.
- Feature evidence is under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/other/` (canonical kinds).
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Each suite imports its module in `BeforeAll` via `Resolve-Path` and removes it in `AfterAll`; per-test mocks are scoped to the `It`/`BeforeEach`; entry tests reset a `$LASTEXITCODE` sentinel of 99 before each case. |
| **Isolation** | PASS | Each `Describe` targets one function or one entry script; AC-tagged names (for example `AC06-EPERM-BACKOFF`) identify the behavior. |
| **Fast Execution** | PASS | Full CI suite of 6709 tests completed in 283.09 s (`poshqc-job.log:1293`); the changed suites contain no sleeps or process starts. |
| **Determinism** | PASS | Retry backoff via injected `-Sleep`, clock via `-Now`; no `Start-Sleep` or `Get-Date` in tests; `-IsWindowsHost` passed explicitly. One default-clock read exists in a wildcard-asserted test (code-review CR-N6). |
| **Readability & Maintainability** | PASS | Arrange/Act/Assert comments, descriptive `It` names, suite-level `.SYNOPSIS`/`.DESCRIPTION` stating the mocking contract. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline 84.69% lines (13328/15738), CI run 38005028184 at `460cd755`, recorded 2026-10-09T23-46 in `evidence/baseline/pwsh-test-coverage-baseline.2026-10-09T23-46.md`. |
| **No Coverage Regression** | PASS | Post-change 88.0% lines (13918/15816); change +3.31 points; the three modified entry scripts moved from 0.00% to 100.00%. |
| **New Code Coverage >= 85% (uniform tier rule)** | PASS | HostTooling 94.74%, HostBootstrap 100%, HostBootstrapWorkspace 100%, HostVerification 100%, SideloadedExtensionPublish 97.84%; changed-code aggregate 99.15% (584/589). Also meets the agent-definition 90% new-file threshold. |
| **Comprehensive Coverage** | PASS | Every exported function has at least one test; uncovered lines are 2 in `HostTooling.psm1` and 3 in `SideloadedExtensionPublish.psm1` (seam wrappers and default scriptblock bodies). |
| **Positive Flows** | PASS | Dry run, apply, already-installed short-circuit, verify pass report, publish VSIX output. |
| **Negative Flows** | PASS | Non-Windows, missing winget, missing python, missing manifest, explicit `-CodeCommand` not found, missing `url` in project entry. |
| **Edge Cases** | PASS | PATH de-duplication (case, trailing backslash), empty winget list, `CodeCommand` bound-empty vs unbound, version text without digits or with an uncastable number, exit-code boundary 0 vs 1 failure. |
| **Error Handling** | PASS | EPERM retry exhaustion, non-EPERM immediate rethrow, poetry winget failure to pip fallback, non-poetry rethrow, poetry project-install failure as warning, VSIX missing throw. |
| **Concurrency** | N/A | Scripts are sequential; no concurrent paths. |
| **State Transitions** | PASS | RunOnce register (both switches), not registered (either switch alone), cleared after apply. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 84.69% lines -> Post-change: 88.0% lines. Change: +3.31 points (+590 covered lines, +78 total lines; population 174 -> 178 files). New/changed-code coverage: 99.15% (584/589 over the 8 changed production files; lowest file 94.74%). Disposition: PASS. Evidence: `artifacts/ci/run-38011932558/reduction.txt`, `evidence/qa-gates/coverage-aggregate.2026-10-10T01-18.md`, `evidence/qa-gates/coverage-per-file.2026-10-10T01-18.md`, `evidence/baseline/pwsh-test-coverage-baseline.2026-10-09T23-46.md`.
- TypeScript: N/A - no changed files on the branch.
- Python: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

Per-file PowerShell rows (from `reduction.txt`):

| File | Status | Covered/Total | Line % | Threshold | Verdict |
|---|---|---|---|---|---|
| `scripts/dev-tools/HostTooling.psm1` | new | 36/38 | 94.74% | 85% | PASS |
| `scripts/dev-tools/HostBootstrap.psm1` | new | 155/155 | 100.00% | 85% | PASS |
| `scripts/dev-tools/HostBootstrapWorkspace.psm1` | new | 70/70 | 100.00% | 85% | PASS |
| `scripts/dev-tools/HostVerification.psm1` | new | 149/149 | 100.00% | 85% | PASS |
| `scripts/dev-tools/SideloadedExtensionPublish.psm1` | new | 136/139 | 97.84% | 85% | PASS |
| `scripts/dev-tools/bootstrap-host.ps1` | modified (baseline 0.00%) | 7/7 | 100.00% | 85%, no regression | PASS |
| `scripts/dev-tools/verify-host.ps1` | modified (baseline 0.00%) | 7/7 | 100.00% | 85%, no regression | PASS |
| `scripts/dev-tools/publish-sideloaded-extension.ps1` | modified (baseline 0.00%) | 24/24 | 100.00% | 85%, no regression | PASS |
| `scripts/dev-tools/bootstrap-host.helpers.ps1` | deleted | no row | — | — | N/A (deleted) |

Branch coverage: not applicable to PowerShell (Pester does not measure branch coverage; `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`). Context only: unchanged `scripts/dev-tools/vscode-cli.helpers.ps1` rose from 33.33% to 55.56%; 38 files remain below 85% repo-wide, none changed on this branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Fail-closed default mocks throw `unmocked host seam: <name>`, naming the seam reached; `Should -Throw -ExpectedMessage` pins error text. |
| **Arrange-Act-Assert Pattern** | PASS | Explicit `# Arrange`, `# Act`, `# Assert` comments in the module and entry suites. |
| **Document Intent** | PASS | AC-tagged `It` names map to spec criteria; 32 AC tokens (11 AC05, 21 AC06) matched in `reduction.txt`, each with passing hits. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No real `winget`, `npm`, `npx`, `wsl`, `git`, `python`, `poetry`, `code`, or `cmd.exe` invocation; `Invoke-HostNativeCommand` real-call tests use the in-process `Write-Output` cmdlet. The scaffold identity test reads the checked-in `extensions/drm-copilot/package.json` (retained per spec). |
| **Use Mocks/Stubs** | PASS | 75 fail-closed default mocks across the 11 suites for process, registry, environment-write, file-system, module-install, and location seams. |
| **Environment Stability** | PASS | Grep of the 11 files for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `GetTempFileName`, `$env:TEMP`, `$env:TMP`, `Set-Content`, `Out-File`: no matches. `Set-HostEnvironmentVariable` real call only under `-WhatIf`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the policy review for the branch. AC-14 (PR description) and AC-15 (PR CI) are later-stage items. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #847; `spec.md` DR-1/DR-2. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.md`; research `research/research.2026-10-08T23-50.md`. |
| **Document the plan** | PASS | `plan.2026-10-08T23-43.md`, 45 of 45 checkboxes checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Entry scripts are 35, 19, and 83 lines; one orchestrator call each. |
| **Reusability** | PASS | `Get-SessionPathFromMachineAndUser`, `Get-CommandVersion`, and manifest access de-duplicated into `HostTooling.psm1`. |
| **Extensibility** | PASS | Clock and sleep injected as scriptblock parameters; seams are named functions. |
| **Separation of concerns** | PASS | Host I/O isolated to seams; logic returns data (`{ Lines; ExitCode }`) and the entry script owns output and exit. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One module per script responsibility; workspace functions split into `HostBootstrapWorkspace.psm1` under the spec's 500-line contingency. |
| **Under 500 lines** | PASS | Max production 463 (`HostBootstrap.psm1`); max test 372 (`SideloadedExtensionPublish.Tests.ps1`); all 19 changed `.ps1`/`.psm1` files <= 500. |
| **Public vs internal** | PASS | Explicit `Export-ModuleMember` in each module; `Stop-NodeProcess` and `Invoke-SideloadedExtensionProcess` not exported. |
| **No circular dependencies** | PASS | `HostTooling` <- `HostBootstrapWorkspace` <- `HostBootstrap`; `HostTooling` <- `HostVerification`; `SideloadedExtensionPublish` dot-sources only `vscode-cli.helpers.ps1`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Module-unique wrapper nouns (for example `Invoke-HostBootstrapWinget`) avoid collisions noted in the spec risk table. |
| **Docs/docstrings** | PASS | Module-level and per-function comment-based help. |
| **Comment why, not what** | PASS | Retained rationale comments (cmd /c execution, npm output noise, backoff). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** CI `Invoke-PoshQCFormat -Root` (run 38011932558).<br>**Result:** 629 `Already formatted:` lines, no reformatted file, no `##[error]`. |
| **2. Linting** | PASS | **Command:** CI `Invoke-PoshQCAnalyze -Root`.<br>**Result:** `poshqc-job.log:832` `PSScriptAnalyzer passed: no findings`. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | PASS | **Command:** CI `Invoke-PoshQCTest -Root` (no `-ScanFolders`).<br>**Result:** `Tests Passed: 6699, Failed: 0, Skipped: 10`; junit 6709 tests, 0 failures, 0 errors. |
| **Architecture / contract / integration stages** | N/A | Not applicable to T4 dev-tools scripts; recorded in `evidence/qa-gates/toolchain-loop-closure.2026-10-10T01-18.md`. |
| **Full toolchain loop** | PASS | Single clean pass recorded in `toolchain-loop-closure.2026-10-10T01-18.md`; CI run is the substituted route per the operator amendment. |
| **Explicit reporting** | PASS | Commands and results recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages `feat(847)` / `docs(847)`; spec Files Expected to Change matches the diff. |
| **Design choices explained** | PASS | Spec "Module gotchas" and Decision Record. |
| **Update supporting documents** | PASS | Potential entry `docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md`. |
| **Provide next steps** | PASS | AC-14 and AC-15 are tracked for the PR stage. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `Invoke-PoshQCFormat -Root` (CI).<br>**Result:** all changed files `Already formatted`. Baseline format evidence `evidence/baseline/pwsh-format-baseline.2026-10-09T23-46.md`. |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `Invoke-PoshQCAnalyze -Root` (CI).<br>**Result:** no findings. |
| **Fix all findings** | PASS | No findings at head. |
| **PowerShell 7 compatibility** | PASS | Test files declare `#Requires -Version 7.0`; CI runs pwsh 7 on `windows-latest`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | Every module function uses `[CmdletBinding()]`; state-changing functions declare `SupportsShouldProcess`. |
| **Parameter validation** | PASS | `ValidateSet` on environment targets, `ValidateRange` on retry parameters, `ValidateNotNullOrEmpty` retained. |
| **Avoid global state** | PASS | Only `$global:LASTEXITCODE` is written, in the entry-script `catch` blocks, to set the process exit code. |
| **Error handling** | PASS | Module-scope `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` in all 5 modules; no `exit` in modules; preconditions use `Write-Error -ErrorAction Stop`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | See 2.3. |
| **Approved verbs** | PASS | PSScriptAnalyzer `PSUseApprovedVerbs` and `PSUseSingularNouns` report no findings. |
| **Comment why** | PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | CI run 38011932558. |
| **Step 2: Analyze** | PASS | CI run 38011932558. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | CI run 38011932558. |
| **Rerun loop if needed** | PASS | Final loop iteration 1 clean per `toolchain-loop-closure.2026-10-10T01-18.md`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `BeforeAll`/`BeforeEach`/`Describe`/`Context`/`It`, `Should -Invoke`. |
| **Use PoshQC Configuration** | PASS | **Command:** `Invoke-PoshQCTest -Root` (CI).<br>**Config:** `pester.runsettings.psd1` and `config/poshqc-coverage.json` unchanged; population `source=config; files=178`. |
| **No production coverage exclusions** | PASS | Coverage config files not in the diff; no `exclude` entry added; no root narrowed. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 182 cases across 11 suites; module helpers and orchestrators tested separately from entry exit paths. |
| **Test Behavior Over Implementation** | PASS | Assertions target emitted lines, exit codes, thrown messages, and seam call arguments. |
| **Mocking** | PASS | Mocks limited to host seams; pure helpers run unmocked. |
| **Organization** | PASS | **Test files:** `tests/scripts/dev-tools/<Module>.Tests.ps1`, `<Module>.Invoke.Tests.ps1`, `<entry>.Tests.ps1`.<br>**Code files:** `scripts/dev-tools/<Module>.psm1`, `<entry>.ps1`. Mirrors the source tree. |
| **No `Import-ScriptFunction`** | PASS | No occurrence in the 11 suites. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | All 11 files. |
| **Describe/Context/It Structure** | PASS | One `Describe` per function or entry script, `Context` for sub-scenarios. |
| **Logical Grouping** | PASS | Module behavior and orchestrator behavior split into `<Module>.Tests.ps1` and `<Module>.Invoke.Tests.ps1`. |
| **Docstrings/Comments** | PASS | Suite-level comment help describing the mock contract. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | CI `Invoke-PoshQCTest -Root`; targeted runs via `mcp__drm-copilot__run_poshqc_test` per the amendment. |
| **No Alternative Test Runners** | PASS | Pester only. |

---

## 5. Test Coverage Detail

### HostTooling.psm1 (19 tests) — 94.74% (36/38)

| Test Group | Scenario Type | Status |
|-----------|--------------|--------|
| `Get-HostToolsManifestPath` | Positive (unnormalized path form) | PASS |
| `Read-HostToolsManifest` | Positive, Negative (absent file returns `$null`) | PASS |
| `Get-SessionPathFromMachineAndUser` | Positive, Edge (empty User, both empty) | PASS |
| `Get/Set-HostEnvironmentVariable` | Positive, Safety (`-WhatIf`) | PASS |
| `Invoke-HostNativeCommand` | Positive (with and without merged stderr) | PASS |
| `ConvertTo-HostToolVersion` | Positive, Edge, Error (uncastable value) | PASS |
| `Get-CommandVersion` | Positive, Negative, Edge | PASS |

### HostBootstrap.psm1 (28 + 16 tests) — 100% (155/155)

| Test Group | Scenario Type | Status |
|-----------|--------------|--------|
| `Install-WithWinget`, `Install-PoetryWithPip`, `Install-WslIfMissing` | Positive, Negative, Error (pip fallback, rethrow, missing python) | PASS |
| `Add-DirectoryToUserPath` | Edge (case, trailing backslash, absent directory) | PASS |
| `Get-BootstrapResumeArgument`, RunOnce set/remove | Positive, State transition | PASS |
| `Invoke-BootstrapHost` (Invoke suite) | Dry run, apply, failure paths, RunOnce, verify invocation | PASS |

### HostBootstrapWorkspace.psm1 (31 tests) — 100% (70/70)

| Test Group | Scenario Type | Status |
|-----------|--------------|--------|
| Workspace resolve/initialize, project sync, repo-root resolve | Positive, Negative (missing `url`), Edge | PASS |
| Process wrappers (git, winget, npm, wsl, poetry, verify script) | Positive, Error (non-zero exit) | PASS |

### HostVerification.psm1 (22 + 10 tests) — 100% (149/149)

| Test Group | Scenario Type | Status |
|-----------|--------------|--------|
| Section functions | OK/FAIL/WARN per section | PASS |
| `Invoke-HostVerification` | Section order, exit boundary, missing manifest | PASS |

### SideloadedExtensionPublish.psm1 (27 + 13 tests) — 97.84% (136/139)

| Test Group | Scenario Type | Status |
|-----------|--------------|--------|
| Manifest, project-root, compile selection | Positive, Negative, Edge (script, tsconfig, neither) | PASS |
| `Invoke-NpmCiWithRetry` | Error (EPERM limit, backoff, non-EPERM rethrow, `-Force` cleanup) | PASS |
| `Invoke-SideloadedExtensionPublish` | Step order, Skip switches, VSIX missing, CodeCommand not found | PASS |

### Entry scripts (5 + 3 + 8 tests) — 100% each

| Test Group | Scenario Type | Status |
|-----------|--------------|--------|
| `bootstrap-host.ps1` | Exit 0 dry run, exit 1 non-Windows, exit 1 missing winget, dot-source guard | PASS |
| `verify-host.ps1` | Exit 0, exit 1 one failure, exit 1 missing manifest | PASS |
| `publish-sideloaded-extension.ps1` | VSIX output, `-WhatIf` no seams, CodeCommand forwarding, Confirm/Verbose/WarningAction forwarding, scaffold identity | PASS |

**Not covered:** 2 lines in `HostTooling.psm1` and 3 lines in `SideloadedExtensionPublish.psm1` (seam wrapper bodies and default scriptblocks). Within threshold.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 6709 (junit) | PASS |
| Tests Passed | 6699 (10 disabled) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 283.09 s total (full repository suite) | PASS |
| Tests in changed suites | 182 | PASS |
| Largest Test File | 372 lines | PASS |
| Code Coverage | 88.0% lines repo-wide; branch not measured by Pester | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root` (CI run 38011932558) | all files already formatted | PASS |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root` (CI run 38011932558) | no findings | PASS |
| Pester Tests | `Invoke-PoshQCTest -Root` (CI run 38011932558) | 0 failures | PASS |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

**Notes:** PowerShell content at `1c3d1a4c6` (CI-measured) equals `d2224baa8`; `git diff --stat 1c3d1a4c6 HEAD` lists only Markdown files.

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap. Non-blocking observations:

| ID | Finding | Recommendation |
|---|---|---|
| PA-N1 | AC-02 and AC-03 text names `evidence/coverage/`; the executor recorded coverage under `evidence/qa-gates/`. `coverage` is not a canonical evidence kind in `evidence-and-timestamp-conventions`, so the executor's location is the compliant one. | State the reconciliation in the PR description; no file move. |
| PA-N2 | PR context artifacts were absent at review start and were regenerated by this review. | Regenerate before PR authoring if the head moves. |
| PA-N3 | Local `pwsh` toolchain runs were not performed; verdicts rely on CI run 38011932558 and PoshQC MCP call dispositions (operator-imposed route). Recorded for traceability only. | None; AC-15 confirms on the PR head. |

### Approved Exceptions

- Operator amendment `evidence/other/execution-amendment.2026-10-09T23-50.md`: PoshQC MCP plus CI artifacts replace local `pwsh` runs.
- Operator decision: folding and deleting `bootstrap-host.helpers.ps1` is accepted.
- Operator decision: the missing host-tools manifest and bash bootstrap defect is out of scope (potential entry recorded).

### Removed/Skipped Tests

None. The rewritten `publish-sideloaded-extension.Tests.ps1` replaced `Import-ScriptFunction`-based helper tests with entry-point tests; helper behavior moved to `SideloadedExtensionPublish.Tests.ps1` and `SideloadedExtensionPublish.Invoke.Tests.ps1`. The `scaffold extension package identity` Describe is retained.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **7f410e59b** - docs(847): prepare feature folder, spec, research, and preflight-cleared plan
2. **c04940465** - Merge remote-tracking branch 'origin/main'
3. **f931207d6** - docs(847): record Phase 0 policy reads and baseline evidence
4. **92e5f9f0b** - feat(847): add HostTooling module with shared host seams and tests
5. **9ac5c06e2** - feat(847): add HostBootstrapWorkspace and HostBootstrap modules with tests
6. **31d347da2** - feat(847): add HostVerification module with tests
7. **e0a6cd13a** - feat(847): add SideloadedExtensionPublish module with tests
8. **19d151f98** - feat(847): reduce entry scripts to module wrappers and add entry tests
9. **1c3d1a4c6** - docs(847): record missing host-tools manifest and bash bootstrap as potential entry
10. **d2224baa8** - docs(847): record final QA loop and acceptance evidence

### Files Modified

1. **scripts/dev-tools/HostTooling.psm1** (NEW) - shared manifest, environment, native-process, and version seams.
2. **scripts/dev-tools/HostBootstrap.psm1** (NEW) - bootstrap orchestrator, install/PATH/RunOnce functions.
3. **scripts/dev-tools/HostBootstrapWorkspace.psm1** (NEW) - workspace/project functions and process wrappers.
4. **scripts/dev-tools/HostVerification.psm1** (NEW) - verification orchestrator and five section checks.
5. **scripts/dev-tools/SideloadedExtensionPublish.psm1** (NEW) - publish orchestrator and helpers.
6. **scripts/dev-tools/bootstrap-host.ps1**, **verify-host.ps1**, **publish-sideloaded-extension.ps1** (MODIFIED) - reduced to entry wiring; `param` blocks unchanged.
7. **scripts/dev-tools/bootstrap-host.helpers.ps1** (DELETED) - absorbed into the modules.
8. **tests/scripts/dev-tools/** - 10 new suites and 1 rewritten suite.
9. **docs/** - feature folder, evidence, potential entry, promoted record.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All policy requirements evaluated for the PowerShell changes are met, with numeric baseline, post-change, and changed-code coverage present for the only language with changed code. Blocking findings: 0. Non-blocking observations: 3 (section 8).

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution (CI route per operator amendment)
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

### Metrics Summary

- PASS 6709 tests, 0 failures
- PASS 88.0% repo-wide PowerShell line coverage (baseline 84.69%)
- PASS 8 of 8 changed production files >= 85% (lowest 94.74%)
- PASS all changed files <= 500 lines
- PASS format, analyzer, tests clean in CI run 38011932558

### Recommendation

**Ready for merge after the PR-stage criteria are met.** AC-14 requires the PR description to reference `docs/features/potential/2026-10-09-host-tools-manifest-and-bash-bootstrap-missing.md`; AC-15 requires the CI `poshqc` job to pass on the PR head.

---

## Appendix A: Test Inventory

Changed and new suites (case counts from `reduction.txt`):

1. `tests/scripts/dev-tools/HostTooling.Tests.ps1` - 19 cases
2. `tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1` - 31 cases
3. `tests/scripts/dev-tools/HostBootstrap.Tests.ps1` - 28 cases
4. `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` - 16 cases
5. `tests/scripts/dev-tools/HostVerification.Tests.ps1` - 22 cases
6. `tests/scripts/dev-tools/HostVerification.Invoke.Tests.ps1` - 10 cases
7. `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1` - 27 cases
8. `tests/scripts/dev-tools/SideloadedExtensionPublish.Invoke.Tests.ps1` - 13 cases
9. `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` - 5 cases
10. `tests/scripts/dev-tools/verify-host.Tests.ps1` - 3 cases
11. `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` - 8 cases

The 32 AC tokens and their test names are listed in `artifacts/ci/run-38011932558/reduction.txt` lines 29-95.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (CI route, run 38011932558):**
```powershell
Import-Module "<root>/scripts/powershell/PoshQC/PoshQC.psm1"; Invoke-PoshQCFormat -Root "<root>"
Import-Module "<root>/scripts/powershell/PoshQC/PoshQC.psm1"; Invoke-PoshQCAnalyze -Root "<root>"
Import-Module "<root>/scripts/powershell/PoshQC/PoshQC.psm1"; Invoke-PoshQCTest -Root "<root>"
```

**Reviewer commands (check-only):**
```text
git diff --name-status 460cd755de560b733be0c471d1d144e553fbe0e5...HEAD
git show 460cd755de560b733be0c471d1d144e553fbe0e5:scripts/dev-tools/<entry>.ps1
git diff --stat 1c3d1a4c6 HEAD
poetry run python -m scripts.dev_tools.pr_context.collector --base 460cd755de560b733be0c471d1d144e553fbe0e5 --head HEAD --repo-root .
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit <this file>
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-10
**Policy Version:** Current (as of audit date)

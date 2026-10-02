# Policy Compliance Audit: PoshQC workspace-derived coverage population (#527, absorbs #623 item 1)

---

**Audit Date:** 2026-10-02
**Reviewer:** feature-review agent (pass 1)
**Branch:** `bug/poshqc-coverage-denominator-not-reproducible-527` at `70ab599d7ed8136ca44f4203fcd5e0c60be751a5`
**Base:** `origin/main` (resolved `ef80c57d`), merge base `71f8dcb49d8ce5d1402ff441855a64be15b37f29`; execution anchor BASE_SHA `589b51a30d856dca973a2ed9988f9443c35339cf`
**Code Under Test (non-documentation files in `git diff origin/main...HEAD`):**

- PowerShell production: `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` (new), `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and the five byte-identical mirrors under `extensions/drm-copilot/resources/powershell/PoshQC/`
- PowerShell tests: `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` (new), `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` (new), `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`
- PowerShell fixture: `tests/fixtures/poshqc-consumer/scripts/Sample.psm1`, `tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1`, `tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1`
- Python test: `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (one tuple entry)
- Configuration and docs: `config/poshqc-coverage.json` (new), `.gitignore`, `scripts/powershell/PoshQC/README.md` (and mirror), `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production + 5 mirrors, 4 test files, 3 fixture files | 6529 Pester tests (30 new) | PASS 6519 pass, 0 fail, 10 skipped (CI run A and run B) | 96.38% lines (11457/11887, 127 files) | 84.67% lines (13325/15738, 174 files) | 95.41% (PoshQC.Coverage.psm1 104/109); changed lines of PoshQC.Testing.psm1 100.00% (11/11) |
| Python | 1 file (test module only) | 1 test (bundled parity) | PASS 1 pass, 0 fail | N/A - artifact absent, see 1.2.1 | N/A - artifact absent, see 1.2.1 | N/A - no production Python file changed, see 1.2.1 |
| JSON | 1 file (`config/poshqc-coverage.json`) | 0 | PASS parsed by the CI run that logged `source=config` | N/A - configuration file | N/A - configuration file | N/A - configuration file |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch
- PowerShell baseline coverage artifact: `artifacts/ci/run-36978425380/powershell-coverage.xml` (CI run https://github.com/drmoisan/drm-copilot/actions/runs/36978425380 on main 71f8dcb4), summarized in `evidence/baseline/pwsh-coverage-baseline.2026-10-02T07-45.md`
- PowerShell post-change coverage artifact: `artifacts/ci/run-36983551836/powershell-coverage.xml` (run A) and `artifacts/ci/run-36984586891/powershell-coverage.xml` (run B), summarized in `evidence/qa-gates/final-pwsh-coverage-run-a.2026-10-02T08-45.md` and `evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md`
- Per-language comparison summary: Section 1.2.1 of this audit

**Note on the canonical PowerShell artifact path.** `artifacts/pester/powershell-coverage.xml` exists in the worktree but records a narrowed MCP run of the installed (pre-fix) PoshQC copy: 117 files, 244/11111 lines, 2.20%. It does not represent the branch code. The authoritative branch figures above come from the CI run A and run B artifacts, which the reviewer re-reduced independently (Appendix B).

---

## Rejected Scope Narrowing

The following caller and plan text attempts to downgrade coverage verdicts for languages with changed files. Each is recorded verbatim; coverage verdicts below remain explicit PASS or FAIL.

1. Caller prompt (orchestrator relay of the 2026-09-30 operator decision), verbatim:
   > 2026-09-30: the recorded scope choice "repo-wide coverage treated as evidence only" is accepted. The aggregate PowerShell line coverage on the branch is 84.67% (174 measured files, up from 127) because the population is now workspace-derived; it is recorded as a follow-up item in evidence/qa-gates/coverage-aggregate.*.md. New-code coverage (PoshQC.Coverage.psm1 95.41%, changed Testing.psm1 lines 100%) is the gate.

   Justification: the repo-wide PowerShell verdict is still recorded as FAIL against the uniform 85% line threshold; the operator decision is applied only to the blocking classification of that FAIL (Section 8).

2. Plan `plan.2026-09-29T15-32.md` D11, verbatim (line breaks added only):
   > **D11 — Python scope.** The only Python change is one tuple entry in the test module `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. No Python production module changes, so Python
   > coverage is not applicable; the
   > Python loop runs Black, Ruff, Pyright, and Pytest on that file.

   Justification: Python has a changed file on the branch, so a Python coverage verdict is mandatory; it is recorded as FAIL because the coverage artifact is absent.

3. Spec `spec.md` Coverage Policy, verbatim:
   > The repository aggregate PowerShell line coverage over the derived population is reported as evidence. It is **not** a gate for this issue, because CI enforces no PowerShell threshold.

   Justification: same disposition as item 1.

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported path.
- `git diff --name-only origin/main...HEAD` contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All branch evidence lives under `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/{baseline,other,qa-gates,regression-testing}/`. CI downloads under `artifacts/ci/` are git-ignored working files and are not committed.
- Verdict: PASS.

---

## Executive Summary

The branch replaces the hand-maintained `CodeCoverage.Path` allow-list in both PoshQC runsettings copies with a population derived from the workspace (`config/poshqc-coverage.json`, else the effective test scan folders, else settings `Run.Path`), resolves a relative `-Root` to an absolute path, and logs the population source and count. Implementation, tests, mirror parity, README, and configuration match spec.md and plan D1-D5. CI runs A and B on `a987ebfb` (code tree identical to `70ab599d`; verified with `git diff --name-only a987ebfb 70ab599d`, which lists only feature-folder files) passed format, analyze, and 6519/6529 tests with 0 failures and produced identical coverage totals (15738 lines, 174 files).

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS (with findings) `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (code change and unit test rules)
- PASS `.claude/rules/python.md` toolchain for the single changed Python test file
- JSON: the new configuration file was read and compared with plan D6

Toolchain: PowerShell format, analyze, and test pass in CI on the branch code tree. Python Black, Ruff, Pyright, and Pytest pass locally on the changed file (reviewer-run). The reviewer could not run `pwsh` (worktree isolation guard, operator decision 2026-10-01 Option A) and has no MCP PoshQC tool in this session, so PowerShell results rely on CI artifacts that the reviewer re-reduced independently.

Coverage verdicts: PowerShell new code PASS; PowerShell changed lines PASS; PowerShell repo-wide FAIL (84.67% CI, below 85%; non-blocking under the operator decision and above the 80% remediation-trigger floor); PowerShell modified file `PoshQC.psm1` FAIL (66.67%, newly measured; non-blocking under the operator decision); Python coverage FAIL (artifact `artifacts/python/lcov.info` absent; blocking).

**Blocking findings in this artifact: 1** (PA-B1, Python coverage artifact absent; remediability `autonomous`).

**Temporary artifacts cleanup:**
- PASS No temporary script was committed. The executor's scratch reducer `artifacts/ci/ci_evidence.py` is git-ignored. The reviewer's reducer lives in the session scratchpad outside the repository.
- PASS No new tooling script requires tests.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Each `It` re-derives state in `BeforeEach` (`$script:covLogs`, `$script:covTreeFiles`, `$script:resConfig`, etc.); parameter sets are built fresh by factory scriptblocks (`$script:covNewParameters`, `$script:cfgNewParameters`, `$script:resNewParameters`). |
| **Isolation** | PASS | Unit tests target one function each: `Get-PoshQCCoverageConfigRoot`, `Get-PoshQCCoverageFileSet`, `Resolve-PoshQCCoveragePopulation`, and the `Invoke-PoshQCTest` population seam. |
| **Fast Execution** | PASS | All filesystem access is answered from in-memory lists; no Pester run, network, or process launch inside the new tests. Full CI suite 346.6 s for 6529 tests. |
| **Determinism** | PASS | No clock, RNG, or temp files. The relative-root test sets the location explicitly with `Push-Location -LiteralPath $TestDirectory` / `Pop-Location`. CI runs A and B reproduced identical JUnit totals and coverage keys. |
| **Readability & Maintainability** | PASS | Descriptive `It` names, explicit `# Arrange` / `# Act` / `# Assert` comments in every test. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline 96.38% lines (11457/11887, 127 files), CI run 36978425380 on main 71f8dcb4; `evidence/baseline/pwsh-coverage-baseline.2026-10-02T07-45.md`. Reviewer re-reduction matched. |
| **No Coverage Regression (changed lines)** | PASS | Changed executable lines of `PoshQC.Testing.psm1` 11/11 covered (reviewer checked lines 291, 301-302, 353-357, 361-363 in the run A XML); `PoshQC.psm1` added line is a non-executable list entry. |
| **Repo-wide line threshold (85%)** | FAIL | 84.67% (13325/15738) in run A and run B. The drop from 96.38% is caused by population growth from 127 to 174 files (47 production files the allow-list omitted). Non-blocking under the 2026-09-30 operator decision; above the 80% remediation-trigger floor. Follow-up list of 42 files in `evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md`. |
| **New Code Coverage (>= 85%)** | PASS | `PoshQC.Coverage.psm1` 104/109 = 95.41% (uncovered lines 75, 96, 163, 256, 257). |
| **Modified-file threshold (85%)** | FAIL | `PoshQC.Testing.psm1` 200/200 = 100.00% PASS. `PoshQC.psm1` 40/60 = 66.67% FAIL: the file was not in the 127-file baseline population, so no regression is measurable; the 20 uncovered lines are pre-existing default-seam bodies of `Install-PoshQCTool` (lines 20-31, 41, 76) and the process-lifetime sub-module cache-miss path (110-111, 123-130). Non-blocking under the operator decision (the file is in the accepted follow-up list). |
| **Comprehensive Coverage** | PASS | All four new functions are exercised; precedence, validation, enumeration, pruning, logging, and empty-population paths each have a test. |
| **Positive Flows** | PASS | Valid config, config source, settings source, fallback scan folders, fallback `Run.Path`, route independence, consumer population. |
| **Negative Flows** | PASS | Eight malformed-config cases (invalid JSON, empty, version 2, missing roots, non-array roots, blank, absolute, `..`). |
| **Edge Cases** | PASS | Shuffled enumeration, case-variant duplicates, overlapping roots, nested `tests` directory kept, root-level `tests` excluded, excluded directories, extension case-insensitivity. |
| **Error Handling** | PASS | Missing roots warn once each; all roots missing returns an empty set; empty population disables coverage and still invokes Pester; nonexistent settings entries pruned and logged. |
| **Concurrency** | PASS | No concurrent code paths introduced; not exercised. |
| **State Transitions** | PASS | Coverage enabled-to-disabled transition on empty population is asserted (`CodeCoverage.Enabled` false, copy not invoked). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.38% lines (127 files) -> Post-change: 84.67% lines (174 files). Change: -11.71 percentage points, attributable to the intended population growth, with 1868 more covered lines and 1983 more uncovered lines. New/changed-code coverage: 95.41% for PoshQC.Coverage.psm1 and 100.00% for changed PoshQC.Testing.psm1 lines. Disposition: FAIL for the repo-wide 85% line threshold and for the PoshQC.psm1 modified-file threshold (66.67%); new-code and changed-line gates PASS. Evidence: `artifacts/ci/run-36978425380/powershell-coverage.xml`, `artifacts/ci/run-36983551836/powershell-coverage.xml`, `evidence/qa-gates/coverage-new-code.2026-10-02T08-45.md`, `evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md`.
- Python: Coverage disposition FAIL. The Python coverage artifact `artifacts/python/lcov.info` is absent from the worktree, and Python has one changed file on the branch (a test module). The changed file itself is a test file, so it is excluded from the coverage denominator, but the mandatory per-language artifact check cannot be satisfied without the artifact. Evidence: `ls artifacts/` lists no `python/` directory.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `Should -Be` on whole arrays prints expected and actual sets (fail-first log lines in `evidence/regression-testing/fail-first-coverage-tests.2026-10-02T08-45.md`); `-Because` text on the absolute-path assertions. |
| **Arrange-Act-Assert Pattern** | PASS | Every new and edited test carries the three labelled sections. |
| **Document Intent** | PASS | Describe blocks cite issue #527; header comments state that no test creates a file. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, process, or real Pester invocation in the new tests. |
| **Use Mocks/Stubs** | PASS | Injected seams (`-TestPathExists`, `-EnumerateFiles`, `-ReadContent`, `-ReadConfig`, `-GetFileSet`, `-InvokePester`, `-CopyCoverage`, `-Logger`) plus `InModuleScope PoshQC` mocks of `Test-Path`, `Get-ChildItem`, `Get-Content`, and `New-Item` for the three route-level tests, so the default seams execute. |
| **Environment Stability** | PASS | Reviewer grep for `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `env:TEMP`, `env:TMP` over the five new or edited test files returned no match (exit 1). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This artifact is the pass-1 policy review. Outstanding items are listed in Section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `spec.md` Context and Root Cause Analysis (#527 and #623 item 1). |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.2026-10-02T07-45.md`. |
| **Document the plan** | PASS | `plan.2026-09-29T15-32.md` (five preflight rounds, recorded under `evidence/other/preflight-round-*.md`). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Four small functions; precedence evaluated once per run. |
| **Reusability** | PASS | `Get-PoshQCSettingsList` serves both `CodeCoverage.Path` and `Run.Path`; the file-set function is reused by both `config` and `fallback` sources. |
| **Extensibility** | PASS | Config schema carries `version`; optional seams with safe defaults. |
| **Separation of concerns** | PASS | I/O isolated behind scriptblock seams; derivation logic is pure given the seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Coverage derivation lives in the new `PoshQC.Coverage.psm1`; `Invoke-PoshQCTest` only calls the seam. |
| **Under 500 lines** | PASS | `PoshQC.Coverage.psm1` 314, `PoshQC.Testing.psm1` 460, `PoshQC.Coverage.Tests.ps1` 405, `PoshQC.CoverageConfig.Tests.ps1` 253, `PoshQC.TestingInvokeSummary.Tests.ps1` 142. `PoshQC.Comprehensive.Tests.ps1` is 766 lines pre-existing and the edit is line-neutral (+4/-4). |
| **Public vs internal** | PASS | No new function added to `Export-ModuleMember` or `PoshQC.psd1` (manifest unchanged; `evidence/other/manifest-unchanged.2026-10-02T08-50.md`). |
| **No circular dependencies** | PASS | Sub-module load order FileDiscovery, ScanConfig, Coverage, Analyzer, Testing; Coverage depends only on module-scope variables. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Approved verbs `Get-` and `Resolve-`; `PoshQC` noun prefix. |
| **Docs/docstrings** | PASS | Comment-based help with `.PARAMETER` entries for all four functions and the new `-ResolveCoveragePopulation` parameter. |
| **Comment why, not what** | PASS | Comments explain #409 and #527 rationale (empty set disables coverage; module-copy independence). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | CI step `Format PowerShell` success (run A, run B); `poetry run black --check` on the Python file: unchanged. |
| **2. Linting** | PASS | CI step `Analyze PowerShell` success (`PSScriptAnalyzer passed: no findings`); `poetry run ruff check`: all checks passed. |
| **3. Type checking** | PASS | Pyright 0 errors on the Python file; PowerShell has no type-check stage. |
| **4. Testing** | PASS | CI `Test PowerShell`: 6529 tests, 0 failures, 0 errors, 10 disabled (reviewer read `testsuites` element of run A JUnit). Pytest parity: 1 passed. |
| **Full toolchain loop** | PASS | CI runs the stages in order on one code tree; plan D12 records no architecture, contract, or integration tooling for PoshQC. The fixture integration-style run is deferred (Section 8). |
| **Explicit reporting** | PASS | Commands recorded in `evidence/qa-gates/final-*.md` and Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages `bb233fe7`..`70ab599d`; Section 9. |
| **Design choices explained** | PASS | Plan D1-D14; spec Proposed Fix. |
| **Update supporting documents** | PASS | README (both copies), potential entry annotated as superseded. |
| **Provide next steps** | PASS | Operator-run blockers listed in `evidence/other/pwsh-task-classification.2026-10-02T07-50.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check tests/scripts/dev_tools/test_poshqc_bundled_parity.py` -> 1 file would be left unchanged. |
| **Linting with Ruff** | PASS | `poetry run ruff check <file>` -> All checks passed. |
| **Type checking with Pyright** | PASS | `poetry run pyright <file>` -> 0 errors, 0 warnings, 0 informations. |
| **Testing with Pytest** | PASS | `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q -p no:cacheprovider` -> 1 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | One string literal added to an existing tuple constant; no new API. |
| **Dataclasses / Protocols / utility classes** | PASS | No structural change. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions / logging / invariants** | PASS | No change to error handling. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | CI run A step `Format PowerShell` success (fails on any rewrite via `git status --porcelain`). |
| **Linting with PSScriptAnalyzer** | PASS | CI run A step `Analyze PowerShell` success; job log `PSScriptAnalyzer passed: no findings`. |
| **Fix all findings** | PASS | No findings reported. |
| **PowerShell 7+ compatible** | PASS | CI runs on `windows-latest` pwsh; no version-specific constructs beyond PS7 baseline. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | All four functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | PASS | No `Mandatory` attributes by design (plan D1: empty arrays must bind); validation is explicit in the config reader. Noted as a design choice in the code review. |
| **Avoid global state** | PASS | Reads only module-scope constants `$script:DefaultExcludedDirs` and `$script:PesterSettings`. |
| **Error handling** | PASS | `$ErrorActionPreference = 'Stop'`; config errors throw with the file name; JSON parse error wrapped with context and rethrown. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | See 2.3. |
| **Approved verbs** | PASS | `Get-PoshQCSettingsList`, `Get-PoshQCCoverageConfigRoot`, `Get-PoshQCCoverageFileSet`, `Resolve-PoshQCCoveragePopulation`. |
| **Comment why** | PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | CI run A and run B. |
| **Step 2: Analyze** | PASS | CI run A and run B. |
| **Step 3: Type check** | PASS | No type-check stage exists for this language; skipped by rule. |
| **Step 4: Test** | PASS | CI run A and run B: 6519 passed, 0 failed, 10 skipped. |
| **Rerun loop if needed** | PASS | Final runs on a single code tree; earlier failing runs were intentional fail-first and pre-adaptation runs. |

### Section 3D: JSON Configuration

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON / content** | PASS | `config/poshqc-coverage.json` read by the reviewer: `version` 1, roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`; LF endings (`git ls-files --eol` -> `i/lf w/lf`). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Existing parity test extended. |
| **Coverage expectation** | FAIL | Python lcov artifact absent; see 1.2.1 and PA-B1. |
| **Organization / naming** | PASS | Unchanged existing module under `tests/scripts/dev_tools/`. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `BeforeAll`, `BeforeEach`, `Describe`/`It`, `-ForEach` data-driven cases, `InModuleScope`, `Mock`. |
| **Use PoshQC Configuration** | PASS | CI step `Invoke-PoshQCTest -Root <workspace>` with the branch runsettings. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 13 tests in `PoshQC.Coverage.Tests.ps1`, 17 cases in `PoshQC.CoverageConfig.Tests.ps1`. |
| **Test Behavior Over Implementation** | PASS | Route tests assert the population handed to Pester, not internal calls. |
| **Mocking Used Sparingly** | PASS | Cmdlet mocks are limited to the filesystem boundary required to avoid temporary files. |
| **Organization** | PASS | Tests under `tests/scripts/powershell/PoshQC/` mirror `scripts/powershell/PoshQC/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | PASS | `*.Tests.ps1`. |
| **Describe/It Structure** | PASS | Four `Describe` blocks across the two new files. |
| **Logical Grouping** | PASS | Grouped by function under test. |
| **Docstrings/Comments** | PASS | Header comments per `Describe`. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | CI `Invoke-PoshQCTest`. Local MCP route calls are route-compliance only (installed copy; plan D10). |
| **No Alternative Test Runners** | PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### PoshQC.Coverage.psm1 (30 test cases across two files)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| measures an identical population for the repository and bundled settings copies | Positive (route independence) | Resolve, FileSet, ConfigRoot default seams | PASS |
| measures only the consumer production file when a stale bundled allow-list names pushed-down files | Positive (#623) | fallback path | PASS |
| logs the population source and file count before Pester runs | Positive (observability) | Testing.psm1 353-357 | PASS |
| resolves a relative Root to an absolute path | Edge | Testing.psm1 300-303 | PASS |
| disables coverage, logs once, and still runs Pester when the population is empty | Error handling (#409) | Testing.psm1 361-363 | PASS |
| hands the scan-configuration folders to the coverage resolver | Positive | seam arguments | PASS |
| Get-PoshQCCoverageFileSet: shuffled order, case-variant duplicates, overlapping roots, exclusions, extensions, missing root, all roots missing (7) | Edge / Error handling | 154-210 | PASS |
| Get-PoshQCCoverageConfigRoot: absent, valid, 8 malformed cases (10) | Positive / Negative | 62-129 | PASS |
| Resolve-PoshQCCoveragePopulation: settings precedence, pruning, module-default ignore, config over fallback, fallback scan folders, fallback Run.Path, all roots missing (7) | Positive / Edge | 246-314 | PASS |

**Coverage:** 95.41% of `PoshQC.Coverage.psm1` (104/109).

**Not covered:** line 75 (rooted `ConfigRelativePath` branch), line 96 (non-object JSON document), line 163 (default `WarningLogger` body), lines 256-257 (default `SettingsPathExists` and `Logger` bodies).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 6529 (CI run A) | PASS |
| Tests Passed | 6519 (99.85%) | PASS |
| Tests Failed | 0 | PASS |
| Skipped / disabled | 10 | PASS |
| Execution Time | 346.6 s full suite | PASS |
| New tests | 30 | PASS |
| Test File Size | 405 and 253 lines | PASS |
| Line Coverage, PowerShell | 84.67% repo-wide; 95.41% new file | FAIL repo-wide, PASS new code |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <file>` | unchanged | PASS |
| Ruff Linting | `poetry run ruff check <file>` | all checks passed | PASS |
| Pyright Type Checking | `poetry run pyright <file>` | 0 errors | PASS |
| Pytest Tests | `poetry run pytest <file>` | 1 passed | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | CI `Invoke-PoshQCFormat -Root <workspace>` | step success, run A and run B | PASS |
| PSScriptAnalyzer | CI `Invoke-PoshQCAnalyze -Root <workspace>` | no findings | PASS |
| Pester Tests | CI `Invoke-PoshQCTest -Root <workspace>` | 6519 passed, 0 failed | PASS |

**Notes:** The pre-adaptation run (https://github.com/drmoisan/drm-copilot/actions/runs/36983547210, `94853dca`) and the fail-first run (https://github.com/drmoisan/drm-copilot/actions/runs/36983544629, `bb233fe7`) concluded failure by design; reviewer confirmed both conclusions with `gh run view`.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-B1 (Blocking, remediability `autonomous`): Python coverage artifact absent.** Location: `artifacts/python/lcov.info` (not present). Rule: feature-review coverage verification (mandatory artifact for every language with changed files) and `.claude/rules/general-unit-test.md` Coverage Requirements. Fix: run `poetry run pytest --cov --cov-report=lcov:artifacts/python/lcov.info` from the worktree root, record repo-wide Python line and branch percentages in `<FEATURE>/evidence/qa-gates/python-coverage.<ts>.md`, and confirm no Python production file changed (no changed-line regression possible).
- **PA-N1 (Non-blocking, operator-accepted): PowerShell repo-wide line coverage FAIL, 84.67% < 85%.** The 2026-09-30 operator decision accepts this as a follow-up item. The follow-up issue is not yet filed; it must be filed before or with the PR per spec Rollout & Follow-up.
- **PA-N2 (Non-blocking, operator-accepted): modified file `scripts/powershell/PoshQC/PoshQC.psm1` FAIL, 66.67% < 85%.** Newly measured (absent from the baseline allow-list), so no regression is measurable; listed in the accepted follow-up list. Include it in the follow-up issue.
- **PA-N3 (Non-blocking, deferred by operator decision 2026-10-01): AC-01, AC-11, AC-12, AC-13 require operator-run `pwsh` commands** (run C and the post-fix consumer fixture run). The PR must state "Partially addresses #527".
- **PA-N4 (Non-blocking): evidence timestamp provenance.** `evidence/other/mcp-route-compliance.2026-10-02T09-00.md` and `evidence/regression-testing/parity-after-mirror.2026-10-02T08-55.md` were introduced by commit `a987ebfb` (2026-10-02 04:20 -0400, 08:20 UTC), so their timestamps postdate their own commit; evidence timestamps generally follow UTC rather than host local time required by `evidence-and-timestamp-conventions`. Numeric content spot-checked against CI artifacts was consistent.

### Approved Exceptions

- Operator decision 2026-09-30: repo-wide PowerShell aggregate recorded as a follow-up item; new-code and changed-line coverage are the gate for this change.
- Operator decision 2026-10-01 (Option A): no local `pwsh`; CI artifacts substitute for self-hosted runs, each recorded as a named deviation in `evidence/other/plan-deviations.2026-10-02T07-45.md`.

### Removed/Skipped Tests

**None.** All planned tests are implemented (13 + 17 cases); the four D14-predicted adaptations were applied.

---

## 9. Summary of Changes

### Commits in This PR/Branch (non-merge, after merge base)

1. `944c8f80`..`43e403a1` - feature folder, research, spec, plan, and five preflight rounds
2. `589b51a3` - PowerShell task classification (Option A)
3. `8c218bd7` - Phase 0 policy reads, baseline evidence, plan deviations
4. `6efc5753` - consumer fixture, ignore rule, fail-first fixture evidence
5. `bb233fe7` - fail-first coverage-population and coverage-config suites
6. `94853dca` - fix: derive the coverage population from the workspace
7. `33ac07ed` - adapt the four affected existing tests
8. `9b5aa44e` - README documentation
9. `a987ebfb` - bundled mirror sync, parity list, potential-entry annotation
10. `ab266ca9`, `70ab599d` - CI evidence, Phase 6 QA evidence, AC check-off

### Files Modified

1. `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` (NEW) - config reader, file-set enumeration, precedence resolver.
2. `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (MODIFIED) - absolute `-Root`, `-ResolveCoveragePopulation` seam, population log line; allow-list pruning moved to the resolver.
3. `scripts/powershell/PoshQC/PoshQC.psm1` (MODIFIED) - loads the new sub-module.
4. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (MODIFIED) - `CodeCoverage.Path` list removed.
5. `config/poshqc-coverage.json` (NEW) - repository coverage roots.
6. Mirrors under `extensions/drm-copilot/resources/powershell/PoshQC/` (MODIFIED/NEW) - byte-identical (reviewer `sha256sum` on five pairs).
7. Tests and fixture as listed in the header; `.gitignore` ignores fixture run output.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Implementation and tests comply with the code-change, unit-test, and PowerShell policies. One blocking policy gap remains (PA-B1, Python coverage artifact absent). PowerShell repo-wide and `PoshQC.psm1` coverage FAIL verdicts are recorded and are non-blocking under the recorded operator decision.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes, Design Principles, Module & File Structure, Naming/Docs/Comments, Toolchain Execution, Summarize & Document

#### Language-Specific Code Change Policy (Section 3)
- Python: PASS tooling, design, error handling
- PowerShell: PASS tooling, design and safety, structure and naming, toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles, Test Structure, External Dependencies, Policy Audit
- FAIL Coverage & Scenarios: PowerShell repo-wide 84.67% and `PoshQC.psm1` 66.67% (both operator-accepted, non-blocking); Python artifact absent (blocking)

#### Language-Specific Unit Test Policy (Section 4)
- Python: FAIL coverage expectation (artifact absent); PASS framework, structure, toolchain
- PowerShell: PASS framework, style, naming, toolchain

### Metrics Summary

- PASS 6519/6529 PowerShell tests passing, 0 failed
- PASS new-code line coverage 95.41%; changed lines 100.00%
- FAIL PowerShell repo-wide line coverage 84.67%
- PASS mirror parity (five pairs byte-identical; pytest parity passed)
- PASS evidence locations

### Recommendation

**Needs revision (one autonomous blocker).** Produce and record the Python coverage artifact (PA-B1), file the PowerShell coverage follow-up issue (PA-N1, PA-N2), and keep the PR wording "Partially addresses #527" while AC-01 and AC-11 to AC-13 await the operator-run commands.

---

## Appendix A: Test Inventory

1. Invoke-PoshQCTest coverage population (issue #527) > measures an identical population for the repository and bundled settings copies over the same workspace
2. ... > measures only the consumer production file when a stale bundled allow-list names pushed-down files
3. ... > logs the population source and file count before Pester runs
4. ... > resolves a relative Root to an absolute path before building run, coverage, and output paths
5. ... > disables coverage, logs once, and still runs Pester when the derived population is empty
6. ... > hands the scan-configuration folders to the coverage resolver when -ScanFolders is absent
7. Get-PoshQCCoverageFileSet (issue #527) > returns the same ordinally sorted list for shuffled enumeration order
8. ... > collapses case-variant duplicates to one entry
9. ... > collapses files reached through overlapping roots
10. ... > excludes *.Tests.ps1 files, the root-level tests tree, and default excluded directories
11. ... > keeps only .ps1 and .psm1 files
12. ... > skips a nonexistent root with one warning naming the root
13. ... > returns an empty set when every root is missing
14. Get-PoshQCCoverageConfigRoot (issue #527) > reports the configuration as absent when the file does not exist
15. ... > returns the validated roots for a version 1 document
16-23. ... > fails fast naming config/poshqc-coverage.json for invalid JSON, empty content, unsupported version, missing roots, non-array roots, blank entry, absolute entry, parent-traversal entry
24. Resolve-PoshQCCoveragePopulation precedence (issue #527) > honors a non-empty CodeCoverage.Path from a caller-supplied settings file over the workspace config
25. ... > prunes and logs each nonexistent caller-supplied settings path
26. ... > ignores CodeCoverage.Path in the module-default settings file and logs that it was ignored
27. ... > uses the workspace config roots over the fallback scan folders
28. ... > falls back to the scan-folder roots when no workspace config exists
29. ... > falls back to the settings Run.Path when no scan folders are supplied
30. ... > returns source config with an empty population when every configured root is missing
31. Edited: PoshQC.TestingInvokeSummary.Tests.ps1 (two summary-replay tests now inject `-ResolveCoveragePopulation`; fixed message count 4 -> 5)
32. Edited: PoshQC.Comprehensive.Tests.ps1 (two Koverage tests; `Test-Path` mock answers true for the coverage source entry)
33. Python: tests/scripts/dev_tools/test_poshqc_bundled_parity.py (parity tuple gains `PoshQC.Coverage.psm1`)

---

## Appendix B: Toolchain Commands Reference

Reviewer-run commands (worktree root):

```bash
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run black --check tests/scripts/dev_tools/test_poshqc_bundled_parity.py
poetry run ruff check tests/scripts/dev_tools/test_poshqc_bundled_parity.py
poetry run pyright tests/scripts/dev_tools/test_poshqc_bundled_parity.py
poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q -p no:cacheprovider
sha256sum scripts/powershell/PoshQC/<file> extensions/drm-copilot/resources/powershell/PoshQC/<file>   # five pairs
git check-ignore -v tests/fixtures/poshqc-consumer/artifacts/pester/powershell-coverage.xml
git ls-files --eol -- tests/fixtures/poshqc-consumer config/poshqc-coverage.json
git diff --name-only a987ebfb 70ab599d
gh run view 36983551836 --json headBranch,headSha,workflowName,conclusion,jobs
gh run view 36984586891 / 36983544629 / 36983547210 --json headSha,workflowName,conclusion
poetry run python <scratchpad>/cx_check.py <four coverage XML files>   # independent JaCoCo reduction
```

Independent reduction results: baseline 11457/11887 = 96.38%, 127 files; run A and run B each 13325/15738 = 84.67%, 174 files; `PoshQC.Coverage.psm1` 104/109; `PoshQC.Testing.psm1` 200/200; run A JUnit `tests="6529" errors="0" failures="0" disabled="10"`; job log line 837 `Code coverage population: source=config; files=174`.

PowerShell toolchain of record (CI `_poshqc.yml`, branch PoshQC copy):

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root .
```

Template source: the bundled template `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the asset the MCP template tool serves; the MCP tool itself was unavailable to this agent session.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-02
**Policy Version:** Current (as of audit date)

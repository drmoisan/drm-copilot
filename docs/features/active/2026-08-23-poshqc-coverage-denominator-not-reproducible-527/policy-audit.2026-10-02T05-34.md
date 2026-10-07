# Policy Compliance Audit: PoshQC workspace-derived coverage population (#527, absorbs #623 item 1)

---

**Audit Date:** 2026-10-02
**Reviewer:** feature-review agent (pass 2, remediation cycle 1 reaudit)
**Branch:** `bug/poshqc-coverage-denominator-not-reproducible-527` at `e5d9b58fda803ab693d05712bd3ba3415064d68e`
**Base:** `origin/main` (resolved `ef80c57d`), merge base `71f8dcb49d8ce5d1402ff441855a64be15b37f29`; execution anchor BASE_SHA `589b51a30d856dca973a2ed9988f9443c35339cf`
**Prior pass:** `policy-audit.2026-10-02T05-08.md` at `70ab599d` (1 blocking: PA-B1)
**Cycle 1 delta:** `git diff --stat 70ab599d e5d9b58f` lists 17 files, all under the feature folder; `git diff --name-only 70ab599d e5d9b58f -- scripts extensions tests config .gitignore` returned no path. No production, test, or configuration file changed in the cycle.

**Code Under Test (non-documentation files in `git diff origin/main...HEAD`, unchanged from pass 1):**

- PowerShell production: `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` (new), `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and the byte-identical mirrors under `extensions/drm-copilot/resources/powershell/PoshQC/`
- PowerShell tests: `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` (new), `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` (new), `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`
- PowerShell fixture: `tests/fixtures/poshqc-consumer/scripts/Sample.psm1`, `tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1`, `tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1`
- Python test: `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (one tuple entry)
- Configuration and docs: `config/poshqc-coverage.json` (new), `.gitignore`, `scripts/powershell/PoshQC/README.md` (and mirror), `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production + 5 mirrors, 4 test files, 3 fixture files | 6529 Pester tests (30 new) | PASS 6519 pass, 0 fail, 10 skipped (CI run A and run B) | 96.38% lines (11457/11887, 127 files) | 84.67% lines (13325/15738, 174 files) | 95.41% (PoshQC.Coverage.psm1 104/109); changed lines of PoshQC.Testing.psm1 100.00% (11/11) |
| Python | 1 file (test module only; no production file) | 6377 passed, 6 skipped (full suite, cycle 1 runs A and B) | PASS 0 failed | 93.53% lines, 86.77% branches (equal to post-change; no production Python file changed) | 93.53% lines (16129/17244), 86.77% branches (5406/6230), 210 source files | N/A - no new or modified Python production file, so no changed line exists |
| JSON | 1 file (`config/poshqc-coverage.json`) | 0 | PASS parsed by the CI run that logged `source=config` | N/A - configuration file, no executable lines | N/A - configuration file, no executable lines | N/A - configuration file, no executable lines |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch
- PowerShell baseline coverage artifact: `artifacts/ci/run-36978425380/powershell-coverage.xml` (CI run https://github.com/drmoisan/drm-copilot/actions/runs/36978425380 on main 71f8dcb4), summarized in `evidence/baseline/pwsh-coverage-baseline.2026-10-02T07-45.md`
- PowerShell post-change coverage artifact: `artifacts/ci/run-36983551836/powershell-coverage.xml` (run A) and `artifacts/ci/run-36984586891/powershell-coverage.xml` (run B), summarized in `evidence/qa-gates/final-pwsh-coverage-run-a.2026-10-02T08-45.md` and `evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (present, git-ignored, 488484 bytes, mtime 2026-10-02 05:29:09 -0400), summarized in `evidence/qa-gates/python-coverage.2026-10-02T05-34.md`
- Python baseline comparison: no Python production file differs between the merge base and HEAD (`evidence/qa-gates/python-changed-files.2026-10-02T05-33.md`; reviewer re-ran `git diff --name-only origin/main...HEAD` and found only the test module)
- Per-language comparison summary: Section 1.2.1 of this audit

**Note on the canonical PowerShell artifact path.** `artifacts/pester/powershell-coverage.xml` in the worktree is unchanged since pass 1 (mtime 2026-10-02 04:18:24 -0400). It records a narrowed MCP run of the installed (pre-fix) PoshQC copy: 117 files, 244/11111 lines, 2.20%. It does not represent the branch code. The authoritative branch figures come from the CI run A and run B artifacts; the PowerShell code tree has not changed since those runs (`a987ebfb` equals `e5d9b58f` outside the feature folder).

---

## Rejected Scope Narrowing

The following caller and plan text attempts to downgrade coverage verdicts for languages with changed files. Each is recorded verbatim; coverage verdicts below remain explicit PASS or FAIL. The caller prompt for this pass did not add a new narrowing; it asked that the pass-1 operator-decision context be carried forward, which is done here.

1. Caller prompt (orchestrator relay of the 2026-09-30 operator decision, carried from pass 1), verbatim:
   > 2026-09-30: the recorded scope choice "repo-wide coverage treated as evidence only" is accepted. The aggregate PowerShell line coverage on the branch is 84.67% (174 measured files, up from 127) because the population is now workspace-derived; it is recorded as a follow-up item in evidence/qa-gates/coverage-aggregate.*.md. New-code coverage (PoshQC.Coverage.psm1 95.41%, changed Testing.psm1 lines 100%) is the gate.

   Justification: the repo-wide PowerShell verdict is still recorded as FAIL against the uniform 85% line threshold; the operator decision is applied only to the blocking classification of that FAIL (Section 8).

2. Caller prompt for this pass, verbatim:
   > repo-wide PowerShell 84.67% is
   > evidence-only per 2026-09-30

   Justification: same disposition as item 1; the FAIL verdict is retained.

3. Plan `plan.2026-09-29T15-32.md` D11, verbatim (line breaks added only):
   > **D11 — Python scope.** The only Python change is one tuple entry in the test module `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. No Python production module changes, so Python
   > coverage is not applicable; the
   > Python loop runs Black, Ruff, Pyright, and Pytest on that file.

   Justification: Python has a changed file on the branch, so a Python coverage verdict is mandatory; it is recorded as PASS from the cycle 1 artifact.

4. Spec `spec.md` Coverage Policy, verbatim:
   > The repository aggregate PowerShell line coverage over the derived population is reported as evidence. It is **not** a gate for this issue, because CI enforces no PowerShell threshold.

   Justification: same disposition as item 1.

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported path (re-run at `e5d9b58f`).
- `git diff --name-only origin/main...HEAD` contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- Cycle 1 evidence lives under `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/other/`, and `<FEATURE>/evidence/remediation-baseline/`. `artifacts/python/lcov.info` is a git-ignored tool output at the path the coverage-verification table names, not committed evidence.
- Verdict: PASS.

---

## Executive Summary

Pass 1 recorded one blocking finding, PA-B1 (Python coverage artifact absent). Remediation cycle 1 ran the full Python suite with coverage twice (statement-only and with `--cov-branch`), wrote `artifacts/python/lcov.info`, and committed seven evidence files. The reviewer re-reduced the lcov file independently: 210 `SF:` records, `LF` sum 17244, `LH` sum 16129 (93.53%), `BRF` sum 6230, `BRH` sum 5406 (86.77%). These match the evidence exactly. The lcov file contains no `tests/` source record, and `pyproject.toml` `[tool.coverage.run] omit` lists only `tests/*`, `*/tests/*`, `*/__pycache__/*`, and `*/site-packages/*`, so no production path is excluded. PA-B1 is closed.

No code, test, or configuration file changed in the cycle, so all pass-1 PowerShell and Python toolchain results still apply to HEAD. The reviewer re-ran the Python file-level toolchain and mirror-parity hashes at `e5d9b58f` (all PASS). No new blocking issue was found.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS (with non-blocking findings) `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (code change and unit test rules)
- PASS `.claude/rules/python.md` toolchain and the Python threshold check
- JSON: configuration file compared with plan D6 in pass 1; unchanged

Coverage verdicts: PowerShell new code PASS; PowerShell changed lines PASS; PowerShell repo-wide FAIL (84.67% CI, below 85%; non-blocking under the 2026-09-30 operator decision and above the 80% remediation-trigger floor); PowerShell modified file `PoshQC.psm1` FAIL (66.67%, newly measured; non-blocking under the operator decision); Python repo-wide PASS (93.53% line, 86.77% branch).

**Blocking findings in this artifact: 0.**

**Temporary artifacts cleanup:**
- PASS No temporary script was committed in the cycle. `artifacts/python/` (lcov, coverage json, run output captures) is git-ignored. The reviewer wrote only to the session scratchpad.
- PASS No new tooling script requires tests.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Unchanged since pass 1: each `It` re-derives state in `BeforeEach`; parameter sets are built by factory scriptblocks. |
| **Isolation** | PASS | Unit tests target one function each (`Get-PoshQCCoverageConfigRoot`, `Get-PoshQCCoverageFileSet`, `Resolve-PoshQCCoveragePopulation`, the `Invoke-PoshQCTest` population seam). |
| **Fast Execution** | PASS | In-memory seams only; full CI suite 346.6 s for 6529 tests. |
| **Determinism** | PASS | No clock, RNG, or temp files. CI runs A and B reproduced identical JUnit totals and coverage keys. The two cycle 1 Python runs reported identical pass/skip counts (6377/6). |
| **Readability & Maintainability** | PASS | Descriptive `It` names and labelled AAA sections. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | PowerShell baseline 96.38% (CI run 36978425380). Python: no production file changed, so the measured post-change figure is also the baseline for every measured file. |
| **No Coverage Regression (changed lines)** | PASS | `PoshQC.Testing.psm1` changed executable lines 11/11 covered; `PoshQC.psm1` added line non-executable; no Python production line changed. |
| **Repo-wide line threshold (85%), PowerShell** | FAIL | 84.67% (13325/15738) in run A and run B, caused by population growth from 127 to 174 files. Non-blocking under the 2026-09-30 operator decision; above the 80% remediation-trigger floor. Follow-up list in `evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md`. |
| **Repo-wide thresholds, Python (85% line, 75% branch)** | PASS | 93.53% line (16129/17244) and 86.77% branch (5406/6230) from `artifacts/python/lcov.info`; reviewer re-reduction matched. |
| **New Code Coverage (>= 85%)** | PASS | `PoshQC.Coverage.psm1` 104/109 = 95.41%. |
| **Modified-file threshold (85%)** | FAIL | `PoshQC.Testing.psm1` 100.00% PASS; `PoshQC.psm1` 40/60 = 66.67% FAIL, newly measured (absent from the 127-file baseline), no regression measurable. Non-blocking under the operator decision. |
| **Comprehensive Coverage** | PASS | All four new functions exercised; precedence, validation, enumeration, pruning, logging, and empty-population paths each have a test. |
| **Positive Flows** | PASS | Valid config, settings source, fallback scan folders, fallback `Run.Path`, route independence, consumer population. |
| **Negative Flows** | PASS | Eight malformed-config cases. |
| **Edge Cases** | PASS | Shuffled enumeration, case-variant duplicates, overlapping roots, nested and root-level `tests` directories, excluded directories, extension case. |
| **Error Handling** | PASS | Nonexistent roots warn once each; all roots absent returns empty; empty population disables coverage and still runs Pester. |
| **Concurrency** | PASS | No concurrent code paths introduced. |
| **State Transitions** | PASS | Coverage enabled-to-disabled transition on empty population asserted. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.38% lines (127 files) -> Post-change: 84.67% lines (174 files). Change: -11.71 percentage points, attributable to the intended population growth. New/changed-code coverage: 95.41% for PoshQC.Coverage.psm1 and 100.00% for changed PoshQC.Testing.psm1 lines. Disposition: FAIL for the repo-wide 85% line threshold and for the PoshQC.psm1 modified-file threshold (66.67%), both non-blocking by operator decision; new-code and changed-line gates PASS. Evidence: `artifacts/ci/run-36978425380/powershell-coverage.xml`, `artifacts/ci/run-36983551836/powershell-coverage.xml`, `evidence/qa-gates/coverage-new-code.2026-10-02T08-45.md`, `evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md`.
- Python: Baseline: 93.53% line, 86.77% branch (equal to post-change for every measured production file, because no production Python file changed) -> Post-change: 93.53% line (16129/17244), 86.77% branch (5406/6230), 210 files. Change: none attributable to the branch. Disposition: PASS against the 85% line and 75% branch thresholds. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/python-coverage.2026-10-02T05-34.md`, `evidence/qa-gates/python-coverage-totals.2026-10-02T05-31.md`, `evidence/qa-gates/python-coverage-lcov-check.2026-10-02T05-32.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Whole-array `Should -Be` comparisons and `-Because` text. |
| **Arrange-Act-Assert Pattern** | PASS | Every new and edited test carries the three labelled sections. |
| **Document Intent** | PASS | Describe blocks cite issue #527. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, process, or real Pester invocation in the new tests. |
| **Use Mocks/Stubs** | PASS | Injected seams plus `InModuleScope PoshQC` filesystem mocks for the route-level tests. |
| **Environment Stability** | PASS | Pass-1 grep for `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `env:TEMP`, `env:TMP` over the five new or edited test files returned no match; the files are unchanged since. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This artifact is the pass-2 policy review. Outstanding non-blocking items are listed in Section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `spec.md`; `remediation-inputs.2026-10-02T05-08.md` for the cycle. |
| **Read existing change plans** | PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-10-02T05-25.md`. |
| **Document the plan** | PASS | `remediation-plan.2026-10-02T05-08.md` (three preflight rounds under `evidence/other/remediation-preflight-round-*.md`); every task checked off. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Unchanged since pass 1. |
| **Reusability** | PASS | Unchanged since pass 1. |
| **Extensibility** | PASS | Unchanged since pass 1. |
| **Separation of concerns** | PASS | Unchanged since pass 1. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Unchanged since pass 1. |
| **Under 500 lines** | PASS | Unchanged: `PoshQC.Coverage.psm1` 314, `PoshQC.Testing.psm1` 460, new tests 405 and 253; `PoshQC.Comprehensive.Tests.ps1` pre-existing 766 with a line-neutral edit. |
| **Public vs internal** | PASS | Manifest unchanged. |
| **No circular dependencies** | PASS | Unchanged since pass 1. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Approved verbs; `PoshQC` prefix. |
| **Docs/docstrings** | PASS | Comment-based help on all four functions. |
| **Comment why, not what** | PASS | Unchanged since pass 1. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | CI `Format PowerShell` success (run A, run B); reviewer `poetry run black --check` at `e5d9b58f`: 1 file unchanged. |
| **2. Linting** | PASS | CI `Analyze PowerShell` no findings; reviewer `poetry run ruff check`: all checks passed. |
| **3. Type checking** | PASS | Reviewer `poetry run pyright`: 0 errors; PowerShell has no type-check stage. |
| **4. Testing** | PASS | CI 6529 tests, 0 failures; cycle 1 full Python suite 6377 passed, 6 skipped, 0 failed (two runs); reviewer parity pytest 1 passed. |
| **Full toolchain loop** | PASS | No code changed in the cycle, so the pass-1 loop result stands; plan D12 records no architecture, contract, or integration tooling for PoshQC. |
| **Explicit reporting** | PASS | Commands recorded in `evidence/qa-gates/python-coverage-*.md` and Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commits `47e65f51`, `e5d9b58f`; Section 9. |
| **Design choices explained** | PASS | Plan D1-D14; spec Proposed Fix. |
| **Update supporting documents** | PASS | Unchanged since pass 1. |
| **Provide next steps** | PASS | Section 8 and `remediation-inputs.2026-10-02T05-08.md` non-blocking list. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check tests/scripts/dev_tools/test_poshqc_bundled_parity.py` -> 1 file would be left unchanged (EXIT 0). |
| **Linting with Ruff** | PASS | `poetry run ruff check <file>` -> All checks passed (EXIT 0). |
| **Type checking with Pyright** | PASS | `poetry run pyright <file>` -> 0 errors, 0 warnings, 0 informations (EXIT 0). |
| **Testing with Pytest** | PASS | Reviewer: parity test 1 passed (EXIT 0). Cycle 1: full suite 6377 passed, 6 skipped. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | One string literal added to an existing tuple constant. |
| **Dataclasses / Protocols / utility classes** | PASS | No structural change. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions / logging / invariants** | PASS | No change to error handling. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | CI run A and run B `Format PowerShell` success. |
| **Linting with PSScriptAnalyzer** | PASS | CI `PSScriptAnalyzer passed: no findings`. |
| **Fix all findings** | PASS | No findings reported. |
| **PowerShell 7+ compatible** | PASS | CI on `windows-latest` pwsh. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `[CmdletBinding()]` and `[OutputType()]` on all four functions. |
| **Parameter validation** | PASS | No `Mandatory` by design (plan D1); explicit validation in the config reader. |
| **Avoid global state** | PASS | Reads only module-scope constants. |
| **Error handling** | PASS | `$ErrorActionPreference = 'Stop'`; config errors throw naming the file. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | See 2.3. |
| **Approved verbs** | PASS | `Get-` and `Resolve-`. |
| **Comment why** | PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | CI run A and run B. |
| **Step 2: Analyze** | PASS | CI run A and run B. |
| **Step 3: Type check** | PASS | No type-check stage exists for this language; skipped by rule. |
| **Step 4: Test** | PASS | CI run A and run B: 6519 passed, 0 failed, 10 skipped. |
| **Rerun loop if needed** | PASS | No PowerShell file changed after the final CI runs (`git diff --name-only a987ebfb e5d9b58f` lists feature-folder files only). |

### Section 3D: JSON Configuration

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON / content** | PASS | `config/poshqc-coverage.json` unchanged since pass 1 (version 1, five roots, LF). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Existing parity test extended. |
| **Coverage expectation** | PASS | 93.53% line, 86.77% branch from `artifacts/python/lcov.info`; closes PA-B1. |
| **Organization / naming** | PASS | Existing module under `tests/scripts/dev_tools/`. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `BeforeAll`, `BeforeEach`, `-ForEach`, `InModuleScope`, `Mock`. |
| **Use PoshQC Configuration** | PASS | CI `Invoke-PoshQCTest -Root <workspace>` with the branch runsettings. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 13 and 17 cases in the two new files. |
| **Test Behavior Over Implementation** | PASS | Route tests assert the population handed to Pester. |
| **Mocking Used Sparingly** | PASS | Cmdlet mocks limited to the filesystem boundary. |
| **Organization** | PASS | Tests mirror `scripts/powershell/PoshQC/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | PASS | `*.Tests.ps1`. |
| **Describe/It Structure** | PASS | Four `Describe` blocks. |
| **Logical Grouping** | PASS | Grouped by function under test. |
| **Docstrings/Comments** | PASS | Header comments per `Describe`. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | CI `Invoke-PoshQCTest`. |
| **No Alternative Test Runners** | PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### PoshQC.Coverage.psm1 (30 test cases across two files; unchanged since pass 1)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| measures an identical population for the repository and bundled settings copies | Positive (route independence) | Resolve, FileSet, ConfigRoot default seams | PASS |
| measures only the consumer production file when a stale bundled allow-list names pushed-down files | Positive (#623) | fallback path | PASS |
| logs the population source and file count before Pester runs | Positive (observability) | Testing.psm1 353-357 | PASS |
| resolves a relative Root to an absolute path | Edge | Testing.psm1 300-303 | PASS |
| disables coverage, logs once, and still runs Pester when the population is empty | Error handling (#409) | Testing.psm1 361-363 | PASS |
| hands the scan-configuration folders to the coverage resolver | Positive | seam arguments | PASS |
| Get-PoshQCCoverageFileSet cases (7) | Edge / Error handling | 154-210 | PASS |
| Get-PoshQCCoverageConfigRoot cases (10) | Positive / Negative | 62-129 | PASS |
| Resolve-PoshQCCoveragePopulation cases (7) | Positive / Edge | 246-314 | PASS |

**Coverage:** 95.41% of `PoshQC.Coverage.psm1` (104/109).

**Not covered:** lines 75, 96, 163, 256, 257 (see code review Minor finding on boundary branches).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests, PowerShell | 6529 (CI run A) | PASS |
| Tests Passed, PowerShell | 6519 (99.85%) | PASS |
| Tests Failed, PowerShell | 0 | PASS |
| Skipped / disabled, PowerShell | 10 | PASS |
| Total Tests, Python full suite | 6383 (6377 passed, 6 skipped) | PASS |
| Execution Time | 346.6 s PowerShell; 69.64 s and 81.06 s Python | PASS |
| New tests | 30 | PASS |
| Line Coverage, PowerShell | 84.67% repo-wide; 95.41% new file | FAIL repo-wide, PASS new code |
| Line and branch, Python | 93.53% line; 86.77% branch | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <file>` | unchanged | PASS |
| Ruff Linting | `poetry run ruff check <file>` | all checks passed | PASS |
| Pyright Type Checking | `poetry run pyright <file>` | 0 errors | PASS |
| Pytest Tests | `poetry run pytest <file>` | 1 passed | PASS |
| Pytest full suite with branch measurement | `poetry run pytest --cov --cov-branch --cov-report=lcov:artifacts/python/lcov.info` | 6377 passed, 6 skipped | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | CI `Invoke-PoshQCFormat -Root <workspace>` | step success, run A and run B | PASS |
| PSScriptAnalyzer | CI `Invoke-PoshQCAnalyze -Root <workspace>` | no findings | PASS |
| Pester Tests | CI `Invoke-PoshQCTest -Root <workspace>` | 6519 passed, 0 failed | PASS |

**Notes:** No CI run exists for `e5d9b58f` or `70ab599d`; the latest branch runs are on `a987ebfb` (runs 36983551836 and 36984586891, both success). The code tree is identical, so the results carry forward.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-B1 (pass 1, Blocking): CLOSED.** `artifacts/python/lcov.info` exists; the reviewer reduced it to 16129/17244 lines (93.53%) and 5406/6230 branches (86.77%), matching `evidence/qa-gates/python-coverage.2026-10-02T05-34.md`. No production Python file changed on the branch.
- **PA-N1 (Non-blocking, operator-accepted 2026-09-30): PowerShell repo-wide line threshold FAIL, 84.67% < 85%.** The follow-up issue is not yet filed; it must be filed before or with the PR per spec Rollout & Follow-up.
- **PA-N2 (Non-blocking, operator-accepted): modified file `scripts/powershell/PoshQC/PoshQC.psm1` FAIL, 66.67% < 85%.** Newly measured; include it in the follow-up issue.
- **PA-N3 (Non-blocking, operator decision 2026-10-01): AC-01, AC-11, AC-12, AC-13 await operator-run `pwsh` commands.** The PR must state "Partially addresses #527".
- **PA-N4 (Non-blocking, carried): evidence timestamp provenance in the original execution evidence** (UTC timestamps; two postdate their commit).
- **PA-N5 (Non-blocking, new): cycle 1 evidence timestamps do not follow the clock.** Commit `47e65f51` (2026-10-02 05:30:31 -0400) introduced `python-changed-files.2026-10-02T05-33.md`, `python-coverage.2026-10-02T05-34.md`, `remediation-preflight-round-2.2026-10-02T05-40.md`, and `remediation-preflight-round-3.2026-10-02T06-05.md`; each timestamp is later than the commit time, and the reviewer's clock read 05:31 when this pass started. The numeric content was re-derived from the lcov file and matched, so the defect is provenance only. Use clock-read local timestamps in future evidence.

### Approved Exceptions

- Operator decision 2026-09-30: repo-wide PowerShell aggregate recorded as a follow-up item; new-code and changed-line figures are the gate for this change.
- Operator decision 2026-10-01 (Option A): no local `pwsh`; CI artifacts substitute for self-hosted runs.

### Removed/Skipped Tests

**None.**

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
11. `7efd9d8f` - feature-review pass 1 artifacts and remediation inputs
12. `47e65f51` - Python coverage evidence for PA-B1 (remediation cycle 1)
13. `e5d9b58f` - remediation plan Phase 2 check-offs

### Files Modified

Unchanged from pass 1 for code; cycle 1 added feature-folder documentation and evidence only.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT WITH RECORDED EXCEPTIONS

No blocking policy gap remains. PowerShell repo-wide and `PoshQC.psm1` FAIL verdicts are recorded and are non-blocking under the recorded operator decision. Python coverage passes both thresholds.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS all subsections

#### Language-Specific Code Change Policy (Section 3)
- Python: PASS tooling, design, error handling
- PowerShell: PASS tooling, design and safety, structure and naming, toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles, Test Structure, External Dependencies, Policy Audit
- FAIL (non-blocking, operator-accepted) Coverage & Scenarios for PowerShell repo-wide 84.67% and `PoshQC.psm1` 66.67%; PASS for Python

#### Language-Specific Unit Test Policy (Section 4)
- Python: PASS
- PowerShell: PASS

### Metrics Summary

- PASS 6519/6529 PowerShell tests passing, 0 failed
- PASS 6377 Python tests passing, 0 failed
- PASS PowerShell new-code line figure 95.41%; changed lines 100.00%
- FAIL PowerShell repo-wide line figure 84.67% (non-blocking)
- PASS Python 93.53% line, 86.77% branch
- PASS mirror parity (five pairs byte-identical at `e5d9b58f`)
- PASS evidence locations

### Recommendation

**Ready for PR with recorded exceptions.** File the PowerShell follow-up issue (PA-N1, PA-N2) before or with the PR and keep the PR wording "Partially addresses #527" while AC-01 and AC-11 to AC-13 await the operator-run commands.

---

## Appendix A: Test Inventory

Unchanged from `policy-audit.2026-10-02T05-08.md` Appendix A (30 new PowerShell cases, two edited PowerShell suites, one edited Python parity test).

---

## Appendix B: Toolchain Commands Reference

Reviewer-run commands at `e5d9b58f` (worktree root):

```bash
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main    # EXIT 0, head e5d9b58f, 2026-10-02 09:33:08 UTC
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .       # EXIT 0
poetry run black --check tests/scripts/dev_tools/test_poshqc_bundled_parity.py    # EXIT 0
poetry run ruff check tests/scripts/dev_tools/test_poshqc_bundled_parity.py       # EXIT 0
poetry run pyright tests/scripts/dev_tools/test_poshqc_bundled_parity.py          # EXIT 0
poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q -p no:cacheprovider --no-cov   # 1 passed
git diff --stat 70ab599d e5d9b58f
git diff --name-only 70ab599d e5d9b58f -- scripts extensions tests config .gitignore   # no output
sha256sum scripts/powershell/PoshQC/<file> extensions/drm-copilot/resources/powershell/PoshQC/<file>   # five pairs equal
awk -F: '/^SF:/{n++} /^LF:/{lf+=$2} /^LH:/{lh+=$2} /^BRF:/{bf+=$2} /^BRH:/{bh+=$2} ...' artifacts/python/lcov.info
grep -c 'SF:.*tests/' artifacts/python/lcov.info                                    # 0
gh run list --branch bug/poshqc-coverage-denominator-not-reproducible-527 --limit 5
```

Independent lcov reduction: `SF` 210, `LF` 17244, `LH` 16129 (93.53%), `BRF` 6230, `BRH` 5406 (86.77%), `BRDA` records 6230 of which 5406 have a positive hit count.

PowerShell toolchain of record (CI `_poshqc.yml`, branch PoshQC copy), unchanged:

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-02
**Policy Version:** Current (as of audit date)

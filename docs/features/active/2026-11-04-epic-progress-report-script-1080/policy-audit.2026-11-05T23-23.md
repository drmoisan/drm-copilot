# Policy Compliance Audit: Get-EpicProgressReport (Issue #1080)

**Audit Date:** 2026-11-05
**Branch:** `feature/epic-progress-report-script` @ `52224c60c5c6f5c8528e78b289887841c13b3110`
**Base:** `main`; merge base `02fb8aada3b10aaf3ac6812e29400c2302a3b372` (equal to the origin/main tip after `git fetch`; origin/main was merged into the branch at `a67ae96d7`)
**Work Mode:** minor-audit (AC source: `issue.md` `## Acceptance Criteria`)
**Code Under Test:**
- `scripts/dev-tools/Get-EpicProgressReport.ps1` (NEW, 456 logical lines)
- `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (NEW, 653 logical lines)
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (NEW, 426 logical lines)
- `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` (NEW, 560 logical lines)
- Documentation and evidence only: 29 files under `docs/features/active/2026-11-04-epic-progress-report-script-1080/` and `docs/features/potential/promoted/2026-11-04-epic-progress-report-script.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 production, 2 test | 89 new; 14387 tree-wide | 89 pass, 0 fail (reviewer); 14387 run, 0 fail (executor P2-T9) | 93.80% lines repo-wide (derived; both new files absent at baseline) | 93.84% lines repo-wide; 90.82% and 100% lines per new file | 90.82% (Get-EpicProgressReport.ps1), 100% (Get-EpicProgressReport.Logic.ps1) |
| Python | 0 files | N/A | N/A | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

Branch coverage: PowerShell is exempt from the branch threshold (Pester emits no branch counter; `.claude/rules/powershell.md`). No branch-capable language has changed files.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files in the branch diff
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files in the branch diff
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-04-epic-progress-report-script-1080/evidence/baseline/coverage-baseline.2026-11-04T20-39.md` (both new files COVERAGE-ABSENT, as expected for files that did not exist)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (merged Invoke-PoshQCParallelTest run, P2-T9) plus `evidence/qa-gates/coverage-final.2026-11-04T20-56.md`, `evidence/qa-gates/coverage-delta.2026-11-04T20-57.md`, and a reviewer re-measurement at HEAD
- Per-language comparison summary: section 1.2.1 of this audit

---

## Executive Summary

The branch adds a read-only PowerShell 7 dev-tools script that prints the epic TL;DR block and hourly progress report, split into an I/O wiring file and a pure logic file, with two mirrored Pester 5 suites (89 tests). No existing production or test file is modified. No Python, TypeScript, C#, Bash, JSON, or configuration file is in the branch diff.

The reviewer independently re-ran format, analyze, and test at HEAD on the Windows host (PowerShell 7.6.9): formatter differences 0 and PSSA findings 0 on all four files; 89 of 89 tests passed; scoped JaCoCo coverage 90.82% (89/98) for `Get-EpicProgressReport.ps1` and 100% (210/210) for `Get-EpicProgressReport.Logic.ps1`. The standing merged artifact `artifacts/pester/powershell-coverage.xml` reports a repo-wide line figure of 93.84% (23154/24673) and a JUnit total of 14387 tests with 0 failures.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`scripts/dev-tools` is classified T4 in `quality-tiers.yml`)

**Language-specific policies evaluated:**
- N/A Python (no changed files; confirmed no `.py` file added)
- ✅ `.claude/rules/powershell.md`
- N/A Bash, JSON, TypeScript, C#

**Temporary artifacts cleanup:**
- ✅ The executor's SCRATCH helper scripts live outside the repository; none is committed. `git status --porcelain` is empty at HEAD.
- ✅ Reviewer probe scripts were written to the session scratchpad only; the reviewer's mutation probe restored the logic file and `git status --porcelain` was confirmed empty afterwards.
- Deviation recorded: the executor's helper scripts were recreated as `sh` launchers invoking PowerShell 7 script files (the preimplementation hook blocked `.ps1` writes to the temp directory). See section 8 for the validity assessment.

---

## Rejected Scope Narrowing

None. The caller prompt did not attempt to narrow the audit scope. The audit covers the full diff `02fb8aada..52224c60c`.

---

## Evidence Location Compliance

- `validate_evidence_locations.py --root <worktree>` exit code: 0.
- The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (`git diff --name-only <merge-base> HEAD` filtered for `^artifacts/` returned no rows).
- All evidence is under `docs/features/active/2026-11-04-epic-progress-report-script-1080/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Mocks are registered in `BeforeEach` with per-test fixture state reset (`$script:gitCalls`, `$script:stateWrites`, and others). Executor evidence shows seeded shuffles (`isolation-shuffle.2026-11-04T21-00.md`), a fresh single-process run over `tests/scripts` (14387 tests, 0 failed), and an 8-worker shard run (0 failed). |
| **Isolation** | ✅ PASS | Logic suite has one `Describe` per function; each `It` asserts one behavior. |
| **Fast Execution** | ✅ PASS | Reviewer run: 89 tests in 3.21 s. No sleeps or waits. |
| **Determinism** | ✅ PASS | Clock is mocked through `Get-EpicProgressUtcNow`; fixtures are in memory; no test reads the wall clock (line 302 of the main script is uncovered, which confirms the real clock seam is never invoked). |
| **Readability & Maintainability** | ✅ PASS | Behavior-stating `It` names; whole-array expected output compared as joined strings. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/coverage-baseline.2026-11-04T20-39.md` (2026-11-04 20:39 UTC): both files COVERAGE-ABSENT because they did not exist. Repo-wide baseline derived as 22855/24365 = 93.80% by removing the two new files' counters from the post-change root counter (assumption: the root denominator differs only by the two added files, since the branch modifies no other production file). |
| **No Coverage Regression** | ✅ PASS | Post-change repo-wide 93.84% vs derived 93.80% (+0.04%). No modified production file exists, so no changed-line regression is possible. |
| **New Code Coverage** | ✅ PASS | 90.82% and 100% line coverage, both at or above the 85% governing threshold (root `CLAUDE.md` states no threshold, so the 85% default governs). |
| **Comprehensive Coverage** | ✅ PASS | All 22 logic functions are tested. The 9 uncovered lines of the main script are the three executable wrappers (201, 215, 229), the clock seam (302), and the entry-point block (448-454); these are the intended untestable seams. |
| **Positive Flows** | ✅ PASS | Parsing, counting, phase, velocity, range, formatting, Full and TLDR composition tests. |
| **Negative Flows** | ✅ PASS | Unparseable gh, cswap, PR list, quota, and state input; absent epic issue throws. |
| **Edge Cases** | ✅ PASS | Two- and five-digit issue numbers, 89 vs 90 s sample spacing, 0.5 velocity threshold, minute rounding at 119.7 min, NaN and infinity. One boundary is not pinned (2-minute interval threshold; see Gaps). |
| **Error Handling** | ✅ PASS | `throws when no epic issue can be resolved`; absent gh and cswap degrade without a terminating error. |
| **Concurrency** | N/A | Single-threaded command-line tool. |
| **State Transitions** | ✅ PASS | Feature-state classification and sample retention (add, skip, drop, cap). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.80% lines (repo-wide, derived; new files absent at baseline) -> Post-change: 93.84% lines. Change: +0.04% lines. New/changed-code coverage: 90.82% (Get-EpicProgressReport.ps1), 100% (Get-EpicProgressReport.Logic.ps1). Disposition: PASS. Evidence: `evidence/baseline/coverage-baseline.2026-11-04T20-39.md`, `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/coverage-delta.2026-11-04T20-57.md`, reviewer scoped re-measurement at HEAD.
- Python: N/A - zero changed Python files in the branch diff. Disposition: N/A.
- TypeScript: N/A - zero changed TypeScript files in the branch diff. Disposition: N/A.
- C#: N/A - zero changed C# files in the branch diff. Disposition: N/A.

Freshness of the post-change artifact: `artifacts/pester/powershell-coverage.xml` was written at 2026-11-05 23:13 UTC by the P2-T9 run, before commit `52224c60c` (23:18 UTC). That commit adds only five comment-help lines (`.NOTES`) to the main script. The artifact's missed line numbers (196, 210, 224, 297, 443-449) are exactly five lower than the reviewer's HEAD measurement (201, 215, 229, 302, 448-454), and covered/missed counts are identical (89/9 and 210/0), so the artifact describes the same executable code as HEAD.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `Should -Be` on full expected strings; constraint tests use `-Because` naming the offending path and token. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Fixtures in `BeforeAll`/`BeforeEach`, one call, then assertions, separated by blank lines. |
| **Document Intent** | ✅ PASS | File header comments state the no-I/O contract; `It` names state the behavior. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No test starts git, gh, or cswap or calls the network. The seam tests read the script file itself (a repository file, not a temporary file) and call `Get-Help` on it. |
| **Use Mocks/Stubs** | ✅ PASS | Eight seams mocked with production parameter names: `Invoke-GitExe` (`GitArgs`), `Invoke-GhExe` (`GhArgs`), `Invoke-CswapExe` (`CswapArgs`), `Test-EpicProgressCommand` (`Name`), `Test-EpicProgressPath` (`Path`), `Read-EpicProgressFile` (`Path`), `Write-EpicProgressState` (`Path`, `Content`), `Get-EpicProgressUtcNow`. |
| **Environment Stability** | ✅ PASS | No TestDrive or temporary files; the state-write seam test runs under `-WhatIf` and asserts the target is absent. No global state. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit plus the executor self-review `evidence/qa-gates/self-review.2026-11-05T23-17.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` AC1-AC9. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-04T14-56.md`, all tasks checked. |
| **Document the plan** | ✅ PASS | Plan file and per-task commits (P0-T1 through P2-T13). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Plain functions; no framework or runner abstraction. |
| **Reusability** | ✅ PASS | Shared formatters and summary record feed both TLDR and Full output. |
| **Extensibility** | ✅ PASS | Every former hardcoded value is a parameter with a documented default. |
| **Separation of concerns** | ✅ PASS | Pure logic file performs no I/O; all I/O is in the main script behind seams, enforced by AST constraint tests. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Two production files split by concern (AC1 permits up to three). |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts (`@(Get-Content).Count`): 456, 653, 426, 560. None at or above 700, so no Warning. `config/file-size-baseline.json` is unchanged and has no entry for these files. |
| **Public vs internal** | ✅ PASS | Public surface is the script parameter set. |
| **No circular dependencies** | ✅ PASS | Main script dot-sources the logic file; the logic file imports nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `EpicProgress` noun prefix with approved verbs. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on the script (13 parameters, 2 examples, `.NOTES`) and on every function. |
| **Comment why, not what** | ✅ PASS | Entry-point and location-push rationale comments. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Reviewer: `Invoke-Formatter -Settings pssa.settings.psd1` comparison on 4 files: 0 differences. |
| **2. Linting** | ✅ PASS | Reviewer: `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` on 4 files: 0 findings. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | Reviewer: 89/89 passed. Executor P2-T8/P2-T9: 14387 tests tree-wide, 0 failed. |
| **Architecture boundary / contract / integration** | N/A | No architecture-boundary, contract, or integration suite applies to a dev-tools script; the AST constraint tests serve as the I/O-boundary check. |
| **Full toolchain loop** | ✅ PASS | Clean in a single pass at HEAD. |
| **Explicit reporting** | ✅ PASS | Evidence artifacts under the feature `evidence/` tree. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Per-task commit messages. |
| **Design choices explained** | ✅ PASS | Plan design section. |
| **Update supporting documents** | ✅ PASS | Comment-based help is the usage documentation (AC9); no `.md` exists under `scripts/dev-tools/`. |
| **Provide next steps** | ✅ PASS | PR authoring and CI on the PR head. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | 0 differences (reviewer and executor `format.2026-11-04T20-53.md`). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings (reviewer and executor `pssa.2026-11-04T20-54.md`). |
| **Fix all findings** | ✅ PASS | No open findings. |
| **PowerShell 7+ compatible** | ✅ PASS | Repository target is PowerShell 7+; tests ran on 7.6.9 on Windows and earlier on the Linux Codespace. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` on every function. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `ValidateNotNullOrEmpty`, `ValidateRange`, `ValidateSet`, `AllowEmptyString`. |
| **ShouldProcess for state change** | ✅ PASS | `Write-EpicProgressState` declares `SupportsShouldProcess` and guards `Set-Content`. Checked by hand because PSSA does not flag the `Write` verb. |
| **Wrapper seams** | ✅ PASS | `Invoke-GitExe -GitArgs`, `Invoke-GhExe -GhArgs`, `Invoke-CswapExe -CswapArgs`, each a single `[string[]]` parameter splatted into the executable. |
| **Avoid global state** | ✅ PASS | No global or script-scope mutable state in production files. |
| **Error handling** | ✅ PASS | `throw` for an unresolved epic issue; JSON is validated before conversion; no empty catch. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 456 and 653 logical lines. |
| **Approved verbs** | ✅ PASS | ConvertFrom, Format, Get, Invoke, Read, Resolve, Select, Test, Write. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 differences. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 89/89 (scoped), 14387/0 failed (tree, executor). |
| **Rerun loop if needed** | ✅ PASS | No rerun needed at HEAD. |

Change budget: 2 production PowerShell files, within the direct-mode budget of 3.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, `BeforeEach`, `Describe`/`Context`/`It`, `Should -Invoke`. |
| **Use PoshQC Configuration** | ✅ PASS | Executor coverage via `Invoke-PoshQCTest` and `Invoke-PoshQCParallelTest` from the worktree module; `config/poshqc-coverage.json` lists root `scripts`, so the new files are in the coverage denominator without a config edit. |
| **PowerShell 7+ Compatible** | ✅ PASS | See 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 60 logic tests, 29 script tests. |
| **Test Behavior Over Implementation** | ✅ PASS | Output lines and seam arguments asserted. Reviewer mutation probe: 6 of 7 targeted mutants killed (see Gaps for the survivor). |
| **Mocking Used Sparingly** | ✅ PASS | Only I/O seams mocked; executables never mocked directly. |
| **Organization** | ✅ PASS | Test files `tests/scripts/dev-tools/Get-EpicProgressReport{,.Logic}.Tests.ps1` mirror code files `scripts/dev-tools/Get-EpicProgressReport{,.Logic}.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | ✅ PASS | `*.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Logic: 16 `Describe`, 1 `Context`; script: 4 `Describe`. |
| **Logical Grouping** | ✅ PASS | One `Describe` per function or concern. |
| **Docstrings/Comments** | ✅ PASS | Header comments and fixture comments explain derivations (for example the range arithmetic). |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | Executor P2-T4 and P2-T9. Reviewer used `Invoke-Pester` with a scoped configuration and output outside the repository so the canonical artifact was not overwritten. |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### Get-EpicProgressReport.Logic.ps1 (60 tests)

**Coverage:** 100% (210 of 210 lines). Every function has a dedicated `Describe`: kickoff row parsing, issue-from-kickoff, worktree map, PR list, weekly quota, task count, current phase, feature state, the three formatters, sample selection, average velocity, recent intervals, standard deviation, critical path, range text, and summary/TLDR/Full composition (including the `non-finite values print n/a` context).

**Not covered:** None.

### Get-EpicProgressReport.ps1 (29 tests)

**Coverage:** 90.82% (89 of 98 lines).

- Lines 201, 215, 229: not covered (executable wrappers; tests must not start git, gh, or cswap).
- Line 302: not covered (real UTC clock seam; tests must not read the wall clock).
- Lines 448-454: not covered (entry-point block, skipped when dot-sourced).
- Line 290: partly covered (`ShouldProcess` evaluated under `-WhatIf`; `Set-Content` not executed).

**Not covered:** the seams above, by design.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (new suites) | 89 | ✅ |
| Tests Passed | 89 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 3.21 s total | ✅ Fast |
| Average Time per Test | about 36 ms | ✅ Fast |
| Tree-wide run (executor P2-T8/P2-T9) | 14387 tests, 0 failed, 10 skipped | ✅ |
| Functions Tested | 22 of 22 logic functions; all main-script functions except the four untestable seams and the entry point | ✅ |
| Test File Size | 426 and 560 logical lines | ✅ PASS |
| Code Coverage | 90.82% and 100% lines (branch: not measured by Pester) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | Formatter comparison with `pssa.settings.psd1` on the 4 files | 0 differences | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` on the 4 files | 0 findings | ✅ |
| Pester Tests | Scoped `Invoke-Pester` with JaCoCo coverage | 89 passed, 0 failed | ✅ |

**Notes:** No pre-existing failures were observed. CI has not yet run on this head because no PR exists; no acceptance criterion depends on CI.

---

## 8. Gaps and Exceptions

### Identified Gaps

All gaps are non-blocking.

- Recent-velocity 2-minute boundary not pinned: changing `$hours -ge (2 / 60)` to `-gt` in `Get-EpicProgressRecentVelocityInterval` survived the full suite (reviewer mutation probe). AC4 asks for tests on fixed inputs, which exist (a 60-second pair is skipped); the exact boundary is not asserted. Recommended: add a 120-second pair fixture.
- Evidence reproducibility: executor evidence names `sh SCRATCH/issue-1080-*.sh` launchers that are not in the repository. The deviation (sh launchers instead of the plan's `.ps1` helper names, caused by the preimplementation hook) does not invalidate the evidence: the launchers only invoked PowerShell 7 script files, and the reviewer reproduced the format, analyze, test, and per-file coverage results independently at HEAD with identical figures (89/98 and 210/210 lines; 89 tests).

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests are implemented; the two new suites have no skipped tests.

---

## 9. Summary of Changes

### Commits in This PR/Branch

33 non-merge commits from `749691a1c` (feature folder) to `52224c60c` (`.NOTES` help), plus merge `a67ae96d7` of origin/main. Code commits: `c6dfc5802`, `f84967243`, `1ea009bc3`, `f8345ffd4`, `c61218ea0`, `78eea761a`, `2d00aafbc`, `ae5275be4`, `52224c60c`. All others are documentation and evidence.

### Files Modified

1. **scripts/dev-tools/Get-EpicProgressReport.ps1** (NEW) - parameters, comment-based help, settings resolution, I/O seams, report wiring, guarded entry point.
2. **scripts/dev-tools/Get-EpicProgressReport.Logic.ps1** (NEW) - pure parsing, counting, velocity, estimate, sample-retention, formatting, and line composition.
3. **tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1** (NEW) - settings, seams, mocked end-to-end report, AC8 argument assertions, AST constraint and help tests.
4. **tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1** (NEW) - unit tests for every logic function.
5. Feature folder documentation and evidence (NEW), and the promoted lifecycle record (NEW).

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All required artifacts exist: baseline coverage evidence, post-change coverage artifact, per-language comparison, toolchain results, and isolation runs. Coverage is numeric for the only in-scope language. Tier classification: `scripts/dev-tools` is T4, so no property-test, mutation, or golden-test obligation applies.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and AC present
- ✅ Design Principles: pure logic separated from I/O
- ✅ Module & File Structure: 456 and 653 lines
- ✅ Naming, Docs, Comments: full comment-based help
- ✅ Toolchain Execution: clean single pass
- ✅ Summarize & Document: per-task commits

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: 0 format differences, 0 findings
- ✅ PowerShell Design & Safety: ShouldProcess, wrapper seams
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent and deterministic
- ✅ Coverage & Scenarios: 90.82% and 100%; one unpinned boundary (non-blocking)
- ✅ Test Structure: AAA
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5
- ✅ Test Style & Structure: mirrored layout
- ✅ Naming & Readability: descriptive names
- ✅ Toolchain: PoshQC routes

### Metrics Summary

- ✅ 89/89 new tests passing (100%); 14387 tree-wide, 0 failed
- ✅ 22/22 logic functions tested
- ✅ 90.82% and 100% line coverage on new files; 93.84% repo-wide
- ✅ Proper file organization: tests mirror `scripts/dev-tools`
- ✅ All code quality checks passing
- ✅ Test execution time: 3.21 seconds (fast)

### Recommendation

**Ready for merge** after the normal PR flow and CI on the PR head. The two gaps in section 8 are non-blocking.

---

## Appendix A: Test Inventory

### Get-EpicProgressReport.Logic.Tests.ps1 (60 tests)

- ConvertFrom-EpicProgressKickoffRow (4): two-digit row, five-digit row, header/separator ignored, empty kickoff
- Get-EpicProgressIssueFromKickoff (2): mid-line marker, no marker
- ConvertFrom-EpicProgressWorktreeList (1): branch-to-path map, detached omitted
- ConvertFrom-EpicProgressPrList (5): first PR, empty list, unparseable, blank, entry without number
- Get-EpicProgressWeeklyQuota (5): active account, none active, unparseable, no accounts, no seven-day pct
- Get-EpicProgressTaskCount (2): checked and unchecked, non-task checkboxes ignored
- Get-EpicProgressCurrentPhase (3): heading, Phase N fallback, all checked
- Get-EpicProgressFeatureState (4): merged/worktree_removed, MERGED PR, Running, Pending
- Formatters (6): H h MM, HH:MM, no 60 minutes, NaN, infinity, invariant rounding
- Select-EpicProgressSample (5): first sample, 90 s add, 89 s skip, drop without ts, cap
- Get-EpicProgressAverageVelocity (2), Get-EpicProgressRecentVelocityInterval (2), Get-EpicProgressStandardDeviation (2), Get-EpicProgressCriticalPath (2), Get-EpicProgressRangeText (3)
- Summary, TLDR, and Full composition (6) plus Context `non-finite values print n/a` (6)

### Get-EpicProgressReport.Tests.ps1 (29 tests)

- Resolve-EpicProgressSetting (5): four defaults, explicit values kept
- I/O seams without side effects (4): absent command, absent path, file read, WhatIf write
- Invoke-EpicProgressReport (15): TLDR output, Full output, kickoff issue, explicit issue, unresolved issue throws, live worktree plan, cswap absent, cswap unparseable, gh absent, gh unparseable, unparseable state, git arguments, gh arguments, state path write, 90-second no-write
- Repository constraints (5): file writes confined, native commands confined, no recovered hardcoded value, every parameter documented, example present

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (reviewer, from the worktree root, outputs to the session scratchpad):**
```powershell
# Formatting check (no write)
Invoke-Formatter -ScriptDefinition (Get-Content -LiteralPath <file> -Raw) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing with scoped coverage
$cfg = New-PesterConfiguration
$cfg.Run.Path = @('tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1','tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1')
$cfg.CodeCoverage.Enabled = $true; $cfg.CodeCoverage.OutputFormat = 'JaCoCo'
$cfg.CodeCoverage.Path = @('scripts/dev-tools/Get-EpicProgressReport.ps1','scripts/dev-tools/Get-EpicProgressReport.Logic.ps1')
Invoke-Pester -Configuration $cfg
```

**Executor routes:** `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/dev-tools` (P2-T4) and `Invoke-PoshQCParallelTest` (P2-T9).

**Evidence-location scan:** `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` (exit 0).

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-05
**Policy Version:** Current (as of audit date)

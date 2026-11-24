# Policy Compliance Audit: targeted-test-cadence (#1228), re-audit after remediation cycle 2

---

**Audit Date:** 2026-11-24  
**Code Under Test:** merge base `23458fade99f40e81b95ce86ed90805258479782` of the base branch `origin/main` (equal to the current `origin/main` tip) and reviewed head `c8a4d99cf3f41b02170caeaf0da398764370c638` (branch `feature/targeted-test-cadence-1228`, equal to the remote branch head); the diff between them lists 290 changed files (+13265/-379). The remediation commit `c8a4d99cf` changes 47 of them; merge commit `c28dfe1a6` brought `origin/main` into the branch before it.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 6 production files (3 sources and 3 byte-identical copies) plus 6 bundle copies; 8 Pester test files | 29658 tests (reviewer full run at head); 3998 (remediation gate selection) | ✅ 0 fail in each run | 96.84% lines | 96.87% lines | 99.12% lines over added and changed executable lines of the five measured files (112 of 113) |
| Python | 0 files | 17104 tests (final QA full run) | ✅ 17104 pass, 0 fail | 98.01% lines, 95.47% branches | 98.01% lines, 95.47% branches | N/A - zero changed Python files |
| TypeScript | 0 files | jest-extension and root jest (final QA) | ✅ 0 fail | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

The remaining changed files are Markdown (rules, skills, agents, prompts, instructions, plan and audit templates, ledger, feature records), TOML (generated Codex agents and variants), and one stored patch. They have no coverage language.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files (executor baseline recorded at `.dev/active/1228-targeted-test-cadence/evidence/baseline/jest.2026-11-23T13-33.md`)
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files (executor final QA recorded at `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/jest.2026-11-24T06-58.md`)
- PowerShell baseline coverage artifact: `.dev/active/1228-targeted-test-cadence/evidence/baseline/pester.2026-11-23T13-26.md` (Phase 0 baseline, 96.84% lines); per-file pre-change figures for the cycle's changed files in `.dev/active/1228-targeted-test-cadence/evidence/remediation-baseline/pester-selection.2026-11-24T12-25.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, the reviewer full Pester run at head `c8a4d99cf` (root LINE counter 47763 covered, 1543 missed); the remediation gate's selection figures are in `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/remediation-gate.2026-11-24T15-14.md`
- Per-language comparison summary: section 1.2.1 of this audit

Baseline coverage is read from the plan's `Phase 0 baseline` artifact, one run of the language's gate.

**CI-proven checks:** Format, lint, and type-check results are read from the remediation-gate static artifacts of each language and are not re-run during the review, except the generator drift checks, which the reviewer re-ran. Each CI check the review relies on is recorded in `## CI Cross-check`.

---

## Executive Summary

This is the re-audit after remediation cycle 2. The branch rewrites the test-cadence policy text on every harness surface so that the full test suite runs only at the `Phase 0 baseline` and in the final QA loop. The previous review (`policy-audit.2026-11-24T10-50.md`) raised one blocking finding, F3: the feature-review coverage Stop hook graded a selection-run coverage report as the repo-wide figure.

Commit `c8a4d99cf` resolves F3 through spec decision D11:

- The test-execution launcher (`Invoke-TestSuite.ps1`, `.agents` source, generated `.claude` copy, two bundles) writes `artifacts/test-execution/run-scope.<suite>.json` after each suite run, with `scope` `selection` or `full` and the UTC start and end instants.
- `Get-FeatureReviewCoverageReportScope` (Claude freshness file and its Codex function-text twin) returns `selection` only for a valid selection record of the language's suite whose window contains the report's write time; every other case, including every C# report, returns `full`.
- The Claude coverage hook skips the repo-wide line and branch floors for a selection report, and the Codex hook skips its line floor; the verdict, narrowing, and freshness checks still apply.
- Spec D3, D11, Data and State, and Out of Scope, the brief and `test-execution-policy` skill (all copies), and ledger entry `0014` (Files Changed, stored patch, revert steps) are updated in the same commit.

Reviewer verification: the reader returns `full` for every malformed, mismatched, offset-bearing, unzoned, or non-covering record in 17 direct probes; a real-file probe over the remediation gate's own selection report and record resolves `selection`, where the old grading reads 14.46% and refuses a PASS row; the reviewer's full launcher run at head wrote a `full` record whose window contains the report write time; 29658 Pester tests passed with 0 failures; generators report no drift; every changed hook and launcher file is byte-identical to its bundle copy.

One new blocking finding, F4: `Write-TestSuiteRunScopeRecord` creates a folder and writes a file but does not implement `SupportsShouldProcess`, which the PowerShell coding standard requires for state-changing functions. The sibling writer `Write-TestExecutionHolderRecord` does implement it. The fix is contained to one function and its copies.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (zero changed Python files)
- ⚠️ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (changed hook, launcher, and Pester test files; F4)
- N/A Bash: shfmt + shellcheck + bats (zero changed shell files)
- N/A JSON: format_json + validate_json (zero changed JSON files)

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; the executor's helper scripts live in the session scratch folder.
- ✅ No new tooling script is added to the repository beyond the D11 functions inside existing files.
- Reviewer scratch files (launchers, probe scripts, report snapshots, a scratch item root for the real-file probe) are in the session scratchpad and are not in the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The new suites register Pester mocks per test and share no state; the reviewer full run sharded 875 suites across 8 parallel processes with 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | `RSCOPE-READ-*` rows test one record condition each; `RSCOPE-HOOK-*` rows test one grading outcome each; `RSCOPE-LAUNCH-*` rows test one launcher path each. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The four new or extended suites ran 145 tests within the 806.83 s full run without a slow-test outlier. |
| **Determinism** - Consistent results | ✅ PASS | Clock readings come from the launcher `Clock` seam and fixed instants; report times come from a mocked seam; fixture roots are synthetic `/`-rooted paths. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Each suite opens with a synopsis naming issue #1228 and spec D11 and the seams it mocks. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 96.84% lines (PowerShell), read from the `Phase 0 baseline` artifact<br>**Command:** `Invoke-PoshQCParallelTest` through the launcher `pester` suite (one run of the gate)<br>**Artifact:** `.dev/active/1228-targeted-test-cadence/evidence/baseline/pester.2026-11-23T13-26.md`<br>**Timestamp:** 2026-11-23 13:26 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.87% lines (PowerShell), reviewer full run at head<br>**Change:** +0.03% lines against the `Phase 0 baseline`<br>**Status:** No regression; every changed production file is at or above its pre-change figure |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** Claude coverage hook 100.00%, Claude freshness file 98.73%, Codex coverage hook 100.00%, Codex freshness file 98.73%, launcher 93.85%<br>**Thresholds:** 85% line (default; root `CLAUDE.md` states none); Pester measures no branches, so only the line threshold is graded for PowerShell<br>**Status:** Every changed production file is above 85% |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** five measured production files<br>**New code coverage:** added and changed executable lines 112 of 113 covered (99.12%), per `remediation-gate.2026-11-24T15-14.md`; reviewer full run gives the same per-file counters<br>**Calculation method:** `<sourcefile>` LINE counters of `powershell-coverage.xml` intersected with `git diff -U0` added lines |
| **Comprehensive Coverage** | ✅ PASS | Launcher selection rules per runner, record writing, refusal and timeout paths, write-failure line; reader validity checks; hook accept and reject cases in the session root and an item worktree; Codex twin rows; a launcher-to-hook contract row. |
| **Positive Flows** - Valid inputs | ✅ PASS | `RSCOPE-HOOK-SELECTION-ACCEPTED`, `RSCOPE-HOOK-ITEM-ROOT-ACCEPTED`, `RSCOPE-CONTRACT-LAUNCHER-RECORD`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `RSCOPE-HOOK-FULL-REJECTED`, `-NO-RECORD-REJECTED`, `-OUTSIDE-WINDOW-REJECTED`, `-STALE-SELECTION-REJECTED`, `-VERDICT-STILL-REQUIRED`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Window bounds are inclusive; the reviewer probe confirmed the exact end instant resolves `selection` and one tick later resolves `full`. |
| **Error Handling** - Error paths | ✅ PASS | A record write failure prints `TEST_EXECUTION_RUN_SCOPE_UNWRITTEN:` and leaves the exit code unchanged (`RSCOPE-LAUNCH-*`). |
| **Concurrency** - If applicable | ✅ PASS | The record is written after the machine lock is released; a racing record of the same suite can only produce a window that excludes the other run's report time, which resolves `full` (fail-safe direction). |
| **State Transitions** - If applicable | N/A | No stateful component beyond the overwritten record file. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.84% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.87% lines. Change: +0.03% lines. New/changed-code coverage: 99.12% lines (112 of 113 added and changed executable lines in the five measured files). Disposition: PASS. Evidence: `.dev/active/1228-targeted-test-cadence/evidence/baseline/pester.2026-11-23T13-26.md`, `.dev/active/1228-targeted-test-cadence/evidence/remediation-baseline/pester-selection.2026-11-24T12-25.md`, `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/remediation-gate.2026-11-24T15-14.md`, `artifacts/pester/powershell-coverage.xml` (reviewer full run at head).
- Python: Baseline: 98.01% lines, 95.47% branches -> Post-change: 98.01% lines, 95.47% branches. Change: +0.00% lines. New/changed-code coverage: N/A - zero changed Python files. Disposition: N/A. Evidence: `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/pytest.2026-11-24T06-43.md`.
- TypeScript: Baseline: N/A - zero changed TypeScript files -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A - zero changed TypeScript files. Disposition: N/A. Evidence: `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/jest.2026-11-24T06-58.md`.

Per-file PowerShell figures (reviewer full run at head, `<sourcefile>` LINE counters; pre-change figures from `pester-selection.2026-11-24T12-25.md`):

- `.claude/hooks/validate-feature-review-coverage.ps1`: 136 of 136 = 100.00% (pre-change 100.00%).
- `.claude/hooks/validate-feature-review-coverage-freshness.ps1`: 78 of 79 = 98.73% (pre-change 97.96%).
- `.codex/hooks/validate-feature-review-coverage.ps1`: 185 of 185 = 100.00% (pre-change 100.00%).
- `.codex/hooks/validate-feature-review-coverage-freshness.ps1`: 78 of 79 = 98.73% (pre-change 97.96%).
- `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`: 122 of 130 = 93.85% (pre-change 92.93%). The one uncovered changed line is the body of the default `WriteRunScope` seam; every test injects the seam. The `.agents` source and the bundle copies are byte-identical to this file and sit outside the configured coverage roots, as on the base branch.

Coverage source and freshness: the remediation gate's selection report (`powershell-coverage.xml` written 2026-11-24T14:59:22Z) predated the remediation commit `c8a4d99cf` (2026-11-24T15:21:35Z). The coverage Stop hook that governs this review runs the default branch's copy (brief `## Hook Execution Context`; remediation plan RD7), which does not yet read run-scope records and would grade a selection report as repo-wide. The reviewer therefore snapshotted the gate's `powershell-coverage.xml`, `pester-junit.xml`, and `run-scope.pester.json` (SHA-256 prefixes `892f35e45254`, `50df4a711f9f`, `bdb18283fdca`) and ran the full Pester suite at head through the launcher (`run-test-suite.sh pester`, no `-TestPath`): attempt 1 started 2026-11-24T15:26:04Z, exit 0, wall-clock 806.83 s, 29658 tests in 875 suites, 0 failures, 0 errors, 18 skipped; root LINE counter 47763 covered and 1543 missed = 96.87%. The report was written at 2026-11-24T15:39:32.592Z, after the commit, and is left in place. The launcher wrote `{"schema_version":1,"suite":"pester","runner":"pester","scope":"full","started_utc":"2026-11-24T15:26:05.2027549Z","completed_utc":"2026-11-24T15:39:32.6592405Z"}`, a real-process confirmation that a full run is recorded as `full` with a window that contains the report write time. This full run is permitted under the branch cadence as the review's repo-wide confirmation; it is not a phase-gate or remediation-gate run.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Hook rows assert on the hook's own reason text (for example the repo-wide FAIL reason) so a failure names the language and figure. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Each `It` builds an artifact table and report times, invokes the hook entry or reader, then asserts the result. |
| **Document Intent** | ✅ PASS | Row ids (`RSCOPE-READ-*`, `RSCOPE-HOOK-*`, `RSCOPE-LAUNCH-*`, `RSCOPE-CODEX-*`, `RSCOPE-DOC-*`) and titles state the expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Transcript, worktree list, and git output come from in-memory seams. |
| **Use Mocks/Stubs** | ✅ PASS | `Get-ArtifactFileContent` and `Get-FeatureReviewReportLastWriteUtc` are mocked over in-memory tables; the launcher's `StartSuiteProcess`, `Clock`, and `WriteRunScope` seams are injected. |
| **Environment Stability** | ✅ PASS | No test creates a file; fixture roots are synthetic `/`-rooted paths, so the Linux hook-suite job sees the same paths. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the required review; F3 is closed and F4 is open. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Owner objective quoted verbatim in `spec.md` and ledger entry `0014`. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-24T10-50.md` cites finding F3 and records decisions RD1 to RD7. |
| **Document the plan** | ✅ PASS | All remediation-plan tasks are checked with task-check, gate, and self-review evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One JSON record per suite, written by the one launcher every local suite uses; one reader function shared by both hooks. |
| **Reusability** | ✅ PASS | The reader lives in the freshness file that both hooks already dot-source; the Codex twin is held function-text identical by its test. |
| **Extensibility** | ✅ PASS | `schema_version` 1 allows a later record shape; the suite map is one switch. |
| **Separation of concerns** | ✅ PASS | The reader is pure (record text plus a write-time seam); file reads stay in the hook entry and the existing `Get-ArtifactFileContent` seam. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Record writing sits in the launcher; reading sits in the coverage freshness helper. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest changed covered files: `test-cadence-wording.Tests.ps1` 688, `Invoke-TestSuite.Tests.ps1` 548, `validate-feature-review-coverage.Coverage.Tests.ps1` (Codex) 471, Codex coverage hook 409, launcher 376 logical lines. None is at or above 700. `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | ✅ PASS | New functions are script-internal; no exported module surface changes. |
| **No circular dependencies** | ✅ PASS | The hooks dot-source the freshness file as before; the launcher loads its existing helpers only. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-TestSuiteRunScope`, `New-TestSuiteRunScopeRecord`, `Get-FeatureReviewCoverageReportScope`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on each new function states the fail-safe cases. |
| **Comment why, not what** | ✅ PASS | The hook comment states why a selection report skips the repo-wide floor. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root <worktree>`<br>**Result:** 1892 files, 0 reformatted; porcelain identical before and after (`remediation-gate.2026-11-24T15-14.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root <worktree>`<br>**Result:** 0 findings; leak scan 0 failures |
| **3. Type checking** | N/A | PowerShell has no type checker; Pyright 0 errors repo-wide in the remediation gate. |
| **4. Testing** | ✅ PASS | **Command:** remediation gate launcher `pester -TestPath` (47 files), `pytest` (9 files), `jest-extension` (1 file); reviewer full launcher `pester` run<br>**Result:** 3998, 229, 18, and 29658 tests, 0 failures |
| **Full toolchain loop** | ✅ PASS | One clean pass of stages 1 to 6 recorded in the remediation gate artifact (pass 2, after a transient analyzer error in pass 1). |
| **Explicit reporting** | ✅ PASS | Commands and exit codes are recorded in each evidence file. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Ledger `0014` `## Summary` gains the remediation cycle 2 sentence. |
| **Design choices explained** | ✅ PASS | `spec.md` D11 and remediation plan RD1 to RD7. |
| **Update supporting documents** | ⚠️ PARTIAL | Brief and `test-execution-policy` skill updated in all copies; `user-story.md` `## Non-Goals` still lists "Adding or changing hooks, validators, or configuration", which D11 now contradicts (non-blocking, see section 8). |
| **Provide next steps** | ✅ PASS | This audit names the F4 fix and the remaining CI step (S9). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .`<br>**Result:** 0 reformatted; porcelain identical before and after |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** 0 findings. The analyzer rule `PSUseShouldProcessForStateChangingFunctions` does not cover the `Write` verb, so a clean run does not show compliance with the ShouldProcess standard (F4). |
| **Fix all findings** | ✅ PASS | No analyzer findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Repository targets PowerShell 7+; `ConvertFrom-Json -AsHashtable -NoEnumerate` and `Set-Content -Encoding utf8NoBOM` are PowerShell 7 features, consistent with the hooks' `#Requires -Version 7`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Every new function carries `[CmdletBinding()]`, `[OutputType()]`, and named parameters. |
| **Parameter validation** | ✅ PASS | `Mandatory` parameters; `ValidateSet('selection', 'full')` on `New-TestSuiteRunScopeRecord -Scope`. |
| **ShouldProcess for state-changing actions** | ❌ FAIL | F4: `Write-TestSuiteRunScopeRecord` (`.agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` line 164, and its generated `.claude` copy and two bundles) runs `New-Item -ItemType Directory` and `Set-Content` with `[CmdletBinding()]` only. The sibling `Write-TestExecutionHolderRecord` in `.claude/hooks/test-execution-lock.ps1` uses `[CmdletBinding(SupportsShouldProcess)]` and `$PSCmdlet.ShouldProcess`. |
| **Avoid global state** | ✅ PASS | No script-scope state added; the reader holds none. |
| **Error handling** | ✅ PASS | A record write failure is caught and reported on stderr with a named prefix; the reader's JSON parse catch returns the fail-safe `full` by design (documented in its help). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | See 2.3. |
| **Approved verbs** | ✅ PASS | `Get`, `New`, `Write`. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Remediation-gate static stage. |
| **Step 2: Analyze** | ✅ PASS | Remediation-gate static stage. |
| **Step 3: Type check** | N/A | PowerShell has no type checker. |
| **Step 4: Test** | ✅ PASS | Remediation gate 3998 tests, 0 failures; reviewer full run 29658 tests, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | Pass 2 of the remediation gate restarted from step 1 after the pass-1 analyzer error. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`/`It -ForEach`, `Mock`, `Should -Be`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through the launcher<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, unchanged |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | New suites carry `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One outcome per row. |
| **Test Behavior Over Implementation** | ✅ PASS | Hook rows assert the accept or reject decision and reason, not internal calls. |
| **Mocking Used Sparingly** | ✅ PASS | Mocks only at the file-read and file-time seams. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/validate-feature-review-coverage.RunScope.Tests.ps1`, `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.RunScope.Tests.ps1`<br>**Code file:** `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1`<br>Existing suite locations retained. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All changed test files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | Describe blocks per surface (session root, item worktree, contract, documentation). |
| **Logical Grouping** | ✅ PASS | `RSCOPE-*` id families. |
| **Docstrings/Comments** | ✅ PASS | Synopsis and description blocks on each new suite. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`<br>**Result:** 29658 tests, 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Launcher only. |

---

## 5. Test Coverage Detail

### Remediation cycle 2 rows (reviewer full run at head)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `validate-feature-review-coverage.RunScope.Tests.ps1` (18) | Hook accept and reject, documentation rows | Claude coverage hook run-scope branch | ✅ |
| `Invoke-TestSuite.RunScope.Tests.ps1` (43) | Selection rules, record writing, refusal paths | Launcher step 7 and three new functions | ✅ |
| Claude `validate-feature-review-coverage-freshness.Tests.ps1` (41) | `RSCOPE-READ-*` reader rows | Reader validity checks | ✅ |
| Codex `validate-feature-review-coverage-freshness.Tests.ps1` (44) | Function-text parity and reader rows | Codex twin | ✅ |
| Codex `validate-feature-review-coverage.Coverage.Tests.ps1` (43) | `RSCOPE-CODEX-*` rows | Codex hook run-scope branch | ✅ |

**Coverage:** see section 1.2.1 per-file figures.

**Reviewer probes:** 17 direct calls of `Get-FeatureReviewCoverageReportScope` (head file, PowerShell 7.6.10): the real gate record with the report's original write time resolves `selection` (also for a Local-kind write time and a lowercase language name); a `+00:00` offset record, an unzoned record, a `full` record, a C# language (seam not invoked), a Python language against a `pester` record, one tick past the window, `schema_version` 1.0 or "1", a JSON array, a leading byte-order mark, `Selection` in another case, a duplicate `scope` key, and a null write time each resolve `full`; the exact end instant resolves `selection`; a throwing seam propagates its error. A real-file probe in a scratch item root holding the gate's selection report (write time restored to 14:59:22.154Z) and record ran the hook's own read sequence: `Get-ArtifactFileContent`, `Get-FeatureReviewReportLastWriteUtc`, and the reader resolve `selection`; `Test-LanguageCoverageRow` accepts a PASS row with no repo-wide figure, while the old grading reads 14.46% and refuses the same row.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 29658 (reviewer full Pester run), 3998 (remediation gate selection) | ✅ |
| Tests Passed | 29640 passed and 18 skipped; 3998 | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 806.83 s reviewer full run; 457.98 s remediation gate selection | ✅ |
| Average Time per Test | about 27 ms wall clock per test across 8 workers (reviewer full run) | ✅ |
| Discovery Time | included in shard start-up | ✅ |
| Functions/Classes Tested | 6 new functions, 2 hook entry branches | ✅ |
| Test File Size | largest changed test file 688 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 96.87% PowerShell lines repo-wide (reviewer full run) | ✅ |

---

## 7. Code Quality Checks

**For Python:** zero changed Python files; remediation-gate figures are recorded for the CI cross-check.

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 1071 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | launcher `pytest` suite (`poetry run pytest -n auto`) | 17104 passed (final QA); 229 passed (remediation gate) | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | 0 reformatted | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | 0 findings | ✅ |
| Pester Tests | launcher `pester` suite (`Invoke-PoshQCParallelTest`) | 29658 tests, 0 failed (reviewer full run); 3998, 0 failed (remediation gate) | ✅ |

**Reviewer-run checks (2026-11-24, item worktree, head `c8a4d99cf`):**

- `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`: exit 0, "harness-generation: no drift".
- The same with `-Surface instructions -Check`: exit 0, no drift.
- `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`: exit 0.
- `cmp` of each changed hook and launcher file with its bundle copy, of the `.agents` launcher source with the generated `.claude` copy, and of `AGENTS.md` with its bundle: all identical.
- Full launcher `pester` run at head: exit 0, 29658 tests, 0 failures, 0 errors, 18 skipped; the ledger chain, index, harness repo-gate, and push-down Pester suites are inside it.
- Reader probes and the real-file hook probe (section 5).
- Branch diff scope: no added `.py` file; no path under `.github/workflows/`, `scripts/dev_tools/atomic_executor/`, `.claude/lib/docs/`, `config/`, the frozen epic surfaces, the D10 standalone Copilot agents and prompts, or any `docs-*` or `documentation-workflow` path.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.

**Notes:** No pre-existing failure was observed.

---

## CI Cross-check

No pull request exists for the branch and no CI run is recorded for head `c8a4d99cf` (`gh pr list` and `gh run list` for the branch return empty). The orchestrator's S9 CI green gate compares these claims with CI on the PR head.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static (format, analyze) | pass | 0 reformatted, 0 findings | c8a4d99cf | `evidence/qa-gates/remediation-gate.2026-11-24T15-14.md` |
| poshqc / Pester tests | pass | 29658 tests, 0 failed, 96.87% lines (reviewer full run) | c8a4d99cf | reviewer run, section 1.2.1 |
| Linux hook-suite job (claude-hooks, codex-hooks) | pass | new suites use `/`-rooted synthetic roots and create no file | c8a4d99cf | file inspection; `remediation-plan.2026-11-24T10-50.md` standing rule |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 17104 passed; 98.01% lines, 95.47% branches | c8a4d99cf | `evidence/qa-gates/pytest.2026-11-24T06-43.md`, `evidence/qa-gates/remediation-gate.2026-11-24T15-14.md` |
| Enforce Python coverage thresholds | pass | 98.01% lines, 95.47% branches | c8a4d99cf | `evidence/qa-gates/pytest.2026-11-24T06-43.md` (no Python file changed since) |
| Harness generation drift check | pass | no drift (both modes) | c8a4d99cf | reviewer run, section 7 |

---

## Evidence Location Compliance

- `validate_evidence_locations.py --root <item worktree>`: exit 0.
- The branch diff adds no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All item evidence is under `.dev/active/1228-targeted-test-cadence/evidence/<kind>/`; remediation cycle 2 wrote under `remediation-baseline/`, `other/`, and `qa-gates/`. The new runtime record `artifacts/test-execution/run-scope.<suite>.json` is launcher state, not evidence, and is not committed.

## Additional Policy Checks

- `modified-workflow-needs-green-run`: not triggered; no path under `.github/workflows/`, `.github/actions/`, or `scripts/benchmarks/` changed.
- Documentation surface check: not applicable; `docs/documentation-estate/docs-profile.json` is absent on the branch head.
- Tier classification: `quality-tiers.yml` exists on the base; the branch adds no project or library folder, so no classification change is required.
- Coverage exclusions: no `exclude`, `omit`, `coveragePathIgnorePatterns`, or settings-file coverage path changed; `config/poshqc-coverage.json` and `.push-down-manifest.json` unchanged.
- File size: no changed covered file is at or above 700 logical lines; `config/file-size-baseline.json` unchanged.
- Process-reduction ledger: commit `c8a4d99cf` carries `reduction: 0014`; `## Files Changed` lists the five hook and launcher sources, the generated launcher, the six bundle copies, and the six changed test files; `## Revert Steps` covers the cycle-2 bundle copies, the generated launcher, and the two created suites; the ledger suites passed in the reviewer full run.
- Hook execution context: reviews run the default branch's copy of the coverage hook, so D11 takes effect for reviews only after merge (RD7). This review therefore used a full run for its repo-wide confirmation.
- Owner directives: the delegation carried no `Owner directives:` block, so no `OWNER-DIRECTIVE-DECISION:` line applies.

## Rejected Scope Narrowing

None. The delegation prompt did not narrow scope.

---

## 8. Gaps and Exceptions

### Identified Gaps

- F3 from `policy-audit.2026-11-24T10-50.md` is resolved: the coverage Stop hook and its Codex twin grade a selection report covered by a valid record as per-file evidence and keep the repo-wide check for every other report (sections 1.2, 5, and 7).
- F4 (Blocking): `Write-TestSuiteRunScopeRecord` lacks `SupportsShouldProcess` and a `$PSCmdlet.ShouldProcess` guard around its folder creation and file write. Remediation: add `[CmdletBinding(SupportsShouldProcess)]` and wrap the `New-Item` and `Set-Content` calls in `if ($PSCmdlet.ShouldProcess($Path, 'Write the test-suite run-scope record'))` in the `.agents` source, regenerate the `.claude` copy, copy both bundles, add a `-WhatIf` row that asserts no write, and regenerate the ledger `0014` stored patch.
- Minor (non-blocking): `user-story.md` `## Non-Goals` still lists "Adding or changing hooks, validators, or configuration"; spec D11 and the spec Out of Scope section now change two hooks and the launcher. Update the non-goal to name the D11 exception.
- Info: the repository suite `jest-extension` writes `run-scope.jest-extension.json`, which the hook does not read; the hook maps TypeScript to the built-in `jest` suite and the root `coverage/lcov.info`, so a `jest-extension` run leaves TypeScript graded as before (fail-safe direction).
- Info: `Get-TestSuiteRunScope` classifies a `-TestPath` that names the whole test tree, or a pytest space-form option value ending in `.py` (for example `--ignore x.py`), as `selection`. Either is a caller choice; the repo-wide figure still comes from the final-QC artifact and CI under D3.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented.

---

## 9. Summary of Changes

The branch limits full-suite test runs in orchestrations to the `Phase 0 baseline` and the final QA loop on every harness surface, pins the new wording with contract tests, records the change as process reduction `0014`, aligns the QA-gate and feature-review coverage contracts with selection runs (cycle 1), and adds a launcher run-scope record that the feature-review coverage hooks read so that a selection report is graded as per-file evidence (cycle 2).

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain, coverage, parity, generator, ledger, evidence, and contract-test checks pass, and F3 is resolved. One blocking finding (F4) remains: a new state-changing PowerShell function does not implement ShouldProcess. CI on the PR head remains for the S9 gate.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: research, spec, plan, and remediation plans present
- ✅ Design Principles: one record writer, one shared fail-safe reader
- ✅ Module & File Structure: within limits
- ✅ Naming, Docs, Comments: clear
- ✅ Toolchain Execution: clean remediation gate
- ⚠️ Summarize & Document: user-story non-goal not updated (non-blocking)

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ❌ PowerShell Design & Safety: ShouldProcess absent on `Write-TestSuiteRunScopeRecord` (F4)
- ✅ Structure & Naming: clean
- ✅ Toolchain: clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: met
- ✅ Coverage & Scenarios: no regression; changed files above thresholds
- ✅ Test Structure: AAA and messages present
- ✅ External Dependencies: seams mocked, no files created
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester through PoshQC
- ✅ Test Style & Structure: focused rows
- ✅ Naming & Readability: clear
- ✅ Toolchain: launcher only

---

### Metrics Summary

- ✅ 29640 of 29658 Pester tests passed in the reviewer full run (18 skipped, 0 failed)
- ✅ 3998 of 3998 remediation-gate Pester tests passing
- ✅ 96.87% PowerShell line coverage repo-wide (baseline 96.84%)
- ✅ Every changed PowerShell production file at or above 93.85% lines
- ✅ Bundle parity and generator drift checks clean

---

### Recommendation

**Needs revision**

Address F4 in one light remediation cycle (one function in the launcher source, its generated copy and bundles, one test row, and the ledger `0014` stored patch), then re-review. After that, the S9 CI green gate confirms the CI rows above on the PR head.

---

## Appendix A: Test Inventory

### Complete Test List

- `validate-feature-review-coverage.RunScope.Tests.ps1` › `RSCOPE-HOOK-SELECTION-ACCEPTED`, `-FULL-REJECTED`, `-NO-RECORD-REJECTED`, `-OUTSIDE-WINDOW-REJECTED`, `-BRANCH-SELECTION-ACCEPTED`, `-VERDICT-STILL-REQUIRED`, `-ITEM-ROOT-ACCEPTED`, `-STALE-SELECTION-REJECTED`, `RSCOPE-CONTRACT-LAUNCHER-RECORD`, `RSCOPE-DOC-BRIEF`, `RSCOPE-DOC-POLICY`
- `Invoke-TestSuite.RunScope.Tests.ps1` › `RSCOPE-LAUNCH-*` (43 tests)
- Claude and Codex `validate-feature-review-coverage-freshness.Tests.ps1` › `RSCOPE-READ-*`, function-name and function-text parity
- Codex `validate-feature-review-coverage.Coverage.Tests.ps1` › `RSCOPE-CODEX-*`
- Earlier rows unchanged: `TCW-*`, `RSC-REGENERATE`, `PGW-*`, `PCW-*`, ledger suites

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing (full run through the launcher)
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester

# Generators
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check
pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface instructions -Check
```

**For Python:**
```bash
env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-24  
**Policy Version:** Current (as of audit date)

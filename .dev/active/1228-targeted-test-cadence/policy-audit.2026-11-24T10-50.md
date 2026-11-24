# Policy Compliance Audit: targeted-test-cadence (#1228), re-audit after remediation cycle 1

---

**Audit Date:** 2026-11-24  
**Code Under Test:** merge base `a4ebf96688106d9bcd0baf51d237a6b77c055560` of the base branch `origin/main` and reviewed head `4ac1f0be8688ddbd9c18a4de072d3f0095dc9cfd` (branch `feature/targeted-test-cadence-1228`, equal to the remote branch head); the diff between them lists the changed files (251 files, +7734/-347). The remediation commit `4ac1f0be8` changes 45 of them.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 test files, 0 production files | 29348 tests (final QA full run); 721 (remediation gate selection); 671 (reviewer selection) | ✅ 0 fail in each run | 96.84% lines | 96.85% lines | 96.85% lines repo-wide (no PowerShell production file changed) |
| Python | 0 files | 17104 tests (final QA full run) | ✅ 17104 pass, 0 fail | 98.01% lines, 95.47% branches | 98.01% lines, 95.47% branches | N/A - zero changed Python files |
| TypeScript | 0 files | jest-extension and root jest (final QA) | ✅ 0 fail | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

The remaining changed files are Markdown (rules, skills, agents, prompts, instructions, plan and audit templates, ledger, feature records), TOML (generated Codex agents and variants), and one stored patch. They have no coverage language.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files (executor baseline recorded at `.dev/active/1228-targeted-test-cadence/evidence/baseline/jest.2026-11-23T13-33.md`)
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files (executor final QA recorded at `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/jest.2026-11-24T06-58.md`)
- PowerShell baseline coverage artifact: `.dev/active/1228-targeted-test-cadence/evidence/baseline/pester.2026-11-23T13-26.md` (Phase 0 baseline, 96.84% lines)
- PowerShell post-change coverage artifact: `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/pester.2026-11-24T06-30.md` (final QA full run, root LINE counter 47435 covered, 1541 missed); the current `artifacts/pester/powershell-coverage.xml` is the reviewer full run at head with the same counters (see 1.2.1)
- Per-language comparison summary: section 1.2.1 of this audit

Baseline coverage is read from the plan's `Phase 0 baseline` artifact, one run of the language's gate.

**CI-proven checks:** Format, lint, and type-check results are read from the final-QC and remediation-gate static artifacts of each language and are not re-run during the review. Each CI check the review relies on is recorded in `## CI Cross-check`.

---

## Executive Summary

This is the re-audit after remediation cycle 1. The branch rewrites the test-cadence policy text on every harness surface so that the full test suite runs only at the `Phase 0 baseline` and in the final QA loop. The previous review (`policy-audit.2026-11-24T07-15.md`) raised two blocking findings: F1 (QA-gate delta and prohibition clauses contradicted the selection-based remediation gate) and F2 (the feature-review agent, skill, and policy-audit template read a selection-only local coverage file as a repo-wide figure and forbade the D3 re-run).

Commit `4ac1f0be8` resolves both:

- F1: in all eight QA-gate copies (Claude, Codex, csharp-legacy variants) and their bundles, `Overall coverage delta` is scoped to the final QA loop, a `Remediation gate coverage` bullet defines the per-file delta over the cycle's changed files with the repo-wide figure from the final-QC artifact and CI, and the prohibition now names the remediation gate's selection run as its gate run while keeping any other partial run as debugging only.
- F2: both halves of the feature-review agent source (and the regenerated `.claude` and `.codex` targets and bundles), step 5 of `feature-review-workflow` (both copies and bundles), and template 4A.1 (and its bundle) read repo-wide totals from the final-QC artifact and `## CI Cross-check`, state that a selection-run coverage file supplies per-file figures only, and replace "does NOT rerun coverage generation" with the D3 selection re-run.

Reviewer verification: generators report no drift; every changed surface file is byte-identical to its bundle; a launcher Pester selection of 12 contract and ledger suites passed 671 of 671; a discrimination probe ran the head test file against the pre-remediation tree and the 24 new or extended rows over the remediated files failed (every one of the five forbidden old sentences reported) while the other 169 rows passed.

One new blocking finding, F3, surfaced while completing this review. The unchanged feature-review coverage Stop hook (`validate-feature-review-coverage-metrics.ps1`) reads the root LINE counter of the local `artifacts/pester/powershell-coverage.xml` as the repo-wide figure and refuses completion unless the policy audit records a FAIL below the floor. After the reviewer's selection re-run, which the remediated step 5 prescribes, the hook refused completion at 2.05%, although the true repo-wide figure is 96.85%. The reviewer then ran the full Pester suite at head to complete honestly. The branch's D3 text forbids that run, so the review enforcement contradicts the review procedure the branch defines.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (zero changed Python files)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (two changed Pester test files)
- N/A Bash: shfmt + shellcheck + bats (zero changed shell files)
- N/A JSON: format_json + validate_json (zero changed JSON files)

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; the executor's helper scripts live under the gitignored `artifacts/issue-1228/` and the session scratch folder.
- ✅ No new tooling script is added to the repository.
- Reviewer scratch files (launchers, a scratch clone for the discrimination probe, report snapshots) are in the session scratchpad and are not in the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The new rows read repository files and in-memory text only; they share no state. The reviewer launcher run sharded 12 suites across 8 parallel processes with 0 failures. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each `TCW-*` row checks one heading of one file for its required and forbidden tokens; `TCW-COVERAGE-SOURCE-DISCRIMINATES` isolates the five checks from file I/O. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 671 selected tests ran in 15.54 s of test time (178.55 s wall clock including shard start-up). |
| **Determinism** - Consistent results | ✅ PASS | Inputs are committed files and literal strings; no clock, random, or network use. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | New check variables (`$script:QaGateDeltaCheck`, `$script:QaGateShortcutCheck`, `$script:ReviewCheck`, `$script:ReviewAgentCheck`, `$script:ReviewTemplateCheck`) carry issue and finding comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 96.84% lines (PowerShell), read from the `Phase 0 baseline` artifact<br>**Command:** `Invoke-PoshQCParallelTest` through the launcher `pester` suite (one run of the gate)<br>**Artifact:** `.dev/active/1228-targeted-test-cadence/evidence/baseline/pester.2026-11-23T13-26.md`<br>**Timestamp:** 2026-11-23 13:26 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.85% lines (PowerShell), read from the final QA single gate run<br>**Change:** +0.01% lines against the `Phase 0 baseline`<br>**Status:** No regression; the remediation cycle changed no production file |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** no production file changed in any coverage language; the two changed files are Pester test files, which are not in the coverage population<br>**Thresholds:** 85% line (default; root `CLAUDE.md` states none), branch threshold not applicable to PowerShell<br>**Status:** No changed production file below a threshold |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** no production code; tests only<br>**New code coverage:** 96.85% repo-wide PowerShell lines<br>**Calculation method:** root LINE counter of the final QA `powershell-coverage.xml`, recorded in `evidence/qa-gates/pester.2026-11-24T06-30.md` |
| **Comprehensive Coverage** | ✅ PASS | The cycle's new rows cover every remediated surface: QA-gate delta and shortcut checks on 14 QA-gate rows, the review skill check on 4 rows, `REVIEW-AGENT` on 4 rows, `REVIEW-TEMPLATE` on 2 rows, and the in-memory discrimination row. |
| **Positive Flows** - Valid inputs | ✅ PASS | Required-token checks pass on every head copy. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Forbidden-token lists fail a file that still carries a removed sentence; the reviewer probe showed all 24 affected rows fail on the pre-remediation tree. |
| **Edge Cases** - Boundary conditions | ✅ PASS | The QA-gate forbidden token `Overall coverage delta** (when the repo enforces it)` matches only the unscoped bullet, so the scoped bullet passes and the old one fails. |
| **Error Handling** - Error paths | ✅ PASS | `TCW-COVERAGE-SOURCE-DISCRIMINATES` asserts that each of the five distinct forbidden tokens is reported from in-memory text. |
| **Concurrency** - If applicable | N/A | Contract tests read files only. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.84% lines (from the `Phase 0 baseline` artifact) -> Post-change: 96.85% lines. Change: +0.01% lines. New/changed-code coverage: 96.85% lines repo-wide; no PowerShell production file changed. Disposition: PASS. Evidence: `.dev/active/1228-targeted-test-cadence/evidence/baseline/pester.2026-11-23T13-26.md`, `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/pester.2026-11-24T06-30.md`, `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/remediation-gate.2026-11-24T10-19.md`.
- Python: Baseline: 98.01% lines, 95.47% branches -> Post-change: 98.01% lines, 95.47% branches. Change: +0.00% lines. New/changed-code coverage: N/A - zero changed Python files. Disposition: N/A. Evidence: `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/pytest.2026-11-24T06-43.md`.
- TypeScript: Baseline: N/A - zero changed TypeScript files -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A - zero changed TypeScript files. Disposition: N/A. Evidence: `.dev/active/1228-targeted-test-cadence/evidence/qa-gates/jest.2026-11-24T06-58.md`.

Coverage source and freshness: the repo-wide PowerShell figure is read from the final QA full-run artifact (`pester.2026-11-24T06-30.md`), as the remediated step 3 of the feature-review agent and step 5 of `feature-review-workflow` require. The remediation gate (`remediation-gate.2026-11-24T10-19.md`) ran the cycle's 14-file selection in coverage mode and overwrote `artifacts/pester/powershell-coverage.xml` with a selection-only report (1002 covered, 47974 missed lines); that figure is per-file evidence only and is not graded as repo-wide. That report was written at 2026-11-24T10:10:13Z, before the remediation commit `4ac1f0be8` (2026-11-24T10:26:08Z), so it was stale against the newest commit touching PowerShell files. Following the D3 rule as the branch head states it (step 5 of `feature-review-workflow`), the reviewer re-ran the cycle's 14-file selection through the launcher (`run-test-suite.sh pester -TestPath <the 14 union files of remediation-gate.2026-11-24T10-19.md>`; attempts 1 and 2 exit 75 queue timeout, attempt 3 exit 0): 721 tests, 0 failures, LINE 1002 covered and 47974 missed, identical to the remediation gate. The report was written at 2026-11-24T11:03:59Z, after the commit, and is left in place. It is per-file evidence only and is not graded as repo-wide. This deviates from the main-branch agent text "does NOT rerun coverage generation", which the branch replaces; the full suite was not run. Before the reviewer's first selection run, `powershell-coverage.xml` and `pester-junit.xml` were snapshotted and restored afterwards (SHA-256 prefixes `ec2205ac427cdf4e` and `85085293773dc0be`); the D3 re-run then replaced them with the equivalent post-commit report.

The coverage Stop hook then graded that selection report as the repo-wide figure (2.05%) and refused completion (F3). To complete without recording a false FAIL, the reviewer ran the full Pester suite at head through the launcher (`run-test-suite.sh pester`, no `-TestPath`): attempt 1 started 2026-11-24T11:06:30Z, exit 0, wall-clock 773.78 s, 29355 tests, 0 failures, 0 errors, 18 skipped (29348 in the final QA run plus the 7 rows added in cycle 1); root LINE counter 47435 covered and 1541 missed = 96.85%, identical to the final QA figure; report written 2026-11-24T11:20:13Z. This full-run report is left in place, postdates the remediation commit, and confirms the final QA figure.

The remediation cycle changed one PowerShell file, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, a test file outside the coverage population, and no production file in any language (`git show --stat 4ac1f0be8`), so the final QA figures remain valid for the production population.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Row failures name the file, the heading, and each forbidden token (`forbidden '<token>' in <file>`); the discrimination row's `-Because` text states that each check must fail when its removed sentence returns. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | `TCW-COVERAGE-SOURCE-DISCRIMINATES` carries `# Arrange`, `# Act`, `# Assert` comments. |
| **Document Intent** | ✅ PASS | `Issue #1228 (F1)` and `Issue #1228 (F2)` comments precede the new check groups. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Repository files only; no network or process calls. |
| **Use Mocks/Stubs** | N/A | No seam needed for read-only contract tests. |
| **Environment Stability** | ✅ PASS | Paths resolve from the repository root; no temporary files are created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the required review; F1 and F2 are closed and F3 is open. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Owner objective quoted verbatim in `spec.md` and ledger entry `0014`. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-24T07-15.md` cites the review findings and records decisions RD1 to RD5. |
| **Document the plan** | ✅ PASS | All remediation-plan tasks are checked with task-check, gate, and self-review evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Each fix adds one scoping clause or replaces one sentence; no new section or mechanism. |
| **Reusability** | ✅ PASS | The same "supplies per-file figures only" and "from the final-QC artifact and" wording is used on the agent, skill, and template. |
| **Extensibility** | ✅ PASS | `## Test Cadence (Mandatory)` remains the single cadence definition; the QA-gate skills point to it. |
| **Separation of concerns** | ⚠️ PARTIAL | The dependent contracts named by F1 and F2 now agree with the cadence; the coverage Stop hook that enforces the review procedure does not (F3). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Test changes stay inside the existing wording suite. |
| **At or below the 800-line hard limit** | ✅ PASS | `test-cadence-wording.Tests.ps1` 688 logical lines; `regeneration-path-skill-contract.Tests.ps1` 350 logical lines (counted with `@(Get-Content -LiteralPath <path>).Count`). Neither is at or above 700. `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | N/A | No public API. |
| **No circular dependencies** | N/A | No module imports changed. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `$script:QaGateDeltaCheck`, `$script:ReviewAgentCheck`, `$script:CoverageSourceCase`. |
| **Docs/docstrings** | ✅ PASS | Issue and finding references in comments. |
| **Comment why, not what** | ✅ PASS | Comments state the rule each check pins. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root <worktree>`<br>**Result:** 1879 files, 0 reformatted; porcelain identical before and after (`remediation-gate.2026-11-24T10-19.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root <worktree>`<br>**Result:** 0 findings; leak scan 0 failures |
| **3. Type checking** | N/A | Not applicable for PowerShell; Pyright 0 errors repo-wide in the remediation gate. |
| **4. Testing** | ✅ PASS | **Command:** remediation gate launcher `pester -TestPath` (14 files), `pytest` (10 files), `jest-extension` (2 files)<br>**Result:** 721, 279, and 22 passed, 0 failures |
| **Full toolchain loop** | ✅ PASS | One clean pass of stages 1 to 6 recorded in the remediation gate artifact. |
| **Explicit reporting** | ✅ PASS | Commands and exit codes are recorded in each evidence file. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Ledger `0014` `## Summary` gains the remediation-cycle sentence. |
| **Design choices explained** | ✅ PASS | `spec.md` D1 to D10; remediation plan RD1 to RD5. |
| **Update supporting documents** | ✅ PASS | Feature-review agent source and generated copies, skill step 5, and policy-audit template updated (F2). |
| **Provide next steps** | ✅ PASS | This audit names the remaining CI step (S9). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .`<br>**Result:** 0 reformatted; porcelain identical before and after |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | No findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Repository targets PowerShell 7+; the new code uses `StartsWith` with an ordinal comparison and array pipelines only. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | N/A | Test file; no new function. |
| **Parameter validation** | N/A | Test file. |
| **Avoid global state** | ✅ PASS | Discovery data is held in `$script:` variables in `BeforeDiscovery`, as in the existing rows. |
| **Error handling** | ✅ PASS | File reads fail the row on error. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 688 and 350 logical lines. |
| **Approved verbs** | N/A | No new function. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Remediation-gate static stage. |
| **Step 2: Analyze** | ✅ PASS | Remediation-gate static stage. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Remediation gate 721 tests, 0 failures; reviewer selection 671 tests, 0 failures. |
| **Rerun loop if needed** | ✅ PASS | One clean pass recorded. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`/`It -ForEach`, `Should -Be`, `Should -BeNullOrEmpty`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through the launcher<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, unchanged |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7 target. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One heading per check per row. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows pin policy statements, the intended contract. |
| **Mocking Used Sparingly** | ✅ PASS | No mocks. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`<br>**Code file:** Markdown and TOML surfaces under `.claude/`, `.agents/`, `.codex/`, `.dev/templates/`<br>Existing contract-suite location retained. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Both files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | New rows join the existing `Describe 'Test cadence wording'`. |
| **Logical Grouping** | ✅ PASS | `QAGATE`, `REVIEW`, `REVIEW-AGENT`, `REVIEW-TEMPLATE` groups. |
| **Docstrings/Comments** | ✅ PASS | Issue and finding comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <12 suites>`<br>**Result:** 671 tests, 0 failures |
| **No Alternative Test Runners** | ✅ PASS | Launcher only. |

---

## 5. Test Coverage Detail

### test-cadence-wording.Tests.ps1 rows added or extended in cycle 1 (reviewer selection run)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `TCW-QAGATE-*` (14) | Positive and negative tokens | `## Delta Requirements`, `## Prohibited Shortcuts` | ✅ |
| `TCW-REVIEW-*` (4) | Positive and negative tokens | `## Ordered Procedure` | ✅ |
| `TCW-REVIEW-AGENT-*` (4) | Positive and negative tokens | `## Coverage Verification` | ✅ |
| `TCW-REVIEW-TEMPLATE-*` (2) | Positive and negative tokens | `#### 4A.1 Framework and Scope` | ✅ |
| `TCW-COVERAGE-SOURCE-DISCRIMINATES` | Error path, in memory | five checks | ✅ |

**Coverage:** test files; no production line coverage applies.

**Discrimination probe:** the head test file run against a scratch clone at `731163ca9` (pre-remediation) failed exactly the 24 rows above that read files (169 other rows passed), reporting `Overall coverage delta** (when the repo enforces it)` 14 times, `based on partial or targeted runs` 14, `local artifact that shows the` 10, `does NOT rerun coverage generation` 4, and `rather than rerunning coverage generation` 4.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 29348 (final QA Pester), 721 (remediation gate), 671 (reviewer selection) | ✅ |
| Tests Passed | 29330, 721, and 671 | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 762.97 s final QA; 166.13 s remediation gate; 178.55 s reviewer selection | ✅ |
| Average Time per Test | about 23 ms (reviewer selection, 15.54 s test time) | ✅ |
| Discovery Time | included in shard start-up | ✅ |
| Functions/Classes Tested | not applicable to Markdown contracts | ✅ |
| Test File Size | 688 and 350 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 96.85% PowerShell lines repo-wide (final QA) | ✅ |

---

## 7. Code Quality Checks

**For Python:** zero changed Python files; remediation-gate figures are recorded for the CI cross-check.

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 1071 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | launcher `pytest` suite (`poetry run pytest -n auto`) | 17104 passed (final QA); 279 passed (remediation gate) | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | 0 reformatted | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | 0 findings | ✅ |
| Pester Tests | launcher `pester` suite (`Invoke-PoshQCParallelTest`) | 29348 tests, 0 failed (final QA); 721, 0 failed (remediation gate) | ✅ |

**Reviewer-run checks (2026-11-24, item worktree, head `4ac1f0be8`):**

- `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check`: exit 0, "harness-generation: no drift".
- The same with `-Surface instructions -Check`: exit 0, no drift.
- `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`: exit 0.
- `cmp AGENTS.md extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md`: exit 0.
- Byte comparison of every changed `.claude`, `.agents`, `.codex`, `.github`, `.dev/templates/policy_audit`, and plan-template path with its bundle copy (`claude-customizations`, `codex-and-agents-customizations`, `customizations`, `templates`, `feature-templates`): no difference, no absent bundle.
- Launcher `pester -TestPath` over `test-cadence-wording`, `regeneration-path-skill-contract`, `parallel-gate-wording`, `less-evidence-contract`, `light-remediation-skill-contract`, the five `ProcessReduction*` suites, `HarnessGeneration.RepoGate`, and `PoshQC.VendoredCoverage.RepoGate`: attempt 1 exit 75 (queue timeout), attempt 2 exit 0, 671 tests, 0 failures, 0 errors.
- Discrimination probe in a scratch clone at `731163ca9` with the head test file: exit 1, 24 failed, 169 passed (section 5).
- Launcher `pytest` over `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_tier_rule_adoption_gate.py` (which pins `governing repo-wide threshold` in the Claude feature-review agent), `test_parallel_orchestrator_surface_contracts.py` (frozen epic surface digest), `test_completion_gate_documentation_contracts.py`, `test_codex_agent_wrapper_contracts.py`, and `test_push_down_issue_824_follow_ups.py`: attempts 1 to 4 exit 75 (queue timeout; lock held by a suite of another repository), attempt 5 exit 0, 251 passed. `artifacts/python/lcov.info` was not rewritten by this run.
- Ledger `## Files Changed` completeness: every branch path outside the ledger folder, the feature folder, and the promotion record is listed (0 absent; the policy-audit template under its earlier `docs/features/templates/` key).
- Sibling-sentence sweep over the worktree (excluding `.dev/`, `node_modules/`, `.venv/`): the five removed sentences occur only in the test file's forbidden lists and in-memory cases.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.

**Notes:** No pre-existing failure was observed.

---

## CI Cross-check

No pull request exists for the branch and no CI run is recorded for head `4ac1f0be8` (`gh pr list` and `gh run list` for the branch return empty). The orchestrator's S9 CI green gate compares these claims with CI on the PR head.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static (format, analyze) | pass | 0 reformatted, 0 findings | 4ac1f0be8 | `evidence/qa-gates/remediation-gate.2026-11-24T10-19.md` |
| poshqc / Pester tests | pass | 29348 tests, 0 failed, 96.85% lines (final QA); 721, 0 failed (remediation gate) | 4ac1f0be8 | `evidence/qa-gates/pester.2026-11-24T06-30.md`, `evidence/qa-gates/remediation-gate.2026-11-24T10-19.md` |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 17104 passed; 98.01% lines, 95.47% branches | 4ac1f0be8 | `evidence/qa-gates/pytest.2026-11-24T06-43.md`, `evidence/qa-gates/remediation-gate.2026-11-24T10-19.md` |
| Enforce Python coverage thresholds | pass | 98.01% lines, 95.47% branches | 4ac1f0be8 | `evidence/qa-gates/pytest.2026-11-24T06-43.md` (no Python file changed since) |
| Harness generation drift check | pass | no drift (both modes) | 4ac1f0be8 | reviewer run, section 7 |

---

## Evidence Location Compliance

- `validate_evidence_locations.py --root <item worktree>`: exit 0.
- The branch diff adds no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All item evidence is under `.dev/active/1228-targeted-test-cadence/evidence/<kind>/`; the remediation cycle wrote under `remediation-baseline/`, `other/`, and `qa-gates/`.

## Additional Policy Checks

- `modified-workflow-needs-green-run`: not triggered; no path under `.github/workflows/`, `.github/actions/`, or `scripts/benchmarks/` changed.
- Documentation surface check: not applicable; `docs/documentation-estate/docs-profile.json` is absent on the branch head.
- Tier classification: `quality-tiers.yml` exists on the base; the branch adds no project or library folder, so no classification change is required.
- Coverage exclusions: no `exclude`, `omit`, `coveragePathIgnorePatterns`, or settings-file coverage path changed; `.push-down-manifest.json` unchanged.
- File size: both changed covered files are below 700 logical lines; `config/file-size-baseline.json` unchanged.
- Out-of-scope paths: the branch diff lists no path under `.github/workflows/`, `scripts/dev_tools/atomic_executor/`, `.claude/lib/docs/`, no frozen epic surface, no D10 standalone Copilot agent or prompt, no `docs-*` or `documentation-workflow` path, and no `.py` file.
- Process-reduction ledger: commit `4ac1f0be8` carries `reduction: 0014`; the entry's `## Summary`, `## Files Changed`, `## Stored Patch`, and `## Revert Steps` were extended for the cycle's paths; the five ledger suites passed in the reviewer run.
- Owner directives: the delegation carried no `Owner directives:` block, so no `OWNER-DIRECTIVE-DECISION:` line applies.

## Rejected Scope Narrowing

None. The delegation prompt did not narrow scope.

---

## 8. Gaps and Exceptions

### Identified Gaps

- F1 and F2 from `policy-audit.2026-11-24T07-15.md` are resolved and pinned by contract rows (sections 5 and 7).
- F3 (Blocking): `.claude/hooks/validate-feature-review-coverage-metrics.ps1` (`Get-LanguageRepoCoverage`, `Get-JacocoRepoCoverage`) and `.claude/hooks/validate-feature-review-coverage.ps1` (line 229) grade the local coverage report as repo-wide; with `validate-feature-review-coverage-freshness.ps1` they force either a false repo-wide FAIL or a full-suite run after any selection run. Spec D3 states no hook change is needed and the spec lists hooks as out of scope; that premise does not hold. Remediation: make the hook grade only a full-suite report as repo-wide, amend D3 with a recorded decision, extend ledger `0014`, add hook tests, and copy the hooks to their bundles.
- Info: the Copilot typed-engineer and test-engineer agents under `.github/agents/` keep "overall coverage delta if applicable"; they are standalone agents that bracket their own runs and are out of scope under spec D10.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented.

---

## 9. Summary of Changes

The branch limits full-suite test runs in orchestrations to the `Phase 0 baseline` and the final QA loop on every harness surface, pins the new wording with contract tests, records the change as process reduction `0014`, and, in remediation cycle 1, aligns the QA-gate delta and prohibition clauses and the feature-review coverage source with the selection runs.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain, coverage, parity, generator, ledger, evidence, and contract-test checks pass. F1 and F2 are resolved. One blocking finding (F3) remains: the review coverage Stop hook contradicts the selection cadence. CI on the PR head remains for the S9 gate.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: research, spec, plan, and remediation plan present
- ⚠️ Design Principles: skills, agents, and template aligned; coverage Stop hook not aligned (F3)
- ✅ Module & File Structure: within limits
- ✅ Naming, Docs, Comments: clear
- ✅ Toolchain Execution: clean remediation gate
- ✅ Summarize & Document: ledger and surfaces updated

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: test-only change
- ✅ Structure & Naming: clean
- ✅ Toolchain: clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: met
- ✅ Coverage & Scenarios: no regression
- ✅ Test Structure: AAA and messages present
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester through PoshQC
- ✅ Test Style & Structure: focused rows
- ✅ Naming & Readability: clear
- ✅ Toolchain: launcher only

---

### Metrics Summary

- ✅ 29348/29348 executed Pester tests without failure in the final QA run (18 skipped)
- ✅ 721/721 remediation-gate Pester tests and 671/671 reviewer-selected tests passing
- ✅ 96.85% PowerShell line coverage repo-wide (baseline 96.84%)
- ✅ All code quality checks passing
- ✅ Bundle parity and generator drift checks clean

---

### Recommendation

**Needs revision**

Address F3 in one full remediation cycle (design scope: coverage Stop hook scripts and bundles, hook Pester tests, spec D3 amendment, ledger `0014` extension), then re-review. After that, the S9 CI green gate confirms the CI rows above on the PR head.

---

## Appendix A: Test Inventory

### Complete Test List

- Test cadence wording › `TCW-QAGATE-*` (delta and shortcut checks added)
- Test cadence wording › `TCW-REVIEW-*` (coverage-source tokens added)
- Test cadence wording › `TCW-REVIEW-AGENT-CLAUDE`, `TCW-REVIEW-AGENT-CODEX`, and bundles
- Test cadence wording › `TCW-REVIEW-TEMPLATE-BASE`, `TCW-REVIEW-TEMPLATE-BUNDLE`
- Test cadence wording › `TCW-COVERAGE-SOURCE-DISCRIMINATES`
- Earlier rows unchanged: `TCW-CANONICAL-*`, `TCW-HANDOFF-*`, `TCW-ENGINEER-*`, `TCW-SCOPED-*`, `TCW-BRIEF-*`, `TCW-CADENCE-SWEEP-*`, `RSC-REGENERATE`

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing (selection through the launcher)
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1

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

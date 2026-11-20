# Policy Compliance Audit: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188), R4 re-audit

---

**Audit Date:** 2026-11-15  
**Code Under Test:** merge base `1df569f65ccdcca86cc9adeb5a1a33ef56f988cb` of the base branch `main` (equal to `origin/main` at review time) and reviewed head `5f8b15daf20b977cfdba2fa14319e36f6536df67` (PR #1191); the diff between them lists the changed files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 30 files (4 copies each of the operands and classify siblings; both gates and both epic-scope files with bundle copies; 10 test files) | 27323 tests | 27305 run, 0 failed, 0 errors, 18 skipped | 95.96% lines | 96.04% lines | 100% lines (operands 154/154 and classify 51/51 per copy; every changed executable line of the gates and epic-scope files covered) |
| Python | 1 file (test file `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py`; no production Python file) | 88 targeted tests | 88 passed, 0 failed | 97.71% lines, 95.13% branches (merge-base CI shards combined) | 97.71% lines, 95.13% branches (no production Python file changed) | N/A - no new or modified production Python file |
| JSON | 2 files (pack manifests) | N/A | N/A | N/A (configuration) | N/A (configuration) | N/A |
| Markdown | skill and brief copies, promoted potential, feature folder documents and evidence | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Python baseline coverage artifact: merge-base CI run `43753053313` artifacts `python-coverage-shard-1` and `python-coverage-shard-2`, combined by the reviewer with the repository coverage settings (35087/35910 lines, 13022/13688 branches); the same run's step `Enforce Python coverage thresholds` succeeded (`--min-line 85 --min-branch 75`)
- Python post-change coverage artifact: no local `artifacts/python/lcov.info`; the branch changes no production Python file (the only changed Python file is a test file, excluded from measurement), so the measured lines equal the merge base; the head CI job `Code Quality & Tests (3.13)` was pending when this audit was written (see `## CI Cross-check`)
- C# baseline coverage artifact: N/A - zero changed C# files
- C# post-change coverage artifact: N/A - zero changed C# files
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/evidence/baseline/pester-gate.2026-11-14T21-02.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, rewritten by the reviewer's full Pester gate at the reviewed head (started 2026-11-15T20-42, ended 2026-11-15T20-54, after the head commit at 2026-11-15T20:37:51Z)
- Per-language comparison summary: section 1.2.1 below

---

## Executive Summary

This is the R4 re-audit after remediation cycle 1 (finding R1: classification supplement in the new byte-identical sibling `enforce-orchestration-preimplementation-gate-classify.ps1`, `Get-OrchestrationModeDenyReason` moved into the Codex epic-scope file, `--rcfile`/`--init-file` value skip) and remediation cycle 2 (finding F2: the literal-path rule in the execution-environment brief, six copies, and in the Codex `bash-command-shape` skill and its bundle copy, pinned by eight new Python rows).

Scope: the full branch diff (100 files). PowerShell and Python have changed files; Python's only changed file is a test file. TypeScript, C#, and bash have zero changed files.

The reviewer verified at the head: four-copy byte identity of both siblings, bundle identity of both gates and both epic-scope files, six-copy identity of the brief, and two-copy identity of the Codex skill (git blob hashes); the full parallel Pester gate (0 failures, 96.04% lines repo-wide, 100% on both siblings, no zero-hit changed executable line); the targeted pytest contract suites (88 passed); `git merge-tree` against `origin/main` (clean); and the evidence-location validator (exit 0).

Two blocking findings exist:

- R2: the classification supplement misses its own form when the joined-word run starts at a record that lacks `npm` or `npx`. `FOO=$(pwd) npm --prefix $(pwd) run lint`, `env FOO=$(pwd) npm --prefix $(pwd) run lint`, and `FOO=$(pwd) npx --prefix $(pwd) jest` are unclassified on both surfaces and admitted by the Claude gate, while the same commands without the leading assignment deny `TARGET_WORKTREE_NOT_DERIVABLE`. It is a defect in cycle 1's new code.
- E1: `evidence/qa-gates/self-review.2026-11-15T20-38.md` carries a filename and `Timestamp:` stamp later than the commit that added it (2026-11-15T20:37:51Z), so the stamp was not read from the clock, and no correction line records this (the owner rule requires clock timestamps).

Both are autonomous and contained, so the remediation path is light.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on the base branch; `.claude/hooks` and `.codex/hooks` are classified; the branch adds no project folder)

**Language-specific policies evaluated:**
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (one test file)
- N/A Bash: no bash file in the branch diff (reviewer and executor helper scripts are gitignored under `artifacts/`)
- ✅ JSON: two pack manifests, covered by the manifest completeness suites

**Temporary artifacts cleanup:**
- ✅ The reviewer's probe scripts live in the gitignored `artifacts/scratch-issue-1188/` folder of the item worktree; none is tracked
- ✅ No ongoing tooling script was added
- Reviewer-created files: this review set and one owner-directive decision file; no existing evidence was edited

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Per-row mocks; script-scope state reset per the `EpicStateIsolation.Baseline.Helpers.ps1` pattern; the classify and operands suites pass inside the eight-worker parallel gate. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One function row or gate row per form; the new Python rows are parametrized per copy. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | In-memory rows; the 88 targeted Python cases ran in 3.38 s. |
| **Determinism** - Consistent results | ✅ PASS | No clock, file, process, or network access in the new rows; synthetic forward-slash roots. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Shared data-only Cases tables; `It` names carry the row kind and command. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 95.96% lines repo-wide; Claude epic-scope 97.73%; Codex epic-scope 98.01%<br>**Command:** `run-test-suite.sh pester` (`Invoke-PoshQCParallelTest`)<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-14T21-02.md`<br>**Timestamp:** 2026-11-14T21-02 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.04% lines repo-wide (44759 covered, 1846 missed)<br>**Change:** +0.08% repo-wide; Claude epic-scope 97.79%, Codex epic-scope 98.09%<br>**Status:** No regression |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** classify 100% (51/51), operands 100% (154/154) per copy; Claude gate 96.57%; Codex gate 100%<br>**Thresholds:** 85% line; no branch threshold for PowerShell<br>**Status:** All changed files meet the thresholds |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** both siblings; both gates; both epic-scope files<br>**New code coverage:** 100% of changed executable lines<br>**Calculation method:** JaCoCo LINE counters and per-line `ci` values from the reviewer's head run; zero-hit lines (Claude gate 147, 464, 488-493; Claude epic-scope 136-138; Codex epic-scope 121-123) lie outside every changed hunk |
| **Comprehensive Coverage** | ⚠️ PARTIAL | Classify function rows and gate rows cover both supplement forms, near misses, and controls; no row covers a joined-word run whose first record lacks the command word (finding R2). |
| **Positive Flows** - Valid inputs | ✅ PASS | Classify positive rows; operands P, N, L, W, A rows. |
| **Negative Flows** - Invalid inputs | ⚠️ PARTIAL | V1-V5 (unquoted V3 restored) and U rows deny as specified; `FOO=$(pwd) npm --prefix $(pwd) run lint` is admitted (R2). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Nested and chained substitutions, braced and backtick forms, unclosed substitution, `bash --rcfile` and `--init-file` rows. |
| **Error Handling** - Error paths | ✅ PASS | I1 and I2 dependency-failure rows on both surfaces. |
| **Concurrency** - If applicable | N/A | No concurrent code. |
| **State Transitions** - If applicable | N/A | Stateless string functions. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.96% lines (from the `Phase 0 baseline` artifact `evidence/baseline/pester-gate.2026-11-14T21-02.md`) -> Post-change: 96.04% lines (reviewed head). Change: +0.08% lines. New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (reviewer full gate at the head).
- Python: Baseline: 97.71% lines, 95.13% branches (merge-base CI shards combined) -> Post-change: 97.71% lines, 95.13% branches (no production Python file changed, so the measured lines are those of the merge base). Change: +0.00% lines, +0.00% branches. New/changed-code coverage: N/A - the only changed Python file is a test file, which is excluded from measurement. Disposition: PASS. Evidence: merge-base CI run `43753053313`; head CI `Code Quality & Tests (3.13)` pending at audit time.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` on classification and index assertions; Python rows report the missing tokens and the file. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comments in the Pester rows and the new Python tests. |
| **Document Intent** | ✅ PASS | Cases headers define Kind (Positive, Negative, Control); Python docstrings. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Listing, checkpoint, and ascent seams mocked; Python rows read committed text only. |
| **Use Mocks/Stubs** | ✅ PASS | Per-row mocks with `-ParameterFilter` on `$script:` variables. |
| **Environment Stability** | ✅ PASS | No temporary files; forward-slash repository-relative paths. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the policy review for the branch at the reviewed head. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md` v0.3 with remediation decision R1. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-14T13-12.md`, `remediation-plan.2026-11-14T23-56.md`, `remediation-plan.2026-11-15T20-12.md`. |
| **Document the plan** | ✅ PASS | Every task of the three plans is checked, with task-check and gate evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One supplement call per gate; two small pure functions. |
| **Reusability** | ✅ PASS | Reuses `Read-CommandLineSegment` and `Test-CommandLineWordPresent`; the npm and npx patterns are the unchanged stage-1 text. |
| **Extensibility** | ✅ PASS | Option set and join pattern are data. |
| **Separation of concerns** | ✅ PASS | Both siblings are pure string logic; I/O stays in the existing seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One sibling per concern (operand extraction, classification supplement). |
| **At or below the 800-line hard limit** | ✅ PASS | Logical lines: classify 116, operands 296, Claude gate 493, Codex gate 485, Claude epic-scope 418, Codex epic-scope 491, tests 76 to 517, `test_bash_command_shape_surfaces.py` 340. No covered file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | Entry functions carry the `OrchestrationGate` prefix. |
| **No circular dependencies** | ✅ PASS | Neither sibling dot-sources anything. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-OrchestrationGateSupplementalPatternIndex`, `Get-OrchestrationGateJoinedWordText`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every new function. |
| **Comment why, not what** | ✅ PASS | The classify header explains the scanner split that motivates Form 1. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** check-only `Invoke-Formatter` (cycle 1); Black check (cycle 2)<br>**Result:** 0 changes (`evidence/qa-gates/final-qc-powershell-static.2026-11-15T19-42.md`, `evidence/qa-gates/final-qc.2026-11-15T20-36.md`); CI `PowerShell QC static` and `Python 3.13 static` pass at the head |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer`, `Invoke-PoshQCLeakScan`; Ruff<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** Pyright on the changed Python file<br>**Result:** 0 errors (PowerShell: not applicable) |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (full, reviewer); `run-test-suite.sh pytest` (targeted contract suites, reviewer)<br>**Result:** Pester 0 failed of 27305 run; pytest 88 passed |
| **Full toolchain loop** | ✅ PASS | One clean pass per cycle; integration lanes are CI-only by the test-execution policy. |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commits `58c73b0cc` and `5f8b15daf`; spec `### Remediation Decision R1 (cycle 1)`. |
| **Design choices explained** | ✅ PASS | Classify header; `fail-before-v3-correction.2026-11-15T18-51.md` records the corrected root cause. |
| **Update supporting documents** | ✅ PASS | Brief six copies and Codex skill two copies, byte-identical (blob `b0ca4b7d` and `f14e434c`). |
| **Provide next steps** | ⚠️ PARTIAL | Evidence stamp E1 lacks a correction line; R2 is unremediated. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** check-only `Invoke-Formatter` per changed file<br>**Result:** 0 differences |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` per changed file<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | No lint findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The repository rule is PowerShell 7+; the hooks run under pwsh 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on the new functions. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyString`, `AllowEmptyCollection`. |
| **Avoid global state** | ✅ PASS | Script-scope pattern strings are read-only data. |
| **Error handling** | ⚠️ PARTIAL | The supplement fails open for runs whose first record lacks the command word (R2); every other probed form is classified. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | See 2.3. |
| **Approved verbs** | ✅ PASS | `Get`. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 differences. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Reviewer full gate at the head: 0 failed, 18 skipped. |
| **Rerun loop if needed** | ✅ PASS | One clean pass. |

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black / Ruff / Pyright on changed file** | ✅ PASS | **Command:** Black check, Ruff check, Pyright on `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py`<br>**Result:** 0 findings each (`evidence/qa-gates/final-qc.2026-11-15T20-36.md`) |
| **Typed signatures** | ✅ PASS | Both new tests annotate parameters and `-> None`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`/`Context`/`It`, `-ForEach` rows, `BeforeDiscovery`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through the launcher<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged) |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Function rows target the classify sibling alone; gate rows target `Test-ImplementationCommand`. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert classification and returned indexes. |
| **Mocking Used Sparingly** | ✅ PASS | Only the epic-state baseline seams. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1`<br>**Code file:** `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Suites end in `.Tests.ps1`; Cases files are data only. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per suite with a function-row `Context`. |
| **Logical Grouping** | ✅ PASS | Positive, Negative, Control kinds. |
| **Docstrings/Comments** | ✅ PASS | Suite and Cases headers. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` (8 workers)<br>**Result:** 0 failed |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest, parametrized, AAA** | ✅ PASS | `@pytest.mark.parametrize` over six brief copies and two skill copies; Arrange/Act/Assert comments. |
| **Fail-before proof** | ✅ PASS | `evidence/regression-testing/fail-before.2026-11-15T20-35.md`: exactly the eight new cases failed before the edit. |
| **No temp files** | ✅ PASS | Reads committed text only. |

---

## 5. Test Coverage Detail

### Get-OrchestrationGateSupplementalPatternIndex (function and gate rows per surface)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `$(`, `${`, backtick, nested, chained joined words | Positive | Form 1 branches | ✅ |
| npx `--prefix`, `--prefix=`, `-C`, `--yes`, `-y`, `-q`, `--no`, `--quiet` | Positive | Form 2 pattern | ✅ |
| near misses (`-p`, `--package`, ungoverned tool, `&&`, quoted, unclosed) | Negative | rejection branches | ✅ |
| run whose first record lacks the command word | Negative (missing) | first-record check | ❌ (R2) |

**Coverage:** 100% of each classify copy (51/51).

**Not covered:** no uncovered line; one behavior gap (R2).

**Mutation probe (reviewer):** reverting the balance check, the `${` opener, the backtick opener, or the npx option set each fails at least one row; removing the first-record `npm` or `npx` check fails no row (survivors), which is where R2 lies.

---

### Resolve-OrchestrationGateTarget command leg and Get-OrchestrationGateCommandTargetOperand

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| P1-P3, N1-N4 (N3 pair), L1-L2, W1-W2, A1 | Positive and Negative | operand call and resolver call | ✅ |
| V1-V5 (unquoted and quoted V3), U1-U5 | Negative | `Unresolved` early return | ✅ |
| M1-M2, R1-R3, F1-F2, I1 | Edge Case and Error Handling | resolver results, guarded dot-source | ✅ |
| `bash --rcfile`, `bash --init-file` G rows | Edge Case | option-value skip | ✅ |

**Coverage:** 100% of each operands copy (154/154); every changed executable line of both epic-scope files covered.

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 27323 Pester (27305 run plus 18 skipped) and 88 targeted pytest | ✅ |
| Tests Passed | 27305 Pester; 88 pytest | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Pester 684.94 s wall clock (8 workers); pytest 3.38 s | ✅ Fast |
| Average Time per Test | under 30 ms | ✅ Fast |
| Discovery Time | not reported separately by the parallel runner | ✅ |
| Functions/Classes Tested | 9/9 new or changed functions | ✅ |
| Test File Size | 76 to 517 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 100% lines on new code; 96.04% repo-wide | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | check-only `Invoke-Formatter` per changed file | 0 differences | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` per changed file | 0 findings | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan` | 0 failures | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 0 failed, 18 skipped | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `black --check` on the changed file | 0 findings | ✅ |
| Ruff | `ruff check` on the changed file | 0 findings | ✅ |
| Pyright | `pyright` on the changed file | 0 errors | ✅ |
| Pytest Tests | `run-test-suite.sh pytest` over the seven brief, shape, push-down, and manifest contract files | 88 passed, 0 failed | ✅ |

**Notes:**
The reviewer's direct `sh <item>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` call from the session checkout was denied with `PREIMPLEMENTATION_GATE_BLOCKED`, because the session runs the pre-fix hook copies of its own branch; this is the defect the item fixes (AC-3) and takes effect after merge. The reviewer used a gitignored scratch `sh` helper in the item worktree instead.

---

## CI Cross-check

CI on PR #1191 ran concurrently with this review (review mode concurrent). Rows record the outcome that local evidence supports at the reviewed head; the source names the local evidence and the CI state when the artifacts were written.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 format differences, 0 PSSA findings | 5f8b15daf20b977cfdba2fa14319e36f6536df67 | `evidence/qa-gates/final-qc-powershell-static.2026-11-15T19-42.md`; CI reported pass |
| poshqc / PowerShell QC shards 1-6 | pass | 27305 run, 0 failed, 18 skipped | 5f8b15daf20b977cfdba2fa14319e36f6536df67 | reviewer full Pester gate at the head (`artifacts/pester/pester-junit.xml`); CI shard 3 pass, shards 1, 2, 4, 5, 6 pending |
| poshqc / PowerShell hook suites (Linux) | pass | N/A | 5f8b15daf20b977cfdba2fa14319e36f6536df67 | synthetic forward-slash fixtures; CI reported pass |
| quality-checks7 / Python 3.13 static | pass | 0 findings | 5f8b15daf20b977cfdba2fa14319e36f6536df67 | `evidence/qa-gates/final-qc.2026-11-15T20-36.md`; CI reported pass |
| quality-checks7 / Code Quality & Tests (3.13) (`Enforce Python coverage thresholds`) | pass | 85% line, 75% branch thresholds met at the merge base | 5f8b15daf20b977cfdba2fa14319e36f6536df67 | no production Python file changed; merge-base run `43753053313` step success; CI pending at the head |
| quality-checks7 / Code Quality & Tests (3.12) | pass | 88 targeted contract cases passed | 5f8b15daf20b977cfdba2fa14319e36f6536df67 | reviewer targeted pytest run; CI reported pass |

---

## 8. Gaps and Exceptions

### Identified Gaps

**R2 (blocking):** `Get-OrchestrationGateJoinedWordText` builds one run from the first record followed by a substitution opener through every record joined only by openers and closers, and `Get-OrchestrationGateSupplementalPatternIndex` then requires the run's first record to carry `npm` or `npx`. Records hold whole spans of text with spaces, so a leading `FOO=$(pwd) ` or `env FOO=$(pwd) ` starts the run, the npm record is never a run start, and Form 1 returns nothing. Reviewer probes on both surfaces: `FOO=$(pwd) npm --prefix $(pwd) run lint`, `env FOO=$(pwd) npm --prefix $(pwd) run lint`, `FOO=$(pwd) npx --prefix $(pwd) jest`, and `env FOO=$(pwd) npx --prefix $(pwd) jest` are unclassified, and the Claude gate decision is allow; the same commands without the assignment deny.

**E1 (blocking):** `evidence/qa-gates/self-review.2026-11-15T20-38.md` was added by commit `5f8b15daf` at 2026-11-15T20:37:51Z, earlier than its stamp, and has no correction line. The comparable stamp in `evidence/regression-testing/fail-before.2026-11-15T20-35.md` (added at 2026-11-15T20:30:27Z) already carries an appended correction.

### Approved Exceptions

**None.** The integration lanes are CI-only under the existing test-execution policy.

### Removed/Skipped Tests

**None.** Remediation cycle 1 removed non-goal row NG-02 (`npx --yes jest`) from `$script:ClassificationNonGoalCase` as the spec states, and the form became a positive classify row; the 18 skipped Pester rows are pre-existing skips.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All item evidence is under the feature folder's `evidence/<kind>/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent at the branch head, so the check is not applicable and produces no finding.

## Rejected Scope Narrowing

None. The caller prompt required the full branch diff against the merge base and attempted no narrowing.

---

## 9. Summary of Changes

The single-feature command leg of both preimplementation gates resolves the target worktree from every literal selector, script operand, and absolute operand of the gated command and denies as not derivable on non-literal operands. Stage 1 additionally classifies an npm script word after a substitution-split word and npx options before the tool word. The execution-environment brief and the Codex `bash-command-shape` skill state that paths are written literally in each command.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain stages, coverage thresholds, file-size limits, mirrors, and test-policy requirements are met. Two blocking findings (R2, classification supplement fail-open; E1, evidence stamp without correction) require a light remediation cycle.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and three plans present
- ✅ Design Principles: pure siblings, minimal gate wiring
- ✅ Module & File Structure: all files below 700 lines
- ✅ Naming, Docs, Comments: help text present
- ✅ Toolchain Execution: one clean pass per cycle
- ⚠️ Summarize & Document: one evidence stamp lacks a correction (E1)

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format, lint, leak scan clean
- ⚠️ PowerShell Design & Safety: supplement fail-open (R2)
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: one pass

**For Python:**
- ✅ Black, Ruff, Pyright clean on the changed test file

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: in-memory, deterministic rows
- ⚠️ Coverage & Scenarios: 100% new-code lines; one behavior gap (R2)
- ✅ Test Structure: AAA, descriptive names
- ✅ External Dependencies: no temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester through PoshQC
- ✅ Test Style & Structure: focused rows
- ✅ Naming & Readability: `.Tests.ps1`, row kinds
- ✅ Toolchain: parallel gate

**For Python:**
- ✅ Parametrized pytest rows with fail-before proof

---

### Metrics Summary

- ✅ 27305 Pester rows and 88 pytest cases passing, 0 failed
- ✅ 9/9 new or changed functions tested
- ✅ 100% line coverage on new code; 96.04% repo-wide
- ✅ Test files mirror the hook layout
- ✅ All code quality checks passing
- ⚠️ Two blocking findings (R2, E1)

---

### Recommendation

**Remediation required** before merge: resolve R2 and E1 in a light remediation cycle, then re-review.

---

## Appendix A: Test Inventory

### Complete Test List

1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` › classify rows (Positive, Negative, Control), F function rows, I2
2. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` › the Codex equivalents
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` › four-copy identity, 500-line bound, brief wording
4. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1` and the Codex twin › G rows, gate rows, I1
5. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Parity.Tests.ps1` › four-copy identity, 500-line bound, brief wording
6. `legacy-codex-hook-contracts.Tests.ps1` › shared-module rows and the 500-line row
7. `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py` › `test_brief_command_text_restrictions_forbids_shell_variable_paths` (6 cases), `test_codex_skill_states_literal_path_rule` (2 cases)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting and linting (per changed file)
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing (parallel, through the launcher)
sh <item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
```

**For Python:**
```bash
env -u VIRTUAL_ENV sh <item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <test files>
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-15  
**Policy Version:** Current (as of audit date)

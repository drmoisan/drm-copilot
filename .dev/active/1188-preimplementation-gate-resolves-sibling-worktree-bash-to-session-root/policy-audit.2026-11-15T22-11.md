# Policy Compliance Audit: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188), re-audit at head 861fecb75 with owner-accepted deviation DEV-R3

---

**Audit Date:** 2026-11-15  
**Code Under Test:** merge base `38f87bc2c4bab54be8121ee546f9eb0dc92272ee` of the base branch `main` (equal to `origin/main` after `git fetch` at review time) and reviewed head `861fecb753d0befcf2907e094196d9e2a404c4d1` (PR #1191); the diff between them lists the changed files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 30 files (4 copies each of the operands and classify siblings; both gates and both epic-scope files with bundle copies; 10 test files) | 27341 tests | 27323 run, 0 failed, 0 errors, 18 skipped | 95.96% lines | 96.04% lines (reviewer gate); 96.13% lines (CI merged report, run `43764064186`) | 100% lines (operands 154/154 and classify 61/61 per copy; every changed executable line of the gates and epic-scope files covered) |
| Python | 1 file (test file `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py`; no production Python file) | CI Python jobs | CI `Code Quality & Tests` 3.11, 3.12, 3.13 pass | 97.71% lines, 95.13% branches (merge-base CI shards combined) | 97.71% lines, 95.13% branches (CI shards of run `43764064186` combined by the reviewer) | N/A - no new or modified production Python file |
| JSON | 2 files (pack manifests) | N/A | N/A | N/A (configuration) | N/A (configuration) | N/A |
| Markdown | skill and brief copies, promoted potential, feature folder documents and evidence | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Python baseline coverage artifact: merge-base CI run `43753053313` artifacts `python-coverage-shard-1` and `python-coverage-shard-2` (35087/35910 lines, 13022/13688 branches), as recorded by the earlier reviews
- Python post-change coverage artifact: CI run `43764064186` (head `06f085b30`, whose non-documentation tree equals the reviewed head) artifacts `python-coverage-shard-1` and `python-coverage-shard-2`, downloaded with `gh run download` and combined by the reviewer with the repository report settings: 35087/35910 lines (97.71%), 13022/13688 branches (95.13%); no local `artifacts/python/lcov.info` exists
- C# baseline coverage artifact: N/A - zero changed C# files
- C# post-change coverage artifact: N/A - zero changed C# files
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/evidence/baseline/pester-gate.2026-11-14T21-02.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, written by the previous reviewer's full Pester gate at `06f085b30` (ended 2026-11-15T21:44Z); `git diff --quiet 06f085b30 861fecb75 -- . ':!docs'` exits 0, so it describes the reviewed head; cross-checked against the CI merged `powershell-coverage.xml` of run `43764064186`
- Per-language comparison summary: section 1.2.1 below

---

## Executive Summary

This re-audit covers the reviewed head `861fecb75`. The only commit after `06f085b30` adds the previous review set inside the feature folder; the non-documentation tree is byte-identical to `06f085b30`, and `origin/main` has not moved from the merge base.

Scope: the full branch diff (111 files). PowerShell and Python have changed files; Python's only changed file is a test file. TypeScript, C#, and bash have zero changed files.

The reviewer verified at the head: four-copy byte identity of the classify sibling (blob `f15f48929`) and the operands sibling (blob `802f0449f`); coverage from the previous reviewer gate and from the CI merged reports of run `43764064186`; the evidence-location validator (exit 0); CI run `43764064186` on `06f085b30` (29 jobs, all success, including PowerShell QC shard 5, which was pending at the previous audit) and CI run `43766284142` on `861fecb75` (success; documentation-only change scope, heavy jobs skipped).

Finding R3 from `remediation-inputs.2026-11-15T21-47.md` (absent Negative rows for four cycle 3 guards) is recorded as the owner-accepted non-blocking deviation DEV-R3 under owner directive OD-2 (class `accept_nonblocking_deviation`). The reviewer re-ran the reverted-mutant probe at the head: the head leaves `` echo `npm --version` lint `` and `echo $(echo npm --version) lint` unclassified and returns no supplement index for `FOO=$(echo npx jest) ls` or `FOO=$(echo npm x lint) npm --version`, so the behavior is correct. A regression of those guards would newly classify a mention form and deny it, which is the fail-closed direction for this gate. The rows are tracked in a coordinator-filed follow-up issue together with the `sh -c` / `pwsh -Command` stage-1 classification gap.

No blocking finding remains.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ⚠️ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`): negative-flow rows absent for four cycle 3 guards, accepted as deviation DEV-R3 (non-blocking)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on the base branch; `.claude/hooks` and `.codex/hooks` are classified; the branch adds no project folder)

**Language-specific policies evaluated:**
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (one test file)
- N/A Bash: no bash file in the branch diff (reviewer and executor helper scripts are gitignored under `artifacts/`)
- ✅ JSON: two pack manifests, covered by the manifest completeness suites

**Temporary artifacts cleanup:**
- ✅ Reviewer probe scripts live in the gitignored `artifacts/scratch-issue-1188/` folder of the item worktree; CI downloads are in the session scratchpad; none is tracked
- ✅ No ongoing tooling script was added
- Reviewer-created files: this review set and two owner-directive decision files; no existing evidence was edited

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Per-row mocks; script-scope state reset; the classify and operands suites pass inside the eight-worker parallel gate and the six CI shards. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One function row or gate row per form. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | In-memory rows; full gate 659.64 s wall clock on eight workers. |
| **Determinism** - Consistent results | ✅ PASS | No clock, file, process, or network access in the new rows. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Shared data-only Cases tables; the cycle 3 rows carry a comment naming the form. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 95.96% lines repo-wide; Claude epic-scope 97.73%; Codex epic-scope 98.01%<br>**Command:** `run-test-suite.sh pester` (`Invoke-PoshQCParallelTest`)<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-14T21-02.md`<br>**Timestamp:** 2026-11-14T21-02 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.04% lines repo-wide (44785 covered, 1846 missed; reviewer gate); CI merged report 96.13% (44826 covered, 1805 missed)<br>**Change:** +0.08% repo-wide; Claude epic-scope 97.79%, Codex epic-scope 98.09%<br>**Status:** No regression |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** classify 100% (61/61), operands 100% (154/154) per copy; Claude gate 96.57% (169/175); Codex gate 100% (180/180)<br>**Thresholds:** 85% line; no branch threshold for PowerShell<br>**Status:** All changed files meet the thresholds |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** both siblings; both gates; both epic-scope files<br>**New code coverage:** 100% of changed executable lines<br>**Calculation method:** JaCoCo LINE counters and per-line `ci` values from the reviewer's head run, matched by the CI merged report; the zero-hit lines lie outside every changed hunk |
| **Comprehensive Coverage** | ⚠️ PARTIAL | Every line of the cycle 3 code executes; four mutants of it survive the row tables. Accepted as deviation DEV-R3 (non-blocking, OD-2). |
| **Positive Flows** - Valid inputs | ✅ PASS | Classify positive rows including the four leading-assignment forms; operands P, N, L, W, A rows. |
| **Negative Flows** - Invalid inputs | ⚠️ PARTIAL | No Negative row exercises the backtick arm of the unclosed-substitution filter or the member word checks. Accepted as deviation DEV-R3 (non-blocking, OD-2). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Nested and chained substitutions, braced and backtick forms, unclosed substitution, leading assignments. |
| **Error Handling** - Error paths | ✅ PASS | I1 and I2 dependency-failure rows on both surfaces. |
| **Concurrency** - If applicable | N/A | No concurrent code. |
| **State Transitions** - If applicable | N/A | Stateless string functions. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.96% lines (from the `Phase 0 baseline` artifact `evidence/baseline/pester-gate.2026-11-14T21-02.md`) -> Post-change: 96.04% lines (reviewed head). Change: +0.08% lines. New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` (reviewer full gate on the identical non-documentation tree) and the CI merged report of run `43764064186` (96.13%).
- Python: Baseline: 97.71% lines, 95.13% branches (merge-base CI shards combined) -> Post-change: 97.71% lines, 95.13% branches (head CI shards combined). Change: +0.00% lines, +0.00% branches. No production Python file changed; the only changed Python file is a test file, which is excluded from measurement. Disposition: PASS. Evidence: merge-base CI run `43753053313`; head CI run `43764064186` artifacts `python-coverage-shard-1` and `python-coverage-shard-2`; `Enforce Python coverage thresholds` (`--min-line 85 --min-branch 75`) passed in `Code Quality & Tests (3.13)`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` on classification and index assertions. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comments in the Pester rows and the Python tests. |
| **Document Intent** | ✅ PASS | Cases headers define Kind (Positive, Negative, Control). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Listing, checkpoint, and ascent seams mocked. |
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
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md` with remediation decision R1. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-14T13-12.md`, two remediation plans, and the light-cycle tasks in `remediation-inputs.2026-11-15T20-57.md`. |
| **Document the plan** | ✅ PASS | All plan and light-cycle tasks are checked, with fail-before and gate evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The siblings are pure string functions wired into the gates by a guarded dot-source. |
| **Reusability** | ✅ PASS | Reuses `Test-CommandLineWordPresent` and the existing npm and npx patterns. |
| **Extensibility** | ✅ PASS | Patterns and the join set stay data. |
| **Separation of concerns** | ✅ PASS | The siblings stay pure string logic. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One sibling per concern. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical lines (unchanged since the previous review): classify 133, operands 296, Claude gate 493, Codex gate 485, Claude epic-scope 418, Codex epic-scope 491, tests 76 to 517, `test_bash_command_shape_surfaces.py` 340. No covered file at or above 700 lines; `config/file-size-baseline.json` unchanged (`git diff --name-only` lists no change). |
| **Public vs internal** | ✅ PASS | Entry functions carry the `OrchestrationGate` prefix. |
| **No circular dependencies** | ✅ PASS | Neither sibling dot-sources anything. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Member`, `Tail`, `memberOffset`. |
| **Docs/docstrings** | ✅ PASS | Header and help text describe the member evaluation in all four copies. |
| **Comment why, not what** | ✅ PASS | One comment states why a member inside an unclosed substitution is skipped. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** check-only `Invoke-Formatter`<br>**Result:** 0 differences (`evidence/qa-gates/cycle3-powershell-static.2026-11-15T21-27.md`); CI `PowerShell QC static` success on `06f085b30` |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer`, `Invoke-PoshQCLeakScan`<br>**Result:** 0 findings, 0 leak failures |
| **3. Type checking** | N/A | Not applicable for PowerShell; no Python production change |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (full, previous reviewer, identical non-documentation tree)<br>**Result:** 0 failed of 27323 run; CI shards 1-6 success |
| **Full toolchain loop** | ✅ PASS | One clean pass in cycle 3 (`cycle3-pester-gate.2026-11-15T21-27.md`); integration lanes are CI-only by the test-execution policy. |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages state each change; review records committed in `861fecb75`. |
| **Design choices explained** | ✅ PASS | Header text in all four copies. |
| **Update supporting documents** | ✅ PASS | Task checkboxes ticked; AC-1 to AC-15 checked. |
| **Provide next steps** | ✅ PASS | DEV-R3 names the follow-up rows. |

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
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` present. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyString`, `AllowEmptyCollection`. |
| **Avoid global state** | ✅ PASS | Script-scope pattern strings are read-only data. |
| **Error handling** | ✅ PASS | Non-literal operands deny `TARGET_WORKTREE_NOT_DERIVABLE`; a failed sibling dot-source denies naming the file. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | See 2.3. |
| **Approved verbs** | ✅ PASS | `Get`, `Resolve`, `Test`. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 differences. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Full gate 0 failed, 18 skipped; CI shards success. |
| **Rerun loop if needed** | ✅ PASS | One clean pass. |

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black / Ruff / Pyright on changed file** | ✅ PASS | **Command:** Black check, Ruff check, Pyright on `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py`<br>**Result:** 0 findings each (`evidence/qa-gates/final-qc.2026-11-15T20-36.md`); CI `Python 3.13 static` success |
| **Typed signatures** | ✅ PASS | The tests annotate parameters and `-> None`. |

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
| **Pytest, parametrized, AAA** | ✅ PASS | `@pytest.mark.parametrize` over the brief and skill copies. |
| **Fail-before proof** | ✅ PASS | `evidence/regression-testing/fail-before.2026-11-15T20-35.md`. |
| **No temp files** | ✅ PASS | Reads committed text only. |

---

## 5. Test Coverage Detail

### Get-OrchestrationGateSupplementalPatternIndex and Get-OrchestrationGateJoinedWordText (function and gate rows per surface)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `$(`, `${`, backtick, nested, chained joined words | Positive | Form 1 branches | ✅ |
| leading assignment and `env` assignment before npm and npx (cycle 3) | Positive | member loop | ✅ |
| npx `--prefix`, `--prefix=`, `-C`, `--yes`, `-y`, `-q`, `--no`, `--quiet` | Positive | Form 2 pattern | ✅ |
| `echo $(npm --version) lint` | Negative | `$(` arm of the unclosed-substitution filter | ✅ |
| npm inside a backtick substitution; npm mentioned inside a substitution; npm pattern only in an earlier excluded member | Negative (absent) | backtick arm of the filter, member word checks, member tail | ⚠️ DEV-R3 (accepted, non-blocking) |

**Coverage:** 100% of each classify copy (61/61).

**Not covered:** no uncovered line; four surviving mutants (DEV-R3).

**Mutation probe (reviewer rerun at the head, reverted, in memory):** `artifacts/scratch-issue-1188/review-r5-probe2.ps1` gives the same results as the previous review: the head returns no index for the four DEV-R3 commands and leaves the two mention forms unclassified; N2, N5, N6, and N7 each change one of them.

---

### Resolve-OrchestrationGateTarget command leg and Get-OrchestrationGateCommandTargetOperand

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| P1-P3, N1-N4 (N3 pair), L1-L2, W1-W2, A1 | Positive and Negative | operand call and resolver call | ✅ |
| V1-V5 (unquoted, quoted, and leading-assignment V3), U1-U5 | Negative | `Unresolved` early return | ✅ |
| M1-M2, R1-R3, F1-F2, I1 | Edge Case and Error Handling | resolver results, guarded dot-source | ✅ |
| `bash --rcfile`, `bash --init-file` G rows | Edge Case | option-value skip | ✅ |

**Coverage:** 100% of each operands copy (154/154); every changed executable line of both epic-scope files covered.

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 27341 Pester (27323 run plus 18 skipped) | ✅ |
| Tests Passed | 27323 Pester | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Pester 659.64 s wall clock (8 workers) | ✅ Fast |
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
| Pytest Tests | CI `Code Quality & Tests` 3.11, 3.12, 3.13 | success | ✅ |

**Notes:**
The reviewer did not rerun the toolchain: no non-documentation file changed after `06f085b30`, which the previous reviewer gate and CI run `43764064186` measured.

---

## CI Cross-check

CI state read with `gh pr checks 1191` and `gh run view` at 2026-11-15T22-11. Run `43766284142` on the reviewed head classified the change scope as documentation-only and skipped the heavy jobs, so the code checks rely on run `43764064186` on `06f085b30`, whose non-documentation tree is byte-identical to the reviewed head. Rows record the outcome that local evidence supports.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| CI Required Gate | pass | N/A | 861fecb753d0befcf2907e094196d9e2a404c4d1 | `gh pr checks 1191`, run `43766284142` |
| poshqc / PowerShell QC static | pass | 0 format differences, 0 PSSA findings | 06f085b30b352deb006126a4053cb2f39e26a37c | `evidence/qa-gates/cycle3-powershell-static.2026-11-15T21-27.md`; run `43764064186` success |
| poshqc / PowerShell QC shards 1-6 | pass | merged report 96.13% lines (44826/46631) | 06f085b30b352deb006126a4053cb2f39e26a37c | run `43764064186` artifact `poshqc-test-results`; reviewer gate 27323 run, 0 failed |
| poshqc / PowerShell hook suites (Linux) | pass | N/A | 06f085b30b352deb006126a4053cb2f39e26a37c | run `43764064186` success |
| quality-checks7 / Python 3.13 static | pass | 0 findings | 06f085b30b352deb006126a4053cb2f39e26a37c | `evidence/qa-gates/final-qc.2026-11-15T20-36.md`; run `43764064186` success |
| quality-checks7 / Code Quality & Tests (3.13) (`Enforce Python coverage thresholds`) | pass | 97.71% lines, 95.13% branches | 06f085b30b352deb006126a4053cb2f39e26a37c | shards `python-coverage-shard-1`/`-2` combined by the reviewer; run `43764064186` success |
| quality-checks7 / Code Quality & Tests (3.11, 3.12) | pass | N/A | 06f085b30b352deb006126a4053cb2f39e26a37c | run `43764064186` success |
| docs-validation / Documentation Validation | pass | N/A | 861fecb753d0befcf2907e094196d9e2a404c4d1 | run `43766284142` success |

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap remains.

### Approved Exceptions

**DEV-R3 (owner-accepted, non-blocking).** Previous finding R3: four guards added in cycle 3 (the backtick arm of the unclosed-substitution filter, the member-tail npm match, and the member `npm` and `npx` word checks in `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` and its three copies) have no discriminating Negative row; reverted mutants N2, N5, N6, and N7 fail no row. Accepted by owner directive OD-2 (class `accept_nonblocking_deviation`). Basis for the non-blocking severity, verified by the reviewer at the head: the behavior is correct for every probed form, every guard line executes (100% line coverage), and a regression would newly classify a mention form and deny it, which fails closed. The six rows are tracked in a coordinator-filed follow-up issue together with the `sh -c` / `pwsh -Command` stage-1 classification gap. The integration lanes are CI-only under the existing test-execution policy.

### Removed/Skipped Tests

**None.** The 18 skipped Pester rows are pre-existing skips.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All item evidence is under the feature folder's `evidence/<kind>/`. Commit `861fecb75` adds only the four previous review records; no evidence file was edited or removed.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent at the branch head, so the check is not applicable and produces no finding.

## Rejected Scope Narrowing

None. The caller prompt required the full branch diff against the merge base and attempted no narrowing. The caller's instruction to record R3 as the owner-accepted deviation DEV-R3 concerns finding severity, not audit scope; the reviewer applied it after re-verifying the head behavior and records the basis above.

---

## 9. Summary of Changes

The single-feature command leg of both preimplementation gates resolves the target worktree from every literal selector, script operand, and absolute operand of the gated command and denies as not derivable on non-literal operands. Stage 1 additionally classifies an npm script word after a substitution-split word (from any top-level member of the joined word, so a leading assignment does not hide it) and npx options before the tool word. The execution-environment brief and the Codex `bash-command-shape` skill state that paths are written literally in each command.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT (one owner-accepted non-blocking deviation, DEV-R3)

Toolchain stages, coverage thresholds, file-size limits, mirrors, evidence rules, and CI are met. The only open item is DEV-R3, accepted as non-blocking under OD-2 and tracked in a follow-up issue.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plans, and light-cycle tasks present
- ✅ Design Principles: pure siblings, minimal gate wiring
- ✅ Module & File Structure: all files below 700 lines
- ✅ Naming, Docs, Comments: help text in all four copies
- ✅ Toolchain Execution: one clean pass in cycle 3; CI success
- ✅ Summarize & Document: records committed

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format, lint, leak scan clean
- ✅ PowerShell Design & Safety: fail-closed on non-literal operands
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: one pass

**For Python:**
- ✅ Black, Ruff, Pyright clean on the changed test file

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: in-memory, deterministic rows
- ⚠️ Coverage & Scenarios: 100% new-code lines; four surviving mutants accepted as DEV-R3
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

- ✅ 27323 Pester rows passing, 0 failed
- ✅ 9/9 new or changed functions tested
- ✅ 100% line coverage on new code; 96.04% repo-wide
- ✅ Test files mirror the hook layout
- ✅ All code quality checks passing
- ⚠️ One owner-accepted non-blocking deviation (DEV-R3)

---

### Recommendation

**Ready to merge** on the green CI of PR #1191. Add the DEV-R3 rows in the coordinator-filed follow-up issue.

---

## Appendix A: Test Inventory

### Complete Test List

1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` › classify rows (Positive, Negative, Control), function rows, I2
2. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` › the Codex equivalents
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` › four-copy identity, 500-line bound, brief wording
4. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1` and the Codex twin › G rows, gate rows (including the leading-assignment V3 row), I1
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

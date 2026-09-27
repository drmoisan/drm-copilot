# Policy Compliance Audit: Gate-suite epic-state isolation (#709)

---

**Audit Date:** 2026-09-27  
**Code Under Test:** `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` (new, 432 lines); two-line insertions in `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`; 36 Markdown files under `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 8 files (all test files; 0 production files) | 5452 tests (full configured run) | ✅ 5452 pass, 0 fail, 9 skipped | 95.27% cmds repo-wide; 90.38% lines EpicScopeResolution.psm1 | 95.28% cmds and 96.04% lines repo-wide; 91.35% lines EpicScopeResolution.psm1 | N/A (0 production lines changed; test files are outside the coverage denominator) |
| Markdown | 36 files | N/A | N/A (documentation) | N/A (documentation) | N/A (documentation) | N/A |

No TypeScript, Python, C#, Bash, or JSON file is changed on the branch.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch
- PowerShell baseline coverage artifact: `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/coverage-epic-scope-baseline.2026-09-27T10-06.md` and `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/pester-full-baseline.2026-09-27T10-06.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-09-27 10:19 by the final full run) and `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/coverage-epic-scope.2026-09-27T10-20.md`
- Per-language comparison summary: section 1.2.1 of this audit

---

## Executive Summary

The branch is a test-only fix for issue #709. Seven Pester suites for the gate-1, gate-3, and gate-4 hooks reached `Resolve-EpicScopeCheckpoint` in `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` without mocking its read seam, so a leftover gitignored `artifacts/orchestration/epic-orchestrator-state.json` could change their results. Each suite gains a two-line insertion in its outermost `BeforeAll`, directly after the hook load: an `Import-Module` of `EpicScopeResolution.psm1` without `-Force` and `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }`. One new file adds a structural guard (AST parse of the seven suites, plus nine predicate-discrimination rows) and a resolver-level seam-sufficiency proof (four control rows and four treatment rows over a hostile in-memory payload).

No production file, hook, library module, push-down mirror, workflow, or settings file is changed (verified with `git diff --name-status origin/main...HEAD`). No change weakens an enforcement hook or introduces a hook bypass.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md`
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A Bash (no Bash file changed)
- N/A JSON (no JSON file changed)

Toolchain evidence recorded by the executor shows one clean QA pass: format drift 0, PSScriptAnalyzer findings 0 on the eight changed files, targeted Pester 301 passed and 0 failed, full configured Pester 5452 passed and 0 failed. Fail-before evidence shows the structural guard failed seven rows (one per suite) before the suite edits. The reviewer verified coverage figures directly from `artifacts/pester/powershell-coverage.xml`. Findings: 0 Blocking, 0 Major, 2 Minor, and several Informational items (see section 8 and `code-review.2026-09-27T10-31.md`).

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; the executor's Route C runner scripts lived in the session scratchpad outside the repository.
- ✅ No ongoing tooling script was added.
- The reviewer regenerated `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (gitignored) because they were absent; both record head `52212212be05b6012d13eacec8198f27d12d9242`.

---

## Rejected Scope Narrowing

None detected. The caller prompt describes the scope as "a test-only change. Seven existing Pester suites under tests/scripts/claude-hooks/ gain a two-line insertion ... and one new file ... is added." That description matches the full branch diff against `origin/main` (merge-base `849aae609787172240c1ae7c33d10d6dd337d497`) and does not exclude any changed file or language. The instruction to treat AC4 as pending CI rather than FAIL concerns an acceptance-criterion verdict, not audit scope; the full feature-vs-base audit was performed.

## Evidence Location Compliance

- `git diff --name-status origin/main...HEAD` lists no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported path.
- All branch evidence is under `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/{baseline,other,qa-gates,regression-testing}/`, which are canonical kinds.
- The executor recorded `EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baselines/ replaced with docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/` for the AC5 baseline (spec text names the non-canonical `baselines/` form).

Result: PASS. No FAIL-level evidence-location finding.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The new file shares only read-only `$script:` values set in `BeforeAll`; hostile mocks are registered per `It` through `Set-HostileEpicSeam`, so control and treatment rows do not share mock state. The seven suite insertions add a `BeforeAll` mock that Pester removes when the block exits. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One structural row per suite path; one predicate row per non-compliant shape; one control and one treatment row per gate call shape. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Full configured run 176.68 s for 5452 tests versus 174.28 s baseline for 5428 tests (`evidence/qa-gates/pester-full.2026-09-27T10-20.md`, `evidence/baseline/pester-full-baseline.2026-09-27T10-06.md`). The new file performs seven AST parses and in-memory resolver calls. |
| **Determinism** - Consistent results | ✅ PASS | The purpose of the change is determinism: the seven suites no longer read gitignored epic state. The new file mocks every filesystem seam of `EpicScopeResolution` in the seam Describe and uses `/synthetic-worktrees/` roots; no clock, RNG, or sleep is used. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `It` names with `<Path>`, `<Name>`, and `<Gate>` templating; comment-based help at file head documents the D9 known limit and the hermeticity contract. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 95.27% commands repo-wide; `EpicScopeResolution.psm1` 90.38% lines (94 covered, 10 missed).<br>**Command:** `Invoke-PoshQCTest` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, then CR-COV over `artifacts/pester/powershell-coverage.xml`.<br>**Timestamp:** 2026-09-27 10:06 |
| **No Coverage Regression** | ✅ PASS | **Post-change:** 95.28% commands and 96.04% lines repo-wide (10224 of 10646 lines, reviewer-read from the report root `LINE` counter); `EpicScopeResolution.psm1` 91.35% lines (95 covered, 9 missed).<br>**Change:** +0.01 commands repo-wide; +0.97 lines on `EpicScopeResolution.psm1`.<br>**Status:** No regression. |
| **New Code Coverage** | N/A | No production line is added or changed; all eight changed PowerShell files are test files under `tests/`, which the coverage configuration excludes. |
| **Comprehensive Coverage** | ✅ PASS | The seam proof drives `Resolve-EpicScopeCheckpoint` through the no-mock (read) path and the `$null` seam path for all four call shapes, including the `-WorktreeSelector` branch. |
| **Positive Flows** - Valid inputs | ✅ PASS | Seven structural rows (compliant suites); two compliant-form predicate rows (positional and `-CommandName`/`-MockWith`); four control rows. **Total positive rows:** 13. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Six non-compliant predicate rows: wrong target command, no `-ModuleName`, non-`$null` body, mock only in nested `Context`, `Import-Module -Force`, and wrong order. **Total negative rows:** 6. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Missing listed suite path row; gate-4 selector variant; nested-`BeforeAll` placement. **Total edge-case rows:** 3 (overlapping the counts above). |
| **Error Handling** - Error paths | ✅ PASS | Treatment rows assert the `epic-checkpoint-absent-or-unparseable` short-circuit and zero calls to the HEAD and `MERGE_HEAD` probes. The guard's parse-error and no-outermost-`BeforeAll` branches have no dedicated predicate row (Minor finding CR-3 in the code review). |
| **Concurrency** - If applicable | N/A | No concurrent behavior under test. |
| **State Transitions** - If applicable | N/A | No stateful component under test. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.38% lines on `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (95.27% commands repo-wide) -> Post-change: 91.35% lines on the same module (95.28% commands, 96.04% lines repo-wide). Change: +0.97 lines on the module, +0.01 commands repo-wide. New/changed-code coverage: N/A (0 production lines changed). Disposition: PASS. Evidence: `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/coverage-epic-scope-baseline.2026-09-27T10-06.md`, `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/qa-gates/coverage-epic-scope.2026-09-27T10-20.md`, `artifacts/pester/powershell-coverage.xml`.

PowerShell has no branch-coverage gate (Pester measures command and line coverage only); no branch figure is evaluated. Repo-wide line coverage 96.04% is above the 85% threshold.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Structural rows assert `Should -Be 0 -Because ($findings -join '; ')`; each finding is prefixed with the repository-relative suite path. The fail-before record shows messages such as "enforce-pr-author-skill.TargetResolution.Tests.ps1: Mock of Get-EpicScopeCheckpointText missing from outermost BeforeAll". Control rows include the resolver reason in `-Because`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Predicate, control, and treatment rows carry explicit `# Arrange`, `# Act`, `# Assert` sections; the structural row combines arrange and act in one labelled line. |
| **Document Intent** | ✅ PASS | File-level comment-based help; per-Context comment explaining non-vacuity; helper functions carry one-line purpose comments. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, process spawn, or git invocation. Command strings containing `git` and `gh` are payload data only (lines 362-365). The structural guard reads committed suite files located from `$PSScriptRoot`. |
| **Use Mocks/Stubs** | ✅ PASS | Seam proof mocks `Find-WorktreeResolutionRoot`, `Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`, `Get-EpicScopeWorktreeHeadBranch`, `Test-EpicScopeMergeInProgress`, and (treatment) `Get-EpicScopeCheckpointText`, all in `EpicScopeResolution` scope. |
| **Environment Stability** | ✅ PASS | Reviewer grep of the new file for `TestDrive`, `TEMP`, `TemporaryFile`, `GetTemp`, `origin/`, drive-letter patterns, `Set-Content`, `Out-File`, `New-Item`, `Start-Process`, and `pwsh` found only the three payload strings and the header comment. No temporary file, no gitignored read, no `origin/main` dependency. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, `code-review.2026-09-27T10-31.md`, and `feature-audit.2026-09-27T10-31.md` form the review set. Outstanding item: AC4 CI half (pending the PR head CI run). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` state the objective (issue #709, source finding #663 CR-4). |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md` and `evidence/baseline/phase0-requirements-read.2026-09-27T09-58.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-09-26T22-55.md` (revised after two preflight rounds). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Two identical lines per suite; no helper file, no production seam (D1, D2). |
| **Reusability** | ✅ PASS | Follows the existing precedent in the three `*.EpicScope.Tests.ps1` suites. |
| **Extensibility** | ✅ PASS | The guard's path list is a `-ForEach` table; adding a suite is one row (D9 known limit recorded). |
| **Separation of concerns** | ✅ PASS | Pure AST helpers (`Get-EpicStateIsolationFinding` and siblings) are separate from the single file-reading helper `Get-EpicStateIsolationSuiteFinding`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The new file covers one concern: epic-state isolation of the gate suites. |
| **Under 500 lines** | ✅ PASS | New file 432; edited suites 113, 397, 394, 463, 334, 489, 225 (`evidence/qa-gates/suite-diff-numstat.2026-09-27T10-21.md`). |
| **Public vs internal** | N/A | Test-only change; no public API. |
| **No circular dependencies** | ✅ PASS | The new file imports only `EpicScopeResolution.psm1`; no module graph change. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-EpicStateIsolationMockBinding`, `Test-EpicStateIsolationNullBody`, `Set-HostileEpicSeam`, `Invoke-HostileEpicResolution`. |
| **Docs/docstrings** | ✅ PASS | File-level `.SYNOPSIS`, `.DESCRIPTION`, `.NOTES`; helper purpose comments. |
| **Comment why, not what** | ✅ PASS | For example, line 371 explains why this file uses `-Force` while the suites must not. Two pre-existing comments in the WorktreeResolution suites still say "three library modules" and are now one module short (Informational; the spec forbids editing existing lines). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** Invoke-Formatter with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the eight changed files (CR-FORMAT-CHECK, read-only).<br>**Result:** FORMAT-DRIFT-COUNT 0. |
| **2. Linting** | ✅ PASS | **Command:** PSScriptAnalyzer with repository settings, severities Error, Warning, Information (CR-PSSA).<br>**Result:** PSSA-TOTAL 0. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** direct `Invoke-Pester` over eleven files (CR-PESTER-LIST), then `Invoke-PoshQCTest` with the repository run settings.<br>**Result:** 301 passed, 0 failed; full run 5452 passed, 0 failed, 9 skipped. |
| **Full toolchain loop** | ✅ PASS | One clean pass (`evidence/qa-gates/qa-loop.2026-09-27T10-20.md`). |
| **Explicit reporting** | ✅ PASS | Each stage recorded under `evidence/qa-gates/` with command, exit code, and output summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages `6cee9940`, `e9679549`, `a7ef501e`, `28d8623c`, `52212212`. |
| **Design choices explained** | ✅ PASS | `spec.md` decisions D1-D10; operator approval (autonomous mode, 2026-09-26) covers the spec decisions and planner decisions P1-P6. |
| **Update supporting documents** | ✅ PASS | `evidence/other/follow-ups.md` records D8 and D9. |
| **Provide next steps** | ✅ PASS | AC4 second half deferred to the PR-head CI run (plan tasks P5-T19, P5-T20). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** CR-FORMAT-CHECK (Invoke-Formatter, repository settings).<br>**Result:** 8 of 8 files FORMAT-CLEAN. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** CR-PSSA (repository settings).<br>**Result:** 0 findings on each of 8 files. |
| **Fix all findings** | ✅ PASS | Construction-time fixes (assignment alignment; renaming the discovery list to `$script:HostileShapes` to clear PSUseDeclaredVarsMoreThanAssignments) recorded in `evidence/other/n1-structure-checks.2026-09-27T10-07.md`. |
| **PowerShell 7+ compatible** | ✅ PASS | Both files declare `#Requires -Version 7.0`; uses only PowerShell 7 language AST types. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | N/A | Test-local helpers; `[OutputType]` and typed parameters are declared. |
| **Parameter validation** | ✅ PASS | `[Parameter(Mandatory)]` on required AST and path parameters; `[AllowNull()]` where null is a valid input. |
| **Avoid global state** | ✅ PASS | Only `$script:` test-scope values; no `$global:` use. |
| **Error handling** | ✅ PASS | Parse errors and absent suite files are returned as findings, so a failing row names the cause. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | Maximum 489 lines (CommandExemption suite). |
| **Approved verbs** | ✅ PASS | Get, Test, Set, Invoke. `Set-HostileEpicSeam` carries a justified `PSUseShouldProcessForStateChangingFunctions` suppression (it registers Pester mocks only). |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | FORMAT-DRIFT-COUNT 0. |
| **Step 2: Analyze** | ✅ PASS | PSSA-TOTAL 0. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 301/0 targeted; 5452/0 full. |
| **Rerun loop if needed** | ✅ PASS | One pass; no file changed during the pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `BeforeAll`, `BeforeDiscovery`, `-ForEach`, `Should -Invoke`. Pester 5.6.1 per `evidence/baseline/toolchain-versions.2026-09-27T09-58.md`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged; the new file is discovered through the existing `Run.Path`). |
| **PowerShell 7+ Compatible** | ✅ PASS | `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 24 expansions: 7 structural, 9 predicate, 4 control, 4 treatment. |
| **Test Behavior Over Implementation** | ✅ PASS | The structural guard intentionally inspects test-suite structure (a hygiene invariant); the seam proof tests resolver behavior. |
| **Mocking Used Sparingly** | ✅ PASS | The seam mocks are the minimum needed to inject a hostile payload without temporary files; the suite mock replaces exactly one read seam with the CI-equivalent `$null`. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`<br>**Code file:** `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` and the seven gate suites.<br>Placed with the existing hook-family suites; follows the `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` precedent. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `enforce-gate-suites.EpicStateIsolation.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 2 Describe blocks, 1 Context, 6 static It blocks expanding to 24 rows. |
| **Logical Grouping** | ✅ PASS | Structural guard and predicate discrimination in the first Describe; seam sufficiency in the second. |
| **Docstrings/Comments** | ✅ PASS | File-level help and per-row AAA comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest`<br>**Result:** 5452 passed, 0 failed, 9 skipped (skips pre-existing, unchanged from baseline). |
| **No Alternative Test Runners** | ✅ PASS | Pester only. Direct `Invoke-Pester` over explicit lists was used for per-suite counts, as the spec requires, because MCP PoshQC summaries carry no per-test output. |

---

## 5. Test Coverage Detail

### Structural guard: `gate suites isolate the epic checkpoint read (structural guard)` (16 rows)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `<Path> isolates the epic checkpoint read in its outermost BeforeAll` (7 rows, one per suite) | Positive | test lines 108-187 | ✅ |
| `accepts the compliant <Name> form with zero findings` (2 rows) | Positive | test lines 53-165 | ✅ |
| `rejects <Name> with a finding containing "<Expected>"` (6 rows) | Negative / Edge Case | test lines 53-165 | ✅ |
| `reports a listed suite path that does not exist and names the path` | Edge Case / Error Handling | test lines 167-176 | ✅ |

**Coverage:** test helper code is outside the coverage denominator. Branches without a dedicated row: no outermost `BeforeAll`, parse error, and `Import-Module` absent while the mock is present.

### Seam sufficiency: `Resolve-EpicScopeCheckpoint` (8 rows)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `<Gate> control: the hostile payload is epic scope without the mock` (gate 1, gate 3, gate 4, gate 4 selector) | Positive (non-vacuity control) | `EpicScopeResolution.psm1` 314-359 | ✅ |
| `<Gate> treatment: the $null mock blocks the epic-state read` (same four shapes) | Error Handling (absent checkpoint short-circuit) | `EpicScopeResolution.psm1` 314-326 | ✅ |

**Coverage:** `EpicScopeResolution.psm1` 91.35% lines (95 of 104). `Resolve-EpicScopeCheckpoint` 28 of 30 lines.

**Not covered:** Two `Resolve-EpicScopeCheckpoint` lines and seven lines across other module functions remain uncovered; none is in scope for this test-only change.

### Seven edited suites (249 rows, unchanged)

Passed/Failed/Skipped per suite equal before and after: 5, 18, 20, 35, 19, 119, 33 passed; 0 failed; 0 skipped (`evidence/regression-testing/pester-targeted-after.2026-09-27T10-14.md`).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 5461 (5452 passed + 9 skipped) | ✅ |
| Tests Passed | 5452 (100% of executed) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 176.68 s total | ✅ Fast |
| Average Time per Test | about 32 ms | ✅ Fast |
| Discovery Time | not recorded separately in the evidence; included in total | ✅ |
| Functions/Classes Tested | 11 of 11 `EpicScopeResolution.psm1` functions have covered lines | ✅ |
| Test File Size | 432 lines (new file) | ✅ Maintainable |
| Code Coverage | 96.04% lines repo-wide (PowerShell); branch not measured by Pester | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | CR-FORMAT-CHECK over the 8 changed files | FORMAT-DRIFT-COUNT 0 | ✅ |
| PSScriptAnalyzer | CR-PSSA over the 8 changed files | PSSA-TOTAL 0 | ✅ |
| Pester Tests | `Invoke-PoshQCTest` with repository run settings | 5452 passed, 0 failed, 9 skipped | ✅ |

**Notes:** The nine skipped tests match the baseline (9 before, 9 after). No pre-existing failure. The toolchain was invoked through scratchpad `sh` wrappers around `pwsh -NoProfile -File` (Route C) because the agent-worktree isolation guard denies Bash text containing `pwsh`; the commands executed are the repository PoshQC functions with repository settings.

---

## 8. Gaps and Exceptions

### Identified Gaps

- Minor: the structural guard proves placement of the mock, not that the mock binds to the module instance the hook uses at run time. No branch test asserts that `Get-EpicScopeCheckpointText` is intercepted inside one of the seven suites. Reviewer verification by inspection: the hooks import `EpicScopeResolution.psm1` with `-Force` only at dot-source time (`.claude/hooks/enforce-pr-author-skill-helpers.ps1:48`, `.claude/hooks/enforce-model-routing-receipt.ps1:55`, `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:30`), each suite inserts its import after that dot-source, and no suite re-imports or re-dot-sources the hook later. The spec recorded this as an accepted indirect-verification risk.
- Minor: the guard's ordering check uses the first dot-source in the outermost `BeforeAll` rather than the hook dot-source specifically, and its search descends into nested script blocks (for example, a function body defined in the `BeforeAll`). Both are low-likelihood false-pass paths.
- Pending: AC4 second half (CI `windows-latest` PoshQC job on the PR head, depth-1 checkout) is scheduled after PR creation (P5-T19, P5-T20). The hermeticity half is verified.

### Approved Exceptions

- D9 explicit seven-path list in the guard (future reaching suites are not guarded automatically); approved under operator autonomous-mode approval of the spec decisions, 2026-09-26.
- Batch-budget state-file resets: the executor deleted `.claude/state/powershell-batch-budget.*.json` twice and retried the denied write once each time, as the plan's Batch Budget section instructs; the cap was not raised and no hook file changed.

### Removed/Skipped Tests

**None.** All planned tests implemented. No existing `It`, `Context`, or `Describe` in the seven suites was changed.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **929078ae** - docs(bug): add issue and research for #709 gate-suite epic-state isolation
2. **62c940da** - docs(bug): add spec for #709 gate-suite epic-state isolation
3. **49fdc2e1** - docs(bug): add atomic plan for #709 gate-suite epic-state isolation
4. **abf256d5** - docs(bug): revise #709 plan after preflight round 1
5. **d68f3bbf** - docs(bug): revise #709 plan after preflight round 2
6. **1b8f3007** - docs(709): record Phase 0 policy reads and baselines
7. **6cee9940** - test(709): add gate-suite epic-state isolation regression file
8. **e9679549** - test(709): isolate the epic checkpoint read in the gate-4 suites
9. **a7ef501e** - test(709): isolate the epic checkpoint read in three more gate suites
10. **28d8623c** - test(709): isolate the epic checkpoint read in the gate-1 target suite
11. **52212212** - docs(709): record final QA loop, scope checks, and AC check-offs

### Files Modified

1. **tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1** (NEW)
   - Structural guard over seven suites plus predicate-discrimination rows.
   - Seam-sufficiency proof with hostile in-memory payload for four call shapes.
2. **Seven gate suites under tests/scripts/claude-hooks/** (MODIFIED, 2 insertions and 0 deletions each)
   - `Import-Module` of `EpicScopeResolution.psm1` without `-Force` and the `$null` mock of `Get-EpicScopeCheckpointText`, after the hook load in the outermost `BeforeAll`.
3. **docs/features/active/gate-suites-read-unmocked-local-epic-state-709/** (NEW, 36 files)
   - issue, spec, research, plan, and evidence.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All applicable general and PowerShell policies pass. Numeric baseline and post-change coverage are present for the one in-scope coverage language (PowerShell). Findings are 0 Blocking and 0 Major. AC4 remains pending the PR-head CI run, which is non-blocking for review and is tracked by plan tasks P5-T19 and P5-T20.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: issue, spec, research, and plan present.
- ✅ Design Principles: two-line additive fix; no production seam.
- ✅ Module & File Structure: all files at or below 489 lines.
- ✅ Naming, Docs, Comments: descriptive helper names and file-level help.
- ✅ Toolchain Execution: one clean pass.
- ✅ Summarize & Document: commits and evidence complete; follow-ups recorded.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyzer clean.
- ✅ PowerShell Design & Safety: no global state; justified suppression only.
- ✅ Structure & Naming: approved verbs; under 500 lines.
- ✅ Toolchain: format, analyze, test pass.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: deterministic and isolated.
- ✅ Coverage & Scenarios: no regression; positive, negative, and edge rows present.
- ✅ Test Structure: AAA sections and actionable `-Because` messages.
- ✅ External Dependencies: none; no temporary files or gitignored reads.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5.6.1 via PoshQC settings.
- ✅ Test Style & Structure: focused rows; minimal mocks.
- ✅ Naming & Readability: `*.Tests.ps1`, templated row names.
- ✅ Toolchain: full configured run 0 failures.

---

### Metrics Summary

- ✅ 5452 of 5452 executed tests passing (9 pre-existing skips).
- ✅ 11 of 11 `EpicScopeResolution.psm1` functions exercised.
- ✅ 96.04% PowerShell line coverage repo-wide; 91.35% on `EpicScopeResolution.psm1`.
- ✅ Test file placed with the hook-family suites under `tests/scripts/claude-hooks/`.
- ✅ All code quality checks passing.
- ✅ Test execution time: 176.68 seconds for the full configured run (fast).

---

### Recommendation

**Ready for merge** after the PR-head CI run satisfies the AC4 CI half (P5-T19, P5-T20). No remediation is required. Record the deferred items listed in `code-review.2026-09-27T10-31.md` as follow-ups.

---

## Appendix A: Test Inventory

### Complete Test List

1. gate suites isolate the epic checkpoint read (structural guard) › `<Path>` isolates the epic checkpoint read in its outermost BeforeAll (7 rows: TargetResolution, pr-author WorktreeResolution, model-routing WorktreeResolution, preimplementation-gate, TriggerScoping, CommandExemption, absolute-paths)
2. gate suites isolate the epic checkpoint read (structural guard) › guard predicate discrimination › accepts the compliant positional form with zero findings
3. gate suites isolate the epic checkpoint read (structural guard) › guard predicate discrimination › accepts the compliant -CommandName and -MockWith form with zero findings
4. gate suites isolate the epic checkpoint read (structural guard) › guard predicate discrimination › rejects a Mock that targets another command
5. gate suites isolate the epic checkpoint read (structural guard) › guard predicate discrimination › rejects a Mock without -ModuleName
6. gate suites isolate the epic checkpoint read (structural guard) › guard predicate discrimination › rejects a Mock body other than $null
7. gate suites isolate the epic checkpoint read (structural guard) › guard predicate discrimination › rejects a Mock declared only in a nested Context BeforeAll
8. gate suites isolate the epic checkpoint read (structural guard) › guard predicate discrimination › rejects an Import-Module with -Force
9. gate suites isolate the epic checkpoint read (structural guard) › guard predicate discrimination › rejects an import and Mock placed before the hook dot-source
10. gate suites isolate the epic checkpoint read (structural guard) › guard predicate discrimination › reports a listed suite path that does not exist and names the path
11. the Get-EpicScopeCheckpointText mock blocks the epic-state read (seam sufficiency) › `<Gate>` control (gate 1, gate 3, gate 4, gate 4 selector)
12. the Get-EpicScopeCheckpointText mock blocks the epic-state read (seam sufficiency) › `<Gate>` treatment (gate 1, gate 3, gate 4, gate 4 selector)

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands (check-only):**
```bash
git -C <worktree> fetch origin main
git -C <worktree> diff --stat origin/main...HEAD
git -C <worktree> diff --name-status origin/main...HEAD
git -C <worktree> log --format='%h %ad %s' origin/main..HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit docs/features/active/gate-suites-read-unmocked-local-epic-state-709/policy-audit.2026-09-27T10-31.md
```

**Executor commands (recorded in evidence):**
```powershell
# Formatting (read-only check)
Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing
Invoke-Pester -Configuration <explicit file list>
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-09-27  
**Policy Version:** Current (as of audit date)

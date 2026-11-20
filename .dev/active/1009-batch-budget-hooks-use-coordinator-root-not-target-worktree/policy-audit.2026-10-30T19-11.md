# Policy Compliance Audit: Batch-budget hooks resolve the target worktree (Issue #1009)

---

**Audit Date:** 2026-10-30
**Code Under Test:** `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` (new), `.codex/hooks/hook-target-worktree.ps1` (new), `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`, the eight bundled mirrors of those files under `extensions/drm-copilot/resources/`, two pack manifests (`core.json`, Claude and Codex), six execution-environment brief copies, `.claude/rules/orchestrator-state.md` and its bundled copy, five new Pester suites plus one shared row-helper file, and two edited Pester suites.

**Base/Head:** base `main` (resolved `origin/main` @ `8451891a592e4d8e267d7de2a9f76f516e77f187`, merge base `8451891a592e4d8e267d7de2a9f76f516e77f187`, committed 2026-10-30T10:33:50-04:00); head `bug/batch-budget-hooks-coordinator-root-1009` @ `84574e7ad5aad1de3a70671e3515b76f6e37ec46`. Branch diff: 85 files, +5479/-171 (2 commits).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 20 files (6 production sources, 6 bundled mirrors, 8 test files) | 13329 tests (full `tests/scripts` run) | ✅ 13319 pass, 0 fail, 10 skipped (pre-existing) | Changed Claude hooks 93.53% lines each; changed Codex hooks 95.28% lines each | Repo-wide 93.51% lines (20726/22165); Claude hooks 94.08%; Codex hooks 95.80% | `HookTargetWorktree.psm1` 99.34% (151/152); `hook-target-worktree.ps1` 99.33% (148/149) |
| JSON | 2 files (pack manifests) | N/A | ✅ parse valid; manifest completeness and dependency-closure pytests pass | N/A (config files) | N/A (config files) | N/A |
| Markdown | 63 files (docs, brief copies, rule file, feature evidence) | N/A | ✅ brief contract pytest passes | N/A | N/A | N/A |

No Python, TypeScript, C#, or Bash file is changed on the branch (verified with `git diff --name-only 8451891a5..HEAD`, extension histogram: 63 md, 18 ps1, 2 psm1, 2 json). PowerShell has no branch-coverage gate (Pester measures line and command coverage only).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree-1009/evidence/baseline/pester-baseline.2026-10-30T17-12.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (inspected directly by this review) and `evidence/qa-gates/coverage-delta.2026-10-30T18-27.md`
- Per-language comparison summary: Section 1.2.1

---

## Executive Summary

The branch adds a pure target-worktree resolver (`Resolve-HookTargetWorktree` and five helpers) as a Claude module and a byte-equal Codex twin, and wires it into the four batch-budget hooks so the checkpoint, containment root, and state-file name derive from the registered worktree that holds the edited file. Root-level `artifacts/` paths are no longer counted. Documentation (brief, rule file, hook help) is updated across all mirrors.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists; every changed path is classified T3)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python files changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- N/A Bash: shfmt + shellcheck + bats (no Bash files changed)
- ✅ JSON: two pack manifests; parse-valid and covered by manifest contract tests

Toolchain evidence shows format (0 changes, 20 files), PSScriptAnalyzer (0 findings, 20 files), Pester over 23 touched suites (1653/1653), a fresh full `tests/scripts` run (13319 passed, 0 failed), three seeded shuffle runs, a single-process isolation run, and contract pytests (167 passed). Coverage meets the 85% line threshold repo-wide, for both new files, and for every modified file, with no regression on changed lines. Three CI-dependent acceptance criteria (AC-13, AC-25, AC-39) remain pending CI and are owned by the orchestrator S9 gate; they are not policy failures.

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted or kept outside the repository (the evidence names `SCRATCH/issue-1009-*` launcher scripts, which live outside the worktree; none appears in the branch diff)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (no tooling script added)
- Scripts created during development: `SCRATCH/issue-1009-pester.sh`, `issue-1009-ps.sh`, `issue-1009-full.sh`, `issue-1009-shuffle.sh/.ps1`, `issue-1009-report.ps1`, `issue-1009-section-tokens.py` — external scratch; not committed.

---

## Rejected Scope Narrowing

None detected. The caller prompt states that AC-13, AC-25, and AC-39 are CI-dependent and checked off at S9; this does not narrow the audit scope, and this audit covers the full branch diff against `main`.

---

## Evidence Location Compliance

- `git diff --name-only 8451891a5..HEAD` filtered for `^artifacts/(baselines|qa|evidence|coverage)/`: no matches.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`: EXIT_CODE 0, no violations reported.
- All 41 evidence files sit under `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`.

Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `evidence/regression-testing/isolation-shuffle.2026-10-30T18-48.md`: seeds 1009, 4242, 777 each 1653/1653 with both relative orders of the module and twin suites; `isolation-single-process.2026-10-30T19-04.md`: 13319 passed in one process. Each suite rebuilds its in-memory store in `BeforeEach`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Resolver rows are data-driven (`HookTargetWorktree.Rows.Helpers.ps1`: helper 24, porcelain 7, resolver 18, identity 25); hook rows are named per behavior (`R1 item worktree checkpoint large leaves the item uncapped`, `R2 two worktrees fill independent counters`, `R3 root-level artifacts scratch is not counted`). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Full `tests/scripts` run 764.46s for 13329 tests (about 57 ms/test); new suites use no process or disk I/O. |
| **Determinism** - Consistent results | ✅ PASS | Every hook row injects `-WorktreeListInvoker` returning in-memory porcelain and in-memory checkpoint/state seams; no clock or randomness; slash-rooted synthetic paths (`/repo`, `/repo/.claude/worktrees/item`, `/repo-wt/sibling`). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `It` names, `-Because` clauses on assertions, comment-based help in each suite describing the seam model. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** Claude hooks 130/139 = 93.53% each; Codex hooks 101/106 = 95.28% each.<br>**Command:** `Invoke-PoshQCTest` over 18 existing touched suites with coverage<br>**Timestamp:** 2026-10-30T17-12 (`evidence/baseline/pester-baseline.2026-10-30T17-12.md`) |
| **No Coverage Regression** | ✅ PASS | **Post-change:** Claude hooks 143/152 = 94.08% (+0.55); Codex hooks 114/119 = 95.80% (+0.52). Missed-line counts unchanged (9 and 5), so all 13 added lines per hook are covered. Read from `artifacts/pester/powershell-coverage.xml` by this review. |
| **New Code Coverage ≥85% (governing threshold)** | ✅ PASS | `HookTargetWorktree.psm1` 151/152 = 99.34%; `hook-target-worktree.ps1` 148/149 = 99.33%. The single uncovered line in each is the host-bound default `WorktreeListInvoker` body, asserted by AST rows. Root `CLAUDE.md` states no threshold, so the 85% line default governs. |
| **Comprehensive Coverage** | ✅ PASS | All six exported functions covered by row lists; nested helpers covered through `Resolve-HookTargetWorktree` rows (83 tests per suite). |
| **Positive Flows** - Valid inputs | ✅ PASS | Nested, sibling, and main worktree resolution; branch match; delegation branch and issue resolution; item-checkpoint `large` uncapped (R1). |
| **Negative Flows** - Invalid inputs | ✅ PASS | Path in no worktree, throwing invoker, empty invoker, branch matching no worktree, issue-only prompt without reader; item worktree without checkpoint stays capped. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Backslash, repeated-slash, trailing-slash, drive-rooted, case-variant normalization; `bare`, `detached`, `prunable` stanzas; CRLF porcelain; nested non-root `artifacts` directory still counts. |
| **Error Handling** - Error paths | ✅ PASS | Module load failure denies (B1 rows in `hook-dependency-failure.Claude/Codex.Tests.ps1`); route-helper import failure denies before any invoker call (`enforce-batch-budget.RouteImportFailure.Tests.ps1` unchanged, 20/20). |
| **Concurrency** - If applicable | N/A | Hooks run per tool call in separate processes; no shared in-process concurrency is introduced. |
| **State Transitions** - If applicable | ✅ PASS | Counter fill per worktree (R2), session-root state-file name unchanged, independent counters across worktrees. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: changed hooks 93.53% / 95.28% lines -> Post-change: 94.08% / 95.80% lines; repo-wide post-change 93.51% lines (20726/22165) from `artifacts/pester/powershell-coverage.xml`. Change: +0.55 / +0.52 percentage points on the changed hooks. New/changed-code coverage: new files 99.34% and 99.33%; all added hook lines covered. Disposition: PASS. Evidence: `evidence/baseline/pester-baseline.2026-10-30T17-12.md`, `evidence/qa-gates/coverage-delta.2026-10-30T18-27.md`, `artifacts/pester/powershell-coverage.xml`.
- TypeScript, Python, C#, Bash: zero changed files on the branch; no coverage verdict required.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions carry `-Because` text that includes the deny reason, for example R2 `"the item worktree has its own counter; reason: ..."`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Rows arrange seams/checkpoints, invoke the hook, then assert decisions and recorded paths; manifest test edits keep their `# Arrange` / `# Act` comments. |
| **Document Intent** | ✅ PASS | Each new suite has `.SYNOPSIS`/`.DESCRIPTION` stating the seam model and the issue. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No test spawns git; `Mock git` is not used (forbidden by `check-powershell-test-purity.ps1`); the default invoker is asserted by AST inspection without execution. |
| **Use Mocks/Stubs** | ✅ PASS | Injected scriptblock seams: `-WorktreeListInvoker`, `-ReadCheckpoint`, `-TestPathExists`, `-EnsureDirectory`, `-ReadState`, `-WriteState`, `-CheckpointIssueReader`. |
| **Environment Stability** | ✅ PASS | Grep of the five new suites and the row-helper file for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `Set-Content`, `Out-File`, `Start-Sleep`, `Get-Date`: the only hit is the banned-command list inside the AST assertion. No temporary files are created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-10-30T19-11.md` and `feature-audit.2026-10-30T19-11.md`, is the pre-PR review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` (Issue #1009) define the defect, root cause, and expected behavior. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-30T17-06.md` records the policy reading order. |
| **Document the plan** | ✅ PASS | `plan.2026-10-30T08-09.md` and `research/research.2026-10-30T12-12.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Hooks add one resolver call, one `artifacts/` check, and a conditional state-file name (13 executable lines each); logic sits in the module. |
| **Reusability** | ✅ PASS | One resolver serves both runtimes and is the stated contract for #1010 and #1011. The four hook wiring blocks are textual duplicates (noted as Minor in the code review). |
| **Extensibility** | ✅ PASS | Additive result fields (`ReasonCode`, `Detail`, `Candidates`); optional sources and seams with defaults. |
| **Separation of concerns** | ✅ PASS | Resolver performs no file, environment, or clock read; its only I/O is through the injected invoker and reader (AST-asserted). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | `HookTargetWorktree.psm1` holds only resolution and path helpers; placed with sibling `worktree-resolution` modules. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts measured by this review (split on line terminators, trailing terminator not counted): Claude hooks 535 and 532; module 391; Codex hooks 390 and 387; twin 369; new tests 158 to 287; `legacy-codex-hook-contracts.Tests.ps1` 501. No covered file is at or above 700 lines. `config/file-size-baseline.json` is unchanged in the diff. |
| **Public vs internal** | ✅ PASS | Explicit `Export-ModuleMember` of six functions; internal helpers are nested inside `Resolve-HookTargetWorktree`. |
| **No circular dependencies** | ✅ PASS | The module imports nothing; hooks import the module; `hook-dependency-guard-completeness.Tests.ps1` 671/671. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Resolve-HookTargetWorktree`, `Get-HookTargetWorktreeEnclosingRoot`, `$targetRoot`, `$isSessionRoot`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function; hook `.DESCRIPTION` rewritten to document resolved-root behavior and the 8.3/junction limitation (`help-tokens-*.md`). |
| **Comment why, not what** | ✅ PASS | Hook comments state why the session root is the fallback and why root-level `artifacts/` is excluded. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file<br>**Result:** FORMAT_FILES=20 FORMAT_CHANGED=0 (`format.2026-10-30T18-27.md`); hashes re-verified by this review for three files. |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information`<br>**Result:** PSSA_FILES=20 PSSA_FINDINGS=0 (`pssa.2026-10-30T18-27.md`). |
| **3. Type checking** | N/A | Not applicable for PowerShell (`type-check.2026-10-30T18-27.md`). |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts`<br>**Result:** 13319 passed, 0 failed, 10 skipped (pre-existing) (`pester-full.2026-10-30T18-43.md`). |
| **Full toolchain loop** | ✅ PASS | Loop restarted once after two `EpicStateIsolation.Discovery` failures; the final pass (18-27) was clean at every stage, followed by the fresh full run. CI confirmation is pending (AC-39). |
| **Explicit reporting** | ✅ PASS | Every stage has a timestamped evidence file with command, exit code, and summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `84574e7ad` message and `self-review.2026-10-30T19-05.md`. |
| **Design choices explained** | ✅ PASS | `spec.md` Root Cause Analysis explains rejection of `Resolve-WorktreeOperandTarget`/`Resolve-WorktreeCallTarget`. |
| **Update supporting documents** | ✅ PASS | Six brief copies byte-identical (one distinct SHA-256 across all six, verified by this review); rule file and bundle byte-identical. |
| **Provide next steps** | ✅ PASS | #1010 and #1011 consume the resolver; S9 confirms CI-dependent criteria. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter` with PoshQC settings (same steps as `Invoke-PoshQCFormat`)<br>**Result:** 0 changes on 20 files. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with PoshQC settings<br>**Result:** 0 findings on 20 files (19 earlier findings fixed in source, `pssa.2026-10-30T18-00.md`). |
| **Fix all findings** | ✅ PASS | No suppression attributes added. |
| **PowerShell 7+ compatible** | ✅ PASS | `.claude/rules/powershell.md` requires PowerShell 7+. The module uses `[System.Security.Cryptography.SHA256]::HashData`, available on PowerShell 7 (.NET 5+). PowerShell 5.1 is not a repository target. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | All exported functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `[Parameter(Mandatory)]` on `SessionRoot` and `WorktreeRoot`; `[AllowNull()]`/`[AllowEmptyString()]` used where blank input is a defined case. |
| **Avoid global state** | ✅ PASS | No module-scope `$script:` state referenced from functions (AC-1). Tests set `$PSDefaultParameterValues` as a local variable inside `It` blocks only. |
| **Error handling** | ✅ PASS | Module sets `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`; invoker failure is caught and converted to a session-root fallback with a `Detail` string; guarded imports fail closed. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest covered file 535 logical lines; none at or above 700. |
| **Approved verbs** | ✅ PASS | `Resolve`, `ConvertFrom`, `ConvertTo`, `Get`, `Add` are approved verbs; PSSA `PSUseApprovedVerbs` reports none. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `format.2026-10-30T18-27.md` |
| **Step 2: Analyze** | ✅ PASS | `pssa.2026-10-30T18-27.md` |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `pester-touched.2026-10-30T18-27.md` (1653/1653), `pester-full.2026-10-30T18-43.md` (13319 passed). |
| **Rerun loop if needed** | ✅ PASS | Two iterations (18-00, 18-27); the second was clean. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | One-line array insertions that match surrounding indentation; parse-valid (`json.load` on both manifests by this review). |
| **Schema validation** | ✅ PASS | Pack-manifest completeness (2 + 2) and dependency-closure (18) pytests pass (`pytest-contracts.2026-10-30T18-27.md`). |
| **Required $schema** | N/A | Pack manifests are not schema-governed JSON in this repository; no `$schema` key existed before the change. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | No comments or trailing commas. |
| **Deterministic key order** | ✅ PASS | No keys added; only array entries placed next to sibling entries. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `Describe`/`Context`/`It`, `BeforeAll`, `BeforeEach`, `-ForEach` row lists, `Should -Be` syntax. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts`<br>**Config:** `config/poshqc-coverage.json` (roots include `.claude/lib`, `.codex/hooks`); unchanged. |
| **PowerShell 7+ Compatible** | ✅ PASS | Suites declare `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Resolver 83 tests; twin 83; Claude hook suites 20 and 21; Codex hook suite 20. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert decisions, recorded checkpoint paths, and state-file names; AST rows pin the no-I/O contract required by the spec. |
| **Mocking Used Sparingly** | ✅ PASS | No `Mock`; scriptblock seams only. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1`<br>**Code file:** `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`<br>Claude hook suites under `tests/scripts/claude-hooks/`, Codex suites under `tests/scripts/codex-hooks/`, matching the existing mirror convention. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All five new suites end in `.Tests.ps1`; the shared row file is `*.Rows.Helpers.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per suite, `Context 'regression (issue #1009)'` and behavior contexts. |
| **Logical Grouping** | ✅ PASS | Shared row lists are reused by the module and twin suites so both run identical behavior rows. |
| **Docstrings/Comments** | ✅ PASS | Suite-level help blocks. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest`<br>**Result:** 13319 passed, 0 failed. |
| **No Alternative Test Runners** | ✅ PASS | The shuffle runs call `Invoke-Pester` directly only because `Invoke-PoshQCTest` sorts files by name; this is an isolation check, not a substitute gate. |

---

## 5. Test Coverage Detail

### HookTargetWorktree.psm1 (83 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Helper rows (normalization, relative path, enclosing root, key) | Positive / Edge Case | 37-146 | ✅ |
| Porcelain rows (main, linked, bare, detached, prunable, blank, CRLF) | Positive / Edge Case | 148-192 | ✅ |
| Resolver and identity rows (precedence, fallback, ambiguity, not-derivable) | Positive / Negative / Error Handling | 194-383 | ✅ |
| AST and reason-code equality rows | Contract | whole module | ✅ |

**Coverage:** 99.34% (151/152 lines).

**Not covered:** line 232, the default `WorktreeListInvoker` body (host-bound `git` call), asserted by AST rows without execution.

### hook-target-worktree.ps1 (83 tests)

Same 74 shared behavior rows plus 9 parity rows (function-name set, byte-identical `Extent.Text` for six functions, no statement outside function definitions). **Coverage:** 99.33% (148/149). **Not covered:** the default invoker body.

### Batch-budget hooks (Claude 20 + 21 tests; Codex 20 tests)

R1/R2/R3 regression rows, item-without-checkpoint capped, session-root state-file name unchanged, outside-every-worktree behavior, sibling-worktree tightening, ordering rows, and the Codex `apply_patch` move row. **Coverage:** Claude 94.08%, Codex 95.80%; all added lines covered.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 13329 (full `tests/scripts`) | ✅ |
| Tests Passed | 13319 (99.92%; 10 pre-existing skips) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 764.46s total | ✅ Acceptable for full suite |
| Average Time per Test | about 57 ms | ✅ Fast |
| Discovery Time | Not recorded in evidence | N/A |
| Functions/Classes Tested | 6/6 exported resolver functions | ✅ |
| Test File Size | 158 to 287 logical lines for new suites | ✅ PASS |
| Code Coverage (if applicable) | 93.51% lines repo-wide PowerShell; no branch metric for PowerShell | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 of 20 files changed | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 findings on 20 files | ✅ |
| Pester Tests | `Invoke-PoshQCTest -ScanFolders tests/scripts` | 13319 passed, 0 failed | ✅ |

**For contract checks:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Contract pytests | `poetry run pytest <eleven CONTRACT-PYTESTS modules> -q -p no:cacheprovider --no-cov` | 167 passed | ✅ |
| Codex generator | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | EXIT_CODE 0 | ✅ |

**Notes:**
The 10 skipped Pester tests are pre-existing skip conditions in files this change does not touch. The CI run on the PR head is not yet available (no PR exists); S9 owns that confirmation.

---

## 8. Gaps and Exceptions

### Identified Gaps
- CI confirmation for AC-13, AC-25, and AC-39 (Linux hook-suite job, Windows shards, full toolchain in CI) is pending because the PR does not yet exist. This is the documented CI-dependent criteria path owned by the orchestrator S9 gate, not a policy gap.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
**None.** All planned tests implemented; no test was removed or skipped by this change.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **3a60f8b62** - docs(features): prepare issue 1009 batch-budget target-worktree fix
2. **84574e7ad** - fix(hooks): resolve target worktree in batch-budget hooks

### Files Modified

1. **`.claude/lib/worktree-resolution/HookTargetWorktree.psm1`** (NEW) - pure resolver module, six exported functions.
2. **`.codex/hooks/hook-target-worktree.ps1`** (NEW) - functions-only Codex twin with byte-equal function text.
3. **`.claude/hooks/enforce-{python,powershell}-batch-budget.ps1`** (MODIFIED) - guarded module import, resolver call, `artifacts/` exclusion, resolved-root checkpoint/containment/state name, help text.
4. **`.codex/hooks/enforce-{python,powershell}-batch-budget.ps1`** (MODIFIED) - guarded twin dot-source and the same wiring without containment.
5. **Bundled mirrors** under `extensions/drm-copilot/resources/` (NEW/MODIFIED) - byte-identical to sources (verified by this review).
6. **Pack manifests** `core.json` Claude and Codex (MODIFIED) - one entry each.
7. **Execution-environment brief** (six copies) and **`.claude/rules/orchestrator-state.md`** (+ bundle) (MODIFIED) - documentation.
8. **Tests** (NEW): five suites plus `HookTargetWorktree.Rows.Helpers.ps1`; (MODIFIED): `WorktreeResolution.Manifest.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`.
9. **Feature folder** documents and evidence (NEW).

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All evaluated policy requirements are met by local evidence. Coverage for the only changed coverage language (PowerShell) meets the governing 85% line threshold repo-wide (93.51%), for each new file, and for each modified file, with no regression on changed lines. CI confirmation of three CI-dependent criteria is pending and owned by S9.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present.
- ✅ Design Principles: logic in a pure module; thin hook wiring.
- ✅ Module & File Structure: all files below 700 logical lines.
- ✅ Naming, Docs, Comments: help text updated across all copies.
- ✅ Toolchain Execution: clean final pass recorded.
- ✅ Summarize & Document: commits and self-review present.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and PSSA clean.
- ✅ PowerShell Design & Safety: StrictMode, guarded imports, no module state.
- ✅ Structure & Naming: approved verbs.
- ✅ Toolchain: two iterations, final clean.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: shuffle and single-process isolation pass.
- ✅ Coverage & Scenarios: 99.3% on new files, no regression.
- ✅ Test Structure: AAA and descriptive names.
- ✅ External Dependencies: injected seams only; no temp files.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 via PoshQC.
- ✅ Test Style & Structure: shared row lists; mirrored locations.
- ✅ Naming & Readability: `.Tests.ps1` naming.
- ✅ Toolchain: `Invoke-PoshQCTest`.

---

### Metrics Summary

- ✅ 13319/13319 executed tests passing (10 pre-existing skips)
- ✅ 6/6 exported resolver functions tested
- ✅ 93.51% PowerShell line coverage repo-wide; 99.34% and 99.33% on new files
- ✅ Proper file organization: tests mirror `.claude/lib`, `.claude/hooks`, `.codex/hooks`
- ✅ All code quality checks passing
- ✅ Test execution time: 764.46 seconds for the full suite

---

### Recommendation

**Ready for merge** (subject to the S9 CI green gate on the PR head)

Proceed to PR authoring. At S9, confirm `poshqc / PowerShell hook suites (Linux)`, `poshqc / PowerShell QC`, and the required contexts listed in `evidence/qa-gates/ci-checks.2026-10-30T19-04.md`, then check off AC-13, AC-25, and AC-39.

---

## Appendix A: Test Inventory

### Complete Test List

1. HookTargetWorktree.psm1 › helper rows (24), porcelain rows (7), resolver rows (18), identity rows (25), module-only rows (9)
2. hook-target-worktree.ps1 › the same 74 shared rows, parity rows (9)
3. enforce-python-batch-budget.ps1 target-worktree resolution › regression (R1, R2, R3) and behavior rows (20 total)
4. enforce-powershell-batch-budget.ps1 target-worktree resolution › regression and behavior rows (21 total)
5. codex-batch-budget.TargetWorktree › both Codex hooks, including the `apply_patch` move row (20 total)
6. WorktreeResolution.Manifest › three new `-ForEach` rows for `HookTargetWorktree.psm1` (25 total)
7. legacy-codex-hook-contracts › `hook-target-worktree.ps1` added to shared modules (43 total)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts
```

**Contract checks:**
```bash
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py -q -p no:cacheprovider --no-cov
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

**Review-side checks run by this audit:**
```bash
git diff --name-only 8451891a592e4d8e267d7de2a9f76f516e77f187..HEAD
git diff 8451891a592e4d8e267d7de2a9f76f516e77f187..HEAD -- <hook, manifest, brief, rule, and contract-test paths>
# JaCoCo parse of artifacts/pester/powershell-coverage.xml (repo-wide and per-file LINE counters)
# SHA-256 comparison of each source and its bundled mirror; logical line counts of covered files
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-30
**Policy Version:** Current (as of audit date)

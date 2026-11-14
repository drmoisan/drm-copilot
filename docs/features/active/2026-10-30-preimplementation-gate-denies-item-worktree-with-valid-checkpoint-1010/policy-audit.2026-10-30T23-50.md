# Policy Compliance Audit: Preimplementation gate resolves the target worktree checkpoint (Issue #1010)

---

**Audit Date:** 2026-10-30
**Code Under Test:** `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, their four bundled mirrors under `extensions/drm-copilot/resources/`, three new Pester suites (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1`), and four edited test files (`EpicStateIsolation.Baseline.Helpers.ps1`, `enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1`, `enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`, `legacy-codex-hook-contracts.Tests.ps1`).

**Base/Head:** base `main` (resolved `origin/main` @ `0c0027faefff4231a129579b2a850fe4c377f4e8`, merge base `0c0027faefff4231a129579b2a850fe4c377f4e8`); head `bug/preimplementation-gate-item-worktree-1010` @ `54b2b77b1db84a616493e05d6f5d01811823520c`. Branch diff: 78 files, +5037/-158 (six commits including one merge of `origin/main`). This is the post-remediation review following remediation cycle 1 (`remediation-inputs.2026-10-30T21-59.md`, findings F1 and F2).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 15 files (4 production sources, 4 bundled mirrors, 7 test files) | 1353 tests over the 18 cycle-1 touched suites; 13437 tests in the full `tests/scripts` run | ✅ 1353/1353 touched (`qa-gates/pester-coverage.2026-10-30T23-38.md`); full run 13427 passed, 0 failed, 10 skipped (pre-existing); 323/323 re-run by this review over 7 suites | Merge base (main-plan suite set): Claude gate 93.08%; Claude `-epic-scope` 98.53%; Codex gate 88.30%; Codex `-epic-scope` 98.18% | Current artifact `artifacts/pester/powershell-coverage.xml`: Claude `-epic-scope` 89.57% (103/115); Codex `-epic-scope` 97.01% (130/134); Codex gate 88.17% (149/169); Claude gate 80.50% (128/159) in the cycle-1 suite subset, 93.08% (148/159) in the main-plan suite set for the same, unchanged file content | Changed-line coverage: main plan 100% / 91.67% / 100% / 94.64%; remediation cycle 100% (24/24) on each `-epic-scope` file; no new production file |
| Markdown | 63 files (feature folder documents, evidence, lifecycle record) | N/A | N/A | N/A | N/A | N/A |

No Python, TypeScript, C#, JSON, or Bash file is changed on the branch (verified with `git diff --name-status 0c0027faefff4231a129579b2a850fe4c377f4e8..HEAD`). PowerShell has no branch-coverage gate (Pester measures line and command coverage only).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/evidence/baseline/pester-coverage.2026-10-30T20-40.md` (main plan) and `evidence/remediation-baseline/pester-coverage.2026-10-30T22-15.md` (cycle 1)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (report `Pester (10/30/2026 23:07:30)`, written after the last production-file modification at 22:22 UTC; parsed directly by this review), `evidence/qa-gates/pester-coverage.2026-10-30T21-08.md` (main-plan suite set, covering the gate entry-point files that cycle 1 did not change), and `evidence/qa-gates/coverage-delta.2026-10-30T22-28.md`
- Per-language comparison summary: Section 1.2.1

---

## Executive Summary

The branch makes the Claude and Codex preimplementation gates evaluate the checkpoint of the worktree that a Write/Edit `file_path`, a Codex `apply_patch` marker path, or a `git add` / `git commit` operand or `-C` selector names, by consuming `Resolve-HookTargetWorktree` from #1009. A failed or empty worktree listing, an ambiguous result, or a null root denies with `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS`. `lifecycle_ready` is ready only when it is the JSON boolean `true`. Remediation cycle 1 added a subcommand-aware option walk to `Get-OrchestrationGateCommandOperandPath` on both surfaces (pathspecs after `-m`, `-F`, `--author`, `--pathspec-from-file`, and similar options are now collected, and option values are not) and a parity suite that pins the three duplicated helper functions to identical text across the two surfaces.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists; `.claude/hooks` and `.codex/hooks` are classified T3)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python files changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- N/A Bash: shfmt + shellcheck + bats (no Bash files changed)

Cycle-1 toolchain evidence shows format (7 files already formatted, porcelain unchanged), PSScriptAnalyzer (0 findings after two fix passes), Pester over 18 touched suites (1353/1353), three seeded shuffles (1353/1353 each), a fresh single-process run over `tests/scripts` (13427 passed, 0 failed), Python contract tests, and the Codex generator `--check`. This review re-ran the five contract pytests (45 passed), the generator check (exit 0), `validate_evidence_locations.py` (exit 0), `cmp` on all four bundle pairs (equal), and seven Pester suites (323/323). No blocking policy finding was identified.

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted or kept outside the repository (the evidence names `SCRATCH/issue-1010-*` launcher scripts; none appears in the branch diff)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (no tooling script added)
- Scripts created during development: `SCRATCH/issue-1010-pt.sh`, `issue-1010-full.sh`, `issue-1010-r1-delta.sh`, `issue-1010-delta.ps1`, `issue-1010-r1-scope.sh`, and related launchers — external scratch; not committed.

---

## Rejected Scope Narrowing

None detected. The caller prompt supplies the base branch, merge base, head, feature folder, PR-context paths, and the `full-bug` AC source; none of these narrows the audit scope. This audit covers the full branch diff against `main`, including both the main-plan commit `84a345c7d` and the remediation commit `54b2b77b1`.

---

## Evidence Location Compliance

- `git diff --name-status 0c0027faefff4231a129579b2a850fe4c377f4e8..HEAD` contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: EXIT_CODE 0, no violations reported (run by this review).
- All evidence files sit under `<FEATURE>/evidence/{baseline,remediation-baseline,qa-gates,regression-testing,other}/`.

Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `evidence/regression-testing/isolation-shuffle.2026-10-30T23-38.md`: seeds 1010, 20261030, 737, each 1353/1353 after the last test edit; `isolation-single-process.2026-10-30T23-38.md`: 13427 passed, 0 failed in one process. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Rows are named per behavior: B1-B15 (building blocks), T1-T15 (Claude decisions), C1-C18 (Codex decisions), F1 parity rows. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | This review's 323-test re-run of seven suites completed in well under a minute; the new rows start no process and touch no disk except the F1 suite's read of two tracked files. |
| **Determinism** - Consistent results | ✅ PASS | Listing wrapper and checkpoint reads are mocked with in-memory text; synthetic `/synthetic-worktrees/...` roots; the F1 suite normalizes CRLF to LF before an ordinal comparison; no clock or randomness. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `It` names with row identifiers, Arrange/Act/Assert comments, suite-level comment-based help. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** main plan 93.08% / 98.53% / 88.30% / 98.18% (`evidence/baseline/pester-coverage.2026-10-30T20-40.md`); cycle 1 `-epic-scope` 86.96% Claude, 96.40% Codex (`evidence/remediation-baseline/pester-coverage.2026-10-30T22-15.md`)<br>**Command:** `Invoke-PoshQCTest` over the touched suites with coverage<br>**Timestamp:** 2026-10-30T20-40 and 2026-10-30T22-15 |
| **No Coverage Regression** | ✅ PASS | Same-suite-set comparison for cycle 1: Claude `-epic-scope` 86.96% -> 89.57%, Codex `-epic-scope` 96.40% -> 97.01% (re-read from `artifacts/pester/powershell-coverage.xml` by this review). The gate entry-point files were not changed by cycle 1 (last modified 20:54 and 20:57 UTC in commit `84a345c7d`); their main-plan measurement stands (93.08%, 88.17%). Changed-line coverage 24/24 on each surface in cycle 1. |
| **New Code Coverage ≥85% (governing threshold)** | ✅ PASS | No new production file. Changed-line coverage 100% (cycle 1) and 91.67% / 94.64% (main plan, the uncovered lines are the always-mocked `git` wrapper body). Root `CLAUDE.md` states no threshold, so the 85% line default governs. |
| **Comprehensive Coverage** | ✅ PASS | Option walk: separate, inline, and attached values (B10), `add --pathspec-from-file` (B11), option value excluded (B12), unmodeled stop (B13), standalone flag and `--` (B14), redirection skip (B15); gate legs T15/C18. |
| **Positive Flows** - Valid inputs | ✅ PASS | T1, T4-T7, T15 (Claude); C1, C4-C7, C9, C18 (Codex); B10, B11, B14, B15. |
| **Negative Flows** - Invalid inputs | ✅ PASS | T2, T3, T12; C2, C3, C14, C15; B12, B13; both F1 negative rows. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `commit -C`/`-c` reuse-message versus git global `-C`; attached `-mmsg`; readiness rows for `"false"`, `"true"`, `1`, `null`. |
| **Error Handling** - Error paths | ✅ PASS | B7, T9-T11, T13; C11-C13, C16; `Assert-GateHelperDefinitionParity` throws on a missing or differing definition. |
| **Concurrency** - If applicable | N/A | Hooks run per tool call in separate processes; the option walk is a pure string function. |
| **State Transitions** - If applicable | ✅ PASS | The script-scope listing-failure flag is reset per resolution; B6-B8 cover set and unset transitions. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.08% / 98.53% / 88.30% / 98.18% (main-plan suite set) and 86.96% / 96.40% for the two `-epic-scope` files (cycle-1 suite set) -> Post-change: Claude `-epic-scope` 89.57% (103/115), Codex `-epic-scope` 97.01% (130/134), Codex gate 88.17% (149/169), Claude gate 93.08% (148/159, main-plan suite set; 80.50% in the cycle-1 subset artifact, which omits suites such as `WorktreeResolution.Tests.ps1` that exercise the gate entry tail). Change: +2.61 and +0.61 percentage points on the two `-epic-scope` files against the same suite set; 0.00 and -0.13 points on the Claude and Codex gate files against the main-plan baseline. Artifact aggregate 88.39% (510/577) for the cycle-1 subset. Coverage is monotone in the suite set, so the per-file figures from the full runs are at least the subset figures. New/changed-code coverage: 100% (24/24) per `-epic-scope` file in cycle 1; main-plan changed lines 100%, 91.67%, 100%, 94.64%. Bundle copies are outside the coverage population (`config/poshqc-coverage.json`, unchanged). Disposition: PASS. Evidence: `evidence/remediation-baseline/pester-coverage.2026-10-30T22-15.md`, `evidence/qa-gates/pester-coverage.2026-10-30T22-27.md`, `evidence/qa-gates/pester-coverage.2026-10-30T23-38.md`, `evidence/qa-gates/coverage-delta.2026-10-30T22-28.md`, `evidence/qa-gates/pester-coverage.2026-10-30T21-08.md`, `artifacts/pester/powershell-coverage.xml`.
- TypeScript, Python, C#, Bash: zero changed files on the branch; no coverage verdict required.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions name the returned paths, decision, reason code, and checkpoint read; the parity helper's exception names the function and whether it is missing or different. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New rows carry Arrange/Act/Assert comments. |
| **Document Intent** | ✅ PASS | Each new suite has `.SYNOPSIS`/`.DESCRIPTION`; the F1 suite states finding F1 and its read-only scope. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The only `git` call is inside `Get-OrchestrationGateWorktreeList`, mocked in every suite that reaches it; the F1 suite dot-sources no hook and starts no process. |
| **Use Mocks/Stubs** | ✅ PASS | T15 and C18 reuse the suites' `Set-TargetFixture` checkpoint mocks and the listing-wrapper mock. |
| **Environment Stability** | ✅ PASS | No temporary files; the F1 suite reads two tracked repository files with `[System.IO.File]::ReadAllText` through `Join-Path` from `$PSScriptRoot`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-10-30T23-50.md` and `feature-audit.2026-10-30T23-50.md`, is the post-remediation pre-PR review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` for the main fix; `remediation-inputs.2026-10-30T21-59.md` for F1 and F2. |
| **Read existing change plans** | ✅ PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-10-30T22-12.md` records the policy reading order for cycle 1. |
| **Document the plan** | ✅ PASS | `plan.2026-10-30T08-09.md`, `remediation-plan.2026-10-30T21-59.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The option model is two per-subcommand tables inside one function; the walk is a single loop. |
| **Reusability** | ✅ PASS | Reuses `Get-CommandLineInvocation` and `Test-CommandLineTokenLiteral`. The duplicated helpers are now pinned identical across surfaces by the F1 suite. |
| **Extensibility** | ✅ PASS | Further options are added as table entries; function signatures unchanged. |
| **Separation of concerns** | ✅ PASS | The parser stays pure string logic; listing I/O stays in one wrapper. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Cycle-1 production change is confined to `Get-OrchestrationGateCommandOperandPath`. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts measured by this review (awk record count; a trailing terminator adds no line): Claude gate 471, Claude `-epic-scope` 387, Codex gate 491, Codex `-epic-scope` 447 (bundle copies equal); tests 106 to 506. No covered file is at or above 700 lines. `config/file-size-baseline.json` is unchanged (no `config/` path in the diff). |
| **Public vs internal** | ✅ PASS | No module export added; no signature change in cycle 1. |
| **No circular dependencies** | ✅ PASS | No new import or dot-source in cycle 1; `hook-dependency-guard-completeness.Tests.ps1` 671/671. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `$valueOptions`, `$flagOptions`, `$optionValues`, `$walked`, `Assert-GateHelperDefinitionParity`. |
| **Docs/docstrings** | ✅ PASS | `.DESCRIPTION` of `Get-OrchestrationGateCommandOperandPath` updated identically on both surfaces. |
| **Comment why, not what** | ✅ PASS | B10 label comment explains the case-fold uniqueness constraint; F1 path-construction comment explains why the paths are joined from segments. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` (write mode) over the 7 cycle-1 PowerShell files<br>**Result:** all already formatted; porcelain unchanged (`qa-gates/poshqc-format.2026-10-30T22-23.md`, re-confirmed in pass 5). |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 0 findings (`qa-gates/poshqc-analyze.2026-10-30T22-23.md`; pass 5 after the positional `Join-Path` fix). |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts`<br>**Result:** 13427 passed, 0 failed, 10 skipped (pre-existing) (`isolation-single-process.2026-10-30T23-38.md`). |
| **Full toolchain loop** | ✅ PASS | Five loop passes recorded; restarts after analyzer findings, an uncovered changed line (B15 added), and two guard-suite failures (name collision, discovery census); the final pass was clean. |
| **Explicit reporting** | ✅ PASS | Each stage has a timestamped evidence file with command, exit code, and summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `54b2b77b1` message and `evidence/qa-gates/self-review.2026-10-30T23-39.md`. |
| **Design choices explained** | ✅ PASS | Five deviations recorded in the cycle-1 self-review, including the option-value exclusion from `Operands`. |
| **Update supporting documents** | ✅ PASS | No execution-environment brief or rule fact changes; none was made. |
| **Provide next steps** | ✅ PASS | `spec.md` Rollout & Follow-up names the R2 owner decision and the #1011 consumer guarantees. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat`<br>**Result:** 0 changes. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with PoshQC settings<br>**Result:** 0 findings. |
| **Fix all findings** | ✅ PASS | Findings (unused parameter, positional `Join-Path`) were fixed in source; no suppression attribute added. |
| **PowerShell 7+ compatible** | ✅ PASS | New suite carries `#Requires -Version 7.0`; no version-specific construct added. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Existing `[CmdletBinding()]`/`[OutputType()]` retained; test helpers carry `[CmdletBinding()]`. |
| **Parameter validation** | ✅ PASS | Unchanged mandatory `-Command`; collected tokens must pass `Test-CommandLineTokenLiteral` and the absolute-path pattern. |
| **Avoid global state** | ✅ PASS | Option tables are function-local. |
| **Error handling** | ✅ PASS | An unmodeled option stops the walk, which fails toward the session-root checkpoint (stricter, not looser). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest covered file 506 logical lines; none at or above 700. |
| **Approved verbs** | ✅ PASS | `Get`, `Invoke`, `Resolve`, `Read`, `Assert`. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `qa-gates/poshqc-format.2026-10-30T22-23.md` |
| **Step 2: Analyze** | ✅ PASS | `qa-gates/poshqc-analyze.2026-10-30T22-23.md` |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `qa-gates/pester-coverage.2026-10-30T23-38.md` (1353/1353), `isolation-single-process.2026-10-30T23-38.md` (13427 passed). |
| **Rerun loop if needed** | ✅ PASS | Five passes; the final pass was clean. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `Describe`/`It`, `BeforeAll`, `-ForEach`, `Mock`, `Should -Invoke`; F1 suite declares `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest`<br>**Config:** `config/poshqc-coverage.json`, unchanged. |
| **PowerShell 7+ Compatible** | ✅ PASS | `#Requires -Version 7.0` on the new suite. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Claude TargetWorktree 43 tests; Codex target-worktree 47 tests; F1 parity 5 tests. |
| **Test Behavior Over Implementation** | ✅ PASS | B rows assert returned paths; T15/C18 assert the allow decision and the checkpoint path read. The F1 rows assert source-text identity, which is the stated contract of the Codex header. |
| **Mocking Used Sparingly** | ✅ PASS | Only I/O seams are mocked; the F1 suite registers no mock. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-hooks/`, `tests/scripts/codex-hooks/`<br>**Code files:** `.claude/hooks/`, `.codex/hooks/`; matches the existing mirror convention. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All three new suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One or two `Describe` blocks per suite; new rows grouped with their B and T/C peers. |
| **Logical Grouping** | ✅ PASS | Building blocks first, then gate decisions. |
| **Docstrings/Comments** | ✅ PASS | Suite-level help blocks and inline Arrange notes. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest`<br>**Result:** 1353/1353 touched; 13427 passed full run. |
| **No Alternative Test Runners** | ✅ PASS | Executor gates used `Invoke-PoshQCTest`. This review's 323-test spot re-run used `Invoke-Pester` directly as a read-only cross-check, not as a gate. |

---

## 5. Test Coverage Detail

### enforce-orchestration-preimplementation-gate-epic-scope.ps1 (Claude; TargetWorktree suite, 43 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| B1-B5, B10-B15 operand parser rows | Positive / Negative / Edge Case | `Get-OrchestrationGateCommandOperandPath` including the option walk | ✅ |
| B6-B8 recording invoker rows | Positive / Error Handling | `Invoke-OrchestrationGateWorktreeList` | ✅ |
| T1-T12, T15 gate decision rows | Positive / Negative / Error Handling | `Resolve-OrchestrationGateTarget` adapter, `Read-OrchestrationGateCheckpoint` | ✅ |
| T13-T14 import-guard and baseline-helper rows | Error Handling / Isolation | guarded import; helper mock | ✅ |

**Coverage:** 89.57% (103/115 lines) in the cycle-1 suite set.

**Not covered:** the three body lines of `Get-OrchestrationGateWorktreeList` (mocked by design) and pre-existing lines exercised only by suites outside the cycle-1 set.

### enforce-orchestration-preimplementation-gate-epic-scope.ps1 (Codex; target-worktree suite, 47 tests)

B1-B15 (including the reason-code equality row B9) and C1-C18, including `apply_patch` marker resolution (C7, C8) and absolute-path validation of `Get-CheckpointContent` (C15). **Coverage:** 97.01% (130/134). **Not covered:** the three wrapper body lines and one pre-existing line.

### Gate entry points

Claude gate 93.08% (148/159) and Codex gate 88.17% (149/169) in the main-plan suite set; neither file changed in cycle 1.

### F1 parity suite (5 tests)

Three positive rows (one per duplicated helper) and two negative rows proving the assertion fails on a one-character difference and on a missing definition.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 13437 (full `tests/scripts`) | ✅ |
| Tests Passed | 13427 (10 pre-existing skips) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | About 25 minutes for the full run (2026-10-30T23-07 to 23-32 UTC) | ✅ Acceptable for full suite |
| Average Time per Test | About 112 ms | ✅ Acceptable |
| Discovery Time | Not recorded in evidence | N/A |
| Functions/Classes Tested | 3/3 helper functions per surface, plus the Codex `Resolve-OrchestrationGateTarget` and `Read-OrchestrationGateCheckpoint` | ✅ |
| Test File Size | 423, 461, and 106 logical lines for the new suites | ✅ PASS |
| Code Coverage (if applicable) | 88.39% lines (510/577) over the four edited production files in the cycle-1 subset; every file at or above 85% in its governing measurement; no branch metric for PowerShell | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` | 0 files changed | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -ScanFolders tests/scripts` | 13427 passed, 0 failed | ✅ |

**For contract checks:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Contract pytests | `poetry run pytest <five push-down contract modules> -q -p no:cacheprovider --no-cov` | 45 passed (re-run by this review) | ✅ |
| Codex generator | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | EXIT_CODE 0 (re-run by this review) | ✅ |
| Bundle parity | `cmp` of each of the four sources against its bundle copy | All four equal (this review) | ✅ |

**Notes:**
The 10 skipped Pester tests are pre-existing skip conditions in files this change does not touch. No CI-dependent criterion exists in `spec.md`; the CI run on the PR head remains the orchestrator S9 gate.

---

## 8. Gaps and Exceptions

### Identified Gaps
- None that are policy failures. Non-blocking observations are recorded in `code-review.2026-10-30T23-50.md`, including a pre-existing case-insensitive option match in the unchanged shared `hook-command-invocation.ps1`.

### Approved Exceptions
**None.** No exceptions needed. The F1 rows could not fail on the unmodified tree; `evidence/regression-testing/fail-before-exception.2026-10-30T22-17.md` records the alternative proof (two passing negative rows).

### Removed/Skipped Tests
**None.** No test was removed or skipped.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **6ee6ba4ee** - docs(feature): prepare issue 1010 preimplementation gate target-worktree fix
2. **dc6a5fb28** - Merge remote-tracking branch 'origin/main' into bug/preimplementation-gate-item-worktree-1010
3. **9fd1654b9** - docs(features): revise issue 1010 plan for the merged 1009 resolver contract
4. **84a345c7d** - fix(hooks): resolve preimplementation gate checkpoint in item worktree
5. **972c6c8ec** - docs(features): record issue 1010 feature review artifacts
6. **54b2b77b1** - fix(hooks): collect pathspecs after value-taking options in epic-scope gate

### Files Modified

1. **`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`** (MODIFIED) - guarded imports; listing wrapper, recording invoker, operand parser with the cycle-1 option walk; path and command legs routed through `Resolve-HookTargetWorktree`; `Get-OrchestrationEpicScopeSelector` removed.
2. **`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`** (MODIFIED) - strict boolean `lifecycle_ready`.
3. **`.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`** (MODIFIED) - guarded dot-source of `hook-target-worktree.ps1`; `Get-CheckpointContent` with mandatory absolute `-Path`; building blocks identical to the Claude copies; Codex `Resolve-OrchestrationGateTarget` and `Read-OrchestrationGateCheckpoint`.
4. **`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`** (MODIFIED) - single-feature read through the target reader; strict boolean `lifecycle_ready`.
5. **Bundled mirrors** under `extensions/drm-copilot/resources/` (MODIFIED) - byte-identical to sources (verified by this review).
6. **Tests** (NEW): two TargetWorktree suites and the F1 parity suite; (MODIFIED): baseline helper, OperandResolution, Parity cases, legacy Codex contracts.
7. **Feature folder** documents, evidence, remediation inputs and plan, prior review artifacts, and the promoted lifecycle record (NEW).

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All evaluated policy requirements are met. Coverage for the only changed coverage language (PowerShell) meets the governing 85% line threshold for every modified production file in its governing measurement, with no regression on changed lines. The PR-head CI run is owned by the orchestrator S9 gate.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, remediation inputs, and both plans present.
- ✅ Design Principles: option model held in two tables; duplicated helpers pinned.
- ✅ Module & File Structure: all files below 700 logical lines.
- ✅ Naming, Docs, Comments: help text updated on both surfaces.
- ✅ Toolchain Execution: clean final pass recorded.
- ✅ Summarize & Document: commits and self-reviews present.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and PSSA clean.
- ✅ PowerShell Design & Safety: conservative stop on unmodeled options; literal and absolute filters.
- ✅ Structure & Naming: approved verbs.
- ✅ Toolchain: five passes, final clean.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: shuffle and single-process isolation pass.
- ✅ Coverage & Scenarios: every modified file at or above 85%.
- ✅ Test Structure: AAA and descriptive names.
- ✅ External Dependencies: mocked listing and read seams; no temporary files.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 via PoshQC.
- ✅ Test Style & Structure: mirrored locations.
- ✅ Naming & Readability: `.Tests.ps1` naming.
- ✅ Toolchain: `Invoke-PoshQCTest`.

---

### Metrics Summary

- ✅ 13427/13427 executed tests passing (10 pre-existing skips)
- ✅ 3/3 duplicated helper functions tested and pinned on each surface
- ✅ 88.39% PowerShell line coverage over the edited production files in the cycle-1 subset; every file at or above 85% in its governing measurement
- ✅ Proper file organization: tests mirror `.claude/hooks` and `.codex/hooks`
- ✅ All code quality checks passing
- ✅ Test execution time: about 25 minutes for the full suite

---

### Recommendation

**Ready for merge** (subject to the S9 CI green gate on the PR head)

Proceed to PR authoring. State the known limitations R2 (epic `target-mixed`) and R4 (`cd <wt> && git commit`) in the PR description, as `spec.md` requires, and note that an unmodeled `git commit` option or a clustered short flag still stops pathspec collection.

---

## Appendix A: Test Inventory

### Complete Test List

1. Claude gate target-worktree building blocks (issue #1010) › B1-B15, interception probe
2. Claude gate target-worktree decisions (issue #1010) › T1-T15
3. Codex gate target-worktree building blocks and decisions (issue #1010) › B1-B15, C1-C18, interception probe
4. Preimplementation gate -epic-scope helper parity (issue #1010, finding F1) › 3 parity rows, 2 negative rows
5. OperandResolution › O1-O9 with the listing wrapper mocked (11 total)
6. Parity › four readiness rows on both surfaces (93 total)
7. legacy-codex-hook-contracts › rewritten `Get-CheckpointContent` and entrypoint rows (43 total)

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
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -q -p no:cacheprovider --no-cov
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

**Review-side checks run by this audit:**
```bash
git diff --name-status 0c0027faefff4231a129579b2a850fe4c377f4e8..HEAD
git show 54b2b77b1 -- .claude/hooks/ tests/scripts/
# LINE counters per sourcefile parsed from artifacts/pester/powershell-coverage.xml
# cmp of each source against its bundled mirror; logical line counts of covered files (awk record count)
# Invoke-Pester over seven suites (TargetWorktree x2, EpicScopeHelperParity, OperandResolution, CommandExemption, Codex -epic-scope, legacy Codex contracts): 323 passed, 0 failed
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-30
**Policy Version:** Current (as of audit date)

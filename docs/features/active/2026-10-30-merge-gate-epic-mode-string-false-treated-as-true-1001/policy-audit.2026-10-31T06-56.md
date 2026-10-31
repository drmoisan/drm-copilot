# Policy Compliance Audit: Strict epic_mode in three enforcement hooks (Issue #1001)

---

**Audit Date:** 2026-10-31
**Code Under Test:** `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, `.claude/hooks/enforce-model-routing-receipt.ps1`, their three bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, three new Pester suites under `tests/scripts/claude-hooks/` (`*.EpicModeStrict.Tests.ps1`), and the feature folder documents and evidence.

**Base/Head:** base `main` (resolved `origin/main` @ `ccec4eba82e272d27f7d81c0e0657a93110de5fb`, merge base `ccec4eba82e272d27f7d81c0e0657a93110de5fb`); head `bug/merge-gate-epic-mode-string-false-1001` @ `efa4259525e592dcc42a52a03bb0e938821d774e`. Branch diff: 38 files, +1660/-12 (9 commits including one merge of `origin/main`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 9 files (3 production hooks, 3 bundled mirrors, 3 new test suites) | 5623 tests (`tests/scripts/claude-hooks` with coverage); 13518 tests (`tests/scripts`, no coverage) | ✅ 5623 pass, 0 fail; full run 13508 pass, 0 fail, 10 skipped (pre-existing) | Merge gate 100.00% (132/132); base-branch 93.55% (29/31); model-routing 96.43% (81/84) | Same three figures (re-read by this review from `artifacts/pester/powershell-coverage.xml`); repo-wide figure in that artifact 48.03% (10717/22315) from a `tests/scripts/claude-hooks`-only run | 100.00% of changed executable lines (3 of 3 changed predicate statements hit, ci=3, mi=0); no new production file |
| Markdown | 29 files (feature folder only) | N/A | N/A | N/A | N/A | N/A |

No Python, TypeScript, C#, or Bash file is changed on the branch (verified with `git diff --name-only ccec4eba8...HEAD`). PowerShell has no branch-coverage gate (Pester measures line and command coverage only).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: `N/A - out of scope` (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/evidence/baseline/pester-coverage.2026-10-31T06-19.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (inspected directly by this review; report generated 2026-10-31 06:30:44) and `evidence/qa-gates/pester-coverage.2026-10-31T06-32.md`, `evidence/qa-gates/coverage-delta.2026-10-31T06-32.md`
- Per-language comparison summary: Section 1.2.1

---

## Executive Summary

The branch replaces two coercing `epic_mode` expressions (`[bool]` cast in two hooks, `-eq $true` in one hook) with the strict idiom `(($v -is [bool]) -and $v)`, so only a JSON boolean `true` counts as epic mode. Comment-based help in each hook states the requirement and cites issue #1001. The three bundled mirrors are byte-identical to the sources. Three new Pester suites cover the eight-value `epic_mode` matrix and the merge-gate decision path.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ❌ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`) — repo-wide PowerShell coverage verdict FAIL from the available artifact (PA-1)
- ✅ `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists; `.claude/hooks` and `extensions/drm-copilot` are classified T3)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python files changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- N/A TypeScript, C#, Bash (no files changed)

Toolchain evidence shows format (0 changes, 9 files), PSScriptAnalyzer (0 findings, 9 files), Pester over `tests/scripts/claude-hooks` with coverage (5623/5623), a fresh single-process `tests/scripts` run (13508 passed, 0 failed, 10 skipped), three seeded shuffle runs (660/660 each), fail-before and pass-after runs, and mirror contract pytests (34 passed). Per-file coverage for each modified hook meets the 85% line default and is unchanged from baseline. The only coverage artifact present was produced by a `tests/scripts/claude-hooks`-only run, so its repo-wide aggregate (48.03%) does not reflect the full suite; the repo-wide PowerShell verdict is recorded as FAIL until a full-population coverage artifact is produced (PA-1).

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted or kept outside the repository (the evidence names `SCRATCH/issue-1001-*` launcher scripts, which live outside the worktree; none appears in the branch diff)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (no tooling script added)
- Scripts created during development: `SCRATCH/issue-1001-run.sh`, `issue-1001-pester.ps1`, `issue-1001-poshqc.ps1`, `issue-1001-static.ps1`, `issue-1001-mirror.sh`, `issue-1001-linehits.ps1` — external scratch; not committed.

---

## Rejected Scope Narrowing

None detected. The caller prompt names the base branch, merge base, feature folder, work mode, and PR context artifacts; it does not narrow the audit to a plan, task, phase, file subset, or language. This audit covers the full branch diff against `main`.

---

## Evidence Location Compliance

- `git diff --name-only ccec4eba8...HEAD` filtered for `^artifacts/(baselines|qa|evidence|coverage)/`: no matches.
- `python -I scripts/dev_tools/validate_evidence_locations.py --root <worktree>`: EXIT_CODE 0, no violations reported.
- All 26 evidence files sit under `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Spec AC-11 names `evidence/coverage/`, which is not a canonical evidence kind in `evidence-and-timestamp-conventions`; the executor recorded coverage under `evidence/qa-gates/`, which is canonical. No override is needed by this review.

Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `evidence/regression-testing/shuffle-seed-{1001,2718,31415}.*.md`: 35 hook suites in seeded file order, 660/660 each; `single-process-tests-scripts.2026-10-31T06-50.md`: 13508 passed in one process. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `It` per `epic_mode` value via `-ForEach` rows; each suite targets one function (`Test-ChildCheckpointAllowsEpicMerge`, `Test-EpicBaseBranchOverride`, `Get-ModelRoutingAuthorAssertedReason`) plus the merge-gate decision rows. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | New suites perform no disk or process I/O; 31 rows total. |
| **Determinism** - Consistent results | ✅ PASS | Checkpoints are in-memory JSON strings; resolution and `gh`/`git` seams are mocked; synthetic roots under `/synthetic-worktrees`; no clock or randomness. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row labels name the value under test (`JSON true`, `string false`, `integer 1`), `-Because` clauses carry the label or deny reason, and suite help describes the seam model. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** merge gate 132/132 = 100.00%; base-branch 29/31 = 93.55%; model-routing 81/84 = 96.43%.<br>**Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks` with coverage<br>**Timestamp:** 2026-10-31T06-19 (`evidence/baseline/pester-coverage.2026-10-31T06-19.md`) |
| **No Coverage Regression** | ✅ PASS | **Post-change:** identical covered/missed counts on all three hooks (delta 0.00). Read from `artifacts/pester/powershell-coverage.xml` by this review (LINE counters 132/0, 29/2, 81/3). The help additions add no executable lines; each changed predicate line is hit. |
| **Modified-file coverage ≥85% (governing threshold)** | ✅ PASS | 100.00%, 93.55%, 96.43%. Root `CLAUDE.md` states no coverage threshold, so the 85% line default governs. |
| **Repo-wide coverage ≥85% (governing threshold)** | ❌ FAIL | The only PowerShell coverage artifact (`artifacts/pester/powershell-coverage.xml`, run over `tests/scripts/claude-hooks` only) reports 10717/22315 = 48.03% lines across the full `config/poshqc-coverage.json` population. The full `tests/scripts` run (`single-process-tests-scripts.2026-10-31T06-50.md`) was executed without coverage. A repo-wide figure from a full-suite coverage run is not available. See PA-1. |
| **Comprehensive Coverage** | ✅ PASS | All three changed functions are exercised across the eight-value matrix; the merge-gate decision path is exercised for allow and deny outcomes. |
| **Positive Flows** - Valid inputs | ✅ PASS | JSON `true` rows: merge gate returns `$true` and `allow`; base-branch returns `EPIC_BASE_BRANCH_MISMATCH`; model-routing returns `$null`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | String `"false"`, string `"true"`, integer `1`, integer `0` rows in all three suites. |
| **Edge Cases** - Boundary conditions | ✅ PASS | JSON `null` and absent key rows; otherwise-green standalone checkpoint with `"epic_mode":"false"` denies with zero `Get-EpicMergeGateLivePrHeadSha` calls. |
| **Error Handling** - Error paths | ✅ PASS | Rows assert the existing reason codes (`EPIC_MERGE_GATE_BLOCKED`, `EPIC_BASE_BRANCH_MISMATCH`, `AUTHOR_ASSERTED_AUTOCLOSE_MISSING`); no new error path is introduced. |
| **Concurrency** - If applicable | N/A | Hooks run per tool call in separate processes; no concurrency is introduced. |
| **State Transitions** - If applicable | N/A | The changed predicates are stateless. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 100.00% / 93.55% / 96.43% lines on the three modified hooks -> Post-change: 100.00% / 93.55% / 96.43% lines. Change: 0.00 percentage points each. New/changed-code coverage: 100.00% (3 of 3 changed executable lines; each changed predicate statement hit, ci=3, mi=0; help-text lines are non-executable). Repo-wide: 48.03% lines (10717/22315) in the available artifact, which was produced by a `tests/scripts/claude-hooks`-only run; a full-suite figure is not recorded. Disposition: FAIL (per-file and changed-line checks pass; repo-wide figure fails, PA-1). Evidence: `evidence/baseline/pester-coverage.2026-10-31T06-19.md`, `evidence/qa-gates/pester-coverage.2026-10-31T06-32.md`, `evidence/qa-gates/coverage-delta.2026-10-31T06-32.md`, `artifacts/pester/powershell-coverage.xml`.
- TypeScript, Python, C#, Bash: zero changed files on the branch; no coverage verdict required.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because "epic_mode is $Label"` and `-Because "reason: $reason"` on decision rows. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Every row carries `# Arrange`, `# Act`, `# Assert` comments. |
| **Document Intent** | ✅ PASS | Each suite has `.SYNOPSIS`/`.DESCRIPTION` naming issue #1001 and the seam model. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | `Invoke-DocsOnlyGhExe`, `Invoke-DocsOnlyGitExe`, `Get-EpicMergeGateLivePrHeadSha`, and all checkpoint-text and worktree-resolution seams are mocked; each suite runs the `baseline mock interception probe` row. |
| **Use Mocks/Stubs** | ✅ PASS | Pester `Mock` at function seams, including module-scoped mocks for `WorktreeItemResolution`, `WorktreeRunResolution`, `EpicScopeResolution`, `OrchestratorState`. |
| **Environment Stability** | ✅ PASS | Inspection by this review of the three suites: no `TestDrive:`, `New-TemporaryFile`, `Set-Content`, `Out-File`, `New-Item`, `Add-Content`; the base-branch suite's `-CheckpointPath` names a non-existent file and the read seam is mocked (`no-file-creation.2026-10-31T06-34.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-10-31T06-56.md` and `feature-audit.2026-10-31T06-56.md`, is the pre-PR review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` (Issue #1001) define the defect class, root cause table, and value matrix. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-31T06-10.md` records the policy reading order. |
| **Document the plan** | ✅ PASS | `plan.2026-10-30T06-58.md` and `research/research.2026-10-30T11-00.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One expression changed per hook; the strict idiom matches existing use in `enforce-epic-merge-gate-green-ci.ps1` and `.claude/lib/orchestrator-state/*.psm1`. |
| **Reusability** | ✅ PASS | A shared helper was considered and rejected in the spec (research approach B); the three-site idiom is a single expression. |
| **Extensibility** | ✅ PASS | Function signatures and output types unchanged. |
| **Separation of concerns** | ✅ PASS | Predicate changes only; no I/O added. Branch 1 of the merge gate remains checkpoint-only. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | No file added to production; tests placed beside existing suites for the same hooks. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical line counts measured by this review (split on line terminators, trailing terminator not counted): merge gate 482, base-branch 146, model-routing 352 (mirrors identical); new suites 109, 71, 60. No covered file is at or above 700 lines. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | No export surface changed. |
| **No circular dependencies** | ✅ PASS | No import added. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | No identifiers renamed or added in production code. |
| **Docs/docstrings** | ✅ PASS | Script `.DESCRIPTION` and function help updated in all three hooks to state the JSON-boolean requirement and cite issue #1001. |
| **Comment why, not what** | ✅ PASS | Help text explains the consequence (branch 1 declines; `--base` requirement does not apply; line not waived). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file, compared without write<br>**Result:** 9 files, 0 would change (`format.2026-10-31T06-25.md`). |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`<br>**Result:** 9 files, 0 findings (`pssa.2026-10-31T06-25.md`). |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks`<br>**Result:** 5623 passed, 0 failed (`pester-coverage.2026-10-31T06-32.md`); full `tests/scripts` 13508 passed, 0 failed, 10 skipped. |
| **Full toolchain loop** | ✅ PASS | Final pass clean at format, analysis, and test stages with no auto-fix; architecture, contract, and integration stages have no applicable change beyond the mirror contract pytests (34 passed). |
| **Explicit reporting** | ✅ PASS | Every stage has a timestamped evidence file with command, exit code, and summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages and `self-review.2026-10-31T06-50.md`. |
| **Design choices explained** | ✅ PASS | `spec.md` Root Cause Analysis and data-flow table. |
| **Update supporting documents** | ✅ PASS | Three mirrors byte-identical (verified by this review with `cmp`). |
| **Provide next steps** | ✅ PASS | `spec.md` Rollout & Follow-up states no follow-up is required. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter` with PoshQC settings<br>**Result:** 0 changes on 9 files. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with PoshQC settings<br>**Result:** 0 findings on 9 files. |
| **Fix all findings** | ✅ PASS | No suppression attributes added. |
| **PowerShell 7+ compatible** | ✅ PASS | Suites declare `#Requires -Version 7.0`; `-is [bool]` is version-neutral. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | No function signature changed. |
| **Parameter validation** | ✅ PASS | Unchanged. |
| **Avoid global state** | ✅ PASS | No `$script:` or `$global:` state added in production code. |
| **Error handling** | ✅ PASS | Property presence is still tested before the value is read, so strict mode does not throw on an absent key (absent-key rows pass). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Largest covered file 482 logical lines. |
| **Approved verbs** | ✅ PASS | No function added; test helper `Invoke-StrictDecision` uses an approved verb. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `format.2026-10-31T06-25.md` |
| **Step 2: Analyze** | ✅ PASS | `pssa.2026-10-31T06-25.md` |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `pester-coverage.2026-10-31T06-32.md`, `single-process-tests-scripts.2026-10-31T06-50.md` |
| **Rerun loop if needed** | ✅ PASS | No stage auto-fixed a file, so no restart was needed. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `Describe`/`Context`/`It -ForEach`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks`<br>**Config:** `config/poshqc-coverage.json` unchanged. |
| **PowerShell 7+ Compatible** | ✅ PASS | `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 13, 9, and 9 rows (including one probe row each). |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert return values and gate decisions, not expression text. |
| **Mocking Used Sparingly** | ✅ PASS | Mocks only at I/O and resolution seams, following the existing suites for the same hooks. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-hooks/*.EpicModeStrict.Tests.ps1`<br>**Code files:** `.claude/hooks/*.ps1`<br>Placement follows the existing `tests/scripts/claude-hooks/` convention for `.claude/hooks/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All three suites end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per suite with behavior `Context` blocks. |
| **Logical Grouping** | ✅ PASS | Unit rows and decision rows in separate contexts. |
| **Docstrings/Comments** | ✅ PASS | Suite-level help blocks. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest`<br>**Result:** 5623 passed, 0 failed. |
| **No Alternative Test Runners** | ✅ PASS | Direct `Invoke-Pester` runs are used only for fail-before, shuffle, and single-process isolation checks, not as a substitute gate. |

---

## 5. Test Coverage Detail

### enforce-epic-merge-gate.EpicModeStrict.Tests.ps1 (13 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| baseline mock interception probe | Isolation guard | n/a | ✅ |
| `Test-ChildCheckpointAllowsEpicMerge` value matrix (8 rows) | Positive / Negative / Edge Case | `Test-ChildCheckpointAllowsEpicMerge` | ✅ |
| `Invoke-EpicMergeGateDecision` branch 1 (3 rows) | Positive / Negative | branch 1 and final deny | ✅ |
| otherwise green standalone checkpoint with `"false"` denies, zero live-head lookups | Edge Case | green-CI branch guard | ✅ |

**Coverage:** 100.00% (132/132 lines) for `enforce-epic-merge-gate.ps1`.

### enforce-pr-author-skill.epic-base-branch.EpicModeStrict.Tests.ps1 (9 tests)

Probe row plus eight value-matrix rows on `Test-EpicBaseBranchOverride`. **Coverage:** 93.55% (29/31). **Not covered (unchanged from baseline):** the file-absent return in `Get-PrAuthorCheckpointContent` and the `ConvertFrom-Json` catch return.

### enforce-model-routing-receipt.EpicModeStrict.Tests.ps1 (9 tests)

Probe row plus eight value-matrix rows on `Get-ModelRoutingAuthorAssertedReason`. **Coverage:** 96.43% (81/84). **Not covered (unchanged from baseline):** lines in `Invoke-ModelRoutingReceiptDecision` and the script entry point.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 13518 (full `tests/scripts`); 5623 (`tests/scripts/claude-hooks` with coverage) | ✅ |
| Tests Passed | 13508 (10 pre-existing skips); 5623 | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Not recorded in evidence | N/A |
| Average Time per Test | Not recorded in evidence | N/A |
| Discovery Time | Not recorded in evidence | N/A |
| Functions/Classes Tested | 3/3 changed functions plus `Invoke-EpicMergeGateDecision` | ✅ |
| Test File Size | 60 to 109 logical lines for new suites | ✅ PASS |
| Code Coverage (if applicable) | Modified hooks 100.00%, 93.55%, 96.43%; repo-wide 48.03% in a claude-hooks-only artifact (full-suite figure absent) | ❌ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 of 9 files would change | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 findings on 9 files | ✅ |
| Pester Tests | `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks` | 5623 passed, 0 failed | ✅ |

**For contract checks:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Mirror contract pytests | `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` | 34 passed | ✅ |
| Mirror parity | `cmp` of each source and bundled mirror (this review) | 3 of 3 identical | ✅ |

**Notes:**
The 10 skipped Pester tests are pre-existing skip conditions in files this change does not touch. No CI run exists for the head (no PR exists yet).

---

## 8. Gaps and Exceptions

### Identified Gaps
- **PA-1 (FAIL, blocking): repo-wide PowerShell line coverage is not established at or above 85%.** The coverage artifact present in the worktree, `artifacts/pester/powershell-coverage.xml`, was generated by `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks` and reports 10717/22315 = 48.03% lines across the full `config/poshqc-coverage.json` population. The fresh `tests/scripts` run was executed without coverage. Remediation: run `Invoke-PoshQCTest -Root . -ScanFolders tests/scripts` with coverage enabled on the branch head, read the repo-wide LINE counter from the regenerated `artifacts/pester/powershell-coverage.xml`, and record it with the per-file figures for the three hooks under `<FEATURE>/evidence/qa-gates/`. The prior full-suite figure recorded for issue #1009 on 2026-10-30 was 93.51% (20726/22165), so the shortfall is expected to be an evidence scope gap rather than a code gap; this review does not verify that expectation.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
**None.** No test was removed or skipped by this change.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **f271be37c** - docs(feature): prepare issue 1001 epic_mode strict-boolean fix
2. **c585d13f8** - Merge remote-tracking branch 'origin/main' into bug/merge-gate-epic-mode-string-false-1001
3. **bcfd08bfa** - docs(features): record issue 1001 phase 0 baseline evidence
4. **0a7baa9d3** - test(hooks): add strict epic_mode regression suites for issue 1001
5. **5ae92c030** - fix(hooks): treat only JSON boolean true as epic_mode (issue 1001)
6. **9391e1a34** - chore(extension): mirror strict epic_mode hooks into the bundle (issue 1001)
7. **6e062e814** - docs(features): record issue 1001 final PowerShell QA evidence
8. **42a555468** - docs(features): record issue 1001 test isolation evidence
9. **efa425952** - docs(features): record issue 1001 scope check and self-review

### Files Modified

1. **`.claude/hooks/enforce-epic-merge-gate.ps1`** (MODIFIED) - strict `epic_mode` test in `Test-ChildCheckpointAllowsEpicMerge`; help text.
2. **`.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`** (MODIFIED) - strict `epic_mode` test in `Test-EpicBaseBranchOverride`; help text.
3. **`.claude/hooks/enforce-model-routing-receipt.ps1`** (MODIFIED) - `-eq $true` replaced by strict test in `Get-ModelRoutingAuthorAssertedReason`; help text.
4. **Bundled mirrors** of the three hooks (MODIFIED) - byte-identical to sources.
5. **Tests** (NEW): three `*.EpicModeStrict.Tests.ps1` suites.
6. **Feature folder** documents and evidence (NEW).

---

## 10. Compliance Verdict

### Overall Status: ❌ NON-COMPLIANT (one evidence gap)

All code-change, formatting, analysis, test, file-size, scope, mirror, and evidence-location requirements pass. The unit-test coverage policy requires a repo-wide PowerShell line figure at or above 85%; the only artifact available reports 48.03% because it was generated from a `tests/scripts/claude-hooks`-only run. PA-1 is autonomous to remediate by producing a full-suite coverage artifact.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present.
- ✅ Design Principles: single-expression fix per hook using an existing repository idiom.
- ✅ Module & File Structure: all files below 500 logical lines.
- ✅ Naming, Docs, Comments: help text updated across all copies.
- ✅ Toolchain Execution: clean final pass recorded.
- ✅ Summarize & Document: commits and self-review present.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and PSSA clean.
- ✅ PowerShell Design & Safety: property presence tested before value read.
- ✅ Structure & Naming: no new production functions.
- ✅ Toolchain: one clean pass.

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: shuffle and single-process isolation pass.
- ❌ Coverage & Scenarios: per-file PASS with no regression; repo-wide figure FAIL in the available artifact (PA-1).
- ✅ Test Structure: AAA and descriptive row labels.
- ✅ External Dependencies: mocked seams only; no temp files.
- ✅ Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 via PoshQC.
- ✅ Test Style & Structure: data-driven value matrix.
- ✅ Naming & Readability: `.Tests.ps1` naming.
- ✅ Toolchain: `Invoke-PoshQCTest`.

---

### Metrics Summary

- ✅ 13508/13508 executed tests passing in the full run (10 pre-existing skips)
- ✅ 3/3 changed functions tested across the eight-value matrix
- ❌ Repo-wide PowerShell line coverage not established (48.03% in a claude-hooks-only artifact); modified hooks 100.00%, 93.55%, 96.43% with no regression
- ✅ Proper file organization: tests under `tests/scripts/claude-hooks/`
- ✅ All code quality checks passing
- N/A Test execution time: not recorded in evidence

---

### Recommendation

**Remediation required before PR** (PA-1 only)

Produce a full `tests/scripts` coverage run, record the repo-wide PowerShell line figure under `<FEATURE>/evidence/qa-gates/`, and re-run this review. No source or test change is expected.

---

## Appendix A: Test Inventory

### Complete Test List

1. enforce-epic-merge-gate strict epic_mode › probe (1), `Test-ChildCheckpointAllowsEpicMerge` value matrix (8), decision rows (3), otherwise-green standalone row (1)
2. Test-EpicBaseBranchOverride strict epic_mode › probe (1), value matrix (8)
3. Get-ModelRoutingAuthorAssertedReason strict epic_mode › probe (1), value matrix (8)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing (full suite with coverage, required for PA-1)
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts
```

**Contract checks:**
```bash
poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:cacheprovider
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

**Review-side checks run by this audit:**
```bash
git diff --name-only ccec4eba82e272d27f7d81c0e0657a93110de5fb...HEAD
git diff ccec4eba82e272d27f7d81c0e0657a93110de5fb..HEAD -- .claude/hooks
# JaCoCo parse of artifacts/pester/powershell-coverage.xml (report-level and per-file LINE counters)
# cmp of each source hook and its bundled mirror; logical line counts of covered files
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-31
**Policy Version:** Current (as of audit date)

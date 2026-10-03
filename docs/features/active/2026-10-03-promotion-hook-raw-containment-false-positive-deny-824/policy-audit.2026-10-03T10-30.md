# Policy Compliance Audit: Token-aware R2 raw invocation matcher (#824)

---

**Audit Date:** 2026-10-03
**Audit Type:** Initial feature review (pass 1)
**Code Under Test:** Full branch diff `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5...90566dd4b1fa172cf6b559c79a2cb392211c6498` (103 files; resolved base `origin/main`). Production PowerShell, each mirrored byte-identically under `extensions/drm-copilot/resources/`:
- NEW: `.claude/hooks/hook-command-raw-invocation.ps1`, `.codex/hooks/hook-command-raw-invocation.ps1`
- MODIFIED: `.claude/hooks/hook-command-invocation.ps1`, `.codex/hooks/hook-command-invocation.ps1`

PowerShell tests: 2 new suites (`hook-command-raw-invocation.Tests.ps1` on each runtime) and 15 modified suites under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`. JSON: both `pack-manifests/core.json` files (one entry each). Markdown: feature-folder scoping documents, plan, research, and evidence.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 4 production (2 new, 2 modified) + 4 mirrors + 17 test files | 6626 in the executor full PoshQC run; 359 in the reviewer's 17 targeted suites (97 tagged Issue824) | ✅ 6626 total, 0 failures, 10 disabled (executor JUnit); 359 pass, 0 fail (reviewer) | 84.67% lines repo-wide; 99.19% lines `.claude` invocation helper; 97.58% lines `.codex` invocation helper | 84.72% lines repo-wide; 99.20% and 97.60% lines invocation helpers; 100% lines both raw-invocation modules | 100% (both new modules 21/21 lines; changed executable lines 18 and 211 hit on both runtimes) |
| JSON | 2 files (`core.json` x2) | N/A | ✅ manifest entries present; 27 parity and manifest pytest cases pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - zero TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/baseline/coverage.2026-10-03T09-46.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-10-03 10:12 local by the PoshQC full run; head commit 90566dd4 at 10:19 changed no production file after that run) and `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/coverage-delta.2026-10-03T10-13.md`
- Per-language comparison summary: section 1.2.1 below

---

## Executive Summary

The branch replaces rule R2 of `Resolve-CommandLineInvocation` (unordered substring containment) with `Test-CommandLineRawInvocation`, a token-bounded, order-preserving regex matcher in a new shared module on both runtimes. All 29 acceptance-criteria tests and every toolchain stage pass. Mirrors and manifests are in parity, and coverage of new and changed code is 100%.

The review found one blocking defect (CR-1, see the code review). The reviewer reproduced five wrapped bypass forms that the merge-base hooks deny and the head hooks allow, on both runtimes, through the real decision entry points. One of them is a real `git worktree remove` bypass of the epic worktree-removal gate. This contradicts issue requirement 4 ("Do not weaken detection of real bypasses") and the general clause of AC-14. The policy compliance items below are otherwise met.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- N/A — no Python files in the branch diff
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- N/A — no Bash files in the branch diff
- ✅ JSON: two manifest entries; validated by the pack-manifest completeness pytest files

Toolchain: the reviewer re-ran format (check-only, repo PSSA settings, 0 of 25 changed `.ps1` files drift), analyzer (0 findings), 17 affected Pester suites with coverage (359 pass), and the four parity pytest files (27 pass). The executor's full PoshQC run (6626 tests, 0 failures) is recorded in evidence.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time script is committed; the executor's scratch scripts live outside the repository (`evidence/baseline/scratch-scripts.2026-10-03T09-38.md`)
- ✅ No ongoing tooling script was added
- The reviewer's probe scripts were written to the session scratchpad only

## Rejected Scope Narrowing

None detected. The caller prompt supplied the base branch, the merge base, the PR-context artifacts, and the work mode, and did not narrow scope to a plan, task, phase, file subset, or language. The audit covers the full branch diff against `origin/main`.

## Evidence Location Compliance

- Branch diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: zero files.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`: exit 0, no violations reported.
- All feature evidence is under `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/{baseline,other,qa-gates,regression-testing}/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each new `It` builds its own command string and calls a pure seam; shared fixtures are read-only `$script:` here-strings set in `BeforeAll`. Mocks are scoped per `It` or `BeforeEach`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Unit rows drive `Test-CommandLineRawInvocation` only; hook rows drive one decision seam with one command each. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 359 tests in the 17 targeted suites ran with coverage in a single reviewer run of under two minutes; the matcher evaluates 90,000-character inputs in 5 ms or less (reviewer probe). |
| **Determinism** - Consistent results | ✅ PASS | Pure string inputs; no clock, RNG, network, child process, or temporary file. Checkpoint seams are mocked to `$null`. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row IDs (R824-P1..P20, R824-N1..N7, P824-A1..A3, P824-D1..D11, A824-*, N824-1) and `-Because` messages state the expected behavior. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 84.67% lines repo-wide (13325/15738); `.claude` helper 99.19%, `.codex` helper 97.58%<br>**Command:** PoshQC `Invoke-PoshQCTest` full run at merge-base content<br>**Timestamp:** 2026-10-03 09:46 (`evidence/baseline/coverage.2026-10-03T09-46.md`) |
| **No Coverage Regression** | ✅ PASS | **Post-change:** 84.72% lines repo-wide (13370/15782), +0.05 points; helpers 99.20% and 97.60%, each at or above baseline. The reviewer re-parsed `artifacts/pester/powershell-coverage.xml` and reproduced each figure. |
| **New Code Coverage** | ✅ PASS | **New files:** `hook-command-raw-invocation.ps1` on both runtimes, 21/21 lines = 100%.<br>**Changed lines:** line 18 (dot-source) and line 211 (R2 predicate) in both helpers are hit (`ci` 2 and 1) in the canonical artifact. All other helper edits are comment-only.<br>**Method:** reviewer parse of per-line `ci`/`mi` attributes in the JaCoCo XML. |
| **Comprehensive Coverage** | ✅ PASS | `Get-CommandLineRawInvocationPattern` and `Test-CommandLineRawInvocation` are both exercised by 27 unit rows per runtime plus all hook-level rows. |
| **Positive Flows** - Valid inputs | ✅ PASS | 20 positive unit rows per runtime (adjacency, spacing, case, leading punctuation, paths, `.exe`, quotes, options, expansions) and 11 promotion deny rows per runtime. |
| **Negative Flows** - Invalid inputs | ✅ PASS | 7 negative unit rows per runtime, 3 promotion allow rows, and per-hook allow rows for pr-author, both worktree gates, validate-bash, and the preimplementation gate. |
| **Edge Cases** - Boundary conditions | ⚠️ PARTIAL | Boundary cases (`newline` versus `new`, `removed` versus `remove`, all-expansion sequence) are covered. Multi-word expansion, splatting, and wrapped backslash-newline forms are not covered, and the matcher does not detect them (code review CR-1). |
| **Error Handling** - Error paths | ✅ PASS | The Unbalanced segment fail-closed path is pinned by P824-D11 on both runtimes. |
| **Concurrency** - If applicable | N/A | Pure stateless string functions. |
| **State Transitions** - If applicable | N/A | No state. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 84.67% lines -> Post-change: 84.72% lines. Change: +0.05% lines. New/changed-code coverage: 100% (new modules 21/21 lines each; changed executable lines 18 and 211 covered on both runtimes). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/baseline/coverage.2026-10-03T09-46.md`, `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/coverage-delta.2026-10-03T10-13.md`.

Threshold note: every changed and new PowerShell file is at or above 85% lines with no regression. The repo-wide figure (84.72%) is below the 85% target stated in `.claude/rules/quality-tiers.md`. It was already 84.67% at the merge base, the branch raises it, and the shortfall comes from packages this branch does not touch (`.codex/scripts` 593/1283 and `scripts/dev-tools` 898/1662 lines). The review contract's remediation trigger for repo-wide coverage is "< 80% repo-wide per language" (feature-review-workflow step 8 and the agent verification procedure), so this figure does not trigger remediation. It is recorded as gap G-2 and recommended for a follow-up issue. Pester emits no BRANCH counter, so no branch threshold applies to PowerShell.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Every new assertion carries `-Because` text naming the expected sequence or reason. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | New `It` blocks carry explicit Arrange/Act/Assert comments or a clear three-step layout. |
| **Document Intent** | ✅ PASS | Suite synopsis blocks describe purpose and the determinism constraints; row labels name each spelling. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No `gh`, network, git process, or filesystem write in any new test. |
| **Use Mocks/Stubs** | ✅ PASS | Checkpoint-reader seams (`Get-*CheckpointContent`) and `Get-PrContextArtifactExistence` are mocked; nothing else. |
| **Environment Stability** | ✅ PASS | No temporary files; no environment variables read; no global state mutation. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the pass-1 policy audit. Outstanding item: CR-1 remediation. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` (#824) define the defect, the root cause, and 29 ACs. |
| **Read existing change plans** | ✅ PASS | `research/research.2026-10-03T08-30.md` and `evidence/baseline/phase0-instructions-read.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-03T08-09.md` (preflight all clear, round 2). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One pattern builder and one predicate, 109 lines; a single-line call-site change in R2. |
| **Reusability** | ✅ PASS | The matcher sits in the shared helper path, so every resolver caller is corrected without per-hook edits. |
| **Extensibility** | ✅ PASS | Pattern construction is parameterized by command word and subcommand path. |
| **Separation of concerns** | ✅ PASS | Pure string logic in its own module; no I/O. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | New module holds only the R2 matcher. |
| **Under 500 lines** | ✅ PASS | Largest changed files: `legacy-codex-hook-contracts.Tests.ps1` 497, `hook-command-invocation.ps1` 491 (both runtimes), `hook-command-raw-invocation.ps1` 109. All 25 changed `.ps1` files are at or below 497 lines (reviewer `wc -l`). |
| **Public vs internal** | ✅ PASS | Public signatures of `Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag` unchanged (signature-pin tests pass without edits). |
| **No circular dependencies** | ✅ PASS | The new module dot-sources nothing; `hook-command-invocation.ps1` dot-sources it. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-CommandLineRawInvocationPattern`, `Test-CommandLineRawInvocation`; approved verbs. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on both functions and a module synopsis that lists the matching rules. |
| **Comment why, not what** | ✅ PASS | The corrected R2 and option-table comments state which callers hard-deny on a classification. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter` check-only with `pssa.settings.psd1` on the 25 changed `.ps1` files (reviewer); executor `Invoke-PoshQCFormat` rewrote 0 of 620 files.<br>**Result:** 0 drift. |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` on changed files (reviewer); executor `Invoke-PoshQCAnalyze`.<br>**Result:** 0 findings. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-Pester` with coverage on the 17 affected suites (reviewer); executor `Invoke-PoshQCTest -Root .`<br>**Result:** 359/359 pass (reviewer); 6626 total, 0 failures (executor). |
| **Full toolchain loop** | ✅ PASS | One clean loop pass (`evidence/qa-gates/qc-loop-complete.2026-10-03T10-15.md`). |
| **Explicit reporting** | ✅ PASS | Commands and results are recorded in `evidence/qa-gates/` and in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `90566dd4` message and the audit record `evidence/other/containment-path-hook-audit.md`. |
| **Design choices explained** | ✅ PASS | Spec "Proposed Fix" and research Option A. |
| **Update supporting documents** | ✅ PASS | Helper comments corrected (AC-22); no external docs require change. |
| **Provide next steps** | ⚠️ PARTIAL | Spec lists six follow-ups; none is filed yet, and the CR-1 regression classes are not among them. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .`<br>**Result:** 0 files rewritten (executor); 0 drift on changed files (reviewer). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** no findings. |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The module uses `[regex]`, `StringBuilder`, and `RegexOptions`, which are available in both editions; no 7-only syntax. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Both functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `ValidateNotNullOrEmpty` on `SubcommandPath`, `AllowEmptyString` on `RawText`. |
| **Avoid global state** | ✅ PASS | No script or global variables in the new module. |
| **Error handling** | ✅ PASS | No I/O; command word and subcommands are escaped with `[regex]::Escape`. Backtracking is bounded (90,000-character input in 5 ms or less). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 109 and 491 lines. |
| **Approved verbs** | ✅ PASS | `Get`, `Test`. |
| **Comment why** | ✅ PASS | Module synopsis explains each rule's rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 3B.1. |
| **Step 2: Analyze** | ✅ PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 6626 total, 0 failures (executor); 359/359 (reviewer). |
| **Rerun loop if needed** | ✅ PASS | One pass. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | One string entry inserted in sorted position in each manifest; `evidence/qa-gates/manifest-json.2026-10-03T10-13.md`. |
| **Schema validation** | ✅ PASS | Pack-manifest completeness pytest files pass (27 cases including the resource-contract files). |
| **Required $schema** | N/A | Pack manifests are not schema-governed files. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | No comments or trailing commas added. |
| **Deterministic key order** | ✅ PASS | Path list remains alphabetical. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules Pester 5.0.0`; `BeforeAll`, `-ForEach` data rows, `Should -BeTrue/-BeFalse/-Be`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. The coverage path list already covers the hooks directories, and the new module appears in the canonical artifact. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Test files declare `#Requires -Version 7.0`, matching the existing hook suites. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 27 unit rows per runtime plus 43 hook-level rows across both runtimes. |
| **Test Behavior Over Implementation** | ✅ PASS | Tests assert decisions and boolean classification, not the regex text. |
| **Mocking Used Sparingly** | ✅ PASS | Only checkpoint and artifact-existence seams. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1`<br>**Code file:** `.claude/hooks/hook-command-raw-invocation.ps1`<br>This follows the established `claude-hooks` and `codex-hooks` test-tree convention. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `hook-command-raw-invocation.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe, 2 Contexts, 2 data-driven Its per new suite; new Contexts in each modified suite. |
| **Logical Grouping** | ✅ PASS | Positive and negative rows separated; hook rows grouped under "issue #824" Contexts. |
| **Docstrings/Comments** | ✅ PASS | Synopsis blocks and per-row labels. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** 6626 total, 0 failures. |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### Test-CommandLineRawInvocation and Get-CommandLineRawInvocationPattern (54 unit tests across both runtimes)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| R824-P1..P20 | Positive | 49-66, 92-106 | ✅ |
| R824-N1..N7 | Negative and edge case | 49-66, 92-108 | ✅ |

**Coverage:** 100% of the module (21/21 lines) on each runtime.

**Not covered:** None.

### Resolve-CommandLineInvocation R2 branch (hook-level, 43 tests across both runtimes plus N824-1 on each)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| P824-A1..A3 | Negative (allow) | 210-212 | ✅ |
| P824-D1..D11 | Positive (deny) and fail-closed | 203-212 | ✅ |
| N824-1 | Negative control | 210-212 | ✅ |
| A824-PR1, A824-WT1/WT2, A824-VB1, A824-PI1, A824-MG1 | Per-hook audit regressions | 210-212 | ✅ |

**Negative-control discrimination (reviewer):** with `Test-CommandLineRawInvocation` redefined in-process as `Test-CommandLineRawContainment`, `Test-CommandLineInvocation` on the reproduction returns `True`, so N824-1 fails on revert as AC-15 requires.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 6626 (executor full run); 359 (reviewer targeted) | ✅ |
| Tests Passed | 6626 (100% of enabled); 359 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | under two minutes for the reviewer's 17 suites with coverage | ✅ Fast |
| Issue824-tagged tests | 97 | ✅ |
| Functions Tested | 2/2 new functions | ✅ |
| Test File Size | 77 lines per new suite; max modified 497 | ✅ Maintainable |
| Code Coverage (if applicable) | 84.72% lines repo-wide; 100% new and changed code; no branch counter in Pester | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | 0 files rewritten; reviewer check-only 0 drift | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 6626 total, 0 failures | ✅ |

**Notes:** Parity pytest files (AC-24): 27 passed (reviewer). No PR exists for the branch yet, so CI (AC-27) has not run.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **G-1 (Blocking, autonomous) — detection regression for wrapped bypass forms.** Reproduced by the reviewer at merge base `f6ef5b2f` (deny) and head `90566dd4` (allow) on both runtimes through `Invoke-PromotionMcpOnlyDecision` and `Invoke-EpicWorktreeRemovalGateDecision`: `bash -c 'cmd="issue create"; gh $cmd'`; `pwsh -c '$a = "issue","create"; gh @a'`; `bash -c 'args=(issue create); gh "${args[@]}"'`; a wrapped backslash-newline continuation `bash -c "gh issue \` newline `create"`; and `bash -c 'a="worktree remove"; git $a ../x'` (worktree-removal gate). See code review CR-1 and remediation inputs R1.
- **G-2 (Non-blocking) — repo-wide PowerShell line coverage 84.72% is below the 85% target.** This condition already existed at the merge base (84.67%), and the branch raises the figure. It is above the review contract's 80% remediation trigger. Recommend a follow-up issue for `.codex/scripts` and `scripts/dev-tools` coverage.
- **G-3 (Non-blocking) — spec follow-ups not yet filed.** The six Non-Goals items should be filed as potential records or issues.
- **G-4 (Informational, policy-text discrepancy).** The agent verification procedure cites 90% for new files and 80% repo-wide, while `.claude/rules/quality-tiers.md` sets a uniform 85%. This audit applied 85% for file-level gates and the 80% remediation trigger for repo-wide coverage.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented. The 10 disabled tests in the full run match the baseline count.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **d058a196** - docs(824): add promoted potential record and active feature folder scaffold
2. **ff807f73** - docs(824): add research and spec for raw-containment false-positive deny
3. **c348e494** - docs(824): add approved atomic plan (preflight all clear, round 2)
4. **90566dd4** - fix(824): replace R2 raw containment with a token-aware sequence matcher

### Files Modified

1. **`.claude/hooks/hook-command-raw-invocation.ps1`**, **`.codex/hooks/hook-command-raw-invocation.ps1`** (NEW, identical) — token-aware matcher.
2. **`.claude/hooks/hook-command-invocation.ps1`**, **`.codex/hooks/hook-command-invocation.ps1`** (MODIFIED, identical) — dot-source, R2 predicate, corrected comments.
3. Four mirrors under `extensions/drm-copilot/resources/` (NEW/MODIFIED, byte-identical) and two `pack-manifests/core.json` (MODIFIED).
4. 17 Pester suites (2 NEW, 15 MODIFIED) and `legacy-codex-hook-contracts.Tests.ps1` line 30.
5. Feature folder documents and evidence (NEW).

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain, coverage, structure, parity, and evidence-location requirements are met. One blocking behavioral defect (G-1, CR-1) requires remediation before the branch is ready for a PR.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: research, spec, and preflighted plan present
- ✅ Design Principles: simple shared module
- ✅ Module & File Structure: all files at or below 497 lines
- ✅ Naming, Docs, Comments: comments corrected per AC-22
- ✅ Toolchain Execution: one clean pass
- ⚠️ Summarize & Document: follow-ups not yet filed

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean
- ✅ PowerShell Design & Safety: advanced functions, validated parameters, bounded regex
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: single pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, deterministic
- ⚠️ Coverage & Scenarios: coverage met; bypass edge cases in G-1 not covered
- ✅ Test Structure: AAA and `-Because` messages
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC
- ✅ Test Style & Structure: behavior-focused rows
- ✅ Naming & Readability: row IDs and labels
- ✅ Toolchain: 6626 total, 0 failures

---

### Metrics Summary

- ✅ 6626 tests, 0 failures (executor); 359/359 targeted (reviewer)
- ✅ 2/2 new functions tested
- ✅ 100% new and changed-code line coverage; 84.72% repo-wide (+0.05 points)
- ✅ Test files mirror the established hook test trees
- ✅ Format, analyze, and parity checks pass
- ❌ One blocking bypass-detection regression (G-1)

---

### Recommendation

**Needs revision**

Remediate CR-1 (remediation inputs R1): restore detection of the five reproduced bypass forms without reintroducing the #824 false positive, add Issue824-tagged deny rows for each on both runtimes, then re-run the PowerShell toolchain and request a reaudit.

---

## Appendix A: Test Inventory

### Complete Test List

1. hook-command-raw-invocation (issue #824) › positive rows › R824-P1..P20 (each runtime)
2. hook-command-raw-invocation (issue #824) › negative rows › R824-N1..N7 (each runtime)
3. hook-command-invocation › fail-closed rules › N824-1 negative control (each runtime); renamed "token-aware ordered sequence" test (each runtime)
4. enforce-promotion-mcp-only trigger scoping › issue #824 › P824-A1..A3, P824-D1..D11 (each runtime)
5. enforce-pr-author-skill trigger scoping › issue #824 › A824-PR1
6. enforce-epic-worktree-removal-gate trigger scoping › issue #824 › A824-WT1, A824-WT2 (each runtime)
7. enforce-parallel-worktree-removal-gate trigger scoping › issue #824 › A824-WT1, A824-WT2
8. validate-bash trigger scoping › issue #824 › A824-VB1 (each runtime)
9. enforce-orchestration-preimplementation-gate trigger scoping › issue #824 › A824-PI1 (each runtime)
10. enforce-epic-merge-gate trigger scoping › issue #824 › A824-MG1 (each runtime)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting (check-only, reviewer)
Invoke-Formatter -ScriptDefinition (Get-Content <file> -Raw) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Linting (reviewer)
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing with coverage (reviewer, 17 affected suites)
$c = New-PesterConfiguration; $c.Run.Path = <17 suite paths>; $c.CodeCoverage.Enabled = $true; Invoke-Pester -Configuration $c

# Full PoshQC loop (executor)
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .
```

**For Python (parity checks):**
```bash
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py --no-cov
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-03
**Policy Version:** Current (as of audit date)

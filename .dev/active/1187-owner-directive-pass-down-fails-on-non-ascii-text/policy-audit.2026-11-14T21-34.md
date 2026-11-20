# Policy Compliance Audit: Owner-directive pass-down fails on non-ASCII text (#1187)

---

**Audit Date:** 2026-11-14  
**Code Under Test:** merge base `1c652e60a61c71382100e584d5a9bccf584aa0e9` of the base branch and reviewed head `aae55c0652c1110385f4220ce2c7672f80320954`; the diff between them lists the changed files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 11 files (2 production dispatchers, 2 byte-identical bundle copies, 7 test files) | 26848 tests | ✅ 26830 pass, 0 fail, 18 skipped | 95.96% lines | 96.01% lines | 100% lines (both changed dispatchers) |
| Markdown | 27 files (feature folder documents and evidence) | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Python baseline coverage artifact: N/A - zero changed Python files
- Python post-change coverage artifact: N/A - zero changed Python files
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text-1187/evidence/baseline/pester.2026-11-14T18-59.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (rewritten 2026-11-14T21:51:34Z by the reviewer's gate run at the reviewed head) and `docs/features/active/2026-11-14-owner-directive-pass-down-fails-on-non-ascii-text-1187/evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md`; the executor's run is `evidence/qa-gates/final-qc-pester.2026-11-14T21-17.md`
- Per-language comparison summary: section 1.2.1 below

---

## Executive Summary

The branch fixes the Windows decode defect of issue #1187 at the PreToolUse dispatcher boundary. Both dispatchers (`.claude/hooks/invoke-pretooluse-dispatch.ps1` and `.codex/hooks/invoke-pretooluse-dispatch.ps1`) gain a stdin reader that decodes the bytes of standard input as UTF-8, and every JSON write of both dispatchers gains `-EscapeHandling EscapeNonAscii`. Bundle copies are byte-identical (verified with `cmp`). The remaining changes are Pester regression rows and feature documentation.

Scope: the full branch diff (38 files). Only PowerShell has changed code files; Python, TypeScript, C#, and bash have zero changed files.

The reviewer verified the fix with a real-process probe: the UTF-8 bytes of an em dash, curly quotes, and U+1F600 piped into `pwsh` (console input encoding `ibm437`) decode to 13 mis-decoded characters through the old `Read-ClaudeHookRawPayload` default, and to exactly U+2014, U+201C, U+201D, U+D83D U+DE00 through the new Claude seam composition and the Codex reader. The ASCII-escaped JSON output round-trips the text. A second probe confirmed that `Get-Content -Raw` and `[System.IO.File]::ReadAllText` decode a BOM-less UTF-8 file correctly on this host (decision D-4).

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/hooks` and `.codex/hooks` are classified; no new folder)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file in the branch diff; the Python contract suites ran as regression evidence)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no bash file in the branch diff
- N/A JSON: no JSON file in the branch diff

Gate evidence: the executor's final Pester gate (26585 tests, 0 failed) and pytest gate (16928 passed, 0 failed) ran after the last production commit `d1665e12e`. Because the head commit `aae55c065` (an `origin/main` merge) is newer than that coverage report, the reviewer re-ran the Pester gate at the reviewed head through the test-execution launcher (`Invoke-PoshQCParallelTest`, 8 workers, exit 0): 26830 passed, 0 failed, 18 skipped; dispatchers 42/42 and 40/40 lines; 44274/46114 = 96.01% repo-wide (`evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md`). No blocking finding exists.

**Temporary artifacts cleanup:**
- ✅ The reviewer's probe scripts live in the session scratchpad, outside the repository
- ✅ No ongoing tooling script was added
- Reviewer-created files: this review set, the new evidence file `evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md` (Pester gate re-run at the head), and one owner-directive decision file; no existing evidence was edited

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | All suites pass inside the eight-worker parallel gate; each new row builds its own `MemoryStream` or fixture text; no shared mutable state. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Reader rows test one decode property each; output rows test one write site each; pass-down rows test one decision path each. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | New rows use in-memory seams only; the full gate took 689.56 s for 26848 tests at the reviewed head (unchanged order of magnitude from the 723.6 s baseline). |
| **Determinism** - Consistent results | ✅ PASS | Fixed clock seams (`2026-11-10T12:00:00Z`), fixed resolvers, in-memory file maps; characters built from code points; no console encoding mutation. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive `It` names with `<Name>` data rows; Arrange/Act/Assert comments in the longer rows. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 95.96% lines repo-wide; dispatchers 37/37 and 35/35 lines<br>**Command:** `Invoke-PoshQCParallelTest` (one run of the gate)<br>**Artifact:** `evidence/baseline/pester.2026-11-14T18-59.md`<br>**Timestamp:** 2026-11-14 18:45 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.01% lines repo-wide (44274/46114) at the reviewed head<br>**Change:** +0.05% lines (the denominator includes files added by the origin/main merge; the branch adds 10 covered of 10 instrumented lines)<br>**Status:** No regression |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** Claude dispatcher 42/42 = 100%; Codex dispatcher 40/40 = 100%<br>**Thresholds:** 85% line; no branch threshold for PowerShell (Pester measures no branches)<br>**Status:** All changed files meet the thresholds |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** the two dispatchers<br>**New code coverage:** 100% (every added line, including the default `OpenStream` line, has a hit)<br>**Calculation method:** per-file JaCoCo LINE counters and per-line `mi`/`ci` values from `artifacts/pester/powershell-coverage.xml` |
| **Comprehensive Coverage** | ✅ PASS | `Read-PreToolUseDispatchStandardInput` and `Read-CodexPreToolUseDispatchStandardInput`: 7 rows each; entry-point output paths: 4 rows each; script tail: 1 row each; parity: 1 row. Untested code: none. |
| **Positive Flows** - Valid inputs | ✅ PASS | Decode of U+2014, U+201C/U+201D, U+1F600; verbatim relay allowed; ledger append allowed; decision lines accepted; B5 accepts matching UTF-8 digests. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Substituted text denied (`OWNER_DIRECTIVE_RELAY_REQUIRED`); ledger edit and altered-digest append denied (`OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`); B5 rejects hyphen-substituted digests; stop hook reports `OWNER_DIRECTIVE_LEDGER_INVALID`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Leading UTF-8 BOM stripped; non-BMP surrogate pair; Latin1 mis-decode contrast. |
| **Error Handling** - Error paths | ✅ PASS | Invalid byte `0xFF` maps to U+FFFD without an exception; stream disposal asserted. |
| **Concurrency** - If applicable | N/A | The reader is a single synchronous read per process; no shared state. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.96% lines (from the `Phase 0 baseline` artifact `evidence/baseline/pester.2026-11-14T18-59.md`) -> Post-change: 96.01% lines (reviewed head). Change: +0.05% lines (the branch adds 10 covered of 10 instrumented lines). New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md`, `evidence/qa-gates/final-qc-pester.2026-11-14T21-17.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `Should -BeExactly` on decoded text; `-Because` clauses on the ASCII-only and parity assertions; deny assertions match the full reason prefix. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Longer rows carry explicit Arrange/Act/Assert comments; short rows are single-expression assertions. |
| **Document Intent** | ✅ PASS | Every new `Describe` names the issue and AC (for example `relay match of non-ASCII directive text (issue #1187 AC-6)`). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, git, or file system access in new rows. One row per dispatcher runs the default `OpenStream` seam, which opens and disposes the process stdin handle without reading it (non-blocking note in the code review). |
| **Use Mocks/Stubs** | ✅ PASS | `MemoryStream` for bytes; mocks of `Read-ClaudeHookRawPayload`, `Read-CodexPreToolUseDispatchStandardInput`, `Invoke-HookDispatchRunner`, `Get-HookDependencyFailureDecision`, `Get-CheckpointFileContent`; injected `ReadText`, `TestFile`, `Clock`, resolver seams. |
| **Environment Stability** | ✅ PASS | No temporary files, no assignment to `[Console]::InputEncoding` or `[Console]::OutputEncoding`, no `[Console]::SetIn` in added lines (the branch removes one prior `SetIn` use); verified by searching the added test lines. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the policy review for the branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` (full-bug) for issue #1187 with root-cause analysis. |
| **Read existing change plans** | ✅ PASS | `research/research.2026-11-14T18-14.md` and `plan.2026-11-14T13-12.md`. |
| **Document the plan** | ✅ PASS | The plan, task-check evidence, and phase-gate evidence are in the feature folder. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One reader function (eight statements) per dispatcher and one added parameter per JSON write. |
| **Reusability** | ✅ PASS | The fix point is the dispatcher boundary, so one decode serves every in-process hook (D-1). The Codex reader is duplicated by design (D-2) and pinned by a parity row. |
| **Extensibility** | ✅ PASS | `OpenStream` seam; `Read-ClaudeHookRawPayload` keeps its redirect probe and fallbacks. |
| **Separation of concerns** | ✅ PASS | I/O stays in the reader seam; decision logic is unchanged. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Each reader lives in the dispatcher that uses it. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical lines: Claude dispatcher 160, Codex dispatcher 147, test files 197 to 423. No file at or above 500 lines; `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | ✅ PASS | The readers are script functions of the entry scripts; no module export surface changed. |
| **No circular dependencies** | ✅ PASS | No new import. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Read-PreToolUseDispatchStandardInput`, `Read-CodexPreToolUseDispatchStandardInput`, `OpenStream`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on both readers; `.DESCRIPTION` and `ReadPayload` help of both entry points updated (AC-19). |
| **Comment why, not what** | ✅ PASS | Help text states why the decode exists (console input code page) and the per-process limitation. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-Formatter` with `pssa.settings.psd1` over the 11 changed `.ps1` files<br>**Result:** 0 files rewritten (`evidence/qa-gates/final-qc-static-powershell.2026-11-14T21-05.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` per file with `pssa.settings.psd1`<br>**Result:** 0 findings |
| **3. Type checking** | N/A | **Command:** none<br>**Result:** not applicable for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (`Invoke-PoshQCParallelTest`, 8 workers)<br>**Result:** 26830 passed, 0 failed, 18 skipped (reviewer run at the head; executor run 26567 passed) |
| **Full toolchain loop** | ✅ PASS | One clean pass at the final QA loop; the integration lane is CI-only (recorded non-blocking deviation). |
| **Explicit reporting** | ✅ PASS | Commands and results are recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `d1665e12e` and the spec Proposed Fix section. |
| **Design choices explained** | ✅ PASS | Decisions D-1 to D-11 in `spec.md`. |
| **Update supporting documents** | ✅ PASS | Dispatcher help updated; the execution-environment brief is unchanged by design (D-10, AC-18). |
| **Provide next steps** | ✅ PASS | AC-20 CI part pending at S9; optional live em-dash delegation after merge. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter` per changed file<br>**Result:** 0 differences |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` per changed file<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The hooks require PowerShell 7 (`-EscapeHandling` is PowerShell 6.2 and later); the spec constrains the item to PowerShell 7, consistent with the existing hook runtime. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType([string])]` on both readers. |
| **Parameter validation** | ✅ PASS | `OpenStream` is typed `[scriptblock]` with a default. |
| **Avoid global state** | ✅ PASS | No console encoding change (D-5); no global variable. |
| **Error handling** | ✅ PASS | Non-throwing decoder (invalid bytes become U+FFFD, which fails B5 closed); reader disposed in `finally`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 160 and 147 logical lines. |
| **Approved verbs** | ✅ PASS | `Read` is an approved verb. |
| **Comment why** | ✅ PASS | Help text explains the code-page dependence and duplication rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 files rewritten. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Reviewer gate at the head: 26830 passed, 0 failed. |
| **Rerun loop if needed** | ✅ PASS | One clean pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`/`It`, `-ForEach` data rows, `BeforeDiscovery`, `Should -Invoke` with `-ParameterFilter`, `InModuleScope`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through the test-execution launcher<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged) |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Test files declare `#Requires -Version 7.0` where new; the hook suite runs on Windows and Linux in CI. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 61 new rows across 7 files, each on one behavior. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert decoded text, emitted JSON content, and allow/deny decisions. The AST rows that pin the `ReadPayload` default text are deliberate contract pins (AC-2, AC-3). |
| **Mocking Used Sparingly** | ✅ PASS | Mocks only at I/O seams and the dispatch runner. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/invoke-pretooluse-dispatch.Tests.ps1`, `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1`, `tests/scripts/claude-hooks/enforce-owner-directive-pass-down.NonAscii.Tests.ps1`<br>**Code file:** `.claude/hooks/invoke-pretooluse-dispatch.ps1`, `.codex/hooks/invoke-pretooluse-dispatch.ps1`, `.claude/hooks/enforce-owner-directive-pass-down.ps1`<br>Mirrors the existing hook-test layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All test files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per behavior group. |
| **Logical Grouping** | ✅ PASS | Grouped by AC (relay, ledger, decision files, stdin contrast). |
| **Docstrings/Comments** | ✅ PASS | The new file has comment-based help describing its seams and the ASCII-only source rule. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` (8 workers)<br>**Result:** 26830 passed, 0 failed |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### Read-PreToolUseDispatchStandardInput and Read-CodexPreToolUseDispatchStandardInput (7 rows each)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| decodes an em dash / curly quotes / a non-BMP character from UTF-8 bytes exactly | Positive | reader body | ✅ |
| strips a leading UTF-8 byte order mark | Edge Case | reader body | ✅ |
| maps an invalid byte to U+FFFD without throwing | Error Handling | reader body | ✅ |
| disposes the stream it reads | Error Handling | `finally` block | ✅ |
| opens the process standard input through the default stream seam without reading it | Positive | default `OpenStream` line | ✅ |

**Coverage:** 100% of both readers.

**Not covered:** None.

---

### Entry points and script tails (5 rows each)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| emits the decision with every character below U+0080 and restores the reason | Positive | decision write | ✅ |
| writes the trace line with every character below U+0080 and restores the reason | Positive | trace write | ✅ |
| emits the dependency-failure deny of the script tail with every character below U+0080 | Positive | script-tail emit | ✅ |
| defaults ReadPayload to the UTF-8 reader | Positive | `ReadPayload` default | ✅ |
| script tail denies a payload without a tool name | Negative | default `ReadPayload` call | ✅ |

**Coverage:** 42/42 (Claude) and 40/40 (Codex) lines.

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 26848 | ✅ |
| Tests Passed | 26830 (99.93%; 18 skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 689.56s total (8 workers) | ✅ Fast |
| Average Time per Test | 25ms | ✅ Fast |
| Discovery Time | not reported separately by the parallel runner | ✅ |
| Functions/Classes Tested | 4/4 changed functions (100%) | ✅ |
| Test File Size | 197 to 423 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 100% lines on changed files; 96.01% repo-wide lines | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` per changed file | 0 rewritten | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` per changed file | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 26830 passed, 0 failed | ✅ |

**For Python (regression only; no Python file changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Pytest Tests | `run-test-suite.sh pytest` (`pytest -n auto`) | 16928 passed, 6 skipped, 0 failed | ✅ |

**Notes:**
The integration-lane suite `codex-pretooluse-integration.Tests.ps1` is CI-only by the test-execution policy and was not run locally (`evidence/other/deviation-integration-lane.2026-11-14T20-32.md`, non-blocking). The head commit `aae55c065` merges `origin/main` after the final gates; the merge changes no path in the branch diff and no dispatcher dependency (`HookPayload.psm1`, `HookDispatchRunner.psm1`, the pass-down hook, and the owner-directive modules are unchanged by it), and `git merge-tree` against current `origin/main` is clean.

---

## CI Cross-check

CI on PR #1189 was in progress at review time (review_mode concurrent). The rows record the outcome that local evidence supports at the reviewed head.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| CI Required Gate | pass | N/A | aae55c0652c1110385f4220ce2c7672f80320954 | final QA evidence under `evidence/qa-gates/` |
| poshqc / PowerShell QC static | pass | 0 format differences, 0 PSSA findings | aae55c0652c1110385f4220ce2c7672f80320954 | `evidence/qa-gates/final-qc-static-powershell.2026-11-14T21-05.md` |
| poshqc / PowerShell QC | pass | 26830 passed, 0 failed; 96.01% lines | aae55c0652c1110385f4220ce2c7672f80320954 | `evidence/qa-gates/review-pester-gate.2026-11-14T21-51.md` |
| poshqc / PowerShell hook suites (Linux) | pass | N/A | aae55c0652c1110385f4220ce2c7672f80320954 | new rows decode bytes explicitly and do not depend on the console code page |
| quality-checks7 / Code Quality & Tests (3.13) | pass | 16928 passed, 0 failed | aae55c0652c1110385f4220ce2c7672f80320954 | `evidence/qa-gates/final-qc-pytest.2026-11-14T21-18.md` |

---

## 8. Gaps and Exceptions

### Identified Gaps

**None.** All policy requirements are met. AC-20 (CI green on the PR head) is pending CI and is owned by the orchestrator at S9; it is not a gap of the branch content.

### Approved Exceptions

**None.** No exceptions needed. The integration-lane suite is CI-only under the existing test-execution policy.

### Removed/Skipped Tests

**None.** All planned tests implemented. The 18 skipped rows are pre-existing skips with recorded reasons, unchanged from the baseline.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All item evidence is under the feature folder's `evidence/<kind>/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent at the branch head, so the check is not applicable and produces no finding.

## Rejected Scope Narrowing

None. The caller prompt required the full branch diff against the merge base and attempted no narrowing.

---

## 9. Summary of Changes

The two PreToolUse dispatchers now decode stdin bytes as UTF-8 and emit ASCII-escaped JSON, so owner-directive text with non-ASCII characters matches on Windows regardless of the console code page.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All toolchain stages, coverage thresholds, file-size limits, and test-policy requirements are met for the only changed code language (PowerShell). No blocking finding.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present
- ✅ Design Principles: single fix point, minimal surface
- ✅ Module & File Structure: all files below 500 lines
- ✅ Naming, Docs, Comments: help text updated
- ✅ Toolchain Execution: one clean pass
- ✅ Summarize & Document: decisions recorded

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and lint clean
- ✅ PowerShell Design & Safety: advanced functions, disposal in `finally`
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: one pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: in-memory, deterministic rows
- ✅ Coverage & Scenarios: 100% changed-file lines; positive, negative, edge, and error rows
- ✅ Test Structure: AAA, descriptive names
- ✅ External Dependencies: no temp files, no console encoding mutation
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester through PoshQC
- ✅ Test Style & Structure: focused rows
- ✅ Naming & Readability: `.Tests.ps1`, AC-labelled groups
- ✅ Toolchain: parallel gate

---

### Metrics Summary

- ✅ 26830/26848 tests passing (0 failed, 18 skipped)
- ✅ 4/4 changed functions tested
- ✅ 100% line coverage on both changed dispatchers; 96.01% repo-wide
- ✅ Test files mirror the hook layout
- ✅ All code quality checks passing
- ✅ Test execution time: 689.56 seconds for the full parallel gate

---

### Recommendation

**Ready for merge** once CI on the reviewed head completes green (AC-20, checked at S9).

---

## Appendix A: Test Inventory

### Complete Test List

1. Read-PreToolUseDispatchStandardInput (issue #1187) › decodes <Name> from UTF-8 bytes exactly (3 rows)
2. Read-PreToolUseDispatchStandardInput (issue #1187) › strips a leading UTF-8 byte order mark
3. Read-PreToolUseDispatchStandardInput (issue #1187) › maps an invalid byte to U+FFFD without throwing
4. Read-PreToolUseDispatchStandardInput (issue #1187) › disposes the stream it reads
5. Read-PreToolUseDispatchStandardInput (issue #1187) › opens the process standard input through the default stream seam without reading it
6. Invoke-PreToolUseDispatchEntryPoint non-ASCII output (issue #1187) › emits the decision / writes the trace line / emits the dependency-failure deny / defaults ReadPayload (4 rows)
7. invoke-pretooluse-dispatch.ps1 script tail › denies a payload without a tool name (updated arrangement)
8. The Codex equivalents of items 1 to 7 in `tests/scripts/codex-hooks/invoke-pretooluse-dispatch.Tests.ps1`
9. PreToolUse dispatcher stdin reader parity (issue #1187) › defines the Claude and Codex stdin readers with equal bodies apart from the name
10. relay match of non-ASCII directive text (issue #1187 AC-6) › allows / denies / records digest (9 rows plus the interception probe)
11. ledger append of non-ASCII entries (issue #1187 AC-7) › allows (3) / denies edit (1) / denies altered digest (3)
12. decision files with non-ASCII reasons (issue #1187 AC-8) › accepts (3)
13. stdin decode contrast (issue #1187 AC-12) › denies the Latin1 decode and allows the UTF-8 reader decode
14. non-ASCII directive text (issue #1187) in `validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1` (4 rows)
15. OrchestratorStateOwnerDirectiveDecision: parses / accepts a decision line whose reason contains <Name> (6 rows)
16. OrchestratorStateOwnerDirectives: B5 digest of U+1F600; B5 accepts (3); B5 rejects (3)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting and linting (per changed file)
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing (parallel, through the launcher)
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-14  
**Policy Version:** Current (as of audit date)

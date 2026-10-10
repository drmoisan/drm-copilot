# Policy Compliance Audit: Hook pre-existing imports fail open (#786, bundled #792)

---

**Audit Date:** 2026-10-10
**Code Under Test:** 57 PowerShell production files under `.claude/hooks/` and `.codex/hooks/` (54 modified, 3 counted as new by the executor's coverage comparison, of which 2 are truly new: both `hook-dependency-guard.ps1` copies), their 57 byte-identical bundle mirrors under `extensions/drm-copilot/resources/`, 2 pack manifests (`core.json`, both bundles), 35 PowerShell test and test-support files under `tests/scripts/`, and feature-folder documentation. Full list: Section 9.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 57 production files (plus 57 mirrors and 35 test files) | 9495 tests | ✅ 9495 pass, 0 fail | 88.78% lines on the 54 pre-existing changed files (4486/5053) | 95.21% lines on the same 54 files (5053/5307); 4 files below 85% | 93.18% lines on the 3 files without a baseline row (123/132); Codex helper copy 57.89% |
| JSON | 2 files | N/A | ✅ pack-manifest pytest suites pass | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/baseline/p0-pester-coverage.md (run 2026-10-09T22-11, 8420 passed)
- PowerShell post-change coverage artifact: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pester-coverage.md (run 2026-10-10T06-08, 9495 passed) and artifacts/pester/powershell-coverage.xml (last written 2026-10-10 06:29 by the MCP route)
- Per-language comparison summary: Section 1.2.1 and docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/coverage-comparison.md

---

## Executive Summary

The branch adds a shared, import-free helper (`hook-dependency-guard.ps1`, four byte-identical copies), wraps every script-scope import and dot-source of every registered PreToolUse and SubagentStop hook on both surfaces in a single-statement `try`, adds a bootstrap flag and an `exit 2` tail to every registered hook, migrates the #690 guard copies, converts the #787/#840 handlers H7 and H8 of `validate-orchestrator-output.ps1` to the helper, keeps the #565 handlers H1 to H6 as named exemptions with fail-closed proofs, and adds AST-based structural (#786) and stdout (#792) guard tests built on one discovery helper.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (mirrored by `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (mirrored by `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (uniform coverage thresholds)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (zero Python files changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash (zero bash files changed)
- ✅ JSON: two pack manifests changed; validated through the push-down pack-manifest pytest suites

Outcome: format, analyze, and Pester pass in QC pass 4 (Formatted 0, PSSA findings 0 on 92 files, 9495 passed and 0 failed). Mirror parity, pack manifests, the no-Python guard, the 500-line cap, test location, and the no-temporary-file rule all pass. The PowerShell coverage gate fails: four changed Codex hook files are below the uniform 85% line threshold in the full run, and five changed Codex files regress against their baseline. The verdict is NON-COMPLIANT on coverage only.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts are committed; the executor's route scripts lived in the session scratchpad (`<SCRATCHPAD>/r.sh`, `rpester.ps1`, and similar, recorded in `evidence/other/deviations.md`).
- ✅ No new tooling scripts were added to the repository; the new test-support files (`HookDependencyGraph.Helpers.ps1`, `HookGuardShape.Helpers.ps1`, `HookImportFailureExemptions.Helpers.ps1`) are exercised by their consuming suites.
- Review-time scripts (`cov.py`, `agg.py`, `checks.sh`) were written to the reviewer's session scratchpad only.

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the PR base (`origin/epic/enforcement-hook-precision-integration`), which matches the resolved merge base `86e457a003be0c60b65e01156e4cccd6495dfd1a`, and asked for explicit blocking classification of the coverage gap. The audit scope is the full branch diff `git diff origin/epic/enforcement-hook-precision-integration...HEAD` (267 files).

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- `git diff --name-only origin/epic/enforcement-hook-precision-integration...HEAD | grep -E '^artifacts/'` returned no paths. No file in the branch diff is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All feature evidence is under `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/{baseline,regression-testing,qa-gates,other}/`.
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Suites reset `$script:HookDependencyFailures` in `finally` blocks; the C4 rows remove leaked module instances (`deviations.md`, [P8-T9]). The full 330-container run passes (9495/0). Observation: test order affects coverage attribution (Section 8), not pass/fail. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Data-driven rows: one B1 row per (hook, direct edge), one B2 row per hook, one S row per structural rule, one N row per #792 form. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Full run 537.52 s for 9495 tests (about 57 ms per test). |
| **Determinism** - Consistent results | ✅ PASS | Import failures are simulated only with `Mock Import-Module` and `Mock Join-Path` (C3). Checkpoint reads are mocked through `Register-EpicStateBaselineMock`. The H8 proof row read live worktree state at proof time (Section 8); after conversion the dependency check precedes resolution, so the current row does not depend on host state. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row names state hook, event, dependency, and expected result (for example `B1: <Event> <Hook> blocks naming <Dependency> when that direct edge fails`). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** 88.78% lines aggregate on the 54 pre-existing changed files; per-file values in `evidence/baseline/p0-pester-coverage.md`<br>**Command:** `Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>**Timestamp:** 2026-10-09 22:11 |
| **No Coverage Regression** | ❌ FAIL | **Post-change coverage:** 95.21% lines aggregate on the same 54 files<br>**Change:** +6.43 points aggregate<br>**Status:** Regression detected on five Codex files: `enforce-epic-child-worktree-binding.ps1` 95.62 -> 74.70, `enforce-epic-planning-only.ps1` 95.71 -> 82.25, `validate-bash.ps1` 100.00 -> 80.25, `enforce-orchestration-preimplementation-gate.ps1` 100.00 -> 86.55, `enforce-epic-merge-gate.ps1` 98.68 -> 98.09 (`evidence/qa-gates/coverage-comparison.md`). |
| **New Code Coverage ≥85% (uniform threshold, quality-tiers.md)** | ❌ FAIL | `.claude/hooks/hook-dependency-guard.ps1` 100.00% (19/19); `.codex/hooks/hook-dependency-guard.ps1` 57.89% (11/19; lines 103-111 uncovered in the full run). The two copies are byte-identical and exercised by `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1` and `tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1`. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | 53 of 57 changed production files are at or above 85%. Below: `.codex/hooks/enforce-epic-child-worktree-binding.ps1` 74.70, `.codex/hooks/enforce-epic-planning-only.ps1` 82.25, `.codex/hooks/hook-dependency-guard.ps1` 57.89, `.codex/hooks/validate-bash.ps1` 80.25. |
| **Positive Flows** - Valid inputs | ✅ PASS | AC-17: every pre-existing hook suite passes with all dependencies loaded; H1-H6 control rows (`hook-import-failure-exemptions.FailClosed.Tests.ps1`) allow when the resolver loads. |
| **Negative Flows** - Invalid inputs | ✅ PASS | B1 rows (Claude and Codex) fail each direct edge and assert deny/exit 2, the leading token, and the dependency name. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Nested failure (AC-9), helper bootstrap failure (B2, C8 fresh-runspace row), D3 absent versus present, D2 MermaidValidation absence, re-dot-source preservation of records. |
| **Error Handling** - Error paths | ✅ PASS | SubagentStop exit 2 with stderr reason, including validators that set `$ErrorActionPreference = 'Stop'` (AC-8). |
| **Concurrency** - If applicable | N/A | Hooks are single-invocation processes; no shared mutable state across invocations. |
| **State Transitions** - If applicable | ✅ PASS | Helper state (empty list, recorded failure, preserved on re-dot-source) tested in both helper suites. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 88.78% lines (aggregate of the 54 pre-existing changed files) -> Post-change: 95.21% lines (same files). Change: +6.43 points aggregate, with per-file regressions on five Codex files and four files below the 85% floor. New/changed-code coverage: 93.18% lines on the files without a baseline row; the Codex helper copy is 57.89%. Repo-wide command coverage in the in-repo full run: 87.07%. Disposition: FAIL. Evidence: docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pester-coverage.md, docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/coverage-comparison.md, docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/p10-coverage-pass2.md, artifacts/pester/powershell-coverage.xml.
- JSON: not a coverage language; validated by the pack-manifest pytest suites (`evidence/qa-gates/final-pytest-guards.md`, 33 passed).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions use `-Because $reason` / `-Because $result.Stderr`, so a failing row prints the actual decision text. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Rows mock (Arrange), invoke the hook (Act), then assert; the FailClosed rows mark the three sections with comments. |
| **Document Intent** | ✅ PASS | Row names and file headers cite the requirement (FR/AC id) under test. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or external process. Hooks are invoked in-process through `&`; the C8 row uses a fresh runspace (`deviations.md`, [P6-T7]). |
| **Use Mocks/Stubs** | ✅ PASS | `Import-Module`, `Join-Path`, `Read-ClaudeHookRawPayload`, `Resolve-ClaudeHookToolInput`, and checkpoint readers are mocked. |
| **Environment Stability** | ✅ PASS | No temporary files: `grep -nE 'TestDrive|New-TemporaryFile|GetTempPath|GetTempFileName|\$env:TEMP|Out-File|Set-Content|New-Item'` over all added or modified test files returned no matches. `$env:CLAUDE_HOOK_INPUT` and `[Console]::In/Error` are set per invocation and restored in `finally`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document. Outstanding items: Section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` (full-bug), issues #786 and #792, epic #852 child C4. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/p0-feature-documents-read.md`, `phase0-instructions-read.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-08T13-54.md` (revised for the 2026-10-09 operator decision). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One 115-line helper with four functions; each guard is one line. |
| **Reusability** | ✅ PASS | The duplicated #690 per-hook guard and deny function are replaced by the shared helper; the merge-gate ordering hazard (FR-6.3) is removed. |
| **Extensibility** | ✅ PASS | Structural and #792 tests discover hooks from `.claude/settings.json` and `.codex/config.toml`; new hooks are covered without a list edit. |
| **Separation of concerns** | ✅ PASS | The helper performs no I/O; hooks write decisions; the discovery helper accepts an injectable text reader. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Helper (recording and decisions), discovery helper (AST graph), shape helper (guard shape), exemption helper (named exemptions). |
| **Under 500 lines** | ✅ PASS | Largest changed files: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` 500 (and mirror), `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` 497, Claude `enforce-python-batch-budget.ps1` 495. None exceeds 500. Command: `wc -l` over `git diff --name-only --diff-filter=AM ... -- '*.ps1' '*.psm1'`. |
| **Public vs internal** | ✅ PASS | Helper exposes four approved-verb functions; no module manifest change. |
| **No circular dependencies** | ✅ PASS | The helper imports nothing and calls no hook or dependency function (FR-1.5). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Add-HookDependencyFailure`, `Test-HookDependencyFailure`, `Get-HookDependencyFailureReason`, `Get-HookDependencyFailureDecision`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on the helper and its functions; hook `.NOTES` updated. |
| **Comment why, not what** | ⚠️ PARTIAL | Three exempt hooks (H4, H5, H6) keep the comment "an earlier recorded failure is kept" and an `if (-not $script:<Name>ResolutionImportFailure)` test that is now always true after the #690 migration (code review, Nit). Non-blocking. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** R-FORMAT-GUARDED (Invoke-PoshQCFormat) over nine scan folders<br>**Result:** pass 4 Formatted 0, SHA_UNEQUAL 0 (`final-poshqc-format.md`) |
| **2. Linting** | ✅ PASS | **Command:** Invoke-PoshQCAnalyze plus per-file PSScriptAnalyzer with repository settings<br>**Result:** 0 findings on 92 files (`final-poshqc-analyze.md`) |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>**Result:** 9495 passed, 0 failed; JUnit 9505 tests, 0 failures, 0 errors |
| **Full toolchain loop** | ❌ FAIL | Pass 4 is green for format, analyze, Pester, MCP routes, pytest guards, line counts, mirror parity, and scope; [P11-T3] and [P11-T10] are not green because of the coverage gate (`final-qc-loop.md`). |
| **Explicit reporting** | ✅ PASS | Every stage is recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | `evidence/other/commits.md`, 22 commits. |
| **Design choices explained** | ✅ PASS | `spec.md` Change Log 2026-10-09; `exemption-decisions.md`; `handler-conversions.md` (PR-BODY-NOTE). |
| **Update supporting documents** | ✅ PASS | Pack manifests and `legacy-codex-hook-contracts.Tests.ps1` `$script:SharedModuleNames` list the helper. |
| **Provide next steps** | ✅ PASS | `evidence/other/ac-status.md` lists AC-6, AC-24, AC-26, AC-27 gaps with escalation inputs. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .` (R-FORMAT-GUARDED) and `mcp__drm-copilot__run_poshqc_format`<br>**Result:** no file changed in pass 4 |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** `PSScriptAnalyzer passed: no findings` |
| **Fix all findings** | ✅ PASS | Pass 2 reported 25 test-file findings (verbs, named parameters); fixed before pass 3. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | Hooks target PowerShell 7 (`pwsh -File`) per spec assumptions; the helper uses only built-in cmdlets and .NET generic lists. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | All helper functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `[ValidateSet('PreToolUse','SubagentStop')]` on `-HookEvent`; mandatory `-Name` and `-ReasonPrefix`. |
| **Avoid global state** | ⚠️ PARTIAL | Seven runtime pre-loads use `Import-Module -Global` (RS-10, `deviations.md` [P10-T1]) to satisfy module-scope `Get-Command` in the full test session. In a hook's own `pwsh -File` process this is equivalent to script-level import. `validate-orchestrator-output.ps1` imports `OrchestratorState.psm1` twice (once without and once with `-Global`). Non-blocking. |
| **Error handling** | ✅ PASS | Single-statement `try` per edge; every guarded `Import-Module` uses `-ErrorAction Stop` (S2, S3); `validate-orchestrator-output.ps1` moves `$ErrorActionPreference = 'Stop'` after the guards (FR-3.3). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | Max 500 (Section 2.3). |
| **Approved verbs** | ✅ PASS | Add, Test, Get; analyzer clean. |
| **Comment why** | ⚠️ PARTIAL | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Formatted 0 in pass 4. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | 9495 passed, 0 failed. |
| **Rerun loop if needed** | ✅ PASS | Four passes recorded; pass 4 changed no file. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | N/A | The two `core.json` pack manifests carry one added array entry each; format is enforced by the manifest completeness pytest suites. |
| **Schema validation** | ✅ PASS | **Command:** `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py ... -q`<br>**Result:** 33 passed (`final-pytest-guards.md`) |
| **Required $schema** | N/A | Pack manifests are not governed schema files. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `Describe`/`It -ForEach`, `BeforeAll`, `Mock -ParameterFilter`, `Should -Invoke -Times 0 -Exactly`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged; coverage roots from `config/poshqc-coverage.json` include `.claude/hooks` and `.codex/hooks`). |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | Suites run under PowerShell 7 with Pester 5.6.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One behaviour per row. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert the emitted decision, exit code, and stderr text. |
| **Mocking Used Sparingly** | ✅ PASS | Only the C3 seams and checkpoint readers. |
| **Organization** | ✅ PASS | **Test files:** `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1`, `tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1`<br>**Code files:** `.claude/hooks/hook-dependency-guard.ps1`, `.codex/hooks/hook-dependency-guard.ps1`<br>All new tests are under `tests/scripts/` mirroring `claude-hooks`, `codex-hooks`, and `claude-runtime`; no test file is colocated with source. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All 21 new test files end in `.Tests.ps1`; support files end in `.Helpers.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per concern with data-driven `It -ForEach`. |
| **Logical Grouping** | ✅ PASS | B (behaviour), S/F (structure), N (stdout), H (handler proofs). |
| **Docstrings/Comments** | ✅ PASS | File headers cite issue and FR/AC ids. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** 9495 passed, 0 failed |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC and the PoshQC MCP route only. |

---

## 5. Test Coverage Detail

### `hook-dependency-guard.ps1` (Claude and Codex copies; helper suites)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| records a failure and Test-HookDependencyFailure returns true | Positive | 22-58 | ✅ |
| returns $null when nothing failed | Edge Case | 100-102 | ✅ |
| PreToolUse deny shape and reason text | Positive | 103, 107-113 | ✅ (Claude copy); ❌ attributed as uncovered for the Codex copy in the full run |
| SubagentStop result carries ExitCode 2 and Reason | Positive | 104-105 | ✅ (Claude copy); ❌ attributed as uncovered for the Codex copy in the full run |
| preserves earlier records on re-dot-source | State Transition | 22, 42 | ✅ |
| writes nothing to any output stream | Negative | whole file | ✅ |

**Coverage:** Claude copy 100.00% (19/19); Codex copy 57.89% (11/19) in the full run.

**Not covered:** Codex copy lines 103-111 in the full run, although the byte-identical Claude copy shows them covered and the Codex suite exercises the same function.

### Registered hooks (57 production files)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| B1 per direct edge (Claude, Codex) | Error Handling | guard catch lines, decision-function first statement, tail lines | ✅ |
| B2 bootstrap flag per hook | Error Handling | bootstrap line | ✅ |
| C8 fresh-runspace bootstrap exit 2 | Error Handling | tail `exit 2` | ✅ (process-level row) |
| Pre-existing suites (AC-17) | Positive | existing decision paths | ✅ |

**Coverage:** 53 of 57 files at or above 85%; see Section 1.2.

**Not covered:** bootstrap `exit 2` lines (known uncovered by spec Test Strategy); Codex tail lines `validate-bash.ps1:305-306` and `enforce-orchestration-preimplementation-gate.ps1:467-468` in the full run; 42 lines of `enforce-epic-child-worktree-binding.ps1` and 30 lines of `enforce-epic-planning-only.ps1` that the baseline run covered.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 9495 run (JUnit 9505 including 10 skipped) | ✅ |
| Tests Passed | 9495 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 537.52s total | ✅ |
| Average Time per Test | 57ms | ✅ Fast |
| Discovery Time | Not separately reported for the full run | N/A |
| Functions/Classes Tested | 4/4 helper functions | ✅ |
| Test File Size | Largest new test file 474 lines (`hook-import-failure-exemptions.FailClosed.Tests.ps1`) | ✅ Maintainable |
| Code Coverage (if applicable) | 95.21% lines on changed pre-existing files; 4 files below 85%; no branch metric for PowerShell | ❌ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | Formatted 0 (pass 4) | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 9495 passed, 0 failed | ✅ |
| Pester coverage gate | per-file line coverage from the JaCoCo XML | 4 files below 85%; 5 regressions | ❌ |
| Mirror parity | `cmp` of each of the 57 changed hook files against its bundle mirror (reviewer run) | 57 equal, 0 unequal | ✅ |
| Push-down parity and manifests | `poetry run pytest <six push-down and manifest suites> -q` | 33 passed | ✅ |
| No-Python guard | `enforcement-hooks-no-python-invocation.Tests.ps1` | 32 passed; guard files unmodified (reviewer `git diff --stat` empty) | ✅ |

**Notes:**
- The coverage XML currently at `artifacts/pester/powershell-coverage.xml` (written 2026-10-10 06:29) was produced by the MCP `run_poshqc_test` route, which uses the installed extension's coverage settings; it contains no `hook-dependency-guard.ps1` entry for either copy. The reviewer's parse of that file reproduces the three Codex hook values (74.70, 82.25, 80.25) and reports 95.86% aggregate over the files it measures. The authoritative per-file record for the helper copies is the in-repo run in `final-pester-coverage.md`.
- Baseline files below 85% before this branch (for example Codex `validate-feature-review-coverage.ps1` 7.30) were raised above 85% by the new `*.Coverage.Tests.ps1` suites.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PowerShell line coverage (FAIL, blocking).** Four changed Codex production files are below the uniform 85% line threshold in the full run: `enforce-epic-child-worktree-binding.ps1` 74.70, `enforce-epic-planning-only.ps1` 82.25, `hook-dependency-guard.ps1` 57.89, `validate-bash.ps1` 80.25. Five Codex files regress against baseline. The executor attributes the loss to Pester 5.6.1 profiler-tracer attribution in the 330-container run, because the covering tests pass and folder-scoped runs report the lines covered (`p10-coverage-pass2.md`, `deviations.md` [P10-T2] to [P11-T3]). This review did not reproduce the folder-scoped runs and treats the attribution explanation as plausible but not verified. Policy measures coverage from the standard run artifact, so the gate fails regardless of cause. Remediation: Section 10 and `remediation-inputs.2026-10-10T06-50.md`.
- **AC-6 (PARTIAL, blocking in the feature audit).** For the exempt edges H1, H4, H5, H6 the entry point acquires the payload before the scoped handler denies. The 2026-10-09 amendment changed AC-11 and AC-12 but not AC-6. Requires an operator decision.
- **Plan check [P9-T7] (c) (non-blocking).** The check counts the word "python" in reason-prefix string literals; no added line invokes Python. AC-26 is met; the plan check is over-broad.

### Approved Exceptions

- D2 (`enforce-mermaid-validation.ps1` designed fail-open on a missing `MermaidValidation` module) and the D3 absence path (spec Operator Decisions).
- Named handler exemptions H1 to H6 under the 2026-10-09 operator decision (option 1), each with a fail-closed proof in `evidence/other/fail-closed-proof.H<n>.md` and an entry with justification in `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`.
- Bootstrap `exit 2` tail lines are known uncovered in-process (spec Test Strategy).

### Removed/Skipped Tests

**None.** All planned tests implemented. The 10 skipped JUnit cases pre-date the branch (baseline also reports Skipped: 10).

---

## 9. Summary of Changes

### Commits in This PR/Branch

22 commits from `86e457a00` (merge base) to `76559b6df` (HEAD), including:
1. **261c77ffb** - fix(786): add shared hook-dependency-guard helper and registrations
2. **ed9c9098d** - fix(786): guard Claude PreToolUse hook dependencies
3. **6b9406124** - fix(786): guard Claude self-gating and SubagentStop hooks; migrate #690 guards
4. **6681bac1c** - fix(786): guard Codex hook dependencies
5. **c4cc2fd63** - fix(786): apply conditional handler conversions and record them
6. **b83b121f9** - fix(786): pre-load runtime modules globally (RS-10) and record coverage pass 1
7. **11f2aac9d** - test(786): coverage remediation and comparison evidence
8. **76559b6df** - docs(786): record final commit

### Files Modified

1. **`.claude/hooks/hook-dependency-guard.ps1`, `.codex/hooks/hook-dependency-guard.ps1`** (NEW, plus 2 mirrors) - shared recording and decision helper.
2. **35 `.claude/hooks/*.ps1` and 20 `.codex/hooks/*.ps1`** (MODIFIED, plus mirrors) - bootstrap, per-edge guards, decision-first check, tail check; #690 guards migrated; H7/H8 converted.
3. **2 `pack-manifests/core.json`** (MODIFIED) - helper listed.
4. **24 new (21 test files, 3 test-support files) and 11 modified test files under `tests/scripts/`** - behaviour, structural, #792, exemption, proof, and coverage suites.
5. **`spec.md`, `plan.2026-10-08T13-54.md`, `evidence/**`** - Change Log, plan revisions, evidence.

---

## 10. Compliance Verdict

### Overall Status: ❌ NON-COMPLIANT

All structural, toolchain, mirror, cap, and test-hygiene policies pass. The PowerShell coverage gate (uniform 85% line threshold and no regression) fails on four Codex files, and AC-6 is not satisfied as written.

**Fail-closed reminder:** The audit is not marked PASS while the coverage gate fails.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present
- ✅ Design Principles: shared helper replaces duplicated guards
- ✅ Module & File Structure: all files at or below 500 lines
- ⚠️ Naming, Docs, Comments: stale comments in three exempt hooks
- ❌ Toolchain Execution: coverage gate not green
- ✅ Summarize & Document: conversions and exemptions recorded

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean
- ⚠️ PowerShell Design & Safety: `-Global` pre-loads and a duplicate import
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: four-pass loop recorded

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: met
- ❌ Coverage & Scenarios: four files below 85%, five regressions
- ✅ Test Structure: met
- ✅ External Dependencies: no temporary files, mocks only
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5 through PoshQC
- ✅ Test Style & Structure: tests mirror source under `tests/scripts/`
- ✅ Naming & Readability: met
- ✅ Toolchain: 9495 passed, 0 failed

---

### Metrics Summary

- ✅ 9495/9495 tests passing (100%)
- ✅ 4/4 helper functions tested
- ❌ 53/57 changed production files at or above 85% line coverage
- ✅ Proper file organization: tests under `tests/scripts/` mirroring source
- ✅ Format, analyze, mirror parity, manifests, no-Python guard passing
- ✅ Test execution time: 537.52 seconds (fast per test)

---

### Recommendation

**Needs revision**

1. Restore line coverage >= 85% and remove the regressions on the four or five Codex files in the standard full run (root-cause the attribution loss or add coverage that the full run attributes), and record the per-file results under `evidence/qa-gates/`.
2. Obtain an operator decision on AC-6 for the named-exemption edges (amend AC-6 to match the 2026-10-09 decision, or require pre-payload checks for H4 to H6).
3. Non-blocking: revise plan check [P9-T7] (c) to match invocation forms only.

---

## Appendix A: Test Inventory

### Complete Test List

New suites (21 files):
1. `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1` › helper unit rows (Claude copy)
2. `tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1` › helper unit rows (Codex copy)
3. `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` › baseline probe, B1 per edge, B2 per hook
4. `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` › B1, B2, X rows
5. `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` › nested, runtime, D2, D3, merge-gate, C8
6. `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` › H1 to H8 proofs
7. `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` › H2 Codex proofs
8. `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` › S1 to S8, F1 to F8
9. `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` › N1 to N8
10. `tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1` › exemption guard
11. Eleven `*.Coverage.Tests.ps1` suites for below-floor baseline hooks (Claude and Codex)

Support files: `HookDependencyGraph.Helpers.ps1`, `HookGuardShape.Helpers.ps1`, `HookImportFailureExemptions.Helpers.ps1`.

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root .

# Testing
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

**Reviewer commands (check-only):**
```bash
git diff --stat origin/epic/enforcement-hook-precision-integration...HEAD
git diff --name-status origin/epic/enforcement-hook-precision-integration...HEAD
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/enforcement-hook-precision-integration --head HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
sh <SCRATCHPAD>/checks.sh   # cmp mirror parity, helper sha1, manifest grep, wc -l, python grep, #690 remnant grep, temp-file grep
python -I <SCRATCHPAD>/cov.py artifacts/pester/powershell-coverage.xml <targets>
python -I <SCRATCHPAD>/agg.py evidence/baseline/p0-pester-coverage.md evidence/qa-gates/final-pester-coverage.md
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py policy-audit <path>
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-10
**Policy Version:** Current (as of audit date)

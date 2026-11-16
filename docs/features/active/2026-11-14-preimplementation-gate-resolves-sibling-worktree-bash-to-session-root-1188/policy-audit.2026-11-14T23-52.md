# Policy Compliance Audit: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188)

---

**Audit Date:** 2026-11-14  
**Code Under Test:** merge base `11c6ecde2e3080722c90bc63289bc160bf9596ea` of the base branch `main` and reviewed head `aca57bf07214fb4436a7459beb1b587eedd6af35` (PR #1191); the diff between them lists the changed files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 13 files (2 new production siblings and 2 edited epic-scope files, each with a byte-identical bundle copy; 5 test files) | 27137 tests | 27115 passed, 0 failed, 22 skipped | 95.96% lines | 96.04% lines | 100% lines (both operands siblings 154/154; 10 changed executable epic-scope lines covered) |
| JSON | 2 files (pack manifests) | N/A | N/A | N/A (configuration) | N/A (configuration) | N/A |
| Markdown | 37 files (six execution-environment brief copies, promoted potential, feature folder documents and evidence) | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Python baseline coverage artifact: N/A - zero changed Python files
- Python post-change coverage artifact: N/A - zero changed Python files
- C# baseline coverage artifact: N/A - zero changed C# files
- C# post-change coverage artifact: N/A - zero changed C# files
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/evidence/baseline/pester-gate.2026-11-14T21-02.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (rewritten by the reviewer's Pester gate run at the reviewed head) and `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/evidence/qa-gates/review-pester-gate.2026-11-14T23-52.md`; the executor's run is `evidence/qa-gates/final-qc-pester.2026-11-14T23-10.md`
- Per-language comparison summary: section 1.2.1 below

---

## Executive Summary

The branch adds `Get-OrchestrationGateCommandTargetOperand` in a new byte-identical sibling `enforce-orchestration-preimplementation-gate-operands.ps1` (four copies) and wires it into `Resolve-OrchestrationGateTarget` of both surfaces' epic-scope files, so the single-feature command leg of the preimplementation gate resolves the target worktree from directory selectors, script operands, and absolute literal operands of every gated command family, and fails closed (`TARGET_WORKTREE_NOT_DERIVABLE`) on shell-variable, substitution, missing-value, unmodelled-option, split-string, and malformed-record operands. Neither gate file changed. The brief is updated in six byte-identical copies.

Scope: the full branch diff (52 files). PowerShell is the only code language with changed files; JSON (pack manifests) and Markdown are configuration and documentation. Python, TypeScript, C#, and bash have zero changed files.

The reviewer verified the implementation with real-process probes of `Get-OrchestrationGateCommandTargetOperand` and `Test-ImplementationCommand` over 70 command forms, including adversarial forms not in the test table (quoted variables, tilde, Windows backslash paths, redirection forms, `timeout`/`nice`/`VAR=` prefixes, payloads under `sh -c` and `pwsh -Command`, chained records). The extraction behaves as specified in every probed form, with two non-blocking edge observations recorded in the code review.

One blocking finding exists (R1): AC-6 is not met. Its command `npm --prefix $(pwd) run lint` is not classified by either gate and is admitted with no checkpoint read; the executor left AC-6 unchecked and replaced the gate row with the quoted form. The reviewer's probe shows the miss is in stage 1 (the shared segment scanner splits the unquoted `$(` word into three scan segments, none of which matches the npm pattern), not in stage 2 as the evidence states. The same fail-open affects `npx --prefix <item> jest` (AC-2 row N3), which stage 1 never matches. Both are pre-existing gate fail-opens on the commands this item's acceptance criteria name, so they are related findings under the owner rule and are routed to a remediation cycle.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/hooks` and `.codex/hooks` are already classified; the branch adds no project folder)

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python file in the branch diff; the Python contract suites ran as regression evidence)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Bash: no bash file in the branch diff (the executor's pytest helper is gitignored under `artifacts/`)
- ✅ JSON: two pack manifests, parsed and covered by the manifest completeness suites

**Temporary artifacts cleanup:**
- ✅ The reviewer's probe scripts live in the gitignored `artifacts/scratch-issue-1188/` folder of the item worktree; none is tracked
- ✅ No ongoing tooling script was added
- Reviewer-created files: this review set, the new evidence file `evidence/qa-gates/review-pester-gate.2026-11-14T23-52.md`, and one owner-directive decision file; no existing evidence was edited

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Mocks are registered per row (`Set-OperandFixture`); `$script:OrchestrationGateWorktreeListFailed` and `$script:HookDependencyFailures` are reset; suites pass inside the eight-worker parallel gate. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One G row per command form for the function alone; one gate row per ID and form. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | In-memory listing and checkpoint bodies; no process or file access per row. |
| **Determinism** - Consistent results | ✅ PASS | No clock, file, process, or network access; synthetic forward-slash roots; Windows drive-letter rows are pure string inputs. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Shared data-only Cases table; `It` names carry the row ID and label. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 95.96% lines repo-wide (43686/45525); Claude epic-scope 97.73% (129/132); Codex epic-scope 98.01% (148/151)<br>**Command:** `run-test-suite.sh pester` (`Invoke-PoshQCParallelTest`)<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-14T21-02.md`<br>**Timestamp:** 2026-11-14T20-49 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.04% lines repo-wide at the reviewed head (the denominator includes files added by the origin/main merge)<br>**Change:** no drop on either epic-scope file; every changed executable line covered<br>**Status:** No regression |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** operands siblings 100% (154/154 each); Claude epic-scope 97.79% (133/136); Codex epic-scope 98.06% (152/155)<br>**Thresholds:** 85% line; no branch threshold for PowerShell (Pester measures no branches)<br>**Status:** All changed files meet the thresholds |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** both operands siblings; both epic-scope files<br>**New code coverage:** 100% (308 new lines and 10 changed executable lines)<br>**Calculation method:** per-file JaCoCo LINE counters and per-line `ci` values (`evidence/qa-gates/coverage-comparison.2026-11-14T23-12.md`), re-read from the reviewer's head run |
| **Comprehensive Coverage** | ✅ PASS | 90 G rows and 44 gate rows per surface, the I1 dependency-failure row per surface, and the four-copy parity suite. |
| **Positive Flows** - Valid inputs | ✅ PASS | P1, N1, N2, L1, W1, W2, A1 allow rows. |
| **Negative Flows** - Invalid inputs | ⚠️ PARTIAL | P2, P3, N4, L2, V1, V2, V4, V5, U1-U5 deny as specified; the AC-6 V3 form `npm --prefix $(pwd) run lint` is admitted (finding R1). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Drive-letter strings, duplicates, redirection targets, `git commit -F <abs>`, attached and inline option forms, empty command. |
| **Error Handling** - Error paths | ✅ PASS | F1 (listing throws), F2 (empty listing), I1 (dependency failure of the sibling). |
| **Concurrency** - If applicable | N/A | No concurrent code. |
| **State Transitions** - If applicable | N/A | Stateless extraction. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.96% lines (from the `Phase 0 baseline` artifact `evidence/baseline/pester-gate.2026-11-14T21-02.md`) -> Post-change: 96.04% lines (reviewed head). Change: +0.08% lines (the branch adds 308 covered of 308 instrumented sibling lines; the denominator also includes files added by the origin/main merge). New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/review-pester-gate.2026-11-14T23-52.md`, `evidence/qa-gates/coverage-comparison.2026-11-14T23-12.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because` on the Paths assertion; reason-code and detail patterns asserted; exact read and listing counts. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Gate rows and I1 carry Arrange/Act/Assert comments. |
| **Document Intent** | ✅ PASS | Suite headers and the Cases header describe each table and its columns. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Listing (`Get-OrchestrationGateWorktreeList`), checkpoint (`Get-CheckpointContent`), and ascent (`Find-WorktreeResolutionRoot`) seams mocked; no git start. |
| **Use Mocks/Stubs** | ✅ PASS | Per-row mocks with path-specific `-ParameterFilter` on `$script:` variables (no case collision with a local name). |
| **Environment Stability** | ✅ PASS | `/synthetic-worktrees/...` roots, forward slashes, no temporary files. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the policy review for the branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` (full-bug) with root-cause analysis. |
| **Read existing change plans** | ✅ PASS | `research/research.2026-11-14.md` and `plan.2026-11-14T13-12.md`. |
| **Document the plan** | ✅ PASS | All 20 plan tasks checked, with task-check and phase-gate evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One entry function and four helpers; one call and one early return per resolver. |
| **Reusability** | ✅ PASS | Reuses `Get-OrchestrationGateCommandOperandPath`, `Read-CommandLineInvocationSegment`, `Test-CommandLineWordPresent`, `Test-CommandLineTokenLiteral`, `Get-CommandLineGlobalOption`. |
| **Extensibility** | ✅ PASS | Prefix and option tables are data. |
| **Separation of concerns** | ✅ PASS | The sibling is pure string logic; I/O stays in the two existing seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One sibling for operand extraction. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical lines: sibling 295 (each copy), Claude epic-scope 418, Codex epic-scope 474, tests 76 to 180, `legacy-codex-hook-contracts.Tests.ps1` 517. No covered file at or above 700 lines; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | One entry function; helpers carry the `OrchestrationGate` prefix. |
| **No circular dependencies** | ✅ PASS | The sibling dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-OrchestrationGateCommandTargetOperand`, `Read-OrchestrationGateOptionRun`, `Get-OrchestrationGateHostOperand`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function; resolver help updated on both surfaces. |
| **Comment why, not what** | ✅ PASS | Tables cite the decision-rule numbers and the option-name source. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** check-only `Invoke-Formatter` with `pssa.settings.psd1` over the 13 changed `.ps1` files<br>**Result:** 0 changes (`evidence/qa-gates/final-qc-powershell-static.2026-11-14T22-58.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` per file with `pssa.settings.psd1`; `Invoke-PoshQCLeakScan`<br>**Result:** 0 findings; 0 leak failures |
| **3. Type checking** | N/A | **Command:** none<br>**Result:** not applicable for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (`Invoke-PoshQCParallelTest`, 8 workers)<br>**Result:** 27115 passed, 0 failed, 22 skipped (reviewer run at the head); executor run 26807 tests, 0 failed |
| **Full toolchain loop** | ✅ PASS | One clean pass in the final QA loop; integration lanes are CI-only by the test-execution policy. |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `17cb58a86` and the spec Proposed Fix section. |
| **Design choices explained** | ✅ PASS | Sibling header; `fail-before-v3.2026-11-14T22-09.md` explains the V3 row change. |
| **Update supporting documents** | ✅ PASS | Execution-environment brief in six byte-identical copies (one blob hash verified). |
| **Provide next steps** | ⚠️ PARTIAL | The classification miss was deferred as "finding for follow-up"; the owner rule routes related findings to a remediation cycle (R1). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** check-only `Invoke-Formatter` per changed file<br>**Result:** 0 differences |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` per changed file<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The repository rule is PowerShell 7+; the hooks run under pwsh 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` on every new function. |
| **Parameter validation** | ✅ PASS | `Mandatory` and `AllowEmpty*` attributes. |
| **Avoid global state** | ✅ PASS | Script-scope tables are read-only data; mutable state passes through `-State`. |
| **Error handling** | ✅ PASS | Unresolvable input becomes an explicit `Unresolved` result that the resolver denies; a failed dot-source denies naming the file (I1). |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | See 2.3. |
| **Approved verbs** | ✅ PASS | `Get`, `Add`, `Read`. |
| **Comment why** | ✅ PASS | See 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | 0 differences. |
| **Step 2: Analyze** | ✅ PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Reviewer gate at the head: 27115 passed, 0 failed, 22 skipped. |
| **Rerun loop if needed** | ✅ PASS | One clean pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`/`Context`/`It`, `-ForEach` data rows, `BeforeDiscovery`, `Should -Invoke -Exactly`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through the test-execution launcher<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged) |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | `#Requires -Version 7.0`, consistent with the sibling hook suites. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | G rows target the function alone; gate rows target one decision each. |
| **Test Behavior Over Implementation** | ✅ PASS | Gate rows assert decisions, reason codes, and seam call counts. |
| **Mocking Used Sparingly** | ✅ PASS | Only the listing, checkpoint, and ascent seams. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1`<br>**Code file:** `.claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-operands.ps1`<br>Mirrors the hook-test layout. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Suites end in `.Tests.ps1`; the Cases file is data only. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` and two `Context` blocks per suite. |
| **Logical Grouping** | ✅ PASS | G rows and gate rows in separate contexts. |
| **Docstrings/Comments** | ✅ PASS | Suite and Cases headers. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` (8 workers)<br>**Result:** 27115 passed, 0 failed, 22 skipped |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### Get-OrchestrationGateCommandTargetOperand (90 G rows per surface)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| poetry, npm, npx, env, pwsh, sh selectors in separate, inline, and attached forms | Positive | selector branches | ✅ |
| shell variables and substitutions in each selector family | Negative | unresolvable branches | ✅ |
| missing selector value, split string, unmodelled options, malformed records | Error Handling | fail-closed branches | ✅ |
| redirection targets and `git commit -F <abs>` not collected | Edge Case | redirection skip, rule 1 | ✅ |

**Coverage:** 100% of each sibling copy (154/154).

**Not covered:** None.

---

### Resolve-OrchestrationGateTarget command leg (44 gate rows and I1 per surface)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| P1-P3, N1-N4, L1-L2, W1-W2, A1 | Positive and Negative | operand call and resolver call | ✅ |
| V1-V5, U1-U5 | Negative | `Unresolved` early return | ✅ |
| M1-M2, R1-R3, F1-F2 | Edge Case and Error Handling | resolver results | ✅ |
| I1 | Error Handling | guarded dot-source | ✅ |

**Coverage:** every changed executable line of both epic-scope files covered.

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 27137 | ✅ |
| Tests Passed | 27115 | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 942.33 s wall clock (8 workers) | ✅ Fast |
| Average Time per Test | under 30 ms | ✅ Fast |
| Discovery Time | not reported separately by the parallel runner | ✅ |
| Functions/Classes Tested | 7/7 new or changed functions (100%) | ✅ |
| Test File Size | 76 to 517 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 100% lines on new code; 96.04% repo-wide lines | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | check-only `Invoke-Formatter` per changed file | 0 differences | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` per changed file | 0 findings | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan` | 0 failures | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 27115 passed, 0 failed, 22 skipped | ✅ |

**For Python (regression only; no Python file changed):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Pytest Tests | `run-test-suite.sh pytest` (`pytest -n auto`) | 16928 passed, 6 skipped, 0 failed (executor final gate); CI `quality-checks7` 3.11 and 3.12 pass at the head | ✅ |

**Notes:**
The executor's final gates ran before the head commit `aca57bf07`, which merges `origin/main` (358 files from main). The merge changes no PowerShell file of the branch diff; it changes the brief copies and one pack manifest by combining main's edits, and `git merge-tree` against current `origin/main` is clean. The reviewer re-ran the Pester gate at the head so the coverage report postdates the head commit.

---

## CI Cross-check

CI on PR #1191 ran concurrently with this review (review mode concurrent) and had reported every check as pass at the reviewed head when the artifacts were written. Rows record the outcome that local evidence supports at the reviewed head; the source names the local evidence and, where already reported, the CI result.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| poshqc / PowerShell QC static | pass | 0 format differences, 0 PSSA findings | aca57bf07214fb4436a7459beb1b587eedd6af35 | `evidence/qa-gates/final-qc-powershell-static.2026-11-14T22-58.md`; CI reported pass |
| poshqc / PowerShell QC shards 1-3 | pass | 27115 passed, 0 failed, 22 skipped | aca57bf07214fb4436a7459beb1b587eedd6af35 | `evidence/qa-gates/review-pester-gate.2026-11-14T23-52.md`; CI reported pass |
| poshqc / PowerShell hook suites (Linux) | pass | N/A | aca57bf07214fb4436a7459beb1b587eedd6af35 | fixtures use synthetic forward-slash roots; CI reported pass |
| quality-checks7 / Code Quality & Tests (3.12) | pass | 16928 passed, 0 failed | aca57bf07214fb4436a7459beb1b587eedd6af35 | `evidence/qa-gates/final-qc-pytest.2026-11-14T23-11.md`; CI reported pass |
| CI Required Gate | pass | N/A | aca57bf07214fb4436a7459beb1b587eedd6af35 | final QA and reviewer evidence under `evidence/qa-gates/`; CI reported pass |

---

## 8. Gaps and Exceptions

### Identified Gaps

**R1 (blocking):** AC-6 is not met. `npm --prefix $(pwd) run lint` is admitted by both gates with no checkpoint read, because stage 1 of `Test-ImplementationCommand` matches its patterns per scan segment and the shared scanner splits the unquoted `$(` word into `npm --prefix `, `pwd`, and ` run lint`. The same gate fail-open exists for `npx --prefix <item> jest` (stage-1 pattern `npx\s+(prettier|eslint|tsc|jest)` requires the tool word immediately after `npx`). Both are pre-existing on `main`, but they are the commands named by AC-6 and AC-2, and the brief now states that the gate resolves `npx --prefix`/`-C` for gated commands. Remediation is routed to a cycle (`remediation-inputs.2026-11-14T23-52.md`).

### Approved Exceptions

**None.** The integration lanes are CI-only under the existing test-execution policy.

### Removed/Skipped Tests

**None.** The skipped rows in the gate are pre-existing skips, unchanged in count from the baseline.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/`. All item evidence is under the feature folder's `evidence/<kind>/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent at the branch head, so the check is not applicable and produces no finding.

## Rejected Scope Narrowing

None. The caller prompt required the full branch diff against the merge base and attempted no narrowing.

---

## 9. Summary of Changes

The single-feature command leg of both preimplementation gates now resolves the target worktree from every literal selector, script operand, and absolute operand of the gated command, and denies as not derivable when an operand is a shell variable, substitution, or otherwise unmodelled.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain stages, coverage thresholds, file-size limits, mirrors, and test-policy requirements are met for PowerShell. One blocking finding (R1, AC-6 and the related classification fail-open) requires a remediation cycle.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present
- ✅ Design Principles: pure extraction in one sibling
- ✅ Module & File Structure: all files below 700 lines
- ✅ Naming, Docs, Comments: help text updated
- ✅ Toolchain Execution: one clean pass
- ⚠️ Summarize & Document: related classification finding deferred instead of remediated

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format, lint, leak scan clean
- ✅ PowerShell Design & Safety: advanced functions, explicit fail-closed results
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: one pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: in-memory, deterministic rows
- ⚠️ Coverage & Scenarios: 100% new-code lines; the AC-6 V3 negative flow is admitted (R1)
- ✅ Test Structure: AAA, descriptive names
- ✅ External Dependencies: no temp files, no process starts
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester through PoshQC
- ✅ Test Style & Structure: focused rows
- ✅ Naming & Readability: `.Tests.ps1`, row IDs
- ✅ Toolchain: parallel gate

---

### Metrics Summary

- ✅ 27115 of 27137 tests passing, 0 failed
- ✅ 7/7 new or changed functions tested
- ✅ 100% line coverage on new code; 96.04% repo-wide
- ✅ Test files mirror the hook layout
- ✅ All code quality checks passing
- ⚠️ One blocking acceptance finding (R1)

---

### Recommendation

**Remediation required** before merge: resolve R1 in a remediation cycle, then re-review.

---

## Appendix A: Test Inventory

### Complete Test List

1. Claude gate command-operand resolution (issue #1188) › baseline mock interception probe
2. Claude gate command-operand resolution (issue #1188) › Get-OrchestrationGateCommandTargetOperand alone (G rows) › G <Name> (90 rows)
3. Claude gate command-operand resolution (issue #1188) › gate decisions for the single-feature command leg › <Id> <Label> (44 rows: P1-P3, N1-N4, L1-L2, W1-W2, A1, V1-V5 with the V3 control, M1-M2, R1-R3, F1-F2, U1-U5)
4. Claude gate command-operand resolution (issue #1188) › I1 denies naming enforce-orchestration-preimplementation-gate-operands.ps1 when its dot-source failed
5. The Codex equivalents of items 1 to 4 in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1`
6. `enforce-orchestration-preimplementation-gate-operands.Parity.Tests.ps1` › four-copy SHA256 identity, 500-line bound, and six-copy brief wording rows
7. `legacy-codex-hook-contracts.Tests.ps1` › shared-module rows extended by the new Codex sibling

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

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-14  
**Policy Version:** Current (as of audit date)

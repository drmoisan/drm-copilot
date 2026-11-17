# Policy Compliance Audit: Preimplementation gate classifies wrapped shell and PowerShell payloads (#1195), remediation cycle 1 re-audit at head 34ac24137

---

**Audit Date:** 2026-11-17  
**Code Under Test:** merge base `b58f045bc58d237129963543e445c7c8d2987772` of the base branch `main` (equal to `origin/main` after `git fetch` at review time) and reviewed head `34ac24137b2ace314c3ac9186358ba16b3044583` (PR #1196); the diff between them lists the changed files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 12 files (classify sibling in 4 copies, gate in 4 copies, 4 test files) | 27494 tests (executor cycle-1 final gate) | 27476 passed, 0 failed, 18 skipped | 96.04% lines (44785/46631) | 96.05% lines (44865/46711) | 100% lines (classify 101/101 per measured copy; every executable line changed by cycle 1 has hits) |
| Python | 0 files | N/A | N/A | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| Markdown | 6 brief copies and the feature folder documents and evidence | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- Python baseline coverage artifact: N/A - zero changed Python files
- Python post-change coverage artifact: N/A - zero changed Python files
- C# baseline coverage artifact: N/A - zero changed C# files
- C# post-change coverage artifact: N/A - zero changed C# files
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-15-preimplementation-gate-wrapped-shell-commands-and-test-rows-1195/evidence/baseline/pester-gate.2026-11-15T23-35.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, written 2026-11-16T03:52Z by the executor's cycle-1 final parallel gate (`evidence/qa-gates/final-qc-pester.2026-11-16T03-52.md`), after the last code commit `9063a8c07` (03:29Z); the reviewer parsed it (repo-wide LINE counter 44865 covered, 1846 missed; classify 101 covered, 0 missed on the `.claude` and `.codex` copies)
- Per-language comparison summary: section 1.2.1 below

---

## Executive Summary

Scope: the full branch diff against the merge base (74 files). PowerShell and Markdown have changed files. Python, TypeScript, C#, and bash have zero changed files.

Remediation cycle 1 addressed finding F1 of `remediation-inputs.2026-11-16T02-21.md`: `env` with value options after another transparent prefix was not classified. The cycle (commits `73ee4f033` to `34ac24137`) changed only the four classify copies, the classify Cases file, and feature-folder files (`git diff --name-status ebacd29f1..HEAD`).

The reviewer verified at the head: four-copy byte identity of the classify sibling (SHA-256 `d2ff656b...`), a real-process probe of `Test-ImplementationCommand` showing `timeout 60 env -u X sh -c "pytest"` and `nohup env --unset X bash -c "ruff check ."` false at the merge base and at the pre-cycle head `ebacd29f1` and true at the head, `timeout 60 env -S sh -c "pytest"` false on all three, two reverted mutants of the new loop each failing the new rows, the coverage report, the evidence-location validator (exit 0), a clean `git merge-tree` against `origin/main`, and CI run `43803257455` on the exact head (success, including `CI full run`, `CI Required Gate`, and `poshqc / PowerShell hook suites (Linux)`).

No blocking finding.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `.claude/hooks` and `.codex/hooks` are already classified; the branch adds no project folder)

**Language-specific policies evaluated:**
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- N/A Python: no Python file in the branch diff
- N/A Bash: no bash file in the branch diff

**Temporary artifacts cleanup:**
- ✅ Reviewer probe files live in the session scratchpad, outside the repository; none is tracked
- ✅ No ongoing tooling script was added
- Reviewer-created files: this review set, a PASS remediation-inputs file, and one owner-directive decision file; no existing evidence was edited. The reviewer ran no Pester suite, so the gitignored `artifacts/pester/` reports still hold the executor's cycle-1 full-gate output

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Data-driven rows with no shared mutable state; the suites pass inside the eight-shard final gate. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One row per prefix order or decline path. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The two classify suites ran in 102.5 s wall clock including worker startup (fail-before run). |
| **Determinism** - Consistent results | ✅ PASS | No clock, file, process, or network access in the new rows. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | The new rows carry names and a comment naming finding F1. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 96.04% lines repo-wide; classify 61/61<br>**Command:** `run-test-suite.sh pester` (`Invoke-PoshQCParallelTest`)<br>**Artifact:** `evidence/baseline/pester-gate.2026-11-15T23-35.md`<br>**Timestamp:** 2026-11-15T23-35 |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 96.05% lines repo-wide (44865 covered, 1846 missed)<br>**Change:** +0.01%<br>**Status:** No regression; the Claude gate stays at 169/175 with the same six zero-hit lines, none in a changed hunk |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** classify 100% (101/101) on both measured surfaces; Claude gate 96.57%; Codex gate 100%<br>**Thresholds:** 85% line; no branch threshold for PowerShell<br>**Status:** All changed files meet the thresholds |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** classify sibling; both gates<br>**New code coverage:** 100% of changed executable lines<br>**Calculation method:** JaCoCo per-file counters from the final gate report (0 missed lines in the classify copies); per-line hit counts for the cycle-1 lines recorded in `final-qc-pester.2026-11-16T03-52.md` |
| **Comprehensive Coverage** | ✅ PASS | Reviewer mutants of the new loop: removing `-Except 'env'` and replacing the prefix-skip test with an unconditional `break` each turn the two Positive F1 forms false and the `env -S` decline true; the unmutated head classifies all as expected. |
| **Positive Flows** - Valid inputs | ✅ PASS | Function rows after `timeout`, `nohup`, and xargs-injected words; one Positive gate row. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `timeout 60 env -S sh -c "pytest"` with `Indexes = @()`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Existing depth, empty-command, and repeated-index rows unchanged and passing. |
| **Error Handling** - Error paths | ✅ PASS | Row I2 unchanged and passing in the final gate. |
| **Concurrency** - If applicable | N/A | No concurrent code. |
| **State Transitions** - If applicable | N/A | Stateless string functions. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.04% lines (from the `Phase 0 baseline` artifact `evidence/baseline/pester-gate.2026-11-15T23-35.md`) -> Post-change: 96.05% lines (reviewed head). Change: +0.01% lines. New/changed-code coverage: 100% lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` from the executor's cycle-1 final parallel gate, parsed by the reviewer.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Existing `-Because` text applies to the new rows. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | The rows run through the existing `It -ForEach` blocks with `# Act` and `# Assert` comments. |
| **Document Intent** | ✅ PASS | Comment `Remediation cycle 1 (finding F1)` above the new function rows. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The changed function is pure string logic. |
| **Use Mocks/Stubs** | ✅ PASS | Existing suite isolation reused; no new mock. |
| **Environment Stability** | ✅ PASS | New row strings carry no path or drive letter; the Linux hook-suite job passed. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the policy review for the branch at the reviewed head. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `remediation-inputs.2026-11-16T02-21.md` (F1), `spec.md`. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-16T02-21.md` with a Design section and Pre-Mortem. |
| **Document the plan** | ✅ PASS | All 11 cycle tasks are checked, each with an evidence record. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The existing head-only strip moved into the existing hop loop; no function added. |
| **Reusability** | ✅ PASS | Reuses `Skip-CommandLineTransparentWrapper -Except 'env'` from the unchanged shared module. |
| **Extensibility** | ✅ PASS | Prefix handling now repeats in any order. |
| **Separation of concerns** | ✅ PASS | Change confined to the classify sibling. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One function changed. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical lines: classify 232 (each copy), Cases 186, Claude gate 493, Codex gate 485. No covered file at or above 700; `config/file-size-baseline.json` unchanged. |
| **Public vs internal** | ✅ PASS | No new public surface. |
| **No circular dependencies** | ✅ PASS | The classify sibling dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `$remaining`, `$position`, `$skip`. |
| **Docs/docstrings** | ✅ PASS | `.SYNOPSIS` of `Get-OrchestrationGateWrapperPayloadText` states that prefixes may appear in any order and repeat. |
| **Comment why, not what** | ✅ PASS | Comment states why the shared skip stops at `env`. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` with a non-writing seam<br>**Result:** 0 files would change (`evidence/qa-gates/final-qc-static.2026-11-16T03-37.md`) |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer`, `Invoke-PoshQCLeakScan`<br>**Result:** 0 findings, 0 leak failures |
| **3. Type checking** | N/A | Not applicable for PowerShell |
| **4. Testing** | ✅ PASS | **Command:** `run-test-suite.sh pester` (parallel)<br>**Result:** 27476 passed, 0 failed; pytest 16957 passed, 0 failed |
| **Full toolchain loop** | ✅ PASS | Phase gate P1 and the final QA loop each closed in one pass; integration lanes ran in CI. |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages and the cycle evidence. |
| **Design choices explained** | ✅ PASS | `## Design (F1)` of the remediation plan; help text. |
| **Update supporting documents** | ✅ PASS | The brief already states the env-with-value-options prefix; no brief change needed. |
| **Provide next steps** | ✅ PASS | AC-20 left for S9. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat` (non-writing)<br>**Result:** 0 differences |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` (Error, Warning, Information)<br>**Result:** 0 findings |
| **Fix all findings** | ✅ PASS | No lint findings. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The repository rule is PowerShell 7+; the hooks run under pwsh 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `[CmdletBinding()]` and `[OutputType()]` retained. |
| **Parameter validation** | ✅ PASS | Unchanged `Mandatory`, `AllowEmptyString`, `AllowEmptyCollection`. |
| **Avoid global state** | ✅ PASS | Local variables only. |
| **Error handling** | ✅ PASS | The inner loop terminates: every skip advances `$position` by at least one (`SkippedWrapper` implies `Index` of at least 1 in the shared function). |

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
| **Step 4: Test** | ✅ PASS | Final gate 0 failed. |
| **Rerun loop if needed** | ✅ PASS | One clean pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`/`Context`/`It -ForEach` rows. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest` through the launcher<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged) |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | pwsh 7. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Function rows drive the classify function alone; the gate row drives `Test-ImplementationCommand`. |
| **Test Behavior Over Implementation** | ✅ PASS | Rows assert classification and returned indexes. |
| **Mocking Used Sparingly** | ✅ PASS | No new mocks. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1`<br>**Code file:** `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | Suites end in `.Tests.ps1`; the Cases file is data only. |
| **Describe/Context/It Structure** | ✅ PASS | Unchanged structure. |
| **Logical Grouping** | ✅ PASS | The Positive gate row sits in the Positive group. |
| **Docstrings/Comments** | ✅ PASS | Row comment names F1. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest`<br>**Result:** 0 failed |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### Get-OrchestrationGateWrapperPayloadText (cycle-1 prefix loop)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| env value option after timeout | Positive | env branch inside the hop loop after the `-Except 'env'` skip | ✅ |
| env long value option after nohup | Positive | `--unset` value skip after a prefix | ✅ |
| env value option after xargs injected words | Positive | prefix strip on `Words` output | ✅ |
| env -S after timeout is declined | Negative | split-string decline after a prefix | ✅ |
| Gate Positive `timeout 60 env -u X sh -c "pytest"` | Positive | gate union path | ✅ |

**Coverage:** 100% of each measured classify copy (101/101).

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 27494 Pester (cycle-1 final gate) | ✅ |
| Tests Passed | 27476 Pester | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | final gate 656.21 s wall clock (8 shards) | ✅ Fast |
| Average Time per Test | under 30 ms | ✅ Fast |
| Discovery Time | not reported separately by the parallel runner | ✅ |
| Functions/Classes Tested | 1/1 changed function | ✅ |
| Test File Size | Cases 186 logical lines | ✅ PASS |
| Code Coverage (if applicable) | 100% lines on new code; 96.05% repo-wide | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` (non-writing) | 0 differences | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings | ✅ |
| Leak scan | `Invoke-PoshQCLeakScan` | 0 failures | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 0 failed, 18 skipped | ✅ |

**Notes:**
The reviewer did not rerun the Pester gate. It verified the classification behavior with real-process probes of `Test-ImplementationCommand` at the merge base, the pre-cycle head, the head, and two mutants, and relied on the executor's post-commit gate and on CI at the exact head.

---

## CI Cross-check

CI read with `gh run view 43803257455` at review time.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| CI Required Gate | pass | N/A | 34ac24137b2ace314c3ac9186358ba16b3044583 | run `43803257455` (pull_request) |
| CI full run | pass | N/A | 34ac24137b2ace314c3ac9186358ba16b3044583 | run `43803257455` |
| poshqc / PowerShell QC | pass | 0 failed | 34ac24137b2ace314c3ac9186358ba16b3044583 | run `43803257455`; local final gate 27476 passed, 0 failed |
| poshqc / PowerShell hook suites (Linux) | pass | N/A | 34ac24137b2ace314c3ac9186358ba16b3044583 | run `43803257455` |
| poshqc / PowerShell QC static | pass | N/A | 34ac24137b2ace314c3ac9186358ba16b3044583 | run `43803257455` |

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap. Non-blocking observations are listed in the code review.

### Approved Exceptions

None.

### Removed/Skipped Tests

**None.** The 18 skipped Pester rows are pre-existing skips.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root <item worktree>` exited 0. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All item evidence is under the feature folder's `evidence/<kind>/`. `git log --diff-filter=MDR` over the evidence folder from the merge base lists no commit, so every evidence file was added once and never edited or removed. The cycle-1 fail-before stamp (02-38Z) precedes the fix commit `9063a8c07` (03:29Z), and the cycle-1 final gate stamp (03-52Z) follows it. No evidence file names an absolute path (scratch is recorded as `SCRATCH`).

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent at the branch head, so the check is not applicable and produces no finding.

## Rejected Scope Narrowing

None. The caller prompt required the full branch diff against the merge base, with an additional cycle-scope confirmation, and attempted no narrowing.

---

## 9. Summary of Changes

Stage 1 of both preimplementation gates scans the literal payload of a sh-family `-c`, `pwsh`/`powershell` command flag, or `eval` wrapper after the transparent prefixes, to nesting depth 4, and feeds every hit to the unchanged stage 2. Cycle 1 lets the prefixes (assignments, `env` with value options, `timeout`, `time`, `command`, `nohup`) appear in any order and repeat, before and after xargs-injected words.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

Toolchain stages, coverage thresholds, file-size limits, mirrors, and evidence rules are met, and CI on the exact head succeeded.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: inputs and remediation plan present
- ✅ Design Principles: existing loop extended, no new function
- ✅ Module & File Structure: all files below 700 lines
- ✅ Naming, Docs, Comments: help text in all four copies
- ✅ Toolchain Execution: one clean pass
- ✅ Summarize & Document: records committed

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format, lint, leak scan clean
- ✅ PowerShell Design & Safety: no I/O, terminating loops
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: one pass

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: in-memory, deterministic rows
- ✅ Coverage & Scenarios: 100% new-code lines; both probed mutants killed
- ✅ Test Structure: AAA comments, descriptive names
- ✅ External Dependencies: no temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester through PoshQC
- ✅ Test Style & Structure: focused rows
- ✅ Naming & Readability: `.Tests.ps1`, named rows
- ✅ Toolchain: parallel gate

---

### Metrics Summary

- ✅ 27476 Pester rows passing, 0 failed
- ✅ 1/1 changed function tested
- ✅ 100% line coverage on new code; 96.05% repo-wide
- ✅ Test files mirror the hook layout
- ✅ All code quality checks passing

---

### Recommendation

**Ready to merge.** CI on the head succeeded; AC-20 check-off is owned by the orchestrator at S9.

---

## Appendix A: Test Inventory

### Complete Test List

1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` › classify rows, wrapped gate rows, wrapped function rows, I2
2. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1` › the Codex equivalents
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1` › four-copy identity, 500-line bound, brief wording, help and Cases-header tokens

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting and linting
Invoke-PoshQCFormat (non-writing -WriteFile seam)
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing (parallel, through the launcher)
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <paths>
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-17  
**Policy Version:** Current (as of audit date)

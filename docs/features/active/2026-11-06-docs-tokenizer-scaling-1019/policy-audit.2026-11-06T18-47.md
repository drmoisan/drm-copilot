# Policy Compliance Audit: Python Tokenizer Scaling (#1019)

---

**Audit Date:** 2026-11-06
**Code Under Test:** `.claude/lib/docs/DocsPythonTokens.psm1`; `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPythonTokens.psm1`; `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1`
**Base:** `origin/epic/documentation-estate-tooling-integration` at `eca4fc203` (supplied by the caller). **Merge base:** `c4a2398aa`, committed 2026-11-06T07:30:25-05:00. **Head:** `bug/docs-tokenizer-scaling-1019` at `fe9a4023d`. PR-context artifacts were generated at this head and were not refreshed.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 production (1 module, 1 byte-identical bundle copy), 1 test | 56 in `DocsPythonTokens.Tests.ps1`; 2049 in the docs test folder | PASS: 56 pass, 0 fail (reviewer run); 2049 pass, 0 fail (recorded run) | Module 100.00% lines (128 of 128, all tests, CI); repo-wide 95.19% lines (31773 of 33377, CI) | Module 100.00% lines (151 of 151); repo-wide 95.20% lines (31796 of 33400, derived) | 100.00% (29 of 29 changed executable lines) |

Python, TypeScript, C#, Bash, and JSON have zero changed files on the branch, confirmed from `git diff --name-status c4a2398aa...HEAD`, so no coverage row applies to them.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope
- TypeScript post-change coverage artifact: N/A - out of scope
- PowerShell baseline coverage artifact: `evidence/baseline/pester-coverage-before.2026-11-06T18-01.md` and merged CI artifact `poshqc-test-results` of run 42138261703, parsed in `evidence/qa-gates/review-reverification.2026-11-06T18-47.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` and `evidence/qa-gates/suite-duration-after.2026-11-06T18-28.md`
- Per-language comparison summary: Section 1.2.1

**Coverage verdicts:** PowerShell PASS, on the full branch diff.

Python, TypeScript, and C# have zero changed files on the branch, so they carry the verdict N/A.

**Governing thresholds:** The root `CLAUDE.md` states no coverage threshold, so the defaults govern: line coverage at least 85%. No branch threshold applies to PowerShell because Pester measures no branch coverage.

---

## Executive Summary

The branch replaces per-call whole-source arguments in `Get-DocsPythonToken` and `Read-DocsPythonStringEnd` with candidate-identical slices and a bounded lexing window, adds two test groups, and mirrors the module into the bundle. Format, analyzer, tests, coverage, differential, scaling, and evidence-location checks hold. One gap requires remediation: the structural guard passes on a mutant whose window has no length bound, so the property the item delivers is not pinned against regression (F1, autonomous).

**Policy documents evaluated:**
- PASS `general-code-change` (`.claude/rules/general-code-change.md`)
- PARTIAL `general-unit-test` (`.claude/rules/general-unit-test.md`): see F1 in Section 8

**Language-specific policies evaluated:**
- N/A Python policies: zero changed files
- PARTIAL PowerShell policies (`.claude/rules/powershell.md`): see F1 in Section 8
- N/A Bash: zero changed files
- N/A JSON: zero changed files

The toolchain was re-verified at head by the reviewer for format, analyzer, and `SUITE`. `SUITE` means `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1`, and `MODULE` means `.claude/lib/docs/DocsPythonTokens.psm1`.

**Temporary artifacts cleanup:**
- PASS No temporary script is in the branch diff. Helpers live under the session scratchpad, recorded as `SCRATCH`.
- PASS No ongoing tooling script was added.
- Reviewer helpers `issue-1019-review.sh`, `issue-1019-review.ps1`, and `issue-1019-ci-parse.ps1` stay in the session scratchpad outside the repository.

**Template source:** The MCP tool `resolve_policy_audit_template_asset` was not available to this agent. The structure was taken from `docs/features/templates/policy_audit/`. `git diff --no-index` against the bundled assets under `extensions/drm-copilot/resources/templates/policy_audit/` shows the policy-audit and code-review templates identical and one changed line in the feature-audit template. The bundled assets were not read through the resolver, so this is a substitution for the skill's stated route.

**Tier classification:** `quality-tiers.yml` exists on the base branch and classifies `.claude/lib/docs` as T3 and `extensions/drm-copilot` as T3. No finding applies. T3 carries no property-test, mutation, or golden-test requirement.

## Rejected Scope Narrowing

None detected. The caller prompt names the small-audit workflow and lists one criterion as pending-CI; it does not narrow the audit scope, so the audit covers the full branch diff against the resolved base.

## Evidence Location Compliance

No violation. `validate_evidence_locations.py --root .` exited 0 with no output, and `git diff --name-only c4a2398aa...HEAD -- artifacts` returned no path. No non-canonical evidence path was supplied by the caller.

## Workflow Rule

`modified-workflow-needs-green-run` does not fire: the branch diff has no path under `.github/workflows/`, `.github/actions/`, or `scripts/benchmarks/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | `evidence/regression-testing/shuffle-isolation.2026-11-06T18-28.md`: seeds 11, 42, and 1019, 163 passed, 0 failed each, with the six consumer suites. |
| **Isolation** - Each test targets single behavior | PASS | One `It` per behavior; data-driven cases use `<Case>` titles. |
| **Fast Execution** - Tests complete quickly | PASS | `SUITE` 32.54 s in the reviewer run, 27.07 s recorded; before the fix it did not finish within the 600 s bound. The pre-existing token-limit test takes about 41 s under coverage and tokenizes about 524,000 tokens in two calls. |
| **Determinism** - Consistent results | PASS | Seeds 102210 and 101910 are named in `-Because` text. No clock, sleep, timing threshold, or network use. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive titles and Arrange/Act/Assert comments. Candidate test title wording recorded in the self-review. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | 98.44% lines (126 of 128) with the token-limit test excluded, `evidence/baseline/pester-coverage-before.2026-11-06T18-01.md`. With all tests, 100.00% (128 of 128) in CI run 42138261703. |
| **No Coverage Regression** | PASS | 128 of 128 to 151 of 151. Changed lines 29 of 29. |
| **New/modified file line coverage at least 85%** | PASS | `MODULE` 100.00%. The bundle copy is outside the coverage roots and is byte-identical to `MODULE` (both SHA-256 `6010cf35...`, same blob `43a713a5b`), so its measured value is that of `MODULE`. |
| **Repo-wide line coverage at least 85%** | PASS | 95.19% in the merged CI artifact for the branch merged at the merge base; 95.20% derived with the `MODULE` delta. The derived denominator of 33400 equals the local artifact's root total. The local root percentage of 26.89% comes from a one-folder test run and is not a repository-wide measure. The S9 CI run prints the merged figure for the PR head. |
| **Local PowerShell artifact root counter against the 85% line coverage floor** | FAIL for this reading only | The root counter of `artifacts/pester/powershell-coverage.xml` reads 26.89% lines (8982 of 33400) because that run executed one test folder. This reading is recorded as it stands. It is not the repo-wide verdict, which is the row above, and it opens no remediation finding. The merged figure for the PR head comes from CI at S9. |
| **Branch coverage** | N/A | Pester measures no branch coverage; no branch threshold applies to PowerShell. |
| **Coverage exclusions** | PASS | `config/poshqc-coverage.json` is not in the branch diff. |
| **Comprehensive Coverage** | PARTIAL | Every line of `MODULE` is executed, but the window length bound has no test that fails when it is removed (F1). |
| **Positive Flows** - Valid inputs | PASS | Token-class cases, padded-offset cases (12 pieces over offsets 1010 to 1026), and the long-input property case. |
| **Negative Flows** - Invalid inputs | PASS | 12 diagnostic cases plus three cases past the first window. |
| **Edge Cases** - Boundary conditions | PASS | String ending at the window end (offsets 1015, 1016, 1023, 1024), a triple-quoted string longer than one window, tokens longer than two windows, and the empty text. |
| **Error Handling** - Error paths | PASS | `PYTHON_LEXER_UNCLASSIFIED`, `PYTHON_LEXER_UNTERMINATED`, `PYTHON_ENCODING_UNSUPPORTED`, and `PYTHON_TOKEN_LIMIT` asserted. |
| **Concurrency** - If applicable | N/A | Pure function with no shared mutable state. |
| **State Transitions** - If applicable | PASS | Window doubling and reset branches are driven by `lexes a token longer than two windows: <Case>`. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 100.00% lines for the module (128 of 128, all tests, CI run 42138261703) and 95.19% repo-wide. Post-change: 100.00% lines for the module (151 of 151) and 95.20% repo-wide (derived). Change: 0.00 points for the module, about +0.004 points repo-wide. New/changed-code coverage: 100.00% (29 of 29). Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/suite-duration-after.2026-11-06T18-28.md`, `evidence/qa-gates/review-reverification.2026-11-06T18-47.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `-Because` text names the case, offset, or seed. Guard failure messages are quoted in `evidence/regression-testing/guard-fail-before.2026-11-06T18-28.md`. |
| **Arrange-Act-Assert Pattern** | PASS | Sections marked in the added cases. |
| **Document Intent** | PASS | Descriptive titles and a short comment in each helper. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | In-memory strings and `Parser::ParseFile` on the module path. |
| **Use Mocks/Stubs** | N/A | No mock is needed for a pure function. |
| **Environment Stability** | PASS | Paths resolve from `$PSScriptRoot`. No temporary file. Literal newlines use the backtick escape. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document. Finding F1 remains open. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` Problem and Implementation Intent. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.2026-11-06T17-49.md`. |
| **Document the plan** | PASS | `plan.2026-11-06T12-15.md`, all tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Two script constants and two rebase points in the existing loop. |
| **Reusability** | PASS | The rebase statements appear twice and differ in how the size is chosen, as the plan specifies. Recorded as Info in the code review. |
| **Extensibility** | N/A | The public signature and output contract are unchanged. |
| **Separation of concerns** | PASS | The function remains pure. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | No new module. |
| **At or below the 800-line hard limit** | PASS | Logical lines: `MODULE` 265, bundle 265, `SUITE` 492. No file is at or above 700. `config/file-size-baseline.json` is not in the branch diff. |
| **Public vs internal** | PASS | `Export-ModuleMember -Function Get-DocsPythonToken` is unchanged. |
| **No circular dependencies** | PASS | Imports are unchanged. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `$sourceText`, `$windowStart`, `$windowSize`, `DocsPythonTokenWindowMargin`. |
| **Docs/docstrings** | PASS | Existing comment-based help remains accurate as to the contract; it does not describe the window (Minor in the code review). |
| **Comment why, not what** | PARTIAL | Comments explain rationale. Two retained candidate comments state an AMSI cause that the root-cause profile records as not established, and one says `Match` runs only for the first token and after a string token, while it now also runs after a window rebase. Non-remediation severity: Minor in the code review. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `Invoke-Formatter` comparison. **Result:** text equal for `MODULE` and `SUITE` (reviewer run); `evidence/qa-gates/format.2026-11-06T18-15.md`. |
| **2. Linting** | PASS | **Command:** `Invoke-ScriptAnalyzer` with repository settings. **Result:** 0 findings for each file (reviewer run). |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Architecture-boundary tests** | N/A | Imports are unchanged; no boundary tool applies to this change. |
| **5. Testing** | PASS | **Command:** Pester 6 on `SUITE`. **Result:** 56 passed, 0 failed. Docs folder 2049 passed, 0 failed in the recorded run. |
| **6. Contract checks** | PASS | Push-down resource contract and manifest tests: 16 passed, `evidence/regression-testing/mirror-parity.2026-11-06T18-09.md`. |
| **7. Integration tests** | N/A | No integration suite targets this pure module. CI runs the consumer suites. |
| **Full toolchain loop** | PASS | The recorded format pass changed no file. |
| **Explicit reporting** | PASS | Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Section 9. |
| **Design choices explained** | PASS | `evidence/qa-gates/self-review.2026-11-06T18-34.md`. |
| **Update supporting documents** | PASS | Feature folder evidence. `issue.md` Dependencies still says 1034 carries the candidate hunks; the 1034 tip has since reverted them (Minor in the code review). |
| **Provide next steps** | PASS | Section 10 Recommendation. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Result:** no change. |
| **Linting with PSScriptAnalyzer** | PASS | **Result:** 0 findings, equal to the baseline. |
| **Fix all findings** | PASS | None to fix. |
| **PowerShell 7+ compatible** | PASS | Module states PowerShell 7.4 or later; ran on 7.6.9 per the root-cause profile. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `CmdletBinding` retained. |
| **Parameter validation** | PASS | Parameters unchanged. |
| **Avoid global state** | PASS | Added script variables are constants. |
| **Error handling** | PASS | Diagnostics paths unchanged; differential reports identical diagnostics over 1098 inputs. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | PASS | 265 and 492 logical lines. |
| **Approved verbs** | PASS | `Get-DocsPythonToken`, `Read-DocsPythonStringEnd`; test helper `Get-TestPaddedInput`. |
| **Comment why** | PARTIAL | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Unchanged hashes. |
| **Step 2: Analyze** | PASS | 0 findings. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | 56 passed, 0 failed. |
| **Rerun loop if needed** | PASS | No rerun was caused by a formatter or analyzer change. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x or later** | PASS | Pester 6.2.0 in the recorded runs; `_poshqc.yml` imports Pester 6.2.0 or later. |
| **Use PoshQC Configuration** | PASS | **Command:** `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs`. No configuration change. |
| **PowerShell 7+ Compatible** | PASS | `#Requires -Version 7.0`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 56 tests across five describes. |
| **Test Behavior Over Implementation** | PARTIAL | Behavior cases are strong. The structural guard is an intended implementation pin, and its second case does not assert the length bound (F1). |
| **Mocking Used Sparingly** | PASS | No mock. |
| **Organization** | PASS | **Test file:** `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1`. **Code file:** `.claude/lib/docs/DocsPythonTokens.psm1`. The location follows the existing mirror. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | Name unchanged. |
| **Describe/Context/It Structure** | PASS | Added `Describe 'Get-DocsPythonToken structural scaling guard'` and `Describe 'Get-DocsPythonToken window boundaries'`. |
| **Logical Grouping** | PASS | Guard and boundary cases are grouped separately. |
| **Docstrings/Comments** | PASS | Short rationale comments. The file synopsis does not mention the two new groups (Nit in the code review). |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Recorded folder run with coverage. |
| **No Alternative Test Runners** | PASS | Pester only. |

---

## 5. Test Coverage Detail

### `Get-DocsPythonToken` and `Read-DocsPythonStringEnd` (56 tests)

| Test Group | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `Get-DocsPythonToken token classes` | Positive, edge | Token loop, string branch | PASS |
| `Get-DocsPythonToken diagnostics` | Negative, error handling | Each diagnostic return | PASS |
| `Get-DocsPythonToken properties` | Property | Span reconstruction | PASS |
| `Get-DocsPythonToken structural scaling guard` | Structural | Module syntax tree | PASS, with the gap in F1 |
| `Get-DocsPythonToken window boundaries` | Edge, negative, property | Margin rebase, doubling, reset, string rebase | PASS |

**Coverage:** 100.00% of `MODULE` lines (151 of 151). Command coverage 274 of 279, for information only.

**Not covered:** None by line.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 56 in `SUITE`; 163 with consumer suites; 2049 in the folder | PASS |
| Tests Passed | 56 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 32.54 s reviewer run; 27.07 s recorded | PASS, was over 600 s before the fix |
| Average Time per Test | about 581 ms, dominated by the token-limit test | PASS |
| Discovery Time | Not recorded by the reviewer run | N/A |
| Functions/Classes Tested | 2 of 2 functions | PASS |
| Test File Size | 492 logical lines | PASS |
| Code Coverage | 100.00% lines; no branch figure for PowerShell | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` comparison and recorded `mcp__drm-copilot__run_poshqc_format` | Text equal | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 findings each | PASS |
| Pester Tests | Pester 6 on `SUITE` | 56 passed, 0 failed | PASS |

**Notes:** Coverage was inspected from existing artifacts and not regenerated. CI on the pull request head has not run; AC-8 is pending-CI.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **F1 (remediation required, autonomous):** the structural guard in `SUITE` passes on a mutant with an unbounded lexing window. `.claude/rules/general-unit-test.md` states that untested critical behavior is not acceptable even when the percentage is high. On this mutant the token-limit test uses a names-only source, so it would not expose the string-heavy regression either. Evidence: `evidence/qa-gates/review-reverification.2026-11-06T18-47.md`.
- **Non-remediation items:** comment accuracy and other Minor, Nit, and Info rows in the code review. These relate to this item and are listed in the remediation inputs for the cycle.

### Approved Exceptions

**None.** No exception was requested.

### Removed/Skipped Tests

**None.** All planned tests are implemented. The baseline run excluded only the token-limit test, as stated in the plan.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **99b26392e** - docs(1019): add feature folder and tokenizer root-cause profile
2. **6e33db871** - docs(1019): add the minimal-audit plan after preflight clearance
3. **1bee6ac5c** - docs(1019): record Phase 0 baselines for the tokenizer scaling fix
4. **39a0bdbe1** - fix(docs): make the Python tokenizer linear with a bounded lexing window
5. **fe9a4023d** - docs(1019): record Phase 2 QA evidence for the tokenizer scaling fix

### Files Modified

1. **`.claude/lib/docs/DocsPythonTokens.psm1`** (MODIFIED)
   - Candidate slices and `NextMatch` loop head, window constants, margin rebase, string rebase.
2. **`extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPythonTokens.psm1`** (MODIFIED)
   - Byte-identical mirror.
3. **`tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1`** (MODIFIED)
   - Candidate tests, structural guard, and window-boundary cases.
4. **`docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/`** (NEW)
   - `issue.md`, plan, and evidence.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Toolchain, coverage, mirror, file-size, and evidence-location requirements hold. Finding F1 requires one remediation cycle.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: plan and reads recorded.
- PASS Design Principles: minimal loop change.
- PASS Module & File Structure: within limits.
- PARTIAL Naming, Docs, Comments: retained comments need correction notes (Minor).
- PASS Toolchain Execution: format, analyzer, tests hold.
- PASS Summarize & Document: recorded.

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline: clean.
- PASS PowerShell Design & Safety: pure function retained.
- PARTIAL Structure & Naming: comment accuracy (Minor).
- PASS Toolchain: format, analyze, test.

#### General Unit Test Policy (Section 1)
- PASS Core Principles: shuffle runs clean.
- PARTIAL Coverage & Scenarios: percentages hold; window bound has no failing test (F1).
- PASS Test Structure: clear.
- PASS External Dependencies: none.
- PASS Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope: Pester through PoshQC.
- PARTIAL Test Style & Structure: guard gap (F1).
- PASS Naming & Readability: clear.
- PASS Toolchain: recorded.

---

### Metrics Summary

- PASS 56 of 56 tests in `SUITE`; 2049 of 2049 in the folder.
- PASS 2 of 2 functions tested.
- PASS 100.00% module line coverage; 95.20% repo-wide (derived).
- PASS File organization follows the existing test tree.
- PASS Format and analyzer clean.
- PASS Suite time 27 to 33 s, from over 600 s.

---

### Recommendation

**Needs revision**

Run one proportionate remediation cycle for F1 per `remediation-inputs.2026-11-06T18-47.md`, then re-review. The item then proceeds to the PR, with AC-8 checked off by the item's own orchestrator run at S9.

---

## Appendix A: Test Inventory

### Complete Test List

Added or changed in this branch:

1. Get-DocsPythonToken token classes › continues with the correct tokens and columns after a string token
2. Get-DocsPythonToken token classes › passes the whole source to a .NET method only at the restart after a string token
3. Get-DocsPythonToken diagnostics › reports PYTHON_LEXER_UNCLASSIFIED for a character reached by continuing from a name and from a string
4. Get-DocsPythonToken structural scaling guard › passes no source text variable to a .NET method inside a loop
5. Get-DocsPythonToken structural scaling guard › assigns the lexing window only from a Substring of the source text
6. Get-DocsPythonToken window boundaries › keeps the token at each padded offset across the window end: <Case> (12 cases)
7. Get-DocsPythonToken window boundaries › property: long inputs reconstruct their spans and lines
8. Get-DocsPythonToken window boundaries › keeps the following token correct when a string ends at the window end
9. Get-DocsPythonToken window boundaries › keeps Line, Column and EndLine after a triple-quoted string longer than one window
10. Get-DocsPythonToken window boundaries › lexes a token longer than two windows: <Case> (4 cases)
11. Get-DocsPythonToken window boundaries › reports diagnostics with the right Line past the first window: <Case> (3 cases)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (reviewer, through the `sh` launcher under `SCRATCH`):**

```powershell
Invoke-Formatter -ScriptDefinition $text -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-ScriptAnalyzer -Path $path -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Pester -Configuration $config   # Run.Path = SUITE, coverage off
```

**Repository checks:**

```text
git diff --name-status c4a2398aa...HEAD
git merge-base --is-ancestor f2c93949358a2763f1d74e5f63cfe604b365b336 c4a2398aa93c721e06f6878851526d4338ec98c7
git merge-tree --write-tree HEAD origin/epic/documentation-estate-tooling-integration
gh run download 42138261703 --name poshqc-test-results
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
git diff --no-index --stat docs/features/templates/policy_audit extensions/drm-copilot/resources/templates/policy_audit
```

**Recorded by the executor:**

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-06
**Policy Version:** Current (as of audit date)

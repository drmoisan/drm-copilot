# Policy Compliance Audit: Preimplementation Gate Helpers Backslash Chain Operator (#710)

---

**Audit Date:** 2026-09-27
**Branch:** `bug/preimplementation-helpers-backslash-chain-operator-710` @ `e5c7a223460a302042840e45192ba6a78924df48`
**Base:** `main` (resolved `origin/main`), merge-base `2dce111ef7cb6cf6326db6e661223e59c85e4bec`
**Code Under Test:**
- `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (MODIFIED, canonical)
- `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (MODIFIED, byte copy)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (MODIFIED, byte copy)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (MODIFIED, byte copy)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` (NEW, test)
- 47 Markdown files under `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/` (issue, spec, plan, research, evidence)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 5 files (4 production copies, 1 test) | 38 new tests; 5244 JUnit tests in full run | ✅ 5235 pass, 0 fail, 9 skipped | 97.04% lines per canonical helper copy; 95.97% lines repo-wide (derived) | 97.08% lines per canonical helper copy; 95.97% lines repo-wide | 100% (2 of 2 changed executable lines per canonical copy) |

Languages with zero changed files on the branch (Python, TypeScript, C#, Bash, JSON): no coverage verdict required. Markdown files are documentation and carry no coverage obligation.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-scoped-coverage.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (full run, 2026-09-27 02:44 local, after fix commit `3fd0c454`) and `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-scoped-coverage.md`
- Per-language comparison summary: Section 1.2.1 of this audit; `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/final-coverage-delta.md`

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the base branch (`main`), merge-base SHA, feature folder, and AC source; none of these narrows the audit below the full feature-vs-base diff. The audit covers all 52 changed files in `2dce111e...e5c7a223`.

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (no violations reported).
- Branch-diff scan: `git diff --name-only 2dce111e...HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` returned no matches.
- All feature evidence is under canonical `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Note: `spec.md` names `evidence/coverage/` and `evidence/regression/` as destinations; neither is a canonical evidence kind. The executor wrote coverage evidence to `evidence/qa-gates/` and fail-before evidence to `evidence/regression-testing/`, which is the canonical placement. Verdict: PASS.

---

## Executive Summary

The branch corrects `Split-OrchestrationCommandLine` so that an unquoted or double-quoted backslash escapes the next character (POSIX Shell Command Language 2.2.1). The edit is two executable lines plus a condensed help block, applied byte-identically to four copies (SHA256 `ebe15355...9c6f7a` for all four, recomputed during this review). A new 198-line Pester suite exercises 19 cases against both canonical copies (38 tests). The helper file line count is unchanged at 497.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (no Python files changed)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- N/A Bash: no shell files changed
- N/A JSON: no JSON files changed

Toolchain: PoshQC format (0 files reformatted of 530), PoshQC analyze (no findings), full Pester (5235 passed, 0 failed, 9 skipped), and the scoped helper suites all passed in a recorded single pass (pass 2). A reviewer rerun of the ChainEscape, Parity, both CommandExemption, and EpicScope suites passed 297 of 297. The only toolchain failure is the known gitignored-state failure in `test_push_down_claude_resource_contracts.py` (issue #510), which is unrelated to this branch.

Review templates were taken from the bundled asset directory `extensions/drm-copilot/resources/templates/policy_audit/`, which is the directory the MCP template asset tool resolves to; the MCP tool itself was not available in this agent's tool set.

**Temporary artifacts cleanup:**
- ✅ No temporary scripts were committed; executor scratch scripts were under `<SCRATCHPAD>` outside the repository.
- ✅ No ongoing tooling scripts were added.
- Reviewer probe scripts (`review-run.ps1`, `probe2.ps1`, `probe3.ps1`, `base-helpers.ps1`) were created in the session scratchpad only.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each `It` builds its own input string and calls a pure function; the only shared state is the dot-sourced function definitions in the per-surface `BeforeAll`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One input per `It`; the data-driven operator case uses `-ForEach` with one operator per expansion. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pure string scanning; no process, filesystem write, or network access. The 297-test reviewer rerun completed well inside the tool timeout. |
| **Determinism** - Consistent results | ✅ PASS | No clock, RNG, environment variable, or git state is read. Newline fixture uses `[char]10`. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange/Act/Assert comments, descriptive `It` names, `-Because` text on the principal assertions. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** 97.04% lines (164/169) for each canonical helper copy<br>**Command:** R-COV (PoshQC Pester, CodeCoverage.Path = both canonical copies)<br>**Timestamp:** 2026-09-27 (P0-T6)<br>**Artifact:** `evidence/baseline/p0-scoped-coverage.md` |
| **No Coverage Regression** | ✅ PASS | **Post-change:** 97.08% lines (166/171) per canonical copy<br>**Change:** +0.04% lines<br>**Missed lines:** 357, 406, 412, 464, 481 before and after; none is a changed line. Reviewer re-parsed `artifacts/pester/powershell-coverage.xml` and obtained the same counts. |
| **New Code Coverage** (policy: >= 85% line, uniform tier rule) | ✅ PASS | **Changed executable lines:** 76 and 78 in each canonical copy<br>**Coverage:** 100% (line 76 ci=1, line 78 ci=4 in the JaCoCo artifact)<br>**Method:** JaCoCo `<line nr>` entries for the post-image changed lines. |
| **Comprehensive Coverage** | ✅ PASS | `Split-OrchestrationCommandLine`: 19 direct cases x 2 surfaces; `Test-ExemptOrchestrationStagingCommand`: 2 cases x 2 surfaces plus 119 + 119 existing CommandExemption tests. |
| **Positive Flows** - Valid inputs | ✅ PASS | Escaped `;`, `&`, `|`, backslash-newline, exempt commit with escaped semicolon. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Chained command after escaped backslash is not exempt; unescaped operators still split. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `\\;`, `\\\;`, `\&&`, trailing lone backslash, empty string, backslash inside single and double quotes, unquoted `\"`. |
| **Error Handling** - Error paths | N/A | The function has no error path; it returns a hashtable. No error handling was added. |
| **Concurrency** - If applicable | N/A | Pure single-threaded string scanning. |
| **State Transitions** - If applicable | ✅ PASS | The scanner is a small state machine (quote state, escape state); tests cover escape-to-literal, escape-in-single-quote (no transition), escape-in-double-quote, and escape pairing. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 97.04% lines per canonical helper copy (repo-wide 95.97% lines, derived) -> Post-change: 97.08% lines per canonical helper copy (repo-wide 95.97% lines from `artifacts/pester/powershell-coverage.xml`, 10034 of 10455). Change: +0.04% lines per copy; repo-wide change below 0.01%. New/changed-code coverage: 100% (2 of 2 changed executable lines per canonical copy). Disposition: PASS. Evidence: `evidence/baseline/p0-scoped-coverage.md`, `evidence/qa-gates/final-scoped-coverage.md`, `evidence/qa-gates/final-coverage-delta.md`, `artifacts/pester/powershell-coverage.xml`.

Repo-wide baseline derivation: the executor did not record a repo-wide PowerShell baseline figure. The only production executable-line delta on the branch is +2 covered lines in each of the two measured canonical copies, so the base repo-wide figure is 10030 of 10451 = 95.97%. Both base and post values exceed the 85% line threshold. PowerShell has no branch-coverage gate (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`).

Coverage denominator note: the two `extensions/drm-copilot/resources/...` mirror copies are not in the Pester `CodeCoverage.Path` (0 occurrences in the JaCoCo artifact). This is pre-existing configuration, not an `exclude` entry added by this branch, and the mirrors are byte-identical to the measured canonical copies (SHA256 recomputed during review). Recorded as informational in the code review.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `Should -Be ... -Because '<reason>'` on segment counts; `Should -BeExactly` on segment text. The fail-before run produced one named failure per case per surface. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | `# Arrange`, `# Act`, `# Assert` comments in every `It` (data-driven and empty-input cases omit Arrange because the input is inline). |
| **Document Intent** | ✅ PASS | File header comment states purpose, the two surfaces, and that bundled copies are covered by the Parity suite. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, no git, no child process, no gitignored state, no `origin/main` ref. Helper files are read by dot-source only. |
| **Use Mocks/Stubs** | N/A | Pure functions; no mocks needed. |
| **Environment Stability** | ✅ PASS | Paths resolved from `$PSScriptRoot` with `Join-Path`; no temporary files; no Windows-only filesystem path (`evidence/qa-gates/test-portability-inspection.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document. Outstanding item: CI PoshQC Pester run on the PR (AC-8), which cannot occur until the PR is opened. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` (#710), `spec.md` Context and Root Cause Analysis. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md`, `evidence/baseline/p0-feature-documents-read.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-09-26T22-56.md` (three preflight revisions recorded in commits `6b8ce59c`, `18afd3c0`, `b59d74e9`). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One boolean state variable and one guard line; no new function or dependency (spec D1 option A). |
| **Reusability** | ✅ PASS | Semantics mirror `Read-CommandLineSegment` in `.claude/hooks/hook-command-scanner.ps1` without adding a cross-file dependency to a self-contained module (spec D1 rationale). |
| **Extensibility** | ✅ PASS | Function signature and return shape unchanged. |
| **Separation of concerns** | ✅ PASS | Change confined to the pure scanner; tokenizer and operand normalization untouched (`evidence/qa-gates/scope-boundary.md`). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | No module boundaries changed. |
| **Under 500 lines** | ✅ PASS | Helper copies: 497 lines each (base 497, recomputed). New test file: 198 lines. |
| **Public vs internal** | ✅ PASS | No new public surface. |
| **No circular dependencies** | ✅ PASS | No new dot-source or import. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `$escaped`. |
| **Docs/docstrings** | ✅ PASS | `.DESCRIPTION` updated to state POSIX backslash escapes and cite #710. |
| **Comment why, not what** | ✅ PASS | Help text states the reason (escaped operator does not split). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCFormat -Root <WORKSPACE_ROOT>`<br>**Result:** 0 formatted, 530 already formatted, porcelain unchanged (`evidence/qa-gates/final-poshqc-format.md`). |
| **2. Linting** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root <WORKSPACE_ROOT>`<br>**Result:** `PSScriptAnalyzer passed: no findings` (`evidence/qa-gates/final-poshqc-analyze.md`). |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root <WORKSPACE_ROOT>`<br>**Result:** 5235 passed, 0 failed, 9 skipped; JUnit 5244 tests, 0 failures, 0 errors (`evidence/qa-gates/final-pester-full.md`). |
| **Full toolchain loop** | ✅ PASS | Pass 2 met every stage with no tracked-file change; pass 1 artifacts retained as `*.pass-1.md` (`evidence/qa-gates/final-seven-stage-loop.md`). |
| **Explicit reporting** | ✅ PASS | Commands and exit codes recorded per evidence file; commit `3fd0c454` message summarizes the change. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `3fd0c454` body; `evidence/other/commits.md`. |
| **Design choices explained** | ✅ PASS | `spec.md` D1-D9. |
| **Update supporting documents** | ✅ PASS | Spec AC check-offs; follow-up record `evidence/other/follow-up-d7-operand-gap.md`. |
| **Provide next steps** | ✅ PASS | D7 follow-up filing and #713 notice recorded (`evidence/other/sibling-713-line-count-notice.md`). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root .`<br>**Result:** no file rewritten. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-PoshQCAnalyze -Root .`<br>**Result:** no findings. |
| **Fix all findings** | ✅ PASS | No findings to fix. |
| **PowerShell 7+ compatible** | ✅ PASS | Helpers are PowerShell 7+ by design (spec Constraints); test declares `#Requires -Version 7.0`. The added line uses only `-eq`, `-ne`, `-or`, `-not`, `StringBuilder.Append`. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `Split-OrchestrationCommandLine` retains its existing `CmdletBinding`/`OutputType` declarations (unchanged). |
| **Parameter validation** | ✅ PASS | Parameter block unchanged. |
| **Avoid global state** | ✅ PASS | `$escaped` is function-local. |
| **Error handling** | N/A | No error path added or changed. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 497 / 497 / 497 / 497 and 198. |
| **Approved verbs** | ✅ PASS | No new functions. |
| **Comment why** | ✅ PASS | Help text updated. The added guard is a single-line compound statement (four statements on line 76) chosen to hold the net-zero line delta; noted as a readability Nit in the code review. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 2.5. |
| **Step 2: Analyze** | ✅ PASS | See 2.5. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | See 2.5; reviewer rerun 297/297. |
| **Rerun loop if needed** | ✅ PASS | Two passes; pass 1 stopped at the push-down step and pass 2 completed with no code change between passes. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `Describe -ForEach`, `BeforeAll`, `It -ForEach`, `Should -BeExactly`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (unchanged; `CodeCoverage.Path` already lists both canonical copies). |
| **PowerShell 7+ Compatible** | ✅ PASS | Suite requires 7.0; CI PoshQC job runs PowerShell 7 on `windows-latest`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 17 scanner cases, 2 entry-predicate cases, each run against 2 surfaces. |
| **Test Behavior Over Implementation** | ✅ PASS | Assertions are on segment count, segment text, `Balanced`, and exemption result; no assertion on internal variables. |
| **Mocking Used Sparingly** | ✅ PASS | No mocks. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`<br>**Code file:** `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and `.codex/hooks` copy)<br>Follows the existing `tests/scripts/claude-hooks/` mirror for `.claude/hooks/`, alongside the existing `...helpers.Parity.Tests.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `...ChainEscape.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 `Describe` (x2 surfaces), 15 `It` blocks, one with 5 data rows: 19 cases per surface, 38 total. |
| **Logical Grouping** | ✅ PASS | Grouped by surface via `Describe -ForEach`. |
| **Docstrings/Comments** | ✅ PASS | File header comment; `-Because` text. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCTest -Root .`<br>**Result:** full run green (see 2.5). |
| **No Alternative Test Runners** | ✅ PASS | Pester only. The reviewer rerun used `Invoke-Pester` with a `New-PesterConfiguration` scoped to five suites, as a check-only confirmation. |

---

## 5. Test Coverage Detail

### Split-OrchestrationCommandLine (34 tests: 17 cases x 2 surfaces)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| treats a mid-line escaped semicolon as literal | Positive | 76, 78 onward | ✅ |
| treats an escaped ampersand as literal | Positive | 76, 78 | ✅ |
| treats an escaped pipe as literal | Positive | 76, 78 | ✅ |
| treats backslash-newline as a line continuation | Edge Case | 76, 78 | ✅ |
| still splits on unescaped operator (5 rows: semicolon, double ampersand, double pipe, pipe, ampersand) | Negative (no over-escaping) | 78 and operator branch | ✅ |
| still splits after an escaped backslash | Edge Case (no bypass) | 78 | ✅ |
| does not split after an odd run of backslashes | Edge Case | 78 | ✅ |
| splits on the unescaped ampersand after an escaped one | Edge Case (no bypass) | 78 | ✅ |
| keeps backslash literal inside single quotes | Edge Case | 78 (guard false) | ✅ |
| consumes an escaped double quote inside double quotes | Edge Case | 78 | ✅ |
| does not open a quote on an unquoted escaped double quote | Edge Case | 78 | ✅ |
| treats a trailing lone backslash as balanced | Edge Case | 78 | ✅ |
| returns no segments for an empty command | Edge Case | 76 | ✅ |

**Coverage:** 97.08% of the helper file (166/171); the two changed executable lines are covered.

**Not covered:** lines 357, 406, 412, 464, 481 (pre-existing, outside the changed function, unchanged by this branch).

### Test-ExemptOrchestrationStagingCommand (4 tests: 2 cases x 2 surfaces)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| exempts a commit whose message contains an escaped semicolon | Positive | 473 onward | ✅ |
| does not exempt a chained command after an escaped backslash | Negative | 473 onward | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full run, JUnit) | 5244 | ✅ |
| Tests Passed | 5235 (9 skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| New suite | 38 tests, 0 failures | ✅ |
| Reviewer rerun (ChainEscape, Parity, 2x CommandExemption, EpicScope) | 297 passed, 0 failed | ✅ |
| Fail-before (base helpers) | 16 failed, 22 passed, as planned | ✅ |
| Test File Size | 198 lines | ✅ |
| Code Coverage | 97.08% lines per canonical helper copy; PowerShell has no branch metric | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat -Root .` | 0 formatted / 530 already formatted | ✅ |
| PSScriptAnalyzer | `Invoke-PoshQCAnalyze -Root .` | no findings | ✅ |
| Pester Tests | `Invoke-PoshQCTest -Root .` | 5235 passed, 0 failed | ✅ |
| Mirror parity | SHA256 of four copies | all `ebe15355...9c6f7a` | ✅ |

**Notes:**
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` reports 1 failed, 13 passed. The failing node names a gitignored `.claude/state/powershell-batch-budget.*.json` file, which is the known local-only issue #510 (`evidence/qa-gates/final-pytest-push-down.md`). No Python file changed on the branch.

---

## 8. Gaps and Exceptions

### Identified Gaps
- CI PoshQC Pester run (AC-8): no PR exists yet, and `ci.yml` triggers on pull requests into `main`, so no CI run against the branch head is observable. This is a delivery gate for the orchestrator S9 CI check, not a policy defect.
- Shell-dialect assumption (code review, Major, non-blocking): the new escape rule models POSIX shells. If the Codex `Bash` tool executes commands through PowerShell on Windows, a crafted `\;` input can now be exempted where the base denied it. Recommended as a follow-up issue.
- `quality-tiers.yml` is absent at the repository root (pre-existing; spec D9 applied uniform gates only).

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
**None.** All planned tests implemented. The 9 skipped tests in the full run are pre-existing and unrelated to this branch.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **0ab3b6b4** - docs(bug): create active folder for #710 backslash chain operator
2. **457e4494** - docs(bug): add #710 research on backslash escape handling
3. **775b4c3e** - docs(bug): add #710 spec with design decisions D1-D9
4. **95c076d7** - docs(bug): add #710 atomic plan
5. **6b8ce59c** - docs(bug): revise #710 plan per preflight round 1
6. **18afd3c0** - docs(bug): revise #710 plan per preflight round 2
7. **b59d74e9** - docs(bug): revise #710 plan per preflight round 3
8. **3fd0c454** - fix(hooks): treat backslash-escaped chain operators as literals (#710)
9. **61e38a0c** - docs(bug): record #710 evidence and acceptance-criteria check-offs
10. **928a8b7e** - docs(bug): record #710 evidence commit in the commits log
11. **e5c7a223** - docs(bug): check off #710 plan task P6-T13

### Files Modified

1. **`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`** (MODIFIED)
   - `Split-OrchestrationCommandLine`: `$escaped` state and escape guard; `.DESCRIPTION` condensed. Net line delta 0.
2. **`.codex/hooks/...helpers.ps1`**, **`extensions/.../.claude/hooks/...helpers.ps1`**, **`extensions/.../.codex/hooks/...helpers.ps1`** (MODIFIED)
   - Byte copies of item 1.
3. **`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`** (NEW)
   - 19 cases per surface, 38 tests.
4. **`docs/features/active/preimplementation-helpers-backslash-chain-operator-710/**`** (NEW)
   - Issue, spec, research, plan, and evidence.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All policy sections evaluated for the in-scope language (PowerShell) pass with numeric baseline and post-change coverage. No Blocking finding exists. The CI run required by AC-8 is outstanding by construction (no PR yet) and is tracked in the feature audit.

**Fail-closed reminder:** every required baseline artifact, QA artifact, coverage metric, and coverage-comparison artifact was located and inspected.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plan present
- ✅ Design Principles: minimal state-machine extension
- ✅ Module & File Structure: 497 lines, unchanged
- ✅ Naming, Docs, Comments: help text updated
- ✅ Toolchain Execution: single-pass record
- ✅ Summarize & Document: commit body and evidence

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean
- ✅ PowerShell Design & Safety: function-local state
- ✅ Structure & Naming: under cap
- ✅ Toolchain: complete

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: pure, deterministic tests
- ✅ Coverage & Scenarios: 97.08% lines, changed lines 100%
- ✅ Test Structure: AAA
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- ✅ Framework & Scope: Pester 5
- ✅ Test Style & Structure: behavior-focused
- ✅ Naming & Readability: descriptive names
- ✅ Toolchain: PoshQC

---

### Metrics Summary

- ✅ 5235/5235 executed tests passing (9 skipped, pre-existing)
- ✅ 38/38 new tests passing; 16 of them failed against base as planned
- ✅ 97.08% line coverage per canonical helper copy; repo-wide PowerShell 95.97%
- ✅ Four helper copies byte-identical
- ✅ All code quality checks passing

---

### Recommendation

**Ready for merge** after the CI PoshQC Pester job passes on the PR (AC-8). File the shell-dialect follow-up described in the code review before or alongside merge.

---

## Appendix A: Test Inventory

### Complete Test List

For each surface `S` in (`.claude/hooks`, `.codex/hooks`):

1. preimplementation gate helpers chain escapes (S) › treats a mid-line escaped semicolon as literal
2. › treats an escaped ampersand as literal
3. › treats an escaped pipe as literal
4. › treats backslash-newline as a line continuation
5. › still splits on unescaped ;
6. › still splits on unescaped &&
7. › still splits on unescaped ||
8. › still splits on unescaped |
9. › still splits on unescaped &
10. › still splits after an escaped backslash
11. › does not split after an odd run of backslashes
12. › splits on the unescaped ampersand after an escaped one
13. › keeps backslash literal inside single quotes
14. › consumes an escaped double quote inside double quotes
15. › does not open a quote on an unquoted escaped double quote
16. › treats a trailing lone backslash as balanced
17. › returns no segments for an empty command
18. › exempts a commit whose message contains an escaped semicolon
19. › does not exempt a chained command after an escaped backslash

---

## Appendix B: Toolchain Commands Reference

**Executor-recorded commands (from evidence):**
```powershell
# Formatting
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCFormat -Root .

# Linting
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCAnalyze -Root .

# Testing (full, with coverage to artifacts/pester/powershell-coverage.xml)
Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root .
```

**Reviewer check-only commands (this audit):**
```bash
git diff --stat 2dce111e...HEAD
git diff --name-status 2dce111e...HEAD
git diff 2dce111e...HEAD -- '*.ps1'
git diff --name-only 3fd0c454 HEAD        # confirms only feature-folder docs changed after the fix commit
sha256sum <four helper copies>
wc -l <helper copy> <test file>; git show 2dce111e:<helper copy> | wc -l
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
python -c "<parse artifacts/pester/powershell-coverage.xml LINE counters and <line> entries for lines 76, 78>"
sh review-run.sh   # exec pwsh: Invoke-Pester over ChainEscape, Parity, 2x CommandExemption, EpicScope -> 297 passed, 0 failed
sh probe2.sh / probe3.sh   # exec pwsh: Split-OrchestrationCommandLine and Test-ExemptOrchestrationStagingCommand on head and base helpers
git ls-remote origin refs/heads/bug/preimplementation-helpers-backslash-chain-operator-710
gh pr list --head bug/preimplementation-helpers-backslash-chain-operator-710 --state all   # no PR
gh run list --branch bug/preimplementation-helpers-backslash-chain-operator-710             # no runs
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-27
**Policy Version:** Current (as of audit date)

# Policy Compliance Audit: Host bootstrap installs poetry (Issue #930)

**Audit Date:** 2026-10-16  
**Code Under Test:** `scripts/dev-tools/HostBootstrap.psm1` (modified, +3 lines), `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` (modified, +57 lines)

**Branch:** bug/host-bootstrap-does-not-install-poetry-930, head 4470de936, diff against the merge-base with origin/main. Work mode: minor-audit.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 files | 629 tests | PASS 629 pass, 0 fail | 100.00% lines (154/154) | 100.00% lines (155/155) | 100% (line 369, 1 of 1) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (no TypeScript files in the branch diff)
- TypeScript post-change coverage artifact: N/A - out of scope (no TypeScript files in the branch diff)
- PowerShell baseline coverage artifact: docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/baseline/coverage-hostbootstrap-baseline.2026-10-16T02-45.md
- PowerShell post-change coverage artifact: docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/qa-gates/coverage-hostbootstrap-final.2026-10-16T03-21.md
- Per-language comparison summary: Section 1.2.1 of this audit

**Non-negotiable verdict rule:** numeric baseline and post-change coverage are recorded above for the only language in scope.

---

## Rejected Scope Narrowing

None. The caller prompt did not narrow the audit scope.

## Evidence Location Compliance

`scripts/dev_tools/validate_evidence_locations.py --root .` exited 0. No file in the branch diff is under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/<kind>/`. Result: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries.

---

## Executive Summary

The branch adds one call, `Install-PoetryWithPip -ApplyMode:$Apply`, to `Invoke-BootstrapHost` after the session PATH refresh, and five `AC930-*` Pester tests plus one seam mock. Code and test policies are met. The executor reported 629 tests with 0 failures and 100.00% line coverage for `HostBootstrap.psm1`; the module-level coverage figure was independently confirmed from `artifacts/pester/powershell-coverage.xml` (sourcefile counter: 155 lines covered, 0 missed). The repo-wide PowerShell figure cannot be confirmed locally (see Section 8), which produces one blocking finding with class `awaiting_ci`.

**Policy documents evaluated:**
- PASS `general-code-change` rule
- PASS `general-unit-test` rule

**Language-specific policies evaluated:**
- N/A Python
- PASS PowerShell (`powershell.md`)
- N/A Bash
- N/A JSON (`scripts/host-tools.manifest.json` is unchanged)

Tier classification: not applicable; no `quality-tiers.yml` exists at the repository root.

**Temporary artifacts cleanup:**
- PASS Scratch wrappers live under the untracked `SCRATCH/` folder and are not part of the branch diff.
- PASS No ongoing tooling scripts were added.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Mocks are installed in `BeforeEach`; the ordering test uses a script-scoped list reset in its own Arrange. |
| **Isolation** | PASS | Each of the five tests asserts one behavior of the new call. |
| **Fast Execution** | PASS | All new tests use mocks only; no process or network calls. |
| **Determinism** | PASS | No sleeps or clock reads; fixture path `C:\fixture\repo` is a literal. |
| **Readability & Maintainability** | PASS | Test names carry the `AC930-` identifier and describe the outcome. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline 100.00% lines (154 covered, 0 missed); evidence `coverage-hostbootstrap-baseline.2026-10-16T02-45.md`. |
| **No Coverage Regression** | PASS | Baseline 100.00% to post-change 100.00% (+0.00%); changed line 369 covered. |
| **New Code Coverage** | PASS | One new executable line (369), 1 of 1 covered = 100%, above the 85% threshold. |
| **Comprehensive Coverage** | PASS | The single new statement is exercised by all five tests. |
| **Positive Flows** | PASS | AC930-APPLY-INVOKES-POETRY-INSTALL and AC930-DRYRUN-INVOKES-POETRY-INSTALL. |
| **Negative Flows** | PASS | AC930-POETRY-INSTALL-FAILURE-PROPAGATES. |
| **Edge Cases** | PASS | AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL and AC930-POETRY-INSTALL-ORDER. |
| **Error Handling** | PASS | A throwing mock proves terminating-error propagation and that `Invoke-HostBootstrapPoetry` is not reached. |
| **Concurrency** | N/A | No concurrency in the change. |
| **State Transitions** | N/A | No stateful component in the change. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 100.00% lines -> Post-change: 100.00% lines. Change: +0.00% lines. New/changed-code coverage: 100% (line 369). Disposition: PASS. Evidence: evidence/baseline/coverage-hostbootstrap-baseline.2026-10-16T02-45.md, evidence/qa-gates/coverage-hostbootstrap-final.2026-10-16T03-21.md, evidence/qa-gates/coverage-delta.2026-10-16T03-22.md.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `Should -Invoke` with `-ParameterFilter` and `-BeExactly` on the joined call order give specific failures. |
| **Arrange-Act-Assert Pattern** | PASS | Each new test carries Arrange/Act/Assert comments. |
| **Document Intent** | PASS | Descriptive `It` names under a new `Context 'poetry tool install'`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No filesystem, network, or process access in the new tests. |
| **Use Mocks/Stubs** | PASS | `Install-PoetryWithPip` is mocked in `BeforeEach`; ordering and failure tests re-mock it locally. |
| **Environment Stability** | PASS | No temporary files created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit serves as the review; one CI-dependent item remains (Section 8). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #930, AC-1..AC-11 in issue.md. |
| **Read existing change plans** | PASS | Research artifact `research/research.2026-10-15T15-50.md`. |
| **Document the plan** | PASS | `plan.2026-10-15T15-45.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Three lines added; no new function. |
| **Reusability** | PASS | Reuses the existing `Install-PoetryWithPip`. |
| **Extensibility** | PASS | Passes `-ApplyMode:$Apply` using the existing keyword parameter. |
| **Separation of concerns** | PASS | Installation logic stays in `Install-PoetryWithPip`; the orchestrator only sequences. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Change is confined to the bootstrap orchestrator and its test file. |
| **Under 500 lines** | PASS | Module 465 lines; test file 348 lines (`wc -l`, matches `line-counts-final`). |
| **Public vs internal** | PASS | No export change. |
| **No circular dependencies** | PASS | No new module imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Test identifiers are descriptive. |
| **Docs/docstrings** | PASS | No new function. |
| **Comment why, not what** | PASS | The added comment states why the call follows the PATH refresh. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Formatter run recorded in `qa-gates/format-check.2026-10-16T02-54.md`: no rewrite. |
| **2. Linting** | PASS | Analyzer: 0 findings on module and test file (`analyzer-hostbootstrap`, `analyzer-invoke-tests`). |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | PASS | 629 tests, 0 failures, 0 errors (`pester-run-final`). |
| **Full toolchain loop** | PASS | One restart (PSReviewUnusedParameter at the ordering-test mock, fixed with `$null = $ApplyMode`); final pass clean (`clean-pass-confirmation`). |
| **Explicit reporting** | PASS | Each stage has an evidence artifact. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Plan and reduced-audit handoff. |
| **Design choices explained** | PASS | Adopted approach stated in issue.md `## Acceptance Criteria`. |
| **Update supporting documents** | PASS | issue.md AC-1..AC-10 checked. |
| **Provide next steps** | PASS | AC-11 pending CI (`ac11-pending-ci`). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | Inline formatter route; zero rewrite. |
| **Linting with PSScriptAnalyzer** | PASS | 0 findings on both files. |
| **Fix all findings** | PASS | The one analyzer finding raised during the loop was fixed. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Change uses only a switch-argument call; no version-specific syntax. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | No new function. |
| **Parameter validation** | N/A | No new parameters. |
| **Avoid global state** | PASS | Test list uses `$script:` scope only. |
| **Error handling** | PASS | Failures propagate without a catch-all. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 465 and 348 lines. |
| **Approved verbs** | PASS | No new functions. |
| **Comment why** | PASS | Added comment explains ordering rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | See 2.5. |
| **Step 2: Analyze** | PASS | See 2.5. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | 629/0/0. |
| **Rerun loop if needed** | PASS | One restart, then a clean single pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe/Context/It`, `Mock -ModuleName`, `Should -Invoke`. |
| **Use PoshQC Configuration** | PASS | Self-hosted PoshQC module run; MCP test call recorded as a disposition only (it returns no counts). |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | Standard Pester 5 syntax. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | Five tests, one behavior each. |
| **Test Behavior Over Implementation** | PASS | Tests assert call count, parameter state, order, and error propagation. |
| **Mocking Used Sparingly** | PASS | Only the seam function and (in one test) `Set-HostEnvironmentVariable` and `Invoke-HostBootstrapPoetry`. |
| **Organization** | PASS | Test file `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` mirrors code file `scripts/dev-tools/HostBootstrap.psm1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | PASS | Existing `.Tests.ps1` file. |
| **Describe/Context/It Structure** | PASS | New `Context 'poetry tool install'` with five `It` blocks. |
| **Logical Grouping** | PASS | Grouped in one Context. |
| **Docstrings/Comments** | PASS | AAA comments in each test. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Self-hosted module run; see `pester-run-final`. |
| **No Alternative Test Runners** | PASS | Pester only. |

---

## 5. Test Coverage Detail

### Invoke-BootstrapHost poetry tool install call (5 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| AC930-APPLY-INVOKES-POETRY-INSTALL | Positive | 369 | PASS |
| AC930-DRYRUN-INVOKES-POETRY-INSTALL | Positive | 369 | PASS |
| AC930-POETRY-INSTALL-ORDER | Edge Case | 365-369 | PASS |
| AC930-POETRY-INSTALL-FAILURE-PROPAGATES | Error Handling | 369 | PASS |
| AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL | Edge Case | 369 | PASS |

**Coverage:** 100% of the new line (369); module-level 155/155 lines (verified in `artifacts/pester/powershell-coverage.xml`, sourcefile counter).

**Not covered:** None in `HostBootstrap.psm1`.

**Repo-wide:** The on-disk artifact reports 1494 covered and 16623 missed lines for the whole coverage population (about 8.25%), because the final run was scoped to `tests/scripts/dev-tools` while the population spans every declared root. This is not a valid repo-wide measure. Disposition: FAIL as measured, deferred to CI (Section 8). Branch coverage: Pester does not measure branch coverage, so no branch threshold applies.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 629 (624 baseline plus 5) | PASS |
| Tests Passed | 629 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | not recorded in evidence | not applicable |
| Functions/Classes Tested | 1/1 changed function | PASS |
| Test File Size | 348 lines | PASS |
| Code Coverage (HostBootstrap.psm1) | 100.00% lines; no branch measure | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | inline formatter route | zero rewrite | PASS |
| PSScriptAnalyzer | inline analyzer route | 0 findings, both files | PASS |
| Pester Tests | inline Pester run with coverage | 629 pass, 0 fail | PASS |

**Notes:** Evidence files `phase0-instructions-read`, `phase1-handoff`, and `reduced-audit-handoff` are documentary records with no command executed, so Command and EXIT_CODE fields do not apply (28 of 31 evidence files carry all four fields). The expect-fail artifact records wrapper EXIT_CODE 0 and states that the child Pester exit code was 5 with FAILURES=5. The MCP test disposition records the call result without counts and asserts none. No absolute host paths appear in the feature folder (grep for drive-letter, `/c/Users`, `/mnt/c`, `/home/` patterns returned no matches). The plan checklist entries reviewed are all `[x]` and each cited artifact exists.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **Repo-wide PowerShell coverage and AC-11 are not verifiable locally (blocking, class awaiting_ci).** The only on-disk coverage artifact comes from a scoped test run and reports about 8.25% repo-wide lines, which is not a representative figure. The `poshqc / PowerShell QC` CI job on the PR head produces the full-population figure. No code change is indicated.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **87e849160** - docs(930): Phase 0 baseline evidence (P0-T1..P0-T3)
2. **4d4dcd83e** - docs(930): revise plan to v1.6
3. **10694bb74** - docs(930): Phase 0 complete, baseline evidence
4. **6c7db8c1d** - fix(930): install poetry in Invoke-BootstrapHost, add tests, Phase 1 evidence
5. **4470de936** - test(930): Phase 2 final QC, analyzer fix, AC-1..AC-10 checked

### Files Modified

1. **scripts/dev-tools/HostBootstrap.psm1** (MODIFIED)
   - Adds `Install-PoetryWithPip -ApplyMode:$Apply` after the session PATH refresh.
2. **tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1** (MODIFIED)
   - Adds the seam mock and five `AC930-*` tests.
3. **docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/** (NEW)
   - issue.md, plan, research, and 31 evidence files.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

All code, test, toolchain, and evidence policies are met. One CI-dependent gap (repo-wide coverage, AC-11) remains and is classified awaiting_ci.

**Fail-closed reminder:** the repo-wide coverage figure is the only coverage artifact that cannot be confirmed locally.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios (module level); repo-wide deferred to CI
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 629/629 tests passing (100%)
- PASS 100.00% line coverage for `HostBootstrap.psm1`; 100% for the new line
- PASS Test file organization mirrors source
- PASS All code quality checks passing, single clean final pass
- FAIL (awaiting_ci) repo-wide PowerShell coverage not locally measurable

---

### Recommendation

**Blocked on CI only.** Open or update the PR, let the `poshqc / PowerShell QC` job run on the PR head, then check off AC-11 at the CI gate. Review-Verdict: AWAITING_CI.

---

## Appendix A: Test Inventory

1. Invoke-BootstrapHost > poetry tool install > AC930-APPLY-INVOKES-POETRY-INSTALL
2. Invoke-BootstrapHost > poetry tool install > AC930-DRYRUN-INVOKES-POETRY-INSTALL
3. Invoke-BootstrapHost > poetry tool install > AC930-POETRY-INSTALL-ORDER
4. Invoke-BootstrapHost > poetry tool install > AC930-POETRY-INSTALL-FAILURE-PROPAGATES
5. Invoke-BootstrapHost > poetry tool install > AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL

---

## Appendix B: Toolchain Commands Reference

**For PowerShell:**
```powershell
# Formatting, linting, and testing were run through the inline PoshQC-equivalent routes
# recorded in evidence/qa-gates/ (Invoke-Formatter, Invoke-ScriptAnalyzer, Invoke-Pester with coverage).
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-10-16  
**Policy Version:** Current (as of audit date)

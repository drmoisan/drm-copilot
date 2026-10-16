# Policy Compliance Audit: Host bootstrap installs poetry (Issue #930), remediation cycle 1 re-audit

**Audit Date:** 2026-10-16  
**Code Under Test:** `scripts/dev-tools/HostBootstrap.psm1` (modified, +3 lines), `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` (modified, +57 lines)

**Branch:** bug/host-bootstrap-does-not-install-poetry-930, head 9d435452f56f6a4e2b8e8eefaf01c41f4400c64a, diff against the merge-base with origin/main. Work mode: minor-audit. Supersedes the 2026-10-16T03-25 audit.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 files | 10371 tests (CI), 629 in the scoped local run | PASS 0 fail | 100.00% lines (154/154) | 100.00% lines (155/155) | 100% (line 369, 1 of 1) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (no TypeScript files in the branch diff)
- TypeScript post-change coverage artifact: N/A - out of scope (no TypeScript files in the branch diff)
- PowerShell baseline coverage artifact: docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/baseline/coverage-hostbootstrap-baseline.2026-10-16T02-45.md
- PowerShell post-change coverage artifact: docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/qa-gates/coverage-hostbootstrap-final.2026-10-16T03-21.md
- PowerShell repo-wide evidence: CI run https://github.com/drmoisan/drm-copilot/actions/runs/38854540823/job/116822953636 (`poshqc / PowerShell QC`, windows-latest, success)
- Per-language comparison summary: Section 1.2.1 of this audit

**Non-negotiable verdict rule:** numeric baseline, post-change, and repo-wide coverage are recorded above for the only language in scope.

---

## Rejected Scope Narrowing

None. The caller prompt did not narrow the audit scope. The caller asked for an independent re-evaluation of the full branch diff, which is the scope applied.

## Evidence Location Compliance

No file in the branch diff (`git diff --name-only origin/main...HEAD`) is under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/<kind>/`. Result: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries. The branch diff contains no path under `SCRATCH/`, `.claude/`, or `scripts/host-tools.manifest.json`.

---

## Executive Summary

The branch adds one call, `Install-PoetryWithPip -ApplyMode:$Apply`, to `Invoke-BootstrapHost` after the session PATH refresh, plus five `AC930-*` Pester tests and one seam mock. Code, test, and coverage policies are met. The prior blocking finding (AC-11 and repo-wide coverage awaiting CI) is resolved: all 17 checks on PR #950 report pass (`gh pr checks 950`), including `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.

The three evidence files named in remediation cycle 1 (`baseline/phase0-instructions-read`, `other/phase1-handoff`, `other/reduced-audit-handoff`) now carry Timestamp, Command, EXIT_CODE, and Output Summary. A scan of all 44 files under `evidence/` found one remaining file that lacks Command, EXIT_CODE, and Output Summary: `other/rem1-phase0-instructions-read.2026-10-16T04-53.md`, which was created by the remediation cycle itself. This is one blocking finding of class autonomous (Section 8).

**Policy documents evaluated:**
- PASS `general-code-change` rule
- PASS `general-unit-test` rule
- PARTIAL evidence-and-timestamp-conventions schema (one file)

**Language-specific policies evaluated:**
- N/A Python
- PASS PowerShell (`powershell.md`)
- N/A Bash
- N/A JSON (`scripts/host-tools.manifest.json` is unchanged)

Tier classification: not applicable; no `quality-tiers.yml` exists at the repository root.

**Temporary artifacts cleanup:**
- PASS `SCRATCH/` is untracked and absent from the branch diff.
- PASS No ongoing tooling scripts were added.
- PASS No `.claude/` path is in the branch diff.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Mocks are installed in `BeforeEach`; the ordering test resets its script-scoped list in its own Arrange. |
| **Isolation** | PASS | Each of the five tests asserts one behavior of the new call. |
| **Fast Execution** | PASS | Mocks only; no process or network calls. |
| **Determinism** | PASS | No sleeps or clock reads; fixture path `C:\fixture\repo` is a literal. |
| **Readability & Maintainability** | PASS | Test names carry the `AC930-` identifier and describe the outcome. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | 100.00% lines (154/154); `coverage-hostbootstrap-baseline.2026-10-16T02-45.md`. |
| **No Coverage Regression** | PASS | 100.00% to 100.00%; changed line 369 covered. |
| **New Code Coverage** | PASS | One new executable line (369), 1 of 1 covered, above 85%. |
| **Repo-wide Coverage** | PASS | CI job `poshqc / PowerShell QC` succeeded; its log reports "Covered 89.61% / 0%. 26,457 analyzed Commands in 203 Files" with 10371 tests passed, 0 failed, 10 skipped. See the caveat in Section 5. |
| **Positive Flows** | PASS | AC930-APPLY-INVOKES-POETRY-INSTALL, AC930-DRYRUN-INVOKES-POETRY-INSTALL. |
| **Negative Flows** | PASS | AC930-POETRY-INSTALL-FAILURE-PROPAGATES. |
| **Edge Cases** | PASS | AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL, AC930-POETRY-INSTALL-ORDER. |
| **Error Handling** | PASS | A throwing mock proves propagation and that `Invoke-HostBootstrapPoetry` is not reached. |
| **Concurrency** | N/A | No concurrency in the change. |
| **State Transitions** | N/A | No stateful component in the change. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 100.00% lines -> Post-change: 100.00% lines. Change: +0.00% lines. New/changed-code coverage: 100% (line 369). Repo-wide (CI): 89.61% command coverage. Disposition: PASS. Evidence: evidence/baseline/coverage-hostbootstrap-baseline.2026-10-16T02-45.md, evidence/qa-gates/coverage-hostbootstrap-final.2026-10-16T03-21.md, evidence/qa-gates/coverage-delta.2026-10-16T03-22.md, CI run 38854540823.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `Should -Invoke` with `-ParameterFilter` and `-BeExactly` on the joined call order. |
| **Arrange-Act-Assert Pattern** | PASS | Each new test carries Arrange/Act/Assert comments. |
| **Document Intent** | PASS | Descriptive `It` names under `Context 'poetry tool install'`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No filesystem, network, or process access in the new tests. |
| **Use Mocks/Stubs** | PASS | `Install-PoetryWithPip` is mocked in `BeforeEach`; ordering and failure tests re-mock it locally. |
| **Environment Stability** | PASS | No temporary files created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PARTIAL | One evidence-schema defect remains (Section 8). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #930, AC-1..AC-11 in issue.md. |
| **Read existing change plans** | PASS | `research/research.2026-10-15T15-50.md`. |
| **Document the plan** | PASS | `plan.2026-10-15T15-45.md`, `remediation-plan.2026-10-16T04-12.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Three lines added; no new function. |
| **Reusability** | PASS | Reuses the existing `Install-PoetryWithPip`. |
| **Extensibility** | PASS | Uses the existing keyword parameter `-ApplyMode`. |
| **Separation of concerns** | PASS | Installation logic stays in `Install-PoetryWithPip`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Change is confined to the bootstrap orchestrator and its test file. |
| **Under 500 lines** | PASS | `wc -l`: module 465, test file 348. |
| **Public vs internal** | PASS | No export change. |
| **No circular dependencies** | PASS | No new imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Test identifiers are descriptive. |
| **Docs/docstrings** | PASS | No new function. |
| **Comment why, not what** | PASS | The added comment states why the call follows the PATH refresh. |
| **Tonality** | PASS | Grep of the feature folder for hyperbolic terms returned no matches; artifacts use factual wording. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `qa-gates/format-check.2026-10-16T02-54.md`: no rewrite. |
| **2. Linting** | PASS | 0 analyzer findings on both files. |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | PASS | 629 local tests, 0 failures; CI 10371 passed, 0 failed. |
| **Full toolchain loop** | PASS | One restart, final pass clean (`clean-pass-confirmation`). |
| **Explicit reporting** | PASS | Each stage has an evidence artifact. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Plan and reduced-audit handoff. |
| **Design choices explained** | PASS | Adopted approach stated in issue.md. |
| **Update supporting documents** | PASS | issue.md AC-1..AC-11 checked. |
| **Evidence schema fields** | PARTIAL | 43 of 44 evidence files carry all four fields; see Section 8. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | Zero rewrite. |
| **Linting with PSScriptAnalyzer** | PASS | 0 findings. |
| **Fix all findings** | PASS | The one finding during the loop was fixed. |
| **PowerShell 5.1 & 7.6+ compatible** | PASS | Switch-argument call only. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | No new function. |
| **Parameter validation** | N/A | No new parameters. |
| **Avoid global state** | PASS | Test list uses `$script:` scope. |
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
| **Step 4: Test** | PASS | 629/0 local; CI green. |
| **Rerun loop if needed** | PASS | One restart, then a clean pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe/Context/It`, `Mock -ModuleName`, `Should -Invoke`. |
| **Use PoshQC Configuration** | PASS | PoshQC run in CI and self-hosted locally. |
| **PowerShell 5.1 & 7.6+ Compatible** | PASS | Standard Pester 5 syntax. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | Five tests, one behavior each. |
| **Test Behavior Over Implementation** | PASS | Call count, parameter state, order, error propagation. |
| **Mocking Used Sparingly** | PASS | Seam function plus two collaborators in the ordering test. |
| **Organization** | PASS | Test file mirrors the code file path. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | PASS | Existing `.Tests.ps1` file. |
| **Describe/Context/It Structure** | PASS | New Context with five `It` blocks. |
| **Logical Grouping** | PASS | One Context. |
| **Docstrings/Comments** | PASS | AAA comments in each test. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Self-hosted module run and CI. |
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

**Coverage:** 100% of the new line (369); module-level 155/155 lines.

**Not covered:** None in `HostBootstrap.psm1`.

**Repo-wide:** The CI Pester step logged "Covered 89.61% / 0%. 26,457 analyzed Commands in 203 Files" (command coverage; the configured Pester target is 0%, so the log line itself is not a gate). The CI job concluded success. The log reviewed does not print an explicit repo-wide line percentage; the 89.61% command figure exceeds the 85% default line threshold and the module under change is at 100%. Disposition: PASS, with the caveat recorded as an observation. Branch coverage: Pester does not measure branch coverage, so no branch threshold applies.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (local scoped) | 629 (624 baseline plus 5) | PASS |
| Tests Failed (local) | 0 | PASS |
| Total Tests (CI, full suite) | 10371 passed, 0 failed, 10 skipped | PASS |
| Test File Size | 348 lines | PASS |
| Code Coverage (HostBootstrap.psm1) | 100.00% lines; no branch measure | PASS |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | inline formatter route | zero rewrite | PASS |
| PSScriptAnalyzer | inline analyzer route | 0 findings, both files | PASS |
| Pester Tests | inline Pester run with coverage; CI poshqc job | 629 pass local; 17 of 17 CI checks pass | PASS |

**Notes:** Evidence schema scan (Timestamp, Command, EXIT_CODE, Output Summary) over 44 files in `evidence/`: 43 carry all four fields, including the three files fixed in cycle 1 (`phase0-instructions-read`, `phase1-handoff`, `reduced-audit-handoff`; verified by reading each). `other/rem1-phase0-instructions-read.2026-10-16T04-53.md` carries Timestamp only. No hyperbolic wording was found in the feature folder.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **Evidence file lacks schema fields (blocking, class autonomous).** `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md` has Timestamp but no Command, EXIT_CODE, or Output Summary. This is the same defect class that cycle 1 corrected in three other files, and the standard applied by remediation-inputs.2026-10-16T04-12.md. The fix is a documentation edit inside the feature folder.

Resolved since the prior audit: AC-11 and repo-wide PowerShell coverage (CI run 38854540823 succeeded).

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None.** All planned tests implemented.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. Earlier feature commits (87e849160 through 4470de936): baseline evidence, plan revisions, the fix, tests, and final QC.
2. **d6543c1ff** - docs(930): record remediation cycle 1 inputs
3. **6103f3479** - docs(930): add remediation cycle 1 plan
4. **8ec75b093** - docs(930): revise remediation cycle 1 plan per preflight
5. **9d435452f** - docs(930): add schema fields to three evidence files (remediation cycle 1)

### Files Modified

1. **scripts/dev-tools/HostBootstrap.psm1** (MODIFIED): adds `Install-PoetryWithPip -ApplyMode:$Apply` after the session PATH refresh.
2. **tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1** (MODIFIED): adds the seam mock and five `AC930-*` tests.
3. **docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/** (NEW): issue, plans, research, review artifacts, and 44 evidence files.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Code, test, toolchain, and coverage policies are met and CI is green. One evidence-schema gap (autonomous) remains.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments (including tonality)
- PASS Toolchain Execution
- PARTIAL Summarize & Document (one evidence file lacks schema fields)

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios, including repo-wide via CI
- PASS Test Structure
- PASS External Dependencies
- PARTIAL Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 629/629 local tests, CI 10371 passed and 0 failed
- PASS 100.00% line coverage for `HostBootstrap.psm1`; 100% for the new line
- PASS Repo-wide CI job success, 89.61% command coverage logged
- PASS Test file organization mirrors source
- FAIL (autonomous) one evidence file lacks Command, EXIT_CODE, and Output Summary

---

### Recommendation

Add Command, EXIT_CODE, and Output Summary to the one evidence file named in Section 8, then re-run the review. Review-Verdict: REMEDIATION_REQUIRED.

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
# recorded in evidence/qa-gates/ and by the poshqc CI job on the PR head.
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-10-16  

# Policy Compliance Audit: activate-prompt-null-background (Issue #202)

**Audit Date:** 2026-06-18
**Code Under Test:** `scripts/dev-tools/activate.ps1` (production, modified), `tests/scripts/dev-tools/activate.Tests.ps1` (test, modified)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 1 prod + 1 test | 53 tests | PASS 53 pass, 0 fail | Not separately captured (see note) | 98.21% commands, 98.1% lines (52/53) on `activate.ps1` | All 8 changed lines covered |

**Note:** Both changed files are modifications of pre-existing files (not new files). No language other than PowerShell has changed files in the branch diff (`db3d528..34176ed`). TypeScript, Python, and C# coverage verdicts are N/A because those languages have zero changed files on the branch.

### Coverage Evidence Checklist

- PowerShell post-change coverage artifact (changed production file): `docs/features/active/2026-06-18-activate-prompt-null-background-202/evidence/coverage/activate-coverage.xml` (generated during this review by a Pester run scoped to `scripts/dev-tools/activate.ps1`).
- Pre-existing repo coverage artifact `artifacts/pester/powershell-coverage.xml`: present but scopes `CodeCoverage.Path` to five `.claude/hooks` files only and does NOT include `scripts/dev-tools/activate.ps1`. It therefore provides no coverage evidence for the changed production file. See Section 8.
- Per-language comparison summary: Section 1.2.1.

**Verdict rule applied:** PowerShell coverage verdict is explicit PASS based on numeric post-change coverage of the changed production file (98.21% commands, 98.1% lines), with all changed lines covered.

---

## Executive Summary

The branch implements the null-tolerant `-BackgroundColor` fix for `Get-VenvAwarePrompt` in `scripts/dev-tools/activate.ps1` and adds a deterministic regression test in `tests/scripts/dev-tools/activate.Tests.ps1`. The diff against the resolved base (`origin/main` @ `db3d528`) is limited to one production PowerShell file, one test PowerShell file, and three feature-scoping docs. No workflow, benchmark, or action files are touched.

The PowerShell toolchain (format -> analyze -> test) was executed during this review and passed cleanly. All 53 tests in the activate suite pass. Coverage on the changed production file is 98.21% commands / 98.1% lines, with every changed line covered.

**Policy documents evaluated:**
- PASS `general-code-change.md` (cross-language code change policy)
- PASS `general-unit-test.md` (cross-language unit test policy)
- PASS `powershell.md` (PowerShell toolchain and standards)
- PASS `quality-tiers.md` (uniform coverage thresholds)

**Language-specific policies evaluated:**
- N/A Python (no changed files)
- PASS PowerShell (`powershell-code-change` + `powershell-unit-test`)
- N/A Bash (no changed files)
- N/A JSON (no changed files)

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts were created during this review. The coverage artifact written to the feature evidence folder is a durable review artifact in the canonical location.

---

## Evidence Location Compliance

The branch diff (`db3d528..34176ed`) was scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.

- Branch-diff scan result: **NONE**. No file in this branch's diff is written to a non-canonical evidence path.
- `validate_evidence_locations.py --root .` exited 0. It reported pre-existing violations under `artifacts/evidence/baseline/**` and `artifacts/evidence/post-change/**` dated 2026-04-18 and 2026-04-25. These files are NOT part of this branch's diff and are not attributable to this feature; they are out of audit scope (the scope is the feature-vs-base diff). No FAIL finding is recorded against this feature for them.
- The coverage evidence this review produced was written to the canonical `<FEATURE>/evidence/coverage/` path (`docs/features/active/2026-06-18-activate-prompt-null-background-202/evidence/coverage/activate-coverage.xml`). No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` was required; no caller instruction specified a non-canonical evidence path.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Tests use `BeforeAll` to import functions via AST/ScriptBlock dot-source; each `It` is self-contained with no shared mutable state. The full suite ran successfully in a single Invoke-Pester pass. |
| **Isolation** - Each test targets single behavior | PASS | Each `It` exercises one function/behavior (e.g., `Test-IsDarkBackground` per-color cases, `Get-VenvAwarePrompt` per-scenario). The new null-background test targets exactly the null path. |
| **Fast Execution** - Tests complete quickly | PASS | Full activate suite (53 tests) completed in 985 ms (discovery 147 ms). |
| **Determinism** - Consistent results | PASS | The new test supplies `-BackgroundColor $null` explicitly rather than reading the ambient host, removing the determinism violation called out in spec Root Cause Analysis. Dark/light cases use literal `[System.ConsoleColor]` values. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `It` names; the new test includes a rationale comment explaining Test Explorer host parity. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PARTIAL | A baseline coverage figure for `activate.ps1` was not separately captured before the change because the repo `pester.runsettings.psd1` does not include `activate.ps1` in coverage scope. Post-change coverage was measured directly: 98.21% commands. Disposition does not block since changed-line coverage is verified at 100%. |
| **No Coverage Regression** | PASS | All 8 changed production lines (288, 289, 292, 293, 301, 302, 305, 307) are covered (`ci>=1`, `mi=0`). No regression on changed lines. |
| **New Code Coverage >= 85%/>=90%** | PASS | The changed file is a modified file (not new). Line coverage 98.1% (52/53), command coverage 98.21% (55/56), exceeding the >= 85% line threshold. The single uncovered command is unrelated to the change. |
| **Comprehensive Coverage** | PASS | `Get-VenvAwarePrompt` is covered for venv-active, default, dark, light, and null-background paths. The new null path (`$false` else branch, line 305) is covered. |
| **Positive Flows** | PASS | Valid background colors (Black -> green; non-dark -> plain) and valid venv path are tested. |
| **Negative Flows** | PASS | Null background (`-BackgroundColor $null`) is the negative/edge input for the fix and is tested deterministically. |
| **Edge Cases** | PASS | Null background, empty venv, and per-color boundary cases are covered. |
| **Error Handling** | PASS | The fix converts a parameter-bind throw into a defined uncolored-render path; the test asserts no throw and the expected uncolored output. |
| **Concurrency** | N/A | Not applicable to a pure prompt-decision function. |
| **State Transitions** | N/A | The function under test is pure with no state. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: not separately captured (repo coverage scope excludes `activate.ps1`) -> Post-change: 98.21% commands / 98.1% lines on `scripts/dev-tools/activate.ps1`. Changed-line coverage: 100% (8/8 changed lines covered). Disposition: PASS. Evidence: `docs/features/active/2026-06-18-activate-prompt-null-background-202/evidence/coverage/activate-coverage.xml`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `Should -Be` assertions produce explicit expected-vs-actual messages on the prompt string. |
| **Arrange-Act-Assert Pattern** | PASS | Each `It` arranges inputs as parameters, acts by invoking the function, and asserts on the returned string. |
| **Document Intent** | PASS | The new test name and inline comment document the Test Explorer host-parity scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | The activate tests exercise pure functions imported via AST; no network, DB, or live executable. |
| **Use Mocks/Stubs** | PASS | The new test requires no mocks; it passes `$null` directly. No prohibited direct executable mocking introduced. |
| **Environment Stability** | PASS | No temporary files; the new test does not read ambient host state, satisfying Terminal/Test Explorer parity. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit constitutes the required policy review prior to PR. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Objective documented in `spec.md` (Issue #202): make `Get-VenvAwarePrompt -BackgroundColor` null-tolerant. |
| **Read existing change plans** | PASS | `plan.2026-06-18T09-25.md` present with recorded P0-P4 tasks. |
| **Document the plan** | PASS | Plan and spec recorded in the feature folder. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The fix adds a single null guard around the existing `Test-IsDarkBackground` call; no new abstractions. |
| **Reusability** | PASS | `Test-IsDarkBackground` and `Get-ColorizedPrompt` are unchanged and reused. |
| **Extensibility** | PASS | `-BackgroundColor` is now optional with `[AllowNull()]`; future invalid-value normalization is noted as follow-up in spec Risks. |
| **Separation of concerns** | PASS | Pure decision logic remains separate from host access; the shim continues to supply the host value. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Change is localized to one function in the existing cohesive script. |
| **Under 500 lines** | PASS | `activate.ps1` = 434 lines; `activate.Tests.ps1` = 417 lines. |
| **Public vs internal** | PASS | `-BackgroundColor` parameter contract relaxed from mandatory non-nullable to optional nullable; this is a widening (non-breaking) change. |
| **No circular dependencies** | PASS | No new dependencies introduced. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Parameter and function names unchanged and descriptive. |
| **Docs/docstrings** | PASS | The `.PARAMETER BackgroundColor` comment-help was updated to document the null case. |
| **Comment why, not what** | PASS | The inline comment at the null guard explains the rationale (redirected/non-interactive host reports null) rather than restating the code. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `Invoke-Formatter` on both changed files returned no diff (FORMAT_CLEAN). |
| **2. Linting** | PASS | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` returned zero findings on both files (ANALYZE_CLEAN). |
| **3. Type checking** | N/A | Not applicable for PowerShell. |
| **4. Testing** | PASS | Invoke-Pester on the activate suite: 53 passed, 0 failed, 0 skipped. |
| **Full toolchain loop** | PASS | Format, analyze, and test all passed in a single pass during this review. |
| **Explicit reporting** | PASS | Commands and results recorded in this audit (Section 7, Appendix B). |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Documented in spec Proposed Fix and commit `34176ed`. |
| **Design choices explained** | PASS | Null-as-not-dark rationale documented in spec and inline comment. |
| **Update supporting documents** | PASS | spec.md, issue.md, plan present. |
| **Provide next steps** | PASS | spec Rollout notes merge via PR after green CI. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | FORMAT_CLEAN on both files. |
| **Linting with PSScriptAnalyzer** | PASS | ANALYZE_CLEAN on both files with repo `pssa.settings.psd1`. |
| **Fix all findings** | PASS | No findings to fix. |
| **PowerShell 7+ compatible** | PASS | `[System.Nullable[System.ConsoleColor]]` and ternary-style `if` expression are PowerShell 7 compatible; the spec environment is PowerShell 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | `Get-VenvAwarePrompt` retains `[CmdletBinding()]` and `[OutputType([string])]`. |
| **Parameter validation** | PASS | `-BackgroundColor` uses `[Parameter()] [AllowNull()] [System.Nullable[System.ConsoleColor]]`; `-CurrentPath` retains `[ValidateNotNullOrEmpty()]`. |
| **Avoid global state** | PASS | No global/script-scoped mutable state introduced. |
| **Error handling** | PASS | The null guard replaces a bind-time throw with explicit branching; failure mode is now defined. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 434 lines. |
| **Approved verbs** | PASS | `Get-VenvAwarePrompt` uses the approved verb `Get`. |
| **Comment why** | PASS | The guard comment explains the host-null rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | FORMAT_CLEAN. |
| **Step 2: Analyze** | PASS | ANALYZE_CLEAN. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | 53/53 passed. |
| **Rerun loop if needed** | PASS | Single clean pass; no rerun required during review. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | Pester 5.6.1; suite uses `Describe`/`Context`/`It` and modern `Should -Be`. |
| **Use PoshQC Configuration** | PASS | Repo config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` exists; for changed-file coverage the review ran a scoped Pester configuration targeting `activate.ps1` because the repo runsettings scope excludes it (see Section 8). |
| **PowerShell 7+ Compatible** | PASS | Tests run under PowerShell 7 / Pester 5.6.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | One behavior per `It`. |
| **Test Behavior Over Implementation** | PASS | Tests assert returned prompt strings, not internals. |
| **Mocking Used Sparingly** | PASS | The new test uses no mocks. |
| **Organization** | PASS | Test file `tests/scripts/dev-tools/activate.Tests.ps1` mirrors `scripts/dev-tools/activate.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming - *.Tests.ps1** | PASS | `activate.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | Grouped under `Describe 'Get-VenvAwarePrompt ...'`. |
| **Logical Grouping** | PASS | Null case grouped with the other `Get-VenvAwarePrompt` cases. |
| **Docstrings/Comments** | PASS | New test name and comment self-document the scenario. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester** | PASS | Invoke-Pester via repo Pester 5.6.1. |
| **No Alternative Test Runners** | PASS | Only Pester used. |

---

## 5. Test Coverage Detail

### Get-VenvAwarePrompt (focus of the change)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| renders the prompt uncolored when the host background is null (Test Explorer host parity) | Edge/Negative (null) | 285, 288-289 or 292-293, 301, 305, 307 | PASS |
| wraps the prompt in green for a dark background (Black) | Positive (dark) | 285, 301-302, 307 | PASS |
| leaves the prompt plain for a non-dark background | Positive (light) | 285, 301-302, 307 | PASS |

**Coverage:** `scripts/dev-tools/activate.ps1` 98.21% commands (55/56), 98.1% lines (52/53). All changed lines covered.

**Not covered:** One command/line unrelated to this change remains uncovered (1 missed of 56). The changed region is fully covered.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 53 | PASS |
| Tests Passed | 53 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 0.985s total | PASS Fast |
| Discovery Time | 147ms | PASS |
| Test File Size | 417 lines | PASS Maintainable |
| Code Coverage (changed prod file) | 98.21% commands, 98.1% lines; branch coverage UNVERIFIED (Pester JaCoCo emits no branch counter) | PASS (line/command) |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -ScriptDefinition <file>` | No diff on both files | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | Zero findings on both files | PASS |
| Pester Tests | `Invoke-Pester` (activate suite, coverage scoped to `activate.ps1`) | 53 passed / 0 failed; 98.21% command coverage | PASS |

**Notes:**
The repo `pester.runsettings.psd1` scopes coverage to `.claude/hooks` files only; the changed production file `scripts/dev-tools/activate.ps1` is not in that scope. To verify coverage for the changed file as required, this review executed a Pester run with `CodeCoverage.Path = scripts/dev-tools/activate.ps1`. See Section 8.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Repo coverage configuration excludes the changed production file.** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` sets `CodeCoverage.Path` to five `.claude/hooks` files only. Consequently the pre-existing artifact `artifacts/pester/powershell-coverage.xml` contains no coverage data for `scripts/dev-tools/activate.ps1`. This is a configuration limitation, not a defect introduced by this branch. This review compensated by running a scoped coverage measurement directly on the changed file (98.21% commands, all changed lines covered). This gap is informational and does not block the feature; it is recorded so the coverage configuration can be widened in a follow-up if the team wants `activate.ps1` in the standing coverage scope.
- **Branch coverage UNVERIFIED.** Pester's JaCoCo output emits no BRANCH counter (`mb`/`cb` are zero across all lines). Branch coverage for the new null/not-null decision cannot be read numerically from the artifact. The decision's both arms are exercised by the test suite (null path -> uncolored; valid color -> dark/light), so the new branch is behaviorally covered even though the numeric branch metric is unavailable. This matches the known PowerShell branch-coverage limitation.

### Approved Exceptions

- **None.** No policy exceptions were required.

### Removed/Skipped Tests

- **None.** No tests were removed or skipped.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **34176ed** - fix(activate): tolerate null console background in venv-aware prompt (#202)

(Range `db3d528..34176ed`.)

### Files Modified

1. **scripts/dev-tools/activate.ps1** (MODIFIED, +18/-4)
   - `Get-VenvAwarePrompt -BackgroundColor` changed from `[Parameter(Mandatory)] [System.ConsoleColor]` to `[Parameter()] [AllowNull()] [System.Nullable[System.ConsoleColor]]`.
   - Added a null guard: when `$BackgroundColor` is `$null`, treat as not-dark (`$false`) and render uncolored; otherwise call `Test-IsDarkBackground` unchanged.
   - Updated `.PARAMETER BackgroundColor` comment-help.

2. **tests/scripts/dev-tools/activate.Tests.ps1** (MODIFIED, +12/-0)
   - Added a deterministic `It` asserting `Get-VenvAwarePrompt -BackgroundColor $null` returns `'(mix-calculator)> '` (uncolored).

3. **docs/features/active/2026-06-18-activate-prompt-null-background-202/{spec.md,issue.md,plan.2026-06-18T09-25.md}** (NEW scoping docs).

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

The change is a minimal, well-scoped null-tolerance fix with a deterministic regression test. The PowerShell toolchain (format -> analyze -> test) passes cleanly. Coverage on the changed production file is 98.21% commands with all changed lines covered. The only recorded gaps are a repo coverage-scope configuration limitation (compensated by a scoped run during this review) and the structural absence of a numeric PowerShell branch counter (the new branch is behaviorally covered). Neither gap is a FAIL.

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
- PASS Coverage & Scenarios (Baseline documentation PARTIAL, non-blocking)
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)
**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

### Metrics Summary

- PASS 53/53 tests passing (100%)
- PASS 98.21% command coverage / 98.1% line coverage on the changed production file
- PASS All 8 changed production lines covered
- PASS All code quality checks passing (format, analyze, test)
- PASS Test execution time 0.985s (fast)
- UNVERIFIED branch coverage (no Pester branch counter; new branch behaviorally covered)

### Recommendation

**Ready for merge** with respect to local policy and toolchain. CI required-checks green on the PR head (AC6) remains to be confirmed by the orchestrator's CI gate, since no PR currently exists for this branch.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope to a plan subset, a file subset, or to mark any language's coverage as out of scope. The caller explicitly directed full feature-vs-base review and application of the PowerShell coverage and toolchain gates. No rejection was required.

---

## Appendix A: Test Inventory

Activate suite top-level groups (53 tests total) include:
- `Get-VenvAwarePrompt (prompt decision used by the shim)` — including the new `renders the prompt uncolored when the host background is null (Test Explorer host parity)`.
- `Test-IsDarkBackground (dark-color predicate)` — parameterized over all dark and non-dark `[System.ConsoleColor]` values.
- `Get-ColorizedPrompt`, `Get-DefaultPrompt`, `Get-RepoRelativePrompt`, `Resolve-RepoRoot`, `Test-IsDotSourced`, and prompt-shim installation cases.

(Full enumeration available via `Invoke-Pester -Output Detailed` on `tests/scripts/dev-tools/activate.Tests.ps1`.)

---

## Appendix B: Toolchain Commands Reference

**For PowerShell (commands executed during this review):**
```powershell
# Formatting (check-only via Invoke-Formatter diff)
Invoke-Formatter -ScriptDefinition (Get-Content -Raw scripts/dev-tools/activate.ps1)
Invoke-Formatter -ScriptDefinition (Get-Content -Raw tests/scripts/dev-tools/activate.Tests.ps1)

# Linting
Invoke-ScriptAnalyzer -Path scripts/dev-tools/activate.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-ScriptAnalyzer -Path tests/scripts/dev-tools/activate.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Testing with coverage scoped to the changed production file
$cfg = New-PesterConfiguration
$cfg.Run.Path = 'tests/scripts/dev-tools/activate.Tests.ps1'
$cfg.CodeCoverage.Enabled = $true
$cfg.CodeCoverage.Path = 'scripts/dev-tools/activate.ps1'
$cfg.CodeCoverage.OutputFormat = 'JaCoCo'
$cfg.CodeCoverage.OutputPath = 'docs/features/active/2026-06-18-activate-prompt-null-background-202/evidence/coverage/activate-coverage.xml'
Invoke-Pester -Configuration $cfg
```

**Evidence-location validator:**
```bash
python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-06-18
**Policy Version:** Current (as of audit date)

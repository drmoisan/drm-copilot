# Policy Compliance Audit: Release flow waits on every check (Issue #931)

---

**Audit Date:** 2026-10-16
**Audit Type:** Re-audit at remediation cycle 2 exit (full branch diff, not only the cycle 2 delta)
**Branch:** `bug/release-flow-waits-on-required-checks-only-931` (local alias `issue-931-cycle2`) @ `85179c841f4efee523776c550defa30b0cf10f12`, PR #948
**Base:** `main` (merge base `ba53ff5694a42e975d5d1db99b2b6ef505143e66`; `origin/main` at `5bc97774b8322e57abb94dfac3cd0a000a136c5b`, 77 commits ahead of the merge base, none touching the files this branch changes)
**Work Mode:** `minor-audit` (AC source: `issue.md` `## Acceptance Criteria`, AC1 to AC6)
**Code Under Test (full branch diff, outside the feature folder):**
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (modified, PowerShell production)
- `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` (new, PowerShell production)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` (new, PowerShell test; 22 tests)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` (modified, PowerShell test; 23 tests)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (modified, PowerShell test; 17 tests)
- `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (modified, Python test)
- Feature folder: Markdown files under `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/` (issue, research, plan, two remediation plans, prior review artifacts, 98 committed evidence files)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 production (1 new, 1 modified), 3 test files | 73 release-flow tests (22 + 23 + 17 + 11); 10417 in the full CI suite | PASS: 10417 tests, 0 errors, 0 failures (CI run 38857583261) | 94.26% lines for `Invoke-FullReleaseFlow.ps1` (115/122, main CI run 38730332356); 90.42% lines repo-wide (same run) | `Invoke-FullReleaseFlow.ps1` 94.93% (131/138); `Invoke-FullReleaseFlow.CheckHelpers.ps1` 100% (30/30); repo-wide 90.44% (16425/18162), all from CI run 38857583261 | 100% of executable lines in changed hunks; the 7 missed lines are unchanged process seams |
| Python | 1 test file, 0 production files | 35 tests in the changed module; 7110 passed in the CI 3.13 job | PASS: 35 pass locally; CI 7110 passed, 6 skipped | 93.72% lines repo-wide (main CI run 38730332356) | 93.72% lines repo-wide (CI run 38857583261 job 116832400485 `TOTAL 17638 1108 6368 504 92%`); `Enforce Python coverage thresholds` (`--min-line 85 --min-branch 75`) passed | 100% of changed production Python lines (0 production Python lines changed) |
| Markdown | Feature folder only | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: CI run 38730332356 artifact `poshqc-test-results` file `powershell-coverage.xml`, recorded in `evidence/baseline/ps-coverage-main.2026-10-16T01-23.md`
- PowerShell post-change coverage artifact: CI run 38857583261 artifact `poshqc-test-results` file `powershell-coverage.xml` (downloaded and parsed by the reviewer). The gitignored local `artifacts/pester/powershell-coverage.xml` came from the executor's scoped run (34 suites under `tests/scripts/dev-tools`; 512/12296 lines, 4.16% repo-wide), which does not measure the repository. The reviewer replaced it with the CI-of-record file for the same head (16425/18162 lines, 90.44%), together with the matching `pester-junit.xml` and `powershell-coverage.koverage.xml`. No coverage was regenerated.
- Per-language comparison summary: Section 1.2.1 of this audit

---

## Executive Summary

The branch replaces the required-only check poll in `Wait-ForPullRequestChecks` with an all-checks poll (`gh pr checks <n> --json bucket`) and makes success a positive assertion (at least one check, every bucket `pass` or `skipping`). Remediation cycle 2 resolved the four related findings in `remediation-inputs.2026-10-16T04-02.md`: F1 (wrapper `OutputType` now `pscustomobject`), F2 (Phase A fails at once on a gh failure other than `no checks reported`), F3 (pure helpers extracted to `Invoke-FullReleaseFlow.CheckHelpers.ps1`; script 499 to 435 lines), and F4 (unreachable `$null` guard removed).

The reviewer verified CI independently: `gh run view 38857583261` reports `completed`/`success` on head `85179c841f4efee523776c550defa30b0cf10f12`, and `gh pr checks 948` lists 17 checks, all `pass`. The reviewer downloaded the `poshqc-test-results` artifact and parsed the JaCoCo and JUnit files directly. All policy requirements pass. There are no blocking findings.

**Policy documents evaluated:**
- PASS `CLAUDE.md` (root; states no coverage thresholds, so the 85% line / 75% branch defaults govern)
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on base; `scripts/dev-tools` is T4, which covers the new helper file by directory)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md` (test-only change)
- PASS `.claude/rules/powershell.md`
- N/A Bash: no Bash files changed
- N/A JSON: no JSON files changed

**Template source:** the structure of the prior audit `policy-audit.2026-10-16T03-14.md`, derived from the bundled template `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`.

**Temporary artifacts cleanup:**
- PASS No temporary or one-time script was added to the branch. The untracked `SCRATCH/` directory in the worktree is not part of the branch diff. Reviewer downloads (CI artifact, job log) were written only to the session scratchpad.
- PASS The new helper file is production code dot-sourced by the release-flow script, not tooling.

---

## Rejected Scope Narrowing

No narrowing was found in the caller prompt. The caller asked for the full branch audit against `main` and the current head. Two caller statements were reviewed and not treated as narrowing:

> "The missing prd-feature receipt is out of scope."

Justification: this concerns an orchestration receipt, not a changed language or file in the branch diff; `minor-audit` mode forbids `spec.md`, so no coverage or toolchain check is skipped.

> "Related issues in the changed files are blocking autonomous findings per operator policy."

Justification: this widens rather than narrows the review; it was applied (see Section 8).

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths (reviewer run at `85179c84`).
- Command: `git diff --name-only ba53ff56..HEAD` filtered for `^artifacts/(baselines|qa|evidence|coverage)/` returned no paths.
- All committed evidence files are under `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/{baseline,regression-testing,qa-gates,other}/`. The one untracked evidence file, `evidence/qa-gates/cycle2-pr-ci-record.2026-10-16T06-05.md`, is also at a canonical path.
- Result: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entry applies.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | `ChecksWait` resets `$script:ghCallCount`, `$script:sleepCallCount`, and `$script:capturedMessage` in `BeforeEach`; helper tests build inputs inline. |
| **Isolation** | PASS | `CheckHelpers` tests dot-source only the helper file and call one function each without mocks; function tests mock only `Invoke-GhExe`, `Invoke-Sleep`, `Write-StderrLine`. |
| **Fast Execution** | PASS | Sleeps are mocked; the Python module runs 35 tests in 0.11 s (reviewer run). |
| **Determinism** | PASS | No wall-clock waits, randomness, network, or filesystem writes; gh responses are scripted per call index. |
| **Readability & Maintainability** | PASS | Behavior-named `It` titles; data-driven `-ForEach` for the three gh failure texts. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | PowerShell per-file baseline 94.26% (115/122), repo-wide 90.42%, Python 93.72%, all from main CI run 38730332356 (`evidence/baseline/ps-coverage-main.2026-10-16T01-23.md`). |
| **No Coverage Regression** | PASS | `Invoke-FullReleaseFlow.ps1` 94.26% to 94.93%; the missed lines 86, 87, 103, 104, 123, 124, 146 are the bodies of the unchanged `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-ChildPowerShellScript`, and `Invoke-Sleep` seams. Python unchanged at 93.72%. |
| **New Code Coverage** | PASS | `Invoke-FullReleaseFlow.CheckHelpers.ps1` 30/30 lines (100%). No executable line inside a changed hunk of the script is missed. |
| **Comprehensive Coverage** | PASS | `ConvertFrom-CheckPollOutput` 7 tests, `Get-CheckSetVerdict` 11 tests, `Test-UnregisteredCheckPollOutput` 4 tests, `Wait-ForPullRequestChecks` 23 tests. |
| **Positive Flows** | PASS | All-pass, pass+skipping, all-skipping, pending-then-pass, registration race then pass (string and `ErrorRecord` forms). |
| **Negative Flows** | PASS | fail, cancel, unrecognized/absent/blank/case-variant bucket, unparsable text, null/scalar elements, HTTP 401, `gh auth login`, connection error. |
| **Edge Cases** | PASS | Empty JSON array; empty gh output for `Test-UnregisteredCheckPollOutput`; fail precedence over unknown and pending. |
| **Error Handling** | PASS | Phase A gh failure returns 1 with zero sleeps; unparsable first poll returns 1; failed completion re-polls consume an attempt. |
| **Concurrency** | N/A | Single-threaded polling loop. |
| **State Transitions** | PASS | not-registered to registered, pending to pass, pending to failed poll to pass, repeated failed polls to timeout. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.26% lines for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (115/122) and 90.42% repo-wide -> Post-change: 94.93% for the script (131/138), 100% for the new `Invoke-FullReleaseFlow.CheckHelpers.ps1` (30/30), 90.44% repo-wide (16425/18162). Change: +0.67 points for the script, +0.02 points repo-wide. New/changed-code coverage: 100%. Thresholds: new file 100% >= 85%, modified file 94.93% >= 85%, repo-wide 90.44% >= 85%; no branch threshold applies to PowerShell. Disposition: PASS. Evidence: CI run 38857583261 artifact `poshqc-test-results` (`powershell-coverage.xml` class-level LINE counters).
- Python: Baseline: 93.72% lines repo-wide -> Post-change: 93.72% lines repo-wide (CI run 38857583261, job 116832400485, `TOTAL 17638 1108 6368 504 92%`); branch coverage at least 92.09% (504 partial branches of 6368). Change: 0 measured files changed (the only changed Python file is under `tests/`, which coverage excludes). New/changed-code coverage: 100% of changed production Python lines (0 lines). The `Enforce Python coverage thresholds` step (`--min-line 85 --min-branch 75`) passed within a successful job. Disposition: PASS. Evidence: CI run 38857583261 job 116832400485 log; baseline main CI run 38730332356 job 116406243603 log; `evidence/qa-gates/py-coverage-pr-ci.2026-10-16T03-38.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Literal `Should -Be`/`-Match`/`-BeExactly` expectations; Python assertions name the script path and the offending fragment. |
| **Arrange-Act-Assert Pattern** | PASS | Each `It` block separates setup, call, and assertions. |
| **Document Intent** | PASS | Describe titles name the helper file and function; It titles state scenario and outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | gh is reached only through the mocked `Invoke-GhExe` seam; helper tests need no seam. |
| **Use Mocks/Stubs** | PASS | Mocks: `Invoke-GhExe`, `Invoke-Sleep`, `Write-StderrLine`. |
| **Environment Stability** | PASS | No temporary files; the `ErrorRecord` is constructed in memory. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit is the cycle 2 re-review. No blocking item remains. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` (#931); cycle 2 objective in `remediation-inputs.2026-10-16T04-02.md` F1 to F4. |
| **Read existing change plans** | PASS | `evidence/baseline/cycle2-phase0-instructions-read.2026-10-16T05-10.md`. |
| **Document the plan** | PASS | `remediation-plan.2026-10-16T04-02.md`; 41 of 41 checkboxes checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The F2 rule is a single substring test placed at the top of the existing Phase A loop. |
| **Reusability** | PASS | One parse helper serves the first poll and every re-poll. |
| **Extensibility** | PASS | The bucket vocabulary is one `$known` array; the no-checks rule is isolated in one function. |
| **Separation of concerns** | PASS | The three pure helpers (no I/O) live in a separate file; I/O stays in the script's seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The helper file holds only the pure check-poll helpers. |
| **Under 500 lines** | PASS | Reviewer `wc -l`: script 435, helpers 116, CheckHelpers tests 197, ChecksWait 346, Tests 438, AdditionalFailurePaths 99, Python 298. |
| **Public vs internal** | PASS | No module manifest; the dot-sourced function set is unchanged except the new `Test-UnregisteredCheckPollOutput`. |
| **No circular dependencies** | PASS | The helper file calls only built-in cmdlets and does not reference the script. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `Test-UnregisteredCheckPollOutput` uses the approved `Test` verb and returns `[bool]`. |
| **Docs/docstrings** | PASS | File-level help on the helper file; `Test-UnregisteredCheckPollOutput` documents the gh text it matches. Help depth of the two moved helpers is `.SYNOPSIS` only (code review, Info). |
| **Comment why, not what** | PASS | The dot-source comment states why the helpers moved and why `$PSScriptRoot` is used. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | Reviewer: `black --check` "1 file would be left unchanged." PoshQC format in CI job `poshqc / PowerShell QC` (success); local `evidence/qa-gates/cycle2-ps-format.2026-10-16T05-25.md`. |
| **2. Linting** | PASS | Reviewer: `ruff check` "All checks passed!" PoshQC analyze in the same CI job; local `evidence/qa-gates/cycle2-ps-analyze.2026-10-16T05-26.md`. |
| **3. Type checking** | PASS | CI job 116832400485 `poetry run pyright`: "0 errors, 0 warnings, 0 informations". A reviewer local run in this worktree reported unresolved `pytest` imports because the worktree `.venv` lacks pytest; this is an environment difference, not a code finding. Not applicable to PowerShell. |
| **4. Architecture-boundary tests** | N/A | No architecture-boundary suite covers `scripts/dev-tools` PowerShell. |
| **5. Testing** | PASS | CI Pester 10417 tests, 0 failures, 0 errors; release-flow suites 22/22, 23/23, 17/17, 11/11. Reviewer pytest 35 passed. |
| **6. Contract / schema checks** | PASS | The Python text pin passes against the post-extraction script. |
| **7. Integration tests** | N/A | No integration suite exists for the release flow. |
| **Full toolchain loop** | PASS | `evidence/qa-gates/cycle2-qc-loop-pass.2026-10-16T05-43.md`; CI run 38857583261 success. |
| **Explicit reporting** | PASS | Commands and exit codes recorded in `evidence/` and Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Section 9. |
| **Design choices explained** | PASS | F2 derivation in `evidence/baseline/cycle2-gh-observation.2026-10-16T05-12.md`. |
| **Update supporting documents** | PASS | Help text for Phase A and `.OUTPUTS` updated; reference search `evidence/regression-testing/cycle2-reference-search.2026-10-16T05-22.md`. |
| **Provide next steps** | PASS | Commit the untracked CI record (feature audit follow-up). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | Reviewer run: `1 file would be left unchanged.` |
| **Linting with Ruff** | PASS | Reviewer run: `All checks passed!` |
| **Type checking with Pyright** | PASS | CI job 116832400485: `0 errors, 0 warnings, 0 informations`. |
| **Testing with Pytest** | PASS | Reviewer run: `35 passed`; CI 3.13 job `7110 passed, 6 skipped`. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Test annotated `-> None`; no `Any`. |
| **Dataclasses for value objects** | N/A | No value objects added. |
| **Protocols/ABCs for interfaces** | N/A | No interfaces added. |
| **Avoid utility classes** | PASS | Module-level constants and one test function. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No exception handling added. |
| **Logging over print** | PASS | No `print`. |
| **Invariants at construction** | N/A | No classes added. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | CI `poshqc / PowerShell QC` success; local `cycle2-ps-format.2026-10-16T05-25.md`. |
| **Linting with PSScriptAnalyzer** | PASS | CI `poshqc / PowerShell QC` success; local `cycle2-ps-analyze.2026-10-16T05-26.md`. |
| **Fix all findings** | PASS | No finding reported. |
| **PowerShell 7+ target** | PASS | CI `windows-latest` job; `poshqc / PowerShell hook suites (Linux)` also passed. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | All three helpers use `[CmdletBinding()]` and `[OutputType()]`; `Test-UnregisteredCheckPollOutput` declares `[bool]`. |
| **Parameter validation** | PASS | `Mandatory` with `[AllowNull()]`/`[AllowEmptyCollection()]` where the contract allows; `-Checks` omits `[AllowNull()]`, so removing the `$null` guard is consistent with the binder contract. |
| **Avoid global state** | PASS | No global or script-scope state in production code. |
| **Error handling** | PASS | Typed `catch [System.ArgumentException]`; every failure path returns 1 with a stderr line. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | Script 435, helpers 116. |
| **Approved verbs** | PASS | `ConvertFrom`, `Get`, `Test`, `Wait`. |
| **Comment why** | PASS | Dot-source comment and helper file `.DESCRIPTION` state the 500-line reason. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | CI and local pass. |
| **Step 2: Analyze** | PASS | CI and local pass. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | CI 10417 tests, 0 failures. |
| **Rerun loop if needed** | PASS | `cycle2-qc-loop-pass.2026-10-16T05-43.md`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Plain pytest function. |
| **Coverage expectation** | PASS | CI threshold step passed; repo-wide 93.72% lines (Section 1.2.1). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One test pins the release-flow script text. |
| **Mocking sparingly** | PASS | No mocks. |
| **Organization** | PASS | Existing module under `tests/scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_release_flow_waits_on_every_check_without_required_wording`. |
| **Docstrings/comments** | PASS | One-line docstring and AAA comments. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `35 passed`. |
| **No Alternative Test Runners** | PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `Describe`/`Context`/`It`, `-ForEach`, `Mock`, `Should -Invoke`. |
| **Use PoshQC Configuration** | PASS | CI `poshqc / PowerShell QC` runs the suites through PoshQC. |
| **PowerShell 7+ Compatible** | PASS | CI `windows-latest` job passed. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 22 helper tests and 23 loop tests. |
| **Test Behavior Over Implementation** | PASS | Assertions target return codes, verdict objects, stderr text, and seam call counts. |
| **Mocking Used Sparingly** | PASS | Only the three I/O seams are mocked. |
| **Organization** | PASS | `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` mirrors `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | PASS | `<Name>.Tests.ps1` for the new helper file. |
| **Describe/Context/It Structure** | PASS | CheckHelpers: 3 Describe blocks (11 + 7 + 4 It). |
| **Logical Grouping** | PASS | One Describe per helper function. |
| **Docstrings/Comments** | PASS | Test titles are self-describing. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Local `run_poshqc_test` and CI PoshQC job. |
| **No Alternative Test Runners** | PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### ConvertFrom-CheckPollOutput (7 direct tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| parses a JSON array into check objects | Positive | helpers 14-46 | PASS |
| parses an empty JSON array as an empty successful result | Edge Case | helpers 14-46 | PASS |
| joins multi-line output before parsing | Positive | helpers 28-46 | PASS |
| reports failure for blank output | Negative | helpers 28-32 | PASS |
| reports failure for text that is not JSON | Error Handling | helpers 33-38 | PASS |
| reports failure for a null element | Negative | helpers 39-43 | PASS |
| reports failure for a scalar element | Negative | helpers 39-43 | PASS |

**Coverage:** 100% (helper file 30/30 lines in CI).

**Not covered:** None.

### Get-CheckSetVerdict (11 direct tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| reports pass for a set of pass buckets | Positive | helpers 48-87 | PASS |
| reports pass for a set of pass and skipping buckets | Positive | helpers 48-87 | PASS |
| reports pending when a pending bucket accompanies pass buckets | Positive | helpers 48-84 | PASS |
| reports fail for a fail bucket | Negative | helpers 48-75 | PASS |
| reports fail for a cancel bucket | Negative | helpers 48-75 | PASS |
| reports fail ahead of pending and unknown buckets | Edge Case | helpers 48-75 | PASS |
| reports unknown for a bucket outside the vocabulary | Negative | helpers 48-80 | PASS |
| reports unknown for a missing bucket property | Negative | helpers 48-80 | PASS |
| reports unknown for a blank bucket value | Negative | helpers 48-80 | PASS |
| reports unknown for a bucket that differs only in case | Edge Case | helpers 48-80 | PASS |
| reports empty for an empty check set | Edge Case | helpers 48-62 | PASS |

**Coverage:** 100%.

**Not covered:** None. The former unreachable `$null` alternative was removed (F4).

### Test-UnregisteredCheckPollOutput (4 direct tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| reports true for the gh no-checks message | Positive | helpers 89-112 | PASS |
| reports true for the gh no-checks message delivered as an error record | Positive | helpers 89-112 | PASS |
| reports false for a gh authentication failure | Negative | helpers 89-116 | PASS |
| reports false for empty output | Edge Case | helpers 89-116 | PASS |

**Coverage:** 100%.

**Not covered:** None.

### Wait-ForPullRequestChecks (23 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| waits through the registration race then merges | Positive | script 233-274 | PASS |
| returns failure on registration timeout | Negative | script 233-245 | PASS |
| returns failure at once without sleeping when gh fails (3 cases) | Error Handling | script 233-241 | PASS |
| keeps retrying while gh reports no registered checks as an error record | Positive | script 233-274 | PASS |
| polls gh pr checks without the required flag | Positive | script 233 | PASS |
| returns failure when a non-required check fails / is cancelled | Negative | script 258-264 | PASS |
| keeps polling and times out on an empty check set | Edge Case | script 258-290 | PASS |
| returns failure on an unrecognized bucket / no bucket property | Negative | script 258-270 | PASS |
| returns success for pass+skipping and all-skipping sets | Positive | script 258-274 | PASS |
| returns failure without throwing on unparsable check output | Error Handling | script 251-255 | PASS |
| continues after a non-zero / unparsable completion poll; times out when polls keep failing | Error Handling | script 276-290 | PASS |
| remaining pre-existing pending, timeout, failure, and sleep-seam tests | Mixed | script 233-290 | PASS |

**Coverage:** 100% of the function's executable lines (no missed line in 214-290 in the CI JaCoCo report).

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (CI Pester, full suite) | 10417 | PASS |
| Tests Passed (CI Pester) | 0 errors, 0 failures, 10 disabled | PASS |
| Release-flow Pester tests | 73 (22 + 23 + 17 + 11), 0 failed | PASS |
| Python tests (changed module) | 35 passed, 0 failed | PASS |
| Execution Time (Python module) | 0.11 s | PASS |
| Functions Tested (script plus helpers) | all functions except the four process seams | PASS |
| Test File Size | 197 / 346 / 438 / 99 / 298 lines | PASS |
| Code Coverage | script 94.93%, helpers 100% lines; PowerShell has no branch metric | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` | 1 file would be left unchanged | PASS |
| Ruff Linting | `poetry run ruff check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright` (CI job 116832400485) | 0 errors, 0 warnings, 0 informations | PASS |
| Pytest Tests | `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q` | 35 passed | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | CI `poshqc / PowerShell QC` | success | PASS |
| PSScriptAnalyzer | CI `poshqc / PowerShell QC` | success | PASS |
| Pester Tests | CI `poshqc / PowerShell QC` | 10417 tests, 0 failures | PASS |

**Notes:**
The local PoshQC MCP runner did not measure the helper file because it reads the installed extension's coverage list; the CI artifact measures it (30/30). The CI artifact is the result of record.

---

## 8. Gaps and Exceptions

### Identified Gaps

None blocking. The operator policy that related issues in the changed files are blocking autonomous findings was applied. The reviewer examined the changed files for further related defects and found none that meet the defect bar. Three Info observations are recorded in `code-review.2026-10-16T06-11.md`:

- Phase B counts a failed re-poll as an empty set, so a persistent gh failure after Phase A ends as a completion timeout without naming the gh failure. The result is fail-closed and the behavior is documented in the help text; it is a deliberate tolerance for transient errors during a long wait, not a defect.
- The two moved helpers carry `.SYNOPSIS` only.
- The pre-existing registration race after the first all-pass read (parity with #899).

### Cycle 2 Finding Disposition

- **F1 (autonomous): resolved.** `[OutputType([pscustomobject])]` on both wrappers; `.OUTPUTS` updated; test `declares the command-result output type on '<CommandName>'` passes in CI.
- **F2 (autonomous): resolved.** Script lines 237-241; rule derived from the recorded gh 2.87.3 output. Tests assert zero sleeps and one poll for three failure texts, and continued retry for the no-checks text as an `ErrorRecord`. `Invoke-GhExe` captures stderr with `2>&1`, so the gh message reaches the substring test.
- **F3 (autonomous): resolved.** Helpers in `Invoke-FullReleaseFlow.CheckHelpers.ps1`; behavior unchanged (`git diff 0eddcff3e HEAD`); helper inside CI coverage at 100%; script at 435 lines. No mirror lists the script's files individually: `quality-tiers.yml` and `config/blast-radius.json` match by directory or glob, and `.vscode/tasks.json` invokes only the entry script.
- **F4 (autonomous): resolved.** Guard removed; the binder and the only caller both exclude `$null` elements.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` was renamed to `Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` with all 18 tests retained; CI JUnit contains no orphan suite under the old name.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **6c6896c06** - docs(931): create active minor-audit feature folder for release-flow all-checks fix
2. **379231a3d** - docs(931): add release-flow all-checks research
3. **8092d59f9** - docs(931): add minimal-audit plan for release-flow all-checks fix
4. **4bbf86c9f** - docs(931): revise plan for preflight round 1 findings
5. **afb3226da** - docs(931): revise plan for preflight round 2 findings
6. **8245f1781** - docs(931): phase 0 baseline evidence
7. **3fdbc47ca** - fix(931): release flow waits on every check
8. **729eb879a** - docs(931): final QC evidence and AC check-off
9. **83c1c5431** - docs(931): record phase 2 commit
10. **f73457642** - docs(931): check off P2-T20
11. **7d0a18d4b** - docs(931): feature review artifacts and related follow-up cycle inputs
12. **790f8ad6d** - docs(931): cycle 1 baseline evidence for check-verdict tests
13. **92ff4d632** - test(931): cover blank bucket value in Get-CheckSetVerdict
14. **4a797da3c** - docs(931): cycle 1 final QC evidence
15. **198c27330** - docs(931): record cycle 1 phase 2 commit
16. **a0ddc4d57** - docs(931): check off cycle 1 remediation plan
17. **7523b73d7** - docs(931): cycle 1 re-audit artifacts
18. **0c24f27a8** - Merge origin/main into bug/release-flow-waits-on-required-checks-only-931
19. **072df4041** - docs(931): check off AC6 after PR CI success
20. **0eddcff3e** - Merge remote-tracking branch 'origin/main' into issue-931-cycle2
21. **7051d8a8d** - docs(931): record cycle 2 remediation inputs (coordinator D5)
22. **049cfa67a** - docs(931): add remediation cycle 2 plan
23. **079414b22** - docs(931): revise remediation cycle 2 plan after preflight round 1
24. **661a55bbf** - docs(931): cycle 2 phase 0 baseline evidence
25. **1c65fc2ce** - fix(931): fail fast on gh poll errors and extract check helpers
26. **4a3eb67a1** - docs(931): cycle 2 phase 2 final QC evidence and verification
27. **85179c841** - docs(931): remove review-only directive from executed cycle 2 plan

### Files Modified

1. **scripts/dev-tools/Invoke-FullReleaseFlow.ps1** (MODIFIED)
   - Drops `--required`; Phase A fail-fast guard; Phase B driven by the verdict helper; help text, header, and `OutputType` updates; dot-sources the helper file.
2. **scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1** (NEW)
   - `ConvertFrom-CheckPollOutput`, `Get-CheckSetVerdict`, `Test-UnregisteredCheckPollOutput`.
3. **tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1** (NEW)
   - 22 direct helper tests.
4. **tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1** (MODIFIED)
   - All-checks classification Context and the cycle 2 Phase A tests.
5. **tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1** (MODIFIED)
   - Argument-string updates and the OutputType test.
6. **tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py** (MODIFIED)
   - Release-flow contract pin.
7. **docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/** (NEW)
   - Issue, research, plans, prior review artifacts, and evidence.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

Every policy requirement passes on head `85179c84`, verified against CI run 38857583261 and reviewer reruns. The four cycle 2 findings are resolved. No blocking finding remains.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure: all files under 500 lines (script 435)
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline
- PASS Python Design & Typing
- PASS Error Handling (no handling added)

**For PowerShell:**
- PASS Tooling & Baseline
- PASS PowerShell Design & Safety
- PASS Structure & Naming
- PASS Toolchain

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

**For PowerShell:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 73 of 73 release-flow Pester tests passing in CI; 10417 Pester tests with 0 failures
- PASS 35 of 35 Python module tests passing
- PASS 94.93% line coverage for the modified script (baseline 94.26%); 100% for the new helper file
- PASS Python repo-wide 93.72% lines; threshold step passed
- PASS 17 of 17 PR checks passing on the head

---

### Recommendation

**Ready to merge** after the untracked CI record `evidence/qa-gates/cycle2-pr-ci-record.2026-10-16T06-05.md` is committed; if that commit changes the PR head, re-run the S9 gate on the new head. No remediation is required.

---

## Appendix A: Test Inventory

### Complete Test List

1. Invoke-FullReleaseFlow.CheckHelpers.ps1 - Get-CheckSetVerdict > 11 tests (Section 5)
2. Invoke-FullReleaseFlow.CheckHelpers.ps1 - ConvertFrom-CheckPollOutput > 7 tests (Section 5)
3. Invoke-FullReleaseFlow.CheckHelpers.ps1 - Test-UnregisteredCheckPollOutput > 4 tests (Section 5)
4. Invoke-FullReleaseFlow.ps1 - Wait-ForPullRequestChecks > 23 tests (Section 5)
5. Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded > 17 tests in `Invoke-FullReleaseFlow.Tests.ps1` and 11 in `AdditionalFailurePaths`
6. tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py::test_release_flow_waits_on_every_check_without_required_wording

---

## Appendix B: Toolchain Commands Reference

**Reviewer-run commands (2026-10-16, worktree at `85179c84`):**
```bash
git fetch origin main -q
git merge-base HEAD origin/main
git diff --stat ba53ff5694a42e975d5d1db99b2b6ef505143e66 HEAD
git diff 0eddcff3e HEAD -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1
git diff --name-only ba53ff5694a42e975d5d1db99b2b6ef505143e66 origin/main -- scripts/dev-tools tests/scripts/dev-tools tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD
poetry run black --check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
poetry run ruff check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
gh run view 38857583261 --json status,conclusion,headSha,workflowName,event
gh pr checks 948
gh pr view 948 --json headRefOid,headRefName,baseRefName,state,mergeable
gh run download 38857583261 -n poshqc-test-results -D <scratchpad>
gh run view 38857583261 --log --job 116832400485
```

**Executor-run PowerShell commands (recorded in evidence):**
```powershell
# run_poshqc_format  (workspace_root = worktree)
# run_poshqc_analyze (workspace_root = worktree)
# run_poshqc_test    (workspace_root = worktree, scan folder tests/scripts/dev-tools)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)

# Policy Compliance Audit: Release flow waits on every check (Issue #931)

---

**Audit Date:** 2026-10-16
**Branch:** `bug/release-flow-waits-on-required-checks-only-931` @ `f73457642c3e47a29f64c6e08b63a529a1570716`
**Base:** `main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
**Work Mode:** `minor-audit` (AC source: `issue.md` `## Acceptance Criteria`, AC1 to AC6)
**Code Under Test (full branch diff, outside the feature folder):**
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (modified, PowerShell production)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` (new, PowerShell test)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` (modified, PowerShell test)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (modified, PowerShell test)
- `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (modified, Python test)
- Feature folder: 44 Markdown files under `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/` (issue, plan, research, evidence)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 1 production, 3 test files | 62 release-flow tests (654 in scoped local run) | PASS: 654 pass, 0 fail (local scoped run) | 94.26% lines (file, main CI run 38730332356); 90.42% lines (repo-wide, same run) | 95.62% lines (file, local scoped run); 90.44% lines (repo-wide, derived) | 100% of executable lines in changed hunks (0 uncovered changed lines) |
| Python | 1 test file, 0 production files | 35 tests in the changed module | PASS: 35 pass, 0 fail | 93.72% lines (repo-wide, main CI run 38730332356 job log TOTAL 17638 stmts / 1108 missed; branch gate 75% passed) | FAIL (awaiting PR CI): no post-change Python coverage report on the branch; expected 93.72% lines because no measured Python file changed; PR CI quality-checks job produces and enforces it | 100% of changed production Python lines (0 production Python lines changed) |
| Markdown | 44 files (feature folder only) | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (no TypeScript file changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (no TypeScript file changed on the branch)
- PowerShell baseline coverage artifact: CI run 38730332356 artifact `poshqc-test-results` file `powershell-coverage.xml`, recorded in `evidence/baseline/ps-coverage-main.2026-10-16T01-23.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (local PoshQC run, written 2026-10-16 01:49 UTC after commit `3fdbc47ca`, scoped to `tests/scripts/dev-tools`)
- Per-language comparison summary: Section 1.2.1 of this audit

---

## Executive Summary

The branch replaces the required-only check poll in `Wait-ForPullRequestChecks` (`gh pr checks <n> --required --json bucket`) with an all-checks poll (`gh pr checks <n> --json bucket`), adds two pure helpers (`ConvertFrom-CheckPollOutput`, `Get-CheckSetVerdict`) that make the success verdict a positive assertion (at least one check, every bucket `pass` or `skipping`), and treats `fail`/`cancel`, unrecognized buckets, absent buckets, unparsable output, and an empty set as non-success. Pester coverage was extended (13 new `Wait-ForPullRequestChecks` tests and 17 new helper tests), the existing release-flow tests were updated to the new argument list and message, and a Python contract pin was added.

The policy documents in the policy-compliance order were evaluated. Every toolchain stage that can run locally passes. PowerShell per-file line coverage rose from 94.26% to 95.62%, with no uncovered line inside a changed hunk. Two items depend on the PR CI run, which does not exist yet because no PR has been opened: (1) AC6's CI-of-record clause (PoshQC pass and per-file coverage no-regression on the PR head), and (2) Python coverage. No Python coverage report exists on the branch for the changed Python test module. CI's quality-checks job produces and enforces that report (85% line / 75% branch). Both are classified `awaiting_ci`. No autonomous remediation is required.

**Policy documents evaluated:**
- PASS `CLAUDE.md` (root; states no coverage thresholds, so the 85% line / 75% branch defaults govern)
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on base; `scripts/dev-tools` is T4)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md` (test-only change)
- PASS `.claude/rules/powershell.md`
- N/A Bash: no Bash files changed
- N/A JSON: no JSON files changed

**Template source:** the MCP template resolver tool was not available in this reviewer's tool set; the bundled extension asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (the file the MCP resolver serves) was used as the template.

**Temporary artifacts cleanup:**
- PASS No temporary or one-time script was added to the repository. Reviewer helper scripts (JaCoCo and JUnit parsers) were written only to the session scratchpad and are not part of the branch.
- PASS No new ongoing tooling script was added.

---

## Rejected Scope Narrowing

No narrowing was found in the caller prompt. The caller instruction to classify AC6's coverage clause as `awaiting_ci` is a remediability classification consistent with `feature-review-workflow`, not a scope reduction. The audit scope remains the full branch diff `adb9aa5f..f7345764`.

One narrowing was found in the plan. The plan text below marks Python coverage as not applicable, even though Python has a changed file on the branch:

> "The only Python change is a test file, so no Python coverage command is planned; the artifacts record `Coverage: not applicable, no Python production file changed`." (`plan.2026-10-15T15-45.md`, Conventions)

Justification for rejecting it: the reviewer contract requires an explicit PASS or FAIL coverage verdict for every language with changed files. The Python coverage verdict is therefore recorded as FAIL in Section 1.2.1 because the post-change artifact is absent. It is classified `awaiting_ci` because the PR CI quality-checks job measures and enforces it.

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0, with no reported paths.
- Command: `git diff --name-only adb9aa5f..HEAD -- artifacts` returned no paths. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 40 evidence files are under `docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/{baseline,regression-testing,qa-gates,other}/`.
- Result: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entry applies.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | `ChecksWait` Context `all-checks classification` resets `$script:responses`/`$script:capturedArgs` in `BeforeEach`; counters reset by the Describe-level `BeforeEach`. Helper tests build their inputs inline. |
| **Isolation** | PASS | Helper tests call `Get-CheckSetVerdict` / `ConvertFrom-CheckPollOutput` directly with no mocks; function tests mock only the seams `Invoke-GhExe`, `Invoke-Sleep`, `Write-StderrLine`. |
| **Fast Execution** | PASS | Sleeps are mocked; the Python module runs 35 tests in 0.10 s (reviewer run). |
| **Determinism** | PASS | No wall-clock waits, randomness, network, or filesystem writes; `gh` responses are scripted per call index. |
| **Readability & Maintainability** | PASS | Behavior-named `It` titles (for example `returns failure when a non-required check fails`); Arrange/Act/Assert spacing; Python pin uses `# Arrange`/`# Act`/`# Assert`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | PowerShell per-file baseline 94.26% (115/122 lines), main CI run 38730332356 at the merge base; `evidence/baseline/ps-coverage-main.2026-10-16T01-23.md`. Repo-wide PowerShell 90.42% (16381/18116) derived by this reviewer from the same artifact. Python repo-wide 93.72% lines from the same run's `quality-checks7 / Code Quality & Tests (3.13)` log. |
| **No Coverage Regression** | PASS (PowerShell) / FAIL-awaiting CI (Python) | PowerShell file 94.26% to 95.62% (+1.36 points); uncovered lines 81, 82, 98, 99, 118, 119, 141 are identical before and after and lie in the unchanged process seams. Python: no post-change report exists on the branch (see 1.2.1). |
| **New Code Coverage** | PASS | Every executable line inside the changed hunks (15-16, 162-235, 248-283, 301, 315-353) is covered in `artifacts/pester/powershell-coverage.xml`. |
| **Comprehensive Coverage** | PASS | `ConvertFrom-CheckPollOutput`: 7 direct tests plus 3 function-level paths. `Get-CheckSetVerdict`: 10 direct tests. `Wait-ForPullRequestChecks`: 19 tests (6 existing, 13 new). |
| **Positive Flows** | PASS | All-pass, pass+skipping, all-skipping, pending-then-pass, multi-line JSON parse. |
| **Negative Flows** | PASS | fail, cancel, unrecognized bucket, absent bucket property, case-differing bucket, unparsable text, blank output, null/scalar elements. |
| **Edge Cases** | PASS | Empty JSON array (parse succeeds, verdict `empty`, polls until timeout); fail precedence over unknown and pending. |
| **Error Handling** | PASS | Unparsable first poll returns 1 without throwing; non-zero and unparsable completion re-polls consume an attempt and are treated as an empty set. |
| **Concurrency** | N/A | Single-threaded polling loop; no shared concurrent state. |
| **State Transitions** | PASS | pending to pass, pending to failed-poll to pass, pending to repeated failed polls to timeout. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.26% lines for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (115/122) and 90.42% repo-wide -> Post-change: 95.62% lines for the file (153/160) and 90.44% repo-wide (derived as 16419/18154 because only this production file changed). Change: +1.36 points file, +0.02 points repo-wide. New/changed-code coverage: 100% of executable lines in changed hunks. Disposition: PASS. Evidence: `evidence/baseline/ps-coverage-main.2026-10-16T01-23.md`, `artifacts/pester/powershell-coverage.xml`, CI run 38730332356 artifact `poshqc-test-results`.
- Python: Baseline: 93.72% lines repo-wide (main CI run 38730332356, 3.13 job TOTAL 17638 statements, 1108 not covered; branch threshold 75% enforced and passed) -> Post-change: no branch report; the expected value is 93.72% because the only changed Python file is under `tests/`, which coverage measurement excludes. Change: 0 measured files changed. New/changed-code coverage: 100% of changed production Python lines (0 production Python lines changed). Disposition: FAIL. Reason: the coverage verification rule requires a post-change artifact for every language with changed files, and `artifacts/python/lcov.info` does not exist on the branch. Classified `awaiting_ci`: the PR CI step `Enforce Python coverage thresholds` (`--min-line 85 --min-branch 75`) produces and gates it. Evidence: CI job 116406243603 log, `.github/workflows/_quality-checks.yml` lines 79-92.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Pester `Should -Be`/`-Match` with literal expected values; Python assertions carry f-string messages naming the script path and the offending fragment. |
| **Arrange-Act-Assert Pattern** | PASS | Each `It` block separates the response setup, the call, and the assertions with blank lines. |
| **Document Intent** | PASS | Context `all-checks classification` groups the new function-level tests, and a comment explains the response-index mock. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | `gh` is reached only through the mocked `Invoke-GhExe` seam; the Python pin reads repository text only. |
| **Use Mocks/Stubs** | PASS | Mocks: `Invoke-GhExe` (gh CLI), `Invoke-Sleep` (time), `Write-StderrLine` (message capture). |
| **Environment Stability** | PASS | No temporary files (`evidence/regression-testing/checkclassification-size.2026-10-16T01-37.md`: 0 matches for `New-TemporaryFile`, `Set-Content`, `Out-File`); no global state beyond `$script:` test fields. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit is the required review. Outstanding items: the two `awaiting_ci` findings in Section 8. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` (#931): align the release flow with the #899 all-checks rule. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.2026-10-16T00-08.md`; research `research/2026-10-15-release-flow-all-checks-research.md`. |
| **Document the plan** | PASS | `plan.2026-10-15T15-45.md`; all tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Classification is a single precedence chain (empty, fail, unknown, pending, pass); the loop branches on one verdict string. |
| **Reusability** | PASS | The parse helper is reused by the first poll and every re-poll, replacing two duplicated `ConvertFrom-Json` pipelines. |
| **Extensibility** | PASS | The bucket vocabulary is one `$known` array; the verdict object carries `Detail` for diagnostics. |
| **Separation of concerns** | PASS | Parsing and classification are pure functions; I/O stays in the `Invoke-GhExe`/`Invoke-Sleep`/`Write-StderrLine` seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Helpers live beside their only caller in the release-flow script. |
| **Under 500 lines** | PASS | `wc -l`: script 499, ChecksWait 297, CheckClassification 151, Tests 426, Python 298. The script has 1 line of headroom (code-review CR-1). |
| **Public vs internal** | PASS | No module manifest; the script's dot-sourced functions are unchanged except the two additions. |
| **No circular dependencies** | PASS | Helpers call only built-in cmdlets. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `ConvertFrom-CheckPollOutput`, `Get-CheckSetVerdict` (approved verbs `ConvertFrom`, `Get`). |
| **Docs/docstrings** | PASS | Both helpers carry a one-line `.SYNOPSIS`; `Wait-ForPullRequestChecks` help rewritten for all-checks semantics. |
| **Comment why, not what** | PASS | The `SuppressMessageAttribute` justification retains its rationale (#310 name binding). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `poetry run black --check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`: `1 file would be left unchanged.` (reviewer run). PoshQC format `ok:true`, no tracked-file change (`evidence/qa-gates/ps-format.2026-10-16T01-45.md`). |
| **2. Linting** | PASS | `poetry run ruff check ...`: `All checks passed!` (reviewer run). PoshQC analyze `ok:true` (`evidence/qa-gates/ps-analyze.2026-10-16T01-48.md`). |
| **3. Type checking** | PASS | `poetry run pyright ...`: exit 0, `0 errors, 0 warnings, 0 informations` (reviewer run). Not applicable to PowerShell. |
| **4. Architecture-boundary tests** | N/A | No architecture-boundary suite covers `scripts/dev-tools` PowerShell. |
| **5. Testing** | PASS | `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q`: `35 passed` (reviewer run). Local Pester `artifacts/pester/pester-junit.xml`: 654 tests, 0 failures, 0 errors; ChecksWait 19/19, CheckClassification 17/17, Tests 15/15, AdditionalFailurePaths 11/11. |
| **6. Contract / schema checks** | PASS | The Python contract pin `test_release_flow_waits_on_every_check_without_required_wording` failed before the edit (`1 failed`) and passed after (`1 passed`). |
| **7. Integration tests** | N/A | No integration suite exists for the release flow; `gh` is an external CLI. |
| **Full toolchain loop** | PASS | `evidence/qa-gates/qc-loop-pass.2026-10-16T01-51.md`: single pass, all seven artifacts exit 0. |
| **Explicit reporting** | PASS | Commands and exit codes are recorded in `evidence/` and Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Section 9. |
| **Design choices explained** | PASS | Plan `## Decisions` items 1-5; research sections 9 and 11. |
| **Update supporting documents** | PASS | Script header and function help updated; `.vscode/tasks.json` wording ("waits for gh checks") needs no change (`evidence/qa-gates/reference-search.2026-10-16T01-51.md`). |
| **Provide next steps** | PASS | Open the PR, then run the S9 procedure in `evidence/qa-gates/ac-verification.2026-10-16T01-51.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | Reviewer run: `1 file would be left unchanged.` Baseline and QA artifacts agree. |
| **Linting with Ruff** | PASS | Reviewer run: `All checks passed!` |
| **Type checking with Pyright** | PASS | Reviewer run: exit 0, `0 errors, 0 warnings, 0 informations`. |
| **Testing with Pytest** | PASS | Reviewer run: `35 passed` (baseline 34, plus one new test). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | New test annotated `-> None`; constants are typed by literal; no `Any`. |
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
| **Formatting with Invoke-Formatter** | PASS | `mcp__drm-copilot__run_poshqc_format` returned `ok:true`; porcelain before and after identical (`evidence/qa-gates/ps-format.2026-10-16T01-45.md`). |
| **Linting with PSScriptAnalyzer** | PASS | `mcp__drm-copilot__run_poshqc_analyze` returned `ok:true` (`evidence/qa-gates/ps-analyze.2026-10-16T01-48.md`). The MCP tool returns status only; the CI `poshqc / PowerShell QC` job is the result of record (awaiting PR CI). |
| **Fix all findings** | PASS | No finding was reported by the local call. |
| **PowerShell 7+ target** | PASS | `.claude/rules/powershell.md` targets PowerShell 7+. The parse helper relies on PowerShell 7 top-level-array enumeration in `ConvertFrom-Json` (plan Notes A3). |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | Both helpers use `[CmdletBinding()]` and `[OutputType([pscustomobject])]`. |
| **Parameter validation** | PASS | `Mandatory` parameters with `[AllowEmptyCollection()]` (and `[AllowNull()]`/`[AllowEmptyString()]` on `-Output`). |
| **Avoid global state** | PASS | No global or script-scope state added in production code. |
| **Error handling** | PASS | `ConvertFrom-Json -ErrorAction Stop` inside a `try` whose `catch` names `[System.ArgumentException]` (no bare catch); failures surface as `Succeeded = $false` and a stderr message plus exit 1. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | 499 / 297 / 151 / 426 lines. |
| **Approved verbs** | PASS | `ConvertFrom`, `Get`, `Wait` are approved verbs. |
| **Comment why** | PASS | Help text explains the poll scope and the timeout behavior. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | `ok:true`, no file changed. |
| **Step 2: Analyze** | PASS | `ok:true`. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | `ok:true`; local `pester-junit.xml` 654 tests, 0 failures (scoped to `tests/scripts/dev-tools`; the full suite runs in PR CI). |
| **Rerun loop if needed** | PASS | One pass; no restart (`evidence/qa-gates/qc-loop-pass.2026-10-16T01-51.md`). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Plain pytest function; no new fixtures. |
| **Coverage expectation** | FAIL (awaiting CI) | No post-change Python coverage report exists on the branch; see 1.2.1 and finding PA-2. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One test pins the release-flow script text. |
| **Mocking sparingly** | PASS | No mocks. |
| **Organization** | PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/` contract tests (existing module). |

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
| **Use Pester v5.x** | PASS | `Describe`/`Context`/`It`, `BeforeAll`/`BeforeEach`, `Mock`, `Should -Invoke`. |
| **Use PoshQC Configuration** | PASS | Run through `mcp__drm-copilot__run_poshqc_test`; `config/poshqc-scan.json` scans `tests/scripts`. |
| **PowerShell 7+ Compatible** | PASS | Local run on PowerShell 7 passed; CI `windows-latest` job is the record. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 10 verdict tests, 7 parse tests, 13 new loop tests. |
| **Test Behavior Over Implementation** | PASS | Assertions target return codes, stderr text, and `gh`/sleep call counts. |
| **Mocking Used Sparingly** | PASS | Only the three I/O seams are mocked; helper tests use none. |
| **Organization** | PASS | Test files `tests/scripts/dev-tools/Invoke-FullReleaseFlow.*.Tests.ps1` mirror `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** | PASS | `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | CheckClassification: 2 Describe blocks (10 + 7 It). ChecksWait: 1 Describe, new Context with 13 It. |
| **Logical Grouping** | PASS | Unit-level helper tests are separate from function-level loop tests. |
| **Docstrings/Comments** | PASS | Test titles are self-describing. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | MCP `run_poshqc_test` `ok:true`. |
| **No Alternative Test Runners** | PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### ConvertFrom-CheckPollOutput (7 direct tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| parses a JSON array into check objects | Positive | 162-194 | PASS |
| parses an empty JSON array as an empty successful result | Edge Case | 162-194 | PASS |
| joins multi-line output before parsing | Positive | 177-194 | PASS |
| reports failure for blank output | Negative | 177-180 | PASS |
| reports failure for text that is not JSON | Error Handling | 181-186 | PASS |
| reports failure for a null element | Negative | 187-191 | PASS |
| reports failure for a scalar element | Negative | 187-191 | PASS |

**Coverage:** 100% of the function's executable lines (local JaCoCo report).

**Not covered:** None.

### Get-CheckSetVerdict (10 direct tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| reports pass for a set of pass buckets | Positive | 196-235 | PASS |
| reports pass for a set of pass and skipping buckets | Positive | 196-235 | PASS |
| reports pending when a pending bucket accompanies pass buckets | Positive | 196-232 | PASS |
| reports fail for a fail bucket | Negative | 196-222 | PASS |
| reports fail for a cancel bucket | Negative | 196-222 | PASS |
| reports fail ahead of pending and unknown buckets | Edge Case | 196-222 | PASS |
| reports unknown for a bucket outside the vocabulary | Negative | 196-228 | PASS |
| reports unknown for a missing bucket property | Negative | 196-228 | PASS |
| reports unknown for a bucket that differs only in case | Edge Case | 196-228 | PASS |
| reports empty for an empty check set | Edge Case | 196-208 | PASS |

**Coverage:** 100% of the function's executable lines.

**Not covered:** None by line. The `$null` element alternative and the blank-string bucket alternative share lines with tested paths and have no dedicated test (code-review CR-2, Minor).

### Wait-ForPullRequestChecks (19 tests: 6 existing, 13 new)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| polls gh pr checks without the required flag | Positive | 301-336 | PASS |
| returns failure when a non-required check fails | Negative | 315-327 | PASS |
| returns failure when a check is cancelled | Negative | 315-327 | PASS |
| keeps polling and times out on an empty check set | Edge Case | 315-357 | PASS |
| returns failure on an unrecognized bucket | Negative | 315-333 | PASS |
| returns failure on a check with no bucket property | Negative | 315-333 | PASS |
| reports a failed check ahead of an unrecognized bucket | Edge Case | 315-327 | PASS |
| returns success when buckets are a mix of pass and skipping | Positive | 315-336 | PASS |
| returns success when every bucket is skipping | Positive | 315-336 | PASS |
| returns failure without throwing on unparsable check output | Error Handling | 315-319 | PASS |
| continues after a non-zero completion poll | Error Handling | 340-357 | PASS |
| continues after an unparsable completion poll | Error Handling | 340-357 | PASS |
| times out when completion polls keep failing | Error Handling | 338-357 | PASS |

**Coverage:** 100% of the function's executable lines (baseline 26/26 per method counter; post-change fully covered).

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (local Pester, scoped) | 654 | PASS |
| Tests Passed (local Pester) | 652 (2 disabled), 0 failed | PASS |
| Release-flow Pester tests | 62 (19 + 17 + 15 + 11), 0 failed | PASS |
| Python tests (changed module) | 35 passed, 0 failed | PASS |
| Execution Time (Python module) | 0.10 s | PASS |
| Functions Tested (release-flow script) | 8 of 12 functions executed (4 uncovered are the mocked process seams) | PASS |
| Test File Size | 297 / 151 / 426 / 298 lines | PASS |
| Code Coverage (release-flow script) | 95.62% lines; PowerShell has no branch metric | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` | 1 file would be left unchanged | PASS |
| Ruff Linting | `poetry run ruff check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` | 0 errors, 0 warnings, 0 informations | PASS |
| Pytest Tests | `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q` | 35 passed | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | ok:true, no tracked change | PASS |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | ok:true | PASS |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` (scan folder `tests/scripts/dev-tools`) | ok:true; junit 654 tests, 0 failures | PASS |

**Notes:**
The PoshQC MCP tools return a status summary only. The PR CI job `poshqc / PowerShell QC` is the result of record for AC6. The local Pester run was scoped to `tests/scripts/dev-tools` because a full-suite call exceeds the MCP idle timeout on this host (`evidence/qa-gates/ps-test.2026-10-16T01-50.md`). As a result, the local repo-wide PowerShell figure (4.34%) reflects that scoping and is not used.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (Blocking, awaiting_ci): AC6 CI-of-record clause pending.** AC6 requires a PoshQC pass and no line-coverage regression for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` against the Phase 0 baseline (94.26%). Local evidence shows 95.62% and 0 failures, but the plan designates the PR CI artifact `poshqc-test-results` as the record. No PR or CI run exists for the branch (`gh pr list --head ...` returned `[]`; `gh run list --branch ...` returned `[]`). Clearing condition: run S9 steps 1-6 in `evidence/qa-gates/ac-verification.2026-10-16T01-51.md`.
- **PA-2 (Blocking, awaiting_ci): Python post-change coverage report absent.** Python has one changed file (a test module), and no `artifacts/python/lcov.info` exists. The baseline is 93.72% line coverage repo-wide, with the branch gate passed at the merge base. The branch changes no measured Python file. Clearing condition: the PR CI job `quality-checks7 / Code Quality & Tests (3.13)` step `Enforce Python coverage thresholds` concludes `success`, and its pytest `TOTAL` line is recorded.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests are implemented (P1-T16 to P1-T22; title counts verified in `evidence/regression-testing/checkswait-size.2026-10-16T01-36.md` and `checkclassification-size.2026-10-16T01-37.md`).

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

### Files Modified

1. **scripts/dev-tools/Invoke-FullReleaseFlow.ps1** (MODIFIED)
   - Drops `--required` from the poll; adds `ConvertFrom-CheckPollOutput` and `Get-CheckSetVerdict`; rewrites Phase B around the verdict; guards both parse sites; rewrites header, help text, and the suppression justification.
2. **tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1** (NEW)
   - 17 direct helper tests.
3. **tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1** (MODIFIED)
   - One message update; new Context with 13 tests.
4. **tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1** (MODIFIED)
   - Four argument-string updates and one message update.
5. **tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py** (MODIFIED)
   - New constants and one release-flow contract pin.
6. **docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/** (NEW)
   - Issue, research, plan, and 40 evidence artifacts.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT (awaiting PR CI)

Every policy requirement that can be verified locally passes. Two Blocking findings remain, both classified `awaiting_ci`: PA-1 (the AC6 CI-of-record clause) and PA-2 (the Python post-change coverage report). Neither requires a branch change. Both clear when the PR CI run on the final head concludes `success` and the S9 procedure records the results.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: issue, research, and plan present.
- PASS Design Principles: pure helpers, I/O in seams.
- PASS Module & File Structure: all files at or under 500 lines (script at 499).
- PASS Naming, Docs, Comments: approved verbs; help text updated.
- PASS Toolchain Execution: single clean loop.
- PASS Summarize & Document: commits and evidence recorded.

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
- PARTIAL Coverage & Scenarios: PowerShell PASS; Python post-change report awaiting CI (PA-2)
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PARTIAL Framework & Scope: coverage awaiting CI (PA-2)
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

- PASS 62 of 62 release-flow Pester tests passing (local); 35 of 35 Python module tests passing
- PASS 95.62% line coverage for the modified PowerShell script (baseline 94.26%)
- PASS 100% of executable lines in changed hunks covered
- PASS All local code quality checks passing
- PARTIAL PR CI results pending (PA-1, PA-2)

---

### Recommendation

**Ready to open the PR.** Merge after the PR CI run reports `success`. Then run the AC6 S9 procedure: download `poshqc-test-results`, confirm a per-file percentage of at least 94.26%, confirm 19 ChecksWait and 17 CheckClassification passes, and check off AC6. Record the Python `Enforce Python coverage thresholds` step result. No autonomous remediation is required.

---

## Appendix A: Test Inventory

### Complete Test List

1. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports pass for a set of pass buckets
2. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports pass for a set of pass and skipping buckets
3. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports pending when a pending bucket accompanies pass buckets
4. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports fail for a fail bucket
5. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports fail for a cancel bucket
6. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports fail ahead of pending and unknown buckets
7. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports unknown for a bucket outside the vocabulary
8. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports unknown for a missing bucket property
9. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports unknown for a bucket that differs only in case
10. Invoke-FullReleaseFlow.ps1 - Get-CheckSetVerdict > reports empty for an empty check set
11. Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput > parses a JSON array into check objects
12. Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput > parses an empty JSON array as an empty successful result
13. Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput > joins multi-line output before parsing
14. Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput > reports failure for blank output
15. Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput > reports failure for text that is not JSON
16. Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput > reports failure for a null element
17. Invoke-FullReleaseFlow.ps1 - ConvertFrom-CheckPollOutput > reports failure for a scalar element
18. Invoke-FullReleaseFlow.ps1 - Wait-ForPullRequestChecks > all-checks classification > the 13 tests listed in Section 5
19. Invoke-FullReleaseFlow.ps1 - Wait-ForPullRequestChecks > the 6 pre-existing tests (one message assertion updated)
20. Invoke-FullReleaseFlow.ps1 - Invoke-FullReleaseFlowGuarded > 15 tests in `Invoke-FullReleaseFlow.Tests.ps1` (argument strings and one message updated) and 11 tests in `AdditionalFailurePaths` (unchanged)
21. tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py::test_release_flow_waits_on_every_check_without_required_wording

---

## Appendix B: Toolchain Commands Reference

**Reviewer-run commands (2026-10-16, worktree at `f73457642`):**
```bash
git diff --stat adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99..HEAD
poetry run black --check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
poetry run ruff check tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
poetry run pyright tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q -p no:cacheprovider
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
gh run download 38730332356 -R drmoisan/drm-copilot -n poshqc-test-results -D <scratchpad>/dl-main-poshqc
gh run view 38730332356 -R drmoisan/drm-copilot --job 116406243603 --log
gh pr list --head bug/release-flow-waits-on-required-checks-only-931 --json number,state,url
gh run list --branch bug/release-flow-waits-on-required-checks-only-931 --limit 5
python -I <scratchpad>/jacoco931.py artifacts/pester/powershell-coverage.xml
python -I <scratchpad>/junit931.py artifacts/pester/pester-junit.xml
```

**Executor-run PowerShell commands (recorded in evidence):**
```powershell
# mcp__drm-copilot__run_poshqc_format  (workspace_root = worktree)
# mcp__drm-copilot__run_poshqc_analyze (workspace_root = worktree)
# mcp__drm-copilot__run_poshqc_test    (workspace_root = worktree, scan folder tests/scripts/dev-tools)
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)

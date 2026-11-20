# Policy Compliance Audit: PowerShell six-shard QC and Python 3.13 two-shard coverage (Issue #1190)

---

**Audit Date:** 2026-11-15
**Code Under Test:** merge base `11c6ecde2e3080722c90bc63289bc160bf9596ea` of `origin/main` and reviewed head `497bf51abae3ecbdf8845b4d799fd72a5930f8f2` on `feature/ci-shard-powershell-and-python`; the diff between them lists the changed files.
- PowerShell production: `scripts/ci/Select-PythonTestShard.ps1` (new, 282 logical lines)
- PowerShell tests: `tests/scripts/ci/Select-PythonTestShard.Tests.ps1` (new, 285 logical lines), `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
- Python tests: `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` (532 logical lines), `test_execution_environment_brief_contracts.py`, `test_host_environment_contracts.py`; no production Python file
- Workflows: `.github/workflows/_poshqc.yml`, `.github/workflows/_quality-checks.yml`, `.github/workflows/README.md`
- Skill and brief copies: `execution-environment/SKILL.md` (six byte-identical copies) and `atomic-plan-contract/SKILL.md` (two copies)
- Feature folder documents and evidence

Scope: full branch diff `11c6ecde2..497bf51ab` against `origin/main` (merge base equals the `origin/main` tip, so the branch is current with the base). Changed-file inventory taken from `git diff --name-only` over that range; PR context at `artifacts/pr_context.summary.txt`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 1 production script, 3 test files | 26885 tests at the final gate (30 new helper tests) | 0 failures, 0 errors | 96.01% lines (covered 44274, missed 1840) | 96.00% lines (covered 44336, missed 1847) | 89.86% lines (62 of 69) for `Select-PythonTestShard.ps1` |
| Python | 3 test files, no production Python | 16949 passed, 6 skipped | 0 failures | 97% total (35910 statements, 810 missed; 13688 branches, 551 partial) | 97% total (35910 statements, 810 missed; 13688 branches, 552 partial) | 100% (vacuous; no production Python line changed) |

The two workflow files and the README are YAML and Markdown configuration; they are verified through the contract tests and CI run 43736520255 (see Section 3C), not through a coverage row. Languages with zero changed files on the branch: TypeScript, C#, Bash. Coverage verdicts for those languages are N/A.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - zero changed TypeScript files`
- TypeScript post-change coverage artifact: `N/A - zero changed TypeScript files`
- PowerShell baseline coverage artifact: `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/evidence/baseline/pester-gate.2026-11-14T23-30.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-11-15 01:16Z by the final gate, after the last code commit), summarized in `evidence/qa-gates/final-pester.2026-11-15T01-16.md`
- Python baseline coverage artifact: `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/evidence/baseline/pytest-gate.2026-11-14T23-34.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (present, 386 source records), summarized in `evidence/qa-gates/final-pytest.2026-11-15T01-16.md`
- Per-language comparison summary: Section 1.2.1 below

Assumptions recorded: the review did not rerun any coverage generation (evidence model). Local artifact times are Eastern (20:13 and 20:16 on 2026-11-14), which equal the final-gate stamps 01:16Z on 2026-11-15; the code commits precede the gate and the head commits after it (`5e8085e4b`, `497bf51ab`) change only feature-folder documents. The `Select-PythonTestShard.ps1` sourcefile entry is present in the Pester coverage artifact.

---

## Executive Summary

The branch raises the PowerShell QC matrix from three to six shards, splits the Python 3.13 leg into a static job, a two-shard coverage job, and a combine job that keeps the required context name, and adds a PowerShell helper with 30 Pester tests. Static gates, the Pester and pytest gates, byte-parity of the brief copies, and CI run 43736520255 (every job green, including `CI Required Gate`) all verify. Coverage thresholds are met, the helper reuses the existing `PoshQC.Shard.psm1`, no Python script was added, and the Python coverage threshold step and the Codecov upload run unchanged on the combined data.

One blocking finding is raised: the measured PowerShell leg duration (longest shard 13.6 minutes) does not meet the roughly 11 minute target of the issue (acceptance criterion AC12 and user-story criterion U5), and the shard spread (7.4 to 13.6 minutes) exceeds the plan's own 20 percent trigger for weights regeneration. The classification and remedy are in the feature audit and the remediation inputs.

**Policy documents evaluated:**
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `scripts/ci` is classified; the tier-classification step ran in CI run 43736520255)
- PASS `.claude/rules/ci-workflows.md` modified-workflow green-run requirement (workflow_dispatch run 43736520255 succeeded on the code head `5e8085e4b`; the later head differs only by feature-folder documents)

**Language-specific policies evaluated:**
- PASS Python (test-only changes)
- PASS PowerShell
- PASS GitHub Actions (actionlint 1.7.12 exit 0)
- N/A Bash: no shell file changed

**Temporary artifacts cleanup:**
- PASS No temporary script is committed; the diff lists no scratch file
- PASS No tooling script beyond the product helper was added

---

## Rejected Scope Narrowing

The caller prompt directs the reviewer to read the final quality-control artifacts instead of re-running format, lint, and type checks. That is the evidence model of this review (coverage and gate artifacts are inspected, not regenerated), not a narrowing of scope to a plan, phase, file subset, or language, and no check for any language with changed files was skipped. The caller also asks for a classification of the shard-balance finding; that is a classification request and does not narrow the audit. No scope narrowing was detected.

---

## Evidence Location Compliance

`git diff --name-only 11c6ecde2..497bf51ab` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence sits under `<FEATURE>/evidence/{baseline,other,qa-gates}/`. `validate_evidence_locations --root .` printed no violation. Result: PASS, no violations.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | The helper tests use in-memory seams only; the final Pester gate ran 26885 tests in one parallel run with 0 failures. |
| **Isolation** | PASS | Each named case (SH01 to SH10) targets one behavior. |
| **Fast Execution** | PASS | No process, sleep, or file system access in the new tests; the test file has no `Set-Content`, `TestDrive`, `New-TemporaryFile`, or `Start-Sleep` (searched). |
| **Determinism** | PASS | SH02 (repeated and reversed enumeration) and SH03 (CRLF equals LF) pin deterministic assignment. |
| **Readability & Maintainability** | PASS | Case ids in the `It` names. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `evidence/baseline/pester-gate.2026-11-14T23-30.md` and `pytest-gate.2026-11-14T23-34.md`. |
| **No Coverage Regression** | PASS | No file with a baseline lost coverage: `PoshQC.Shard.psm1` 100% to 100%, `Invoke-CiRequiredGate.ps1` 90% to 90%. Repo-wide PowerShell 96.01% to 96.00% is the 7 uncovered entry lines of the new file. |
| **New Code Coverage** | PASS | `Select-PythonTestShard.ps1` is a new file at 89.86% (62 of 69) against the 85% line threshold (the root `CLAUDE.md` states none, so defaults govern). No branch threshold applies to PowerShell. |
| **Comprehensive Coverage** | PASS | The seven uncovered lines are parameter defaults, default seam bodies, and the guarded entry call. |
| **Positive Flows** | PASS | SH01, SH02, SH06, SH09 pass case. |
| **Negative Flows** | PASS | SH05 empty shard throws; SH08 no summary line throws. |
| **Edge Cases** | PASS | SH03 CRLF, SH04 size weighting, SH07 weights file ignored. |
| **Error Handling** | PASS | SH09 absent file, duplicate file, JUnit-sum mismatch; SH10 exit code one. |
| **Concurrency** | N/A | No concurrent behavior in the helper. |
| **State Transitions** | N/A | Stateless helper. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 96.01% lines repo-wide (covered 44274, missed 1840) -> Post-change: 96.00% lines (covered 44336, missed 1847). Change: -0.01 percentage points, wholly the 7 uncovered lines of the new file; no existing file dropped. New/changed-code coverage: 89.86% (62 of 69 lines in the new shard helper script). Pester reports no branch counter, so the line threshold governs. Disposition: PASS. Evidence: `evidence/qa-gates/final-pester.2026-11-15T01-16.md`, `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: 97% total (35910 statements, 810 missed; 13688 branches, 551 partial) -> Post-change: 97% total (identical statements and misses, 552 partial branches). Change: +0.00 percentage points on statements; one partial branch of run-to-run parallel variance in code this feature does not change. New/changed-code coverage: 100% (vacuous, no production Python line changed). The repo-wide line and branch thresholds are enforced in CI by the unchanged threshold step. Disposition: PASS. Evidence: `evidence/qa-gates/final-pytest.2026-11-15T01-16.md`, `artifacts/python/lcov.info`, CI Cross-check below.
- TypeScript, C#, Bash: zero changed files on the branch. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions carry `-Because` text in the workflow tests. |
| **Arrange-Act-Assert Pattern** | PASS | Helper tests follow the structure. |
| **Document Intent** | PASS | Case ids state the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | All I/O through injected seams (`EnumerateTestFile`, `ReadTestFileText`, `WriteFile`, `FindFile`, `ReadText`). |
| **Use Mocks/Stubs** | PASS | In-memory fixtures; no temp file (parallel-only and no-temp-file standing rules respected; `--collect-only` runs no test). |
| **Environment Stability** | PASS | No environment variable written by the tests. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit; executor self-review `evidence/qa-gates/self-review.2026-11-15T01-24.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #1190, `spec.md`, `user-story.md`, research note. |
| **Read existing change plans** | PASS | `plan.2026-11-14T17-45.md`; all tasks checked. |
| **Document the plan** | PASS | Plan present with phase gates. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The helper reuses `Select-PoshQCShardTestFile`, `Test-PoshQCShardCompleteness`, and `Test-PoshQCShardTestCount` unchanged. |
| **Reusability** | PASS | PoshQC module unchanged; its mirror copies unchanged. |
| **Extensibility** | PASS | The shard count is written only in the workflow matrix; the helper takes it as a parameter. |
| **Separation of concerns** | PASS | Pure selection and verification functions are separate from the seam boundaries and the guarded entry. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **At or below the 800-line hard limit** | PASS | Logical line counts (awk NR): `Select-PythonTestShard.ps1` 282, `Select-PythonTestShard.Tests.ps1` 285, `test_quality_checks_workflow_contracts.py` 532. No covered file reaches 700 lines. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | PASS | New helper is a CI script, not a public module. |
| **No circular dependencies** | PASS | The script imports the existing module only. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Approved-verb function names with comment-based help on every function. |
| **Docs/docstrings** | PASS | Script synopsis, description, and parameter help present. |
| **Comment why, not what** | PASS | Workflow comments state the reason (non-dot coverage file name, always-run combine job). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `evidence/qa-gates/final-qc-static-powershell.2026-11-15T01-16.md` and `final-qc-static-python.2026-11-15T01-16.md` (read, not rerun). |
| **2. Linting** | PASS | Same records: PSScriptAnalyzer and Ruff exit 0. |
| **3. Type checking** | PASS | Pyright exit 0 over the whole tree; PowerShell has no type stage. |
| **4. Testing** | PASS | Pester 26885 tests and pytest 16949 passed, 0 failures. |
| **Full toolchain loop** | PASS | Final gates at 2026-11-15T01-16; phase gates P1 to P3. |
| **Explicit reporting** | PASS | Each gate record carries `Command:` and `EXIT_CODE:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages and `.github/workflows/README.md` rows 22 to 27 and the restructure paragraph. |
| **Design choices explained** | PASS | Research note and spec Behavior. |
| **Update supporting documents** | PASS | Brief copies, plan contract copies, README. |
| **Provide next steps** | PASS | Shard-balance tuning recorded in `evidence/other/ci-measurement.2026-11-15T17-20.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black / Ruff / Pyright** | PASS | `final-qc-static-python.2026-11-15T01-16.md`, exit 0. |
| **No new Python script** | PASS | The diff adds no `.py` file; the one modified Python test file already existed. |
| **Dependencies** | PASS | `pyproject.toml` and `poetry.lock` are not in the diff. |

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | `final-qc-static-powershell.2026-11-15T01-16.md`. |
| **Linting with PSScriptAnalyzer** | PASS | Same record. |
| **ShouldProcess on state-changing function** | PASS | `Write-PythonShardFileText` declares `SupportsShouldProcess` and calls `ShouldProcess` (inspected by hand, because the analyzer rule ignores the Write verb). |
| **Strict mode and approved verbs** | PASS | `Set-StrictMode -Version Latest`; verbs `Get`, `Read`, `Write`, `Find`, `Test`, `Invoke`. |

### Section 3C: GitHub Actions Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **actionlint** | PASS | actionlint 1.7.12 over both workflows exit 0 (`task-check.P2-T2` and the final static record). |
| **Pinned toolchain versions** | PASS | Poetry `2.5.1` in every new job; actions use the same major pins as the existing jobs. |
| **Modified workflow has a green run** | PASS | Run 43736520255, every job green, on the code head. |
| **Every step gated on run-heavy** | PASS | Each step of `python-static-313`, `python-coverage-shard`, and `python-coverage-combine` carries `inputs.run-heavy`; the pinning test covers all three jobs. |
| **Expression use in run scripts** | PASS | The combine first step interpolates only `needs.<job>.result` enumerations; no untrusted input reaches a script. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest** | PASS | Eight new named contract tests plus updated dispositions, loading jobs by id from the YAML. |
| **Parallel-only** | PASS | The gate ran `pytest -n auto`; no serial run is introduced. |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x or later** | PASS | Run through the repository launcher. |
| **File Naming and Structure** | PASS | `tests/scripts/ci/Select-PythonTestShard.Tests.ps1` mirrors `scripts/ci/Select-PythonTestShard.ps1`. |
| **Focused Unit Tests** | PASS | 30 cases SH01 to SH10. |

---

## 5. Test Coverage Detail

### Select-PythonTestShard.ps1 (SH01 to SH10)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| SH01 to SH04 | Positive / Edge Case | `Get-PythonTestShardSelection` weighting and ordering | PASS |
| SH05 | Negative | empty-shard throw | PASS |
| SH06, SH07 | Positive | manifest write, weights-file isolation | PASS |
| SH08 | Positive / Negative | `Get-PythonCollectedTestCount` | PASS |
| SH09 | Positive / Negative | `Test-PythonTestShardResult` | PASS |
| SH10 | Positive / Error Handling | `Invoke-PythonTestShardEntry` exit codes | PASS |

**Coverage:** 89.86% (62 of 69). **Not covered:** the `RootPath` parameter default, the default seam bodies in the entry function parameters, and the guarded entry call (7 lines).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Pester 26885; pytest 16949 passed, 6 skipped | PASS |
| Tests Failed | 0 | PASS |
| Test File Size | largest test file 532 logical lines | PASS at or below 800 lines |
| Code Coverage | PowerShell 96.00%; helper 89.86%; Python 97% total | PASS |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | formatter check over `scripts/ci`, `tests/scripts/ci`, `tests/scripts/workflows` | 0 differences | PASS |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with `pssa.settings.psd1` | 0 findings | PASS |
| Pester Tests | launcher pester suite, one parallel run | 26885 tests, 0 failures | PASS |

**For Python and workflows:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black, Ruff, Pyright | whole tree from the worktree root | exit 0 | PASS |
| Pytest | launcher pytest suite, `-n auto` with coverage | 16949 passed | PASS |
| actionlint | version 1.7.12 over both workflows | exit 0 | PASS |

**Notes:** Quality checks were read from the final-QC artifacts (the review did not rerun them). Review-time commands: `git diff` of both workflows, README, and test files; byte comparison of the six `execution-environment` copies and two `atomic-plan-contract` copies (identical); logical line counts; a search of the new test file for banned constructs; `validate_evidence_locations`.

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| Enforce Python coverage thresholds (combine job) | pass | thresholds 85 line and 75 branch; the step is silent on success | `5e8085e4b` | `evidence/other/ci-measurement.2026-11-15T17-20.md`, run 43736520255 |
| Code Quality & Tests (3.13) combine job | pass | 1.8 minutes | `5e8085e4b` | same run |
| PowerShell QC aggregator (completeness, coverage merge, discovery count) | pass | 1.8 minutes | `5e8085e4b` | same run |
| CI Required Gate | pass | all jobs green | `5e8085e4b` | same run |

The reviewed head `497bf51ab` differs from `5e8085e4b` only by feature-folder documents (`git diff --name-only 5e8085e4b..497bf51ab`). Local evidence agrees with the claimed outcomes (outcome pass).

---

## 8. Gaps and Exceptions

### Identified Gaps

- Blocking: the PowerShell leg duration target is not met (longest shard 13.6 minutes against about 11); see the feature audit and remediation inputs.
- Non-blocking: the Python shard spread is 6.0 against 9.4 minutes; the Python leg meets the target (critical path 11.3 minutes), so no action is required. `test_quality_checks_workflow_contracts.py` is 532 logical lines, above the 500-line guidance tier and below the 700-line advisory tier (no finding at this tier; the plan expected it to stay under 500).

### Approved Exceptions

**None.** No coverage exclusion, suppression, or skipped test was introduced.

### Removed/Skipped Tests

**None.**

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. The 13 commits in `11c6ecde2..497bf51ab` (`git rev-list --count`): plan and preflight records, baselines, helper and tests, workflow restructure, brief and README updates, final QA records, and the CI measurement record.

### Files Modified

1. `.github/workflows/_poshqc.yml`: matrix `[1, 2, 3, 4, 5, 6]`.
2. `.github/workflows/_quality-checks.yml`: compatibility matrix `["3.11", "3.12"]`, plus static, shard, and combine jobs.
3. `scripts/ci/Select-PythonTestShard.ps1` and its Pester tests.
4. Pinning tests (workflows, brief contracts, host-environment contract).
5. Six `execution-environment` copies, two `atomic-plan-contract` copies, and `.github/workflows/README.md`.

---

## 10. Compliance Verdict

### Overall Status: PARTIAL COMPLIANCE (one blocking finding)

Toolchain, coverage, file size, evidence location, mirror parity, determinism, dependency, and workflow requirements are met. The measured PowerShell leg duration does not meet the issue target, which is a feature acceptance gap and not a policy violation; it is carried as the blocking finding of the feature audit.

**Fail-closed reminder:** every required baseline artifact, QA artifact, coverage metric, and coverage-comparison artifact is present.

### Metrics Summary

- PASS 0 Pester and pytest failures
- PASS helper coverage 89.86% (new-file threshold 85%)
- PASS Python repo-wide thresholds enforced green in CI
- PARTIAL longest PowerShell shard 13.6 minutes against about 11

### Recommendation

**Remediation required** before pull request creation: tune the PowerShell shard weights and re-measure.

---

## Appendix A: Test Inventory

1. Select-PythonTestShard › SH01 to SH10 (30 cases)
2. PoshQcWorkflow › six-shard matrix case
3. CiChangeScopeWorkflow › run-heavy gating for `python-static-313`, `python-coverage-shard`, `python-coverage-combine`
4. test_quality_checks_workflow_contracts › eight new contract tests plus updated dispositions

---

## Appendix B: Toolchain Commands Reference

**Commands run during this review (read-only):**
```bash
git diff --name-only 11c6ecde2..HEAD
git diff 11c6ecde2..HEAD -- .github/workflows/_quality-checks.yml .github/workflows/_poshqc.yml
cmp (six execution-environment copies, two atomic-plan-contract copies)
awk 'END{print NR}' on the three new or large files
validate_evidence_locations --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-15
**Policy Version:** Current (as of audit date)

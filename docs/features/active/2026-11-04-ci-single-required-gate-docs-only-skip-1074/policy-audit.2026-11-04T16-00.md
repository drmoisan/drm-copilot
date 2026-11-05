# Policy Compliance Audit: CI single required gate (Issue #1074)

**Audit Date:** 2026-11-04
**Reviewer:** feature-review
**Scope:** Entire feature branch `bug/ci-single-required-gate` versus `main`, merge base 11f188d1b4f3726d854ddc00f8ad4c810138f049; reviewed head cd5923ff8330dba3afb7b970d1b5476e8e559e4d (43 files, 2624 insertions, 53 deletions).
**Template provenance:** The MCP template resolver tool was not available in this reviewer's tool set, so the artifact structure follows the canonical policy-audit headings enforced by `scripts/dev_tools/validate_policy_audit_artifact.py` and the layout of prior validated audits in this repository. This is recorded as an assumption.
**Evidence roots:** Paths beginning `evidence/` are relative to this feature folder. PCOV=evidence/qa-gates/pester-coverage.2026-11-04T15-49.md; DELTA=evidence/qa-gates/coverage-delta.2026-11-04T15-49.md; BASE=evidence/baseline/pester-ci-workflows.2026-11-04T15-28.md; SHUF=evidence/qa-gates/isolation-shuffle.2026-11-04T15-51.md; CONTRACT=evidence/qa-gates/contract-tests-final.2026-11-04T15-50.md.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 2 production (new); 3 test (new) | 410 Pester tests in tests/scripts/ci and tests/scripts/workflows (reviewer rerun) | PASS; 0 failures | scripts/ci existing files 93.57% and 91.15% lines (BASE) | CiRequiredGate.psm1 100%; Invoke-CiRequiredGate.ps1 90% (PCOV, recorded); raw artifact at HEAD overwritten; repo-wide figure N/A until CI | 117 of 120 new lines = 97.5% (recorded) |
| Python | 1 test file modified; 0 production files | 92 contract tests (reviewer rerun) | PASS; 0 failures | N/A - artifacts/python/lcov.info absent | N/A - artifacts/python/lcov.info absent; CI Python 3.13 threshold step is the source | N/A - no production Python changed |
| YAML (GitHub Actions) | 1 workflow (ci.yml, one job added) | CiRequiredGateWorkflow 5, CiWorkflow 4, CiChangeScopeWorkflow 40, PoshQcWorkflow 15; actionlint | PASS locally; FAIL awaiting a green ci.yml run | N/A - declarations carry no line instrumentation | N/A - declarations carry no line instrumentation | N/A - no executable code |
| TypeScript | 0 | None required | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- PowerShell baseline coverage artifact: evidence/baseline/pester-ci-workflows.2026-11-04T15-28.md (read from artifacts/pester/powershell-coverage.xml at the P0-T4 run).
- PowerShell post-change coverage artifact: evidence/qa-gates/pester-coverage.2026-11-04T15-49.md records the branch-current figures. The raw artifacts/pester/powershell-coverage.xml now on disk was rewritten at 15:53 UTC by a later 40-test run (hook-docs-only-diff and PoshQC.RunSettings suites) and reports CiRequiredGate.psm1 at 0 of 90 lines, so it no longer describes the P6-T3 run.
- Per-language comparison summary: evidence/qa-gates/coverage-delta.2026-11-04T15-49.md.

Explicit coverage verdicts: PowerShell FAIL (awaiting_ci: the raw artifact at HEAD does not describe the recorded run and no repo-wide figure exists for the branch); Python FAIL (awaiting_ci: coverage artifact absent; the Python 3.13 CI job enforces the 85/75 thresholds); YAML has no coverage instrumentation; TypeScript N/A because zero TypeScript files changed. No language with changed files was waived or narrowed.

Thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults govern (line >= 85%, branch >= 75% for branch-capable languages). PowerShell has no branch gate. `quality-tiers.yml` exists and classifies `scripts/ci` as T4, so no tier-dependent gate (property tests, mutation score, golden tests) applies to the new files.

## Executive Summary

The branch adds a `ci-required-gate` job (`CI Required Gate`) to `.github/workflows/ci.yml`, a pure decision module `scripts/ci/CiRequiredGate.psm1`, an entry script `scripts/ci/Invoke-CiRequiredGate.ps1` with I/O seams, three Pester suites, an updated Python brief-contract test, documentation updates in six byte-identical brief copies, two `atomic-plan-contract` copies and `.github/workflows/README.md`, and a ruleset runbook. Reviewer reruns at the head confirm: 410 Pester tests pass, 92 Python contract tests pass, Invoke-Formatter reports no difference and PSScriptAnalyzer reports 0 findings on all five new PowerShell files, actionlint reports 0 findings, and Black and Ruff are clean on the edited Python test. No autonomous defect was identified. The review verdict is AWAITING_CI: the modified workflow has no green run at the branch head (no pull request exists yet, and the Codespace token cannot dispatch workflows), the coverage gates for PowerShell and Python depend on CI-produced artifacts, and seven CI-dependent acceptance criteria (proof steps A to E and the runbook context-name entry) are pending by design.

## 1. General Unit Test Policy Compliance

The new suites use in-memory JSON fixtures, injected `-ReadVariable` and `-OutputWriter` seams, and Pester mocks of `Add-Content`, `Write-Information` and the environment wrapper. No temporary file, process, or network call is made in the tests.

### 1.1 Core Principles

| Requirement | Status | Evidence |
|---|---|---|
| Independence | PASS | SHUF: three seeded file-order shuffles (11, 42, 1074) over four suites, 166 tests each, 0 failures. |
| Isolation | PASS | Each `It` targets one decision rule (RG01 to RG13), one seam (IG01 to IG07) or one workflow invariant (WG01 to WG05). |
| Fast Execution | PASS | The new suites are pure in-memory evaluations; the 410-test reviewer rerun over tests/scripts/ci and tests/scripts/workflows completed within a few minutes on the Linux Codespace (exact duration not recorded). |
| Determinism | PASS | No clock, randomness or environment read in the code under test; the real NEEDS_JSON and GITHUB_STEP_SUMMARY are never touched (Invoke-CiRequiredGate.Tests.ps1 IG07 mocks the wrapper). |
| Readability & Maintainability | PASS | Test ids carry rule codes and AC references; each case uses Arrange, Act and Assert sections with `-Because` messages. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|---|---|---|
| Baseline Coverage Documented | PASS | BASE records CiChangeScope.psm1 93.57% and Invoke-CiChangeScope.ps1 91.15% before the change. |
| No Coverage Regression | FAIL | DELTA records no regression, but the raw artifact on disk no longer describes that run and no repo-wide PowerShell or Python figure exists for the branch; classified awaiting_ci (finding F2 and F3). |
| New Code Coverage >= 85% | FAIL | Recorded figures are 100% and 90% (PCOV); the raw artifact at HEAD was rewritten by a later run, so the figures cannot be re-read from it; classified awaiting_ci (finding F2). |
| Comprehensive Coverage | PASS | Every decision-table row of spec.md has a Pester case (RG01 to RG10), plus exact summary text (RG11) and the module surface (RG12, RG13). |
| Positive Flows | PASS | RG01 docs-only pass, RG03 full-scope pass, IG02 and IG07 passing entry. |
| Negative Flows | PASS | RG02, RG04, RG06, RG07, RG08, RG09 and RG10 red verdicts. |
| Edge Cases | PASS | RG05 `code` values `true`, empty, absent and `False`; RG08 null and unknown results; RG10 blank, whitespace, invalid JSON, array and scalar input. |
| Error Handling | PASS | IG05 converts a thrown decision error into a failed decision with exit code 1. |
| Concurrency | N/A | The gate is a single-process, single-threaded evaluation; no concurrency behavior exists. |
| State Transitions | N/A | The decision is a pure function of its input; no stateful component exists. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.57% (CiChangeScope.psm1) and 91.15% (Invoke-CiChangeScope.ps1) -> Post-change: 93.57% and 91.15% unchanged; new files 100% (CiRequiredGate.psm1, 90 of 90) and 90% (Invoke-CiRequiredGate.ps1, 27 of 30). Change: 0 percentage points on existing files. New/changed-code coverage: 97.5%. Disposition: FAIL. Evidence: DELTA and PCOV record the figures; the raw artifacts/pester/powershell-coverage.xml at HEAD was rewritten by a 40-test run and reports 0% for CiRequiredGate.psm1, and no repo-wide figure exists for the branch. The windows-latest `poshqc / PowerShell QC` merged coverage artifact of the first pull-request run is the source that closes this (awaiting_ci).
- Python: Baseline: N/A - artifacts/python/lcov.info absent -> Post-change: N/A - artifacts/python/lcov.info absent. Change: none measurable; the only Python change is a test file. New/changed-code coverage: N/A - no production Python changed. Disposition: FAIL. Evidence: `ls artifacts/python` reports no directory in the worktree; the `quality-checks7 / Code Quality & Tests (3.13)` job runs `check_python_coverage_thresholds --min-line 85 --min-branch 75` and is the source that closes this (awaiting_ci).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Clear Failure Messages | PASS | Assertions use `-Because` text naming the violated rule (for example the WG02 needs-set assertion states that an omitted job would not be enforced by the gate). |
| Arrange-Act-Assert Pattern | PASS | WG04 and IG suites carry explicit Arrange and Act/Assert comments; RG cases build fixtures, call `Get-CiRequiredGateDecision`, then assert. |
| Document Intent | PASS | Each suite opens with a header comment describing the technique and stating that no process, temporary file or network call is used. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| Avoid External Dependencies | PASS | ci.yml is read from disk as text; no YAML module, process or network is used. |
| Use Mocks/Stubs | PASS | Mocks are limited to the I/O boundary (`Add-Content`, `Write-Information`, `Get-CiRequiredGateVariable`) and one fail-closed case (`Get-CiRequiredGateDecision`). |
| Environment Stability | PASS | IG07 reads only a fixed issue-specific variable name that no process sets. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Pre-submission Review | PASS | evidence/qa-gates/self-review.2026-11-04T15-52.md plus this review. |

## 2. General Code Change Policy Compliance

The design separates the pure decision (`CiRequiredGate.psm1`) from I/O (`Invoke-CiRequiredGate.ps1`), following the existing `CiChangeScope.psm1` and `Invoke-CiChangeScope.ps1` precedent. No existing job, reusable workflow or public function changed.

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | spec.md states the defect (8 of 20 required contexts unreported on docs-only heads) and the owner decision for one aggregate gate. |
| Read existing change plans | PASS | research/research.2026-11-04.md and plan.2026-11-04T09-46.md, with preflight fixes in evidence/other/preflight-fixes.2026-11-04T15-23.md. |
| Document the plan | PASS | plan.2026-11-04T09-46.md. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|---|---|---|
| Simplicity first | PASS | One job, one module of six functions, one entry script; the decision is a single loop over sorted job ids. |
| Reusability | PASS | Summary rendering and result extraction are separate helpers reused by every path. |
| Extensibility | PASS | The gate derives rows from every key of NEEDS_JSON; a new job is enforced once added to `needs:` (pinned by WG02). |
| Separation of concerns | PASS | RG13 asserts the module contains no I/O call; environment and file writes live only in the entry script. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive modules | PASS | Decision module, entry script and three suites each have one responsibility. |
| At or below the 800-line hard limit | PASS | Logical line counts (reviewer, `@(Get-Content).Count`): 229, 149, 336, 169, 149 for the PowerShell files and 497 for the Python test; none reaches 700. `config/file-size-baseline.json` is unchanged. |
| Public vs internal | PASS | The module exports only `Get-CiRequiredGateDecision` and `Get-CiRequiredGateSkippableJob` (RG13). |
| No circular dependencies | PASS | The entry script imports the module; the module imports nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | Approved verbs and `CiRequiredGate` nouns throughout. |
| Docs/docstrings | PASS | Every function carries comment-based help. |
| Comment why, not what | PASS | Comments explain the fail-closed envelope and why `$Code` is `[object]` (null preservation). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|---|---|---|
| 1. Formatting | PASS | Reviewer rerun: Invoke-Formatter output equals content for all five new PowerShell files; Black reports the Python test unchanged. |
| 2. Linting | PASS | Reviewer rerun: PSScriptAnalyzer 0 findings on all five files; Ruff "All checks passed!"; actionlint 0 findings on ci.yml. |
| 3. Type checking | PASS | Pyright 0 errors recorded in CONTRACT for the Python test; PowerShell has no type-check stage. |
| 4. Testing | PASS | Reviewer rerun: Pester 410 of 410 passed; pytest 92 of 92 passed. |
| Full toolchain loop | PASS | evidence/qa-gates/format, pssa, pester-coverage, contract-tests-final and actionlint-ci records, each EXIT_CODE 0. |
| Explicit reporting | PASS | Each gate is recorded under evidence/qa-gates/ with its command and exit code. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Summarize changes | PASS | Commit messages and the self-review evidence. |
| Design choices explained | PASS | `.github/workflows/README.md` `## CI Required Gate (Issue #1074)` carries the decision table. |
| Update supporting documents | PASS | Six brief copies share one SHA-256 (reviewer check); both atomic-plan-contract copies share one SHA-256. |
| Provide next steps | PASS | runbook/ruleset-single-required-gate.md documents the post-merge ruleset change and rollback. |

## 3. Language-Specific Code Change Policy Compliance

PowerShell, Python (test only) and GitHub Actions rules apply. No C#, TypeScript or Bash file changed.

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with Black | PASS | Reviewer rerun: "1 file would be left unchanged." |
| Linting with Ruff | PASS | Reviewer rerun: "All checks passed!" |
| Type checking with Pyright | PASS | CONTRACT: "0 errors, 0 warnings, 0 informations". |
| Testing with Pytest | PASS | Reviewer rerun: 92 passed across five contract modules. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|---|---|---|
| Strong typing | PASS | Module-level tuples; no new function signature. |
| Dataclasses for value objects | N/A | No value object introduced. |
| Protocols/ABCs for interfaces | N/A | No interface introduced. |
| Avoid utility classes | PASS | No class added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|---|---|---|
| Specific exceptions | N/A | Test-only change. |
| Logging over print | N/A | Test-only change. |
| Invariants at construction | N/A | Test-only change. |

### Section 3B: PowerShell Code Change Policy Compliance (if applicable)

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | Reviewer rerun with scripts/powershell/PoshQC/settings/pssa.settings.psd1: formatted text equals content for all five files. |
| Linting with PSScriptAnalyzer | PASS | Reviewer rerun: 0 findings for all five files. |
| Fix all findings | PASS | No findings to fix. |
| PowerShell 5.1 & 7.6+ compatible | N/A | The gate runs under `shell: pwsh` (PowerShell 7) and uses `ConvertFrom-Json -AsHashtable -NoEnumerate`, which is PowerShell 7 only; repository PowerShell policy targets 7+. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|---|---|---|
| Advanced functions | PASS | Every function has `[CmdletBinding()]` and `[OutputType()]`. |
| Parameter validation | PASS | `Mandatory`, `AllowEmptyString`, `AllowNull` and `ValidateSet('Summary','Log')` are used. |
| Avoid global state | PASS | Module constants are `$script:` scoped; `Get-CiRequiredGateSkippableJob` returns a fresh copy (RG12). |
| Error handling | PASS | Parse errors become configuration-error verdicts; unexpected errors become a failed decision (IG05); exits are explicit `exit 0` and `exit 1`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive and at or below the 800-line hard limit | PASS | 229 and 149 logical lines. |
| Approved verbs | PASS | Get, ConvertFrom, Format, Write, Invoke. |
| Comment why | PASS | Comments state the fail-closed rationale and the null-preservation reason. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Step 1: Format | PASS | Reviewer rerun, see 3B.1. |
| Step 2: Analyze | PASS | Reviewer rerun, see 3B.1. |
| Step 3: Type check | N/A | No type-check stage for PowerShell. |
| Step 4: Test | PASS | Reviewer rerun: 410 passed, 0 failed. |
| Rerun loop if needed | PASS | No stage changed files on the reviewer pass. |

### Section 3C: GitHub Actions Workflow Policy Compliance (if applicable)

#### 3C.1 Workflow Checks

| Requirement | Status | Evidence |
|---|---|---|
| actionlint clean | PASS | Reviewer rerun `actionlint .github/workflows/ci.yml`: exit 0, no output. |
| Least-privilege permissions | PASS | `permissions: contents: read`; checkout uses `persist-credentials: false`. |
| No expression injection in run scripts | PASS | `toJSON(needs)` is passed through `env:` (NEEDS_JSON), not interpolated into `run:`. |
| Explicit exit codes | PASS | The entry script ends with `exit 0` or `exit 1` under the dot-source guard. |
| Green workflow run against the branch head (modified-workflow-needs-green-run) | FAIL | No ci.yml run exists for head cd5923ff8; classified awaiting_ci (finding F1). |

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|---|---|---|
| Use Pytest | PASS | The edited module runs under pytest. |
| Coverage expectation | FAIL | artifacts/python/lcov.info is absent; classified awaiting_ci (finding F3). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|---|---|---|
| Focused unit tests | PASS | The edited test checks one brief section and adds one absence assertion. |
| Mocking sparingly | PASS | No mocks. |
| Organization | PASS | Existing module location under tests/scripts/dev_tools. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|---|---|---|
| Naming conventions | PASS | `_OS`, `_REQUIRED_CONTEXTS`, `_REMOVED_DOCS_ONLY_CLAIM`. |
| Docstrings/comments | PASS | A comment states the source and date of the context list. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Use Pytest | PASS | Reviewer rerun, 92 passed. |
| No Alternative Test Runners | PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|---|---|---|
| Use Pester v5.x | PASS | Pester 5 configuration objects; `-ForEach` data-driven cases. |
| Use PoshQC Configuration | PASS | The executor's coverage run used `Invoke-PoshQCTest` (PCOV); `config/poshqc-scan.json` includes tests/scripts, so CI shards pick up the suites (evidence/other/poshqc-config-check.2026-11-04T15-40.md). |
| PowerShell 5.1 & 7.6+ Compatible | N/A | PowerShell 7 only, see 3B.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|---|---|---|
| Focused Unit Tests | PASS | One rule per case. |
| Test Behavior Over Implementation | PASS | Cases assert decisions and summary output; WG04 proves the workflow pin detects mutations. |
| Mocking Used Sparingly | PASS | Mocks only at the I/O boundary and for one fail-closed case. |
| Organization | PASS | tests/scripts/ci mirrors scripts/ci; workflow pins under tests/scripts/workflows. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|---|---|---|
| File Naming | PASS | `*.Tests.ps1`. |
| Describe/Context/It Structure | PASS | One Describe per suite, Contexts per rule group. |
| Logical Grouping | PASS | RG, IG and WG id prefixes. |
| Docstrings/Comments | PASS | Suite header comments. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Use PoshQCTest Command | PASS | PCOV records `Invoke-PoshQCTest -ScanFolders tests/scripts/ci,tests/scripts/workflows`. |
| No Alternative Test Runners | PASS | The reviewer rerun used plain `Invoke-Pester` without coverage only, so the executor's artifact was not further altered. |

## 5. Test Coverage Detail

Recorded (PCOV, P6-T3 at 15:49 UTC, after the last production commit 7a42e3ec5 at 15:41 UTC): CiRequiredGate.psm1 90 of 90 lines (100%); Invoke-CiRequiredGate.ps1 27 of 30 lines (90%), the three uncovered lines being the guarded `Invoke-CiRequiredGateEntry` call and the two `exit` statements, which the reviewer confirmed are the only statements outside the tests' reach by reading the script. CiChangeScope.psm1 and Invoke-CiChangeScope.ps1 are unchanged at 93.57% and 91.15%. The raw artifact now on disk (written 15:53 UTC) reports a single file, CiRequiredGate.psm1, at 0 of 90 lines from a 40-test run; its 90-line denominator matches the recorded denominator, but the numerators cannot be re-read. No repo-wide PowerShell or Python figure exists for the branch. Branch coverage is not measured for PowerShell. No coverage exclusion was added.

## 6. Test Execution Metrics

Reviewer rerun at head cd5923ff8 (plain Invoke-Pester, coverage off): 410 tests, 410 passed, 0 failed, 0 skipped across 15 suites, including CiRequiredGate 103, Invoke-CiRequiredGate 18, CiRequiredGateWorkflow 5, CiWorkflow 4, CiChangeScopeWorkflow 40 and PoshQcWorkflow 15. Python: 92 passed (execution-environment brief, push-down claude resource, evidence timestamp, single-pass preflight and discovery documentation contracts). Executor records: 167 passed in the wider nine-module contract set and 19 passed in reversed order (CONTRACT); three seeded shuffles of 166 tests each (SHUF).

## 7. Code Quality Checks

Reviewer commands: Invoke-Formatter comparison and PSScriptAnalyzer on the five new PowerShell files (0 differences, 0 findings; the analyzer's intermittent NullReferenceException occurred once and the retry completed); Black and Ruff on the Python test (clean); actionlint on ci.yml (clean); `git diff --check` over the merge-base range (clean); `validate_evidence_locations.py --root .` (exit 0); SHA-256 of the six brief copies (one hash) and of the two atomic-plan-contract copies (one hash).

## Evidence Location Compliance

`git diff --name-only` over the merge-base range lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. `validate_evidence_locations.py --root .` exited 0. All evidence is under `evidence/baseline/`, `evidence/qa-gates/` and `evidence/other/` in this feature folder. Result: PASS.

## 8. Gaps and Exceptions

Three blocking waits, all classified awaiting_ci, plus the CI-dependent acceptance criteria:

- F1: modified-workflow-needs-green-run. `.github/workflows/ci.yml` is modified and no ci.yml run exists for the branch head. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.
- F2: PowerShell coverage. The raw coverage artifact at HEAD does not describe the recorded branch-current run, and no repo-wide figure exists for the branch.
- F3: Python coverage. `artifacts/python/lcov.info` is absent; only a test file changed.
- F4: Seven CI-dependent acceptance criteria (spec.md proof A to E, final-head criteria and the runbook context-name entry) are pending the pull-request run by design.

No autonomous finding. No policy waiver is requested.

## 9. Summary of Changes

Twelve commits from 2d9452668 to cd5923ff8. Production: scripts/ci/CiRequiredGate.psm1 (229 lines, new) and scripts/ci/Invoke-CiRequiredGate.ps1 (149 lines, new). Workflow: one job appended to ci.yml (30 added lines, 0 removed). Tests: three new Pester suites and one modified pytest module. Documentation: six brief copies, two atomic-plan-contract copies, .github/workflows/README.md, and the feature folder (spec, plan, research, runbook, evidence). Full inventory is in artifacts/pr_context.appendix.txt.

## 10. Compliance Verdict

Overall status: AWAITING_CI. No autonomous code or policy defect was found. Readiness depends on the first pull-request run of ci.yml at the final head (gate green, every currently required context green), the PowerShell and Python coverage artifacts that run produces, and the plan's Phase 7 proof sequence. This audit does not claim a green workflow or merge readiness.

## Appendix A: Test Inventory

New: tests/scripts/ci/CiRequiredGate.Tests.ps1 (RG01 to RG13, 103 tests), tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1 (IG01 to IG07, 18 tests), tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1 (WG01 to WG05, 5 tests). Modified: tests/scripts/dev_tools/test_execution_environment_brief_contracts.py (`_REQUIRED_CONTEXTS` and the CI-section tokens of `test_brief_ci_section_names_jobs_and_required_contexts`). Unchanged and passing: CiWorkflow.Tests.ps1, CiChangeScopeWorkflow.Tests.ps1, PoshQcWorkflow.Tests.ps1 and the CiChangeScope suites.

## Appendix B: Toolchain Commands Reference

Reviewer commands (run from the worktree):

- `git diff --stat 11f188d1b4f3726d854ddc00f8ad4c810138f049...HEAD` and `git diff --check 11f188d1b4f3726d854ddc00f8ad4c810138f049 HEAD`
- `pwsh -NoProfile -File <scratch>/fr1074-pester.ps1` (New-PesterConfiguration, Run.Path tests/scripts/ci and tests/scripts/workflows, CodeCoverage.Enabled false)
- `pwsh -NoProfile -File <scratch>/fr1074-pssa.ps1` (Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1; logical line counts with `@(Get-Content).Count`)
- `python -m pytest -o addopts="" -q tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_evidence_timestamp_contracts.py tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py`
- `python -m black --check` and `python -m ruff check` on the edited Python test
- `actionlint .github/workflows/ci.yml`
- `python3 scripts/dev_tools/validate_evidence_locations.py --root .`
- `sha256sum` over the six execution-environment brief copies and the two atomic-plan-contract copies
- Parse of artifacts/pester/powershell-coverage.xml and artifacts/pester/pester-junit.xml (LINE counters and test-suite counts)

Executor commands are recorded with exit codes in the evidence/qa-gates/ files listed in the evidence roots.

## Rejected Scope Narrowing

None. The caller supplied the base branch, merge base, head, feature folder, PR-context artifacts and AC source only; the review covered the entire branch diff.

## Pending workflow gate

No ci.yml run exists for head cd5923ff8330dba3afb7b970d1b5476e8e559e4d: no pull request exists for the branch, ci.yml runs for this branch only on the `pull_request` event, and the Codespace token cannot dispatch workflows (HTTP 403). The awaited workflow is `.github/workflows/ci.yml` on the pull-request run of the final head.

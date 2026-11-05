# Policy Compliance Audit: CI single required gate (Issue #1074)

**Audit Date:** 2026-11-04
**Reviewer:** feature-review
**Audit Type:** Re-audit after review 0 (policy-audit.2026-11-04T16-00.md, verdict AWAITING_CI).
**Scope:** Entire feature branch `bug/ci-single-required-gate` versus `main`, merge base 11f188d1b4f3726d854ddc00f8ad4c810138f049; reviewed head f707c32b0a56c81774d6c7fbd6490a0045b5cbe8 (53 files, 3539 insertions, 53 deletions); pull request #1077.
**Template provenance:** The MCP template resolver tool was not available in this reviewer's tool set, so the artifact structure follows the canonical policy-audit headings enforced by `scripts/dev_tools/validate_policy_audit_artifact.py` and the layout of review 0. This is recorded as an assumption.
**Evidence roots:** Paths beginning `evidence/` are relative to this feature folder. PCOV=evidence/qa-gates/pester-coverage.2026-11-04T15-49.md; CICOV=evidence/qa-gates/coverage-ci-artifact.2026-11-04T17-14.md; DELTA=evidence/qa-gates/coverage-delta.2026-11-04T15-49.md; BASE=evidence/baseline/pester-ci-workflows.2026-11-04T15-28.md; SHUF=evidence/qa-gates/isolation-shuffle.2026-11-04T15-51.md; CONTRACT=evidence/qa-gates/contract-tests-final.2026-11-04T15-50.md; PROOFA to PROOFD=evidence/other/proof-a-full-run.2026-11-04T16-31.md, proof-b-gate-red.2026-11-04T16-51.md, proof-c-revert-green.2026-11-04T17-08.md, proof-d-docs-only.2026-11-04T17-11.md.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 2 production (new); 3 test (new) | 410 Pester tests in tests/scripts/ci and tests/scripts/workflows (reviewer rerun at f707c32b0) | PASS; 0 failures | CiChangeScope.psm1 93.57%; Invoke-CiChangeScope.ps1 91.15% (BASE) | Repo-wide 93.83% (22572 of 24056 lines); CiRequiredGate.psm1 100%; Invoke-CiRequiredGate.ps1 90% (CI run 41871788989 merged artifact, reviewer download) | 117 of 120 new lines = 97.5% |
| Python | 1 test file modified; 0 production files | 92 contract tests (review 0 rerun); quality-checks7 3.11, 3.12, 3.13 success in CI | PASS; 0 failures | 96.67% line repo-wide (33367 statements, 1111 missed; main push run 41844626077 at the merge base) | 96.67% line repo-wide (33367 statements, 1111 missed; pull-request run 41871788989) | N/A - no production Python changed |
| YAML (GitHub Actions) | 1 workflow (ci.yml, one job added) | CiRequiredGateWorkflow 5, CiWorkflow 4, CiChangeScopeWorkflow 40, PoshQcWorkflow 15; actionlint | PASS; green ci.yml runs at 23dd72202 (full) and f707c32b0 (head) | N/A - declarations carry no line instrumentation | N/A - declarations carry no line instrumentation | N/A - no executable code |
| TypeScript | 0 | None required | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- PowerShell baseline coverage artifact: evidence/baseline/pester-ci-workflows.2026-11-04T15-28.md (read from artifacts/pester/powershell-coverage.xml at the P0-T4 run).
- PowerShell post-change coverage artifact: `powershell-coverage.xml` in the `poshqc-test-results` artifact of ci.yml pull-request run 41871788989 (head 23dd72202, windows-latest, merged across shards 1 to 3). The reviewer downloaded it with `gh run download 41871788989 -n poshqc-test-results` and parsed the JaCoCo LINE counters; the figures equal CICOV.
- Python baseline and post-change coverage artifact: the coverage report printed by the `quality-checks7 / Code Quality & Tests (3.13)` job at the merge base (run 41844626077) and at 23dd72202 (run 41871788989), followed by the `check_python_coverage_thresholds --min-line 85 --min-branch 75` step, which succeeded. No Python coverage file is uploaded as a run artifact and `artifacts/python/lcov.info` is absent in the worktree; the CI job log is recorded as the pre-existing coverage artifact (assumption A2).
- Per-language comparison summary: evidence/qa-gates/coverage-delta.2026-11-04T15-49.md and CICOV.

Explicit coverage verdicts: PowerShell PASS; Python PASS; YAML has no coverage instrumentation; TypeScript N/A because zero TypeScript files changed. No language with changed files was waived or narrowed.

Thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults govern (line >= 85%, branch >= 75% for branch-capable languages). PowerShell has no branch gate. `quality-tiers.yml` exists and classifies `scripts/ci` as T4, so no tier-dependent gate (property tests, mutation score, golden tests) applies to the new files.

Assumptions:

- A1: The production and test code measured by CI run 41871788989 (head 23dd72202) is identical to the reviewed head. `git log 23dd72202..HEAD -- . ":!docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074"` returns no commits, and `git diff --name-only cd5923ff8 23dd72202` lists only feature-folder files, so the proof B change and its revert cancel exactly.
- A2: For Python, only a test module changed, and coverage measurement excludes tests. The CI job's coverage report is accepted as the coverage artifact; its totals are identical at the merge base and at 23dd72202.

## Executive Summary

The branch adds a `ci-required-gate` job (`CI Required Gate`) to `.github/workflows/ci.yml`, a pure decision module `scripts/ci/CiRequiredGate.psm1`, an entry script `scripts/ci/Invoke-CiRequiredGate.ps1` with I/O seams, three Pester suites, an updated Python brief-contract test, documentation updates in six byte-identical brief copies, two `atomic-plan-contract` copies and `.github/workflows/README.md`, and a ruleset runbook. Since review 0 the branch gained the Phase 7 proof sequence (a throwaway failing step and its exact revert) and feature-folder documentation only.

Review 0 findings F1 to F3 are closed: ci.yml has green pull-request runs on the full-run head 23dd72202 (run 41871788989) and on the current head f707c32b0 (run 41875760445, docs-only, `CI Required Gate` success); the merged windows-latest PowerShell coverage artifact reports 100% and 90% for the two new files and 93.83% repo-wide; the Python 3.13 job reports 96.67% line coverage, unchanged from the merge base, and its threshold step succeeded. Proofs A to D are verified against the GitHub API. One awaiting_ci item remains: spec AC-45 requires the final pull-request head to be a commit outside the docs-only allowlist with a full run in which every legacy required context is green, which the plan assigns to the orchestrator at S9. The review verdict is AWAITING_CI. No autonomous defect was identified.

## 1. General Unit Test Policy Compliance

The new suites use in-memory JSON fixtures, injected `-ReadVariable` and `-OutputWriter` seams, and Pester mocks of `Add-Content`, `Write-Information` and the environment wrapper. No temporary file, process, or network call is made in the tests.

### 1.1 Core Principles

| Requirement | Status | Evidence |
|---|---|---|
| Independence | PASS | SHUF: three seeded file-order shuffles (11, 42, 1074) over four suites, 166 tests each, 0 failures; CI shards ran the suites in a different partition and passed. |
| Isolation | PASS | Each `It` targets one decision rule (RG01 to RG13), one seam (IG01 to IG07) or one workflow invariant (WG01 to WG05). |
| Fast Execution | PASS | The new suites are pure in-memory evaluations; the 410-test reviewer rerun completed within the 580-second bound on the Linux Codespace. |
| Determinism | PASS | No clock, randomness or environment read in the code under test; the same suites passed locally and on windows-latest. |
| Readability & Maintainability | PASS | Test ids carry rule codes and AC references; each case uses Arrange, Act and Assert sections with `-Because` messages. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|---|---|---|
| Baseline Coverage Documented | PASS | BASE records CiChangeScope.psm1 93.57% and Invoke-CiChangeScope.ps1 91.15%; the Python merge-base figure is 96.67% (run 41844626077). |
| No Coverage Regression | PASS | CI artifact: CiChangeScope.psm1 131 of 140 (93.57%) and Invoke-CiChangeScope.ps1 103 of 113 (91.15%), unchanged; Python totals identical at merge base and branch. |
| New Code Coverage >= 85% | PASS | CI artifact: CiRequiredGate.psm1 90 of 90 (100%); Invoke-CiRequiredGate.ps1 27 of 30 (90%). |
| Comprehensive Coverage | PASS | Every decision-table row of spec.md has a Pester case (RG01 to RG10), plus exact summary text (RG11) and the module surface (RG12, RG13). |
| Positive Flows | PASS | RG01 docs-only pass, RG03 full-scope pass, IG02 and IG07 passing entry; proofs A, C and D on real runners. |
| Negative Flows | PASS | RG02, RG04, RG06, RG07, RG08, RG09 and RG10 red verdicts; proof B on a real runner. |
| Edge Cases | PASS | RG05 `code` values `true`, empty, absent and `False`; RG08 null and unknown results; RG10 blank, whitespace, invalid JSON, array and scalar input. |
| Error Handling | PASS | IG05 converts a thrown decision error into a failed decision with exit code 1. |
| Concurrency | N/A | The gate is a single-process, single-threaded evaluation; no concurrency behavior exists. |
| State Transitions | N/A | The decision is a pure function of its input; no stateful component exists. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 93.57% (CiChangeScope.psm1) and 91.15% (Invoke-CiChangeScope.ps1) -> Post-change: 93.57% and 91.15% unchanged; repo-wide 93.83%; new files 100% (CiRequiredGate.psm1, 90 of 90) and 90% (Invoke-CiRequiredGate.ps1, 27 of 30). Change: 0 percentage points on existing files. New/changed-code coverage: 97.5%. Disposition: PASS. Evidence: reviewer parse of `powershell-coverage.xml` from the `poshqc-test-results` artifact of run 41871788989; CICOV; BASE.
- Python: Baseline: 96.67% line repo-wide -> Post-change: 96.67% line repo-wide. Change: 0 percentage points; the only Python change is a test file. New/changed-code coverage: N/A - no production Python changed. Disposition: PASS. Evidence: `TOTAL 33367 1111 12516 548 96%` in the `quality-checks7 / Code Quality & Tests (3.13)` job log of runs 41844626077 and 41871788989; the threshold step `--min-line 85 --min-branch 75` succeeded under `bash -e`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Clear Failure Messages | PASS | Assertions use `-Because` text naming the violated rule. |
| Arrange-Act-Assert Pattern | PASS | WG04 and IG suites carry explicit Arrange and Act/Assert comments; RG cases build fixtures, call `Get-CiRequiredGateDecision`, then assert. |
| Document Intent | PASS | Each suite opens with a header comment describing the technique. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| Avoid External Dependencies | PASS | ci.yml is read from disk as text; no YAML module, process or network is used. |
| Use Mocks/Stubs | PASS | Mocks are limited to the I/O boundary and one fail-closed case. |
| Environment Stability | PASS | IG07 reads only a fixed issue-specific variable name that no process sets. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Pre-submission Review | PASS | evidence/qa-gates/self-review.2026-11-04T15-52.md, evidence/qa-gates/self-review.2026-11-04T17-12.md, review 0 and this re-audit. |

## 2. General Code Change Policy Compliance

The design separates the pure decision (`CiRequiredGate.psm1`) from I/O (`Invoke-CiRequiredGate.ps1`), following the existing `CiChangeScope.psm1` and `Invoke-CiChangeScope.ps1` precedent. No existing job, reusable workflow or public function changed. No code outside the feature folder changed since review 0 (assumption A1).

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | spec.md states the defect (8 of 20 required contexts unreported on docs-only heads) and the owner decision for one aggregate gate. |
| Read existing change plans | PASS | research/research.2026-11-04.md and plan.2026-11-04T09-46.md. |
| Document the plan | PASS | plan.2026-11-04T09-46.md, Phase 7 tasks checked with evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|---|---|---|
| Simplicity first | PASS | One job, one module of six functions, one entry script. |
| Reusability | PASS | Summary rendering and result extraction are separate helpers reused by every path. |
| Extensibility | PASS | The gate derives rows from every key of NEEDS_JSON; a new job is enforced once added to `needs:` (pinned by WG02). |
| Separation of concerns | PASS | RG13 asserts the module contains no I/O call. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive modules | PASS | Decision module, entry script and three suites each have one responsibility. |
| At or below the 800-line hard limit | PASS | Reviewer `@(Get-Content).Count` at f707c32b0: 229, 149, 336, 169, 149 for the PowerShell files and 497 for the Python test; none reaches 700. `config/file-size-baseline.json` is unchanged. |
| Public vs internal | PASS | The module exports only `Get-CiRequiredGateDecision` and `Get-CiRequiredGateSkippableJob` (RG13). |
| No circular dependencies | PASS | The entry script imports the module; the module imports nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | Approved verbs and `CiRequiredGate` nouns throughout. |
| Docs/docstrings | PASS | Every function carries comment-based help. |
| Comment why, not what | PASS | Comments explain the fail-closed envelope and the null-preservation reason. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|---|---|---|
| 1. Formatting | PASS | Review 0 rerun (Invoke-Formatter 0 differences, Black unchanged); no code changed since. CI `poshqc / PowerShell QC static` success in run 41871788989. |
| 2. Linting | PASS | Review 0 PSScriptAnalyzer 0 findings and Ruff clean; reviewer actionlint rerun at f707c32b0 exit 0. |
| 3. Type checking | PASS | Pyright 0 errors recorded in CONTRACT; CI quality-checks7 success; PowerShell has no type-check stage. |
| 4. Testing | PASS | Reviewer Pester rerun at f707c32b0: 410 of 410 passed; every ci.yml job in run 41871788989 succeeded. |
| Full toolchain loop | PASS | evidence/qa-gates/ records, each EXIT_CODE 0, plus the full CI run. |
| Explicit reporting | PASS | Each gate is recorded under evidence/qa-gates/ or evidence/other/ with its command and exit code. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Summarize changes | PASS | Commit messages and the self-review evidence. |
| Design choices explained | PASS | `.github/workflows/README.md` `## CI Required Gate (Issue #1074)` carries the decision table. |
| Update supporting documents | PASS | Six brief copies and both atomic-plan-contract copies unchanged since review 0, when each set shared one SHA-256. |
| Provide next steps | PASS | runbook/ruleset-single-required-gate.md; section 2 now carries the verified context name and `app.id` 15368. |

## 3. Language-Specific Code Change Policy Compliance

PowerShell, Python (test only) and GitHub Actions rules apply. No C#, TypeScript or Bash file changed.

### Section 3A: Python Code Change Policy Compliance (if applicable)

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with Black | PASS | Review 0 rerun; file unchanged since. |
| Linting with Ruff | PASS | Review 0 rerun; file unchanged since. |
| Type checking with Pyright | PASS | CONTRACT: "0 errors, 0 warnings, 0 informations". |
| Testing with Pytest | PASS | Review 0 rerun 92 passed; CI quality-checks7 3.11, 3.12 and 3.13 success. |

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
| Formatting with Invoke-Formatter | PASS | Review 0 rerun; files unchanged since (A1). |
| Linting with PSScriptAnalyzer | PASS | Review 0 rerun 0 findings; CI `poshqc / PowerShell QC static` success. |
| Fix all findings | PASS | No findings to fix. |
| PowerShell 5.1 & 7.6+ compatible | N/A | The gate runs under `shell: pwsh` (PowerShell 7) and uses `ConvertFrom-Json -AsHashtable -NoEnumerate`, which is PowerShell 7 only; repository PowerShell policy targets 7+. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|---|---|---|
| Advanced functions | PASS | Every function has `[CmdletBinding()]` and `[OutputType()]`. |
| Parameter validation | PASS | `Mandatory`, `AllowEmptyString`, `AllowNull` and `ValidateSet('Summary','Log')` are used. |
| Avoid global state | PASS | Module constants are `$script:` scoped; `Get-CiRequiredGateSkippableJob` returns a fresh copy (RG12). |
| Error handling | PASS | Parse errors become configuration-error verdicts; unexpected errors become a failed decision (IG05); proof B shows the step fails on a red decision. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive and at or below the 800-line hard limit | PASS | 229 and 149 logical lines. |
| Approved verbs | PASS | Get, ConvertFrom, Format, Write, Invoke. |
| Comment why | PASS | Comments state the fail-closed rationale and the null-preservation reason. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Step 1: Format | PASS | See 3B.1. |
| Step 2: Analyze | PASS | See 3B.1. |
| Step 3: Type check | N/A | No type-check stage for PowerShell. |
| Step 4: Test | PASS | Reviewer rerun at f707c32b0: 410 passed, 0 failed. |
| Rerun loop if needed | PASS | No stage changed files. |

### Section 3C: GitHub Actions Workflow Policy Compliance (if applicable)

#### 3C.1 Workflow Checks

| Requirement | Status | Evidence |
|---|---|---|
| actionlint clean | PASS | Reviewer rerun `actionlint .github/workflows/ci.yml` at f707c32b0: exit 0, no output. |
| Least-privilege permissions | PASS | `permissions: contents: read`; checkout uses `persist-credentials: false`. |
| No expression injection in run scripts | PASS | `toJSON(needs)` is passed through `env:` (NEEDS_JSON), not interpolated into `run:`. |
| Explicit exit codes | PASS | The entry script ends with `exit 0` or `exit 1`; proof B shows the gate job concluding `failure` on a red decision. |
| Green workflow run against the branch head (modified-workflow-needs-green-run) | PASS | (a) run 41875760445 (pull_request, head f707c32b0, `CI Required Gate` success, docs-only scope); (b) run 41871788989 (pull_request, head 23dd72202, full run, every job success) satisfies all three predecessor-head conditions, see `## Pending workflow gate`. |
| Proof B change removed | PASS | `git diff --name-only 11f188d1b HEAD -- .github/workflows/_docs-validation.yml` prints nothing. |

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance (if applicable)

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|---|---|---|
| Use Pytest | PASS | The edited module runs under pytest. |
| Coverage expectation | PASS | CI Python 3.13 job: 96.67% line repo-wide; threshold step (85 line, 75 branch) succeeded (A2). |

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
| Use Pytest | PASS | Review 0 rerun and CI. |
| No Alternative Test Runners | PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance (if applicable)

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|---|---|---|
| Use Pester v5.x | PASS | Pester 5 configuration objects; `-ForEach` data-driven cases. |
| Use PoshQC Configuration | PASS | `config/poshqc-scan.json` includes tests/scripts; CI shards ran the suites and merged coverage includes both new files. |
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
| Use PoshQCTest Command | PASS | PCOV records `Invoke-PoshQCTest`; CI uses `Invoke-PoshQCParallelTest` shards. |
| No Alternative Test Runners | PASS | The reviewer rerun used plain `Invoke-Pester` without coverage only. |

## 5. Test Coverage Detail

Source: `powershell-coverage.xml` in artifact `poshqc-test-results` of run 41871788989 (head 23dd72202, merged shards 1 to 3 on windows-latest), downloaded and parsed by the reviewer. Root LINE counter: 22572 covered, 1484 missed (93.83%). scripts/ci: CiRequiredGate.psm1 90 covered, 0 missed (100%); Invoke-CiRequiredGate.ps1 27 covered, 3 missed (90%), the three missed lines being the guarded entry call and the two `exit` statements; CiChangeScope.psm1 131 covered, 9 missed (93.57%); Invoke-CiChangeScope.ps1 103 covered, 10 missed (91.15%). These equal CICOV and PCOV. Python: coverage report `TOTAL 33367 1111 12516 548 96%` at both the merge base (run 41844626077) and 23dd72202 (run 41871788989). Branch coverage is not measured for PowerShell. No coverage exclusion was added.

## 6. Test Execution Metrics

Reviewer rerun at head f707c32b0 (plain Invoke-Pester, coverage off): 410 tests, 410 passed, 0 failed, 0 skipped across 15 containers in tests/scripts/ci and tests/scripts/workflows. CI run 41871788989: all 23 jobs success, including `poshqc / PowerShell QC shard 1` to `3`, `PowerShell QC static`, `PowerShell hook suites (Linux)` and `quality-checks7` 3.11, 3.12, 3.13. Review 0 Python rerun: 92 passed. Executor records: three seeded shuffles of 166 tests each (SHUF).

## 7. Code Quality Checks

Reviewer commands at f707c32b0: actionlint on ci.yml (clean); `git diff --check` over the merge-base range (clean); `validate_evidence_locations.py --root .` (exit 0); logical line counts with `@(Get-Content).Count`; `git merge-tree --write-tree origin/main HEAD` (exit 0, no conflict with current main 61338f51f; no path overlap between the branch and main's 143 changed paths). Formatter and analyzer results carry over from review 0 because no code changed (A1).

## Evidence Location Compliance

`git diff --name-only` over the merge-base range lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. `validate_evidence_locations.py --root .` exited 0. All evidence is under `evidence/baseline/`, `evidence/qa-gates/` and `evidence/other/` in this feature folder. Result: PASS.

## 8. Gaps and Exceptions

Review 0 findings and their status:

- F1 (modified-workflow-needs-green-run): closed by runs 41875760445 and 41871788989.
- F2 (PowerShell coverage): closed by the merged CI coverage artifact of run 41871788989.
- F3 (Python coverage): closed by the CI Python 3.13 coverage report and threshold step (A2).
- F4 (CI-dependent acceptance criteria): AC-33 and AC-40 to AC-44 verified; AC-45 remains pending as finding R1-F1 (awaiting_ci).

Open item R1-F1: spec AC-45 requires the final pull-request head commit to touch a path outside `config/ci-docs-only-paths.json` and its full ci.yml run to report every context required by ruleset 15241672 as success together with `CI Required Gate`. The current head f707c32b0 changes only feature-folder Markdown and ran in docs-only scope, so the legacy shard, root-typescript-tests and NPM Audit Gate contexts did not report and the pull request is BLOCKED. The plan assigns this final commit and check-off to the orchestrator at S9. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.

Non-blocking note: evidence/other/proof-d-docs-only.2026-11-04T17-11.md ends with "This file is left uncommitted for the orchestrator's S9 commit", but the file was committed in c7a2940de. The sentence is stale and does not affect any criterion.

No autonomous finding. No policy waiver is requested.

## 9. Summary of Changes

Eighteen commits from 2d9452668 to f707c32b0. Production: scripts/ci/CiRequiredGate.psm1 (229 lines, new) and scripts/ci/Invoke-CiRequiredGate.ps1 (149 lines, new). Workflow: one job appended to ci.yml (30 added lines, 0 removed); the proof B step in `_docs-validation.yml` was added in 16be68a10 and reverted in 23dd72202. Tests: three new Pester suites and one modified pytest module. Documentation: six brief copies, two atomic-plan-contract copies, .github/workflows/README.md, and the feature folder (spec, plan, research, runbook, evidence, review 0 artifacts). Full inventory is in artifacts/pr_context.appendix.txt (generated 17:15:16 UTC at f707c32b0).

## 10. Compliance Verdict

Overall status: AWAITING_CI. No autonomous code or policy defect was found, all coverage gates pass, and the modified workflow has a green run at the branch head. The remaining item is spec AC-45, the final full-run head at S9. This audit does not claim merge readiness ahead of that run.

## Appendix A: Test Inventory

New: tests/scripts/ci/CiRequiredGate.Tests.ps1 (RG01 to RG13, 103 tests), tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1 (IG01 to IG07, 18 tests), tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1 (WG01 to WG05, 5 tests). Modified: tests/scripts/dev_tools/test_execution_environment_brief_contracts.py. Unchanged and passing: CiWorkflow.Tests.ps1, CiChangeScopeWorkflow.Tests.ps1, PoshQcWorkflow.Tests.ps1 and the CiChangeScope suites.

## Appendix B: Toolchain Commands Reference

Reviewer commands (absolute worktree paths or `git -C`):

- `git diff --stat 11f188d1b4f3726d854ddc00f8ad4c810138f049..HEAD`, `git diff --check 11f188d1b HEAD`, `git log 23dd72202..HEAD -- . ":!<feature folder>"`, `git diff --name-only cd5923ff8 23dd72202`
- `gh run view <id> --json headSha,event,conclusion,status,workflowName` for runs 41864628204, 41868374284, 41871788989, 41874737526 and 41875760445; `gh run view <id> --json jobs`; `gh run view 41874737526 --log --job 126731576072` (proof D gate rows); `gh pr view 1077 --json headRefOid,state,mergeStateStatus,mergeable`
- `gh run download 41871788989 -n poshqc-test-results -D <scratch>` and a JaCoCo LINE-counter parse
- `gh run view <id> --log --job <quality-checks7 3.13 job>` for runs 41844626077 and 41871788989
- `pwsh -NoProfile -File <scratch>/fr1074r1-pester.ps1` (New-PesterConfiguration, Run.Path tests/scripts/ci and tests/scripts/workflows, CodeCoverage.Enabled false)
- `actionlint .github/workflows/ci.yml`; `python3 scripts/dev_tools/validate_evidence_locations.py --root .`; `git merge-tree --write-tree origin/main HEAD`

## Rejected Scope Narrowing

None. The caller supplied the base branch, merge base, head, pull request, feature folder, PR-context artifacts, AC source, prior review set and CI run identifiers only; the review covered the entire branch diff, and each supplied run fact was verified with `gh`.

## Pending workflow gate

Green-run evidence for the modified `.github/workflows/ci.yml`:

- (a) Run 41875760445, event `pull_request`, head f707c32b0a56c81774d6c7fbd6490a0045b5cbe8 (the current branch head), conclusion success; `Change scope` docs-only and `CI Required Gate` success.
- (b) Run 41871788989, event `pull_request`, head 23dd72202a594c0e829072b7c6aee72b47be8140, full run, conclusion success with all 23 jobs success. Condition (1): `git merge-base --is-ancestor 23dd72202 HEAD` succeeds, and 23dd72202 is the latest commit that changes a path outside the active feature folder. Condition (2): `git log 23dd72202..HEAD -- . ":!docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074"` returns no commits. Condition (3): the orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.

The awaited item is the final-head full run required by spec AC-45, on `.github/workflows/ci.yml` at the pull-request head chosen at S9.

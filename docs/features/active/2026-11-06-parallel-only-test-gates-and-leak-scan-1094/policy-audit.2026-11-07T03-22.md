# Policy Compliance Audit: parallel-only-test-gates-and-leak-scan (#1094)

---

**Audit Date:** 2026-11-07
**Code Under Test:** Full branch diff of `feature/parallel-only-test-gates-and-leak-scan-1094` against `origin/main`: 248 files (219 modified, 29 added). Executable files: `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` (new) and five modified Python contract test modules under `tests/scripts/dev_tools/`. All other files are skill, agent, prompt, template, and feature-folder Markdown or TOML text.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 5 files | 16109 tests | ✅ 16103 pass, 0 fail, 6 skipped | N/A - no pre-change run | 49.52% lines, 45.29% branches | N/A - no production file changed |
| PowerShell | 1 file | 14452 tests | ✅ 14452 tests, 0 fail, 10 disabled | N/A - no pre-change run | 93.85% lines | N/A - no production file changed |

Rows for TypeScript, C#, Bash, and JSON are deleted because the branch diff holds zero files of those languages.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no pre-change run
- TypeScript post-change coverage artifact: N/A - no TypeScript files in the branch diff
- PowerShell baseline coverage artifact: N/A - no pre-change run
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- Per-language comparison summary: Section 1.2.1 of this audit

**Assumption on template source:** the MCP template resolver was not available to this agent. The structure of this audit follows `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` on the reviewed branch.

---

## Executive Summary

The branch replaces the serial, seeded, and reversed-order test requirements with two parallel gates across the skills, agents, prompts, and templates of all mirrors, and adds contract tests that pin the new wording. The core brief, plan contract, and review workflow changes are correct, mirrored, and pinned. Four blocking findings remain.

- RF-1: four Copilot agents and their bundle copies still require a coverage comparison, or compare a gate failure to a baseline.
- RF-2: typed-engineer agents in the Claude, Codex, and Copilot surfaces still require a targeted test run after every batch, which contradicts the rule that a focused run is debugging only.
- RF-3: the contract test for the `N/A - no pre-change run` record covers the Python validator only, while the criterion names the validators, including the TypeScript twin.
- RF-4: the Python coverage artifact reports 49.52% line and 45.29% branch, below the governing 85% and 75% repo-wide thresholds. The cause is diagnosed as a measurement defect of the item worktree, not a code defect, but the artifact as recorded does not satisfy the threshold.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [N/A] Bash: no bash file in the branch diff
- [N/A] JSON: no JSON file in the branch diff

Toolchain state: Black, Ruff, and Pyright were re-run check-only at head with zero findings. Parallel gates passed before the final merge of `origin/main`. Coverage is PASS for PowerShell and FAIL for Python.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --short` showed no stray file before this review wrote its artifacts, and the branch diff holds no script outside `tests/`.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: no tooling script is added.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller text below was evaluated against the Scope Invariant.

> "No review check may require a single-process, seeded-shuffle, reversed-order, comparison, or pre-change baseline run, and you must not report the absence of one as a finding."

This text does not limit the audit to a subset of the diff and does not waive any language. It was accepted because it matches the owner directive the branch implements, and because the changed-line regression check is vacuous here: the branch changes no production line. Coverage for Python and PowerShell was still evaluated and carries an explicit verdict.

> "spec `## Decisions` and the out-of-scope list record what was deferred to #1096 by owner decision."

This text identifies the spec sections that hold the deferral. The audit scope stayed the full feature-vs-base diff.

---

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 at head. The branch diff holds no file under `artifacts/`. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/issue-updates/`, and `<FEATURE>/evidence/other/`. No violations were found.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Added tests read repository files and share no mutable state. Both suites ran under parallel workers: 8 Pester shards, and `pytest -n auto`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `PGW-` row per file. Each Python test pins one section, one copy set, or one validator behavior. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 321.78 s wall-clock over 14452 tests; pytest 157.29 s over 16109 tests, per `evidence/qa-gates`. |
| **Determinism** - Consistent results | ✅ PASS | File reads only; no clock, network, or randomness in the added tests. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names, Arrange/Act/Assert comments, and `-Because` failure text. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | N/A | No production file changed. Changed code files are tests, which the coverage configuration excludes from measurement. |
| **New Code Coverage ≥90%** | N/A | No production file was added. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | The Python validator is pinned by two new tests. The TypeScript twin has no such test (RF-3). |
| **Positive Flows** - Valid inputs | ✅ PASS | `test_validate_policy_audit_text_accepts_no_pre_change_run_record` and the `PGW-` required tokens. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Forbidden-token rows; `test_comparison_line_baseline_label_reaches_later_percentage` asserts rejection without a percentage. A replay showed that all 46 `PGW-` rows fail against the `origin/main` text. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Case folding and whitespace collapse in the token search; `PGW-SWEEP-HELPER` covers tokens that contain shorter tokens. |
| **Error Handling** - Error paths | N/A | No production error path changed. |
| **Concurrency** - If applicable | N/A | The added tests only read files. |
| **State Transitions** - If applicable | N/A | No stateful component under test. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: N/A - no pre-change run -> Post-change: 49.52% lines, 45.29% branches. Change: N/A. New/changed-code coverage: N/A - no production file changed. Disposition: FAIL. Evidence: artifacts/python/lcov.info; docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/pytest-parallel.2026-11-07T03-11.md.
- PowerShell: Baseline: N/A - no pre-change run -> Post-change: 93.85% lines. Change: N/A. New/changed-code coverage: N/A - no production file changed. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/pester-parallel.2026-11-07T03-07.md.

Python detail (RF-4). `artifacts/python/lcov.info` holds 366 files: `scripts/dev_tools` measures 94.27% line and 89.10% branch over 226 files, and `packages/discovery-runtime` measures 0% over 140 files. An import probe from the item worktree showed that `drm_copilot_discovery` resolves to the main checkout through the shared `.venv`, so the worktree copies configured as coverage sources were never executed. With `PYTHONPATH` set to the worktree `packages/discovery-runtime/src`, the same probe resolved the package inside the worktree. The evidence record stated this cause as unverified, and the self-review recorded Coverage Metrics as PASS for Python; neither closes the threshold. Corroboration: the `CI` run 42329060481 on merge base `9a19be8e7` reports TOTAL 33367 statements, 1111 missed, 12516 branches, 548 partial, 96%, with the 85/75 threshold step succeeding; the statement and branch denominators equal those of the local artifact. That run does not include the branch and is context only.

PowerShell detail. The root LINE counter of `artifacts/pester/powershell-coverage.xml` is 23175 covered and 1519 missed (93.85%). Pester reports no branch figure, and no branch threshold applies. The artifact was written by the gate run before the final merge of `origin/main`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions name the copy and the tokens: `offending`, `missing`, and `-Because` text. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit `# Arrange`, `# Act`, and `# Assert` comments in added tests. |
| **Document Intent** | ✅ PASS | Docstrings on new Python tests; file header and comment-based help in the Pester suite. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Reads repository files only. |
| **Use Mocks/Stubs** | N/A | No external system is involved. |
| **Environment Stability** | ✅ PASS | The Pester suite derives the root from `$PSScriptRoot`; no temporary files are created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required review. Outstanding items are RF-1 to RF-4. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1094, reduced by the owner split recorded in `issue.md` and `spec.md`. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-11-07T02-43.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-11-06T20-01.md`, with preflight records under `evidence/other/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Table-driven `PGW-` rows with two small helpers. |
| **Reusability** | ✅ PASS | `_section` gains an optional path instead of a second helper. |
| **Extensibility** | ✅ PASS | New rows and tokens extend the tables without code changes. |
| **Separation of concerns** | ✅ PASS | Test-only code; no production logic is added. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One new suite with one purpose. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical lines: `parallel-gate-wording.Tests.ps1` 247, `test_validate_policy_audit_artifact.py` 580, `test_execution_environment_brief_contracts.py` 566, `test_discovery_documentation_contracts.py` 461, `test_single_pass_preflight_contracts.py` 432, `test_codex_orchestration_contracts.py` 95. None reaches 700. `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | N/A | No public API. |
| **No circular dependencies** | N/A | No module dependency is added. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | For example `test_brief_copies_carry_no_removed_run_tokens`, `Get-PgwSweepFile`. |
| **Docs/docstrings** | ✅ PASS | New tests and helpers are documented. |
| **Comment why, not what** | ✅ PASS | Comments state why tokens are folded and why `baseline coverage` is not a sweep token. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check` over the five Python files, and `Invoke-PoshQCFormat`.<br>**Result:** 5 files unchanged at head (reviewer run); 21 of 21 PowerShell files formatted (evidence). |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check` and `Invoke-ScriptAnalyzer`.<br>**Result:** All checks passed at head (reviewer run); 0 analyzer findings over 21 files (evidence). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright` over the five files.<br>**Result:** 0 errors at head (reviewer run). N/A for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** one `Invoke-PoshQCParallelTest` run and one `poetry run pytest -n auto` run.<br>**Result:** 0 failures in both. `artifacts/pester/pester-junit.xml` confirms 14452 tests, 0 failures, 0 errors, 48 `PGW-` testcases. |
| **Full toolchain loop** | ⚠️ PARTIAL | The gates ran before merge commit `f59b9caab` brought 89 files from `origin/main`. A merge is not a fix, so no re-run was required, and the replay of the sweep tokens at head over 894 files found no hit. The remediation cycle re-runs the gates, and CI covers the merged head. |
| **Explicit reporting** | ✅ PASS | Commands are recorded under `evidence/` and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 of this audit and the commit history. |
| **Design choices explained** | ✅ PASS | Spec `## Decisions` and `## Constraints & Risks`. |
| **Update supporting documents** | ✅ PASS | The brief lists the new contract test under `## Contract Tests That Pin Mirrored Files`. |
| **Provide next steps** | ✅ PASS | `remediation-inputs.2026-11-07T03-22.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check`<br>**Result:** 5 files unchanged. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** no findings. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`<br>**Result:** 16103 passed, 6 skipped, 0 failures. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | The private helper is bound through a `cast` to a typed `Callable`, matching the file's existing pattern. |
| **Dataclasses for value objects** | N/A | None added. |
| **Protocols/ABCs for interfaces** | N/A | None added. |
| **Avoid utility classes** | ✅ PASS | Module functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | Tests only. |
| **Logging over print** | N/A | Tests only. |
| **Invariants at construction** | N/A | Tests only. |

---

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-PoshQCFormat -Root <worktree> -ScanFolders tests/scripts/claude-runtime`<br>**Result:** 21 of 21 already formatted. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with the repo settings<br>**Result:** 0 findings over 21 files. |
| **Fix all findings** | ✅ PASS | None to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The suite runs under PowerShell 7; `[System.IO.Path]::GetRelativePath` needs 7, which `.claude/rules/powershell.md` requires. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Helpers use `CmdletBinding` and `OutputType`. |
| **Parameter validation** | ✅ PASS | Mandatory parameters with `AllowEmptyString` and `AllowEmptyCollection` where needed. |
| **Avoid global state** | ✅ PASS | `$script:` scope within the test file only. |
| **Error handling** | N/A | Test file. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 247 logical lines. |
| **Approved verbs** | ✅ PASS | `Get-PgwSurfaceText`, `Get-PgwTokenHit`, `Get-PgwSweepHit`, `Get-PgwSweepFile`. |
| **Comment why** | ✅ PASS | The header and sweep comments state rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `evidence/qa-gates/powershell-format.2026-11-07T03-00.md`. |
| **Step 2: Analyze** | ✅ PASS | `evidence/qa-gates/powershell-analyze.2026-11-07T03-00.md`. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `evidence/qa-gates/pester-parallel.2026-11-07T03-07.md`. |
| **Rerun loop if needed** | ✅ PASS | One gate run. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Plain functions; existing helpers. |
| **Coverage expectation** | ❌ FAIL | Repo-wide artifact 49.52% line, 45.29% branch, against 85% and 75% (RF-4). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One behavior per test. |
| **Mocking sparingly** | N/A | No mocks. |
| **Organization** | ✅ PASS | Under `tests/scripts/dev_tools/`, mirroring the tools and contracts they pin. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<subject>_<expected behavior>`. |
| **Docstrings/comments** | ✅ PASS | Each new test has a docstring. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto`<br>**Result:** 0 failures. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

---

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeDiscovery`, `BeforeAll`, `Describe`, `Context`, `It -ForEach`, and `Should`. |
| **Use PoshQC Configuration** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`<br>No configuration change. |
| **PowerShell 5.1 & 7.6+ Compatible** | ✅ PASS | PowerShell 7 per repository rule. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | One file per row. |
| **Test Behavior Over Implementation** | ✅ PASS | The surface under test is the wording itself. |
| **Mocking Used Sparingly** | N/A | No mocks. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`<br>**Code file:** none; it pins mirrored text, like its sibling contract suites. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `parallel-gate-wording.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe, 1 Context, 48 generated `It` testcases. |
| **Logical Grouping** | ✅ PASS | Per-file rows, then the class sweep. |
| **Docstrings/Comments** | ✅ PASS | Comment-based help on helpers. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Result:** ExitCode 0, 8 shards. |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

## 5. Test Coverage Detail

### parallel-gate-wording.Tests.ps1 (48 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `PGW-<Id>` (46 rows) | Positive and Negative | N/A - text surfaces | ✅ |
| `PGW-SWEEP-SURFACES` | Negative | N/A - text surfaces | ✅ |
| `PGW-SWEEP-HELPER` | Edge Case | N/A - in-memory text | ✅ |

**Coverage:** N/A; the suite pins Markdown and TOML text, not production code.

**Not covered:** the wording of RF-1 and RF-2 is outside the sweep tokens.

---

### Python contract tests (6 new or replaced tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_brief_test_isolation_states_parallel_gates` | Positive | N/A - text surfaces | ✅ |
| `test_brief_copies_carry_no_removed_run_tokens` | Negative | N/A - text surfaces | ✅ |
| `test_brief_passages_state_parallel_gate_facts` | Positive | N/A - text surfaces | ✅ |
| `test_contract_premortem_test_isolation_states_parallel_gates` | Positive and Negative | N/A - text surfaces | ✅ |
| `test_validate_policy_audit_text_accepts_no_pre_change_run_record` | Positive | `validate_policy_audit_text` | ✅ |
| `test_comparison_line_baseline_label_reaches_later_percentage` | Edge Case | `_comparison_line_has_labelled_percentage` | ✅ |

**Coverage:** see Section 1.2.1.

**Not covered:** `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts` has no test of this record (RF-3).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 30561 (14452 Pester, 16109 pytest) | ✅ |
| Tests Passed | 16103 pytest; Pester 14452 tests with 0 failures and 10 disabled | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 321.78 s Pester, 157.29 s pytest | ✅ Fast |
| Average Time per Test | N/A - parallel wall-clock | ✅ |
| Discovery Time | N/A - not recorded by the parallel gates | ✅ |
| Functions/Classes Tested | N/A - no production function changed | ✅ |
| Test File Size | 247 logical lines for the new file; 580 maximum | ✅ PASS |
| Code Coverage (if applicable) | Python 49.52% lines, 45.29% branches; PowerShell 93.85% lines | ❌ Python below threshold |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check` | 5 unchanged | ✅ |
| Ruff Linting | `poetry run ruff check` | no findings | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 0 failures | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` | 21 of 21 formatted | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | ExitCode 0, 0 failures | ✅ |

**Notes:**
`poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exited 0 at head. 101 mirrored file pairs in the diff compare equal after line-ending normalization. No tool-permission line changed in `.claude/agents`, `.codex/agents`, or `.github/agents`. `modified-workflow-needs-green-run` does not fire: no path under `.github/workflows/`, `.github/actions/`, or `scripts/benchmarks/` changed. Tier classification: `quality-tiers.yml` exists, and no project is added.

---

## 8. Gaps and Exceptions

### Identified Gaps

- RF-1 (spec `### 1`, comparison removal): `Confirm coverage does not regress for touched files.` remains in `.github/agents/powershell-typed-engineer.agent.md` and `.github/agents/csharp-typed-engineer.agent.md`; `Coverage does not regress for any file you touch` remains in `.github/agents/pytest-unit-test-coding.agent.md`; `Any failure in the single gate run compared to baseline` is branch-authored in `.github/agents/Powershell DI Unit Test Engineer.agent.md`. Each bundle copy under `extensions/drm-copilot/resources/customizations/` holds the same text.
- RF-2 (spec `### 1`, focused runs): after-each-batch targeted test runs remain required in the typed-engineer agents and their mirrors, including `### Iteration runs (required after each batch)` in the DI agent.
- RF-3 (AC 9): no contract test covers the TypeScript validator.
- RF-4 (coverage): the Python artifact is below the governing repo-wide thresholds.

### Approved Exceptions

- Decision 1 of `spec.md`: policy files are not edited; they still name single-process commands and a changed-line regression rule. Recorded by the spec for the owner report.
- The deferred Python tools and VS Code aggregates in spec `### 2. Out of scope` move to #1096.
- Policy-audit baseline fields record `N/A - no pre-change run` by owner directive.

### Removed/Skipped Tests

`test_brief_test_isolation_requires_seeded_pester_shuffle` and `test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` were replaced by the tests in Section 5, as the spec directs. No test was skipped by this branch.

---

## 9. Summary of Changes

### Commits in This PR/Branch

27 commits plus merge commit `f59b9caab`. Implementation commits:

1. **269aaeff0** - docs(skills): state the parallel test gates in the execution brief
2. **c89b11aa4** - docs(skills): state the parallel gates in the plan contract
3. **ef3fef4ba** - docs(skills): name the parallel gates in the QA gate skills
4. **572b83867** - docs(skills): apply the parallel gates to the feature review workflow
5. **299134f26** - docs(skills): apply the suite-baseline rule to the remaining skills
6. **28402e53d** - docs(agents): apply the parallel gates to Claude and Codex agents
7. **ce5445704** - docs(agents): apply the parallel gates to Copilot agents and prompts
8. **215f4c07c** - docs(templates): remove the pre-change run from audit and plan templates
9. **bd99bd5af** - test(contracts): sweep the surfaces for removed test-suite baseline wording
10. **b58a31d62** - test(contracts): declare helper output types and record PowerShell static gates

### Files Modified

1. **`tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`** (NEW)
   - Per-file token rows and a class sweep over the mirrored surfaces.

2. **`tests/scripts/dev_tools/test_*.py`, five modules** (MODIFIED)
   - Replaced contract tests, the `REPO_ROOT`-relative worktree filter, and validator record tests.

3. **Skills, agents, prompts, templates in all mirrors** (MODIFIED)
   - Parallel gates, static baselines, and coverage read from the single gate run.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The core change is compliant. Four blocking findings remain, all remediable without a production change.

**Fail-closed reminder:** Python coverage is recorded as FAIL. This audit does not report PASS.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and policy read recorded
- ✅ Design Principles: table-driven tests
- ✅ Module & File Structure: all files below 700 lines
- ✅ Naming, Docs, Comments: compliant
- ⚠️ Toolchain Execution: gates predate the final merge of `origin/main`
- ✅ Summarize & Document: compliant

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean at head
- ✅ Python Design & Typing: compliant
- ✅ Error Handling: test code only

**For PowerShell:**
- ✅ Tooling & Baseline: clean
- ✅ PowerShell Design & Safety: compliant
- ✅ Structure & Naming: compliant
- ✅ Toolchain: one parallel gate run

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ❌ Coverage & Scenarios: Python artifact below thresholds; TypeScript twin not pinned
- ✅ Test Structure: compliant
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ❌ Framework & Scope: coverage expectation not met
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: `pytest -n auto`

**For PowerShell:**
- ✅ Framework & Scope: compliant
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: `Invoke-PoshQCParallelTest`

---

### Metrics Summary

- ✅ 0 failures in both parallel gates
- ❌ Python 49.52% line and 45.29% branch against 85% and 75%
- ✅ PowerShell 93.85% line against 85%
- ✅ 101 mirrored file pairs equal; 46 of 46 `PGW-` rows discriminate against base text
- ✅ All code quality checks clean
- ✅ Gate wall-clock 321.78 s and 157.29 s

---

### Recommendation

**Needs revision**

Resolve RF-1 to RF-4 per `remediation-inputs.2026-11-07T03-22.md`, then re-run the parallel gates once, which also covers the merged head.

---

## Appendix A: Test Inventory

### Complete Test List

- Parallel gate wording › `PGW-<Id>` carries the required wording and no forbidden wording (46 rows)
- Parallel gate wording › Class sweep › `PGW-SWEEP-SURFACES`
- Parallel gate wording › Class sweep › `PGW-SWEEP-HELPER`
- `test_execution_environment_brief_contracts.py::test_brief_test_isolation_states_parallel_gates`
- `test_execution_environment_brief_contracts.py::test_brief_copies_carry_no_removed_run_tokens`
- `test_execution_environment_brief_contracts.py::test_brief_passages_state_parallel_gate_facts`
- `test_single_pass_preflight_contracts.py::test_contract_premortem_test_isolation_states_parallel_gates`
- `test_validate_policy_audit_artifact.py::test_validate_policy_audit_text_accepts_no_pre_change_run_record`
- `test_validate_policy_audit_artifact.py::test_comparison_line_baseline_label_reaches_later_percentage`
- `test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies` (filter fixed)
- `test_codex_orchestration_contracts.py::test_codex_orchestrator_workflow_requires_large_path_evidence_gates` (assertion updated)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Reviewer runs at head, check-only, over the five changed test modules
poetry run black --check <files>
poetry run ruff check <files>
poetry run pyright <files>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check

# Gate, per evidence/qa-gates/pytest-parallel.2026-11-07T03-11.md
poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov
```

**For PowerShell:**
```powershell
# Gates, per evidence/qa-gates
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root . -ScanFolders tests/scripts/claude-runtime
Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
```

No suite was re-run by this review. Coverage figures were read from the existing artifacts.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)

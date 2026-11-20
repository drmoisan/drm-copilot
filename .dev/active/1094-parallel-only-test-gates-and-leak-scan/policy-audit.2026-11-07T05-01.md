# Policy Compliance Audit: parallel-only-test-gates-and-leak-scan (#1094)

---

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after the remediation of RF-5 (`remediation-inputs.2026-11-07T04-20.md`)
**Code Under Test:** Full branch diff of `feature/parallel-only-test-gates-and-leak-scan-1094` (head `6b8c3640a48e0ea7f1c2c80e8bb89201d8a87164`) against `origin/main` (merge base `9a19be8e72ea479212e2e43c3ad766afb270fae6`): 303 paths (232 modified, 71 added). By extension: 209 Markdown, 87 TOML, 5 Python, 1 PowerShell, 1 TypeScript. All seven code files are tests: `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` (new), five modules under `tests/scripts/dev_tools/`, and `extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts`. No production file changed.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 5 files | 16109 tests | ✅ 16103 pass, 0 fail, 6 skipped | N/A - no pre-change run | 96.71% lines, 93.66% branches | N/A - no production file changed |
| PowerShell | 1 file | 14518 tests | ✅ 14518 tests, 0 fail, 10 disabled | N/A - no pre-change run | 93.87% lines | N/A - no production file changed |
| TypeScript | 1 file | 5303 tests | ✅ 5303 pass, 0 fail | N/A - no pre-change run | 98.22% lines, 93.42% branches | N/A - no production file changed |

Rows for C#, Bash, and JSON are deleted because the branch diff holds zero files of those languages.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no pre-change run
- TypeScript post-change coverage artifact: coverage/lcov.info
- PowerShell baseline coverage artifact: N/A - no pre-change run
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- Per-language comparison summary: Section 1.2.1 of this audit

**Assumption on template source:** the MCP template resolver was not available to this agent. The structure of this audit follows `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` on the reviewed branch. That template has no TypeScript section, so Sections 3E and 4C were added for the changed TypeScript test file.

**Disclosure on this audit's own form:** the lines above that carry `N/A - no pre-change run` follow the branch template and the owner directive. RF-6 below shows that the coverage stop hook rejects those lines, so this audit would itself fail that hook if the hook read it.

---

## Executive Summary

RF-5 and both optional items from the prior inputs are closed, and each closure was verified independently at head. Coverage passes for all three changed languages. Criterion 1 now evaluates as PASS. One new blocking finding exists, RF-6.

- RF-5 closed: `staged-review.agent.md` and its bundle copy state the parallel gates and the debugging statement, the two copies are equal, and `smallest applicable subset` has 0 hits at head.
- The cycle 2 sweep tokens discriminate: each of the 5 added tokens hits 2 files at the prior review head `2c5c12a08` and 0 at head.
- An independent phrasing search, which did not rely on the 38 sweep tokens, found no passage that requires a removed run or names a serial command as a gate.
- RF-6 new: the branch template and the `feature-review-workflow` skill prescribe `N/A - no pre-change run`, and the unchanged SubagentStop hook `validate-feature-review-coverage.ps1` treats `N/A` on a coverage-scoped line as scope narrowing. A real hook run from the item worktree on an audit filled that way exits 2, and exits 2 again with `stop_hook_active` true. After merge, a feature review of a branch that changes PowerShell or TypeScript files cannot satisfy both the template and the hook.

RF-6 is not a finding about an absent run. No baseline run is required or recommended. The finding is that the record the branch prescribes is rejected by a gate the branch did not update.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [✅] `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md`
- [N/A] Bash: no bash file in the branch diff
- [N/A] JSON: no JSON file in the branch diff

Toolchain state: every static tool was re-run check-only at head with zero findings. The Pester and pytest gates ran after the last change outside the feature folder and reported zero failures. No TypeScript file changed after the Jest gate. Coverage is PASS for Python, PowerShell, and TypeScript.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --short` was empty before this review wrote its artifacts, and the branch diff holds no script outside `tests/`.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: no tooling script is added.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller text below was evaluated against the Scope Invariant.

> "No review check may require a single-process, seeded-shuffle, reversed-order, comparison, or pre-change baseline run, and you must not report the absence of one as a finding."

This text does not limit the audit to a subset of the diff and does not waive any language. It was accepted because it matches the owner directive the branch implements, and because the changed-line check is vacuous here: the branch changes no production line. Coverage for Python, PowerShell, and TypeScript was still evaluated and carries an explicit verdict. RF-6 complies with this text: it concerns a rejected record, not an absent run.

> "spec `## Decisions` and the out-of-scope list record what was deferred to #1096 by owner decision."

This text identifies the spec sections that hold the deferral. The audit scope stayed the full feature-vs-base diff. The stop hook in RF-6 is not named in those sections.

---

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 at head. The branch diff holds no file under `artifacts/`. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/remediation-baseline/`, `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/issue-updates/`, and `<FEATURE>/evidence/other/`, all canonical kinds. No violations were found.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Added tests read repository files or in-memory text and share no mutable state. All suites ran under parallel workers: 8 Pester shards, `pytest -n auto`, and Jest workers. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `PGW-` row per file; each Python and Jest test pins one section, one copy set, or one validator behavior. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 315.77 s over 14518 tests; pytest 162.39 s over 16109 tests, per `evidence/qa-gates`. |
| **Determinism** - Consistent results | ✅ PASS | File reads and in-memory fixtures only; no clock, network, or randomness in the added tests. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names, Arrange/Act/Assert comments, and `-Because` failure text. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | N/A | No production file changed. Changed code files are tests, which the configuration excludes from measurement. |
| **New Code Threshold** | N/A | No production file was added. |
| **Comprehensive Tests** | ⚠️ PARTIAL | Both policy-audit validators are pinned for the no-pre-change-run record: two Python tests and two Jest cases. No test exercises that record against the stop hook (RF-6). |
| **Positive Flows** - Valid inputs | ✅ PASS | `test_validate_policy_audit_text_accepts_no_pre_change_run_record`, `accepts an audit that records no pre-change run`, and the `PGW-` required tokens. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Forbidden-token rows; the Python and Jest comparison-line tests assert rejection without a percentage. The 5 cycle 2 sweep tokens hit 2 files each at `2c5c12a08` and 0 at head. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Case folding and whitespace collapse in the token search; `PGW-SWEEP-HELPER` covers tokens that contain shorter tokens; `replaceRequired` fails on stale fixture text. |
| **Error Handling** - Error paths | N/A | No production error path changed. |
| **Concurrency** - If applicable | N/A | The added tests only read files. |
| **State Transitions** - If applicable | N/A | No stateful component under test. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: N/A - no pre-change run -> Post-change: 96.71% lines, 93.66% branches. Change: N/A. New/changed-code coverage: N/A - no production file changed. Disposition: PASS. Evidence: artifacts/python/lcov.info; docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/pytest-parallel.2026-11-07T04-50.md.
- PowerShell: Baseline: N/A - no pre-change run -> Post-change: 93.87% lines. Change: N/A. New/changed-code coverage: N/A - no production file changed. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/pester-parallel.2026-11-07T04-46.md.
- TypeScript: Baseline: N/A - no pre-change run -> Post-change: 98.22% lines, 93.42% branches. Change: N/A. New/changed-code coverage: N/A - no production file changed. Disposition: PASS. Evidence: coverage/lcov.info; docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/jest-coverage.2026-11-07T04-03.md.

Python detail. This review parsed `artifacts/python/lcov.info`: 366 files, 32270 of 33367 lines and 11722 of 12516 branches. The figures match the gate record. The gate set `PYTHONPATH` to the worktree `packages/discovery-runtime/src`; no source, omit, or pragma entry changed.

PowerShell detail. The root LINE counter of `artifacts/pester/powershell-coverage.xml` is 23248 covered and 1519 missed (93.87%). Pester reports no branch figure, and no branch threshold applies. `artifacts/pester/pester-junit.xml` reads 14518 tests, 0 failures, 0 errors, 10 disabled, which identifies a full-tree run. All 56 `PGW-` testcases report `Passed`.

TypeScript detail. This review parsed `coverage/lcov.info`: 276 files, 67752 of 68978 lines and 10031 of 10737 branches. The only changed TypeScript file is a test, which is excluded from the denominator.

Freshness. The last change outside the feature folder is `06a1ea618`, committed at 23:40:38 local time. The Pester and pytest artifacts were written at 23:46 and 23:49, after it. The Jest artifact was written at 23:02, before cycle 2. Cycle 2 changed no TypeScript file, and a search of `extensions/drm-copilot/test` finds no reference to the files cycle 2 changed, so that artifact still describes head.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions name the copy and the tokens: `offending`, `missing`, and `-Because` text. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit `# Arrange`, `# Act`, and `# Assert` comments, and their `//` equivalents in Jest. |
| **Document Intent** | ✅ PASS | Docstrings on new Python tests, TSDoc on Jest helpers, and comment-based help in the Pester suite. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Reads repository files only. |
| **Use Mocks/Stubs** | N/A | No external system is involved. |
| **Environment Stability** | ✅ PASS | The Pester suite derives the root from `$PSScriptRoot`; no temporary files are created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required review. The outstanding item is RF-6. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1094, reduced by the owner split recorded in `issue.md` and `spec.md`. |
| **Read existing change plans** | ✅ PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-07T04-38.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-11-06T20-01.md`, `remediation-plan.2026-11-07T03-22.md`, and `remediation-plan.2026-11-07T04-20.md`, whose tasks are all checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Table-driven `PGW-` rows with small helpers. |
| **Reusability** | ✅ PASS | `_section` gains an optional path; `buildNoPreChangeRunPolicyAuditText` reuses the existing valid fixture. |
| **Extensibility** | ✅ PASS | New rows and tokens extend the tables without code changes. |
| **Separation of concerns** | ✅ PASS | Test-only code; no production logic is added. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One new suite with one purpose. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical lines: `test_validate_policy_audit_artifact.py` 580, `test_execution_environment_brief_contracts.py` 566, `test_discovery_documentation_contracts.py` 461, `test_single_pass_preflight_contracts.py` 432, `policy-audit-artifact.test.ts` 426, `parallel-gate-wording.Tests.ps1` 260, `test_codex_orchestration_contracts.py` 95. None reaches 700. `config/file-size-baseline.json` is unchanged. |
| **Public vs internal** | N/A | No public API. |
| **No circular dependencies** | N/A | No module dependency is added. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | For example `test_brief_copies_carry_no_removed_run_tokens`, `Get-PgwSweepFile`, `buildNoPreChangeRunPolicyAuditText`. |
| **Docs/docstrings** | ✅ PASS | New tests and helpers are documented. |
| **Comment why, not what** | ✅ PASS | Comments state why tokens are folded and why `baseline coverage` is not a sweep token. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check`, `npx prettier --check`, and `Invoke-Formatter`.<br>**Result:** 5 Python files unchanged, the TypeScript file matches Prettier, and the PowerShell file is identical after formatting (reviewer runs at head). |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check`, `npx eslint`, and `Invoke-ScriptAnalyzer`.<br>**Result:** 0 findings in each (reviewer runs at head). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright` and `npm run typecheck`.<br>**Result:** 0 errors in each (reviewer runs at head). N/A for PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** one `Invoke-PoshQCParallelTest` run, one `poetry run pytest -n auto` run, and one `npm run test:unit:coverage` run.<br>**Result:** 0 failures in all three. `artifacts/pester/pester-junit.xml` confirms 14518 tests and 56 `PGW-` testcases. |
| **Full toolchain loop** | ✅ PASS | Static tools and gates are clean at head, and no change outside the feature folder follows the gates. RF-6 changes hook code; its remediation re-runs the affected gates. |
| **Explicit reporting** | ✅ PASS | Commands are recorded under `evidence/` and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 of this audit and the commit history. |
| **Design choices explained** | ✅ PASS | Spec `## Decisions` and `## Constraints & Risks`. |
| **Update supporting documents** | ✅ PASS | The brief lists the new contract test under `## Contract Tests That Pin Mirrored Files`. |
| **Provide next steps** | ✅ PASS | `remediation-inputs.2026-11-07T05-01.md`. |

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
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter` with the repo settings<br>**Result:** output identical to the file. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with the repo settings<br>**Result:** 0 findings. |
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
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 260 logical lines. |
| **Approved verbs** | ✅ PASS | `Get-PgwSurfaceText`, `Get-PgwTokenHit`, `Get-PgwSweepHit`, `Get-PgwSweepFile`. |
| **Comment why** | ✅ PASS | The header and sweep comments state rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `evidence/qa-gates/powershell-format.2026-11-07T04-41.md`. |
| **Step 2: Analyze** | ✅ PASS | `evidence/qa-gates/powershell-analyze.2026-11-07T04-41.md`. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | `evidence/qa-gates/pester-parallel.2026-11-07T04-46.md`. |
| **Rerun loop if needed** | ✅ PASS | One gate run in the remediation cycle. |

---

### Section 3E: TypeScript Code Change Policy Compliance

#### 3E.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | **Command:** `npx prettier --check`<br>**Result:** the file matches Prettier style. |
| **Linting with ESLint** | ✅ PASS | **Command:** `npx eslint`<br>**Result:** exit 0, no findings. |
| **Type checking with TSC** | ✅ PASS | **Command:** `npm run typecheck`<br>**Result:** exit 0 for the source and test projects. |

#### 3E.2 TypeScript Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No untyped escape hatches** | ✅ PASS | The added helpers use explicit types; no `any` is added. |
| **Immutable fixture data** | ✅ PASS | The replacement table is `readonly`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Plain functions; existing helpers. |
| **Coverage expectation** | ✅ PASS | Repo-wide artifact 96.71% line, 93.66% branch, against 85% and 75%. |

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
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe, 1 Context, 56 generated `It` testcases. |
| **Logical Grouping** | ✅ PASS | Per-file rows, then the class sweep. |
| **Docstrings/Comments** | ✅ PASS | Comment-based help on helpers. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Command:** `Invoke-PoshQCParallelTest -Root .`<br>**Result:** ExitCode 0, 8 shards. |
| **No Alternative Test Runners** | ✅ PASS | Pester through PoshQC only. |

---

### Section 4C: TypeScript Unit Test Policy Compliance

#### 4C.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | ✅ PASS | `describe`, `it`, and `expect`, in the existing file. |
| **Test location** | ✅ PASS | `extensions/drm-copilot/test/lib/validate/`, mirroring `src/lib/validate/`. |
| **Coverage expectation** | ✅ PASS | Repo-wide artifact 98.22% line, 93.42% branch, against 85% and 75%. |

#### 4C.2 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest workers** | ✅ PASS | **Command:** `npm run test:unit:coverage`<br>**Result:** 330 suites and 5303 tests passed, 0 failures, per `evidence/qa-gates/jest-coverage.2026-11-07T04-03.md`. |

---

## 5. Test Coverage Detail

### parallel-gate-wording.Tests.ps1 (56 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `PGW-<Id>` (54 rows) | Positive and Negative | N/A - text surfaces | ✅ |
| `PGW-SWEEP-SURFACES` | Negative | N/A - text surfaces | ✅ |
| `PGW-SWEEP-HELPER` | Edge Case | N/A - in-memory text | ✅ |

**Coverage:** N/A; the suite pins Markdown and TOML text, not production code.

**Not covered:** the suite reads wording only, so it cannot show that a filled audit passes the stop hook (RF-6).

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

**Not covered:** nothing additional.

---

### policy-audit-artifact.test.ts (2 new tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `accepts an audit that records no pre-change run` | Positive | `validatePolicyAuditSubstantiveRequirements` | ✅ |
| `accepts the no-pre-change-run comparison line only through the later Post-change percentage` | Positive and Negative | `validatePolicyAuditSubstantiveRequirements` | ✅ |

**Coverage:** see Section 1.2.1. `policy-audit-artifact.ts` measures 94.92% line and 83.70% branch.

**Not covered:** nothing additional.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 35930 (14518 Pester, 16109 pytest, 5303 Jest) | ✅ |
| Tests Passed | 16103 pytest; 5303 Jest; Pester 14518 tests with 0 failures and 10 disabled | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 315.77 s Pester, 162.39 s pytest | ✅ Fast |
| Average Time per Test | N/A - parallel wall-clock | ✅ |
| Discovery Time | N/A - not recorded by the parallel gates | ✅ |
| Functions/Classes Tested | N/A - no production function changed | ✅ |
| Test File Size | 260 logical lines for the new file; 580 maximum | ✅ PASS |
| Code Coverage (if applicable) | Python 96.71% lines, 93.66% branches; PowerShell 93.87% lines; TypeScript 98.22% lines, 93.42% branches | ✅ |

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
| Invoke-Formatter | `Invoke-Formatter` | identical | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | ExitCode 0, 0 failures | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check` | clean | ✅ |
| ESLint | `npx eslint` | 0 findings | ✅ |
| TSC | `npm run typecheck` | 0 errors | ✅ |
| Jest Tests | `npm run test:unit:coverage` | 0 failures | ✅ |

**Notes:**
`poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exited 0 at head. Of the 116 bundle files in the diff, 110 equal their source after line-ending normalization; the other 6 are `csharp-legacy` variants with no same-path source. All 66 changed source files that have a same-path bundle copy equal it. The six `execution-environment` copies share one blob, and each `atomic-plan-contract` bundle copy shares the blob of its source. The path-limited diff over `.claude/rules`, `.github/instructions`, the policy mirrors, `.github/workflows`, `.github/actions`, `scripts/benchmarks`, `scripts/powershell/PoshQC`, `.vscode/tasks.json`, `scripts/dev_tools`, `extensions/drm-copilot/src`, `config`, and `pyproject.toml` is empty. `modified-workflow-needs-green-run` does not fire. Tier classification: `quality-tiers.yml` exists, `check_quality_tiers.py` reports 29 entries for 29 projects, and no project is added. A search of the agent diff for tool-entry lines returns 0 changed lines.

---

## 8. Gaps and Exceptions

### Identified Gaps

- RF-6: `Test-LanguageCoverageRow` in `.claude/hooks/validate-feature-review-coverage-rules.ps1` rejects every line outside `## Rejected Scope Narrowing` that holds a changed-language label, a coverage word (`coverage`, `lcov`, `pester`), and `N/A`. `.codex/hooks/validate-feature-review-coverage.ps1` carries the same pattern. The branch template prescribes `- PowerShell baseline coverage artifact: N/A - no pre-change run`, the same line for TypeScript, and a comparison line holding `Baseline: N/A - no pre-change run` and `Change: N/A`. The `feature-review-workflow` skill prescribes the same comparison line.
  - Probe 1: the real hook, run from the item worktree on `policy-audit.2026-11-07T04-20.md`, exits 2 with `a coverage-scoped row narrows scope: '- PowerShell baseline coverage artifact: N/A - no pre-change run'`. The Python row is rejected in the same run.
  - Probe 2: the same payload with `stop_hook_active` true also exits 2, because the condition is classed repairable.
  - Probe 3, controls on `Test-LanguageCoverageRow`: the PowerShell checklist line with a path returns Ok, and with the N/A record returns not Ok. The TypeScript checklist line with the N/A record returns not Ok. The Python comparison line with numeric values returns Ok, and with the N/A record returns not Ok.
  - Impact: the checklist labels are required by the validators, so a branch that changes PowerShell or TypeScript has no compliant wording. A branch that changes Python production code needs `New/changed-code coverage:` on the comparison line, which has the same result.
  - Why earlier cycles likely did not surface it: the item folder exists only in the worktree, so a hook that resolves paths against the main checkout stops at the file-existence check and does not reach this rule. This was inferred from the hook flow and the caller's note, and was not observed in an earlier run. The draft at `research/full-scope-plan-draft-for-1096.md` states that the hook needs no change because it reads no baseline field; that statement does not consider the `N/A` match.

### Approved Exceptions

- Decision 1 of `spec.md`: policy files are not edited; they still name single-process commands and a changed-line rule. Recorded by the spec for the owner report.
- The deferred Python tools and VS Code aggregates in spec `### 2. Out of scope` move to #1096.
- Policy-audit baseline fields record `N/A - no pre-change run` by owner directive.

### Removed/Skipped Tests

`test_brief_test_isolation_requires_seeded_pester_shuffle` and `test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` were replaced by the tests in Section 5, as the spec directs. No test was skipped by this branch.

---

## 9. Summary of Changes

### Commits in This PR/Branch

62 non-merge commits plus the merge of `origin/main`. Remediation commits for RF-5 and the optional items:

1. **b5f4b228c** - docs(agents): state the parallel gates in the staged-review test step
2. **20231993e** - docs(agents): add the debugging statement and reword the bug template verification
3. **dc30fca18** - docs(agents): fix the class sweep hits in three Copilot agents
4. **06a1ea618** - test(claude-runtime): pin the cycle 2 sweep tokens and wording rows

### Files Modified

1. **`tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`** (NEW)
   - Per-file token rows and a class sweep of 38 tokens over the mirrored surfaces.

2. **`tests/scripts/dev_tools/test_*.py`, five modules** (MODIFIED)
   - Replaced contract tests, the `REPO_ROOT`-relative worktree filter, and validator record tests.

3. **`extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts`** (MODIFIED)
   - Two cases pin the no-pre-change-run record in the TypeScript validator.

4. **Skills, agents, prompts, templates in all mirrors** (MODIFIED)
   - Parallel gates, static baselines, and coverage read from the single gate run.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Coverage, toolchain, mirror, and scope requirements are met, and 14 of 15 acceptance criteria evaluate as PASS. One blocking finding remains, RF-6: the record that the branch prescribes is rejected by the coverage stop hook.

**Fail-closed reminder:** numeric post-change coverage is recorded for every changed language. This audit does not report PASS because RF-6 is open.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and policy read recorded
- ✅ Design Principles: table-driven tests
- ✅ Module & File Structure: all files below 700 lines
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: clean at head; gates postdate the last change outside the feature folder
- ✅ Summarize & Document: compliant

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean at head
- ✅ Python Design & Typing: compliant
- ✅ Error Handling: test code only

**For PowerShell:**
- ✅ Tooling & Baseline: clean at head
- ✅ PowerShell Design & Safety: compliant
- ✅ Structure & Naming: compliant
- ✅ Toolchain: one parallel gate run

**For TypeScript:**
- ✅ Tooling & Baseline: clean at head
- ✅ Design: compliant

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: compliant
- ⚠️ Coverage & Scenarios: all three languages above the thresholds; no test covers the audit record against the stop hook (RF-6)
- ✅ Test Structure: compliant
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: compliant
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: `pytest -n auto`

**For PowerShell:**
- ✅ Framework & Scope: compliant
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: `Invoke-PoshQCParallelTest`

**For TypeScript:**
- ✅ Framework & Scope: compliant
- ✅ Toolchain: Jest through its normal workers

---

### Metrics Summary

- ✅ 0 failures in all three gates
- ✅ Python 96.71% line and 93.66% branch against 85% and 75%
- ✅ PowerShell 93.87% line against 85%
- ✅ TypeScript 98.22% line and 93.42% branch against 85% and 75%
- ✅ Bundle copies equal their sources; the 5 cycle 2 sweep tokens hit at `2c5c12a08` and not at head
- ✅ All code quality checks clean
- ⚠️ RF-6 open in the two coverage stop hooks and their bundle copies

---

### Recommendation

**Needs revision**

Resolve RF-6 per `remediation-inputs.2026-11-07T05-01.md`, then re-run the Pester gate once, and any other gate the edit affects. No other blocking item remains. `CI Required Gate` stays pending until a PR head exists, and the orchestrator's S9 gate owns it.

---

## Appendix A: Test Inventory

### Complete Test List

- Parallel gate wording › `PGW-<Id>` carries the required wording and no forbidden wording (54 rows)
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
- `policy-audit-artifact.test.ts` › `validatePolicyAuditSubstantiveRequirements` › accepts an audit that records no pre-change run
- `policy-audit-artifact.test.ts` › `validatePolicyAuditSubstantiveRequirements` › accepts the no-pre-change-run comparison line only through the later Post-change percentage

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Reviewer runs at head, check-only, over the five changed test modules
poetry run black --check <files>
poetry run ruff check <files>
poetry run pyright <files>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python scripts/dev_tools/check_quality_tiers.py
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check

# Gate, per evidence/qa-gates/pytest-parallel.2026-11-07T04-50.md
PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov
```

**For PowerShell:**
```powershell
# Reviewer runs at head, check-only, over the changed suite
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# RF-6 probe, from the item worktree, with a SubagentStop payload on stdin
pwsh -NoProfile -File .claude/hooks/validate-feature-review-coverage.ps1

# Gate, per evidence/qa-gates/pester-parallel.2026-11-07T04-46.md
Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCParallelTest -Root .
```

**For TypeScript:**
```bash
# Reviewer runs at head, check-only, from extensions/drm-copilot
npx prettier --check test/lib/validate/policy-audit-artifact.test.ts
npx eslint test/lib/validate/policy-audit-artifact.test.ts
npm run typecheck

# Gate, per evidence/qa-gates/jest-coverage.2026-11-07T04-03.md, at the repository root
npm run test:unit:coverage
```

No suite was re-run by this review. Coverage figures were parsed from the existing artifacts.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)

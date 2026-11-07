# Policy Compliance Audit: parallel-only-test-gates-and-leak-scan (#1094)

---

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after the remediation of RF-6 (`remediation-inputs.2026-11-07T05-01.md`) and the process-reduction ledger addendum (`remediation-plan-ledger.2026-11-07T06-50.md`)
**Code Under Test:** Full branch diff of `feature/parallel-only-test-gates-and-leak-scan-1094` (head `3c842ab7f9dce9aca98b47866e69b54047b734a7`) against `origin/main` (merge base `51d3886485956df68a68a38e920c7c3687ec4462`, which equals the fetched `origin/main` tip): 334 paths, of which 92 are in the feature folder. Outside the feature folder: 242 paths (237 modified, 5 added). By extension: 142 Markdown, 87 TOML, 7 PowerShell, 4 Python, 1 TypeScript, 1 patch. Production code: `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, and their two bundle copies. The other seven code files are tests.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 4 files | 16109 tests | ✅ 16103 pass, 0 fail, 6 skipped | N/A - no pre-change run | 96.71% lines, 93.66% branches | N/A - no production file changed |
| PowerShell | 7 files | 14584 tests | ✅ 14584 tests, 0 fail, 10 disabled | N/A - no pre-change run | 93.87% lines | 100% of changed lines |
| TypeScript | 1 file | 5303 tests | ✅ 5303 pass, 0 fail | N/A - no pre-change run | 98.22% lines, 93.42% branches | N/A - no production file changed |

Rows for C#, Bash, and JSON are deleted because the branch diff holds zero files of those languages.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - no pre-change run
- TypeScript post-change coverage artifact: coverage/lcov.info
- PowerShell baseline coverage artifact: N/A - no pre-change run
- PowerShell post-change coverage artifact: artifacts/pester/powershell-coverage.xml
- Per-language comparison summary: Section 1.2.1 of this audit

**Assumption on template source:** the MCP template resolver was not available to this agent. The structure of this audit follows `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` on the reviewed branch. That template has no TypeScript section, so Sections 3E and 4C were added for the changed TypeScript test file.

---

## Executive Summary

RF-6 is closed, the process-reduction ledger entry is in place, and no blocking finding remains. Coverage passes for all three changed languages, and 14 of 15 acceptance criteria evaluate as PASS. Criterion 15 is pending CI on the PR head and is not a finding.

- RF-6 closed. The two hooks hold byte-identical `Get-CoverageNarrowingLine` definitions, and each hook equals its bundle copy. The prescribed lines are accepted and every other narrowing form stays rejected. This review checked that three ways: direct calls on all 30 line cases of the parity suite, 14 reverted mutants of the rule, and real hook runs on this audit from the item worktree (Section 8).
- Ledger entry `0001`: `Test-ProcessReductionLedger` over the real folder returns `IsValid` true, 0 errors, row count 1. The committed patch reverses cleanly on the working tree. Applied in reverse to a temporary index, it returns all 238 reduction paths to the merge base, leaving only the ledger files, the promoted record, and the feature folder different.
- Two Minor items and five Info items are recorded in `code-review.2026-11-07T06-38.md`. None is blocking. The two Minor items are the PR number in the entry, because `#1101` is an open PR of another branch, and two regular-expression guards with no discriminating test case.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [✅] `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md`
- [N/A] Bash: no bash file in the branch diff
- [N/A] JSON: no JSON file in the branch diff

Toolchain state: every static tool was re-run check-only at head with zero findings. The Pester and pytest gates ran after the last code change and reported zero failures. By owner directive they were not re-run after the merge of `origin/main`, which is not a fix; test results for the merged head come from CI on the PR head. No suite was run by this review.

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted: `git status --short` was empty before this review wrote its artifacts, and the branch diff holds no script outside `tests/` and the hook folders.
- [✅] Any ongoing tooling scripts are fully tested and compliant with repo policies: no tooling script is added.
- Review probes were written only to the session scratchpad.

---

## Rejected Scope Narrowing

No narrowing was rejected. The caller text below was evaluated against the Scope Invariant.

> "No review check may require a single-process, seeded-shuffle, reversed-order, comparison, or pre-change baseline run, and you must not report the absence of one as a finding."

This text does not limit the audit to a subset of the diff and does not waive any language. It was accepted because it matches the owner directive the branch implements. The `.claude/agents/feature-review.md` on `main` still names a changed-line comparison; the branch removes that wording, and the owner directive governs this review. Coverage for Python, PowerShell, and TypeScript carries an explicit verdict read against the thresholds.

> "Test results for the merged head come from CI on the PR head, which is the CI-dependent criterion and the S9 gate."

This text concerns when a result becomes available, not which files are audited. The audit scope stayed the full diff, and the coverage figures are stated with their run time in Section 1.2.1.

> "spec `## Decisions` and the out-of-scope list record what was deferred to #1096 by owner decision."

This text identifies the spec sections that hold the deferral. The audit scope stayed the full feature-vs-base diff.

> "Classify a result that only CI can supply as `awaiting_ci`."

This text was evaluated with the contract in `acceptance-criteria-tracking` `### CI-Dependent Criteria` and `orchestrate` `## PR Creation Gate` condition 2. Criterion 15 is the only item that CI alone can supply. It is listed as pending-CI with `awaiting_ci` as its class of wait, and it carries no finding block, because a blocking entry would hold the PR that CI requires. If the S9 poll times out, `orchestrate` records that timeout as a finding with this class.

---

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 from the item worktree. The branch diff holds no file under `artifacts/`. Evidence is stored under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/remediation-baseline/`, `<FEATURE>/evidence/qa-gates/`, `<FEATURE>/evidence/issue-updates/`, and `<FEATURE>/evidence/other/`, all canonical kinds. No violations were found.

---

## Process-Reduction Ledger Compliance

Rule: `feature-review-workflow` `### Process-reduction ledger`. `docs/engineering/process-reductions/` exists, and the branch reduces gates, so the rule applies.

| Requirement | Status | Evidence |
|------------|--------|----------|
| **A reduction has an entry** | ✅ PASS | `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`, with one Index row. `Test-ProcessReductionLedger` over the real folder: `IsValid` true, 0 errors, row count 1. |
| **Entry format** | ✅ PASS | The six sections are present, with four `### Revert Block:` subsections and a stored patch. `## Revert Steps` names the six labels in order. |
| **Entry is revertible** | ✅ PASS | `git apply -R --check` of the committed patch blob exits 0 on the working tree. Reverse application to a temporary index leaves 4 paths differing from the merge base outside the feature folder: the three ledger files and the promoted record. `Get-ProcessReductionRevertBlock` returns the 4 named paths. |
| **File list is complete** | ✅ PASS | 242 paths outside the feature folder, less the 3 ledger files and the promoted record, equals the 238 paths recorded by `ledger-check.2026-11-07T06-25.md`. |
| **Token in a commit subject** | ✅ PASS | `20e1cb1cc` carries `reduction: 0001` and holds exactly the entry, the patch, and the README. No path outside the feature folder changes after it. |
| **Each reduction is its own commit** | ⚠️ PARTIAL | The reduction spans the branch's earlier commits, and `20e1cb1cc` holds only the record. Reason, verified from the log: the rule was committed on `main` as `dfbb071d5` and reached this branch through merge `5483ba240` at 01:05 local time. The last code commit before that merge, `9c4049cb8`, is dated 00:50. The entry's `## Summary` states this. The Blocking condition of the rule is a reduction with no entry, which does not apply. Non-blocking; rewriting 84 commits would add risk and no revert capability. |

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Added tests read repository files or in-memory text and share no mutable state. All suites ran under parallel workers: 8 Pester shards, `pytest -n auto`, and Jest workers. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `PGW-` row per file and one `FRN-` row per line case. Each hook is dot-sourced in its own child scope. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pester 317.45 s over 14584 tests; pytest 177.80 s over 16109 tests, per `evidence/qa-gates`. |
| **Determinism** - Consistent results | ✅ PASS | File reads and in-memory fixtures only; no clock, network, or randomness in the added tests. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names, table-driven cases, and `-Because` failure text. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Changed Files Meet Thresholds** | ✅ PASS | `validate-feature-review-coverage-rules.ps1` 98 of 99 lines (98.99%); `.codex/hooks/validate-feature-review-coverage.ps1` 163 of 163 lines (100%), against the 85% line threshold. Read from `artifacts/pester/powershell-coverage.xml` by this review. The two bundle copies are byte-identical to these sources. |
| **New Code Threshold** | N/A | No production file was added. |
| **Comprehensive Tests** | ✅ PASS | `FRN-ACCEPT`, `FRN-REJECT`, `FRN-SECTION`, and `FRN-PARITY` run on both hooks. Two regular-expression guards have no discriminating case; see Section 8. |
| **Positive Flows** - Valid inputs | ✅ PASS | 8 accept rows on each hook, including the prescribed checklist, comparison, and table lines. |
| **Negative Flows** - Invalid inputs | ✅ PASS | 22 reject rows on each hook. Direct calls on those rows gave 0 wrong results, and 12 of 14 mutants of the rule changed at least one result. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Fifth versus sixth table cell, a lowercase record, the record after other labels, and a `.NET` label line. |
| **Error Handling** - Error paths | N/A | The rule is a pure string function with no failure branch. |
| **Concurrency** - If applicable | N/A | The added tests only read files. |
| **State Transitions** - If applicable | ✅ PASS | The only state is the section flag inside one call, covered by `FRN-SECTION`. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: N/A - no pre-change run -> Post-change: 96.71% lines, 93.66% branches. Change: N/A. New/changed-code coverage: N/A - no production file changed. Disposition: PASS. Evidence: artifacts/python/lcov.info; docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/pytest-parallel.2026-11-07T06-02.md.
- PowerShell: Baseline: N/A - no pre-change run -> Post-change: 93.87% lines. Change: N/A. New/changed-code coverage: 100% of changed lines. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml; docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/pester-parallel.2026-11-07T05-59.md.
- TypeScript: Baseline: N/A - no pre-change run -> Post-change: 98.22% lines, 93.42% branches. Change: N/A. New/changed-code coverage: N/A - no production file changed. Disposition: PASS. Evidence: coverage/lcov.info; docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/evidence/qa-gates/jest-coverage.2026-11-07T04-03.md.

Thresholds: the root `CLAUDE.md` states none, so the defaults of 85% line and 75% branch govern. Pester reports no branch figure, and no branch threshold applies to PowerShell.

Python detail. This review parsed `artifacts/python/lcov.info`: 366 files, 32270 of 33367 lines and 11722 of 12516 branches. The figures match the gate record. The gate set `PYTHONPATH` to the worktree `packages/discovery-runtime/src`; no source, omit, or pragma entry changed.

PowerShell detail. The root LINE counter of `artifacts/pester/powershell-coverage.xml` is 23275 covered and 1519 missed (93.87%). `artifacts/pester/pester-junit.xml` reads 14584 tests, 0 failures, 0 errors, 10 disabled, which identifies a full-tree run. The only lines of the rules file with missed instructions are 42, 45, and 87, and none lies in a hunk of the branch diff. The Codex hook has no missed line. The bundle copies sit under `extensions/drm-copilot/resources/`, are not measured separately, and are byte-identical to their sources.

TypeScript detail. This review parsed `coverage/lcov.info`: 276 files, 67752 of 68978 lines and 10031 of 10737 branches. The only changed TypeScript file is a test, which is excluded from the denominator.

Freshness. The last code commit is `9c4049cb8`, dated 00:50 local time. The Pester artifact was written at 00:59 and the Python artifact at 01:02, both after it. The TypeScript artifact was written at 23:02, after the last TypeScript commit `d0b9b4836` at 22:53. Merge `5483ba240` at 01:05 and the ledger commits followed these runs. The merge added `scripts/dev-tools/ProcessReductionLedger.psm1`, its two suites, the ledger README, and the ledger rule in six skill copies; none of these is measured in the figures above. Under the owner directive, the merged-head result comes from CI on the PR head.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions name the surface and the reported reason through `-Because` text. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit `# Arrange`, `# Act`, and `# Assert` comments, or `# Act` and `# Assert` where the case table is the arrangement. |
| **Document Intent** | ✅ PASS | The parity suite header states what each row family pins; docstrings on new Python tests and TSDoc on Jest helpers. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | Reads repository files only. The parity suite header states no temporary file, no child process, and no clock. |
| **Use Mocks/Stubs** | ✅ PASS | The hook closure seams are mocked in the parity suite, so no seam reads live repository state; the row rule runs unmocked. |
| **Environment Stability** | ✅ PASS | The suites derive the root from `$PSScriptRoot`; no temporary files are created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the required review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1094, reduced by the owner split recorded in `issue.md` and `spec.md`. |
| **Read existing change plans** | ✅ PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-07T05-46.md` and `phase0-instructions-read.2026-11-07T06-22.md`. |
| **Document the plan** | ✅ PASS | `remediation-plan.2026-11-07T05-01.md` and `remediation-plan-ledger.2026-11-07T06-50.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One function holds the narrowing rule. The allow-list is three patterns and two gated removals. |
| **Reusability** | ⚠️ PARTIAL | The function is copied into the Claude and Codex hooks, as `Test-LanguageCoverageRow` already was. `FRN-PARITY` pins the two definitions as equal. Non-blocking; the two runtimes ship as separate surfaces. |
| **Extensibility** | ✅ PASS | New allowed positions are entries in one array. |
| **Separation of concerns** | ✅ PASS | The narrowing rule is a pure string function; I/O stays in the hook entry points. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The rule sits with the other coverage-row rules. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest logical line counts: `test_validate_policy_audit_artifact.py` 580, `test_execution_environment_brief_contracts.py` 566, `validate-feature-review-coverage.Tests.ps1` 447, `test_single_pass_preflight_contracts.py` 432, `policy-audit-artifact.test.ts` 426, Codex hook 363. None reaches 700. `config/file-size-baseline.json` is not in the branch diff. |
| **Public vs internal** | N/A | No public API. |
| **No circular dependencies** | ✅ PASS | The rules file stays dot-sourced by one hook. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-CoverageNarrowingLine`, `$recordPatterns`, `$reducedLine`. |
| **Docs/docstrings** | ✅ PASS | The rules file synopsis and description, and the Codex hook description, name the rule and its three positions. |
| **Comment why, not what** | ✅ PASS | Comments state why the record is removed in three positions only, and why the condition reads the original line. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check`, `npx prettier --check`, and `Invoke-Formatter`.<br>**Result:** 4 Python files unchanged, the TypeScript file matches Prettier, and all 7 PowerShell files are identical after formatting (reviewer runs at head). |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check`, `npx eslint`, and `Invoke-ScriptAnalyzer`.<br>**Result:** 0 findings in each (reviewer runs at head). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright` and `npm run typecheck`.<br>**Result:** exit 0 in each (reviewer runs at head). Does not apply to PowerShell. |
| **4. Testing** | ✅ PASS | **Command:** one `Invoke-PoshQCParallelTest` run, one `poetry run pytest -n auto` run, and one `npm run test:unit:coverage` run.<br>**Result:** 0 failures in all three. `artifacts/pester/pester-junit.xml` confirms 14584 tests. |
| **Full toolchain loop** | ✅ PASS | Static tools are clean at head, and no code changed on this branch after the gates. The merged-head run is CI on the PR head, per the owner directive. |
| **Explicit reporting** | ✅ PASS | Commands are recorded under `evidence/` and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 of this audit and the commit history. |
| **Design choices explained** | ✅ PASS | Spec `## Decisions` and `## Constraints & Risks`, which now records the hook change. |
| **Update supporting documents** | ✅ PASS | Ledger entry 0001 and its Index row. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check`<br>**Result:** 4 files unchanged. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** no findings. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** exit 0. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`<br>**Result:** 16103 passed, 6 skipped, 0 failures. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | No Python file changed since the prior review. The private helper is bound through a `cast` to a typed `Callable`. |
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
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `Invoke-Formatter` with the repo settings<br>**Result:** output identical for all 7 files. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `Invoke-ScriptAnalyzer` with the repo settings<br>**Result:** 0 findings in all 7 files. |
| **Fix all findings** | ✅ PASS | None to fix. |
| **PowerShell 5.1 & 7.6+ compatible** | ✅ PASS | The new function uses regular expressions and string methods available in both. The test suites declare PowerShell 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `Get-CoverageNarrowingLine` uses `CmdletBinding` and `OutputType`. |
| **Parameter validation** | ✅ PASS | Mandatory parameters, with `AllowEmptyString` on `Lines`. |
| **Avoid global state** | ✅ PASS | Function-local state only. |
| **Error handling** | ✅ PASS | The function has no failure branch and fails closed: a line outside the allow-list stays a narrowing line. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | Rules file 229 logical lines, Codex hook 363, narrowing suite 163. |
| **Approved verbs** | ✅ PASS | `Get-CoverageNarrowingLine`. |
| **Comment why** | ✅ PASS | See Section 2.4. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | `evidence/qa-gates/powershell-format.2026-11-07T05-50.md`. |
| **Step 2: Analyze** | ✅ PASS | `evidence/qa-gates/powershell-analyze.2026-11-07T05-50.md`. |
| **Step 3: Type check** | N/A | Does not apply to this language. |
| **Step 4: Test** | ✅ PASS | `evidence/qa-gates/pester-parallel.2026-11-07T05-59.md`. |
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
| **Focused Unit Tests** | ✅ PASS | One case per row. |
| **Test Behavior Over Implementation** | ✅ PASS | `FRN-` rows call the row rule on audit text. `FRN-PARITY` compares definition text by design. |
| **Mocking Used Sparingly** | ✅ PASS | Only the closure seams of the hooks are mocked. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1`, beside its sibling `feature-review-coverage-floor-parity.Tests.ps1`.<br>**Code file:** the two hooks. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `feature-review-coverage-narrowing-parity.Tests.ps1`, `parallel-gate-wording.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One Describe per suite with generated `It` rows; 65 `FRN-` and 56 `PGW-` testcases. |
| **Logical Grouping** | ✅ PASS | Accept, reject, section, and parity rows. |
| **Docstrings/Comments** | ✅ PASS | File header and comment-based help on helpers. |

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

### feature-review-coverage-narrowing-parity.Tests.ps1 (65 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `FRN-ACCEPT` (8 rows, 2 hooks) | Positive | `Get-CoverageNarrowingLine` | ✅ |
| `FRN-REJECT` (22 rows, 2 hooks) | Negative | `Get-CoverageNarrowingLine` | ✅ |
| `FRN-SECTION` (2 rows, 2 hooks) | Edge Case | `Get-CoverageNarrowingLine` | ✅ |
| `FRN-PARITY` | Edge Case | Definition text of both hooks | ✅ |

**Coverage:** see Section 1.2.1.

**Not covered:** the backtick colon guard and the `Change:` lookbehind have no discriminating row (Section 8).

---

### parallel-gate-wording.Tests.ps1 (56 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `PGW-<Id>` (54 rows) | Positive and Negative | Text surfaces | ✅ |
| `PGW-SWEEP-SURFACES` | Negative | Text surfaces | ✅ |
| `PGW-SWEEP-HELPER` | Edge Case | In-memory text | ✅ |

**Coverage:** the suite pins Markdown and TOML text, not production code.

**Not covered:** a paraphrase outside the 38 tokens. This review also searched the surfaces for other phrasing at head.

---

### Python contract tests (6 new or replaced tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_brief_test_isolation_states_parallel_gates` | Positive | Text surfaces | ✅ |
| `test_brief_copies_carry_no_removed_run_tokens` | Negative | Text surfaces | ✅ |
| `test_brief_passages_state_parallel_gate_facts` | Positive | Text surfaces | ✅ |
| `test_contract_premortem_test_isolation_states_parallel_gates` | Positive and Negative | Text surfaces | ✅ |
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

**Coverage:** see Section 1.2.1.

**Not covered:** nothing additional.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 35996 (14584 Pester, 16109 pytest, 5303 Jest) | ✅ |
| Tests Passed | 16103 pytest; 5303 Jest; Pester 14584 tests with 0 failures and 10 disabled | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 317.45 s Pester, 177.80 s pytest | ✅ Fast |
| Average Time per Test | N/A - parallel wall-clock | ✅ |
| Discovery Time | N/A - not recorded by the parallel gates | ✅ |
| Functions/Classes Tested | 1 production function added, `Get-CoverageNarrowingLine`, in two hooks | ✅ |
| Test File Size | 163 logical lines for the newest file; 580 maximum | ✅ PASS |
| Code Coverage (if applicable) | Python 96.71% lines, 93.66% branches; PowerShell 93.87% lines; TypeScript 98.22% lines, 93.42% branches | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check` | 4 unchanged | ✅ |
| Ruff Linting | `poetry run ruff check` | no findings | ✅ |
| Pyright Type Checking | `poetry run pyright` | exit 0 | ✅ |
| Pytest Tests | `poetry run pytest -n auto` | 0 failures | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter` | identical, 7 files | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` | 0 findings, 7 files | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | ExitCode 0, 0 failures | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check` | clean | ✅ |
| ESLint | `npx eslint` | 0 findings | ✅ |
| TSC | `npm run typecheck` | exit 0 | ✅ |
| Jest Tests | `npm run test:unit:coverage` | 0 failures | ✅ |

**Notes:**
`poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exited 0 at head. `poetry run python scripts/dev_tools/check_quality_tiers.py` reported OK for 29 entries and 29 discovered projects; `quality-tiers.yml` is not in the branch diff. Of the changed sources, 112 pairs with a same-path bundle copy were compared after line-ending normalization, and 0 differ. The six `execution-environment` copies share one blob. Each `feature-review-workflow` source shares a blob with its bundle copy. The `modified-workflow-needs-green-run` rule does not fire: the diff is empty over `.github/workflows/`, `.github/actions/`, and `scripts/benchmarks/`.

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap remains. The items below are recorded for the owner.

- `Merge commit: pending (PR #1101)` in the ledger entry. No PR exists for this branch. `#1101` is an open PR, `Stage B: stage timing (#1097)`, with head `feature/reduce-feature-cycle-time`. The number therefore cannot be correct for this branch, and the provisional correction after the PR opens is required, not optional. That PR's file list touches no ledger file and none of this branch's skills or hooks. Non-blocking, because the correct number cannot exist before this branch's PR.
- Two guards of `Get-CoverageNarrowingLine` have no discriminating row. Of 14 reverted mutants, evaluated by direct calls on the 30 line cases and 2 section cases of the parity suite, 12 changed a result and 2 did not: removing the `(?<![\w/-])` lookbehind from the `Change: N/A` removal, and removing the `(?<!:\s*)` guard from the backtick pattern. Both guards work at head: `Post-Change: N/A` on a record line and a colon-led backticked record are both reported as narrowing. Non-blocking, with two rows recommended in `code-review.2026-11-07T06-38.md`.
- The ledger rule's own-commit clause is met in part; see `## Process-Reduction Ledger Compliance`.
- Merged-head test results. Merge `5483ba240` followed the gates, and the ledger suite `PRL-REAL-LEDGER-AGREES` has not run against a real entry in a test run. A direct call of `Test-ProcessReductionLedger` on the real folder returns valid, and the suite's assertion reads the same result. Criterion 15 supplies the test result.

Probes for RF-6, each from the item worktree. Outcomes are stated in the Executive Summary.

- `Get-CoverageNarrowingLine` on the 8 accept rows and 22 reject rows of the parity suite: 0 wrong results.
- Real hook runs on this audit, with a SubagentStop payload on standard input: `.claude/hooks/validate-feature-review-coverage.ps1` exit 0 with empty output; `.codex/hooks/validate-feature-review-coverage.ps1` exit 0 with empty output.
- `hook-proof.2026-11-07T05-53.md` was written after the last hook commit, and `scope-check.2026-11-07T06-03.md` matched its hashes to the files.

### Approved Exceptions

- Decision 1 of `spec.md`: policy files are not edited; they still name single-process commands and a changed-line rule. Recorded by the spec for the owner report.
- The deferred Python tools and VS Code aggregates in spec `### 2. Out of scope` move to #1096.
- Policy-audit baseline fields record `N/A - no pre-change run` by owner directive.
- Spec `## Constraints & Risks` records the hook change, which supersedes the text-only wording elsewhere in the spec.

### Removed/Skipped Tests

`test_brief_test_isolation_requires_seeded_pester_shuffle` and `test_contract_premortem_test_isolation_requires_seeded_pester_shuffle` were replaced by the tests in Section 5, as the spec directs. No test was skipped by this branch.

---

## 9. Summary of Changes

### Commits in This PR/Branch

84 non-merge commits plus 2 merges of `origin/main`. Commits since the prior review that change paths outside the feature folder:

1. **f300c46af** - fix(hooks): accept the no-pre-change-run record in the Claude coverage hook
2. **7284479ce** - fix(hooks): align the Codex coverage hook with the Claude narrowing rule
3. **9c4049cb8** - test(hooks): add the coverage narrowing parity suite for both hooks
4. **5483ba240** - Merge remote-tracking branch 'origin/main'
5. **20e1cb1cc** - docs(process-reductions): record parallel-only test gates (#1094), reduction: 0001

### Files Modified

1. **`.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, and bundle copies** (MODIFIED)
   - `Get-CoverageNarrowingLine` accepts the prescribed record in three positions. The Codex hook gains the rejected-section skip, the branch exception, and the `.NET` label correction.

2. **`tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1`** (NEW)
   - One case table run on both hooks.

3. **`tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`** (NEW)
   - Per-file token rows and a class sweep of 38 tokens over the mirrored surfaces.

4. **`tests/scripts/dev_tools/test_*.py`, four modules** (MODIFIED)
   - Replaced contract tests and validator record tests. The fifth module of earlier cycles, `test_discovery_documentation_contracts.py`, equals `origin/main` after the merge, because `main` holds the same filter.

5. **`extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts`** (MODIFIED)
   - Two cases pin the no-pre-change-run record in the TypeScript validator.

6. **`docs/engineering/process-reductions/`** (ADDED ENTRY)
   - Entry 0001, its stored patch, and one Index row.

7. **Skills, agents, prompts, templates in all mirrors** (MODIFIED)
   - Parallel gates, static baselines, and coverage read from the single gate run.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

Coverage, toolchain, mirror, scope, and ledger requirements are met, and 14 of 15 acceptance criteria evaluate as PASS. Criterion 15 is pending CI on the PR head. No blocking finding remains.

**Fail-closed reminder:** numeric post-change coverage is recorded for every changed language, and changed-line coverage is recorded for the changed production files.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: plan and policy read recorded
- ✅ Design Principles: compliant; the rule is copied across two surfaces and pinned equal
- ✅ Module & File Structure: all files below 700 lines
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: clean at head; gates postdate the last code commit
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
- ✅ Coverage & Scenarios: all three languages above the thresholds; the changed hook lines are covered
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
- ✅ PowerShell 93.87% line against 85%; changed hook files 98.99% and 100%
- ✅ TypeScript 98.22% line and 93.42% branch against 85% and 75%
- ✅ 112 source and bundle pairs equal; 0 sweep hits over 894 surface files
- ✅ All code quality checks clean
- ✅ Ledger entry 0001 valid and its patch reversible

---

### Recommendation

**Ready for PR**

Open the PR, then replace `PR #1101` in the ledger entry with this branch's PR number before the S9 gate, so that `ci_gate.head_sha` describes the corrected head. `CI Required Gate` stays pending until a PR head exists, and the orchestrator's S9 gate owns it.

---

## Appendix A: Test Inventory

### Complete Test List

- feature-review coverage narrowing parity › `FRN-ACCEPT` (8 rows on each hook)
- feature-review coverage narrowing parity › `FRN-REJECT` (22 rows on each hook)
- feature-review coverage narrowing parity › `FRN-SECTION` (2 rows on each hook)
- feature-review coverage narrowing parity › `FRN-PARITY`
- Parallel gate wording › `PGW-<Id>` carries the required wording and no forbidden wording (54 rows)
- Parallel gate wording › Class sweep › `PGW-SWEEP-SURFACES`
- Parallel gate wording › Class sweep › `PGW-SWEEP-HELPER`
- `test_execution_environment_brief_contracts.py::test_brief_test_isolation_states_parallel_gates`
- `test_execution_environment_brief_contracts.py::test_brief_copies_carry_no_removed_run_tokens`
- `test_execution_environment_brief_contracts.py::test_brief_passages_state_parallel_gate_facts`
- `test_single_pass_preflight_contracts.py::test_contract_premortem_test_isolation_states_parallel_gates`
- `test_validate_policy_audit_artifact.py::test_validate_policy_audit_text_accepts_no_pre_change_run_record`
- `test_validate_policy_audit_artifact.py::test_comparison_line_baseline_label_reaches_later_percentage`
- `test_codex_orchestration_contracts.py::test_codex_orchestrator_workflow_requires_large_path_evidence_gates` (assertion updated)
- `policy-audit-artifact.test.ts` › `validatePolicyAuditSubstantiveRequirements` › accepts an audit that records no pre-change run
- `policy-audit-artifact.test.ts` › `validatePolicyAuditSubstantiveRequirements` › accepts the no-pre-change-run comparison line only through the later Post-change percentage

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Reviewer runs at head, check-only, over the four changed test modules
poetry run black --check <files>
poetry run ruff check <files>
poetry run pyright <files>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python scripts/dev_tools/check_quality_tiers.py
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check

# Gate, per evidence/qa-gates/pytest-parallel.2026-11-07T06-02.md
PYTHONPATH=<worktree>/packages/discovery-runtime/src poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov
```

**For PowerShell:**
```powershell
# Reviewer runs at head, check-only, over the seven changed files
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Ledger, from the item worktree
Import-Module ./scripts/dev-tools/ProcessReductionLedger.psm1
Test-ProcessReductionLedger -Ledger (Read-ProcessReductionLedger -LedgerPath docs/engineering/process-reductions)
git apply -R --check <committed patch blob>

# Real hook probes, from the item worktree, with a SubagentStop payload on stdin
pwsh -NoProfile -File .claude/hooks/validate-feature-review-coverage.ps1
pwsh -NoProfile -File .codex/hooks/validate-feature-review-coverage.ps1

# Gate, per evidence/qa-gates/pester-parallel.2026-11-07T05-59.md
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

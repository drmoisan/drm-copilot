# Policy Compliance Audit: retire `.github/skills` and thin the Copilot layer (#1032)

---

**Audit Date:** 2026-11-20  
**Review type:** S7 feature review and R4 exit re-audit of remediation cycles 1 and 2  
**Code Under Test:** merge base `0cf0dd629c51e74d84298e3c8c98b01044c4ec3d` of the base branch `origin/epic/shared-agent-harness-layer-integration` (orchestrator decision AD-7) and reviewed head `6a0b4b3f7da7d98629be3fa3c695834e9b514406`; the head is 0 commits behind the integration tip and `git merge-tree` against the tip reports no conflict. The diff lists 356 files (6107 insertions, 11919 deletions): 147 added, 109 deleted, 100 modified; 151 of them are feature-folder documents.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 3 modified production, 7 modified test files | 6450 Jest tests (extension gate); 6482 (reviewer root run) | ✅ 0 fail | 97.29% lines, 94.30% branches | 97.51% lines, 94.83% branches | 98.17% to 100.00% lines, 90.00% to 100.00% branches per modified production file |
| Python | 2 modified production, 17 modified test files | 17107 pytest cases | ✅ 17101 pass, 6 skipped, 0 fail | 98.00% lines, 95.46% branches | 98.00% lines, 95.46% branches | 98.02% and 98.25% lines, 94.12% and 90.00% branches per modified production file |
| PowerShell | 1 modified production module, 1 deleted production script, 1 added and 18 modified test files, 1 deleted test file | 29141 Pester tests | ✅ 29123 pass, 18 skipped, 0 fail | 96.77% lines | 96.84% lines | 100.00% lines (`HarnessInstructions.psm1`, 64/64) |
| JSON / Markdown / patch data | settings, tasks, shard weights, parity matrix, pack manifests, ledger entries and patches, skills, agents, docs | N/A | ✅ pinned by contract tests | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/evidence/baseline/jest-baseline.2026-11-19T08-00.md` (main plan Phase 0) and `evidence/baseline/h3-jest-baseline.2026-11-19T14-49.md` (H3 plan Phase 0)
- TypeScript post-change coverage artifact: `coverage/lcov.info` at the worktree root (reviewer run, `evidence/qa-gates/review-jest-root-coverage.2026-11-20T05-09.md`) and the executor gate `evidence/regression-testing/c2-jest-final.2026-11-20T04-43.md`
- Python baseline coverage artifact: `evidence/baseline/pytest-baseline.2026-11-19T07-59.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (written 2026-11-20T04:42Z by the gate in `evidence/regression-testing/c2-pytest-final.2026-11-20T04-43.md`)
- PowerShell baseline coverage artifact: `evidence/baseline/pester-baseline.2026-11-19T08-12.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (merged 2026-11-20T04:55Z by the gate in `evidence/regression-testing/c2-pester-final.2026-11-20T04-55.md`)
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-11-19T11-59.md`, `evidence/qa-gates/h3-coverage-delta.2026-11-19T17-08.md`, `evidence/qa-gates/c2-coverage-note.2026-11-20T04-56.md`, and section 1.2.1 below

The reviewer re-parsed the executor's JSON reports and the canonical artifacts with read-only Node scripts and obtained the recorded figures: pytest 35359/36079 lines and 13091/13714 branches; Pester root LINE counter 47273 covered and 1541 missed; Jest per-file figures identical in the executor's extension run and the reviewer's root run. All commits after the 2026-11-20T04:42Z to 04:55Z gate runs (`872165dfa`, `af74c42f4`, `6a0b4b3f7`) change only feature-folder files, so the reports describe the reviewed head.

Disclosure: at review start the canonical TypeScript artifact `coverage/lcov.info` was absent at the worktree root because the executor's Jest gate wrote its report under `SCRATCH`. The reviewer ran one root Jest coverage run through normal parallel workers (6482 tests passed) to create it, and recorded the run as new evidence. No other test or coverage generation was run by this review.

---

## Executive Summary

The branch deletes both `RETIRED-SKILL-TREES` (`.github/skills/` and its Copilot bundle mirror), repoints the four `READ-FIRST-AGENTS` and their bundle copies to `.agents/skills/execution-environment/SKILL.md`, reduces `.github/copilot-instructions.md` to Copilot-only text, documents the collision controls as user-scope settings in `README.md` (E4 workspace scope read as `no`), sets the Branch B `native` dispositions for all 50 `copilot:agent:` entries, retires the `AGENTS.md` sync writer and every `H3-SURFACES` member, rewrites every copy-count statement from six to four, and updates the process-reduction ledger records in the same commits. Remediation cycle 1 (pack manifests after #1029) and cycle 2 (merge of #1049, #1050, #1051) are both resolved at the reviewed head. No blocking policy finding was identified.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (`.claude/rules/general-unit-test.md`)
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on the base branch; the branch adds no project)

**Language-specific policies evaluated:**
- ✅ `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` (`.claude/rules/typescript.md`)
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (`.claude/rules/python.md`; existing files edited in place only)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (`.claude/rules/powershell.md`)
- ✅ JSON configuration and data: validated by the pinned contract suites

**Temporary artifacts cleanup:**
- ✅ No scratch script is committed; executor and reviewer helpers live under `SCRATCH` outside the repository.
- ✅ `git status --porcelain` is empty at the reviewed head after the reviewer run.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | All gates ran in parallel workers (`Invoke-PoshQCParallelTest` with 8 workers, `pytest -n auto`, Jest workers) with 0 failures; the new guard suite holds no cross-test state and removes its helper functions in `AfterAll`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | `copilot-layer-retirement.Tests.ps1` has one `It` per `CLR-` rule and one `-REJECTS` companion per rule. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The guard suite is 22 text checks; edited suites only drop rows. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, or sleep in added or edited tests. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Rule ids in test names; Arrange-Act-Assert comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline:** Jest 97.29% lines, 94.30% branches; pytest 98.00% lines, 95.46% branches; Pester 96.77% lines<br>**Command:** launcher `jest-extension --coverage`, `pytest --cov --cov-branch`, `pester`<br>**Artifact:** `evidence/baseline/jest-baseline.2026-11-19T08-00.md`, `pytest-baseline.2026-11-19T07-59.md`, `pester-baseline.2026-11-19T08-12.md`<br>**Timestamp:** 2026-11-19 07:59 to 08:12 UTC |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** Jest 97.51% lines, 94.83% branches; pytest 98.00% / 95.46%; Pester 96.84%<br>**Change:** no repo-wide drop in any language<br>**Status:** every changed production line is a removal, a non-executable comment or docstring, or a covered import line |
| **Changed Files Meet Thresholds** | ✅ PASS | **Post-change coverage:** lowest modified production file `repo-automation-command-registration-admin.ts` 98.17% lines, 90.00% branches<br>**Thresholds:** 85% lines, 75% branches (defaults; root `CLAUDE.md` states none); line only for PowerShell<br>**Status:** all modified production files meet the thresholds |
| **New Code Coverage** | ✅ PASS | **New files:** no new production file; one new test file<br>**New code coverage:** no added executable production line<br>**Calculation method:** `git diff` of each production file read against the per-file figures |
| **Comprehensive Coverage** | ✅ PASS | The retirement is guarded by `CLR-` rules and by the edited contract suites; uncovered lines in modified files are unchanged code. |
| **Positive Flows** - Valid inputs | ✅ PASS | Each `CLR-` rule runs over the committed repository files. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Each `CLR-` rule has a `-REJECTS` case over in-memory text that breaks the rule. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Changelog removal under a released version only (`CLR-WRITER-CHANGELOG-REJECTS`); writer file map with one present and one absent file. |
| **Error Handling** - Error paths | ✅ PASS | Absent files return `$null` through `Read-ClrText` and are reported as violations. |
| **Concurrency** - If applicable | N/A | No concurrent behavior is changed. |
| **State Transitions** - If applicable | N/A | No stateful component is changed. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.29% lines, 94.30% branches -> Post-change: 97.51% lines, 94.83% branches. Change: +0.22% lines, +0.53% branches (the cycle-2 denominator growth comes from the merged #1049 to #1051 suites). New/changed-code coverage: 98.17% lines and 90.00% branches (`repo-automation-command-registration-admin.ts`, baseline 98.26% / 90.27%; 21 covered lines removed, the one modified line is a covered import), 99.15% lines and 94.11% branches (`reference-rewrites.ts`, baseline 99.17% / 94.11%; removal only), 100.00% lines and 100.00% branches (`copilot-customizations-engine.ts`, baseline 97.99% / 86.66%; removal of one array element; the file was later refactored by #1029). Disposition: PASS. Evidence: `coverage/lcov.info`, `evidence/qa-gates/review-jest-root-coverage.2026-11-20T05-09.md`, `evidence/regression-testing/c2-jest-final.2026-11-20T04-43.md`.
- Python: Baseline: 98.00% lines, 95.46% branches -> Post-change: 98.00% lines, 95.46% branches. Change: 0.00%. New/changed-code coverage: 98.02% lines and 94.12% branches (`scripts/dev_tools/agentic_sync.py`, unchanged from baseline; one tuple element removed and docstring lines rewritten), 98.25% lines and 90.00% branches (`scripts/dev_tools/push_down_copilot_customizations_rewrites.py`, unchanged from baseline; one tuple argument removed). Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/regression-testing/c2-pytest-final.2026-11-20T04-43.md`.
- PowerShell: Baseline: 96.77% lines -> Post-change: 96.84% lines. Change: +0.07%. New/changed-code coverage: 100.00% lines (`scripts/harness-generation/HarnessInstructions.psm1`, 64/64; two text edits on covered lines); the deleted writer script (72.09% at baseline) left the denominator. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/regression-testing/c2-pester-final.2026-11-20T04-55.md`. Pester measures no branch coverage, so no branch threshold applies.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Each `CLR-` check returns violation strings that name the file and the broken rule. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comment markers in every `It` of the new suite. |
| **Document Intent** | ✅ PASS | Comment-based help in the new suite; one comment per helper naming its rule. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The guard suite reads tracked repository files only; no network or process. |
| **Use Mocks/Stubs** | ✅ PASS | Reader seams (`Read-ClrText`, `Get-ClrFileUnder`) separate I/O from the pure rule checks. |
| **Environment Stability** | ✅ PASS | No temporary files; the retired path and writer tokens are built at runtime so the suite does not match its own searches. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit with `code-review.2026-11-20T05-16.md` and `feature-audit.2026-11-20T05-16.md`; executor self-reviews `evidence/qa-gates/self-review.2026-11-19T12-03.md` to `self-review.2026-11-20T04-59.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1032, child 6 of epic #1018; `spec.md` v0.4 and `user-story.md`. |
| **Read existing change plans** | ✅ PASS | Phase 0 upstream records `evidence/baseline/phase0-upstream-child1.2026-11-19T07-48.md`, `phase0-upstream-child3...`, `phase0-upstream-children4-5...`; anchor re-checks `h3-recheck`, `branch-b-recheck`, `c2-baseline-ref`. |
| **Document the plan** | ✅ PASS | Main plan, H3 plan, Branch B plan and both remediation plans, all checked off. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Deletions and single-element removals; no new production code. |
| **Reusability** | ✅ PASS | The guard suite factors one `Test-ClrRetiredPathAbsent` check across agent files, current documents and pack manifests. |
| **Extensibility** | ✅ PASS | No public API added; removed command `drmCopilotExtension.syncAgentsFromInstructions` recorded under `### Removed` in the extension CHANGELOG. |
| **Separation of concerns** | ✅ PASS | Pure checks over text supplied by reader seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Each edit stays in the file that pinned the removed surface. |
| **At or below the 800-line hard limit** | ✅ PASS | 49 added or modified covered files measured in logical lines; largest `test_execution_environment_brief_contracts.py` 676 and `test-cadence-wording.Tests.ps1` 542; none at or above 700; `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | Only the removed command export changed visibility; its registration call was removed with it. |
| **No circular dependencies** | ✅ PASS | No import added; the registration-admin import was narrowed to `getWorkspaceRoot`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `CLR-` rule names map to spec checks. |
| **Docs/docstrings** | ✅ PASS | `agentic_sync.py` module docstring updated to the remaining roots; `reference-rewrites.ts` catalog-size comment updated. |
| **Comment why, not what** | ✅ PASS | `HarnessInstructions.psm1` comment names the retired writer by issue rather than by a removed path. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** Prettier check, Black check, Invoke-Formatter comparison over the changed files<br>**Result:** 0 differences (`final-static-*.2026-11-19T11-17.md`, `h3-final-static-*.2026-11-19T16-43.md`, `r1-final-static.2026-11-19T13-47.md`, `c2-final-static.2026-11-20T04-34.md`) |
| **2. Linting** | ✅ PASS | **Command:** ESLint `--max-warnings 0`, Ruff, PSScriptAnalyzer with repo settings<br>**Result:** 0 findings |
| **3. Type checking** | ✅ PASS | **Command:** `npm run typecheck`, Pyright<br>**Result:** 0 errors |
| **4. Testing** | ✅ PASS | **Command:** launcher `pester`, `pytest`, `jest-extension`<br>**Result:** Pester 29123 passed, 18 skipped; pytest 17101 passed, 6 skipped; Jest 6450 passed; 0 failures |
| **Full toolchain loop** | ✅ PASS | One clean pass per cycle; contract checks (`c2-contract-checks.2026-11-20T04-34.md`: Codex generator check, harness skills and agents checks with no drift, manifest JSON parse); stage 4 is not configured for these packages; stage 7 runs in CI. |
| **Explicit reporting** | ✅ PASS | Every command step records `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit subjects `feat(1032)`, `test(1032)`, `docs(1032)` with `reduction: NNNN` tokens on ledger commits. |
| **Design choices explained** | ✅ PASS | `spec.md` AD-1 to AD-4; deviation records under `evidence/other/` (AD-7 merge base, entry 0012, integration lane). |
| **Update supporting documents** | ✅ PASS | `README.md`, `extensions/drm-copilot/README.md`, CHANGELOG, architecture doc, `.agents/README.md` and bundle copy, legacy-discovery guides. |
| **Provide next steps** | ✅ PASS | Destination cleanup of stale `.github/skills` copies remains with child 4 (risk R3). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3T: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | No type changed; only removals. |
| **ES modules** | ✅ PASS | Unchanged module form. |
| **No new runtime dependency** | ✅ PASS | `package.json` change removes one `contributes.commands` entry only. |
| **Error handling** | ✅ PASS | Not affected. |
| **Language rule** | ✅ PASS | TypeScript edits are in extension-command and MCP-tool code, which the owner rule permits. |

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check` over the changed Python files<br>**Result:** 0 changes |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`<br>**Result:** 0 findings |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors |
| **Testing with Pytest** | ✅ PASS | **Command:** `pytest -n auto` through the launcher<br>**Result:** 17101 passed, 6 skipped |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Typed tuple constants keep their annotations. |
| **Dataclasses for value objects** | N/A | No new type. |
| **Protocols/ABCs for interfaces** | N/A | No new interface. |
| **Avoid utility classes** | N/A | No new class. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No new error handling. |
| **Logging over print** | N/A | No new output. |
| **Invariants at construction** | N/A | No new class. |

No `.py` file is added between the merge base and the head (owner rule "Avoid new Python").

### Section 3P: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **PowerShell 7+** | ✅ PASS | New suite declares `#Requires -Version 7.0`. |
| **Formatter and analyzer clean** | ✅ PASS | PSScriptAnalyzer 0 findings and formatter unchanged (`h3-final-static-powershell.2026-11-19T16-43.md`, `c2-final-static.2026-11-20T04-34.md`). |
| **Change budget** | ✅ PASS | One production module edited (`HarnessInstructions.psm1`) and one deleted script, on the orchestrated path. |
| **No Invoke-Expression, no hard-coded host paths** | ✅ PASS | Inspected in the diff. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4T: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | ✅ PASS | Edited suites under `extensions/drm-copilot/test/` mirror `src/`. |
| **Coverage expectation** | ✅ PASS | Per-file figures in section 1.2.1. |
| **Parallel-only runs** | ✅ PASS | Executor and reviewer runs used normal Jest workers. |

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `UPDATED-PYTEST-MODULES` edited in place; no edit removes an assertion about a remaining copy. |
| **Coverage expectation** | ✅ PASS | Repo-wide 98.00% lines, 95.46% branches from `artifacts/python/lcov.info`. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Edits remove retired copy rows and retarget the canonical brief. |
| **Mocking sparingly** | ✅ PASS | No mock added. |
| **Organization** | ✅ PASS | File locations unchanged. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | Test names that held a six-copy count now name the four-copy count. |
| **Docstrings/comments** | ✅ PASS | Module docstrings updated with the copy list. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch ...`<br>**Result:** 17101 passed, 6 skipped, 0 failed |
| **No Alternative Test Runners** | ✅ PASS | Only Pytest. |

### Section 4P: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester** | ✅ PASS | New suite `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1`; edited suites in place. |
| **Coverage expectation** | ✅ PASS | Repo-wide 96.84% lines; `HarnessInstructions.psm1` 100.00%. |
| **Parallel-only runs** | ✅ PASS | One `Invoke-PoshQCParallelTest` run per gate. |

---

## 5. Test Coverage Detail

### `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` (guard suite, 22 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| CLR-SKILL-TREES-ABSENT and -REJECTS | Positive / Negative | tree listing check | ✅ |
| CLR-BRIEF-COUNT and -REJECTS | Positive / Negative | S1 to S6 target and source wording | ✅ |
| CLR-READ-FIRST and -REJECTS | Positive / Negative | read-first line | ✅ |
| CLR-COPILOT-INSTRUCTIONS and -REJECTS | Positive / Negative | tone tokens and bundle identity | ✅ |
| CLR-COLLISION-CONTROLS and -REJECTS | Positive / Negative | AD-3 case exclusivity, kept-default keys | ✅ |
| CLR-AGENT-FILES, CLR-CURRENT-DOCS, CLR-PACK-MANIFESTS and -REJECTS | Positive / Negative | retired-path absence | ✅ |
| CLR-WRITER-FILES-ABSENT, CLR-WRITER-COMMAND-ABSENT, CLR-WRITER-CHANGELOG and -REJECTS | Positive / Negative / Edge | H3 surfaces | ✅ |

**Coverage:** test file; not in the production denominator.

**Not covered:** the retired-path branch of `Test-ClrBriefCount` and the workspace-case branch of `Test-ClrCollisionControl` are not driven by a `-REJECTS` case (non-blocking; code review finding CR-1).

### Modified production files

`repo-automation-command-registration-admin.ts` 98.17% / 90.00%; `reference-rewrites.ts` 99.15% / 94.11%; `copilot-customizations-engine.ts` 100.00% / 100.00%; `agentic_sync.py` 98.02% / 94.12%; `push_down_copilot_customizations_rewrites.py` 98.25% / 90.00%; `HarnessInstructions.psm1` 100.00% lines (lines / branches).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Jest 6450 (extension gate), 6482 (reviewer root run); pytest 17107; Pester 29141 | ✅ |
| Tests Passed | Jest 6450; pytest 17101 (6 skipped); Pester 29123 (18 skipped) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Jest 21.6 s; pytest 256.72 s; Pester 730.18 s wall-clock (8 workers) | ✅ |
| Average Time per Test | Not recorded per test in evidence | ✅ |
| Discovery Time | Not recorded in evidence | ✅ |
| Functions/Classes Tested | All `CLR-` checks; all edited pinning suites | ✅ |
| Test File Size | Largest edited test file 676 logical lines | ✅ PASS |
| Code Coverage (if applicable) | TypeScript 97.51% / 94.83%; Python 98.00% / 95.46%; PowerShell 96.84% lines | ✅ |

---

## 7. Code Quality Checks

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check` over changed TS files | All matched files use Prettier code style | ✅ |
| ESLint | `npx eslint --max-warnings 0` over changed TS files | 0 findings | ✅ |
| TSC | `npm run --silent typecheck` | 0 errors | ✅ |
| Jest | launcher `jest-extension --coverage` | 394 suites, 6450 tests passed | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check` over changed Python files | 0 changes | ✅ |
| Ruff Linting | `poetry run ruff check` | 0 findings | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | launcher `pytest` (`-n auto`) | 17101 passed, 6 skipped | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | formatter comparison over changed PS files | unchanged | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer` with repo settings | 0 findings | ✅ |
| Pester Tests | launcher `pester` (`Invoke-PoshQCParallelTest`) | 29123 passed, 18 skipped | ✅ |

**Notes:**
Static checks were run per cycle over the files each cycle changed; cycle 2 changed only TypeScript and PowerShell test files and data, and its loop passed on the first iteration.

---

## CI Cross-check

No pull request exists for this branch yet (PR context `Auto-close issues: None (no PR exists yet for this branch)`), so no CI run exists at the reviewed head. Two CI runs on earlier heads of this branch concluded `success`: run 44574374390 at `02a329dc1` (H3 plan) and run 44599765016 at `58bca152e` (Branch B). The outcomes below are from local evidence; the orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

| Check | Claimed outcome | Claimed figure | Head | Source |
|-------|-----------------|----------------|------|--------|
| PowerShell QC (format, analyze) | pass | 0 findings | 6a0b4b3f7da7d98629be3fa3c695834e9b514406 | `evidence/qa-gates/c2-final-static.2026-11-20T04-34.md` |
| PowerShell QC shards (Pester) | pass | 29123 passed, 96.84% lines | 6a0b4b3f7da7d98629be3fa3c695834e9b514406 | `evidence/regression-testing/c2-pester-final.2026-11-20T04-55.md`, `artifacts/pester/powershell-coverage.xml` |
| Harness parity matrix repo gate | pass | 7 passed | 6a0b4b3f7da7d98629be3fa3c695834e9b514406 | `evidence/regression-testing/c2-pester-final.2026-11-20T04-55.md` |
| drm-copilot Extension Tests (Jest) | pass | 6450 passed; 97.51% lines, 94.83% branches | 6a0b4b3f7da7d98629be3fa3c695834e9b514406 | `evidence/regression-testing/c2-jest-final.2026-11-20T04-43.md`, `coverage/lcov.info` |
| TypeScript format, lint, type check | pass | 0 findings, 0 errors | 6a0b4b3f7da7d98629be3fa3c695834e9b514406 | `evidence/qa-gates/c2-final-static.2026-11-20T04-34.md` |
| quality-checks7 / Code Quality & Tests (3.13) (`Enforce Python coverage thresholds`) | pass | 98.00% lines, 95.46% branches | 6a0b4b3f7da7d98629be3fa3c695834e9b514406 | `evidence/regression-testing/c2-pytest-final.2026-11-20T04-43.md`, `artifacts/python/lcov.info` |

---

## Coverage Verification (per language with changed files)

| Language | Artifact | Repo-wide | New files | Modified files | Verdict |
|----------|----------|-----------|-----------|----------------|---------|
| TypeScript | `coverage/lcov.info` | 97.51% lines, 94.83% branches (extension gate); 98.51% / 94.51% (root run) | none | 3, all at or above 85% / 75%, no changed-line regression | PASS |
| Python | `artifacts/python/lcov.info` | 98.00% lines, 95.46% branches | none | 2, all at or above 85% / 75%, unchanged from baseline | PASS |
| PowerShell | `artifacts/pester/powershell-coverage.xml` | 96.84% lines | none | 1 at 100.00% lines | PASS |

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exited 0 in the worktree. The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. All evidence, including the reviewer's new record, is under `docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/evidence/<kind>/`. No violation.

## Rejected Scope Narrowing

None. The caller directed the diff to the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD` (AD-7), which is the PR base branch and the full branch diff; this is not a narrowing.

## Additional Policy Rules

| Rule | Status | Evidence |
|------|--------|----------|
| modified-workflow-needs-green-run | N/A | No path under `.github/workflows/**`, `.github/actions/**` or `scripts/benchmarks/**` is in the diff. |
| Process-reduction ledger | PASS | Ledger records changed only in the five commits that delete or edit their regions, each carrying the `reduction: NNNN` token of every entry it modifies; `ProcessReductionChain.psm1` is not in the diff; no skip list added; `LEDGER-CHAIN-TESTS` pass. |
| Documentation surface check | N/A | `docs/documentation-estate/docs-profile.json` is absent on the branch head. |
| Tier classification | PASS | `quality-tiers.yml` exists on the base branch; the branch adds no project or library folder. |
| Coverage exclusion policy | PASS | No coverage `exclude` entry added. |
| Canonical policy files | PASS | No file under `.claude/rules/`, `.github/instructions/`, `.claude/settings.json` or `CLAUDE.md` is in the diff. |
| No new Python | PASS | No `.py` file added between the merge base and the head. |
| File size | PASS | No covered file at or above 700 logical lines; `config/file-size-baseline.json` unchanged. |

## Owner Directive Decisions

- OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | 2026-11-20T05:03:42Z | The review proceeds to completion without asking questions or pausing, consistent with the feature-review no-questions constraint.
- OWNER-DIRECTIVE-DECISION: OD-2 | merge_timing | refused | 2026-11-20T05:03:42Z | Outside the feature-review agent scope: the reviewer produces audit artifacts only and performs no merge; the orchestrator owns merge timing.
- OWNER-DIRECTIVE-DECISION: OD-3 | merge_timing | refused | 2026-11-20T05:03:42Z | Outside the feature-review agent scope: the reviewer performs no merge and deletes no branch; the orchestrator owns post-merge branch cleanup.
- OWNER-DIRECTIVE-DECISION: OD-4 | scheduling | refused | 2026-11-20T05:03:42Z | Outside the feature-review agent scope: the cost-benefit rule governs parallel scheduling decisions, which the coordinator makes, not audit verdicts.
- OWNER-DIRECTIVE-DECISION: OD-5 | scheduling | refused | 2026-11-20T05:03:42Z | Outside the feature-review agent scope: the parallel cap is a coordinator scheduling setting and the reviewer launches no parallel work.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None blocking.** Non-blocking observations are recorded in the code review (CR-1 to CR-3).

### Approved Exceptions

**None.** Orchestrator decisions AD-7 (merge-base scope against the integration branch) and AD-8 (atomic-plan-contract copies form two pre-existing byte-identical pairs) are applied as recorded.

### Removed/Skipped Tests

`tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` is deleted with the writer it tested (spec `H3-SURFACES`). Rows for the retired copies were removed from the pinning suites; no assertion about a remaining copy was removed.

---

## 9. Summary of Changes

The branch retires the Copilot skill copies and their bundle mirror, settles `.github/agents` as Branch B native, thins the Copilot instructions, documents the collision controls as user-scope settings, retires the `AGENTS.md` sync writer, updates every count statement and pinning test, updates the ledger records, and resolves two integration syncs.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All toolchain stages passed, coverage meets the thresholds for every language with changed files, and no blocking policy finding was identified. Review-Verdict: PASS.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: Phase 0 upstream and anchor re-checks recorded for every plan
- ✅ Design Principles: removals only; no new production code
- ✅ Module & File Structure: all files below 700 logical lines
- ✅ Toolchain Execution: one clean pass per cycle

#### Language-Specific Code Change Policy (Section 3)
- ✅ TypeScript: removals in extension-command and push-down code
- ✅ Python: in-place edits of existing files
- ✅ PowerShell: one module text edit; one script deleted

#### General Unit Test Policy (Section 1)
- ✅ Core Principles, coverage, structure, dependencies

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Jest, Pytest and Pester gates in parallel workers

---

### Metrics Summary

- ✅ 6450/6450 Jest tests passing (extension gate); 6482/6482 in the reviewer root run
- ✅ 17101 pytest tests passing, 6 skipped
- ✅ 29123 Pester tests passing, 18 skipped
- ✅ All modified production files at or above 85% lines and 75% branches

---

### Recommendation

**Ready for PR creation**, subject to the orchestrator's S9 CI green gate on the PR head.

---

## Appendix A: Test Inventory

### Complete Test List

- Added: `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` (22 tests).
- Deleted: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`.
- Edited Pester: `DocsAuthoringRoles.Helpers.ps1`, `NestingDepthContract.Tests.ps1`, `claude-architecture-doc.Tests.ps1`, `docs-authoring-roles.Mirrors.Tests.ps1`, `docs-authoring-roles.Skills.Tests.ps1`, `docs-authoring-roles.Templates.Tests.ps1`, `documentation-workflow.CommitStage.Tests.ps1`, `less-evidence-contract.Tests.ps1`, `light-remediation-skill-contract.Tests.ps1`, `owner-directives-skill-contract.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `test-cadence-wording.Tests.ps1`, `ProcessReductionLedger.Tests.ps1`, three `tests/scripts/claude-hooks/*.Parity.Tests.ps1`, `PoshQC.VendoredCoverage.RepoGate.Tests.ps1`.
- Edited pytest: the twelve always-edited `UPDATED-PYTEST-MODULES`, the four conditional ones (`test_agentic_sync.py`, `test_agentic_sync_artifacts.py`, `test_push_down_copilot_customizations.py`, `test_push_down_copilot_customizations_rewrites.py`), and `test_bash_command_shape_surfaces.py`.
- Edited Jest: `extension.test.ts`, `extension.integration.test.ts`, `extension.workflow-commands.test.ts`, `copilot-customizations-engine.test.ts`, `reference-rewrites.test.ts`, `push-down-ci-contract.test.ts`, `push-down-integration-skill.test.ts`.

---

## Appendix B: Toolchain Commands Reference

**Commands run by this review (check-only, plus one coverage run):**
```bash
git -C <worktree> fetch origin
git -C <worktree> merge-base origin/epic/shared-agent-harness-layer-integration HEAD
git -C <worktree> diff --name-status 0cf0dd629c51e74d84298e3c8c98b01044c4ec3d..HEAD
git -C <worktree> merge-tree --write-tree --name-only origin/epic/shared-agent-harness-layer-integration HEAD
git -C <worktree> ls-files -s '*execution-environment/SKILL.md' '*atomic-plan-contract/SKILL.md'
git -C <worktree> grep -c -F '.github/skills' -- . ':!docs/features/'
git -C <worktree> grep -c -e syncAgentsFromInstructions -e sync-agents-from-instructions -- . ':!docs/features/'
git -C <worktree> log --first-parent --format='%h %s' 0cf0dd629c51e74d84298e3c8c98b01044c4ec3d..HEAD -- docs/engineering/process-reductions/
node <scratch script> (per-file figures from coverage-summary.json, pytest JSON report, and logical line counts)
python scripts/dev_tools/validate_evidence_locations.py --root .
sh SCRATCH/issue-1032-rev-jest.sh   # node run-jest.cjs --coverage at the worktree root
```

**Executor final gates (read from evidence):**
```bash
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage
env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch
sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-11-20  
**Policy Version:** Current (as of audit date)

# Policy Compliance Audit: Test-support hygiene and stale skipif (#938)

---

**Audit Date:** 2026-10-16
**Audit Type:** Initial audit
**Branch:** `bug/test-support-hygiene-793-skipif-938` (HEAD `91044a5b7`)
**Base:** `origin/main` (`adb9aa5f0`; merge base equals the `origin/main` tip)
**Work Mode:** `minor-audit`
**Code Under Test:** 11 non-documentation files changed: 1 new Python test-support module, 8 modified Python test modules, 1 modified TypeScript test file (comment change only), plus feature-folder documentation and evidence (48 files). No production Python, TypeScript, PowerShell, or C# file changed.

**Total blocking findings: 1.**

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 9 files (0 production, 9 test) | 7094 passed, 6 skipped (full suite); 125 in the eight-file set | PASS: 0 failed | 93.8% lines, 88.1% branches | 93.8% lines, 88.1% branches | 93.8% lines, 88.1% branches (repo-wide; test files are omitted from measurement by pyproject) |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| TypeScript | 1 file (test only, comment change) | 1 suite run, passed | PASS: 0 failed | N/A (coverage artifact absent; see PA-1) | N/A (coverage artifact absent; see PA-1) | N/A (artifact absent; FAIL per PA-1) |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: absent; the baseline jest run `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/evidence/baseline/jest-epic-core.2026-10-16T00-35.md` ran without coverage collection and `coverage/lcov.info` does not exist in the worktree
- TypeScript post-change coverage artifact: absent; `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/evidence/qa-gates/jest-epic-core.2026-10-16T00-48.md` records a pass without coverage output (PA-1)
- PowerShell baseline coverage artifact: N/A, no PowerShell file changed
- PowerShell post-change coverage artifact: N/A, no PowerShell file changed
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/evidence/qa-gates/coverage-comparison.2026-10-16T00-48.md`

---

## Executive Summary

The branch moves `build_valid_epic_state` and `build_read_text_stub` into the new `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py`, repoints five importing test modules, updates two cross-language citations, and removes a stale `skipif` guard and unused `import pytest` from `test_codex_handoff_contract_parity.py`. The reviewer compared the moved bodies with the removed bodies in `git diff` and found them verbatim. Evidence shows `.codex/agents` and `.agents/skills` are tracked (171 files) and not ignored, so the guard reason was stale; all five parity tests run and pass with none skipped. The eight-file set collects 125 tests before and after. Black, Ruff, Pyright, Prettier, ESLint, and both `tsc` projects exit 0; every touched file is at most 500 lines.

One blocking finding: TypeScript has a changed file in the branch diff and the TypeScript coverage artifact `coverage/lcov.info` is absent, which the coverage-verification contract treats as FAIL regardless of the comment-only nature of the change (PA-1). Python repo-wide coverage, read from `artifacts/python/lcov.info` (17638 lines, 16544 hit; 6368 branches, 5612 hit), is 93.8% line and 88.1% branch, above 85% and 75%, and equals the baseline.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on base; no new project added, so no classification gap)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/python.md` and `.claude/rules/python-suppressions.md` (Python test changes)
- ✅ `.claude/rules/typescript.md` and `.claude/rules/typescript-suppressions.md` (TypeScript comment change; coverage artifact FAIL, PA-1)
- N/A PowerShell: no changed files.
- N/A C#: no changed files.
- N/A Bash: no changed files.

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed; `git diff --name-only` shows only the ten in-scope files and feature-folder paths.
- ✅ No ongoing tooling script was added.

---

## Rejected Scope Narrowing

None detected. The caller prompt fixed the base at `main` (merge base against `origin/main`) and asked for the full feature review. It did not narrow scope to a plan, phase, task, file subset, or language. The reduced-audit handoff in the evidence folder is executor material and was not treated as a scope limit.

## Evidence Location Compliance

- `git diff --name-only adb9aa5f0..HEAD -- artifacts` returned no path.
- No path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appears in the branch diff; all evidence sits under `<FEATURE>/evidence/<kind>/` (`baseline`, `qa-gates`, `regression-testing`, `other`).
- Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entries were needed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The support module holds two pure builders with no module state; importers no longer depend on other `test_*.py` modules. |
| **Isolation** - Each test targets single behavior | ✅ PASS | No test body changed. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Eight-file set: 125 passed in 1.63s. |
| **Determinism** - Consistent results | ✅ PASS | Builders return literals; no clock, randomness, or I/O. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Module docstring and builder docstrings preserved verbatim. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Baseline total 92% combined (17638 statements, 1094 missed, 6368 branches, 504 partial) in `evidence/baseline/pytest-full-coverage.2026-10-16T00-35.md`. |
| **No Coverage Regression** | ✅ PASS | Final TOTAL row identical to baseline; reviewer awk over `artifacts/python/lcov.info`: 93.8% line, 88.1% branch. |
| **New Code Coverage >= 85% (uniform tier rule)** | ✅ PASS | No production line added; the new support module is a test file omitted from measurement (`tests/*`), so the denominator is unchanged. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | TypeScript coverage artifact absent (PA-1). |
| **Positive Flows** - Valid inputs | ✅ PASS | Unchanged tests cover them. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Unchanged tests cover them. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Unchanged. |
| **Error Handling** - Error paths | ✅ PASS | Unchanged. |
| **Concurrency** - If applicable | N/A | No concurrent code. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.8% lines, 88.1% branches -> Post-change: 93.8% lines, 88.1% branches. Change: +0.0% lines, +0.0% branches. New/changed-code coverage: 93.8% lines, 88.1% branches (repo-wide figures govern; the changed Python files are test modules and the new support module is not an lcov entry). Disposition: PASS. Evidence: evidence/qa-gates/pytest-full-coverage.2026-10-16T00-48.md, evidence/qa-gates/coverage-comparison.2026-10-16T00-48.md, reviewer awk over artifacts/python/lcov.info.
- TypeScript: Baseline: N/A (no artifact) -> Post-change: N/A (no artifact). Change: not computable without an artifact. New/changed-code coverage: N/A (artifact absent, no figure exists). Disposition: FAIL. Evidence: coverage/lcov.info absent; evidence/qa-gates/jest-epic-core.2026-10-16T00-48.md shows a pass without coverage output. See PA-1.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | No assertion changed. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | No test body changed. |
| **Document Intent** | ✅ PASS | Builder docstrings retained. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | The un-skipped parity tests read tracked repository files only (171 tracked `.codex`/`.agents` files; `git check-ignore` exit 1). |
| **Use Mocks/Stubs** | ✅ PASS | `build_read_text_stub` unchanged. |
| **Environment Stability** | ✅ PASS | No temporary files introduced. Skip guard removed because it was stale; test file location rule met (support module under `tests/`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ⚠️ PARTIAL | This audit; PA-1 outstanding. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` Acceptance Criteria. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-10-16T00-24.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-10-15T17-45.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Verbatim move into one small module. |
| **Reusability** | ✅ PASS | Removes the test-module-to-test-module import pattern. |
| **Extensibility** | ✅ PASS | No public API change. |
| **Separation of concerns** | ✅ PASS | Shared builders separated from test modules. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Support module has two related builders (60 lines). |
| **Under 500 lines** | ✅ PASS | Largest touched file 475 lines (`epic-orchestrator-state-core.test.ts`); Python largest 457. `evidence/qa-gates/line-counts.2026-10-16T00-48.md`. |
| **Public vs internal** | ✅ PASS | No change. |
| **No circular dependencies** | ✅ PASS | The support module imports only `typing` under `TYPE_CHECKING`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `validate_orchestration_artifacts_test_support.py` follows the `*_test_support.py` convention. |
| **Docs/docstrings** | ✅ PASS | Module and function docstrings present. |
| **Comment why, not what** | ✅ PASS | Citation docstring and comment updated to the new location. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | `black --check` and `prettier --check` exit 0. |
| **2. Linting** | ✅ PASS | `ruff check` and `eslint --max-warnings=0` exit 0. |
| **3. Type checking** | ✅ PASS | `pyright`, `tsc -p ./`, `tsc -p tsconfig.jest.json` exit 0. |
| **4. Testing** | ✅ PASS | pytest 7094 passed; jest epic core passes. |
| **Full toolchain loop** | ✅ PASS | `evidence/qa-gates/final-loop-single-pass.2026-10-16T00-49.md`. |
| **Explicit reporting** | ✅ PASS | One timestamped evidence file per stage. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | `evidence/other/phase1-handoff.2026-10-16T00-36.md`. |
| **Design choices explained** | ✅ PASS | Research and plan documents. |
| **Update supporting documents** | ✅ PASS | Citations updated in the Python and TypeScript files. |
| **Provide next steps** | ✅ PASS | See Recommendation. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check` over nine touched files; exit 0. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check`; exit 0. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`; exit 0. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest`; 7094 passed, 6 skipped (pre-existing), 0 failed. |
| **Suppressions** | ✅ PASS | The diff adds no `noqa`, `type: ignore`, or `pyright: ignore`. |

### Section 3E: TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Prettier / ESLint / tsc / Jest** | ✅ PASS | All exit 0 in `extensions/drm-copilot` (evidence/qa-gates/prettier-check, eslint, tsc-src, tsc-test, jest-epic-core). |
| **Coverage artifact present** | ❌ FAIL | `coverage/lcov.info` absent (PA-1). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | All tests run under pytest. |
| **Coverage expectation** | ✅ PASS | 93.8% line / 88.1% branch repo-wide. |
| **Focused unit tests / organization / naming** | ✅ PASS | Support module lives at `tests/scripts/dev_tools/`, mirroring the production tree; no colocation in `src/`. |
| **Skip hygiene** | ✅ PASS | `skipif` and `_requires_codex_runtime` tokens absent (`evidence/regression-testing/parity-token-search.2026-10-16T00-41.md`, exit 1 as expected). |

---

## 5. Test Coverage Detail

### `tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Importer suites (epic state, merge status, dispatch, plan gates, parallel dispatch) | Positive | Both builders (exercised by 125 tests) | ✅ |

**Coverage:** test file; outside the measured denominator by configuration. **Not covered:** not measured.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | pytest 7100 (full); 125 in the eight-file set | ✅ |
| Tests Passed | 7094; 125 | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | Eight-file set 1.63s; full suite 162.51s | ✅ |
| Test File Size | All under 500 lines | ✅ |
| Code Coverage (if applicable) | Python 93.8% / 88.1%; TypeScript artifact absent | ⚠️ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check` | exit 0 | ✅ |
| Ruff | `poetry run ruff check` | exit 0 | ✅ |
| Pyright | `poetry run pyright` | exit 0 | ✅ |
| Pytest | `poetry run pytest` | 7094 passed | ✅ |
| Prettier / ESLint / tsc / jest | `npx ...` | exit 0 | ✅ |

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (Blocking):** The branch diff changes `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` (one comment line). The coverage contract requires an artifact for every language with changed files; `coverage/lcov.info` does not exist and no evidence file records TypeScript coverage. Disposition FAIL. Required outcome: run `npx jest --config jest.config.cjs --coverage` in `extensions/drm-copilot`, record repo-wide line and branch percentages in an evidence file under `<FEATURE>/evidence/qa-gates/`, and confirm they meet 85% and 75%.
- **PA-2 (Non-blocking):** `tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py:28` defines a private `_build_read_text_stub` with the same behavior as the shared builder. It is a different name, outside the AC token search, and not a policy violation; consolidation is optional.
- **PA-3 (Non-blocking):** `issue.md` header line 5 still reads `Promoted -> docs/features/active/test-support-hygiene-793-skipif/`, which is not the current folder name. Documentation only.

### Approved Exceptions

- None.

### Removed/Skipped Tests

- No test removed. Two skip decorators removed from tests that now pass unconditionally (justified by tracked, non-ignored `.codex`/`.agents` content).

---

## 9. Summary of Changes

1. **a4883ee93 / fad4b1358 / 779d2e9f9 / 7b3b91aa8** - feature folder, research, acceptance criteria, plan
2. **91044a5b7** - test: move shared validator builders to a support module and drop stale skipif (#938)

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIAL

All toolchain stages pass, file-size and evidence-location checks pass, and Python coverage meets thresholds with no regression. The TypeScript coverage artifact required for a language with changed files is absent.

**Total blocking findings: 1.**

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Compliant

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python: compliant
- ❌ TypeScript: coverage artifact absent (PA-1)

#### General Unit Test Policy (Section 1)
- ⚠️ Coverage & Scenarios: PA-1

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python: compliant

---

### Metrics Summary

- ✅ pytest 7094 passed, 0 failed
- ✅ Python 93.8% line / 88.1% branch
- ❌ TypeScript coverage artifact absent

---

### Recommendation

**Remediation required (one item)**

Generate and record the TypeScript coverage artifact, then re-review.

---

## Appendix A: Test Inventory

1. test_codex_handoff_contract_parity: 5 tests, all executed and passed (two formerly guarded)
2. Eight-file validator set: 125 collected before and after, 125 passed

---

## Appendix B: Toolchain Commands Reference

**Reviewer commands:**
```bash
git diff adb9aa5f0..HEAD -- tests extensions
git diff --name-only adb9aa5f0..HEAD -- artifacts
awk -F: '/^LF:/{lf+=$2}/^LH:/{lh+=$2}/^BRF:/{bf+=$2}/^BRH:/{bh+=$2}' artifacts/python/lcov.info
```

**For Python:**
```bash
poetry run black --check <files>
poetry run ruff check <files>
poetry run pyright <files>
poetry run pytest
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)

# Policy Compliance Audit: handoff test independence from archived active directory (#765)

**Audit Date:** 2026-09-28  
**Code Under Test:** `tests/scripts/dev_tools/test_orchestration_handoff_paths.py` (Python, modified, one line)  
**Base:** origin/main 5d0b93a0b0a15633b42559827fd7459d65c0b671 | **Head:** a760a7c139aedc53c7c290bd6ab5a30ce3a2e302 | **Work mode:** minor-audit

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 file (test only) | 13 tests | ✅ 13 pass, 0 fail | 43% lines (89 stmts, 38 branches; module orchestration_handoff_contract_support.py) | 43% lines (unchanged) | N/A (no production line changed) |
| JSON | 0 files | N/A | N/A | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed)
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed)
- Per-language comparison summary: section 1.2.1 below; evidence in `evidence/baseline/baseline-pytest-coverage.2026-09-28T19-35.md` and `evidence/qa-gates/final-pytest-coverage.2026-09-28T19-35.md`

**Non-negotiable verdict rule:** Numeric baseline and post-change coverage are reported for Python, the only language in scope.

**Fail-closed rule:** All required baseline, QA, and coverage-comparison artifacts exist in the feature evidence folder.

**Evidence rule:** No evidence was backfilled from inference; each claim cites an artifact or a reviewer command.

## Rejected Scope Narrowing

None. The caller prompt did not narrow scope.

---

## Executive Summary

The branch changes one line in one Python test so that `test_plan_directory_rediscovery_blocks_before_write` passes the tracked directory `tests/fixtures/orchestration-handoff/contract` to `resolve_pinned_plan_path` instead of `docs/features/active`, which no longer exists after PR #759. The remaining 18 changed files are feature documentation and evidence. No production file changed. The reviewer re-ran the module: 13 passed. Black, Ruff, and Pyright evidence records exit code 0.

**Policy documents evaluated:**
- ✅ `general-code-change.md`
- ✅ `general-unit-test.md`

**Language-specific policies evaluated:**
- ✅ `python.md` and `python-suppressions.md`
- N/A PowerShell, Bash, TypeScript, C#, JSON (zero changed files)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts were created
- ✅ No ongoing tooling scripts were added
- None created; nothing to dispose

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The changed test uses only the module constants ROOT and FIXTURES; no shared mutable state was added. The change removes the dependency on a directory that other work adds or removes. |
| **Isolation** - Each test targets single behavior | ✅ PASS | The test asserts one behavior: a directory plan path raises `HandoffContractError`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 13 passed in 0.05s (reviewer run); targeted test 1 passed in 0.06s. |
| **Determinism** - Consistent results | ✅ PASS | The argument is a tracked directory; no clock, randomness, or network. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | `FIXTURES.relative_to(ROOT).as_posix()` reuses an existing constant. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Baseline: 43% lines for `scripts/dev_tools/orchestration_handoff_contract_support.py`. Command: `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py --cov=scripts.dev_tools.orchestration_handoff_contract_support --cov-branch --cov-report=term-missing --cov-fail-under=0`. Timestamp: 2026-09-28 19:42. |
| **No Coverage Regression** | ✅ PASS | Post-change 43%, change 0%. No regression. |
| **New Code Coverage** | ✅ PASS | No new files. The only changed file is test code, which is excluded from coverage measurement by policy; zero production lines changed. |
| **Comprehensive Coverage** | ✅ PASS | Scenario set of the module is unchanged (13 tests). No untested code introduced. |
| **Positive Flows** - Valid inputs | ✅ PASS | Pre-existing tests in the module; unchanged. |
| **Negative Flows** - Invalid inputs | ✅ PASS | The changed test is the directory-rejection negative flow; retained with `pytest.raises(HandoffContractError)`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Pre-existing traversal fixture tests; unchanged. |
| **Error Handling** - Error paths | ✅ PASS | Error path asserted by the changed test. |
| **Concurrency** - If applicable | N/A | Not applicable; no concurrent behavior. |
| **State Transitions** - If applicable | N/A | Not applicable; stateless resolver. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 43% lines -> Post-change: 43% lines. Change: 0% lines. New/changed-code coverage: N/A - test-only change, no production line changed. Disposition: PASS. Evidence: `evidence/baseline/baseline-pytest-coverage.2026-09-28T19-35.md`, `evidence/qa-gates/final-pytest-coverage.2026-09-28T19-35.md`.
- Repo-wide Python threshold (85% line, 75% branch): `artifacts/python/lcov.info` totals LF 89, LH 45 (50.6% line), BRF 38, BRH 10. LF 89 equals the single module statement count, so the artifact comes from a scoped run and is not a repo-wide measurement. Disposition: FAIL as literally read, advisory and not attributable to this branch (no production line changed); full-repo coverage is enforced by the CI quality-checks job. Not a blocking finding.
- TypeScript, PowerShell, C#: zero changed files; N/A - out of scope.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `HandoffContractError` carries a field and reason. A non-raising call would report pytest's "DID NOT RAISE". |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Fixture arranges write denial; one call acts inside `pytest.raises`. |
| **Document Intent** | ✅ PASS | Test name states the behavior. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or process; reads a tracked repository directory via the resolver. |
| **Use Mocks/Stubs** | ✅ PASS | `deny_write_boundaries` fixture retained. |
| **Environment Stability** | ✅ PASS | No temporary files created; the substituted path is tracked content. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document. No outstanding review items. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #765 `issue.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-09-28T19-35.md`. |
| **Document the plan** | ✅ PASS | Plan file in the feature folder. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One-line change. |
| **Reusability** | ✅ PASS | Reuses the module constant `FIXTURES`. |
| **Extensibility** | N/A | No API surface changed. |
| **Separation of concerns** | ✅ PASS | Test-only; production untouched. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | No structural change. |
| **Under 500 lines** | ✅ PASS | Net diff is +1/-1 lines in an existing file. |
| **Public vs internal** | N/A | No public API change. |
| **No circular dependencies** | ✅ PASS | No import added. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Existing names retained. |
| **Docs/docstrings** | N/A | No new function. |
| **Comment why, not what** | N/A | No comment added. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Command: `poetry run black tests/scripts/dev_tools/test_orchestration_handoff_paths.py`. Result: 1 file left unchanged, exit 0. |
| **2. Linting** | ✅ PASS | Command: `poetry run ruff check tests/scripts/dev_tools/test_orchestration_handoff_paths.py`. Result: All checks passed, exit 0. |
| **3. Type checking** | ✅ PASS | Command: `poetry run pyright tests/scripts/dev_tools/test_orchestration_handoff_paths.py`. Result: 0 errors, exit 0. |
| **4. Testing** | ✅ PASS | Command: `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py`. Result: 13 passed (reviewer re-run). |
| **Full toolchain loop** | ✅ PASS | All steps exit 0 in a single pass per the QA-gate evidence. |
| **Explicit reporting** | ✅ PASS | Commands and results are in `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 below. |
| **Design choices explained** | ✅ PASS | `issue.md` Proposed Fix: use a stable tracked directory already depended on by the module. |
| **Update supporting documents** | ✅ PASS | Feature folder and promoted record added. |
| **Provide next steps** | ✅ PASS | Open the PR; confirm CI quality-checks job. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | Exit 0, no rewrite. |
| **Linting with Ruff** | ✅ PASS | Exit 0. |
| **Type checking with Pyright** | ✅ PASS | 0 errors, 0 warnings. |
| **Testing with Pytest** | ✅ PASS | 13 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Test signature unchanged and annotated; no `Any` added. |
| **Dataclasses for value objects** | N/A | None involved. |
| **Protocols/ABCs for interfaces** | N/A | None involved. |
| **Avoid utility classes** | ✅ PASS | None added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | Test asserts the specific `HandoffContractError`. |
| **Logging over print** | ✅ PASS | No print added. |
| **Invariants at construction** | N/A | No class added. |

Suppressions: the diff adds no `noqa`, `type: ignore`, or `pyright: ignore` (PASS under `python-suppressions.md`).

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Pytest with `pytest.raises` and the `deny_write_boundaries` fixture. |
| **Coverage expectation** | ✅ PASS | 43% before and after for the exercised module; no production lines changed; repo-wide figure discussed in 1.2.1. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Single behavior. |
| **Mocking sparingly** | ✅ PASS | One write-denial fixture, retained. |
| **Organization** | ✅ PASS | Test stays under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_plan_directory_rediscovery_blocks_before_write`. |
| **Docstrings/comments** | N/A | None changed. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `poetry run pytest`, 13 passed. |
| **No Alternative Test Runners** | ✅ PASS | Only Pytest used. |

---

## 5. Test Coverage Detail

### test_plan_directory_rediscovery_blocks_before_write (1 test)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_plan_directory_rediscovery_blocks_before_write | Negative / Error Handling | `resolve_pinned_plan_path` lines 46-53 (raises at the `is_file()` check) | ✅ |

**Coverage:** the resolver raises at line 53 for a directory argument.

**Not covered:** None attributable to this change.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 13 | ✅ |
| Tests Passed | 13 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 0.05s total | ✅ Fast |
| Average Time per Test | about 4ms | ✅ Fast |
| Discovery Time | not separately reported | N/A |
| Functions/Classes Tested | 1 changed test of 13 in module | ✅ |
| Test File Size | under 500 lines | ✅ Maintainable |
| Code Coverage (if applicable) | 43% lines for the exercised module (scoped run) | ✅ no regression |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | 1 file unchanged | ✅ |
| Ruff Linting | `poetry run ruff check tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py` | 13 passed | ✅ |

**Notes:**
Evidence-location scan: `validate_evidence_locations.py --root .` exits non-zero with two violations, `artifacts/research/2026-07-07T19-00-epic-folder-structure-research.md` and `artifacts/research/2026-08-04T09-53-crlf-atomic-plan-validator-434-research.md`. Neither is in the branch diff (both are untracked local files), so the branch has no evidence-location violation. Canonical replacement location would be `docs/research/`. All branch evidence is under the feature `evidence/baseline`, `evidence/qa-gates`, and `evidence/regression-testing` folders.

---

## 8. Gaps and Exceptions

### Identified Gaps
- Repo-wide Python coverage artifact is a scoped run (see 1.2.1); advisory, not blocking.
- `issue.md` Status line cites a folder path without the date prefix or issue suffix. Cosmetic.
- `evidence/regression-testing/edit-diff.2026-09-28T19-35.md` records that the file was left unstaged at capture time and later committed at head; no effect on the delivered diff.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
**None.** No tests removed or skipped.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **a760a7c1** - test(handoff): remove dependency on archived active features directory

### Files Modified

1. **tests/scripts/dev_tools/test_orchestration_handoff_paths.py** (MODIFIED)
   - Replaces the literal `docs/features/active` argument with `FIXTURES.relative_to(ROOT).as_posix()`.
2. **docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/** (NEW)
   - `issue.md`, plan, and 15 evidence files.
3. **docs/features/potential/promoted/2026-09-28-handoff-test-depends-on-archived-active-dir.md** (NEW)
   - Promoted lifecycle record.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

The change is minimal, test-only, and passes the toolchain. The repo-wide coverage observation is advisory and not caused by this branch. Blocking findings: 0.

**Fail-closed reminder:** No required baseline, QA, or coverage-comparison artifact is missing.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objective and plan documented
- ✅ Design Principles: one-line reuse of an existing constant
- ✅ Module & File Structure: no structural change
- ✅ Naming, Docs, Comments: unchanged
- ✅ Toolchain Execution: all exit 0
- ✅ Summarize & Document: complete

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright clean
- ✅ Python Design & Typing: no change
- ✅ Error Handling: specific exception asserted

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: satisfied
- ⚠️ Coverage & Scenarios: no regression on changed lines; repo-wide artifact is a scoped run (advisory)
- ✅ Test Structure: satisfied
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: Pytest
- ✅ Test Style & Structure: focused
- ✅ Naming & Readability: satisfied
- ✅ Toolchain: Pytest only

---

### Metrics Summary

- ✅ 13/13 tests passing (100%)
- ✅ 43% line coverage of the exercised module before and after
- ✅ Test file location mirrors source
- ✅ All code quality checks passing
- ✅ Test execution time: 0.05 seconds (fast)

---

### Recommendation

**Ready for merge.** Confirm the CI quality-checks job passes on the PR; CI status was not available at review time.

---

## Appendix A: Test Inventory

### Complete Test List

- tests/scripts/dev_tools/test_orchestration_handoff_paths.py::test_plan_directory_rediscovery_blocks_before_write (changed)
- Twelve other tests in the same module (unchanged; 13 collected in total)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
poetry run black tests/scripts/dev_tools/test_orchestration_handoff_paths.py
poetry run ruff check tests/scripts/dev_tools/test_orchestration_handoff_paths.py
poetry run pyright tests/scripts/dev_tools/test_orchestration_handoff_paths.py
poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_paths.py --cov=scripts.dev_tools.orchestration_handoff_contract_support --cov-branch --cov-report=term-missing --cov-fail-under=0
```

---

**Audit Completed By:** feature-review agent  
**Audit Date:** 2026-09-28  
**Policy Version:** Current (as of audit date)

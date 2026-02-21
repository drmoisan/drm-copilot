# Policy Compliance Audit: minor-audit-small-change-28

**Audit Date:** 2026-02-20  
**Code Under Test:**
- `.vscode/tasks.json`
- `docs/engineering/Feature Playbook.md`
- `docs/features/templates/README.md`
- `docs/features/active/2026-02-19-minor-audit-small-change-28/issue.md`
- `scripts/dev_tools/new_active_feature_folder.py`
- `scripts/dev_tools/potential_to_issue.py`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py`
- `tests/scripts/dev_tools/test_potential_to_issue.py`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 4 files | Pytest | [❌] 0 pass, 37 errors (collection) | 83% lines (baseline evidence 2026-02-19T12-02) | N/A (collection failed on Windows) | 90%+ in QA evidence (Linux, 2026-02-19T12-02) |
| JSON | 1 file | N/A | [✅] schema validation | N/A | N/A | N/A |

---

## Executive Summary

This audit reviewed the minor-audit feature branch changes against repo policy. Formatting, linting, and type checking passed locally on Windows, but Pytest failed during collection due to `ModuleNotFoundError: No module named 'scripts'`. That failure blocks full compliance and leaves coverage verification unconfirmed for this environment. Additionally, Python docstring/comment policy gaps and unauthorized suppression formatting require remediation.

**Policy documents evaluated:**
- [✅] `.github/copilot-instructions.md`
- [✅] `.github/instructions/general-code-change.instructions.md`
- [✅] `.github/instructions/general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `.github/instructions/python-code-change.instructions.md`
- [✅] `.github/instructions/python-unit-test.instructions.md`
- [✅] `.github/instructions/python-suppressions.instructions.md`
- [✅] `.github/instructions/self-explanatory-code-commenting.instructions.md`
- [✅/N/A] JSON: format_json + validate_json (validate_json only; format not run)

**Temporary artifacts cleanup:**
- [✅] All temporary/one-time scripts created during development have been deleted
- [✅] No new tooling scripts introduced in this change

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | [⚠️] [PARTIAL] | Pytest collection failed on Windows (`ModuleNotFoundError: No module named 'scripts'`), so independence could not be verified here. |
| **Isolation** - Each test targets single behavior | [⚠️] [PARTIAL] | Test intent appears scoped (see `tests/scripts/dev_tools/test_*`), but collection failure prevents runtime validation. |
| **Fast Execution** - Tests complete quickly | [⚠️] [PARTIAL] | Collection failed in 0.58s; no full runtime metrics available. |
| **Determinism** - Consistent results | [⚠️] [PARTIAL] | Determinism unverified due to collection errors. |
| **Readability & Maintainability** - Clear structure | [⚠️] [PARTIAL] | Tests are organized, but docstring/comment policy gaps noted in code review. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | [✅] [PASS] | Baseline evidence: `evidence/baseline/python-test-baseline.2026-02-19T12-02.md` shows 83% total coverage. |
| **No Coverage Regression** | [⚠️] [PARTIAL] | Post-change coverage could not be computed due to collection errors. |
| **New Code Coverage ≥90%** | [⚠️] [PARTIAL] | QA evidence (Linux) shows `potential_to_issue.py` at 93% and `new_active_feature_folder.py` at 90%, but local Windows run failed. |
| **Comprehensive Coverage** | [⚠️] [PARTIAL] | Tests exist for new behavior, but execution failed in this environment. |
| **Positive Flows** - Valid inputs | [⚠️] [PARTIAL] | Covered by tests in `test_potential_to_issue.py` and `test_new_active_feature_folder.py`, not executed locally. |
| **Negative Flows** - Invalid inputs | [⚠️] [PARTIAL] | Covered by tests (eligibility rejection, invalid args), not executed locally. |
| **Edge Cases** - Boundary conditions | [⚠️] [PARTIAL] | Edge cases appear covered (missing sections, invalid names), not executed locally. |
| **Error Handling** - Error paths | [⚠️] [PARTIAL] | Error path tests exist, not executed locally. |
| **Concurrency** - If applicable | [✅] [N/A] | No concurrency in scope. |
| **State Transitions** - If applicable | [✅] [N/A] | No state machine transitions in scope. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | [⚠️] [PARTIAL] | Collection failure prevents runtime assertion review. |
| **Arrange-Act-Assert Pattern** | [⚠️] [PARTIAL] | Pattern appears in tests by inspection, not executed locally. |
| **Document Intent** | [❌] [FAIL] | Test functions/classes lack docstrings despite repo policy requiring docstrings for all functions/classes. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | [❌] [FAIL] | Tests use `tmp_path` for filesystem I/O (e.g., `test_real_filesystem_round_trip`), which violates the no-temporary-files policy. |
| **Use Mocks/Stubs** | [✅] [PASS] | Extensive mocking of gh and filesystem for isolation in tests. |
| **Environment Stability** | [❌] [FAIL] | Test collection failed due to import path (`scripts` package not resolved). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | [✅] [PASS] | This audit document provides the required policy review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | [✅] [PASS] | Objectives documented in `issue.md`, `spec.md`, and plan file. |
| **Read existing change plans** | [✅] [PASS] | `plan.2026-02-19T12-02.md` exists and references required policies. |
| **Document the plan** | [✅] [PASS] | Plan and requirements traceability table present in `plan.2026-02-19T12-02.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | [✅] [PASS] | Changes are localized helpers and CLI flags; no excessive indirection. |
| **Reusability** | [✅] [PASS] | Eligibility logic centralized in helper functions. |
| **Extensibility** | [✅] [PASS] | Work mode argument allows extension with minimal API change. |
| **Separation of concerns** | [✅] [PASS] | IO abstractions (FileSystem/GhClient) keep logic testable. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | [✅] [PASS] | Scripts remain focused on promotion and folder creation. |
| **Under 500 lines** | [✅] [PASS] | `potential_to_issue.py` (~276 lines), `new_active_feature_folder.py` (~406 lines). |
| **Public vs internal** | [✅] [PASS] | Internal helpers are module-level; no unintended exports. |
| **No circular dependencies** | [✅] [PASS] | No circular imports observed. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | [✅] [PASS] | Function and variable names are descriptive. |
| **Docs/docstrings** | [❌] [FAIL] | Many functions/classes in modified Python files lack required intent-first docstrings. |
| **Comment why, not what** | [❌] [FAIL] | Loop/branch intent comments required by policy are missing in several functions. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | [✅] [PASS] | `poetry run black . --check` (2026-02-20): “82 files would be left unchanged.” |
| **2. Linting** | [✅] [PASS] | `poetry run ruff check` (2026-02-20): “All checks passed!” |
| **3. Type checking** | [✅] [PASS] | `poetry run pyright` (2026-02-20): “0 errors, 0 warnings, 0 informations.” |
| **4. Testing** | [❌] [FAIL] | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` failed during collection (37 errors, `ModuleNotFoundError: No module named 'scripts'`). |
| **Full toolchain loop** | [❌] [FAIL] | Loop did not complete due to test failures. |
| **Explicit reporting** | [✅] [PASS] | Commands and results documented in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | [✅] [PASS] | Summary in Section 9 and code review artifact. |
| **Design choices explained** | [✅] [PASS] | Plan and spec describe mode routing and eligibility gates. |
| **Update supporting documents** | [✅] [PASS] | `Feature Playbook.md`, template README, and `issue.md` updated. |
| **Provide next steps** | [⚠️] [PARTIAL] | Remediation inputs required due to test and policy failures. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | [✅] [PASS] | `poetry run black . --check` succeeded. |
| **Linting with Ruff** | [✅] [PASS] | `poetry run ruff check` succeeded. |
| **Type checking with Pyright** | [✅] [PASS] | `poetry run pyright` succeeded. |
| **Testing with Pytest** | [❌] [FAIL] | Pytest collection failed on Windows (ModuleNotFoundError). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | [✅] [PASS] | Type hints across public helpers and protocols are present. |
| **Dataclasses for value objects** | [✅] [PASS] | `GhResult`, `IssueMeta`, and outcomes use `@dataclass`. |
| **Protocols/ABCs for interfaces** | [✅] [PASS] | `GhClient` and `FileSystem` protocols used. |
| **Avoid utility classes** | [✅] [PASS] | No static-only utility classes introduced. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | [✅] [PASS] | Raises `PromotionError`, `FileNotFoundError`, `ValueError` with explicit messaging. |
| **Logging over print** | [⚠️] [PARTIAL] | Scripts use `print` for CLI output (acceptable for CLI), but no structured logging. |
| **Invariants at construction** | [✅] [PASS] | `RealGhClient` enforces gh path on init; `get_est_timestamp` validates tz-aware input. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | [✅] [PASS] | Tests use Pytest. |
| **Coverage expectation** | [⚠️] [PARTIAL] | Baseline coverage recorded; post-change run failed on Windows. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | [✅] [PASS] | Tests target specific functions and behaviors. |
| **Mocking sparingly** | [✅] [PASS] | Mocks used for gh + filesystem interactions. |
| **Organization** | [✅] [PASS] | Test files mirror module paths. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | [✅] [PASS] | Descriptive `test_...` names. |
| **Docstrings/comments** | [❌] [FAIL] | Test functions/classes lack required docstrings per repo policy. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | [❌] [FAIL] | Pytest collection failed (37 errors). |
| **No Alternative Test Runners** | [✅] [PASS] | Only Pytest was used. |

---

## 5. Test Coverage Detail

Coverage detail could not be generated locally because Pytest failed during collection. Prior QA evidence (Linux, `qa-test.2026-02-19T12-02.md`) indicates:
- `scripts/dev_tools/potential_to_issue.py`: 93% coverage
- `scripts/dev_tools/new_active_feature_folder.py`: 90% coverage

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | N/A (collection failed) | [❌] |
| Tests Passed | 0 | [❌] |
| Tests Failed | 37 errors (collection) | [❌] |
| Execution Time | 0.58s | [⚠️] | Fast (but incomplete) |
| Average Time per Test | N/A | [❌] |
| Discovery Time | N/A | [❌] |
| Functions/Classes Tested | N/A | [❌] |
| Test File Size | N/A | [❌] |
| Code Coverage | N/A | [❌] |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black . --check` | 82 files left unchanged | [✅] |
| Ruff Linting | `poetry run ruff check` | All checks passed | [✅] |
| Pyright Type Checking | `poetry run pyright` | 0 errors | [✅] |
| Pytest Tests | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | 37 collection errors | [❌] |
| JSON Validation | `poetry run python -m scripts.dev_tools.validate_json` | No errors reported | [✅] |

**Notes:** Pytest failed due to missing `scripts` module on Windows; see remediation inputs.

---

## 8. Gaps and Exceptions

### Identified Gaps
1. Pytest collection fails on Windows (`ModuleNotFoundError: No module named 'scripts'`).
2. Python docstring/comment policy violations in modified scripts and tests.
3. Unauthorized or incomplete `# noqa: S603` suppression comments for subprocess usage.
4. Temporary filesystem usage in tests (`tmp_path`) violates unit test policy.

### Approved Exceptions
- **None.** No exceptions approved.

### Removed/Skipped Tests
- **None.** No planned tests were removed.

---

## 9. Summary of Changes

### Commits in This PR/Branch
1. `ff6f244` - Add PR branch recovery note to issue doc

### Files Modified
1. `.vscode/tasks.json` (MODIFIED)
   - Added work-mode inputs for minor-audit routing in promotion and active-folder tasks.
2. `docs/engineering/Feature Playbook.md` (MODIFIED)
   - Added minor-audit eligibility rule and fallback guidance.
3. `docs/features/templates/README.md` (MODIFIED)
   - Added decision tree for minor-audit, feature, refactor paths.
4. `docs/features/active/2026-02-19-minor-audit-small-change-28/issue.md` (MODIFIED)
   - Added evidence contract + PR recovery note.
5. `scripts/dev_tools/potential_to_issue.py` (MODIFIED)
   - Added work-mode routing, minor-audit eligibility, and body builder.
6. `scripts/dev_tools/new_active_feature_folder.py` (MODIFIED)
   - Added work-mode routing and minor-audit issue-centric flow.
7. `tests/scripts/dev_tools/test_potential_to_issue.py` (MODIFIED)
   - Added minor-audit routing tests and security checks.
8. `tests/scripts/dev_tools/test_new_active_feature_folder.py` (MODIFIED)
   - Added minor-audit routing tests and fallback checks.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Key gaps include Windows test collection failures and Python docstring/comment policy violations. Remediation is required before PR readiness.

---

## Appendix B: Toolchain Commands Reference

**Commands executed in this audit (2026-02-20):**

```bash
poetry run black . --check
poetry run ruff check
poetry run pyright
poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
poetry run python -m scripts.dev_tools.validate_json
```

**Audit Completed By:** GitHub Copilot  
**Audit Date:** 2026-02-20  
**Policy Version:** Current (as of audit date)

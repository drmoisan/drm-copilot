# Policy Compliance Audit: potential-to-issue-missing-label (Bug #123)

**Audit Date:** 2026-04-05  
**Audit Timestamp:** 2026-04-05T15-30  
**Branch:** `bug/potential-to-issue-missing-label-123`  
**Base:** `development`  
**Work Mode:** `minor-audit`  
**Feature Folder:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`  
**Feature Folder Selection Rule:** Derived from branch name suffix `-123` matching the issue number in the single active feature folder `2026-04-05-potential-to-issue-missing-label-123`.

**Code Under Test:**

| File | Role |
|------|------|
| `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` | Bundled-runtime production file |
| `scripts/dev_tools/potential_to_issue.py` | Root production file |
| `tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py` | Bundled-runtime test file |
| `tests/scripts/dev_tools/test_potential_to_issue.py` | Root test file |

**Coverage Metrics:**

| Language | Files Changed | Tests | Test Result | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|
| Python | 4 files | 42 tests | ✅ 42 pass, 0 fail | Bundled: 95%; Root: 90% |

---

## Executive Summary

All four Python QA gates (Black, Ruff, Pyright, Pytest) pass cleanly on a single toolchain pass as of 2026-04-05T15-30. The bugfix adds `ensure_label()` recovery logic to `promote_potential()` and corresponding regression tests. Acceptance criteria from `issue.md` are fully satisfied with fail-before/pass-after evidence. One policy finding exists: the bundled-runtime test file exceeds the 500-line limit (689 lines vs. 500 limit). The root test file pre-existed at 784 lines before this branch and is now 877 lines.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `python-suppressions.instructions.md`
- [✅] `self-explanatory-code-commenting.instructions.md`
- [N/A] PowerShell, Bash, JSON, TypeScript — no files changed in those languages

**Temporary artifacts cleanup:**
- [✅] No temporary scripts were created during development
- [✅] All development artifacts are evidence files stored in canonical locations

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Each test uses its own `FakeFileSystem` and `FakeGhClient` instances with isolated module loading/cleanup in `try/finally` blocks. No shared mutable state between tests. |
| **Isolation** | ✅ PASS | Each test targets a single behavior: missing-label recovery, existing-label single-create, input validation, RealGhClient subprocess, minor-audit path, etc. |
| **Fast Execution** | ✅ PASS | 42 tests complete in 0.13s total (~3ms average per test). 14 bundled-runtime tests complete in 0.58s with coverage. |
| **Determinism** | ✅ PASS | All external dependencies are faked (`FakeFileSystem`, `FakeGhClient`). No network calls, no filesystem I/O, no time dependencies. |
| **Readability & Maintainability** | ✅ PASS | Test names are descriptive (`test_bundled_runtime_feature_missing_label_recovers_and_moves_file`). Each test has a docstring explaining the scenario. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/p0-t6.pytest-coverage.2026-04-05T13-36.md`: Root 90% (184 stmts, 18 miss). `evidence/remediation-baseline/baseline-pytest-coverage.2026-04-05T15-00.md`: Bundled 95% (200 stmts, 10 miss). |
| **No Coverage Regression** | ✅ PASS | `evidence/qa-gates/final-coverage-delta.2026-04-05T15-00.md`: Bundled baseline 95% → final 95%, delta 0%. Root baseline 90% → maintained. |
| **New Code Coverage ≥90%** | ✅ PASS | Bundled-runtime: 95% (200 stmts, 10 miss). Root: 90% (184 stmts, 18 miss). Both meet ≥90% threshold. |
| **Positive Flows** | ✅ PASS | Tests: existing-label single-create, minor-audit path, full feature promotion with metadata update. |
| **Negative Flows** | ✅ PASS | Tests: invalid promotion type, invalid work mode, unauthenticated client, file-not-found, empty file, normalize mode failure. |
| **Edge Cases** | ✅ PASS | Tests: missing-label recovery with retry, RealGhClient fallback (gh_path=None after init), relpath ValueError fallback. |
| **Error Handling** | ✅ PASS | Tests: `PromotionError` for all precondition failures, `FileNotFoundError` for missing gh CLI, `RuntimeError` for unresolved gh path. |
| **Concurrency** | N/A | Not applicable; synchronous CLI wrapper. |
| **State Transitions** | ✅ PASS | Tests verify state transitions: initial create failure → ensure_label → retry create → success → metadata update → file move. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions use direct comparisons (`assert outcome.exit_code == 0`, `assert len(create_calls) == 2`) producing clear pytest diffs on failure. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Each test follows: setup fakes → call `promote_potential()` → assert outcome and side effects. |
| **Document Intent** | ✅ PASS | Every test function has a docstring. Test names encode scenario and expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No external services used. All gh CLI calls faked via `FakeGhClient`. All filesystem operations faked via `FakeFileSystem`. |
| **Use Mocks/Stubs** | ✅ PASS | `FakeFileSystem` (in-memory fake), `FakeGhClient` (deterministic fake), `unittest.mock.patch` for `shutil.which`/`subprocess.run` in RealGhClient tests. |
| **Environment Stability** | ✅ PASS | No global state, no config files, no temporary files. Module imports cleaned up in `finally` blocks. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Objective: fix missing-label failure in `promote_potential()`. Documented in `issue.md` (Bug #123) with clear repro steps. |
| **Read existing change plans** | ✅ PASS | `plan.2026-04-05T13-30.md` documents the minimal-audit plan with deterministic constraints (CON-001 through CON-009). |
| **Document the plan** | ✅ PASS | Plan documented with phases, evidence naming rules, small-path directives, and acceptance criteria mapping. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Fix is minimal: one helper function (`_is_missing_label_failure`), one new method (`ensure_label`), and a recovery branch in `promote_potential()`. |
| **Reusability** | ✅ PASS | `ensure_label()` added to `GhClient` protocol so all implementations share the contract. `_is_missing_label_failure()` is a pure helper. |
| **Extensibility** | ✅ PASS | Protocol-based `GhClient` extended without breaking existing implementations. Recovery scoped to `feature` promotion type, other types unaffected. |
| **Separation of concerns** | ✅ PASS | Detection logic (`_is_missing_label_failure`) separated from recovery orchestration. `GhClient` encapsulates all gh CLI interaction. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Production changes scoped to `potential_to_issue.py` (label recovery concern). Test changes mirror production structure. |
| **Under 500 lines** | ⚠️ PARTIAL | Production files: 345 lines (bundled) and 493 lines (root) — PASS. Test files: **689 lines (bundled)** and **877 lines (root)** — FAIL. The root test file was 784 lines on `development` (pre-existing violation). The bundled test file grew from 123 to 689 lines on this branch. |
| **Public vs internal** | ✅ PASS | `_is_missing_label_failure` uses underscore prefix for internal helper. `ensure_label` added to `GhClient` public protocol. |
| **No circular dependencies** | ✅ PASS | No circular imports. Dependencies: `potential_to_issue` → `potential_to_issue_content`, `prompt_mode_contract`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `_is_missing_label_failure`, `ensure_label`, `FEATURE_LABEL_COLOR`, `FEATURE_LABEL_DESCRIPTION` — all self-documenting. |
| **Docs/docstrings** | ✅ PASS | `_is_missing_label_failure` and `ensure_label` (in root file) have docstrings. Test functions have docstrings. |
| **Comment why, not what** | ✅ PASS | Comment above recovery branch: "Recover only from the known feature-label failure so other gh errors still fail fast with their original output." — explains rationale. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | `poetry run black --check` → 4 files would be left unchanged (audit run: 2026-04-05T15-30). |
| **2. Linting** | ✅ PASS | `poetry run ruff check` → All checks passed (audit run: 2026-04-05T15-30). |
| **3. Type checking** | ✅ PASS | `poetry run pyright` → 0 errors, 0 warnings, 0 informations (audit run: 2026-04-05T15-30). |
| **4. Testing** | ✅ PASS | `poetry run pytest` → 42 passed in 0.13s (audit run: 2026-04-05T15-30). |
| **Full toolchain loop** | ✅ PASS | All four steps passed in a single pass. Confirmed by stored evidence in `evidence/qa-gates/final-*.2026-04-05T15-00.md` and live audit run. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Changes summarized in plan, remediation inputs, and this audit. |
| **Design choices explained** | ✅ PASS | Recovery scoped to `feature` type only; other types fail fast. `ensure_label` uses `gh label create` which is idempotent. Comment in code explains scoping decision. |
| **Update supporting documents** | ✅ PASS | `issue.md` updated with acceptance criteria check-offs. Audit artifacts produced at each remediation stage. |
| **Provide next steps** | ✅ PASS | Documented in this audit and accompanying review artifacts. |

---

## 3. Language-Specific: Python Code Change Policy Compliance

### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | `poetry run black --check` → 4 files unchanged. |
| **Linting with Ruff** | ✅ PASS | `poetry run ruff check` → All checks passed. |
| **Type checking with Pyright** | ✅ PASS | `poetry run pyright` → 0 errors, 0 warnings. |
| **Testing with Pytest** | ✅ PASS | `poetry run pytest` → 42 passed in 0.13s. |

### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | All new methods fully annotated: `ensure_label(self, label: str) -> GhResult`, `_is_missing_label_failure(output: list[str], label: str) -> bool`. No use of `Any`. |
| **Dataclasses for value objects** | ✅ PASS | `GhResult`, `RealGhClient`, `PromotionOutcome` use `@dataclass`. |
| **Protocols/ABCs for interfaces** | ✅ PASS | `GhClient(Protocol)` extended with `ensure_label`. `FileSystem(Protocol)` unchanged. |
| **Avoid utility classes** | ✅ PASS | `_is_missing_label_failure` is a module-level function, not a method on a utility class. |

### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `PromotionError` for all precondition failures. `FileNotFoundError` for missing gh CLI. No broad catches. |
| **Logging over print** | ✅ PASS | `emit` callback used for message output (not raw `print` in production paths). `_default` is the fallback `emit`. |
| **Invariants at construction** | ✅ PASS | `RealGhClient.__post_init__` validates `gh_path` is resolved via `shutil.which()`. |

### 3A.4 Suppression Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **S603 suppressions** | ✅ PASS | Two `# noqa: S603` in `RealGhClient` use the pre-authorized pattern (subprocess with `shutil.which()` validation). Comment text matches required format. |
| **No unauthorized suppressions** | ✅ PASS | No `# type: ignore` used. No other `# noqa` used beyond the two pre-authorized S603 suppressions. |

---

## 4. Python Unit Test Policy Compliance

### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | All tests use Pytest. Fixtures: none (each test self-contained). |
| **Coverage expectation** | ✅ PASS | Bundled: 95% ≥ 90%. Root: 90% ≥ 90%. Repo-wide 80% met. |

### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Each test exercises one scenario (missing label recovery, existing label single attempt, validation rejection, etc.). |
| **Mocking sparingly** | ✅ PASS | Fakes (`FakeFileSystem`, `FakeGhClient`) used for isolation. `unittest.mock.patch` used only for `RealGhClient` subprocess testing. |
| **Organization** | ✅ PASS | Tests in `tests/extensions/drm_copilot/resources/templates/` mirror `extensions/drm-copilot/resources/`. |

### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_bundled_runtime_feature_missing_label_recovers_and_moves_file` — clear scenario + expected outcome. |
| **Docstrings/comments** | ✅ PASS | All test functions have docstrings summarizing scenario and expected behavior. |

---

## 5. Bugfix Workflow Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Failing regression test first** | ✅ PASS | Root: `evidence/regression-testing/p1-t3.red-pytest.2026-04-05T13-57.md` (EXIT_CODE: 1). Bundled: `evidence/regression-testing/remediation.red-bundled-runtime-pytest.2026-04-05T14-15.md` (EXIT_CODE: 1). |
| **Test passes after fix** | ✅ PASS | Root: `evidence/regression-testing/p1-t5.green-pytest.2026-04-05T13-58.md` (EXIT_CODE: 0). Bundled: `evidence/regression-testing/remediation.green-bundled-runtime-pytest.2026-04-05T14-15.md` (EXIT_CODE: 0). |
| **Minimal, targeted fix** | ✅ PASS | Fix adds only `ensure_label` + recovery logic. No opportunistic refactors. |
| **Full toolchain verified** | ✅ PASS | All four gates pass. Evidence in `evidence/qa-gates/final-*.2026-04-05T15-00.md`. |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (combined) | 42 | ✅ |
| Tests Passed | 42 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 0.13s total | ✅ Fast |
| Bundled-Runtime Tests | 14 | ✅ |
| Bundled-Runtime Coverage | 95% (200 stmts, 10 miss) | ✅ |
| Root Tests | 28 | ✅ |
| Root Coverage | 90% (184 stmts, 18 miss) | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <4 files>` | 4 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check <4 files>` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright <4 files>` | 0 errors, 0 warnings | ✅ |
| Pytest Tests | `poetry run pytest <2 test files> -q --tb=short` | 42 passed in 0.13s | ✅ |

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **Test file over 500 lines (bundled runtime):** `tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py` is 689 lines. Grew from 123 to 689 lines on this branch due to adding full bundled-runtime test coverage (fakes, module loading helpers, and 10 new test functions). A split into multiple test files would improve maintainability.

2. **Test file over 500 lines (root, pre-existing):** `tests/scripts/dev_tools/test_potential_to_issue.py` is 877 lines (was 784 on `development`). This branch added 93 net lines. The pre-existing violation is not attributable to this bug fix.

### Approved Exceptions

None. The test file size gaps should be addressed in a follow-up refactor.

### Removed/Skipped Tests

None. All planned tests were implemented.

---

## 9. Summary of Changes

### Files Modified

1. **`extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`** (MODIFIED, +34 lines)
   - Added `FEATURE_LABEL_COLOR`, `FEATURE_LABEL_DESCRIPTION` constants
   - Added `ensure_label()` to `GhClient` protocol and `RealGhClient`
   - Added `_is_missing_label_failure()` helper
   - Added recovery branch in `promote_potential()` for missing feature label

2. **`scripts/dev_tools/potential_to_issue.py`** (MODIFIED, +35 lines)
   - Same changes as bundled runtime (root copy)

3. **`tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`** (MODIFIED, +670/-5 lines)
   - Added bundled-runtime module loading helpers
   - Added `FakeFileSystem` and `FakeGhClient` test fakes
   - Added 10 new test functions covering missing-label recovery, existing-label passthrough, RealGhClient subprocess, input validation, minor-audit path, and bug promotion path

4. **`tests/scripts/dev_tools/test_potential_to_issue.py`** (MODIFIED, +114/-5 lines)
   - Extended `FakeGhClient` with `ensure_label` support
   - Added missing-label recovery test and existing-label passthrough test

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

All QA gates pass cleanly. Code quality, typing, design, and test coverage meet or exceed policy requirements. The sole non-compliance is the 500-line file size limit for test files. The bundled-runtime test file (689 lines) was introduced by this branch. The root test file (877 lines) was a pre-existing violation expanded by 93 lines. A follow-up refactor to split these test files is recommended but is not a blocker for merging the bugfix.

### Policy-by-Policy Summary

| Policy | Status |
|--------|--------|
| General Code Change | ⚠️ PARTIAL (500-line limit for test files) |
| General Unit Test | ✅ PASS |
| Python Code Change | ✅ PASS |
| Python Unit Test | ✅ PASS |
| Python Suppressions | ✅ PASS |
| Self-Explanatory Code Commenting | ✅ PASS |
| Bugfix Workflow | ✅ PASS |

---

## Appendix A: Evidence Artifacts Referenced

| Artifact | Location |
|----------|----------|
| Baseline coverage (root) | `evidence/baseline/p0-t6.pytest-coverage.2026-04-05T13-36.md` |
| Baseline coverage (bundled) | `evidence/remediation-baseline/baseline-pytest-coverage.2026-04-05T15-00.md` |
| Red test (root) | `evidence/regression-testing/p1-t3.red-pytest.2026-04-05T13-57.md` |
| Green test (root) | `evidence/regression-testing/p1-t5.green-pytest.2026-04-05T13-58.md` |
| Red test (bundled) | `evidence/regression-testing/remediation.red-bundled-runtime-pytest.2026-04-05T14-15.md` |
| Green test (bundled) | `evidence/regression-testing/remediation.green-bundled-runtime-pytest.2026-04-05T14-15.md` |
| Final Black | `evidence/qa-gates/final-black.2026-04-05T15-00.md` |
| Final Ruff | `evidence/qa-gates/final-ruff.2026-04-05T15-00.md` |
| Final Pyright | `evidence/qa-gates/final-pyright.2026-04-05T15-00.md` |
| Final Pytest + coverage | `evidence/qa-gates/final-pytest-coverage.2026-04-05T15-00.md` |
| Coverage delta | `evidence/qa-gates/final-coverage-delta.2026-04-05T15-00.md` |

## Appendix B: Toolchain Commands Run (Audit Session)

All commands run in check-only / read-only mode during this audit session:

1. `poetry run black --check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` → 4 files unchanged
2. `poetry run ruff check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` → All checks passed
3. `poetry run pyright extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` → 0 errors, 0 warnings, 0 informations
4. `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py -q --tb=short` → 42 passed in 0.13s
5. `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing` → 14 passed, bundled `potential_to_issue.py`: 95%

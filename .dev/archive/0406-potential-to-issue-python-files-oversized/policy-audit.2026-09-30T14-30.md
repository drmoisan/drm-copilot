# Policy Compliance Audit: potential_to_issue decomposition (Issue #406)

**Audit Date:** 2026-09-30
**Code Under Test:** `scripts/dev_tools/potential_to_issue.py` (M), `scripts/dev_tools/potential_to_issue_adapters.py` (A), `tests/scripts/dev_tools/potential_to_issue_test_support.py` (A), `tests/scripts/dev_tools/test_potential_to_issue.py` (M), `tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py` (A), `tests/scripts/dev_tools/test_potential_to_issue_work_modes.py` (A), `tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py` (A), `tests/scripts/dev_tools/test_potential_to_issue_content.py` (M)

**Review basis:** feature-vs-base audit. Base branch `main`, merge base `2b0121abf74f5862a3d12929d833504668941156`, head `c9b3cb67da0d673f850d125b031c2552e92a7ca2` (branch `bug/potential-to-issue-python-files-oversized-406`). Work mode `minor-audit`; the acceptance-criteria source is `issue.md` `## Acceptance Criteria`. PR context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` record head SHA `c9b3cb67...` and merge base `2b0121ab...`, so they are current.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| `scripts/dev_tools/potential_to_issue_adapters.py` | 1 file (new) | 59 tests (family) | PASS: 59 pass, 0 fail | 99.4% lines (code resided in `potential_to_issue.py`; the file did not exist at baseline) | 100.0% lines, 75.0% branches | 100.0% |
| `scripts/dev_tools/potential_to_issue.py` | 1 file (modified) | 59 tests (family) | PASS: 59 pass, 0 fail | 99.4% lines (177/178) | 99.3% lines (135/136), 97.4% branches (37/38) | 100.0% |
| `scripts/dev_tools/potential_to_issue_content.py` | 0 files (unchanged) | 59 tests (family) | PASS: 59 pass, 0 fail | 96.8% lines (92/95) | 96.8% lines (92/95), 82.1% branches (23/28) | 96.8% (no changed lines; file-level figure) |
| `scripts/dev_tools/potential_to_issue_filesystem.py` | 0 files (unchanged) | 59 tests (family) | PASS: 59 pass, 0 fail | 100.0% lines (31/31) | 100.0% lines (31/31), 100.0% branches (14/14) | 100.0% (no changed lines; file-level figure) |
| Aggregate (four potential_to_issue modules) | 2 files (1 new, 1 modified) | 59 tests | PASS: 59 pass, 0 fail | 98.7% lines (300/304) | 98.7% lines (306/310), 89.6% branches (86/96) | 100.0% |

**Note:** Rows are per production module in the Python coverage artifact. The row label doubles as the key of the comparison bullet in section 1.2.1. The test files changed on the branch are not coverage subjects (test paths are excluded from the coverage denominator by policy).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch; the diff touches no path under `extensions/`)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Per-language comparison summary: section 1.2.1 of this document; Python baseline `evidence/baseline/pytest-coverage.md`, Python post-change `evidence/qa-gates/pytest-coverage.md` and `artifacts/python/lcov.info`, delta `evidence/qa-gates/coverage-delta.md`

**Non-negotiable verdict rule:** Numeric baseline and post-change coverage metrics are present for every language with changed files (Python only). Changed/new-code coverage is reported for each changed module.

**Fail-closed rule:** Every required baseline artifact, QA artifact, and coverage-comparison artifact exists on disk (see section 8, Evidence Completeness). The verdict is therefore not BLOCKED or INCOMPLETE.

**Evidence rule:** No evidence was synthesized. Values that the reviewer could not recompute are labelled as taken from the recorded artifacts.

### Rejected Scope Narrowing

None. The caller prompt did not narrow scope to a plan, task, phase, file subset, or language subset. The full feature-vs-base audit was performed. The caller's request to reuse prior conclusions was applied only after re-verification.

### Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 in this review. No file in the branch diff is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence lives under `<FEATURE>/evidence/{baseline,qa-gates,other}/`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred.

---

## Executive Summary

The branch decomposes two oversized Python files for issue #406. `scripts/dev_tools/potential_to_issue.py` fell from 559 to 438 lines by moving the gh subprocess adapter seam (`GhResult`, `GhClient`, `RealGhClient`, `FEATURE_LABEL_COLOR`, `FEATURE_LABEL_DESCRIPTION`) into the new `scripts/dev_tools/potential_to_issue_adapters.py` (154 lines). `tests/scripts/dev_tools/test_potential_to_issue.py` fell from 1076 to 282 lines by moving tests into three new split files, a shared helper module, and the existing content test file. The change is a behavior-neutral extract-and-move. The diff outside `docs/` is exactly eight paths and none is under `extensions/`.

Re-verification performed in this review at head `c9b3cb67`: `wc -l` line counts; `pytest --collect-only` (59 collected) and a plain `pytest` run (59 passed in 0.41 s); `black --check` (533 files unchanged); `ruff check` (all checks passed); `pyright scripts/dev_tools tests/scripts/dev_tools` (0 errors, 0 warnings, 0 informations); `validate_evidence_locations.py --root .` (exit 0); parsing of `artifacts/python/lcov.info`. The Jest parity result (9 suites, 131 tests), the baseline-side figures, and the pre-change collected-name list were taken from the recorded artifacts and were not rerun.

Overall result: no blocking findings, all four acceptance criteria PASS, remediation not required.

**Policy documents evaluated:**
- PASS `general-code-change.md` (file size, design principles, error handling, naming)
- PASS `general-unit-test.md` (independence, determinism, no temporary files, file location, coverage)
- PASS `quality-tiers.md` (uniform coverage thresholds; no exclusion added)
- PASS `tonality.md`

**Language-specific policies evaluated:**
- PASS `python.md` and `python-suppressions.md` (Black, Ruff, Pyright, Pytest; no new suppression)
- N/A PowerShell, TypeScript, C#, Bash, JSON: zero changed files on the branch

**Note:** The review artifacts were authored from the repository copies of the templates under `docs/features/templates/policy_audit/`.

Coverage summary: Python line coverage across the four affected modules is 98.68% at baseline and 98.71% post-change. The uncovered-line count is 4 at both points and the partial-branch count is 10 at both points. The new adapters module reaches 100.0% line and 75.0% branch coverage.

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts were added to the branch diff.
- PASS The only new non-test helper module is `tests/scripts/dev_tools/potential_to_issue_test_support.py`, which is test infrastructure and is exercised by the tests that import it.
- Disposition: no scripts created during development remain in the branch.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Tests build state through fixtures and the in-memory `FakeFileSystem`; no test writes shared state. The split files import shared fakes from `potential_to_issue_test_support.py` without module-level mutable state. A plain run of all 59 tests passed in this review. |
| **Isolation** - Each test targets single behavior | PASS | Test names are unchanged from baseline and each names one behavior (`test_promote_potential_bug_minor_audit_uses_bug_body`, `test_real_gh_client_raises_when_missing`). Tests are grouped by behavior area: core flow, bug bodies, work modes, CLI and adapters, content. |
| **Fast Execution** - Tests complete quickly | PASS | 59 tests passed in 0.41 s in this review (0.45 s for collection). No slow tests. |
| **Determinism** - Consistent results | PASS | No clock, sleep, or randomness added. Subprocess and `shutil.which` are monkeypatched at `adapters.subprocess` and `adapters.shutil`. |
| **Readability & Maintainability** - Clear structure | PASS | Largest test file in the family is 430 lines (pre-existing `..._missing_label_regression.py`); every file changed on the branch is at most 295 lines. Names are descriptive and match baseline. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development):** family 98.68% lines (300/304), 10 partial branches, 4 uncovered lines.<br>**Command:** `poetry run pytest <family test files> --cov=<four modules> --cov-branch --cov-report=term-missing`, recorded in `evidence/baseline/pytest-coverage.md`.<br>**Timestamp:** recorded as 2026-09-30T09-59 in the artifact.<br>**Note:** The baseline covers three module rows because the adapters file did not exist. |
| **No Coverage Regression** | PASS | **Post-change coverage:** family 98.71% lines (306/310), 10 partial branches, 4 uncovered lines.<br>**Change:** +0.03% lines; uncovered-line count 4 to 4; partial branches 10 to 10.<br>**Status:** No regression. The single uncovered line in `potential_to_issue.py` (line 296) is the same statement as baseline line 417, moved by the extraction.<br>**Evidence:** `evidence/qa-gates/coverage-delta.md`, confirmed against `artifacts/python/lcov.info`. |
| **New Code Coverage >=85% line, >=75% branch** | PASS | **New/modified files:** `potential_to_issue_adapters.py` (new), `potential_to_issue.py` (modified).<br>**New code coverage:** adapters 48/48 lines = 100.0%, branches 12/16 = 75.0% (threshold >=75% is met at the boundary).<br>**Calculation method:** per-file `LF/LH/BRF/BRH` records parsed from `artifacts/python/lcov.info`.<br>The four unhit adapter branches are the `GhClient` Protocol member stubs (`44->exit`, `46->exit`, `48->exit`, `50->exit`). |
| **Comprehensive Coverage** | PASS | **All functions/classes tested:**<br>- `RealGhClient` (`__post_init__`, `is_authenticated`, `_run`, `issue_create`, `ensure_label`, `issue_view`): exercised by the split cli-and-adapters tests and the flow tests.<br>- `GhResult`: constructed by every gh-path test.<br>**Untested code:** none in the adapters module at line level. Protocol stub branches are structural, with no behavior. |
| **Positive Flows** - Valid inputs | PASS | `test_promote_potential_success_updates_metadata_and_moves_file`, `test_real_gh_client_invokes_subprocess`, `test_promote_potential_bug_builds_issue_body_from_bug_sections` and related tests cover valid input paths. |
| **Negative Flows** - Invalid inputs | PASS | `test_promote_potential_rejects_invalid_promotion_type`, `test_promote_potential_rejects_invalid_work_mode`, `test_promote_potential_rejects_empty_content` cover invalid inputs. |
| **Edge Cases** - Boundary conditions | PASS | `test_evaluate_minor_audit_eligibility_rejects_more_than_three_production_files` (boundary of three files), `test_extract_last_updated_returns_none_for_*` cover boundary and malformed inputs. |
| **Error Handling** - Error paths | PASS | `test_real_gh_client_raises_when_missing`, `test_main_exits_on_promotion_error`, `test_promote_potential_fails_fast_when_not_authenticated` cover error paths. |
| **Concurrency** - If applicable | N/A | The module is synchronous and single-process; no concurrency behavior exists. |
| **State Transitions** - If applicable | N/A | No stateful component was introduced or changed. |

### 1.2.1 Per-Language Coverage Comparison

- `scripts/dev_tools/potential_to_issue_adapters.py`: Baseline: 99.4% lines (hosted in `potential_to_issue.py` before the move; the adapters file is new) -> Post-change: 100.0% lines, 75.0% branches. Change: +0.6% lines relative to the former host module. New/changed-code coverage: 100.0% (48/48 lines). Disposition: PASS. Evidence: `evidence/baseline/pytest-coverage.md`, `evidence/qa-gates/pytest-coverage.md`, `artifacts/python/lcov.info`.
- `scripts/dev_tools/potential_to_issue.py`: Baseline: 99.4% lines (177/178) -> Post-change: 99.3% lines (135/136), 97.4% branches (37/38). Change: -0.2% lines by ratio, with the uncovered-line count unchanged at 1 and partial branches falling from 5 to 1. New/changed-code coverage: 100.0% (changed lines are imports and `__all__`, all executed). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-delta.md`, `artifacts/python/lcov.info`.
- `scripts/dev_tools/potential_to_issue_content.py`: Baseline: 96.8% lines (92/95) -> Post-change: 96.8% lines (92/95), 82.1% branches (23/28). Change: 0.0% lines; source file unchanged. New/changed-code coverage: 96.8% (file has no changed lines; file-level figure reported). Disposition: PASS. Evidence: `evidence/baseline/pytest-coverage.md`, `artifacts/python/lcov.info`.
- `scripts/dev_tools/potential_to_issue_filesystem.py`: Baseline: 100.0% lines (31/31) -> Post-change: 100.0% lines (31/31), 100.0% branches (14/14). Change: 0.0% lines; source file unchanged. New/changed-code coverage: 100.0% (file has no changed lines; file-level figure reported). Disposition: PASS. Evidence: `evidence/baseline/pytest-coverage.md`, `artifacts/python/lcov.info`.
- Aggregate (four potential_to_issue modules): Baseline: 98.7% lines (300/304) -> Post-change: 98.7% lines (306/310), 89.6% branches (86/96). Change: +0.03% lines; uncovered lines 4 -> 4; partial branches 10 -> 10. New/changed-code coverage: 100.0% (all changed executable lines are hit). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-delta.md`, `artifacts/python/lcov.info`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions are direct value and equality checks moved verbatim; pytest diagnostics identify the failing comparison. |
| **Arrange-Act-Assert Pattern** | PASS | Moved tests retain their existing structure; helper construction is centralized in `potential_to_issue_test_support.py`. |
| **Document Intent** | PASS | Descriptive test names are unchanged from baseline; the 59 sorted names are identical before and after. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or real gh process is used; the gh adapter tests monkeypatch `subprocess` and `shutil`. |
| **Use Mocks/Stubs** | PASS | `FakeFileSystem` and fake gh clients from the support module; monkeypatch for `adapters.subprocess` and `adapters.shutil` (repointed from the former host module). |
| **Environment Stability** | PASS | Search of the five changed test files and the support module for `tmp_path` and `tempfile` returned no match. No environment-dependent configuration was added. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the required policy review. No outstanding review items remain. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Objective: bring both files under the 500-line limit while preserving behavior, per `issue.md` (#406). |
| **Read existing change plans** | PASS | `research/research.2026-09-29T14-20.md` and `plan.2026-09-29T14-12.md` exist in the feature folder; Phase 0 instruction reading is recorded in `evidence/baseline/phase0-instructions-read.md`. |
| **Document the plan** | PASS | `plan.2026-09-29T14-12.md`, including a Plan Deviations section (D1 to D4). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Definitions moved verbatim; no new abstraction was introduced. |
| **Reusability** | PASS | The #623 filesystem seam (`potential_to_issue_filesystem.py`) is reused, not duplicated (plan deviation D1). Test helpers are shared through one support module. |
| **Extensibility** | PASS | `GhClient` Protocol and `RealGhClient` are unchanged in signature, so injection of alternative clients remains available. |
| **Separation of concerns** | PASS | The gh subprocess adapter is isolated in `potential_to_issue_adapters.py`, which imports nothing from `potential_to_issue.py`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Adapters module holds only the gh transport seam; content and filesystem modules keep their existing scope. Test files are split by behavior area. |
| **Under 500 lines** | PASS | Measured with `wc -l` at head: `potential_to_issue.py` 438 (baseline 559), adapters 154, test support 116, `test_potential_to_issue.py` 282 (baseline 1076), bug bodies 288, work modes 235, cli and adapters 138, content 295. Other family files: 430 max. |
| **Public vs internal** | PASS | `potential_to_issue.py` keeps the fifteen names in `__all__` (D1), re-exporting the moved adapter names; the diff shows no signature or message change. |
| **No circular dependencies** | PASS | `potential_to_issue_adapters.py` imports only `shutil`, `subprocess`, `dataclasses`, and `typing`; the dependency direction is `potential_to_issue` to adapters. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | New module and test file names follow the `potential_to_issue_<concern>` and `test_potential_to_issue_<concern>` convention. |
| **Docs/docstrings** | PASS | Moved classes retain their structured docstrings. The `GhClient` Protocol members carry none, as at baseline (see code review finding N1). |
| **Comment why, not what** | PASS | Existing rationale comments moved unchanged; no new narrative comments were needed. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`<br>**Result:** 533 files would be left unchanged (reviewer run). Executor evidence: `evidence/qa-gates/black.md`. |
| **2. Linting** | PASS | **Command:** `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`<br>**Result:** All checks passed (reviewer run). Executor evidence: `evidence/qa-gates/ruff.md`. |
| **3. Type checking** | PASS | **Command:** `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`<br>**Result:** 0 errors, 0 warnings, 0 informations (reviewer run). Executor evidence: `evidence/qa-gates/pyright.md`. |
| **4. Testing** | PASS | **Command:** `poetry run pytest -q tests/scripts/dev_tools/test_potential_to_i*.py`<br>**Result:** 59 passed in 0.41 s (reviewer run). Executor evidence with coverage: `evidence/qa-gates/pytest-coverage.md`. |
| **Full toolchain loop** | PASS | The executor recorded an initial Black reformat of three test files and restarted the loop; the recorded final pass is uninterrupted (`evidence/qa-gates/black.md`). |
| **Explicit reporting** | PASS | Commands and results are recorded under `evidence/qa-gates/` and summarized here. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | See section 9. |
| **Design choices explained** | PASS | Plan deviations D1 to D4 in `plan.2026-09-29T14-12.md` explain the adaptation to the merged #623 filesystem extraction. |
| **Update supporting documents** | PASS | `issue.md` acceptance criteria are checked; plan progress recorded (commit `c9b3cb67`). |
| **Provide next steps** | PASS | The change is ready for normal PR flow; see section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

Only Python has changed files on the branch. PowerShell, Bash, and JSON sections are not applicable because zero files of those languages changed.

---

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`<br>**Result:** 533 files unchanged. |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`<br>**Result:** 0 errors, 0 warnings, 0 informations. |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest -q tests/scripts/dev_tools/test_potential_to_i*.py`<br>**Result:** 59 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Full annotations retained (`list[str]`, `str | None`, `subprocess.CompletedProcess[str]`); Pyright reports 0 errors; no `Any` introduced. |
| **Dataclasses for value objects** | PASS | `GhResult` and `RealGhClient` remain `@dataclass`. |
| **Protocols/ABCs for interfaces** | PASS | `GhClient` Protocol retained; `RealGhClient` implements it. |
| **Avoid utility classes** | PASS | No static-method-only classes added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | `FileNotFoundError` and `RuntimeError` with explicit messages, moved verbatim; no broad catches. |
| **Logging over print** | PASS | No `print` calls added by the diff; CLI output behavior unchanged (`evidence/qa-gates/cli-help-smoke.md`). |
| **Invariants at construction** | PASS | `RealGhClient.__post_init__` resolves and validates `gh_path` at construction. |

Suppression policy: the two `# noqa: S603` comments moved with the code they annotate. The `# noqa: E501` in `test_potential_to_issue_content.py` line 67 exists at the merge base (line 65 there). No `# type: ignore` or `# pragma` was added.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Pytest with `monkeypatch` and plain fixtures. |
| **Coverage expectation** | PASS | New adapters module 100.0% lines and 75.0% branches; modified `potential_to_issue.py` 99.3% lines and 97.4% branches; unchanged content module 96.8% lines and 82.1% branches; unchanged filesystem module 100.0% and 100.0%. Repo-wide Python percentage is not derivable because the artifact is scoped to the four modules (see section 5). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One behavior per test; names unchanged from baseline. |
| **Mocking sparingly** | PASS | Mocks limited to the gh boundary (`subprocess`, `shutil`) and the in-memory filesystem fake. |
| **Organization** | PASS | Tests live under `tests/scripts/dev_tools/` mirroring `scripts/dev_tools/`; no colocation with production code. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_<behavior>` functions; file names `test_potential_to_issue_<area>.py`. |
| **Docstrings/comments** | PASS | Moved tests keep their existing documentation; unchanged in substance. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest -q tests/scripts/dev_tools/test_potential_to_i*.py`<br>**Result:** 59 passed. |
| **No Alternative Test Runners** | PASS | Only Pytest is used for Python. Jest ran solely as a TypeScript parity check. |

---

## 5. Test Coverage Detail

Coverage data source: `artifacts/python/lcov.info`, parsed by this review at head `c9b3cb67`. The file records LF, LH, BRF, and BRH per source file. It contains only the four `potential_to_issue*` modules (scoped run), so a repo-wide Python percentage cannot be derived from it; this is recorded as a limitation and not as a failure, because every changed module meets both thresholds and the change is a behavior-neutral move.

### potential_to_issue_adapters.py (new; 5 gh-adapter tests plus flow tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_real_gh_client_invokes_subprocess` | Positive | PASS |
| `test_real_gh_client_raises_when_missing` | Error Handling | PASS |
| `test_real_gh_client_command_raises_when_path_unresolved` | Error Handling | PASS |
| `test_real_gh_client_is_authenticated_false_when_path_unresolved` | Negative | PASS |
| `test_real_gh_client_post_init_accepts_explicit_gh_path` | Edge Case | PASS |

**Coverage:** 48/48 lines (100.0%), 12/16 branches (75.0%). Not covered: the four `GhClient` Protocol member stub exits (`44->exit`, `46->exit`, `48->exit`, `50->exit`), which contain no executable behavior.

### potential_to_issue.py (modified; 8 core-flow tests plus bug-body and work-mode tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_promote_potential_success_updates_metadata_and_moves_file` | Positive | PASS |
| `test_promote_potential_failure_does_not_move_file` | Error Handling | PASS |
| `test_promote_potential_feature_missing_label_recovers_and_moves_file` | Error Handling | PASS |
| `test_promote_potential_raises_on_missing_file` | Negative | PASS |
| `test_promote_potential_rejects_invalid_promotion_type` | Negative | PASS |
| `test_promote_potential_fails_fast_when_not_authenticated` | Error Handling | PASS |
| `test_promote_potential_bug_minor_audit_uses_bug_body` | Positive | PASS |
| `test_promote_potential_minor_audit_honors_explicit_user_selection` | Edge Case | PASS |

**Coverage:** 135/136 lines (99.3%), 37/38 branches (97.4%). Not covered: line 296, the same statement as baseline line 417 (unchanged by the split).

### potential_to_issue_content.py and potential_to_issue_filesystem.py (unchanged sources)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_build_bug_body_preserves_canonical_heading_order` | Positive | PASS |
| `test_evaluate_minor_audit_eligibility_rejects_more_than_three_production_files` | Edge Case | PASS |
| `test_extract_last_updated_returns_none_for_invalid_json` | Negative | PASS |
| `test_real_filesystem_round_trip` | Positive | PASS |

**Coverage:** content 92/95 lines (96.8%), 23/28 branches (82.1%); filesystem 31/31 lines (100.0%), 14/14 branches (100.0%). Not covered in content: lines 111, 114, and 172 plus partial branches `46->49` and `200->203`, all identical to baseline.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 59 (baseline 59; identical sorted names) | PASS |
| Tests Passed | 59 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 0.41 s total (reviewer run) | PASS Fast |
| Average Time per Test | about 7 ms | PASS Fast |
| Discovery Time | 450 ms | PASS |
| Functions/Classes Tested | Not measured separately; all four modules are at 96.8% line coverage or higher | PASS |
| Test File Size | 282 lines (was 1076); every changed test file at most 295 lines | PASS Maintainable |
| Code Coverage (if applicable) | 98.7% lines, 89.6% branches (four-module aggregate) | PASS |
| Jest parity (TypeScript side unchanged) | 9 suites, 131 tests, equal to baseline (recorded artifact, not rerun) | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` | 533 files unchanged | PASS |
| Ruff Linting | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright scripts/dev_tools tests/scripts/dev_tools` | 0 errors, 0 warnings, 0 informations | PASS |
| Pytest Tests | `poetry run pytest -q tests/scripts/dev_tools/test_potential_to_i*.py` | 59 passed in 0.41 s | PASS |

**Notes:** No pre-existing failure was observed in these checks. Zero PowerShell, TypeScript, or C# files changed, so their toolchains were not applicable to the diff; the TypeScript Jest parity run recorded by the executor confirms the sibling implementation was not disturbed.

---

## 8. Gaps and Exceptions

### Identified Gaps
**None blocking.** The following advisory observations do not fail any policy requirement:
- Coverage artifact scope: `artifacts/python/lcov.info` covers only the four affected modules, so a repo-wide Python percentage is not derived. Every changed module individually satisfies line >= 85% and branch >= 75%.
- Evidence timestamp provenance: the timestamps recorded inside `evidence/baseline/` and `evidence/qa-gates/` (for example 2026-09-30T10-22 to 10-27) are later than the commit that contains them (`c9b3cb67` at 09:59:26 -0400) and later than the wall-clock time at review. The recorded values agree with independently recomputed figures (59 tests, line counts, lcov totals), so the content is corroborated. See code review finding M1.

### Evidence Completeness (fail-closed check)
- Baseline artifacts under `evidence/baseline/`: phase0-instructions-read, issue-ac-section, line-counts, black-check, ruff-check, pyright, collected-count, pytest-coverage, jest-parity. All present.
- QA artifacts under `evidence/qa-gates/`: black, ruff, pyright, collected-count, pytest-coverage, jest-parity, cli-help-smoke, line-counts, coverage-delta, scope-check, ac-traceability. All present.
- Handoff artifact `evidence/other/phase1-handoff.md`. Present.
- Python coverage artifact `artifacts/python/lcov.info`. Present.

### Plan Deviations Reviewed
D1 to D4 in `plan.2026-09-29T14-12.md` (five names moved instead of seven because #623 already extracted the filesystem seam; 559-line baseline; expanded test and coverage sets; unchanged eight-path radius). Each is consistent with the tree at head and none weakens an acceptance criterion.

### Approved Exceptions
**None.** No exceptions needed. No `exclude` entry was added and the diff touches no coverage configuration.

### Removed/Skipped Tests
**None.** All planned tests are implemented. The collected count is 59 before and after, and the sorted test-function-name lists are identical (`evidence/qa-gates/collected-count.md`; count re-verified in this review).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **73ebd73a** - docs(406): prepare feature folder, research, and plan for oversized promotion files
2. **76f3b70f** - Merge origin/main into the feature branch
3. **2e262b38** - docs(406): record plan deviations for the 623 filesystem extraction
4. **c9488f46** - docs(406): record Phase 0 baseline evidence
5. **663a41f8** - refactor(406): split the promotion module and tests under the 500-line limit
6. **c9b3cb67** - docs(406): record final QC evidence, check off acceptance criteria and plan tasks

### Files Modified

1. **scripts/dev_tools/potential_to_issue.py** (MODIFIED)
   - 559 to 438 lines; adapter definitions removed and re-exported through `__all__`.
2. **scripts/dev_tools/potential_to_issue_adapters.py** (NEW)
   - 154 lines: `GhResult`, `GhClient`, `RealGhClient`, label constants.
3. **tests/scripts/dev_tools/potential_to_issue_test_support.py** (NEW)
   - 116 lines of shared test fakes and helpers.
4. **tests/scripts/dev_tools/test_potential_to_issue.py** (MODIFIED)
   - 1076 to 282 lines; core flow tests only.
5. **tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py** (NEW)
   - 288 lines, 6 tests.
6. **tests/scripts/dev_tools/test_potential_to_issue_work_modes.py** (NEW)
   - 235 lines, 7 tests.
7. **tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py** (NEW)
   - 138 lines, 5 tests.
8. **tests/scripts/dev_tools/test_potential_to_issue_content.py** (MODIFIED)
   - 295 lines; received moved content tests (11 tests).

Documentation under `docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/` (issue, plan, research, evidence) was added. The eight non-documentation paths equal the blast radius declared in plan task P2-T10; no path under `extensions/` changed.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policies pass. Python is the only language with changed files and its coverage verdict is an explicit PASS: every changed module meets line >= 85% and branch >= 75%, and no regression exists on changed lines. No blocking findings; remediation inputs are not required.

**Fail-closed reminder:** Every required baseline artifact, QA artifact, coverage metric, and coverage-comparison artifact is present, so the fail-closed condition does not apply.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, plan, and deviations documented.
- PASS Design Principles: verbatim extract-and-move; separation of concerns improved.
- PASS Module & File Structure: all eight files at most 438 lines.
- PASS Naming, Docs, Comments: conventions followed; Protocol member docstrings absent as at baseline.
- PASS Toolchain Execution: Black, Ruff, Pyright, Pytest all pass.
- PASS Summarize & Document: plan deviations and evidence recorded.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline: all four gates pass.
- PASS Python Design & Typing: typed, dataclass and Protocol usage retained.
- PASS Error Handling: specific exceptions, no broad catches.

#### General Unit Test Policy (Section 1)
- PASS Core Principles: independent, isolated, fast, deterministic.
- PASS Coverage & Scenarios: no regression; new module meets thresholds.
- PASS Test Structure: unchanged AAA structure.
- PASS External Dependencies: no network, no temporary files.
- PASS Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope: Pytest only.
- PASS Test Style & Structure: mirrored layout under `tests/`.
- PASS Naming & Readability: names preserved from baseline.
- PASS Toolchain: 59 passed.

---

### Metrics Summary

- PASS 59/59 tests passing (100%)
- PASS 98.7% four-module line coverage (baseline 98.7%), 89.6% branch coverage
- PASS Proper file organization: tests mirror the source tree, eight paths only
- PASS All code quality checks passing
- PASS Test execution time: 0.41 seconds (fast)

---

### Recommendation

**Ready for merge**

No corrective action is required. The optional follow-ups are the advisory items in section 8 (scoped coverage artifact; evidence timestamp provenance).

---

## Appendix A: Test Inventory

### Complete Test List

Family collected by `pytest --collect-only -q tests/scripts/dev_tools/test_potential_to_i*.py`: 59 tests across nine files.

1. `test_potential_to_issue.py` (8): success updates metadata and moves file; failure does not move file; feature missing label recovers and moves file; feature existing label uses single create attempt; raises on missing file; rejects invalid promotion type; checks authentication before proceeding; fails fast when not authenticated.
2. `test_potential_to_issue_bug_bodies.py` (6): bug builds issue body from bug sections; bug missing sections use placeholders; normalizes smart punctuation in body and title; bug honors explicit minor-audit; bug minor-audit uses bug body; full alias normalizes bug to full-bug.
3. `test_potential_to_issue_work_modes.py` (7): minor-audit adds required issue sections; work mode marker minor-audit; marker honors explicit minor-audit; persists explicit selected work mode; minor-audit honors explicit user selection; full mode preserves existing body contract; body omits token-like secret strings.
4. `test_potential_to_issue_cli_and_adapters.py` (5): real gh client invokes subprocess; raises when missing; real filesystem round trip; parse args and main paths; main exits on promotion error.
5. `test_potential_to_issue_content.py` (11): build bug body canonical heading order; minor-audit eligibility accepts bootstrapped keyword; rejects more than three production files; extract last updated returns none for invalid JSON, non-string, and invalid ISO timestamp; update metadata lines inserts missing fields; normalize smart punctuation; get feature name variants; get feature path variants; get section variants.
6. `test_potential_to_issue_branches.py` (10), `test_potential_to_issue_filesystem.py` (8), `test_potential_to_issue_missing_label_regression.py` (1), `test_potential_to_issue_move_verification.py` (3): unchanged files, included in the 59-test family.

Sum: 8 + 6 + 7 + 5 + 11 + 10 + 8 + 1 + 3 = 59, equal to the baseline count of 59.

---

## Appendix B: Toolchain Commands Reference

Python (run in this review at head `c9b3cb67`):

1. `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`
2. `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`
3. `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`
4. `poetry run pytest -q tests/scripts/dev_tools/test_potential_to_i*.py`
5. `poetry run pytest --collect-only -q tests/scripts/dev_tools/test_potential_to_i*.py`
6. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`

Read-only evidence inspection: `wc -l` on the eight changed paths; `git diff --name-status 2b0121ab HEAD`; `git grep` for `noqa` at the merge base; parsing `LF`, `LH`, `BRF`, `BRH` records in `artifacts/python/lcov.info`.

Recorded by the executor and not rerun (coverage generation is not rerun by the reviewer): `poetry run pytest <family> --cov=<four modules> --cov-branch --cov-report=term-missing` and `npm --prefix extensions/drm-copilot run test:unit -- test/lib/potential-to-issue test/extension.potential-to-issue.test.ts`.

Coverage artifact paths: TypeScript `coverage/lcov.info` (not applicable, no changed TypeScript files); Python `artifacts/python/lcov.info` (present); PowerShell `artifacts/pester/powershell-coverage.xml` (not applicable); C# `artifacts/csharp/coverage.xml` (not applicable).

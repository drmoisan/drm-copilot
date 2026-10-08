# Policy Compliance Audit: Claude resource parity test excludes gitignored local runtime state (#510)

---

**Audit Date:** 2026-10-07
**Code Under Test:** `tests/scripts/dev_tools/claude_payload_scope_test_support.py` (new), `tests/scripts/dev_tools/test_claude_payload_scope_support.py` (new), `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (modified), `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` (modified). The remaining 30 changed files are feature-folder documents and evidence under `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/`.

**Base / Head:** base `main` (resolved `origin/main` at `869c4fad`, merge base `869c4fad`); head `bug/claude-resource-parity-enumerates-gitignored-state-510` at `b0215e91`. Source: `artifacts/pr_context.summary.txt`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 4 files (all under `tests/`) | 38 tests across the three affected test files (22 baseline + 16 new) | PASS: 38 pass, 0 fail | Not applicable to the new helper (new file). Two-file comparison run: TOTAL 2% (Stmts 17556, Miss 17034, Branch 6338, BrPart 12) with `--cov-fail-under=0` | Identical TOTAL row, 2% (no regression) | Helper: 12/12 lines = 100%, 2/2 branches = 100% |
| TypeScript | 0 files | N/A | N/A | N/A (zero changed files) | N/A | N/A |
| PowerShell | 0 files | N/A | N/A | N/A (zero changed files) | N/A | N/A |
| C# | 0 files | N/A | N/A | N/A (zero changed files) | N/A | N/A |
| Markdown (docs/evidence) | 30 files | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- Python baseline coverage artifact: `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/baseline/baseline-pytest-coverage.2026-09-29T14-11.md`
- Python post-change coverage artifact: `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-pytest-coverage.2026-09-29T14-11.md`
- Python new-code coverage artifact: `artifacts/python/lcov.info` (helper: LF 12, LH 12, BRF 2, BRH 2) and `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/qa-gates/final-helper-coverage.2026-09-29T14-11.md`
- TypeScript, PowerShell, C# artifacts: not applicable; zero changed files for those languages on the branch.
- Per-language comparison summary: Section 1.2.1.

---

## Rejected Scope Narrowing

None detected. The caller prompt specified the full branch diff against `main`, the refreshed PR-context artifacts, and the `spec.md` acceptance-criteria source, which matches the authoritative scope. The caller's agent-count cap (no sub-agents) constrains execution mechanics only and does not narrow audit scope.

## Evidence Location Compliance

- `EVIDENCE_LOCATION_OVERRIDE_REJECTED`: none supplied by the caller.
- Scan command: `poetry run python -I scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no violations reported.
- Branch diff inspection (`git diff --name-status 869c4fad..HEAD`): no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 30 evidence files sit under `docs/features/active/.../evidence/{baseline,other,qa-gates,regression-testing}/`.
- Note: `spec.md` acceptance criterion 11 names the override rc file at `evidence/coverage/coveragerc-helper.ini`. `evidence/coverage/` is not a canonical evidence kind in `evidence-and-timestamp-conventions`; the file was stored at `evidence/other/coveragerc-helper.ini`, which is the compliant location. Verdict: PASS (see finding F-03 in the code review for the spec wording drift).

Executive result: PASS.

---

## Executive Summary

The change is a test-only fix for issue #510. A shared pure helper (`claude_payload_scope_test_support.py`) classifies repo-relative `.claude` paths as local runtime state by `Path.parts[:2]` (subdirs `agent-memory`, `state`, `worktrees`) or by an explicit file entry (`.claude/settings.local.json`). The parity test now filters its repo-side enumeration through `filter_distributable_claude_paths`, the earlier private `_is_agent_memory_path` and `AGENT_MEMORY_RELATIVE_ROOT` were removed, and `EXCLUDED_CLAUDE_SUBDIRS` in the frontmatter test is bound to the helper constant as a drift guard. The `Repo file missing from bundle` assertion and byte-comparison loop are unchanged. No production file changed.

Toolchain verification performed in this review (check-only, no coverage regeneration): Black check on the four Python files (4 files unchanged), Ruff check on `tests/scripts/dev_tools` (all checks passed), Pyright on the four files (no diagnostics reported), and pytest on the three affected test files with `--no-cov` (38 passed). Executor evidence for the repo-wide Black, Ruff, and Pyright runs is recorded in `evidence/qa-gates/`.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`
- PASS `quality-tiers.md`

**Language-specific policies evaluated:**
- PASS `python.md` and `python-suppressions.md` (typing, suppressions, test layout)
- N/A PowerShell, TypeScript, C#, Bash, JSON (zero changed files for these languages)

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts are present in the branch diff.
- PASS The new helper is fully tested by 16 tests and is kept deliberately as shared test support.
- Dispositions: no scripts were created during development beyond the helper and its tests.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | All 16 helper tests operate on literal `Path` values with no shared mutable state (`test_claude_payload_scope_support.py`). |
| **Isolation** - Each test targets single behavior | PASS | One behavior per test: reported path, nested state, worktrees, agent-memory, settings.local, retained paths (parametrized x5), order/return type, missing-file scenario, drift guard, single-part path, bare state path, empty input. |
| **Fast Execution** - Tests complete quickly | PASS | 38 tests passed in 0.27s in this review; `evidence/qa-gates/final-pytest.2026-09-29T14-11.md` records 0.32s. |
| **Determinism** - Consistent results | PASS | No clock, RNG, filesystem, or subprocess use in the new tests; the helper is pure. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive names, one-line docstrings, AAA comments, assertion messages on each assert (one exception noted as Nit N-01 in the code review). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `evidence/baseline/baseline-pytest-coverage.2026-09-29T14-11.md` (TOTAL 2% two-file comparison value) and `evidence/baseline/baseline-pytest.2026-09-29T14-11.md` (22 passed). |
| **No Coverage Regression** | PASS | `evidence/qa-gates/final-pytest-coverage.2026-09-29T14-11.md` records an identical TOTAL row (2%). No production line changed, and `pyproject.toml` omits `tests/*` from measurement, so the two modified test files carry no measured lines. |
| **New Code Coverage >= 85% line / >= 75% branch** | PASS | New helper: 12/12 lines (100%), 2/2 branches (100%) per `artifacts/python/lcov.info` and `evidence/qa-gates/final-helper-coverage.2026-09-29T14-11.md`. Calculation uses the override rc file `evidence/other/coveragerc-helper.ini` (no `omit`), required because the default configuration omits `tests/*`. |
| **Comprehensive Coverage** | PASS | `is_local_runtime_path` (lines 35-44) and `filter_distributable_claude_paths` (lines 47-49) are exercised; FNH 2 of FNF 2. Untested code: none. |
| **Positive Flows** | PASS | Five retained-path cases plus the order/list test. |
| **Negative Flows** | PASS | Excluded-path tests for state, nested state, worktrees, agent-memory, settings.local.json. |
| **Edge Cases** | PASS | Single-part `.claude`, bare `.claude/state`, empty input, lookalikes `.claude/statement.md`, `.claude/hooks/state/x.ps1`, `.claude/settings.local.json.bak`. |
| **Error Handling** | N/A | The helper raises no errors by design (spec "Error handling and logging updates: None"). |
| **Concurrency** | N/A | Pure synchronous functions. |
| **State Transitions** | N/A | Stateless. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 2% (two-file comparison TOTAL, comparison value only) -> Post-change: 2%. Change: 0 percentage points. New/changed-code coverage: 100% line, 100% branch for the new helper; modified files are test files omitted from measurement by `pyproject.toml`. Disposition: PASS. Evidence: `evidence/baseline/baseline-pytest-coverage.2026-09-29T14-11.md`, `evidence/qa-gates/final-pytest-coverage.2026-09-29T14-11.md`, `evidence/qa-gates/final-helper-coverage.2026-09-29T14-11.md`, `artifacts/python/lcov.info`.
- TypeScript, PowerShell, C#: N/A. Zero changed files on the branch.

Coverage-limit note: `artifacts/python/lcov.info` currently holds the helper measurement only (the last coverage command overwrote it); it does not carry a repo-wide Python figure. The branch changes no production Python file, so the repo-wide Python figure is unaffected by this diff. Recorded as finding F-02 (Minor) in the code review.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Each assertion carries an explanatory message, for example `"Reported .claude/state file must be excluded"`. |
| **Arrange-Act-Assert Pattern** | PASS | Each test contains `# Arrange`, `# Act`, `# Assert` sections. |
| **Document Intent** | PASS | Module docstring cites issue #510; every test has a one-line docstring. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | Helper module states and implements "no filesystem access, no subprocess, no logging". |
| **Use Mocks/Stubs** | N/A | None needed; inputs are literal `Path` values. |
| **Environment Stability** | PASS | No temporary files, no wall-clock use. `test_missing_tracked_file_is_still_reported` uses in-memory lists. The contract test still reads the real repo tree, as it did at baseline. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the policy review. No outstanding blocking items. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md`, `spec.md` (Context, Root Cause Analysis) for issue #510. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.md` records the six policy files read. |
| **Document the plan** | PASS | `plan.2026-09-29T14-11.md`, `research/research.2026-09-29T14-15.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Static part-level predicate; options `git ls-files` and `.gitignore` parsing explicitly rejected in `spec.md`. |
| **Reusability** | PASS | One shared constant set consumed by the parity test and the frontmatter test; the duplicate literal was removed. |
| **Extensibility** | PASS | New gitignored `.claude/<subdir>` paths require one edit to `LOCAL_ONLY_CLAUDE_SUBDIRS`. |
| **Separation of concerns** | PASS | Pure classification logic is separated from the filesystem walk (`list_scoped_files`) that remains in the contract test. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Helper has one purpose (49 lines). |
| **Under 500 lines** | PASS | 49, 199, 467, and 499 lines (`evidence/qa-gates/final-limits-and-boundary.2026-09-29T14-11.md`). The frontmatter test file sits at 499, one line under the limit. |
| **Public vs internal** | PASS | Public surface: two constants and two functions, all documented. |
| **No circular dependencies** | PASS | The helper imports only stdlib; the two test modules import the helper. `test_claude_payload_scope_support.py` imports from `test_claude_rules_frontmatter.py` (test-to-test import, one direction only). See finding F-01. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `is_local_runtime_path`, `filter_distributable_claude_paths`, `LOCAL_ONLY_CLAUDE_SUBDIRS`. |
| **Docs/docstrings** | PASS | Module and function docstrings present. |
| **Comment why, not what** | PASS | Module docstring records the gitignore line references (23, 69, 70, verified against `.gitignore` in this review) and why parts-based matching is used. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `poetry run black --check .` (executor, `evidence/qa-gates/final-black-check.2026-09-29T14-11.md`, EXIT_CODE 0); reviewer rerun on the four files: 4 files would be left unchanged. |
| **2. Linting** | PASS | **Command:** `poetry run ruff check .` (executor evidence, EXIT_CODE 0); reviewer rerun on `tests/scripts/dev_tools`: All checks passed. |
| **3. Type checking** | PASS | **Command:** `poetry run pyright` (executor evidence, EXIT_CODE 0); reviewer rerun on the four files reported no diagnostics. |
| **4. Testing** | PASS | **Command:** `poetry run pytest <three files>`; 38 passed (executor and reviewer runs). |
| **Full toolchain loop** | PASS | Executor evidence records a final single-pass QC phase (P5). |
| **Explicit reporting** | PASS | Each gate has a dated artifact under `evidence/qa-gates/`. Executor EXIT_CODE values are inferred from output summaries (the artifacts state this); see finding F-04. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commits `2c120131`, `ee7ec57a`, `b0215e91`; docstring updates in the contract test. |
| **Design choices explained** | PASS | `spec.md` "Proposed Fix" and "Drift-guard decision". |
| **Update supporting documents** | PASS | `spec.md` acceptance criteria checked; AC status summary at `evidence/qa-gates/ac-status-summary.2026-09-29T14-11.md`. |
| **Provide next steps** | PASS | `evidence/other/follow-up-issue-request.2026-09-29T14-11.md` requests a separate issue for the out-of-scope production push-down defect. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check .` exit 0 (executor); reviewer 4 files unchanged. |
| **Linting with Ruff** | PASS | `poetry run ruff check .` exit 0 (executor); reviewer rerun clean. |
| **Type checking with Pyright** | PASS | `poetry run pyright` exit 0 (executor); reviewer rerun no diagnostics. |
| **Testing with Pytest** | PASS | 38 passed. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Explicit `frozenset[str]`, `frozenset[Path]`, `bool`, `list[Path]` annotations; `Iterable` imported under `TYPE_CHECKING`. No `Any`. |
| **Dataclasses for value objects** | N/A | No value objects introduced. |
| **Protocols/ABCs for interfaces** | N/A | No interfaces introduced. |
| **Avoid utility classes** | PASS | Module-level functions, no static-method classes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | No exception handling; `try/except ValueError` removed together with `_is_agent_memory_path`. |
| **Logging over print** | PASS | No print or logging calls. |
| **Invariants at construction** | N/A | No classes. |

Suppression scan: no `# type: ignore`, `# noqa`, or `# pyright: ignore` introduced in the four Python files (`python-suppressions.md`). PASS.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `pytest.mark.parametrize` for the retained-path cases. |
| **Coverage expectation** | PASS | New helper 100% line and 100% branch (threshold 85% / 75%). Modified files are test files omitted from measurement; no production file changed. See Section 1.2.1 for the repo-wide note. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One behavior per test. |
| **Mocking sparingly** | PASS | No mocks. |
| **Organization** | PASS | Tests live under `tests/scripts/dev_tools/`; no colocation under production source. The helper is itself test support under `tests/`, following the pattern of `push_down_handoff_test_support.py`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_<behavior>` names. |
| **Docstrings/comments** | PASS | One-line docstrings, AAA comments. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `poetry run pytest` (three files, 38 passed). |
| **No Alternative Test Runners** | PASS | Only pytest used. |

Coverage exclusion policy check (`general-unit-test.md`): the branch diff contains no change to `pyproject.toml`, `jest.config.cjs`, or any coverage `exclude` list; no production path is excluded. PASS. The override rc file `evidence/other/coveragerc-helper.ini` is verification tooling stored as evidence, not a repository coverage configuration.

---

## 5. Test Coverage Detail

### `claude_payload_scope_test_support.py` (16 tests via `test_claude_payload_scope_support.py`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_state_file_from_issue_report_is_excluded | Negative (exclusion) | 37-43 | PASS |
| test_nested_state_paths_are_excluded | Edge Case | 37-43 | PASS |
| test_worktrees_paths_are_excluded | Edge Case | 37-43 | PASS |
| test_agent_memory_paths_remain_excluded | Negative (exclusion) | 37-43 | PASS |
| test_settings_local_json_remains_excluded | Negative (exclusion) | 44 | PASS |
| test_lookalike_and_tracked_paths_are_retained (x5) | Positive | 37-44 | PASS |
| test_filter_preserves_order_and_returns_list | Positive | 47-49 | PASS |
| test_missing_tracked_file_is_still_reported | Positive (scenario) | 47-49 | PASS |
| test_subdirs_match_frontmatter_excluded_subdirs | Contract / drift guard | 27-32 | PASS |
| test_single_part_claude_path_is_retained | Edge Case | 37-38, 44 | PASS |
| test_bare_state_path_without_child_is_excluded | Edge Case | 37-43 | PASS |
| test_empty_input_returns_empty_list | Edge Case | 49 | PASS |

**Coverage:** 100% of the helper (12/12 statements, 2/2 branches, functions 2/2).

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (three affected files) | 38 | PASS |
| Tests Passed | 38 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 0.27s total (reviewer run, `--no-cov`) | PASS Fast |
| Average Time per Test | about 7ms | PASS Fast |
| Functions/Classes Tested | 2/2 helper functions (100%) | PASS |
| Test File Size | 199 lines (new test file) | PASS Maintainable |
| Code Coverage (new helper) | 100% lines, 100% branches | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` (executor); `poetry run black --check <four files>` (reviewer) | 4 files would be left unchanged | PASS |
| Ruff Linting | `poetry run ruff check .` (executor); `poetry run ruff check tests/scripts/dev_tools` (reviewer) | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright` (executor); `poetry run pyright <four files>` (reviewer) | No diagnostics reported | PASS |
| Pytest Tests | `poetry run pytest <three files> --no-cov -q` | 38 passed | PASS |

**Notes:** No pre-existing failures were observed. The reviewer did not create a `.claude/state/` file to reproduce the original failure end to end: the worktree has no `.claude/state/` directory, the spec forbids creating the state file from a test, and review commands are check-only. The fix is verified through the pure predicate tests and the wiring evidence (`evidence/regression-testing/contracts-test-wiring.2026-09-29T14-11.md`). Recorded as finding F-05 (Info).

---

## 8. Gaps and Exceptions

### Identified Gaps

- No blocking gap. Minor and informational observations are listed as F-01 to F-05 in `code-review.2026-10-07T15-30.md`.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests (16 test functions including 5 parametrized cases) are implemented; `_is_agent_memory_path` and its constant were removed because the shared helper supersedes them (confirmed by `evidence/regression-testing/removed-identifiers-grep.2026-09-29T14-11.md`, grep exit 1 as expected).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **194975b9** - docs(510): prepare feature folder, research, spec, and plan
2. **2647bcd6** - Merge origin/main into bug/claude-resource-parity-enumerates-gitignored-state-510
3. **2c120131** - test(510): add shared .claude payload scope helper and exclude state/worktrees from parity
4. **ee7ec57a** - test(510): wire shared payload-scope helper into bundle parity test
5. **b0215e91** - docs(510): record helper coverage, final QC evidence, and AC closure

### Files Modified

1. **tests/scripts/dev_tools/claude_payload_scope_test_support.py** (NEW, 49 lines)
   - Pure scope predicate and list filter for distributable `.claude` paths.
2. **tests/scripts/dev_tools/test_claude_payload_scope_support.py** (NEW, 199 lines)
   - 16 unit tests over literal `Path` values.
3. **tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py** (MODIFIED, +13/-46)
   - Inline filter replaced with `filter_distributable_claude_paths`; private helper and constant removed; docstrings updated.
4. **tests/scripts/dev_tools/test_claude_rules_frontmatter.py** (MODIFIED, +4/-4)
   - `EXCLUDED_CLAUDE_SUBDIRS` now imported as an alias of `LOCAL_ONLY_CLAUDE_SUBDIRS`.
5. **docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/** (NEW, 30 files)
   - issue, spec, plan, research, and evidence artifacts.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

The branch satisfies the general code change, general unit test, quality-tier, and Python policies. Python coverage for the only new code file is 100% line and 100% branch; no production file changed; no coverage exclusion was added; evidence is stored in canonical locations. No FAIL or PARTIAL result requires remediation.

**Fail-closed reminder:** All required baseline, QA-gate, and coverage-comparison artifacts were located and inspected (paths listed above).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, plan, and policy reading recorded.
- PASS Design Principles: simple, reusable, extensible, separated.
- PASS Module & File Structure: all files at or under 500 lines (499 maximum).
- PASS Naming, Docs, Comments: descriptive and documented.
- PASS Toolchain Execution: Black, Ruff, Pyright, Pytest clean.
- PASS Summarize & Document: spec, plan, evidence, follow-up request.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline: clean.
- PASS Python Design & Typing: fully annotated, no suppressions.
- PASS Error Handling: not applicable beyond removal of a try/except.

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 38/38 tests passing (100%).
- PASS 2/2 helper functions tested (100%).
- PASS 100% line and 100% branch coverage for the new helper.
- PASS Test layout mirrors the `tests/scripts/dev_tools/` structure; no colocation.
- PASS All code quality checks passing.
- PASS Test execution time 0.27 seconds.

---

### Recommendation

**Ready for merge**

No blocking findings. Optional follow-ups (all non-blocking): reconcile stale `.gitignore` line numbers and the `evidence/coverage/` path in `spec.md`; open the follow-up issue for the out-of-scope production push-down defect; consider recording a repo-wide Python coverage artifact in CI.

---

## Appendix A: Test Inventory

- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_state_file_from_issue_report_is_excluded
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_nested_state_paths_are_excluded
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_worktrees_paths_are_excluded
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_agent_memory_paths_remain_excluded
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_settings_local_json_remains_excluded
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_lookalike_and_tracked_paths_are_retained (5 parametrized cases)
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_filter_preserves_order_and_returns_list
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_missing_tracked_file_is_still_reported
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_subdirs_match_frontmatter_excluded_subdirs
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_single_part_claude_path_is_retained
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_bare_state_path_without_child_is_excluded
- tests/scripts/dev_tools/test_claude_payload_scope_support.py::test_empty_input_returns_empty_list
- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts (modified, existing)
- tests/scripts/dev_tools/test_claude_rules_frontmatter.py (existing tests; excluded-subdir binding changed)

---

## Appendix B: Toolchain Commands Reference

**For Python (check-only, as run or inspected in this review):**
```bash
# Formatting
poetry run black --check .

# Linting
poetry run ruff check .

# Type checking
poetry run pyright

# Testing (reviewer run)
poetry run pytest -p no:cacheprovider --no-cov -q tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_payload_scope_support.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py

# Helper coverage (executor evidence, not rerun by reviewer)
poetry run pytest tests/scripts/dev_tools/test_claude_payload_scope_support.py --cov=tests.scripts.dev_tools.claude_payload_scope_test_support --cov-branch --cov-config=docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/evidence/other/coveragerc-helper.ini --cov-report=term-missing

# Evidence location scan
poetry run python -I scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-07
**Policy Version:** Current (as of audit date)

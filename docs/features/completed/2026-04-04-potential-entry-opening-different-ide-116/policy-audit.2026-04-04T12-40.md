# Policy Compliance Audit: potential-entry-opening-different-ide (Issue #116)

**Audit Date:** 2026-04-04  
**Feature Folder:** `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116`  
**Base Branch (user-specified):** `development`  
**Feature Folder Selection Rule:** The user-specified active folder was retained because it is the only folder matching issue `#116` and it contains complete Phase 0, Phase 1, and Phase 2 evidence.  
**Code Under Test:**
- `scripts/dev_tools/new_potential_bug_entry.py`
- `scripts/dev_tools/new_active_feature_folder_io.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`
- `tests/scripts/dev_tools/test_new_potential_bug_entry.py`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py`

**Review scope note:** The repository-level PR context artifacts under `artifacts/` were stale for this audit run and referenced `feature/mcp-functions` rather than the audited minor-audit folder. This review therefore used the folder-local evidence as the authoritative execution record, plus the Phase 0 branch baseline artifact recording `potential-entry-opening-different-ide` at commit `da3fa594bcb10be67f885c7cc9f49aa1d83653b3`.

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 4 production files, 2 test files | 31 targeted tests; 911 full-suite tests | ⚠️ PARTIAL | 83% (`6633` statements, `1153` missed) | 83% (`6669` statements, `1153` missed) | UNVERIFIED / remediation required |

## Executive Summary

This reduced audit confirms that the minor-audit folder integrity requirements were satisfied: `issue.md` is the sole requirements source, the explicit `## Acceptance Criteria` section exists, `spec.md` and `user-story.md` are absent, and the required Phase 0–2 evidence artifacts exist. The recorded toolchain loop reached a clean final pass (`black`, `ruff`, `pyright`, `pytest --cov`) and the targeted red/green regression evidence exists for the Python launcher fix.

The review outcome is **⚠️ PARTIALLY COMPLIANT / Needs revision**. Acceptance Criterion 3 is satisfied, but Acceptance Criteria 1 and 2 remain `UNVERIFIED / remediation required` because no live Windows verification evidence was recorded showing that the two workflows reused the originating VS Code or VS Code Insiders window. In addition, the recorded evidence does not deterministically isolate changed/new-code coverage, so the repo policy requirement for ≥90% coverage on new code cannot be closed as passed.

**Policy documents evaluated:**
- [✅] `.github/instructions/general-code-change.instructions.md`
- [✅] `.github/instructions/general-unit-test.instructions.md`
- [✅] `.github/instructions/python-code-change.instructions.md`
- [✅] `.github/instructions/python-unit-test.instructions.md`
- [✅] `.github/instructions/python-suppressions.instructions.md`
- [✅] `.github/instructions/self-explanatory-code-commenting.instructions.md`

**Temporary artifacts cleanup:**
- [✅] No temporary one-off scripts were introduced by the recorded implementation evidence.
- [✅] The audited scripts remain part of the repository's maintained Python tooling and are covered by pytest evidence.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | [✅] [PASS] | The targeted regression tests are pure pytest unit tests using fakes/monkeypatching rather than shared filesystem state. Evidence: `evidence/regression-testing/p1-t1.red-pytest.2026-04-04T12-26.md`, `p1-t2.targeted-pytest.2026-04-04T12-29.md`. |
| Isolation | [✅] [PASS] | The targeted tests isolate CLI resolution, Insiders detection, `--reuse-window`, and no-CLI fallback as separate behaviors in `tests/scripts/dev_tools/test_new_potential_bug_entry.py` and `tests/scripts/dev_tools/test_new_active_feature_folder.py`. |
| Fast Execution | [✅] [PASS] | Red run: `31` tests in `0.14s`; green run: `31` tests in `0.05s`. Full suite: `911` tests in `3.22s`. |
| Determinism | [✅] [PASS] | Tests use fake launchers, fake PATH resolution, and controlled environment variables. No network, no external services, and no temporary files were required by the targeted scenarios. |
| Readability & Maintainability | [✅] [PASS] | Test names are descriptive and scenario-based, for example `test_default_code_launcher_prefers_code_insiders_for_insiders_session`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | [✅] [PASS] | Baseline recorded in `evidence/baseline/p0-t7.pytest-coverage.2026-04-04T12-21.md`: `907` passed, `83%` total coverage. |
| No Coverage Regression | [✅] [PASS] | `83%` baseline → `83%` post-change. `p2-t5.end-state-summary.2026-04-04T12-36.md` explicitly records no headline regression. |
| New Code Coverage ≥90% | [⚠️] [PARTIAL] | `p2-t5.end-state-summary.2026-04-04T12-36.md` states that changed/new-code coverage could not be deterministically isolated, so the policy obligation was not closed as passed. |
| Comprehensive Coverage | [✅] [PASS] | Red/green evidence covers the new launcher behaviors. AC-3 is recorded as PASS in `p2-t5.end-state-summary.2026-04-04T12-36.md`. |
| Positive Flows | [✅] [PASS] | Targeted passing tests confirm standard `code` resolution and successful launch invocation. |
| Negative Flows | [✅] [PASS] | Targeted tests validate failure paths when no VS Code CLI is available and invalid inputs are supplied. |
| Edge Cases | [✅] [PASS] | Targeted tests cover Insiders-session detection, fallback resolution order, and path argument handling. |
| Error Handling | [✅] [PASS] | The CLI boundary tests cover invalid short names and missing template behavior for `new_potential_bug_entry.py`. |
| Concurrency | [N/A] [N/A] | The audited scripts do not implement concurrent behavior. |
| State Transitions | [N/A] [N/A] | The audited scripts are stateless workflow helpers rather than explicit state machines. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear Failure Messages | [✅] [PASS] | The red-run artifact names the six failing scenarios explicitly. |
| Arrange-Act-Assert Pattern | [✅] [PASS] | The targeted tests follow explicit setup, invocation, and assertion steps with fake launchers and patched environment lookups. |
| Document Intent | [✅] [PASS] | Many tests include docstrings describing the exact behavior under test. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid External Dependencies | [✅] [PASS] | Targeted tests avoid network and live editor dependencies by mocking PATH resolution and subprocess calls. |
| Use Mocks/Stubs | [✅] [PASS] | `FakeFileSystem`, fake launchers, monkeypatched `shutil.which`, and monkeypatched `subprocess.run` isolate behavior safely. |
| Environment Stability | [✅] [PASS] | No temporary files or mutable external configuration are required for the targeted launcher tests. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission Review | [✅] [PASS] | This document, together with `code-review.2026-04-04T12-40.md` and `feature-audit.2026-04-04T12-40.md`, satisfies the reduced post-implementation review requirement. |

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | [✅] [PASS] | `issue.md` states the defect, expected behavior, actual behavior, and explicit acceptance criteria. |
| Read existing change plans | [✅] [PASS] | The feature folder contains `plan.2026-04-04T11-48.md`, and `change-plan.md` was also reviewed. |
| Document the plan | [✅] [PASS] | The plan file records deterministic Phase 0–2 tasks and evidence requirements. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | [✅] [PASS] | The recorded implementation summary shows the fix stayed at the Python launcher seam instead of widening scope into extension-host artifact plumbing. |
| Reusability | [✅] [PASS] | Root and bundled launcher copies were kept behaviorally aligned, and the existing `FileSystem`/helper patterns were preserved. |
| Extensibility | [✅] [PASS] | The CLI resolution logic is isolated in `_is_insiders_session()` and `_resolve_code_cli()` helpers. |
| Separation of concerns | [✅] [PASS] | Template materialization, author lookup, and editor launch concerns remain separated from the higher-level workflows. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | [✅] [PASS] | Each audited module remains focused on either bug-entry generation or active-feature-folder I/O. |
| Under 500 lines | [✅] [PASS] | Line counts gathered during review: `363`, `255`, `363`, `256`, `230`, `453`. All audited files remain under the 500-line limit. |
| Public vs internal | [✅] [PASS] | Internal helpers remain underscore-prefixed; the public script entrypoints stay small and explicit. |
| No circular dependencies | [✅] [PASS] | Static inspection shows one-way imports from the active-folder I/O module into supporting markdown/models helpers only. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | [✅] [PASS] | Function names such as `_resolve_code_cli`, `_is_insiders_session`, and `default_code_launcher` are descriptive and accurate. |
| Docs/docstrings | [⚠️] [PARTIAL] | Most functions include robust docstrings, but `_resolve_code_cli()` in both root and bundled copies contains an accidental stray literal line (`[code_cmd, "--reuse-window", ...]`) inside the docstring. |
| Comment why, not what | [✅] [PASS] | The Insiders-detection loops include intent comments explaining deterministic ordering and fallback behavior. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| 1. Formatting | [✅] [PASS] | Recorded command: `poetry run black .` → `172 files left unchanged` in `p2-t1.black.2026-04-04T12-36.md`. |
| 2. Linting | [✅] [PASS] | Recorded command: `poetry run ruff check` → `All checks passed!` in `p2-t2.ruff.2026-04-04T12-36.md`. |
| 3. Type checking | [✅] [PASS] | Recorded command: `poetry run pyright` → `0 errors, 0 warnings, 0 informations` in `p2-t3.pyright.2026-04-04T12-36.md`. |
| 4. Testing | [✅] [PASS] | Recorded command: `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` → `911 passed`, `83%` in `p2-t4.pytest-coverage.2026-04-04T12-36.md`. |
| Full toolchain loop | [✅] [PASS] | `p2-t5.end-state-summary.2026-04-04T12-36.md` documents an initial Phase 2 failure, correction, rerun from `P2-T1`, and final clean pass. |
| Explicit reporting | [✅] [PASS] | Exact commands and outputs are preserved in the feature evidence artifacts. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | [✅] [PASS] | `p1-t3.implementation-summary.2026-04-04T12-29.md` maps each modified file to the supported acceptance criteria. |
| Design choices explained | [✅] [PASS] | The implementation summary explicitly records why the fix stayed at the launcher seam and aligned the Python paths with the PowerShell control path. |
| Update supporting documents | [✅] [PASS] | The feature folder includes issue, plan, research, baseline evidence, regression evidence, QA evidence, and now review artifacts. |
| Provide next steps | [⚠️] [PARTIAL] | Next steps are clear—live Windows verification and coverage-evidence closure—but they are still outstanding. |

## 3. Python Code Change Policy Compliance

### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Black | [✅] [PASS] | `poetry run black .` passed in final QC evidence. |
| Linting with Ruff | [✅] [PASS] | `poetry run ruff check` passed in final QC evidence. |
| Type checking with Pyright | [✅] [PASS] | `poetry run pyright` passed in final QC evidence. |
| Testing with Pytest | [✅] [PASS] | Targeted pytest and full coverage-enabled pytest both passed after the fix. |

### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| Strong typing | [✅] [PASS] | Production functions are fully annotated; tests use `Any` only in a helper patch signature. |
| Dataclasses for value objects | [✅] [PASS] | `RealFileSystem` remains a focused dataclass wrapper for filesystem behavior. |
| Protocols/ABCs for interfaces | [✅] [PASS] | `FileSystem` stays modeled as a `Protocol`, preserving testability and structural typing. |
| Avoid utility classes | [✅] [PASS] | Helper behavior stays in module-level functions rather than static-only classes. |

### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| Specific exceptions | [✅] [PASS] | `ValueError` and `FileNotFoundError` remain explicit at the CLI boundary. |
| Logging over print | [⚠️] [PARTIAL] | The scripts are CLI-facing and still use `print()` for user-facing warnings/errors. That behavior is acceptable at the entrypoint boundary, but helper-layer warning emission remains a minor review note rather than a merge blocker. |
| Invariants at construction | [✅] [PASS] | Input validation occurs before filesystem mutation and launcher invocation. |

## 4. Python Unit Test Policy Compliance

### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | [✅] [PASS] | All recorded tests use pytest. |
| Coverage expectation | [⚠️] [PARTIAL] | Repo-wide coverage stayed at `83%`, but changed/new-code coverage proof remains missing. |

### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Focused unit tests | [✅] [PASS] | The targeted tests isolate specific launcher behaviors. |
| Mocking sparingly | [✅] [PASS] | Only subprocess/PATH/environment seams and filesystem abstractions are mocked. |
| Organization | [✅] [PASS] | Test files mirror the corresponding `scripts/dev_tools` modules. |

### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| Naming conventions | [✅] [PASS] | Test names are descriptive and scenario-based. |
| Docstrings/comments | [✅] [PASS] | Many tests include short purpose docstrings; the remainder are self-describing by name. |

### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | [✅] [PASS] | Both targeted and full-suite evidence use pytest. |
| No Alternative Test Runners | [✅] [PASS] | No alternative Python test framework appears in the recorded evidence. |

## 5. Test Coverage Detail

### Launcher regression scenarios

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_default_code_launcher_runs_when_code_present` | Positive | [✅] |
| `test_default_code_launcher_prefers_code_insiders_for_insiders_session` | Edge / Environment | [✅] |
| `test_default_code_launcher_returns_false_when_missing` | Negative | [✅] |
| `test_default_code_launcher_uses_code_with_reuse_window` | Positive | [✅] |
| `test_default_code_launcher_returns_false_when_no_cli_is_available` | Negative | [✅] |

**Coverage note:** AC-3 is supported by deterministic red/green evidence, but changed/new-code coverage isolation remains outstanding.

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Targeted Tests | 31 | [✅] |
| Targeted Tests Passed | 31 (100%) | [✅] |
| Initial Targeted Failures | 6 | [✅] Expected red phase |
| Full-Suite Tests Passed | 911 | [✅] |
| Full-Suite Execution Time | 3.22s | [✅] |
| Repo Coverage | 83% | [✅] No regression |
| Changed/New-Code Coverage | Unverified | [⚠️] |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black .` | `172 files left unchanged` | [✅] |
| Ruff Linting | `poetry run ruff check` | `All checks passed!` | [✅] |
| Pyright Type Checking | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` | [✅] |
| Pytest Tests | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | `911 passed`, `83%` | [✅] |

## 8. Gaps and Exceptions

### Identified Gaps

1. **Acceptance Criteria 1 and 2 remain unverified**  
   No live Windows execution artifact demonstrates that `drmCopilotExtension.newPotentialBugEntry` and `drmCopilotExtension.newActiveFeatureFolder` reused the originating IDE window.

2. **Changed/new-code coverage proof is missing**  
   The recorded evidence shows no headline coverage regression but does not isolate the changed launcher paths to prove the ≥90% new-code policy target.

3. **Reviewer branch/diff context was stale at the repo root**  
   `artifacts/pr_context.summary.txt` referenced a different feature branch, so this reduced audit relied on folder-local evidence rather than a fresh branch-aligned PR context artifact.

### Approved Exceptions

**None.** No explicit policy exceptions were documented for this feature.

### Removed/Skipped Tests

**None recorded.** The plan-required red/green targeted launcher tests were implemented and executed.

## 9. Summary of Changes

### Commits / baseline evidence consulted

1. `da3fa594bcb10be67f885c7cc9f49aa1d83653b3` — feature branch/commit recorded in `p0-t3.git-baseline.2026-04-04T12-21.md`

### Files Modified (per implementation summary)

1. `tests/scripts/dev_tools/test_new_potential_bug_entry.py` (MODIFIED)
   - Added targeted launcher regression tests.
   - Supports AC-3 directly.

2. `tests/scripts/dev_tools/test_new_active_feature_folder.py` (MODIFIED)
   - Added targeted launcher regression tests.
   - Supports AC-3 directly.

3. `scripts/dev_tools/new_potential_bug_entry.py` (MODIFIED)
   - Added Insiders-aware CLI selection and `--reuse-window` behavior.

4. `scripts/dev_tools/new_active_feature_folder_io.py` (MODIFIED)
   - Added Insiders-aware CLI selection and `--reuse-window` behavior.

5. `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py` (MODIFIED)
   - Bundled mirror aligned with the root launcher contract.

6. `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py` (MODIFIED)
   - Bundled mirror aligned with the root launcher contract.

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The reduced audit confirms the minor-audit folder integrity, recorded QC loop, and regression testing requirements were met. The branch is **not ready for merge** because two acceptance criteria remain unverified on live Windows and the changed/new-code coverage obligation is still open.

### Policy-by-Policy Summary

- [✅] General code change policy: planning, structure, and final recorded QC loop are present.
- [⚠️] General unit test policy: deterministic red/green evidence exists, but changed/new-code coverage proof is incomplete.
- [✅] Python code change policy: typing and toolchain requirements are satisfied by the recorded evidence.
- [⚠️] Python unit test policy: pytest usage is correct, but coverage closure is incomplete.

### Metrics Summary

- [✅] `31/31` targeted regression tests passed after the fix.
- [✅] `911` full-suite tests passed in the final recorded QC pass.
- [✅] Repo-wide coverage remained at `83%`.
- [⚠️] Changed/new-code coverage remains unverified.
- [⚠️] AC-1 and AC-2 remain unverified pending live Windows evidence.

### Recommendation

**Needs revision**

Minimum actions to reach a PASS-style audit outcome:
1. Record live Windows verification for AC-1 and AC-2 in the active feature folder.
2. Record deterministic changed/new-code coverage evidence or another policy-compliant proof for the affected launcher changes.
3. Refresh the end-state summary after the two gaps above are closed.

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_new_potential_bug_entry.py::test_default_code_launcher_runs_when_code_present`
- `tests/scripts/dev_tools/test_new_potential_bug_entry.py::test_default_code_launcher_prefers_code_insiders_for_insiders_session`
- `tests/scripts/dev_tools/test_new_potential_bug_entry.py::test_default_code_launcher_returns_false_when_missing`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_default_code_launcher_uses_code_with_reuse_window`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_default_code_launcher_prefers_code_insiders_for_insiders_session`
- `tests/scripts/dev_tools/test_new_active_feature_folder.py::test_default_code_launcher_returns_false_when_no_cli_is_available`

## Appendix B: Toolchain Commands Reference

Recorded implementation commands:
- `poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder.py -q`
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

Reviewer-only context command:
- `git rev-parse potential-entry-opening-different-ide`
- `git rev-parse development`
- `git diff --name-status development...potential-entry-opening-different-ide`

**Audit Completed By:** GitHub Copilot  
**Policy Version:** Current as of 2026-04-04

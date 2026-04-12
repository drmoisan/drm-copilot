# Policy Compliance Audit: potential-to-issue-missing-label

**Audit Date:** 2026-04-05  
**Base Branch:** `development`  
**Feature Folder:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`  
**Feature Folder Selection Rule:** User-specified folder matched the active branch suffix `123`; no competing active folder was needed.  
**Code Under Test:** `scripts/dev_tools/potential_to_issue.py`, `tests/scripts/dev_tools/test_potential_to_issue.py`, runtime-path inspection of `extensions/drm-copilot/resources/templates/potential_to_issue.py`, `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`, and `extensions/drm-copilot/src/repo-automation-service.ts`

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 working-tree files | 28 targeted pytest cases | FAIL for feature readiness; targeted QC command passed | 90% file coverage (`p0-t6.pytest-coverage.2026-04-05T13-36.md`) | 90% file coverage (`p2-t4.pytest-coverage.2026-04-05T14-01.md`) | 90% at touched root module; bundled runtime path not covered |
| TypeScript | 0 files changed | N/A | N/A | N/A | N/A | N/A |

## Executive Summary

This minor-audit review used `issue.md` as the sole requirements source, confirmed that `spec.md` and `user-story.md` are absent, and verified that the required Phase 0 artifacts exist. The constrained Python toolchain for the root script and root pytest module passes cleanly. However, the user-facing extension command still launches `extensions/drm-copilot/resources/templates/potential_to_issue.py`, which delegates into `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`. That bundled script does not contain the new missing-label recovery path that was added only to the root `scripts/dev_tools/potential_to_issue.py`, so the primary acceptance criterion is not met for the actual runtime path.

The refreshed PR-context artifacts were required and were regenerated with `development`, but they show an empty committed range because the implementation remains only in the working tree. This audit therefore used the refreshed PR-context artifacts as the primary branch-state evidence and supplemented them with a live working-tree diff against `origin/development` for the actual modified files under review.

**Policy documents evaluated:**
- [PASS] `.github/copilot-instructions.md`
- [PASS] `.github/instructions/general-code-change.instructions.md`
- [PASS] `.github/instructions/general-unit-test.instructions.md`
- [PASS] `.github/instructions/python-code-change.instructions.md`
- [PASS] `.github/instructions/python-unit-test.instructions.md`
- [PASS] `.github/instructions/python-suppressions.instructions.md`
- [PASS] `.github/instructions/self-explanatory-code-commenting.instructions.md`

**Temporary artifacts cleanup:**
- [PASS] No throwaway review scripts were created.
- [FAIL] Acceptance criteria were checked off in `issue.md` before the runtime-path evidence supported them. The review corrected the checklist to match the evidence.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | [PASS] | `tests/scripts/dev_tools/test_potential_to_issue.py` uses in-memory fakes (`FakeFileSystem`, `FakeGhClient`) and no shared external state. |
| Isolation | [PASS] | The new regression tests each exercise one promotion scenario: missing-label recovery and existing-label unchanged path. |
| Fast Execution | [PASS] | Reviewer rerun: `28 passed in 0.10s` for the targeted coverage command. |
| Determinism | [PASS] | Tests use fake gh responses and never call the network, real gh, or temporary files. |
| Readability & Maintainability | [PASS] | Test names are descriptive and follow clear Arrange–Act–Assert structure. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | [PASS] | `evidence/baseline/p0-t6.pytest-coverage.2026-04-05T13-36.md` records `Coverage Total: 90%` and `Coverage File: scripts/dev_tools/potential_to_issue.py = 90%`. |
| No Coverage Regression | [PASS] | `evidence/qa-gates/p2-t5.clean-pass-summary.2026-04-05T14-01.md` records baseline 90% and post-change 90%. |
| New Code Coverage ≥90% | [PARTIAL] | The touched root module remains at 90% coverage, but there is no direct coverage for the bundled runtime module used by the extension. |
| Comprehensive Coverage | [FAIL] | Root regression coverage exists, but no focused test covers `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`, the actual runtime implementation for `drmCopilotExtension.potentialToIssue`. |
| Positive Flows | [PASS] | Existing-label create path covered by `test_promote_potential_feature_existing_label_uses_single_issue_create_attempt`. |
| Negative Flows | [PASS] | Red-run artifact `p1-t3.red-pytest.2026-04-05T13-57.md` captures the pre-fix missing-label failure. |
| Edge Cases | [PASS] | The missing-label recovery branch and the unchanged existing-label branch both have dedicated focused scenarios. |
| Error Handling | [PASS] | Root tests verify auth failure, invalid promotion type, and failed issue creation behavior. |
| Concurrency | [N/A] | The workflow is synchronous and has no concurrent behavior in scope. |
| State Transitions | [PASS] | The tests verify issue creation, metadata update, and file move transitions in memory. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear Failure Messages | [PASS] | The red-run artifact includes the failing assertion and the emitted gh output. |
| Arrange-Act-Assert Pattern | [PASS] | New tests clearly set up fake workspace state, call `promote_potential`, then assert exit code, calls, and move behavior. |
| Document Intent | [PASS] | New test docstrings describe the exact scenario and expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid External Dependencies | [PASS] | Root pytest module uses fake filesystem and fake gh client only. |
| Use Mocks/Stubs | [PASS] | `FakeGhClient` and `FakeFileSystem` isolate all external behavior. |
| Environment Stability | [PASS] | No temp files, network calls, or mutable global configuration are required. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission Review | [PASS] | This audit file records the required policy review for the small-path implementation. |

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | [PASS] | `issue.md` states the missing-label failure for `drmCopilotExtension.potentialToIssue`. |
| Read existing change plans | [PASS] | `plan.2026-04-05T13-30.md` exists and constrains the work to issue-only minor-audit scope. |
| Document the plan | [PASS] | The plan file records Phase 0, implementation, and final QC tasks. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | [PASS] | The root fix is a small retry-on-missing-label branch rather than a broader refactor. |
| Reusability | [PARTIAL] | The logic was added only to the root Python module and not propagated to the bundled extension runtime copy, leaving duplicated behavior out of sync. |
| Extensibility | [PASS] | The recovery path is narrowly scoped to the known feature-label failure. |
| Separation of concerns | [PASS] | The gh client still encapsulates CLI calls separately from orchestration logic. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | [PASS] | The root script and pytest module remain cohesive. |
| Under 500 lines | [FAIL] | `tests/scripts/dev_tools/test_potential_to_issue.py` exceeds the repo’s 500-line policy limit. The review did not introduce that condition, but the touched test file is still over the limit. |
| Public vs internal | [PASS] | Protocols and helper functions are still scoped within the module. |
| No circular dependencies | [PASS] | No circular dependency evidence was found in the reviewed Python path. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | [PASS] | The new root test names and helper names are descriptive. |
| Docs/docstrings | [PASS] | The root script includes docstrings on new public and helper members. |
| Comment why, not what | [PASS] | The root retry branch includes a rationale comment explaining the narrow recovery scope. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | [PASS] | Reviewer command: `poetry run black --check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` -> clean. |
| Linting | [PASS] | Reviewer command: `poetry run ruff check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` -> clean. |
| Type checking | [PASS] | Reviewer command: `poetry run pyright scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` -> clean. |
| Testing | [PASS] | Reviewer command: `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing` -> `28 passed`, 90% file coverage. |
| Full toolchain loop | [PASS] | The targeted small-path reviewer loop passed in a single check-only pass. |
| Explicit reporting | [PASS] | Commands and outputs are documented below and in the feature evidence artifacts. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | [PASS] | The working-tree diff shows 35 added lines in the root script and 114 insertions in the root pytest module. |
| Design choices explained | [PASS] | The root code and tests show a single-retry recovery design. |
| Update supporting documents | [PARTIAL] | The feature docs exist, but the acceptance checklist was marked complete before the runtime-path evidence existed. The review corrected that contradiction. |
| Provide next steps | [PASS] | This audit, code review, feature audit, and remediation inputs document the remaining work. |

## 3. Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Black | [PASS] | Reviewer check-only Black command passed. |
| Linting with Ruff | [PASS] | Reviewer Ruff command passed. |
| Type checking with Pyright | [PASS] | Reviewer Pyright command passed. |
| Testing with Pytest | [PASS] | Targeted pytest with coverage passed. |
| Strong typing | [PASS] | The root change uses typed protocols, dataclasses, and concrete return records; no new `Any` was introduced. |
| Dataclasses for value objects | [PASS] | `GhResult`, `RealGhClient`, `RealFileSystem`, and `PromotionOutcome` remain dataclass-based. |
| Protocols/ABCs for interfaces | [PASS] | `GhClient` and `FileSystem` remain typed protocols. |
| Avoid utility classes | [PASS] | Helpers remain module-level functions. |
| Specific exceptions | [PASS] | The root path uses `PromotionError`, `FileNotFoundError`, and `subprocess.SubprocessError`. |
| Logging over print | [PASS] | The production path uses the existing emitter callback pattern; no ad-hoc debug prints were added. |
| Invariants at construction | [PASS] | `RealGhClient.__post_init__` enforces gh path resolution. |

## 4. Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | [PASS] | All reviewed tests are in `tests/scripts/dev_tools/test_potential_to_issue.py`. |
| Coverage expectation | [PARTIAL] | Root-module coverage is 90%, but coverage does not extend to the bundled extension runtime module that actually serves the command path. |
| Focused unit tests | [PASS] | Both added regression tests target single behaviors. |
| Mocking sparingly | [PASS] | Fakes are limited to gh and filesystem boundaries. |
| Organization | [PASS] | Tests live in the mirrored `tests/scripts/dev_tools/` location for the root module. |
| Naming conventions | [PASS] | Names describe exact scenario and expectation. |
| Docstrings/comments | [PASS] | Scenario docstrings are present. |
| No alternative test runners | [PASS] | Only Pytest evidence was used for the Python review path. |

## 5. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PR context refresh | `poetry run python -m scripts.dev_tools.pr_context.collector --base development` | Completed; refreshed canonical artifacts, but committed range remained empty because the change is still only in the working tree | PASS |
| Working-tree diff | `git diff --stat origin/development -- scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py docs/features/active/2026-04-05-potential-to-issue-missing-label-123` | 2 files changed in code under test; feature folder is untracked | PASS |
| Black | `poetry run black --check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` | No formatting changes required | PASS |
| Ruff | `poetry run ruff check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` | No diagnostics | PASS |
| Pyright | `poetry run pyright scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` | `0 errors, 0 warnings, 0 informations` | PASS |
| Pytest | `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing` | `28 passed in 0.10s`, 90% file coverage | PASS |

## 6. Gaps and Exceptions

### Identified Gaps

1. The actual extension runtime path remains unfixed because `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` still exits immediately on missing-label failures.
2. The review had to correct the `issue.md` acceptance checklist because two items were checked before supporting runtime-path evidence existed.
3. The refreshed PR-context artifacts cannot express the implementation scope as a branch diff yet because the code and feature-folder changes are not committed.

### Approved Exceptions

None.

### Removed/Skipped Tests

None by the reviewer. No reviewer test was skipped.

## 7. Summary of Changes Under Review

### Working-tree code changes

1. `scripts/dev_tools/potential_to_issue.py` (MODIFIED)
   - Adds `ensure_label`, feature-label constants, missing-label detection, and a single retry path.
2. `tests/scripts/dev_tools/test_potential_to_issue.py` (MODIFIED)
   - Adds root-path regression tests for missing-label recovery and existing-label behavior.

### Runtime-path files inspected

1. `extensions/drm-copilot/src/repo-automation-service.ts`
   - Confirms the extension launches `resources/templates/potential_to_issue.py`.
2. `extensions/drm-copilot/resources/templates/potential_to_issue.py`
   - Confirms the wrapper imports bundled `dev_tools.potential_to_issue`.
3. `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`
   - Confirms the bundled runtime script does not include the new recovery branch.

## 8. Compliance Verdict

### Overall Status: NON-COMPLIANT

The minor-audit prerequisites were met: `issue.md` is the sole requirements source, `spec.md` and `user-story.md` are absent, and the required Phase 0 artifacts exist. The targeted root Python QC loop is clean. The review is still blocked because the implementation does not satisfy the actual extension runtime path described in `issue.md`, and the acceptance checklist had been prematurely marked complete.

### Policy-by-Policy Summary

- General Code Change Policy: PARTIAL
  - Toolchain execution passed, but runtime-path duplication and premature checklist checkoff violate the intended delivery workflow.
- Python Code Change Policy: PARTIAL
  - The root script is clean and typed, but the duplicated bundled runtime implementation is inconsistent.
- General Unit Test Policy: PARTIAL
  - Root tests are deterministic and fast, but runtime-path coverage is incomplete.
- Python Unit Test Policy: PARTIAL
  - Pytest usage is correct, but coverage does not reach the extension-bundled module that actually implements the command.

### Recommendation

**Blocked**

Before this work is ready for PR/merge, the missing-label recovery logic must be applied to the extension-bundled runtime script that the command actually executes, focused runtime-path regression coverage must be added or updated, and the acceptance evidence/checklist must be regenerated from that true runtime path.

## Appendix A: Toolchain Commands Reference

- `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
- `git diff --stat origin/development -- scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py docs/features/active/2026-04-05-potential-to-issue-missing-label-123`
- `git diff --name-status origin/development -- scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py docs/features/active/2026-04-05-potential-to-issue-missing-label-123`
- `poetry run black --check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`
- `poetry run ruff check scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`
- `poetry run pyright scripts/dev_tools/potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`
- `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing`

**Audit Completed By:** GitHub Copilot  
**Policy Version:** Current as of 2026-04-05

# Policy Compliance Audit: potential-to-issue-missing-label

**Audit Date:** 2026-04-05  
**Base Branch:** `development`  
**Feature Folder:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`  
**Feature Folder Selection Rule:** User-specified folder; it matches issue `#123` and the active branch suffix.  
**Requirements Source of Truth:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md` only (`- Work Mode: minor-audit`)  
**Required Absence Re-checked:** `spec.md` absent; `user-story.md` absent  
**Code Under Review:** `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`, `tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`, plus companion verification of `extensions/drm-copilot/resources/templates/potential_to_issue.py`, `extensions/drm-copilot/src/repo-automation-service.ts`, `scripts/dev_tools/potential_to_issue.py`, and `tests/scripts/dev_tools/test_potential_to_issue.py`

## Coverage Metrics by Language

| Language | Files Inspected | Tests Rerun | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|-----------------|-------------|-------------|-------------------|----------------------|-------------------|
| Python | 4 changed Python files in the working tree; remediation focus on bundled runtime + bundled runtime tests | 34 targeted pytest cases across 2 modules | Behavior checks passed; policy coverage target failed for bundled runtime path | Root baseline: 90% (`evidence/baseline/p0-t6.pytest-coverage.2026-04-05T13-36.md`) | Root companion: 90%; bundled runtime: 65% | 65% for `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` |

## Executive Summary

This remediation re-audit followed the `minor-audit` contract and used `issue.md` as the sole requirements source. The explicit `## Acceptance Criteria` section remains present and all three criteria are now supported by bundled-runtime evidence under the feature folder. The required Phase 0 artifacts still exist, and `spec.md` plus `user-story.md` remain absent.

The actual extension command path is now correct: `extensions/drm-copilot/src/repo-automation-service.ts` still dispatches `resources/templates/potential_to_issue.py`, the wrapper still delegates to bundled `dev_tools.potential_to_issue`, and the bundled runtime now contains the missing-label recovery branch. Fresh Black, Ruff, Pyright, and targeted pytest reruns passed on the changed Python files.

The remaining blocking gap is policy coverage depth. The bundled-runtime pytest module passes, but the focused coverage result for `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` is only 65%, below the repository requirement that new or modified code target at least 90% coverage.

**Policy documents evaluated:**
- [PASS] `.github/copilot-instructions.md`
- [PASS] `.github/instructions/general-code-change.instructions.md`
- [PASS] `.github/instructions/general-unit-test.instructions.md`
- [PASS] `.github/instructions/python-code-change.instructions.md`
- [PASS] `.github/instructions/python-unit-test.instructions.md`
- [PASS] `.github/instructions/python-suppressions.instructions.md`
- [PASS] `.github/instructions/self-explanatory-code-commenting.instructions.md`

**Phase 0 artifact existence check:**
- [PASS] `evidence/baseline/phase0-instructions-read.md`
- [PASS] `evidence/baseline/p0-t2.requirements-scope.2026-04-05T13-36.md`
- [PASS] `evidence/baseline/p0-t3.black-check.2026-04-05T13-36.md`
- [PASS] `evidence/baseline/p0-t4.ruff.2026-04-05T13-36.md`
- [PASS] `evidence/baseline/p0-t5.pyright.2026-04-05T13-36.md`
- [PASS] `evidence/baseline/p0-t6.pytest-coverage.2026-04-05T13-36.md`
- [PASS] `evidence/baseline/p0-t7.small-path-scope.2026-04-05T13-36.md`

**Temporary artifacts cleanup:**
- [PASS] No throwaway review scripts were created.

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | [PASS] | Both pytest modules use in-memory fakes only (`FakeFileSystem`, `FakeGhClient`) and do not share mutable external state. |
| Isolation | [PASS] | The bundled-runtime remediation tests each target one promotion behavior: missing-label recovery and existing-label single-create behavior. |
| Fast Execution | [PASS] | Fresh reruns: bundled runtime `6 passed in 0.06s`; root companion `28 passed in 0.10s`. |
| Determinism | [PASS] | No network, no real `gh`, and no temporary files are used. |
| Readability & Maintainability | [PASS] | Test names are descriptive and follow Arrange–Act–Assert structure. |
| Baseline Coverage Documented | [PASS] | Phase 0 artifact `p0-t6.pytest-coverage.2026-04-05T13-36.md` records the original root baseline. |
| No Coverage Regression | [PASS] | Root companion path remains at 90%; the remediation introduced separate bundled-runtime evidence without reducing the original measured root baseline. |
| New Code Coverage ≥90% | [FAIL] | Fresh command `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=dev_tools.potential_to_issue --cov-report=term-missing` reported `65%` coverage for the bundled runtime module. |
| Comprehensive Coverage | [PARTIAL] | The bundled runtime now has direct red/green and green regression evidence, but many branches remain uncovered (fresh missing-line report shows 70 missed statements). |
| Positive Flows | [PASS] | Existing-label path passes in both the saved green remediation artifact and the fresh bundled-runtime rerun. |
| Negative Flows | [PASS] | Saved red artifact `evidence/regression-testing/remediation.red-bundled-runtime-pytest.2026-04-05T14-15.md` proves the pre-fix failure. |
| Edge Cases | [PASS] | The known missing-label branch is explicitly covered by dedicated runtime-path tests. |
| Error Handling | [PASS] | Fresh coverage output and existing tests continue to cover invalid inputs and failed command paths on the root companion module. |
| Concurrency | [N/A] | No concurrent behavior is in scope. |
| State Transitions | [PASS] | Tests verify issue creation, metadata update, and move-to-promoted-folder behavior. |
| Clear Failure Messages | [PASS] | The red remediation artifact contains the failing assertion and emitted gh output. |
| Arrange-Act-Assert Pattern | [PASS] | Both bundled-runtime remediation tests keep setup, invocation, and assertions separate. |
| Document Intent | [PASS] | Test docstrings describe the exact scenario and expected outcome. |
| Avoid External Dependencies | [PASS] | Tests are fully isolated from external services and processes. |
| Use Mocks/Stubs | [PASS] | Only gh and filesystem boundaries are faked. |
| Environment Stability | [PASS] | No temp-file exception is needed; all data is in memory. |
| Pre-submission Review | [PASS] | This artifact documents the required policy review. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | [PASS] | `issue.md` defines the missing-label failure on `drmCopilotExtension.potentialToIssue`. |
| Read existing change plans | [PASS] | `plan.2026-04-05T13-30.md` and `remediation-plan.2026-04-05T14-05.md` were reviewed. |
| Document the plan | [PASS] | The feature folder contains the original plan and remediation plan. |
| Simplicity first | [PASS] | The remediation mirrors the existing root fix into the bundled runtime rather than widening scope. |
| Reusability | [PARTIAL] | The branch still maintains both a root implementation and a bundled runtime copy, which keeps duplication risk in place. |
| Extensibility | [PASS] | The recovery branch remains narrowly scoped to the known missing `feature` label failure. |
| Separation of concerns | [PASS] | The wrapper remains thin, the service still dispatches the bundled script, and CLI orchestration stays separate from gh client behavior. |
| Cohesive modules | [PASS] | The bundled runtime, wrapper, and bundled test module remain focused on promotion behavior. |
| Under 500 lines | [PASS] | Re-audited remediation files are under 500 lines: bundled runtime `422`, bundled pytest module `410`. |
| Public vs internal | [PASS] | Protocols and helpers remain module-local; no new public surface was added outside the runtime module contract. |
| No circular dependencies | [PASS] | No circular dependency evidence was found in the reviewed remediation path. |
| Descriptive names | [PASS] | `ensure_label`, `_is_missing_label_failure`, and the bundled-runtime test names are descriptive. |
| Docs/docstrings | [PASS] | The bundled runtime and tests include docstrings for new and existing helpers used in the remediation path. |
| Comment why, not what | [PASS] | The recovery branch comment explains why only the known failure is retried. |
| 1. Formatting | [PASS] | Fresh command: `poetry run black --check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` -> clean. |
| 2. Linting | [PASS] | Fresh command: `poetry run ruff check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` -> clean. |
| 3. Type checking | [PASS] | Fresh command: `poetry run pyright extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` -> `0 errors, 0 warnings, 0 informations`. |
| 4. Testing | [FAIL] | The fresh bundled-runtime pytest command passes behaviorally but records 65% coverage for the changed bundled runtime module, below policy. |
| Full toolchain loop | [FAIL] | The loop completed with clean format/lint/type-check results, but the test stage did not satisfy the coverage requirement for modified code. |
| Explicit reporting | [PASS] | All commands and outputs are recorded in this audit. |
| Summarize changes | [PASS] | This audit and the code review summarize the mirrored bundled-runtime remediation. |
| Design choices explained | [PASS] | The re-audit documents the bundled runtime delta and the remaining policy gap. |
| Update supporting documents | [PASS] | The feature folder contains updated remediation evidence and this fresh review set. |
| Provide next steps | [PASS] | This audit and the remediation follow-up files document the remaining work. |

## 3. Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Black | [PASS] | Fresh Black check passed on the four changed Python files. |
| Linting with Ruff | [PASS] | Fresh Ruff check passed on the same scope. |
| Type checking with Pyright | [PASS] | Fresh Pyright check passed on the same scope. |
| Testing with Pytest | [FAIL] | Behavior passed, but bundled-runtime coverage is 65%, not >=90%. |
| Strong typing | [PASS] | No new `Any` or type weakening was introduced. |
| Dataclasses for value objects | [PASS] | `GhResult`, `RealGhClient`, `RealFileSystem`, and `PromotionOutcome` remain dataclass-based. |
| Protocols/ABCs for interfaces | [PASS] | `GhClient` and `FileSystem` remain typed protocols in both implementations. |
| Avoid utility classes | [PASS] | Logic remains in module functions and domain-oriented dataclasses. |
| Specific exceptions | [PASS] | Explicit boundary exceptions remain in use. |
| Logging over print | [PASS] | The runtime continues using the emitter callback pattern rather than new debug prints. |
| Invariants at construction | [PASS] | `RealGhClient.__post_init__` still validates `gh` availability. |

## 4. Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | [PASS] | All verification used pytest only. |
| Coverage expectation | [FAIL] | Fresh bundled-runtime coverage is 65% for the changed runtime module. |
| Focused unit tests | [PASS] | The two bundled-runtime remediation tests each assert one runtime behavior. |
| Mocking sparingly | [PASS] | Fakes remain limited to the gh client and filesystem boundaries. |
| Organization | [PASS] | The bundled tests mirror the bundled template/runtime area under `tests/extensions/drm_copilot/resources/templates/`. |
| Naming conventions | [PASS] | Test names describe the scenario and expected outcome directly. |
| Docstrings/comments | [PASS] | Scenario docstrings are present. |
| No alternative test runners | [PASS] | No non-pytest runner was used. |

## 5. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PR context refresh | `poetry run python -m scripts.dev_tools.pr_context.collector --base development` | Refreshed canonical artifacts successfully; committed range remains empty because branch changes are still in the working tree | PASS |
| Requirements-state check | `issue.md` + file existence inspection | `minor-audit` marker present; explicit `## Acceptance Criteria` section present; `spec.md` and `user-story.md` absent | PASS |
| Black | `poetry run black --check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` | `4 files would be left unchanged` | PASS |
| Ruff | `poetry run ruff check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` | `All checks passed!` | PASS |
| Pyright | `poetry run pyright extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py` | `0 errors, 0 warnings, 0 informations` | PASS |
| Bundled-runtime pytest | `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=dev_tools.potential_to_issue --cov-report=term-missing` | `6 passed in 0.06s`; coverage `65%` for bundled runtime module | FAIL |
| Root companion pytest | `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing` | `28 passed in 0.10s`; coverage `90%` for root module | PASS |

## 6. Gaps and Exceptions

### Identified Gaps

1. The bundled runtime now behaves correctly, but its focused coverage remains at 65%, below the repository’s 90% target for modified code.
2. The branch still carries two Python implementations of the promotion workflow (root and bundled runtime), so future drift remains a maintenance risk.
3. The canonical PR-context diff is still empty until the working-tree changes are committed.

### Approved Exceptions

None.

### Removed/Skipped Tests

None.

## 7. Summary of Changes Under Review

### Remediation files

1. `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` (MODIFIED)
   - Mirrors the missing-label recovery behavior into the actual bundled runtime used by the extension.
2. `tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py` (MODIFIED)
   - Adds bundled-runtime coverage for the missing-label recovery and existing-label pass-through scenarios.

### Companion files rechecked

1. `extensions/drm-copilot/resources/templates/potential_to_issue.py`
   - Wrapper still delegates to the bundled runtime only.
2. `extensions/drm-copilot/src/repo-automation-service.ts`
   - Service still dispatches `resources/templates/potential_to_issue.py` for `potentialToIssue`.
3. `scripts/dev_tools/potential_to_issue.py`
   - Root companion implementation remains aligned with the bundled runtime fix.
4. `tests/scripts/dev_tools/test_potential_to_issue.py`
   - Root companion tests remain green at 90% focused coverage.

## 8. Compliance Verdict

### Overall Status: NON-COMPLIANT

The minor-audit requirements are now satisfied functionally: the issue-only acceptance criteria are supported by bundled-runtime evidence, the required baseline artifacts remain present, and the actual runtime path passes its targeted behavior checks. The branch is still not ready for merge because the changed bundled runtime module does not yet meet the repository’s required coverage threshold for modified code.

### Policy-by-Policy Summary

- General Code Change Policy: PARTIAL  
  Clean format/lint/type-check passes, but the testing gate remains open because bundled-runtime coverage is below policy.
- Python Code Change Policy: PARTIAL  
  Strong typing and narrow logic are intact, but the test/coverage obligation for changed code is not yet met.
- General Unit Test Policy: PARTIAL  
  Tests are deterministic, isolated, and fast, but comprehensive coverage remains insufficient on the changed bundled runtime path.
- Python Unit Test Policy: PARTIAL  
  Pytest structure is correct, but the changed module is only 65% covered.

### Recommendation

**Needs revision**

Before this branch is ready to open or merge a PR into `development`, increase focused bundled-runtime coverage for `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` to at least 90%, then rerun the focused Python QC loop and refresh the audit artifacts.

## Appendix A: Toolchain Commands Reference

- `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
- `poetry run black --check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`
- `poetry run ruff check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`
- `poetry run pyright extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue.py`
- `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=dev_tools.potential_to_issue --cov-report=term-missing`
- `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing`

**Audit Completed By:** GitHub Copilot  
**Policy Version:** Current as of 2026-04-05

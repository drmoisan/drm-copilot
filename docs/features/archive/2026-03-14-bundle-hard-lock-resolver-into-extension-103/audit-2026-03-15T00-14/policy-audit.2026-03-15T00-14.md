# Policy Compliance Audit: bundle-hard-lock-resolver-into-extension (#103)

**Audit Date:** 2026-03-15  
**Base Branch:** development  
**Feature Folder:** `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/`  
**Feature Folder Selection Rule:** Used the user-specified active feature folder, which matches the issue-number suffix (`-103`) and contains the primary scoping docs (`issue.md`, `spec.md`, `user-story.md`).  
**PR Context Assumption:** `artifacts/pr_context.summary.txt` was refreshed against `development`, but because the feature currently exists as working-tree changes rather than committed branch delta, the summary range was empty. This audit therefore uses the refreshed PR context appendix working-tree diff plus live workspace inspection as authoritative scope evidence.

**Code Under Test:**
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/README.md`
- `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py`
- `extensions/drm-copilot/resources/customizations/.github/codex/execute-hard-lock.prompt.md`
- `extensions/drm-copilot/resources/customizations/.github/codex/resume-hard-lock.prompt.md`
- `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`
- `scripts/dev_tools/resolve_hard_lock_prompt.py`
- `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`
- `tests/scripts/dev_tools/test_resolve_hard_lock_prompt_part2.py`
- `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py`
- `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/*.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 6 files | 38 tests | [✅] 898 passed in repo suite | 83% total; 97% `scripts/dev_tools/resolve_hard_lock_prompt.py` | 83% total; 97% root bundled resolver; 100% wrapper | 92% |
| TypeScript | 2 files | 6 tests | [✅] 80/80 passed in extension suite | 89.3% total; 90.48% `src/extension.ts` | 89.83% total; 91.34% `src/extension.ts` | 91.34% |
| JSON | 1 file | N/A | [✅] validation passed | N/A | N/A | N/A |

## Executive Summary

Most repository policies were met: the Python and extension toolchain loops both passed cleanly, coverage thresholds were met without regression, and the feature docs provide clear scope and acceptance criteria. However, the bundled wrapper `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` masks resolver failures by always exiting with code `0`, which violates the feature's clear-failure requirement and makes the extension capable of reporting success on missing-target/template failures. A second policy violation exists because the new Python test file `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` is 536 lines long, exceeding the repo-wide 500-line file limit that explicitly applies to test code.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`
- [✅] `python-code-change.instructions.md`
- [✅] `python-unit-test.instructions.md`
- [✅] `typescript-code-change.instructions.md`
- [✅] `typescript-unit-test.instructions.md`

**Temporary artifacts cleanup:**
- [✅] No temporary one-off scripts were introduced in the feature implementation.
- [✅] New ongoing tooling artifacts are bundled resources and tests, all checked via the Python/TypeScript loops.
- Evidence artifacts under `evidence/` are intentional review records, not throwaway scripts.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | [✅] [PASS] | New Python tests use `tmp_path`/`mem_path`, patching, and isolated module loads; TypeScript tests reset mocks and command handler state in `beforeEach` / `afterEach`. |
| Isolation | [✅] [PASS] | Python tests target wrapper injection, template lookup, clipboard fallbacks, and resolver error branches individually. TypeScript tests target command registration, picker behavior, argv wiring, and missing-runtime behavior one case at a time. |
| Fast Execution | [✅] [PASS] | Current audit run: repo `pytest` completed 898 tests in 1.73s; extension Jest completed 80 tests in 0.523s. |
| Determinism | [✅] [PASS] | Tests rely on local fixtures, mocks, and in-memory state only; no network access or temp-file creation outside pytest-managed fixtures. |
| Readability & Maintainability | [⚠️] [PARTIAL] | Test names are descriptive, but `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` reached 536 lines, reducing maintainability and violating the file-size rule. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | [✅] [PASS] | Baseline artifacts exist under `evidence/baseline/`; coverage deltas cite baseline Python pytest and extension Jest artifacts. |
| No Coverage Regression | [✅] [PASS] | Python delta artifact reports 83% → 83% total coverage, no regression; TypeScript delta artifact reports 89.3% → 89.83%, no regression. |
| New Code Coverage ≥90% | [✅] [PASS] | `python-coverage-delta.2026-03-15T00-08-39.md` reports 92% new/changed Python coverage; `extension-coverage-delta.2026-03-15T00-12-56.md` reports 91.34% new/changed TypeScript coverage. |
| Comprehensive Coverage | [⚠️] [PARTIAL] | Unit tests cover most branches, but they do not assert the bundled wrapper propagates non-zero process exit codes, which allowed a real failure-path defect to pass the suite. |
| Positive / Negative / Edge / Error Scenarios | [✅] [PASS] | Coverage includes template-root preference/fallback, Windows path normalization, versioned folder lookup, clipboard success/failure, missing target, missing runtime, and missing template lookup. |
| Concurrency | [N/A] [N/A] | No concurrent behavior introduced by this feature. |
| State Transitions | [N/A] [N/A] | No stateful workflow object was added. |

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear Failure Messages | [✅] [PASS] | Assertions check specific stderr/stdout substrings such as `Target file not found`, `Checked locations`, and runtime error text. |
| Arrange-Act-Assert Pattern | [✅] [PASS] | Both Python and TypeScript test files consistently set up mocks/fixtures, invoke the subject, then assert outputs/calls. |
| Document Intent | [✅] [PASS] | Test names and docstrings clearly describe scenarios like explicit template-root preservation and missing runtime behavior. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid External Dependencies | [✅] [PASS] | Tests do not call live services; subprocesses are mocked in TypeScript and wrapper tests patch file/runtime boundaries. |
| Use Mocks/Stubs | [✅] [PASS] | `patch`, `MagicMock`, Jest spies, mocked `vscode`, mocked `node:child_process`, and mocked filesystem checks isolate runtime edges. |
| Environment Stability | [✅] [PASS] | No mutable global state leaks across cases beyond test-local setup/reset; no prohibited ad-hoc temporary files are created. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission Review | [✅] [PASS] | This artifact documents the required review and records both passing gates and remaining policy gaps. |

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | [✅] [PASS] | `issue.md`, `spec.md`, and `user-story.md` clearly define the extension command, bundled-wrapper model, and source-of-truth constraints. |
| Read existing change plans | [✅] [PASS] | The feature folder contains `plan.2026-03-14T22-49.md` plus evidence of Phase 0 policy reading. |
| Document the plan | [✅] [PASS] | The active feature folder includes scoping docs and plan artifacts aligned to issue #103. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | [✅] [PASS] | The extension remains a thin launcher and the wrapper remains a thin Python adapter; core prompt logic stays in the resolver module. |
| Reusability | [✅] [PASS] | Root resolver logic is mirrored into bundled resources instead of reimplemented in TypeScript. |
| Extensibility | [✅] [PASS] | The new `--template-root` seam supports future bundled template sources while remaining backward compatible. |
| Separation of concerns | [⚠️] [PARTIAL] | High-level layering is good, but the wrapper currently breaks command-runtime error propagation by discarding the bundled resolver's exit code. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | [✅] [PASS] | Each modified file has a focused responsibility: command registration, wrapper bootstrapping, resolver logic, or targeted tests. |
| Under 500 lines | [❌] [FAIL] | `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` is 536 lines. Repo policy explicitly applies the 500-line cap to test files. |
| Public vs internal | [✅] [PASS] | New helpers remain internal module functions; no unnecessary public API expansion occurred. |
| No circular dependencies | [✅] [PASS] | The wrapper imports the bundled resolver one-way; TypeScript command wiring remains acyclic. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | [✅] [PASS] | Symbols such as `getActiveFeaturePlanPath`, `promptForActiveFeaturePlan`, and `_resolve_template_path` are descriptive and purpose-specific. |
| Docs/docstrings | [✅] [PASS] | The new Python wrapper and resolver helpers include strong docstrings; README documents the new command. |
| Comment why, not what | [✅] [PASS] | Comments explain ordering and runtime-probing rationale rather than restating syntax. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | [✅] [PASS] | Python: `poetry run black --check .` → 169 files unchanged. TypeScript: `npm --prefix extensions/drm-copilot run format -- --check` → all matched files use Prettier style. |
| Linting | [✅] [PASS] | Python: `poetry run ruff check` → all checks passed. TypeScript: `npm --prefix extensions/drm-copilot run lint` → clean. |
| Type checking | [✅] [PASS] | Python: `poetry run pyright` → 0 errors, 0 warnings, 0 informations. TypeScript: `npm --prefix extensions/drm-copilot run typecheck` → clean. |
| Testing | [✅] [PASS] | Python: `poetry run pytest` → 898 passed. TypeScript: `npm --prefix extensions/drm-copilot run test:unit` → 6 suites, 80 tests passed. JSON: `python -m scripts.dev_tools.validate_json` → exit code 0. |
| Full toolchain loop | [✅] [PASS] | All check-only steps passed in a single final pass for both Python and extension-local TypeScript loops. |
| Explicit reporting | [✅] [PASS] | Exact commands and outcomes are recorded in this audit and Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | [✅] [PASS] | Docs, manifest, extension command wiring, bundled resources, and tests were all updated within the feature folder and extension package. |
| Design choices explained | [✅] [PASS] | `spec.md` and `user-story.md` explain the wrapper-plus-bundled-script approach and source-of-truth rationale. |
| Update supporting documents | [✅] [PASS] | `extensions/drm-copilot/README.md` documents the new command; active feature docs are present. |
| Provide next steps | [⚠️] [PARTIAL] | Remediation is required before PR readiness; see remediation artifacts for exact steps. |

## 3. Language-Specific Code Change Policy Compliance

### 3A. Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Black | [✅] [PASS] | `poetry run black --check .` passed. |
| Linting with Ruff | [✅] [PASS] | `poetry run ruff check` passed. |
| Type checking with Pyright | [✅] [PASS] | `poetry run pyright` passed cleanly. |
| Testing with Pytest | [✅] [PASS] | `poetry run pytest` passed with 898 tests. |
| Strong typing | [⚠️] [PARTIAL] | Most new Python is well typed, but the wrapper casts `module.main` to `Callable[[], None]` and then unconditionally returns `0`, which mismatches the bundled resolver's `main() -> int` contract. |
| Dataclasses / value objects | [N/A] [N/A] | No value-object dataclasses were introduced. |
| Protocols/ABCs | [N/A] [N/A] | No new polymorphic domain interface was needed. |
| Avoid utility classes | [✅] [PASS] | All Python changes use modules/functions, not static-only classes. |
| Specific exceptions | [✅] [PASS] | The resolver reports explicit file/template errors and uses targeted `except ImportError` / `except OSError` / `except subprocess.CalledProcessError` handling. |
| Logging over print | [✅] [PASS] | CLI stdout/stderr are part of the user-facing contract rather than ad-hoc application logging. |
| Invariants at construction | [N/A] [N/A] | No new stateful class constructors were added. |

### 3B. TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Prettier | [✅] [PASS] | `npm --prefix extensions/drm-copilot run format -- --check` passed. |
| Linting with ESLint | [✅] [PASS] | `npm --prefix extensions/drm-copilot run lint` passed. |
| Type checking with TSC | [✅] [PASS] | `npm --prefix extensions/drm-copilot run typecheck` passed. |
| Testing with Jest | [✅] [PASS] | `npm --prefix extensions/drm-copilot run test:unit` passed. |
| Strong typing | [✅] [PASS] | The new command wiring uses explicit types and existing runtime APIs without introducing `any`. |
| Avoid cleverness | [✅] [PASS] | The new code uses small helpers and early returns. |
| Separation of concerns | [✅] [PASS] | TypeScript remains a thin command launcher; resolver logic stays in Python. |
| Error handling / logging | [⚠️] [PARTIAL] | TypeScript command-runtime correctly treats non-zero exits as failures, but the feature still fails end-to-end because the bundled wrapper always exits zero. |

### 3C. JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| JSON validation | [✅] [PASS] | `python -m scripts.dev_tools.validate_json` exited with `0`. |
| Strict JSON only | [✅] [PASS] | `extensions/drm-copilot/package.json` remains strict JSON. |
| Deterministic structure | [✅] [PASS] | Manifest command contribution is structurally consistent and formatter-clean. |

## 4. Language-Specific Unit Test Policy Compliance

### 4A. Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | [✅] [PASS] | All new Python tests are pytest-based. |
| Coverage expectation | [✅] [PASS] | New Python code coverage is 92% and total coverage remains above the 80% threshold. |
| Focused unit tests | [✅] [PASS] | Tests isolate wrapper injection, resolver lookup, mode resolution, and error branches. |
| Mocking sparingly | [✅] [PASS] | Only runtime boundaries (`sys.argv`, clipboard, imports, file reads) are mocked. |
| Organization | [⚠️] [PARTIAL] | Test structure mirrors the code under test, but one new test module exceeded the file-size limit and should be split. |
| Naming conventions | [✅] [PASS] | Test names are descriptive and scenario-specific. |
| Docstrings/comments | [✅] [PASS] | New Python tests include concise docstrings. |
| Use Pytest in toolchain | [✅] [PASS] | `poetry run pytest` was used; no alternate runner introduced. |

### 4B. TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Jest | [✅] [PASS] | The extension test file uses Jest and passed under `npm --prefix extensions/drm-copilot run test:unit`. |
| Focused unit tests | [✅] [PASS] | Tests isolate command registration, picker flow, argv wiring, and missing-runtime handling. |
| Mocking / isolation | [✅] [PASS] | `vscode`, child processes, and filesystem checks are mocked locally. |
| Naming and readability | [✅] [PASS] | `it(...)` names clearly state the expected behavior. |
| Coverage completeness | [⚠️] [PARTIAL] | The suite does not cover wrapper subprocess failure propagation, leaving a correctness hole in the end-to-end error path. |

## 5. Test Coverage Detail

### `scripts/dev_tools/resolve_hard_lock_prompt.py` + bundled mirror

- Covered scenarios: template-root precedence, workspace fallback, missing template reporting, missing target reporting, resume template selection, versioned-folder work-mode lookup, clipboard fallback behavior.
- Evidence: `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py`, `tests/scripts/dev_tools/test_resolve_hard_lock_prompt_part2.py`, `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py`.
- Coverage artifacts: Python delta file reports 97% coverage for both root and bundled resolver copies and 100% for the wrapper.
- Remaining gap: wrapper process exit propagation is not asserted end-to-end.

### `extensions/drm-copilot/src/extension.ts`

- Covered scenarios: command registration, active editor reuse, picker fallback, argv wiring, cancel flow, missing Python runtime.
- Evidence: `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`.
- Coverage artifact: TypeScript delta file reports 91.34% coverage for `src/extension.ts`.

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total repo pytest tests | 898 | [✅] |
| Extension Jest tests | 80 | [✅] |
| Python tests added/updated for this feature | 38 | [✅] |
| TypeScript tests added/updated for this feature | 6 | [✅] |
| Repo pytest execution time | 1.73s | [✅] Fast |
| Extension Jest execution time | 0.523s | [✅] Fast |
| Largest changed production file | `extensions/drm-copilot/src/extension.ts` = 439 lines | [✅] |
| Largest changed test file | `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` = 536 lines | [❌] |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Python Black | `poetry run black --check .` | 169 files would be left unchanged | [✅] |
| Python Ruff | `poetry run ruff check` | All checks passed | [✅] |
| Python Pyright | `poetry run pyright` | 0 errors, 0 warnings, 0 informations | [✅] |
| Python Pytest | `poetry run pytest` | 898 passed in 1.73s | [✅] |
| Extension Prettier | `npm --prefix extensions/drm-copilot run format -- --check` | All matched files use Prettier code style | [✅] |
| Extension ESLint | `npm --prefix extensions/drm-copilot run lint` | Passed cleanly | [✅] |
| Extension TSC | `npm --prefix extensions/drm-copilot run typecheck` | Passed cleanly | [✅] |
| Extension Jest | `npm --prefix extensions/drm-copilot run test:unit` | 6 suites, 80 tests passed | [✅] |
| JSON validation | `python -m scripts.dev_tools.validate_json` | Exit code 0 | [✅] |
| Wrapper failure probe | `python extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py --target <missing> --workspace <feature-folder>` | Printed target-not-found error but exited with `WRAPPER_EXIT=0` | [❌] |

## 8. Gaps and Exceptions

### Identified Gaps

1. **Bundled wrapper failure propagation** — `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` ignores the bundled resolver's integer return value and always exits `0`, violating the clear-failure contract.
2. **Oversized test module** — `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` is 536 lines, exceeding the repo's 500-line cap for test files.
3. **Missing regression for process exit status** — current tests validate stderr content but not wrapper subprocess exit propagation, which allowed the blocker defect through.

### Approved Exceptions

**None.** No policy exceptions were documented or approved.

### Removed/Skipped Tests

**None recorded.** The gap is missing coverage of wrapper exit propagation, not an explicitly skipped documented test.

## 9. Summary of Changes

### Commits in This Branch

No committed delta exists relative to `development` in the refreshed PR context. The reviewed feature exists as working-tree modifications and untracked files captured in `artifacts/pr_context.appendix.txt`.

### Files Modified / Added

- `extensions/drm-copilot/src/extension.ts` — new command wiring and active-plan selection helpers.
- `extensions/drm-copilot/package.json` — command contribution for `drmCopilotExtension.resolveExecuteHardLockPrompt`.
- `extensions/drm-copilot/README.md` — user-facing command documentation.
- `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` — bundled wrapper entrypoint.
- `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` — bundled resolver mirror.
- `extensions/drm-copilot/resources/customizations/.github/codex/*.prompt.md` — bundled prompt templates.
- `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts` — extension command tests.
- `scripts/dev_tools/resolve_hard_lock_prompt.py` — root resolver `--template-root` seam.
- `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py` and `...part2.py` — root resolver tests.
- `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py` — bundled wrapper/resolver tests.
- Feature docs and evidence files under `docs/features/active/2026-03-14-bundle-hard-lock-resolver-into-extension-103/`.

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The branch is close, but not compliant enough for PR readiness. Toolchain and coverage gates pass, yet the bundled wrapper masks failure exit codes and one new test file violates the 500-line repository limit.

### Policy-by-Policy Summary

- General Code Change Policy: ⚠️ Partial — design/docs/tooling are solid, but file-size and failure-propagation issues remain.
- Python Code Change Policy: ⚠️ Partial — typed CLI logic is mostly strong, but wrapper exit propagation breaks the `main() -> int` contract.
- TypeScript Code Change Policy: ⚠️ Partial — command-runtime is fine, but end-to-end error behavior still fails through the wrapper boundary.
- General Unit Test Policy: ⚠️ Partial — tests are deterministic and broad, but one critical failure scenario and one maintainability limit remain unmet.
- Python Unit Test Policy: ⚠️ Partial — coverage is strong, yet test organization must be split below 500 lines.
- TypeScript Unit Test Policy: ⚠️ Partial — Jest tests are clean, but the process-level failure path is not covered.

### Recommendation

**Needs revision**

Fix the bundled wrapper so it returns the bundled resolver's exit code, add a regression test that proves non-zero subprocess exit propagation, and split the oversized Python test module below 500 lines. After that, rerun the same Python + extension + JSON checks and re-audit the acceptance criteria.

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py::*`
- `tests/scripts/dev_tools/test_resolve_hard_lock_prompt_part2.py::*`
- `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py::*`
- `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts::*`

## Appendix B: Toolchain Commands Reference

**Python / root repo (check-only):**
- `poetry run black --check .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest`

**Extension / TypeScript (check-only):**
- `npm --prefix extensions/drm-copilot run format -- --check`
- `npm --prefix extensions/drm-copilot run lint`
- `npm --prefix extensions/drm-copilot run typecheck`
- `npm --prefix extensions/drm-copilot run test:unit`

**JSON:**
- `python -m scripts.dev_tools.validate_json`

**Targeted feature probe:**
- `python extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py --target <missing-target> --workspace <feature-folder>`

**Audit Completed By:** GitHub Copilot (GPT-5.4)  
**Audit Date:** 2026-03-15  
**Policy Version:** Current as of audit date

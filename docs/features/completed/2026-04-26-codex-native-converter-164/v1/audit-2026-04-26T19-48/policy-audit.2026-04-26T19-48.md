# Policy Audit: codex-native-converter post-remediation rerun (#164)

**Audit Date:** 2026-04-26  
**Code Under Test:** `scripts/dev_tools/codex_native_converter/*.py`, `tests/scripts/dev_tools/codex_native_converter/*.py`, `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/src/repo-automation-service.ts`, `extensions/drm-copilot/src/repo-automation-command-registration.ts`, `extensions/drm-copilot/src/repo-automation-service-workflows.ts`, `extensions/drm-copilot/test/extension.workflow-commands.test.ts`, and feature evidence under `docs/features/active/2026-04-26-codex-native-converter-164/evidence/`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 10 production files, 8 test files | Pytest | ✅ 1031 pass, 14 skip, 0 fail | 83% lines | 84% lines | 94% targeted converter coverage |
| TypeScript | 4 production files, 1 focused test file in the remediation scope | Jest | ✅ 32 suites, 349 tests, 0 fail | 94.42% lines | 95.49% lines | 98.55% on `repo-automation-command-registration.ts`; 100% on `repo-automation-service.ts` and `repo-automation-service-workflows.ts`; 98.63% on `extension.ts` |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-typescript-test-coverage.2026-04-26T19-20.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-typescript-test-coverage.2026-04-26T19-20.md`
- PowerShell baseline coverage artifact: `N/A - out of scope`
- PowerShell post-change coverage artifact: `N/A - out of scope`
- Per-language comparison summary: Section `1.2.1` below

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** This audit uses only inspected artifacts and commands run during this session.

## Executive Summary

This rerun reviewed the current branch state for `feature/codex-native-converter-164` against explicit base branch `development` after the first remediation loop. The refreshed PR context now anchors the review at `origin/development@0762f58a1451994999c2f49f2dbdc489120d138a` and head `b9542764a8271b83ecb075b7ca6edeb8575d1dfe`. Python feature evidence remains valid from the prior full toolchain pass because the remediation scope did not modify Python files. The current TypeScript rerun confirmed that linting, type checking, and Jest coverage all pass on the branch state under review.

The original blockers on `extension.ts` and `repo-automation-service.ts` are closed: current line counts are 266 and 471 respectively. One residual structural blocker remains. The newly extracted `extensions/drm-copilot/src/repo-automation-command-registration.ts` is 513 lines, which still violates the repository-wide 500-line production-file limit. On that basis, the branch remains non-compliant for final review even though feature behavior and automated verification remain strong.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md`
- [N/A] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [N/A] Bash
- [N/A] JSON

**Temporary artifacts cleanup:**
- [✅] No temporary one-time scripts were introduced during this review.
- [✅] Existing implementation files remain the product code under review.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | [✅] PASS | The Jest and Pytest suites are file- and fixture-based, with no evidence of shared mutable state in the reviewed artifacts. The current TypeScript rerun passed package-wide with stable results, and the Python baseline/final artifacts report stable full-suite passes. |
| **Isolation** - Each test targets single behavior | [✅] PASS | The converter Python tests are split by classifier, CLI review/apply, inventory, mapping, validation, and end-to-end behavior. The remediation TypeScript addition focuses on `extension.workflow-commands.test.ts` and command-registration behavior. |
| **Fast Execution** - Tests complete quickly | [✅] PASS | The current TypeScript package-wide Jest rerun completed in 2.164 s. The Python evidence reflects standard CI-friendly unit coverage runs rather than external-process integration suites. |
| **Determinism** - Consistent results | [✅] PASS | Current review evidence comes from deterministic local commands: `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, and `npm --prefix extensions/drm-copilot run test:unit -- --coverage`. Existing feature evidence shows no network or temp-file dependence in unit tests. |
| **Readability & Maintainability** - Clear structure | [✅] PASS | Python tests mirror the converter modules under `tests/scripts/dev_tools/codex_native_converter/`. TypeScript tests remain organized under `extensions/drm-copilot/test/` by command or service behavior. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | [✅] PASS | Python baseline: 83% repo-wide from `phase0-python-test-coverage.md`. TypeScript remediation baseline: 94.42% lines from `remediation-typescript-test-coverage.2026-04-26T19-20.md`. |
| **No Coverage Regression** | [✅] PASS | Python improved from 83% to 84%. TypeScript remediation scope improved from 94.42% to 95.49%. |
| **New Code Coverage ≥90%** | [✅] PASS | Python targeted converter coverage is 94%. Remediation TypeScript touched production files remain at or above 98.55% except `extension.ts`, which is still 98.63%. |
| **Comprehensive Coverage** | [✅] PASS | The current Jest run covers command registration, repo-automation service behavior, MCP inputs/handlers, and extension wiring. Python evidence covers CLI review/apply, validation, mapping, inventory, classifier, and end-to-end fixture conversion. |
| **Positive Flows** - Valid inputs | [✅] PASS | Review/apply happy paths are covered in Python CLI tests and TypeScript command registration tests. |
| **Negative Flows** - Invalid inputs | [✅] PASS | The converter validation tests cover unsupported or malformed inputs, and TypeScript workflow tests cover cancellation and missing-input early returns. |
| **Edge Cases** - Boundary conditions | [✅] PASS | The converter inventory and mapping tests cover mixed and unsupported source surfaces; the remediation tests cover direct versus interactive command invocation. |
| **Error Handling** - Error paths | [✅] PASS | The converter validation suite and extension workflow tests exercise blocking failures, unresolved mappings, and missing runtime conditions. |
| **Concurrency** - If applicable | [N/A] N/A | No concurrency-sensitive behavior was added or remediated in the reviewed scope. |
| **State Transitions** - If applicable | [✅] PASS | The extension workflow tests cover prompt-driven command flows and early-return states; converter review/apply behavior is validated through deterministic mode transitions. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 83% lines -> Post-change: 84% lines. Change: +1%. New/changed-code coverage: 94%. Disposition: PASS. Evidence: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-python-test-coverage.md`, `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-python-test-coverage.md`, `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-python-targeted-coverage.md`.
- TypeScript: Baseline: 94.42% lines -> Post-change: 95.49% lines. Change: +1.07%. New/changed-code coverage: 98.55% or higher for the touched production files. Disposition: PASS. Evidence: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-typescript-test-coverage.2026-04-26T19-20.md`, `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-typescript-test-coverage.2026-04-26T19-20.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | [✅] PASS | The current Jest output identifies suites, tests, and uncovered lines per file. Prior Pytest evidence similarly reports exact pass/fail counts and targeted coverage summaries. |
| **Arrange-Act-Assert Pattern** | [✅] PASS | The reviewed TypeScript tests are organized around setup via mocks, command execution, and explicit spawn/assertion verification. Python tests are similarly organized by scenario and expected result. |
| **Document Intent** | [✅] PASS | Test names in `extension.workflow-commands.test.ts` and the converter Python suites describe the exact scenario under test, including review/apply mode, early return, and validation behavior. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | [✅] PASS | The reviewed unit tests do not rely on remote services. The current Jest run is entirely local, and the existing Pytest evidence is local CLI/module validation. |
| **Use Mocks/Stubs** | [✅] PASS | The TypeScript test harness uses mocked prompts and spawned process interception to avoid external runtime dependencies. Python tests use fixtures for supported source trees rather than live repositories. |
| **Environment Stability** | [✅] PASS | No prohibited temporary files or mutable global environment coupling were required by the reviewed tests. The only environment-specific issue observed was Windows glob handling for `prettier --check`, which affected formatting verification but not test determinism. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | [✅] PASS | This document is the required post-remediation policy review and is paired with the matching code-review and feature-audit artifacts for this branch state. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | [✅] PASS | The objective is documented in `issue.md`, `spec.md`, and the prior remediation artifacts. This rerun specifically verifies the residual structural blocker after the first remediation loop. |
| **Read existing change plans** | [✅] PASS | The review used the active feature documents, prior remediation review artifacts, and refreshed PR context against `development`. |
| **Document the plan** | [✅] PASS | The original full-feature plan exists at `plan.2026-04-26T18-01.md`; this review adds a new remediation-inputs and remediation-plan set for the remaining blocker. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | [⚠️] PARTIAL | The remediation simplified `extension.ts` and `repo-automation-service.ts` by extraction, but one extracted helper is still oversized and needs a second split to restore simple, focused module boundaries. |
| **Reusability** | [✅] PASS | The branch keeps reusable converter logic in dedicated Python modules and extracted TypeScript helper modules rather than duplicating workflow logic across command registrations. |
| **Extensibility** | [✅] PASS | The Python converter remains classifier- and validation-driven, and the TypeScript wrapper continues to delegate to focused service/helper modules. |
| **Separation of concerns** | [⚠️] PARTIAL | Separation improved materially, but `repo-automation-command-registration.ts` still aggregates too many interactive command paths into one production file. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | [⚠️] PARTIAL | `extension.ts` and `repo-automation-service.ts` are now cohesive. `repo-automation-command-registration.ts` still needs one more decomposition by command family. |
| **Under 500 lines** | [❌] FAIL | Current line counts from this session: `extension.ts` 266, `repo-automation-service.ts` 471, `repo-automation-service-workflows.ts` 177, `repo-automation-command-registration.ts` 513. The last file violates policy. |
| **Public vs internal** | [✅] PASS | The extracted TypeScript modules keep the public command IDs and service contract stable while moving internal assembly logic behind helper modules. |
| **No circular dependencies** | [✅] PASS | No circular-dependency evidence surfaced in lint, type-check, or runtime review of the extracted modules. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | [✅] PASS | Names such as `repo-automation-command-registration.ts` and `repo-automation-service-workflows.ts` are clear and purpose-specific. Python converter module names are similarly direct. |
| **Docs/docstrings** | [✅] PASS | The public TypeScript helper export `registerRepoAutomationCommands` includes a contract comment, and the Python implementation remains documented through structured module layout and typed models. |
| **Comment why, not what** | [✅] PASS | The reviewed TypeScript extraction preserves brief rationale comments, such as the explicit branch confirmation behavior for PR-context collection. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | [⚠️] PARTIAL | **Commands:** `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`; `npm --prefix extensions/drm-copilot exec -- prettier --check src/*.ts src/**/*.ts test/*.ts test/**/*.ts *.json *.cjs`.<br>**Result:** Both check-only attempts reported Windows glob mismatches for `test` patterns; matched files reported formatted. The existing authoritative remediation formatter artifact `remediation-typescript-format.2026-04-26T19-20.md` remains PASS. |
| **2. Linting** | [✅] PASS | **Command:** `npm --prefix extensions/drm-copilot run lint`<br>**Result:** Passed on the current branch state. |
| **3. Type checking** | [✅] PASS | **Command:** `npm --prefix extensions/drm-copilot run typecheck`<br>**Result:** Passed on the current branch state. |
| **4. Testing** | [✅] PASS | **Command:** `npm --prefix extensions/drm-copilot run test:unit -- --coverage`<br>**Result:** Passed on the current branch state with 32 suites and 349 tests. |
| **Full toolchain loop** | [⚠️] PARTIAL | A clean current-pass result exists for lint, type-check, and tests. Formatting verification is partially blocked by Windows glob behavior in `npm exec prettier --check`, although the prior repo-approved formatter artifact is clean and no new formatting defect surfaced in the rerun. |
| **Explicit reporting** | [✅] PASS | This audit records all verification commands and the residual blocker explicitly. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | [✅] PASS | The current review artifacts summarize the branch state after the remediation extraction. |
| **Design choices explained** | [✅] PASS | The extraction rationale is traceable through the split-boundary evidence and the new focused helper modules. |
| **Update supporting documents** | [✅] PASS | The active feature folder now contains a refreshed review triplet plus a new remediation-inputs/remediation-plan pair. |
| **Provide next steps** | [✅] PASS | The next action is a narrow second split of `repo-automation-command-registration.ts`, then a TypeScript QA rerun and another review loop. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | [✅] PASS | **Command:** `poetry run black scripts tests`<br>**Result:** Prior final Python artifact passed; no Python files changed in the remediation loop under review. |
| **Linting with Ruff** | [✅] PASS | **Command:** `poetry run ruff check scripts tests`<br>**Result:** Prior final Python artifact passed; no Python changes were introduced after that evidence. |
| **Type checking with Pyright** | [✅] PASS | **Command:** `poetry run pyright`<br>**Result:** Prior final Python artifact passed. |
| **Testing with Pytest** | [✅] PASS | **Command:** `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing`<br>**Result:** Prior final Python artifact passed with 84% repo-wide coverage. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | [✅] PASS | The converter implementation was introduced as typed Python modules with targeted 94% coverage for the converter package. No new untyped Python remediation surface was added. |
| **Dataclasses for value objects** | [✅] PASS | The converter design centers on model modules and typed structures documented in the feature evidence. |
| **Protocols/ABCs for interfaces** | [✅] PASS | The converter separation into engine, models, mapping, reporting, and validation modules preserves explicit contracts between layers. |
| **Avoid utility classes** | [✅] PASS | The implementation is module- and function-oriented rather than static-class based. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | [✅] PASS | Validation failures are modeled explicitly and verified through the converter validation tests. |
| **Logging over print** | [✅] PASS | The reviewed evidence does not indicate permanent ad-hoc print debugging in the converter implementation. |
| **Invariants at construction** | [✅] PASS | The converter model and validation layers enforce supported-surface and blocking-result invariants. |

### Section 3E: TypeScript Code Change Policy Compliance

#### 3E.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | [⚠️] PARTIAL | Check-only verification is partially blocked by Windows glob behavior in `npm exec prettier --check`, but the prior remediation formatter artifact is PASS and the rerun found no contradictory evidence. |
| **Linting with ESLint** | [✅] PASS | **Command:** `npm --prefix extensions/drm-copilot run lint`<br>**Result:** Passed on the current branch state. |
| **Type checking with TSC** | [✅] PASS | **Command:** `npm --prefix extensions/drm-copilot run typecheck`<br>**Result:** Passed on the current branch state. |
| **Testing with Jest** | [✅] PASS | **Command:** `npm --prefix extensions/drm-copilot run test:unit -- --coverage`<br>**Result:** Passed on the current branch state. |

#### 3E.2 TypeScript Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | [✅] PASS | The extracted helper modules remain fully typed and pass the current TSC run. |
| **Prefer explicit domain types** | [✅] PASS | The remediation preserves explicit repo-automation input and command-registration contracts instead of weakening them with untyped helpers. |
| **Avoid cleverness** | [⚠️] PARTIAL | The new registration helper is readable, but its size indicates that responsibilities are still too concentrated in one file. |
| **Separation of concerns** | [⚠️] PARTIAL | Separation improved, but one final extraction is still needed to align module size and cohesion with policy. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | [✅] PASS | The converter Python test suite uses Pytest exclusively. |
| **Coverage expectation** | [✅] PASS | Repo-wide Python coverage is 84%, and targeted converter coverage is 94%. |
| **Focused unit tests** | [✅] PASS | Converter tests are split by module and behavior. |
| **Mocking sparingly** | [✅] PASS | The fixture-based converter tests rely on representative source trees rather than broad mocking. |
| **Organization** | [✅] PASS | Test files mirror the converter module layout under `tests/scripts/dev_tools/codex_native_converter/`. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | [✅] PASS | The current rerun used `npm --prefix extensions/drm-copilot run test:unit -- --coverage`. |
| **Focused unit tests** | [✅] PASS | The current remediation test additions focus on workflow command registration behavior. |
| **Mocking and isolation** | [✅] PASS | The TypeScript test harness isolates prompt and process interactions with targeted mocks. |
| **Resetting mocks / diagnostics** | [✅] PASS | The package-wide Jest suite passed cleanly and reports per-file uncovered lines for diagnosis. |

---

## 5. Test Coverage Detail

### Python converter package

| Test/Artifact | Scenario Type | Status |
|-----------|--------------|--------|
| `tests/scripts/dev_tools/codex_native_converter/test_classifier.py` | Positive, negative, unsupported classification | ✅ |
| `tests/scripts/dev_tools/codex_native_converter/test_cli_review.py` | Review-mode behavior | ✅ |
| `tests/scripts/dev_tools/codex_native_converter/test_cli_apply.py` | Apply-mode behavior | ✅ |
| `tests/scripts/dev_tools/codex_native_converter/test_validation.py` | Error handling, blocking failures | ✅ |
| `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/final-python-targeted-coverage.md` | Targeted package coverage summary | ✅ |

Coverage: 94% for `scripts.dev_tools.codex_native_converter`.

### TypeScript remediation scope

| Test/Artifact | Scenario Type | Status |
|-----------|--------------|--------|
| `extensions/drm-copilot/test/extension.workflow-commands.test.ts` | Interactive command registration paths | ✅ |
| `extensions/drm-copilot/test/repo-automation-service.codex-native-converter.test.ts` | Service wrapper correctness | ✅ |
| `extensions/drm-copilot/test/mcp-tools.codex-native-converter.test.ts` | MCP exposure and wiring | ✅ |
| Current Jest coverage rerun | Package-wide regression coverage | ✅ |

Coverage: 95.49% lines overall in the extension package for the current remediation rerun.

## 6. Test Execution Metrics

- Refreshed PR context command: `poetry run python -m scripts.dev_tools.pr_context.collector --base development` -> PASS.
- Current lint command: `npm --prefix extensions/drm-copilot run lint` -> PASS.
- Current type-check command: `npm --prefix extensions/drm-copilot run typecheck` -> PASS.
- Current Jest coverage command: `npm --prefix extensions/drm-copilot run test:unit -- --coverage` -> PASS in 2.164 s.
- Current Prettier check attempts: partial due Windows glob mismatch, with matched files reported formatted.

## 7. Code Quality Checks

- `extensions/drm-copilot/src/extension.ts` current line count: 266 -> PASS for the 500-line rule.
- `extensions/drm-copilot/src/repo-automation-service.ts` current line count: 471 -> PASS for the 500-line rule.
- `extensions/drm-copilot/src/repo-automation-service-workflows.ts` current line count: 177 -> PASS for the 500-line rule.
- `extensions/drm-copilot/src/repo-automation-command-registration.ts` current line count: 513 -> FAIL for the 500-line rule.
- Refreshed PR context now anchors the review to `development` with current head `b9542764a8271b83ecb075b7ca6edeb8575d1dfe`.

## 8. Gaps and Exceptions

- Residual blocker: `extensions/drm-copilot/src/repo-automation-command-registration.ts` exceeds the repository production-file limit by 13 lines.
- Formatting verification exception: the Windows `npm exec prettier --check` invocations returned unmatched-pattern errors for the extension `test` globs even though the matched files reported formatted. This affects audit certainty for the current check-only formatting step but does not outweigh the structural blocker.

## 9. Summary of Changes

This rerun confirms that the branch still satisfies the original feature behavior and retains strong Python and TypeScript automated verification. The first remediation loop successfully reduced the original oversized files and preserved command/service behavior, but it left one new oversized TypeScript helper that still requires decomposition.

## 10. Compliance Verdict

FAIL. The branch is not yet policy-compliant for final review because `extensions/drm-copilot/src/repo-automation-command-registration.ts` remains above the repository’s 500-line production-file limit.

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/codex_native_converter/test_classifier.py`
- `tests/scripts/dev_tools/codex_native_converter/test_cli_apply.py`
- `tests/scripts/dev_tools/codex_native_converter/test_cli_entrypoints.py`
- `tests/scripts/dev_tools/codex_native_converter/test_cli_review.py`
- `tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py`
- `tests/scripts/dev_tools/codex_native_converter/test_inventory.py`
- `tests/scripts/dev_tools/codex_native_converter/test_mapping.py`
- `tests/scripts/dev_tools/codex_native_converter/test_validation.py`
- `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
- `extensions/drm-copilot/test/repo-automation-service.codex-native-converter.test.ts`
- `extensions/drm-copilot/test/mcp-tools.codex-native-converter.test.ts`
- `extensions/drm-copilot/test/mcp-tool-inputs.codex-native-converter.test.ts`

## Appendix B: Toolchain Commands Reference

- `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
- `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- `npm --prefix extensions/drm-copilot exec -- prettier --check src/*.ts src/**/*.ts test/*.ts test/**/*.ts *.json *.cjs`
- `npm --prefix extensions/drm-copilot run lint`
- `npm --prefix extensions/drm-copilot run typecheck`
- `npm --prefix extensions/drm-copilot run test:unit -- --coverage`

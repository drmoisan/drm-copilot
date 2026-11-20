# Policy Compliance Audit: harden feature promotion lifecycle MCP-only (Issue #168)

**Audit Date:** 2026-04-29  
**Code Under Test:** `scripts/dev_tools/validate_orchestration_artifacts.py`, `scripts/dev_tools/validate_orchestration_review_artifacts.py`, `scripts/dev_tools/validate_orchestrator_state.py`, `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 3 files | 29 tests | ✅ 29 pass, 0 fail | 87% lines | 87% lines | 87% |
| PowerShell | 3 files | 72 tests | ✅ 72 pass, 0 fail | 96.83% line coverage | 96.83% line coverage | N/A - generated coverage report does not expose a numeric per-file changed-code metric |
| JSON | 1 file | N/A | ✅ validation | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope`
- TypeScript post-change coverage artifact: `N/A - out of scope`
- PowerShell baseline coverage artifact: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/powershell-test.2026-04-29T08-56.md`
- PowerShell post-change coverage artifact: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/powershell-test.2026-04-29T08-56.md`
- Per-language comparison summary: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-coverage-comparison.2026-04-29T08-56.md` and `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/powershell-coverage-comparison.2026-04-29T08-56.md`

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Do not synthesize or backfill missing audit evidence from memory or inference. If evidence is missing, stop and list the exact missing artifact paths.

---

## Executive Summary

This remediation review evaluated `general-code-change.instructions.md`, `general-unit-test.instructions.md`, `python-code-change.instructions.md`, and `python-unit-test.instructions.md` against the current split-validator implementation for feature `#168`. The functional objective of the remediation is delivered: the validator is split into smaller cohesive Python modules, the stable CLI entrypoint still exposes the existing artifact-type names, and the receipt-namespace validation behavior remains intact.

The review did not find regressions in the remediated behavior. Focused Python verification, CLI contract inspection, and coverage-enabled regression tests all passed. The overall audit remains **partially compliant** because the new split modules `scripts/dev_tools/validate_orchestration_review_artifacts.py` and `scripts/dev_tools/validate_orchestrator_state.py` currently measure 87% and 83% line coverage respectively, below the repository target of at least 90% for new modules.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`

**Language-specific policies evaluated:**
- [✅] `python-code-change.instructions.md` + `python-unit-test.instructions.md`
- [✅] `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md`
- [N/A] Bash: shfmt + shellcheck + bats
- [✅] JSON: `validate_json`

**Temporary artifacts cleanup:**
- [✅] All temporary or one-time scripts created during development have been deleted
- [✅] The new ongoing tooling script `.claude/hooks/enforce-promotion-mcp-only.ps1` is permanent, targeted, and covered by tests
- Kept with tests: `.claude/hooks/enforce-promotion-mcp-only.ps1`

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | [✅] [PASS] | The added PowerShell and Python tests are self-contained and operate on local strings, JSON payloads, and repository text. They do not share mutable global state across cases. |
| **Isolation** - Each test targets single behavior | [✅] [PASS] | `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` isolates one allow case and four deny-token cases. The Python suites isolate wording contracts and validator acceptance/rejection paths. |
| **Fast Execution** - Tests complete quickly | [✅] [PASS] | The focused Python suite completed in `0.14s` for 28 tests. The selected Pester run completed without long-running dependencies and reported 72 passing tests in the QA evidence artifact. |
| **Determinism** - Consistent results | [✅] [PASS] | Tests use static repository files and synthetic `CLAUDE_TOOL_INPUT` payloads only. No network, external service, temp-file creation, or timing-sensitive assertions are used. |
| **Readability & Maintainability** - Clear structure | [✅] [PASS] | The new tests use descriptive Pytest names and `Describe`/`Context`/`It` grouping in Pester. The changed suites mirror the code-under-test locations. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | [✅] [PASS] | Baseline Python and PowerShell coverage artifacts exist under `evidence/baseline/` for this feature folder and record the exact commands and outputs. |
| **No Coverage Regression** | [✅] [PASS] | Python remained `87% -> 87%`. PowerShell remained `96.83% -> 96.83%` per the baseline and final QA comparison artifacts. |
| **New Code Coverage ≥90%** | [⚠️] [PARTIAL] | Python changed-code coverage is numerically reported as `87%` for `scripts/dev_tools/validate_orchestration_artifacts.py`. PowerShell changed-code coverage for `.claude/hooks/enforce-promotion-mcp-only.ps1` is behavior-tested but not numerically isolated by the generated coverage report. |
| **Comprehensive Coverage** | [✅] [PASS] | The new hook has direct allow and deny-path tests. The validator has acceptance tests for legacy receipts, namespaced receipts, scalar rejection, and unknown-key rejection. The lifecycle skill contract tests verify MCP preflight, receipt capture, banned strings, and orchestrator namespace documentation. |
| **Positive Flows** - Valid inputs | [✅] [PASS] | Positive scenarios cover benign Bash commands, valid namespaced receipt payloads, and compliant skill/orchestrator wording. |
| **Negative Flows** - Invalid inputs | [✅] [PASS] | Negative scenarios cover each forbidden promotion token, malformed or unsupported receipt shapes, and banned wording absence checks. |
| **Edge Cases** - Boundary conditions | [✅] [PASS] | The validator tests both legacy and additive checkpoint shapes. The hook allows missing tool input or missing command text without false blocks. |
| **Error Handling** - Error paths | [✅] [PASS] | The hook throws on malformed JSON in `CLAUDE_TOOL_INPUT`, and the validator rejects unsupported namespace keys and scalar receipt payloads. |
| **Concurrency** - If applicable | [N/A] [N/A] | The reviewed code paths are deterministic single-process validators and hooks. |
| **State Transitions** - If applicable | [N/A] [N/A] | No state machine transitions were added beyond validating persisted checkpoint structure. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 87% lines -> Post-change: 87% lines. Change: +0% lines. New/changed-code coverage: 87%. Disposition: PASS. Evidence: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/python-test.2026-04-29T08-56.md` and `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-coverage-comparison.2026-04-29T08-56.md`.
- PowerShell: Baseline: 96.83% line coverage -> Post-change: 96.83% line coverage. Change: +0% line coverage. New/changed-code coverage: N/A - generated report does not provide a numeric per-file metric for `.claude/hooks/enforce-promotion-mcp-only.ps1`. Disposition: PASS. Evidence: `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/baseline/powershell-test.2026-04-29T08-56.md` and `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/powershell-coverage-comparison.2026-04-29T08-56.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | [✅] [PASS] | The Python contract tests assert exact wording fragments, and the Pester suite asserts the exact deny message from `Get-PromotionMcpOnlyBlockedReason`. Failures would point directly to the missing token or incorrect message. |
| **Arrange-Act-Assert Pattern** | [✅] [PASS] | The new Pester file explicitly separates Arrange, Act, and Assert blocks. The Pytest cases follow the same pattern through local builders and direct assertions. |
| **Document Intent** | [✅] [PASS] | The new and changed tests use descriptive names such as `test_claude_feature_promotion_lifecycle_requires_mcp_preflight` and `blocks new_active_feature_folder`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | [✅] [PASS] | No changed test depends on a database, network, remote API, or external process. All verification is local. |
| **Use Mocks/Stubs** | [✅] [PASS] | No mocking framework was required. The tests use repository files and synthetic command payloads instead of external dependencies. |
| **Environment Stability** | [✅] [PASS] | The tests do not create temporary files and do not depend on mutable external configuration beyond the local repository checkout. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | [✅] [PASS] | This document, together with `code-review.2026-04-29T13-55.md` and `feature-audit.2026-04-29T13-55.md`, is the required post-implementation review set for this feature folder. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | [✅] [PASS] | The objective is documented in `issue.md`, `spec.md`, and `user-story.md` in the active feature folder for issue `#168`. |
| **Read existing change plans** | [✅] [PASS] | The implementation references `plan.2026-04-29T08-56.md`, and baseline evidence records the reviewed plan and inputs. |
| **Document the plan** | [✅] [PASS] | The implementation plan exists at `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/plan.2026-04-29T08-56.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | [✅] [PASS] | The change uses narrow, explicit enforcement points: one skill rewrite, one new PowerShell hook, one settings registration, and additive validator helpers. |
| **Reusability** | [✅] [PASS] | The new PowerShell hook exposes helper functions that the Pester suite exercises directly, and the validator separates list and namespaced receipt validation into dedicated helpers. |
| **Extensibility** | [✅] [PASS] | The receipt validator accepts an additive object namespace without breaking the legacy list shape, and the orchestrator docs define stable receipt keys. |
| **Separation of concerns** | [✅] [PASS] | The skill documents workflow rules, the hook enforces Bash bypass blocking, and the Python validator enforces checkpoint schema. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | [✅] [PASS] | Each touched file retains a single purpose: skill contract, hook registration, hook enforcement, checkpoint documentation, validator behavior, or tests. |
| **Under 500 lines** | [✅] [PASS] | `scripts/dev_tools/validate_orchestration_artifacts.py` is 194 lines, `scripts/dev_tools/validate_orchestration_review_artifacts.py` is 404 lines, and `scripts/dev_tools/validate_orchestrator_state.py` is 242 lines, so each touched production module is below the repository-wide 500-line limit. |
| **Public vs internal** | [✅] [PASS] | The changed Python module keeps helper functions internal, and the PowerShell hook exposes only local helper functions used by its entrypoint and tests. |
| **No circular dependencies** | [✅] [PASS] | The touched files are documentation, a standalone hook, and a validator module; no new import cycle is visible in the changed scope. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | [✅] [PASS] | Names such as `enforce-promotion-mcp-only.ps1`, `Test-PromotionBypassToken`, and `_validate_namespaced_delegation_receipts` describe behavior directly. |
| **Docs/docstrings** | [✅] [PASS] | The new hook and validator helpers include docstrings/comments that explain intent and contracts. |
| **Comment why, not what** | [✅] [PASS] | The new PowerShell hook comments explain why command-text inspection is intentionally narrow and non-mutating. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | [✅] [PASS] | **Command:** `poetry run black scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`.<br>**Result:** After one formatter-triggered restart, the final QA-loop pass completed cleanly with `5 files left unchanged.` |
| **2. Linting** | [✅] [PASS] | **Command:** `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`.<br>**Result:** Ruff reported `All checks passed!` after the restarted QA loop. |
| **3. Type checking** | [✅] [PASS] | **Commands:** `poetry run pyright`; PowerShell type check is not applicable per policy.<br>**Result:** Pyright reported `0 errors, 0 warnings, 0 informations`. |
| **4. Testing** | [✅] [PASS] | **Command:** `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`.<br>**Result:** Pytest reported `29 passed in 0.16s`, wrote `coverage.xml`, and wrote `artifacts/python/lcov.info`. |
| **Full toolchain loop** | [✅] [PASS] | The remediation-focused Python toolchain loop completed cleanly after one required restart from Black when a later Ruff fix changed code. |
| **Explicit reporting** | [✅] [PASS] | All review-time commands and the existing baseline/QA evidence artifact paths are recorded in this audit and Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | [✅] [PASS] | The changed working tree tightens the Claude promotion lifecycle contract, adds a Bash promotion guard, documents receipt namespaces, and broadens checkpoint validation. |
| **Design choices explained** | [✅] [PASS] | The feature docs explain the decision to require MCP-only execution and preserve raw receipt payloads without normalization. |
| **Update supporting documents** | [✅] [PASS] | `issue.md`, `spec.md`, `user-story.md`, the implementation plan, and review evidence artifacts exist in the feature folder. |
| **Provide next steps** | [⚠️] [PARTIAL] | Functional work is complete, but the new split Python modules should add more targeted tests to raise line coverage for the new modules toward the repository target for new code. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | [✅] [PASS] | **Command:** `poetry run black scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`.<br>**Result:** The final QA-loop pass completed with `5 files left unchanged.` |
| **Linting with Ruff** | [✅] [PASS] | **Command:** `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`.<br>**Result:** `All checks passed!` |
| **Type checking with Pyright** | [✅] [PASS] | **Command:** `poetry run pyright`.<br>**Result:** `0 errors, 0 warnings, 0 informations`. |
| **Testing with Pytest** | [✅] [PASS] | **Command:** `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`.<br>**Result:** `29 passed in 0.16s`. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | [✅] [PASS] | The touched validator remains type-annotated and Pyright-clean. The helper functions use concrete container types and `cast` only at JSON boundaries. |
| **Dataclasses for value objects** | [N/A] [N/A] | No new Python value objects were introduced in this scope. |
| **Protocols/ABCs for interfaces** | [N/A] [N/A] | No new Python interface layer was introduced in this scope. |
| **Avoid utility classes** | [✅] [PASS] | The validator continues to use top-level functions instead of static-method utility classes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | [✅] [PASS] | The validator catches `json.JSONDecodeError` explicitly and returns structured errors rather than suppressing failures. |
| **Logging over print** | [✅] [PASS] | The validator uses CLI output for validation results and does not introduce ad-hoc debug prints. |
| **Invariants at construction** | [N/A] [N/A] | No new Python classes or constructors were added. |

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | [✅] [PASS] | **Command:** `mcp_drmcopilotext_run_poshqc_format scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`.<br>**Result:** Completed successfully. |
| **Linting with PSScriptAnalyzer** | [✅] [PASS] | **Command:** `mcp_drmcopilotext_run_poshqc_analyze scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`.<br>**Result:** Completed successfully. |
| **Fix all findings** | [✅] [PASS] | The final PowerShell QA evidence records a clean analyzer pass with no remaining findings. |
| **PowerShell 7+ compatible** | [✅] [PASS] | The new hook declares `#Requires -Version 7.0` in its companion test file, and the repository PowerShell QA pipeline targets PowerShell 7. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | [✅] [PASS] | The hook exposes focused helper functions with `CmdletBinding()` and typed outputs. |
| **Parameter validation** | [✅] [PASS] | `Test-PromotionBypassToken` requires a mandatory `CommandText` parameter and the entrypoint handles absent input safely. |
| **Avoid global state** | [✅] [PASS] | The only script-scoped state is the canonical deny message string; behavior is otherwise driven by function arguments and environment input. |
| **Error handling** | [✅] [PASS] | The hook surfaces malformed JSON explicitly and returns deterministic `allow` or `block` JSON responses. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | [✅] [PASS] | The new hook is cohesive and well under the 500-line limit. The changed PowerShell test files are also within the limit. |
| **Approved verbs** | [✅] [PASS] | The added helper functions use approved verbs such as `Get`, `Test`, and `Invoke`. |
| **Comment why** | [✅] [PASS] | The hook comments explain why the policy gate is intentionally narrow and non-mutating. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | [✅] [PASS] | Completed successfully through the repository PowerShell QA toolchain. |
| **Step 2: Analyze** | [✅] [PASS] | Completed successfully through the repository PowerShell QA toolchain. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | [✅] [PASS] | Completed successfully through the repository PowerShell QA toolchain. |
| **Rerun loop if needed** | [✅] [PASS] | The review-time PowerShell pass succeeded without requiring another iteration. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | [N/A] [N/A] | No separate review-time JSON formatting pass was required because the file already remained syntactically valid and stable under repository tests. |
| **Schema validation** | [✅] [PASS] | **Command:** `poetry run python -m scripts.dev_tools.validate_json` via task `shell: JSON: validate`.<br>**Result:** The task completed without diagnostics. |
| **Required $schema** | [✅] [PASS] | `.claude/settings.json` declares `$schema: https://json.schemastore.org/claude-code-settings.json`. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | [✅] [PASS] | `.claude/settings.json` is strict JSON with no comments or trailing commas. |
| **Deterministic key order** | [✅] [PASS] | The file remains organized as stable JSON configuration and passed repository validation. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | [✅] [PASS] | The changed Python tests run under Pytest and use standard function-style test definitions. |
| **Coverage expectation** | [⚠️] [PARTIAL] | Repo-wide and changed-module coverage are documented, but the changed Python validator remains at `87%` line coverage and the file-size policy violation still requires remediation. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | [✅] [PASS] | Each new test covers one wording contract or one validator acceptance/rejection behavior. |
| **Mocking sparingly** | [✅] [PASS] | No mocking framework is used. The tests rely on repository text and synthetic JSON payloads. |
| **Organization** | [✅] [PASS] | The tests remain under `tests/scripts/dev_tools/`, mirroring the validator module location and scope. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | [✅] [PASS] | Names explicitly describe the required contract, such as `test_validate_orchestrator_state_text_accepts_promotion_receipt_namespace`. |
| **Docstrings/comments** | [✅] [PASS] | Each added test function includes a concise docstring or uses a self-describing name. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | [✅] [PASS] | **Command:** `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`.<br>**Result:** `28 passed in 0.14s`. |
| **No Alternative Test Runners** | [✅] [PASS] | Only Pytest was used for the Python scope. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | [✅] [PASS] | The PowerShell tests use `BeforeAll`, `Describe`, `Context`, and `It` blocks under the repository Pester configuration. |
| **Use PoshQC Configuration** | [✅] [PASS] | **Command:** `mcp_drmcopilotext_run_poshqc_test scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`.<br>**Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` via the repository QA tooling.<br>**Result:** Completed successfully. |
| **PowerShell 7+ Compatible** | [✅] [PASS] | The changed hook and tests are aligned with the repository's PowerShell 7 workspace selection and QA tooling. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | [✅] [PASS] | The new suite verifies one allow case and one deny case per forbidden promotion token. |
| **Test Behavior Over Implementation** | [✅] [PASS] | The tests assert observable decisions and the canonical deny message rather than internal implementation details. |
| **Mocking Used Sparingly** | [✅] [PASS] | No mocking framework is used. The tests call the hook helpers directly with synthetic inputs. |
| **Organization** | [✅] [PASS] | **Test file:** `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1`.<br>**Code file:** `.claude/hooks/enforce-promotion-mcp-only.ps1`.<br>The location mirrors the hook runtime area used across the repository. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | [✅] [PASS] | The new PowerShell test file is named `enforce-promotion-mcp-only.Tests.ps1`. |
| **Describe/Context/It Structure** | [✅] [PASS] | The suite uses one `Describe`, two `Context` blocks, and targeted `It` cases. |
| **Logical Grouping** | [✅] [PASS] | The allow case and the forbidden token cases are grouped separately for clarity. |
| **Docstrings/Comments** | [✅] [PASS] | The file header and test names are self-explanatory and document the scenario intent. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | [✅] [PASS] | **Command:** `mcp_drmcopilotext_run_poshqc_test scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`.<br>**Result:** Completed successfully with 72 passing tests per the QA evidence artifact. |
| **No Alternative Test Runners** | [✅] [PASS] | Only the repository PowerShell QA/Pester tooling was used for PowerShell verification. |

---

## 5. Test Coverage Detail

### Split validator modules (29 tests in the focused Python suite)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_entrypoint_reexports_split_validator_functions` | Positive | Stable entrypoint aliasing for the split modules | ✅ |
| `test_validate_orchestrator_state_text_accepts_legacy_list_delegation_receipts` | Positive | Legacy receipt validation path | ✅ |
| `test_validate_orchestrator_state_text_accepts_promotion_receipt_namespace` | Positive | Namespaced receipt validation path | ✅ |
| `test_validate_orchestrator_state_rejects_noncontainer_receipts` | Negative | Scalar receipt rejection path | ✅ |
| `test_validate_orchestrator_state_rejects_unknown_promotion_receipt_keys` | Negative | Unsupported nested-key rejection path | ✅ |
| `test_claude_feature_promotion_lifecycle_requires_mcp_preflight` | Contract | Guardrail wording contract remains unchanged after the split | ✅ |

**Coverage:** `scripts/dev_tools/validate_orchestration_artifacts.py` 90%, `scripts/dev_tools/validate_orchestration_review_artifacts.py` 87%, and `scripts/dev_tools/validate_orchestrator_state.py` 83%.

**Not covered:** Defensive branches in the two new split modules that depend on uncommon malformed review-artifact combinations and unsupported orchestrator-state edge cases remain unexecuted in the focused suite.

### `.claude/hooks/enforce-promotion-mcp-only.ps1` (5 targeted Pester tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `allows benign Bash commands` | Positive | Allow decision path | ✅ |
| `blocks new-potential-entry.ps1` | Negative | Token block path | ✅ |
| `blocks new_potential_bug_entry` | Negative | Token block path | ✅ |
| `blocks potential_to_issue` | Negative | Token block path | ✅ |
| `blocks new_active_feature_folder` | Negative | Token block path | ✅ |

**Coverage:** Aggregate PowerShell coverage remained at 96.83%; the generated report does not expose a numeric per-file value for this new hook.

**Not covered:** The generated coverage artifact does not provide isolated numeric line coverage for the new hook, but the behavior-level deny and allow paths are exercised directly.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 29 | ✅ |
| Tests Passed | 29 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 0.16s focused Python suite | ✅ Fast |
| Average Time per Test | N/A - mixed runners and aggregate Pester duration not surfaced in the review-time tool output | ✅ |
| Discovery Time | N/A - not surfaced by the runner outputs used for this review | ✅ |
| Functions/Classes Tested | 3 split validator modules plus changed contract suites | ✅ |
| Test File Size | New and changed test files remain maintainable and well below the 500-line limit | ✅ |
| Code Coverage (if applicable) | Python 87% aggregate line coverage across the remediated split modules | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --check` | `3 files would be left unchanged.` | ✅ |
| Ruff Linting | `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` | `All checks passed!` | ✅ |
| Pyright Type Checking | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` | ✅ |
| Pytest Tests | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info` | `29 passed in 0.16s` | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp_drmcopilotext_run_poshqc_format scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]` | Completed successfully | ✅ |
| PSScriptAnalyzer | `mcp_drmcopilotext_run_poshqc_analyze scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]` | Completed successfully | ✅ |
| Pester Tests | `mcp_drmcopilotext_run_poshqc_test scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]` | Completed successfully; QA evidence records 72 passing tests | ✅ |

**Notes:**
JSON validation ran through the repository task `shell: JSON: validate` and completed without diagnostics.

---

## 8. Gaps and Exceptions

### Identified Gaps
- **New-module coverage target:** `scripts/dev_tools/validate_orchestration_review_artifacts.py` and `scripts/dev_tools/validate_orchestrator_state.py` measure 87% and 83% line coverage in the final QA evidence, below the repository target of at least 90% coverage for new modules.

### Approved Exceptions
**None.** No exceptions were approved for the reviewed scope.

### Removed/Skipped Tests
**None.** All planned tests referenced by the implemented scope were present in the reviewed evidence.

---

## 9. Summary of Changes

### Commits in This PR/Branch

No commits are in range relative to `development`; this review covered the current working tree on `feature/harden-feature-promotion-lifecycle-mcp-only-168`.

### Files Modified

1. **`.claude/skills/feature-promotion-lifecycle/SKILL.md`** (MODIFIED)
   - Rewrites the Claude-side lifecycle contract to be MCP-only for agent sessions.
   - Documents preflight MCP availability checks and raw promotion receipt capture keys.

2. **`.claude/settings.json`** (MODIFIED)
   - Registers the new promotion-specific Bash pre-tool hook.

3. **`.claude/hooks/enforce-promotion-mcp-only.ps1`** (NEW)
   - Blocks direct Bash promotion-script bypass attempts using a narrow token check.

4. **`.claude/agents/orchestrator.md`** (MODIFIED)
   - Documents the `delegation_receipts.promotion.*` persistence namespace.

5. **`scripts/dev_tools/validate_orchestration_artifacts.py`** (MODIFIED)
   - Remains the stable CLI entrypoint while importing and re-exporting the split validator functions.

6. **`scripts/dev_tools/validate_orchestration_review_artifacts.py`** (NEW)
   - Owns the review-artifact validation helpers and shared parsing logic that were previously embedded in the CLI module.

7. **`scripts/dev_tools/validate_orchestrator_state.py`** (NEW)
   - Owns the orchestrator-state and receipt-namespace validation helpers while preserving the additive namespaced receipt behavior and legacy compatibility.

8. **Changed test files** (MODIFIED)
   - Update the Python regression suite to validate the split-module entrypoint aliases and preserve the prior validator and guardrail contract coverage.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The remediation is functionally implemented and the focused verification passes succeeded, but the reviewed working tree is not yet fully policy-compliant because the two new split Python modules remain below the repository target of at least 90% line coverage for new modules. The prior 500-line production-file violation is resolved.

**Fail-closed reminder:** Do not mark the audit PASS, fully compliant, or ready for merge when any required baseline artifact, QA artifact, coverage metric, or coverage-comparison artifact is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- [✅] Before Making Changes: Planned and documented in the feature folder.
- [✅] Design Principles: Narrow, additive implementation.
- [✅] Module & File Structure: All touched production modules are below 500 lines after the split.
- [✅] Naming, Docs, Comments: Clear names and contract comments.
- [✅] Toolchain Execution: Focused review-time toolchain passed.
- [⚠️] Summarize & Document: Documented, but next steps include required remediation.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- [✅] Tooling & Baseline: Black, Ruff, Pyright, and Pytest passed.
- [✅] Python Design & Typing: Typed helpers and explicit schema validation.
- [✅] Error Handling: Explicit JSON and schema errors.

**For PowerShell:**
- [✅] Tooling & Baseline: Format, analyze, and test passed.
- [✅] PowerShell Design & Safety: Narrow, explicit hook behavior.
- [✅] Structure & Naming: Cohesive hook and test surfaces.
- [✅] Toolchain: Review-time PowerShell QA pass succeeded.

#### General Unit Test Policy (Section 1)
- [✅] Core Principles: Independent, isolated, deterministic, and fast.
- [⚠️] Coverage & Scenarios: Broad scenario coverage exists, but the two new split Python modules remain below the repository target of at least 90% line coverage for new modules.
- [✅] Test Structure: Clear and focused.
- [✅] External Dependencies: None.
- [✅] Policy Audit: This document fulfills the review requirement.

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- [✅] Framework & Scope: Pytest used correctly.
- [✅] Test Style & Structure: Focused contract and validator tests.
- [✅] Naming & Readability: Descriptive names and docstrings.
- [✅] Toolchain: Pytest run recorded and passing.

**For PowerShell:**
- [✅] Framework & Scope: Pester via PoshQC tooling.
- [✅] Test Style & Structure: One behavior per case.
- [✅] Naming & Readability: Standard `*.Tests.ps1` layout.
- [✅] Toolchain: Pester QA evidence is passing.

---

### Metrics Summary

- [✅] 29/29 reviewed Python test cases passing across the focused remediation evidence set
- [✅] Python toolchain clean: Black, Ruff, Pyright, and Pytest all passed
- [✅] All touched production Python modules are below the repository 500-line production-file limit
- [⚠️] `validate_orchestration_review_artifacts.py` remains at 87% line coverage
- [⚠️] `validate_orchestrator_state.py` remains at 83% line coverage

---

### Recommendation

**Needs revision**

Add targeted tests for the review-artifact and orchestrator-state edge paths so the two new split modules move closer to the repository target of at least 90% coverage for new modules while preserving the current CLI behavior and the additive receipt-namespace validation.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` — focused split-validator regression suite (19 tests)
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` — lifecycle/orchestrator wording contract suite (10 tests)

---

## Appendix B: Toolchain Commands Reference

**For Python:**

- `poetry run black scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
- `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py scripts/dev_tools/validate_orchestration_review_artifacts.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
- `poetry run pyright`
- `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov=scripts.dev_tools.validate_orchestration_review_artifacts --cov=scripts.dev_tools.validate_orchestrator_state --cov-report=term-missing --cov-report=xml:coverage.xml --cov-report=lcov:artifacts/python/lcov.info`
- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json`

**For PowerShell:**

- `mcp_drmcopilotext_run_poshqc_format scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`
- `mcp_drmcopilotext_run_poshqc_analyze scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`
- `mcp_drmcopilotext_run_poshqc_test scan_folders=[".claude/hooks","tests/scripts/claude-hooks","tests/scripts/claude-runtime"]`
- `pwsh -NoProfile -Command "Select-String -Path '.claude/skills/feature-promotion-lifecycle/SKILL.md' -Pattern 'Fallback','fallback','dev_tools','dev-tools','poetry run python -m scripts' -SimpleMatch"`

**For JSON:**

- `poetry run python -m scripts.dev_tools.validate_json`

---

**Audit Completed By:** GitHub Copilot  
**Audit Date:** 2026-04-29  
**Policy Version:** Current as of 2026-04-29

# Policy Compliance Audit: Epic-planner per-feature receipt-checks key gate (#543)

---

**Audit Date:** 2026-10-16
**Code Under Test:**
- `scripts/dev_tools/validate_epic_planner_state.py` (Python, modified)
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (TypeScript, modified)
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (Python test, modified)
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` (Python test, new)
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` (TypeScript test, new)
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (TypeScript test, modified)
- Feature-folder Markdown under `docs/features/active/epic-planner-receipt-checks-key-gate-543/` (issue, spec, research, plan, evidence)

**Base/Head:** base `main` (`origin/main` @ `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`, merge base), head `bug/epic-planner-receipt-checks-key-gate-543` @ `5e338716153fcf29c2d9e3c3ba23d16906220cd4`. Scope is the full branch diff `adb9aa5f0..5e3387161` (67 files, +2636/-73).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 production, 2 test | 78 targeted (68 re-run by reviewer with `--no-cov`); full suite 7100 | PASS: 78 pass, 0 fail; full suite 7100 pass, 6 skipped, 1 deselected (#510) | `validate_epic_planner_state.py` 91.76% lines (167/182), 84.38% branches (81/96) | 92.55% lines (174/188), 86.00% branches (86/100); confirmed from `artifacts/python/lcov.info` (LH 174/LF 188, BRH 86/BRF 100) | 100% of added executable lines covered; 0 missing arcs from the two new conditions |
| TypeScript | 1 production, 2 test | 4009 full suite; 68 targeted re-run by reviewer | PASS: 4009 pass, 0 fail | `epic-planner-state-core.ts` 98.31% lines, 93.8% branches (text reporter) | 98.36% lines, 94.06% branches (text reporter); repo-wide 97.26% lines, 92.29% branches (text-summary) | 100% of added executable lines (0 in the uncovered set, text reporter) |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 61 files | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/baseline/baseline-typescript-test-coverage.2026-10-16T00-38.md` (text reporter transcript; no `lcov.info` produced)
- TypeScript post-change coverage artifact: required `coverage/lcov.info` (and the jest `coverageDirectory` `extensions/drm-copilot/coverage/lcov.info`) is ABSENT. The final run (`evidence/qa-gates/final-typescript-test-coverage.2026-10-16T01-13.md`) overrode the configured `lcov` reporter with `--coverageReporters=text --coverageReporters=text-summary`, so no lcov artifact was written.
- Python baseline coverage artifact: `evidence/baseline/baseline-python-per-file-coverage.2026-10-16T00-33.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (present; written 2026-10-16 01:08 UTC; one `SF:` record, `scripts\dev_tools\validate_epic_planner_state.py`)
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed on the branch
- Per-language comparison summary: Section 1.2.1 and `evidence/qa-gates/coverage-delta-verification.2026-10-16T01-16.md`

**Verdict rule applied:** TypeScript has changed files and its mandatory coverage artifact is absent, so the TypeScript coverage verdict is FAIL (finding PA-1) even though the recorded text-reporter figures exceed the thresholds.

---

## Executive Summary

The branch key-gates the per-feature `model_routing_receipt` and `topology_receipt` checks in the epic-planner execution-ready gate, in both the Python validator (`_validate_ready_features`) and its TypeScript twin (`validateReadyFeatures`). Under `require_ready_for_execution` with no Codex flag, each check now runs only when the feature carries that key; either Codex flag keeps both checks unconditional. Error strings are unchanged. Tests were added in both runtimes and the MCP threading test was extended.

**Policy documents evaluated:**
- PASS `CLAUDE.md` and `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists; `scripts/dev_tools` is T4 and `extensions/drm-copilot` is T3)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md`
- PARTIAL `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md` (code and tests compliant; coverage artifact absent)
- N/A PowerShell, C#, Bash, JSON (no changed files)

The reviewer re-ran Black, Ruff, Pyright, Prettier, ESLint, `tsc` (typecheck), targeted pytest (68 passed, `--no-cov`), targeted Jest (5 suites, 68 passed), and `validate_evidence_locations.py --root .`; all exited 0. One FAIL finding remains: PA-1, the TypeScript coverage artifact is absent. All 17 non-CI acceptance criteria pass; AC18 is pending CI.

**Temporary artifacts cleanup:**
- PASS No temporary scripts are committed; scratch files were kept in the session scratchpad (`SCRATCH/543/...` in evidence commands).
- PASS No ongoing tooling scripts were added.

---

## Rejected Scope Narrowing

None detected. The caller prompt stated "PowerShell and bats evidence policy for this run: PoshQC MCP tools plus CI results (no PowerShell files are expected in this diff)." This is not a narrowing: the branch diff contains zero PowerShell and zero bash files, verified with `git diff --name-status adb9aa5f0..HEAD`. The caller's AC18 instruction ("list it as pending-CI") matches `.claude/skills/acceptance-criteria-tracking/SKILL.md` "CI-Dependent Criteria" and is not a narrowing. The audit covers the full branch diff.

## Evidence Location Compliance

- `git diff --name-only adb9aa5f0..HEAD | grep -E "^artifacts/"`: no output. No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` is in the branch diff.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0, no violations.
- All 57 evidence files are under `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/<kind>/` (`baseline`, `other`, `qa-gates`, `regression-testing`).
- Result: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record was needed.

## Tier Classification

`quality-tiers.yml` exists at the repository root. Both changed projects are classified: `scripts/dev_tools` T4 and `extensions/drm-copilot` T3. T3/T4 require no property-based tests and no mutation score; the T3 escape-hatch limit (<= 5 per file, justified) is met because the diff adds no `any`. Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Every test builds its own checkpoint through `_claude_state()` / `_state_with_receipts()` (Python) and `claudeState()` / `withReceipts()` (TypeScript). No module-level mutable state is mutated. |
| **Isolation** - Each test targets single behavior | PASS | One test per behaviour-matrix row: absent keys, Codex flag, present `null`, independent per-key gate, index preservation. |
| **Fast Execution** - Tests complete quickly | PASS | Reviewer re-run: 68 pytest tests in 0.85s; 5 Jest suites (68 tests) completed in seconds. |
| **Determinism** - Consistent results | PASS | Pure in-memory JSON validation; no clock, randomness, network, or filesystem. Receipts are built by the deterministic resolvers `resolve_codex_deployment` / `resolveCodexTopology`. |
| **Readability & Maintainability** - Clear structure | PASS | Named error-string constants shared within each file; descriptive test names and docstrings. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Python baseline 91.76% lines / 84.38% branches (`evidence/baseline/baseline-python-per-file-coverage.2026-10-16T00-33.md`); TypeScript baseline 98.31% lines / 93.8% branches (`evidence/baseline/baseline-typescript-test-coverage.2026-10-16T00-38.md`). |
| **No Coverage Regression** | PASS | Python 92.55% / 86.00% (+0.79 / +1.62 points); TypeScript 98.36% / 94.06% (+0.05 / +0.26 points). `evidence/qa-gates/coverage-delta-verification.2026-10-16T01-16.md`. |
| **New Code Coverage** | PASS (Python), FAIL (TypeScript artifact) | Python: zero added executable lines in `missing_lines`; zero missing arcs from lines 285/287, cross-checked against `artifacts/python/lcov.info`. TypeScript: the text reporter shows no added line uncovered, but the mandatory `lcov.info` artifact is absent (PA-1). |
| **Comprehensive Coverage** | PASS | `_validate_feature_model_receipt` (new), `_validate_ready_features`, `validateReadyFeatures`, and the call sites are exercised by the new suites in both runtimes. |
| **Positive Flows** - Valid inputs | PASS | `test_ready_gate_skips_feature_receipts_when_keys_absent` and its TypeScript twin: a Claude-shaped checkpoint yields only the repository-context error. |
| **Negative Flows** - Invalid inputs | PASS | Present-`null` receipts (`test_ready_gate_validates_present_null_feature_receipt`, 2 cases) and wrong `logical_agent` (`test_ready_gate_gates_each_feature_receipt_independently`). |
| **Edge Cases** - Boundary conditions | PASS | Index preservation when `features[0]` is receipt-less and `features[1].topology_receipt` is `null`; each Codex flag alone. |
| **Error Handling** - Error paths | PASS | Exact error strings asserted for every armed check; `test_readiness_requires_resolved_child_model_receipt` changed from substring to exact match. |
| **Concurrency** - If applicable | N/A | Pure synchronous validation. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 91.76% lines, 84.38% branches -> Post-change: 92.55% lines, 86.00% branches. Change: +0.79 line points, +1.62 branch points. New/changed-code coverage: 100% of added executable lines. Repo-wide figure from `artifacts/python/lcov.info`: 92.55% lines / 86.00% branches (the artifact measures only `validate_epic_planner_state.py`; see non-blocking finding PA-N2). Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/final-python-per-file-coverage.2026-10-16T01-08.md`.
- TypeScript: Baseline: 98.31% lines, 93.8% branches -> Post-change: 98.36% lines, 94.06% branches (text reporter). Change: +0.05 line points, +0.26 branch points. New/changed-code coverage: 100% of added executable lines (text reporter; not artifact-verified). Repo-wide (text-summary): 97.26% lines, 92.29% branches. Disposition: FAIL - coverage artifact absent for TypeScript; coverage verification is mandatory for all languages with changed files (PA-1). Evidence: `evidence/qa-gates/final-typescript-test-coverage.2026-10-16T01-13.md`; `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` not found (`find . -name lcov.info -not -path "*/node_modules/*"` returns only `./artifacts/python/lcov.info`).
- PowerShell: N/A - zero changed files on the branch.
- C#: N/A - zero changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Exact-string membership and list-equality assertions (`assert expected in errors`, `toContain`, `toEqual([])`) show the full error list on failure. |
| **Arrange-Act-Assert Pattern** | PASS | Each test builds the state, calls the validator once, then asserts, with blank-line separation. |
| **Document Intent** | PASS | Every Python test has a docstring; TypeScript `it` titles state the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | None. No filesystem, network, or subprocess. |
| **Use Mocks/Stubs** | N/A | No mocking required; tests call pure functions. |
| **Environment Stability** | PASS | No temporary files, no global state, no environment variables. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the pre-submission policy review. Outstanding item: PA-1. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` and `spec.md` state the remaining #543 gap left by PRs #829 and #874. |
| **Read existing change plans** | PASS | `research/research.2026-10-15T08-05.md` and `evidence/baseline/phase0-instructions-read.2026-10-16T00-29.md`. |
| **Document the plan** | PASS | `plan.2026-10-15T07-42.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One membership predicate per check, reusing the existing activation value (research Candidate A). |
| **Reusability** | PASS | Python extracts `_validate_feature_model_receipt`; the existing receipt validators are reused unchanged. |
| **Extensibility** | PASS | Python `key_gated` is keyword-only with a fail-closed default `False`. |
| **Separation of concerns** | PASS | Pure validation logic only; no I/O added. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Changes remain in the existing validator modules; new tests are separate files mirroring the source layout. |
| **Under 500 lines** | PASS | 397, 488, 429, 204, 199, 246 lines (`evidence/qa-gates/line-counts-final.2026-10-16T01-17.md`). |
| **Public vs internal** | PASS | No exported or public signature changed; `_validate_feature_model_receipt` is private; `validateReadyFeatures` is module-internal (`evidence/qa-gates/final-typescript-contract.2026-10-16T01-14.md`, `final-python-contract.2026-10-16T01-09.md`). |
| **No circular dependencies** | PASS | No new imports in production code. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `key_gated`, `keyGated`, `_validate_feature_model_receipt`. The TypeScript call site passes `requireLaunchPaths`, whose name no longer describes everything it gates (non-blocking PA-N3). |
| **Docs/docstrings** | PASS | Docstrings and comments updated in both runtimes (`evidence/qa-gates/docs-updated.2026-10-16T01-06.md`). |
| **Comment why, not what** | PASS | Comments state the gating rule and its Codex-flag exception. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `poetry run black --check` (3 files unchanged); `npx prettier --check` (3 files). Reviewer re-run: exit 0. |
| **2. Linting** | PASS | `poetry run ruff check` (All checks passed); `npm --prefix extensions/drm-copilot run lint` exit 0. |
| **3. Type checking** | PASS | `poetry run pyright` (0 errors, 0 warnings); `npm --prefix extensions/drm-copilot run typecheck` exit 0. |
| **4. Architecture boundaries** | PASS | No dependency-cruiser or import-linter configuration applies (`evidence/qa-gates/final-python-architecture.2026-10-16T01-07.md`, `final-typescript-architecture.2026-10-16T01-13.md`). |
| **5. Testing** | PASS | Python full suite 7100 passed (1 deselected, #510 local-only); TypeScript 4009 passed. |
| **6. Contract** | PASS | No exported API change (contract evidence files). |
| **7. Integration** | PASS | `evidence/qa-gates/final-typescript-integration.2026-10-16T01-14.md` includes `test/mcp-server-epic-validation.test.ts`. |
| **Full toolchain loop** | PASS | Loop iteration 1 recorded for every final stage (`evidence/qa-gates/final-qa-clean-pass.2026-10-16T01-17.md`). |
| **Explicit reporting** | PARTIAL | Commands and results are recorded, but the TypeScript coverage stage did not emit the required `lcov.info` artifact (PA-1). |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages and `spec.md`. |
| **Design choices explained** | PASS | `spec.md` Proposed Fix and research Candidate A. |
| **Update supporting documents** | PASS | In-file docstrings and comments; no external docs needed. |
| **Provide next steps** | PASS | AC18 deferred to S9 per spec. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check <3 files>`<br>**Result:** 3 files would be left unchanged (reviewer re-run). |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check <3 files>`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <3 files>`<br>**Result:** 0 errors, 0 warnings, 0 informations. |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest --no-cov -q <4 epic-planner test files>`<br>**Result:** 68 passed (reviewer); 78 passed with coverage and 7100 full suite (executor evidence). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | All new signatures annotated; `dict[str, Any]` follows the existing module pattern for JSON payloads (T4). |
| **Dataclasses for value objects** | N/A | No value objects introduced. |
| **Protocols/ABCs for interfaces** | N/A | No interfaces introduced. |
| **Avoid utility classes** | PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | Validator returns error strings; no exception handling changed. |
| **Logging over print** | PASS | No `print` added. |
| **Invariants at construction** | N/A | No classes introduced. |
| **Suppressions** | PASS | Two `# noqa: S105 - test fixture data` in the new test file use the pre-authorized format in `.claude/rules/python-suppressions.md` (S108/S105 tests-only). |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | `npx --prefix extensions/drm-copilot prettier --check <3 files>`: All matched files use Prettier code style. |
| **Linting with ESLint** | PASS | `npm --prefix extensions/drm-copilot run lint`: exit 0. |
| **Type checking with tsc** | PASS | `npm --prefix extensions/drm-copilot run typecheck`: exit 0 (src and test configs). |
| **No untyped escape hatches** | PASS | No `any`, `as unknown as`, `@ts-ignore`, or `eslint-disable` added. |
| **Coverage artifact** | FAIL | `coverage/lcov.info` absent (PA-1). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `pytest.mark.parametrize` with ids; no other framework. |
| **Coverage expectation** | PASS | 92.55% lines / 86.00% branches for the changed module (>= 85 / >= 75). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One behaviour per test. |
| **Mocking sparingly** | PASS | No mocks. |
| **Organization** | PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_ready_gate_<behaviour>` naming. |
| **Docstrings/comments** | PASS | One-line docstring per test and helper. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest`<br>**Result:** pass. |
| **No Alternative Test Runners** | PASS | Pytest only. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | PASS | `@jest/globals`, `it.each` for flag and null-key matrices. |
| **Organization** | PASS | `extensions/drm-copilot/test/lib/validate/` mirrors `src/lib/validate/`. |
| **Determinism** | PASS | No timers, no `Date.now()`, no I/O. |
| **Coverage expectation** | FAIL | Text reporter figures pass (98.36% / 94.06%), but the required artifact is absent (PA-1). |

---

## 5. Test Coverage Detail

### `_validate_ready_features` / `validateReadyFeatures` per-feature receipt gate (7 Python cases, 7 TypeScript cases, 1 extended MCP test)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_ready_gate_skips_feature_receipts_when_keys_absent` / TS twin | Positive | Python 285, 287 false branches; TS 335, 363 false branches | PASS |
| `test_codex_flag_keeps_feature_receipts_unconditional[require_codex_model_routing]` / `[require_codex_topology]` / TS `it.each` | Edge Case | `not key_gated` true path | PASS |
| `test_ready_gate_validates_present_null_feature_receipt[model_routing_receipt]` / `[topology_receipt]` / TS `it.each` | Negative | key-present path with `null` | PASS |
| `test_ready_gate_gates_each_feature_receipt_independently` / TS twin | Negative | model path armed, topology path skipped | PASS |
| `test_ready_gate_preserves_feature_index_when_receipts_skipped` / TS twin | Edge Case | skip on index 0, armed on index 1 | PASS |
| `test_readiness_requires_resolved_child_model_receipt` (updated) | Negative | Codex-flag path with exact string | PASS |
| `threads the Codex flags into epic-planner-state` (extended) | Integration | MCP service call threading | PASS |

**Coverage:** Python `validate_epic_planner_state.py` 92.55% lines / 86.00% branches; TypeScript `epic-planner-state-core.ts` 98.36% lines / 94.06% branches (text reporter).

**Not covered:** Python missing lines 121, 127, 143-144, 149-150, 152, 154, 156, 189, 271, 280, 282, 346 and TypeScript uncovered 69-70, 75-76, 78-79, 273-274 are all pre-existing context lines outside the added hunks.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Python 7100 full suite; TypeScript 4009 | PASS |
| Tests Passed | 100% of executed | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Python full suite 51.51s; targeted 0.85s | PASS |
| Average Time per Test | about 12ms (targeted Python) | PASS |
| Discovery Time | Not separately recorded | N/A |
| Functions/Classes Tested | 3/3 changed functions (`_validate_feature_model_receipt`, `_validate_ready_features`, `validateReadyFeatures`) plus both call sites | PASS |
| Test File Size | 204 and 199 lines (new) | PASS |
| Code Coverage | Python 92.55% lines, 86.00% branches; TypeScript 98.36% lines, 94.06% branches (no lcov artifact) | Python PASS; TypeScript FAIL (PA-1) |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <3 files>` | 3 unchanged | PASS |
| Ruff Linting | `poetry run ruff check <3 files>` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright <3 files>` | 0 errors | PASS |
| Pytest Tests | `poetry run pytest --no-cov -q <4 files>` | 68 passed | PASS |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx --prefix extensions/drm-copilot prettier --check <3 files>` | clean | PASS |
| ESLint | `npm --prefix extensions/drm-copilot run lint` | exit 0 | PASS |
| tsc | `npm --prefix extensions/drm-copilot run typecheck` | exit 0 | PASS |
| Jest | `npm --prefix extensions/drm-copilot test -- <5 suites>` | 68 passed | PASS |
| Coverage artifact | `coverage/lcov.info` | absent | FAIL |

**For PowerShell:** N/A - no PowerShell files changed.

**Notes:** The Python full suite deselects `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, the local-only failure tracked in #510 (closed); CI runs it.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (FAIL, blocking, autonomous): TypeScript coverage artifact absent.** `coverage/lcov.info` (and the jest-configured `extensions/drm-copilot/coverage/lcov.info`) does not exist. The final TypeScript coverage run passed `--coverageReporters=text --coverageReporters=text-summary`, which replaces the `lcov` reporter configured in `extensions/drm-copilot/jest.config.cjs` line 18. Coverage verification is mandatory for every language with changed files and is performed from the artifact. Remediation: run `npm --prefix extensions/drm-copilot run test:coverage` (configured reporters `lcov` and `text-summary`), confirm `extensions/drm-copilot/coverage/lcov.info` exists, and record the repo-wide and `src/lib/validate/epic-planner-state-core.ts` line and branch figures from it under `evidence/qa-gates/`.

Non-blocking findings (no remediation required for merge):

- **PA-N1 (Info, same feature):** AC18 (PR closes #543, CI success on final head) is CI-dependent and pending; it is checked off at S9.
- **PA-N2 (Minor, same feature):** `artifacts/python/lcov.info` contains one `SF:` record (`validate_epic_planner_state.py`), so it does not provide a repository-wide Python figure. The changed file meets the thresholds; regenerating with `--cov=scripts` alongside PA-1 would give a repository-wide figure.
- **PA-N3 (Nit, same file as this change):** the TypeScript call site passes `requireLaunchPaths` as `keyGated`; the variable now governs receipt checks too. The spec mandated this form.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented. The #510 deselection is a pre-existing local-only exclusion, not a removed test.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **0349ed1f0** - docs(543): add active feature folder
2. **f563cb655** - docs(543): add research
3. **e0e44e872** - docs(543): add spec
4. **4febfc0f2** - docs(543): add atomic plan
5. **3d9a1ee59** - docs(543): revise plan after preflight round 1
6. **97943a7ca** - docs(543): add preflight directive line to plan
7. **0c1a92873** - Merge remote-tracking branch 'origin/main'
8. **b26989010** - docs(543): record plan and phase 0 baselines
9. **ddbfccc19** - test(543): add fail-before regression tests
10. **7a666794c** - fix(543): key-gate per-feature receipt checks in Python planner ready gate
11. **490ff104b** - fix(543): key-gate per-feature receipt checks in TypeScript planner ready gate
12. **89ea41d31** - test(543): cover per-feature receipt key gate matrix in Python
13. **5b1bbbedd** - test(543): cover per-feature receipt key gate matrix in TypeScript and MCP
14. **4192c9504** - docs(543): record verification evidence
15. **b033e0e8c** - docs(543): record Python final QA evidence
16. **90d67f210** - docs(543): record TypeScript final QA evidence
17. **5e3387161** - docs(543): record acceptance check-off

### Files Modified

1. **scripts/dev_tools/validate_epic_planner_state.py** (MODIFIED) - extracts `_validate_feature_model_receipt`; adds keyword-only `key_gated` to `_validate_ready_features`; gates each receipt block on key membership; docstring and comment updates.
2. **extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts** (MODIFIED) - adds `keyGated` parameter to `validateReadyFeatures`; wraps each receipt block in `if (!keyGated || "<key>" in feature)`; passes `requireLaunchPaths`.
3. **tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py** (NEW) - behaviour-matrix tests.
4. **extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts** (NEW) - TypeScript twin tests.
5. **tests/scripts/dev_tools/test_validate_epic_planner_state.py** (MODIFIED) - defect-pinning test passes `require_codex_model_routing=True` and asserts the exact string.
6. **extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts** (MODIFIED) - six added assertions on Codex-flag and key-gated results.
7. **docs/features/active/epic-planner-receipt-checks-key-gate-543/** (NEW) - issue, spec, research, plan, 57 evidence files.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Code, tests, toolchain, file size, suppressions, evidence locations, and tier rules comply. One FAIL remains: PA-1, the absent TypeScript coverage artifact.

**Fail-closed reminder:** The audit is not marked PASS because a required coverage artifact is missing.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: research, spec, and plan present.
- PASS Design Principles: minimal predicate reuse.
- PASS Module & File Structure: all files <= 500 lines.
- PASS Naming, Docs, Comments: updated in both runtimes.
- PARTIAL Toolchain Execution: all seven stages pass; TypeScript coverage artifact absent.
- PASS Summarize & Document: commits and spec.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline
- PASS Python Design & Typing
- PASS Error Handling

**For TypeScript:**
- PASS Tooling (Prettier, ESLint, tsc)
- FAIL Coverage artifact (PA-1)

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PARTIAL Coverage & Scenarios: scenarios complete; TypeScript artifact absent.
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

**For TypeScript:**
- PASS Framework, Style, Naming
- FAIL Coverage artifact (PA-1)

---

### Metrics Summary

- PASS 7100/7100 executed Python tests and 4009/4009 TypeScript tests passing
- PASS 3/3 changed functions tested in both runtimes
- PASS Python 92.55% line / 86.00% branch coverage for the changed module (artifact-verified)
- FAIL TypeScript coverage not artifact-verified (text reporter shows 98.36% / 94.06%)
- PASS All format, lint, and type checks passing
- PASS Targeted test execution under 1 second (Python)

---

### Recommendation

**Needs revision**

Regenerate the TypeScript coverage with the configured `lcov` reporter, record the artifact-derived figures under `evidence/qa-gates/`, and re-audit. No production or test code change is expected.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_skips_feature_receipts_when_keys_absent`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_codex_flag_keeps_feature_receipts_unconditional[require_codex_model_routing]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_codex_flag_keeps_feature_receipts_unconditional[require_codex_topology]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_validates_present_null_feature_receipt[model_routing_receipt]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_validates_present_null_feature_receipt[topology_receipt]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_gates_each_feature_receipt_independently`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_preserves_feature_index_when_receipts_skipped`
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_resolved_child_model_receipt` (updated)
- validateEpicPlannerStateText per-feature receipt key gate › skips the per-feature receipts when the keys are absent without a Codex flag
- validateEpicPlannerStateText per-feature receipt key gate › keeps the per-feature receipts unconditional under %p (2 cases)
- validateEpicPlannerStateText per-feature receipt key gate › validates a present null %s without a Codex flag (2 cases)
- validateEpicPlannerStateText per-feature receipt key gate › gates each per-feature receipt independently
- validateEpicPlannerStateText per-feature receipt key gate › preserves the feature index when receipts are skipped
- validateOrchestrationServiceCall › threads the Codex flags into epic-planner-state (extended)

---

## Appendix B: Toolchain Commands Reference

Reviewer-executed (worktree root, 2026-10-16):

```bash
git diff --stat adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99..HEAD
git diff --name-status adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99..HEAD -- . ":!docs"
poetry run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
poetry run ruff check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
poetry run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
poetry run pytest --no-cov -q tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
npx --prefix extensions/drm-copilot prettier --check extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot test -- test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/validate-orchestration-service-call.test.ts
find . -name lcov.info -not -path "*/node_modules/*"
grep -E "^(LF|LH|BRF|BRH):" artifacts/python/lcov.info
```

Remediation command for PA-1:

```bash
npm --prefix extensions/drm-copilot run test:coverage
```

**For PowerShell:** not run; no PowerShell files changed.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)

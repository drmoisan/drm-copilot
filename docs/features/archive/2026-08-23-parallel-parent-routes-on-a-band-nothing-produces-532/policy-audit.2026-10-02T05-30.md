# Policy Compliance Audit: Parallel planner ready-gate invariant P10 routing record (#532)

---

**Audit Date:** 2026-10-02
**Branch:** `bug/parallel-parent-routes-on-a-band-nothing-produces-532` @ `601675fbd23a17cfb5a95f390d91569fcbb05f38`
**Base:** `main` (resolved `origin/main` @ `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`); merge-base `74e1d6741485aa38c28fecbbc77ea169f31df0ef`
**Diff anchor:** `git diff 74e1d674...HEAD` (85 files, +3418/-112)
**Review pass:** 1
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, read from the repository resources folder; the template instruction block is removed.

**Code Under Test:**

- Python production: `scripts/dev_tools/_parallel_planner_state_routing.py` (NEW), `scripts/dev_tools/validate_parallel_planner_state.py` (MODIFIED)
- Python tests and test support: `tests/scripts/dev_tools/parallel_planner_state_builders.py` (NEW, support module), `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py` (NEW), `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py` (NEW), `tests/scripts/dev_tools/test_validate_parallel_planner_state.py` (MODIFIED)
- TypeScript production: `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts` (NEW), `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts` (MODIFIED)
- TypeScript tests, support, and config: `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` (NEW), `parallel-planner-state-core.test.ts`, `parallel-state-tolerated-edge-fields.test.ts`, `parallel-state-test-support.ts` (MODIFIED), `extensions/drm-copilot/jest.config.cjs` (MODIFIED, threshold entry)
- Markdown runtime text: six `.claude` files and their six byte-identical bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/`
- Feature documentation and evidence under `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 6 files (2 production, 4 test) | 136 targeted, 6474 full suite | PASS 136 pass, 0 fail; full suite 6474 pass, 0 fail, 6 skipped | 100.00% lines, 100.00% branches (validate_parallel_planner_state.py, 112/112 lines, 46/46 branches) | 100.00% lines, 100.00% branches (validate_parallel_planner_state.py 115/115, 46/46; routing module 50/50, 16/16) | 100.00% (new module 50/50 lines, 16/16 branches; changed executable lines 0 uncovered) |
| TypeScript | 7 files (2 production, 4 test/support, 1 config) | 3808 full Jest suite | PASS 3808 pass, 0 fail | 97.07% lines, 91.35% branches (package); core 100% lines, 97.95% branches | 97.09% lines, 91.37% branches (package); core 100% lines, 97.95% branches | 100% lines, 92.59% branches (new routing module 225/225 lines, 25/27 branches; changed executable lines 0 uncovered) |
| PowerShell | 0 files | N/A | N/A (no PowerShell file changed) | N/A - no PowerShell file changed | N/A - no PowerShell file changed | N/A - no PowerShell file changed |
| Markdown | 72 files (12 runtime text, 60 feature docs and evidence) | 7 contract tests + 74 existing surface/parity tests | PASS 81 pass, 0 fail | N/A - documentation | N/A - documentation | N/A - documentation |

### Coverage Evidence Checklist

- Python baseline coverage artifact: `artifacts/python/coverage-532-baseline.json` (local, gitignored), recorded in `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/evidence/baseline/python-pytest-coverage.2026-10-02T04-29.md`
- Python post-change coverage artifact: `artifacts/python/coverage-532-final.json` and `artifacts/python/lcov.info` (local, gitignored), recorded in `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/evidence/qa-gates/python-pytest-coverage.2026-10-02T05-19.md`
- TypeScript baseline coverage artifact: `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/evidence/baseline/ts-jest-coverage.2026-10-02T04-29.md` (figures read from `extensions/drm-copilot/coverage/coverage-summary.json` at baseline time)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/coverage-summary.json` and `extensions/drm-copilot/coverage/lcov.info` (local, gitignored), recorded in `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532/evidence/qa-gates/ts-jest-coverage.2026-10-02T05-19.md`
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Per-language comparison summary: section 1.2.1 of this audit; delta artifacts `evidence/qa-gates/python-coverage-delta.2026-10-02T05-19.md` and `evidence/qa-gates/ts-coverage-delta.2026-10-02T05-19.md`

---

## Executive Summary

The branch adds ready-gate invariant P10 to the parallel planner checkpoint validators. A new pure Python helper (`_parallel_planner_state_routing.py`) validates each item's `complexity_band`, `complexity_assessment`, and `model_routing_receipt` under `require_ready_for_execution`, reusing the Claude helpers `_validate_complexity_assessments`, `_validate_model_routing_receipts`, and `BAND_ORDER`. A TypeScript structural-subset port (`parallel-planner-state-routing.ts`) emits byte-identical strings for the resolver-free checks. Six runtime Markdown files and their bundled mirrors name the band and receipt source for the parallel parent.

**Policy documents evaluated:**
- PASS `CLAUDE.md` and `.claude/rules/tonality.md`
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` maps `scripts/dev_tools` to T4 and `extensions/drm-copilot` to T3)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md`
- PASS `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md`
- N/A PowerShell (no PowerShell file changed; Pester suites that read a changed Markdown file are tracked as pending CI evidence)
- N/A Bash, JSON, C#

Toolchain results (executor evidence, independently re-run by this review where check-only): Black, Ruff, Pyright, Prettier, and the targeted Pytest and Jest suites pass. Coverage on new and changed production files meets the uniform 85% line / 75% branch thresholds with no regression. The only open item is the CI poshqc confirmation for the two Pester suites that read `.claude/skills/parallel-orchestrate/SKILL.md` (DEV-2), which holds AC-30, AC-35, and plan tasks P5-T24, P6-T32, P7-T10, and P7-T17. That item is classified as a non-blocking PARTIAL pending CI.

**Blocking findings in this artifact: 0** (FAIL: 0; blocking PARTIAL: 0). Non-blocking PARTIAL: 1 (PA-1, pending CI).

**Temporary artifacts cleanup:**
- PASS No temporary or one-time script is committed on the branch. DEV-2 records that the plan's scratchpad Pester wrapper was never created.
- PASS No new tooling script was added outside the tested modules listed above.

---

## Rejected Scope Narrowing

No scope narrowing was detected. The caller directives evaluated were:

- "Base for review: main. Diff the branch against the merge-base 74e1d6741485aa38c28fecbbc77ea169f31df0ef" — consistent with the resolved merge-base; accepted.
- "Mark the PowerShell lines N/A, because no PowerShell file is changed" — verified against the branch diff (`git diff --name-only 74e1d674...HEAD` lists no `.ps1`, `.psm1`, or `.psd1` path); accepted because PowerShell has zero changed files.
- "Classify them as pending CI evidence (non-blocking PARTIAL), not as FAIL, unless you find a substantive defect" — a classification directive, not a scope reduction; this audit found no substantive defect in the held items and applied the classification.

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported path.
- Command: `git diff --name-only 74e1d674...HEAD -- artifacts/` printed no path. No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` is part of the branch diff.
- All committed evidence lives under `<FEATURE>/evidence/{baseline,regression-testing,qa-gates,other,remediation-baseline}/`. Superseded attempts are under `evidence/remediation-baseline/superseded/` with a README.
- The raw coverage outputs `artifacts/python/coverage-532-*.json`, `artifacts/python/lcov.info`, and `extensions/drm-copilot/coverage/*` are gitignored tool outputs at the canonical coverage-artifact locations, not committed evidence.

Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entry was required.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each Python test builds a fresh checkpoint through `build_valid_planner_state()`; `build_routing_fields()` returns `copy.deepcopy(_ROUTING_FIELDS)`. Each TS case calls `buildValidPlannerState()` or `buildPlannerRoutingFields()`, which return new object literals. No shared mutable module state. |
| **Isolation** - Each test targets single behavior | PASS | One P10 check per Python test function (18 functions) or per parametrized row (12 rows); TS mirrors this with 22 cases, including direct calls of `validateReadyItemRouting`. |
| **Fast Execution** - Tests complete quickly | PASS | Python routing suite 29 cases in 0.08s; targeted Python run 217 cases in 0.76s (this review); TS three suites 110 cases in 0.394s (this review). |
| **Determinism** - Consistent results | PASS | Pure functions over JSON literals; no clock, RNG, network, filesystem write, or timer use. The contract tests read committed repository Markdown only. |
| **Readability & Maintainability** - Clear structure | PASS | Arrange/Act/Assert comments in every Python test; module docstrings in all new test files; named literal constants shared between suites. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Python baseline 100.00% lines (112/112), 100.00% branches (46/46) for `validate_parallel_planner_state.py`; TS baseline core 100% lines, 97.95% branches, package 97.07% / 91.35%. Timestamp 2026-10-02T04-29, before any code change (commit `5dca560d`). |
| **No Coverage Regression** | PASS | Python validator 100.00% -> 100.00% lines and branches (+0.00); TS core 100% -> 100% lines, 97.95% -> 97.95% branches (+0.00); TS package +0.02 points lines and branches. Changed executable lines with zero hits: 0 in both languages. |
| **New Code Coverage at or above threshold** | PASS | `_parallel_planner_state_routing.py` 50/50 lines = 100.00%, 16/16 branches = 100.00%; `parallel-planner-state-routing.ts` 225/225 lines = 100%, 25/27 branches = 92.59%. Uniform threshold is 85% line / 75% branch. |
| **Comprehensive Coverage** | PASS | `validate_ready_item_routing`, `_validate_assessment`, `_validate_receipt`, `_hashable_entry`, `_rewrite_prefix` all exercised; TS `validateReadyItemRouting`, `validateAssessment`, `validateAssessmentEntry`, `validateReceipt`, `sameValue`, `isListOfStrings` exercised. Uncovered: two nullish-coalescing branch arms in TS `sameValue` (line 60), see section 8. |
| **Positive Flows** - Valid inputs | PASS | `test_ready_gate_accepts_item_with_valid_routing_record`, `test_gate_off_accepts_item_without_routing_fields`, `test_routing_fields_and_kickoff_path_are_optional_off_the_gate`; TS equivalents plus a direct-call valid case. |
| **Negative Flows** - Invalid inputs | PASS | All ten FR2 checks have a dedicated negative test with an exact expected string. |
| **Edge Cases** - Boundary conditions | PASS | Band `C9` reporting check 1 twice and both mismatches; string-valued assessment and receipt; list-valued bands (DEV-8); whitespace-only rationale; empty `assessed_at`. |
| **Error Handling** - Error paths | PASS | Validators return error lists and never raise; list-valued band inputs that previously raised `TypeError` in the reused helpers are covered by two parametrized rows in each language. |
| **Concurrency** - If applicable | N/A | Pure synchronous validators with no shared state. |
| **State Transitions** - If applicable | PASS | Gate-off versus gate-on transitions are covered; P10-after-P7 ordering is pinned by `test_p10_errors_follow_p7_errors_for_same_item` and the TS ordering case. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 100.00% lines, 100.00% branches (validate_parallel_planner_state.py 112/112, 46/46) -> Post-change: 100.00% lines, 100.00% branches (validate_parallel_planner_state.py 115/115, 46/46; scoped artifact total 165/165 lines, 62/62 branches). Change: +0.00% lines, +0.00% branches. New/changed-code coverage: 100.00% (new module 50/50 lines, 16/16 branches; 0 of 6 changed executable validator lines uncovered). Disposition: PASS. Evidence: `evidence/baseline/python-pytest-coverage.2026-10-02T04-29.md`, `evidence/qa-gates/python-pytest-coverage.2026-10-02T05-19.md`, `evidence/qa-gates/python-coverage-delta.2026-10-02T05-19.md`, `artifacts/python/lcov.info`.
- TypeScript: Baseline: 97.07% lines, 91.35% branches (package); core 100% lines, 97.95% branches -> Post-change: 97.09% lines, 91.37% branches (package); core 100% lines, 97.95% branches. Change: +0.02% lines, +0.02% branches (package); +0.00% lines, +0.00% branches (core). New/changed-code coverage: 100% lines, 92.59% branches (new routing module 225/225, 25/27; 0 of 4 changed executable core lines with a zero-hit DA record). Disposition: PASS. Evidence: `evidence/baseline/ts-jest-coverage.2026-10-02T04-29.md`, `evidence/qa-gates/ts-jest-coverage.2026-10-02T05-19.md`, `evidence/qa-gates/ts-coverage-delta.2026-10-02T05-19.md`, `extensions/drm-copilot/coverage/coverage-summary.json`.
- PowerShell: Baseline: N/A -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A - out of scope. Disposition: N/A. Evidence: branch diff contains zero PowerShell files.

Coverage verdict per language with changed files: Python PASS; TypeScript PASS. PowerShell has zero changed files.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Python assertions pass the full error list as the assertion message (`assert X in errors, errors`); TS uses `toEqual`/`toContain` with literal expectations. The recorded fail-before output shows the actual list (`AssertionError: []`). |
| **Arrange-Act-Assert Pattern** | PASS | Explicit `# Arrange`, `# Act`, `# Assert` comments in every new Python test; TS cases follow the same three-block layout. |
| **Document Intent** | PASS | Every Python test has a one-line docstring naming the check; TS case names state the expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No database, network, process, or remote API use. Contract tests read committed Markdown under the repository root. |
| **Use Mocks/Stubs** | N/A | Pure functions; no mock is needed. Builders supply fixtures. |
| **Environment Stability** | PASS | No temporary file creation (`grep` for `tempfile`, `tmp_path`, `mkdtemp`, `NamedTemporaryFile`, `os.tmpdir` over the changed test files returned no match). No global state or environment-variable reads. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the pass-1 policy audit for the branch. Outstanding item: PA-1 (CI poshqc confirmation), non-blocking. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `spec.md` Problem Statement and Root Cause; issue #532. |
| **Read existing change plans** | PASS | `research/research.2026-09-29T19-50.md`; plan revised through five preflight rounds (commits `4cffc110` to `c1289a6b`). |
| **Document the plan** | PASS | `plan.2026-09-29T15-46.md` with Fixed Values, per-task acceptance, and named deviations DEV-1 to DEV-9 in evidence. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | One public function per language; checks run in a flat table order; no class hierarchy. |
| **Reusability** | PASS | Python reuses `_validate_complexity_assessments`, `_validate_model_routing_receipts`, `BAND_ORDER`, `enum_error`, `is_non_empty_string`; floor and model formulas are not reimplemented. TS reuses `enumError`, `isEnumMember`, `isNonEmptyString`, `isObject`, `pythonRepr`, `pythonStr`. |
| **Extensibility** | PASS | The routing helper is called per item from the ready gate; additional checks can be appended without touching P7. |
| **Separation of concerns** | PASS | Routing logic is pure and isolated from JSON parsing and CLI dispatch. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Routing modules hold only P10; builders module holds only checkpoint builders. |
| **Under 500 lines** | PASS | Re-counted by this review: 251, 461, 97, 462, 448, 188 (Python); 225, 464, 278, 446, 195, 242, 398 (TS/config). Maximum 464. |
| **Public vs internal** | PASS | Python exposes `validate_ready_item_routing`; helpers are underscore-prefixed. TS exports only `validateReadyItemRouting`. |
| **No circular dependencies** | PASS | The TS routing module imports only `./parallel-state-shared` (grep for `parallel-planner-state-core` in it returns no match). The Python builders module does not import the test module that re-exports it. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `validate_ready_item_routing`, `ROUTING_AGENT`, `VALID_FABLE_POLICIES`, `_hashable_entry`. |
| **Docs/docstrings** | PASS | Python module docstring (Purpose/Flow/Invariants) and Google-style docstrings with Args/Returns/Raises/Side Effects on every function; TS header comment records the divergence, TSDoc on every function. |
| **Comment why, not what** | PASS | Comments explain why checks 5 and 9 are reported after a failed check 1 and why `_hashable_entry` exists. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `poetry run black --check` (6 files unchanged) and Prettier `--check` (7 files) pass; re-run by this review with the same result. |
| **2. Linting** | PASS | `poetry run ruff check` (9 files) "All checks passed!"; `npm --prefix extensions/drm-copilot run lint` 0 problems. |
| **3. Type checking** | PASS | `poetry run pyright` 0 errors, 0 warnings, 0 informations (re-run by this review); `npm --prefix extensions/drm-copilot run typecheck` 0 errors. |
| **4. Architecture-boundary tests** | N/A | `evidence/qa-gates/toolchain-stage-applicability.2026-10-02T05-19.md`: no import-linter or dependency-cruiser is configured for these packages. |
| **5. Unit tests** | PASS | Python full suite 6474 passed, 6 skipped (pre-existing); Jest 251 suites, 3808 tests passed. |
| **6. Contract / schema checks** | N/A | No oasdiff or schema-diff tool is configured (same artifact). Text-contract tests for runtime Markdown pass (81 passed). |
| **7. Integration tests** | PASS | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py` runs in the targeted and full Python runs. |
| **Full toolchain loop** | PASS | `python-black` records "First pass of the Phase 7 loop; no restart was required"; one artifact per P7 gate in `evidence/qa-gates/`. The Pester half of P7-T10 is PA-1 (pending CI). |
| **Explicit reporting** | PASS | Every gate artifact carries Timestamp, Command, EXIT_CODE, and Output Summary; the regenerated PR context renders 36 verification rows, all normalized `pass`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages per phase (`5dca560d` through `601675fb`); section 9 below. |
| **Design choices explained** | PASS | Spec FR2/FR3 and the TS header comment record the structural-subset divergence; DEV-8 records the `_hashable_entry` rationale. |
| **Update supporting documents** | PASS | `.claude/rules/parallel-orchestration.md` defines P10 and the TS divergence; skills and agents name the band source. The rule edit was approved by the operator on 2026-09-30 and is not a policy violation. |
| **Provide next steps** | PASS | Spec Follow-ups 1 to 5; this audit adds one follow-up candidate (see section 8). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check <6 paths>`: "6 files would be left unchanged." |
| **Linting with Ruff** | PASS | `poetry run ruff check <9 paths>`: "All checks passed!" |
| **Type checking with Pyright** | PASS | `poetry run pyright <9 paths>`: "0 errors, 0 warnings, 0 informations". |
| **Testing with Pytest** | PASS | Targeted 136 passed; full suite 6474 passed, 6 skipped. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | All signatures typed; `grep` for `\bAny\b` in the new and changed Python files returns no match. `cast("dict[str, object]", ...)` is used after `isinstance` narrowing. No `type: ignore`, `pyright: ignore`, or `noqa` was added. |
| **Dataclasses for value objects** | N/A | The validator operates on parsed JSON dictionaries; no value object is introduced. |
| **Protocols/ABCs for interfaces** | N/A | A single implementation; no interface is warranted. |
| **Avoid utility classes** | PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | The helper returns errors and raises nothing; DEV-8 removed the only `TypeError` path (unhashable band values reaching `frozenset` membership in the reused helpers). |
| **Logging over print** | PASS | No `print` or logging added; validators return error lists by contract. |
| **Invariants at construction** | N/A | No class is constructed. |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | 7 paths "All matched files use Prettier code style!" (re-run by this review). |
| **Linting with ESLint** | PASS | `npm run lint`: 0 problems (baseline also 0). |
| **Type checking with tsc** | PASS | `npm run typecheck`: 0 errors for `tsconfig.json` and `tsconfig.jest.json`. |
| **No `any` / suppressions** | PASS | `grep` for `: any`, `as any`, `<any>`, `eslint-disable` in the changed TS files returns no match. Inputs are typed `unknown` and narrowed through `isObject`/`isEnumMember`. |
| **Tier escape-hatch budget (T3)** | PASS | Zero untyped escape hatches. |

### Section 3F: Markdown Runtime Text and Mirrors

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Mirror byte parity** | PASS | `cmp` re-run by this review on all six pairs: all identical. |
| **Governance-file edit approval** | PASS | `.claude/rules/parallel-orchestration.md` P10 edit approved by the operator on 2026-09-30 (caller context; DEV-3 evidence note in `mirror-parity-parallel-orchestration-rule.2026-10-02T04-54.md`). |
| **No Codex or `.agents` mirror created** | PASS | `evidence/qa-gates/scope-boundary-mirrors.2026-10-02T05-06.md`: empty `git status` for `.agents`, `.codex`, `.github`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `pytest.mark.parametrize` for the 12 shared-literal rows; no other runner. |
| **Coverage expectation** | PASS | New module 100.00% line and branch; modified validator 100.00% with no regression. Thresholds 85% line / 75% branch. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One behavior per test or parametrized row. |
| **Mocking sparingly** | PASS | No mocks. |
| **Organization** | PASS | Tests under `tests/scripts/dev_tools/` mirror `scripts/dev_tools/`; the builders module is a non-collected support module (`parallel_planner_state_builders.py`). |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_ready_gate_rejects_<condition>` pattern, matching spec AC names exactly. |
| **Docstrings/comments** | PASS | Module docstring and per-test docstrings present. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `poetry run pytest -q`: 6474 passed, 6 skipped. |
| **No Alternative Test Runners** | PASS | Pytest only. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | PASS | `it.each` for shared literals and divergence pins. |
| **Test location** | PASS | `extensions/drm-copilot/test/lib/validate/` mirrors `src/lib/validate/`; no colocated test. |
| **Coverage threshold gate** | PASS | `jest.config.cjs` adds a per-file `coverageThreshold` for `./src/lib/validate/parallel-planner-state-routing.ts` (lines 85, branches 75); the full Jest run exits 0 with that gate active. No production path was added to any coverage exclude list. |
| **Determinism infrastructure** | PASS | No timers, clocks, or randomness in the changed tests. |

---

## 5. Test Coverage Detail

### `scripts/dev_tools/_parallel_planner_state_routing.py` (18 test functions, 29 cases)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| test_ready_gate_rejects_item_without_band_assessment_or_receipt | Negative (checks 1, 2, 6; fail-before) | PASS |
| test_ready_gate_accepts_item_with_valid_routing_record | Positive | PASS |
| test_gate_off_accepts_item_without_routing_fields | Positive (gate off) | PASS |
| test_ready_gate_rejects_floor_that_disagrees_with_signals | Negative (check 3 floor) | PASS |
| test_ready_gate_rejects_band_below_floor | Negative (check 3 ordering) | PASS |
| test_ready_gate_rejects_receipt_model_that_disagrees_with_resolver | Negative (check 7 resolver) | PASS |
| test_ready_gate_rejects_disabled_policy_fable_model | Negative (check 7 clamp) | PASS |
| test_ready_gate_rejects_assessment_band_mismatch | Negative (check 5) | PASS |
| test_ready_gate_rejects_receipt_band_mismatch | Negative (check 9) | PASS |
| test_ready_gate_rejects_non_orchestrator_agent | Negative (check 8) | PASS |
| test_ready_gate_rejects_unknown_fable_policy | Negative (check 10) | PASS |
| test_ready_gate_rejects_non_object_assessment_and_receipt | Edge (skip rules) | PASS |
| test_ready_gate_rejects_missing_assessed_at | Negative (check 4) | PASS |
| test_band_mismatch_reported_when_item_band_invalid | Edge (C9) | PASS |
| test_p10_errors_follow_p7_errors_for_same_item | State/ordering | PASS |
| test_routing_helper_reuses_claude_helpers_only | Contract (imports by identity) | PASS |
| test_ready_gate_emits_shared_literal_strings (12 rows) | Negative and edge (shared literals, list values) | PASS |
| test_required_item_keys_unchanged | Contract (REQUIRED_ITEM_KEYS) | PASS |

**Coverage:** 100.00% lines (50/50), 100.00% branches (16/16). **Not covered:** None.

### `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts` (22 cases)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| rejects an item without band, assessment, or receipt under the ready gate (fail-before) | Negative | PASS |
| accepts an item with a valid routing record under the ready gate | Positive | PASS |
| accepts items without the routing fields with the gate off | Positive | PASS |
| reports both band mismatches and check 1 twice when the item band is C9 | Edge | PASS |
| reports only checks 2 and 6 for string-valued assessment and receipt | Edge | PASS |
| reports every P7 error for an item before its P10 errors | Ordering | PASS |
| emits the shared literal when ... (12 rows) | Negative and edge | PASS |
| returns no errors when called directly on a valid routing record | Positive | PASS |
| pins the documented divergence ... (3 rows) | Divergence pin | PASS |

**Coverage:** 100% lines (225/225), 92.59% branches (25/27). **Not covered:** two nullish-coalescing arms on line 60 (`sameValue` with an absent assessment band or absent item band while the nested object is present); non-blocking, see section 8.

### Runtime text contracts (`tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py`, 7 tests)

All seven tests named in AC-22 to AC-28 pass, together with 74 existing surface and bundle-parity tests (81 passed).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Python full suite | 6474 passed, 0 failed, 6 skipped (pre-existing) | PASS |
| Python targeted (5 planner suites) | 136 passed | PASS |
| Python surface, contract, and parity | 81 passed | PASS |
| Jest full suite | 251 suites, 3808 tests passed | PASS |
| Jest routing, core, tolerated-edge | 110 passed in 0.394s | PASS |
| Pester suites reading parallel-orchestrate SKILL.md | Pending CI poshqc (DEV-2) | PARTIAL (non-blocking, PA-1) |
| Largest changed code file | 464 lines | PASS |
| New-code coverage | Python 100.00% / 100.00%; TS 100% / 92.59% | PASS |

---

## 7. Code Quality Checks

| Check | Command | Result |
|-------|---------|--------|
| Black | `poetry run black --check <6 Python paths>` | PASS, 6 unchanged |
| Ruff | `poetry run ruff check <9 Python paths>` | PASS |
| Pyright | `poetry run pyright <9 Python paths>` | PASS, 0 errors |
| Pytest | `poetry run pytest -q` | PASS, 6474 passed |
| Prettier | `node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --check <7 paths>` | PASS |
| ESLint | `npm --prefix extensions/drm-copilot run lint` | PASS, 0 problems |
| tsc | `npm --prefix extensions/drm-copilot run typecheck` | PASS, 0 errors |
| Jest | `npm --prefix extensions/drm-copilot run test:unit -- --coverage ...` | PASS, 3808 passed |
| Mirror parity | `cmp <runtime> <bundled mirror>` x6 | PASS |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | PASS, exit 0 |

**Notes:** The six Pytest skips are pre-existing (`test_blast_radius_regression_452.py:483` and five `test_parallel_manifest_bash_parity.py:231` cases). No pre-existing lint, type, or test failure exists in the baselines.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (Non-blocking PARTIAL, pending CI):** The Pester suites `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` and `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` read `.claude/skills/parallel-orchestrate/SKILL.md`, which this branch changes. Under DEV-2 they ran locally only as a PoshQC MCP call, which carries no counts. The CI poshqc job on the PR head is the authoritative evidence. This review statically confirmed the two constraints those suites depend on: the `## Parallel-Mode Kickoff Parameter` marker line (SKILL.md line 246) is still the first line in that section containing `parallel_checkpoint_path`, and no added line starts with `## `. The section `## Per-Item Branch and Worktree Lifecycle` is unchanged. Holds AC-30, AC-35, P5-T24, P6-T32, P7-T10, P7-T17. Remediability class: `awaiting_ci`.
- **PA-2 (Non-blocking, Info):** The Python coverage artifact is scoped to the two changed production modules (`--cov=scripts.dev_tools._parallel_planner_state_routing --cov=scripts.dev_tools.validate_parallel_planner_state`). A whole-repository Python coverage percentage was not produced by the executor run. Both changed production files are measured at 100.00%, so the per-file thresholds and no-regression requirement are verified; the repo-wide Python figure is not reported by this evidence set.
- **PA-3 (Non-blocking, Info):** Two branch arms of TS `sameValue` (`parallel-planner-state-routing.ts` line 60) are not exercised. Branch coverage remains 92.59%, above the 75% threshold.

### Approved Exceptions

- Orchestrator-accepted plan deviations DEV-1 to DEV-9 (recorded in evidence). This review assessed each and found none that weakens an acceptance criterion:
  - DEV-1: anchor `b7b4a2dc` executed as merge-base `74e1d674`; consistent with the resolved merge-base and with the fail-before diffs showing the validators unmodified at the anchor.
  - DEV-2: Pester via PoshQC MCP plus CI; tracked as PA-1.
  - DEV-3: edit locations shifted after the origin/main merge; content verified by the contract tests and by diff inspection.
  - DEV-4: parser first-occurrence handling; no effect on the reviewed code.
  - DEV-5: jest threshold entry placement; the entry is present and active.
  - DEV-6: `quality-tiers.yml` now tracked; T4 (`scripts/dev_tools`) and T3 (`extensions/drm-copilot`) mean no property-test or mutation obligation applies.
  - DEV-7: restored `build_blast_radius` import in `test_validate_parallel_planner_state.py`; still used at lines 387-388.
  - DEV-8: `_hashable_entry` prevents `TypeError` from unhashable band values; covered by two parametrized rows per language.
  - DEV-9: `.claude/state` absent, so no batch-budget counter existed; recorded with `ExpectedExitCode: 2`.
- `.claude/rules/parallel-orchestration.md` edit: operator-approved on 2026-09-30.

### Removed/Skipped Tests

- The test `test_optional_keys_are_absent_from_the_builder_and_yield_no_errors` (Python) and the TS case `treats kickoff_prompt_path and complexity_band as optional off the gate` were replaced, as AC-16 and AC-21 require, by gate-off cases that delete the three routing fields and expect no errors.

---

## 9. Summary of Changes

### Commits in This Branch (since merge-base)

1. `40e645e2` - docs(532): add feature folder and research
2. `beea2900` - docs(532): add bug spec with acceptance criteria
3. `0f432eb4` - docs(532): add atomic plan
4. `4cffc110`, `e1f40ae2`, `58c98bf4`, `aa96c4fe`, `c1289a6b` - docs(532): revise plan per preflight rounds 1 to 5
5. `d6798176` - Merge remote-tracking branch 'origin/main'
6. `5dca560d` - test(532): phase 0 policy reads and baseline capture
7. `d952a1bf` - test(532): phase 1 python fail-before regression
8. `66e05c2f` - test(532): phase 2 typescript fail-before regression
9. `f0aff0e9` - fix(532): phase 3 python P10 ready-gate routing validator
10. `768d6e72` - fix(532): phase 3 routing helper raises nothing for list-valued bands
11. `15a3105f` - fix(532): phase 4 typescript P10 structural subset
12. `b9055802` - fix(532): phase 5 runtime text, mirrors, and routing contract tests
13. `12c5fea5` - docs(532): phase 6 scope verification and acceptance-criteria check-off
14. `601675fb` - docs(532): phase 7 final QA loop and acceptance-criteria check-off

### Files Modified

1. `scripts/dev_tools/_parallel_planner_state_routing.py` (NEW) - P10 checks 1 to 10 with prefix rewriting over the reused Claude helpers.
2. `scripts/dev_tools/validate_parallel_planner_state.py` (MODIFIED) - calls the helper after `_validate_ready_item`; comment and docstrings qualify band optionality.
3. `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts` (NEW) - structural subset with byte-identical strings.
4. `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts` (MODIFIED) - calls the subset after `validateReadyItem`.
5. `extensions/drm-copilot/jest.config.cjs` (MODIFIED) - per-file threshold for the routing module.
6. Test files and builders (Python and TS) as listed in the header.
7. Six `.claude` runtime files and six bundled mirrors (MODIFIED).
8. Feature folder documents and evidence (NEW).

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT, pending CI confirmation (0 blocking findings)

All Python and TypeScript policy gates pass with numeric baseline and post-change coverage for both languages. The single open item (PA-1) is CI-dependent evidence for Pester suites that read a changed Markdown file; it is classified non-blocking under the #744 CI-dependent AC protocol.

**Blocking count: 0** (FAIL: 0, blocking PARTIAL: 0). Non-blocking: PA-1 (PARTIAL, awaiting CI), PA-2 (Info), PA-3 (Info).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: research, spec, and a five-round preflighted plan.
- PASS Design Principles: helper reuse, no formula reimplementation.
- PASS Module & File Structure: maximum 464 lines; no import cycle.
- PASS Naming, Docs, Comments: full docstrings and TSDoc.
- PASS Toolchain Execution: single-pass Phase 7 loop for Python and TS; Pester half pending CI (PA-1).
- PASS Summarize & Document: rule, skills, agents updated with mirrors.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline
- PASS Python Design & Typing: no `Any`, no suppressions.
- PASS Error Handling: never raises; DEV-8 closed the `TypeError` path.

**For TypeScript:**
- PASS Tooling, typing (no `any`), and threshold gate.

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies: no temporary files.
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

**For TypeScript:**
- PASS Framework, location, coverage gate, determinism.

---

### Metrics Summary

- PASS 6474/6474 Python tests passing (6 pre-existing skips)
- PASS 3808/3808 Jest tests passing
- PASS New-code coverage: Python 100.00% line / 100.00% branch; TS 100% line / 92.59% branch
- PASS No coverage regression on changed lines in either language
- PASS All format, lint, and type checks clean
- PARTIAL Pester readers of the changed skill: pending CI poshqc (non-blocking)

---

### Recommendation

**Ready for merge after CI confirmation**

Open the PR, confirm the CI poshqc job passes on the PR head, then check off AC-30, AC-35, P5-T24, P6-T32, P7-T10, and P7-T17. The branch merge-base (`74e1d674`) is behind the current `origin/main` (`ef80c57d`); update the branch before opening the PR.

---

## Appendix A: Test Inventory

### Complete Test List

Python (`tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py`):

- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_item_without_band_assessment_or_receipt
- test_validate_parallel_planner_state_routing.py::test_ready_gate_accepts_item_with_valid_routing_record
- test_validate_parallel_planner_state_routing.py::test_gate_off_accepts_item_without_routing_fields
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_floor_that_disagrees_with_signals
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_band_below_floor
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_receipt_model_that_disagrees_with_resolver
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_disabled_policy_fable_model
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_assessment_band_mismatch
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_receipt_band_mismatch
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_non_orchestrator_agent
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_unknown_fable_policy
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_non_object_assessment_and_receipt
- test_validate_parallel_planner_state_routing.py::test_ready_gate_rejects_missing_assessed_at
- test_validate_parallel_planner_state_routing.py::test_band_mismatch_reported_when_item_band_invalid
- test_validate_parallel_planner_state_routing.py::test_p10_errors_follow_p7_errors_for_same_item
- test_validate_parallel_planner_state_routing.py::test_routing_helper_reuses_claude_helpers_only
- test_validate_parallel_planner_state_routing.py::test_ready_gate_emits_shared_literal_strings (12 parametrized rows)
- test_validate_parallel_planner_state_routing.py::test_required_item_keys_unchanged

Python (`tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py`):

- test_parallel_plan_has_complexity_assessment_section
- test_parallel_plan_uses_claude_receipt_agent_field
- test_parallel_orchestrate_names_planner_checkpoint_band_source
- test_parallel_orchestrator_agent_names_planner_checkpoint_band_source
- test_parallel_add_requires_complexity_assessment
- test_parallel_planner_agent_requires_routing_record
- test_parallel_orchestration_rule_defines_p10

Python (`tests/scripts/dev_tools/test_validate_parallel_planner_state.py`, replaced case):

- test_routing_fields_and_kickoff_path_are_optional_off_the_gate

TypeScript (`extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts`):

1. parallel planner ready gate P10 routing record > rejects an item without band, assessment, or receipt under the ready gate (fail-before)
2. > accepts an item with a valid routing record under the ready gate
3. > accepts items without the routing fields with the gate off
4. > reports both band mismatches and check 1 twice when the item band is C9
5. > reports only checks 2 and 6 for string-valued assessment and receipt
6. > reports every P7 error for an item before its P10 errors
7. > emits the shared literal when %s.%s is %p (12 rows)
8. > returns no errors when called directly on a valid routing record
9. > pins the documented divergence: %s yields no error (3 rows)

TypeScript (`parallel-planner-state-core.test.ts`, replaced case):

- invariant P1 required top-level keys > treats kickoff_prompt_path and the routing fields as optional off the gate

---

## Appendix B: Toolchain Commands Reference

**Commands run by this review (check-only):**

```bash
git diff --stat=200 74e1d674...HEAD
git diff --name-only 74e1d674...HEAD -- artifacts/
poetry run python -m scripts.dev_tools.pr_context.collector --base main --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run black --check scripts/dev_tools/_parallel_planner_state_routing.py scripts/dev_tools/validate_parallel_planner_state.py tests/scripts/dev_tools/parallel_planner_state_builders.py tests/scripts/dev_tools/test_validate_parallel_planner_state.py tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py
poetry run ruff check <same six paths>
poetry run pyright <same six paths>
poetry run pytest tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py tests/scripts/dev_tools/test_validate_parallel_planner_state.py tests/scripts/dev_tools/test_validate_parallel_planner_state_bounds.py tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:cacheprovider
npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/parallel-planner-state-routing.test.ts test/lib/validate/parallel-planner-state-core.test.ts test/lib/validate/parallel-state-tolerated-edge-fields.test.ts
node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --check <7 TS and config paths>
cmp .claude/<file> extensions/drm-copilot/resources/claude-customizations/.claude/<file>   # six pairs
wc -l <13 changed code files>
```

**Executor commands (from evidence):**

```bash
poetry run pytest <5 planner suites> --cov=scripts.dev_tools._parallel_planner_state_routing --cov=scripts.dev_tools.validate_parallel_planner_state --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-532-final.json
poetry run pytest -q
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text --coverageReporters=json-summary --coverageReporters=lcov
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-02
**Policy Version:** Current (as of audit date)

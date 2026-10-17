# Policy Compliance Audit: Epic planner ready gate key-gates Codex-only launch evidence (#543)

---

**Audit Date:** 2026-10-02
**Code Under Test:** Python: `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`, `scripts/dev_tools/epic_planner_launch_evidence.py`, `scripts/dev_tools/epic_planner_readiness.py`, `scripts/dev_tools/validate_epic_planner_state.py`, `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`, `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`. TypeScript: `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`, `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts`, `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts`, `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts`, `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`. Guidance (Markdown/TOML, three root/bundle pairs): `.agents/skills/epic-plan/SKILL.md`, `.agents/skills/epic-run/SKILL.md`, `.codex/agents/epic-orchestrator.toml`, and their `extensions/drm-copilot/resources/codex-and-agents-customizations/` mirrors. Feature-folder documents and evidence under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 7 files (4 production, 3 test) | 118 targeted tests; 6450 full-suite tests | ✅ 118 pass, 0 fail (reviewer re-run); 6450 pass, 0 fail (executor full suite) | 92% combined (TOTAL row 17499 stmts, 1118 missed; 6320 branches, 576 partial) | 92% combined (TOTAL row 17503 stmts, 1112 missed; 6322 branches, 566 partial); changed modules 90.58%-97.48% lines, 77.17%-94.64% branches | 100% of added executable lines covered (0 of the added lines appear in the lcov zero-hit set) |
| TypeScript | 8 files (5 production, 3 test) | 133 targeted tests; 3794 full-suite tests | ✅ 133 pass, 0 fail (reviewer re-run); 3794 pass, 0 fail (executor full suite) | 97.07% lines, 91.35% branches (executor text-summary transcription) | 97.08% lines, 91.42% branches (executor text-summary transcription); changed files 91.62%-100% lines, 84.28%-97.56% branches (transcribed) | 100% of added executable lines covered per executor transcription; no lcov artifact exists to confirm it |
| PowerShell | 0 files | N/A | N/A (no PowerShell file changed; Pester ran only as a guidance-contract check) | N/A | N/A | N/A |
| Markdown/TOML guidance | 6 files | 1 pytest contract test plus 10 Pester contract tests | ✅ all pass | N/A (not a coverage language) | N/A (not a coverage language) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: none on disk; executor text transcription only at `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/baseline/baseline-typescript-test-coverage.2026-10-02T05-01.md`
- TypeScript post-change coverage artifact: absent. Neither `coverage/lcov.info` nor `extensions/drm-copilot/coverage/lcov.info` exists, because the recorded run overrode the configured `lcov` reporter with `--coverageReporters=text --coverageReporters=text-summary`. Text transcription only at `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/final-typescript-test-coverage.2026-10-02T06-35.md`. Disposition: FAIL (finding PA-1).
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Per-language comparison summary: Section 1.2.1 of this audit; Python artifact `artifacts/python/lcov.info` (written 05:39, after the last Python commit `7ee6d91b` at 05:34); executor delta table `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/coverage-delta-verification.2026-10-02T06-45.md`

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is absent, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Missing audit evidence is not synthesized or backfilled from memory or inference. Absent artifacts are listed by exact path above and in Section 8.

---

## Executive Summary

The branch fixes the latent #543 defect in the epic-planner execution-readiness gate in both runtimes. Under `require_ready_for_execution`, the gate now key-gates per-feature launch evidence: a feature with neither `launch_receipt_path` nor `launch_status_path` is skipped unless the caller asserts `require_codex_model_routing` or `require_codex_topology`. The fix covers both call sites, the launch-binding validator and the launch-evidence validator reached through readiness integrity. The MCP `epic-planner-state` dispatch now forwards both Codex flags, and the three Codex guidance callers and their bundle mirrors pass both flags, so Codex enforcement stays unconditional.

The production change is small and correct, every acceptance-criterion test exists and passes, and the reviewer independently re-ran format, lint, type-check, and the targeted test suites with clean results. Two policy findings block a PASS verdict:

- **PA-1 (FAIL, blocking): no TypeScript coverage artifact.** No `lcov.info` exists for TypeScript, which has changed files on the branch. Coverage verification from an artifact is mandatory for every such language. The executor's text transcription reports passing per-file values, but Jest's `coverageThreshold` gates only one of the five changed TypeScript files, so the exit code does not substantiate the other four.
- **PA-2 (FAIL, blocking): composed evidence timestamps.** 35 evidence artifacts under `evidence/regression-testing/` and `evidence/qa-gates/` carry `Timestamp:` values, and matching filename suffixes, that are 4 to 67 minutes later than the files' own write times and later than the commits that added them. This violates `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` line 49, which requires the value to be read from the host clock and never composed or estimated. It also contradicts the fail-before ordering for AC-1: `fail-before-python` records `05-20`, but the fix commit `af88dd58` is dated 05:19:12.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- ✅ `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- ✅ `.claude/rules/quality-tiers.md` and `quality-tiers.yml` (`scripts/dev_tools` T4, `extensions/drm-copilot` T3)
- ✅ `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- ✅ `.claude/skills/feature-review-workflow/SKILL.md`

**Language-specific policies evaluated:**
- ✅ `.claude/rules/python.md` + `.claude/rules/python-suppressions.md`
- ✅ `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md`
- N/A `.claude/rules/powershell.md` (no PowerShell file changed)
- N/A Bash (no shell file changed)
- N/A JSON (no governed JSON file changed)

Templates were read from the bundled asset directory `extensions/drm-copilot/resources/templates/policy_audit/`, which is the directory the MCP template-resolver serves. The MCP tool surface was not available in this reviewer session.

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts were added to the branch. The reviewer's two lcov parsing helpers live in the session scratchpad, outside the repository.
- ✅ No new tooling scripts were added.
- Executor scratchpad readers (`read_pester_junit.py`, Jest JSON readers) are cited in evidence as scratchpad files and are not in the branch diff.

---

## Rejected Scope Narrowing

No caller instruction narrowed the audit scope. The caller prompt states: "Context you may need for judgment, not a scope limit: ... Issue #543 has an additional reported gap (the planner topology-receipt check `_validate_planner_topology_receipt`) that the approved plan leaves out of scope; the PR will state \"Partially addresses #543\" for that reason." That sentence describes the feature's requirement scope, not the audit scope. This audit covers the full branch diff `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd..ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81` for every changed language.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`; exit 0.
- `git diff --name-only ef80c57d..HEAD -- artifacts` returns no paths. No branch file lives under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 54 evidence files are under the canonical `<FEATURE>/evidence/{baseline,regression-testing,qa-gates,other}/` kinds.
- The spec's `evidence/regression/` reference (AC-1) was replaced with the canonical `evidence/regression-testing/`, recorded by the executor as `EVIDENCE_LOCATION_OVERRIDE_REJECTED` in `evidence/baseline/scope-confirmation.2026-10-02T05-01.md`.
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New Python tests build fresh state through `_state()`, `_fixture()`, or `launch_evidence_fixture()` per test. New TypeScript tests call `state()` or `launchEvidenceFixture()` per test or per loop iteration. No shared mutable module state was added. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each test exercises one activation case: keyless skip, partial binding, Codex flag, index preservation, or empty-value arming. Two TypeScript tests loop over two parameter values inside one `it`; Python uses `pytest.mark.parametrize` for the same cases. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer re-run: 118 Python tests in 0.79 s; 7 Jest suites (133 tests) in 2.07 s. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, network, or temporary files. The dispatch test uses the in-memory `VirtualFileSystem`. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names that match the spec AC text, one-line docstrings, and `# Arrange / # Act / # Assert` markers on all new tests. The rewritten `test_launch_evidence_is_required_only_for_execution_readiness` keeps its original shape. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ⚠️ PARTIAL | **Python baseline:** TOTAL 92% (17499 stmts / 1118 missed; branches 6320 / 576 partial), from `evidence/baseline/baseline-python-test-coverage.2026-10-02T05-01.md`, with per-file values in `baseline-python-per-file-coverage`. **TypeScript baseline:** 97.07% lines, 91.35% branches, as a text transcription in `evidence/baseline/baseline-typescript-test-coverage.2026-10-02T05-01.md`; no baseline lcov artifact exists. Baseline `Timestamp:` values reuse one `05-01` reading across files written 05:01-05:18 (see Section 8). |
| **No Coverage Regression** | ⚠️ PARTIAL | **Python:** no per-file decrease. Reviewer parse of `artifacts/python/lcov.info`: `_epic_orchestrator_state_launch_binding.py` 97.48% lines / 94.64% branches, `epic_planner_launch_evidence.py` 92.31% / 89.13%, `epic_planner_readiness.py` 90.58% / 77.17% (full-suite value 93.19%), `validate_epic_planner_state.py` 91.71% / 84.04%. **TypeScript:** the executor transcription shows no decrease, but no artifact exists to confirm it (PA-1). |
| **New Code Coverage ≥90%** | ⚠️ PARTIAL | No new production files. **Python changed lines:** the reviewer intersected the added-line hunks from `git diff -U0` with the lcov zero-hit lines; the intersection is empty, so 100% of added executable lines are covered. **TypeScript changed lines:** 100% per the executor transcription only. |
| **Comprehensive Coverage** | ✅ PASS | `feature_carries_launch_path` / `featureCarriesLaunchPath` is exercised through the skip, partial, and empty-value tests in both runtimes. `require_launch_paths` forwarding is exercised in the launch-binding, launch-evidence, and readiness-integrity paths. The MCP dispatch flag forwarding is exercised by `threads the Codex flags into epic-planner-state`. |
| **Positive Flows** - Valid inputs | ✅ PASS | `test_ready_gate_skips_launch_binding_for_feature_without_launch_paths`, `test_require_launch_paths_skips_feature_without_launch_keys`, `test_complete_launch_evidence_reaches_repository_context_gate` (unchanged), and the TypeScript twins. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `test_ready_gate_rejects_partial_launch_binding`, `test_require_launch_paths_still_rejects_partial_launch_keys`, `test_codex_flag_keeps_launch_binding_unconditional[...]`, and the TypeScript twins. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `test_ready_gate_validates_feature_with_empty_launch_path_value[""/None]`; `test_ready_gate_preserves_feature_index_when_earlier_feature_is_skipped`; readiness-integrity non-list and non-record feature tests. |
| **Error Handling** - Error paths | ✅ PASS | Error strings are asserted byte-for-byte in both runtimes, for example `Epic planner checkpoint features[0] launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.` |
| **Concurrency** - If applicable | N/A | Pure validators; no concurrency. |
| **State Transitions** - If applicable | N/A | Stateless validation functions. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92% combined (TOTAL row) -> Post-change: 92% combined (TOTAL row; statements 93.65%, branches 91.05%). Change: no decrease in the TOTAL row or in any changed module; `epic_planner_readiness.py` branches rose from 69.57% to 77.17%. New/changed-code coverage: 100% of added executable lines. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/final-python-test-coverage.2026-10-02T06-25.md`, `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/coverage-delta-verification.2026-10-02T06-45.md`.
- TypeScript: Baseline: 97.07% lines, 91.35% branches (text transcription) -> Post-change: 97.08% lines, 91.42% branches (text transcription). Change: +0.01 lines, +0.07 branches per transcription. New/changed-code coverage: 100% per transcription. Disposition: FAIL, because no TypeScript coverage artifact exists on disk and coverage verification from an artifact is mandatory for every language with changed files (PA-1). Evidence: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/final-typescript-test-coverage.2026-10-02T06-35.md`, `extensions/drm-copilot/jest.config.cjs` lines 18-19 (configured `lcov` reporter and `coverageDirectory`).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Exact-list equality on filtered launch-binding errors, so a failure shows the full diff. The guidance test passes `f"{root}: {relative_path}"` as its assertion message. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | All new tests carry explicit `Arrange` / `Act` / `Assert` sections. |
| **Document Intent** | ✅ PASS | One-line docstrings in Python; descriptive `it(...)` titles in TypeScript that match the spec AC wording. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or process calls. Readiness contexts come from in-memory fixtures. |
| **Use Mocks/Stubs** | ✅ PASS | The `VirtualFileSystem` fake is used in the dispatch test; the existing launch-evidence fixtures supply in-memory repository context. |
| **Environment Stability** | ✅ PASS | No temporary files. `test_epic_planner_ready_gate_guidance_passes_both_codex_flags` reads tracked repository files under `REPO_ROOT` and `CODEX_BUNDLE_ROOT`, following the existing pattern in that test module. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the pre-submission policy audit. Outstanding items: PA-1 and PA-2 (Section 8). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `spec.md` (Work Mode `full-bug`), research `research/research.2026-09-29T16-10.md` (Approach A), issue #543. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md` lists eleven policy files in policy-compliance order. |
| **Document the plan** | ✅ PASS | `plan.2026-09-29T16-06.md`; all 88 tasks checked, with no open task boxes. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One activation value (`key_gated` / `requireLaunchPaths`) is computed once and passed to both call sites. The skip is a single `continue` / `return` inside the existing loops. |
| **Reusability** | ✅ PASS | The existing #524 predicate is promoted to public (`feature_carries_launch_path`, `featureCarriesLaunchPath`) and reused by the launch-evidence validator instead of being duplicated. |
| **Extensibility** | ✅ PASS | New parameters are keyword-only (Python) or optional option-bag fields (TypeScript), with defaults that preserve pre-fix behaviour. |
| **Separation of concerns** | ✅ PASS | Pure validation logic only. Flag forwarding is confined to the MCP dispatch case in `orchestration-artifacts.ts`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Each change stays within its module's existing responsibility. |
| **Under 500 lines** | ✅ PASS | Reviewer `wc -l`: maximum production file 471 (`epic-planner-state-core.ts`); maximum test file 436 (`test_push_down_codex_and_agents_customizations.py`). The pre-existing 508-line `orchestration-artifacts.test.ts` is not modified. |
| **Public vs internal** | ✅ PASS | `feature_carries_launch_path` is public inside the underscore-prefixed module `_epic_orchestrator_state_launch_binding.py`, as `spec.md` mandated. This is noted as a code-review Minor item. |
| **No circular dependencies** | ✅ PASS | `epic-planner-launch-evidence.ts` imports from `epic-orchestrator-state-launch-binding.ts`, which imports no planner module; `epic_planner_launch_evidence.py` imports from `_epic_orchestrator_state_launch_binding.py`, which imports only the standard library. Executor architecture gates (`final-python-architecture`, `final-typescript-architecture`) exit 0. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `key_gated`, `require_launch_paths`, `LaunchPathGateOptions`, `featureCarriesLaunchPath`. |
| **Docs/docstrings** | ✅ PASS | Updated docstrings describe the key-gate semantics on every changed public function in both runtimes. |
| **Comment why, not what** | ✅ PASS | "A keyless feature contributes neither errors nor a shared status path." explains the shared-status invariant. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check <7 Python files>` -> `7 files would be left unchanged.`; `npx prettier --check <8 TypeScript files>` -> `All matched files use Prettier code style!` (reviewer re-run). |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check <7 Python files>` -> `All checks passed!` (reviewer re-run); `npm run lint` exit 0 (executor `final-typescript-lint`). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <7 Python files>` -> `0 errors, 0 warnings, 0 informations`; `npx tsc -p extensions/drm-copilot --noEmit` exit 0 (reviewer re-run). The executor's `npm run typecheck` also covers the test tree. |
| **4. Testing** | ✅ PASS | **Command:** targeted `poetry run pytest` (6 files) -> 118 passed; targeted Jest (7 suites) -> 133 passed (reviewer re-run). Full suites 6450 passed (Python) and 3794 passed (TypeScript) per executor evidence. |
| **Full toolchain loop** | ✅ PASS | `evidence/qa-gates/final-qa-clean-pass.2026-10-02T06-45.md`: Python 7 stages clean in iteration 1; TypeScript clean in iteration 2 after one Prettier restart. |
| **Explicit reporting** | ⚠️ PARTIAL | Commands and exit codes are recorded, but 35 artifacts carry composed `Timestamp:` values (PA-2). |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Conventional commit messages scoped `(543)`; the PR body is not yet authored. |
| **Design choices explained** | ✅ PASS | `spec.md` Proposed Fix, Boundaries and invariants, and Non-goals (Python CLI deferral, remaining Codex-only receipts). |
| **Update supporting documents** | ✅ PASS | Six guidance files updated, byte-identical by pair. Reviewer `sha256sum`: `6e1752a9...`, `12b8a82c...`, `8d62f9a0...` match within each pair. |
| **Provide next steps** | ✅ PASS | `spec.md` Rollout & Follow-up names the remaining Codex-only receipts. The #543 issue comment of 2026-09-30 tracks `_validate_planner_topology_receipt`. The PR must state "Partially addresses #543". |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check <7 files>`<br>**Result:** 7 files unchanged. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check <7 files>`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright <7 files>`<br>**Result:** 0 errors, 0 warnings. |
| **Testing with Pytest** | ✅ PASS | **Command:** targeted `poetry run pytest` over 6 files<br>**Result:** 118 passed in 0.79 s. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | New parameters are typed `bool` and keyword-only. `feature_carries_launch_path(feature: Mapping[str, object]) -> bool` widens the input type, with the `Mapping` import under `TYPE_CHECKING`. No new `Any` was introduced in production code. |
| **Dataclasses for value objects** | N/A | No value objects added. |
| **Protocols/ABCs for interfaces** | N/A | No interfaces added. |
| **Avoid utility classes** | ✅ PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | The validators return error lists; no exception handling changed. |
| **Logging over print** | ✅ PASS | No print or logging changes. |
| **Invariants at construction** | N/A | No classes added. |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | Reviewer `npx prettier --check` over the 8 files: clean. |
| **Linting with ESLint** | ✅ PASS | `npm run lint` exit 0 (executor `final-typescript-lint`). |
| **Type checking with tsc** | ✅ PASS | Reviewer `tsc --noEmit` exit 0. |
| **Untyped escape hatches (T3: <= 5 per file, justified)** | ✅ PASS | No `any` added. Test casts use `as Record<string, unknown>[]`, following the existing pattern in the file. |
| **Strict option handling** | ✅ PASS | `options.requireLaunchPaths === true` and `!== true` comparisons treat `undefined` as false, matching the Python defaults. |

PowerShell (3B), Bash (3C), and JSON (3D) sections are omitted because no files in those languages changed on the branch.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Plain pytest functions and `pytest.mark.parametrize`. |
| **Coverage expectation** | ✅ PASS | Changed modules are at least 90.58% lines and 77.17% branches (thresholds 85/75). Added lines are 100% covered. The full-suite TOTAL is 92%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One behaviour per test. |
| **Mocking sparingly** | ✅ PASS | No mocks; real fixtures. |
| **Organization** | ⚠️ PARTIAL | Files are under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`. However, the three `test_readiness_integrity_*` tests target `epic_planner_readiness.validate_epic_readiness_integrity` but live in `test_validate_epic_planner_state_launch_binding.py`. `spec.md` line 162 directs additional tests to new mirror-layout files; plan line 120 authorized this placement. Non-blocking (code-review CR-3). |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<behaviour>` names that match the AC text exactly. |
| **Docstrings/comments** | ✅ PASS | One-line docstrings on every new test. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest <6 files> -q`<br>**Result:** 118 passed. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest via run-jest.cjs** | ✅ PASS | Executor runs used `node run-jest.cjs`. The reviewer ran `npx jest --config <abs>/jest.config.cjs` (the same config) and got 133 passed. |
| **Coverage expectation** | ❌ FAIL | No TypeScript coverage artifact exists (PA-1). Jest `coverageThreshold` gates only `./src/lib/validate/orchestration-artifacts.ts` among the five changed files (`jest.config.cjs` line 98). |
| **Organization** | ✅ PASS | Tests are under `extensions/drm-copilot/test/lib/validate/`, mirroring `src/lib/validate/`. |
| **Determinism** | ✅ PASS | No timers or real I/O. |

---

## 5. Test Coverage Detail

### Python ready gate and launch validators (13 new or rewritten test cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_ready_gate_skips_launch_binding_for_feature_without_launch_paths` | Positive | `validate_epic_planner_state.py` 328-329, 340-344, 359-361; skip branches in both launch validators | ✅ |
| `test_ready_gate_rejects_partial_launch_binding` | Negative | `_epic_orchestrator_state_launch_binding.py` 231 (predicate true) | ✅ |
| `test_codex_flag_keeps_launch_binding_unconditional[require_codex_model_routing]` | Negative | `key_gated` false path | ✅ |
| `test_codex_flag_keeps_launch_binding_unconditional[require_codex_topology]` | Negative | `key_gated` false path | ✅ |
| `test_launch_evidence_is_required_only_for_execution_readiness` (rewritten) | Negative | Codex-flag path | ✅ |
| `test_ready_gate_preserves_feature_index_when_earlier_feature_is_skipped` | Edge Case | In-loop skip keeps `features[1]` | ✅ |
| `test_ready_gate_validates_feature_with_empty_launch_path_value[]` / `[None]` | Edge Case | Key-membership arming | ✅ |
| `test_require_launch_paths_skips_feature_without_launch_keys` | Positive | `epic_planner_launch_evidence.py` 323-325 | ✅ |
| `test_require_launch_paths_still_rejects_partial_launch_keys` | Negative | Same branch, false side | ✅ |
| `test_readiness_integrity_skips_ignored_kickoff_for_unsafe_path` | Error Handling | `epic_planner_readiness.py` pre-existing branch | ✅ |
| `test_readiness_integrity_skips_feature_checks_for_non_list_features` | Edge Case | pre-existing branch | ✅ |
| `test_readiness_integrity_skips_non_record_feature` | Edge Case | pre-existing branch | ✅ |
| `test_epic_planner_ready_gate_guidance_passes_both_codex_flags` | Contract | Six guidance files | ✅ |

**Coverage:** `validate_epic_planner_state.py` 91.71% lines / 84.04% branches; `_epic_orchestrator_state_launch_binding.py` 97.48% / 94.64%; `epic_planner_launch_evidence.py` 92.31% / 89.13%; `epic_planner_readiness.py` 90.58% / 77.17% (lcov artifact).

**Not covered:** No added line is uncovered. The remaining uncovered lines are pre-existing (for example `validate_epic_planner_state.py` 324, the non-epic `next_step` append).

### TypeScript ready gate, launch evidence, and dispatch (8 new or rewritten tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `skips launch binding for a feature without launch paths` | Positive | `epic-planner-state-core.ts` 424-426, 439-441, 464 | ✅ |
| `rejects a partial launch binding` | Negative | predicate true path | ✅ |
| `keeps launch binding unconditional under a Codex flag` | Negative | `requireLaunchPaths` false | ✅ |
| `preserves the feature index when an earlier feature is skipped` | Edge Case | in-loop skip | ✅ |
| `validates a feature with an empty launch path value` | Edge Case | key-membership arming | ✅ |
| `activates only for execution readiness` (rewritten) | Negative | Codex-flag path | ✅ |
| `skips a feature without launch keys when requireLaunchPaths is set` / `still rejects a partial launch key when requireLaunchPaths is set` | Positive / Negative | `epic-planner-launch-evidence.ts` 416-421 | ✅ |
| `threads the Codex flags into epic-planner-state` | Contract | `orchestration-artifacts.ts` 320-325 | ✅ |

**Coverage:** per-file values exist only as executor text transcription (PA-1).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 118 Python targeted + 133 TypeScript targeted (reviewer); 6450 + 3794 full suites (executor) | ✅ |
| Tests Passed | 251 of 251 targeted (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 0.79 s (pytest) + 2.07 s (Jest) | ✅ Fast |
| Average Time per Test | about 11 ms | ✅ Fast |
| Discovery Time | Not separately reported by either runner | ✅ |
| Functions/Classes Tested | 9 of 9 changed functions or options (100%) | ✅ |
| Test File Size | 225 to 436 lines | ✅ Maintainable |
| Code Coverage (if applicable) | Python changed modules 90.58%-97.48% lines, 77.17%-94.64% branches; TypeScript has no artifact | ❌ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <7 files>` | 7 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check <7 files>` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright <7 files>` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest <6 targeted files>` | 118 passed | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check <8 files>` | clean | ✅ |
| tsc | `npx tsc -p extensions/drm-copilot --noEmit` | exit 0 | ✅ |
| Jest | `npx jest --config extensions/drm-copilot/jest.config.cjs <7 suites>` | 133 passed | ✅ |
| Coverage artifact | inspection of `coverage/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` | neither file exists | ❌ |

**For PowerShell (guidance contract only):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Pester contracts | PoshQC MCP run (executor), JUnit inspected by reviewer | `codex-epic-runtime-contracts.Tests.ps1`: tests=10, failures=0, errors=0; `keeps root and tracked bundle runtime copies byte-identical` Passed; JUnit written 05:44:43, after guidance commit `7ee6d91b` (05:34:04) | ✅ |

**Notes:** The executor's full Python suite deselects the #510 local-only node `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, identically at baseline and final. The deselection is unrelated to this change. PowerShell was not run through the shell, per the operator decision recorded in `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (FAIL, blocking): TypeScript coverage artifact absent.** TypeScript has 8 changed files on the branch, but no `lcov.info` exists for it. The recorded command `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` overrides the configured `coverageReporters: ["lcov", "text-summary"]` (`jest.config.cjs` line 18), so no artifact was written. Jest `coverageThreshold` gates only `orchestration-artifacts.ts`, so for the other four changed production files the exit code does not establish the 85% line / 75% branch floors. Remediability: autonomous.
- **PA-2 (FAIL, blocking): composed evidence timestamps.** 35 artifacts carry `Timestamp:` values, and identical filename suffixes, later than their own write times: 13 under `evidence/regression-testing/` and 22 under `evidence/qa-gates/`. Examples:
  - `qa-gates/acceptance-checkoff.2026-10-02T06-55.md` was written at 05:48:23 and committed in `ecbe5ba1` at 05:48:43.
  - `regression-testing/fail-before-python.2026-10-02T05-20.md` was written at 05:15:41, before the fix commit `af88dd58` at 05:19:12, yet its recorded value `05-20` places the fail-before run after the fix.
  - The values follow a fixed 5-minute schedule (05-20, 05-30, 05-40, 05-45, 05-55, 06-00 through 06-55) that does not match any clock reading.

  This violates `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` line 49. Remediability: autonomous.
- **PA-3 (non-blocking): reused Phase 0 timestamp.** 17 baseline artifacts and `other/python-batch-budget` record `05-01` but were written between 05:01:50 and 05:18:16. A single reading was reused rather than read per command. These values are not later than the write times, so they are listed for correction alongside PA-2 but do not independently block.
- **PA-4 (non-blocking): plan-deviation record.** Deviations D1-D3 (anchored merge-base SHA, PowerShell substitution routes) are cited throughout the evidence and in `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`, but the plan file has no deviations section recording them.

### Approved Exceptions

- **Python CLI parity.** `scripts/dev_tools/validate_orchestration_artifacts.py` gains no `--require-codex-*` flags. This deviation is recorded in `spec.md` Non-goals because adding them would push the 495-line file past the 500-line limit. Reviewer `git diff` shows the file unchanged.
- **Pester execution route.** PowerShell was not run through the shell, per the operator decision (2026-10-01, Option A) recorded in `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`. Pester results come from the PoshQC MCP run's JUnit output, which the reviewer inspected directly.

### Removed/Skipped Tests

**None.** All planned tests are implemented. One pre-existing node (#510) is deselected identically at baseline and final.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **1d1c9955** - docs(543): add feature folder and research
2. **c4b45ba2** - docs(543): add bug spec
3. **e749831f** - docs(543): add atomic plan
4. **af952f75** - docs(543): revise plan after preflight round 1
5. **7fcdf86e** - docs(543): revise plan after preflight round 2
6. **1b6b06e2** - Merge remote-tracking branch 'origin/main'
7. **f5c4c918** - docs(543): classify PowerShell-bearing plan tasks before execution
8. **0c6abb95** - docs(543): record Phase 0 policy reads and baselines
9. **0a5b90d2** - test(543): add fail-before regression tests for keyless planner features
10. **af88dd58** - fix(543): key-gate planner launch evidence unless a Codex flag is set
11. **23db0a97** - fix(543): key-gate planner launch evidence in the TypeScript runtime
12. **e1393abd** - test(543): align Python tests with the key-gated planner ready gate
13. **41f03caf** - test(543): add TypeScript twins for the key-gated planner ready gate
14. **7ee6d91b** - docs(543): pass both Codex flags in planner ready-gate guidance
15. **59c8c2f3** - docs(543): record targeted and preserved-behaviour verification
16. **910288a5** - docs(543): record Python final QA loop
17. **9cef2d22** - wip(543): checkpoint in-progress TypeScript and QA-loop edits before quota limit
18. **70b21fab** - style(543): apply Prettier and record TypeScript final QA loop
19. **ecbe5ba1** - docs(543): record coverage delta, scope, size, and acceptance check-off

### Files Modified

1. **scripts/dev_tools/validate_epic_planner_state.py** (MODIFIED) - adds `require_codex_model_routing` / `require_codex_topology`; computes `key_gated` and passes it to both launch call sites.
2. **scripts/dev_tools/_epic_orchestrator_state_launch_binding.py** (MODIFIED) - `_carries_launch_path` renamed to public `feature_carries_launch_path`; the planner wrapper forwards `require_launch_paths`.
3. **scripts/dev_tools/epic_planner_launch_evidence.py** (MODIFIED) - in-loop keyless skip under `require_launch_paths`.
4. **scripts/dev_tools/epic_planner_readiness.py** (MODIFIED) - forwards `require_launch_paths`.
5. **extensions/drm-copilot/src/lib/validate/*.ts** (5 files, MODIFIED) - TypeScript twins of the above, plus MCP dispatch flag forwarding.
6. **Guidance pairs** (6 files, MODIFIED) - add both Codex flags to the `epic-planner-state` ready-gate invocation.
7. **Tests** (6 files, MODIFIED) - regression, twin, dispatch, contract, and branch-coverage tests.
8. **docs/features/active/2026-08-24-...-543/** (NEW) - issue, spec, research, plan, and 54 evidence files.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The code change complies with the general, Python, and TypeScript code-change and unit-test policies, and the reviewer's independent re-runs are clean. Two evidence-level policy failures remain: no TypeScript coverage artifact (PA-1) and composed evidence timestamps (PA-2). Both are remediable autonomously without production-code changes.

**Fail-closed reminder:** This audit does not report PASS, because the TypeScript coverage artifact is absent.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present
- ✅ Design Principles: single activation value, predicate reuse
- ✅ Module & File Structure: all files within 500 lines; no cycles
- ✅ Naming, Docs, Comments: docstrings updated
- ⚠️ Toolchain Execution: clean results; evidence timestamps composed (PA-2)
- ✅ Summarize & Document: scope and follow-ups recorded

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright, and Pytest clean
- ✅ Python Design & Typing: typed keyword-only parameters
- ✅ Error Handling: unchanged error contract

**For TypeScript:**
- ✅ Tooling: Prettier, ESLint, and tsc clean
- ✅ Type safety: no `any` added

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: met
- ⚠️ Coverage & Scenarios: scenarios complete; TypeScript coverage not artifact-verified (PA-1)
- ✅ Test Structure: AAA pattern and docstrings present
- ✅ External Dependencies: none
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: pytest; coverage thresholds met
- ⚠️ Test Style & Structure: three readiness tests placed in a non-mirroring file (plan-authorized)
- ✅ Naming & Readability: met
- ✅ Toolchain: met

**For TypeScript:**
- ❌ Coverage: no artifact (PA-1)
- ✅ Structure, naming, determinism: met

---

### Metrics Summary

- ✅ 251/251 targeted tests passing (100%), reviewer re-run
- ✅ 9/9 changed functions or options exercised
- ✅ Python changed modules at least 90.58% lines and 77.17% branches; added lines 100% covered
- ❌ TypeScript per-file coverage not verifiable from an artifact
- ✅ Format, lint, and type-check clean in both languages (reviewer re-run)
- ✅ Test execution time under 3 seconds for the targeted suites

---

### Recommendation

**Needs revision**

Address PA-1 by producing the TypeScript lcov artifact and recording per-file values from it. Address PA-2 by correcting the 35 composed `Timestamp:` values to their observed write times, and record the PA-3 and PA-4 corrections in the same pass. No production-code change is required. The PR, when authored, must state "Partially addresses #543" and must not use a closing keyword, because the topology-receipt and per-feature receipt checks remain Codex-only (see `spec.md` Rollout & Follow-up and the 2026-09-30 comment on #543).

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_complete_launch_evidence_reaches_repository_context_gate` (unchanged)
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_launch_evidence_is_required_only_for_execution_readiness` (rewritten)
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_ready_gate_skips_launch_binding_for_feature_without_launch_paths`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_ready_gate_rejects_partial_launch_binding`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_codex_flag_keeps_launch_binding_unconditional[require_codex_model_routing]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_codex_flag_keeps_launch_binding_unconditional[require_codex_topology]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_ready_gate_preserves_feature_index_when_earlier_feature_is_skipped`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_ready_gate_validates_feature_with_empty_launch_path_value[]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_ready_gate_validates_feature_with_empty_launch_path_value[None]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_readiness_integrity_skips_ignored_kickoff_for_unsafe_path`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_readiness_integrity_skips_feature_checks_for_non_list_features`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py::test_readiness_integrity_skips_non_record_feature`
- `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py::test_require_launch_paths_skips_feature_without_launch_keys`
- `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py::test_require_launch_paths_still_rejects_partial_launch_keys`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged` (updated)
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_epic_planner_ready_gate_guidance_passes_both_codex_flags`
- epic planner child launch binding › activates only for execution readiness (rewritten)
- epic planner child launch binding › skips launch binding for a feature without launch paths
- epic planner child launch binding › rejects a partial launch binding
- epic planner child launch binding › keeps launch binding unconditional under a Codex flag
- epic planner child launch binding › preserves the feature index when an earlier feature is skipped
- epic planner child launch binding › validates a feature with an empty launch path value
- epic planner launch file and status evidence › skips a feature without launch keys when requireLaunchPaths is set
- epic planner launch file and status evidence › still rejects a partial launch key when requireLaunchPaths is set
- validateOrchestrationServiceCall › threads the Codex flags into epic-planner-state

---

## Appendix B: Toolchain Commands Reference

Commands run by the reviewer (worktree root `<wt>`; check-only, no file mutation):

**For Python:**
```bash
poetry -C <wt> run black --check scripts/dev_tools/_epic_orchestrator_state_launch_binding.py scripts/dev_tools/epic_planner_launch_evidence.py scripts/dev_tools/epic_planner_readiness.py scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_launch_evidence.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py
poetry -C <wt> run ruff check <same 7 files>
poetry -C <wt> run pyright <same 7 files>
poetry -C <wt> run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_launch_evidence.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py -q -p no:cacheprovider
python <scratchpad>/lcov_parse.py artifacts/python/lcov.info <4 module names>
python <scratchpad>/lcov_zero_lines.py artifacts/python/lcov.info
poetry -C <wt> run python scripts/dev_tools/validate_evidence_locations.py --root <wt>
```

**For TypeScript:**
```bash
npx --prefix <wt>/extensions/drm-copilot prettier --check <8 changed TypeScript files>
npx --prefix <wt>/extensions/drm-copilot tsc -p <wt>/extensions/drm-copilot --noEmit
npx --prefix <wt>/extensions/drm-copilot jest --config <wt>/extensions/drm-copilot/jest.config.cjs test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-launch-evidence.test.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/epic-orchestrator-state-launch-binding.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/orchestration-artifacts.test.ts
```

**Repository state and evidence checks:**
```bash
git -C <wt> diff --name-status ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd..HEAD
git -C <wt> diff --name-only ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd..HEAD -- artifacts .claude .github scripts/dev_tools/validate_orchestration_artifacts.py
sha256sum <three root/bundle guidance pairs>
wc -l <15 changed code files>
ls -l --time-style=+%H:%M:%S <feature>/evidence/*/
grep -r -m1 "^Timestamp:" <feature>/evidence/
git -C <wt> log --format="%h %ci %s" ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd..HEAD
grep -o '<testsuite [^>]*codex-epic-runtime-contracts[^>]*>' artifacts/pester/pester-junit.xml
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-02
**Policy Version:** Current (as of audit date)

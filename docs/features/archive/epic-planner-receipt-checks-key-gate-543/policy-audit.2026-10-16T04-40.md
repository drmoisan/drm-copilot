# Policy Compliance Audit: Epic-planner per-feature receipt-checks key gate (#543), re-audit after remediation cycle 1

---

**Audit Date:** 2026-10-16
**Code Under Test:**
- `scripts/dev_tools/validate_epic_planner_state.py` (Python, modified)
- `scripts/dev_tools/epic_planner_git_integrity.py` (Python, modified; cycle 1, CR-5)
- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` (Python, modified; cycle 1, CR-5)
- `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (TypeScript, modified)
- `extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts` (TypeScript, modified; cycle 1, CR-5)
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` (TypeScript, modified; cycle 1, CR-5)
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (Python test, modified)
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` (Python test, new)
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py` (Python test, new; cycle 1)
- `tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py` (Python test, new; cycle 1)
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts` (TypeScript test, new)
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-indices.test.ts` (TypeScript test, new; cycle 1)
- `extensions/drm-copilot/test/lib/validate/epic-planner-git-integrity-feature-indices.test.ts` (TypeScript test, new; cycle 1)
- `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (TypeScript test, modified)
- Feature-folder Markdown under `docs/features/active/epic-planner-receipt-checks-key-gate-543/` (issue, spec, research, plans, prior review set, evidence)

**Base/Head:** base `main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`), head `bug/epic-planner-receipt-checks-key-gate-543` @ `c99c528a9bbba77fa3678014f9a3b0f7f669a409`. Scope is the full branch diff `adb9aa5f0..c99c528a9` (142 files, +5852/-125; 14 code files, 128 Markdown files).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 3 production, 4 test | Full suite 7114 (1 deselected, #510); reviewer targeted re-run 97 | PASS: 7114 passed, 6 skipped, 0 failed; reviewer 97 passed | Repo-wide 93.82% lines (16554/17644), 88.14% branches (5616/6372) at cycle-1 start; `validate_epic_planner_state.py` 91.76% / 84.38% at `main` | Repo-wide 93.86% lines (16580/17665), 88.21% branches (5628/6380), from `artifacts/python/lcov.info` (214 `SF:` records). Per file: `validate_epic_planner_state.py` 94.24% / 88.00%; `epic_planner_git_integrity.py` 99.34% / 98.84%; `_epic_orchestrator_state_launch_binding.py` 98.32% / 96.43% | 100% of added executable lines covered (0 added lines with `DA:<n>,0` in any of the 3 files; reviewer cross-check of diff hunks against the artifact) |
| TypeScript | 3 production, 4 test | Full suite 4023 (273 suites); reviewer targeted re-run 89 (8 suites) | PASS: 4023 passed, 0 failed; reviewer 89 passed | Repo-wide 97.27% lines (51173/52610), 92.29% branches (7568/8200) at cycle-1 start; `epic-planner-state-core.ts` 98.31% / 93.8% at `main` | Repo-wide 97.28% lines (51226/52661), 92.34% branches (7585/8214), from `extensions/drm-copilot/coverage/lcov.info` (212 `SF:` records). Per file: `epic-planner-state-core.ts` 98.38% / 94.12%; `epic-planner-git-integrity.ts` 100.00% / 96.84%; `epic-orchestrator-state-launch-binding.ts` 96.75% / 94.17% | 100% of added executable lines covered (0 added lines with `DA:<n>,0` in any of the 3 files) |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| Markdown | 128 files | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/remediation-baseline/rc1-baseline-typescript-lcov-coverage.2026-10-16T03-51.md` (lcov-derived); original `main` baseline `evidence/baseline/baseline-typescript-test-coverage.2026-10-16T00-38.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (present, git-ignored, written 2026-10-16 04:20 UTC, after the last code commit `dbd82313e` at 04:06 UTC); figures recorded in `evidence/qa-gates/typescript-lcov-coverage.2026-10-16T04-22.md` and re-derived by the reviewer
- Python baseline coverage artifact: `evidence/remediation-baseline/rc1-baseline-python-repo-wide-coverage.2026-10-16T03-49.md` and `rc1-baseline-python-per-file-coverage.2026-10-16T03-47.md`; original `main` baseline `evidence/baseline/baseline-python-per-file-coverage.2026-10-16T00-33.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (present, git-ignored, written 2026-10-16 04:16 UTC, after the last Python code commit `7f727fa41` at 04:01 UTC); figures recorded in `evidence/qa-gates/python-repo-wide-coverage.2026-10-16T04-18.md` and re-derived by the reviewer
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed on the branch
- Per-language comparison summary: Section 1.2.1 and `evidence/qa-gates/rc1-coverage-delta-verification.2026-10-16T04-24.md`

**Verdict rule applied:** both languages with changed files have their coverage artifact present; every changed production file and both repository-wide figures meet line >= 85% and branch >= 75%; no added line is uncovered. Python coverage verdict PASS; TypeScript coverage verdict PASS.

---

## Executive Summary

The branch key-gates the per-feature `model_routing_receipt` and `topology_receipt` checks in the epic-planner execution-ready gate in both runtimes (original change). Remediation cycle 1 closed the prior blocking finding PA-1 (TypeScript lcov artifact absent), produced a repository-wide Python figure (PA-N2), and, by orchestrator decision, fixed CR-5: every `features[i]` prefix on the epic-planner validation path (ready gate, dependency waves, planner launch bindings, git-integrity `planning_commit`) now uses the entry's original index in the checkpoint `features` array, in both runtimes, with fail-before / pass-after evidence.

**Policy documents evaluated:**
- PASS `CLAUDE.md` and `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (tiers adopted: `quality-tiers.yml` exists; `scripts/dev_tools` T4, `extensions/drm-copilot` T3)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md`
- PASS `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md`
- N/A PowerShell, C#, Bash, JSON (no changed files)

The reviewer re-ran Black, Ruff, Pyright (7 Python files), Prettier (7 TypeScript files), ESLint, `tsc`, targeted pytest (8 files, 97 passed, `--no-cov`), targeted Jest (8 suites, 89 passed), `validate_evidence_locations.py --root .`, and the AC11 / AC12 / AC13 diff checks; all exited 0. Per-file and repository-wide coverage were re-derived from both lcov artifacts. No FAIL finding remains. All 17 non-CI acceptance criteria pass; AC18 is pending CI.

**Temporary artifacts cleanup:**
- PASS No temporary scripts are committed; helper programs were kept in the session scratchpad (`SCRATCH/rc1/...` in evidence commands; `evidence/other/rc1-helper-scripts.2026-10-16T03-45.md`).
- PASS No ongoing tooling scripts were added.

---

## Rejected Scope Narrowing

None detected. The caller prompt names the active feature folder, the prior review set, the cycle-1 plan, and the coverage artifact locations, and states "AC18 is CI-dependent and is checked off at S9; list it as pending-CI." None of these narrows the audit: the instruction on AC18 matches `.claude/skills/acceptance-criteria-tracking/SKILL.md` "CI-Dependent Criteria". The audit covers the full branch diff `adb9aa5f0..c99c528a9`, including the six production files changed across both cycles.

## Evidence Location Compliance

- `git diff --name-only adb9aa5f0..HEAD -- artifacts`: no output. No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` is in the branch diff.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`: exit 0, no violations.
- All evidence files are under `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/<kind>/` (`baseline`, `remediation-baseline`, `other`, `qa-gates`, `regression-testing`).
- The two coverage data files (`artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`) are tool outputs at their configured, git-ignored locations and are not committed.
- Result: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record was needed.

## Tier Classification

`quality-tiers.yml` exists at the repository root. Both changed projects are classified: `scripts/dev_tools` T4 and `extensions/drm-copilot` T3. T3/T4 require no property-based tests and no mutation score; the T3 escape-hatch limit (<= 5 per file, justified) is met because the diff adds no `any`. Result: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Every test builds its own checkpoint (`_claude_state()`, `_claude_feature()`, `claudeState()`, `claudeFeature()`); the git-integrity tests use a stateless `GitStub` / `git` fake. No shared mutable state. |
| **Isolation** - Each test targets single behavior | PASS | One prefix site per test (ready gate, Codex-flag receipts, dependency waves, launch bindings, planning commit) plus unchanged-index and fallback controls. |
| **Fast Execution** - Tests complete quickly | PASS | Reviewer re-run: 97 pytest tests in 1.41s; 8 Jest suites (89 tests) in seconds. |
| **Determinism** - Consistent results | PASS | Pure in-memory validation; git access is replaced by a deterministic fake; no clock, randomness, network, or filesystem. |
| **Readability & Maintainability** - Clear structure | PASS | Named error-string constants; descriptive test names and docstrings. Three Python test files define an unused `ASSERTED_MESSAGES` tuple (non-blocking CR-6 in the code review). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `main` baselines under `evidence/baseline/`; cycle-1 baselines under `evidence/remediation-baseline/` for all six production files and both repository-wide figures. |
| **No Coverage Regression** | PASS | Every changed production file improved or held: Python `validate_epic_planner_state.py` 92.55/86.00 -> 94.24/88.00, `epic_planner_git_integrity.py` 98.50/97.44 -> 99.34/98.84, `_epic_orchestrator_state_launch_binding.py` 97.48/94.64 -> 98.32/96.43; TypeScript `epic-planner-state-core.ts` 98.36/94.07 -> 98.38/94.12, `epic-planner-git-integrity.ts` 100.00/93.98 -> 100.00/96.84, `epic-orchestrator-state-launch-binding.ts` 96.11/93.28 -> 96.75/94.17. |
| **New Code Coverage** | PASS | Reviewer intersection of the `git diff -U0` added-line ranges with each file's `DA:<n>,0` lines found 0 uncovered added lines in all six production files. |
| **Comprehensive Coverage** | PASS | `_pair_plans_with_features` / `pairPlansWithFeatures` (match, skip, positional fallback, empty and non-list inputs), the indexed ready-gate, dependency-wave and launch-binding paths are exercised in both runtimes. |
| **Positive Flows** - Valid inputs | PASS | Unchanged-index controls (`test_ready_gate_prefix_unchanged_without_non_object_entries`, `test_planning_commit_prefix_unchanged_without_skipped_entries`, and TypeScript twins). |
| **Negative Flows** - Invalid inputs | PASS | Non-object entries (string, null, number, list) and plan-less entries precede a failing feature. |
| **Edge Cases** - Boundary conditions | PASS | Empty and non-list `features` values; plans with no matching entry (positional fallback). |
| **Error Handling** - Error paths | PASS | Exact error strings asserted, full error lists compared with `==` / `toEqual` where ordering matters. |
| **Concurrency** - If applicable | N/A | Pure synchronous validation. |
| **State Transitions** - If applicable | N/A | No stateful component changed. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.82% lines, 88.14% branches (repo-wide, cycle-1 start) -> Post-change: 93.86% lines, 88.21% branches. Change: +0.04 line points, +0.07 branch points. New/changed-code coverage: 100% of added executable lines (0 uncovered added lines in the three changed production files). Per file: `validate_epic_planner_state.py` 94.24% / 88.00% (uncovered 121, 127, 151-158, 194, 277, 286, 356, all context lines); `epic_planner_git_integrity.py` 99.34% / 98.84% (uncovered 295, context); `_epic_orchestrator_state_launch_binding.py` 98.32% / 96.43% (uncovered 188, 299, context). Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/python-repo-wide-coverage.2026-10-16T04-18.md`, `evidence/qa-gates/rc1-final-python-per-file-coverage.2026-10-16T04-13.md`.
- TypeScript: Baseline: 97.27% lines, 92.29% branches (repo-wide, cycle-1 start) -> Post-change: 97.28% lines, 92.34% branches. Change: +0.01 line points, +0.05 branch points. New/changed-code coverage: 100% of added executable lines (0 uncovered added lines in the three changed production files). Per file: `epic-planner-state-core.ts` 98.38% / 94.12% (uncovered 69-70, 75-76, 78-79, 276-277, context); `epic-planner-git-integrity.ts` 100.00% / 96.84%; `epic-orchestrator-state-launch-binding.ts` 96.75% / 94.17% (uncovered 45-46, 56-61, 215-217, context). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/qa-gates/typescript-lcov-coverage.2026-10-16T04-22.md`.
- PowerShell: N/A - zero changed files on the branch.
- C#: N/A - zero changed files on the branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | List-equality and exact-membership assertions print the full error list on failure. |
| **Arrange-Act-Assert Pattern** | PASS | Each test builds the state, calls the validator once, then asserts, with blank-line separation. |
| **Document Intent** | PASS | Every Python test has a docstring; TypeScript `it` titles state the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No filesystem, network, or subprocess; git access is faked. |
| **Use Mocks/Stubs** | PASS | `GitStub` (Python) and a `ReadinessGitRepository` object literal (TypeScript) replace git. |
| **Environment Stability** | PASS | No temporary files, global state, or environment variables. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the pre-submission policy re-audit. No FAIL item remains. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md`, `spec.md`, and `remediation-inputs.2026-10-16T01-36.md`. |
| **Read existing change plans** | PASS | `evidence/remediation-baseline/rc1-phase0-instructions-read.2026-10-16T03-42.md`. |
| **Document the plan** | PASS | `plan.2026-10-15T07-42.md` and `remediation-plan.2026-10-16T01-36.md` (revision 3, records the CR-5 scope decision and caller analysis). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Index pairs are carried through existing loops; only the git-integrity module needed a pairing helper. |
| **Reusability** | PASS | One `indexed_features` / `indexedFeatures` list feeds the dependency-wave and ready-gate checks. |
| **Extensibility** | PASS | Public signatures unchanged except a widening of the planner launch-binding parameter type (accepts every argument accepted before). |
| **Separation of concerns** | PASS | Pure validation logic only; no I/O added. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Changes stay in the existing validator modules; new tests mirror the source layout. |
| **Under 500 lines** | PASS | Reviewer `wc -l`: production 407, 305, 310, 495, 331, 338; tests 429, 204, 201, 139, 199, 169, 107, 246. `epic-planner-state-core.ts` has 5 lines of headroom (non-blocking CR-4). |
| **Public vs internal** | PASS | New helpers are private (`_plan_path`, `_pair_plans_with_features`, module-local `pairPlansWithFeatures`, `PlanEntry`); `evidence/qa-gates/rc1-final-python-contract.2026-10-16T04-13.md`, `rc1-final-typescript-contract.2026-10-16T04-23.md`. |
| **No circular dependencies** | PASS | The only new import is `pathlib.PurePosixPath` (standard library) and a `TYPE_CHECKING`-only `Sequence`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `indexed_features`, `checkpoint_entries`, `_pair_plans_with_features`. The TypeScript `requireLaunchPaths` name remains narrower than what it gates (non-blocking CR-3, spec-mandated). |
| **Docs/docstrings** | PASS | Docstrings state the original-index rule and the positional fallback (`evidence/qa-gates/rc1-docs.2026-10-16T04-08.md`). |
| **Comment why, not what** | PASS | Docstrings explain why the fallback exists (callers whose plans are not drawn from the checkpoint). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `poetry run black --check` (7 files unchanged); `npx prettier --check` (7 files). Reviewer re-run: exit 0. |
| **2. Linting** | PASS | `poetry run ruff check` (All checks passed); `npm run lint` exit 0. |
| **3. Type checking** | PASS | `poetry run pyright` (0 errors); `npm run typecheck` exit 0. |
| **4. Architecture boundaries** | PASS | No dependency-cruiser or import-linter configuration applies (`rc1-final-python-architecture`, `rc1-final-typescript-architecture` evidence). |
| **5. Testing** | PASS | Python full suite 7114 passed (1 deselected, #510 local-only); TypeScript 4023 passed. |
| **6. Contract** | PASS | No exported API break (rc1 contract evidence). |
| **7. Integration** | PASS | `evidence/qa-gates/rc1-final-typescript-integration.2026-10-16T04-23.md`. |
| **Full toolchain loop** | PASS | Loop iteration 1, 0 restarts (`evidence/qa-gates/rc1-final-qa-clean-pass.2026-10-16T04-24.md`). |
| **Explicit reporting** | PASS | Commands, exit codes, and figures recorded for every stage, including both lcov artifacts. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit messages, `spec.md`, `remediation-plan.2026-10-16T01-36.md`. |
| **Design choices explained** | PASS | Remediation plan sections "The CR-5 change, decided", caller analyses, and "Pairing consequence". |
| **Update supporting documents** | PASS | In-file docstrings and comments. `spec.md` was not updated to list the CR-5 files (non-blocking CR-7 in the code review). |
| **Provide next steps** | PASS | AC18 deferred to S9. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check <7 files>`<br>**Result:** 7 files would be left unchanged (reviewer re-run). |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check <7 files>`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <7 files>`<br>**Result:** 0 errors, 0 warnings, 0 informations. |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest --no-cov -q <8 epic-planner test files>`<br>**Result:** 97 passed (reviewer); 7114 full suite (executor evidence). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | All new signatures annotated; `Sequence[object]` widening is type-safe; `cast` usage follows the module pattern. |
| **Dataclasses for value objects** | N/A | Tuples are used for transient `(index, feature[, plan])` pairs; no value object introduced. |
| **Protocols/ABCs for interfaces** | PASS | Tests implement the existing `ReadinessGitRepository` protocol. |
| **Avoid utility classes** | PASS | Module-level functions only. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | Validators return error strings; no exception handling changed. |
| **Logging over print** | PASS | No `print` added. |
| **Invariants at construction** | N/A | No classes introduced in production code. |
| **Suppressions** | PASS | Only the two pre-authorized `# noqa: S105 - test fixture data` lines from cycle 0; cycle 1 adds none. |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | `npx prettier --check <7 files>`: All matched files use Prettier code style. |
| **Linting with ESLint** | PASS | `npm run lint`: exit 0. |
| **Type checking with tsc** | PASS | `npm run typecheck`: exit 0. |
| **No untyped escape hatches** | PASS | No `any`, `as unknown as`, `@ts-ignore`, or `eslint-disable` added. |
| **Coverage artifact** | PASS | `extensions/drm-copilot/coverage/lcov.info` present; per-file and repo-wide figures above thresholds. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `pytest.mark.parametrize` with ids; no other framework. |
| **Coverage expectation** | PASS | All three changed modules >= 94% lines / >= 88% branches; repo-wide 93.86% / 88.21%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One prefix site per test. |
| **Mocking sparingly** | PASS | Only git is faked. |
| **Organization** | PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_<site>_prefix_uses_original_index_<condition>` naming. |
| **Docstrings/comments** | PASS | One-line docstring per test and helper. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest`<br>**Result:** pass. |
| **No Alternative Test Runners** | PASS | Pytest only. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | PASS | `@jest/globals`, `it.each` for non-object and empty-input matrices. |
| **Organization** | PASS | `extensions/drm-copilot/test/lib/validate/` mirrors `src/lib/validate/`. |
| **Determinism** | PASS | No timers, no `Date.now()`, no I/O. |
| **Coverage expectation** | PASS | Artifact-verified: all three changed files >= 96% lines / >= 94% branches; repo-wide 97.28% / 92.34%. |

---

## 5. Test Coverage Detail

### Original-index prefixes (cycle 1, CR-5): 14 Python cases, 14 TypeScript cases

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_ready_gate_prefix_uses_original_index_after_non_object_entry[string/null/number/list]` / TS `it.each` | Negative | indexed ready-gate loop | PASS |
| `test_ready_gate_receipt_prefix_uses_original_index_under_codex_flag` / TS twin | Edge Case | receipt blocks under a Codex flag with a shifted index | PASS |
| `test_dependency_wave_prefixes_use_original_index_after_non_object_entry` / TS twin | Negative | all three dependency-wave loops | PASS |
| `test_launch_binding_prefix_uses_original_index_under_codex_flag` / TS twin | Negative | raw `checkpoint_entries` / `entries` passed to launch bindings | PASS |
| `test_ready_gate_prefix_unchanged_without_non_object_entries` / TS twin | Positive | control | PASS |
| `test_planning_commit_prefix_uses_original_index_after_non_object_entry` / TS twin | Negative | `_pair_plans_with_features` skip of non-object entry | PASS |
| `test_planning_commit_prefix_uses_original_index_after_planless_entry` / TS twin | Negative | skip of entry whose `plan_path` does not match | PASS |
| `test_planning_commit_prefix_unchanged_without_skipped_entries` / TS twin | Positive | control | PASS |
| `test_planning_commit_prefix_keeps_positional_pairing_without_plan_paths` / TS twin | Edge Case | positional fallback | PASS |
| `test_plans_without_object_entries_report_no_feature_error[empty/not-list]` / TS `it.each` | Edge Case | empty and non-list inputs | PASS |

### Per-feature receipt key gate (original change): 7 Python cases, 7 TypeScript cases, 1 extended MCP test

Unchanged since the prior review; all pass on reviewer re-run (see `policy-audit.2026-10-16T01-36.md` Section 5 for the list).

**Coverage:** see Section 1.2.1.

**Not covered:** every uncovered line in the six changed production files is a context line outside the added hunks. Python `validate_epic_planner_state.py` line 276 (`if len(indexed_features) < 2:`) is a modified line whose true arm is not taken in the coverage run; the guarded line 277 was already uncovered at baseline (old line 271), so this is a pre-existing gap carried through a rename, not a regression (non-blocking CR-9 in the code review).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | Python 7114 full suite; TypeScript 4023 | PASS |
| Tests Passed | 100% of executed | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Python full suite 142.94s with coverage; reviewer targeted 1.41s | PASS |
| Average Time per Test | about 15ms (reviewer targeted Python) | PASS |
| Discovery Time | Not separately recorded | N/A |
| Functions/Classes Tested | All changed functions in both runtimes, including `_pair_plans_with_features` / `pairPlansWithFeatures` and `_plan_path` | PASS |
| Test File Size | 107 to 429 lines | PASS |
| Code Coverage | Python 93.86% / 88.21% repo-wide; TypeScript 97.28% / 92.34% repo-wide | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <7 files>` | 7 unchanged | PASS |
| Ruff Linting | `poetry run ruff check <7 files>` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright <7 files>` | 0 errors | PASS |
| Pytest Tests | `poetry run pytest --no-cov -q <8 files>` | 97 passed | PASS |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check <7 files>` | clean | PASS |
| ESLint | `npm run lint` | exit 0 | PASS |
| tsc | `npm run typecheck` | exit 0 | PASS |
| Jest | `node run-jest.cjs <8 suites>` | 89 passed | PASS |
| Coverage artifact | `extensions/drm-copilot/coverage/lcov.info` | present, thresholds met | PASS |

**For PowerShell:** N/A - no PowerShell files changed.

**Notes:** The Python full suite deselects `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, the local-only failure tracked in #510; CI runs it.

---

## 8. Gaps and Exceptions

### Identified Gaps

No FAIL finding. The prior blocking finding PA-1 is closed: `extensions/drm-copilot/coverage/lcov.info` exists, post-dates the last code commit, and its figures (repo-wide 97.28% / 92.34%; `epic-planner-state-core.ts` 98.38% / 94.12%) were re-derived by the reviewer.

Non-blocking findings (no remediation required for merge):

- **PA-N1 (Info, same feature):** AC18 (PR closes #543, CI success on final head) is CI-dependent and pending; it is checked off at S9.
- **PA-N2 (closed):** `artifacts/python/lcov.info` now carries 214 `SF:` records and a repository-wide figure (93.86% / 88.21%).
- **PA-N3 (Nit, same file as this change):** the TypeScript call site passes `requireLaunchPaths` as `keyGated`. Spec-mandated; carried forward as code-review CR-3.
- **PA-N4 (Info, unrelated to the change content):** `origin/main` (`de4f91294`) is 53 commits ahead of the merge base. None of the 14 code files changed on this branch is changed on `main` in that range; rebase onto `main` before opening the PR.

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
18. **3d1386f78** - docs(543): add initial feature review artifacts
19. **02e1aa0b5** - docs(543): add remediation plan for review cycle 1
20. **7c5b6fd16** - docs(543): revise remediation plan after preflight round 1
21. **259c93f7a** - docs(543): record remediation cycle 1 plan and baselines
22. **a066f7b22** - test(543): add fail-before tests for original feature indices in planner prefixes
23. **7f727fa41** - fix(543): use original feature indices in Python planner validation prefixes
24. **dbd82313e** - fix(543): use original feature indices in TypeScript planner validation prefixes
25. **c3aa91074** - docs(543): record remediation cycle 1 verification evidence
26. **ff781cc2a** - docs(543): record remediation cycle 1 Python final QA evidence
27. **f6c8ceae4** - docs(543): record remediation cycle 1 TypeScript lcov coverage evidence
28. **c99c528a9** - docs(543): record remediation cycle 1 closeout evidence

### Files Modified

1. **scripts/dev_tools/validate_epic_planner_state.py** (MODIFIED) - key-gated per-feature receipts; `_extract_features` returns `(index, feature)` pairs; dependency-wave and ready-gate loops use original indices; launch bindings receive the raw checkpoint entries.
2. **scripts/dev_tools/epic_planner_git_integrity.py** (MODIFIED) - `_plan_path` and `_pair_plans_with_features` pair each plan with its owning entry and original index, with a positional fallback.
3. **scripts/dev_tools/_epic_orchestrator_state_launch_binding.py** (MODIFIED) - planner entry point parameter widened to `Sequence[object]`; docstring states the original-index rule.
4. **extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts** (MODIFIED) - TypeScript twin of item 1.
5. **extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts** (MODIFIED) - TypeScript twin of item 2 (`pairPlansWithFeatures`).
6. **extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts** (MODIFIED) - parameter widened to `readonly unknown[]`; JSDoc updated.
7. **Tests** (4 new files from cycle 1, 2 new and 2 modified from cycle 0) - see Code Under Test.
8. **docs/features/active/epic-planner-receipt-checks-key-gate-543/** - issue, spec, research, plans, prior review set, evidence.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

Code, tests, toolchain, coverage artifacts, file size, suppressions, evidence locations, and tier rules comply. No FAIL finding remains. AC18 is pending CI by design.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: research, spec, plan, remediation plan present.
- PASS Design Principles: index pairs reuse existing loops.
- PASS Module & File Structure: all files <= 500 lines.
- PASS Naming, Docs, Comments: updated in both runtimes.
- PASS Toolchain Execution: all seven stages pass in one loop; both coverage artifacts present.
- PASS Summarize & Document: commits, spec, remediation plan.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline
- PASS Python Design & Typing
- PASS Error Handling

**For TypeScript:**
- PASS Tooling (Prettier, ESLint, tsc)
- PASS Coverage artifact

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

**For TypeScript:**
- PASS Framework, Style, Naming
- PASS Coverage artifact

---

### Metrics Summary

- PASS 7114/7114 executed Python tests and 4023/4023 TypeScript tests passing
- PASS All changed functions tested in both runtimes
- PASS Python 93.86% line / 88.21% branch repo-wide (artifact-verified)
- PASS TypeScript 97.28% line / 92.34% branch repo-wide (artifact-verified)
- PASS All format, lint, and type checks passing
- PASS Targeted test execution under 2 seconds (Python)

---

### Recommendation

**Ready for PR**

Rebase onto `main` before opening the PR (PA-N4). Check off AC18 at S9 after CI succeeds on the final head.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py::test_ready_gate_prefix_uses_original_index_after_non_object_entry[string|null|number|list]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py::test_ready_gate_receipt_prefix_uses_original_index_under_codex_flag`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py::test_dependency_wave_prefixes_use_original_index_after_non_object_entry`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py::test_launch_binding_prefix_uses_original_index_under_codex_flag`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py::test_ready_gate_prefix_unchanged_without_non_object_entries`
- `tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py::test_planning_commit_prefix_uses_original_index_after_non_object_entry`
- `tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py::test_planning_commit_prefix_uses_original_index_after_planless_entry`
- `tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py::test_planning_commit_prefix_unchanged_without_skipped_entries`
- `tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py::test_planning_commit_prefix_keeps_positional_pairing_without_plan_paths`
- `tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py::test_plans_without_object_entries_report_no_feature_error[empty|not-list]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py` (7 cases, unchanged since the prior review)
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_resolved_child_model_receipt` (updated in cycle 0)
- validateEpicPlannerStateText original feature index (8 cases)
- validatePlanningGitIntegrity original feature index (6 cases)
- validateEpicPlannerStateText per-feature receipt key gate (7 cases)
- validateOrchestrationServiceCall › threads the Codex flags into epic-planner-state (extended)

---

## Appendix B: Toolchain Commands Reference

Reviewer-executed (worktree root, 2026-10-16):

```bash
git diff --stat adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99..HEAD
git diff --name-status adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99..HEAD -- . ":!docs"
poetry run black --check <7 Python files>
poetry run ruff check <7 Python files>
poetry run pyright <7 Python files>
poetry run pytest --no-cov -q -p no:cacheprovider <8 epic-planner test files>
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
npx prettier --check <7 TypeScript files>        # from extensions/drm-copilot
npm run lint                                     # from extensions/drm-copilot
npm run typecheck                                # from extensions/drm-copilot
node run-jest.cjs <8 suites>                     # from extensions/drm-copilot
python -I SCRATCH/perfile.py <lcov.info> <changed files>   # per-file LH/LF, BRH/BRF, DA:n,0 lines
git diff -U0 adb9aa5f0..HEAD -- scripts/dev_tools extensions/drm-copilot/src   # added-line ranges
git diff --name-only adb9aa5f0 de4f91294 -- <changed directories>              # main overlap check
```

**For PowerShell:** not run; no PowerShell files changed.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-16
**Policy Version:** Current (as of audit date)

# Policy Compliance Audit: Epic planner ready gate key-gates the planner topology receipt (#543)

---

**Audit Date:** 2026-10-10
**Audit Type:** Initial feature review (review pass 1) for branch `bug/epic-planner-topology-receipt-gate-543`.
**Diff scope:** `git diff 7bbd0b9b990737642b4eeded01a27b7c5c8348b3...HEAD` (merge base equals the current `origin/main` tip, confirmed by `git merge-base origin/main HEAD` and `git rev-parse origin/main`); head `e7612e93a4e88f68eadae6ee9e34ead251c82872`. 60 paths, 5 outside the feature folder.
**Code Under Test:** Python: `scripts/dev_tools/validate_epic_planner_state.py` (production), `tests/scripts/dev_tools/test_validate_epic_planner_state.py` (test). TypeScript: `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (production), `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` and `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` (test). Feature-folder documents and evidence under `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files (1 production, 1 test; both modified, none new) | 71 targeted tests (reviewer re-run at e7612e93); 6746 full-suite tests (executor) | ✅ 71 pass, 0 fail | `validate_epic_planner_state.py` 91.71% lines, 84.04% branches; repo-wide 93.70% lines (TOTAL 17571 stmts, 1107 missed), 92% combined | `validate_epic_planner_state.py` 91.76% lines, 84.38% branches (reviewer parse of `artifacts/python/lcov.info`: LF 182, LH 167, BRF 96, BRH 81); repo-wide 93.70% lines (TOTAL 17572 stmts, 1107 missed), 92% combined | 100% of added executable lines (348, 349); 100% of new arcs (348->349, 348->352) |
| TypeScript | 3 files (1 production, 2 test; all modified, none new) | 63 tests in 5 suites (reviewer re-run at e7612e93); 3951 full-suite tests (executor) | ✅ 63 pass, 0 fail | `epic-planner-state-core.ts` 98.3% lines, 93.57% branches; repo-wide 97.23% lines, 92.01% branches (executor Jest text reporter) | `epic-planner-state-core.ts` 98.31% lines, 93.8% branches; repo-wide 97.23% lines, 92.01% branches (executor Jest text reporter only; no lcov artifact on disk) | 100% of added executable lines (444-446 absent from `Uncovered Line #s`) per executor text output |
| PowerShell | 0 files | N/A | N/A (no PowerShell file changed) | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A (no C# file changed) | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: text-reporter baseline at `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-typescript-test-coverage.2026-10-10T08-06.md` (command used `--coverageReporters=text --coverageReporters=text-summary`, so no lcov file was written)
- TypeScript post-change coverage artifact: absent. Neither `coverage/lcov.info` nor `extensions/drm-copilot/coverage/lcov.info` exists in the worktree (reviewer `ls` and `find -name lcov.info` in this pass). The executor's post-change run `evidence/qa-gates/final-typescript-test-coverage.2026-10-10T08-20.md` used text reporters only. Disposition: FAIL (PA-1).
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Per-language comparison summary: Section 1.2.1 of this audit; Python artifact `artifacts/python/lcov.info` (5454 bytes, written 2026-10-10 08:19, after the last Python code commit `e1f4ff1b4` at 08:11:20); TypeScript text-reporter evidence only

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required.

**Fail-closed rule:** If any required baseline artifact, QA artifact, or coverage-comparison artifact is absent, the verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence rule:** Audit evidence is not synthesized or backfilled from memory or inference. The Python lcov artifact was opened and parsed by the reviewer in this pass. TypeScript figures are quoted from executor evidence files because no TypeScript coverage artifact exists to parse; the reviewer did not regenerate coverage (agent contract: verification from existing artifacts only).

---

## Executive Summary

The branch key-gates the planner-level `topology_receipt` check in both runtimes. The Python call at `scripts/dev_tools/validate_epic_planner_state.py:348-351` and the TypeScript call at `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts:444-446` now run only when a Codex flag is asserted or the checkpoint carries a top-level `topology_receipt` key. Error strings, signatures, MCP schemas, the Python CLI, guidance, mirrors, and the Jest configuration are unchanged.

The reviewer re-ran, check-only, at head `e7612e93`: Black, Ruff, Pyright, and the four-file targeted pytest selection (71 passed); Prettier, ESLint (`npm run lint`), `tsc` (`npm run typecheck`), and the five-suite targeted Jest selection (63 passed). All exited 0.

One blocking finding exists: **PA-1**, the TypeScript coverage artifact is absent. The executor's TypeScript coverage evidence is text-reporter output only, which the spec's AC13 command prescribes, so the substantive figures are recorded but cannot be verified against an artifact. Remediation requires no code change: one Jest coverage run with the `lcov` reporter and an evidence record. The same defect class was raised as blocking in the PR #829 precedent review (`docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-inputs.2026-10-02T05-58.md` line 22).

**Policy documents evaluated:**
- ✅ `CLAUDE.md`
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` and `quality-tiers.yml` (`scripts/dev_tools` T4, `extensions/drm-copilot` T3)
- ✅ `.claude/rules/tonality.md`
- ✅ `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- ✅ `.claude/skills/acceptance-criteria-tracking/SKILL.md`

**Language-specific policies evaluated:**
- ✅ `.claude/rules/python.md` and `.claude/rules/python-suppressions.md`
- ✅ `.claude/rules/typescript.md` and `.claude/rules/typescript-suppressions.md`
- N/A `.claude/rules/powershell.md` (no PowerShell file changed)
- N/A `.claude/rules/csharp.md` (no C# file changed)

Threshold note: the agent contract's verification procedure cites 90% new-file and 80% repo-wide figures, while its threshold section and `.claude/rules/quality-tiers.md` set a uniform 85% line / 75% branch floor. This audit applies 85% / 75%. No new file was added; both changed production files also exceed 90% lines.

**PR context artifacts:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in the worktree. They were not regenerated because the caller restricted writes to the feature folder, and the collector writes under `artifacts/`. The reviewer used `git diff 7bbd0b9b...HEAD` directly as the diff source; this is the same baseline the collector would use, because the merge base equals the `origin/main` tip. Recorded as PA-3 (non-blocking).

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts were added to the branch.
- ✅ No new tooling scripts were added.
- The executor's intermediates `artifacts/python/coverage-543-topology-baseline.json` and `coverage-543-topology-final.json` are in the gitignored `artifacts/` tree and are not in the branch diff.

---

## Rejected Scope Narrowing

The caller prompt was checked for scope narrowing. It contains two scope-related statements:

- "Scope note: the change intentionally key-gates only the planner-level topology_receipt check; the per-feature model_routing_receipt / topology_receipt checks stay unconditional (spec Non-goals), and the PR will state \"Partially addresses #543\". Treat that residual scope as an accepted, documented non-goal, not a finding."
- "Do not write anything outside the feature folder."

Neither narrows the audit scope. The first concerns requirement scope; `spec.md` "Scope & Non-Goals" (lines 55-56) and "Rollout & Follow-up" (lines 253-255) independently exclude the per-feature receipts, so the reviewer reaches the same classification from the authoritative source. The second is a write constraint on review outputs, not a restriction on files reviewed. This audit covers the full branch diff for every changed language (Python and TypeScript). No narrowing was rejected.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (worktree root); exit 0, no output.
- `git diff --name-status 7bbd0b9b...HEAD` lists no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 51 evidence files are under the canonical `<FEATURE>/evidence/` tree: `baseline/` (18), `other/` (1), `qa-gates/` (22), `regression-testing/` (10).
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Each new test builds fresh state with `_ready_state()` (Python) or `readyState()` (TypeScript). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One gate outcome per test case; parametrization separates the two Codex flags. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer re-run: 71 Python tests in 0.29 s; 63 Jest tests in 1.7 s. |
| **Determinism** - Consistent results | ✅ PASS | In-memory JSON fixtures; no clock, randomness, network, or temporary files. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Names match the spec AC text; one-line docstrings on every new Python test. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Python per-file and TOTAL in `evidence/baseline/baseline-python-per-file-coverage.2026-10-10T08-04.md` and `baseline-python-test-coverage.2026-10-10T08-04.md`; TypeScript text row in `baseline-typescript-test-coverage.2026-10-10T08-06.md`. |
| **No Coverage Regression** | ⚠️ PARTIAL | Python artifact-verified: 91.71% -> 91.76% lines, 84.04% -> 84.38% branches. TypeScript: 98.3% -> 98.31% lines, 93.57% -> 93.8% branches per executor text output; no artifact to verify against (PA-1). |
| **New Code Coverage** | ⚠️ PARTIAL | Python: added executable lines 348 and 349 are absent from the lcov zero-hit set; both arcs from 348 executed. TypeScript: lines 444-446 absent from `Uncovered Line #s` in executor text output; not artifact-verified (PA-1). |
| **Comprehensive Coverage** | ✅ PASS | Both outcomes of the new conditional (run and skip) exercised in each runtime; the run outcome reached by both the flag and the key-presence disjuncts. |
| **Positive Flows** - Valid inputs | ✅ PASS | Key absent with no flag; present valid receipt with and without `require_codex_topology`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Key absent under each Codex flag; present `null` with no flag. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Present `null` pins key-membership (not truthiness) semantics. |
| **Error Handling** - Error paths | ✅ PASS | Exact error string `Epic planner topology_receipt must be an object.` asserted byte-identically in both runtimes. |
| **Concurrency** - If applicable | N/A | Pure validators. |
| **State Transitions** - If applicable | N/A | Stateless validation functions. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 91.71% lines, 84.04% branches for `validate_epic_planner_state.py`; repo-wide 93.70% lines -> Post-change: 91.76% lines, 84.38% branches for `validate_epic_planner_state.py` (reviewer parse of `artifacts/python/lcov.info`); repo-wide 93.70% lines. Change: +0.05 lines, +0.34 branches on the changed file; zero-hit line set identical to baseline after the two-line docstring shift (324 -> 326). New/changed-code coverage: 100% of added executable lines (348, 349) and 100% of new arcs. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-python-per-file-coverage.2026-10-10T08-17.md`, `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/coverage-delta-verification.2026-10-10T08-21.md`.
- TypeScript: Baseline: 98.3% lines, 93.57% branches for `epic-planner-state-core.ts`; repo-wide 97.23% lines, 92.01% branches -> Post-change: 98.31% lines, 93.8% branches for `epic-planner-state-core.ts`; repo-wide 97.23% lines, 92.01% branches (executor text reporter). Change: +0.01 lines, +0.23 branches on the changed file per text output. New/changed-code coverage: 100% of added executable lines per text output. Disposition: FAIL (the mandatory coverage artifact is absent; the figures are not artifact-verified; see PA-1). Evidence: `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/qa-gates/final-typescript-test-coverage.2026-10-10T08-20.md`, `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/baseline-typescript-test-coverage.2026-10-10T08-06.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Filtered-list equality (`offending == []`, `toEqual([])`) shows the offending strings on failure; membership assertions name the exact string. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Blank-line-separated sections in every new test, matching the adjacent pre-existing style; the service-call test keeps explicit `// Arrange`, `// Act`, `// Assert` markers. |
| **Document Intent** | ✅ PASS | Python docstrings; descriptive `it(...)` titles with `%p` parameter rendering. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network or process calls. |
| **Use Mocks/Stubs** | ✅ PASS | Existing `VirtualFileSystem` fake in the service-call test. |
| **Environment Stability** | ✅ PASS | No temporary files; no global state. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ⚠️ PARTIAL | This document. One blocking item (PA-1) remains. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` (Work Mode `full-bug`), `spec.md`, `research/research.2026-10-08T14-00.md`. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md` lists the policy files read. |
| **Document the plan** | ✅ PASS | `plan.2026-10-08T13-56.md`, 64 of 64 tasks checked; `## Plan Deviations` records 8 execution-route deviations, none of which changes the write set or a test assertion. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One condition per runtime reusing the existing activation value (`key_gated` / `requireLaunchPaths`). |
| **Reusability** | ✅ PASS | Reuses the PR #829 key-membership idiom (`"launch_receipt_path" in feature` at `epic-orchestrator-state-launch-binding.ts:238`). |
| **Extensibility** | ✅ PASS | No signature change; option bag and keyword-only parameters unchanged. |
| **Separation of concerns** | ✅ PASS | Pure validation logic only. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Changes confined to the existing call sites. |
| **Under 500 lines** | ✅ PASS | Reviewer `awk 'END{print NR}'`: 375, 474, 424, 490, 232. |
| **Public vs internal** | ✅ PASS | No export added or removed (`git diff` shows no `export` or `def` line change). |
| **No circular dependencies** | ✅ PASS | No import added to production code; the test adds one `import type`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Test names and helper tables (`codexFlagCases`, `validReceiptCases`) are descriptive. The activation variable names are now narrower than their use (CR-1, non-blocking; rename deferred by `spec.md` line 61). |
| **Docs/docstrings** | ✅ PASS | Python docstring (lines 289-293) and both comments (Python 330-331, TypeScript 423-424) updated to describe the new gate. |
| **Comment why, not what** | ✅ PASS | Comments state the gating rule. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Reviewer: `black --check` 2 files unchanged; `prettier --check` 3 files clean. |
| **2. Linting** | ✅ PASS | Reviewer: `ruff check --no-fix` all checks passed; `npm run lint` exit 0. |
| **3. Type checking** | ✅ PASS | Reviewer: `pyright` 0 errors; `npm run typecheck` (both `tsc` projects) exit 0. |
| **4. Architecture** | ✅ PASS | No architecture-boundary tool is configured (reviewer `git ls-files "*cruiser*" "*importlinter*"` returns only feature-folder evidence notes, no configuration). Presence check recorded by executor (PA-5, non-blocking observation). |
| **5. Testing** | ✅ PASS | Reviewer: 71 pytest passed; 63 Jest passed. Executor full suites: 6746 pytest, 3951 Jest. |
| **6. Contract** | ✅ PASS | MCP definition, input, and dispatch files unchanged; no exported declaration or `def` signature changed. |
| **7. Integration** | ✅ PASS | Reviewer five-suite Jest run including `mcp-server-epic-validation.test.ts`: 63 passed. |
| **Full toolchain loop** | ✅ PASS | `evidence/qa-gates/final-qa-clean-pass.2026-10-10T08-22.md`: single clean iteration, 0 restarts. |
| **Explicit reporting** | ✅ PASS | Commands, exit codes, and deviations recorded. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Conventional commits scoped `(543)`. |
| **Design choices explained** | ✅ PASS | `spec.md` Proposed Fix, Boundaries and invariants, Non-goals. |
| **Update supporting documents** | ✅ PASS | No guidance or mirror change required (`spec.md` Assumptions; Codex callers assert both flags). |
| **Provide next steps** | ✅ PASS | `spec.md` Rollout & Follow-up: per-feature receipts and contract-gap follow-up; PR must state "Partially addresses #543". |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check <2 files>`<br>**Result:** 2 files would be left unchanged. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check --no-fix <2 files>`<br>**Result:** All checks passed. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright <2 files>`<br>**Result:** 0 errors, 0 warnings. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest --no-cov -p no:cacheprovider -q <4 files>`<br>**Result:** 71 passed in 0.29 s. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | No new parameters; `state` is `dict[str, Any]` after the `isinstance` guard at line 300. |
| **Dataclasses for value objects** | N/A | No value objects added. |
| **Protocols/ABCs for interfaces** | N/A | No interfaces added. |
| **Avoid utility classes** | ✅ PASS | No classes added. |
| **Suppressions** | ✅ PASS | No `# noqa`, `# type: ignore`, or `# pyright:` comment added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | Validator returns error lists; no exception handling changed. |
| **Logging over print** | ✅ PASS | No print or logging changes. |
| **Invariants at construction** | N/A | No classes added. |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | Reviewer `prettier --check` over 3 files: clean. |
| **Linting with ESLint** | ✅ PASS | Reviewer `npm run lint` (`eslint src test`): exit 0. |
| **Type checking with tsc** | ✅ PASS | Reviewer `npm run typecheck`: exit 0. |
| **Untyped escape hatches (T3: <= 5 per file, justified)** | ✅ PASS | No `any` added; test tables typed with `Pick<ValidateEpicPlannerStateOptions, ...>`. |
| **Suppressions** | ✅ PASS | No `eslint-disable`, `@ts-ignore`, or `@ts-expect-error` added. |

PowerShell and C# sections are omitted because no files in those languages changed on the branch.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Plain functions and `pytest.mark.parametrize`. |
| **Coverage expectation** | ✅ PASS | 91.76% lines, 84.38% branches (floors 85 / 75), artifact-verified. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One outcome per test case. |
| **Mocking sparingly** | ✅ PASS | No mocks. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |
| **Invariant pinning** | ⚠️ PARTIAL | The modified test no longer pins per-feature `topology_receipt` enforcement in key-gated mode (CR-2, non-blocking). |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<behaviour>` names matching the AC text. |
| **Docstrings/comments** | ✅ PASS | One-line docstrings on every new test. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest ...`<br>**Result:** 71 passed. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest via run-jest.cjs** | ✅ PASS | Reviewer ran `npm run test -- <5 suites>` (`node run-jest.cjs`). |
| **Coverage expectation** | ❌ FAIL | Text-reporter figures exceed 85 / 75, but no coverage artifact exists to verify them (PA-1). |
| **Organization** | ✅ PASS | `test/lib/validate/` mirrors `src/lib/validate/`. |
| **Determinism** | ✅ PASS | No timers or real I/O. |

---

## 5. Test Coverage Detail

### Python planner topology receipt gate (7 new or modified test cases)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_ready_gate_skips_planner_topology_receipt_when_key_absent` | Positive | 348 false outcome (348->352) | ✅ |
| `test_codex_flag_keeps_planner_topology_receipt_unconditional[require_codex_model_routing]` | Negative | 348 true via flag; 349 | ✅ |
| `test_codex_flag_keeps_planner_topology_receipt_unconditional[require_codex_topology]` | Negative | 348 true via flag; 349 | ✅ |
| `test_ready_gate_validates_present_null_planner_topology_receipt` | Edge Case | 348 true via key presence | ✅ |
| `test_ready_gate_accepts_present_valid_planner_topology_receipt[False]` | Positive | 348 true via key presence | ✅ |
| `test_ready_gate_accepts_present_valid_planner_topology_receipt[True]` | Positive | 348 true via flag | ✅ |
| `test_readiness_requires_epic_preparation_topology_receipts` (modified) | Negative | 348 true via flag | ✅ |

**Coverage:** `validate_epic_planner_state.py` 91.76% lines / 84.38% branches.

### TypeScript planner topology receipt gate (6 new test cases plus 3 new assertions)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `skips the planner topology receipt when the key is absent without a Codex flag` | Positive | 444 false outcome | ✅ |
| `keeps the planner topology receipt unconditional under %p` (2 cases) | Negative | 444-445 via flag | ✅ |
| `validates a present null planner topology receipt without a Codex flag` | Edge Case | 444-445 via key presence | ✅ |
| `accepts a present valid planner topology receipt under %p` (2 cases) | Positive | 444-445 | ✅ |
| `threads the Codex flags into epic-planner-state` (3 assertions added) | Contract | MCP dispatch, both flags and key-gated | ✅ |

**Coverage:** `epic-planner-state-core.ts` 98.31% lines / 93.8% branches (executor text reporter; not artifact-verified).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 71 Python targeted + 63 TypeScript targeted (reviewer, e7612e93); 6746 + 3951 full suites (executor) | ✅ |
| Tests Passed | 134 of 134 targeted (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 0.29 s (pytest), 1.7 s (Jest) | ✅ Fast |
| Average Time per Test | under 10 ms (pytest) | ✅ Fast |
| Discovery Time | Not separately reported | ✅ |
| Functions/Classes Tested | 2 of 2 changed functions | ✅ |
| Test File Size | 232 to 490 lines | ✅ Maintainable |
| Code Coverage (if applicable) | Python 91.76% / 84.38% (artifact); TypeScript 98.31% / 93.8% (text only) | ⚠️ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <2 files>` | 2 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check --no-fix <2 files>` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright <2 files>` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest --no-cov <4 targeted files>` | 71 passed | ✅ |
| Coverage artifact | reviewer parse of `artifacts/python/lcov.info` | LF 182, LH 167, BRF 96, BRH 81 | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npm exec -- prettier --check <3 files>` | clean | ✅ |
| ESLint | `npm run lint` | exit 0 | ✅ |
| tsc | `npm run typecheck` | exit 0 | ✅ |
| Jest | `npm run test -- <5 suites>` | 5 suites, 63 passed | ✅ |
| Coverage artifact | `find <worktree> -name lcov.info` | only `artifacts/python/lcov.info` found | ❌ |

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (Blocking): TypeScript coverage artifact absent.** TypeScript has 3 changed files on the branch. Neither `coverage/lcov.info` nor `extensions/drm-copilot/coverage/lcov.info` exists. The executor's coverage runs (`evidence/baseline/baseline-typescript-test-coverage.2026-10-10T08-06.md`, `evidence/qa-gates/final-typescript-test-coverage.2026-10-10T08-20.md`) used `--coverageReporters=text --coverageReporters=text-summary`, which overrides the `lcov` reporter configured at `extensions/drm-copilot/jest.config.cjs:18`. The agent contract states: "coverage artifact absent for [language]; coverage verification is mandatory for all languages with changed files." The recorded text figures (98.31% / 93.8%) exceed the floors, so the expected outcome of remediation is a confirmation, not a code change. Remediation: from `extensions/drm-copilot/`, run `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text --coverageReporters=text-summary`, parse the `epic-planner-state-core.ts` record (LF/LH/BRF/BRH) and confirm lines 444-446 have non-zero hits, and record the result under `evidence/qa-gates/`.
- **PA-2 (Non-blocking): Python lcov artifact is file-scoped.** `artifacts/python/lcov.info` contains one record (`validate_epic_planner_state.py`) because the last coverage run to write it was the targeted P7-T8 run. Repo-wide Python figures are taken from the executor's full-suite TOTAL row (93.70% lines computed from 17572 / 1107; 92% combined). Per-file verification, the binding check for the changed file, is artifact-backed.
- **PA-3 (Non-blocking): PR context artifacts absent and not regenerated.** See the Executive Summary. The direct `git diff` against the confirmed merge base was used.
- **PA-4 (Non-blocking): no per-file Jest threshold for the changed TypeScript file.** `extensions/drm-copilot/jest.config.cjs` has no `coverageThreshold` entry for `./src/lib/validate/epic-planner-state-core.ts` and no `global` key, so CI does not gate this file's coverage. `spec.md` lines 66 and 167 exclude `jest.config.cjs` from this change and record the assumption. Candidate for the follow-up issue.
- **PA-5 (Non-blocking): architecture stage is a presence check.** No dependency-cruiser or import-linter configuration exists in the repository; the executor and reviewer both confirmed this. The stage cannot fail for this change.

### Approved Exceptions

- **Residual #543 scope.** The per-feature `model_routing_receipt` and `topology_receipt` checks remain unconditional (`spec.md` Non-goals line 56; Rollout & Follow-up lines 253-255). The PR must state "Partially addresses #543" and must not use a closing keyword.
- **Python CLI parity.** `scripts/dev_tools/validate_orchestration_artifacts.py` is unchanged (`spec.md` line 57).
- **Execution-route deviations.** `plan.2026-10-08T13-56.md` `## Plan Deviations` items 1-8 change command routing only (npm `--prefix`, scratchpad diff files, split invocations, reporter selection); none changes a write-set path or an assertion.

### Removed/Skipped Tests

**None.** One pre-existing node (#510) is deselected identically at baseline and final in the executor's full Python suite.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **1aa280ded** - docs(543): prepare planner topology-receipt key-gating fix
2. **2596bfd10** - Merge remote-tracking branch 'origin/main'
3. **325e8407e** - docs(543): record Phase 0 policy reads and baseline evidence
4. **38d21557c** - test(543): add fail-before regression tests for planner topology receipt gate
5. **0192f0a0f** - fix(543): key-gate the Python planner topology receipt check
6. **bc8973bdf** - fix(543): key-gate the TypeScript planner topology receipt check
7. **e1f4ff1b4** - test(543): cover the Python planner topology receipt matrix
8. **7ca7068cb** - test(543): add TypeScript planner topology receipt twins and MCP assertion
9. **8a090c531**, **cd7f3fc85**, **88963c2ba**, **e7612e93a** - docs(543): Phase 6-9 evidence

### Files Modified

1. **scripts/dev_tools/validate_epic_planner_state.py** (MODIFIED) - gate condition, comment, docstring (+10 / -4).
2. **extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts** (MODIFIED) - gate condition and comment (+5 / -2).
3. **tests/scripts/dev_tools/test_validate_epic_planner_state.py** (MODIFIED) - one call updated; four new tests (six cases).
4. **extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts** (MODIFIED) - four new tests (six cases), typed case tables.
5. **extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts** (MODIFIED) - three assertions added.
6. **docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/** (NEW) - issue, spec, research, plan, evidence.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ REMEDIATION REQUIRED

The code change complies with the general, Python, and TypeScript code-change and unit-test policies, and the reviewer's toolchain re-run at `e7612e93` is clean. One blocking item remains: the TypeScript coverage artifact is absent (PA-1). Four non-blocking observations are recorded (PA-2 through PA-5).

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, plan present
- ✅ Design Principles: minimal condition reusing existing activation value
- ✅ Module & File Structure: all files within 500 lines
- ✅ Naming, Docs, Comments: docstring and comments updated
- ✅ Toolchain Execution: clean single pass
- ✅ Summarize & Document: scope, deviations, follow-ups recorded

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright, Pytest clean
- ✅ Python Design & Typing: no signature change
- ✅ Error Handling: error contract unchanged

**For TypeScript:**
- ✅ Tooling: Prettier, ESLint, tsc clean
- ✅ Type safety: no `any`; no suppressions

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: met
- ⚠️ Coverage & Scenarios: Python artifact-verified; TypeScript text-only (PA-1)
- ✅ Test Structure: AAA and docstrings
- ✅ External Dependencies: none
- ⚠️ Policy Audit: one blocking item

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: pytest; floors met
- ⚠️ Test Style & Structure: per-feature key-gated invariant no longer pinned (CR-2, non-blocking)
- ✅ Naming & Readability: met
- ✅ Toolchain: met

**For TypeScript:**
- ❌ Coverage: artifact absent (PA-1)
- ✅ Structure, naming, determinism: met

---

### Metrics Summary

- ✅ 134/134 targeted tests passing (reviewer re-run at e7612e93)
- ✅ 2/2 changed functions exercised on both outcomes of the new condition
- ✅ Python changed file 91.76% lines, 84.38% branches (artifact)
- ⚠️ TypeScript changed file 98.31% lines, 93.8% branches (text output only)
- ✅ Format, lint, and type-check clean in both languages
- ✅ Evidence locations canonical

---

### Recommendation

**Remediate PA-1, then proceed to PR authoring.** Generate `extensions/drm-copilot/coverage/lcov.info` with the command in Section 8, record the per-file values for `epic-planner-state-core.ts` under `evidence/qa-gates/`, and confirm lines 444-446 have non-zero hits. No code change is expected. The PR body must state "Partially addresses #543" and must not use a closing keyword.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_epic_preparation_topology_receipts` (modified)
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_skips_planner_topology_receipt_when_key_absent`
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_codex_flag_keeps_planner_topology_receipt_unconditional[require_codex_model_routing]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_codex_flag_keeps_planner_topology_receipt_unconditional[require_codex_topology]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_validates_present_null_planner_topology_receipt`
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_accepts_present_valid_planner_topology_receipt[False]`
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_gate_accepts_present_valid_planner_topology_receipt[True]`
- validateEpicPlannerStateText › skips the planner topology receipt when the key is absent without a Codex flag
- validateEpicPlannerStateText › keeps the planner topology receipt unconditional under {"requireCodexModelRouting": true}
- validateEpicPlannerStateText › keeps the planner topology receipt unconditional under {"requireCodexTopology": true}
- validateEpicPlannerStateText › validates a present null planner topology receipt without a Codex flag
- validateEpicPlannerStateText › accepts a present valid planner topology receipt under {}
- validateEpicPlannerStateText › accepts a present valid planner topology receipt under {"requireCodexTopology": true}
- validateOrchestrationServiceCall › threads the Codex flags into epic-planner-state (three assertions added)

---

## Appendix B: Toolchain Commands Reference

Commands run by the reviewer in this pass (worktree root `<wt>`; check-only, no source mutation; pytest run with `--no-cov` so no coverage artifact was overwritten):

**For Python:**
```bash
poetry -C <wt> run black --check scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
poetry -C <wt> run ruff check --no-fix scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
poetry -C <wt> run pyright scripts/dev_tools/validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
poetry -C <wt> run pytest --no-cov -p no:cacheprovider -q tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py
poetry -C <wt> run python scripts/dev_tools/validate_evidence_locations.py --root .
grep -E '^(SF|LF|LH|BRF|BRH)' <wt>/artifacts/python/lcov.info
```

**For TypeScript:**
```bash
npm --prefix <wt>/extensions/drm-copilot exec -- prettier --check <3 changed TypeScript files>
npm --prefix <wt>/extensions/drm-copilot run lint
npm --prefix <wt>/extensions/drm-copilot run typecheck
npm --prefix <wt>/extensions/drm-copilot run test -- test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/validate-orchestration-service-call.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/mcp-server-epic-validation.test.ts
find <wt> -name lcov.info -not -path '*/node_modules/*'
```

**Repository state and evidence checks:**
```bash
git merge-base origin/main HEAD
git rev-parse origin/main
git diff --stat 7bbd0b9b990737642b4eeded01a27b7c5c8348b3...HEAD
git diff 7bbd0b9b990737642b4eeded01a27b7c5c8348b3...HEAD -- '*.ts' '*.py'
git log --format="%h %ci %s" 7bbd0b9b990737642b4eeded01a27b7c5c8348b3..HEAD
git ls-files "*cruiser*" "*importlinter*"
awk 'END{print NR}' <each of the 5 changed code files>
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-10
**Policy Version:** Current (as of audit date)

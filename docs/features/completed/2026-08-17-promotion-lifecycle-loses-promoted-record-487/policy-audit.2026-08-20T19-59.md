# Policy Compliance Audit: Promotion Lifecycle Promoted-Record Retention (Issue #487)

**Audit Date:** 2026-08-20
**Code Under Test:**

Production (4):
- `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` (TypeScript)
- `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts` (TypeScript)
- `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` (TypeScript)
- `scripts/dev_tools/new_active_feature_folder_flow.py` (Python)

Tests (8 files):
- `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts` (NEW)
- `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts` (MODIFIED)
- `extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` (MODIFIED)
- `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` (MODIFIED)
- `extensions/drm-copilot/test/lib/promotion-lifecycle-sequence.test.ts` (NEW)
- `tests/scripts/dev_tools/test_new_active_feature_folder.py` (MODIFIED)
- `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py` (MODIFIED)
- `tests/scripts/dev_tools/test_new_active_feature_folder_part5.py` (NEW)

Docs/skill (5): `docs/engineering/Feature Playbook.md`, `docs/features/potential/README.md`, `docs/research/2026-07-09-potential-entries-duplicate-audit.md`, `.claude/skills/feature-promotion-lifecycle/SKILL.md`, and its byte-identical bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md` (verified byte-identical by `cmp`, exit 0).

**Baseline:** `origin/main` @ `cd4b887f4e56606a7aca4bd02e093829b33bf8db` (merge base confirmed in regenerated `artifacts/pr_context.summary.txt`). Head: `bug/promotion-lifecycle-loses-promoted-record-487` @ `6f7f864b`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 3 prod, 5 test | 2654 (full suite); 37 re-run by reviewer | ✅ 2654 pass, 0 fail (executor); 37/37 pass (reviewer re-run of changed suites) | 96.65% lines, 90.00% branches | 96.66% lines, 90.04% branches | Changed-line coverage 100% line / 100% branch (verified against `lcov.info` DA/BRDA records) |
| Python | 1 prod, 3 test | 4062 (full suite); 28 re-run by reviewer | ✅ 4062 pass, 0 fail (executor); 28/28 pass (reviewer re-run of changed suites) | 92.60% lines, 89.80% branches | 92.60% lines, 89.81% branches | Changed-line coverage 100% statement / 100% branch (verified against `artifacts/python/lcov.info`) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-ts-jest-coverage.2026-08-20T18-54.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-ts-jest-coverage.2026-08-20T20-24.md` plus `extensions/drm-copilot/coverage/lcov.info` (parsed independently by this reviewer)
- Python baseline coverage artifact: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/baseline/baseline-py-pytest-coverage.2026-08-20T18-54.md`
- Python post-change coverage artifact: `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/qa-gates/final-py-pytest-coverage.2026-08-20T20-41.md` plus `artifacts/python/lcov.info` (parsed independently by this reviewer)
- PowerShell baseline coverage artifact: N/A - out of scope (zero changed PowerShell files on this branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero changed PowerShell files on this branch)
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-08-20T20-44.md` and Section 1.2.1 below

---

## Executive Summary

This branch fixes issue #487: `new_active_feature_folder` destroyed the promoted lifecycle record under `docs/features/potential/promoted/` by moving it into the active folder as `issue.md`. The fix introduces source-directory-aware disposition (copy when the resolved source is under `promoted/`, move otherwise) at both placement sites in both language implementations, adds a receipt existence post-condition to both MCP service-call layers, inverts two defect-codifying Python assertions, adds a sequenced two-call lifecycle regression, and corrects three conflicting documentation artifacts plus one skill file with its bundled mirror.

The audit verdict is **FULLY COMPLIANT with zero Blocking findings**. All toolchain stages passed in a single consecutive clean pass in both languages (evidence: `evidence/qa-gates/final-qc-loop-ledger.2026-08-20T20-42.md`; targeted suites independently re-run by this reviewer, all green). Coverage thresholds are met for every changed file and repo-wide in both languages, verified by independent parsing of the lcov artifacts, not by trusting the executor's recorded numbers. Three non-blocking findings are recorded in Section 8 and in the code review.

**Policy documents evaluated:**
- ✅ `general-code-change` policy (`.claude/rules/general-code-change.md`)
- ✅ `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ TypeScript: `.claude/rules/typescript.md` (toolchain evidence inspected; targeted suites re-run)
- ✅ Python: `.claude/rules/python.md` (toolchain evidence inspected; targeted suites re-run)
- N/A PowerShell — zero changed `.ps1`/`.psm1` files in the branch diff
- N/A C# — zero changed C# files in the branch diff
- N/A Bash — zero changed shell files in the branch diff
- N/A GitHub Actions — zero changed workflow files; `modified-workflow-needs-green-run` not triggered (no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` in the diff)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts appear in the branch diff.
- ✅ All new files are production code, tests, docs, or canonical evidence.

## Rejected Scope Narrowing

None. The caller directive requested the full feature-vs-base audit (`git diff origin/main...HEAD` against `origin/main` @ `cd4b887f`) with no narrowing. No attempted narrowing was detected.

## Evidence Location Compliance

- The branch diff contains **zero** files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (verified: `git diff origin/main...HEAD --name-only | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"` returned no matches).
- All 48 evidence files are under the canonical `docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/<kind>/` scheme with kinds `baseline/`, `regression-testing/`, `qa-gates/`, and `other/`.
- `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- The executor's own audit at `evidence/qa-gates/evidence-location-audit.2026-08-20T20-48.md` is consistent with this result.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no delegation instruction supplied a non-canonical path to this reviewer.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Every new test constructs its own `Map`-backed fake filesystem (`FakeFolderFileSystem`, `SharedLifecycleFileSystem`, `FakeFileSystem`) inside the test body. No module-level mutable state is shared. Reviewer re-ran the five changed Jest suites together and the three pytest modules together; all green in one process. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One disposition arm per test: full-mode copy, minor-audit copy, sibling-prefix move, unpromoted move, and one post-condition arm per service-call case. Failures identify the exact placement site (fail-before evidence lists per-test assertion failures at `evidence/regression-testing/fail-before-ts-jest.2026-08-20T19-16.md`). |
| **Fast Execution** | ✅ PASS | Reviewer runs: 5 Jest suites / 37 tests in 0.57 s; 3 pytest modules / 28 tests in 0.14 s. |
| **Determinism** | ✅ PASS | Fixed `nowProvider` (`FIXED_INSTANT`) in Jest; fixed `datetime(2024, 1, 2, 3, 4, tzinfo=ZoneInfo(...))` in pytest; injected `GhClient` and `CommandRunner` fakes; no wall-clock reads, no `setTimeout`, no sleeps, no network. |
| **Readability & Maintainability** | ✅ PASS | AAA comments present in every new test; descriptive names (`retains the promoted potential file in minor-audit mode`, `test_create_minor_audit_folder_copies_promoted_potential`); module docstrings state scope and the 500-line split rationale. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | TS: 96.65% lines / 90.00% branches; Py: 92.60% lines / 89.80% branches. Commands and numeric outputs at `evidence/baseline/baseline-ts-jest-coverage.2026-08-20T18-54.md` and `evidence/baseline/baseline-py-pytest-coverage.2026-08-20T18-54.md`, captured before the production change. |
| **No Coverage Regression** | ✅ PASS | TS: +0.01 pp lines, +0.04 pp branches. Py: 0.00 pp lines, +0.01 pp branches. Reviewer independently recomputed repo-wide totals from both lcov artifacts: TS 43055/44542 = 96.66% lines, 6122/6799 = 90.04% branches; Py 13834/14939 = 92.60% lines. |
| **New Code Coverage** | ✅ PASS | Changed-line coverage is 100% line and 100% branch in all four production files. Reviewer verification: uncovered lines in `flow.ts` are exactly {388, 389} (pre-existing, unchanged block); uncovered lines in `new_active_feature_folder_flow.py` are exactly {117, 322, 399-416} (all pre-existing); both service-call files have zero uncovered lines. None intersects a changed range. |
| **Comprehensive Coverage** | ✅ PASS | Both arms of the disposition branch at both placement sites in both languages; both arms of both receipt post-conditions; the containment boundary (sibling-prefix negative case, TS). |
| **Positive Flows** | ✅ PASS | Promoted-copy full mode, promoted-copy minor-audit mode, sequenced two-call lifecycle, enriched-record success arms for both service calls. |
| **Negative Flows** | ✅ PASS | Absent destination path and absent artifact path throw with tool name and path (`BlockedPathFolderFileSystem` / `BlockedPathPotentialFileSystem` fakes force `exists` to return false). |
| **Edge Cases** | ✅ PASS | Sibling path that is a string prefix of the promoted root (`promoted-notes-feature.md`) takes the move branch — asserted with explicit `startsWith` preconditions proving the case discriminates. |
| **Error Handling** | ✅ PASS | Thrown messages asserted to contain both the tool name (`new_active_feature_folder`, `potential_to_issue`) and the absent path. |
| **Concurrency** | N/A | Single-threaded synchronous filesystem workflow; no concurrent access paths introduced. |
| **State Transitions** | ✅ PASS | The sequenced lifecycle test asserts the intermediate state after `promotePotential` (source absent, destination present) before asserting the final state after `createActiveFolder` (record retained byte-identical). |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.65% lines / 90.00% branches -> Post-change: 96.66% lines / 90.04% branches. Change: +0.01 pp lines / +0.04 pp branches. New/changed-code coverage: 100% line and 100% branch on changed lines; per changed file 99.59% lines / 93.33% branches (`flow.ts`), 100% / 100% (`new-active-feature-folder-service-call.ts`), 100% lines / 83.33% branches (`potential-to-issue-service-call.ts`, 3 uncovered branches all pre-existing and outside the diff). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` (independently parsed), `evidence/qa-gates/coverage-delta.2026-08-20T20-44.md`.
- Python: Baseline: 92.60% lines / 89.80% branches -> Post-change: 92.60% lines / 89.81% branches. Change: 0.00 pp lines / +0.01 pp branches. New/changed-code coverage: 100% statement and 100% branch on changed lines; per changed file 92.05% lines / 90.00% branches (`new_active_feature_folder_flow.py`), with uncovered and partial counts (12 / 6) unchanged from baseline while the measured surface grew by 16 statements and 8 branches. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (independently parsed), `evidence/qa-gates/coverage-delta.2026-08-20T20-44.md`.
- PowerShell: zero changed files on the branch. Disposition: N/A (permitted only because no PowerShell file changed).
- C#: zero changed files on the branch. Disposition: N/A (permitted only because no C# file changed).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Fail-before evidence demonstrates the diagnostics in practice: `expect(fs.files.has(promoted)).toBe(true) — Expected: true, Received: false` pinpoints the removed record; `Received function did not throw` pinpoints the missing post-condition. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit `// Arrange` / `// Act` / `// Assert` comments in every new Jest test; `# Arrange` / `# Act` / `# Assert` in every new pytest test. |
| **Document Intent** | ✅ PASS | File-level docblocks state scope, hermeticity, and the reason for the sibling-file split (500-line limit). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, no `gh` process, no real filesystem, no database. `GhClient` and `CommandRunner` are injected fakes. |
| **Use Mocks/Stubs** | ✅ PASS | `Map`-backed filesystem fakes; `BlockedPath*` subclasses override only `exists` to drive the negative arm; `FakeGhClient` supplies canned gh output. |
| **Environment Stability** | ✅ PASS | No temporary files created by any new or modified test (grep of the changed test files shows no `tmp`, `mkdtemp`, `TemporaryDirectory`, or real-path writes). No mutable global state. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document plus `code-review.2026-08-20T19-59.md` and `feature-audit.2026-08-20T19-59.md` constitute the pre-PR review set. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #487; `issue.md` carries the four-observation history and the bracketed reproduction; `spec.md` v0.2 records the confirmed root cause. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md` records the policy reading order execution. |
| **Document the plan** | ✅ PASS | `plan.2026-08-17T15-01.md` (validated by the plan validator; exit 0 with two non-blocking G4 warnings). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The fix is one predicate computed once (`retainsPotentialSource` / `retains_potential_source`) and a two-arm branch at each placement site. Four rejected alternatives are recorded in `spec.md` with reasons. |
| **Reusability** | ✅ PASS | TS containment reuses the existing `isRelativeTo` helper; Python reuses `Path.relative_to`; no new predicate machinery duplicated. |
| **Extensibility** | ✅ PASS | The disposition decision is a named helper (`isPromotedPotentialSource` / `_is_promoted_potential_source`) rather than an inline condition, so a future disposition rule extends one function. |
| **Separation of concerns** | ✅ PASS | The disposition rule lives in the workflow layer; the receipt post-condition lives in the service-call layer only, deliberately, because the Python CLI emits no receipt (spec INV-6). Verified: no assertion was added to `flow.ts`/`promotion.ts`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | No new modules; changes land in the four files that own the affected behavior. |
| **Under 500 lines** | ✅ PASS (changed production files) | `flow.ts` 492; `new-active-feature-folder-service-call.ts` 164; `potential-to-issue-service-call.ts` 209; `new_active_feature_folder_flow.py` 416. Test files: new files 165/260/151; `flow.test.ts` grew 499 → 500 (at, not over, the limit). Pre-existing condition: `tests/scripts/dev_tools/test_new_active_feature_folder.py` is 533 lines on `origin/main` and on this branch — over the limit before this work, changed by a net-zero two-line edit, not worsened. Recorded in Section 8. |
| **Public vs internal** | ✅ PASS | Both new predicates are module-private (unexported function in TS, `_`-prefixed in Python). No public API change; result record shapes unchanged. |
| **No circular dependencies** | ✅ PASS | No new imports between clusters; `evidence/qa-gates/final-ts-architecture.2026-08-20T20-23.md` records the dependency-cruiser configuration search (no config exists; executed as a real command with exit 0, matching the baseline absence record). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `isPromotedPotentialSource`, `retainsPotentialSource`, `requireReportedPathExists`, `_is_promoted_potential_source`, `retains_potential_source` — all state the rule they implement. Naming conventions per language respected. |
| **Docs/docstrings** | ✅ PASS | Full JSDoc on the TS helper (including the sibling-prefix caveat) and a Google-style docstring on the Python helper with Args/Returns. |
| **Comment why, not what** | ✅ PASS | The decide-once comment explains why the disposition is computed a single time ("so both placement sites and both emission sites agree"); the hoist comment explains why the filesystem instance is shared ("the post-condition observes the SAME filesystem the workflow wrote to"). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | TS: `npx prettier --write ...` clean on final iteration (exit 0, 0 rewrites; `--check` confirms). Py: `poetry run black .` clean (438 files unchanged). |
| **2. Linting** | ✅ PASS | TS: `npx eslint --no-error-on-unmatched-pattern src test` — 0 errors, 0 warnings. Py: `poetry run ruff check .` — 0 violations. |
| **3. Type checking** | ✅ PASS | TS: `npx tsc -p ./ --noEmit` — 0 errors. Py: `poetry run pyright` — 0 errors, 0 warnings, 0 informations. |
| **4. Architecture** | ✅ PASS | No dependency-cruiser configuration exists in this repository; the search was executed as a real command with a real exit code rather than skipped (final-ts-architecture evidence). |
| **5. Testing** | ✅ PASS | TS: 195/195 suites, 2654/2654 tests with coverage. Py: 4062 passed, 0 failed. Reviewer re-ran the changed-scope subset in both languages: 37/37 and 28/28. |
| **6. Contract/schema checks** | N/A | No contract or schema surface changed (receipt shapes unchanged; no `artifact_type`, no JSON schema, no MCP signature change). No configured tooling for this scope. |
| **7. Integration tests** | N/A | No configured integration suite for this scope; the sequenced lifecycle test is the cross-cluster verification and runs in the unit loop. |
| **Full toolchain loop** | ✅ PASS | TS final iteration 3, Py final iteration 4, each a single consecutive clean pass. The two Python restarts were policy-correct: a bundle-mirror test failure (genuine defect, remediated) and a changed-line coverage regression treated as blocking despite a zero exit code (remediated by adding the minor-audit copy test). Ledger: `evidence/qa-gates/final-qc-loop-ledger.2026-08-20T20-42.md`. |
| **Explicit reporting** | ✅ PASS | Every stage has a per-iteration evidence file with `Timestamp:`, `Command:`, `EXIT_CODE:` captured directly from the process (no pipes). |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Three commits with conventional messages (`ffa03095`, `ecfb64d3`, `6f7f864b`). |
| **Design choices explained** | ✅ PASS | Spec records the adopted disposition rule and four rejected alternatives; comments record the decide-once and hoist rationales. |
| **Update supporting documents** | ✅ PASS | Feature Playbook, potential README, duplicate-audit correction note, promotion-lifecycle SKILL (4b check), and the bundled mirror — all consistent with the fixed behavior. |
| **Provide next steps** | ✅ PASS | Spec Rollout & Follow-up section present; retroactive record repair explicitly out of scope. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting (Prettier)** | ✅ PASS | Final iteration exit 0, zero rewrites (`evidence/qa-gates/final-ts-prettier.2026-08-20T20-20.md`). |
| **Linting (ESLint)** | ✅ PASS | 0 errors, 0 warnings (`evidence/qa-gates/final-ts-eslint.2026-08-20T20-22.md`). |
| **Type checking (tsc)** | ✅ PASS | 0 errors (`evidence/qa-gates/final-ts-tsc.2026-08-20T20-23.md`). No `any`, no `@ts-ignore`, no suppression added anywhere in the diff (verified by diff inspection). |
| **Strong typing** | ✅ PASS | New helper fully typed (`(potentialPath: string, workspacePath: string): boolean`); `override` keyword used on test fake subclass methods; `readonly` on constructor-injected field. |
| **Error handling** | ✅ PASS | Post-condition failures `throw new Error` with tool name and absent path; no catch-and-continue, no warning-only path (spec's prohibition honored). |

### Section 3B: Python Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | `poetry run black .` — clean, 438 files unchanged (`evidence/qa-gates/final-py-black.2026-08-20T20-39.md`). |
| **Linting with Ruff** | ✅ PASS | `poetry run ruff check .` — 0 violations (`evidence/qa-gates/final-py-ruff.2026-08-20T20-40.md`). |
| **Type checking with Pyright** | ✅ PASS | 0 errors, 0 warnings, 0 informations (`evidence/qa-gates/final-py-pyright.2026-08-20T20-40.md`). |
| **Testing with Pytest** | ✅ PASS | 4062 passed / 0 failed with `--cov --cov-branch` (`evidence/qa-gates/final-py-pytest-coverage.2026-08-20T20-41.md`); reviewer re-ran the three changed modules: 28/28. |

#### 3B.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | `_is_promoted_potential_source(potential_file: Path, workspace_path: Path) -> bool`; no `Any`, no `cast`, no `# type: ignore` in the diff. |
| **Dataclasses / Protocols** | ✅ PASS | Existing `FileSystem` protocol reused (`copy_file` already a member); no new interface surface. |
| **Avoid utility classes** | ✅ PASS | The helper is a module-level function, not a static-method class. |

#### 3B.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `Path.relative_to`'s `ValueError` is caught narrowly and converted to `False` — the one exception type the containment probe can legitimately raise; not a broad catch. |
| **Logging over print** | ✅ PASS (established pattern) | The two new `print` emissions extend the module's existing CLI stdout contract (`Moved potential file to ...` predates this change); the spec mandates the wording parity. No logging channel exists on this CLI path and none was required. |
| **Invariants at construction** | N/A | No new class or constructor. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: TypeScript (Jest)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS | `@jest/globals` imports; run through the repo-sanctioned `run-jest.cjs` wrapper with `jest.config.cjs` (issue-#423 prohibited-flag guard applied; recorded in the fail-before evidence wrapper note). |
| **Test file location** | ✅ PASS | All Jest tests live in the established `extensions/drm-copilot/test/**` mirror of `src/**` (`test/lib/new-active-feature-folder/`, `test/lib/potential-to-issue/`, `test/lib/`). No colocation in `src/`. |
| **Naming** | ✅ PASS | `*.test.ts` suffix; describe blocks name the unit and the rule. |
| **Determinism infrastructure** | ✅ PASS | Fixed `nowProvider`; no fake timers needed (no async timing); no banned APIs (`setTimeout`, `Date.now()`) in changed test code. |

### Section 4B: Python (pytest)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Plain pytest functions with `capsys` fixture for stdout assertions. |
| **Test file location** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`; the `_partN` split convention already in use is followed for the new module. |
| **Coverage expectation** | ✅ PASS | Section 1.2.1 figures; changed-file 92.05% lines / 90.00% branches. |
| **No alternative runners** | ✅ PASS | Only pytest invoked. |

---

## 5. Test Coverage Detail

### `createActiveFolder` disposition rule (TS) — 4 targeted tests + existing suite

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `retains the promoted potential file and writes issue.md in full mode` | Positive | full-branch copy arm + copy emission | ✅ |
| `retains the promoted potential file in minor-audit mode` | Positive | minor-audit copy arm + copy emission | ✅ |
| `takes the move branch for a sibling path that is only a string prefix of the promoted root` | Edge case | move arm via containment boundary | ✅ |
| `moves the potential file to issue.md, marks the work mode, and emits seeding lines` (existing, unmodified) | Positive (INV-2) | move arm, unpromoted source | ✅ |
| `resolves the feature name from a valid promoted active file` (extended) | Positive | auto-resolve path, copy arm retention | ✅ |

**Coverage:** `flow.ts` 99.59% lines / 93.33% branches; changed lines 100%/100%. Not covered: lines 388-389 (pre-existing unreachable fallback-reason emission, unchanged).

### Sequenced lifecycle (TS) — 1 test

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `retains the promoted record across potential_to_issue then new_active_feature_folder` | State transition / regression | `promotePotential` + `createActiveFolder` against one shared filesystem | ✅ |

### `newActiveFeatureFolderServiceCall` post-condition (TS) — 3 tests

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `throws when the reported destination path is absent` | Negative | throw arm, `result.target` | ✅ |
| `throws when the reported artifact path is absent` | Negative | throw arm, `potentialIssuePath` | ✅ |
| `returns the enriched record when every reported path exists` | Positive | success arm | ✅ |

**Coverage:** 100% lines / 100% branches.

### `potentialToIssueServiceCall` post-condition (TS) — 2 tests

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `throws when the promoted destination is absent` | Negative | throw arm, `outcome.destination` | ✅ |
| `returns the enriched record when the destination exists` | Positive | success arm; also proves the issue-URL `artifacts` entry is not stat-ed | ✅ |

**Coverage:** 100% lines; 83.33% branches (3 uncovered branches pre-existing, outside diff).

### `create_active_folder` disposition rule (Python) — 5 tests

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_create_feature_folder_moves_unpromoted_potential` (new, part5) | Positive (INV-2) | move arm + move emission | ✅ |
| `test_create_feature_folder_copies_promoted_potential` (new, part5) | Positive | full-branch copy arm + copy emission | ✅ |
| `test_create_minor_audit_folder_copies_promoted_potential` (new, part5) | Positive | minor-audit copy arm + copy emission | ✅ |
| `test_create_feature_folder_retains_promoted_potential_and_updates_files` (inverted) | Positive | retention assertion replacing the defect-codifying removal assertion | ✅ |
| `test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file` (inverted, part4) | Positive | auto-resolve retention | ✅ |

**Coverage:** 92.05% lines / 90.00% branches; changed lines 100%/100%. Not covered: pre-existing lines 117, 322, 399-416 (CLI `main` region and unreachable fallback emission), unchanged from baseline.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (TS full suite) | 2654 (195 suites) | ✅ |
| Tests Passed (TS) | 2654 (100%) | ✅ |
| Total Tests (Py full suite) | 4062 passed, 5 skipped | ✅ |
| Tests Failed | 0 | ✅ |
| Reviewer targeted re-run (TS) | 37/37 in 0.57 s | ✅ Fast |
| Reviewer targeted re-run (Py) | 28/28 in 0.14 s | ✅ Fast |
| Code Coverage (TS) | 96.66% lines, 90.04% branches | ✅ |
| Code Coverage (Py) | 92.60% lines, 89.81% branches | ✅ |

---

## 7. Code Quality Checks

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | Clean final pass, 0 rewrites | ✅ |
| ESLint | `npx eslint --no-error-on-unmatched-pattern src test` | 0 errors, 0 warnings | ✅ |
| tsc | `npx tsc -p ./ --noEmit` | 0 errors | ✅ |
| Jest + coverage | `npm run test:coverage` | 195/195 suites, 2654/2654 tests | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black .` | Clean, 438 files unchanged | ✅ |
| Ruff | `poetry run ruff check .` | 0 violations | ✅ |
| Pyright | `poetry run pyright` | 0 errors / 0 warnings / 0 informations | ✅ |
| Pytest + coverage | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 4062 passed, 0 failed | ✅ |

**Notes:**
Pre-existing conditions unrelated to and untouched by this work: `scripts/dev_tools/potential_to_issue.py` at 639 lines (separately tracked; not modified) and `tests/scripts/dev_tools/test_new_active_feature_folder.py` at 533 lines (see Section 8).

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **[Minor — non-blocking] No runner-enforced per-file coverage threshold for the four changed production files.** `jest.config.cjs` `coverageThreshold` (line 25 onward) carries no entry for `flow.ts`, `new-active-feature-folder-service-call.ts`, or `potential-to-issue-service-call.ts` (and pytest has no per-file gate for `new_active_feature_folder_flow.py`). The repo's own config comment documents the issue-#305 pattern of per-changed-file threshold entries; this branch relies instead on the hand-asserted `coverage-delta.2026-08-20T20-44.md`. The recorded numbers were independently re-derived by this reviewer from the lcov artifacts and are correct, and the narrowest margin (83.33% branch vs 75%) is comfortable, so the gate outcome is not in question — but a future regression in these files will not fail the runner. Non-blocking because no written rule mandates the enforcement mechanism and the thresholds are demonstrably met; recommend adding the three Jest per-file entries in a follow-up.
2. **[Info] Evidence filename timestamps run ahead of file mtimes.** Example: `final-ts-jest-coverage.2026-08-20T20-24.md` has mtime 2026-08-20 19:28 -0400; the lcov artifacts (mtimes 19:35/19:38) postdate the fix commit `ecfb64d3` (19:19) and match the branch-head file shapes (`flow.ts` LF=492), so the evidence is correctly anchored to the reviewed code state. The internal ordering of the evidence set is self-consistent. No rule specifies the timestamp's clock source; no action required beyond this note.
3. **[Info] Pre-existing over-limit test file, not worsened.** `tests/scripts/dev_tools/test_new_active_feature_folder.py` is 533 lines on `origin/main` and on this branch (net-zero two-line edit). The executor correctly placed all new Python tests in the new 151-line `_part5` module rather than growing the over-limit file. Separately trackable; not caused by this branch.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** No test was removed or skipped. Two existing Python assertions were inverted by design (they codified the defect), each replaced with the retention assertion plus a new move-branch test (`test_create_feature_folder_moves_unpromoted_potential`) so the move arm kept coverage.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **ffa03095** — docs(487): prepare promotion-lifecycle promoted-record loss fix (feature folder, spec, plan, research, baselines)
2. **ecfb64d3** — fix(487): retain the promoted record when seeding an active folder (production + tests)
3. **6f7f864b** — docs(487): correct promoted-record docs and record final QC evidence

### Files Modified

1. **`extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts`** (MODIFIED) — decide-once `retainsPotentialSource`; copy-vs-move at both placement sites; disposition-accurate emission at both emission sites; new private `isPromotedPotentialSource` helper delegating to `isRelativeTo`.
2. **`scripts/dev_tools/new_active_feature_folder_flow.py`** (MODIFIED) — parity mirror: `_is_promoted_potential_source` via `Path.relative_to`, both placement sites, both emission sites, identical emitted wording.
3. **`extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts`** (MODIFIED) — hoisted filesystem instance; `requireReportedPathExists` post-condition on `result.target` and non-null `result.potentialIssuePath`.
4. **`extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts`** (MODIFIED) — hoisted filesystem instance; existence post-condition on `outcome.destination`; issue-URL `artifacts` entry deliberately excluded from the check.
5. Tests, docs, and skill files as listed under Code Under Test.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

Zero Blocking findings. All uniform gates pass with independently verified numeric evidence: format 100%, lint 0, type errors 0, architecture 0 (no config; real-command verification), line coverage >= 85% and branch coverage >= 75% repo-wide and per changed file in both languages, no regression on changed lines (changed-line coverage 100%/100% in all four production files). Three non-blocking findings recorded in Section 8.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: issue, spec, validated plan, baselines all present
- ✅ Design Principles: minimal decide-once predicate; alternatives documented
- ✅ Module & File Structure: all changed production files under 500 lines
- ✅ Naming, Docs, Comments: complete JSDoc/docstrings; why-comments
- ✅ Toolchain Execution: single consecutive clean pass per language, ledgered
- ✅ Summarize & Document: docs corrected, mirror byte-identical

#### Language-Specific Code Change Policy (Section 3)
- ✅ TypeScript: Tooling clean; strong typing; explicit throw-based error handling
- ✅ Python: Tooling clean; typed helper; narrow `ValueError` handling; CLI stdout pattern preserved

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: hermetic, deterministic, AAA, fast
- ✅ Coverage & Scenarios: both arms of every new branch in both languages
- ✅ Test Structure: clear diagnostics demonstrated by fail-before evidence
- ✅ External Dependencies: fakes only; no temporary files

#### Language-Specific Unit Test Policy (Section 4)
- ✅ TypeScript: mirrored `test/**` tree; sanctioned wrapper; determinism seams
- ✅ Python: mirrored `tests/` tree; `_partN` convention; pytest only

### Metrics Summary

- ✅ 2654/2654 TS tests passing; 4062/4062 Py tests passing (0 failed)
- ✅ TS 96.66% lines / 90.04% branches; Py 92.60% lines / 89.81% branches (repo-wide)
- ✅ Changed-file coverage: 99.59%/93.33%, 100%/100%, 100%/83.33% (TS); 92.05%/90.00% (Py)
- ✅ Changed-line coverage 100% line / 100% branch in all four production files
- ✅ Fail-before demonstrated: 7 targeted tests failed pre-fix (5 suites), all pass post-fix
- ✅ All code quality checks passing in a single consecutive pass

### Recommendation

**Ready for merge.** No remediation required. Optional follow-up (non-gating): add per-file `coverageThreshold` entries for the three changed TypeScript production files.

---

## Appendix A: Test Inventory

New and modified tests in this branch:

1. `flow.promoted-disposition.test.ts` › createActiveFolder promoted-record disposition › retains the promoted potential file and writes issue.md in full mode
2. `flow.promoted-disposition.test.ts` › createActiveFolder promoted-record disposition › retains the promoted potential file in minor-audit mode
3. `flow.promoted-disposition.test.ts` › createActiveFolder promoted-record disposition › takes the move branch for a sibling path that is only a string prefix of the promoted root
4. `flow.test.ts` › createActiveFolder validation › resolves the feature name from a valid promoted active file (extended with retention assertion)
5. `promotion-lifecycle-sequence.test.ts` › promotion lifecycle sequence › retains the promoted record across potential_to_issue then new_active_feature_folder
6. `new-active-feature-folder-service-call.test.ts` › receipt post-condition › throws when the reported destination path is absent
7. `new-active-feature-folder-service-call.test.ts` › receipt post-condition › throws when the reported artifact path is absent
8. `new-active-feature-folder-service-call.test.ts` › receipt post-condition › returns the enriched record when every reported path exists
9. `potential-to-issue-service-call.test.ts` › receipt post-condition › throws when the promoted destination is absent
10. `potential-to-issue-service-call.test.ts` › receipt post-condition › returns the enriched record when the destination exists
11. `test_new_active_feature_folder.py::test_create_feature_folder_retains_promoted_potential_and_updates_files` (renamed + inverted)
12. `test_new_active_feature_folder_part4.py::test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file` (inverted)
13. `test_new_active_feature_folder_part5.py::test_create_feature_folder_moves_unpromoted_potential`
14. `test_new_active_feature_folder_part5.py::test_create_feature_folder_copies_promoted_potential`
15. `test_new_active_feature_folder_part5.py::test_create_minor_audit_folder_copies_promoted_potential`

---

## Appendix B: Toolchain Commands Reference

**For TypeScript (from `extensions/drm-copilot/`):**
```bash
# Formatting
npx prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"

# Linting
npx eslint --no-error-on-unmatched-pattern src test

# Type checking
npx tsc -p ./ --noEmit

# Testing (sanctioned wrapper; do not use bare npx jest)
npm run test:coverage
```

**For Python (from repo root):**
```bash
# Formatting
poetry run black .

# Linting
poetry run ruff check .

# Type checking
poetry run pyright

# Testing
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**Reviewer verification commands:**
```bash
# Merge base / diff scope
git diff origin/main...HEAD --stat

# PR context regeneration
python -m scripts.dev_tools.pr_context.collector --base origin/main --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt

# Targeted re-runs
npx jest test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts test/lib/promotion-lifecycle-sequence.test.ts test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts test/lib/potential-to-issue/potential-to-issue-service-call.test.ts test/lib/new-active-feature-folder/flow.test.ts
poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py tests/scripts/dev_tools/test_new_active_feature_folder_part4.py tests/scripts/dev_tools/test_new_active_feature_folder_part5.py -q

# Independent lcov parsing (per-file LF/LH/BRF/BRH and DA:<n>,0 records)
# parsed extensions/drm-copilot/coverage/lcov.info and artifacts/python/lcov.info

# Evidence locations
python scripts/dev_tools/validate_evidence_locations.py --root .   # exit 0

# Plan gates
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-17-promotion-lifecycle-loses-promoted-record-487/plan.2026-08-17T15-01.md   # exit 0, two G4 warnings

# Skill mirror byte identity
cmp .claude/skills/feature-promotion-lifecycle/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md   # exit 0
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-08-20
**Policy Version:** Current (as of audit date)

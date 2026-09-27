# Policy Compliance Audit: PR-context gh detection false negative (Issue #588)

---

**Audit Date:** 2026-09-26
**Branch:** `bug/pr-context-gh-detection-false-negative-588` @ `51f852dc807308d645486960fea2e73edaae8ca3`
**Base:** `origin/main` @ `b67453837646fd2dd4f5ac692f76e6f7703fe798` (merge base equals base head; merge commit of PR #703 for sibling #622)
**Diff command:** `git diff origin/main...HEAD` (61 files, +2686 / -7)
**Template source:** bundled policy-audit asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (the MCP template tool is not in this reviewer's tool list; the bundled resource file is the same asset the MCP tool serves).

**Code Under Test:**
- TypeScript production (new): `extensions/drm-copilot/src/lib/executable-resolver.ts`
- TypeScript production (modified): `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`, `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`
- TypeScript/JS config (modified): `extensions/drm-copilot/jest.config.cjs`
- TypeScript tests (new): `extensions/drm-copilot/test/lib/executable-resolver.test.ts`, `extensions/drm-copilot/test/extension.collect-pr-context-gh-resolution.test.ts`
- TypeScript tests (modified): `test/extension.integration.test.ts`, `test/lib/pr-context/collector-core.test.ts`, `test/lib/pr-context/pr-context-service-call.test.ts`, `test/lib/pr-context/pr-context-service-call-target.test.ts`, `test/lib/pr-context/render-pr-helpers.test.ts`, `test/repo-automation-dispatch-pr-context-verification.test.ts` (all under `extensions/drm-copilot/`)
- Python production (modified): `scripts/dev_tools/pr_context/render_pr_helpers.py`
- Python tests (new): `tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py`
- Python tests (modified): `tests/scripts/dev_tools/test_pr_context_integration.py`
- Markdown: feature folder documents and 42 evidence files under `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 12 files (3 prod, 1 config, 8 test) | 3130 tests (full suite, executor); 97 tests in 9 changed-scope suites (reviewer rerun) | PASS 3130 pass, 0 fail | 96.88% lines, 90.76% branches | 96.90% lines, 90.79% branches | 100.00% lines, 100.00% branches (new `executable-resolver.ts`); every added executable line hit |
| Python | 3 files (1 prod, 2 test) | 5131 tests (full suite, executor); 10 tests in changed files (reviewer rerun) | PASS 5131 pass, 0 fail, 5 skipped, 1 deselected (#510) | 93.03% lines (package `scripts.dev_tools.pr_context`) | 93.04% lines, 83.49% branches (package `scripts.dev_tools.pr_context`) | 96.21% lines, 95.45% branches (`render_pr_helpers.py`); every added executable line hit |
| PowerShell | 0 files | N/A | N/A | N/A (zero PowerShell files changed) | N/A (zero PowerShell files changed) | N/A |
| C# | 0 files | N/A | N/A | N/A (zero C# files changed) | N/A (zero C# files changed) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/evidence/baseline/ts-jest-coverage.2026-09-25T22-06.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (parsed by the reviewer) and `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/evidence/qa-gates/ts-jest-coverage.2026-09-25T22-06.md`
- Python baseline coverage artifact: `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/evidence/baseline/py-pytest-coverage.2026-09-25T22-06.md` and `artifacts/python/coverage-588-baseline.json`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (parsed by the reviewer) and `artifacts/python/coverage-588-final.json`
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Per-language comparison summary: Section 1.2.1 of this document

---

## Executive Summary

The branch fixes the confirmed root cause of issue #588: the TypeScript PR-context collector reached through `collect_pr_context` never resolved `gh`, because `GhClient` defaults its resolver to `() => undefined` and the service call supplied none. The branch adds a pure PATH/PATHEXT resolver (`resolveExecutableOnPath`) with a process-bound `defaultWhichGh`, wires `input.whichGh ?? defaultWhichGh` into `collectPrContextServiceCall`, and adds the empty-list `None (GitHub CLI unavailable; closing issues not verified)` body in both the TypeScript builder (`autoclose.ts`) and the Python builder (`render_pr_helpers.py`). The #622-owned code paths (non-empty rendering, annotation line, not-open fallback, collectors' call sites) have no removed lines in the diff.

**Policy documents evaluated:**
- PASS `CLAUDE.md` and `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md` (uniform coverage gates evaluated; tier-dependent gates not evaluable, see Section 8)

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` + `.claude/rules/python-suppressions.md`
- PASS `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md`
- N/A PowerShell, C#, Bash, JSON, GitHub Actions (zero changed files in those categories)

Toolchain results (reviewer reruns, check-only): `tsc --noEmit` exit 0; `eslint src test` exit 0; Prettier `--check` on all 12 changed TS/CJS files clean; Jest on 9 changed-scope suites 97/97 passed; Black `--check` clean; Ruff clean; Pyright 0 errors; Pytest on both changed Python test files 10/10 passed. Coverage was verified from the executor's existing artifacts and meets 85% line / 75% branch for every new and modified production file. No blocking finding was identified.

**Temporary artifacts cleanup:**
- PASS No temporary scripts are committed on the branch; `git diff --name-only origin/main...HEAD` lists no script outside the planned production and test files.
- PASS No new tooling scripts were added.
- The reviewer's lcov parsing helper was written to the session scratchpad only (outside the repository).

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller instruction "The operator approved all spec design decisions D1-D13 (operator-supplied, 2026-09-26); do not raise approval of those decisions as a finding." was evaluated; it does not narrow files, languages, toolchain checks, or coverage checks, so it was accepted. The audit scope is the full `origin/main...HEAD` diff.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no reported paths.
- Command: `git diff --name-only origin/main...HEAD -- artifacts` returned no paths. No branch file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 42 evidence files are under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Tests that mutate `process.platform`, `process.env.PATH`, and `process.env.PATHEXT` (`executable-resolver.test.ts`, `extension.collect-pr-context-gh-resolution.test.ts`) capture the original values and restore them in `afterEach`; mocks are reset with `jest.resetAllMocks()` / `jest.clearAllMocks()`. Python tests call a pure builder with no shared state. |
| **Isolation** - Each test targets single behavior | PASS | Resolver tests each target one resolution rule (R1-R11); builder tests target one body text each (H1-H4, K1-K2); the Python unit file mirrors the four TS builder cases. |
| **Fast Execution** - Tests complete quickly | PASS | Reviewer rerun: 9 Jest suites / 97 tests in 1.73 s; 10 Python tests in 0.09 s. |
| **Determinism** - Consistent results | PASS | `node:fs` and `node:child_process` are module-mocked in composition-root and resolver tests; `whichGh` is injected in service-call tests; `defaultWhichGh` is pinned to `undefined` by module mock in the two tests whose composition root has no injection seam. No wall-clock, RNG, or real process use. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `it(...)` titles, Arrange/Act/Assert comments, a file-level doc comment explaining the hermeticity strategy in each new TS test file. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **TS baseline:** 96.88% lines (48372/49925), 90.76% branches (6941/7647), `node run-jest.cjs --coverage ...`, `evidence/baseline/ts-jest-coverage.2026-09-25T22-06.md`. **Python baseline:** TOTAL `1608 112 640 80 90%` for `--cov=scripts.dev_tools.pr_context`, `evidence/baseline/py-pytest-coverage.2026-09-25T22-06.md`. |
| **No Coverage Regression** | PASS | **TS post-change:** 96.90% lines (48510/50063), 90.79% branches (6970/7677), change +0.02% lines, +0.03% branches. **Python post-change:** 93.04% lines (1498/1610), 83.49% branches (536/642); `render_pr_helpers.py` 96.15% -> 96.21% lines, 95.31% -> 95.45% branches. Every added executable line has a hit count > 0 (`DA:277,68`, `DA:278..280,35`, `DA:152,33`, reviewer-verified in `extensions/drm-copilot/coverage/lcov.info`). One unchanged file, `collector-core.ts`, dropped 91.22% -> 89.28% branches with no diff to it; see Section 8 (non-blocking). |
| **New Code Coverage** | PASS | `executable-resolver.ts`: 121/121 lines = 100.00%, 25/25 branches = 100.00% (meets the 85%/75% uniform rule and the 90% new-file rule in the review workflow). |
| **Comprehensive Coverage** | PASS | `resolveExecutableOnPath` (11 tests), `defaultWhichGh` (2 tests), `collectPrContextServiceCall` whichGh wiring (1 new test plus 16 existing tests now injecting), composition root (2 tests), `buildIssuesToAutocloseSection` (4 new TS tests, 4 new Python tests incl. parametrized cases), collector-core availability (2 tests), Python offline integration scenario (1 new assertion block). |
| **Positive Flows** - Valid inputs | PASS | R1, R4, R6, D1, S1, C1, H4, K2, Python `keeps_available_fallback_texts[...]`. |
| **Negative Flows** - Invalid inputs | PASS | R7 (no candidate), R8 (undefined PATH), R9 (empty PATH), D2 (`existsSync` false), C2 (gh not on PATH), K1 (gh unresolved). The resolver has no invalid-type input path beyond the typed interface. |
| **Edge Cases** - Boundary conditions | PASS | R2/R3 (mixed-case PATHEXT, name already carrying an extension), R5 (PATHEXT ignored on linux), R10 (empty PATH entries), R11 (unset PATHEXT fallback order), H2 (unavailable text precedes the PASS fallback), H3 (non-empty list with gh unavailable). |
| **Error Handling** - Error paths | PASS | Resolved-but-unauthenticated `gh` path covered by the existing service-call tests (comment corrected) and the composition-root test runner (`auth status` exit 1). No new error types were introduced (spec D3). |
| **Concurrency** - If applicable | N/A | The resolver and builders are synchronous and stateless. |
| **State Transitions** - If applicable | N/A | No stateful component was added. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.88% lines, 90.76% branches -> Post-change: 96.90% lines, 90.79% branches. Change: +0.02% lines, +0.03% branches. New/changed-code coverage: 100.00% lines and 100.00% branches for `executable-resolver.ts`; `pr-context-service-call.ts` 100.00% lines / 93.75% branches; `autoclose.ts` 98.68% lines / 95.74% branches. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/baseline/ts-jest-coverage.2026-09-25T22-06.md`, `evidence/qa-gates/ts-jest-coverage.2026-09-25T22-06.md`, `evidence/qa-gates/ts-coverage-delta.2026-09-25T22-06.md`.
- Python: Baseline: 93.03% lines (package `scripts.dev_tools.pr_context`) -> Post-change: 93.04% lines, 83.49% branches (same package). Change: +0.01% lines. New/changed-code coverage: 96.21% lines and 95.45% branches for `render_pr_helpers.py`. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `artifacts/python/coverage-588-final.json`, `evidence/baseline/py-pytest-coverage.2026-09-25T22-06.md`, `evidence/qa-gates/py-coverage-delta.2026-09-25T22-06.md`.

Repo-wide per-language result: TypeScript 96.90% lines / 90.79% branches (all `src/**/*.ts`, PASS). Python: the available artifact is scoped to `scripts.dev_tools.pr_context` as the spec prescribes (93.04% / 83.49%, PASS for that scope); the full Python suite ran under that measurement scope.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions compare exact strings (`toBe`, `==`) or exact argv (`toHaveBeenCalledWith("/opt/gh-bin/gh", ["auth","status"], ...)`), so failures print the expected and received values. |
| **Arrange-Act-Assert Pattern** | PASS | Arrange/Act/Assert comments in the new TS and Python tests. |
| **Document Intent** | PASS | File-level doc comments in both new TS test files and a module docstring plus per-test docstrings in the new Python file. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No test spawns `gh` or `git`, reads the real filesystem, uses the network, or references a real remote ref. `origin/main` appears only as an opaque string in fake runners and stubs. |
| **Use Mocks/Stubs** | PASS | `node:fs` and `node:child_process` module mocks; injected `exists` fakes; injected `whichGh`; in-memory `TreeFileSystem`; `AuthenticatedGhRunner` / `ScriptRunner` fakes; module mock of `defaultWhichGh` in `extension.integration.test.ts` and `repo-automation-dispatch-pr-context-verification.test.ts`. |
| **Environment Stability** | PASS | No temporary files (`grep -n -E "tmpdir|mkdtemp|tmp_path|tempfile"` over new tests: no matches). Windows semantics exercised through the `platform` parameter with drive-letter-free strings. All other suites that reach `collectPrContextServiceCall` set `PATH` explicitly and mock `node:fs` (reviewer search: every test file calling `collectPrContext(` mocks `node:fs`, mocks the resolver, or injects `whichGh`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the policy review for the branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md`, `spec.md` (Root Cause Analysis, D1-D13), research `research/2026-09-26T02-10-pr-context-gh-detection-research.md`. |
| **Read existing change plans** | PASS | `plan.2026-09-25T22-06.md` (85 tasks, all checked); merge-order state recorded in `evidence/baseline/merge-order-state.2026-09-25T22-06.md` (ORDER: 622-MERGED). |
| **Document the plan** | PASS | Plan file plus preflight revision commits `863aa332`, `35382e31`, `36fa6113`, `f42a3a2b`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The resolver is 121 lines including documentation; two small private helpers and two exports. The builder change is a single inserted `else if` branch in each runtime. |
| **Reusability** | PASS | The resolver is generic over `name`; `defaultWhichGh` is a thin binding. Consolidation of three existing PATH lookups is deferred by D4. |
| **Extensibility** | PASS | New parameters are optional with behavior-preserving defaults (`whichGh?`, existing `ghAvailable = true`). |
| **Separation of concerns** | PASS | Pure resolution logic is parameterized on PATH, PATHEXT, platform, and an existence predicate; the only I/O binding (`process.env`, `fs.existsSync`) is isolated in `defaultWhichGh`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | `executable-resolver.ts` has a single purpose; the service-call change is a one-line forward plus an interface field. |
| **Under 500 lines** | PASS | Reviewer `wc -l`: largest touched files are `extension.integration.test.ts` 491, `collector-core.test.ts` 476, `test_pr_context_integration.py` 347, `pr-context-service-call.test.ts` 356, `jest.config.cjs` 325, `render_pr_helpers.py` 322, `autoclose.ts` 304. All 15 touched code/test files are at or below 491. |
| **Public vs internal** | PASS | `splitNonEmpty` and `candidateNames` are module-private; `resolveExecutableOnPath`, `ResolveExecutableOptions`, and `defaultWhichGh` are exported. |
| **No circular dependencies** | PASS | `executable-resolver.ts` imports only `node:fs` and `node:path`; `pr-context-service-call.ts` imports it and a type from `gh-client-core.ts`. dependency-cruiser is not configured in the repository (pre-existing). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `resolveExecutableOnPath`, `defaultWhichGh`, `candidateNames`, `DEFAULT_PATHEXT`, `AuthenticatedGhRunner`. |
| **Docs/docstrings** | PASS | Module doc comment in `executable-resolver.ts` documents purpose, Windows semantics, and the D5 limitation (CVE-2024-27980, `shell: false`, `.cmd`/`.bat`). JSDoc on all exports; Python docstring updated for `gh_available`. |
| **Comment why, not what** | PASS | The inserted branch comments state why the unavailable text takes precedence. One pre-existing precedence comment in each builder is now partially inaccurate (code-review finding CR-2, Nit). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `npm --prefix extensions/drm-copilot exec -- prettier --check <12 changed files>`; `poetry run black --check <3 changed py files>`<br>**Result:** all files already formatted. |
| **2. Linting** | PASS | **Command:** `npm --prefix extensions/drm-copilot run lint`; `poetry run ruff check <3 files>`<br>**Result:** exit 0; `All checks passed!`. |
| **3. Type checking** | PASS | **Command:** `npm --prefix extensions/drm-copilot run typecheck`; `poetry run pyright <3 files>`<br>**Result:** exit 0; `0 errors, 0 warnings, 0 informations`. |
| **4. Testing** | PASS | **Command:** `npm --prefix extensions/drm-copilot test -- executable-resolver collect-pr-context-gh-resolution pr-context-service-call render-pr-helpers collector-core repo-automation-dispatch-pr-context-verification extension.integration`; `poetry run pytest tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py tests/scripts/dev_tools/test_pr_context_integration.py`<br>**Result:** 97/97 and 10/10 passed. Executor full-suite runs: 3130/3130 Jest, 5131 passed Pytest. |
| **Full toolchain loop** | PASS | Executor: TS loop iteration 2 and Python loop iteration 2 completed without file changes (`evidence/qa-gates/*`). Reviewer reruns are consistent. Architecture-boundary stage: no tool configured (pre-existing). Contract and integration stages: covered by the Jest composition-root and Python offline integration tests. |
| **Explicit reporting** | PASS | Commands and exit codes recorded in `evidence/qa-gates/` and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Conventional commit messages per change (`fix(pr-context): ...`, `test(pr-context): ...`, `docs(bug): ...`). |
| **Design choices explained** | PASS | Spec D1-D13 with options and rationale (operator-approved 2026-09-26). |
| **Update supporting documents** | PASS | Spec, plan, research, and evidence are in the feature folder; no consumer prose change is required (spec out-of-scope list). |
| **Provide next steps** | PASS | Spec Rollout: publish the MCP package and VSIX, then run the live `closingIssuesReferences` check; file the D4 consolidation follow-up. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | **Command:** `poetry run black --check <changed py files>`<br>**Result:** `3 files would be left unchanged.` |
| **Linting with Ruff** | PASS | **Command:** `poetry run ruff check <changed py files>`<br>**Result:** `All checks passed!` No suppression added. |
| **Type checking with Pyright** | PASS | **Command:** `poetry run pyright <changed py files>`<br>**Result:** `0 errors, 0 warnings, 0 informations`. |
| **Testing with Pytest** | PASS | **Command:** `poetry run pytest <changed test files>`<br>**Result:** `10 passed`. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | The production change adds no new signature; the existing `gh_available: bool = True` keyword is reused. Test functions are annotated (`-> None`, `readiness: list[str]`). No `Any`. |
| **Dataclasses for value objects** | N/A | No value object added. |
| **Protocols/ABCs for interfaces** | N/A | No interface added. |
| **Avoid utility classes** | PASS | No class added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No exception handling added. |
| **Logging over print** | PASS | No `print` added. |
| **Invariants at construction** | N/A | No constructor added. |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | Reviewer `prettier --check`: `All matched files use Prettier code style!` |
| **Linting with ESLint** | PASS | `npm run lint` exit 0. |
| **Type checking with tsc** | PASS | `npm run typecheck` exit 0. The executor's first loop found TS4111 on `process.env.PATH`; fixed with index access in `2cab0e89`. |
| **No untyped escape hatches or suppressions** | PASS | Reviewer grep of added lines for `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `as any`, `: any`, `noqa`, `type: ignore`: no matches. Test-only `context as never` mirrors the existing sibling test. |
| **Coverage exclusions** | PASS | `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`; no production path excluded; one per-file threshold entry added for `./src/lib/executable-resolver.ts` (85/75). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Plain pytest functions with `pytest.mark.parametrize`. |
| **Coverage expectation** | PASS | `render_pr_helpers.py` 96.21% lines / 95.45% branches; package 93.04% / 83.49%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | Each test exercises one body outcome of `build_issues_to_autoclose_section`. |
| **Mocking sparingly** | PASS | The unit file uses no mocks (pure function). The integration file uses pre-existing stubs. |
| **Organization** | PASS | `tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py` mirrors `scripts/dev_tools/pr_context/render_pr_helpers.py`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_build_issues_to_autoclose_section_reports_gh_unavailable_when_empty` and siblings. A single-case parametrize was used to satisfy E501 (code-review CR-6, Nit). |
| **Docstrings/comments** | PASS | Each test has a one-line docstring. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | **Command:** `poetry run pytest ...`<br>**Result:** 10 passed (reviewer); 5131 passed (executor full suite). |
| **No Alternative Test Runners** | PASS | Only Pytest. |

### Section 4E: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest via repo runner** | PASS | `node run-jest.cjs` through `npm test`; no prohibited flag. |
| **Test file location** | PASS | `test/lib/executable-resolver.test.ts` mirrors `src/lib/executable-resolver.ts`; composition-root test sits beside `extension.collect-pr-context.test.ts` per D12. No colocated tests. |
| **Banned APIs** | PASS | No `setTimeout`, `Date.now()`, or real waits in added test code. |
| **Hermetic on Linux CI** | PASS | Platform pinned to `linux` in the composition-root and `defaultWhichGh` tests; Windows cases use the `platform: "win32"` parameter with `path.win32`, independent of host. |

---

## 5. Test Coverage Detail

### `resolveExecutableOnPath` / `defaultWhichGh` (13 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| R1 returns the gh.exe candidate for a win32 PATH and PATHEXT | Positive | 56-76, 85-103 | PASS |
| R2 matches a lower-case PATHEXT entry against an existing gh.exe | Edge Case | 56-76 | PASS |
| R3 tries a name that already ends in a PATHEXT extension as-is | Edge Case | 70-76 | PASS |
| R4-R6 posix first-directory match, PATHEXT ignored, first match wins | Positive / Edge Case | 61-62, 92-103 | PASS |
| R7-R10 no candidate, undefined PATH, empty PATH, empty entries | Negative / Edge Case | 44-46, 89-90, 94-102 | PASS |
| R11 falls back to the default PATHEXT list when PATHEXT is unset | Edge Case | 64-69 | PASS |
| D1-D2 defaultWhichGh resolves through process env and fs.existsSync | Positive / Negative | 113-121 | PASS |

**Coverage:** 100.00% lines (121/121), 100.00% branches (25/25).

**Not covered:** None.

### `collectPrContextServiceCall` whichGh wiring (1 new test, 16 updated tests; 2 composition-root tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| S1 invokes the resolved gh with auth status and reports the authenticated repository | Positive (fail-first) | 152 | PASS |
| C1 collectPrContext spawns the PATH-resolved gh with auth status | Positive (fail-first, default resolver arm) | 152 and resolver 113-121 | PASS |
| C2 collectPrContext does not spawn gh when no PATH directory contains it | Negative | 152 | PASS |

**Coverage:** `pr-context-service-call.ts` 100.00% lines (185/185), 93.75% branches (15/16; uncovered branch at line 59 pre-existing).

### `buildIssuesToAutocloseSection` / `build_issues_to_autoclose_section` (4 TS + 5 Python cases; 2 collector-core tests; 1 Python integration block)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| H1 / `reports_gh_unavailable_when_empty` | Positive | TS 277-280; Py 288-291 | PASS |
| H2 / `prefers_unavailable_text_over_pass_readiness` | Edge Case | TS 277-280; Py 288-291 | PASS |
| H3 / `lists_pending_refs_when_gh_unavailable` | Edge Case (D11) | non-empty branch | PASS |
| H4 / `keeps_available_fallback_texts` | Positive (regression guard) | fallback branches | PASS |
| K1 / K2 collector-core availability | Positive / Negative (fail-first K1) | call site through builder | PASS |

**Coverage:** `autoclose.ts` 98.68% lines / 95.74% branches; `render_pr_helpers.py` 96.21% / 95.45%.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (executor full suites) | Jest 3130; Pytest 5131 passed, 5 skipped, 1 deselected | PASS |
| Tests Passed (reviewer reruns) | Jest 97/97 (100%); Pytest 10/10 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time (reviewer reruns) | Jest 1.73 s; Pytest 0.09 s | PASS Fast |
| Functions Tested | 4/4 new or modified functions (`resolveExecutableOnPath`, `defaultWhichGh`, `collectPrContextServiceCall`, both builders) | PASS |
| Test File Size | largest touched test file 491 lines | PASS |
| Code Coverage | TS 96.90% lines / 90.79% branches; Python package 93.04% / 83.49% | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <3 files>` | 3 files unchanged | PASS |
| Ruff Linting | `poetry run ruff check <3 files>` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright <3 files>` | 0 errors | PASS |
| Pytest Tests | `poetry run pytest <2 test files>` | 10 passed | PASS |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npm --prefix extensions/drm-copilot exec -- prettier --check <12 files>` | all files formatted | PASS |
| ESLint | `npm --prefix extensions/drm-copilot run lint` | exit 0 | PASS |
| tsc | `npm --prefix extensions/drm-copilot run typecheck` | exit 0 | PASS |
| Jest | `npm --prefix extensions/drm-copilot test -- <7 patterns>` | 9 suites, 97 tests passed | PASS |

**Notes:**
- The executor deselected `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` in both baseline and final Python runs because of open issue #510 (gitignored local state); the deselection is identical in both runs and unrelated to this change.
- dependency-cruiser is not configured in the repository (pre-existing condition).
- CI on Linux has not run against head `51f852dc` at review time (no PR exists yet); Linux hermeticity is established by inspection and platform pinning.

---

## 8. Gaps and Exceptions

### Identified Gaps

Non-blocking:
- `collector-core.ts` branch coverage fell from 91.22% to 89.28% with no diff to that file. The uncovered arm is `BRDA:135,2,0,0`, the `whichGh === undefined` side of `...(whichGh === undefined ? {} : { whichGh })`; before this branch it was exercised only by service-call tests that omitted `whichGh`, which now inject it. The file remains above 75% branches and its per-file Jest threshold passes; the policy's no-regression rule applies to changed lines, and no line of this file changed. Judged non-blocking; a one-test follow-up is recommended (code-review CR-1).
- Evidence `Timestamp:` fields do not match the host clock: for example `evidence/qa-gates/ac-checkoff-count.2026-09-25T22-06.md` records `2026-09-26T22-40`, while the check-off commit `51f852dc` is dated `2026-09-26 21:30:43 -0400` and this review began at `2026-09-26T21-37` local time. Evidence content was independently reproduced by the reviewer, so the gap affects provenance only (code-review CR-4).
- `quality-tiers.yml` does not exist at the repository root, so tier-dependent gates (property-test density, mutation score) cannot be evaluated for `executable-resolver.ts`. No property-testing library (`fast-check`, `hypothesis`) is a declared dependency. Pre-existing repository condition; not attributed to this branch.

### Approved Exceptions

- Spec D1-D13 were operator-approved on 2026-09-26 (caller-supplied). D4 (resolver consolidation deferred) and D5 (`.cmd`/`.bat` shim limitation documented, not handled) are the relevant scoped exceptions.

### Removed/Skipped Tests

- **None.** All planned tests are present. The #510 deselection is pre-existing and applies equally to baseline and final runs.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **f0239fb5** - docs(bug): create active folder for pr-context gh detection false negative (#588)
2. **968a8629** - docs(research): record root cause for pr-context gh detection false negative (#588)
3. **745e05c2** - docs(spec): define fix and acceptance criteria for gh detection false negative (#588)
4. **fe0d6a61**, **863aa332**, **35382e31**, **117b59a9**, **1b386dd4**, **36fa6113**, **0ef0e6d1**, **f42a3a2b** - plan and spec revisions (merge-order agnosticism, D8-D13, preflight rounds)
5. **a306debb**, **ace16a25** - phase 0 synchronization, state, baselines, batch budget
6. **06b01d2e** - test(pr-context): add #588 fail-first gh resolution regression tests
7. **58b93e12** - fix(pr-context): resolve gh from PATH in the collect-pr-context service call
8. **a27d1513** - fix(pr-context): render the gh-unavailable autoclose body in python
9. **f92d43bf** - test(pr-context): cover the gh resolver and unavailable autoclose body
10. **f6517820** - docs(bug): record #588 pass-after verification
11. **2cab0e89** - fix(pr-context): read PATH and PATHEXT with index access in the resolver
12. **1a885cb1** - test(pr-context): satisfy black and ruff for the #588 python tests
13. **bd5712df** - docs(bug): record #588 scope, size, and hermeticity verification
14. **51f852dc** - docs(bug): check off the #588 acceptance criteria

### Files Modified

1. **extensions/drm-copilot/src/lib/executable-resolver.ts** (NEW) - pure PATH/PATHEXT resolver and process-bound `defaultWhichGh`; D5 limitation documented.
2. **extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts** (MODIFIED) - optional `whichGh` input; forwards `input.whichGh ?? defaultWhichGh`.
3. **extensions/drm-copilot/src/lib/pr-context/autoclose.ts** (MODIFIED) - inserted empty-list unavailable branch ahead of the #622 fallbacks; doc comment line.
4. **scripts/dev_tools/pr_context/render_pr_helpers.py** (MODIFIED) - Python twin of item 3; docstring update.
5. **extensions/drm-copilot/jest.config.cjs** (MODIFIED) - per-file threshold for `executable-resolver.ts`.
6. Eight TS test files and two Python test files (NEW/MODIFIED) - see Section 5 and Appendix A.
7. Feature folder documents and evidence (NEW).

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT (with non-blocking observations)

All general, TypeScript, and Python policy checks pass on reviewer reruns and executor evidence. Coverage meets the uniform thresholds for every new and modified production file in both changed languages. No blocking finding exists. The non-blocking items are listed in Section 8 and in the code review.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: spec, research, plan, and merge-order state recorded.
- PASS Design Principles: pure resolver with isolated I/O binding.
- PASS Module & File Structure: all touched files <= 491 lines.
- PASS Naming, Docs, Comments: one stale pre-existing precedence comment per builder (Nit).
- PASS Toolchain Execution: reviewer reruns clean.
- PASS Summarize & Document: commits and evidence complete.

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline
- PASS Python Design & Typing
- PASS Error Handling (no change)

**For TypeScript:**
- PASS Tooling, suppressions, and coverage configuration

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios (collector-core branch drop recorded as non-blocking)
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
- PASS Framework, location, banned APIs, hermeticity

---

### Metrics Summary

- PASS 97/97 Jest tests and 10/10 Pytest tests on reviewer reruns; 3130 Jest and 5131 Pytest on executor full runs.
- PASS 4/4 new or modified functions tested.
- PASS TypeScript 96.90% lines / 90.79% branches repo-wide; new file 100.00% / 100.00%.
- PASS Python `render_pr_helpers.py` 96.21% lines / 95.45% branches.
- PASS Test files mirror production layout.
- PASS Code quality checks clean.

---

### Recommendation

**Ready for merge** after normal CI on the PR head. Recommended follow-ups (non-blocking): add one collector-core test that omits `whichGh`; correct the two stale precedence comments; publish the MCP package and VSIX and run the live `closingIssuesReferences` check.

---

## Appendix A: Test Inventory

### Complete Test List

1. resolveExecutableOnPath › returns the gh.exe candidate for a win32 PATH and PATHEXT
2. resolveExecutableOnPath › matches a lower-case PATHEXT entry against an existing gh.exe
3. resolveExecutableOnPath › tries a name that already ends in a PATHEXT extension as-is
4. resolveExecutableOnPath › returns the posix candidate from the first PATH directory that contains the name
5. resolveExecutableOnPath › ignores PATHEXT on non-win32 platforms
6. resolveExecutableOnPath › returns the earlier directory's match when several directories contain the name
7. resolveExecutableOnPath › returns undefined when no candidate exists
8. resolveExecutableOnPath › returns undefined for an undefined PATH
9. resolveExecutableOnPath › returns undefined for an empty PATH
10. resolveExecutableOnPath › skips empty PATH entries
11. resolveExecutableOnPath › falls back to the default PATHEXT list when PATHEXT is unset
12. defaultWhichGh › resolves gh from process PATH, PATHEXT, and platform through fs.existsSync
13. defaultWhichGh › returns undefined when fs.existsSync reports no candidate
14. drm-copilot collectPrContext gh resolution › collectPrContext spawns the PATH-resolved gh with auth status
15. drm-copilot collectPrContext gh resolution › collectPrContext does not spawn gh when no PATH directory contains it
16. collectPrContextServiceCall › invokes the resolved gh with auth status and reports the authenticated repository
17. collectPrContext autoclose body availability › renders the unavailable autoclose body when gh is not resolved
18. collectPrContext autoclose body availability › keeps the readiness-not-PASS autoclose body when gh is available and nothing is listed
19. buildIssuesToAutocloseSection › reports GitHub CLI unavailable when gh is unavailable and nothing is listed
20. buildIssuesToAutocloseSection › prefers the unavailable text over the PASS fallback when gh is unavailable
21. buildIssuesToAutocloseSection › lists pending refs and omits the empty-list unavailable body when gh is unavailable
22. buildIssuesToAutocloseSection › keeps both available fallback texts when ghAvailable is true

**Python:**

- tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py::test_build_issues_to_autoclose_section_reports_gh_unavailable_when_empty
- tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py::test_build_issues_to_autoclose_section_prefers_unavailable_text_over_pass_readiness[readiness0]
- tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py::test_build_issues_to_autoclose_section_lists_pending_refs_when_gh_unavailable
- tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py::test_build_issues_to_autoclose_section_keeps_available_fallback_texts[readiness0-...]
- tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py::test_build_issues_to_autoclose_section_keeps_available_fallback_texts[readiness1-...]
- tests/scripts/dev_tools/test_pr_context_integration.py::test_collect_and_write_end_to_end_scenarios (three parametrized cases; OfflineGh and OnlineGh empty-list assertions added)

Existing tests modified only to inject `whichGh` or pin `defaultWhichGh`: 7 in `pr-context-service-call-target.test.ts`, 8 in `pr-context-service-call.test.ts`, module-level mocks in `extension.integration.test.ts` and `repo-automation-dispatch-pr-context-verification.test.ts`.

---

## Appendix B: Toolchain Commands Reference

All reviewer commands were run check-only against worktree `agent-a1ffc16acdc3f2d54` at head `51f852dc`.

**For TypeScript (reviewer):**
```bash
npm --prefix extensions/drm-copilot run typecheck                # exit 0
npm --prefix extensions/drm-copilot run lint                     # exit 0
npm --prefix extensions/drm-copilot exec -- prettier --check <12 changed TS/CJS files>   # clean
npm --prefix extensions/drm-copilot test -- executable-resolver collect-pr-context-gh-resolution \
  pr-context-service-call render-pr-helpers collector-core \
  repo-automation-dispatch-pr-context-verification extension.integration              # 9 suites, 97 tests passed
node <scratchpad>/lcov.js extensions/drm-copilot/coverage/lcov.info <files>             # coverage parse
```

**For Python (reviewer):**
```bash
poetry run black --check scripts/dev_tools/pr_context/render_pr_helpers.py tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py tests/scripts/dev_tools/test_pr_context_integration.py
poetry run ruff check <same three files>
poetry run pyright <same three files>
poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py tests/scripts/dev_tools/test_pr_context_integration.py
node <scratchpad>/lcov.js artifacts/python/lcov.info render_pr_helpers.py collector.py autoclose.py
```

**Scope and structure (reviewer):**
```bash
git diff --stat origin/main...HEAD
git diff --stat origin/main...HEAD -- extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts scripts/dev_tools/pr_context/github.py extensions/drm-copilot/src/lib/pr-context/collector-core.ts scripts/dev_tools/pr_context/collector.py extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts scripts/dev_tools/pr_context/autoclose.py   # empty
git diff --name-only origin/main...HEAD -- artifacts             # empty
poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>     # exit 0
wc -l <15 touched code/test files>
grep -c -F '"./src/lib/executable-resolver.ts": {' extensions/drm-copilot/jest.config.cjs   # 1 (also 1 for render-pr-helpers.ts and autoclose.ts)
```

**Executor commands (from evidence):** `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary --coverageReporters=lcov`; `poetry run pytest --cov=scripts.dev_tools.pr_context --cov-branch --cov-report=term-missing --deselect <#510 node>`.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-26
**Policy Version:** Current (as of audit date)

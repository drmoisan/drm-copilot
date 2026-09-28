# Policy Compliance Audit: collector-core-no-whichgh-branch-untested (#714)

---

**Audit Date:** 2026-09-27
**Code Under Test:** `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts` (new, 73 lines). No file under `extensions/drm-copilot/src/` is changed by this branch.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 1 file (new test file) | 3143 tests | PASS - 3143 pass, 0 fail | 96.95% lines, 90.89% branches (repo-wide) | 96.95% lines, 90.91% branches (repo-wide) | N/A - no new production file added; the sole changed file is a test file, which is excluded from `collectCoverageFrom` |

**Note:** Python, PowerShell, Bash, and JSON rows are omitted per the template's own instruction to delete rows for languages not involved in this change. Zero files in any of those languages changed in `git diff origin/main...HEAD` (confirmed below), so this is not a scope narrowing but a correct application of the template's own row-deletion instruction.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/baseline/typescript-test-coverage.2026-09-27T10-30.md` (repo-wide aggregate, captured before this change) and `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/baseline/collector-core-coverage-baseline.2026-09-27T10-30.md` (per-file, `collector-core.ts` only).
- TypeScript post-change coverage artifact: `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/qa-gates/final-typescript-test-coverage.2026-09-27T10-30.md` (repo-wide aggregate) and `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/qa-gates/coverage-delta-collector-core.2026-09-27T10-30.md` (per-file delta), both cross-checked directly against `extensions/drm-copilot/coverage/lcov.info`.
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed on this branch.
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed on this branch.
- Per-language comparison summary: see `### 1.2.1 Per-Language Coverage Comparison` below.

**Non-negotiable verdict rule:** No policy audit may report PASS unless it includes numeric baseline and post-change coverage metrics for every language in scope, plus changed/new-code coverage when required. This audit reports the required numeric TypeScript figures above and in Section 1.2.1; no required figure is missing.

**Fail-closed rule:** Every artifact cited in this audit was independently opened and read during this review (see per-section evidence citations); none is inferred or backfilled from memory.

---

## Executive Summary

This is a test-only, coverage-restoration change on branch `bug/collector-core-no-whichgh-branch-untested-714` (issue #714, work mode `full-bug`). It adds exactly one Jest test file, `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts` (73 lines), which calls `collectPrContext` with the `whichGh` option omitted entirely, exercising the previously-untested `whichGh === undefined` arm of the conditional spread at `extensions/drm-copilot/src/lib/pr-context/collector-core.ts:136`. No file under `extensions/drm-copilot/src/` is touched. `git diff origin/main...HEAD --name-status` shows 26 total changed paths: 25 new feature-folder documentation/evidence files and exactly one `A` entry under `extensions/drm-copilot/`, the new test file. The base branch is `origin/main` at `daae7f79`, which is an ancestor of `HEAD` (`300d05e4`) with no divergence (`git rev-list --left-right --count origin/main...HEAD` = `0  12`).

Toolchain evidence (format, lint, type-check, test-with-coverage) all record `EXIT_CODE: 0`. Repo-wide TypeScript coverage is 96.95% lines / 90.91% branches post-change, both above the uniform thresholds (>= 85% line, >= 75% branch). The single production file whose behavior is exercised by the new test, `collector-core.ts`, was not modified, but its measured branch coverage rose from 90.3846% to 92.4528% (a strict increase) with line coverage unchanged at 98.4456% (no regression).

**Policy documents evaluated:**
- [OK] `.claude/rules/general-code-change.md`
- [OK] `.claude/rules/general-unit-test.md`

**Language-specific policies evaluated:**
- [OK] `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/architecture-boundaries.md`
- [N/A] `.claude/rules/python.md` + `.claude/rules/python-suppressions.md` — no Python files changed
- [N/A] `.claude/rules/powershell.md` — no PowerShell files changed
- [N/A] Bash: no Bash files changed
- [N/A] JSON: no JSON configuration files changed

**Note:** all languages with changed files in the branch diff (TypeScript only) are evaluated above; Python, PowerShell, Bash, and JSON are correctly N/A because zero files of those languages changed.

Full toolchain results (format, lint, type-check, test with coverage) are PASS with `EXIT_CODE: 0` on every stage; no restart of the seven-stage loop was required (Section 2.5). Test coverage detail and per-language comparison are in Sections 1.2, 1.2.1, and 5.

**Temporary artifacts cleanup:**
- [OK] All temporary/one-time scripts created during development have been deleted
- [OK] Any ongoing tooling scripts are fully tested and compliant with repo policies
- No scripts were created during this feature's development. The only production-tree artifact created is the permanent test file `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts`, which is a kept, tested addition, not a temporary script.

---

## Rejected Scope Narrowing

None detected. The delegation prompt for this rework instructed rebuilding the three review artifacts from the MCP-resolved canonical templates using the substantive findings already produced by a completed full-bug audit of the entire branch-vs-base diff. It did not attempt to narrow scope to a plan, task, phase, or file subset, and did not mark any language's coverage as out of scope, plan-scope-only, or not applicable when that language had changed files.

## Scope Confirmation

- Reviewed HEAD: `300d05e4` (`git rev-parse HEAD`).
- Resolved base: `origin/main` at `daae7f79` (`git rev-parse origin/main`). `git rev-list --left-right --count origin/main...HEAD` = `0  12`: `origin/main` is an ancestor of `HEAD` with no divergence, confirming a clean rebase.
- Note on the local `main` ref: the worktree's local `main` branch is stale relative to `origin/main` (it pulls in unrelated already-merged history, including issues #716, #713, #710, and hook/skill changes, if diffed directly). Per the Scope Invariant, the legitimate base is the resolved base branch from `origin/main`, so this audit uses `git diff origin/main...HEAD`, independently re-run during this rework and confirmed to isolate only this branch's actual contribution.
- `git diff origin/main...HEAD --name-status` (re-run during this rework) shows exactly 26 changed paths: 25 new files under `docs/features/active/collector-core-no-whichgh-branch-untested-714/` (issue.md, spec.md, plan, research, and 21 evidence artifacts), and exactly one path under `extensions/drm-copilot/`:

```
A	extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts
```

- Independently confirmed by `git diff origin/main...HEAD --stat -- extensions/drm-copilot`: `1 file changed, 73 insertions(+)`, and by `wc -l` on the file directly: `73`.
- `git status --porcelain` returns empty (clean working tree) at the time of this rework.

**Verdict: PASS.** No path under `extensions/drm-copilot/src/` appears in the diff.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | The single `it` block constructs its own `TreeFileSystem` and `RecordingRunner` instances with no shared or global state, and no `beforeAll`/module-level mutable fixture is used (verified by direct read of the test file). |
| **Isolation** - Each test targets single behavior | PASS | Exactly one `it` targets exactly one behavior: the `whichGh === undefined` default-resolver arm. No other assertion targets an unrelated code path. |
| **Fast Execution** - Tests complete quickly | PASS | `evidence/qa-gates/verify-new-test.2026-09-27T10-30.md`: isolated run, `Time: 0.459 s`, 1 passed. Full-suite run (`evidence/qa-gates/final-typescript-test-coverage.2026-09-27T10-30.md`): 3143 tests in 5.531 s. |
| **Determinism** - Consistent results | PASS | No real `gh` process (`RecordingRunner` fake, no `child_process` import), no real filesystem (`TreeFileSystem` fake, no `fs`/`node:fs` import), no `process.env` read, no `jest.mock`/timers (verified by direct read of the test file). |
| **Readability & Maintainability** - Clear structure | PASS | `describe("collectPrContext (whichGh option omitted)", ...)` / `it("falls back to the default whichGh resolver and reports gh unavailable", ...)` names the scenario and expected outcome directly; a block comment at the top of the file states purpose and cross-references the untested branch by exact source text. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Repo-wide baseline (pre-development): 96.95% lines, 90.65% functions, 90.89% branches. **Command:** `cd extensions/drm-copilot && npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`. **Timestamp:** 2026-09-27T10-30. **Artifact:** `evidence/baseline/typescript-test-coverage.2026-09-27T10-30.md`. Per-file baseline for `collector-core.ts`: 98.4456% lines (380/386), 90.3846% branches (47/52) (`evidence/baseline/collector-core-coverage-baseline.2026-09-27T10-30.md`). |
| **No Coverage Regression** | PASS | Repo-wide post-change coverage: 96.95% lines (unchanged), 90.91% branches (+0.02 pp from 90.89%). **Status:** No regression; branch coverage strictly increased. Per-file `collector-core.ts`: line coverage 98.4456% -> 98.4456% (byte-identical, 380/386 both runs); branch coverage 90.3846% -> 92.4528% (+2.0682 pp). **Artifact:** `evidence/qa-gates/coverage-delta-collector-core.2026-09-27T10-30.md`, independently re-parsed from `extensions/drm-copilot/coverage/lcov.info` during this rework (`SF:src\lib\pr-context\collector-core.ts` block: `LF:386`, `LH:380`, `BRDA:136,2,0,1`, `BRDA:136,3,0,52`). |
| **New Code Coverage >=90%** | N/A | No new production file was added. The one changed file, `collector-core-default-resolver.test.ts`, is a test file and is excluded from `collectCoverageFrom` (`src/**/*.ts` only, per `extensions/drm-copilot/jest.config.cjs` line 17). No production line in `collector-core.ts` changed (`git diff origin/main...HEAD -- extensions/drm-copilot/src/lib/pr-context/collector-core.ts` returns no output). |
| **Comprehensive Coverage** | PASS | The new test targets `collectPrContext`'s `GhClient` construction default-resolver arm exclusively. Untested code: none introduced by this branch; the branch adds test code only, and the tested arm's counterpart (`whichGh` supplied) is already covered by the pre-existing `collector-core.test.ts` suite. |
| **Positive Flows** - Valid inputs | PASS | `test_falls_back_to_the_default_whichGh_resolver_and_reports_gh_unavailable` (the sole `it`): valid, well-formed options object with `whichGh` omitted -> `collectPrContext` returns a result with `ghAvailable === false` and the expected status message. Total positive tests: 1 (matching the single, narrowly-scoped behavior this bugfix targets). |
| **Negative Flows** - Invalid inputs | N/A | This bugfix's scope (per `spec.md` "Scope & Non-Goals") is limited to covering one specific existing, previously-untested branch; it explicitly excludes new negative-input scenarios as out of scope, to avoid duplicate coverage of behavior already exercised by `collector-core.test.ts`'s `"collectPrContext (gh unavailable)"` test. |
| **Edge Cases** - Boundary conditions | N/A | No new boundary condition is introduced; the change targets exactly one previously-uncovered ternary outcome, which is not a boundary/edge-case scenario. |
| **Error Handling** - Error paths | PASS | The test asserts the exact `ghStatusOverride` substring (`"GitHub CLI (gh) is not installed."`) produced by `hydrateAvailability`'s `!ghPath` early-return branch in `gh-client-core.ts`, and separately asserts that no `"gh"` argv was ever dispatched through the injected runner, confirming the error/unavailable path was taken correctly. |
| **Concurrency** - If applicable | N/A | The code under test (`collectPrContext`, `GhClient` construction) is synchronous; no concurrency behavior exists to test. |
| **State Transitions** - If applicable | N/A | No stateful component is introduced or exercised beyond a single synchronous call. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.95% lines / 90.89% branches -> Post-change: 96.95% lines / 90.91% branches. Change: +0.00 pp lines / +0.02 pp branches. New/changed-code coverage: N/A - no new production file added; the sole changed file is a test file excluded from `collectCoverageFrom`. Disposition: PASS. Evidence: `evidence/baseline/typescript-test-coverage.2026-09-27T10-30.md`; `evidence/qa-gates/final-typescript-test-coverage.2026-09-27T10-30.md`; `evidence/qa-gates/coverage-delta-collector-core.2026-09-27T10-30.md`; `extensions/drm-copilot/coverage/lcov.info` (independently re-parsed during this rework).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `expect(result.ghAvailable).toBe(false)`, `expect(result.ghStatusOverride).toContain("GitHub CLI (gh) is not installed.")`, and `expect(runner.calls.some((argv) => argv[0] === "gh")).toBe(false)` each produce a specific, diagnosable Jest assertion failure tied to one concern. |
| **Arrange-Act-Assert Pattern** | PASS | The test file carries explicit `// Arrange`, `// Act`, and `// Assert` comments (lines 47, 53, 64 of the test file, verified by direct read). |
| **Document Intent** | PASS | Test name states the scenario and expected outcome directly; the top-of-file block comment explains purpose and cites the exact untested source text. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No database, network, external process, or real filesystem dependency (verified by direct read: no `child_process`, `fs`/`node:fs`, `process.env`, or network imports in the test file). |
| **Use Mocks/Stubs** | PASS | `TreeFileSystem` (imported, existing in-memory filesystem fake) and `RecordingRunner` (new, minimal, hand-written `CommandRunner` fake local to this file) isolate the unit under test from real I/O. `RecordingRunner` is defined locally rather than imported because `collector-core.test.ts`'s equivalent fakes (`ScriptRunner`, `buildRunner`) are module-private and not exported. |
| **Environment Stability** | PASS | No global mutable state, no config file, and no temporary file is created or used (verified by direct read; confirmed no prohibited temporary-file usage). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document constitutes the required policy audit for this change, produced from the MCP-resolved canonical `policy-audit` template. No outstanding review items remain. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Objective is documented in `issue.md` (bug report, work mode `full-bug`) and `spec.md` (Context, Repro & Evidence, Root Cause Analysis sections), referencing issue #714 and the coverage regression introduced after issue #588 / PR #704. |
| **Read existing change plans** | PASS | `plan.2026-09-27T00-23.md` documents the execution plan; `research/research.2026-09-27T00-30.md` documents the call-site analysis and root-cause confirmation read before implementation. |
| **Document the plan** | PASS | The plan is documented in `docs/features/active/collector-core-no-whichgh-branch-untested-714/plan.2026-09-27T00-23.md`, with design decisions recorded in `spec.md`'s "Design Decisions" (D1-D7) section. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The test is a single `describe`/`it` pair with no unnecessary abstraction; the fake `CommandRunner` is the minimum needed to observe whether a `gh` invocation occurred. |
| **Reusability** | PASS | The test reuses the existing `TreeFileSystem` fake from `./tree-file-system` rather than duplicating filesystem-fake logic, while keeping the test-specific `RecordingRunner` local because it is unique to this test's needs. |
| **Extensibility** | N/A | No public API is introduced or modified by this test-only change. |
| **Separation of concerns** | PASS | The test exercises only the public `collectPrContext` entry point; it does not reach into `GhClient` or `hydrateAvailability` internals, keeping the test coupled to behavior rather than implementation. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | The new file has one clear purpose: covering the `whichGh === undefined` default-resolver arm. |
| **Under 500 lines** | PASS | `wc -l` on the new file returns `73` (verified directly, re-run during this rework). |
| **Public vs internal** | N/A | No public API surface change; the file is test code only. |
| **No circular dependencies** | PASS | The file imports only from `./tree-file-system`, `../../../src/lib/subprocess-runner`, and `../../../src/lib/pr-context/collector-core` — a strict one-way dependency from test to production code, with no cycle. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `RecordingRunner` (PascalCase class), `run`/`calls` (camelCase members), `collector-core-default-resolver.test.ts` (kebab-case, descriptive filename). |
| **Docs/docstrings** | PASS | The `RecordingRunner` class and its `run` method carry JSDoc-style comments explaining purpose and parameters. |
| **Comment why, not what** | PASS | The top-of-file block comment explains why the test exists (which arm was previously untested) rather than narrating obvious code; inline `// Arrange`/`// Act`/`// Assert` comments explain the phase's role in context. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `cd extensions/drm-copilot && npm run format`. **Result:** `EXIT_CODE: 0`, `All matched files use Prettier code style!` (`evidence/qa-gates/final-typescript-prettier.2026-09-27T10-30.md`). |
| **2. Linting** | PASS | **Command:** `cd extensions/drm-copilot && npm run lint`. **Result:** `EXIT_CODE: 0`, zero stdout/stderr findings (`evidence/qa-gates/final-typescript-lint.2026-09-27T10-30.md`). |
| **3. Type checking** | PASS | **Command:** `cd extensions/drm-copilot && npm run typecheck`. **Result:** `EXIT_CODE: 0`, no diagnostics (`evidence/qa-gates/final-typescript-typecheck.2026-09-27T10-30.md`). |
| **4. Testing** | PASS | **Command:** `cd extensions/drm-copilot && npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`. **Result:** `EXIT_CODE: 0`, 3143/3143 tests passing (`evidence/qa-gates/final-typescript-test-coverage.2026-09-27T10-30.md`). |
| **Full toolchain loop** | PASS | All four stages completed in a single pass with `EXIT_CODE: 0`; `evidence/qa-gates/final-typescript-test-coverage.2026-09-27T10-30.md` explicitly confirms via `git status --porcelain` that no prior loop step (prettier, eslint, tsc) changed a tracked file, so no restart was required. |
| **Explicit reporting** | PASS | All four commands and their exact results are documented in the evidence files cited above, timestamped `2026-09-27T10-30`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | `spec.md`'s "Proposed Fix" and Design Decisions (D1-D7) sections summarize the change; this audit's Executive Summary restates it. |
| **Design choices explained** | PASS | `spec.md` D1 (fix approach: test-only, rejecting production restructure or coverage-ignore comment) and D2 (test home: new dedicated file) explain the key alternatives considered and why each was adopted or rejected. |
| **Update supporting documents** | PASS | `spec.md`'s Acceptance Criteria section is checked off `[x]` for all 5 items (independently re-verified in Section "Acceptance Criteria Cross-Reference" below). `issue.md`'s Acceptance Criteria remain unchecked by design, since `spec.md` is the authoritative AC source for `full-bug` mode. |
| **Provide next steps** | PASS | `spec.md`'s "Rollout & Follow-up" section states standard PR merge, with no feature flag or staged rollout required. |

---

## 3. Language-Specific Code Change Policy Compliance

Only TypeScript has changed files in this branch's diff. Python, PowerShell, Bash, and JSON sections are omitted per the template's instruction to delete inapplicable-language sections.

### Section 3E: TypeScript Code Change Policy Compliance (`.claude/rules/typescript.md`)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | The test imports `type CommandResult`, `type CommandRunner`, `type CommandRunOptions` as explicit type-only imports; `RecordingRunner implements CommandRunner` with a fully-typed `run` method signature; no `any` is used anywhere in the file (verified by direct read). |
| **ES modules** | PASS | `import`/`export` syntax only; no `require`/`module.exports`. |
| **Naming** | PASS | `RecordingRunner` (PascalCase class), `run`/`calls` (camelCase members), `collector-core-default-resolver.test.ts` (kebab-case filename). |
| **Separation of concerns** | PASS | The test exercises only the public `collectPrContext` entry point and does not reach into host-bound or internal implementation details. |
| **No unauthorized suppressions** | PASS | No `eslint-disable`, `@ts-expect-error`, `@ts-ignore`, or `@ts-nocheck` appears anywhere in the file (verified by direct read, corroborated by the zero-finding ESLint result). |
| **Architecture boundaries** (`.claude/rules/architecture-boundaries.md`, `dependency-cruiser`) | PASS | The test imports only from `./tree-file-system`, `../../../src/lib/subprocess-runner`, and `../../../src/lib/pr-context/collector-core` — no Office.js import, no Microsoft Graph SDK import, no cross-layer violation. |

---

## 4. Language-Specific Unit Test Policy Compliance

Only TypeScript has changed files with tests in this branch's diff. Python and PowerShell sections are omitted per the template's instruction.

### Section 4C: TypeScript Unit Test Policy Compliance (`.claude/rules/typescript.md`)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | PASS | The test uses `describe`/`it`/`expect` from `@jest/globals`, matching every other test file in the suite. |
| **`*.test.ts` naming** | PASS | File is named `collector-core-default-resolver.test.ts`. |
| **No Outlook host runtime dependency** | PASS | No Office.js or Outlook host API is referenced anywhere in the file. |
| **Arrange-Act-Assert** | PASS | Explicit `// Arrange`, `// Act`, `// Assert` comments delineate each phase (test file lines 47, 53, 64). |
| **One behavior per test** | PASS | Exactly one `it`, targeting exactly one behavior (the default-resolver arm). |
| **Mocking / fakes** | PASS | Hand-written fakes (`TreeFileSystem`, `RecordingRunner`) are used in place of `jest.mock`/`jest.spyOn`. The policy's example (`jest.spyOn`/`jest.mock`) is a suggested mechanism, not an exclusive requirement; the hand-written fakes satisfy the same isolation and determinism goals, and there is no shared mock state requiring an `afterEach(() => jest.resetAllMocks())` teardown. |
| **No external dependencies** | PASS | No network, filesystem temp file, or external process dependency (verified by direct read). |
| **Avoid snapshot tests** | PASS | No `toMatchSnapshot()` or equivalent is used. |
| **Coverage thresholds** | PASS | See Section 1.2, 1.2.1, and 5 for full detail; repo-wide 96.95% lines / 90.91% branches, both above the 85%/75% uniform floors. |
| **Test file location** | PASS | The file is at `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts`, mirroring `src/lib/pr-context/collector-core.ts`'s path under this project's `test/` root. This matches the established, pre-existing convention for every sibling test file in this project (a project-wide `test/` root rather than the general policy's literal `tests/` example); the convention predates this branch and is not introduced or altered by it. No colocation in `src/` occurs. |

---

## 5. Test Coverage Detail

### `collectPrContext` — `GhClient` default-resolver arm (1 test)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `falls back to the default whichGh resolver and reports gh unavailable` | Positive / Error Handling | `collector-core.ts:136` (the `whichGh === undefined` ternary, previously-untaken arm); transitively, `gh-client-core.ts`'s `hydrateAvailability` `!ghPath` early-return branch | PASS |

**Coverage:** the single previously-uncovered ternary outcome at `collector-core.ts:136` is now covered: both `BRDA:` entries for the anchor line report non-zero hit counts post-change (`BRDA:136,2,0,1` and `BRDA:136,3,0,52`), versus the single zero-hit entry (`BRDA:136,2,0,0`) at baseline.

**Detailed line-by-line coverage:**
- Line 136 (`...(whichGh === undefined ? {} : { whichGh })`): PASS. Covered — the `whichGh === undefined` (true) arm now executes via the new test; the `whichGh` supplied (false) arm remains covered by the pre-existing `collector-core.test.ts` suite, which supplies `whichGh` at every one of its 7 `collectPrContext` call sites.

**Not covered:** None. The one branch this change targets is now fully covered on both outcomes.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (full suite) | 3143 | PASS |
| Tests Passed | 3143 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time (full suite) | 5.531 s total | PASS Fast |
| Execution Time (new test, isolated) | 0.459 s | PASS Fast |
| Test Suites | 228/228 | PASS |
| New Test File Size | 73 lines | PASS Maintainable |
| Code Coverage (repo-wide, post-change) | 96.95% lines, 90.91% branches | PASS |
| Code Coverage (`collector-core.ts`, post-change) | 98.4456% lines, 92.4528% branches | PASS |

---

## 7. Code Quality Checks

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier Formatting | `cd extensions/drm-copilot && npm run format` | `All matched files use Prettier code style!`, exit 0 | PASS |
| ESLint Linting | `cd extensions/drm-copilot && npm run lint` | Zero findings, exit 0 | PASS |
| TSC Type Checking | `cd extensions/drm-copilot && npm run typecheck` | No diagnostics, exit 0 | PASS |
| Jest Tests (with coverage) | `cd extensions/drm-copilot && npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` | 3143/3143 passing, exit 0 | PASS |

**Notes:** No pre-existing failures unrelated to this work were observed. All four toolchain stages passed in a single pass with no restart.

---

## 8. Gaps and Exceptions

### Identified Gaps
**None.** All policy requirements are met.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
**None.** All planned tests implemented. `spec.md`'s Test Strategy explicitly scoped this change to a single `it` block, and that single test was delivered as planned.

---

## 9. Summary of Changes

### Commits in This PR/Branch

This branch's commit history reflects an orchestrator-required per-phase commit-and-push pattern; the working tree at review time (`HEAD` = `300d05e4`) reflects the complete, final state described below. The full commit log is available via `git log origin/main..HEAD` and is not restated verbatim here because it is not the audit's evidentiary basis — the branch-vs-base diff is.

### Files Modified

1. **`extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts`** (NEW)
   - Adds one Jest test covering the previously-untested `whichGh === undefined` arm of `collector-core.ts`'s `GhClient` construction.
   - 73 lines; imports the existing `TreeFileSystem` fake and defines one new, minimal, local `RecordingRunner` fake.

2. **`docs/features/active/collector-core-no-whichgh-branch-untested-714/*`** (NEW, 25 files)
   - `issue.md`, `spec.md`, `plan.2026-09-27T00-23.md`, `research/research.2026-09-27T00-30.md`, and 21 evidence artifacts under `evidence/{baseline,qa-gates,regression-testing,other}/` documenting the toolchain runs, coverage baselines, and acceptance-criteria verification for this feature.

No file under `extensions/drm-copilot/src/` is created, modified, or deleted by this branch.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policy requirements — general code-change policy, general unit-test policy, TypeScript-specific code-change and unit-test policy, coverage thresholds (repo-wide, per-file, and per-language comparison), evidence-location compliance, and architecture boundaries — are satisfied with verified, independently re-checked evidence. No blocking or partial findings were identified.

**Fail-closed reminder:** Every baseline artifact, QA artifact, and coverage-comparison artifact cited above was independently opened and verified during this audit; none was missing, so this verdict is not fail-closed to BLOCKED or INCOMPLETE.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, plan, and design decisions all documented in `issue.md`, `spec.md`, and `plan.2026-09-27T00-23.md`.
- PASS Design Principles: simplicity, reusability, and separation of concerns all demonstrated in the new test file.
- PASS Module & File Structure: 73 lines, no circular dependencies, one clear purpose.
- PASS Naming, Docs, Comments: descriptive names, JSDoc on the fake class, comments explain why.
- PASS Toolchain Execution: all four stages pass with exit 0 in a single pass.
- PASS Summarize & Document: `spec.md` documents changes and design choices; AC checked off.

#### Language-Specific Code Change Policy (Section 3)

**For TypeScript:**
- PASS Strong typing, ES modules, naming, separation of concerns, no unauthorized suppressions, architecture boundaries: all verified directly against the file contents.

#### General Unit Test Policy (Section 1)
- PASS Core Principles: independence, isolation, fast execution, determinism, readability all demonstrated.
- PASS Coverage & Scenarios: baseline documented, no regression, comprehensive coverage of the targeted branch; new/edge-case/concurrency/state-transition items are correctly N/A for this narrowly-scoped bugfix.
- PASS Test Structure: clear failure messages, AAA pattern, documented intent.
- PASS External Dependencies: no external dependencies; mocks/stubs used appropriately; environment stable.
- PASS Policy Audit: this document satisfies the requirement.

#### Language-Specific Unit Test Policy (Section 4)

**For TypeScript:**
- PASS Framework & Scope: Jest, `*.test.ts` naming, no host-runtime dependency.
- PASS Test Style & Structure: AAA, one behavior per test, appropriate fakes, no external dependencies.
- PASS Naming & Readability: descriptive test and `describe` names.
- PASS Toolchain: all four stages pass with exit 0.

---

### Metrics Summary

- PASS 3143/3143 tests passing (100%)
- PASS Full toolchain (format, lint, type-check, test-with-coverage) exit 0, single pass, no restart
- PASS 96.95% repo-wide line coverage (>= 85% threshold)
- PASS 90.91% repo-wide branch coverage (>= 75% threshold)
- PASS Proper file organization: new test file under `test/lib/pr-context/`, mirroring `src/lib/pr-context/`
- PASS All code quality checks passing (Prettier, ESLint, TSC)
- PASS Test execution time: 5.531 s full suite, 0.459 s isolated (fast)

---

### Recommendation

**Ready for merge.**

No outstanding items. All acceptance criteria in `spec.md` are PASS and checked off `[x]`; the toolchain is clean; coverage thresholds are met with margin; evidence locations are canonical; and no policy violation was identified.

---

## Appendix A: Test Inventory

### Complete Test List (this branch's new file)

1. `collectPrContext (whichGh option omitted)` › `falls back to the default whichGh resolver and reports gh unavailable`

**Full-suite context (unchanged tests, for reference):** 3142 pre-existing tests across 227 test suites (baseline, per `evidence/other/change-footprint.2026-09-27T10-30.md`), plus this one new test, totaling 3143 tests across 228 suites (post-change, per `evidence/qa-gates/final-typescript-test-coverage.2026-09-27T10-30.md`).

---

## Appendix B: Toolchain Commands Reference

**For TypeScript (cwd: `extensions/drm-copilot`, per `spec.md` D7):**
```bash
# Formatting
cd extensions/drm-copilot && npm run format

# Linting
cd extensions/drm-copilot && npm run lint

# Type checking
cd extensions/drm-copilot && npm run typecheck

# Testing (with coverage)
cd extensions/drm-copilot && npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

# Isolated new-test run
cd extensions/drm-copilot && npx jest --config jest.config.cjs test/lib/pr-context/collector-core-default-resolver.test.ts
```

**Scope-confirmation commands used in this audit:**
```bash
git rev-parse HEAD
git rev-parse origin/main
git rev-list --left-right --count origin/main...HEAD
git diff origin/main...HEAD --name-status
git diff origin/main...HEAD --stat -- extensions/drm-copilot
wc -l extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts
git status --porcelain
```

---

**Audit Completed By:** feature-review agent (Claude Sonnet 5)
**Audit Date:** 2026-09-27
**Policy Version:** Current (as of audit date)

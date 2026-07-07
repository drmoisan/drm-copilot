# Policy Compliance Audit: fix-subagent-tree-discovery-terminal (Issue #325)

**Audit Date:** 2026-07-07
**Code Under Test:** `extensions/drm-copilot/src/command-runtime.ts`, `extensions/drm-copilot/src/subagent-tree-command.ts`, `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts`, `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/test/command-runtime.test.ts`, `extensions/drm-copilot/test/subagent-tree-command.test.ts`, `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`, `extensions/drm-copilot/test/lib/subagent-tree/module-boundary.test.ts`

**Base branch:** `main` (merge base `4db27ebed2bde1919eda5991ff0de938204aef03`)
**Head branch:** `bug/fix-subagent-tree-discovery-terminal-325` @ `f13414af56995c8b64d471e7f749f07f54b48e5d`
**Work Mode (from `issue.md`):** `minor-audit` — acceptance-criteria source is the `## Acceptance Criteria` section of `issue.md` only.

**Template provenance note:** The MCP tool `resolve_policy_audit_template_asset` was not available as a callable tool in this review session. As a best-effort fallback per the workflow's "proceed with best-effort assumptions and document them" guidance, this audit was authored from the repository-local template at `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, preserving its canonical section structure.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage (repo-wide) | Post-Change Coverage (repo-wide) | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 7 src/test files + 1 config (`jest.config.cjs`) | 1529 | PASS 1529 pass, 0 fail | 96.53% lines / 88.42% branches (`evidence/baseline/test-coverage.2026-07-07T02-45.md`) | 96.59% lines / 88.52% branches (independently recomputed from `extensions/drm-copilot/coverage/lcov.info`) | `workspace-encoding.ts` (new file): 100.00% lines / 100.00% branches |

No Python, PowerShell, C#, Bash, or JSON-schema-governed files changed in this branch diff (`git diff main...HEAD --name-only` yields only `.ts`, one `.cjs`, and `.md` files). Those language sections are omitted per template guidance; TypeScript is the only in-scope language.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/baseline/test-coverage.2026-07-07T02-45.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/test-coverage.2026-07-07T03-15.md`, cross-checked directly against `extensions/drm-copilot/coverage/lcov.info` (regenerated on disk from the executor's `npm run test:coverage` run; not re-run by this audit per the coverage-verification "inspect, don't regenerate" rule)
- Per-language comparison summary: this section and `## 5. Test Coverage Detail` below

**Non-negotiable verdict rule compliance:** Numeric baseline and post-change coverage metrics for TypeScript (the only in-scope language) are recorded above and cross-verified against `coverage/lcov.info`.

---

## Rejected Scope Narrowing

No caller instruction in this delegation prompt attempted to narrow the audit to a plan/task/phase subset, to a subset of changed files, or to mark any language's coverage as out of scope. The delegation prompt explicitly names `extensions/drm-copilot/` as "the changed production code," which matches the actual branch diff (verified independently via `git diff main...HEAD --name-only`) rather than narrowing it — no other language has changed files in this diff. No rejected-narrowing entries are recorded.

---

## Executive Summary

This review audits the full `bug/fix-subagent-tree-discovery-terminal-325` branch diff against `main` (merge-base `4db27eb`), a single-commit change (`f13414a`) that fixes transcript discovery for the `drmCopilotExtension.showSubagentTree` command (resolving the user-global `~/.claude/projects/` directory instead of a repo-relative glob) and re-routes rendered output from an `OutputChannel` to an integrated VS Code terminal.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`
- PASS `typescript.md`
- PASS `typescript-suppressions.md`
- PASS `architecture-boundaries.md` (TypeScript layer/No-COM assertions)
- N/A `ci-workflows.md` — no `pwsh` workflow steps touched
- N/A `benchmark-baselines.md` — no benchmark baselines touched
- N/A `orchestrator-state.md` — no orchestrator-state checkpoint touched

**Language-specific policies evaluated:**
- PASS TypeScript (`typescript.md` + `general-unit-test.md`)
- N/A Python, PowerShell, C#, Bash, JSON-schema — no changed files

Toolchain execution (format, lint, typecheck, test:coverage, build) was independently re-run by this audit (except coverage generation itself, which was inspected from the existing `coverage/lcov.info` artifact per policy) and all five stages pass cleanly with zero findings, matching the executor's own Phase 2 evidence. Per-file and repo-wide coverage exceed the uniform 85%/75% gate.

Two Blocking findings were identified during independent code inspection that were not caught by the plan's own Phase 1/Phase 2 verification:
1. `extensions/drm-copilot/src/command-runtime.ts` is 669 lines, exceeding the repository's 500-line file-size limit (`general-code-change.md`). The file was already over the limit before this feature (531 lines at `main`); this feature's diff added 138 more lines to it rather than extracting the new `TerminalWriter` seam into its own module.
2. `PseudoterminalTerminalWriter.write()` only inserts `\r\n` at the header/body boundary; it does not normalize internal newlines within a multi-line `body` (produced by `formatTree`'s `\n`-joined lines). A raw VS Code `Pseudoterminal` requires `\r\n` for every line break, so any tree with more than one rendered line (i.e., any session with subagent children — the common case) will render with a "staircase" cursor-offset defect in the real integrated terminal.

Both findings are detailed in `code-review.2026-07-07T03-30.md` and are documented as remediation-required in `remediation-inputs.2026-07-07T03-30.md`.

**Temporary artifacts cleanup:**
- PASS No temporary/one-time scripts were introduced by this feature's diff (verified via `git diff main...HEAD --name-only`; the only non-`.ts`/`.md` file is `jest.config.cjs`, a permanent config edit, not a throwaway script).
- N/A No ongoing tooling scripts were added.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | All new/modified test files use `beforeEach`/`afterEach` to reset mocks (`commandHandlers.clear()`, `jest.clearAllMocks()`, `createTerminalMock.mockClear()`); no shared mutable module-level state persists across tests other than mock call-tracking arrays that are reset each test. |
| **Isolation** - Each test targets single behavior | PASS | `test/command-runtime.test.ts` groups by `describe("getClaudeProjectsRoot")` / `describe("createSubagentTreeTerminalWriter")`, each `it()` asserting one behavior (e.g., "reuses the same terminal...", "creates a replacement terminal once..."). `test/subagent-tree-command.test.ts` similarly has one scenario per `it()`. |
| **Fast Execution** - Tests complete quickly | PASS | Full suite (133 files, 1529 tests) completes in 2.405s per this audit's independent `npm run test` run. |
| **Determinism** - Consistent results | PASS | No real timers, no `Date.now()`/`Math.random()`/network/filesystem I/O in the new tests; `InMemoryFileSystem` and `FakeTerminalWriter`/`FakeEventEmitter` fakes are used throughout. Re-running the suite twice (once via `test:coverage`, once via plain `test`) produced identical pass counts. |
| **Readability & Maintainability** - Clear structure | PASS | Test names are descriptive full sentences (e.g., "does not fire pending content before the Pseudoterminal reports it is open"); every test has an Arrange/Act/Assert comment structure. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Baseline (pre-development, `evidence/baseline/test-coverage.2026-07-07T02-45.md`): repo-wide 96.53% lines / 88.42% branches; pre-existing `src/subagent-tree-command.ts` 92.44%/85.71%; pre-existing `src/command-runtime.ts` 92.66%/83.10%. Command: `npm run test:coverage`. Timestamp: 2026-07-07T02-45. |
| **No Coverage Regression** | PASS | Post-change repo-wide: 96.59% lines / 88.52% branches (independently recomputed from `coverage/lcov.info`: `LF=31907 LH=30818 BRF=4453 BRH=3942`) — a net improvement over baseline, not a regression. Per-file: `command-runtime.ts` 92.66%→94.02% lines, 83.10%→87.10% branches; `subagent-tree-command.ts` 92.44%→100.00% lines, 85.71%→94.74% branches (both improved). |
| **New Code Coverage ≥90%** | PASS | New file `src/lib/subagent-tree/workspace-encoding.ts`: 64/64 lines (100.00%), 4/4 branches (100.00%), independently confirmed via `grep -n "SF:" coverage/lcov.info` plus `awk` extraction of the `LF/LH/BRF/BRH` block at that file's `SF:` anchor. |
| **Comprehensive Coverage** | PASS | `getClaudeProjectsRoot`: 5 tests (config-dir override, HOME fallback, USERPROFILE fallback, whitespace-only override treated as unset, throw-when-unset). `encodeWorkspacePath`/`matchEncodedDirectories`: 6 tests (separator equivalence, case-insensitive drive letter, worktree sibling, nested worktree sibling, no-match). `PseudoterminalTerminalWriter`: 6 tests (create+emit, reveal, reuse-while-open, replace-when-exited, defer-until-open). `registerSubagentTreeCommand`: 9 tests covering discovery source, auto-select, quick-pick, subagents exclusion, zero-candidates message, terminal write+reveal, terminal-writer reuse across invocations, discovery-failure error routing, user-cancel error routing. |
| **Positive Flows** - Valid inputs | PASS | E.g. "resolves candidates from the user-global Claude projects directory...", "auto-selects a single discovered root session...", "uses CLAUDE_CONFIG_DIR's projects subfolder when it is set". |
| **Negative Flows** - Invalid inputs | PASS | "throws when none of CLAUDE_CONFIG_DIR, HOME, or USERPROFILE is set"; "routes a discovery failure to the error path and does not write to the terminal seam". |
| **Edge Cases** - Boundary conditions | PASS | Lowercase-vs-uppercase drive-letter matching; nested worktree-of-a-worktree; whitespace-only `CLAUDE_CONFIG_DIR` treated as unset; write-before-`open()` deferred-content case. |
| **Error Handling** - Error paths | PASS | Discovery-failure and user-cancel paths both asserted to route to `showErrorMessage`/output log and never to `terminalWriter.write`. |
| **Concurrency** - If applicable | N/A | No concurrent/async-race behavior is introduced; the command handler is a single sequential `async` flow with no parallel awaits. |
| **State Transitions** - If applicable | PASS | `PseudoterminalTerminalWriter`'s open/exited/replaced terminal lifecycle is a state machine and is explicitly tested (open→write, exited→replace, pre-open buffering). |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.53% lines / 88.42% branches -> Post-change: 96.59% lines / 88.52% branches. Change: +0.06% lines / +0.10% branches. New/changed-code coverage: `workspace-encoding.ts` 100.00%/100.00%; `command-runtime.ts` (modified) 94.02%/87.10%; `subagent-tree-command.ts` (modified) 100.00%/94.74%. Disposition: PASS. Evidence: `evidence/baseline/test-coverage.2026-07-07T02-45.md`, `evidence/qa-gates/test-coverage.2026-07-07T03-15.md`, `extensions/drm-copilot/coverage/lcov.info` (independently parsed by this audit).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Jest's `expect(...).toBe/.toEqual/.toHaveBeenCalledTimes` assertions produce standard diff-based failure output; several assertions target specific substrings (e.g. `expect(message).not.toContain(".claude/projects/**/*.jsonl")`) that would fail loudly and specifically. |
| **Arrange-Act-Assert Pattern** | PASS | Every new/modified `it()` block in the four reviewed test files uses explicit `// Arrange` / `// Act` / `// Assert` comments. |
| **Document Intent** | PASS | Test names are full descriptive sentences; module-level JSDoc explains fixture purpose (e.g. `FakeEventEmitter`, `CLAUDE_PROJECTS_ROOT` constant comment explaining why it's deliberately distinct from `WORKSPACE_ROOT`). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or real filesystem access in the new/modified tests. `vscode` is `jest.mock`'d (`{ virtual: true }`); filesystem access goes through the pre-existing `InMemoryFileSystem` test double. |
| **Use Mocks/Stubs** | PASS | `FakeEventEmitter`/`createTerminalMock` stand in for `vscode.EventEmitter`/`vscode.window.createTerminal`; `FakeTerminalWriter` implements the `TerminalWriter` interface directly for `subagent-tree-command.test.ts`; `getWorkspaceRootMock`/`getClaudeProjectsRootMock` replace the real environment-dependent resolvers. |
| **Environment Stability** | PASS | No temporary files are created (`InMemoryFileSystem` is purely in-memory); no reliance on the real `HOME`/`USERPROFILE`/`CLAUDE_CONFIG_DIR` in tests (all injected). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document, `code-review.2026-07-07T03-30.md`, and `feature-audit.2026-07-07T03-30.md` constitute the required pre-submission policy review for this branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` states the problem (relative-glob discovery bug + OutputChannel→terminal enhancement) and Proposed Behavior in detail; Issue #325. |
| **Read existing change plans** | PASS | `plan.2026-07-06T22-35.md` Phase 0 records reading `general-code-change.md`, `general-unit-test.md`, `typescript.md`, `typescript-suppressions.md` (`evidence/baseline/phase0-instructions-read.md`). |
| **Document the plan** | PASS | `plan.2026-07-06T22-35.md` documents an 18-task Phase 1 implementation plan plus a 6-task Phase 2 QC loop, all checked complete. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | `workspace-encoding.ts` is two small, pure, single-purpose functions; `getClaudeProjectsRoot` is a short resolver with a clear precedence order. |
| **Reusability** | PARTIAL | The new `TerminalWriter` seam mirrors the existing `FileSystem` injection pattern (good reuse of an established convention), but the new logic was appended into the already-oversized `command-runtime.ts` rather than factored into its own module — see Section 2.3 finding. |
| **Extensibility** | PASS | `TerminalWriter` is an interface with an injectable factory (`createTerminalWriter?`), mirroring `createFileSystem?`, so alternative implementations/fakes can be substituted without changing `registerSubagentTreeCommand`'s signature contract. |
| **Separation of concerns** | PASS | Pure encoding/matching logic (`workspace-encoding.ts`) has no `vscode` import (statically verified by `test/lib/subagent-tree/module-boundary.test.ts` and independently re-inspected by this audit); all VS Code host wiring (terminal creation, environment resolution) stays in `command-runtime.ts`/`subagent-tree-command.ts`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | `workspace-encoding.ts` is cohesive (encoding + matching only); `subagent-tree-command.ts` remains thin host wiring. |
| **Under 500 lines** | **FAIL** | `extensions/drm-copilot/src/command-runtime.ts` is **669 lines** (`wc -l`, independently confirmed), exceeding the repository's 500-line limit (`general-code-change.md`: "No production code... file may exceed 500 lines"). The file was already over the limit at `main` (531 lines, confirmed via `git show main:extensions/drm-copilot/src/command-runtime.ts \| wc -l`); this feature's diff adds +138 lines (the `getClaudeProjectsRoot` resolver, the `TerminalWriter` interface, `PseudoterminalTerminalWriter` class, and `createSubagentTreeTerminalWriter` factory) directly into the same file rather than extracting them into a new module (e.g. a `terminal-writer.ts`), which would have both respected the limit and improved cohesion. All other changed/new files are within limit: `subagent-tree-command.ts` 179 lines, `workspace-encoding.ts` 64 lines, `test/command-runtime.test.ts` 207 lines, `test/subagent-tree-command.test.ts` 309 lines, `test/lib/subagent-tree/workspace-encoding.test.ts` 120 lines, `test/lib/subagent-tree/module-boundary.test.ts` 40 lines. This is a Blocking finding; see `remediation-inputs.2026-07-07T03-30.md`. |
| **Public vs internal** | PASS | `discoverRootSessionCandidates`/`selectRootSession` remain unexported (module-private); `PseudoterminalTerminalWriter` is not exported, only the `TerminalWriter` interface and `createSubagentTreeTerminalWriter` factory are. |
| **No circular dependencies** | PASS | `subagent-tree-command.ts` imports from `command-runtime.ts` and `lib/subagent-tree/*`; neither of those imports back from `subagent-tree-command.ts`. `npm run build`/`npm run typecheck` complete without circular-reference errors. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `getClaudeProjectsRoot`, `encodeWorkspacePath`, `matchEncodedDirectories`, `PseudoterminalTerminalWriter`, `SUBAGENT_TREE_TERMINAL_NAME` — all `camelCase`/`PascalCase` per convention, no unexplained abbreviations. |
| **Docs/docstrings** | PASS | Every new exported function/interface/class carries a JSDoc block with `@param`/`@returns`/`@throws` as applicable. |
| **Comment why, not what** | PASS | E.g. the comment on `terminalWriter` construction explains *why* it is built once at registration time ("so repeated command invocations share the same TerminalWriter instance"), not merely restating the code. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (check-only variant run by this audit to avoid mutating files; equivalent to `npm run format`). **Result:** "All matched files use Prettier code style!" — 0 files needed reformatting. Cross-checked against executor evidence `evidence/qa-gates/format.2026-07-07T03-15.md` (EXIT_CODE 0). |
| **2. Linting** | PASS | **Command:** `npm run lint` (independently re-run). **Result:** no output, exit 0 — 0 errors/warnings. Matches `evidence/qa-gates/lint.2026-07-07T03-15.md`. |
| **3. Type checking** | PASS | **Command:** `npm run typecheck` (independently re-run). **Result:** no output, exit 0 — 0 type errors. Matches `evidence/qa-gates/typecheck.2026-07-07T03-15.md`. |
| **4. Testing** | PASS | **Command:** `npm run test` (independently re-run, non-coverage). **Result:** 133 suites / 1529 tests passed, 2.405s. Matches the test-count reported alongside `evidence/qa-gates/test-coverage.2026-07-07T03-15.md`. |
| **Full toolchain loop** | PASS | Executor evidence (`evidence/qa-gates/final-qc-clean-pass.2026-07-07T03-15.md`) records a single-pass clean loop (iteration count 1); this audit's independent re-run of format-check/lint/typecheck/test/build corroborates a clean state with zero file modifications. |
| **Explicit reporting** | PASS | Commands and results recorded above and in `evidence/qa-gates/*.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | See Section 9 below and the single commit `f13414a`. |
| **Design choices explained** | PASS | `command-runtime.ts` module JSDoc and `subagent-tree-command.ts` function JSDoc explain the discovery/terminal-wiring rationale. |
| **Update supporting documents** | PASS | `issue.md` Acceptance Criteria checkboxes are checked; `evidence/other/ac-verification.2026-07-07T03-09.md` documents criterion-by-criterion mapping. |
| **Provide next steps** | PASS | See `## 10. Compliance Verdict` and `remediation-inputs.2026-07-07T03-30.md` for the two Blocking findings that must be resolved before merge. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3E: TypeScript Code Change Policy Compliance

#### 3E.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | `npx prettier --check` — all files pass. |
| **Linting with ESLint** | PASS | `npm run lint` — 0 errors/warnings. |
| **Type checking with tsc** | PASS | `npm run typecheck` — 0 errors. No `any` introduced (`git diff main...HEAD -- extensions/drm-copilot/src extensions/drm-copilot/test \| grep ": any\b"` — no matches). |
| **Testing with Jest** | PARTIAL | `typescript.md` specifies Vitest as the required TypeScript test framework, but this extension uses Jest (`test:coverage`: `node run-jest.cjs --coverage`). This is a pre-existing repository convention for `extensions/drm-copilot/` predating this feature (the whole extension's existing test suite — 126 of 133 test files — already uses Jest before this branch), not a deviation introduced by this diff. Recorded as a pre-existing, out-of-scope inconsistency, not attributed to this feature. |

#### 3E.2 TypeScript Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | `getClaudeProjectsRoot(env: NodeJS.ProcessEnv = process.env): string`; `TerminalWriter` interface with explicit method signatures; no `any` in the diff. |
| **No suppressions** | PASS | `git diff` search for `eslint-disable`, `@ts-ignore`, `@ts-expect-error` in the changed `src`/`test` files returns no matches. |
| **ES modules** | PASS | All new code uses `import`/`export`; no `require`/`module.exports` introduced in `src`/`test`. |
| **Domain types** | PASS | `TerminalWriter` interface models the seam's invariant (write + reveal) cleanly. |

#### 3E.3 TypeScript Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Fail fast, explicit errors** | PASS | `getClaudeProjectsRoot` throws a descriptive `Error` when no home/config-dir source is resolvable, which the pre-existing outer `try`/`catch` in `registerSubagentTreeCommand`'s command handler routes to `showErrorMessage`. |
| **No silent catch-alls** | PASS | The single `catch (error: unknown)` block extracts `error.message` and re-surfaces it via `output.appendLine` + `showErrorMessage`; it does not swallow the failure. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4C: TypeScript (Jest) Unit Test Policy Compliance

#### 4C.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest (repo convention for this extension)** | PASS | All new/modified test files use `@jest/globals` (`describe`, `it`, `expect`, `jest`). |
| **Coverage expectation** | PASS | Per-file thresholds (85% lines / 75% branches) added to `jest.config.cjs` for `workspace-encoding.ts` and `command-runtime.ts`; both, plus `subagent-tree-command.ts` (pre-existing entry), independently confirmed to exceed the gate. |

#### 4C.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | See Section 1.1/1.2 above. |
| **Mocking sparingly** | PASS | Mocking is limited to the `vscode` module boundary (necessarily virtual) and the two environment-dependent resolvers (`getWorkspaceRoot`, `getClaudeProjectsRoot`); domain logic (`encodeWorkspacePath`, `matchEncodedDirectories`) is tested unmocked. |
| **Organization mirrors code structure** | PASS | `test/command-runtime.test.ts` ↔ `src/command-runtime.ts`; `test/subagent-tree-command.test.ts` ↔ `src/subagent-tree-command.ts`; `test/lib/subagent-tree/workspace-encoding.test.ts` ↔ `src/lib/subagent-tree/workspace-encoding.ts`. No colocation in `src/`. |

#### 4C.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File naming `*.test.ts`** | PASS | All four reviewed test files follow the convention. |
| **Describe/It structure** | PASS | Nested `describe`/`it` blocks group by function/class under test. |

#### 4C.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest via `npm run test`/`test:coverage`** | PASS | Independently re-run by this audit; 1529/1529 pass. |
| **No alternative test runners** | PASS | Only Jest is invoked; no other test framework present in the diff. |

---

## 5. Test Coverage Detail

### `getClaudeProjectsRoot` (5 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| uses CLAUDE_CONFIG_DIR's projects subfolder when it is set | Positive | PASS |
| falls back to HOME/.claude/projects when CLAUDE_CONFIG_DIR is unset | Positive | PASS |
| falls back to USERPROFILE when neither CLAUDE_CONFIG_DIR nor HOME is set | Positive | PASS |
| treats a whitespace-only CLAUDE_CONFIG_DIR as unset and falls back to HOME | Edge Case | PASS |
| throws when none of CLAUDE_CONFIG_DIR, HOME, or USERPROFILE is set | Negative/Error Handling | PASS |

**Coverage:** Function fully exercised across all branches (config-dir set/unset/whitespace, HOME set/unset, USERPROFILE fallback, throw path).

### `PseudoterminalTerminalWriter` / `createSubagentTreeTerminalWriter` (6 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| creates a single named terminal backed by a Pseudoterminal that emits header and body joined by \r\n | Positive | PASS |
| reveals the terminal via show() | Positive | PASS |
| reuses the same terminal across repeated writes while it remains open | State Transition | PASS |
| creates a replacement terminal once the previous terminal has exited | State Transition | PASS |
| does not fire pending content before the Pseudoterminal reports it is open | Edge Case | PASS |

**Coverage:** 629/669 lines (94.02%), 81/93 branches (87.10%) for the whole `command-runtime.ts` file (includes pre-existing, previously-tested functions outside this feature's scope). **Not covered / known gap:** no test exercises a **multi-line** `body` value through `write()`; every test uses single-line bodies (`"BODY"`, `"b1"`, `"b2"`). This gap is what allowed the CRLF-normalization defect (Blocking finding in `code-review.2026-07-07T03-30.md`) to go undetected by the existing suite.

### `encodeWorkspacePath` / `matchEncodedDirectories` (6 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| replaces backslashes, forward slashes, and colons with hyphens | Positive | PASS |
| encodes a forward-slash workspace path identically to a backslash one | Positive | PASS |
| matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name | Edge Case | PASS |
| includes a per-worktree sibling folder among the matched candidate directories | Positive | PASS |
| includes a nested worktree-of-a-worktree sibling folder | Edge Case | PASS |
| returns an empty array when no directory name matches | Negative | PASS |

**Coverage:** 64/64 lines (100.00%), 4/4 branches (100.00%). **Not covered:** None.

### `registerSubagentTreeCommand` / `discoverRootSessionCandidates` / `selectRootSession` (9 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| resolves candidates from the user-global Claude projects directory rather than the workspace root | Positive | PASS |
| auto-selects a single discovered root session without prompting | Positive | PASS |
| prompts via showQuickPick among multiple candidates and renders the one selected | Positive | PASS |
| excludes flattened /subagents/ transcripts from candidates | Edge Case | PASS |
| names the real resolved user-global search location in the zero-candidates error message | Negative/Error Handling | PASS |
| writes the header plus full formatTree output to the terminal seam and reveals it | Positive | PASS |
| reuses the same terminal-writer instance across two consecutive invocations | State Transition | PASS |
| routes a discovery failure to the error path and does not write to the terminal seam | Error Handling | PASS |
| routes a user-cancel selection to the output log and does not write to the terminal seam | Negative | PASS |

**Coverage:** 179/179 lines (100.00%), 18/19 branches (94.74%). **Not covered:** one branch not exercised (per `coverage/lcov-report`); does not affect the 85%/75% gate.

### Module Boundary (`module-boundary.test.ts`) (1 test)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| contains no `vscode` import statements in any source file | Architecture-boundary | PASS |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 1529 | PASS |
| Tests Passed | 1529 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 2.405s total (independent `npm run test` run) | PASS Fast |
| Test Suites | 133 | PASS |
| Functions/Classes Tested (new this feature) | `getClaudeProjectsRoot`, `createSubagentTreeTerminalWriter`/`PseudoterminalTerminalWriter`, `encodeWorkspacePath`, `matchEncodedDirectories`, `discoverRootSessionCandidates` (modified), `selectRootSession` (modified), `registerSubagentTreeCommand` (modified) — all exercised | PASS |
| Code Coverage (repo-wide) | 96.59% lines, 88.52% branches | PASS |
| Code Coverage (this feature's files) | `workspace-encoding.ts` 100.00%/100.00%; `command-runtime.ts` 94.02%/87.10%; `subagent-tree-command.ts` 100.00%/94.74% | PASS |

---

## 7. Code Quality Checks

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier Formatting | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | All matched files use Prettier code style | PASS |
| ESLint Linting | `npm run lint` | 0 errors, 0 warnings | PASS |
| tsc Type Checking | `npm run typecheck` | 0 type errors | PASS |
| Jest Tests | `npm run test` | 133 suites / 1529 tests passed | PASS |
| Jest Coverage | `npm run test:coverage` (inspected from executor's `coverage/lcov.info`, not re-run) | 96.59% lines / 88.52% branches repo-wide; all three feature files above gate | PASS |
| `npm run build` | `npm run build` | `tsc --noEmit` + both esbuild bundles succeeded | PASS |

**Notes:**
No pre-existing failures unrelated to this work were observed. The file-size (Section 2.3) and terminal CRLF-normalization (see `code-review.2026-07-07T03-30.md`) findings are the only deviations from a clean run, and neither is a toolchain failure — both are code-quality/policy findings surfaced by manual inspection.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **File-size limit exceeded:** `extensions/drm-copilot/src/command-runtime.ts` is 669 lines (limit: 500). Pre-existing at 531 lines before this feature; this feature's diff adds 138 more lines without extracting the new `TerminalWriter` seam into its own module. Blocking finding; see `remediation-inputs.2026-07-07T03-30.md`.
- **Multi-line terminal output CRLF normalization:** `PseudoterminalTerminalWriter.write()` does not convert internal `\n` line breaks within a multi-line `body` to `\r\n`, which will produce a "staircase" rendering defect in the real integrated terminal for any tree with more than one line. Not caught by the existing test suite, which only exercises single-line bodies. Blocking finding; see `remediation-inputs.2026-07-07T03-30.md`.
- **Testing-framework policy mismatch:** `typescript.md` specifies Vitest; this extension's pre-existing toolchain uses Jest. Pre-existing, out-of-scope, not introduced by this feature.
- **No `quality-tiers.yml` at repo root** and no `.dependency-cruiser.cjs` for this extension: both are pre-existing repository-wide gaps, not introduced or worsened by this feature. The architecture boundary is instead enforced by a hand-written static-scan test (`module-boundary.test.ts`), consistent with the pattern already established in PR #323.

### Approved Exceptions

**None.** No exceptions were requested or granted for this feature.

### Removed/Skipped Tests

**None.** All planned tests (per `plan.2026-07-06T22-35.md` Phase 1, P1-T10 through P1-T17) were implemented; no test was removed.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **f13414a** - fix(subagent-tree): discover transcripts from user-global projects directory and render to terminal

### Files Modified

1. **`extensions/drm-copilot/src/command-runtime.ts`** (MODIFIED, +138 lines)
   - Added `getClaudeProjectsRoot(env?)`, the `TerminalWriter` interface, `PseudoterminalTerminalWriter` class, `SUBAGENT_TREE_TERMINAL_NAME` constant, and `createSubagentTreeTerminalWriter()` factory.
   - Now 669 lines; exceeds the 500-line policy limit (Blocking finding).

2. **`extensions/drm-copilot/src/subagent-tree-command.ts`** (MODIFIED)
   - Discovery now globs the resolved user-global Claude projects root narrowed to matched/worktree-sibling directories, instead of a repo-relative glob.
   - Zero-candidates error message now names the real resolved search location.
   - Rendered output now routed to an injected `TerminalWriter` (write + reveal) instead of `output.appendLine`/`output.show`.
   - `registerSubagentTreeCommand` options extended with optional `createFileSystem`/`createTerminalWriter` injection seams.

3. **`extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts`** (NEW, 64 lines)
   - Pure `encodeWorkspacePath` and `matchEncodedDirectories` functions; no `vscode` import.

4. **`extensions/drm-copilot/jest.config.cjs`** (MODIFIED)
   - Added per-file coverage thresholds for `workspace-encoding.ts` and `command-runtime.ts`.

5. **`extensions/drm-copilot/test/command-runtime.test.ts`** (NEW, 207 lines)
6. **`extensions/drm-copilot/test/subagent-tree-command.test.ts`** (MODIFIED, largely rewritten to use `InMemoryFileSystem`/`FakeTerminalWriter` instead of `node:fs` mocks)
7. **`extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`** (NEW, 120 lines)
8. **`extensions/drm-copilot/test/lib/subagent-tree/module-boundary.test.ts`** (NEW, 40 lines)

Additionally, 16 documentation/evidence files under `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/` (issue.md, plan, and Phase 0/1/2 evidence artifacts) were added; these are process artifacts, not production code.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Toolchain execution, test quality, and coverage are fully compliant and independently re-verified. Two Blocking findings — the `command-runtime.ts` file-size violation and the terminal CRLF-normalization defect — were identified by this audit's independent code inspection and were not caught by the plan's own Phase 1/Phase 2 verification. Both must be remediated before merge.

**Fail-closed reminder:** This audit does not mark the branch fully compliant or ready for merge given the two Blocking findings above.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PARTIAL Design Principles (reusability finding — see 2.2)
- **FAIL** Module & File Structure (500-line limit exceeded — see 2.3)
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For TypeScript:**
- PASS Tooling & Baseline (with a noted pre-existing Jest-vs-Vitest inconsistency, not attributable to this feature)
- PASS TypeScript Design & Typing
- PASS Error Handling

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For TypeScript (Jest):**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 1529/1529 tests passing (100%)
- PASS All new/modified functions and classes tested
- PASS 96.59% repo-wide line coverage / 88.52% branch coverage
- **FAIL** File organization: `command-runtime.ts` exceeds the 500-line limit
- PARTIAL Code quality checks: toolchain is clean, but two Blocking code-quality findings exist (see `code-review.2026-07-07T03-30.md`)
- PASS Test execution time: 2.405s (fast)

---

### Recommendation

**Needs revision.**

Before merge:
1. Extract the `TerminalWriter` interface, `PseudoterminalTerminalWriter` class, `SUBAGENT_TREE_TERMINAL_NAME` constant, and `createSubagentTreeTerminalWriter()` factory out of `command-runtime.ts` into a new, appropriately-sized module (e.g. `extensions/drm-copilot/src/terminal-writer.ts`), bringing `command-runtime.ts` back under the 500-line limit.
2. Normalize all line endings (not just the header/body boundary) to `\r\n` before writing to the `Pseudoterminal`, and add a unit test asserting correct CRLF conversion for a multi-line `body` value.

See `remediation-inputs.2026-07-07T03-30.md` for the full remediation task list.

---

## Appendix A: Test Inventory

### Complete Test List (new/modified tests only)

1. `getClaudeProjectsRoot` › uses CLAUDE_CONFIG_DIR's projects subfolder when it is set
2. `getClaudeProjectsRoot` › falls back to HOME/.claude/projects when CLAUDE_CONFIG_DIR is unset
3. `getClaudeProjectsRoot` › falls back to USERPROFILE when neither CLAUDE_CONFIG_DIR nor HOME is set
4. `getClaudeProjectsRoot` › treats a whitespace-only CLAUDE_CONFIG_DIR as unset and falls back to HOME
5. `getClaudeProjectsRoot` › throws when none of CLAUDE_CONFIG_DIR, HOME, or USERPROFILE is set
6. `createSubagentTreeTerminalWriter` › creates a single named terminal backed by a Pseudoterminal that emits header and body joined by \r\n
7. `createSubagentTreeTerminalWriter` › reveals the terminal via show()
8. `createSubagentTreeTerminalWriter` › reuses the same terminal across repeated writes while it remains open
9. `createSubagentTreeTerminalWriter` › creates a replacement terminal once the previous terminal has exited
10. `createSubagentTreeTerminalWriter` › does not fire pending content before the Pseudoterminal reports it is open
11. `encodeWorkspacePath` › replaces backslashes, forward slashes, and colons with hyphens
12. `encodeWorkspacePath` › encodes a forward-slash workspace path identically to a backslash one
13. `matchEncodedDirectories` › matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name
14. `matchEncodedDirectories` › includes a per-worktree sibling folder among the matched candidate directories
15. `matchEncodedDirectories` › includes a nested worktree-of-a-worktree sibling folder
16. `matchEncodedDirectories` › returns an empty array when no directory name matches
17. `drm-copilot showSubagentTree command` › resolves candidates from the user-global Claude projects directory rather than the workspace root
18. `drm-copilot showSubagentTree command` › auto-selects a single discovered root session without prompting
19. `drm-copilot showSubagentTree command` › prompts via showQuickPick among multiple candidates and renders the one selected
20. `drm-copilot showSubagentTree command` › excludes flattened /subagents/ transcripts from candidates
21. `drm-copilot showSubagentTree command` › names the real resolved user-global search location in the zero-candidates error message
22. `drm-copilot showSubagentTree command` › writes the header plus full formatTree output to the terminal seam and reveals it
23. `drm-copilot showSubagentTree command` › reuses the same terminal-writer instance across two consecutive invocations
24. `drm-copilot showSubagentTree command` › routes a discovery failure to the error path and does not write to the terminal seam
25. `drm-copilot showSubagentTree command` › routes a user-cancel selection to the output log and does not write to the terminal seam
26. `src/lib/subagent-tree pure-module boundary` › contains no `vscode` import statements in any source file

---

## Appendix B: Toolchain Commands Reference

**For TypeScript (`extensions/drm-copilot/`):**
```bash
# Formatting (mutating)
npm run format
# Formatting (check-only, used by this audit to avoid mutation)
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"

# Linting
npm run lint

# Type checking
npm run typecheck

# Testing
npm run test
npm run test:coverage

# Build
npm run build
```

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-07
**Policy Version:** Current (as of audit date)

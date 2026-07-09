# Policy Compliance Audit: subagent-tree-mcp-and-dropdown (Issue #334)

---

**Audit Date:** 2026-07-09
**Code Under Test:**

- TypeScript (extension, `extensions/drm-copilot/`): `src/lib/subagent-tree/quick-pick-labels.ts` (new), `src/lib/subagent-tree/session-transcript-resolver.ts` (new), `src/mcp-handlers/render-subagent-tree-handler.ts` (new), `src/mcp-tool-inputs-subagent-tree.ts` (new), `src/repo-automation-execute-script.ts` (new, extraction), `src/repo-automation-service-subagent-tree.ts` (new), `src/repo-automation-service.ts` (modified), `src/subagent-tree-command.ts` (modified), `src/lib/file-system.ts` (modified), `src/mcp-tools.ts` (modified), `src/mcp-repo-automation-tool-definitions.ts` (modified), `src/repo-automation-tool-names.ts` (modified), `jest.config.cjs` (modified); tests: `test/lib/subagent-tree/quick-pick-labels.test.ts` (new), `test/lib/subagent-tree/session-transcript-resolver.test.ts` (new), `test/repo-automation-render-subagent-tree.test.ts` (new), `test/subagent-tree-command.test.ts` (extended), `test/mcp-repo-automation-tool-definitions.test.ts` (extended), `test/mcp-server.test.ts` (extended)
- PowerShell: `.claude/hooks/persist-session-id.ps1` (new), `tests/scripts/claude-hooks/persist-session-id.Tests.ps1` (new), `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (modified), `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (modified)
- JSON: `.claude/settings.json` (modified)
- Markdown/docs: `.claude/skills/identify-session-id/SKILL.md` (new), `.claude/skills/show-my-agent-tree/SKILL.md` (new), feature-folder docs and evidence under `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/`

**Baseline:** `origin/main` @ `d5242b2d3dbb881a5d140da4ba5ed1662fb87209` (merge base). Head: `drm-copilot-wt-2026-07-09T09-18` @ `c215c87d8f0ba54ef10a69b5702977212c2ba464`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 19 files | 1611 tests | PASS 1611 pass, 0 fail | 96.58% lines, 88.56% branches | 96.64% lines, 88.62% branches | 100.0% lines (lowest new file), 77.78% branches (lowest new file) |
| PowerShell | 4 files | 1087 tests (14 new) | PASS 1087 pass, 0 fail | 93.67% lines (fixed coverage path list) | 93.67% lines (fixed coverage path list) | 87.04% command/line for the new hook |
| JSON | 1 file | N/A | PASS validation | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/ts-jest-coverage.2026-07-09T09-59.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (parsed independently by this review) and `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-ts-jest-coverage.2026-07-09T09-59.md`
- PowerShell baseline coverage artifact: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/baseline/ps-pester-coverage.2026-07-09T09-59.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (parsed independently by this review) plus `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-ps-test.2026-07-09T09-59.md` and `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/phase6-ps-test.2026-07-09T09-59.md`
- Per-language comparison summary: section 1.2.1 below and `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/coverage-delta.2026-07-09T09-59.md`

---

## Rejected Scope Narrowing

No scope narrowing was attempted by the caller. The delegation prompt requested the full feature-vs-base audit against merge base `d5242b2d3dbb881a5d140da4ba5ed1662fb87209` and left scope determination to this agent. The audit scope is the full branch diff `d5242b2..c215c87` (60 files).

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (no violations).
- Branch-diff scan: no files are written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All feature evidence lives at the canonical `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/<kind>/` paths.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred; no caller instruction supplied a non-canonical evidence path.

---

## Executive Summary

This audit covers the full branch diff for issue #334 (quick-pick display rework for `drm-copilot: Show Subagent Tree`, new MCP tool `render_subagent_tree`, SessionStart hook `persist-session-id.ps1`, and the `identify-session-id` / `show-my-agent-tree` skills). Work mode is `full-feature` (explicit marker in `issue.md`).

The reviewer independently re-ran the check-only toolchain at head `c215c87` on 2026-07-09T11-07: Prettier check, ESLint, tsc, the full Jest suite (137 suites / 1611 tests), and the new Pester suite (14 tests) all pass. Coverage was verified from the pre-existing executor artifacts (`extensions/drm-copilot/coverage/lcov.info`, `artifacts/pester/powershell-coverage.xml`) by direct parsing, and the parsed numbers match the executor evidence. Every new TypeScript production file meets the 85% line / 75% branch per-file gate; the new PowerShell hook measures 87.04% command/line coverage. No blocking findings were identified.

**Policy documents evaluated:**

- PASS `general-code-change.md`
- PASS `general-unit-test.md`

**Language-specific policies evaluated:**

- N/A Python (no Python files changed)
- PASS `powershell.md`
- PASS `typescript.md`, `typescript-suppressions.md`, `architecture-boundaries.md`
- PASS JSON: `.claude/settings.json` parses as strict JSON
- N/A Bash, C#

The `modified-workflow-needs-green-run` policy rule does not fire: the branch diff contains no paths under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (verified via `git diff --name-status d5242b2..HEAD`).

**Temporary artifacts cleanup:**

- PASS No temporary/one-time scripts remain in the diff; the working tree is clean at head.
- PASS All committed scripts (`persist-session-id.ps1`) carry a full Pester suite.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Jest suites use per-test in-memory fixtures (fake `FileSystem`/`FileTimes` objects constructed inside each test); Pester suite resets recorder state in `BeforeEach`. Full suite passes as a single run. |
| **Isolation** - Each test targets single behavior | PASS | One behavior per `it`/`It`; e.g. `quick-pick-labels.test.ts` splits truncation, timestamp rendering, ordering, tie-break, and mutation checks into separate cases. |
| **Fast Execution** - Tests complete quickly | PASS | Jest: 1611 tests in 1.87 s (reviewer run). Pester `persist-session-id.Tests.ps1`: 14 tests in 870 ms (reviewer run). |
| **Determinism** - Consistent results | PASS | Fixed epoch values injected through the `FileTimes` seam; no wall-clock reads in production or test code (grep for `Date.now`, `setTimeout`, `Math.random` across changed files matched only a documentation comment). |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive test names stating scenario and expected outcome; Arrange-Act-Assert layout throughout; Describe/Context/It grouping in Pester. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline (pre-development):** TypeScript 96.58% lines, 88.56% branches; PowerShell 93.67% lines (fixed coverage path list)<br>**Command:** `npm run test:coverage`; `mcp__drm-copilot__run_poshqc_test`<br>**Timestamp:** 2026-07-09 09:59 (`evidence/baseline/ts-jest-coverage.2026-07-09T09-59.md`, `evidence/baseline/ps-pester-coverage.2026-07-09T09-59.md`) |
| **No Coverage Regression** | PASS | **Post-change coverage:** TypeScript 96.64% lines, 88.62% branches (+0.06 pp / +0.06 pp); PowerShell aggregate 93.67% lines (unchanged). Reviewer independently parsed `coverage/lcov.info` (31877/32985 lines, 4056/4577 branches) and `artifacts/pester/powershell-coverage.xml` (LINE 1006 covered / 68 missed = 93.67%). No regression. |
| **New Code Coverage** | PASS | New TypeScript files: `quick-pick-labels.ts` 100%/94.4%, `session-transcript-resolver.ts` 100%/85.7%, `render-subagent-tree-handler.ts` 100%/100%, `mcp-tool-inputs-subagent-tree.ts` 100%/100%, `repo-automation-service-subagent-tree.ts` 100%/100%, `repo-automation-execute-script.ts` 100%/77.8% (lines/branches, from `lcov.info`). New PowerShell hook: 87.04% command/line (47/54 commands; `evidence/qa-gates/phase6-ps-test.2026-07-09T09-59.md`). All meet the uniform 85/75 gate. |
| **Comprehensive Coverage** | PASS | Uncovered hook lines are 124 and 149-153 only (default `[Console]::In.ReadToEnd()` reader and the guarded script entry body) — the sanctioned thinnest-possible host-bound wiring; all decision, write, and payload logic is covered. |
| **Positive Flows** - Valid inputs | PASS | Valid session id resolution (exact directory and `-wt-` sibling), quick-pick label composition, env-file append path, state-file write path. |
| **Negative Flows** - Invalid inputs | PASS | Malformed session ids (path separators, `..`, empty, over-length, wrong charset) rejected with the validation rule named; malformed/empty hook payloads produce no write; `session_id` argument absent throws. |
| **Edge Cases** - Boundary conditions | PASS | `truncateLeftAnchored` at exactly max, max 1, max 0, empty string; epoch 0 boundary; equal-timestamp tie-break; two-`undefined` tie-break; empty candidate list. |
| **Error Handling** - Error paths | PASS | Unknown id names searched directories (`ok:false`); stat failure yields `undefined` mtime and the prompt still renders; stdin read failure falls back to `CLAUDE_HOOK_INPUT`. |
| **Concurrency** - If applicable | N/A | No concurrent behavior introduced; all new code is synchronous pure logic plus thin async dispatch. |
| **State Transitions** - If applicable | N/A | No stateful component introduced; the hook is a single-shot decision function. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.58% lines / 88.56% branches -> Post-change: 96.64% lines / 88.62% branches. Change: +0.06 pp lines, +0.06 pp branches (no regression). New/changed-code coverage: 100.0% lines on every new file (lowest new-file branch value 77.78%, above the 75% gate). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`; `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/final-ts-jest-coverage.2026-07-09T09-59.md`.
- PowerShell: Baseline: 93.67% lines -> Post-change: 93.67% lines. Change: 0.00 pp (aggregate over the fixed PoshQC coverage path list; +14 new tests). New/changed-code coverage: 87.04% command/line for `.claude/hooks/persist-session-id.ps1` via a dedicated Invoke-Pester coverage run. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`; `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/phase6-ps-test.2026-07-09T09-59.md`.
- JSON: `N/A - config file only` (`.claude/settings.json`; validated by strict JSON parse). Disposition: N/A.

Coverage verdicts: TypeScript PASS; PowerShell PASS. Both languages with changed files carry explicit verdicts backed by pre-existing artifacts. Note (documented limitation, not a gap in verdict): the repository's PowerShell coverage tooling (Pester CoverageGutters/JaCoCo) emits line/command counters only and no branch counter, consistent with the recorded baseline; the 85% line gate is the authoritative PowerShell numeric check.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Jest `expect(...).toBe/toEqual` with exact expected literals (e.g. exact label strings, exact error-message regexes); Pester `Should -Be` with exact values, `Should -Invoke -Times N -Exactly`. |
| **Arrange-Act-Assert Pattern** | PASS | All inspected tests follow AAA (fixture construction, single call, assertions); Pester tests separate arrange payload, act call, assert decision/recorders. |
| **Document Intent** | PASS | Test names state scenario and expected outcome; recorder rationale documented in `BeforeEach` comment of the Pester suite. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or external-process use. Filesystem access is faked: in-memory `FileSystem`/`FileTimes` fakes in TypeScript; injected scriptblock recorders and Pester cmdlet mocks (`Mock Add-Content` / `Mock Set-Content` / `Mock New-Item` / `Mock Test-Path`) in PowerShell. |
| **Use Mocks/Stubs** | PASS | Mocked at seams only: `FileTimes` seam, `FileSystem` seam, cmdlet mocks for default writers. No executable is mocked directly. |
| **Environment Stability** | PASS | No temporary files created by any new test (verified by inspection of `persist-session-id.Tests.ps1` and the new Jest suites); no reliance on mutable global state. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document, together with `code-review.2026-07-09T11-07.md` and `feature-audit.2026-07-09T11-07.md`, constitutes the required pre-PR review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #334; `issue.md`, `spec.md`, `user-story.md` in the feature folder define the objective. |
| **Read existing change plans** | PASS | Research doc `research/2026-07-09T09-50-subagent-tree-mcp-and-dropdown-334-research.md` and plan `plan.2026-07-09T10-30.md` present and referenced by the spec. |
| **Document the plan** | PASS | `plan.2026-07-09T10-30.md` (193 lines) plus spec Implementation Strategy section. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Pure formatting/ordering logic isolated in `quick-pick-labels.ts`; resolver is a single linear function; handler is a 2-line delegation. |
| **Reusability** | PASS | Reuses existing `buildSubagentTree`/`formatTree`, `encodeWorkspacePath`/`matchEncodedDirectories`, `normalizeWorkspaceRoot`/`normalizeRequiredText`, and the established `*-service-call` extraction precedent. |
| **Extensibility** | PASS | `FileTimes` seam is a one-method interface with injected fakes; `rendered_tree`/`renderedTree` are additive optional result fields; tool registered through the existing definitions/dispatch tables. |
| **Separation of concerns** | PASS | Host-neutral logic in `src/lib/**` (no `vscode`/`node:fs` imports — verified by grep); host wiring confined to `subagent-tree-command.ts` and `file-system.ts` (`RealFileTimes`, the sanctioned exception location). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | One concern per module: labels, resolver, input resolution, handler, service-call body, script-execution extraction. |
| **Under 500 lines** | PASS | Largest changed files: `test/subagent-tree-command.test.ts` 499, `src/repo-automation-service.ts` 487, `src/lib/file-system.ts` 364 (reviewer `wc -l`). All under 500. |
| **Public vs internal** | PASS | `compareCandidates`/`padTwo` are module-private; exported surface matches the spec API section exactly. |
| **No circular dependencies** | PASS | New modules depend only downward (lib -> lib; service -> lib; handler -> inputs + service); `repo-automation-execute-script.ts` was extracted specifically to keep host-bound `command-runtime` out of the host-neutral support module. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `truncateLeftAnchored`, `formatLastActivityTimestamp`, `buildRootSessionPickEntries`, `resolveSessionTranscriptPath`, `Get-PersistSessionIdDecision` (approved verb). kebab-case filenames; camelCase/PascalCase respected. |
| **Docs/docstrings** | PASS | Every new exported symbol carries a JSDoc block with purpose/params/returns/throws; the hook carries comment-based help (`.SYNOPSIS`/`.DESCRIPTION`/`.NOTES`). |
| **Comment why, not what** | PASS | Comments explain rationale (e.g. why validation precedes filesystem access, why the extraction module exists, why coverage-path entries were added to the runsettings). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `npx prettier --check src test jest.config.cjs` (reviewer, 2026-07-09T11-07)<br>**Result:** "All matched files use Prettier code style!"; PoshQC format executor run exit 0 (`final-ps-format.2026-07-09T09-59.md`). |
| **2. Linting** | PASS | **Command:** `npm run lint` (reviewer)<br>**Result:** ESLint clean, zero findings; PoshQC analyze full-workspace executor run exit 0 (`final-ps-analyze.2026-07-09T09-59.md`). |
| **3. Type checking** | PASS | **Command:** `npm run typecheck` (reviewer)<br>**Result:** `tsc -p ./ --noEmit` clean; N/A for PowerShell. |
| **4. Testing** | PASS | **Command:** `npm run test` and `Invoke-Pester -Path tests/scripts/claude-hooks/persist-session-id.Tests.ps1` (reviewer)<br>**Result:** 1611/1611 Jest tests pass; 14/14 Pester tests pass. Executor full-workspace Pester run: 1087 tests, 0 failures. |
| **Full toolchain loop** | PASS | Executor evidence records a clean single pass (phase gates plus final QA at 2026-07-09T09-59); reviewer re-run at head confirms format, lint, typecheck, and tests all pass in one pass. |
| **Explicit reporting** | PASS | Commands and results recorded in this audit and in the 22 evidence files under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commit `c215c87` "feat(subagent-tree): add render_subagent_tree MCP tool and rework quick-pick UX"; section 9 below. |
| **Design choices explained** | PASS | Spec Design Decisions DD-1..DD-5 (FileTimes seam, session-id-only input, reply-surface output, Jest precedent, provisioned `CLAUDE_SESSION_ID`). |
| **Update supporting documents** | PASS | Two new skills, settings wiring, feature-folder docs, runsettings coverage-path comments. |
| **Provide next steps** | PASS | Remaining step is PR creation after this review; see Compliance Verdict. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` (scan_folders: `.claude/hooks`, `tests/scripts/claude-hooks`)<br>**Result:** exit 0, no changes (`final-ps-format.2026-07-09T09-59.md`). |
| **Linting with PSScriptAnalyzer** | PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze` (full workspace)<br>**Result:** exit 0, zero findings (`final-ps-analyze.2026-07-09T09-59.md`). |
| **Fix all findings** | PASS | No findings recorded; clean single pass per evidence. |
| **PowerShell 7+ compatible** | PASS | Hook `.NOTES` declares PowerShell 7+; no version-gated syntax; analyzer settings enforce compatibility. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | PASS | All three functions use `[CmdletBinding()]` with `[OutputType()]`; script-level `[CmdletBinding()] param()`. |
| **Parameter validation** | PASS | `[Parameter(Mandatory)]` on `StateFilePath`; `[AllowNull()]`/`[AllowEmptyString()]` on the fallback payload; injectable scriptblock seams with safe defaults (repo seam pattern #2). |
| **Avoid global state** | PASS | No global/script-scope mutation in production code; data passed explicitly. |
| **Error handling** | PASS | Unparseable JSON handled with a narrow try/catch that logs via `Write-Verbose` and returns the documented `none` decision — the intentional never-block-session-start contract; no `Invoke-Expression`; explicit `exit 0`. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | PASS | Hook 153 lines; test 200 lines. |
| **Approved verbs** | PASS | `Get-PersistSessionIdDecision`, `Invoke-PersistSessionIdHook`, `Read-HookPayload` — all approved verbs. |
| **Comment why** | PASS | Comments explain the persistence channels, the dot-source guard, and the no-write contract. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | PASS | Executor PoshQC format run exit 0 (2026-07-09T09-59). |
| **Step 2: Analyze** | PASS | Executor PoshQC analyze runs (scoped and full workspace) exit 0. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | PASS | Executor `run_poshqc_test` full workspace: 1087 tests, 0 failures; reviewer re-ran the new suite: 14/14 pass. |
| **Rerun loop if needed** | PASS | Evidence records a clean single pass (format -> analyze -> test). |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting (Prettier)** | PASS | `npx prettier --check src test jest.config.cjs` clean (reviewer run). |
| **Linting (ESLint)** | PASS | `npm run lint` clean (reviewer run); zero suppressions in the diff (grep for `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck` across changed files: none). |
| **Type checking (tsc)** | PASS | `npm run typecheck` clean (reviewer run); no `any`, no type assertions in new code; `unknown` used at the MCP boundary and narrowed via `asToolArgumentObject`. |
| **Testing (Jest)** | PASS | 1611/1611 pass (reviewer run). Framework note: the extension's wired framework is Jest with tests under `extensions/drm-copilot/test/**`, a recorded deviation from the Vitest/`tests/` wording in `.claude/rules/typescript.md`; this feature follows the extension's established configuration (spec DD-4, 137 pre-existing suites). See section 8. |
| **ES modules / naming / kebab-case** | PASS | ES module syntax throughout; kebab-case filenames; no `I`-prefixed interfaces. |
| **No new runtime dependencies** | PASS | `git diff main -- extensions/drm-copilot/package.json packages/mcp-server/package.json` empty (`dependency-check.2026-07-09T09-59.md`); reviewer confirmed package.json files unchanged in the name-status diff. |
| **Architecture boundaries** | PASS | New `src/lib/**` modules import neither `vscode` nor `node:fs` (reviewer grep clean); `RealFileTimes` lives in `file-system.ts`, the sanctioned host-bound location. No dependency-cruiser config exists in the extension; host-neutrality enforced by convention and this review, per spec constraint. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | PASS | `.claude/settings.json` diff is additive entries in existing arrays/objects, consistent with existing style; strict JSON parse succeeds (`python -c "json.load(...)"`, reviewer run). |
| **Schema validation** | N/A | `.claude/settings.json` is not a `$schema`-governed repo JSON file. |
| **Required $schema** | N/A | Not applicable to `.claude/settings.json`. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | PASS | Strict parse succeeds; no comments or trailing commas. |
| **Deterministic key order** | PASS | New entries follow the file's existing ordering conventions (hook block added alongside existing hook events; allow-list entries appended in the established groupings). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | PASS | `BeforeAll`/`BeforeEach`, `Describe`/`Context`/`It`, modern `Should` syntax, `Should -Invoke` cmdlet-mock assertions. |
| **Use PoshQC Configuration** | PASS | Full-workspace run through `mcp__drm-copilot__run_poshqc_test` (config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`); the new hook was added to the coverage `Path` list in both the repo and the bundled runsettings so it is measured going forward. |
| **PowerShell 7+ Compatible** | PASS | No version-gated features; suite passes under pwsh 7 (reviewer run). |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | PASS | 14 tests across four contexts: decision logic (5), hook invocation (4), payload reading (3), default writers (2). |
| **Test Behavior Over Implementation** | PASS | Asserts decision records, written lines, and cmdlet invocation counts — the observable contract. |
| **Mocking Used Sparingly** | PASS | Injected recorders for the writer seams; cmdlet mocks (`Add-Content`, `Set-Content`, `New-Item`, `Test-Path`) only to cover the default writer bodies without disk access. No executable mocked directly. |
| **Organization** | PASS | **Test file:** `tests/scripts/claude-hooks/persist-session-id.Tests.ps1`<br>**Code file:** `.claude/hooks/persist-session-id.ps1`<br>Mirrors the existing claude-hooks test convention (same directory as the other hook suites). |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | PASS | `persist-session-id.Tests.ps1`. |
| **Describe/Context/It Structure** | PASS | 1 Describe, 4 Contexts, 14 Its. |
| **Logical Grouping** | PASS | Grouped by function under test plus a default-writer context. |
| **Docstrings/Comments** | PASS | Self-documenting It names; `.SYNOPSIS` header; recorder-purpose comment. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | PASS | Executor `run_poshqc_test` full workspace exit 0 (1087 tests). |
| **No Alternative Test Runners** | PASS | Only Pester; the dedicated `Invoke-Pester` coverage run for the new hook is the same framework, invoked directly solely to produce per-file numeric coverage. |

### Section 4E: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | PASS (recorded deviation) | Jest (`jest.config.cjs`, ts-jest); the repository rule names Vitest, but the extension's wired, established framework is Jest — deviation recorded in section 8 and spec DD-4. `*.test.ts` naming followed. |
| **Coverage expectation** | PASS | Per-file `coverageThreshold` entries at 85 lines / 75 branches added for every new production file; `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]` — no production exclusion (only declaration files with no executable behavior are omitted, a permitted clarification). |
| **Test structure** | PASS | AAA structure; one behavior per test; fakes injected at seams; no host runtime required. |
| **No external dependencies** | PASS | In-memory `FileSystem`/`FileTimes` fixtures; no temporary files; no network. |
| **Determinism infrastructure** | PASS | Fixed epoch inputs; no fake timers needed (no timer usage); no `Date.now()` outside seams. |

---

## 5. Test Coverage Detail

### quick-pick-labels.ts (20 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| truncateLeftAnchored: unchanged when shorter / exactly max | Positive/Edge | 34-39 | PASS |
| truncateLeftAnchored: ellipsis + tail when longer; maxLength 1 and 0; empty string | Edge Case | 34-39 | PASS |
| formatLastActivityTimestamp: known epoch, undefined -> unknown, epoch 0 | Positive/Negative/Edge | 54-68 | PASS |
| buildRootSessionPickEntries: ordering, undefined-last, tie-breaks, label/detail composition, empty list, no mutation | Positive/Edge | 94-133 | PASS |

**Coverage:** 100.0% lines, 94.4% branches (133/133 lines, 17/18 branches).

**Not covered:** one branch arm in the tie-break comparator (equivalent-path equality path); no behavioral gap.

### session-transcript-resolver.ts (10 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Malformed ids rejected before filesystem access (separators, `..`, empty, over-length, charset) | Negative | 50-54 | PASS |
| Exact-match directory, `-wt-` sibling, case-insensitive match, deterministic first hit | Positive | 56-67 | PASS |
| Not-found error naming searched directories | Error Handling | 69-77 | PASS |

**Coverage:** 100.0% lines, 85.7% branches.

**Not covered:** None material.

### MCP layer: inputs, handler, service call, dispatch (10 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| ok:true with rendered_tree and summary for a valid id | Positive | service-call full body | PASS |
| Dispatch reachability; workspace_root echo/fallback | Positive | mcp-tools case | PASS |
| ok:false naming searched directory (unknown id) | Error Handling | failure path | PASS |
| ok:false naming validation rule; no filesystem access (malformed id) | Negative | validation path | PASS |
| Tool advertised with required session_id, optional workspace_root, additionalProperties false | Positive | definitions | PASS |
| resolveRenderSubagentTreeToolInput: absent session_id throws; normalization; fallback root | Negative/Positive | 31-43 | PASS |

**Coverage:** 100% lines on all four new MCP-layer files.

**Not covered:** None.

### subagent-tree-command.ts (16 tests, extended suite)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Ordered entries with formatted labels and matchOnDetail | Positive | selectRootSession | PASS |
| Selection maps to full path; single-candidate bypass (with and without injected FileTimes) | Positive | selection paths | PASS |
| Unreadable mtime sorts last as `unknown`; prompt still renders | Error Handling | discovery/stat path | PASS |
| Discovery failure and user-cancel routes | Error Handling | error paths | PASS |

**Coverage:** 100.0% lines, 95.5% branches.

**Not covered:** None material.

### persist-session-id.ps1 (14 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| Env-file channel chosen/appended (`CLAUDE_SESSION_ID=<id>`) | Positive | 41-67, 101-104 | PASS |
| State-file channel chosen/written with directory ensure | Positive | 105-111 | PASS |
| Malformed JSON, empty input, absent session_id -> action none, no write | Negative | 43-61, 112-114 | PASS |
| Read-HookPayload: stdin, empty-stdin fallback, throwing-stdin fallback | Error Handling | 120-143 | PASS |
| Default writers via cmdlet mocks (Add-Content / Set-Content + New-Item) | Positive | 81-96 | PASS |

**Coverage:** 87.04% command/line (47/54 commands).

**Not covered:** lines 124, 149-153 — default `[Console]::In.ReadToEnd()` reader and the guarded host entry body; sanctioned thin host-bound wiring per `general-unit-test.md` refactoring guidance.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 1625 (1611 Jest + 14 Pester new-suite; full-workspace Pester 1087) | PASS |
| Tests Passed | 1625 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | Jest 1.87 s; new Pester suite 0.87 s | PASS Fast |
| Average Time per Test | ~1.2 ms (Jest) | PASS Fast |
| Discovery Time | Pester discovery 144 ms (14 tests) | PASS |
| Functions/Classes Tested | All new exported functions/classes tested (12/12) | PASS |
| Test File Size | Largest 499 lines (`subagent-tree-command.test.ts`) | PASS Maintainable |
| Code Coverage | TS 96.64% lines / 88.62% branches; PS 93.67% lines (aggregate), hook 87.04% | PASS |

---

## 7. Code Quality Checks

**For TypeScript (from `extensions/drm-copilot/`):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check src test jest.config.cjs` | All files use Prettier code style (reviewer, 2026-07-09T11-07) | PASS |
| ESLint | `npm run lint` | Clean, zero findings (reviewer) | PASS |
| tsc | `npm run typecheck` | Clean (reviewer) | PASS |
| Jest | `npm run test` | 137 suites / 1611 tests pass (reviewer) | PASS |
| Bundles | `npm run build` (extension) and `npm run build` (mcp-server) | exit 0 (executor evidence `bundle-extension` / `bundle-mcp-server` 2026-07-09T09-59) | PASS |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | exit 0 (executor evidence 2026-07-09T09-59) | PASS |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` (full workspace) | exit 0, zero findings (executor evidence) | PASS |
| Pester Tests | `mcp__drm-copilot__run_poshqc_test` (full workspace); reviewer re-ran the new suite via `Invoke-Pester` | 1087 tests 0 failures (executor); 14/14 pass (reviewer) | PASS |

**Other checks:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |
| settings.json strict parse | `python -c "import json; json.load(open('.claude/settings.json'))"` | valid | PASS |
| Host neutrality | grep for `vscode`/`node:fs` imports in new `src/lib/**` modules | zero matches | PASS |
| modified-workflow-needs-green-run trigger paths | `git diff --name-status d5242b2..HEAD` | no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths; rule not triggered | PASS |

**Notes:**
No pre-existing failures were encountered. The MCP PoshQC tools were exercised by the executor (evidence exit codes 0); the reviewer environment re-ran the equivalent direct commands where the MCP surface was not invocable.

---

## 8. Gaps and Exceptions

### Identified Gaps

**None blocking.** Two documented, non-blocking limitations:

1. **PowerShell branch coverage counter**: the repository's Pester CoverageGutters/JaCoCo output emits line/command counters only and no branch counter, consistent with the recorded P0-T7 baseline. The uniform 75% branch gate therefore cannot be numerically evaluated for PowerShell with the current tooling; the 85% line gate (met at 87.04% for the new hook, 93.67% aggregate) is the authoritative numeric PowerShell check. This is a toolchain limitation that predates this feature, not a coverage exclusion.
2. **Installed-bundle coverage denominator**: the MCP `run_poshqc_test` tool reads the installed extension bundle's runsettings, whose fixed coverage `Path` list predates this feature, so `artifacts/pester/powershell-coverage.xml` does not include the new hook as a sourcefile. Per-file numeric coverage for the hook was produced by a dedicated `Invoke-Pester` coverage run recorded in `evidence/qa-gates/phase6-ps-test.2026-07-09T09-59.md`, and the hook was added to the coverage `Path` in both the repo and the bundled runsettings so future runs measure it.

### Approved Exceptions

1. **Jest instead of Vitest; tests under `extensions/drm-copilot/test/**` instead of a `tests/` tree**: `.claude/rules/typescript.md` names Vitest and the universal test-location rule names a `tests/` mirror, but the extension's wired, established toolchain is Jest with 137 suites under `test/**`. The spec records this as a governing-precedent deviation (Constraints, Risks #3, DD-4). Following the established configuration avoids an out-of-scope framework migration.
2. **Interface-only threshold omission**: `src/lib/subagent-tree/types.ts` has no per-file threshold entry because it consists solely of interface declarations (0% executable coverage under the v8 provider). It remains inside `collectCoverageFrom` (not excluded from measurement); this matches the explicit interface-only clarification in `general-unit-test.md`.

### Removed/Skipped Tests

**None.** All planned tests implemented; full-workspace Pester reports 9 pre-existing disabled tests unrelated to this feature (same count in baseline).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **c215c87** - feat(subagent-tree): add render_subagent_tree MCP tool and rework quick-pick UX

### Files Modified

1. **extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts** (NEW) — pure quick-pick label/ordering module (`truncateLeftAnchored`, `formatLastActivityTimestamp`, `buildRootSessionPickEntries`, `MAX_PATH_LABEL_LENGTH = 60`).
2. **extensions/drm-copilot/src/lib/subagent-tree/session-transcript-resolver.ts** (NEW) — host-neutral session-id validation (`^[0-9A-Za-z-]{8,64}$`) and id-to-transcript resolution across `-wt-` siblings.
3. **extensions/drm-copilot/src/lib/file-system.ts** (MODIFIED) — `FileTimes` seam and `RealFileTimes` (statSync mtimeMs, failure -> `undefined`).
4. **extensions/drm-copilot/src/subagent-tree-command.ts** (MODIFIED) — threads `FileTimes` through discovery; quick-pick consumes `RootSessionPickEntry[]` with `matchOnDetail: true`; single-candidate bypass retained.
5. **extensions/drm-copilot/src/mcp-tool-inputs-subagent-tree.ts**, **src/mcp-handlers/render-subagent-tree-handler.ts**, **src/repo-automation-service-subagent-tree.ts**, **src/repo-automation-execute-script.ts** (NEW) — MCP input resolver, thin handler, service-call body, and the `executeScript` extraction that keeps `repo-automation-service.ts` under 500 lines.
6. **extensions/drm-copilot/src/repo-automation-service.ts**, **src/mcp-tools.ts**, **src/mcp-repo-automation-tool-definitions.ts**, **src/repo-automation-tool-names.ts** (MODIFIED) — `renderSubagentTree` service method, `rendered_tree` result mapping, tool definition (required `session_id`, optional `workspace_root`, `additionalProperties: false`), dispatch case, tool-name registration.
7. **extensions/drm-copilot/jest.config.cjs** (MODIFIED) — per-file 85/75 threshold entries for all new production files.
8. **.claude/hooks/persist-session-id.ps1** (NEW) + **tests/scripts/claude-hooks/persist-session-id.Tests.ps1** (NEW) — SessionStart hook persisting the session id via `CLAUDE_ENV_FILE` or `.claude/state/current-session-id`; always exits 0.
9. **.claude/skills/identify-session-id/SKILL.md**, **.claude/skills/show-my-agent-tree/SKILL.md** (NEW) — session self-identification fallback chain and the reply-surface tree-rendering flow.
10. **.claude/settings.json** (MODIFIED) — SessionStart hook entry; allow-list additions for the MCP tool and both skills.
11. **scripts/powershell/PoshQC/settings/pester.runsettings.psd1** and **extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1** (MODIFIED) — new hook added to the coverage `Path` list.
12. **docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/** (NEW) — issue/spec/user-story/plan/research plus 29 evidence files.
13. **Test extensions** — `test/mcp-repo-automation-tool-definitions.test.ts`, `test/mcp-server.test.ts`, `test/subagent-tree-command.test.ts`.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All toolchain stages pass at head `c215c87` (reviewer re-run for TypeScript format/lint/typecheck/tests and the new Pester suite; executor evidence for PoshQC format/analyze/full test and bundles). Coverage evidence is numeric, present for both languages with changed files, meets every uniform-tier threshold, and shows no regression. No blocking findings.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: issue/spec/plan/research all present.
- PASS Design Principles: pure modules, thin wiring, seam-based I/O.
- PASS Module & File Structure: all files under 500 lines; cohesive modules.
- PASS Naming, Docs, Comments: full JSDoc/comment-based help; rationale comments.
- PASS Toolchain Execution: clean single pass, independently re-verified.
- PASS Summarize & Document: spec DD-1..DD-5, evidence set, this audit.

#### Language-Specific Code Change Policy (Section 3)

**For TypeScript:**
- PASS Tooling & Baseline: Prettier/ESLint/tsc/Jest all clean.
- PASS Design & Typing: no `any`, no assertions, no suppressions.
- PASS Architecture: host-neutral lib modules verified by grep.

**For PowerShell:**
- PASS Tooling & Baseline: PoshQC format/analyze/test exit 0.
- PASS PowerShell Design & Safety: advanced functions, validation attributes, seam injection, no Invoke-Expression.
- PASS Structure & Naming: approved verbs, 153 lines.
- PASS Toolchain: clean single pass.

#### General Unit Test Policy (Section 1)
- PASS Core Principles: independent, isolated, fast, deterministic, readable.
- PASS Coverage & Scenarios: numeric baseline/post-change/new-code coverage, all gates met.
- PASS Test Structure: AAA, exact assertions.
- PASS External Dependencies: seam fakes and cmdlet mocks only; no temporary files.
- PASS Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)

**For TypeScript:**
- PASS Framework & Scope: Jest per recorded deviation; per-file 85/75 gates enforced in config.
- PASS Test Style & Structure: focused, behavior-oriented.
- PASS Naming & Readability: descriptive `it` names.
- PASS Toolchain: 1611/1611.

**For PowerShell:**
- PASS Framework & Scope: Pester v5 via PoshQC; hook added to coverage denominator.
- PASS Test Style & Structure: recorders + cmdlet mocks at seams.
- PASS Naming & Readability: Describe/Context/It, self-documenting names.
- PASS Toolchain: 1087/1087 (workspace), 14/14 (new suite).

### Metrics Summary

- PASS 1611/1611 Jest tests passing (100%)
- PASS 1087/1087 workspace Pester tests passing; 14/14 new-suite tests passing
- PASS TypeScript 96.64% line / 88.62% branch coverage (no regression from 96.58/88.56)
- PASS PowerShell 93.67% aggregate line coverage; new hook 87.04% command/line
- PASS All new files meet per-file 85/75 gates
- PASS All code quality checks passing
- PASS Test execution time: Jest 1.87 s, Pester new suite 0.87 s (fast)

### Recommendation

**Ready for merge** (from a policy-compliance standpoint). No remediation required. Proceed to PR creation via the standard flow.

---

## Appendix A: Test Inventory

New and extended tests introduced by this branch (pre-existing suites omitted; full inventory is the 137 Jest suites plus the workspace Pester run):

1. truncateLeftAnchored › returns the value unchanged when shorter than the maximum
2. truncateLeftAnchored › returns the value unchanged when exactly the maximum length
3. truncateLeftAnchored › left-truncates with an ellipsis when longer than the maximum, preserving the tail
4. truncateLeftAnchored › degenerates to a single ellipsis glyph for a maxLength of 1
5. truncateLeftAnchored › degenerates to a single ellipsis glyph for a maxLength of 0
6. truncateLeftAnchored › returns an empty string unchanged
7. truncateLeftAnchored › exposes the module label-length constant
8. formatLastActivityTimestamp › renders a known epoch as an exact yyyy-MM-dd HH:mm UTC string
9. formatLastActivityTimestamp › renders undefined as the literal 'unknown'
10. formatLastActivityTimestamp › renders the epoch 0 boundary as 1970-01-01 00:00
11. buildRootSessionPickEntries › orders entries most-recent-first
12. buildRootSessionPickEntries › sorts candidates with an undefined mtime last
13. buildRootSessionPickEntries › breaks equal-timestamp ties by path ascending
14. buildRootSessionPickEntries › breaks ties between two unreadable-mtime candidates by path ascending
15. buildRootSessionPickEntries › composes the label with the timestamp first, then the truncated tail
16. buildRootSessionPickEntries › sets detail equal to the full absolute path even when the label is truncated
17. buildRootSessionPickEntries › returns an empty array for an empty candidate list
18. buildRootSessionPickEntries › does not mutate the input candidate array
19. resolveSessionTranscriptPath — validation › (malformed-id rejection cases: separators, `..`, empty, over-length, charset)
20. resolveSessionTranscriptPath — resolution › resolves the transcript in the exact-match encoded directory
21. resolveSessionTranscriptPath — resolution › resolves the transcript in a -wt- worktree sibling directory
22. resolveSessionTranscriptPath — resolution › matches encoded directories case-insensitively
23. resolveSessionTranscriptPath — resolution › returns the first matching directory deterministically when several contain the transcript
24. resolveSessionTranscriptPath — resolution › throws a not-found error naming the searched directories for a valid but unknown id
25. render_subagent_tree service + dispatch › returns ok:true with rendered_tree and a summary naming the session id and transcript path for a valid id
26. render_subagent_tree service + dispatch › is reachable through dispatchRepoAutomationTool and echoes the requested workspace root
27. render_subagent_tree service + dispatch › returns ok:false naming the searched directory for a valid but unknown id
28. render_subagent_tree service + dispatch › returns ok:false naming the validation rule for a malformed id and never touches the filesystem
29. listRepoAutomationTools advertisement › advertises render_subagent_tree with required session_id and optional workspace_root
30. resolveRenderSubagentTreeToolInput › throws when session_id is missing
31. resolveRenderSubagentTreeToolInput › normalizes a present session_id and workspace_root
32. resolveRenderSubagentTreeToolInput › falls back to the provided workspace root when workspace_root is omitted
33. drm-copilot showSubagentTree command › shows quick-pick entries ordered most-recent-first with formatted timestamp labels and matchOnDetail
34. drm-copilot showSubagentTree command › maps the selected quick-pick entry back to its full transcript path
35. drm-copilot showSubagentTree command › auto-selects a single candidate without prompting even when a FileTimes is injected
36. drm-copilot showSubagentTree command › keeps the prompt working when one candidate's mtime is unreadable, sorting it last as 'unknown'
37. persist-session-id.ps1 › Get-PersistSessionIdDecision › chooses the env-file channel when CLAUDE_ENV_FILE is set
38. persist-session-id.ps1 › Get-PersistSessionIdDecision › chooses the state-file channel when CLAUDE_ENV_FILE is unset
39. persist-session-id.ps1 › Get-PersistSessionIdDecision › returns action none for malformed JSON
40. persist-session-id.ps1 › Get-PersistSessionIdDecision › returns action none for empty input
41. persist-session-id.ps1 › Get-PersistSessionIdDecision › returns action none when session_id is absent from the payload
42. persist-session-id.ps1 › Invoke-PersistSessionIdHook › appends CLAUDE_SESSION_ID=<id> to the env file when CLAUDE_ENV_FILE is set
43. persist-session-id.ps1 › Invoke-PersistSessionIdHook › writes the id to the state file (ensuring its directory) when CLAUDE_ENV_FILE is unset
44. persist-session-id.ps1 › Invoke-PersistSessionIdHook › performs no write on malformed JSON
45. persist-session-id.ps1 › Invoke-PersistSessionIdHook › performs no write on empty input
46. persist-session-id.ps1 › Read-HookPayload › returns the standard-input payload when present
47. persist-session-id.ps1 › Read-HookPayload › falls back to CLAUDE_HOOK_INPUT when standard input is empty
48. persist-session-id.ps1 › Read-HookPayload › falls back to CLAUDE_HOOK_INPUT when reading standard input throws
49. persist-session-id.ps1 › default writers › appends the session line via Add-Content by default when CLAUDE_ENV_FILE is set
50. persist-session-id.ps1 › default writers › writes via Set-Content and creates the directory via New-Item by default when CLAUDE_ENV_FILE is unset

---

## Appendix B: Toolchain Commands Reference

**For TypeScript (from `extensions/drm-copilot/`):**
```bash
# Formatting (check-only)
npx prettier --check src test jest.config.cjs

# Linting
npm run lint

# Type checking
npm run typecheck

# Testing
npm run test

# Coverage
npm run test:coverage   # writes coverage/lcov.info
```

**For PowerShell:**
```powershell
# Formatting
mcp__drm-copilot__run_poshqc_format   # or Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root .

# Linting
mcp__drm-copilot__run_poshqc_analyze  # or Invoke-PoshQCAnalyze -Root .

# Testing (workspace, with coverage artifact at artifacts/pester/powershell-coverage.xml)
mcp__drm-copilot__run_poshqc_test     # or Invoke-PoshQCTest -Root .

# New-hook scoped suite (reviewer verification)
pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/persist-session-id.Tests.ps1"
```

**Other:**
```bash
# Evidence-location compliance
python scripts/dev_tools/validate_evidence_locations.py --root .

# Branch scope
git diff --name-status d5242b2d3dbb881a5d140da4ba5ed1662fb87209..HEAD
```

**Template provenance note:** this artifact was created from the bundled policy-audit template asset at `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the exact source file that the MCP asset resolver copies for selector `template`; the MCP tool surface itself could not be invoked from this review environment, so the byte-identical bundled source was used directly and this assumption is documented here.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-09
**Policy Version:** Current (as of audit date)

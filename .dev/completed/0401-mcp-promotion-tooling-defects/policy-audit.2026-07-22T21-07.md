# Policy Compliance Audit: MCP Promotion Tooling Defects (Issue #401)

---

**Audit Date:** 2026-07-22
**Code Under Test:**
- TypeScript (production): `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`, `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-push-down-schema-properties.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tool-inputs-potential-to-issue.ts` (NEW), `extensions/drm-copilot/src/workflow-command-arguments.ts`
- TypeScript (tests): 14 test files under `extensions/drm-copilot/test/` (4 new: `promotion.matrix.test.ts`, `mcp-tool-inputs.workspace-root.test.ts`, `mcp-tools.workspace-root.test.ts`; new support additions in `promotion-test-support.ts`)
- Python (production): `scripts/dev_tools/potential_to_issue.py`
- Python (tests): `tests/scripts/dev_tools/test_potential_to_issue.py`
- Documentation: `README.md`, `extensions/drm-copilot/README.md`, four `execute-hard-lock/SKILL.md` copies (repo + bundled mirrors)

**Baseline:** base branch `main`, merge-base `a0b251d330525b8307467f4cf529c5cc3e947445`. Head branch `bug/mcp-promotion-tooling-defects-401` @ `9d2e7633bdb461e2c34b37a784e1f06f9628c73e`. Work mode: `full-bug`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 8 production, 14 test | 2031 tests (168 suites) | PASS 2031 pass, 0 fail (independently rerun this audit) | 96.30% lines, 89.22% branches | 96.34% lines (37622/39053), 89.21% branches (5201/5830) | `mcp-tool-inputs-potential-to-issue.ts`: 100% lines, 100% branches |
| Python | 1 production, 1 test | 1982 tests full scope; 38 in target suites (independently rerun) | PASS 38 pass, 0 fail | TOTAL 90.91% lines, 87.3% branch (measured set); `potential_to_issue.py` 91.00% lines, 68.18% branches | TOTAL 90.91% lines (11138/12252), 81.60% branches lcov (3628/4446); `potential_to_issue.py` 91.00% lines (182/200), 68.18% branches (45/66) — identical to baseline | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/baseline/baseline-ts-test-coverage.2026-07-22T15-53.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (parsed this audit) + `evidence/qa-gates/final-ts-test-coverage.2026-07-22T20-17.md` + `evidence/qa-gates/coverage-delta-ts.2026-07-22T20-17.md`
- Python baseline coverage artifact: `evidence/baseline/baseline-py-test-coverage.2026-07-22T15-53.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (parsed this audit) + `evidence/qa-gates/final-py-test-coverage.2026-07-22T20-17.md` + `evidence/qa-gates/coverage-delta-py.2026-07-22T20-17.md`
- PowerShell baseline coverage artifact: `N/A - out of scope` (zero PowerShell files in the branch diff)
- PowerShell post-change coverage artifact: `N/A - out of scope` (zero PowerShell files in the branch diff)
- C# baseline coverage artifact: `N/A - out of scope` (zero C# files in the branch diff)
- C# post-change coverage artifact: `N/A - out of scope` (zero C# files in the branch diff)
- Per-language comparison summary: Section 1.2.1 below

**Coverage verdicts (explicit, per language with changed files):**
- **TypeScript: PASS.** Repo-wide 96.34% lines / 89.21% branches (thresholds 85/75). Every changed production file >= 85% lines and >= 75% branches. New file at 100%/100%. No regression versus baseline (96.30%/89.22%).
- **Python: FAIL** on the uniform modified-file branch-coverage criterion. Repo-wide 90.91% lines / 81.60% branches: PASS. Modified file `scripts/dev_tools/potential_to_issue.py` line coverage 91.00% with zero regression (identical 200/18/66/21 counts as baseline): PASS. Modified-file branch coverage 68.18% (45/66) is below the uniform 75% floor (`.claude/rules/quality-tiers.md`). This shortfall is pre-existing at the merge-base (baseline records the identical 66 branches / 21 partial) and was neither caused nor worsened by this branch; changed lines are fully exercised by the new regression tests. Classified as a Major (non-blocking) finding routed to remediation; see Section 8 and `remediation-inputs.2026-07-22T21-07.md`.

## Rejected Scope Narrowing

None detected. The caller instructed a full branch-diff audit against merge-base `a0b251d3` with both TypeScript and Python toolchains and coverage in scope, which matches the scope invariant. No narrowing attempt was present in the delegation prompt.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` → EXIT_CODE 0 (no violations).
- The branch diff writes zero files under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, or `artifacts/post-change/` (verified via `git diff --name-status a0b251d3..HEAD`).
- All evidence in the diff resides under the canonical `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/<kind>/` tree. **PASS.**

---

## Executive Summary

This audit reviews the two-defect bug fix for issue #401 (fail-closed `workspace_root` across all 28 MCP tools; `buildIssueBody` bug-promotion routing reorder in TypeScript/Python lockstep) on branch `bug/mcp-promotion-tooling-defects-401` against merge-base `a0b251d3` of `main`.

Both defect fixes are correctly implemented, in lockstep, with strong regression tests (fail-before evidence recorded, pass-after verified, and the full toolchains independently rerun green during this audit: Prettier/ESLint/tsc/Jest 2031 tests; Black/Ruff/Pyright/pytest). Protected files (`content.ts`, `promotion-filesystem.ts`, `prompt-mode-contract.ts`, `potential_to_issue_content.py`) are confirmed absent from the diff. Coverage is verified from existing lcov artifacts for both languages.

**One Blocking finding was identified:** this branch pushed the production file `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` over the 500-line hard limit (490 lines at merge-base → 504 lines at head), a new violation of `general-code-change.md` that the executor's line-count evidence (`mcp-tool-inputs-linecount-final.2026-07-22T20-17.md`) did not measure. Two Major findings accompany it: the modified Python module's branch coverage (68.18%) is below the uniform 75% floor (pre-existing, no regression), and two pre-existing over-500-line Python files touched by this branch grew further. Remediation inputs are emitted at `remediation-inputs.2026-07-22T21-07.md`. Blocking-finding count: 1.

**Policy documents evaluated:**
- [x] `general-code-change` policy (`.claude/rules/general-code-change.md`)
- [x] `general-unit-test` policy (`.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- [x] TypeScript: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
- [x] Python: Python code-change and unit-test policies (per policy-compliance order)
- N/A PowerShell, C#, Bash, JSON (no changed files in the branch diff)

**Temporary artifacts cleanup:**
- [x] No temporary/one-time scripts remain in the branch diff (verified against `git diff --name-status`)
- [x] Working tree at review time is clean (`git status --porcelain` empty)

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Jest suites use per-test fakes (`FakePotentialFileSystem`, `FakeGhClient`) constructed inside each test; pytest cases construct `FakeFileSystem`/`FakeGhClient` per test. Full suites pass in bulk runs (2031 Jest, 1982 pytest). No shared mutable state observed in the changed tests. |
| **Isolation** - Each test targets single behavior | PASS | New tests are one-behavior-per-`it`/function: fail-closed throw, explicit-fallback preservation, relative/absolute `potential_path`, one routing-matrix cell per case (`promotion.matrix.test.ts`), envelope shape (`mcp-tools.workspace-root.test.ts`). |
| **Fast Execution** - Tests complete quickly | PASS | Jest full suite: 2031 tests in 3.32 s (this audit). pytest target suites: 38 tests in 0.10 s (this audit). |
| **Determinism** - Consistent results | PASS | All I/O is faked; no wall-clock, RNG, network, or filesystem access in the changed tests. No `setTimeout`/`Date.now()` in the added test code (diff inspection). |
| **Readability & Maintainability** - Clear structure | PASS | AAA comments present in new tests; descriptive names reference the AC they verify (e.g., `AC-4 fail-closed`, `AC-6`); matrix tests grouped in a dedicated file. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | TS: 96.30% lines / 89.22% branches (`baseline-ts-test-coverage.2026-07-22T15-53.md`). Py: TOTAL 88% combined; `potential_to_issue.py` 200/18/66/21 (`baseline-py-test-coverage.2026-07-22T15-53.md`). Command: `npm run test:coverage` / `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch`. |
| **No Coverage Regression** | PASS | TS: 96.30% → 96.34% lines (+0.04), 89.22% → 89.21% branches (−0.01, attributable to added production branches; all changed lines exercised). Py: `potential_to_issue.py` identical counts (200/18/66/21) baseline vs post-change — zero regression on changed lines. |
| **New Code Coverage** | PASS | New production file `mcp-tool-inputs-potential-to-issue.ts`: 100% lines (60/60), 100% branches (1/1), parsed from `extensions/drm-copilot/coverage/lcov.info`. |
| **Comprehensive Coverage** | PARTIAL | Changed lines in `workflow-command-arguments.ts`, `mcp-tool-inputs*.ts`, `promotion.ts`, `potential_to_issue.py` are all exercised. However, `potential_to_issue.py` overall branch coverage is 68.18% (45/66), below the uniform 75% floor — pre-existing shortfall, unchanged by this branch. See Section 8. |
| **Positive Flows** | PASS | Bug/minor-audit promotion renders authored content (Jest + pytest); explicit-fallback path; valid absolute/relative `potential_path`. |
| **Negative Flows** | PASS | Omitted `workspace_root` throws with actionable message (resolver + dispatch boundary); empty-string and whitespace-only `workspace_root` rejected; invalid-type preserved (`normalizeWorkspaceRoot(42)`). |
| **Edge Cases** | PASS | Partial bug sections fall back to `PLACEHOLDER` individually (`promotion.matrix.test.ts` "partial sections" case); relative `potential_path` normalization; legacy `full` mode alias. |
| **Error Handling** | PASS | Failure envelope `ok:false` with `workspace_root`, `summary` containing `workspace_root is required` asserted (`mcp-tools.workspace-root.test.ts`); invalid mode/type combinations still throw before body build (matrix tests). |
| **Concurrency** | N/A | No concurrent behavior in the changed scope. |
| **State Transitions** | N/A | No stateful components changed. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.30% lines / 89.22% branches -> Post-change: 96.34% lines / 89.21% branches. Change: +0.04% lines / -0.01% branches (flat; changed lines exercised). New/changed-code coverage: 100% lines and 100% branches for the new file `mcp-tool-inputs-potential-to-issue.ts` (60/60, 1/1). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`; `evidence/qa-gates/coverage-delta-ts.2026-07-22T20-17.md`.
- Python: Baseline: 91.00% lines / 68.18% branches for the changed module `potential_to_issue.py` (repo-wide 90.91% lines / 81.60% branches) -> Post-change: 91.00% lines / 68.18% branches (identical 200/18/66/21 counts). Change: 0.00% (zero regression). New/changed-code coverage: 100% of changed lines exercised by the new regression cases (no new Python production files). Disposition: FAIL on the uniform modified-file branch floor (68.18% < 75%; pre-existing at merge-base, no regression, classified Major/non-blocking in Section 8); repo-wide, modified-file line, and no-regression criteria all pass. Evidence: `artifacts/python/lcov.info`; `evidence/qa-gates/coverage-delta-py.2026-07-22T20-17.md`.
- PowerShell: no changed files in the branch diff; coverage comparison not applicable. Disposition: N/A. Evidence: `git diff --name-status a0b251d3..HEAD` (zero `.ps1`/`.psm1` entries).
- C#: no changed files in the branch diff; coverage comparison not applicable. Disposition: N/A. Evidence: `git diff --name-status a0b251d3..HEAD` (zero `.cs` entries).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions match exact strings/regexes (`/workspace_root is required/`, first-line equality `- Work Mode: minor-audit`, exact summary pinning), producing actionable diffs on failure. |
| **Arrange-Act-Assert Pattern** | PASS | New tests carry explicit Arrange/Act/Assert comments (diff inspection of `promotion.test.ts`, `mcp-tools.workspace-root.test.ts`, service-call test). |
| **Document Intent** | PASS | Docblocks in new test files state the defect and AC under verification; pytest case has a docstring naming AC-3. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | All gh/filesystem interaction is faked on both sides; no network, subprocess, or real filesystem in the changed tests. |
| **Use Mocks/Stubs** | PASS | `FakePotentialFileSystem`, `FakeGhClient` (TS); `FakeFileSystem`, `FakeGhClient` (Py); `jest.fn` service fake at the dispatch boundary. |
| **Environment Stability** | PASS | No temporary files created in tests (prohibited); paths are literal fake paths (`/workspace/...`, `C:/ws`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is that review. Outstanding items are enumerated in Section 8 and the remediation inputs. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #401; `spec.md` (Ready, v1.0) with research at `research/2026-07-22T10-20-mcp-promotion-tooling-defects-research.md`. |
| **Read existing change plans** | PASS | `plan.2026-07-22T09-56.md` present; Phase 0 policy-read evidence at `evidence/baseline/phase0-instructions-read.md`. |
| **Document the plan** | PASS | Atomic plan with per-task evidence artifacts under `evidence/`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Fail-closed is a single guard in `normalizeWorkspaceRoot`; Defect B is a branch reorder reusing existing builders; no new abstractions. |
| **Reusability** | PASS | Reuses `normalizeWorkspaceDestinationPath` for `potential_path`; extraction follows the existing `mcp-tool-inputs-push-down.ts` precedent. |
| **Extensibility** | PASS | Two-argument `normalizeWorkspaceRoot(value, fallbackWorkspaceRoot?)` signature retained; VS Code surface unaffected. |
| **Separation of concerns** | PASS | Path normalization stays at the resolver layer; `promotion-filesystem.ts` (documented Python mirror) untouched. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | New sibling module has a single responsibility (potential-to-issue input resolution) with a documented extraction rationale. |
| **Under 500 lines** | **FAIL** | **Blocking (new violation):** `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` = **504 lines** (> 500), grown from **490 at merge-base** by this branch (+26/−12). Verified: `wc -l` = 504; `git show a0b251d3:<file> | wc -l` = 490. **Pre-existing, worsened (Major):** `scripts/dev_tools/potential_to_issue.py` 634 → 639 (+5, the required lockstep reorder + docblock); `tests/scripts/dev_tools/test_potential_to_issue.py` 1017 → 1076 (+59, required regression cases). Compliant: `mcp-tool-inputs.ts` 477, `mcp-tool-inputs-potential-to-issue.ts` 60, `promotion.ts` 443, `workflow-command-arguments.ts` 410, `mcp-tool-definitions.ts` 451, `mcp-discovery-tool-definitions.ts` 214, `mcp-push-down-schema-properties.ts` 59; all changed TS test files <= 496. |
| **Public vs internal** | PASS | `resolvePotentialToIssueToolInput` re-exported from `mcp-tool-inputs.ts`, preserving the public import surface. |
| **No circular dependencies** | PASS | Sibling imports `asToolArgumentObject`/type from `mcp-tool-inputs`, which re-exports the function; ESLint (`eslint-plugin-import`) and tsc pass; Jest module graph loads cleanly (2031 tests). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `mcp-tool-inputs-potential-to-issue.ts` (kebab-case), `resolvePotentialToIssueToolInput`, snake_case in Python unchanged. |
| **Docs/docstrings** | PASS | New TSDoc on `normalizeWorkspaceRoot` and the extracted resolver explains the why (shared long-running server cannot infer caller checkout). |
| **Comment why, not what** | PASS | Reorder comments in both `buildIssueBody` twins explain the ordering requirement, not the mechanics. |

### 2.5 After Making Changes - Toolchain Execution

All commands below were **independently rerun during this audit** at head `9d2e7633` (in addition to the executor's recorded qa-gates evidence at 2026-07-22T20-17):

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | TS: `npx prettier --check "src/**/*.ts" "test/**/*.ts"` → "All matched files use Prettier code style!", exit 0. Py: `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` → 323 files unchanged, exit 0. |
| **2. Linting** | PASS | TS: `npm run lint` (eslint src test) → exit 0. Py: `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` → "All checks passed!", exit 0. |
| **3. Type checking** | PASS | TS: `npm run typecheck` (`tsc -p ./ --noEmit`) → exit 0. Py: `poetry run pyright scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue_content.py tests/scripts/dev_tools` → 0 errors, exit 0. |
| **4. Testing** | PASS | TS: `node run-jest.cjs` full suite → 168 suites, 2031 tests passed, exit 0. Py: `poetry run pytest` on the three `test_potential_to_issue*` suites → 38 passed, exit 0 (full-scope 1982 passed per executor evidence). |
| **Architecture / contract / integration stages** | N/A | No dependency-cruiser configuration exists for the extension package; no schema/contract surfaces or integration-test suites are affected by this diff. No stage was silently skipped — no repo-defined runner exists for these stages in the changed scope. |
| **Full toolchain loop** | PASS | Single-pass green on rerun (this audit) and recorded single-pass green in `evidence/qa-gates/final-*` (executor). |
| **Explicit reporting** | PASS | Commands and exit codes recorded here and in `evidence/qa-gates/*.2026-07-22T20-17.md`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | `issue.md` "Fix Outcome" section; issue-update mirror at `evidence/issue-updates/issue-401.2026-07-22T20-17.md`. |
| **Design choices explained** | PASS | Spec Proposed Fix + research decision matrix (fail-closed vs auto-detection; resolver-layer vs filesystem-layer). |
| **Update supporting documents** | PASS | Both READMEs and four `execute-hard-lock` SKILL.md copies updated; sweep evidence at `evidence/other/doc-sweep-workspace-root.2026-07-22T20-17.md`; residual grep for "Defaults to process.cwd" outside historical feature docs returns 0 (this audit). |
| **Provide next steps** | PASS | Rollout section in spec (rebuild/republish extension; breaking-change note). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` → exit 0 (this audit). |
| **Linting with Ruff** | PASS | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` → exit 0 (this audit). |
| **Type checking with Pyright** | PASS | `poetry run pyright <changed files + tests>` → 0 errors (this audit). |
| **Testing with Pytest** | PASS | 38 target-suite tests pass (this audit); 1982 full-scope per executor evidence. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | The changed function retains full annotations; no `Any` introduced (diff inspection; pyright clean). |
| **Dataclasses for value objects** | N/A | No new value objects. |
| **Protocols/ABCs for interfaces** | N/A | No new interfaces; existing fake-backed seams reused. |
| **Avoid utility classes** | PASS | Change is a branch reorder inside an existing module function. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | `PromotionError` semantics unchanged; invalid mode/type combinations still raise before body build (pytest matrix assertions). |
| **Logging over print** | N/A | No logging changes in the diff. |
| **Invariants at construction** | N/A | No constructors changed. |

### Section 3B: TypeScript Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting — Prettier** | PASS | `npx prettier --check ...` → exit 0 (this audit). |
| **Linting — ESLint** | PASS | `npm run lint` → exit 0 (this audit). No new suppressions in the diff (grep for `eslint-disable`/`@ts-expect-error`/`@ts-ignore` over changed hunks: none). |
| **Type checking — TSC** | PASS | `npm run typecheck` → exit 0. No `any` introduced; `unknown` + narrowing used at the resolver boundary. |
| **Testing** | PASS | Jest (ts-jest) via `node run-jest.cjs`: 2031 tests pass. Note: `.claude/rules/typescript.md` names Vitest; the extension's established framework is Jest — a known pre-existing docs discrepancy recorded in spec Rollout & Follow-up, not a violation introduced here. |

#### 3B.2 Design & Standards

| Requirement | Status | Evidence |
|------------|--------|----------|
| **ES modules / kebab-case files** | PASS | New file `mcp-tool-inputs-potential-to-issue.ts` uses ES imports/exports, kebab-case name. |
| **Fail fast with clear errors** | PASS | New thrown error names the field and corrective action: `workspace_root is required. The MCP server cannot infer the calling agent's checkout; pass the absolute worktree root explicitly.` Surfaces via `toFailureToolResult` (`ok:false` envelope) — asserted by test. |
| **No new runtime dependencies** | PASS | `extensions/drm-copilot/package.json` dependencies unchanged in the diff. |
| **Runtime determinism** | PASS | No `Date`, `Math.random`, or timer usage introduced. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | New case `test_promote_potential_bug_minor_audit_uses_bug_body` plus updated routing assertions; plain pytest functions, no alternative runner. |
| **Coverage expectation** | PARTIAL | Repo-wide 90.91% lines / 81.60% branches: PASS. Modified module line 91.00% + zero regression: PASS. Modified module branch 68.18% < 75% uniform floor: pre-existing shortfall (Major finding, Section 8). |
| **Focused unit tests / mocking sparingly / organization** | PASS | One behavior per test; only the gh client and filesystem are faked; test file mirrors production path (`tests/scripts/dev_tools/test_potential_to_issue.py` for `scripts/dev_tools/potential_to_issue.py`). |
| **Naming and readability** | PASS | Descriptive names + AC-referencing docstrings. |

### Section 4B: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | PASS | Jest (`@jest/globals`), file naming `*.test.ts`, tests under `test/` mirroring `src/` structure; no colocation in the production tree. |
| **Coverage expectation** | PASS | 96.34% lines / 89.21% branches repo-wide; all changed files above thresholds; new file 100%/100%. |
| **AAA / one behavior per test / fakes** | PASS | Diff inspection: explicit AAA comments, dedicated fakes, `jest.fn` service fake at the dispatch boundary; no snapshot tests added. |
| **No external dependencies** | PASS | No network/filesystem/temp files in the added tests. |

---

## 5. Test Coverage Detail

### `normalizeWorkspaceRoot` (`workflow-command-arguments.ts`) — 6 new tests

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| throws an actionable error when the value is omitted and no fallback is supplied | Negative | new fail-closed guard | PASS |
| returns the explicit fallback when the value is omitted | Positive | fallback path | PASS |
| normalizes a valid string value unchanged | Positive | string path | PASS |
| preserves the existing invalid-type error | Negative | type guard | PASS |
| rejects an empty-string workspace_root | Edge | validation | PASS |
| rejects a whitespace-only workspace_root | Edge | validation | PASS |

**Coverage:** `workflow-command-arguments.ts` 91.46% lines / 88.24% branches (lcov).

### `resolvePotentialToIssueToolInput` (`mcp-tool-inputs-potential-to-issue.ts`, NEW) — covered by `mcp-tool-inputs.workspace-root.test.ts` + service-call test

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| resolves a workspace-relative potential_path against workspace_root | Positive | normalization path | PASS |
| preserves an absolute potential_path unchanged | Positive | passthrough | PASS |
| pins the summary form to the workspace-resolved absolute path (service call) | Positive/contract | summary pinning | PASS |

**Coverage:** 100% lines (60/60), 100% branches (1/1).

### `buildIssueBody` twins (`promotion.ts` / `potential_to_issue.py`) — matrix + regression tests

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| (bug, minor-audit) renders bug-headed body with authored content, first line `- Work Mode: minor-audit`, no placeholders (Jest + pytest) | Regression (fail-before recorded) | PASS |
| (feature/refactor/epic, minor-audit) → `buildMinorAuditBody`; (bug, full-bug/full) → `buildBugBody`; (feature/refactor/epic, full-feature/full) → `buildBody` | Matrix guard | PASS |
| (bug, full-feature) / (feature, full-bug) throw before body build | Negative | PASS |
| partial bug sections fall back to PLACEHOLDER individually | Edge | PASS |

**Coverage:** `promotion.ts` 98.87% lines / 81.97% branches; `potential_to_issue.py` 91.00% lines / 68.18% branches (pre-existing branch gap, unchanged).

### MCP schema + dispatch boundary

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| lists workspace_root in inputSchema.required for every repo automation tool (with length pin vs `REPO_AUTOMATION_TOOLS`) + per-tool discovery assertions | Contract | PASS |
| does not advertise a process.cwd() default in the workspace_root description | Contract | PASS |
| dispatch returns ok:false with actionable message when workspace_root omitted (envelope shape: ok, tool, workspace_root, summary) | Error handling | PASS |

**Independent verification:** `grep -c '"workspace_root"'` = 21 (`mcp-repo-automation-tool-definitions.ts`) + 7 (`mcp-discovery-tool-definitions.ts`) = 28 required entries, matching 21 + 7 tool `name:` entries; base mirror `mcp-tool-definitions.ts` 18/18.

**Not covered:** 21 partially-covered branches in `potential_to_issue.py` (pre-existing; enumerated as remediation item R2).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (TS) | 2031 (168 suites) | PASS |
| Tests Passed (TS) | 2031 (100%) | PASS |
| Execution Time (TS) | 3.32 s total | PASS Fast |
| Total Tests (Py, target suites) | 38 (full scope 1982 per executor evidence) | PASS |
| Tests Passed (Py) | 38 (100%) | PASS |
| Execution Time (Py, target suites) | 0.10 s | PASS Fast |
| Code Coverage (TS) | 96.34% lines, 89.21% branches | PASS |
| Code Coverage (Py) | 90.91% lines, 81.60% branches repo-wide; modified file 91.00% / 68.18% | PARTIAL (see Section 8) |

---

## 7. Code Quality Checks

**For TypeScript (from `extensions/drm-copilot/`):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check "src/**/*.ts" "test/**/*.ts"` | All files formatted, exit 0 | PASS |
| ESLint | `npm run lint` | No findings, exit 0 | PASS |
| TSC | `npm run typecheck` | 0 errors, exit 0 | PASS |
| Jest | `node run-jest.cjs` | 2031/2031 pass, exit 0 | PASS |

**For Python (from repo root):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` | 323 files unchanged, exit 0 | PASS |
| Ruff | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` | All checks passed, exit 0 | PASS |
| Pyright | `poetry run pyright scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue_content.py tests/scripts/dev_tools` | 0 errors, exit 0 | PASS |
| Pytest | `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue*.py -q --no-cov` | 38 passed, exit 0 | PASS |

**Notes:**
Pre-existing conditions unrelated to this fix: `.claude/rules/typescript.md` names Vitest while the extension's established framework is Jest (recorded in spec for separate docs correction); `potential_to_issue.py` branch-coverage shortfall and two over-500-line Python files predate the merge-base (Section 8).

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **[Blocking] File-size limit — new violation.** `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` is 504 lines (> 500), grown from 490 at merge-base by this branch's `required: ["workspace_root", ...]` insertions (+26/−12). The executor's AC-14 evidence (`evidence/other/mcp-tool-inputs-linecount-final.2026-07-22T20-17.md`) measured only `mcp-tool-inputs.ts` and its sibling and missed this file. Remediation: extract a portion of `REPO_AUTOMATION_TOOL_DEFINITIONS` to a sibling module (precedent: `mcp-tool-inputs-push-down.ts` extraction pattern). See `remediation-inputs.2026-07-22T21-07.md` (R1).
2. **[Major] Modified-file branch coverage below uniform floor.** `scripts/dev_tools/potential_to_issue.py` branch coverage is 68.18% (45/66) vs the uniform 75% floor. Pre-existing at merge-base (identical 66/21 branch/partial counts in baseline evidence); zero regression; changed lines fully exercised. The executor's `coverage-delta-py.2026-07-22T20-17.md` checked the branch threshold against the overall measured set (87.3%) rather than the changed module — an evidence-accuracy defect. Not an independent blocking trigger under the feature-review remediation-trigger rules (no regression; line coverage 91%), but routed into the required remediation cycle (R2).
3. **[Major] Pre-existing over-500-line files worsened.** `scripts/dev_tools/potential_to_issue.py` 634 → 639 (+5, the required lockstep reorder); `tests/scripts/dev_tools/test_potential_to_issue.py` 1017 → 1076 (+59, required regression cases). Both violations predate the branch (precedent: treated as non-blocking follow-up in `docs/features/archive/2026-04-05-potential-to-issue-missing-label-123/policy-audit.2026-04-05T15-30.md` for these same files). Recommended follow-up decomposition (R3), distinct from the Blocking new violation in gap 1.

### Approved Exceptions

**None.** No exceptions were requested or approved.

### Removed/Skipped Tests

**None.** All planned tests implemented; existing fallback-default tests were inverted per AC-4 (documented, not removed).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **9d2e7633** — `fix(mcp-tools): require workspace_root and fix bug promotion body` (single commit; full diff vs merge-base `a0b251d3`)

### Files Modified

1. **`extensions/drm-copilot/src/workflow-command-arguments.ts`** (MODIFIED) — `normalizeWorkspaceRoot` fails closed on omitted value with no explicit fallback; TSDoc added.
2. **`extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`**, **`mcp-discovery-tool-definitions.ts`**, **`mcp-tool-definitions.ts`** (MODIFIED) — `workspace_root` added to every tool's `inputSchema.required` (21 + 7 runtime tools; 18-tool test-only base mirror).
3. **`extensions/drm-copilot/src/mcp-push-down-schema-properties.ts`** (MODIFIED) — description rewritten: required, no `process.cwd()` default.
4. **`extensions/drm-copilot/src/mcp-tool-inputs.ts`** (MODIFIED, 477 lines) + **`mcp-tool-inputs-potential-to-issue.ts`** (NEW, 60 lines) — `resolvePotentialToIssueToolInput` extracted; relative `potential_path` resolved against `workspace_root` via `normalizeWorkspaceDestinationPath`.
5. **`extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`** (MODIFIED) — `buildIssueBody` bug-first branch reorder; routing docblock updated; stale parity-header path corrected to `scripts/dev_tools/potential_to_issue.py`.
6. **`scripts/dev_tools/potential_to_issue.py`** (MODIFIED) — identical lockstep branch reorder.
7. **Tests** — 14 TS test files (4 new) and `tests/scripts/dev_tools/test_potential_to_issue.py` updated per the AC test matrix.
8. **Docs** — repo/extension READMEs, four `execute-hard-lock/SKILL.md` copies updated to the required-`workspace_root` contract.
9. **Feature docs/evidence** — spec, issue, plan, research, and 31 evidence artifacts under the canonical feature evidence tree.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

Both defect fixes are correct, lockstep-parity-preserving, and comprehensively tested; both language toolchains pass in a single pass on independent rerun; coverage artifacts exist and were parsed for both languages. One Blocking finding prevents PASS: the branch newly pushed `mcp-repo-automation-tool-definitions.ts` over the 500-line hard limit (490 → 504). Two Major findings (pre-existing per-file branch-coverage shortfall; pre-existing over-limit files worsened) are routed to the same remediation cycle.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec/plan/research present
- ✅ Design Principles: minimal, precedent-following design
- ❌ Module & File Structure: one new >500-line production file (Blocking); two pre-existing overages worsened
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: single-pass green, independently rerun
- ✅ Summarize & Document: issue mirror + doc sweep complete

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python Tooling & Baseline / Design & Typing / Error Handling
- ✅ TypeScript Tooling & Baseline / Design & Standards (no new suppressions, no `any`, no new dependencies)

#### General Unit Test Policy (Section 1)
- ✅ Core Principles
- ⚠️ Coverage & Scenarios: TS PASS; Py modified-file branch floor not met (pre-existing, no regression)
- ✅ Test Structure
- ✅ External Dependencies

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python Framework/Style/Naming; ⚠️ coverage as above
- ✅ TypeScript Framework/Style/Coverage

### Metrics Summary

- ✅ 2031/2031 TS tests passing; 38/38 Py target-suite tests passing (1982 full scope per executor evidence)
- ✅ TS coverage 96.34% lines / 89.21% branches
- ⚠️ Py coverage 90.91% lines / 81.60% branches repo-wide; modified file 91.00% lines / **68.18% branches** (pre-existing)
- ❌ File-size gate: 504-line production file (new violation)
- ✅ All format/lint/type checks passing on independent rerun
- ✅ Evidence locations canonical (validator exit 0)

### Recommendation

**Needs revision** — one Blocking finding (R1: extract/decompose `mcp-repo-automation-tool-definitions.ts` to <= 500 lines) must be remediated and reaudited before PR authoring. R2 (branch-coverage tests for `potential_to_issue.py`) and R3 (follow-up decomposition of the two pre-existing over-limit Python files) are enumerated in `remediation-inputs.2026-07-22T21-07.md`; R2 is recommended within this cycle, R3 may be deferred to a follow-up issue at the orchestrator's discretion.

---

## Appendix A: Test Inventory

New/updated tests attributable to this branch (representative; full suites: 168 Jest suites / 2031 tests, pytest `tests/scripts/dev_tools`):

1. workflow-command-arguments.test.ts › normalizeWorkspaceRoot (AC-4 fail-closed) › throws an actionable error when the value is omitted and no fallback is supplied
2. workflow-command-arguments.test.ts › normalizeWorkspaceRoot › returns the explicit fallback when the value is omitted
3. workflow-command-arguments.test.ts › normalizeWorkspaceRoot › normalizes a valid string value unchanged
4. workflow-command-arguments.test.ts › normalizeWorkspaceRoot › preserves the existing invalid-type error
5. workflow-command-arguments.test.ts › normalizeWorkspaceRoot › rejects an empty-string workspace_root
6. workflow-command-arguments.test.ts › normalizeWorkspaceRoot › rejects a whitespace-only workspace_root
7. mcp-tool-inputs.workspace-root.test.ts › resolveNewPotentialBugEntryToolInput — fail-closed workspace_root (AC-4) › throws an actionable error naming workspace_root when omitted with no fallback
8. mcp-tool-inputs.workspace-root.test.ts › resolveNewPotentialBugEntryToolInput › returns the explicit fallback workspace root when workspace_root is omitted
9. mcp-tool-inputs.workspace-root.test.ts › resolvePotentialToIssueToolInput — workspace-relative potential_path (AC-6) › resolves a workspace-relative potential_path against workspace_root
10. mcp-tool-inputs.workspace-root.test.ts › resolvePotentialToIssueToolInput › preserves an absolute potential_path unchanged
11. mcp-tools.workspace-root.test.ts › dispatchRepoAutomationTool workspace_root failure envelope (AC-8) › returns ok:false with the actionable message when workspace_root is omitted
12. mcp-repo-automation-tool-definitions.test.ts › workspace_root required contract (AC-5) › lists workspace_root in inputSchema.required for every repo automation tool (all 28)
13. mcp-repo-automation-tool-definitions.test.ts › workspace_root required contract (AC-5) › does not advertise a process.cwd() default in the workspace_root description
14. lib/potential-to-issue/promotion.test.ts › promotePotential — bug promotion in minor-audit mode (AC-1) › routes a populated bug potential to the bug body under minor-audit with the minor-audit marker
15. lib/potential-to-issue/promotion.matrix.test.ts › buildIssueBody routing matrix (AC-2) › [matrix cells: minor-audit non-bug routing, bug full-bug/full routing, full-feature routing, invalid-combination throws]
16. lib/potential-to-issue/promotion.matrix.test.ts › buildIssueBody bug minor-audit partial sections (AC-1 edge) › emits placeholders only for empty bug sections while populated ones carry content
17. lib/potential-to-issue/potential-to-issue-service-call.test.ts › relative potential_path summary (AC-6) › pins the summary form to the workspace-resolved absolute path for a relative input
18. tests/scripts/dev_tools/test_potential_to_issue.py::test_promote_potential_bug_minor_audit_uses_bug_body
19. tests/scripts/dev_tools/test_potential_to_issue.py::test_promote_potential_bug_honors_explicit_minor_audit (updated assertions for the reorder)
20. Updated omission/inversion cases across mcp-tool-inputs.test.ts, mcp-tool-inputs-discovery.test.ts, mcp-server.test.ts, mcp-tools.push-down-claude.test.ts, repo-automation-render-subagent-tree.test.ts, extension.list-mcp-tools.test.ts

---

## Appendix B: Toolchain Commands Reference

**For TypeScript (from `extensions/drm-copilot/`):**
```bash
# Formatting (check-only used in this audit)
npx prettier --check "src/**/*.ts" "test/**/*.ts"

# Linting
npm run lint

# Type checking
npm run typecheck

# Testing
node run-jest.cjs
npm run test:coverage   # coverage artifact: extensions/drm-copilot/coverage/lcov.info
```

**For Python (from repo root):**
```bash
# Formatting (check-only)
poetry run black --check scripts/dev_tools tests/scripts/dev_tools

# Linting
poetry run ruff check scripts/dev_tools tests/scripts/dev_tools

# Type checking
poetry run pyright scripts/dev_tools/potential_to_issue.py scripts/dev_tools/potential_to_issue_content.py tests/scripts/dev_tools

# Testing + coverage
poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term
# coverage artifact: artifacts/python/lcov.info
```

**Evidence-location validation:**
```bash
python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-07-22
**Policy Version:** Current (as of audit date)

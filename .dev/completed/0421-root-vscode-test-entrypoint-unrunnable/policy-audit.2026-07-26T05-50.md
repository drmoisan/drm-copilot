# Policy Compliance Audit: Root vscode-test Entry-Point Repair (#421)

---

**Audit Date:** 2026-07-26
**Code Under Test:** `package.json` (scripts block), `tests/unit/vscode-test-removal.test.ts` (new), `.github/workflows/_root-typescript-tests.yml` (new), `.github/workflows/ci.yml`, `.github/workflows/README.md`

**Baseline:** `origin/main` @ `fb483b8468204e4385b5583c3b3ec4c0a987eede` (merge base identical). Head: `bug/vscode-test-integration-entrypoint` @ `852075346e7068435fb2c9d9744e9892fb789260`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 1 file (new test) | 2038 tests / 170 suites | ✅ 2038 pass, 0 fail | 97.01% lines, 89.07% branch | 97.01% lines, 89.07% branch | N/A (no production TS file added or modified; the only new file is a test file, excluded from coverage measurement per policy) |
| JSON | 1 file (`package.json`) | N/A | ✅ validation (parses; per-key diff confirms `scripts`-only change) | N/A (config file) | N/A (config file) | N/A |
| GitHub Actions YAML | 3 files | N/A | ✅ green run at branch head (run 30189725327) | N/A | N/A | N/A |
| Markdown (docs/evidence) | 28 files | N/A | N/A | N/A | N/A | N/A |

Languages with zero changed files on the branch: Python, PowerShell, C#, Bash. Coverage verdicts for these are legitimately N/A (zero changed files verified via `git diff --name-only fb483b84..85207534`).

**TypeScript coverage verdict (language with changed files): PASS** — repo-wide line 97.01% (>= 85%) and branch 89.07% (>= 75%); no regression versus the recorded baseline (identical to two decimal places); no production file's coverage denominator changed.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-test-coverage-root.2026-07-26T05-10.md` (169 suites / 2036 tests, line 97.01%, branch 89.07%)
- TypeScript post-change coverage artifact: `coverage/lcov.info` (178 SF records; regenerated and re-verified by the reviewer on 2026-07-26) plus `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-test-coverage-root.2026-07-26T05-29.md`
- PowerShell baseline coverage artifact: `N/A - out of scope` (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: `N/A - out of scope` (zero PowerShell files changed on the branch)
- Per-language comparison summary: `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/coverage-comparison-root.2026-07-26T05-31.md` and section 1.2.1 below

---

## Executive Summary

This branch repairs the unrunnable repository-root `npm test` / `npm run test:integration` entry points (issue #421) by (1) repointing root `test` at the real jest suite (`node run-jest.cjs`), removing the dead `test:integration` and `compile:integration-tests` scripts, trimming `pretest`, and removing the vestigial `.vscode-test.mjs` prettier globs; (2) adding a regression-guard test `tests/unit/vscode-test-removal.test.ts`; and (3) wiring a new reusable CI workflow `_root-typescript-tests.yml` (called from `ci.yml`) that runs the root TypeScript toolchain on ubuntu-latest and windows-latest.

The reviewer independently re-ran the full root TypeScript toolchain (format:check, lint, typecheck, jest with coverage via the path-independent invocation) — all stages exited 0 in a single pass. The reviewer also independently dispatched CI run 30189725327 against the current branch head `85207534` (the executor's recorded green run 30189336124 was against the prior head `df874e81`; the delta is docs-only); the new run concluded `success` with all 16 jobs green, including both `root-typescript-tests` matrix legs with `PASS tests/unit/vscode-test-removal.test.ts` in both logs. All policy checks pass. No blocking findings.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ TypeScript: `.claude/rules/typescript.md`
- ✅ GitHub Actions: `.claude/rules/ci-workflows.md`
- ✅ JSON: strict-JSON inspection of `package.json` (scripts-only change)
- N/A `python-code-change.instructions.md` + `python-unit-test.instructions.md` (zero changed Python files)
- N/A `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (zero changed PowerShell files)
- N/A C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts appear in the branch diff (`git diff --name-only fb483b84..85207534` contains only the five implementation files and the feature-folder docs/evidence)
- ✅ The one new ongoing artifact (`tests/unit/vscode-test-removal.test.ts`) is itself a test and passes the full toolchain

## Rejected Scope Narrowing

None. The caller prompt supplied context facts only and explicitly delegated scope determination ("Scope determination is your responsibility. Apply the full workflow contract without narrowing."). No attempted narrowing was detected; the audit scope is the full branch diff `fb483b84..85207534` against `origin/main`.

## Evidence Location Compliance

- `python -m scripts.dev_tools.validate_evidence_locations --root .` → exit 0 (no violations).
- Branch diff scan: zero files under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 26 evidence files in the diff are under the canonical `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/<kind>/` scheme (`baseline/`, `regression-testing/`, `qa-gates/`, `other/`).
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no caller instruction supplied a non-canonical evidence path.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | The two new guard tests share no mutable state; each re-reads `package.json` / probes the filesystem independently. Verified passing inside the full 170-suite run and in a name-scoped solo run (`--testPathPatterns "vscode-test-removal"`). |
| **Isolation** - Each test targets single behavior | ✅ PASS | Test 1 asserts only "no script value contains `vscode-test`"; test 2 asserts only "no dead config file exists at the root". One behavior each. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Name-scoped run: 0.291–0.324 s for the suite (evidence: `guard-test-local-run.2026-07-26T05-22.md`). Full 170-suite run: 6.3 s (reviewer re-run). |
| **Determinism** - Consistent results | ✅ PASS | Reads only versioned repository files; no wall-clock, RNG, network, or temp-file use. Reviewer re-run reproduced identical results (2038/2038 pass). |
| **Readability & Maintainability** - Clear structure | ✅ PASS | 78-line file with a file-level doc comment explaining the defect and the guard's purpose, typed `PackageJson` shape, explicit Arrange/Act/Assert comments, descriptive test names. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** 97.01% lines, 89.07% branch, 169 suites / 2036 tests<br>**Command:** `node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"`<br>**Artifact:** `evidence/baseline/baseline-test-coverage-root.2026-07-26T05-10.md` |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 97.01% lines, 89.07% branch (reviewer re-verified 2026-07-26)<br>**Change:** +0.00% lines, +0.00% branch; +1 suite, +2 tests<br>**Status:** No regression. No production file changed, so no changed-line regression is possible. |
| **New Code Coverage** | ✅ N/A | **New/modified files:** `tests/unit/vscode-test-removal.test.ts` (test file — excluded from coverage measurement per policy), `package.json`, workflow YAML, docs (not coverage-measured). No production code file was added or modified, so the new-code coverage threshold has no denominator. |
| **Comprehensive Coverage** | ✅ PASS | The defect class ("declared npm script whose entry point cannot exist") is covered by both guard assertions; the repaired entry point itself is exercised end-to-end by CI run 30189725327 (`npm test` → pretest → jest, 170 suites). |
| **Positive Flows** - Valid inputs | ✅ PASS | Both tests assert the current (valid) repository state produces empty offending-item lists. |
| **Negative Flows** - Invalid inputs | ✅ PASS | The guard's purpose is negative-path: reintroducing a `vscode-test` script or any of the five dead config files fails the assertions (`toEqual([])` reports the offending names). Fail-before evidence for the original defect: `evidence/regression-testing/fail-before-npm-test.2026-07-26T05-06.md` and `fail-before-npm-test-integration.2026-07-26T05-07.md` (both non-zero exit with the verbatim `@vscode/test-cli` error). |
| **Edge Cases** - Boundary conditions | ✅ PASS | `scripts ?? {}` handles an absent scripts block; the dead-file list covers all four `.vscode-test.*` variants plus `tsconfig.vscode-test.json`. |
| **Error Handling** - Error paths | ✅ N/A | The unit under guard is declarative configuration; no production error path exists to test. `JSON.parse`/`readFileSync` failures would fail the test loudly, which is the desired behavior. |
| **Concurrency** - If applicable | N/A | No concurrent behavior in scope. |
| **State Transitions** - If applicable | N/A | No stateful component in scope. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.01% lines / 89.07% branch -> Post-change: 97.01% lines / 89.07% branch. Change: +0.00% / +0.00% (+1 suite, +2 tests). New/changed-code coverage: N/A (no production file changed; only a test file was added). Disposition: PASS. Evidence: `evidence/baseline/baseline-test-coverage-root.2026-07-26T05-10.md`, `evidence/qa-gates/final-test-coverage-root.2026-07-26T05-29.md`, `evidence/qa-gates/coverage-comparison-root.2026-07-26T05-31.md`, `coverage/lcov.info`, plus the reviewer's independent re-run (exit 0, identical figures).
- Python: N/A - out of scope (zero changed files on the branch).
- PowerShell: N/A - out of scope (zero changed files on the branch).
- C#: N/A - out of scope (zero changed files on the branch).
- Bash: N/A - out of scope (zero changed files on the branch).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions compare name arrays against `[]`, so a failure prints the offending script names or file names directly. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Both tests carry explicit `// Arrange`, `// Act`, `// Assert` sections. |
| **Document Intent** | ✅ PASS | File-level doc comment records the defect (#421), the prior art (`2f67b888`), and the determinism rationale; test names state the invariant. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, database, external process, or temp-file use. The tests read committed repository files (`package.json`, root path probes), which is deterministic versioned input, consistent with the spec's Test Strategy and the repo's prior-art guard. |
| **Use Mocks/Stubs** | ✅ N/A | Nothing to mock; inputs are versioned files. |
| **Environment Stability** | ✅ PASS | `repositoryRoot` is derived from `__dirname`, not the working directory, so results do not depend on invocation location. **No temporary files are created** (prohibited by policy; none present). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, plus `code-review.2026-07-26T05-50.md` and `feature-audit.2026-07-26T05-50.md`, constitute the pre-PR policy review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #421; `issue.md` work-mode marker `full-bug`; objective and scope decision recorded in `spec.md` (Scope Decision section, option (a) selected with decisive evidence). |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md` records the eight policy files read in order; research artifact `research/2026-07-25T23-45-root-vscode-test-entrypoint-scope-research.md` predates the plan. |
| **Document the plan** | ✅ PASS | `plan.2026-07-25T21-43.md` — 37/37 tasks checked off. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The fix is removal-plus-repoint text edits, one small guard test, and a 30-line workflow modeled on the existing extension-tests workflow. No new abstraction. |
| **Reusability** | ✅ PASS | Reuses the existing `run-jest.cjs` harness, the existing `testMatch`, and the established reusable-workflow (`workflow_call` + `workflow_dispatch`) pattern. |
| **Extensibility** | ✅ PASS | The guard's `deadConfigFileNames` list is a single extension point; the workflow matrix is extensible per-OS. |
| **Separation of concerns** | ✅ PASS | Script definitions, test, and CI wiring are separate files; no production logic touched. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One guard suite per defect class; one workflow per CI stage. |
| **Under 500 lines** | ✅ PASS | `tests/unit/vscode-test-removal.test.ts`: 78 lines; `_root-typescript-tests.yml`: 30 lines; `package.json`: 56 lines (`wc -l`). |
| **Public vs internal** | ✅ PASS | No exported API surface added; test-internal helpers are module-local. |
| **No circular dependencies** | ✅ PASS | Test imports only `@jest/globals`, `node:fs`, `node:path`. `ci.yml` → `_root-typescript-tests.yml` is a one-way `uses:` reference. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `vscode-test-removal.test.ts` (kebab-case), `deadConfigFileNames`, `readRootPackageJson`, `offendingScriptNames` — camelCase locals, PascalCase type (`PackageJson`). |
| **Docs/docstrings** | ✅ PASS | File-level doc comment; `.github/workflows/README.md` updated (seven → eight workflows, dispatch-table row added). |
| **Comment why, not what** | ✅ PASS | Comments explain the defect history and determinism rationale, not mechanics. |

### 2.5 After Making Changes - Toolchain Execution

Reviewer independently re-ran every runnable stage (single pass, all exit 0):

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `npm run format:check`<br>**Result:** "All matched files use Prettier code style!" exit 0 (reviewer re-run 2026-07-26; executor evidence `final-format-check-root.2026-07-26T05-26.md`). |
| **2. Linting** | ✅ PASS | **Command:** `npm run lint`<br>**Result:** zero findings, exit 0 (reviewer re-run; executor evidence `final-lint-root.2026-07-26T05-26.md`). |
| **3. Type checking** | ✅ PASS | **Command:** `npm run typecheck`<br>**Result:** zero errors, exit 0 (reviewer re-run; executor evidence `final-typecheck-root.2026-07-26T05-27.md`). |
| **4. Testing** | ✅ PASS | **Command:** `node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"`<br>**Result:** 170 suites / 2038 tests, all pass, exit 0 (reviewer re-run). Authoritative `npm test` verification: CI run 30189725327 at head `85207534`, both OS legs green. |
| **Full toolchain loop** | ✅ PASS | Stages 1–3, 5 ran clean in a single pass; stage 4 (architecture-boundary), 6 (contract/schema), 7 (integration) are N/A at the repository root with rationale recorded in `evidence/qa-gates/final-stages-4-6-7-na-root.2026-07-26T05-28.md` (no root TypeScript architecture gate is configured; no root contract surface; extension integration-style jest tests run under stage 5 and in `_drm-copilot-extension-tests.yml`). |
| **Explicit reporting** | ✅ PASS | Exact commands and exit codes recorded here and in the `evidence/qa-gates/` artifacts. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Eight conventional commits (`b340f5a8`..`85207534`) with scoped messages; section 9 below. |
| **Design choices explained** | ✅ PASS | `spec.md` Scope Decision records option (a) vs (b), decisive evidence, and the strongest counterargument. |
| **Update supporting documents** | ✅ PASS | `.github/workflows/README.md` dispatch table updated. |
| **Provide next steps** | ✅ PASS | `spec.md` Rollout & Follow-up records the deferred devDependency cleanup (sibling-owned), manifest-vestige cleanup, and the optional required-check procedure. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting — Prettier** | ✅ PASS | `npm run format:check` exit 0 (reviewer re-run). |
| **Linting — ESLint** | ✅ PASS | `npm run lint` exit 0, zero findings (reviewer re-run). |
| **Type checking — TSC** | ✅ PASS | `npm run typecheck` exit 0. No `any`, no type assertions beyond the single justified `JSON.parse(raw) as PackageJson` narrowing to a local structural type; no suppression comments (`grep` for `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck` in the new file: zero matches). |
| **Strong typing** | ✅ PASS | Local `PackageJson` type models the consumed shape; helpers fully typed. |
| **Module syntax** | ✅ PASS | ES-module `import` syntax throughout the new test (compiled per repo tsconfig). No new CommonJS production code. |
| **Naming / file naming** | ✅ PASS | Kebab-case filename; conventional identifier casing. |
| **Dependencies** | ✅ PASS | No dependency added or removed; `devDependencies`, `dependencies`, `overrides`, and `package-lock.json` byte-identical to base (per-key comparison, section 9). |
| **Test framework note** | ⚠️ observation (Info, non-blocking) | `.claude/rules/typescript.md` names Vitest as the test framework, but the repository's actual root harness is jest/ts-jest (`run-jest.cjs`, all 169 pre-existing suites, `@jest/globals`). The new guard follows the established repo-wide jest convention; the rule-vs-repo divergence is pre-existing and outside this workstream's ownership (`jest.config.cjs`/`run-jest.cjs` are forbidden files). Recorded in section 8. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | `package.json` parses with `JSON.parse` (verified by the per-key comparison script and by the guard test itself). |
| **Scoped change** | ✅ PASS | Per-key diff against `fb483b84`: only the `scripts` key changed; all nine other top-level keys byte-identical. |
| **Schema validation** | ✅ N/A | `package.json` is an npm manifest, not a `$schema`-governed repo config; the `docs-validation` and `NPM Audit Gate` CI jobs passed on run 30189725327. |

### Section 3E: GitHub Actions Workflow Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Reusable-workflow convention** | ✅ PASS | `_root-typescript-tests.yml` declares both `on: workflow_call:` and `on: workflow_dispatch:`; referenced from `ci.yml` via `uses: ./.github/workflows/_root-typescript-tests.yml`; README dispatch table updated. Matches the `_drm-copilot-extension-tests.yml` model (same `actions/checkout@v7`, `actions/setup-node@v7`, node 20, npm cache keyed on the root `package-lock.json`). |
| **Deliberately-failing nested command pattern (`.claude/rules/ci-workflows.md`)** | ✅ N/A | The new workflow contains no `pwsh` step and no intentionally-failing nested command; both steps (`npm ci`, `npm test`) use default failure propagation. |
| **`modified-workflow-needs-green-run`** | ✅ PASS | The diff modifies `.github/workflows/**`, so the rule fires. Evidence: CI run **30189725327** (https://github.com/drmoisan/drm-copilot/actions/runs/30189725327), trigger `workflow_dispatch`, head SHA `852075346e7068435fb2c9d9744e9892fb789260` — **exactly the current branch head** (local and `origin` verified identical) — conclusion `success`, all 16 jobs green including `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)` and `(windows-latest)`, both logs containing `PASS tests/unit/vscode-test-removal.test.ts` and `Test Suites: 170 passed, 170 total`. This run was dispatched and verified by the reviewer on 2026-07-26 because the executor's recorded green run 30189336124 was against the prior head `df874e81` (superseded by the docs-only evidence commit `85207534`). The supporting validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` referenced by the skill does not exist in the repository; the rule was applied manually (recorded in section 8). |
| **Existing check-run names preserved** | ✅ PASS | `ci.yml` diff is purely additive (one new job); no job renamed. |

Python (3A-python), PowerShell (3B), Bash (3C) sections: deleted — zero changed files in those languages.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS (with Info observation) | Guard uses `@jest/globals`, matching the repository's actual root harness and all 169 pre-existing suites. See the Vitest rule-divergence observation in sections 3A and 8. |
| **File naming `*.test.ts`** | ✅ PASS | `vscode-test-removal.test.ts`. |
| **Test file location (`tests/` tree, no colocation)** | ✅ PASS | Placed at `tests/unit/`, matching the existing `tests/unit/hello-typescript.test.ts` layout and auto-discovered by the existing `testMatch` with zero jest-config changes (verified: `--listTests` names the file; `jest.config.cjs` unchanged vs base). |
| **Arrange–Act–Assert** | ✅ PASS | Explicit AAA comments in both tests. |
| **One behavior per test** | ✅ PASS | Two tests, one invariant each. |
| **No external dependencies / no temp files** | ✅ PASS | Versioned-file reads only; nothing created. |
| **No banned APIs** (`setTimeout`, `Date.now`, RNG) | ✅ PASS | `grep` of the new file: zero matches. |
| **Coverage thresholds (uniform tier rule)** | ✅ PASS | Repo-wide TS: 97.01% line / 89.07% branch (>= 85 / >= 75). No changed-line regression possible (no production file changed). |
| **Snapshot tests** | ✅ N/A | None added (0 snapshots reported by jest). |
| **Property-based tests** | ✅ N/A | No new pure production function was added; the guard covers declarative configuration. |

---

## 5. Test Coverage Detail

### `tests/unit/vscode-test-removal.test.ts` — guard suite (2 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `vscode-test harness removal › no root npm script invokes the vscode-test runner` | Negative-path guard (regression) | `package.json` scripts values (declarative input, not coverage-measured) | ✅ |
| `vscode-test harness removal › no dead vscode-test config file exists at the repository root` | Negative-path guard (regression) | Repository-root file presence (declarative input, not coverage-measured) | ✅ |

**Coverage:** The guard is a test file and contributes no lines to the production coverage denominator (test files are excluded per policy). The behavior it protects (`npm test` entry-point integrity) is additionally exercised end-to-end by CI run 30189725327.

**Not covered:** None. No production code was added or modified; the repo-wide TypeScript figures (97.01% / 89.07%) are unchanged from baseline.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 2038 (170 suites) | ✅ |
| Tests Passed | 2038 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | 6.3 s local full suite (reviewer); 11.97 s / 18.4 s on CI (ubuntu / windows) | ✅ Fast |
| Average Time per Test | ~3 ms | ✅ Fast |
| New guard suite solo runtime | 0.29–0.32 s | ✅ |
| Code Coverage (TypeScript repo-wide) | 97.01% lines, 89.07% branches | ✅ |
| Test File Size | 78 lines | ✅ Maintainable |

---

## 7. Code Quality Checks

**For TypeScript (repository root):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier check | `npm run format:check` | All matched files use Prettier code style; exit 0 | ✅ |
| ESLint | `npm run lint` | Zero findings; exit 0 | ✅ |
| TSC typecheck | `npm run typecheck` | Zero errors; exit 0 | ✅ |
| Jest (path-independent) | `node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"` | 170/170 suites, 2038/2038 tests; exit 0 | ✅ |
| Root `npm test` (authoritative) | CI run 30189725327 (head `85207534`) | Both OS legs `success`; guard suite `PASS` in both logs | ✅ |
| Evidence locations | `python -m scripts.dev_tools.validate_evidence_locations --root .` | Exit 0 | ✅ |

**Notes:**
Plain `npm test` in this local worktree reports `No tests found, exiting with code 1` due to the pre-existing jest `<rootDir>` glob-escape artifact for paths containing a dot-directory (issue #414 Condition 3; this worktree path contains `.claude`). This is a separately-filed, pre-existing defect in files (`jest.config.cjs`, `run-jest.cjs`) that are explicitly out of this workstream's ownership and were verified unchanged on this branch. The spec handles it correctly: local verification uses the documented rootDir-free `--testMatch` invocation (which the reviewer confirmed selects exactly the 170-suite set the committed config intends — CI reports the identical suite/test counts), and the authoritative `npm test` verification is CI, where the checkout path has no dot-directory. This local condition is not a defect of this change and is not counted against it.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **None blocking.** Two non-blocking observations:
  1. **Skill-referenced validator missing (pre-existing, out of this branch's scope):** `.claude/skills/feature-review-workflow/SKILL.md` references `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1`, which does not exist anywhere in the repository (`scripts/feature-review/` is absent). The `modified-workflow-needs-green-run` rule was applied manually in this audit. This is repository tooling debt, not a defect introduced by this branch.
  2. **`.claude/rules/typescript.md` names Vitest while the actual root harness is jest** (pre-existing divergence affecting all 170 suites). The new guard correctly follows the repository's actual convention. Rule files are policy documents and were correctly not modified by this workstream.

### Approved Exceptions

- **Local `npm test` pass not required in this worktree** — documented in `spec.md` Test Strategy (verification constraint) and AC6/AC7: the #414 Condition 3 dot-directory artifact makes plain `npm test` unrunnable in any `.claude`-path worktree, and the fix files are forbidden here. The exception is evidence-backed (path-independent local run + head-matching green CI run) and does not reduce verification strength.
- **devDependency cleanup deferred** (`@vscode/test-cli`, `@vscode/test-electron`, `@types/mocha`) — deliberate follow-up recorded in `spec.md` Rollout & Follow-up because a sibling orchestration owns `devDependencies`/`package-lock.json` against the same base commit. Verified: those keys are byte-identical to base, so no collision was introduced.

### Removed/Skipped Tests

**None.** No test was removed or skipped; the suite grew by exactly the new guard (+1 suite, +2 tests), and the two removed npm scripts had never executed a single test (fail-before evidence shows exit inside `@vscode/test-cli`'s `loadDefaultConfigFile`).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **b340f5a8** - docs(bug): add issue 421 feature folder and scope research
2. **4d092a4c** - docs(bug): add atomic plan for issue 421
3. **9af4aff8** - docs(bug): clear plan preflight for issue 421
4. **b4082a2d** - docs(bug): capture phase 0 policy reads and baselines for #421
5. **0fdb3cb7** - fix(scripts): repoint root npm test at jest and remove dead vscode-test entry points (#421)
6. **b67d409f** - test(unit): add vscode-test removal regression guard (#421)
7. **df874e81** - ci: run the root TypeScript toolchain in CI (#421)
8. **85207534** - docs(bug): record green CI run and check off all 11 acceptance criteria for #421

### Files Modified

1. **package.json** (MODIFIED) — scripts block only: `test` repointed to `node run-jest.cjs`; `test:integration` and `compile:integration-tests` removed; `pretest` trimmed to `npm run compile && npm run lint`; `.vscode-test.mjs` removed from `format`/`format:check` globs. Per-key comparison confirms all other keys byte-identical to base.
2. **tests/unit/vscode-test-removal.test.ts** (NEW) — 78-line regression guard, 2 tests.
3. **.github/workflows/_root-typescript-tests.yml** (NEW) — 30-line reusable workflow (`workflow_call` + `workflow_dispatch`), ubuntu-latest + windows-latest matrix, `npm ci` + `npm test`.
4. **.github/workflows/ci.yml** (MODIFIED) — one additive `root-typescript-tests` job via `uses:`.
5. **.github/workflows/README.md** (MODIFIED) — dispatch table row and workflow count.
6. **docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/** (NEW, 28 files) — issue.md, spec.md, plan, research, and canonical evidence (`baseline/`, `regression-testing/`, `qa-gates/`, `other/`).

**Boundary verification (forbidden files):** `git diff --name-only fb483b84..85207534 -- run-jest.cjs jest.config.cjs package-lock.json .claude/rules .agents/skills extensions/drm-copilot/resources/claude-customizations` returns empty. Confirmed independently by the reviewer.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All policy gates pass on independently re-run evidence: single-pass clean toolchain (format, lint, typecheck, tests), repo-wide TypeScript coverage 97.01% line / 89.07% branch with zero regression, canonical evidence locations, forbidden-file boundaries respected, and a head-matching green CI run (30189725327) satisfying `modified-workflow-needs-green-run`.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objective, research, and plan documented
- ✅ Design Principles: minimal removal-plus-guard design
- ✅ Module & File Structure: all files well under 500 lines
- ✅ Naming, Docs, Comments: compliant; README updated
- ✅ Toolchain Execution: single-pass clean (stages 4/6/7 N/A with recorded rationale)
- ✅ Summarize & Document: spec, plan, evidence complete

#### Language-Specific Code Change Policy (Section 3)
- ✅ TypeScript Tooling & Baseline: all four commands exit 0
- ✅ TypeScript Design & Typing: typed, suppression-free
- ✅ JSON: strict, scripts-only change
- ✅ GitHub Actions: convention-compliant; head-matching green run

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, fast, deterministic, readable
- ✅ Coverage & Scenarios: no regression; negative-path guard purpose-built
- ✅ Test Structure: AAA with clear diagnostics
- ✅ External Dependencies: none; no temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)
- ✅ TypeScript Framework & Scope: repo-convention jest; correct `tests/` location
- ✅ Test Style & Structure: compliant
- ✅ Naming & Readability: compliant
- ✅ Toolchain: compliant

---

### Metrics Summary

- ✅ 2038/2038 tests passing (100%), 170/170 suites
- ✅ 97.01% line coverage / 89.07% branch coverage (TypeScript repo-wide; thresholds 85%/75%)
- ✅ Zero coverage regression (identical to baseline; +1 suite, +2 tests)
- ✅ All code quality checks passing in a single pass
- ✅ Head-matching green CI run: 16/16 jobs `success` at `85207534`
- ✅ Test execution time: 6.3 s local / <20 s per CI leg (fast)

---

### Recommendation

**Ready for merge.**

No remediation is required. Optional non-blocking follow-ups (already recorded in `spec.md`): sibling-owned devDependency cleanup; repository tooling debt items in section 8 (missing `Test-ModifiedWorkflowNeedsGreenRun.ps1` validator; `typescript.md` Vitest/jest divergence) may be filed separately.

---

## Appendix A: Test Inventory

New tests introduced by this branch (full suite: 170 suites / 2038 tests, all passing):

1. vscode-test harness removal › no root npm script invokes the vscode-test runner (`tests/unit/vscode-test-removal.test.ts`)
2. vscode-test harness removal › no dead vscode-test config file exists at the repository root (`tests/unit/vscode-test-removal.test.ts`)

Pre-existing suites (unchanged, all passing): `tests/unit/hello-typescript.test.ts` plus 168 suites under `extensions/drm-copilot/test/**` — counts verified identical between the local path-independent run and both CI legs of run 30189725327.

---

## Appendix B: Toolchain Commands Reference

**For TypeScript (repository root):**
```bash
# Formatting (check-only)
npm run format:check

# Linting
npm run lint

# Type checking
npm run typecheck

# Testing + coverage (path-independent invocation; workaround for #414 Condition 3 in dot-directory worktrees)
node run-jest.cjs --coverage --testMatch "**/tests/unit/**/*.test.ts" --testMatch "**/extensions/drm-copilot/test/**/*.test.ts"

# Guard suite solo
node run-jest.cjs --testMatch "**/tests/unit/**/*.test.ts" --testPathPatterns "vscode-test-removal"

# Authoritative entry-point verification (CI)
gh workflow run ci.yml --ref bug/vscode-test-integration-entrypoint
gh run view 30189725327 --json status,conclusion,url,headSha
```

**Evidence-location validation:**
```bash
python -m scripts.dev_tools.validate_evidence_locations --root .
```

**PR-context refresh (was missing; regenerated by the reviewer):**
```bash
python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-07-26
**Policy Version:** Current (as of audit date)

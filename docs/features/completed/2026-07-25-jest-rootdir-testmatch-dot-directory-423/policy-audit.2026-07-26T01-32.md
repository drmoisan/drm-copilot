# Policy Compliance Audit: Jest rootDir/testMatch dot-directory fix (Issue #423)

---

**Audit Date:** 2026-07-26
**Code Under Test:**
- `jest.config.cjs` (root, modified)
- `run-jest.cjs` (root, modified)
- `extensions/drm-copilot/jest.config.cjs` (modified)
- `extensions/drm-copilot/run-jest.cjs` (modified)
- `tests/unit/jest-config-resolution.test.ts` (new)
- `extensions/drm-copilot/test/jest-config-resolution.test.ts` (new)
- Feature-folder documentation and evidence under `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/` (36 files)

**Branch:** `bug/jest-no-tests-found-dot-directory-worktree` (HEAD `914e9fea`)
**Base:** `origin/main` @ merge-base `fb483b8468204e4385b5583c3b3ec4c0a987eede`
**Work Mode:** `full-bug` (persisted marker in `issue.md`)

**Template source note:** The MCP tool `resolve_policy_audit_template_asset` is not available in this review session (no MCP tools in the reviewer toolset). The on-disk bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` — the same asset the MCP server resolves — was used as the template source. This deviation is procedural only; the artifact structure is identical.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 2 files (both test files) | 2046 ext + 2061 root-project run | PASS: 2046 pass, 0 fail (ext); 2061 pass, 0 fail (root project incl. ext suites) | N/A - structurally unobtainable pre-fix (zero test discovery; documented exception dossier, see Section 1.2) | 96.34% lines, 89.22% branches (extension package, lcov) | N/A - both changed TypeScript files are test files, excluded from coverage measurement per policy |
| JavaScript (CommonJS scaffolding) | 4 files (`jest.config.cjs` x2, `run-jest.cjs` x2) | Behavior verified via config-shape regression tests + executed guard evidence | PASS | N/A — config/entry-point scaffolding outside `collectCoverageFrom` (`src/**`) at base and head | N/A — unchanged denominator | N/A |

**Coverage verdict per language with changed files (explicit, per scope invariant):**
- **TypeScript: PASS.** Evidence: `extensions/drm-copilot/coverage/lcov.info` (mtime 2026-07-26 01:16, post-fix executor run) independently parsed by this reviewer: lines 37690/39121 = 96.34% (gate >= 85%), branches 5206/5835 = 89.22% (gate >= 75%). Both changed TypeScript files are test files (`tests/unit/`, `extensions/drm-copilot/test/`), which policy excludes from coverage measurement; no production TypeScript file changed, so no per-file or changed-line coverage obligation was created. Extension `test:coverage` exited 0 (`evidence/qa-gates/final-extension-coverage.2026-07-26T01-24.md`), proving all 30 configured per-file `coverageThreshold` entries (lines 85 / branches 75) passed.
- **JavaScript (.cjs): PASS.** The four changed `.cjs` files are Jest configuration and CLI entry-point scaffolding outside both packages' coverage denominators at base and at head (`collectCoverageFrom: ["src/**/*.ts", ...]` unchanged; root package defines no `collectCoverageFrom`). No coverage exclusion was added or modified. Behavioral verification is supplied by the regression tests and the six executed guard invocations (all exit 1), re-verified live by this reviewer.
- Python, PowerShell, C#, Bash, JSON, GitHub Actions: **N/A — zero changed files** in the branch diff (verified: `git diff --name-only fb483b84...HEAD`).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/baseline-extension-coverage.2026-07-26T00-57.md` (expect-fail exception dossier: numeric baseline structurally unobtainable because the defect under repair caused zero test discovery; `WhyNumericBaselineUnavailable:` recorded)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` + `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-extension-coverage.2026-07-26T01-24.md`
- PowerShell baseline coverage artifact: `N/A - out of scope` (zero PowerShell files changed)
- PowerShell post-change coverage artifact: `N/A - out of scope`
- Per-language comparison summary: `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/coverage-delta.2026-07-26T01-25.md` and Section 1.2.1 below

---

## Rejected Scope Narrowing

None detected. The caller prompt requested a full feature-vs-base audit and supplied the correct base (`origin/main`, merge-base `fb483b84`). The caller's parallel-orchestration file-ownership constraint (root `package.json`, `tsconfig*.json`, `.vscode-test.*`, `.claude/rules/**`, `.agents/skills/**`, `extensions/drm-copilot/resources/claude-customizations/**` must not be modified) is an additional check, not a scope narrowing, and was applied (see Section 7 and AC17 in the feature audit).

---

## Evidence Location Compliance

**PASS.** No violations found.

- `python scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0.
- Branch-diff scan for files under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, `artifacts/post-change/` → zero matches (`git diff --name-only fb483b84...HEAD | grep -E '^artifacts/(baselines|baseline|qa|qa-gates|evidence|coverage|regression-testing|post-change)/'` → no output, exit 1).
- All 30 evidence artifacts in the diff are under the canonical `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/{baseline,regression-testing,qa-gates,other}/` scheme.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no caller instruction supplied a non-canonical evidence path.

---

## Executive Summary

This audit covers the fix for issue #423: on Windows, Jest discovered zero test files in checkouts whose path contains a dot-prefixed directory segment (for example `.claude/worktrees/<name>/`), because `<rootDir>`-interpolated `testMatch` globs retained a literal `\.` byte pair that picomatch consumed as an escape. The fix replaces the absolute-path patterns with relative `**/`-anchored patterns in both Jest configs, adds an inline prohibited-flag guard (`--passWithNoTests`, `--onlyChanged`, `--lastCommit`) to both `run-jest.cjs` entry points, and adds two regression test files (25 tests total) pinning the fixed shape, the matcher behavior on synthetic dot-prefixed and POSIX paths, and the defect witness.

The full check-only toolchain was re-executed by this reviewer in this dot-prefixed worktree and passed in a single pass for both packages (Section 2.5 and Section 7). The root Jest run discovered 171 suites / 2061 tests and the extension run 169 suites / 2046 tests — direct in-situ confirmation that the fix works, since this worktree path contains `\.claude\worktrees\`. All six prohibited-flag guard invocations were re-executed live and exited 1 with the required stderr message citing issue #423.

**Policy documents evaluated:**
- [x] `.claude/rules/general-code-change.md` (mirrors `general-code-change.instructions.md`)
- [x] `.claude/rules/general-unit-test.md` (mirrors `general-unit-test.instructions.md`)

**Language-specific policies evaluated:**
- [x] `.claude/rules/typescript.md` (TypeScript files in scope; see documented Vitest/Jest discrepancy in Section 8)
- N/A `python-code-change` / `python-unit-test` (no Python files changed)
- N/A `powershell-code-change` / `powershell-unit-test` (no PowerShell files changed)
- N/A C#, Bash, JSON, GitHub Actions policies (no such files changed)

The policy rule `modified-workflow-needs-green-run` does not fire: the branch diff contains no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (verified by grep against the diff file list; zero matches).

**Temporary artifacts cleanup:**
- [x] No temporary or one-time scripts were introduced by this branch (diff inspected; only the six in-scope files and feature-folder docs/evidence changed).
- [x] No ongoing tooling scripts were added.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Both new test files operate only on a `require`d config object and pure `globsToMatcher` calls over synthetic strings; no shared mutable state, no setup/teardown ordering. Full-suite runs pass (171/171 and 169/169 suites). |
| **Isolation** - Each test targets single behavior | PASS | 14 root + 11 extension tests, each asserting one property (one shape rule, one pattern-path pair, one config key). Organized into six named `describe` groups mirroring the spec's assertion groups. |
| **Fast Execution** - Tests complete quickly | PASS | Root project run: 3.2 s for 2061 tests; extension run: 2.5 s for 2046 tests (reviewer re-run, 2026-07-26). |
| **Determinism** - Consistent results | PASS | All matcher inputs are hard-coded synthetic path strings; no clock, RNG, network, or filesystem dependence beyond the config `require`. Assertions are byte-identical on Windows and Linux per file header documentation. |
| **Readability & Maintainability** - Clear structure | PASS | Descriptive `describe`/`it` names keyed to assertion groups; file-level doc comments explain the defect mechanism, the fix, and the test constraints. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS (documented exception) | **Baseline (pre-fix):** structurally unobtainable — the defect under repair caused zero test discovery, so `test:coverage` exited 1 before emitting any summary.<br>**Command:** `npm --prefix extensions/drm-copilot run test:coverage` (EXIT_CODE 1)<br>**Timestamp:** 2026-07-26T00-57<br>**Exception dossier:** `evidence/baseline/baseline-extension-coverage.2026-07-26T00-57.md` with `WhyNumericBaselineUnavailable:`. This is a recorded impossible-baseline exception, not a missing artifact. |
| **No Coverage Regression** | PASS | **Post-change coverage:** 96.34% lines, 89.22% branches (extension, lcov, independently parsed by reviewer).<br>**Change:** delta not computable (no numeric baseline can exist pre-fix); regression check supplied instead by the stricter per-file gate: `test:coverage` exit 0 proves all 30 per-file `coverageThreshold` entries (lines 85 / branches 75) passed. Denominator byte-identical to base (`collectCoverageFrom` unchanged, `evidence/other/config-diff.2026-07-26T01-03.md`). |
| **New Code Coverage** | N/A | The only new files are the two test files, which policy excludes from coverage measurement. No production file was added. The four modified `.cjs` files are config/entry-point scaffolding outside `collectCoverageFrom` at base and head. |
| **Comprehensive Coverage** | PASS | Config `testMatch` behavior: covered by groups 1–5 in both files. Loudness config keys: group 6. `run-jest.cjs` guard: not unit-testable under policy (unit tests must not spawn processes; helper-module extraction forbidden by parallel-ownership scope) — verified instead by six executed evidence invocations (`evidence/regression-testing/guard-root.2026-07-26T01-06.md`, `guard-extension.2026-07-26T01-07.md`) and re-executed live by this reviewer (all exit 1, correct stderr, no Jest spawn). |
| **Positive Flows** - Valid inputs | PASS | Groups 2–3: per-pattern positive matches for synthetic dot-prefixed Windows paths and POSIX CI paths (3 patterns x 2 platforms = 6 positive matcher tests plus shape positives). |
| **Negative Flows** - Invalid inputs | PASS | Group 5: production source paths (`src/extension.ts`) asserted NOT to match each pattern (guards against over-broad globs). |
| **Edge Cases** - Boundary conditions | PASS | Group 4 defect witness: hard-coded pre-fix broken pattern with retained `\.` byte pair asserted NOT to match, pinning picomatch escaped-dot semantics against future Jest upgrades. |
| **Error Handling** - Error paths | PASS | `patternAt()` throws a descriptive error if a pattern index is absent (guards test integrity). Guard error path verified by executed evidence (exit 1 + stderr message), not unit tests, for the policy reasons above. |
| **Concurrency** - If applicable | N/A | No concurrent behavior in scope. |
| **State Transitions** - If applicable | N/A | No stateful component in scope. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: structurally unobtainable (zero test discovery pre-fix; recorded exception dossier `evidence/baseline/baseline-extension-coverage.2026-07-26T00-57.md`) -> Post-change: 96.34% lines, 89.22% branches (extension package). Change: not numerically computable; superseded by absolute gates (>= 85% lines PASS at +11.34 pts; >= 75% branches PASS at +14.22 pts) and the per-file threshold gate (exit 0 = all 30 entries pass). New/changed-code coverage: `N/A - changed TS files are test files, excluded from measurement`. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` (parsed: 37690/39121 lines, 5206/5835 branches), `evidence/qa-gates/final-extension-coverage.2026-07-26T01-24.md`, `evidence/qa-gates/coverage-delta.2026-07-26T01-25.md`.
- JavaScript (.cjs scaffolding): outside coverage denominator at base and head; no exclusion added or modified. Disposition: **PASS** (see Coverage verdict block above).
- All other languages: `N/A - out of scope` (zero changed files).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Jest matcher assertions (`toEqual`, `toContain`, `toBe`) produce value diffs; `patternAt()` failure message names the file, index, and observed pattern count. |
| **Arrange-Act-Assert Pattern** | PASS | Each test arranges a pattern/fixture constant, acts via `globsToMatcher`, and asserts the boolean or shape result. Fixtures are hoisted, named constants with doc comments. |
| **Document Intent** | PASS | Six-group `describe` structure mirrors the spec's Test Strategy; file headers document defect, fix, and constraints. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, external process, or temp-file usage. Only filesystem access is `require` of the config module under test (explicitly permitted as the unit under test). |
| **Use Mocks/Stubs** | N/A | Nothing to mock: the unit is a static config object plus a pure matcher function. |
| **Environment Stability** | PASS | No environment variables, global state, or temporary files. Confirmed no prohibited temporary-file creation (spec AC13, verified by reading both test files in full). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This artifact, plus `code-review.2026-07-26T01-32.md` and `feature-audit.2026-07-26T01-32.md`, constitute the pre-PR review set. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | Issue #423 captured in `issue.md`; root cause confirmed experimentally before design (spec Root Cause Analysis with in-process probe results). |
| **Read existing change plans** | PASS | `plan.2026-07-25T21-48.md` references the accepted research recommendation (`research/2026-07-25T22-15-...-research.md`) and forbids re-opening the design. |
| **Document the plan** | PASS | Atomic plan with 4 phases / 27 tasks, all checked, each with evidence artifact acceptance criteria. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Minimal fix: two `testMatch` value edits and an inline O(argc) exact-match guard. No new modules, no abstraction. |
| **Reusability** | PASS (bounded) | Guard code is intentionally duplicated across the two `run-jest.cjs` files because helper-module extraction is forbidden by the parallel-orchestration file-ownership constraint (spec Scope & Non-Goals). Recorded as an accepted, documented duplication (see code review Finding CR-2). |
| **Extensibility** | PASS | `PROHIBITED_FLAGS` array makes future flag additions one-line changes; `patternAt()` accessor stays correct if patterns are added. |
| **Separation of concerns** | PASS | Pure matcher logic tested without I/O; entry-point scripts remain thin argv-to-exit-code wiring. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Each changed file retains a single purpose (config, entry point, regression test). |
| **Under 500 lines** | PASS | Line counts (reviewer-measured): `jest.config.cjs` 14; `run-jest.cjs` 31; `extensions/drm-copilot/jest.config.cjs` 163; `extensions/drm-copilot/run-jest.cjs` 39; root test 191; extension test 164. All under 500. |
| **Public vs internal** | PASS | No public API surface changed except the documented CLI rejection of three flags at the two entry points. |
| **No circular dependencies** | PASS | Test files depend on config + `jest-util` only; entry points unchanged in dependency shape. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `PROHIBITED_FLAGS`, `DEFECTIVE_PATTERN`, `WINDOWS_UNIT_PATH`, `patternAt` — all intention-revealing; TypeScript camelCase/PascalCase conventions followed. |
| **Docs/docstrings** | PASS | JSDoc on all fixtures and helpers; file-level headers explain the defect mechanism and constraints. |
| **Comment why, not what** | PASS | Guard comment explains the `exitWith0` rationale and the inline/exact-match style decision; defect-witness comment explains why the broken pattern is hard-coded. |

### 2.5 After Making Changes - Toolchain Execution

All commands re-executed by this reviewer on 2026-07-26 in the dot-prefixed worktree (check-only forms):

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Root:** `npm run format:check` → exit 0, "All matched files use Prettier code style!". **Extension:** prettier `--check` over the extension `format` globs (`src/**/*.ts`, `test/**/*.ts`, `*.json`, `*.cjs`) → exit 0, all clean. (The extension `format` script is write-mode; the reviewer used the check-only equivalent with identical globs.) |
| **2. Linting** | PASS | **Root:** `npm run lint` → exit 0. **Extension:** `npm --prefix extensions/drm-copilot run lint` → exit 0. |
| **3. Type checking** | PASS | **Root:** `npm run typecheck` → exit 0. **Extension:** `npm --prefix extensions/drm-copilot run typecheck` → exit 0. |
| **4. Testing** | PASS | **Root:** `node run-jest.cjs` → exit 0, 171/171 suites, 2061/2061 tests. **Extension:** `npm --prefix extensions/drm-copilot run test` → exit 0, 169/169 suites, 2046/2046 tests. |
| **Architecture / contract / integration stages** | N/A | No architecture-boundary tooling targets `.cjs` scaffolding or test files; no service contract or integration surface changed. The guard's process-level behavior (the closest integration concern) was verified by six live invocations. |
| **Full toolchain loop** | PASS | Single clean pass in the reviewer re-run; executor evidence also records one clean pass with zero restarts (`evidence/qa-gates/final-loop-summary.2026-07-26T01-27.md`). |
| **Explicit reporting** | PASS | All commands and exit codes documented here and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Spec Proposed Fix design table; commit `914e9fea` "fix(423): resolve zero test discovery under dot-prefixed paths". |
| **Design choices explained** | PASS | Research artifact records option analysis (rejected `roots` change with coverage-denominator rationale; rejected preflight diagnostic on startup cost). |
| **Update supporting documents** | PASS | `issue.md`, `spec.md`, plan, research, and 30 evidence artifacts updated/added in the feature folder. |
| **Provide next steps** | PASS | Spec Rollout & Follow-up records four out-of-scope follow-ups (root CI wiring, Vitest rule reconciliation, `jest-util` devDependency declaration, Jest-upgrade watch). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: TypeScript Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | PASS | Reviewer re-ran check-only Prettier for both packages → exit 0 (Section 2.5). |
| **Linting with ESLint** | PASS | Both packages lint clean (exit 0). The extension test file carries one justified `eslint-disable-next-line @typescript-eslint/no-require-imports` with an inline reason (the CJS config module is the unit under test). |
| **Type checking with TSC** | PASS | Both packages `tsc --noEmit` clean (exit 0). No `any` introduced; config shape typed via a local `JestConfigUnderTest` interface with `readonly` members and `unknown` for `passWithNoTests`. |
| **Testing with Jest** | PASS | 171 + 169 suites pass. Note: `.claude/rules/typescript.md` names Vitest as the test framework, but neither package installs Vitest; all 169 pre-existing test files use Jest 30.4.2. Using Jest here is consistent with repository reality; the rule-file discrepancy is pre-existing, recorded in the spec and in `evidence/baseline/phase0-instructions-read.md`, and the rule file is forbidden to this branch (`.claude/rules/**` owned by parallel work). See Section 8. |

#### 3A.2 TypeScript Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | `JestConfigUnderTest` interface with `readonly string[]` members; single `as` assertion per file confined to the `require` boundary of the untyped CJS module, which is the unit under test. |
| **ES modules** | PASS with justified exception | Test files use ESM imports throughout; the single `require` per file exists because the unit under test is a CommonJS config module that Jest itself consumes via CJS loading. The exception is documented inline (extension) and by file-header doc comments (both). |
| **Domain types** | N/A | No domain modeling in scope. |
| **Naming / file naming** | PASS | Kebab-case filenames (`jest-config-resolution.test.ts`); camelCase functions; SCREAMING_SNAKE constants for fixtures. |

#### 3A.3 Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Fail fast with clear errors** | PASS | Guard exits 1 immediately with a specific, actionable stderr message naming the flag and citing issue #423. `patternAt()` throws with a descriptive message on missing pattern index. |
| **No broad catch-alls** | PASS | No `catch` blocks introduced. Existing `result.error` handling in the entry points is unchanged. |

### Section 3B: JavaScript (CommonJS scaffolding) Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Prettier formatting** | PASS | Both root globs (`jest.config.cjs`, `run-*.cjs`) and extension globs (`*.cjs`) are covered by the check-only runs in Section 2.5. |
| **CommonJS appropriate here** | PASS | `jest.config.cjs` / `run-jest.cjs` are host-loaded CJS by design (Jest config contract and node entry points); the ESM-only rule targets TypeScript sources. |
| **Behavior preservation** | PASS | Diff shows the `--testPathPattern` rewrite, spawn wiring, `result.error` handling, and `result.status ?? 1` propagation byte-identical to base in both entry points (`evidence/other/run-jest-diff.2026-07-26T01-05.md`; independently confirmed by reviewer diff read). |

Python (3A in template), PowerShell (3B), Bash (3C), and JSON (3D) sections deleted — no such files changed.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: TypeScript Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | PASS (Jest, matching repo reality) | `@jest/globals` imports in both files, matching the 169 pre-existing Jest test files. Vitest rule-file discrepancy recorded in Section 8. |
| **Coverage expectation** | PASS | Repo-wide extension coverage 96.34% lines / 89.22% branches vs uniform gates >= 85% / >= 75%. Changed TS files are test files (excluded from measurement); no production TS changed. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | One behavior per `it`; six spec-mapped `describe` groups per file. |
| **Mocking sparingly** | PASS | Zero mocks; pure inputs. |
| **Organization** | PASS with note | Root test at `tests/unit/jest-config-resolution.test.ts` follows the root `tests/` convention. Extension test at `extensions/drm-copilot/test/jest-config-resolution.test.ts` follows the extension package's established `test/**` convention (169 existing files; `testMatch` configured accordingly). The unit under test in each case is the package-root `jest.config.cjs`; placement matches each package's existing test-tree layout. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `*.test.ts` suffix; `describe` titles cite issue #423 and the assertion group; `it` titles are behavior statements. |
| **Docstrings/comments** | PASS | JSDoc on all fixtures/helpers; file headers document defect, fix, and policy constraints. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Test runner** | PASS | `node run-jest.cjs` (root project) and `npm --prefix extensions/drm-copilot run test` — both exit 0 in reviewer re-run. |
| **No alternative test runners** | PASS | Jest only. |

Python (4A in template) and PowerShell (4B) sections deleted — no such tests changed.

---

## 5. Test Coverage Detail

### Root `jest.config.cjs` resolution — `tests/unit/jest-config-resolution.test.ts` (14 tests)

| Test Name | Scenario Type | Target | Status |
|-----------|--------------|--------|--------|
| group 1 (5 tests): exact array, string type, no `<rootDir>`, no backslash, `**/` anchor | Positive / shape guard | `config.testMatch` | PASS |
| group 2 (2 tests): dot-prefixed Windows path per pattern | Positive | `globsToMatcher([pattern])` | PASS |
| group 3 (2 tests): POSIX path per pattern | Positive | `globsToMatcher([pattern])` | PASS |
| group 4 (1 test): pre-fix escaped-dot pattern does not match | Edge case / defect witness | hard-coded `DEFECTIVE_PATTERN` | PASS |
| group 5 (2 tests): production path rejected per pattern | Negative | `globsToMatcher([pattern])` | PASS |
| group 6 (2 tests): `passWithNoTests` falsy; ignore patterns retained | Config guard | `config.passWithNoTests`, `config.testPathIgnorePatterns` | PASS |

### Extension `jest.config.cjs` resolution — `extensions/drm-copilot/test/jest-config-resolution.test.ts` (11 tests)

Same six groups adapted to the single extension pattern (5 shape + 1 Windows positive + 1 POSIX positive + 1 defect witness + 1 negative + 2 config-guard tests). All PASS.

**Not covered by unit tests:** the `run-jest.cjs` guard branch. Justification: repository unit-test policy prohibits spawning external processes in unit tests, and helper-module extraction is forbidden by the parallel-ownership constraint. Verification is by executed evidence: six guard invocations captured by the executor and all six re-executed live by this reviewer on 2026-07-26 (exit 1, correct stderr, no Jest spawn in every case).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (root project run) | 2061 (171 suites) | PASS |
| Total Tests (extension run) | 2046 (169 suites) | PASS |
| Tests Passed | 2061/2061 and 2046/2046 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 3.2 s (root run), 2.5 s (extension run) | PASS (fast) |
| New tests added by this branch | 25 (14 root + 11 extension) | PASS |
| Test File Sizes | 191 and 164 lines | PASS (maintainable, < 500) |
| Code Coverage (extension package) | 96.34% lines, 89.22% branches | PASS (gates 85%/75%) |

---

## 7. Code Quality Checks

**For TypeScript/JavaScript (reviewer re-run, 2026-07-26, this worktree):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier (root) | `npm run format:check` | exit 0, all clean | PASS |
| ESLint (root) | `npm run lint` | exit 0 | PASS |
| TSC (root) | `npm run typecheck` | exit 0 | PASS |
| Jest (root project) | `node run-jest.cjs` | exit 0, 171 suites / 2061 tests | PASS |
| Prettier (extension, check-only equivalent) | `node ../../run-node-tool.cjs prettier/bin/prettier.cjs --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | exit 0, all clean | PASS |
| ESLint (extension) | `npm --prefix extensions/drm-copilot run lint` | exit 0 | PASS |
| TSC (extension) | `npm --prefix extensions/drm-copilot run typecheck` | exit 0 | PASS |
| Jest (extension) | `npm --prefix extensions/drm-copilot run test` | exit 0, 169 suites / 2046 tests | PASS |
| Guard behavior (6 invocations) | `node run-jest.cjs --passWithNoTests` / `--onlyChanged` / `--lastCommit` at both package roots | exit 1 each, stderr names flag + cites issue #423, no Jest spawn | PASS |
| Forbidden-file check | `git diff --name-only fb483b84...HEAD` grep against caller's ownership list | zero matches | PASS |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

**Notes:** No pre-existing failures were encountered in any stage. The extension `format` script is write-mode; the reviewer substituted the check-only Prettier form with identical globs to honor the no-mutation review constraint.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **Root Jest entry point not CI-wired (pre-existing, recorded, out of scope).** No CI workflow executes `node run-jest.cjs` at the repository root, so `tests/unit/jest-config-resolution.test.ts` has no CI signal. Mitigation already in place: the extension twin test covers the identical mechanism and runs in CI on windows-latest and ubuntu-latest via `_drm-copilot-extension-tests.yml`. Follow-up is assigned to the orchestration that owns workflow files (spec Rollout & Follow-up #1). Not a blocking finding for this branch: workflow files are forbidden to it.
2. **`.claude/rules/typescript.md` names Vitest; the repository uses Jest (pre-existing documentation discrepancy).** Recorded by research, spec, and `evidence/baseline/phase0-instructions-read.md`. `.claude/rules/**` is forbidden to this branch. Follow-up assigned to a rules-owning change (spec Rollout & Follow-up #2).
3. **`jest-util` imported as an undeclared transitive dependency** in both test files. Declaring it requires `package.json` edits, which are forbidden to this branch. Accepted residual risk documented in the spec (jest-util is a hard dependency of jest and ships its own type declarations). Follow-up assigned (spec Rollout & Follow-up #3).

### Approved Exceptions

1. **Numeric pre-fix coverage baseline unobtainable.** The defect under repair is zero test discovery; no coverage summary can exist at base in this worktree class. Recorded as a schema-valid expect-fail exception dossier with `WhyNumericBaselineUnavailable:` (`evidence/baseline/baseline-extension-coverage.2026-07-26T00-57.md`). Verification substituted by absolute gate satisfaction plus the per-file threshold gate (exit 0 = all 30 entries pass).
2. **Guard code duplicated inline in two entry points.** Helper-module extraction forbidden by parallel-orchestration file ownership. Documented in spec Scope & Non-Goals and enforced by plan hard constraint.
3. **MCP template-asset resolution unavailable to this reviewer session.** On-disk bundled assets (identical content source) used instead; recorded in the header of each review artifact.

### Removed/Skipped Tests

**None.** All planned tests implemented; no test removed or skipped. The `EXIT_CODE: SKIPPED` outcome is absent from all 30 evidence artifacts (plan No-SKIPPED rule).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **0b287eb1** — docs(423): promote jest rootDir testMatch dot-directory bug and record research
2. **b22a58f1** — docs(423): complete full-bug spec with 17 verifiable acceptance criteria
3. **8da72e98** — docs(423): finalize atomic plan after preflight all-clear
4. **914e9fea** — fix(423): resolve zero test discovery under dot-prefixed paths

### Files Modified

1. **`jest.config.cjs`** (MODIFIED) — two `testMatch` entries changed from `<rootDir>`-interpolated absolute globs to `**/`-anchored relative globs. Nothing else changed.
2. **`extensions/drm-copilot/jest.config.cjs`** (MODIFIED) — single `testMatch` entry changed the same way. Coverage config byte-identical to base.
3. **`run-jest.cjs`** (MODIFIED) — inline prohibited-flag guard added before `runNodeTool` spawn; existing rewrite and exit propagation unchanged.
4. **`extensions/drm-copilot/run-jest.cjs`** (MODIFIED) — same inline guard before `cp.spawnSync`; existing behavior unchanged.
5. **`tests/unit/jest-config-resolution.test.ts`** (NEW) — 14 regression tests, assertion groups 1–6, root config.
6. **`extensions/drm-copilot/test/jest-config-resolution.test.ts`** (NEW) — 11 regression tests, assertion groups 1–6, extension config; CI-visible twin.
7. **`docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/**`** (NEW, 36 files) — issue, spec, plan, research, and 30 evidence artifacts under canonical `evidence/{baseline,regression-testing,qa-gates,other}/` paths.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All policy gates pass. The fix is minimal, evidence-first, and was re-verified live by this reviewer in the affected environment class (a dot-prefixed `.claude/worktrees/**` checkout): test discovery now succeeds (171 and 169 suites), the full check-only toolchain passes in a single pass for both packages, coverage exceeds the uniform gates with headroom, no forbidden file is touched, and all evidence is in canonical locations.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: objective, research, and plan documented.
- PASS Design Principles: minimal fix; documented, constraint-driven duplication.
- PASS Module & File Structure: all files < 500 lines.
- PASS Naming, Docs, Comments: rationale-focused comments; typed fixtures.
- PASS Toolchain Execution: single clean pass, reviewer re-verified.
- PASS Summarize & Document: spec, plan, evidence, and follow-ups complete.

#### Language-Specific Code Change Policy (Section 3)
- PASS TypeScript Tooling & Baseline; Design & Typing; Error Handling.
- PASS JavaScript scaffolding: formatting, behavior preservation verified by diff.

#### General Unit Test Policy (Section 1)
- PASS Core Principles: independent, isolated, fast, deterministic, readable.
- PASS Coverage & Scenarios: gates exceeded; documented impossible-baseline exception.
- PASS Test Structure: AAA, clear diagnostics.
- PASS External Dependencies: none; no temp files.
- PASS Policy Audit: this document.

#### Language-Specific Unit Test Policy (Section 4)
- PASS Framework & Scope (Jest, matching repo reality; rule discrepancy recorded).
- PASS Test Style & Structure; Naming & Readability; Toolchain.

### Metrics Summary

- 2061/2061 root-project tests passing (100%); 2046/2046 extension tests passing (100%)
- 25 new regression tests (14 root + 11 extension), all passing
- 96.34% line coverage / 89.22% branch coverage (extension package) vs 85%/75% gates
- All 30 per-file `coverageThreshold` entries passing (exit-0 proof)
- All quality checks passing in a single pass; 0 loop restarts
- 6/6 guard invocations exit 1 with correct message; 0 forbidden files touched

### Recommendation

**Ready for merge.** No remediation required. Follow-ups (root CI wiring, Vitest rule reconciliation, `jest-util` devDependency declaration) are recorded in the spec for their owning orchestrations and do not block this branch.

---

## Appendix A: Test Inventory

New tests added by this branch (25):

Root — `tests/unit/jest-config-resolution.test.ts`:
1. root jest.config.cjs testMatch resolution (issue #423) › group 1: testMatch shape guard › declares exactly the two expected relative patterns
2. … › group 1 › declares every pattern as a string
3. … › group 1 › interpolates \<rootDir\> into no pattern
4. … › group 1 › embeds a backslash in no pattern
5. … › group 1 › anchors every pattern with a leading globstar
6. … › group 2: per-pattern match, dot-prefixed Windows checkout › matches a tests/unit file via the unit pattern alone
7. … › group 2 › matches an extension test file via the extension pattern alone
8. … › group 3: per-pattern match, POSIX checkout › matches a tests/unit file via the unit pattern alone
9. … › group 3 › matches an extension test file via the extension pattern alone
10. … › group 4: defect witness › confirms the pre-fix escaped-dot pattern matches nothing real
11. … › group 5: negative flow › rejects a production source file under the unit pattern
12. … › group 5 › rejects a production source file under the extension pattern
13. … › group 6: loudness config guard › leaves passWithNoTests strictly falsy
14. … › group 6 › still ignores node_modules and out during discovery

Extension — `extensions/drm-copilot/test/jest-config-resolution.test.ts`:
15. extension jest.config.cjs testMatch resolution (issue #423) › group 1: testMatch shape guard › declares exactly the expected relative pattern
16. … › group 1 › declares every pattern as a string
17. … › group 1 › interpolates \<rootDir\> into no pattern
18. … › group 1 › embeds a backslash in no pattern
19. … › group 1 › anchors every pattern with a leading globstar
20. … › group 2: per-pattern match, dot-prefixed Windows checkout › matches an extension test file via the test pattern alone
21. … › group 3: per-pattern match, POSIX checkout › matches an extension test file via the test pattern alone
22. … › group 4: defect witness › confirms the pre-fix escaped-dot pattern matches nothing real
23. … › group 5: negative flow › rejects a production source file under the test pattern
24. … › group 6: loudness config guard › leaves passWithNoTests strictly falsy
25. … › group 6 › still ignores node_modules and out during discovery

Pre-existing suites: 1 root (`tests/unit/hello-typescript.test.ts`) and 168 extension suites, all passing and unmodified.

---

## Appendix B: Toolchain Commands Reference

**Root package (repo root):**
```bash
# Formatting (check-only)
npm run format:check

# Linting
npm run lint

# Type checking
npm run typecheck

# Testing
node run-jest.cjs
```

**Extension package:**
```bash
# Formatting (check-only equivalent of the write-mode `format` script)
cd extensions/drm-copilot && node ../../run-node-tool.cjs prettier/bin/prettier.cjs \
  --no-error-on-unmatched-pattern --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"

# Linting
npm --prefix extensions/drm-copilot run lint

# Type checking
npm --prefix extensions/drm-copilot run typecheck

# Testing
npm --prefix extensions/drm-copilot run test

# Coverage (executor artifact inspected; not re-generated by reviewer per evidence-verification model)
npm --prefix extensions/drm-copilot run test:coverage   # artifact: extensions/drm-copilot/coverage/lcov.info
```

**Guard verification:**
```bash
node run-jest.cjs --passWithNoTests   # exit 1 (both package roots)
node run-jest.cjs --onlyChanged       # exit 1 (both package roots)
node run-jest.cjs --lastCommit        # exit 1 (both package roots)
```

**Scope and evidence checks:**
```bash
git diff --name-only fb483b8468204e4385b5583c3b3ec4c0a987eede...HEAD
python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-07-26
**Policy Version:** Current (as of audit date)

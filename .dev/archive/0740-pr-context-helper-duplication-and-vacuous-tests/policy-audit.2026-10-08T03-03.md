# Policy Compliance Audit: pr-context helper consolidation and code-point ordering (Issue #740)

**Audit Date:** 2026-10-08
**Branch:** `bug/pr-context-helper-duplication-and-vacuous-tests-740` @ `0c3f5aab4300b0bb07c1a1c92c8af939b7ac4699`
**Base:** `main` (resolved `origin/main`), merge-base `6dac65b0930b299dc7b3c3925a607735a05fca35`
**Work Mode:** `minor-audit` (AC source: `issue.md` `## Acceptance Criteria`)
**Code Under Test (branch diff vs merge-base, non-documentation files):**

- `extensions/drm-copilot/src/lib/pr-context/models.ts` (modified)
- `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` (modified)
- `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts` (modified)
- `extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts` (modified)
- `extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts` (modified)
- `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts` (modified)
- `extensions/drm-copilot/src/lib/pr-context/render.ts` (modified)
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` (modified)
- `extensions/drm-copilot/test/lib/pr-context/models.test.ts` (modified)
- `extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts` (modified)
- `extensions/drm-copilot/jest.config.cjs` (modified; Jest configuration, not production code)

The remaining 37 changed files are Markdown under the feature folder (issue, plan, research, evidence). No new production files were added. No Python, PowerShell, C#, Bash, JSON, or GitHub Actions files changed.

**Template source:** the structure follows the bundled policy-audit template asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` read from this checkout; MCP tools were not available to this review session, so the asset was read from the repository copy rather than through the MCP server.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 10 files (8 production, 2 test) + jest.config.cjs | 409 pr-context tests (3879 full suite) | PASS: 409 pass, 0 fail (reviewer run); 3879 pass, 0 fail (executor full run) | 97.11% lines, 91.53% branches (repo-wide extension) | 97.14% lines, 91.61% branches (repo-wide extension) | 100.00% (76/76 changed executable lines) |
| Markdown | 37 files | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A (documentation) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/evidence/baseline/ts-jest-coverage.2026-10-08T02-38.md` (97.11% lines, 91.53% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (parsed by reviewer: 97.14% lines, 91.61% branches) and `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/evidence/qa-gates/ts-jest-coverage.2026-10-08T02-38.md`
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on the branch)
- Per-language comparison summary: Section 1.2.1 of this document; per-file detail in `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/evidence/qa-gates/coverage-delta.2026-10-08T02-38.md`

Coverage artifact path note: the TypeScript coverage artifact for this repository is produced under `extensions/drm-copilot/coverage/lcov.info` (Jest `coverageDirectory: <rootDir>/coverage` in `extensions/drm-copilot/jest.config.cjs`). The reviewer parsed that file directly; it was generated after the last production-code change on the branch (production files are unchanged between `53304594` and HEAD; only `models.test.ts` changed in `0c3f5aab`).

---

## Rejected Scope Narrowing

No scope-narrowing instruction was detected in the caller prompt. The audit covers the full branch diff `6dac65b0930b299dc7b3c3925a607735a05fca35..0c3f5aab4300b0bb07c1a1c92c8af939b7ac4699` (48 files).

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- `git diff --name-only 6dac65b..HEAD` lists no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All 34 evidence files are under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Result: PASS. No violations.

---

## Executive Summary

The branch fixes the `compareCodePoint` ordering contract (UTF-16 code-unit comparison replaced by Unicode code-point comparison, matching Python `str` ordering), replaces two vacuous operator-derived tests with literal fixed-order tests, makes the antisymmetry and transitivity tests report offending pairs, and consolidates four duplicated helpers (`sortedSet`, `relativeToPosix`, `escapeRegExp`, `splitLines`) into single exported definitions. The change set is TypeScript only within `extensions/drm-copilot/src/lib/pr-context/` plus two test files and the Jest per-file threshold map.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- PASS TypeScript: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
- N/A Python, PowerShell, C#, Bash, JSON, GitHub Actions (zero changed files)

Reviewer-run checks at HEAD `0c3f5aab`: Prettier check exit 0, ESLint (`npm run lint`) exit 0, TypeScript (`npm run typecheck`, both tsconfig projects) exit 0, Jest pr-context suites 22/22 and 409/409 passed. Coverage was verified by parsing the existing `extensions/drm-copilot/coverage/lcov.info` (not regenerated). All eight changed production files meet the 85% line and 75% branch thresholds; changed-line coverage is 76/76.

**Temporary artifacts cleanup:**
- PASS: no temporary scripts are committed; executor scratch scripts were kept in the session scratch directory (plan-deviations DEV-6, DEV-7, coverage-delta note). Reviewer scratch scripts (`lcov.cjs`, `changed.cjs`) live in the session scratch directory and are not in the repository.
- PASS: no new tooling scripts were added to the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | New tests in `models.test.ts` and `feature-docs.test.ts` construct their inputs locally; no shared mutable state, no `beforeAll` fixtures. The `DOMAIN` constant is read-only. |
| **Isolation** - Each test targets single behavior | PASS | One `describe` per helper (`sortedSet`, `escapeRegExp`, `splitLines`, `relativeToPosix`); each code-point test (D1-D4, S1, A1-A4) targets one ordering pair or one sort. |
| **Fast Execution** - Tests complete quickly | PASS | 22 pr-context suites, 409 tests in 0.844 s (reviewer run). |
| **Determinism** - Consistent results | PASS | Pure string functions; no clock, RNG, I/O, or timers. |
| **Readability & Maintainability** - Clear structure | PASS | Titles name the pair and expected order (for example `D1 orders U+FFFF before U+1F600 in both argument orders`); escapes use `\uXXXX`/`\u{...}` forms (DEV-7 remediation). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline:** 97.11% lines, 91.53% branches (51037/52551 lines; 7503/8197 branches). **Command:** `cd extensions/drm-copilot && npx jest --config jest.config.cjs --coverage ...`. **Timestamp:** 2026-10-08T02-38. Artifact: `evidence/baseline/ts-jest-coverage.2026-10-08T02-38.md`. |
| **No Coverage Regression** | PASS | **Post-change:** 97.14% lines, 91.61% branches (reviewer parse of `extensions/drm-copilot/coverage/lcov.info`: 50986/52486 lines, 7491/8177 branches). **Change:** +0.03 pp lines, +0.08 pp branches. Per-file: render-pr-helpers.ts lines 87.71% to 87.08% (-0.63 pp) is a denominator effect; uncovered lines are 50 before and 50 after. No changed line is uncovered. |
| **New/Changed Code Coverage** | PASS | No new files. Changed executable lines: 76/76 covered = 100.00% (reviewer recomputed from `git diff -U0` hunks against lcov `DA:` records; matches `evidence/qa-gates/coverage-delta.2026-10-08T02-38.md`). |
| **Comprehensive Coverage** | PASS | `compareCodePoint`: 13 code-point and enumerative tests plus 6 pre-existing; `sortedSet`: 5; `escapeRegExp`: 3; `splitLines`: 7 direct plus indirect callers; `relativeToPosix`: 5. `models.ts` 391/391 lines, 49/49 branches. |
| **Positive Flows** - Valid inputs | PASS | D1-D4, A1-A4, S1; `sortedSet` dedupe/sort; `escapeRegExp` metacharacters; `splitLines` CRLF/CR/LF; `relativeToPosix` POSIX root. |
| **Negative Flows** - Invalid inputs | PASS | Helpers are total functions over `string`; negative cases are expressed as non-matching inputs: path outside root, sibling directory sharing a root prefix, U+2028 not split. |
| **Edge Cases** - Boundary conditions | PASS | Empty string, U+E000, U+FFFF, surrogate-pair lead/trail differences, prefix ordering, empty iterable, trailing terminator, lone `\n`, Windows root with trailing backslash. |
| **Error Handling** - Error paths | N/A | The changed functions have no error paths (pure, total string functions); no throw sites were added or removed. |
| **Concurrency** - If applicable | N/A | No concurrent or asynchronous behavior in the changed code. |
| **State Transitions** - If applicable | N/A | No stateful components changed. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.11% lines, 91.53% branches -> Post-change: 97.14% lines, 91.61% branches. Change: +0.03 pp lines, +0.08 pp branches; every changed production file is at or above 85% lines and 75% branches (lowest: render-pr-helpers.ts 87.08% lines; verification-evidence.ts branches rose from 84.61% to 93.94%). New/changed-code coverage: 100.00% (76/76 changed executable lines). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`; `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/evidence/baseline/ts-jest-coverage.2026-10-08T02-38.md`; `docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/evidence/qa-gates/coverage-delta.2026-10-08T02-38.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Antisymmetry and transitivity tests collect a `violations` array of `U+XXXX`-described pairs/triples and assert `toEqual([])`, so a failure prints every offending pair (AC-5). Scalar tests use `toBe(-1)` with descriptive titles. |
| **Arrange-Act-Assert Pattern** | PASS | New tests use `// Arrange`, `// Act` (or combined `// Arrange / Act`), `// Assert` comments. The seven `splitLines` tests are single-line `expect(...)` statements without section comments; see code review Nit. |
| **Document Intent** | PASS | Titles carry the scenario ID and code points; the antisymmetry/transitivity tests carry intent comments. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No filesystem, network, process, or timer usage in the changed tests. |
| **Use Mocks/Stubs** | N/A | Pure functions; no collaborators to mock. |
| **Environment Stability** | PASS | No global state, no environment variables, no temporary files. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document, with `code-review.2026-10-08T03-03.md` and `feature-audit.2026-10-08T03-03.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` (Issue #740) Steps 1-5 and AC-1..AC-14. |
| **Read existing change plans** | PASS | `research/research.2026-09-29T22-25.md`; `evidence/baseline/phase0-instructions-read.md`. |
| **Document the plan** | PASS | `plan.2026-09-29T22-17.md` (all tasks checked); deviations DEV-1..DEV-8 in `evidence/other/plan-deviations.2026-10-08T02-38.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | `compareCodePoint` is a single linear scan comparing code points at the first differing UTF-16 index; no allocation. |
| **Reusability** | PASS | Eight private copies removed (12 definitions before, 4 after per `evidence/baseline/helper-definitions` and `evidence/qa-gates/helper-definitions`); reviewer grep confirms one definition each. |
| **Extensibility** | PASS | `sortedSet` accepts `Iterable<string>` (widened from `string[]` in the gh-client-details copy). |
| **Separation of concerns** | PASS | Shared pure helpers live in `models.ts`; `relativeToPosix` lives in `feature-docs-parsers.ts` per AC-6. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Helpers placed with the module that already owned the canonical version. |
| **Under 500 lines** | PASS | Reviewer `wc -l`: models.ts 391, collector-core.ts 382, feature-docs-parsers.ts 312, gh-client-details.ts 379, render-feature-excerpts.ts 430, render-pr-helpers.ts 387, render.ts 375, verification-evidence.ts 260, models.test.ts 486, feature-docs.test.ts 354, jest.config.cjs 470. |
| **Public vs internal** | PASS | `sortedSet` and `escapeRegExp` newly exported from `models.ts` (not re-exported through `index.ts`; a reviewer grep of `index.ts` finds only `splitLines`, which was re-exported before this branch, and `index.ts` is unchanged on the branch). |
| **No circular dependencies** | PASS | New edges `render-feature-excerpts.ts -> feature-docs-parsers.ts` and `verification-evidence.ts -> feature-docs-parsers.ts`. `feature-docs-parsers.ts` imports only `../file-system` and `./models`; `models.ts` imports only a type from `../subprocess-runner` (reviewer grep). No cycle. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Existing helper names retained; locals `sharedLength`, `leftPoint`, `rightPoint`. |
| **Docs/docstrings** | PASS | JSDoc for `compareCodePoint` (code-point contract, UTF-16 difference, return set), `sortedSet`, `escapeRegExp`, `splitLines` (terminator subset), `relativeToPosix` (outside-root divergence from Python). `models.ts` header lists the four helpers. |
| **Comment why, not what** | PASS | The `compareCodePoint` JSDoc explains why the comparison differs from `<`. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `npx --prefix extensions/drm-copilot prettier --check extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/package.json`<br>**Result:** "All matched files use Prettier code style!" (exit 0). |
| **2. Linting** | PASS | **Command:** `npm --prefix extensions/drm-copilot run lint`<br>**Result:** exit 0, no findings. |
| **3. Type checking** | PASS | **Command:** `npm --prefix extensions/drm-copilot run typecheck`<br>**Result:** exit 0 (`tsconfig.json` and `tsconfig.jest.json`). |
| **4. Architecture boundaries** | N/A | No `.dependency-cruiser.cjs` exists at the repository root or in `extensions/drm-copilot/` (reviewer `ls`); import-cycle check done by inspection (Section 2.3). |
| **5. Testing** | PASS | **Command:** `npm --prefix extensions/drm-copilot run test -- test/lib/pr-context`<br>**Result:** 22 suites, 409 tests passed. Executor full suite with coverage: 253 suites, 3879 tests passed (`evidence/qa-gates/ts-jest-coverage.2026-10-08T02-38.md`). |
| **6. Contract / schema** | N/A | No host-service boundary or schema changed. |
| **7. Integration** | N/A | No adapter-to-external-system code changed. |
| **Full toolchain loop** | PASS | Executor loop pass 3 completed P2-T1..P2-T15 with no file changed (plan-deviations DEV-7, DEV-8). |
| **Explicit reporting** | PASS | Commands and results recorded under `evidence/qa-gates/` and in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commits `9b8bc6ed`, `53304594`, `0c3f5aab`; Section 9. |
| **Design choices explained** | PASS | Code-point ordering chosen for parity with Python and cross-runtime determinism (issue Proposed Fix; research). |
| **Update supporting documents** | PASS | JSDoc and module header updated; no README impact. |
| **Provide next steps** | PASS | Out-of-scope items recorded in `issue.md` (comparator consolidation outside pr-context, Python parity port). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | All new exports have explicit parameter and return types. No `any`, no `as` assertions added. |
| **Untyped escape hatches (T3: <= 5 per file, justified)** | PASS | Zero `any`. Two non-null assertions (`codePointAt(index)!`) in `compareCodePoint`; the index is bounded by `sharedLength`, so `codePointAt` cannot return `undefined`. ESLint reports no finding. |
| **Suppressions** | PASS | No `eslint-disable`, `@ts-ignore`, or `@ts-expect-error` added (diff inspection). |
| **Tier classification** | PASS | `quality-tiers.yml` classifies `extensions/drm-copilot` as T3; no property-test, mutation, or golden-test obligation applies. |
| **Coverage exclusion policy** | PASS | `jest.config.cjs` diff adds only per-file `coverageThreshold` entries; no `exclude` or `coveragePathIgnorePatterns` entry added. `collectCoverageFrom` remains `src/**/*.ts`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4E: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | PASS | `@jest/globals` imports; run through `run-jest.cjs`. |
| **Test location mirrors source** | PASS | `test/lib/pr-context/models.test.ts` mirrors `src/lib/pr-context/models.ts`; `relativeToPosix` tests are in the pre-existing `feature-docs.test.ts`, which already covers `feature-docs-parsers.ts` exports. The extension uses `test/` (pre-existing convention for this package). |
| **Coverage expectation** | PASS | Section 1.2.1. Per-file threshold entries exist for all eight changed production files (reviewer grep of `jest.config.cjs`: lines 33, 51, 55, 59, 63, 70, 74, 78). |
| **No banned determinism APIs** | PASS | No `setTimeout`, `Date.now()`, or real waits in the changed tests. |
| **Focused unit tests** | PASS | One behavior per test. |

---

## 5. Test Coverage Detail

### compareCodePoint (models.ts) (19 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| D1 orders U+FFFF before U+1F600 in both argument orders | Edge Case (BMP vs supplementary disagreement) | 355-368 | PASS |
| D2 orders U+E000 before U+10000 | Edge Case | 355-368 | PASS |
| D3 orders U+FF5E before U+1F600 | Edge Case | 355-368 | PASS |
| D4 orders a shared-prefix U+FFFD before a shared-prefix U+1F600 | Edge Case | 355-368 | PASS |
| S1 sorts a mixed BMP and non-BMP array into a literal code-point order | Positive | 355-368 | PASS |
| A1-A4 agreement pairs (BMP, trail surrogate, lead surrogate, prefix) | Positive / Edge Case | 355-368 | PASS |
| reflexive / antisymmetric / transitive / returns only -1, 0, 1 (enumerative, 11-element domain) | Property (enumerative) | 355-368 | PASS |
| pre-existing compareCodePoint describe (6 tests) | Positive | 355-368 | PASS |

**Coverage:** 100% of `models.ts` (391/391 lines, 49/49 branches).

Independent fail-before confirmation: the reviewer evaluated the pre-fix comparator `(a, b) => a < b ? -1 : a > b ? 1 : 0` with Node on the D1-D4 inputs (result `1` for each, expected `-1`) and on the S1 input (U+1F600 sorted before U+E000 and U+FFFF), consistent with `evidence/regression-testing/ts-fail-before.2026-10-08T02-38.md` (5 failed, 4 passed).

### sortedSet, escapeRegExp, splitLines (models.ts) (15 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| sortedSet: dedupe and sort; U+FFFF before U+1F600; Set and generator input; no mutation; empty input | Positive / Edge Case | 378-380 | PASS |
| escapeRegExp: all metacharacters round-trip with `u` flag; hyphen unescaped; plain text unchanged | Positive / Edge Case | 389-391 | PASS |
| splitLines: empty; CRLF; CR; trailing terminator; interior empty line; lone newline; U+2028 not split | Positive / Edge Case / Negative | 226-241 | PASS |

**Not covered:** None.

### relativeToPosix (feature-docs-parsers.ts) (5 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| returns the path relative to a POSIX root | Positive | 305-312 | PASS |
| normalizes a Windows-style root and path | Edge Case | 305-312 | PASS |
| strips a trailing slash from the root | Edge Case | 305-312 | PASS |
| returns the leading-slash-stripped path for a path outside the root | Negative | 305-312 | PASS |
| does not treat a sibling directory sharing the root prefix as inside the root | Negative | 305-312 | PASS |

**Not covered:** None in `relativeToPosix`. File-level: 306/312 lines, 52/57 branches (pre-existing uncovered lines outside the changed hunks).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (pr-context, reviewer run) | 409 | PASS |
| Tests Passed | 409 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 0.844 s | PASS (fast) |
| Full suite (executor, with coverage) | 3879 passed of 3879 (+27 vs 3852 baseline) | PASS |
| Test File Size | models.test.ts 486 lines; feature-docs.test.ts 354 lines | PASS |
| Code Coverage (extension, repo-wide) | 97.14% lines, 91.61% branches | PASS |

---

## 7. Code Quality Checks

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx --prefix extensions/drm-copilot prettier --check extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/package.json` | exit 0 | PASS |
| ESLint | `npm --prefix extensions/drm-copilot run lint` | exit 0 | PASS |
| TypeScript | `npm --prefix extensions/drm-copilot run typecheck` | exit 0 | PASS |
| Jest (pr-context) | `npm --prefix extensions/drm-copilot run test -- test/lib/pr-context` | 22 suites, 409 tests passed | PASS |
| Coverage (artifact inspection) | `node <scratch>/lcov.cjs extensions/drm-copilot/coverage/lcov.info ...` | 97.14% lines, 91.61% branches; all changed files >= 85/75 | PASS |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

**Notes:** Coverage was not regenerated by the reviewer, per the agent contract; the existing artifact was parsed. The PR-context summary classifies the eight `src/lib/pr-context/*.ts` files under "Docs/templates/agents/tooling" with "Core logic changes: 0 files"; the reviewer treated them as production code regardless of that classification.

---

## 8. Gaps and Exceptions

### Identified Gaps
**None.** All policy requirements are met for the TypeScript change set.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
1. **"agrees with the native < and > operators for every ordered pair in the domain"** - Removed in commit `53304594`
   - **Reason:** Expected value was derived from the operators under test; the test could not detect a regression (issue Step 2).
   - **Impact:** None; replaced by literal-expectation tests D1-D4, A1-A4.
   - **Justification:** Required by AC-4.
2. **"produces the same order as native comparison via Array.prototype.sort, including an astral surrogate-pair string"** - Removed in commit `53304594`
   - **Reason:** Same as above.
   - **Impact:** None; replaced by S1 with a literal expected array.
   - **Justification:** Required by AC-4.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **28710c77** - docs(740): add active feature folder and research
2. **e0517b30** - docs(740): add acceptance criteria and out-of-scope notes to issue.md
3. **028e2150** - docs(740): add minimal-audit atomic plan
4. **6026dd58** - docs(740): revise plan per preflight round 1 (R1-R7)
5. **7aa28510** - docs(740): revise plan per preflight round 2 (D1-D5)
6. **14fecbec** - Merge remote-tracking branch 'origin/main' into the feature branch
7. **07de1705** - docs(740): record phase 0 baseline evidence
8. **9b8bc6ed** - fix(740): order compareCodePoint by Unicode code point with fail-before/pass-after tests
9. **53304594** - fix(740): consolidate pr-context helpers and pin code-point order
10. **0c3f5aab** - docs(740): record final QC evidence and check off AC

### Files Modified

1. **extensions/drm-copilot/src/lib/pr-context/models.ts** (MODIFIED) - code-point `compareCodePoint`; exported `sortedSet`, `escapeRegExp`; `splitLines` JSDoc; header list.
2. **collector-core.ts, render.ts, gh-client-details.ts, render-pr-helpers.ts, verification-evidence.ts, render-feature-excerpts.ts** (MODIFIED) - private helper copies removed; canonical imports added; gh-client-details.ts imports from `./models` in one statement.
3. **feature-docs-parsers.ts** (MODIFIED) - imports `escapeRegExp`; `relativeToPosix` JSDoc expanded.
4. **test/lib/pr-context/models.test.ts, feature-docs.test.ts** (MODIFIED) - +27 tests, -2 vacuous tests.
5. **jest.config.cjs** (MODIFIED) - per-file thresholds for render.ts, gh-client-details.ts, verification-evidence.ts.
6. **docs/features/active/2026-09-27-pr-context-helper-duplication-and-vacuous-tests-740/** (NEW) - issue, plan, research, 34 evidence files.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All toolchain checks re-run by the reviewer pass. Coverage numbers are present for the only in-scope language (TypeScript), with baseline, post-change, and changed-line figures, and all thresholds are met. No evidence-location violations. No workflow files changed, so the `modified-workflow-needs-green-run` rule does not apply.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: issue, research, plan present
- PASS Design Principles: duplication removed; simple comparator
- PASS Module & File Structure: all files under 500 lines; no cycles
- PASS Naming, Docs, Comments: contracts documented
- PASS Toolchain Execution: format, lint, type, test clean
- PASS Summarize & Document: commits and evidence recorded

#### Language-Specific Code Change Policy (Section 3)
- PASS TypeScript typing, suppressions, tier rules, coverage exclusion policy

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)
- PASS TypeScript framework, location, coverage thresholds

### Metrics Summary

- PASS 409/409 pr-context tests passing (reviewer run); 3879/3879 full suite (executor run)
- PASS 97.14% line, 91.61% branch coverage (extension-wide)
- PASS 76/76 changed executable lines covered
- PASS All code quality checks passing

### Recommendation

**Ready for merge.** No blocking findings. Non-blocking observations are listed in `code-review.2026-10-08T03-03.md`.

---

## Appendix A: Test Inventory

### Tests added or changed on this branch

1. compareCodePoint - enumerative properties over a fixed domain › is antisymmetric for every ordered pair in the domain (rewritten: violations array)
2. compareCodePoint - enumerative properties over a fixed domain › is transitive for every ordered triple in the domain (rewritten: violations array)
3. compareCodePoint issue #740 code-point order › D1, D2, D3, D4, S1, A1, A2, A3, A4 (9 tests)
4. sortedSet › removes duplicates and sorts by code point; orders U+FFFF before U+1F600; accepts a Set and a generator; does not mutate the input array; returns an empty array for empty input
5. escapeRegExp › escapes every regex metacharacter so the pattern matches the literal text; leaves a hyphen unescaped; returns plain text unchanged
6. splitLines › empty string; CRLF; lone CR; single trailing terminator; interior empty line; lone newline; U+2028 not split
7. relativeToPosix › POSIX root; Windows-style root and path; trailing slash on root; path outside root; sibling directory sharing root prefix

Removed: the two operator-derived tests listed in Section 8.

---

## Appendix B: Toolchain Commands Reference

```bash
# Formatting (check only)
npx --prefix extensions/drm-copilot prettier --check extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/package.json

# Linting
npm --prefix extensions/drm-copilot run lint

# Type checking
npm --prefix extensions/drm-copilot run typecheck

# Tests (pr-context, no coverage regeneration)
npm --prefix extensions/drm-copilot run test -- test/lib/pr-context

# Coverage artifact inspection (no regeneration)
node <session-scratch>/lcov.cjs extensions/drm-copilot/coverage/lcov.info src/lib/pr-context/<file>.ts ...
node <session-scratch>/changed.cjs 6dac65b0930b299dc7b3c3925a607735a05fca35 extensions/drm-copilot/coverage/lcov.info

# Evidence location scan
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# Scope
git diff --name-only 6dac65b0930b299dc7b3c3925a607735a05fca35..HEAD
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-08
**Policy Version:** Current (as of audit date)

# Policy Compliance Audit: shared code-point string comparator consolidation (Issue #796)

**Audit Date:** 2026-10-09
**Branch:** `bug/duplicated-string-comparators-outside-pr-context-796` @ `5d3caa21d5ed2b0224fa569b89ed0cddf875b313`
**Base:** `main` (resolved `origin/main` at `46dd56a8c2d6df15571f5f088ae2d677e5123b55`), merge-base `46dd56a8c2d6df15571f5f088ae2d677e5123b55`
**Work Mode:** `full-bug` (AC source: `spec.md` `## Acceptance Criteria`, AC-1..AC-10)
**Code Under Test (branch diff `git diff origin/main...HEAD`, non-documentation files):**

- `extensions/drm-copilot/src/lib/string-ordering.ts` (new, 66 lines)
- `extensions/drm-copilot/src/lib/pr-context/`: `models.ts`, `autoclose.ts`, `collector-core.ts`, `collector-output.ts`, `feature-docs.ts`, `feature-docs-parsers.ts`, `render-feature-excerpts.ts`, `render-pr-helpers.ts`, `verification-evidence.ts` (modified, 9 files)
- `extensions/drm-copilot/src/lib/codex-native-converter/`: `engine-pipeline.ts`, `intermediate-state.ts`, `inventory.ts`, `models.ts`, `pipeline.ts`, `pipeline-traces.ts`, `reporting.ts`, `reporting-render.ts`, `validation.ts` (modified, 9 files)
- `extensions/drm-copilot/src/lib/push-down/`: `claude-blast-radius-derive.ts`, `claude-blast-radius-derive-core.ts`, `claude-blast-radius-derive-manifests.ts`, `claude-blast-radius-overlay.ts`, `copilot-customizations-engine.ts`, `filesystem-adapter.ts` (modified, 6 files)
- `extensions/drm-copilot/src/lib/subagent-tree/`: `quick-pick-labels.ts`, `tree-assembler.ts` (modified, 2 files)
- Tests, new (7): `test/lib/string-ordering.test.ts`, `test/lib/pr-context/collector-output-ordering.test.ts`, `test/lib/codex-native-converter/engine-pipeline.test.ts`, `pipeline-traces.test.ts`, `reporting-coverage.test.ts`, `reporting-render.test.ts`, `test/lib/push-down/claude-blast-radius-derive.test.ts`
- Tests, modified (7): `test/lib/pr-context/models.test.ts` (222 lines removed, 0 added), `codex-native-converter/inventory.test.ts`, `codex-native-converter/pipeline.test.ts`, `push-down/blast-radius-derive-manifests.test.ts`, `push-down/copilot-customizations-engine.test.ts`, `subagent-tree/quick-pick-labels.test.ts`, `subagent-tree/tree-assembler.test.ts` (additions only)
- `extensions/drm-copilot/jest.config.cjs` (modified; one per-file `coverageThreshold` entry; Jest configuration, not production code)

The remaining 53 changed files are Markdown (feature folder issue, spec, research, plan, evidence, and the promoted lifecycle record). No Python, PowerShell, C#, Bash, or GitHub Actions files changed. Total: 95 files, +3145/-400.

**Template source:** the structure follows the bundled policy-audit template asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, read from this checkout because MCP tools were not available to this review session.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 27 production (1 new, 26 modified), 14 test (7 new, 7 modified), plus jest.config.cjs | 1068 tests in 81 affected suites (reviewer run); 3945 tests in 264 suites (executor full run) | PASS: 1068 pass, 0 fail (reviewer); 3945 pass, 0 fail (executor) | 97.16% lines, 91.73% branches (extension-wide) | 97.23% lines, 92.01% branches (extension-wide) | 100.00% (168/168 added executable lines); string-ordering.ts 100.00% lines, 100.00% branches |
| Markdown | 53 files | N/A | N/A | N/A (documentation) | N/A (documentation) | N/A (documentation) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/evidence/baseline/ts-test-coverage.2026-10-09T21-15.md` (97.16% lines, 91.73% branches; per-file table for 26 changed production files)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (parsed by reviewer: 97.23% lines, 92.01% branches; file mtime 2026-10-09 21:42 -0400, after the last test-file write at 21:38 and after the last production commit `506d11164` at 21:29) and `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/evidence/qa-gates/coverage-delta.2026-10-09T23-14.md`
- PowerShell baseline coverage artifact: N/A - zero PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A - zero PowerShell files changed on the branch
- Per-language comparison summary: Section 1.2.1 of this document; per-file detail in `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/evidence/qa-gates/coverage-delta.2026-10-09T23-14.md`

Coverage artifact path note: the TypeScript coverage artifact for this package is produced at `extensions/drm-copilot/coverage/lcov.info` (Jest `coverageDirectory`). The reviewer parsed it directly and did not regenerate it.

---

## Rejected Scope Narrowing

No scope-narrowing instruction was detected. The caller prompt specified the full branch diff (`git diff origin/main...HEAD`) and did not limit files, languages, or toolchain stages.

The caller supplied an operator coverage standing decision ("every changed file must have at least 85% line and 75% branch coverage, and no changed line may be uncovered. A per-file percentage below baseline is NOT a blocking finding when those conditions hold."). This is a coverage-acceptance interpretation recorded beneath AC-9 in `spec.md`, not a scope narrowing. The reviewer did not adopt it without checking: Section 1.2 shows that the repository rule "no regression on changed lines" (`.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`) is met independently, because every per-file percentage decrease is a denominator effect with an unchanged count of uncovered lines or branches.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no output.
- `git diff --name-only origin/main...HEAD -- artifacts` returned no paths. No file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 48 evidence files are under `<FEATURE>/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Result: PASS. No violations.

---

## Executive Summary

The branch adds a dependency-free module `extensions/drm-copilot/src/lib/string-ordering.ts` that exports `compareCodePoint`, a strict total order over all JavaScript strings that equals Unicode code-point order for well-formed strings. It removes the `compareCodePoint` definition from `pr-context/models.ts`, deletes two module-private `compareStrings` copies, two local `compare` arrows, and the exported `compareOrdinal`, and replaces all 24 inventoried comparator sites outside `pr-context/` plus the residual `collector-output.ts` site with calls to the shared comparator. Every consumer imports directly from `../string-ordering`; there is no re-export.

**Policy documents evaluated:**
- PASS `CLAUDE.md`, `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- PASS TypeScript: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
- N/A Python, PowerShell, C#, Bash, GitHub Actions (zero changed files)

Reviewer-run checks at HEAD `5d3caa21d`: Prettier check exit 0 ("All matched files use Prettier code style!"), ESLint exit 0, TypeScript typecheck (both tsconfig projects) exit 0, Jest over the five affected test trees 81/81 suites and 1068/1068 tests passed, Python overlay parity test 4/4 passed. Coverage was verified by parsing the existing `lcov.info` against `git diff -U0 origin/main...HEAD -- extensions/drm-copilot/src`: all 27 changed production files meet 85% lines and 75% branches, and 0 of 168 added executable lines are uncovered.

No Blocking findings. Non-blocking findings are listed in Section 8 and in `code-review.2026-10-09T21-56.md`.

**Temporary artifacts cleanup:**
- PASS: no temporary scripts are committed. Reviewer scratch files (`cov.js`, `src.diff`) are in the session scratch directory, outside the repository.
- PASS: no new tooling scripts were added to the repository.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | New tests build inputs locally. The two files that use `jest.mock` (`pipeline-traces.test.ts`, `claude-blast-radius-derive.test.ts`) reset mocks in `afterEach(() => { jest.resetAllMocks(); })`. No shared mutable fixtures. |
| **Isolation** - Each test targets single behavior | PASS | Each consumer regression test drives one consumer function on one supplementary-versus-U+E000 input; each comparator test targets one property or pair. |
| **Fast Execution** - Tests complete quickly | PASS | 81 suites, 1068 tests in 1.673 s (reviewer run). |
| **Determinism** - Consistent results | PASS | Pure string functions; in-memory file systems (`InMemoryFileSystem`, `TreeFileSystem`); `node:fs` mocked. No clock, RNG, or timers. |
| **Readability & Maintainability** - Clear structure | PASS | Titles name the issue, the input class, and the expected order; escapes use `\uXXXX` / `\u{...}` forms. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | **Baseline:** 97.16% lines, 91.73% branches (51037/52524 lines; 7523/8201 branches). **Command:** `cd extensions/drm-copilot && npm run test:coverage`. Per-file baseline for 26 changed production files in `evidence/baseline/ts-test-coverage.2026-10-09T21-15.md`. |
| **No Coverage Regression** | PASS | **Post-change:** 97.23% lines, 92.01% branches (reviewer `awk` over `lcov.info`: 51061/52514 lines, 7509/8161 branches). **Change:** +0.07 pp lines, +0.28 pp branches. Five files show a lower per-file percentage (feature-docs.ts, feature-docs-parsers.ts, inventory.ts, filesystem-adapter.ts on lines; validation.ts on branches). In each case the count of uncovered items is unchanged (feature-docs.ts 17 to 17 lines; feature-docs-parsers.ts 6 to 6; inventory.ts 6 to 6; filesystem-adapter.ts 4 to 4; validation.ts 8 to 8 branches); the decrease comes from removing covered comparator lines or branches. No changed line is uncovered. |
| **New/Changed Code Coverage** | PASS | `string-ordering.ts`: 66/66 lines, 20/20 branches. Added executable lines across the 27 files: 168/168 covered (reviewer script over `git diff -U0` hunks and lcov `DA:` records; matches `evidence/qa-gates/coverage-delta.2026-10-09T23-14.md`). |
| **Comprehensive Coverage** | PASS | `compareCodePoint`: 23 tests (6 unit, 5 enumerative over a 15-element domain, 9 #740 D/S/A cases, 3 #796 unpaired-surrogate cases). Six consumer regression tests, one per consumer family plus both subagent-tree copies. Eight coverage tests for changed lines. |
| **Positive Flows** - Valid inputs | PASS | BMP ordering, prefix ordering, S1 literal-order sort, consumer sorts. |
| **Negative Flows** - Invalid inputs | PASS | The comparator is total; ill-formed inputs (lone high surrogate, lone low surrogate, high surrogate followed by U+E000, `\uDC00\uD800`) are exercised. `realDirectoryLister` unreadable-directory path returns `[]`. |
| **Edge Cases** - Boundary conditions | PASS | Empty string, proper prefix, U+E000, U+FFFF, surrogate-pair lead and trail differences, the research triple. |
| **Error Handling** - Error paths | N/A | No error paths were added or removed; the comparator does not throw. |
| **Concurrency** - If applicable | N/A | No concurrent behavior in the changed code. |
| **State Transitions** - If applicable | N/A | No stateful components changed. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.16% lines, 91.73% branches -> Post-change: 97.23% lines, 92.01% branches. Change: +0.07 pp lines, +0.28 pp branches; all 27 changed production files are at or above 85% lines and 75% branches (lowest line: render-pr-helpers.ts 87.08%; lowest branch: engine-pipeline.ts 84.78%); five per-file percentage decreases are denominator effects with unchanged uncovered counts. New/changed-code coverage: 100.00% (168/168 added executable lines). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`; `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/evidence/baseline/ts-test-coverage.2026-10-09T21-15.md`; `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/evidence/qa-gates/coverage-delta.2026-10-09T23-14.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Antisymmetry, transitivity, and well-formed-equivalence tests collect a `violations` array of `U+XXXX`-described pairs or triples and assert `toEqual([])`. Consumer tests assert literal expected arrays. |
| **Arrange-Act-Assert Pattern** | PASS | New tests carry `// Arrange`, `// Act`, `// Assert` comments. The six moved one-line unit tests in `string-ordering.test.ts` are single `expect` statements, unchanged from `models.test.ts`. |
| **Document Intent** | PASS | Each coverage test file has a header comment naming the module, the standing decision, and (where used) the reason for the mock. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, process, or real filesystem access. `claude-blast-radius-derive.test.ts` mocks `node:fs.readdirSync`; no file is created or read. |
| **Use Mocks/Stubs** | PASS | `jest.mock` with `jest.requireActual` spread keeps the unmocked surface real; mocks reset in `afterEach`. |
| **Environment Stability** | PASS | No environment variables, global state, or temporary files. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document, with `code-review.2026-10-09T21-56.md` and `feature-audit.2026-10-09T21-56.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` (Issue #796) and `spec.md` (Decisions 1-5, AC-1..AC-10). |
| **Read existing change plans** | PASS | `research/research.2026-10-08T21-30.md`; `evidence/baseline/phase0-instructions-read.md`. |
| **Document the plan** | PASS | `plan.2026-10-08T17-25.md`, 103 tasks checked; the three remaining `- [ ]` strings are inline text inside task descriptions, not tasks. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | `compareCodePoint` is one linear scan with a three-branch `rankCodeUnit` helper; no allocation. |
| **Reusability** | PASS | Reviewer `git grep -nE "function compareCodePoint\|const compareCodePoint"` returns one match (`string-ordering.ts:53`); `git grep -nE "\bcompareStrings\b\|\bcompareOrdinal\b"` over `src` and `test` returns none. |
| **Extensibility** | PASS | Standard `(left: string, right: string) => number` comparator signature usable directly as a `.sort` argument. |
| **Separation of concerns** | PASS | Pure comparator isolated in a module with no imports; consumers keep their key-projection wrappers. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Subsystem-neutral location `src/lib/` chosen per spec Decision 3 to avoid cross-subsystem edges between `pr-context/`, `push-down/`, `codex-native-converter/`, and `subagent-tree/`. |
| **Under 500 lines** | PASS | Reviewer `wc -l` over all added or modified files under `extensions/drm-copilot/src`, `test`, and `jest.config.cjs`: largest is `collector-output.ts` at 491; `jest.config.cjs` 476; `string-ordering.test.ts` 338. |
| **Public vs internal** | PASS | `compareCodePoint` exported once; no `export { compareCodePoint }` re-export anywhere in `src` (reviewer grep). `compareOrdinal` removal is an in-repo-only symbol; all callers updated (spec Backward-compatibility). |
| **No circular dependencies** | PASS | `string-ordering.ts` contains no `import` statement (reviewer `git grep -nE "^\s*import\b"` exit 1), so it cannot participate in a cycle. `module-boundary.test.ts` passed (`evidence/qa-gates/ts-architecture.2026-10-09T23-10.md`). |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `rankCodeUnit`, `leftUnit`, `rightUnit`, `sharedLength`; consumer locals `bySource`, `bySection`. |
| **Docs/docstrings** | PASS | Module header (responsibilities, no-import boundary); JSDoc on `rankCodeUnit` (injective mapping) and `compareCodePoint` (contract, UTF-16 difference, total-order guarantee, return set). `pr-context/models.ts` header no longer lists `compareCodePoint`. |
| **Comment why, not what** | PASS | JSDoc explains why the surrogate fix-up is needed and why the order is total. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | **Command:** `npm --prefix extensions/drm-copilot exec -- prettier --check extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/jest.config.cjs`<br>**Result:** "All matched files use Prettier code style!" |
| **2. Linting** | PASS | **Command:** `npm --prefix extensions/drm-copilot run lint`<br>**Result:** exit 0, no findings. |
| **3. Type checking** | PASS | **Command:** `npm --prefix extensions/drm-copilot run typecheck`<br>**Result:** exit 0 (`tsconfig.json` and `tsconfig.jest.json`). |
| **4. Architecture boundaries** | PASS | No dependency-cruiser configuration exists (executor `git ls-files` empty). `module-boundary.test.ts` passed; `string-ordering.ts` has no import edge. |
| **5. Testing** | PASS | **Command:** `npm --prefix extensions/drm-copilot test -- test/lib/string-ordering.test.ts test/lib/codex-native-converter test/lib/push-down test/lib/subagent-tree test/lib/pr-context`<br>**Result:** 81 suites, 1068 tests passed. Executor full suite with coverage (pass 2): 264 suites, 3945 tests passed. |
| **6. Contract / schema** | N/A | No host-service boundary or schema changed. |
| **7. Integration** | PASS | Integration suites under the extension (for example `collector-integration.test.ts`) ran in the executor full suite; `claude-blast-radius-overlay-parity.test.ts` passed in the reviewer run; Python `test_push_down_claude_overlay_parity.py` 4/4 passed (reviewer run). |
| **Full toolchain loop** | PASS | Executor pass 2 of the Phase 4 loop completed P4-T1..P4-T15 with no file rewritten (`evidence/other/handoff.2026-10-09T23-30.md`). |
| **Explicit reporting** | PASS | Commands and results under `evidence/qa-gates/` and in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Commits listed in Section 9. |
| **Design choices explained** | PASS | Code-point order (Decision 1), total-order correction (Decision 2), module path and no re-export (Decision 3). |
| **Update supporting documents** | PASS | Module headers and JSDoc updated; `BREAKING CHANGE:` footer on `506d11164` records the `compareOrdinal` removal. |
| **Provide next steps** | PASS | Argument-less `.sort()` follow-up recorded in `spec.md` Rollout & Follow-up. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | `compareCodePoint(left: string, right: string): number` and `rankCodeUnit(unit: number): number` have explicit types. The previous `codePointAt(index)!` non-null assertions were removed with the old implementation. |
| **Untyped escape hatches (T3: <= 5 per file, justified)** | PASS | Zero `any` in production changes. Test-only assertions (`as unknown as fs.Dirent`, `as jest.MockedFunction<...>`) are standard Jest mock typing. |
| **Suppressions** | PASS | No `eslint-disable`, `@ts-ignore`, or `@ts-expect-error` added (diff inspection). |
| **Tier classification** | PASS | `quality-tiers.yml` classifies `extensions/drm-copilot` as T3; no property-test, mutation, or golden-test obligation. |
| **Coverage exclusion policy** | PASS | `jest.config.cjs` diff adds only `"./src/lib/string-ordering.ts": { lines: 85, branches: 75 }`; no `exclude` or `coveragePathIgnorePatterns` change. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4E: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | PASS | `@jest/globals` imports; run through `run-jest.cjs`. |
| **Test location mirrors source** | PASS | `test/lib/string-ordering.test.ts` mirrors `src/lib/string-ordering.ts`; `engine-pipeline.test.ts`, `pipeline-traces.test.ts`, `reporting-render.test.ts`, `claude-blast-radius-derive.test.ts` mirror their sources. `collector-output-ordering.test.ts` is named by spec AC-5. `reporting-coverage.test.ts` covers `reporting.ts` under a suffixed name (code review Nit). |
| **Coverage expectation** | PASS | Section 1.2.1. Per-file threshold entry for `string-ordering.ts` present (AC-7). |
| **No banned determinism APIs** | PASS | No `setTimeout`, `Date.now()`, `Math.random`, or real waits in changed tests. |
| **Mock reset** | PASS | `afterEach(() => { jest.resetAllMocks(); })` in both mocking files, as `.claude/rules/typescript.md` requires. |

---

## 5. Test Coverage Detail

### compareCodePoint (string-ordering.ts) (23 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| identical, less, greater, empty, case, prefix (6 moved unit tests) | Positive / Edge Case | 53-66 | PASS |
| reflexive / antisymmetric / transitive / range over 15-element domain including `\uD800`, `\uDC00`, `\uD800`, `\u{10000}` | Property (enumerative) | 25-66 | PASS |
| matches code-point-sequence order for every well-formed pair | Property (enumerative) | 25-66 | PASS |
| #740 D1-D4, S1, A1-A4 (9 moved tests) | Edge Case / Positive | 25-66 | PASS |

Of the 23 tests, 19 were moved unchanged in title from `models.test.ts`; the well-formed equivalence test and the three #796 tests are new.
| #796 research triple without a cycle; zero only for identical strings; lone high vs lone low antisymmetric | Negative / Edge Case | 25-66 | PASS |

**Coverage:** 66/66 lines, 20/20 branches.

Fail-before: `evidence/regression-testing/fail-before-string-ordering.2026-10-09T21-50.md` records the moved, uncorrected implementation failing the transitivity and cycle tests (2 failed, 21 passed), with the research triple listed among 9 violating triples.

### Consumer regression tests (6 tests)

| Test Name | Scenario Type | Consumer | Status |
|-----------|--------------|----------|--------|
| issue #796 sorts a supplementary-character path after a U+E000 path by code point | Regression | `normalizeSelectedPaths` (inventory.ts) | PASS |
| issue #796 sorts a supplementary-character module path after a U+E000 module path | Regression | `classifyProjectDirectories` | PASS |
| issue #796 emits a U+E000 key before a supplementary-character key | Regression | `stringifySorted` | PASS |
| issue #796 orders orphans with a U+E000 agentId before a supplementary-character agentId | Regression | `compareByAgentId` via `assembleTree` | PASS |
| issue #796 breaks an equal-timestamp tie with a U+E000 path before a supplementary-character path | Regression | `compareCandidates` via `buildRootSessionPickEntries` | PASS |
| issue #796 renders a U+E000 evidence source before a supplementary-character evidence source | Regression | `renderVerificationEvidenceSection` | PASS |

Each has a fail-before artifact under `evidence/regression-testing/`.

### Changed-line coverage tests (8 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| engine-pipeline: orders traces with equal source and section by target role | Positive | engine-pipeline.ts 241 | PASS |
| reporting-render: section traces by role then path; findings by code, source, target | Positive | reporting-render.ts 79, 182 | PASS |
| reporting-coverage: validation results sorted by code, source, target | Positive | reporting.ts 150 | PASS |
| pipeline-traces: orders traces by source, section, role (mocked classifier) | Positive | pipeline-traces.ts 114, 120 | PASS |
| claude-blast-radius-derive: sorted entries; unreadable directory returns [] | Positive / Negative | claude-blast-radius-derive.ts 126 | PASS |
| pipeline: equal-position destinations ordered by path text | Edge Case | pipeline.ts 58 | PASS |

**Not covered:** no added executable line. Seven added lines carry a partially taken `?? ""` branch (reporting-render.ts 83, 189; reporting.ts 152, 157; validation.ts 364, 365, 370); these branch arms existed before the change and the uncovered-branch counts are unchanged (code review Minor).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (affected trees, reviewer run) | 1068 | PASS |
| Tests Passed | 1068 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time | 1.673 s | PASS (fast) |
| Full suite (executor, with coverage, pass 2) | 3945 passed of 3945 (+18 vs 3927 baseline: +23 in string-ordering.test.ts, -19 moved out of models.test.ts, +6 consumer regression, +8 coverage) | PASS |
| Test File Size | largest changed test file `string-ordering.test.ts` 338 lines | PASS |
| Code Coverage (extension, repo-wide) | 97.23% lines, 92.01% branches | PASS |

---

## 7. Code Quality Checks

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npm --prefix extensions/drm-copilot exec -- prettier --check extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/jest.config.cjs` | exit 0 | PASS |
| ESLint | `npm --prefix extensions/drm-copilot run lint` | exit 0 | PASS |
| TypeScript | `npm --prefix extensions/drm-copilot run typecheck` | exit 0 | PASS |
| Jest (affected trees) | `npm --prefix extensions/drm-copilot test -- test/lib/string-ordering.test.ts test/lib/codex-native-converter test/lib/push-down test/lib/subagent-tree test/lib/pr-context` | 81 suites, 1068 tests passed | PASS |
| Python parity | `poetry run pytest -q tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py -p no:cacheprovider` | 4 passed | PASS |
| Coverage (artifact inspection) | `node <scratch>/cov.js extensions/drm-copilot/coverage/lcov.info <scratch>/src.diff` | 27/27 files >= 85/75; 0 uncovered added lines | PASS |
| Repo-wide coverage | `awk` sum of `LF/LH/BRF/BRH` over `lcov.info` | 97.23% lines, 92.01% branches | PASS |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 | PASS |

**Notes:** Coverage was not regenerated by the reviewer. The PR-context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent from this worktree and the MCP collector was not available to this session; the reviewer used `git diff origin/main...HEAD` directly as the scope source, which is the authoritative base the caller supplied.

---

## 8. Gaps and Exceptions

### Identified Gaps

All non-blocking:

1. **Evidence timestamps do not match wall-clock time (Non-blocking).** Commit `0229a886d` (2026-10-09 21:11 -0400) contains baseline artifacts stamped 21-12 to 21-19; commit `ed74a410b` (21:18) contains fail-before artifacts stamped 21-24 to 21-40; commit `5d3caa21d` (21:48) contains the handoff stamped 23-30. The stamps are later than the commits that contain them, so they are sequence labels rather than capture times. The reviewer reproduced the load-bearing claims (coverage, structural searches, toolchain), so no verdict depends on the stamps. Recommendation: take timestamps from the system clock at capture.
2. **Claude-Session trailer absent on `506d11164` and `5d3caa21d` (Non-blocking, informational).** No repository policy requires the trailer (reviewer grep of `.claude/` and `.github/` finds it only as an example in two planning skills). Both commits carry the required `Co-Authored-By` trailer, which is the only line the current attribution instruction requires. No action; history rewriting is not permitted.
3. **Per-file percentages below baseline in five files (Non-blocking).** Denominator effect with unchanged uncovered counts (Section 1.2). Meets the standing decision and the changed-line no-regression rule.
4. **`pipeline-traces.ts` lines 114 and 120 covered only through a mocked classifier (Non-blocking).** See code review Minor finding.
5. **PR-context artifacts not regenerated (Non-blocking, process).** See Section 7 notes.

### Approved Exceptions
**None.** No exceptions needed.

### Removed/Skipped Tests
1. **`compareCodePoint` describe blocks in `test/lib/pr-context/models.test.ts`** - Removed in commit `506d11164`
   - **Reason:** The definition moved to `string-ordering.ts` (spec Decision 3).
   - **Impact:** None; all 19 removed tests (6 unit, 4 enumerative, 9 #740 D/S/A) are present in `test/lib/string-ordering.test.ts` under the same titles (compared by reviewer), with the domain extended by four entries and four new tests added (23 in total).
   - **Justification:** Required by spec scope and AC-6.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **b6b3f8560** - docs(796): prepare shared code-point comparator consolidation
2. **e7183a978** - docs(796): apply coordinator coverage decision to plan P4-T6
3. **3b658a52d** - Merge remote-tracking branch 'origin/main' into the feature branch
4. **0229a886d** - docs(796): record Phase 0 baseline evidence
5. **ed74a410b** - test(796): add fail-first consumer ordering regression tests
6. **58310332f** - feat(796): add shared string-ordering module with total-order comparator
7. **506d11164** - refactor(796): route every ordinal string comparator to string-ordering
8. **5d3caa21d** - test(796): close changed-line coverage gaps and record final QA

### Files Modified

1. **extensions/drm-copilot/src/lib/string-ordering.ts** (NEW) - `compareCodePoint` with surrogate fix-up.
2. **pr-context (9 files)** (MODIFIED) - definition removed from `models.ts`; imports switched to `../string-ordering`; `collector-output.ts` inline ternary replaced.
3. **codex-native-converter (9 files)** (MODIFIED) - `compareStrings` x2 and local `compare` x2 deleted; inline and guarded sites replaced.
4. **push-down (6 files)** (MODIFIED) - exported `compareOrdinal` deleted; callers and inline sites replaced.
5. **subagent-tree (2 files)** (MODIFIED) - `compareByAgentId` and `compareCandidates` path tiebreak delegate to the shared comparator.
6. **Tests (14 files: 7 new, 7 modified)** - 1 comparator suite, 6 consumer regression tests, 8 coverage tests; `models.test.ts` moved blocks removed.
7. **jest.config.cjs** (MODIFIED) - per-file threshold for `string-ordering.ts`.
8. **docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/** (NEW) - issue, spec, research, plan, 48 evidence files; promoted lifecycle record.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All reviewer-run toolchain checks pass. Coverage figures are present for the only in-scope language (TypeScript) with baseline, post-change, and changed-line values, and all thresholds are met. No evidence-location violations. No workflow, benchmark, or action files changed, so the `modified-workflow-needs-green-run` rule does not apply.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes: issue, spec, research, plan present
- PASS Design Principles: one comparator definition; simple algorithm
- PASS Module & File Structure: all files under 500 lines; no import edges from the new module
- PASS Naming, Docs, Comments: contract documented
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
- PASS TypeScript framework, location, coverage thresholds, mock reset

### Metrics Summary

- PASS 1068/1068 affected-tree tests (reviewer run); 3945/3945 full suite (executor run)
- PASS 97.23% line, 92.01% branch coverage (extension-wide)
- PASS 168/168 added executable lines covered; 27/27 changed production files >= 85/75
- PASS All code quality checks passing

### Recommendation

**Ready for merge.** Blocking findings: 0. Non-blocking observations are listed in Section 8 and in `code-review.2026-10-09T21-56.md`.

---

## Appendix A: Test Inventory

### Tests added or changed on this branch

1. `test/lib/string-ordering.test.ts` - compareCodePoint (6); enumerative properties (5); issue #740 code-point order (9); issue #796 unpaired surrogates (3)
2. `test/lib/codex-native-converter/inventory.test.ts` - issue #796 normalizeSelectedPaths case
3. `test/lib/push-down/blast-radius-derive-manifests.test.ts` - issue #796 classifyProjectDirectories case
4. `test/lib/push-down/copilot-customizations-engine.test.ts` - issue #796 stringifySorted case
5. `test/lib/subagent-tree/tree-assembler.test.ts` - issue #796 compareByAgentId case
6. `test/lib/subagent-tree/quick-pick-labels.test.ts` - issue #796 compareCandidates tiebreak case
7. `test/lib/pr-context/collector-output-ordering.test.ts` - issue #796 renderVerificationEvidenceSection case
8. `test/lib/codex-native-converter/engine-pipeline.test.ts` (1), `reporting-render.test.ts` (2), `reporting-coverage.test.ts` (1), `pipeline-traces.test.ts` (1), `pipeline.test.ts` (+1), `test/lib/push-down/claude-blast-radius-derive.test.ts` (2) - changed-line coverage tests

Removed: the `compareCodePoint` blocks from `test/lib/pr-context/models.test.ts` (moved, Section 8).

---

## Appendix B: Toolchain Commands Reference

```bash
# Scope
git diff --stat=200 origin/main...HEAD
git diff -U0 origin/main...HEAD -- extensions/drm-copilot/src

# Formatting (check only)
npm --prefix extensions/drm-copilot exec -- prettier --check extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/jest.config.cjs

# Linting
npm --prefix extensions/drm-copilot run lint

# Type checking
npm --prefix extensions/drm-copilot run typecheck

# Tests (affected trees, no coverage regeneration)
npm --prefix extensions/drm-copilot test -- test/lib/string-ordering.test.ts test/lib/codex-native-converter test/lib/push-down test/lib/subagent-tree test/lib/pr-context

# Python parity
poetry run pytest -q tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py -p no:cacheprovider

# Coverage artifact inspection (no regeneration)
node <session-scratch>/cov.js extensions/drm-copilot/coverage/lcov.info <session-scratch>/src.diff
awk -F: '/^LF:/{lf+=$2} /^LH:/{lh+=$2} /^BRF:/{bf+=$2} /^BRH:/{bh+=$2} END{...}' extensions/drm-copilot/coverage/lcov.info

# Structural searches (AC-1, AC-2, AC-3)
git grep -nE "function compareCodePoint|const compareCodePoint" -- extensions/drm-copilot/src
git grep -nE "\bcompareStrings\b|\bcompareOrdinal\b" -- extensions/drm-copilot/src extensions/drm-copilot/test
git grep -nE "^\s*import\b" -- extensions/drm-copilot/src/lib/string-ordering.ts
git grep -n "compareCodePoint" -- extensions/drm-copilot/src extensions/drm-copilot/test
rg -n "(\?\s*1\s*:\s*-1|return\s+-1|\?\s*-1\b)" extensions/drm-copilot/src
rg -nU "if\s*\([^()]*\s<\s[^()]*\)\s*\{?\s*return\s+-1" extensions/drm-copilot/src

# Evidence location scan
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-09
**Policy Version:** Current (as of audit date)

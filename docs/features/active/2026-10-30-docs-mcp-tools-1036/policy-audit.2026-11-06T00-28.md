# Policy Compliance Audit: docs-mcp-tools (#1036)

**Audit Date:** 2026-11-06 (UTC stamp 2026-11-06T00-28)
**Branch:** `feature/docs-mcp-tools-1036-r2` at `ca0d5c2dc29d29c4d70468957ee8eb911085cb05`
**Base:** `origin/epic/documentation-estate-tooling-integration`, merge base `82492b61a7788befcde52353a6fc3925c99a783c` (supplied by the caller and confirmed with `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`)
**Scope command:** `git diff --name-status 82492b61a7788befcde52353a6fc3925c99a783c...HEAD` (64 paths, 4157 insertions, 149 deletions)
**Code Under Test:** five new TypeScript production modules, six edited TypeScript production modules, seven new and four edited Jest test files, one new JSON coverage map, one edited CommonJS Jest configuration, six byte-identical copies of the execution-environment brief, the extension README and CHANGELOG, and the feature folder (plan, spec, user story, evidence). The full list is in Section 9.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 22 files (11 production, 11 test) | 5333 tests (334 suites) | PASS: 5333 pass, 0 fail | 97.06% lines, 93.67% branches (extension suite) | 97.10% lines, 93.77% branches (extension suite) | 99.88% lines (1108/1110), 98.05% branches (201/205) across the five new modules |
| JSON | 1 file | N/A | PASS: loaded by Jest configuration; Prettier check | N/A (configuration data) | N/A (configuration data) | N/A |
| CommonJS (Jest configuration) | 1 file | N/A | PASS: Jest run loads it | N/A (permitted non-production configuration exclusion) | N/A (permitted non-production configuration exclusion) | N/A |
| Markdown | 40 files | N/A | PASS: brief copies byte-identical | N/A (documentation) | N/A (documentation) | N/A |

Python, PowerShell, Bash and C#: zero changed files on the branch; no row is required.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-30-docs-mcp-tools-1036/evidence/baseline/jest-coverage.2026-11-05T23-39.md` (suite 97.06% lines, 93.67% branches; five edited-file rows).
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (written 2026-11-06T00-08 UTC by the [P8-T4] run) and `docs/features/active/2026-10-30-docs-mcp-tools-1036/evidence/qa-gates/jest-coverage.2026-11-06T00-09.md`; reviewer recomputed 97.10% lines (63029/64911) and 93.77% branches (9596/10234) from the lcov file.
- PowerShell baseline coverage artifact: N/A, zero PowerShell files changed on the branch.
- PowerShell post-change coverage artifact: N/A, zero PowerShell files changed on the branch.
- Per-language comparison summary: Section 1.2.1 records TypeScript as PASS; no other coverage language has changed files.

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the epic integration merge base, which is the legitimate base for an epic child, and the audit covers the full branch diff against it.

## Executive Summary

The branch adds six MCP tools (`run_docs_check`, `run_docs_inventory`, `run_docs_coverage`, `update_docs_ledger`, `generate_docs_reference`, `validate_docs_artifacts`) to the drm-copilot extension as TypeScript wrappers over the workspace's `.claude/lib/docs/Invoke-DocsCommand.ps1`. No Python, PowerShell, Bash or C# file is created or edited, which satisfies the owner directive that TypeScript is used only for MCP surfaces and that no new Python is added.

Toolchain evidence (Prettier, ESLint, TSC, Jest with coverage, seeded shuffle) is clean. The reviewer independently re-ran 13 affected Jest suites (188 tests, 0 failures), recomputed coverage from `extensions/drm-copilot/coverage/lcov.info`, re-measured logical line counts, re-hashed the six brief copies (all `fe43258b50ec159b4fafdeef50efb595`), and confirmed that no path under `artifacts/` is in the diff.

One blocking item remains, and it is classified `awaiting_ci`. The stage 6 contract test `tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies` excludes every path that has a `worktrees` component (line 454). The checkout lives under `.claude/worktrees/`, so the test finds zero copies locally. Its byte-identity premise holds. CI on the PR head is the only environment that can produce a passing run. Four acceptance criteria (spec SAC-27, SAC-31; user story US2-6, US3-6) depend on that result and remain unchecked.

Overall status: compliant pending CI. Review verdict: `AWAITING_CI`.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | `evidence/regression-testing/jest-shuffle.2026-11-06T00-09.md`: `--randomize --seed=1036`, 5333 passed; each docs test builds its own mock service, recording launcher and `InMemoryFileSystem` |
| Isolation | PASS | one behavior per `it`; behavior-named tests (for example `adds stderr_excerpt only for exit 3`) |
| Fast execution | PASS | reviewer run of 13 suites completed in 3.2 s |
| Determinism | PASS | no clock, randomness, network or filesystem writes in the new tests |
| Readability | PASS | Arrange/Act/Assert comments, module header comments |

### 1.2 Coverage and Scenarios

| Item | Status | Evidence |
|---|---|---|
| Baseline coverage documented | PASS | `evidence/baseline/jest-coverage.2026-11-05T23-39.md` |
| No regression on edited files | PASS | `evidence/qa-gates/coverage-delta.2026-11-06T00-09.md`; reviewer lcov recomputation agrees (`mcp-tools.ts` 95.98% / 92.00%, `repo-automation-service.ts` 98.32% / 93.33%) |
| New files at or above 85% lines and 75% branches | PASS | lcov: `docs-command-envelope.ts` 243/243, 62/63; `mcp-tool-inputs-docs.ts` 490/492, 100/102; `repo-automation-execute-docs.ts` 185/185, 17/17; `mcp-docs-tool-definitions.ts` 135/135, 13/14; `mcp-handlers/docs-handlers.ts` 55/55, 9/9 |
| Thresholds enforced per file | PASS | `extensions/drm-copilot/jest.docs-coverage.json` holds an 85/75 entry per new module, merged into `jest.config.cjs` by one spread line |
| Positive, negative, edge and error flows | PASS | argv-per-tool tests, rejection matrix tests, empty-array and omitted-field tests, eight host failure codes, envelope parser codes |
| Concurrency / state transitions | N/A | stateless modules; one launch per call |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.06% lines, 93.67% branches. Post-change: 97.10% lines, 93.77% branches. Change: +0.04 points lines, +0.10 points branches; no edited file decreased. Disposition: PASS. New/changed-code coverage: 99.88% lines and 98.05% branches across the five new modules; edited production files 95.98% to 100% lines. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/qa-gates/jest-coverage.2026-11-06T00-09.md`, `evidence/qa-gates/coverage-delta.2026-11-06T00-09.md`.

Note on `src/repo-automation-service-contract.ts` (edited): the lcov file reports 0/307 lines. The module contains only `import type` statements and `interface` declarations (no `const`, `function`, `class` or `enum`), so it is a type-only module under `.claude/rules/general-unit-test.md` and `.claude/rules/typescript.md`, which permit 0% executable coverage. It remains in the denominator, and the edit adds one optional interface member. This is not a finding.

### 1.3 Test Structure and Diagnostics

| Item | Status | Evidence |
|---|---|---|
| Arrange-Act-Assert | PASS | AAA comments in every new test |
| Clear failure messages | PASS | loop assertions carry a case label |
| Intent documented | PASS | descriptive names and file headers |

### 1.4 External Dependencies and Environment

| Item | Status | Evidence |
|---|---|---|
| No temporary files | PASS | `evidence/qa-gates/test-isolation-scan.2026-11-06T00-10.md`: 0 `tmpdir`, `mkdtemp`, `writeFileSync` |
| No process launch | PASS | 0 `createNodeProcessLauncher`; the single `child_process` hit is the pre-existing module mock in `test/repo-automation-service.test.ts` present at the merge base (`evidence/other/orchestrator-decision-p8-t8.2026-11-06T00-23.md`); it replaces the module with a stub |
| Mocks and fakes | PASS | injected `DiscoveryProcessLauncher` fake, `InMemoryFileSystem`, stub `pwsh` resolver |
| Test location | PASS | `extensions/drm-copilot/test/` mirrors `src/` (`test/mcp-handlers/docs-handlers.test.ts`), following the extension's existing layout |

### 1.5 Policy Audit Requirement

PASS. This artifact, the executor self-review `evidence/qa-gates/self-review.2026-11-06T00-20.md`, and the companion code review and feature audit with the same stamp.

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Item | Status | Evidence |
|---|---|---|
| Objective clarified | PASS | issue #1036, `spec.md`, `user-story.md`, plan `plan.2026-10-30T18-58.md` |
| Policy read order | PASS | `evidence/baseline/phase0-instructions-read.2026-11-05T23-35.md` |
| Upstream contracts verified | PASS | `evidence/baseline/upstream-contract.2026-11-05T23-35.md`, `evidence/baseline/upstream-grammars.2026-11-05T23-35.md` (`LEDGER-RULES: match`) |

### 2.2 Design Principles

| Item | Status | Evidence |
|---|---|---|
| Simplicity | PASS | one declarative table per tool; 55-line handler; pure parser |
| Reusability | PASS | reuses `DiscoveryProcessLauncher`, `resolveExecutableOnPath`, `isAbsolutePathLike`, `workspaceRootProperty` |
| Extensibility | PASS | adding an option is one table row; `runDocsCommand?` and `docs` options are optional seams |
| Separation of concerns | PASS | parsing, input mapping, process I/O and MCP wiring are separate modules |

### 2.3 Module and File Structure

| Item | Status | Evidence |
|---|---|---|
| File size (700 advisory / 800 hard) | PASS | reviewer `awk 'END{print NR}'` logical counts: largest new file 492 (`src/mcp-tool-inputs-docs.ts`), largest edited file 562 (`jest.config.cjs`); no covered file at or above 700 |
| File-size baseline | PASS | `config/file-size-baseline.json` unchanged on the branch |
| No circular runtime dependency | PASS | `docs-handlers.ts` imports `RepoAutomationMcpToolResult` type-only from `mcp-tools.ts`; erased at compile time |

### 2.4 Naming, Docs, and Comments

| Item | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | `resolveDocsToolInput`, `invokeDocsCommand`, `parseDocsEnvelope`, `DOCS_MUTATING_TOOLS` |
| JSDoc on exports | PASS | every exported function and type in the five new modules |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|---|---|---|
| 1 Formatting (Prettier) | PASS | `evidence/qa-gates/prettier.2026-11-06T00-08.md` |
| 2 Linting (ESLint) | PASS | `evidence/qa-gates/eslint.2026-11-06T00-08.md`: 0 errors, 0 warnings |
| 3 Type checking (TSC) | PASS | `evidence/qa-gates/typecheck.2026-11-06T00-08.md`: 0 errors |
| 4 Architecture boundaries | N/A | no `.dependency-cruiser.cjs` exists anywhere in the repository; pre-existing condition, not introduced by this branch |
| 5 Unit tests | PASS | 5333 passed; reviewer re-run of 13 suites, 188 passed |
| 6 Contract / schema checks | PENDING CI | `evidence/qa-gates/contract-tests-final.2026-11-06T00-09.md`: 42 passed, 1 failed for an environment reason (finding PA-1) |
| 7 Integration | PASS | `test/mcp-server.docs.test.ts` (`InMemoryTransport`) passed |

### 2.6 Summarize and Document

PASS. Ten scoped commits; README, CHANGELOG and six brief copies updated; design decisions D-1 to D-6 recorded in the plan.

## 3. Language-Specific Code Change Policy Compliance

### TypeScript

| Item | Status | Evidence |
|---|---|---|
| Strong typing, no `any` | PASS | reviewer search over the five new modules and the seven new tests: 0 `any` |
| Suppressions | PASS | 0 `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck` |
| ES modules | PASS | ES imports throughout; `jest.config.cjs` keeps its existing CommonJS form and adds one `require` |
| Dependencies | PASS | no dependency added |
| Tier gate (T3, `extensions/drm-copilot` in `quality-tiers.yml`) | PASS | escape hatches 0 (limit 5 per file); no property-test or mutation obligation at T3 |
| Owner directive (TypeScript only for MCP; no new Python) | PASS | zero `.py` files in the diff |

### JSON

| Item | Status | Evidence |
|---|---|---|
| Strict JSON, formatted | PASS | `jest.docs-coverage.json` loaded by `require`; Prettier check covers `*.json` |

Python, PowerShell, Bash, C#: N/A, zero changed files.

## 4. Language-Specific Unit Test Policy Compliance

| Item | Status | Evidence |
|---|---|---|
| Jest framework, `*.test.ts` | PASS | all new tests import from `@jest/globals` |
| Targeted mocking | PASS | injected fakes; module mocks limited to pre-existing `vscode`, `node:fs`, `node:child_process` mocks in edited files and `vscode` in `mcp-server.docs.test.ts` |
| Fake timers / determinism | PASS | no timers used |

Python and PowerShell unit test sections: N/A, zero changed files.

## 5. Test Coverage Detail

| Module | Lines | Branches | Primary test file |
|---|---|---|---|
| `src/docs-command-envelope.ts` | 100% | 98.41% | `test/docs-command-envelope.test.ts` |
| `src/mcp-tool-inputs-docs.ts` | 99.59% | 98.04% | `test/mcp-tool-inputs-docs.test.ts`, `test/mcp-tool-inputs-docs.ledger.test.ts` |
| `src/repo-automation-execute-docs.ts` | 100% | 100% | `test/repo-automation-execute-docs.test.ts` |
| `src/mcp-docs-tool-definitions.ts` | 100% | 92.86% | `test/mcp-docs-tool-definitions.test.ts` |
| `src/mcp-handlers/docs-handlers.ts` | 100% | 100% | `test/mcp-handlers/docs-handlers.test.ts`, `test/mcp-server.docs.test.ts` |

## 6. Test Execution Metrics

| Run | Result | Evidence |
|---|---|---|
| Full Jest with coverage | 334 suites, 5333 passed, 0 failed | `evidence/qa-gates/jest-coverage.2026-11-06T00-09.md` |
| Seeded shuffle (seed 1036) | 334 suites, 5333 passed | `evidence/regression-testing/jest-shuffle.2026-11-06T00-09.md` |
| Reviewer re-run (13 suites, no coverage) | 188 passed, 0 failed | `node run-jest.cjs <13 suites> --silent` in `extensions/drm-copilot` |
| Stage 6 pytest contract set | 42 passed, 1 failed (environment) | `evidence/qa-gates/contract-tests-final.2026-11-06T00-09.md` |
| Live docs probe (pwsh 7.6.9) | six valid envelopes, tree unchanged | `evidence/other/docs-probe.2026-11-06T00-18.md` |

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| Prettier | PASS | `evidence/qa-gates/prettier.2026-11-06T00-08.md` |
| ESLint | PASS | `evidence/qa-gates/eslint.2026-11-06T00-08.md` |
| TSC (both projects) | PASS | `evidence/qa-gates/typecheck.2026-11-06T00-08.md` |
| CON-1 token scan | PASS | `evidence/qa-gates/con1-token-scan.2026-11-06T00-11.md` |

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported path. No file in the branch diff is under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. All executor evidence is under `docs/features/active/2026-10-30-docs-mcp-tools-1036/evidence/<kind>/`. Spec SAC-29 names `evidence/coverage/`, which is not a canonical kind; the executor used `evidence/qa-gates/`, which follows the non-overridable evidence-location skill. Result: PASS.

## 8. Gaps and Exceptions

### Identified Gaps

- PA-1 (blocking, `awaiting_ci`): `test_execution_environment_fact_is_unchanged_across_copies` cannot pass in a checkout whose path contains a `worktrees` component (`tests/scripts/dev_tools/test_discovery_documentation_contracts.py` line 454 filters on `{"node_modules", ".git", "packages", "worktrees"}`). The reviewer confirmed that the six brief copies have identical MD5 hashes, so the assertion is expected to hold in CI. Resolution requires a green CI run on the PR head.
- PR context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent in this checkout and no pull request exists yet. The reviewer used `git diff 82492b61a7788befcde52353a6fc3925c99a783c...HEAD` directly as the authoritative scope. This is documented as an assumption, not a finding.

### Approved Exceptions

- [P8-T8] `child_process` token hit accepted by orchestrator decision (`evidence/other/orchestrator-decision-p8-t8.2026-11-06T00-23.md`); the reviewer confirmed it is the pre-existing module mock at the merge base.
- Plan D-1: `limit` is a `diagnostic-`-prefixed identifier string, not the "positive integer" stated in the spec table, per the binding confirmation `### F1a` and verified against the committed 1023 module (`evidence/baseline/upstream-grammars.2026-11-05T23-35.md`).

### Removed/Skipped Tests

None. Row 1 of the enumeration table moved the expected tool list from `test/mcp-server.test.ts` into `test/mcp-server-test-service.ts` without removing an assertion.

## 9. Summary of Changes

### Commits in This PR/Branch

`5fade8f91`, `24f8eb0b8`, `5f35bcacb`, `4abdf3fb0`, `5e98a0f65`, `5a11e84a4`, `01894a352`, `7cda22388`, `34d7e12c4`, `ca0d5c2dc`.

### Files Modified

- New production: `extensions/drm-copilot/src/docs-command-envelope.ts`, `src/mcp-tool-inputs-docs.ts`, `src/repo-automation-execute-docs.ts`, `src/mcp-docs-tool-definitions.ts`, `src/mcp-handlers/docs-handlers.ts`.
- Edited production: `src/mcp-tools.ts`, `src/repo-automation-tool-names.ts`, `src/mcp-repo-automation-tool-definitions.ts`, `src/mcp-tool-definitions.ts`, `src/repo-automation-service-contract.ts`, `src/repo-automation-service.ts`.
- New tests: `test/docs-command-envelope.test.ts`, `test/mcp-tool-inputs-docs.test.ts`, `test/mcp-tool-inputs-docs.ledger.test.ts`, `test/repo-automation-execute-docs.test.ts`, `test/mcp-docs-tool-definitions.test.ts`, `test/mcp-handlers/docs-handlers.test.ts`, `test/mcp-server.docs.test.ts`.
- Edited tests: `test/mcp-server.test.ts`, `test/mcp-discovery-authority-tool-definitions.test.ts`, `test/mcp-server-test-service.ts`, `test/repo-automation-service.test.ts`.
- Configuration: `jest.docs-coverage.json` (new), `jest.config.cjs` (edited).
- Documentation: extension `README.md`, `CHANGELOG.md`; six `execution-environment/SKILL.md` copies; feature folder plan, spec, user story and 29 evidence files.

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT (pending CI only)

### Policy-by-Policy Summary

| Policy | Verdict |
|---|---|
| General unit test | PASS |
| General code change | PASS, with stage 6 pending CI (PA-1) |
| TypeScript code change and unit test | PASS |
| Coverage (TypeScript) | PASS |
| File size | PASS |
| Evidence location | PASS |
| Owner directive on language | PASS |

### Metrics Summary

- TypeScript suite coverage 97.10% lines / 93.77% branches; new modules 99.88% / 98.05%.
- 0 lint errors, 0 type errors, 0 suppressions, 0 `any`.

### Recommendation

Open the pull request into `epic/documentation-estate-tooling-integration`. Epic-child PRs do not trigger `ci.yml` automatically, so dispatch it manually against the branch head. When CI is green, the item's orchestrator run checks off SAC-27, SAC-31, US2-6 and US3-6 and plan tasks [P7-T4], [P8-T7] and [P8-T13] at S9, then re-runs the CI gate on the resulting head.

## Appendix A: Test Inventory

| Test file | Top-level test declarations |
|---|---|
| `test/docs-command-envelope.test.ts` | 8 |
| `test/mcp-tool-inputs-docs.test.ts` | 8 |
| `test/mcp-tool-inputs-docs.ledger.test.ts` | 5 |
| `test/repo-automation-execute-docs.test.ts` | 9 |
| `test/mcp-docs-tool-definitions.test.ts` | 7 |
| `test/mcp-handlers/docs-handlers.test.ts` | 7 |
| `test/mcp-server.docs.test.ts` | 4 |

Several declarations iterate over case tables, so the executed test count is higher than the declaration count.

## Appendix B: Toolchain Commands Reference

Working directory `extensions/drm-copilot` unless stated:

- Formatting: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- Linting: `npm run lint`
- Type checking: `npm run typecheck`
- Testing with coverage: `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=lcov`
- Shuffle: `node run-jest.cjs --randomize --seed=1036`
- Contract tests (repository root): `poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q --no-cov`
- Evidence locations (repository root): `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`

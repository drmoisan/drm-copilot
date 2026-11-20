# Policy Compliance Audit: expose-pr-context-script (#77)

**Audit Date:** 2026-03-04  
**Base branch:** `origin/development` (user-provided, merge-base resolved)  
**Feature folder selection rule:** User explicitly provided `docs/features/active/2026-03-04-expose-pr-context-script-77`, so this folder was used as authoritative scope.  
**Code Under Test (effective working-tree scope):**
- `extensions/scaffold-extension/package.json`
- `extensions/scaffold-extension/src/extension.ts`
- `extensions/scaffold-extension/test/extension.test.ts`
- `extensions/scaffold-extension/test/extension.integration.test.ts`
- `extensions/scaffold-extension/resources/templates/collect_pr_context.py` (untracked)
- `jest.config.cjs`

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---:|---:|---|---|---|---|
| TypeScript | 5 | 33 | ✅ 33 pass, 0 fail | 100.00% statements / 100.00% branches / 100.00% functions / 100.00% lines (`evidence/baseline/ts-test-coverage.2026-03-04T23-20.md`) | 84.78% statements / 65.62% branches / 81.81% functions / 84.67% lines (current run + `evidence/qa-gates/ts-test-coverage.2026-03-04T23-26.md`) | UNVERIFIED (no changed-lines metric emitted) |
| Python | 1 | 801 (repo suite) | ✅ 801 pass, 0 fail | N/A for this feature | TOTAL 81% on configured Python coverage targets | UNVERIFIED for the new bundled script |

## Executive Summary

Overall status: **⚠️ PARTIALLY COMPLIANT / Needs revision**.

Strong positives:
- TypeScript lint, type-check, and unit/integration tests pass.
- Python lint/type/test gates pass.
- Command behavior for PR-context collection is implemented and tested for key UX/runtime paths.

Blocking/major policy issues:
1. Formatting checks fail (`npm run format:check`, extension Prettier check, and `black --check` on bundled Python script).
2. Coverage regression is documented and unresolved (baseline 100% -> post 84.67% lines; no-regression gate FAIL in existing evidence).
3. `extensions/scaffold-extension/test/extension.test.ts` exceeds 500-line file limit (524 lines).
4. Plan checklist in `plan.2026-03-04T23-07.md` shows QA complete while current branch state is no longer clean.

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independence | ✅ PASS | Jest tests use isolated mocks/reset in `beforeEach`; no shared mutable state leaks across tests. |
| Isolation | ✅ PASS | Tests target specific command behaviors (`collectPrContext` registration, cancel, args, default branch, cwd). |
| Fast execution | ✅ PASS | Current unit run: 33 tests in ~0.33s. |
| Determinism | ✅ PASS | Controlled mock outputs for `spawn`/`spawnSync`, deterministic branch lists, no network/filesystem dependency for assertions. |
| Readability | ✅ PASS | Test names are scenario-explicit and aligned to acceptance criteria. |
| Baseline coverage documented | ✅ PASS | `evidence/baseline/ts-test-coverage.2026-03-04T23-20.md` captured with numeric metrics. |
| No coverage regression | ❌ FAIL | `evidence/qa-gates/ts-coverage-delta.2026-03-04T23-26.md` explicitly reports regression in all tracked categories. |
| New code coverage >= 90% | ⚠️ PARTIAL | Not measurable from available workflow (`text-summary` only). Explicitly marked unavailable in `ts-coverage-delta.2026-03-04T23-26.md`. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Clarify objective / plan docs read | ✅ PASS | `issue.md`, `spec.md`, `user-story.md`, and `plan.2026-03-04T23-07.md` present and scoped to #77. |
| Simplicity / separation of concerns | ✅ PASS | `extension.ts` keeps command orchestration, runtime detection, and process execution in separated helpers. |
| Cohesive modules | ✅ PASS | Changed files stay focused on extension command flow and tests. |
| Under 500 lines (all files, incl. tests) | ❌ FAIL | `extensions/scaffold-extension/test/extension.test.ts` is 524 lines (line-count capture from terminal). |
| Naming/docs/comments | ✅ PASS | TypeScript symbol names are descriptive; test names and helper names are clear. |
| Toolchain loop final clean pass | ❌ FAIL | Current pass has formatting failures and unresolved coverage regression gate. |
| Summarize and update supporting docs | ⚠️ PARTIAL | Prior evidence exists, but current working state diverges from checked-off plan QA items. |

## 3. Language-Specific Compliance

### TypeScript (repo policy + tooling)

| Requirement | Status | Evidence |
|---|---|---|
| Formatting check | ❌ FAIL | `npm run format:check` fails (`tests/unit/hello-typescript.test.ts`); extension Prettier check fails (`package.json` + unmatched pattern warning). |
| Lint | ✅ PASS | `npm run lint` and `npm --prefix extensions/scaffold-extension run lint` both pass. |
| Type check | ✅ PASS | `npm run typecheck` and `npm --prefix extensions/scaffold-extension run typecheck` pass. |
| Tests | ✅ PASS | Coverage run passes: 3 suites / 33 tests. |

### Python (changed bundled script)

| Requirement | Status | Evidence |
|---|---|---|
| Black check | ❌ FAIL | `poetry run black --check extensions/scaffold-extension/resources/templates/collect_pr_context.py` -> would reformat file. |
| Ruff | ✅ PASS | `poetry run ruff check ...collect_pr_context.py` passes. |
| Pyright | ✅ PASS | `poetry run pyright` -> 0 errors. |
| Pytest | ✅ PASS | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` -> 801 passed, TOTAL 81%. |

## 4. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

**Recommendation:** **Needs revision** before PR merge.

Required fixes to reach merge-ready:
1. Resolve formatting failures (root Prettier, extension Prettier, Black for bundled Python file).
2. Address or justify coverage regression and produce measurable new-code coverage evidence.
3. Refactor `extensions/scaffold-extension/test/extension.test.ts` under 500 lines.
4. Reconcile `plan.2026-03-04T23-07.md` checkboxes with actual current QA state.

## Appendix B: Commands Executed (check-only where possible)

- `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/development`
- `npm run format:check` **(failed)**
- `npm run lint` **(passed)**
- `npm run typecheck` **(passed)**
- `npm run test:unit -- --coverage --coverageReporters=text-summary` **(passed)**
- `npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` **(failed)**
- `npm --prefix extensions/scaffold-extension run lint` **(passed)**
- `npm --prefix extensions/scaffold-extension run typecheck` **(passed)**
- `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs --coverage --coverageReporters=text-summary` **(passed)**
- `poetry run black --check extensions/scaffold-extension/resources/templates/collect_pr_context.py` **(failed)**
- `poetry run ruff check extensions/scaffold-extension/resources/templates/collect_pr_context.py` **(passed)**
- `poetry run pyright` **(passed)**
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` **(passed)**

**Audit Completed By:** GitHub Copilot (GPT-5.3-Codex)

# Policy Compliance Audit: expose-commit-script (#74)

**Audit Date:** 2026-03-03  
**Feature Folder:** `docs/features/active/2026-03-03-expose-commit-script-74`  
**Base Branch:** `development` (provided; merge-base resolved)  
**Head Branch:** `feature/expose-commit-script-74`

## Feature-folder selection rule used

Selected `docs/features/active/2026-03-03-expose-commit-script-74` because it was explicitly requested and matches branch suffix issue number `-74`.

## Executive Summary

- PR context artifacts were regenerated with `poetry run python -m scripts.dev_tools.pr_context.collector --base development`.
- Summary artifact is stale/degenerate for diff scope (base/head/merge-base all equal), so scope evidence was taken from `artifacts/pr_context.appendix.txt` working-tree diff + direct file inspection.
- Type/lint/tests are passing for changed Python + extension TypeScript targets.
- **Blocking gap:** check-only format command currently fails for `extensions/scaffold-extension/package.json` and also used an unmatched `test/**/*.ts` glob.

**Overall Status:** ⚠️ **PARTIALLY COMPLIANT**  
**Recommendation:** **Needs revision before merge**

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---:|---:|---|---|---|---|
| TypeScript | 4 | 2 suites / 25 tests | ✅ PASS | UNVERIFIED | UNVERIFIED | UNVERIFIED |
| Python | 3 | 56 tests (targeted) | ✅ PASS | UNVERIFIED | UNVERIFIED | UNVERIFIED |

Notes:
- Existing baseline/QA evidence exists under `evidence/baseline/` and `evidence/qa-gates/` from prior implementation run.
- This review run was check-only and did not execute repo-wide coverage collection.

## Policy Evaluation

### General code + test policy

| Requirement | Status | Evidence |
|---|---|---|
| Objective/plan documents present | ✅ PASS | `issue.md`, `spec.md`, `user-story.md`, and `plan.2026-03-03T21-15.md` exist in feature folder. |
| Policy-aware workflow artifacts present | ✅ PASS | Evidence artifacts exist under `evidence/baseline/`, `evidence/qa-gates/`, `evidence/other/`. |
| Toolchain checks executed and documented | ⚠️ PARTIAL | Lint/type/test pass, but check-only format fails in current branch state (see command output below). |
| Test quality (deterministic, isolated) | ✅ PASS | Extension tests are mocked/deterministic; Python tests are local, deterministic (`56 passed`). |

### TypeScript policy (extension)

| Requirement | Status | Evidence |
|---|---|---|
| Command contribution + activation wiring | ✅ PASS | `extensions/scaffold-extension/package.json:21-22`, `extensions/scaffold-extension/src/extension.ts:205-214`. |
| Runtime args contract | ✅ PASS | `extensions/scaffold-extension/src/extension.ts:17`, `:165` (`args?: ReadonlyArray<string>`, spread into argv). |
| Tests for new command behavior | ✅ PASS | `extensions/scaffold-extension/test/extension.test.ts` and `extension.integration.test.ts` include registration, workspace/runtime failures, argv/cwd, error paths, staged/no-staged sections. |
| Formatting check clean | ❌ FAIL | `npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` -> exit 1 (`package.json` style issues; unmatched `test/**/*.ts`). |

### Python policy (changed files)

| Requirement | Status | Evidence |
|---|---|---|
| Black/Ruff/Pyright clean | ✅ PASS | Commands run on changed files; all passed. |
| Regression tests for behavior change | ✅ PASS | `tests/scripts/dev_tools/test_feature_docs.py:375` adds minor-audit regression; targeted pytest run passed (`56 passed`). |
| Strong typing / explicit contracts | ✅ PASS | `scripts/dev_tools/pr_context/feature_docs.py` changes remain fully typed and pyright-clean. |

## Temporary artifacts cleanup

| Requirement | Status | Evidence |
|---|---|---|
| Temporary scripts removed or justified | ✅ PASS | No new ad-hoc scripts created during this review run. |

## Gaps and Exceptions

1. **Formatting gate is currently failing in check-only mode** for extension package manifest.
2. **PR context summary diff scope is not reliable** for uncommitted changes (base/head identical); appendix and direct file inspection were required.
3. Coverage deltas (baseline vs post-change vs new-code >=90%) remain **UNVERIFIED** in this review run.

## Compliance Verdict

**Overall Status:** ⚠️ **PARTIALLY COMPLIANT**

- General Code Change Policy: ⚠️ PARTIAL (format gate failure)
- General Unit Test Policy: ✅ PASS (deterministic and passing targeted suites)
- TypeScript policy: ⚠️ PARTIAL (format gap)
- Python policy: ✅ PASS

**Recommendation:** **Needs revision** (formatting gate + coverage verification evidence).

## Appendix B: Commands executed (check-only)

- `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
- `npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- `npm --prefix extensions/scaffold-extension run lint`
- `npm --prefix extensions/scaffold-extension run typecheck`
- `npm --prefix extensions/scaffold-extension run test -- --runInBand`
- `poetry run black --check scripts/dev_tools/pr_context/feature_docs.py tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_feature_docs.py`
- `poetry run ruff check scripts/dev_tools/pr_context/feature_docs.py tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_feature_docs.py`
- `poetry run pyright scripts/dev_tools/pr_context/feature_docs.py tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_feature_docs.py`
- `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_feature_docs.py -q`

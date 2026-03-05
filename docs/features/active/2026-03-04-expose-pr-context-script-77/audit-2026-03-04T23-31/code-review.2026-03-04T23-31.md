# Code Review — expose-pr-context-script (#77)

**Date:** 2026-03-04  
**Base branch:** `origin/development`  
**Feature folder selection rule:** Explicitly provided by user (`docs/features/active/2026-03-04-expose-pr-context-script-77`).

## Executive Summary

This feature adds a new extension command, `scaffoldExtension.collectPrContext`, plus branch discovery/defaulting, quick-pick branch selection, and test coverage around command behavior. The implementation is coherent and test-backed for primary UX flow.

Top risks:
1. **Policy gate risk:** formatting currently fails in both TS and Python paths.
2. **Quality gate risk:** documented TypeScript coverage regression and missing changed-lines coverage metric.
3. **Maintainability risk:** `extension.test.ts` exceeds repo 500-line file limit.

**PR readiness recommendation:** **No-Go (Needs revision)**.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/scaffold-extension/test/extension.test.ts` | file-level | File length is 524 lines, violating repo max 500-line rule (applies to tests). | Split into focused suites (`extension.collect-pr-context.test.ts`, runtime tests, common helpers). | Keeps tests maintainable and policy-compliant. | Terminal line count capture: `extension.test.ts 524`. |
| Major | `extensions/scaffold-extension/resources/templates/collect_pr_context.py` | file-level | Python formatting gate fails (`black --check` would reformat). | Run formatter and re-verify lint/type/tests. | Repo toolchain requires clean formatting pass. | `poetry run black --check ...collect_pr_context.py` failed. |
| Major | `jest.config.cjs` + test evidence | coverage gate | No-regression gate currently fails vs feature baseline (`100%` -> `84.67%` lines; branch coverage `65.62%`). | Add/adjust tests to recover baseline intent or explicitly reset baseline with approved rationale + updated evidence. | Existing feature evidence already marks no-regression FAIL. | `evidence/qa-gates/ts-coverage-delta.2026-03-04T23-26.md`. |
| Major | Root/extension formatting | toolchain | Root and extension formatting checks fail (`tests/unit/hello-typescript.test.ts`, extension `package.json`). | Run formatting and rerun full QA loop from format -> lint -> typecheck -> tests. | Must pass in one clean loop per policy. | `npm run format:check` and extension Prettier check failures. |
| Minor | `extensions/scaffold-extension/src/extension.ts` | `discoverPrBaseBranches` + error paths | PR command has good happy-path/cancel tests, but explicit tests for PR-specific git-failure and non-zero-exit logging context are limited. | Add targeted tests for `collectPrContext` git discovery failure and collector non-zero exit diagnostics. | Strengthens confidence in ACs about actionable failure paths. | Current tests emphasize registration/cancel/default/args/cwd; less direct on PR-specific failure branches. |

## Typed Python Audit

Python changed file: `extensions/scaffold-extension/resources/templates/collect_pr_context.py`.

- Typing: uses `list[str] | None` signatures; no new `Any` introduced. ✅
- Suppressions: uses pre-authorized `BLE001` comment for CLI top-level catch. ✅
- Lint/type: Ruff and Pyright pass. ✅
- Formatting: Black fails currently. ❌
- Public API/docs: script has module/function docstrings; clear enough for bundled utility. ✅

## Test Quality Audit

- Deterministic/unit-isolated behavior is strong (mocked subprocess + quick-pick controls). ✅
- Integration tests cover no script materialization and workspace path with spaces/unicode. ✅
- Remaining gaps for stricter AC confidence:
  - explicit PR-command git discovery failure behavior assertion,
  - explicit PR-command non-zero collector exit diagnostic assertion.
- Coverage governance currently unresolved due regression and unavailable changed-lines metric. ❌

## Security and Correctness Checks

- No hardcoded secrets observed. ✅
- Subprocess calls use argv arrays with `shell: false`. ✅
- Runtime and workspace validation paths are explicit. ✅
- Git branch discovery failures throw explicit errors. ✅

## Conclusion

Implementation direction is good and largely complete for core UX. However, this branch is **not yet merge-ready** until formatting issues, coverage-gate evidence, and test-file size policy violations are resolved.

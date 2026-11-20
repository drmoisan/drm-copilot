# Code Review: F8 ts-new-active-feature-folder (Issue #240) — R4 Re-Review

**Review Date:** 2026-06-26T05-44
**Review Cycle:** R4 (post-remediation re-review)
**Resolved base branch:** `main`
**Merge-base SHA:** `c432b69a294ef17ace8b64964b6b0cafb22bd450`
**Branch head:** `6afaf7ec243d942d45ee3aadbfed39af8c2a2ce5`
**Reviewer:** feature-review agent

## Executive Summary

F8 ports the Python `new_active_feature_folder` cluster to in-process TypeScript and rewires `RepoAutomationService.newActiveFeatureFolder()` from a Python subprocess spawn to a direct in-process call. This R4 cycle re-reviews the full branch diff against `main` after remediation of the single R3 Blocking finding.

The R3 Blocking finding (`io.ts` = 542 lines exceeding the 500-line hard limit) is **resolved**. The remediation commit (`6afaf7e`) extracted the VS Code launcher seam into a new `io-launcher.ts` (188 lines) and re-exports its symbols from `io.ts` (now 386 lines), preserving every prior `./io` import path. The split is clean: `io-launcher.ts` imports only from the F1 shared layer (`subprocess-runner`, `file-system`) and never from `io.ts`, so the dependency direction is one-way and no circular import is introduced. The module docstring explicitly states and justifies this constraint.

Reviewer-independent toolchain: Prettier `--check` clean, ESLint 0 errors / 0 warnings, `tsc --noEmit` 0 errors, 999/999 Jest tests pass across 85 suites. Coverage on every new cluster file exceeds the uniform thresholds (line >= 85%, branch >= 75%). The port preserves byte-identical regexes, error messages, the `gh --json` field list, the bug-template copy `break` control flow, and the escape-safe (function-form replacement) `setSection`/`updateSectionBody` regression fixes.

No new defects were identified. The only divergence is the documented, accepted D1 (Jest vs Vitest) and the documented naive-datetime `getEstTimestamp` divergence.

**Overall assessment: APPROVE.** No blockers. The remediation is correct and minimal.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Resolved (was Blocking in R3) | `src/lib/new-active-feature-folder/io.ts` | whole file | R3 reported 542 lines, over the 500-line hard limit. R4: file is now 386 lines after the launcher seam was extracted to `io-launcher.ts`. | None — resolved. | `.claude/rules/general-code-change.md` "File Size Limit" (500 lines). The plan Split Strategy mandated this exact contingent split. | `wc -l io.ts` = 386; `wc -l io-launcher.ts` = 188; commit `6afaf7e`. |
| Info | `src/lib/new-active-feature-folder/io-launcher.ts` | lines 16-17, module docstring | New module documents the one-directional `io.ts -> io-launcher.ts` import constraint to prevent a cycle. | None — correct design. | Avoids circular dependency; lint with `eslint-plugin-import` confirms 0 errors. | File read; `npm run lint` 0 errors. |
| Info | `src/lib/new-active-feature-folder/io.ts` | lines 29-39 | `io.ts` imports `defaultWhichLookup` from `io-launcher` and re-exports the launcher public surface (`INSIDERS_SIGNAL_NAMES`, `isInsidersSession`, `resolveCodeCli`, `defaultCodeLauncher`, etc.) so consumers and tests that import from `./io` are unaffected. | None. | Preserves the public API; `io.test.ts` exercises the launcher symbols via the re-export and passes. | File read; tests pass. |
| Info | `src/lib/new-active-feature-folder/io.ts` | lines 338-385 (`defaultIssueFetcher`) | `gh issue view <n> --json number,title,url,author,updatedAt` invoked via the injected `CommandRunner` with `allowError: true`; parses stdout as `unknown` then narrows; returns `null` on missing gh / non-zero exit / blank stdout / parse error. Byte-identical to the Python parity target and the plan spec. | None. | Parity preserved; no `any`; guarded optional dependency. | File read lines 338-385; AC-F8-3 parity. |
| Info | `src/repo-automation-service.ts` | lines 347-355 | `newActiveFeatureFolder` body replaced the Python-spawn delegation with a single `newActiveFeatureFolderServiceCall({ ...input, runner, templateRoot, log })` call; the unused `buildNewActiveFeatureFolderOptions` import was removed. File is 499 lines (<= 500). | None. | In-process wiring per AC-F8-7; `--template-root` parity preserved by forwarding `this.templateRoot`. | `git diff` of the service file; `wc -l` = 499. |
| Info (accepted) | cluster tests | all | Tests use Jest (`@jest/globals`) rather than Vitest. | None — accept per D1. | D1 recorded in `spec.md`; package-wide condition, not introduced by F8. | `spec.md` Decisions section. |
| Info (accepted) | `src/lib/new-active-feature-folder/models.ts` | `getEstTimestamp` docstring (~line 311) | The Python naive-datetime `ValueError` guard has no TS analogue (a `Date` carries no naive form); documented intentional divergence; no spurious throw introduced. | None. | Documented in `models.ts` and `evidence/regression-testing/f8-port-parity.md`. | File read; parity artifact. |
| Info (pre-existing) | `test/extension.workflow-commands.test.ts` | whole file | 775 lines (over 500). Pre-existing condition: was 790 at merge-base; F8 reduced it by 15 lines. | Out of F8 scope. Track separately if a future feature touches this file substantially. | The over-limit condition predates F8 and was not introduced or worsened. | `git show c432b69:...` = 790; current `wc -l` = 775. |

## Detailed Observations

### Remediation correctness (primary R4 focus)

The R3 remediation is the minimal, plan-prescribed fix. The plan Split Strategy (line 55) stated: "If `io.ts` would exceed 500 lines, extract the VS Code launcher seam into `io-launcher.ts` and re-export." The remediation does exactly this:

- `io-launcher.ts` (188 lines) contains `INSIDERS_SIGNAL_NAMES`, `defaultWhichLookup`, `defaultEnvLookup`, `isInsidersSession`, `resolveCodeCli`, `CodeLauncherDeps`, and `defaultCodeLauncher`. All seams (env, which, runner) remain injectable with production defaults, so tests never touch the real environment, PATH, or `code`.
- `io.ts` re-exports the launcher surface, leaving the consumer-facing API unchanged.
- No behavior change: the 999 tests (including the launcher-seam tests in `io.test.ts`) pass unchanged, and launcher coverage is 97.87% line / 84.61% branch.

### Toolchain and coverage (reviewer-independent)

- Format: `npx prettier --check` over all changed source and test files → clean.
- Lint: `npm run lint` → 0 errors, 0 warnings.
- Typecheck: `npm run typecheck` → 0 errors.
- Tests: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` → 999/999 pass, 85 suites, 2.527s.
- Coverage (cluster): `models.ts` 97.36/83.33, `markdown.ts` 100/93.1, `io.ts` 99.48/91.04, `io-launcher.ts` 97.87/84.61, `docs.ts` 100/100, `flow.ts` 99.54/92.1, `new-active-feature-folder-service-call.ts` 100/100, `index.ts` 100 line (re-export facade). All executable files exceed line >= 85% / branch >= 75%; `src/lib/**` overall 97.52/90.7 (no regression vs 97.36/87.55 baseline).

### Scope containment

`git diff --name-only` confirms no change to `command-runtime.ts`, the `"python"` runtime branch, `executeScript`, `repo-automation-args.ts`, `repo-automation-service-workflows.ts` (`buildNewActiveFeatureFolderOptions` body), `mcp-handlers/feature-entry-handlers.ts`, `mcp-tool-inputs.ts`, the Python sources under `resources/**` and `scripts/dev_tools/**`, or the F1 shared interfaces. The change set matches the plan's allowed list.

### Best-practices review

- **Simplicity / SoC:** Pure logic (`models`, `markdown`) is cleanly separated from I/O (`io`, `io-launcher`, `RealFolderFileSystem`) and service wiring. The launcher extraction further improves cohesion.
- **Error handling:** Fail-fast with byte-identical error messages; the optional `gh` dependency is guarded and returns `null` rather than throwing.
- **Typing:** No `any` in executable code; `gh` output parsed as `unknown` then narrowed. No suppressions.
- **Determinism:** Injected `nowProvider`, `gh`/env/which lookups, and `CommandRunner`; deterministic `America/New_York` formatting via `Intl.DateTimeFormat`; no banned wall-clock or RNG APIs.
- **Naming/structure:** kebab-case filenames, ES modules, AAA tests, tests mirror source under `test/lib/new-active-feature-folder/`.

## Conclusion

The R3 Blocking finding is resolved by a correct, minimal launcher-seam split. No new defects were found in the full-branch re-review. The feature is recommended for merge.

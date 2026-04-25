# Code Review: 2026-04-05-ci-failing-error-128 (Reduced Audit Re-Review)

**Review Timestamp:** 2026-04-05T20-45  
**Base Branch:** `development`  
**Feature Folder:** `docs/features/active/2026-04-05-ci-failing-error-128/`  
**Feature Folder Selection Rule:** Used the user-specified active feature folder and confirmed it matches the refreshed PR-context additional-context entries.

## Executive Summary

The remediated branch state resolves the prior policy blocker without widening the production fix. The current working tree keeps the behavioral fix in `extensions/drm-copilot/src/command-runtime.ts`, splits the oversized extension test surface into focused companion files, preserves the four required Windows-root POSIX regressions exactly as named, and passes the live extension verification sequence.

### Top 3 residual risks

1. The refreshed canonical PR-context artifacts remain commit-based and do not yet reflect the unstaged remediation working tree; commit the current state before using PR-context-derived automation for PR authoring.
2. The review artifacts created across `20-20`, `20-42`, and this `20-45` refresh are all present in the feature folder; ensure only the intended latest artifacts are cited in the eventual PR description.
3. The reduced-audit pass depends on the companion helper split remaining unchanged; any further scope growth in test files should be rechecked against the 500-line policy immediately.

### Recommendation

**Go** for PR readiness. No additional remediation is required for the reduced audit.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| None | — | — | No blocker, major, or minor defects were identified in the remediated working tree. | Proceed with commit/PR preparation using the refreshed `20-45` audit set. | The previous blocker was the oversized touched test file; the current line counts and live green verification resolve that issue. | `evidence/final-qa/final-scope-and-line-counts.md`; live Prettier/ESLint/TSC/Jest runs at 20:45 |
| Nit | `artifacts/pr_context.summary.txt` | whole artifact | The PR-context summary still reflects `HEAD` rather than the unstaged remediation working tree. | Regenerate PR-context after committing the remediation if a PR body or downstream automation will rely on it. | Review evidence remains sound because it is supplemented by live `git status`, direct file inspection, and current test runs, but PR-context-derived automation should ideally match the committed branch state. | Refreshed collector run plus `git status --short` showing unstaged remediation files |

## Typed TypeScript / Test-Surface Audit

### Scope and typing

- `extensions/drm-copilot/src/command-runtime.ts` remains the only production TypeScript file carrying the bug fix.
- The remediation added companion test/helper files only:
  - `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
  - `extensions/drm-copilot/test/extension-test-harness.ts`
  - `extensions/drm-copilot/test/runtime-test-helpers.ts`
- The helper split retains explicit types for executable presence, mocked fs behavior, mocked child processes, and command handlers.
- No new `any`, `@ts-ignore`, or broad ESLint suppressions were introduced.

### File-size compliance

The touched test/helper files now satisfy the repository 500-line rule:

- `extension.test.ts` — 251 lines
- `extension.workflow-commands.test.ts` — 393 lines
- `extension-test-harness.ts` — 244 lines
- `runtime-test-helpers.ts` — 135 lines
- `repo-automation-service.test.ts` — 234 lines

### Correctness and control-flow review

- `resolveBundledScriptPath()` still contains the targeted Windows drive-root guard and remains exported.
- The regression names required by the approved plan and remediation inputs are still present exactly as authored:
  - `helloPython preserves C:/extension on POSIX hosts`
  - `helloPowerShell preserves C:/extension on POSIX hosts`
  - `collectCommitContext preserves C:/extension on POSIX hosts`
  - `newPotentialEntry preserves C:/extension on POSIX hosts`
- Subprocess safety assertions (`shell: false`, argv-array execution) remain covered in the touched test files.

## Test Quality Audit

- **Deterministic:** Yes. All touched tests rely on mocks for VS Code APIs, `node:fs`, `node:child_process`, and controlled PATH/PATHEXT values.
- **Isolated:** Yes. Each suite resets harness state in `beforeEach`/`afterEach`; fresh-module POSIX tests explicitly reset module state in `finally` blocks.
- **Fast:** Yes. Targeted slice completed in 0.368 s; full extension unit suite completed in 1.033 s during this review.
- **Clear failure messages:** Yes. The regression names are descriptive and assert explicit bundled-path expectations.
- **Coverage expectations:** Satisfied for this re-review. `final-jest-coverage.md` reports a passing coverage run with 89.36% lines overall, and the production fix coverage reference remains above the repo threshold.

## Security and Correctness Checks

- **Secrets in code:** None observed in touched files.
- **Unsafe subprocess usage:** None observed. The touched tests continue to assert argv-array subprocess launches with `shell: false`.
- **Input validation at boundaries:** The command and repo-automation tests continue covering missing runtime, missing workspace, and invalid input paths where applicable.

## Research Log

No external research was needed for this re-review. Evidence came from repository policy files, the approved plan/remediation documents, direct source inspection, and live verification commands.

## Review Conclusion

The reduced audit now passes. The prior blocker was structural and has been resolved without widening the production fix. The branch is ready for PR review once the current working-tree state and refreshed audit artifacts are committed.

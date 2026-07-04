# Code Review: codex-worktree-session-regression (#281)

**Review Date:** 2026-07-03
**Reviewer:** Codex feature-review workflow
**Feature Folder:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281`
**Feature Folder Selection Rule:** Explicit user-provided active feature folder, matching branch issue number #281.
**Base Branch:** `main`
**Head Branch:** `bug/codex-worktree-session-regression-281`
**Review Type:** Initial feature branch review

## Executive Summary

The branch addresses Issue #281 by preserving the generic VS Code extension boundary while passing explicit source and worktree roots to the repository post-Codex script. The PowerShell resource script now plans and applies deterministic `.codex` and `.agents` copy operations, skips transient paths, logs concise summaries, and exposes testable function boundaries. The added tests cover the command order, resolved Codex launch shape, trust command serialization, source-root resolution, copy planning, rerun behavior, skip filtering, and failure propagation.

Implementation quality is acceptable for the changed TypeScript and PowerShell code. The branch is not ready for normal PR flow because full branch range whitespace validation fails on `spec.md`.

**What changed:**
The production delta is one TypeScript contract/comment change in `extensions/drm-copilot/src/codex-worktree-session.ts` and a larger PowerShell update in `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1`. Test changes add focused Jest and Pester coverage for Issue #281 behavior.

**Top 3 risks:**
1. The committed branch contains trailing whitespace in `spec.md`, which fails `git diff --check <merge-base>...HEAD`.
2. The final QA evidence used `git diff --check` without the base range and did not catch the committed whitespace issue.
3. GitHub CLI was unavailable during PR context generation, so CI and issue metadata were not verified from GitHub.

**PR readiness recommendation:** **Needs Revision** - remediate the committed whitespace and update range-based QA evidence before PR readiness can be reported.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md` | line 85 | The committed branch contains trailing whitespace. | Remove the trailing tab/whitespace and rerun `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD`. | The feature-review scope is the full branch diff; committed whitespace failures block policy compliance. | Review command returned `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md:85: trailing whitespace.` |
| Major | `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/git-diff-check.2026-07-03T09-14.md` | command section | The recorded QA evidence used `git diff --check` without the merge-base range. | Replace or supersede the evidence with a range-based command artifact after remediation. | A clean working-tree diff check does not validate committed whitespace across the feature-vs-base branch diff. | `git diff --check` evidence exited 0, while `git diff --check 476b110...HEAD` exited 1. |

No Blocker findings were identified in the TypeScript or PowerShell implementation.

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- `CodexWorktreeSessionCommandInput.postCodexScriptPath` now documents that the script path is resolved from the source root before command construction.
- Existing command construction continues to pass `-SourceRoot` and `-WorktreeRoot` explicitly to the post-Codex script.
- Tests assert that the post-Codex command is sent after trust setup and before Codex launch.

#### Type safety and maintainability

- No new TypeScript suppression was found in changed TypeScript files.
- The command builder preserves explicit typed input and output interfaces.
- `src/codex-worktree-session.ts` remains 102 lines and focused on command generation.

#### Error handling and logging

- The TypeScript command builder remains deterministic and does not introduce new catch-all error handling.
- Missing executable behavior is covered by existing command-handler tests and evidence, although the implementation for runtime resolution is not modified in this branch diff.

### PowerShell implementation audit

#### What changed well

- The script uses strict mode and stop-on-error semantics.
- Source-root resolution is factored into `Resolve-CodexCustomizationSourceRoot`.
- Copy planning is separated from copy execution and summary logging.
- Transient path filtering is explicit and deterministic.
- Existing destination behavior is rerunnable because copy operations create directories with `-Force` and copy files with `-Force`.

#### API and safety notes

- Functions use `[CmdletBinding()]` and mandatory parameters where appropriate.
- External git execution is isolated behind an injectable `$InvokeGit` scriptblock for tests.
- Copy scope is limited to `.codex` and `.agents`.
- The script does not introduce new runtime dependencies.

#### Error handling and logging

- Copy failures propagate rather than being swallowed.
- Logging reports source root, worktree root, copied count, and skipped count without dumping every file.
- Missing source customization folders are skipped rather than treated as fatal.

## Test Quality Audit

The reviewed test set is focused and aligned with the regression. TypeScript coverage is high and stable. PowerShell repo-wide coverage is high; focused changed-script line entries are exactly at the 80% threshold based on `coverage.xml`.

### Reviewed test and QA artifacts

- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/typescript-test-coverage-final.2026-07-03T09-14.md` - TypeScript final Jest coverage passed; 121 suites and 1462 tests.
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/powershell-test-coverage-final.2026-07-03T09-14.md` - PowerShell final Pester coverage passed; 941 tests, 0 failures.
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/regression-testing/windows-powershell-validation.2026-07-03T09-14.md` - Records Windows PowerShell validation for command sequence and customization copy simulation.
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/git-diff-check.2026-07-03T09-14.md` - Insufficient as full branch evidence because it used `git diff --check` without the base range.

### Quality assessment prompts

- **Determinism:** Tests use mocked extension harness state, explicit executable presence, and injected PowerShell delegates.
- **Isolation:** Each added assertion targets one command-shape, copy-planning, source-resolution, logging, or failure behavior.
- **Speed:** TypeScript final coverage completed in 5.195 seconds according to the evidence artifact.
- **Diagnostics:** Assertions compare exact command text, order positions, paths, and thrown messages, which should produce actionable failures.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection found no hard-coded credentials or `.env` content. |
| No unsafe subprocess or command construction | PASS | PowerShell git invocation is isolated to `git @GitArgs`; TypeScript command paths are quoted through existing quoting helpers. |
| Input validation at boundaries | PASS | PowerShell functions use mandatory parameters where required; blank source root falls through explicit resolution logic. |
| Error handling remains explicit | PASS | Strict mode and stop-on-error are active; copy failure test verifies propagation. |
| Configuration / path handling is safe | PASS | The extension/script boundary passes explicit source and destination roots; transient paths are skipped. |
| Full branch whitespace cleanliness | FAIL | `git diff --check 476b110...HEAD` reports `spec.md:85` trailing whitespace. |

## Research Log

No external research was required for this review. Evidence came from repository policy files, PR context artifacts, feature documents, branch diff inspection, and local check-only commands.

## Verdict

The TypeScript and PowerShell implementation is acceptable based on code inspection and available tests. The review result is remediation required because the committed branch fails full branch whitespace validation and the recorded QA evidence did not exercise the required feature-vs-base diff range.

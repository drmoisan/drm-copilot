# Feature Audit: codex-worktree-session-regression (#281)

**Audit Date:** 2026-07-03
**Feature Folder:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281`
**Base Branch:** `main`
**Head Branch:** `bug/codex-worktree-session-regression-281`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Base branch:** `main` at merge base `476b110cc53c7f26a573c9cf23b4f3dba1b095a9`
- **Head branch/commit:** `bug/codex-worktree-session-regression-281` at `9f611a2ad55e5631a81034267c42885cdb2c3fc6`
- **Merge base:** `476b110cc53c7f26a573c9cf23b4f3dba1b095a9`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/**`
  - Additional evidence: local review commands run during this audit
- **Feature folder used:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281`
- **Requirements source:** `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md`
- **Work mode resolution note:** `issue.md` contains `- Work Mode: full-bug`, so `spec.md` is the only authoritative acceptance-criteria source.
- **Scope note:** The audit evaluates the full feature branch against `main`, not only implementation files. Policy compliance fails due a range-based whitespace check finding, but acceptance criteria are behaviorally supported by evidence.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md` - only source for `full-bug`

### Acceptance criteria

1. AC-1: Running `drm-copilot: New Codex Worktree Session` for Issue #281 no longer emits generated PowerShell containing `; elseif` or a prompt-start `elseif` statement.
2. AC-2: The Codex trust setup command runs after `Set-Location` without the `elseif: The term 'elseif' is not recognized as a name of a cmdlet...` error.
3. AC-3: The generated command invokes the configured `postCodexScriptPath` after `Set-Location` and Codex trust setup, and before Codex launch.
4. AC-4: The VS Code extension remains generic: repository-specific `.codex` and `.agents` copy behavior is implemented only through the configured post-Codex script mechanism.
5. AC-5: Codex executable resolution occurs before launch, uses an explicitly configured executable when provided, falls back to PATH/PATHEXT lookup for `codex` when unset, and does not emit a bare unresolved `codex` launch command.
6. AC-6: Missing Codex executable resolution fails before terminal creation with a clear configuration-oriented error instead of a later shell `codex: The term 'codex' is not recognized...` failure.
7. AC-7: The post-worktree script uses strict mode and stop-on-error semantics, resolves the source root robustly through git common-dir or main-worktree information when possible, and has deterministic fallback behavior.
8. AC-8: The post-worktree script copies source repository `.codex` and `.agents` content into the destination worktree before Codex starts, is rerunnable, handles existing destination folders deterministically, and skips transient or machine-local files.
9. AC-9: Post-worktree script logging is concise and includes source root, destination root, copied entries, and skipped entries.
10. AC-10: Regression tests cover trust command serialization, Codex executable resolution, missing-Codex preflight behavior, post-Codex invocation timing, source-root resolution, rerun behavior, destination-existing behavior, transient-file skips, and `.codex` / `.agents` copy behavior.
11. AC-11: Manual Windows PowerShell validation for Issue #281 confirms `.codex` and `.agents` are present in the new worktree before Codex starts and confirms neither observed error appears.
12. AC-12: Applicable TypeScript and PowerShell toolchain commands pass in repository-required order: format, lint/analyze, type-check where applicable, then test.
13. AC-13: Documentation and configuration descriptions match the Issue #281 behavior, including `postCodexScriptPath` as the repository-specific setup hook and resolved Codex executable launch behavior.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 | PASS | `trust-command-pass-after.2026-07-03T09-14.md`; `codex-worktree-session.test.ts` | `Push-Location extensions/drm-copilot; npm run test -- --runTestsByPath test/codex-worktree-session.test.ts; Pop-Location` | Evidence verifies no `; elseif` and no prompt-start `elseif`. |
| 2 | AC-2 | PASS | `windows-powershell-validation.2026-07-03T09-14.md`; trust command tests | Same as AC-1 plus Windows validation artifact | No observed `elseif` error in validation evidence. |
| 3 | AC-3 | PASS | `command-handler-pass-after.2026-07-03T09-14.md`; `codex-worktree-session-command.test.ts` | `Push-Location extensions/drm-copilot; npm run test -- --runTestsByPath test/codex-worktree-session-command.test.ts; Pop-Location` | Tests assert post-Codex command after `Set-Location` and trust, before Codex launch. |
| 4 | AC-4 | PASS | Diff inspection of `codex-worktree-session.ts` and post-Codex script | `git diff --unified=80 476b110...HEAD -- <changed files>` | Repository-specific copy logic is in the post-Codex resource script. |
| 5 | AC-5 | PASS | `codex-resolution-pass-after.2026-07-03T09-14.md`; command-handler tests | `Push-Location extensions/drm-copilot; npm run test -- --runTestsByPath test/extension.test.ts; Pop-Location` | Tests assert resolved executable launch and no bare `codex` command. |
| 6 | AC-6 | PASS | `codex-resolution-pass-after.2026-07-03T09-14.md` | Same as AC-5 | Missing-Codex preflight behavior is covered by the existing test evidence. |
| 7 | AC-7 | PASS | `post-script-pass-after.2026-07-03T09-14.md`; PowerShell diff inspection | `mcp__drm-copilot__run_poshqc_test` | Script uses strict mode and tested source-root resolution paths. |
| 8 | AC-8 | PASS | `post-script-pass-after.2026-07-03T09-14.md`; Pester tests | `mcp__drm-copilot__run_poshqc_test` | Tests cover `.codex`/`.agents` copy, rerun behavior, existing destinations, and transient skips. |
| 9 | AC-9 | PASS | `post-script-pass-after.2026-07-03T09-14.md`; logging tests | `mcp__drm-copilot__run_poshqc_test` | Summary logging includes source, destination, copied count, and skipped count. |
| 10 | AC-10 | PASS | TypeScript and PowerShell regression evidence under `evidence/regression-testing/` | Jest run-by-path commands and `mcp__drm-copilot__run_poshqc_test` | Coverage exists for the specified regression areas. |
| 11 | AC-11 | PASS | `windows-powershell-validation.2026-07-03T09-14.md` | Agent-driven Windows PowerShell validation command recorded in artifact | Evidence records that neither observed error appears. |
| 12 | AC-12 | PASS | Final TypeScript and PowerShell QA artifacts under `evidence/qa-gates/` | Format, lint/analyze, typecheck, coverage test commands | Language toolchains passed. Policy audit separately flags full branch whitespace evidence failure. |
| 13 | AC-13 | PASS | `spec.md`, `review-readiness.2026-07-03T09-14.md`, `codex-worktree-session.ts` comment | Diff inspection and feature evidence | Documentation and comments match the post-Codex hook behavior, apart from the whitespace issue recorded in policy audit. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 13 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Policy audit failure: `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD` reports trailing whitespace in `spec.md`.
2. The committed final QA evidence used a working-tree whitespace command rather than the required full branch range command.

**Recommended follow-up verification steps:**

1. Remove the trailing whitespace in `spec.md` line 85.
2. Rerun and record `git diff --check 476b110cc53c7f26a573c9cf23b4f3dba1b095a9...HEAD` in canonical QA evidence.
3. Rerun feature review after remediation.

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, all 13 acceptance criteria in `spec.md` were already checked off before this review. This review did not change the source file because all criteria were already checked.

### AC Status Summary

- Source: `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md`
- Total AC items: 13
- Checked off (delivered): 13
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-03-codex-worktree-session-regression-281/spec.md` | 13 | 13 | 0 | Checkbox-backed and authoritative for `full-bug`. |

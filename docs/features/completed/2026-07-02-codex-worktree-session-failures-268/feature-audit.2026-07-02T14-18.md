# Feature Audit: codex-worktree-session-failures (#268)

**Audit Date:** 2026-07-02
**Feature Folder:** `docs/features/active/2026-07-02-codex-worktree-session-failures-268`
**Base Branch:** `main` / `origin/main`
**Head Branch:** `bug/codex-worktree-session-failures-268`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Base branch:** `main`, resolved in PR context as `origin/main` at `51867789325248793a241886033c3ce86681f9ad`
- **Head branch/commit:** `bug/codex-worktree-session-failures-268` at `8126e749e5270c5bca37e1bf03581e04f631ff81`
- **Merge base:** `51867789325248793a241886033c3ce86681f9ad`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-02-codex-worktree-session-failures-268/evidence/**`
  - Additional reviewer evidence: direct execution of `.codex/scripts/post-codex-worktree-session.ps1` for same-root and missing-source no-op cases
- **Feature folder used:** `docs/features/active/2026-07-02-codex-worktree-session-failures-268`
- **Requirements source:** `docs/features/active/2026-07-02-codex-worktree-session-failures-268/spec.md`
- **Work mode resolution note:** `issue.md` contains `- Work Mode: full-bug`; per workflow rules, `spec.md` is the authoritative acceptance-criteria source.
- **Scope note:** Review scope is the full branch diff against the resolved base branch. No scope narrowing was accepted.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-02-codex-worktree-session-failures-268/spec.md` - only authoritative AC source for `full-bug`

### Acceptance criteria

1. Running `drm-copilot: New Codex Worktree Session` for issue #268 no longer emits generated PowerShell containing `; elseif`.
2. The Codex trust setup command runs without the `elseif: The term 'elseif' is not recognized as a name of a cmdlet...` parse error.
3. When `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath` is set, the Codex start command uses the resolved configured executable path with correct PowerShell quoting.
4. When `codexExecutablePath` is blank, the command resolves `codex` through PATH/PATHEXT before terminal creation.
5. When no configured executable or PATH fallback resolves, the command fails before terminal creation with the clear missing-Codex preflight error.
6. The configured post-Codex script path is resolved from the source repository root, not the new worktree root.
7. `.codex/scripts/post-codex-worktree-session.ps1` accepts source/worktree root inputs and is safe to run during the first worktree session.
8. A new Codex worktree receives `.codex` and `.agents` from the source repository before Codex starts.
9. Repository-specific `.codex` and `.agents` copy behavior is implemented only through the configured post-Codex script mechanism; the extension remains generic.
10. Regression tests cover trust command formatting, Codex CLI resolution, missing Codex preflight behavior, post-Codex source-root invocation, first-run script behavior, and `.codex`/`.agents` copy behavior.
11. No unrelated files, implementation surfaces, tests, or planning artifacts are changed outside the issue #268 scope.
12. Applicable TypeScript and PowerShell toolchain commands pass in required order: format, lint/analyze, type-check where applicable, then tests.
13. Extension configuration documentation in `package.json` matches the new `codexExecutablePath` setting and post-Codex source-root resolution behavior.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | No generated `; elseif` | PASS | `pass-after-codex-worktree-builder.2026-07-02T13-13.md`; diff in `codex-worktree-session.ts` | `Push-Location extensions/drm-copilot; npm run test:unit -- codex-worktree-session.test.ts --runInBand; Pop-Location` | Builder test asserts absence of `; elseif`. |
| 2 | Trust setup avoids `elseif` parse error | PASS | Same builder evidence | Same command as AC1 | The generated branch is one PowerShell statement. |
| 3 | Configured Codex executable path is used with quoting | PASS | `pass-after-codex-command-handler.2026-07-02T13-13.md`; `codex-worktree-session-command.test.ts` | `Push-Location extensions/drm-copilot; npm run test:unit -- codex-worktree-session-command.test.ts --runInBand; Pop-Location` | Test verifies `& 'C:/Tools/Codex/codex.exe'`. |
| 4 | Blank `codexExecutablePath` resolves `codex` through PATH/PATHEXT | PASS | `extension.test.ts`; final Jest coverage | `Push-Location extensions/drm-copilot; npm run test:unit -- --coverage; Pop-Location` | Runtime helper test covers undefined and blank config fallback. |
| 5 | Missing Codex fails before terminal creation | PASS | `pass-after-codex-command-handler.2026-07-02T13-13.md` | `Push-Location extensions/drm-copilot; npm run test:unit -- codex-worktree-session-command.test.ts --runInBand; Pop-Location` | Test asserts no terminal is created. |
| 6 | Post-Codex script path resolves from source root | PASS | `pass-after-codex-command-handler.2026-07-02T13-13.md`; `extension.ts` diff | Same command as AC3 | Test verifies source-root path and both root arguments. |
| 7 | Post-Codex script accepts roots and is first-run safe | FAIL | Direct reviewer verification failed for same-root and missing-source no-op execution | `& .\.codex\scripts\post-codex-worktree-session.ps1 -SourceRoot (Get-Location).Path -WorktreeRoot (Get-Location).Path`; second command with source and destination folders lacking `.codex`/`.agents` | Both commands failed with `Cannot bind argument to parameter 'CopyOperation' because it is an empty array.` |
| 8 | New worktree receives `.codex` and `.agents` before Codex starts | PASS | Copy planning tests and source-root command-handler evidence | Pester and Jest commands above | Normal copy planning is covered; the AC is not the empty-plan no-op case. |
| 9 | Repository-specific copy behavior remains in script mechanism | PASS | Diff shows extension invokes configured script and script implements copy behavior | Diff inspection | No hardcoded `.codex`/`.agents` copy behavior was added to extension TypeScript. |
| 10 | Regression tests cover required areas | PARTIAL | Jest and Pester evidence; direct no-op gap | Jest/Pester commands above | Tests cover most required areas but miss full-script no-op execution. |
| 11 | No unrelated files changed | PASS | `final-scope-diff.2026-07-02T13-13.md` | `git diff --name-only`; `git ls-files --others --exclude-standard`; `git status --ignored --short -- .codex/scripts/post-codex-worktree-session.ps1` | Scope evidence records PASS. |
| 12 | Toolchain commands pass in required order | PASS | `final-qa-sequence-verification.2026-07-02T13-13.md` | Recorded final TypeScript and PowerShell QA commands | Recorded evidence shows required order and recency. |
| 13 | `package.json` config docs match behavior | PASS | `package.json` diff; command-handler evidence | Diff inspection; Jest command-handler tests | Config key and source-root description are present. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 11 criteria
- **PARTIAL:** 1 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criteria

**Top gaps preventing PASS:**

1. `.codex/scripts/post-codex-worktree-session.ps1` fails for same-root and missing-source no-op cases because an empty operation array is passed to a mandatory parameter.
2. Pester coverage does not execute the full script body for the no-op paths.
3. The policy audit separately records a non-canonical research artifact path reported by the evidence-location validator.

**Recommended follow-up verification steps:**

1. Fix the empty copy-operation handling in both root and bundled post-Codex scripts, then recheck parity.
2. Add Pester coverage for full-script no-op execution and rerun PoshQC format, analyze, and test.
3. Correct the research artifact location and rerun `python scripts\dev_tools\validate_evidence_locations.py --root .`.

## Acceptance Criteria Check-off

The authoritative `spec.md` already has all 13 criteria checked before this review. The reviewer did not modify the source file. AC #7 remains checked in the source but is evaluated as FAIL in this audit based on direct verification; AC #10 is evaluated as PARTIAL due to the missing full-script no-op test.

### AC Status Summary

- Source: `docs/features/active/2026-07-02-codex-worktree-session-failures-268/spec.md`
- Total AC items: 13
- Checked off (delivered in source): 13
- Remaining (unchecked in source): 0
- Items remaining: None unchecked in source; one checked item requires remediation based on this audit.

| Source File | Total AC | Checked (PASS in source) | Unchecked | Notes |
|-------------|----------|--------------------------|-----------|-------|
| `docs/features/active/2026-07-02-codex-worktree-session-failures-268/spec.md` | 13 | 13 | 0 | Checkbox-backed; audit verdict overrides source checkbox state for AC #7 and AC #10 until remediation. |

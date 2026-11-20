# Feature Audit: nested-worktree-folder-scheme (#328)

---

**Audit Date:** 2026-07-07
**Feature Folder:** `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-07-07-11-50`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `3eda262ffbc3ab82e6eefed3e9a72ab4133b893c`)
- **Head branch/commit:** `drm-copilot-wt-2026-07-07-11-50` (commit `f4bbfdf7c804f094ed11e42b56aed73444629f7d`; working tree clean)
- **Merge base:** `3eda262ffbc3ab82e6eefed3e9a72ab4133b893c`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and direct `git diff 3eda262..f4bbfdf`
  - Feature evidence: `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/**`
  - Additional evidence: check-only re-execution by this review (Prettier/ESLint/tsc/Jest/PSScriptAnalyzer/Pester), `extensions/drm-copilot/coverage/lcov.info` re-parse, `artifacts/pester/powershell-coverage.xml` + `pester-junit.xml` re-parse, `git diff --no-index` template-parity check
- **Feature folder used:** `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/`
- **Requirements source:** `spec.md` and `user-story.md` (multiple files)
- **Work mode resolution note:** Explicit marker in `issue.md` line 11: `- Work Mode: full-feature`, resolving AC sources to `spec.md` + `user-story.md` per `acceptance-criteria-tracking`.
- **Scope note:** Scope is the full branch diff against the resolved base. The nine AC items are textually identical in `spec.md` (`## Acceptance Criteria`) and `user-story.md` (`## Acceptance Criteria`); they are inventoried once and evaluated once, with check-off status tracked per file. PR-context artifacts were supplied refreshed by the caller and match the current head SHA (verified against `git rev-parse HEAD`), so no regeneration was needed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/spec.md` — primary source
- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/user-story.md` — co-authoritative source (identical AC text)

### Acceptance criteria

1. New worktrees are created at `<parent>/<repoName>-wt/<yyyy-MM-ddTHH-mm>`.
2. The `<repoName>-wt` grouping directory is created when missing, before `git worktree add` runs, and creation is idempotent when the directory already exists.
3. The timestamp format is `yyyy-MM-ddTHH-mm` (literal `T`, 24-hour `HH`) in both the PowerShell `Get-WorktreeTimestamp` and the TypeScript `formatWorktreeTimestamp`, and unit tests verify the two formatters are consistent for an equivalent fixed date-time fixture.
4. The branch name remains flat `<repoName>-wt-<yyyy-MM-ddTHH-mm>` (no slash-nested branch names are produced).
5. `drm-copilot: Remove Secondary Worktrees` still discovers and removes worktrees created under the nested scheme.
6. After secondary-worktree removal, an emptied `<repoName>-wt` grouping directory is removed and the removal is reported in the operation summary; a non-empty grouping directory is never removed; the primary worktree is never removed.
7. The `workspace-encoding.ts` matcher continues to resolve transcript directories for the new scheme with no change to matching logic, covered by additive test cases (old-scheme tests retained).
8. The PowerShell script and the bundled template (`extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`) produce the new scheme identically (lockstep parity maintained).
9. All existing tests affected by the scheme change are updated, and new behavior (parent-directory creation, `ensureParentDirectory` command, empty-parent cleanup, new-scheme encoding matches) has unit coverage meeting repository thresholds (line >= 85%, branch >= 75%).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Nested worktree path `<parent>/<repoName>-wt/<ts>` | PASS | PS `Build-WorktreePath` composes `Get-WorktreeGroupDirectory` (diff, script lines 76-77); TS `buildWorktreePath` composes `buildWorktreeGroupDirectory`. Tests assert exact `/parent/auth-wt/2026-04-20T09-59` on both sides, incl. backslash-parent and trailing-slash normalization. | `pwsh Invoke-Pester` (changed suite, 31 pass); `npm test` (1555 pass) | Applies identically to Claude and Codex paths (shared builder inputs). |
| 2 | Grouping directory created when missing, before `git worktree add`, idempotent | PASS | PS: `New-WorktreeParentDirectory` (`New-Item -Force` seam) invoked between preconditions and `Invoke-GitWorktreeAdd` (diff, script lines 255-258); ordering asserted by test; idempotence via `-Force` + double-invocation test; `-WhatIf` gate tested. TS: `ensureParentDirectory` (`New-Item -ItemType Directory -Force ... | Out-Null`) sent via its own `terminal.sendText` before `commands.git` in both handlers (`extension.ts` diff), asserted in `extension.workflow-commands.test.ts` ("ensureParentDirectory send must precede the git send"). | `npm test`; `pwsh Invoke-Pester` | Guard derived from the worktree path via shared helpers — no drift possible. |
| 3 | `yyyy-MM-ddTHH-mm` in both formatters + cross-toolchain fixture test | PASS | PS `'yyyy-MM-ddTHH-mm'` format string; TS emits `...${day}T${hour}-${minute}`. Shared fixture local 2026-04-20 09:59 → `2026-04-20T09-59` asserted in both suites, each cross-referencing the other. | Both test suites (green) | 16-character output preserved. |
| 4 | Branch remains flat, no slash | PASS | `Build-BranchName`/`buildBranchName` structurally unchanged (`<repoName>-wt-<ts>`); explicit no-`/` assertion in Pester (`Should -Not -Match "/"`). | `pwsh Invoke-Pester` | Refname-collision rationale documented in spec Section 4. |
| 5 | Remove Secondary Worktrees discovers/removes nested worktrees | PASS | Discovery unchanged (porcelain-based `parseWorktreePorcelain` + positional selection — verified no diff to discovery logic); nested-scheme porcelain fixtures added in `remove-worktrees-runner.test.ts` (+185 lines). | `npm test` | Path-agnostic by construction; additive tests confirm. |
| 6 | Empty grouping dir removed + reported; non-empty never removed; primary never removed | PASS | Pure `classifyParentDirectoryForCleanup` enforces `-wt` basename, emptiness, and primary/primary-parent protection; `removedEmptyParents` surfaced in `WorktreeSummary` and appended to `buildRemovalSummaryMessage`; `fs.rmdirSync` defense in depth. Individual tests for each invariant, incl. the empty `-wt` primary-parent edge case (`remove-worktrees.test.ts` lines 425-476). | `npm test` | Cleanup is best-effort with logged skips; non-`-wt` custom parents also protected. |
| 7 | workspace-encoding resolves new scheme, no logic change, additive tests | PASS | Production diff to `workspace-encoding.ts` is doc comments only (+9 lines, verified in diff hunk); `workspace-encoding.test.ts` +72 additive lines (sibling new-scheme, worktree-of-a-worktree, leaf-workspace); old-scheme tests retained. | `git diff 3eda262..f4bbfdf -- extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts`; `npm test` | `/` encodes to `-`, so the `-wt-` infix prefix match still resolves. |
| 8 | Script and bundled template identical (lockstep parity) | PASS | Byte-identical: `git diff --no-index` exit 0 (re-run by this review); Pester parity test asserts raw content equality; executor evidence `evidence/other/2026-07-07T12-48-template-parity.md`. | `git diff --no-index scripts/dev-tools/new-claude-worktree-session.ps1 extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` | Both files 273 lines. |
| 9 | Affected tests updated; new behavior covered at line >= 85% / branch >= 75% | PARTIAL | Tests updated across 8 test files; all suites green. TypeScript thresholds verified per changed file from `lcov.info`: 96.0–100% lines, 84.8–100% branches (all above 85/75). PowerShell portion NOT numerically verifiable: changed script outside the committed coverage denominator (`CodeCoverage.Path` allow-list) and targeted measurement structurally invalid (attribution artifact, 4.88% reported vs 31 direct tests); PS branch coverage not emitted at all. | `awk`-parse of `extensions/drm-copilot/coverage/lcov.info`; targeted `Invoke-Pester` coverage probe (`evidence/qa-gates/2026-07-07T13-16-review-targeted-ps-coverage.md`) | Fail-closed: the numeric threshold clause of this criterion cannot be confirmed for the PowerShell new behavior. Remediation defined in `remediation-inputs.2026-07-07T13-16.md`. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 1 criterion (AC9)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC9's numeric-coverage clause is unverifiable for the PowerShell new behavior: the changed script is excluded from the committed coverage denominator and no structurally valid targeted measurement is obtainable with the current AST test-import pattern; PowerShell branch coverage is not emitted by the repo Pester configuration. (Behavioral coverage — 31 direct tests over all nine functions — is present; the gap is measurement, not tests.)

**Recommended follow-up verification steps:**

1. Execute the remediation defined in `remediation-inputs.2026-07-07T13-16.md` (make the changed PowerShell file's coverage measurable and record a valid >= 85% line figure; emit or formally except branch coverage), then re-audit.
2. On re-audit, re-run the per-file lcov parse and the PowerShell coverage parse to confirm both languages meet the numeric thresholds for changed files.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

All nine AC checkboxes in both `spec.md` and `user-story.md` were already marked `[x]` by the executor before this review ran, so no new check-offs were performed by this audit. **Discrepancy note:** AC9 is evaluated **PARTIAL** by this audit but is pre-checked `[x]` in both source files. The check-off protocol authorizes reviewers to check off PASS items; it does not authorize rewriting executor check-offs, so the source files were left unmodified and this audit is the authoritative record of the discrepancy. The remediation cycle should re-verify AC9 and correct the source-file state if its own protocol permits.

### AC Status Summary

- Source: `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/spec.md`, `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/user-story.md`
- Total AC items: 9 (identical set in each file)
- Checked off (delivered): 9 pre-checked in each file; 8 confirmed PASS by this audit
- Remaining (unchecked): 0 in the source files; 1 item (AC9) does not meet PASS per this audit despite being pre-checked
- Items remaining: AC9 — "All existing tests affected by the scheme change are updated, and new behavior ... has unit coverage meeting repository thresholds (line >= 85%, branch >= 75%)." (PARTIAL; see discrepancy note)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 9 | 9 pre-checked (8 audit-confirmed PASS) | 0 | Checkbox-backed; AC9 pre-checked but evaluated PARTIAL |
| `user-story.md` | 9 | 9 pre-checked (8 audit-confirmed PASS) | 0 | Checkbox-backed; AC9 pre-checked but evaluated PARTIAL |

No source-file checkbox change was made by this audit: every PASS item was already checked, and unchecking an executor-checked PARTIAL item is outside the reviewer check-off protocol; the discrepancy is recorded here and in the remediation inputs instead.

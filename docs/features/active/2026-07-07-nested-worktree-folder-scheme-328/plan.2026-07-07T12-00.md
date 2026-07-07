# nested-worktree-folder-scheme — Plan

- **Issue:** #328
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-07T12-00
- **Status:** Pending Preflight
- **Version:** 1.0
- **Work Mode:** full-feature
- **Spec:** [spec.md](spec.md)
- **User Story:** [user-story.md](user-story.md)
- **Research:** [research/2026-07-07T12-30-nested-worktree-folder-scheme-328-research.md](research/2026-07-07T12-30-nested-worktree-folder-scheme-328-research.md)

## Required References

- `.claude/rules/general-code-change.md` (cross-language code change policy)
- `.claude/rules/general-unit-test.md` (cross-language unit test policy)
- `.claude/rules/powershell.md` (PoshQC loop, seams, mocking, change budget)
- `.claude/rules/typescript.md` (Prettier/ESLint/tsc/test loop, pure-module rules)
- `.claude/rules/typescript-suppressions.md` (suppression authorization)
- `.claude/rules/quality-tiers.md` (uniform coverage thresholds)

All work must comply with these policies; this plan does not duplicate their content.

## Conventions Used in This Plan

- `<FEATURE>` = `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328`
- `<TS>` = execution-time timestamp in `yyyy-MM-ddTHH-mm` format.
- All evidence artifacts are written under `<FEATURE>/evidence/<kind>/` (canonical scheme; non-overridable). Each command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- PowerShell toolchain loop = `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`. TypeScript toolchain loop = `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test` (all with cwd `extensions/drm-copilot`). **Restart rule:** if any stage fails or changes files, restart that language's loop from its first stage; a phase's loop task is complete only when all stages pass in one uninterrupted pass.
- PowerShell per-batch cap: at most 3 production + 3 test files per batch. Phase 1 touches exactly 2 production PowerShell files (script + template) and 1 test file, within the cap; no split required.
- Fixed date-time fixture shared across both toolchains for timestamp parity: local time `2026-04-20 09:59` → expected string `2026-04-20T09-59`.

## Acceptance-Criteria Mapping

Acceptance criteria are quoted from `spec.md` / `user-story.md` (identical lists, 9 items).

| # | Acceptance criterion (abbreviated) | Satisfied by |
|---|---|---|
| AC1 | New worktrees created at `<parent>/<repoName>-wt/<yyyy-MM-ddTHH-mm>` | P1-T2, P1-T6, P2-T2; verified by P1-T8, P2-T6 |
| AC2 | `<repoName>-wt` grouping directory created when missing, before `git worktree add`, idempotently | P1-T3, P1-T4, P2-T3, P2-T4, P3-T1, P3-T2; verified by P1-T11, P1-T12, P2-T8, P2-T10, P3-T3, P3-T5 |
| AC3 | Timestamp `yyyy-MM-ddTHH-mm` in both formatters, cross-toolchain consistency tested with a fixed fixture | P1-T1, P2-T1; verified by P1-T7, P2-T5, P2-T9 |
| AC4 | Branch name remains flat `<repoName>-wt-<timestamp>` (no slash) | No builder-structure change (decision preserved); verified by P1-T9, P2-T7, P3-T4, P3-T5 |
| AC5 | Remove Secondary Worktrees still discovers/removes nested-scheme worktrees | No discovery-logic change; verified by P4-T7 (nested porcelain fixtures) |
| AC6 | Emptied `<repoName>-wt` parent removed and reported; non-empty never removed; primary never removed | P4-T1..P4-T5; verified by P4-T6, P4-T7 |
| AC7 | `workspace-encoding.ts` matcher resolves new scheme with no logic change; additive tests; old-scheme tests retained | P5-T1; verified by P5-T2 |
| AC8 | Script and bundled template produce the scheme identically (lockstep parity) | P1-T6; verified by P1-T14, P6-T9 |
| AC9 | All affected tests updated; new behavior covered; line >= 85% / branch >= 75% | All test tasks (P1-T7..T14, P2-T5..T10, P3-T3..T5, P4-T6..T7, P5-T2); verified by P6-T3, P6-T7, P6-T8 |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read repository policies in the `policy-compliance-order` sequence: `CLAUDE.md`-loaded rules, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`; write `<FEATURE>/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read.
  - Acceptance: artifact exists at the stated path with all three fields populated.
- [x] [P0-T2] Capture PowerShell analyzer baseline by running `mcp__drm-copilot__run_poshqc_analyze`; write `<FEATURE>/evidence/baseline/<TS>-baseline-poshqc-analyze.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (diagnostic count / pass state).
  - Acceptance: artifact exists with all four fields; EXIT_CODE recorded verbatim.
- [x] [P0-T3] Capture PowerShell test-and-coverage baseline by running `mcp__drm-copilot__run_poshqc_test` (repo Pester config with coverage enabled); write `<FEATURE>/evidence/baseline/<TS>-baseline-poshqc-test.md` with the four fields and numeric baseline line and branch coverage percentages in `Output Summary:`.
  - Acceptance: artifact contains numeric coverage values (no placeholders) plus pass/fail counts.
- [x] [P0-T4] Capture TypeScript lint baseline by running `npm run lint` in `extensions/drm-copilot`; write `<FEATURE>/evidence/baseline/<TS>-baseline-ts-lint.md` with the four fields.
  - Acceptance: artifact exists with all four fields; EXIT_CODE recorded verbatim.
- [x] [P0-T5] Capture TypeScript type-check baseline by running `npm run typecheck` in `extensions/drm-copilot`; write `<FEATURE>/evidence/baseline/<TS>-baseline-ts-typecheck.md` with the four fields.
  - Acceptance: artifact exists with all four fields; EXIT_CODE recorded verbatim.
- [x] [P0-T6] Capture TypeScript test-and-coverage baseline by running `npm run test:coverage` in `extensions/drm-copilot`; write `<FEATURE>/evidence/baseline/<TS>-baseline-ts-test-coverage.md` with the four fields and numeric baseline line and branch coverage percentages in `Output Summary:`.
  - Acceptance: artifact contains numeric coverage values (no placeholders) plus pass/fail counts.

### Phase 1 — PowerShell Script, Template, and Pester Tests

Batch scope: 2 production files (`scripts/dev-tools/new-claude-worktree-session.ps1`, `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`) + 1 test file (`tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`); within the 3+3 per-batch cap.

- [x] [P1-T1] Update `Get-WorktreeTimestamp` in `scripts/dev-tools/new-claude-worktree-session.ps1` (line ~40) to use format string `'yyyy-MM-ddTHH-mm'`.
  - Acceptance: injected fixed datetime `2026-04-20 09:59` yields `2026-04-20T09-59`.
- [x] [P1-T2] Add a grouping-directory helper function `Get-WorktreeGroupDirectory` (returns `"<WorktreeParentPath>/<RepoName>-wt"`) to `scripts/dev-tools/new-claude-worktree-session.ps1` and rewrite `Build-WorktreePath` (line ~57) to return `"<group>/<Timestamp>"` via that helper.
  - Acceptance: `Build-WorktreePath -WorktreeParentPath '/parent' -RepoName 'auth' -Timestamp '2026-04-20T09-59'` returns `/parent/auth-wt/2026-04-20T09-59`; `Build-BranchName` is untouched.
- [x] [P1-T3] Add advanced function `New-WorktreeParentDirectory` to `scripts/dev-tools/new-claude-worktree-session.ps1` with `[CmdletBinding(SupportsShouldProcess = $true)]` and an injectable `[scriptblock] $NewDirectory` seam defaulting to `{ param([string] $Path) New-Item -ItemType Directory -Force -Path $Path | Out-Null }`; the function creates the grouping directory idempotently (`-Force` no-ops on an existing directory).
  - Acceptance: function exists, guards state change with `ShouldProcess`, and invokes only the seam (no direct filesystem call outside the default scriptblock).
- [x] [P1-T4] Invoke `New-WorktreeParentDirectory` in the script body of `scripts/dev-tools/new-claude-worktree-session.ps1` between the `Test-PreconditionsMet` check and `Invoke-GitWorktreeAdd`, passing the grouping directory from `Get-WorktreeGroupDirectory`.
  - Acceptance: invocation appears textually and control-flow-wise before `Invoke-GitWorktreeAdd`; script remains under 500 lines.
- [x] [P1-T5] Update comment-based help in `scripts/dev-tools/new-claude-worktree-session.ps1`: the `.PARAMETER BranchName` default note and the header comment (line ~19) to document the nested path scheme and `yyyy-MM-ddTHH-mm` timestamp, with the branch name remaining flat.
  - Acceptance: no remaining `yyyy-MM-dd-HH-mm` references in the script's help text.
- [x] [P1-T6] Apply the identical Phase 1 edits (P1-T1 through P1-T5) to `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` in lockstep.
  - Acceptance: `git diff --no-index scripts/dev-tools/new-claude-worktree-session.ps1 extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` reports no differences.
- [x] [P1-T7] Update the Pester timestamp test in `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` (lines ~20-24): rename the `It` to reference `yyyy-MM-ddTHH-mm` and expect `2026-04-20T09-59` for the shared fixed fixture.
  - Acceptance: test asserts the exact string `2026-04-20T09-59`.
- [x] [P1-T8] Update the Pester path-builder tests in `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` (lines ~34-47): segment assertion becomes `auth-wt/`, ending assertion becomes `/2026-04-20T09-59$`, full-path assertion becomes `/parent/auth-wt/2026-04-20T09-59`.
  - Acceptance: all three assertions target the nested scheme and pass.
- [x] [P1-T9] Update the Pester branch-default test in `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` (lines ~57-60) to expect flat `auth-wt-2026-04-20T09-59`, and add an assertion that the returned branch name contains no `/`.
  - Acceptance: flat-branch expectation and no-slash assertion both present and passing.
- [x] [P1-T10] Add Pester tests for `Get-WorktreeGroupDirectory` in `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`: returns `<parent>/<repoName>-wt`, and `Build-WorktreePath` output starts with the helper's output for the same inputs (no-drift check).
  - Acceptance: both tests present and passing.
- [x] [P1-T11] Add Pester tests for `New-WorktreeParentDirectory` in `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`: (a) the injected seam receives the grouping-directory path; (b) invoking twice with the same path succeeds without error (idempotence via seam); (c) `-WhatIf` does not invoke the seam. No temporary files; the seam scriptblock captures arguments instead of touching disk.
  - Acceptance: all three behaviors covered with seam-only mocking.
- [x] [P1-T12] Add a Pester ordering test in `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` asserting the script body invokes `New-WorktreeParentDirectory` before `Invoke-GitWorktreeAdd` (script-content or mocked-invocation-order assertion).
  - Acceptance: test fails if the invocation order is reversed or the guard is removed.
- [x] [P1-T13] Update the function-definition integration test in `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` (lines ~268-278) from seven to nine expected functions, adding `Get-WorktreeGroupDirectory` and `New-WorktreeParentDirectory` to the expected list.
  - Acceptance: expected-function list names all nine functions and passes.
- [x] [P1-T14] Add a Pester parity test in `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` asserting the raw content of `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` equals the raw content of `scripts/dev-tools/new-claude-worktree-session.ps1`.
  - Acceptance: parity test present and passing; a future divergence fails the suite.
- [x] [P1-T15] Run the PowerShell toolchain loop (`run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`) until all three stages pass in a single uninterrupted pass, restarting from format on any failure or file change; write `<FEATURE>/evidence/qa-gates/<TS>-phase1-poshqc-loop.md` with `Timestamp:`, `Command:` (all three), `EXIT_CODE:` (per stage), `Output Summary:`.
  - Acceptance: artifact records a clean single pass for all three stages.

### Phase 2 — TypeScript Command Builders and Unit Tests

Files: `extensions/drm-copilot/src/claude-worktree-session.ts`, `extensions/drm-copilot/src/codex-worktree-session.ts`, `extensions/drm-copilot/test/claude-worktree-session.test.ts`, `extensions/drm-copilot/test/codex-worktree-session.test.ts`.

- [x] [P2-T1] Update `formatWorktreeTimestamp` in `extensions/drm-copilot/src/claude-worktree-session.ts` (line ~70) to return `` `${year}-${month}-${day}T${hour}-${minute}` `` and update its doc comments (lines ~56, ~62) to the new format (the 16-character claim remains true).
  - Acceptance: fixed `Date` for local `2026-04-20 09:59` yields `2026-04-20T09-59`.
- [x] [P2-T2] Add an exported grouping-directory helper `buildWorktreeGroupDirectory(workspaceParent, repoName)` returning `` `${normalizedParent}/${repoName}-wt` `` in `extensions/drm-copilot/src/claude-worktree-session.ts`, rewrite `buildWorktreePath` (line ~93) to return `` `${group}/${timestamp}` `` via that helper, and update JSDoc (lines ~77, ~99).
  - Acceptance: `buildWorktreePath("/parent", "auth", "2026-04-20T09-59")` returns `/parent/auth-wt/2026-04-20T09-59`; `buildBranchName` remains flat and untouched.
- [x] [P2-T3] Add an `ensureParentDirectory` field to `WorktreeSessionCommands` and `buildWorktreeSessionCommands` in `extensions/drm-copilot/src/claude-worktree-session.ts`, emitting `New-Item -ItemType Directory -Force -Path <quoted group> | Out-Null` using `quoteForPwsh` and the shared `buildWorktreeGroupDirectory` helper; update the module JSDoc for the nested scheme.
  - Acceptance: field present and typed; module still imports no `vscode`, `node:fs`, or `node:child_process`.
- [x] [P2-T4] Add an `ensureParentDirectory` field to `CodexWorktreeSessionCommands` and `buildCodexWorktreeSessionCommands` in `extensions/drm-copilot/src/codex-worktree-session.ts`, deriving the grouping directory for the supplied pre-built `worktreePath` (via the shared helper or equivalent pure derivation) and quoting with `quoteForPwsh`.
  - Acceptance: field present and typed; module remains side-effect free; branch/path construction stays in `extension.ts`.
- [x] [P2-T5] Update `formatWorktreeTimestamp` expectations in `extensions/drm-copilot/test/claude-worktree-session.test.ts` (lines ~20, ~31) to `T`-separated values (`2026-04-20T09-59`, `2026-01-01T00-00`), rename affected test titles, and retain the `toHaveLength(16)` assertion (line ~32).
  - Acceptance: all formatter tests target the new format and pass.
- [x] [P2-T6] Update `buildWorktreePath` expectations in `extensions/drm-copilot/test/claude-worktree-session.test.ts` (lines ~47, ~58, ~69) to nested outputs (`/parent/auth-wt/2026-04-20T09-59`, `C:/repos/auth-wt/2026-04-20T09-59`), retaining the backslash-parent and trailing-slash normalization cases.
  - Acceptance: nested expectations pass including both normalization cases.
- [x] [P2-T7] Update `buildBranchName` and `buildWorktreeSessionCommands` fixtures in `extensions/drm-copilot/test/claude-worktree-session.test.ts` (branch expectation line ~77; `baseInput` lines ~120-121; `git`/`setLocation` expectations lines ~135, ~148) to the new timestamp and nested path, and add an assertion that the branch name contains no `/`.
  - Acceptance: flat-branch and nested-path expectations pass; no-slash assertion present.
- [x] [P2-T8] Add `ensureParentDirectory` tests in `extensions/drm-copilot/test/claude-worktree-session.test.ts`: exact command string with `quoteForPwsh` quoting, and a no-drift assertion that the guarded path is the leading segment of `buildWorktreePath` output for the same inputs.
  - Acceptance: both tests present and passing.
- [x] [P2-T9] Add a cross-toolchain timestamp-consistency test in `extensions/drm-copilot/test/claude-worktree-session.test.ts` asserting the fixed fixture (local `2026-04-20 09:59`) formats to `2026-04-20T09-59`, with a comment naming the matching Pester assertion (P1-T7) as the PowerShell counterpart.
  - Acceptance: test present; expected string is byte-identical to the Pester expectation.
- [x] [P2-T10] Update `extensions/drm-copilot/test/codex-worktree-session.test.ts` fixtures and expectations (lines ~46-47, ~58, ~61, ~122) to the nested scheme (`-WorktreeRoot 'C:/workspace-wt/...'`) and add `ensureParentDirectory` command-string coverage for the Codex builder.
  - Acceptance: nested fixtures pass; Codex `ensureParentDirectory` string and quoting asserted.
- [x] [P2-T11] Run the TypeScript toolchain loop (`npm run format` → `npm run lint` → `npm run typecheck` → `npm run test`, cwd `extensions/drm-copilot`) until all stages pass in a single uninterrupted pass, restarting from format on any failure or file change; write `<FEATURE>/evidence/qa-gates/<TS>-phase2-ts-loop.md` with `Timestamp:`, `Command:` (all stages), `EXIT_CODE:` (per stage), `Output Summary:`.
  - Acceptance: artifact records a clean single pass for all four stages.

### Phase 3 — Extension Wiring and Workflow Tests

Files: `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/test/extension.workflow-commands.test.ts`, `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`.

- [x] [P3-T1] Update the `newClaudeWorktreeSession` handler in `extensions/drm-copilot/src/extension.ts` (~line 207) to send `commands.ensureParentDirectory` via its own `terminal.sendText` immediately before the `commands.git` send, preserving all other command ordering.
  - Acceptance: exactly one added `sendText`; `ensureParentDirectory` precedes `git`; remaining order unchanged.
- [x] [P3-T2] Update the `newCodexWorktreeSession` handler in `extensions/drm-copilot/src/extension.ts` (~line 309) to send `commands.ensureParentDirectory` via its own `terminal.sendText` immediately before the `commands.git` send, preserving all other command ordering.
  - Acceptance: exactly one added `sendText`; `ensureParentDirectory` precedes `git`; remaining order unchanged.
- [x] [P3-T3] Update `extensions/drm-copilot/test/extension.workflow-commands.test.ts` for the added sendText: call-count assertion (line ~308) and call-index destructuring (lines ~309-314, ~330-331), plus every affected ordering test (`It`s at lines ~262, ~344, ~390, ~420, ~450, ~488, ~521, ~565, ~603); add an explicit assertion that the `ensureParentDirectory` send occurs before the `git` send.
  - Acceptance: all counts/indices consistent with the new command; ordering assertion present.
- [x] [P3-T4] Update path/branch regexes in `extensions/drm-copilot/test/extension.workflow-commands.test.ts`: line ~321 to `/-b 'workspace-wt-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}'$/`, line ~324 to match `Set-Location 'C:/workspace-wt/\d{4}-\d{2}-\d{2}T\d{2}-\d{2}'`, and confirm the terminal-name regex at line ~294 (`/^Claude: workspace-wt-/`) passes unchanged under the flat branch policy.
  - Acceptance: both regexes updated; line ~294 assertion unmodified and passing.
- [x] [P3-T5] Update `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`: change the `-WorktreeRoot 'C:/workspace-wt-` substrings at lines ~91, ~156, ~189, ~221 to `-WorktreeRoot 'C:/workspace-wt/`, adjust sendText count/index assertions for the added command, add an ordering assertion that `ensureParentDirectory` precedes `git`, and confirm the terminal-name regex at line ~60 (`/^Codex: workspace-wt-/`) passes unchanged.
  - Acceptance: all four substring updates applied; counts/indices/ordering consistent; line ~60 assertion unmodified and passing.
- [x] [P3-T6] Run the TypeScript toolchain loop to a clean single pass (restart rule applies); write `<FEATURE>/evidence/qa-gates/<TS>-phase3-ts-loop.md` with the four fields per stage.
  - Acceptance: artifact records a clean single pass for all four stages.

### Phase 4 — Remove-Worktrees Empty-Parent Cleanup

Files: `extensions/drm-copilot/src/remove-worktrees.ts`, `extensions/drm-copilot/src/remove-worktrees-runner.ts`, `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/test/remove-worktrees.test.ts`, `extensions/drm-copilot/test/remove-worktrees-runner.test.ts`.

- [x] [P4-T1] Add pure cleanup-decision logic to `extensions/drm-copilot/src/remove-worktrees.ts`: (a) a string-only parent-path derivation for a removed worktree path (handles `/` and `\` separators; no `node:path` import), and (b) a classifier (e.g. `classifyParentDirectoryForCleanup`) returning a discriminated union that marks a candidate parent eligible only when its basename ends with `-wt`, its supplied directory listing is empty, and it is neither the primary worktree path nor the primary worktree's parent.
  - Acceptance: both functions exported and pure; module keeps its no-I/O import contract.
- [x] [P4-T2] Extend `WorktreeSummary` in `extensions/drm-copilot/src/remove-worktrees.ts` with a `removedEmptyParents: ReadonlyArray<string>` field and update `buildRemovalSummaryMessage` to report removed grouping directories when the array is non-empty.
  - Acceptance: field typed readonly; message includes removed-parent reporting; existing message shapes preserved when the array is empty.
- [x] [P4-T3] Add an injectable filesystem seam to `extensions/drm-copilot/src/remove-worktrees-runner.ts` mirroring the `GitRunner` pattern: an interface (e.g. `ParentDirectoryFileSystem` with `directoryExists`, `listDirectoryEntries`, `removeEmptyDirectory`) plus a production factory backed by `node:fs`; the seam is a parameter of `removeAllSecondaryWorktrees`.
  - Acceptance: interface and factory exported; pure module `remove-worktrees.ts` gains no I/O.
- [x] [P4-T4] Implement empty-parent cleanup in `removeAllSecondaryWorktrees` in `extensions/drm-copilot/src/remove-worktrees-runner.ts`: after the removal loop, derive the unique parents of successfully removed paths (P4-T1 derivation), check existence and take a fresh listing via the seam immediately before removal, classify with the pure function (P4-T1), remove eligible parents via the seam, record them in `summary.removedEmptyParents`, and append per-parent output lines. Any remaining entry, non-`-wt` basename, or primary-parent match aborts cleanup for that parent without error; cleanup failures never fail the overall command.
  - Acceptance: cleanup runs only after all removals; non-empty and non-`-wt` parents are never removed; primary worktree and its parent are never targeted.
- [x] [P4-T5] Update the `removeSecondaryWorktrees` wiring in `extensions/drm-copilot/src/extension.ts` (lines ~340-377) to construct the production filesystem seam and pass it to `removeAllSecondaryWorktrees`, and update any test doubles or call-site fixtures broken by the new parameter so `npm run typecheck` passes across `src` and `test`.
  - Acceptance: production seam wired; `npm run typecheck` exits 0.
- [x] [P4-T6] Update and extend `extensions/drm-copilot/test/remove-worktrees.test.ts`: parent-path derivation cases (forward and backslash), classifier positive case (empty listing, `-wt` basename), classifier negatives (non-empty listing; non-`-wt` basename; parent equals primary path or primary's parent), and `buildRemovalSummaryMessage` cases with and without `removedEmptyParents` (existing fixtures updated for the new field).
  - Acceptance: all listed scenarios covered by passing tests.
- [x] [P4-T7] Update and extend `extensions/drm-copilot/test/remove-worktrees-runner.test.ts` with seam-injected tests and nested-scheme porcelain fixtures (`<parent>/<repo>-wt/<timestamp>` paths): (a) nested secondary worktrees are discovered and removed unchanged (AC5); (b) an emptied `-wt` parent is removed via the seam and reported in the summary; (c) a non-empty parent is preserved; (d) the seam is never invoked when no worktree was removed. No test touches the real filesystem.
  - Acceptance: all four scenarios covered; only fake seam implementations used.
- [x] [P4-T8] Run the TypeScript toolchain loop to a clean single pass (restart rule applies); write `<FEATURE>/evidence/qa-gates/<TS>-phase4-ts-loop.md` with the four fields per stage.
  - Acceptance: artifact records a clean single pass for all four stages.

### Phase 5 — Workspace-Encoding Doc Comments and Additive Tests

Files: `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts`, `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`.

- [x] [P5-T1] Update doc comments only in `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts` (lines ~38-43) to note that under the nested scheme the `/` between `<repoName>-wt` and the timestamp encodes to `-`, so encoded names still carry the `-wt-` infix and match without logic change.
  - Acceptance: diff contains comment lines only; `WORKTREE_INFIX`, `encodeWorkspacePath`, and `matchEncodedDirectories` logic are byte-identical.
- [x] [P5-T2] Add additive test cases to `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`: (a) new-scheme sibling encoded name (e.g. `C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-07T12-00`) matches; (b) new-scheme worktree-of-a-worktree encoded name matches; (c) exact-equality match when the workspace root is the nested leaf. Existing old-scheme tests (lines ~33-119) remain unmodified.
  - Acceptance: three new passing cases; zero changes to existing test cases.
- [x] [P5-T3] Run the TypeScript toolchain loop to a clean single pass (restart rule applies); write `<FEATURE>/evidence/qa-gates/<TS>-phase5-ts-loop.md` with the four fields per stage.
  - Acceptance: artifact records a clean single pass for all four stages.

### Phase 6 — Final QA Loop, Coverage Verification, and Acceptance Checkoff

Final-QA restart rule: if any stage below fails or changes files, restart that language's loop from its first stage and re-record the affected artifacts; completion requires one uninterrupted clean pass per language. No `SKIPPED` outcomes are authorized for any task in this phase.

- [x] [P6-T1] Run `mcp__drm-copilot__run_poshqc_format`; write `<FEATURE>/evidence/qa-gates/<TS>-final-poshqc-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact recorded; zero reformatted files in the final clean pass.
- [x] [P6-T2] Run `mcp__drm-copilot__run_poshqc_analyze`; write `<FEATURE>/evidence/qa-gates/<TS>-final-poshqc-analyze.md` with the four fields.
  - Acceptance: artifact recorded; zero diagnostics; EXIT_CODE 0.
- [x] [P6-T3] Run `mcp__drm-copilot__run_poshqc_test` in coverage mode; write `<FEATURE>/evidence/qa-gates/<TS>-final-poshqc-test.md` with the four fields and numeric post-change line and branch coverage in `Output Summary:`.
  - Acceptance: all Pester tests pass; numeric coverage recorded (no placeholders).
- [x] [P6-T4] Run `npm run format` in `extensions/drm-copilot`; write `<FEATURE>/evidence/qa-gates/<TS>-final-ts-format.md` with the four fields.
  - Acceptance: artifact recorded; zero reformatted files in the final clean pass.
- [x] [P6-T5] Run `npm run lint` in `extensions/drm-copilot`; write `<FEATURE>/evidence/qa-gates/<TS>-final-ts-lint.md` with the four fields.
  - Acceptance: artifact recorded; zero lint errors; EXIT_CODE 0.
- [x] [P6-T6] Run `npm run typecheck` in `extensions/drm-copilot`; write `<FEATURE>/evidence/qa-gates/<TS>-final-ts-typecheck.md` with the four fields.
  - Acceptance: artifact recorded; zero type errors; EXIT_CODE 0.
- [x] [P6-T7] Run `npm run test:coverage` in `extensions/drm-copilot`; write `<FEATURE>/evidence/qa-gates/<TS>-final-ts-test-coverage.md` with the four fields and numeric post-change line and branch coverage in `Output Summary:`.
  - Acceptance: all tests pass; numeric coverage recorded (no placeholders).
- [x] [P6-T8] Verify coverage thresholds and deltas: compare P0-T3 vs P6-T3 (PowerShell) and P0-T6 vs P6-T7 (TypeScript); write `<FEATURE>/evidence/qa-gates/<TS>-coverage-delta.md` recording baseline, post-change, and changed-line coverage numerically, and confirming line >= 85%, branch >= 75%, and no coverage regression on changed lines for both languages.
  - Acceptance: artifact contains all numeric values; any unmet threshold or missing value makes the plan outcome remediation-required, not PASS (AC9).
- [x] [P6-T9] Verify final script/template lockstep parity by running `git diff --no-index scripts/dev-tools/new-claude-worktree-session.ps1 extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`; write `<FEATURE>/evidence/other/<TS>-template-parity.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (empty diff).
  - Acceptance: diff is empty; EXIT_CODE 0 recorded (AC8).
- [x] [P6-T10] Check off each of the 9 acceptance criteria in `<FEATURE>/spec.md` and `<FEATURE>/user-story.md`, and write `<FEATURE>/evidence/other/<TS>-acceptance-verification.md` mapping every AC to the tasks, tests, and evidence artifacts that satisfy it (per the mapping table in this plan).
  - Acceptance: all 9 criteria checked in both documents; mapping artifact names concrete test names/files and evidence paths for each AC.

## Test Plan

- Unit (Pester): timestamp format, nested path builder, flat branch (no slash), `Get-WorktreeGroupDirectory` no-drift, `New-WorktreeParentDirectory` seam/idempotence/`-WhatIf`, invocation ordering, function-count integration, script/template parity. All seam-mocked; no temporary files.
- Unit (Jest via `npm run test`): formatter `T` separator + 16-char length + cross-toolchain fixture parity, nested path builder with normalization cases, flat branch, `ensureParentDirectory` strings for Claude and Codex builders, extension sendText ordering/count/index, remove-worktrees parent derivation + cleanup classifier + summary message, runner cleanup via fake seams, nested porcelain discovery, additive workspace-encoding matches.
- Manual/CLI: none required; behavior is fully covered by seam-injected unit tests.
- Coverage evidence: baselines at `<FEATURE>/evidence/baseline/<TS>-baseline-poshqc-test.md` and `<FEATURE>/evidence/baseline/<TS>-baseline-ts-test-coverage.md`; post-change at `<FEATURE>/evidence/qa-gates/<TS>-final-poshqc-test.md` and `<FEATURE>/evidence/qa-gates/<TS>-final-ts-test-coverage.md`; comparison at `<FEATURE>/evidence/qa-gates/<TS>-coverage-delta.md`.

## Open Questions / Notes

- Decisions fixed by the approved spec and not reopened here: flat branch names, empty-parent cleanup reported in the summary, template updated in lockstep (not deleted), no `matchEncodedDirectories` logic change.
- Line numbers cited from the research artifact are anchors, not contracts; the executor locates the named symbols if lines have drifted.
- The `extensions/drm-copilot` test runner is invoked through the repo npm scripts (`npm run test`, `npm run test:coverage`); use those scripts verbatim.

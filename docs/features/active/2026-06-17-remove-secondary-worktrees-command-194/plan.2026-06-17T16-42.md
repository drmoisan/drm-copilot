# remove-secondary-worktrees-command — Atomic Implementation Plan

- **Issue:** #194
- **Issue URL:** https://github.com/drmoisan/drm-copilot/issues/194
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-17T16-42
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Required References

These policies govern all work in this plan. Do not duplicate their content here; comply with them.

- Tone policy: `.github/copilot-instructions.md`, `.claude/rules/tonality.md`
- General code change: `.claude/rules/general-code-change.md`
- General unit test: `.claude/rules/general-unit-test.md`
- TypeScript code standards: `.claude/rules/typescript.md`
- TypeScript suppression policy: `.claude/rules/typescript-suppressions.md`
- Architecture boundaries: `.claude/rules/architecture-boundaries.md`
- Quality tiers (coverage thresholds): `.claude/rules/quality-tiers.md`

## Toolchain Note (authoritative for this feature)

The destination is the TypeScript VS Code extension at `extensions/drm-copilot/`. This package uses **Jest** (`run-jest.cjs`), not Vitest. Where `.claude/rules/typescript.md` names Vitest commands, the package-local Jest configuration governs for this feature. All commands below run from the `extensions/drm-copilot/` directory:

- Format: `npm run format`
- Lint: `npm run lint`
- Type-check: `npm run typecheck`
- Test (no coverage): `npm test`
- Test (with coverage, used for baseline and final QC): `node run-jest.cjs --coverage`

Toolchain order is format → lint → type-check → test. Restart from format if any step changes files or fails.

## Acceptance Criteria Source (authoritative)

The six acceptance criteria are defined in `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/issue.md` (the "Acceptance Criteria" list). Restated here for traceability mapping only:

- **AC1** — A new extension command removes all secondary worktrees and never removes the primary worktree.
- **AC2** — A worktree that cannot be fully removed is skipped and left intact; the command continues with remaining worktrees.
- **AC3** — The command reports removed and skipped worktrees with reasons.
- **AC4** — Implemented in TypeScript with pure logic separated from git I/O.
- **AC5** — Unit tests cover positive, negative, and edge cases; coverage meets repository thresholds (line ≥ 85%, branch ≥ 75%).
- **AC6** — The command is registered in `package.json` contributions and `extension.ts`, and documented in the extension README.

## Naming Decisions (binding for all tasks)

- Command ID: `drmCopilotExtension.removeSecondaryWorktrees`
- Command title: `drm-copilot: Remove Secondary Worktrees`
- Pure module: `extensions/drm-copilot/src/remove-worktrees.ts`
- I/O module: `extensions/drm-copilot/src/remove-worktrees-runner.ts`
- Test file: `extensions/drm-copilot/test/remove-worktrees.test.ts`

## Evidence Location Invariant

All evidence artifacts produced by this plan MUST be written under:
`docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/<kind>/`

Canonical kinds used here: `baseline/`, `qa-gates/`, `regression-testing/`, `other/`. Writing baseline/QA/coverage evidence to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and is rejected by the `enforce-evidence-locations.ps1` PreToolUse hook.

---

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture and Policy Reading

- [x] [P0-T1] Read the policy files in required order and record a Phase 0 read-evidence artifact.
  - Files to read, in order: `.github/copilot-instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/architecture-boundaries.md`, `.claude/rules/quality-tiers.md`.
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and the explicit list of files read.

- [x] [P0-T2] Capture the baseline Prettier format-check state for the extension.
  - Command (run from `extensions/drm-copilot/`): `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/baseline/baseline-format.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T3] Capture the baseline ESLint state for the extension.
  - Command (run from `extensions/drm-copilot/`): `npm run lint`
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/baseline/baseline-lint.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).

- [x] [P0-T4] Capture the baseline TypeScript type-check state for the extension.
  - Command (run from `extensions/drm-copilot/`): `npm run typecheck`
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/baseline/baseline-typecheck.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture the baseline Jest test and coverage state for the extension.
  - Command (run from `extensions/drm-copilot/`): `node run-jest.cjs --coverage`
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/baseline/baseline-test-coverage.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric headline line-coverage % and branch-coverage % for the package before any change.

### Phase 1 — Pure-Logic Module (`remove-worktrees.ts`)

Maps primarily to AC4 (pure/I-O separation) and supports AC1/AC2/AC3.

- [x] [P1-T1] Create `extensions/drm-copilot/src/remove-worktrees.ts` declaring the typed contract with no `vscode`, `node:child_process`, `node:fs`, or `node:path` imports.
  - Define and export: `WorktreeEntry` (readonly `path`, `isPrimary`, `isLocked`, `lockReason`, `isPrunable`, `pruneReason`); `WorktreeRemovalOutcome` (readonly `path`, `removed`, `skipReason: string | undefined`); `WorktreeSummary` (readonly `removed: ReadonlyArray<string>`, `skipped: ReadonlyArray<{ readonly path: string; readonly reason: string }>`); the classification result discriminated union `{ skip: true; reason: string } | { skip: false }`.
  - Acceptance: File compiles under `npm run typecheck`; contains no import of `vscode`/`node:child_process`/`node:fs`/`node:path`; file is ≤ 500 lines.

- [x] [P1-T2] Implement `parseWorktreePorcelain(raw: string): WorktreeEntry[]` in `extensions/drm-copilot/src/remove-worktrees.ts`.
  - Behavior: split blocks on blank lines handling both `\n\n` and `\r\n\r\n`; per block parse `worktree <path>`, `bare`, `detached`, `locked [reason]`, `prunable [reason]`, `branch refs/heads/<name>`, `HEAD <sha>`; mark only the first parsed block `isPrimary: true`; ignore empty trailing blocks.
  - Acceptance: Function exported and typed; covered by tests in [P4-T1]; file ≤ 500 lines.

- [x] [P1-T3] Implement `selectSecondaryWorktrees(entries: WorktreeEntry[]): WorktreeEntry[]` in `extensions/drm-copilot/src/remove-worktrees.ts`.
  - Behavior: return entries where `isPrimary === false`, preserving order. The primary worktree is excluded by position (first block) per the research design; this guarantees the primary is never selected for removal.
  - Acceptance: Function exported and typed; covered by tests in [P4-T2]; maps to AC1 (primary never removed).

- [x] [P1-T4] Implement `classifyWorktreeForRemoval(entry: WorktreeEntry): { skip: true; reason: string } | { skip: false }` in `extensions/drm-copilot/src/remove-worktrees.ts`.
  - Behavior: if `isLocked`, return `{ skip: true, reason }` where reason is `"locked"` plus the lock reason when non-empty; else if `isPrunable`, return `{ skip: true, reason }` where reason states the path is missing on disk plus the prune reason when non-empty; otherwise return `{ skip: false }` (eligible for NON-force `git worktree remove`).
  - Acceptance: Function exported and typed; covered by tests in [P4-T3]; maps to AC2 (locked/prunable skipped intact).

- [x] [P1-T5] Implement `buildRemovalSummaryMessage(summary: WorktreeSummary): string` in `extensions/drm-copilot/src/remove-worktrees.ts`.
  - Behavior: produce the user-facing report — `"No secondary worktrees found."` when both lists empty; `"Removed N worktree(s)."` when nothing skipped; otherwise `"Removed N worktree(s). Skipped M: <comma-separated paths>. See output channel for details."`.
  - Acceptance: Function exported and typed; covered by tests in [P4-T4]; maps to AC3 (reports removed/skipped with reasons).

- [x] [P1-T6] Run the toolchain after Phase 1 and confirm a clean pass.
  - Commands (from `extensions/drm-copilot/`), in order: `npm run format`, `npm run lint`, `npm run typecheck`, `npm test`. Restart from format if any step changes files or fails.
  - Acceptance: All four commands exit 0 in a single pass after the loop stabilizes. (Phase-1 final coverage is verified in Phase 5.)

### Phase 2 — I/O Module (`remove-worktrees-runner.ts`)

Maps primarily to AC4 (I/O boundary) and AC1/AC2/AC3.

- [x] [P2-T1] Create `extensions/drm-copilot/src/remove-worktrees-runner.ts` declaring the `GitRunner` interface.
  - Define and export `GitRunner` with `run(args: ReadonlyArray<string>, cwd: string): Promise<{ exitCode: number; stdout: string; stderr: string }>`. Import the pure types from `./remove-worktrees` and `CommandOutput`/`ProcessExecutionResult` from `./command-runtime` as needed. The interface contract is that `run` RESOLVES (never rejects) on a non-zero exit code.
  - Acceptance: File compiles under `npm run typecheck`; file ≤ 500 lines.

- [x] [P2-T2] Implement `createGitRunner(): GitRunner` in `extensions/drm-copilot/src/remove-worktrees-runner.ts`.
  - Behavior: wrap `node:child_process.spawn("git", args, { cwd, stdio: ["ignore","pipe","pipe"], shell: false })`; aggregate stdout/stderr; resolve with `{ exitCode, stdout, stderr }` for any close code (including non-zero); reject only on the child `error` event (spawn failure). Do not reuse `runCommandWithOutput` because it rejects on non-zero exit.
  - Acceptance: Function exported; uses only `node:child_process`; covered by tests in [P4-T9]; file ≤ 500 lines.

- [x] [P2-T3] Implement the orchestration function `removeAllSecondaryWorktrees(workspaceRoot: string, git: GitRunner, output: CommandOutput): Promise<WorktreeSummary>` in `extensions/drm-copilot/src/remove-worktrees-runner.ts`.
  - Behavior: (1) call `git.run(["worktree","list","--porcelain"], workspaceRoot)`; if `exitCode !== 0`, throw an `Error` carrying the stderr; (2) `parseWorktreePorcelain(stdout)` then `selectSecondaryWorktrees(...)`; (3) for each secondary entry call `classifyWorktreeForRemoval`: when `skip: true` record a skipped outcome with the reason and continue; when `skip: false` call `git.run(["worktree","remove", entry.path], workspaceRoot)` (NON-force) — `exitCode === 0` records removed, non-zero records skipped with `stderr.trim()` or `"git worktree remove failed"`; (4) a single failing/locked/prunable worktree must not abort the batch (continue to remaining entries); (5) never invoke `git worktree prune`; (6) aggregate into and return a `WorktreeSummary`; (7) append per-worktree progress lines to `output`.
  - Acceptance: Function exported and typed; covered by tests [P4-T5] through [P4-T8]; maps to AC1, AC2, AC3.

- [x] [P2-T4] Run the toolchain after Phase 2 and confirm a clean pass.
  - Commands (from `extensions/drm-copilot/`), in order: `npm run format`, `npm run lint`, `npm run typecheck`, `npm test`. Restart from format if any step changes files or fails.
  - Acceptance: All four commands exit 0 in a single pass.

### Phase 3 — Command Registration and Manifest

Maps primarily to AC6 and supports AC1/AC3.

- [x] [P3-T1] Add the command entry to `extensions/drm-copilot/package.json` `contributes.commands`.
  - Entry: `{ "command": "drmCopilotExtension.removeSecondaryWorktrees", "title": "drm-copilot: Remove Secondary Worktrees" }`.
  - Acceptance: `package.json` parses as valid JSON (verified by `npm run format` which formats `*.json`); entry present in `contributes.commands`; maps to AC6.

- [x] [P3-T2] Register the command handler in `extensions/drm-copilot/src/extension.ts` mirroring the existing `vscode.commands.registerCommand(...)` + `context.subscriptions.push(...)` pattern.
  - Behavior: in `activate()`, register `drmCopilotExtension.removeSecondaryWorktrees`; handler steps: (1) `getWorkspaceRoot()`; (2) modal confirmation `vscode.window.showWarningMessage("Remove all secondary git worktrees? This action removes each secondary worktree directory.", { modal: true }, "Remove All")` and return early when the result is not `"Remove All"`; (3) call `removeAllSecondaryWorktrees(workspaceRoot, createGitRunner(), output)`; (4) on success, append `buildRemovalSummaryMessage(summary)` to the output channel and surface it via `showInformationMessage` (all removed / none found) or `showWarningMessage` (some skipped); (5) wrap in try/catch and surface thrown errors via `vscode.window.showErrorMessage`. Push the returned disposable into `context.subscriptions`.
  - Acceptance: Import statements added for `createGitRunner`/`removeAllSecondaryWorktrees` from `./remove-worktrees-runner` and `buildRemovalSummaryMessage` from `./remove-worktrees`; `extension.ts` remains ≤ 500 lines (split a helper into a new module if it would exceed the limit); maps to AC1, AC3, AC6.

- [x] [P3-T3] Run the toolchain after Phase 3 and confirm a clean pass.
  - Commands (from `extensions/drm-copilot/`), in order: `npm run format`, `npm run lint`, `npm run typecheck`, `npm test`. Restart from format if any step changes files or fails.
  - Acceptance: All four commands exit 0 in a single pass.

### Phase 4 — Tests (Jest)

Maps primarily to AC5 and verifies AC1/AC2/AC3.

- [x] [P4-T1] Add tests for `parseWorktreePorcelain` to `extensions/drm-copilot/test/remove-worktrees.test.ts`.
  - Cover: single primary block; primary + multiple secondary blocks; `locked` with and without reason; `prunable` with and without reason; `detached` and `bare` flags; `\r\n\r\n` block separators; trailing blank block ignored. Use string inputs only; no git, no filesystem, no temp files.
  - Acceptance: Tests pass under `npm test`; uses `@jest/globals` imports consistent with existing test files.

- [x] [P4-T2] Add tests for `selectSecondaryWorktrees` to `extensions/drm-copilot/test/remove-worktrees.test.ts`.
  - Cover: primary excluded; order preserved; empty secondary set when only primary present (no-secondary-worktrees case for the selector). Maps to AC1.
  - Acceptance: Tests pass under `npm test`.

- [x] [P4-T3] Add tests for `classifyWorktreeForRemoval` to `extensions/drm-copilot/test/remove-worktrees.test.ts`.
  - Cover: locked entry → `{ skip: true }` with reason containing `"locked"`; prunable entry → `{ skip: true }` with path-missing reason; clean entry → `{ skip: false }`; locked-and-prunable precedence (locked reported first). Maps to AC2.
  - Acceptance: Tests pass under `npm test`.

- [x] [P4-T4] Add tests for `buildRemovalSummaryMessage` to `extensions/drm-copilot/test/remove-worktrees.test.ts`.
  - Cover: empty summary → `"No secondary worktrees found."`; all removed → `"Removed N worktree(s)."`; mixed removed/skipped → message listing skipped paths. Maps to AC3.
  - Acceptance: Tests pass under `npm test`.

- [x] [P4-T5] Add a fake `GitRunner` helper and the positive-flow orchestration test to `extensions/drm-copilot/test/remove-worktrees.test.ts`.
  - Helper: a fake `GitRunner` that records each `args` array it receives and returns canned `{ exitCode, stdout, stderr }` responses in sequence; no `child_process`, no `EventEmitter`, no temp files.
  - Positive flow: list returns primary + two clean secondary worktrees; both removes return exit 0; assert `summary.removed` contains both paths, `summary.skipped` is empty, and the captured argv shows NON-force `["worktree","remove",<path>]` (no `--force`). Maps to AC1, AC3.
  - Acceptance: Test passes under `npm test`.

- [x] [P4-T6] Add the skip-on-failure continuation orchestration test to `extensions/drm-copilot/test/remove-worktrees.test.ts`.
  - Cover: list returns primary + two clean secondary worktrees; first remove returns non-zero with stderr; second remove returns exit 0; assert the batch continues, the first path is in `summary.skipped` with the stderr reason, and the second path is in `summary.removed`. Maps to AC2, AC3.
  - Acceptance: Test passes under `npm test`.

- [x] [P4-T7] Add the locked/prunable skip orchestration test to `extensions/drm-copilot/test/remove-worktrees.test.ts`.
  - Cover: list returns primary + one locked + one prunable secondary worktree; assert neither triggers a `git worktree remove` call (argv capture shows only the list call), both appear in `summary.skipped` with appropriate reasons, and `summary.removed` is empty. Maps to AC2, AC3.
  - Acceptance: Test passes under `npm test`.

- [x] [P4-T8] Add the no-secondary-worktrees and primary-never-removed orchestration tests to `extensions/drm-copilot/test/remove-worktrees.test.ts`.
  - Cover: (a) list returns only the primary block → `summary.removed` and `summary.skipped` both empty and no remove call issued; (b) assert that under all the above scenarios the primary worktree path is never passed to a `git worktree remove` call. Also cover the list-failure path: `git worktree list` returns non-zero → `removeAllSecondaryWorktrees` throws. Maps to AC1.
  - Acceptance: Tests pass under `npm test`.

- [x] [P4-T9] Add a `createGitRunner` resolve-on-nonzero test to `extensions/drm-copilot/test/remove-worktrees.test.ts`.
  - Cover: using the existing `childProcessMock`/`createMockProcess` harness facility, configure `spawn` to return a process closing with a non-zero exit code and assert `createGitRunner().run(...)` RESOLVES with that `exitCode` and captured stderr (does not reject). Add a spawn-error case asserting rejection only on the `error` event. No real git, no temp files.
  - Acceptance: Tests pass under `npm test`; maps to AC4 (I/O seam) and the reject-vs-resolve contract.

- [x] [P4-T10] Extend `extensions/drm-copilot/test/extension-test-harness.ts` with `showWarningMessage`, `showInformationMessage`, and `showErrorMessage` jest mocks if they are not already present, and export them alongside `showInputBoxMock`.
  - Behavior: add `const showWarningMessageMock = jest.fn();` (and the information/error equivalents), wire them into the mocked `vscode.window` object, reset them in `resetExtensionHarnessState`, and export them.
  - Acceptance: Harness compiles under `npm run typecheck`; mocks reset between tests consistent with the existing reset pattern.

- [x] [P4-T11] Add command-registration and confirmation tests to `extensions/drm-copilot/test/extension.test.ts` consistent with the existing harness pattern.
  - Cover: (a) `activate` registers `drmCopilotExtension.removeSecondaryWorktrees` (assert `commandHandlers.has(...)` is true and present exactly once); (b) confirmation cancellation — when `showWarningMessage` resolves to `undefined`, invoking the handler does not call `childProcessMock.spawn`; (c) error path — when `git worktree list` exits non-zero, the handler calls `showErrorMessage`. Maps to AC6, AC2.
  - Acceptance: Tests pass under `npm test`.

- [x] [P4-T12] Run the toolchain after Phase 4 and confirm a clean pass with coverage thresholds met.
  - Commands (from `extensions/drm-copilot/`), in order: `npm run format`, `npm run lint`, `npm run typecheck`, `node run-jest.cjs --coverage`. Restart from format if any step changes files or fails.
  - Acceptance: All commands exit 0; coverage for the new modules and the package meets line ≥ 85% and branch ≥ 75%. Maps to AC5.

### Phase 5 — Documentation, Cleanup, and Final QA Loop

Maps to AC5, AC6, and final verification of AC1–AC4.

- [x] [P5-T1] Document the command in `extensions/drm-copilot/README.md`.
  - Behavior: add `drmCopilotExtension.removeSecondaryWorktrees` to the "VS Code Commands" command-ID list and add a prose section (mirroring the "New Claude Worktree Session" section) describing: that it removes all secondary worktrees and never the primary; the modal confirmation; the NON-force `git worktree remove` semantics (worktrees that cannot be fully removed are skipped and left intact); that locked and prunable worktrees are skipped with reasons; that `git worktree prune` is not invoked automatically; and that removed/skipped outcomes are reported to the output channel and a notification.
  - Acceptance: README updated; maps to AC6.

- [x] [P5-T2] Remove the superseded draft `scripts/dev-tools/remove-worktrees.ps1`.
  - Rationale: the TypeScript command replaces the untracked, untested, Windows-centric draft. The file is currently untracked; deleting it removes the superseded artifact so it is not mistaken for the supported implementation.
  - Acceptance: `scripts/dev-tools/remove-worktrees.ps1` no longer exists in the working tree. Record the deletion in evidence artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/other/superseded-script-removal.md` with `Timestamp:` and the removed path.

- [x] [P5-T3] Run the final-QC Prettier format check and record evidence.
  - Command (from `extensions/drm-copilot/`): `npm run format`
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/qa-gates/final-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If this step changes files, restart the loop from this task.

- [x] [P5-T4] Run the final-QC ESLint check and record evidence.
  - Command (from `extensions/drm-copilot/`): `npm run lint`
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/qa-gates/final-lint.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (0 errors).

- [x] [P5-T5] Run the final-QC TypeScript type-check and record evidence.
  - Command (from `extensions/drm-copilot/`): `npm run typecheck`
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/qa-gates/final-typecheck.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (0 type errors).

- [x] [P5-T6] Run the final-QC Jest suite with coverage and record evidence.
  - Command (from `extensions/drm-copilot/`): `node run-jest.cjs --coverage`
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/qa-gates/final-test-coverage.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric post-change line-coverage % and branch-coverage % for the package.

- [x] [P5-T7] Verify coverage delta against thresholds and record the comparison.
  - Behavior: compare baseline coverage ([P0-T5]) to post-change coverage ([P5-T6]); confirm package line coverage ≥ 85% and branch coverage ≥ 75%, that coverage on the changed lines did not regress, and report new-code coverage for `remove-worktrees.ts` and `remove-worktrees-runner.ts`.
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/qa-gates/coverage-comparison.md` recording baseline coverage, post-change coverage, and new/changed-code coverage with numeric values. If thresholds are not met, outcome is remediation-required (not PASS). Maps to AC5.

- [x] [P5-T8] Verify acceptance-criteria traceability and record the end-state summary.
  - Behavior: confirm each of AC1–AC6 is satisfied by the tasks above and cite the file/test evidence for each.
  - Acceptance: Artifact `docs/features/active/2026-06-17-remove-secondary-worktrees-command-194/evidence/other/ac-traceability.md` mapping AC1→[P1-T3]/[P3-T2]/[P4-T2]/[P4-T8], AC2→[P1-T4]/[P2-T3]/[P4-T6]/[P4-T7], AC3→[P1-T5]/[P2-T3]/[P4-T4]/[P4-T5], AC4→[P1-T1]/[P2-T1]/[P2-T2]/[P4-T9], AC5→[P4-*]/[P5-T6]/[P5-T7], AC6→[P3-T1]/[P3-T2]/[P4-T11]/[P5-T1], each with concrete evidence.

## Test Plan

- Unit (pure): `parseWorktreePorcelain`, `selectSecondaryWorktrees`, `classifyWorktreeForRemoval`, `buildRemovalSummaryMessage` — string-in/object-out, no I/O ([P4-T1]–[P4-T4]).
- Unit (orchestration): `removeAllSecondaryWorktrees` with an injected fake `GitRunner` capturing argv and returning canned exit codes — positive flow, skip-on-failure continuation, locked/prunable skip, no-secondary case, primary-never-removed, list-failure throw ([P4-T5]–[P4-T8]).
- Unit (I/O seam): `createGitRunner` resolves on non-zero exit and rejects only on spawn error via the existing `childProcessMock` harness ([P4-T9]).
- Registration: command registered once; confirmation cancellation issues no git; list failure surfaces `showErrorMessage` ([P4-T11]).
- Coverage evidence: baseline `evidence/baseline/baseline-test-coverage.md`; post-change `evidence/qa-gates/final-test-coverage.md`; comparison `evidence/qa-gates/coverage-comparison.md`.

## Constraints Encoded

- No new runtime dependencies; only `@modelcontextprotocol/sdk` is permitted. New modules use `node:` built-ins only (`node:child_process` in the runner).
- Pure module `remove-worktrees.ts` imports none of `vscode`/`node:child_process`/`node:fs`/`node:path`.
- Each touched/new source and test file stays under 500 lines.
- NON-force `git worktree remove` only; `git worktree remove --force`/`--force --force` is prohibited; `git worktree prune` is never invoked automatically.
- Toolchain order format → lint → type-check → test, run from `extensions/drm-copilot/`, restarting on any change/failure.

## Open Questions / Notes

- The research artifact uses the command ID `drmCopilotExtension.removeAllWorktrees`; this plan follows the delegation-specified ID `drmCopilotExtension.removeSecondaryWorktrees`. If the research ID is preferred, update [P3-T1], [P3-T2], [P4-T11], and [P5-T1] consistently.
- `.claude/rules/typescript.md` names Vitest; the extension package is configured for Jest (`run-jest.cjs`, `jest.config.cjs`). This plan uses the package-local Jest toolchain, which governs for this feature.

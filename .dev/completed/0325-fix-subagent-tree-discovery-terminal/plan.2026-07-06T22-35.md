# fix-subagent-tree-discovery-terminal (Plan) — Issue #325

- **Issue:** #325
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-06T22-35
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** minor-audit (short path)

**DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED**

**Requirements source:** `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/issue.md` is the sole requirements source. Only its `## Acceptance Criteria` section is the acceptance-criteria source for this plan. This plan does not require and must not be blocked by the absence of `spec.md`, `user-story.md`, or `research.md`.

**Work directory:** All commands in this plan run from `extensions/drm-copilot/` unless a task states otherwise.

**Fail-closed evidence rule:** Baseline artifact tasks, delegated-implementation acceptance tasks, and final-QC artifact tasks are mandatory. If any required baseline artifact, implementation acceptance artifact, or final-QC artifact is missing or incomplete, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Every evidence-producing task names its exact artifact path under `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/<kind>/`. No evidence may be written under any `artifacts/` path. Do not mark a checklist item complete without the artifact existing on disk with all required fields.

**Evidence path base (canonical):** `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/`
**Timestamp format:** `yyyy-MM-ddTHH-mm` (ISO-8601), substituted for `<TS>` in artifact filenames below at execution time.

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `CLAUDE.md` at the repository root in full before any implementation work begins.
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` in full.
- [x] [P0-T3] Read `.claude/rules/general-unit-test.md` in full.
- [x] [P0-T4] Read `.claude/rules/typescript.md` in full.
- [x] [P0-T5] Read `.claude/rules/typescript-suppressions.md` in full.
- [x] [P0-T6] Write the Phase 0 policy-read evidence artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/baseline/phase0-instructions-read.md` containing at minimum: `Timestamp:`, `Policy Order:` (numbered list matching P0-T1..P0-T5 in order), and the explicit list of files read with their full repo-relative paths.
- [x] [P0-T7] Run `npm run format` from `extensions/drm-copilot/` and write the baseline artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/baseline/format.<TS>.md` with `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and any files reformatted).
- [x] [P0-T8] Run `npm run lint` from `extensions/drm-copilot/` and write the baseline artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/baseline/lint.<TS>.md` with `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T9] Run `npm run typecheck` from `extensions/drm-copilot/` and write the baseline artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/baseline/typecheck.<TS>.md` with `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, and `Output Summary:` (error count).
- [x] [P0-T10] Run `npm run test:coverage` from `extensions/drm-copilot/` and write the baseline artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/baseline/test-coverage.<TS>.md` with `Timestamp:`, `Command: npm run test:coverage`, `EXIT_CODE:`, and `Output Summary:` that records the numeric overall lines/branches coverage headline plus the per-file lines/branches coverage for `extensions/drm-copilot/src/subagent-tree-command.ts` and `extensions/drm-copilot/src/command-runtime.ts`.
- [x] [P0-T11] Run `npm run build` from `extensions/drm-copilot/` and write the baseline artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/baseline/build.<TS>.md` with `Timestamp:`, `Command: npm run build`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and any errors).

### Phase 1 — Constrained Small-Path Implementation (Delegated)

**Handoff:** Delegate the tasks below to the small-path implementation engineer. **Acceptance criteria for implementation completion:** every task in this phase is checked, every named test exists and passes locally, the encoding-rule confirmation artifact and the AC-verification artifact (P1-T1, P1-T17) exist on disk, and no task in Phase 1 introduces a `vscode` import into `extensions/drm-copilot/src/lib/subagent-tree/`.

- [x] [P1-T1] Confirm the workspace-path encoding rule against on-disk examples under the real `~/.claude/projects/` directory (separators and `:` replaced by `-`; drive-letter case varies) and record the confirmed rule, with at least two on-disk example folder names cited verbatim, in `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/other/encoding-rule-confirmation.<TS>.md`.
- [x] [P1-T2] Implement a home-directory / CLAUDE-config-dir resolver in `extensions/drm-copilot/src/command-runtime.ts` (e.g. `getClaudeProjectsRoot(env?: NodeJS.ProcessEnv): string`) that returns the user-global Claude projects directory (default derived from the user's home directory + `.claude/projects`), honoring an injectable override so unit tests do not depend on the real `HOME`/`USERPROFILE`.
- [x] [P1-T3] Add a new pure module file `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts` (no `vscode` imports) exporting a function that encodes an absolute workspace path per the confirmed rule from P1-T1 and a function that, given a list of directory names and the encoded workspace name, returns the matching directory names case-insensitively on the drive-letter segment, including per-worktree sibling folders (names beginning with `<encoded>-wt-`).
- [x] [P1-T4] Update `discoverRootSessionCandidates` in `extensions/drm-copilot/src/subagent-tree-command.ts` to glob `*.jsonl` under the resolved user-global Claude projects directory (from P1-T2) narrowed to the matching encoded/worktree-sibling directories (from P1-T3) via the existing `FileSystem` seam, replacing the current `getWorkspaceRoot()` + `.claude/projects/**/*.jsonl` relative glob.
- [x] [P1-T5] Update the zero-candidates error message construction in `extensions/drm-copilot/src/subagent-tree-command.ts` so it names the real resolved user-global search location(s) produced by P1-T2/P1-T3 instead of the literal string `.claude/projects/**/*.jsonl`.
- [x] [P1-T6] Add a terminal-writer seam to `extensions/drm-copilot/src/command-runtime.ts`: an interface (e.g. `TerminalWriter` with a `write(header: string, body: string): void` and `reveal(): void` method) plus a real implementation that creates or reuses a single VS Code integrated terminal named `"drm-copilot: Subagent Tree"` backed by a `vscode.Pseudoterminal` that emits the header and body joined with `\r\n`, and reveals the terminal.
- [x] [P1-T7] Extend the `options` parameter of `registerSubagentTreeCommand` in `extensions/drm-copilot/src/subagent-tree-command.ts` to accept an injected terminal-writer factory (mirroring how the `FileSystem` seam is constructed/injected).
- [x] [P1-T8] Update `registerSubagentTreeCommand` in `extensions/drm-copilot/src/subagent-tree-command.ts` to route the header line `[drmCopilotExtension.showSubagentTree] subagent tree for <path>:` plus the full `formatTree` output to the injected terminal-writer seam (write + reveal) instead of `output.appendLine`/`output.show`.
- [x] [P1-T9] Confirm and, if needed, adjust `extensions/drm-copilot/src/subagent-tree-command.ts` so that genuine errors (discovery failure, zero-candidates, user-cancel) continue to call `output.appendLine` and `vscode.window.showErrorMessage` exclusively, and are never written to the terminal-writer seam.
- [x] [P1-T10] Add a Jest unit test in `extensions/drm-copilot/test/subagent-tree-command.test.ts` verifying that transcript discovery resolves candidates from a fake user-global Claude projects directory (injected via the P1-T2 override) rather than from the workspace root.
- [x] [P1-T11] Add a Jest unit test in `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` verifying workspace-to-encoded-directory matching, including a case where the on-disk directory uses a lowercase drive-letter segment (e.g. `c--Users-...`) and the workspace path uses an uppercase drive letter (e.g. `C:\Users\...`).
- [x] [P1-T12] Add a Jest unit test in `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` verifying that per-worktree sibling folders (e.g. `<encoded>-wt-2026-06-13-11-51`) are included among the matched candidate directories.
- [x] [P1-T13] Add a Jest unit test in `extensions/drm-copilot/test/subagent-tree-command.test.ts` verifying the zero-candidates error message names the real resolved user-global search location rather than the old relative-glob string.
- [x] [P1-T14] Add a Jest unit test in `extensions/drm-copilot/test/subagent-tree-command.test.ts` verifying that a fake injected terminal-writer receives the header line plus the full `formatTree` output and that `reveal()` is called.
- [x] [P1-T15] Add a Jest unit test in `extensions/drm-copilot/test/subagent-tree-command.test.ts` verifying that two consecutive command invocations reuse/replace the same named terminal (the terminal-writer factory is invoked in a way that does not accumulate a second terminal instance) rather than creating a new terminal per run.
- [x] [P1-T16] Add a Jest unit test in `extensions/drm-copilot/test/subagent-tree-command.test.ts` verifying that on a discovery failure, a zero-candidates result, and a user-cancel selection, `showErrorMessage`/the output-channel error path is invoked and the fake terminal-writer's `write` method is not called.
- [x] [P1-T17] Add a Jest unit test (e.g. in `extensions/drm-copilot/test/lib/subagent-tree/module-boundary.test.ts`) that statically scans every file under `extensions/drm-copilot/src/lib/subagent-tree/` for the substring `"vscode"` in import statements and fails if any is found, confirming the pure-module boundary is preserved.
- [x] [P1-T18] Verify each checkbox in the `## Acceptance Criteria` section of `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/issue.md` against the implementation and tests from P1-T1..P1-T17, and record the criterion-by-criterion mapping (criterion text, satisfying task ID(s), satisfying test file/name) in `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/other/ac-verification.<TS>.md`.

### Phase 2 — Final QC Loop

All commands run from `extensions/drm-copilot/`. Every task below is unconditional: it must execute its stated command and record the result. `EXIT_CODE: SKIPPED` is not a valid outcome for any task in this phase.

- [x] [P2-T1] Run `npm run format` from `extensions/drm-copilot/` and write the final-QC artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/format.<TS>.md` with `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P2-T2] Run `npm run lint` from `extensions/drm-copilot/` and write the final-QC artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/lint.<TS>.md` with `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P2-T3] Run `npm run typecheck` from `extensions/drm-copilot/` and write the final-QC artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/typecheck.<TS>.md` with `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P2-T4] Run `npm run test:coverage` from `extensions/drm-copilot/` and write the final-QC artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/test-coverage.<TS>.md` with `Timestamp:`, `Command: npm run test:coverage`, `EXIT_CODE:`, and `Output Summary:` that records the numeric overall lines/branches coverage plus per-file lines/branches coverage for `extensions/drm-copilot/src/subagent-tree-command.ts`, `extensions/drm-copilot/src/command-runtime.ts`, and `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts`, demonstrating lines >= 85% and branches >= 75% for each and confirming none of the three files is excluded from the coverage report.
- [x] [P2-T5] Run `npm run build` from `extensions/drm-copilot/` and write the final-QC artifact to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/build.<TS>.md` with `Timestamp:`, `Command: npm run build`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P2-T6] If any of P2-T1..P2-T5 reported a non-zero `EXIT_CODE` or modified any tracked file (e.g. `npm run format` reformatted a file), restart the loop from P2-T1 and re-run every step in order; repeat until one full pass of P2-T1..P2-T5 completes with `EXIT_CODE: 0` for every step and no file modifications, then write the final clean-pass confirmation to `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/final-qc-clean-pass.<TS>.md` with `Timestamp:`, the loop iteration count, and `Output Summary: all five steps passed with EXIT_CODE 0 in a single pass`.

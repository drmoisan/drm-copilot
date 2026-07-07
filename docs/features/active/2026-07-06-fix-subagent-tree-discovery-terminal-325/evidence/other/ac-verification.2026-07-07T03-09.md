# Acceptance-Criteria Verification — Issue #325 (P1-T18)

Timestamp: 2026-07-07T03-09

Source: `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/issue.md`
`## Acceptance Criteria` section, criterion-by-criterion mapping to the satisfying
implementation task(s) and test file/name.

## 1. Transcript discovery resolves the user-global Claude projects directory

**Criterion:** Transcript discovery resolves the user-global Claude projects directory
(`~/.claude/projects/`, honoring a home-dir / CLAUDE config dir override) rather than
globbing `<repo>/.claude/projects/`.

- Satisfying tasks: P1-T2 (`getClaudeProjectsRoot` in `src/command-runtime.ts`), P1-T4
  (`discoverRootSessionCandidates` in `src/subagent-tree-command.ts` now globs under the
  resolved `claudeProjectsRoot` instead of `workspaceRoot`).
- Satisfying tests:
  - `test/command-runtime.test.ts` → `describe("getClaudeProjectsRoot")` (5 cases: `CLAUDE_CONFIG_DIR`
    override, `HOME` fallback, `USERPROFILE` fallback, whitespace-only `CLAUDE_CONFIG_DIR`
    treated as unset, throws when none set).
  - `test/subagent-tree-command.test.ts` → `"resolves candidates from the user-global Claude
    projects directory rather than the workspace root"`.

## 2. Candidate discovery narrowed to the encoded workspace directory, including worktree siblings

**Criterion:** Candidate discovery is narrowed to the encoded directory name for the current
workspace path (separators and `:` replaced by `-`), verified against on-disk examples, and
includes per-worktree sibling folders.

- Satisfying tasks: P1-T1 (on-disk rule confirmation:
  `evidence/other/encoding-rule-confirmation.2026-07-07T02-50.md`), P1-T3
  (`src/lib/subagent-tree/workspace-encoding.ts`), P1-T4 (wiring into discovery).
- Satisfying tests: `test/lib/subagent-tree/workspace-encoding.test.ts` →
  `"replaces backslashes, forward slashes, and colons with hyphens"`,
  `"encodes a forward-slash workspace path identically to a backslash one"`,
  `"matches an on-disk directory whose drive-letter segment uses a lowercase letter against an
  uppercase-encoded workspace name"`,
  `"includes a per-worktree sibling folder among the matched candidate directories"`,
  `"includes a nested worktree-of-a-worktree sibling folder"`,
  `"returns an empty array when no directory name matches"`.

## 3. Existing selection behavior preserved

**Criterion:** Flattened `/subagents/` transcripts are excluded, a single candidate auto-selects,
multiple candidates prompt via quick-pick.

- Satisfying task: P1-T4 (discovery filter/sort logic carried over unchanged; selection logic
  in `selectRootSession` unchanged).
- Satisfying tests: `test/subagent-tree-command.test.ts` →
  `"auto-selects a single discovered root session without prompting"`,
  `"prompts via showQuickPick among multiple candidates and renders the one selected"`,
  `"excludes flattened /subagents/ transcripts from candidates"`.

## 4. Zero-candidates error message names the real search location

**Criterion:** The zero-candidates error message names the real user-global search location.

- Satisfying task: P1-T5 (`selectRootSession` error message construction).
- Satisfying test: `test/subagent-tree-command.test.ts` →
  `"names the real resolved user-global search location in the zero-candidates error message"`
  (asserts the message contains the resolved `claudeProjectsRoot` and does not contain the old
  `.claude/projects/**/*.jsonl` literal).

## 5. Rendered tree written to an integrated terminal and revealed

**Criterion:** The rendered tree (existing header line plus full `formatTree` output) is written
to an integrated VS Code terminal, and the terminal is revealed.

- Satisfying tasks: P1-T6 (`TerminalWriter` seam + `PseudoterminalTerminalWriter` in
  `src/command-runtime.ts`), P1-T8 (`registerSubagentTreeCommand` routes header + rendered tree
  to the terminal seam and calls `reveal()`).
- Satisfying tests:
  - `test/command-runtime.test.ts` →
    `"creates a single named terminal backed by a Pseudoterminal that emits header and body
    joined by \r\n"`, `"reveals the terminal via show()"`.
  - `test/subagent-tree-command.test.ts` →
    `"writes the header plus full formatTree output to the terminal seam and reveals it"`.

## 6. Stable terminal name; repeated runs reuse/replace a single terminal

**Criterion:** The terminal uses a stable, recognizable name and repeated runs reuse/replace a
single named terminal rather than accumulating terminals.

- Satisfying tasks: P1-T6 (`SUBAGENT_TREE_TERMINAL_NAME = "drm-copilot: Subagent Tree"`;
  `PseudoterminalTerminalWriter` reuses the live terminal or replaces an exited one), P1-T7
  (terminal-writer factory constructed once at `registerSubagentTreeCommand` registration time
  so the same `TerminalWriter` instance is shared across invocations).
- Satisfying tests:
  - `test/command-runtime.test.ts` →
    `"reuses the same terminal across repeated writes while it remains open"`,
    `"creates a replacement terminal once the previous terminal has exited"`.
  - `test/subagent-tree-command.test.ts` →
    `"reuses the same terminal-writer instance across two consecutive invocations"`.

## 7. Genuine errors still route to the error path

**Criterion:** Genuine errors (failures, zero-candidates, user-cancel) still route to the error
path (`showErrorMessage` / diagnostic sink), not solely to the terminal.

- Satisfying task: P1-T9 (error-path calls confirmed unchanged; `catch` block and
  zero-candidates/user-cancel branches never call `terminalWriter.write`).
- Satisfying tests: `test/subagent-tree-command.test.ts` →
  `"routes a discovery failure to the error path and does not write to the terminal seam"`,
  `"names the real resolved user-global search location in the zero-candidates error message"`
  (also asserts `terminalWriter.writes` has length 0),
  `"routes a user-cancel selection to the output log and does not write to the terminal seam"`.

## 8. Pure module boundary preserved

**Criterion:** `extensions/drm-copilot/src/lib/subagent-tree/` contains no `vscode` imports and
`formatTree` remains a pure string renderer; filesystem-root resolution and terminal wiring live
in the host-bound command file or behind injectable seams.

- Satisfying tasks: P1-T3 (`workspace-encoding.ts` added with no `vscode` import), P1-T6/P1-T7/P1-T8
  (all terminal wiring lives in `src/command-runtime.ts` and `src/subagent-tree-command.ts`, not
  in `src/lib/subagent-tree/`).
- Satisfying test: `test/lib/subagent-tree/module-boundary.test.ts` →
  `"contains no \`vscode\` import statements in any source file"` (static scan of every `.ts`
  file under `src/lib/subagent-tree/`).

## 9. Command remains testable without a live VS Code host

**Criterion:** The terminal factory is injected the same way as the `FileSystem` seam, and unit
tests assert on captured terminal output.

- Satisfying task: P1-T7 (`registerSubagentTreeCommand` options extended with
  `createFileSystem?: () => FileSystem` and `createTerminalWriter?: () => TerminalWriter`, both
  optional with real-implementation defaults).
- Satisfying tests: every scenario in `test/subagent-tree-command.test.ts` injects a
  `FakeTerminalWriter` (implementing `TerminalWriter`) and an `InMemoryFileSystem` via these
  seams, and asserts directly on `FakeTerminalWriter.writes` / `revealCallCount` — no live VS
  Code host is required.

## 10. Toolchain passes; per-file coverage thresholds met; no file excluded

**Criterion:** The extension toolchain passes: `npm run format`, `lint`, `typecheck`,
`test:coverage`, `build`. Per-file coverage meets lines >= 85% and branches >= 75%; no production
file is excluded from coverage.

- Satisfying tasks: P2-T1..P2-T6 (final-QC loop).
- Satisfying evidence: `evidence/qa-gates/format.2026-07-07T03-15.md`,
  `evidence/qa-gates/lint.2026-07-07T03-15.md`, `evidence/qa-gates/typecheck.2026-07-07T03-15.md`,
  `evidence/qa-gates/test-coverage.2026-07-07T03-15.md`, `evidence/qa-gates/build.2026-07-07T03-15.md`,
  `evidence/qa-gates/final-qc-clean-pass.2026-07-07T03-15.md`.
- Status: the canonical Phase 2 evidence above confirms `npm run format`, `lint`, `typecheck`,
  `test:coverage`, and `build` all pass with `EXIT_CODE: 0` in a single pass (no restart
  required). Per-file coverage: `src/subagent-tree-command.ts` lines 179/179 (100.00%) /
  branches 18/19 (94.74%); `src/lib/subagent-tree/workspace-encoding.ts` lines 64/64 (100.00%) /
  branches 4/4 (100.00%); `src/command-runtime.ts` lines 629/669 (94.02%) / branches 81/93
  (87.10%) — all above the 85%/75% gate and none excluded from `coverage/lcov.info` or from
  `jest.config.cjs`'s `collectCoverageFrom`. This criterion is checked off in `issue.md`.

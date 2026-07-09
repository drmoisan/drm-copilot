# subagent-tree-mcp-and-dropdown — Plan

- **Issue:** #334
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-09T10-30
- **Status:** Draft (pending preflight)
- **Version:** 1.0
- **Work Mode:** full-feature

## Required References

- Spec: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/spec.md`
- User story: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/user-story.md`
- Research: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/research/2026-07-09T09-50-subagent-tree-mcp-and-dropdown-334-research.md`
- Policies: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/powershell.md`

All work must comply with these policies; do not duplicate their content here.

## Conventions Used Throughout This Plan

- `<FEATURE>` = `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334`. All evidence artifacts go under `<FEATURE>/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No `artifacts/**` evidence paths are permitted.
- `<TS>` = the ISO-8601 run timestamp `yyyy-MM-ddTHH-mm` captured at task execution time.
- Every command-step evidence artifact MUST contain: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Test-step artifacts for coverage-bearing languages MUST include numeric coverage values in `Output Summary:`.
- **TS toolchain loop** (run from `extensions/drm-copilot/`): `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test` (or `npm run test:coverage` where the task says so). If any step fails or changes files, restart the loop from `npm run format` until all steps pass in a single clean pass.
- **PowerShell toolchain loop** (MCP tools): `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`. If any step fails or changes files, restart from format until a single clean pass.
- Toolchain divergence note (research §Open Risks #3): the extension's wired test framework is **Jest** with tests under `extensions/drm-copilot/test/**`; `.claude/rules/typescript.md` names Vitest/`tests/`. This plan follows the extension's established configuration (all 27 existing suites) as governing precedent. Record this deviation in QA evidence rather than migrating.
- No production file may exceed 500 lines. No new runtime dependency may be added. New `extensions/drm-copilot/src/lib/**` modules must import neither `vscode` nor `node:fs` (the `RealFileTimes` exception lives in `src/lib/file-system.ts` itself).

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read repo policies in the required order — `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/powershell.md` — and write `<FEATURE>/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read.
  - Acceptance: artifact exists at `<FEATURE>/evidence/baseline/phase0-instructions-read.md` with all three required fields.
- [x] [P0-T2] Capture the TypeScript formatting baseline: from `extensions/drm-copilot/`, run `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` and write `<FEATURE>/evidence/baseline/ts-format-check.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact exists with all four fields; `EXIT_CODE: 0` expected on a clean baseline.
- [x] [P0-T3] Capture the TypeScript lint baseline: from `extensions/drm-copilot/`, run `npm run lint` and write `<FEATURE>/evidence/baseline/ts-lint.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact exists with all four fields.
- [x] [P0-T4] Capture the TypeScript type-check baseline: from `extensions/drm-copilot/`, run `npm run typecheck` and write `<FEATURE>/evidence/baseline/ts-typecheck.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: artifact exists with all four fields.
- [x] [P0-T5] Capture the Jest coverage baseline: from `extensions/drm-copilot/`, run `npm run test:coverage` and write `<FEATURE>/evidence/baseline/ts-jest-coverage.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` containing the numeric suite counts and the numeric line/branch coverage headline from `text-summary`.
  - Acceptance: artifact exists; `Output Summary:` contains numeric line % and branch % values (no placeholders).
- [x] [P0-T6] Capture the PowerShell analyzer baseline: run `mcp__drm-copilot__run_poshqc_analyze` for the workspace and write `<FEATURE>/evidence/baseline/ps-analyze.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (diagnostic counts).
  - Acceptance: artifact exists with all four fields.
- [x] [P0-T7] Capture the Pester coverage baseline: run `mcp__drm-copilot__run_poshqc_test` for the workspace and write `<FEATURE>/evidence/baseline/ps-pester-coverage.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` containing the numeric pass/fail counts and the numeric coverage headline.
  - Acceptance: artifact exists; `Output Summary:` contains numeric coverage values (no placeholders).

### Phase 1 — Quick-Pick Label Pure Module (Part 1)

- [x] [P1-T1] Create `extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts` exporting `truncateLeftAnchored(value, maxLength)`, `formatLastActivityTimestamp(epochMs)`, `RootSessionPickEntry { label; detail; path }`, `buildRootSessionPickEntries(candidates, maxPathLength)`, and the constant `MAX_PATH_LABEL_LENGTH = 60`, per the spec `## API / CLI Surface` signatures. Truncation: unchanged when `value.length <= maxLength`; otherwise `"…" + value.slice(value.length - (maxLength - 1))` (total length == maxLength); `maxLength <= 1` degenerates to the last character or `…`. Timestamp: `yyyy-MM-dd HH:mm` from UTC parts; `undefined` → `unknown`. Ordering: `lastActivityMs` descending, `undefined` last, ties by path ascending. No `vscode` or `node:fs` import; no `Date.now()` call.
  - Acceptance: file exists, exports match the spec signatures, file < 500 lines; `npm run typecheck` passes from `extensions/drm-copilot/`.
- [x] [P1-T2] Create `extensions/drm-copilot/test/lib/subagent-tree/quick-pick-labels.test.ts` with `truncateLeftAnchored` tests: shorter than max (unchanged), exactly max (unchanged), longer than max (ellipsis + tail, total length == max, tail characters equal the real path tail), `maxLength` of 1 and 0 (boundary), empty string.
  - Acceptance: from `extensions/drm-copilot/`, `npm run test` passes including the new suite.
- [x] [P1-T3] Add `formatLastActivityTimestamp` tests to `extensions/drm-copilot/test/lib/subagent-tree/quick-pick-labels.test.ts`: known epoch → exact UTC string, `undefined` → `unknown`, epoch 0 boundary → `1970-01-01 00:00`.
  - Acceptance: from `extensions/drm-copilot/`, `npm run test` passes including the new cases.
- [x] [P1-T4] Add `buildRootSessionPickEntries` tests to `extensions/drm-copilot/test/lib/subagent-tree/quick-pick-labels.test.ts`: most-recent-first ordering, `undefined` mtime sorts last, mtime tie broken by path ascending, label composition (timestamp first then truncated tail), detail equals full path, empty candidate list returns empty array.
  - Acceptance: from `extensions/drm-copilot/`, `npm run test` passes including the new cases.
- [x] [P1-T5] Add a per-file `coverageThreshold` entry (85% lines / 75% branches) for `src/lib/subagent-tree/quick-pick-labels.ts` in `extensions/drm-copilot/jest.config.cjs`.
  - Acceptance: from `extensions/drm-copilot/`, `npm run test:coverage` passes with the new threshold entry enforced.
- [x] [P1-T6] Run the full TS toolchain loop from `extensions/drm-copilot/` — `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:coverage` — restarting from format on any failure or file change, and write `<FEATURE>/evidence/qa-gates/phase1-ts-loop.<TS>.md` with `Timestamp:`, `Command:` (all four commands), `EXIT_CODE:` per command, and `Output Summary:` including the numeric coverage for `quick-pick-labels.ts`.
  - Acceptance: single clean pass of all four steps; artifact exists with numeric per-file coverage for the new module >= 85% lines / >= 75% branches.

### Phase 2 — FileTimes Seam and Command Wiring (Part 1)

- [x] [P2-T1] Add to `extensions/drm-copilot/src/lib/file-system.ts` the interface `FileTimes { getModifiedTimeMs(path: string): number | undefined }` and class `RealFileTimes` implementing it via `fs.statSync(...).mtimeMs` with try/catch returning `undefined` on stat failure. Do not modify the existing `FileSystem` interface or any of its three in-memory fakes.
  - Acceptance: from `extensions/drm-copilot/`, `npm run typecheck` passes; `file-system.ts` remains < 500 lines; `git diff` shows no change to the `FileSystem` interface members.
- [x] [P2-T2] Update `discoverRootSessionCandidates` in `extensions/drm-copilot/src/subagent-tree-command.ts` to accept a `FileTimes` parameter, read each candidate transcript's mtime through it, return `{ path, lastActivityMs }[]`, and remove the current lexicographic sort. Discovery scope (encoded workspace directory plus `-wt-` siblings, `/subagents/` exclusion) is unchanged.
  - Acceptance: from `extensions/drm-copilot/`, `npm run typecheck` passes; the lexicographic `.sort()` on paths is removed.
- [x] [P2-T3] Update `selectRootSession` in `extensions/drm-copilot/src/subagent-tree-command.ts` to build entries via `buildRootSessionPickEntries(candidates, MAX_PATH_LABEL_LENGTH)` and show them with `showQuickPick(entries, { matchOnDetail: true, ... })`, returning the selected entry's `path`; add an optional `createFileTimes?: () => FileTimes` seam on `registerSubagentTreeCommand` mirroring the existing `createFileSystem` seam, defaulting to `RealFileTimes`. Single-candidate bypass behavior is unchanged.
  - Acceptance: from `extensions/drm-copilot/`, `npm run typecheck` passes; `subagent-tree-command.ts` remains < 500 lines.
- [x] [P2-T4] Extend `extensions/drm-copilot/test/subagent-tree-command.test.ts` with a fake `FileTimes`: multi-candidate flow shows entries ordered most-recent-first with formatted labels, selection maps back to the full path, single candidate still auto-selects without a prompt, stat failure on one candidate (`undefined` mtime) does not break the prompt and sorts last with timestamp `unknown`.
  - Acceptance: from `extensions/drm-copilot/`, `npm run test` passes including the four new scenarios.
- [x] [P2-T5] Run the full TS toolchain loop from `extensions/drm-copilot/` (format → lint → typecheck → `npm run test:coverage`), restarting on any failure or file change, and write `<FEATURE>/evidence/qa-gates/phase2-ts-loop.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` per command, and `Output Summary:` with the numeric coverage headline.
  - Acceptance: single clean pass; artifact exists with numeric coverage values.

### Phase 3 — Session Transcript Resolver (Part 2, host-neutral lib)

- [x] [P3-T1] Create `extensions/drm-copilot/src/lib/subagent-tree/session-transcript-resolver.ts` exporting `resolveSessionTranscriptPath(sessionId, workspaceRoot, claudeProjectsRoot, fileSystem)`. Validate `sessionId` against `^[0-9A-Za-z-]{8,64}$` before any filesystem access (malformed id → specific validation error naming the rule; no filesystem call). Resolution: `encodeWorkspacePath(workspaceRoot)` → `matchEncodedDirectories(fileSystem.listDirectory(claudeProjectsRoot))` (exact match plus `-wt-` siblings, case-insensitive) → first matching directory where `fileSystem.isFile(<dir>/<sessionId>.jsonl)` wins deterministically; not-found → specific error naming the searched directories. No `vscode` or `node:fs` import.
  - Acceptance: file exists, < 500 lines; from `extensions/drm-copilot/`, `npm run typecheck` passes; `grep` finds no `vscode`/`node:fs` import in the file.
- [x] [P3-T2] Create `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts` with validation tests: rejects path separators (`/`, `\`), rejects `..`-bearing ids, rejects empty string, rejects over-length (> 64 chars), rejects out-of-charset characters, and asserts no filesystem method is invoked on a mock/fake `FileSystem` for any malformed id (path-traversal rejection proof).
  - Acceptance: from `extensions/drm-copilot/`, `npm run test` passes including the validation suite with the no-filesystem-access assertion.
- [x] [P3-T3] Add resolution tests to `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts` using an in-memory `FileSystem`: resolves in the exact-match encoded directory, resolves in a `-wt-` sibling directory, case-insensitive directory matching, multiple matching directories → first hit wins deterministically, valid-but-unknown id → error naming the searched directories.
  - Acceptance: from `extensions/drm-copilot/`, `npm run test` passes including the five resolution scenarios.
- [x] [P3-T4] Add a per-file `coverageThreshold` entry (85% lines / 75% branches) for `src/lib/subagent-tree/session-transcript-resolver.ts` in `extensions/drm-copilot/jest.config.cjs`.
  - Acceptance: from `extensions/drm-copilot/`, `npm run test:coverage` passes with the new threshold entry enforced.
- [x] [P3-T5] Run the full TS toolchain loop from `extensions/drm-copilot/` (format → lint → typecheck → `npm run test:coverage`), restarting on any failure or file change, and write `<FEATURE>/evidence/qa-gates/phase3-ts-loop.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` per command, and `Output Summary:` with the numeric coverage for the resolver module.
  - Acceptance: single clean pass; artifact exists with numeric per-file coverage >= 85% lines / >= 75% branches for the resolver.

### Phase 4 — MCP Tool Plumbing (`render_subagent_tree`)

- [x] [P4-T1] Append `"render_subagent_tree"` to `REPO_AUTOMATION_TOOLS` in `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
  - Acceptance: the union type includes the new name; `npm run typecheck` is expected to fail until P4-T6 adds the dispatch case (exhaustive switch) — record this expected intermediate state; do not run the full loop until P4-T6.
- [x] [P4-T2] Add the `render_subagent_tree` `ToolDefinition` to `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`: properties `workspace_root` (shared `workspaceRootProperty`, optional) and `session_id` (string, description naming the transcript-stem semantics), `required: ["session_id"]`, `additionalProperties: false`; the tool `description` explicitly states the search scope (encoded workspace directory plus `-wt-` worktree siblings, case-insensitive).
  - Acceptance: definition present with `additionalProperties: false` and required `session_id`; file remains < 500 lines.
- [x] [P4-T3] Create `extensions/drm-copilot/src/mcp-tool-inputs-subagent-tree.ts` exporting `RenderSubagentTreeToolInput { workspaceRoot; sessionId }` and its resolver, reusing `asToolArgumentObject`/`normalizeRequiredText`/`normalizeWorkspaceRoot` from `mcp-tool-inputs.ts`. Do not add lines to `mcp-tool-inputs.ts` (483 lines; split precedent `mcp-tool-inputs-push-down.ts`).
  - Acceptance: new file exists, < 500 lines; `mcp-tool-inputs.ts` line count unchanged.
- [x] [P4-T4] Update `extensions/drm-copilot/src/repo-automation-service.ts`: add `readonly renderedTree?: string` to `RepoAutomationExecutionResult`; add interface method and implementation `renderSubagentTree(input)` (~12 lines) that resolves `getClaudeProjectsRoot(process.env)`, calls `resolveSessionTranscriptPath`, then returns `formatTree(buildSubagentTree(path, { fileSystem: this.fileSystem }))` with summary `Rendered subagent tree for session <id> (<transcript path>).`; validation/not-found errors surface through the existing `toFailureToolResult` path.
  - Acceptance: from `extensions/drm-copilot/`, `wc -l`-equivalent check confirms `repo-automation-service.ts` <= 500 lines (research projects ~490).
- [x] [P4-T5] Create `extensions/drm-copilot/src/mcp-handlers/render-subagent-tree-handler.ts` as a thin handler: resolve input via the P4-T3 resolver, call `service.renderSubagentTree`, matching the existing handler pattern.
  - Acceptance: file exists, < 500 lines, delegates to exactly one service method.
- [x] [P4-T6] Update `extensions/drm-copilot/src/mcp-tools.ts`: add `readonly rendered_tree?: string` to `RepoAutomationMcpToolResult`, map `renderedTree` → `rendered_tree` in `toMcpToolResult` (same pattern as `assetId`/`asset_id`), and add the `render_subagent_tree` dispatch `case` in `dispatchRepoAutomationTool`.
  - Acceptance: from `extensions/drm-copilot/`, `npm run typecheck` passes (exhaustive switch satisfied); `mcp-tools.ts` remains < 500 lines.
- [x] [P4-T7] Create `extensions/drm-copilot/test/repo-automation-render-subagent-tree.test.ts` covering service + dispatch with an in-memory `FileSystem` fixture (small root transcript plus one subagent): valid id → `ok: true` with `rendered_tree` equal to `formatTree(buildSubagentTree(...))` and summary naming the session id and transcript path; unknown id → `ok: false` with summary naming the searched directories; malformed id → `ok: false` naming the validation rule with no filesystem access; dispatch case reachable via `dispatchRepoAutomationTool`.
  - Acceptance: from `extensions/drm-copilot/`, `npm run test` passes including the four scenarios.
- [x] [P4-T8] Add input-resolver tests (missing `session_id` → error; invalid charset → error; `workspace_root` fallback behavior) to `extensions/drm-copilot/test/repo-automation-render-subagent-tree.test.ts` (or a dedicated `test/mcp-tool-inputs-subagent-tree.test.ts` mirroring `src/`), and extend `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` to assert the `render_subagent_tree` definition (required `session_id`, optional `workspace_root`, `additionalProperties: false`).
  - Acceptance: from `extensions/drm-copilot/`, `npm run test` passes including the new assertions.
- [x] [P4-T9] Add per-file `coverageThreshold` entries (85% lines / 75% branches) in `extensions/drm-copilot/jest.config.cjs` for `src/mcp-tool-inputs-subagent-tree.ts` and `src/mcp-handlers/render-subagent-tree-handler.ts`.
  - Acceptance: from `extensions/drm-copilot/`, `npm run test:coverage` passes with the new threshold entries enforced.
- [x] [P4-T10] Run the full TS toolchain loop from `extensions/drm-copilot/` (format → lint → typecheck → `npm run test:coverage`), restarting on any failure or file change, and write `<FEATURE>/evidence/qa-gates/phase4-ts-loop.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` per command, and `Output Summary:` with numeric coverage for all Phase 3–4 new production files.
  - Acceptance: single clean pass; artifact exists with numeric per-file coverage >= 85% lines / >= 75% branches for each new production file.

### Phase 5 — Bundle Rebuild and Tool Advertisement Verification

- [x] [P5-T1] Rebuild the extension and MCP server bundles: from `extensions/drm-copilot/`, run `npm run build` (tsc + `esbuild-extension.cjs` + `esbuild-mcp-server.cjs`); verify via `git status`/`git diff` that no esbuild config file (`esbuild-extension.cjs`, `esbuild-mcp-server.cjs`) required modification. Write `<FEATURE>/evidence/qa-gates/bundle-extension.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (including the no-esbuild-change confirmation).
  - Acceptance: `EXIT_CODE: 0`; artifact records that no esbuild config was modified.
- [x] [P5-T2] Rebuild the standalone MCP server package: from `packages/mcp-server/`, run `npm run build` and write `<FEATURE>/evidence/qa-gates/bundle-mcp-server.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0`; artifact exists with all four fields.
- [x] [P5-T3] Verify the new tool is advertised: add or extend a Jest assertion that `listRepoAutomationTools()` (from `extensions/drm-copilot/src/mcp-tools.ts`) returns a definition named `render_subagent_tree` with required `session_id`, run `npm run test` from `extensions/drm-copilot/`, and write `<FEATURE>/evidence/qa-gates/tool-advertised.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (assertion location and result).
  - Acceptance: assertion exists and passes; artifact records the passing run.

### Phase 6 — SessionStart Hook (PowerShell)

- [x] [P6-T1] Create `.claude/hooks/persist-session-id.ps1`: read hook JSON from stdin with fallback to `$env:CLAUDE_HOOK_INPUT` (SubagentStop-hook precedent); extract `session_id`; when `$env:CLAUDE_ENV_FILE` is set, append the line `CLAUDE_SESSION_ID=<id>` to that file; when unset, write the id to `.claude/state/current-session-id`; on malformed or empty input, perform no write; always exit 0. PowerShell 7+, `CmdletBinding()`, < 500 lines, no `Invoke-Expression`.
  - Acceptance: file exists; manual trace confirms all three branches (env-file append, state-file fallback, no-write) terminate with exit code 0.
- [x] [P6-T2] Create `tests/scripts/claude-hooks/persist-session-id.Tests.ps1` (Pester v5, mirroring the batch-budget hook test structure): stdin/`CLAUDE_HOOK_INPUT` JSON with `session_id` and `CLAUDE_ENV_FILE` set → `CLAUDE_SESSION_ID=<id>` line appended; `CLAUDE_ENV_FILE` unset → `.claude/state/current-session-id` written with the id; malformed JSON → exit 0 and no write; empty input → exit 0 and no write. No temporary files; no network; deterministic.
  - Acceptance: `mcp__drm-copilot__run_poshqc_test` passes including the new suite.
- [x] [P6-T3] Run `mcp__drm-copilot__run_poshqc_format` and write `<FEATURE>/evidence/qa-gates/phase6-ps-format.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If files changed, restart the PowerShell loop from format.
  - Acceptance: clean pass recorded in the artifact.
- [x] [P6-T4] Run `mcp__drm-copilot__run_poshqc_analyze` and write `<FEATURE>/evidence/qa-gates/phase6-ps-analyze.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (zero errors). If findings require edits, fix and restart the PowerShell loop from format.
  - Acceptance: zero analyzer errors recorded in the artifact.
- [x] [P6-T5] Run `mcp__drm-copilot__run_poshqc_test` and write `<FEATURE>/evidence/qa-gates/phase6-ps-test.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric pass counts and the numeric coverage headline for the new hook (>= 85% lines / >= 75% branches).
  - Acceptance: all Pester tests pass; artifact contains numeric coverage values meeting thresholds.

### Phase 7 — Skills and Settings Wiring

- [x] [P7-T1] Create `.claude/skills/identify-session-id/SKILL.md` with repo-precedent frontmatter (`name`, `description`, `allowed-tools` listing Bash/Read; no `context:`/`agent:` keys) documenting the ordered resolution chain: (1) read `CLAUDE_SESSION_ID` from the environment (one pwsh/Bash command), (2) read `.claude/state/current-session-id`, (3) newest-mtime root `*.jsonl` filename stem under `~/.claude/projects/<encodeWorkspacePath(cwd)>/`; the skill must instruct reporting which source was used.
  - Acceptance: file exists with valid frontmatter and all three ordered fallbacks plus the source-reporting instruction.
- [x] [P7-T2] Create `.claude/skills/show-my-agent-tree/SKILL.md` with repo-precedent frontmatter (`allowed-tools` listing `mcp__drm-copilot__render_subagent_tree` plus Bash/Read) defining the flow: (1) resolve the session id via `identify-session-id`, (2) call `mcp__drm-copilot__render_subagent_tree` with `session_id` and an explicit `workspace_root`, (3) print `rendered_tree` in the assistant reply as a fenced code block (works under `/btw`; no VS Code host API).
  - Acceptance: file exists with valid frontmatter and the three-step flow including the fenced-code-block output instruction.
- [x] [P7-T3] Update `.claude/settings.json`: add the SessionStart hook entry invoking `.claude/hooks/persist-session-id.ps1`, and add allow-list entries `mcp__drm-copilot__render_subagent_tree`, `Skill(identify-session-id *)`, `Skill(show-my-agent-tree *)`.
  - Acceptance: `.claude/settings.json` parses as valid JSON and contains the hook entry and all three allow-list additions.

### Phase 8 — Final QA Loop (Full Toolchain, Both Languages)

- [x] [P8-T1] Run TypeScript final-QA formatting: from `extensions/drm-copilot/`, run `npm run format` then `git status --porcelain` to confirm no file changed; write `<FEATURE>/evidence/qa-gates/final-ts-format.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If any file changed, restart the TS loop from format after re-running subsequent steps.
  - Acceptance: artifact records a no-change clean pass.
- [x] [P8-T2] Run TypeScript final-QA lint: from `extensions/drm-copilot/`, run `npm run lint`; write `<FEATURE>/evidence/qa-gates/final-ts-lint.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. On failure, fix and restart the TS loop from format.
  - Acceptance: `EXIT_CODE: 0` recorded.
- [x] [P8-T3] Run TypeScript final-QA type check: from `extensions/drm-copilot/`, run `npm run typecheck`; write `<FEATURE>/evidence/qa-gates/final-ts-typecheck.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. On failure, fix and restart the TS loop from format.
  - Acceptance: `EXIT_CODE: 0` recorded.
- [x] [P8-T4] Run TypeScript final-QA tests with coverage: from `extensions/drm-copilot/`, run `npm run test:coverage`; write `<FEATURE>/evidence/qa-gates/final-ts-jest-coverage.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric overall line/branch coverage plus numeric per-file coverage for every new production file. On failure, fix and restart the TS loop from format.
  - Acceptance: all suites pass; artifact contains numeric overall and per-new-file coverage values, each new file >= 85% lines / >= 75% branches.
- [x] [P8-T5] Run PowerShell final-QA formatting via `mcp__drm-copilot__run_poshqc_format`; write `<FEATURE>/evidence/qa-gates/final-ps-format.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If files changed, restart the PowerShell loop from format.
  - Acceptance: artifact records a no-change clean pass.
- [x] [P8-T6] Run PowerShell final-QA analysis via `mcp__drm-copilot__run_poshqc_analyze`; write `<FEATURE>/evidence/qa-gates/final-ps-analyze.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (zero errors). On failure, fix and restart the PowerShell loop from format.
  - Acceptance: zero analyzer errors recorded.
- [x] [P8-T7] Run PowerShell final-QA tests via `mcp__drm-copilot__run_poshqc_test`; write `<FEATURE>/evidence/qa-gates/final-ps-test.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric pass counts and numeric coverage. On failure, fix and restart the PowerShell loop from format.
  - Acceptance: all Pester tests pass; artifact contains numeric coverage values.
- [x] [P8-T8] Write the coverage delta verification artifact `<FEATURE>/evidence/qa-gates/coverage-delta.<TS>.md` comparing P0-T5/P0-T7 baselines against P8-T4/P8-T7 results: report baseline coverage, post-change coverage, and new-code (per-new-file) coverage for both languages; confirm no regression on changed lines and every new production file meets 85/75.
  - Acceptance: artifact contains all three numeric coverage sets (baseline, post-change, new-code) with an explicit pass/fail verdict per threshold; a missing numeric value forces a remediation-required verdict, never PASS.
- [x] [P8-T9] Verify the 500-line limit for every touched production and test file (at minimum: `quick-pick-labels.ts`, `file-system.ts`, `subagent-tree-command.ts`, `session-transcript-resolver.ts`, `repo-automation-tool-names.ts`, `mcp-repo-automation-tool-definitions.ts`, `mcp-tool-inputs-subagent-tree.ts`, `repo-automation-service.ts`, `render-subagent-tree-handler.ts`, `mcp-tools.ts`, `persist-session-id.ps1`, all new/extended test files) and record the per-file line counts in `<FEATURE>/evidence/qa-gates/file-size-check.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: every listed file <= 500 lines; counts recorded in the artifact.
- [x] [P8-T10] Verify host-neutrality of new lib modules: grep `extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts` and `session-transcript-resolver.ts` for `vscode` and `node:fs` imports (expect none; `RealFileTimes` in `file-system.ts` is the sanctioned exception) and record the search commands and results in `<FEATURE>/evidence/qa-gates/host-neutrality-check.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: zero matches in both new lib modules, recorded in the artifact.
- [x] [P8-T11] Verify no new runtime dependency: run `git diff main -- extensions/drm-copilot/package.json packages/mcp-server/package.json` and confirm the `dependencies` blocks are unchanged (only `@modelcontextprotocol/sdk` present); record in `<FEATURE>/evidence/qa-gates/dependency-check.<TS>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
  - Acceptance: `dependencies` unchanged in both manifests, recorded in the artifact.

### Phase 9 — Acceptance-Criteria Check-Off

- [x] [P9-T1] Verify spec Acceptance Criteria 1–3 (quick-pick label format/ordering/selection parity) against the Phase 1–2 test evidence and record the AC→test/evidence mapping in `<FEATURE>/evidence/qa-gates/acceptance-criteria.<TS>.md` (section `Part 1`), citing test names in `quick-pick-labels.test.ts` and `subagent-tree-command.test.ts`.
  - Acceptance: each of AC 1–3 mapped to at least one passing named test; verdict recorded per AC.
- [x] [P9-T2] Verify spec Acceptance Criteria 4–6 (tool advertisement/valid-id success, malformed/unknown-id failure with no filesystem access, resolver search scope and description) against Phase 3–5 evidence and append the mapping to `<FEATURE>/evidence/qa-gates/acceptance-criteria.<TS>.md` (section `Part 2 — MCP`), citing test names and the P5-T3 artifact.
  - Acceptance: each of AC 4–6 mapped to passing named tests/artifacts; verdict recorded per AC.
- [x] [P9-T3] Verify spec Acceptance Criteria 7–9 (hook persistence behavior and exit code, `identify-session-id` fallbacks and source reporting, `show-my-agent-tree` flow and settings wiring) against Phase 6–7 evidence and append the mapping to `<FEATURE>/evidence/qa-gates/acceptance-criteria.<TS>.md` (section `Hook and Skills`), citing the Pester test names, both SKILL.md files, and the `.claude/settings.json` diff.
  - Acceptance: each of AC 7–9 mapped to concrete files/tests; verdict recorded per AC.
- [x] [P9-T4] Verify spec Acceptance Criteria 10–12 (toolchain + per-file coverage thresholds, file sizes + no new dependencies, host-neutrality + no esbuild change) against the Phase 8 artifacts and append the mapping to `<FEATURE>/evidence/qa-gates/acceptance-criteria.<TS>.md` (section `Quality Gates`), citing `final-ts-*`, `final-ps-*`, `coverage-delta`, `file-size-check`, `host-neutrality-check`, `dependency-check`, and `bundle-*` artifacts. Note AC 13 (feature-review clean of blocking findings) as pending the downstream feature-review stage — it is verified by that stage, not by this plan.
  - Acceptance: each of AC 10–12 mapped to concrete evidence artifacts with per-AC verdicts; AC 13 explicitly marked as delegated to feature-review.
- [x] [P9-T5] Update the checkbox states in `<FEATURE>/spec.md` `## Acceptance Criteria` and `## Definition of Done` to reflect verified items (leaving AC 13/feature-review-dependent boxes unchecked), and record the update in `<FEATURE>/evidence/qa-gates/acceptance-criteria.<TS>.md`.
  - Acceptance: spec checkboxes match the verdicts in the acceptance-criteria artifact; no box is checked without cited evidence.

## Test Plan

- Unit (Jest, `extensions/drm-copilot/`): `test/lib/subagent-tree/quick-pick-labels.test.ts` (new), `test/lib/subagent-tree/session-transcript-resolver.test.ts` (new), `test/repo-automation-render-subagent-tree.test.ts` (new), `test/subagent-tree-command.test.ts` (extended), `test/mcp-repo-automation-tool-definitions.test.ts` (extended). Scenario lists per spec `## Test Conditions`.
- Unit (Pester): `tests/scripts/claude-hooks/persist-session-id.Tests.ps1` (new).
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/ts-jest-coverage.<TS>.md` and `ps-pester-coverage.<TS>.md`; post-change `<FEATURE>/evidence/qa-gates/final-ts-jest-coverage.<TS>.md` and `final-ps-test.<TS>.md`; comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<TS>.md`.
- Integration/manual: none required — the MCP dispatch path is covered by Jest via `dispatchRepoAutomationTool`; bundle integrity is covered by P5-T1/P5-T2/P5-T3.

## Open Questions / Notes

- `repo-automation-service.ts` is at 477 lines; P4-T4 adds ~12. If any restart iteration pushes it past 500, extract the method into a support module per the existing `repo-automation-service-support.ts` precedent before completing P8-T9.
- The exact `CLAUDE_ENV_FILE` line format should be sanity-checked against the running CLI during P6-T1 (research §Open Risks #2); the state-file fallback covers absence.
- Jest/`test/`-tree usage is an intentional, recorded deviation from `.claude/rules/typescript.md` (Vitest/`tests/`), following the extension's wired toolchain (research §Open Risks #3).

# subagent-tree-command - Plan

- **Issue:** none
- **Parent (optional):** none
- **Owner:** TBD
- **Last Updated:** 2026-07-05T18-28
- **Status:** Complete
- **Version:** 0.2

## Required References

- General Code Change Policy: [`.claude/rules/general-code-change.md`](../../../../.claude/rules/general-code-change.md)
- General Unit Test Policy: [`.claude/rules/general-unit-test.md`](../../../../.claude/rules/general-unit-test.md)
- TypeScript Code Standards: [`.claude/rules/typescript.md`](../../../../.claude/rules/typescript.md)
- TypeScript Suppression Policy: [`.claude/rules/typescript-suppressions.md`](../../../../.claude/rules/typescript-suppressions.md)
- Architecture Boundaries: [`.claude/rules/architecture-boundaries.md`](../../../../.claude/rules/architecture-boundaries.md)
- Module Rigor Tiers: [`.claude/rules/quality-tiers.md`](../../../../.claude/rules/quality-tiers.md)

**All work must comply with these policies; do not duplicate their content here.**

**Acceptance criteria source:** `docs/features/active/subagent-tree-command/issue.md`, section `## Acceptance Criteria` (AC1–AC5). This plan does not depend on `spec.md` or `user-story.md`; neither exists for this feature and neither is required.

**Toolchain note:** the `drm-copilot` extension's configured test runner is **Jest with v8 coverage** (`jest.config.cjs`, `npm run test`, `npm run test:coverage`), not Vitest. All test tasks below use Jest (`*.test.ts` under `test/`, mirroring `src/`) per the extension's established convention, overriding the generic Vitest guidance in `.claude/rules/typescript.md` for this specific package.

## Design Decisions (binding for implementation tasks)

1. **Reuse the existing `FileSystem` seam.** `extensions/drm-copilot/src/lib/file-system.ts` already defines a host-neutral `FileSystem` interface (`glob`, `isFile`, `exists`, `isDirectory`, `listDirectory`, `readTextFile`, `writeTextFile`, `ensureDir`) and a `RealFileSystem` implementation. The subagent-tree module injects this existing interface rather than defining a new one, per the repo's reusability principle. No new filesystem interface is created.
2. **Module layout under `src/lib/subagent-tree/`:**
   - `types.ts` — `TreeNode`, `SubagentMeta`, `ScannedTranscript`, `ScannedSession` (no I/O, no VS Code imports).
   - `transcript-parser.ts` — `parseTranscriptLines(lines: readonly string[]): { models: readonly string[]; agentToolUseIds: readonly string[] }`, pure, no I/O.
   - `transcript-scanner.ts` — `scanTranscripts(rootSessionPath: string, fileSystem: FileSystem): ScannedSession`, the only file in the module that touches `FileSystem`.
   - `tree-assembler.ts` — `assembleTree(scanned: ScannedSession): TreeNode`, pure, no I/O (parent/child matching, sibling ordering, orphan handling).
   - `tree-formatter.ts` — `formatTree(node: TreeNode): string`, pure renderer.
   - `index.ts` — barrel exporting `buildSubagentTree(rootSessionPath, deps: { fileSystem: FileSystem }): TreeNode` (composes `scanTranscripts` + `assembleTree`), `formatTree`, and the `TreeNode` type.
3. **`spawnDepth` is read verbatim from each subagent's `meta.json`** as the node's `depth` field; the algorithm never recomputes depth from recursion, matching the "port exactly, no heuristics" requirement. The root node's `depth` is `0`.
4. **Orphan handling (deterministic, non-crashing):** a subagent whose `meta.toolUseId` matches no `Agent` tool-use id in the root transcript or in any other scanned subagent transcript is an *orphan*. Orphans are attached as additional children of the root node, appended **after** the root's normally-matched children, ordered by ascending `agentId` (the meta filename's `agent-<agentId>` segment) for determinism. An orphan's own descendants (if its `toolUseId` matched some other transcript that in turn spawned children of it) are still assembled normally under it.
5. **Sibling ordering:** children of a given parent are ordered by the index (`indexOf`) of their spawning `toolUseId` within the parent's ordered `agentToolUseIds` list, ascending. Ties (which should not occur, since tool-use ids are unique per Agent invocation) are broken by ascending `agentId` string comparison.
6. **Render format:** `formatTree` renders each node as one line: `${"  ".repeat(node.depth)}${node.agentType} · [${node.models.join(",")}] · ${node.depth} · ${node.description}`, followed by each child's rendered lines, in child order. Indentation is two spaces per `depth` unit. `node.models` is always sorted ascending before joining, so a node with more than one distinct model prints all of them, comma-joined, deterministically ordered.
7. **Root-session path convention:** given `rootSessionPath` ending in `.jsonl`, the sibling `subagents` directory is `` `${rootSessionPath without the trailing ".jsonl"}/subagents` ``. `scanTranscripts` throws a explicit, fail-fast `Error` if `rootSessionPath` does not end in `.jsonl` (invariant violation caught at the I/O boundary, not silently ignored).
8. **Command host wiring** (`src/subagent-tree-command.ts`) discovers candidate root sessions by globbing `.claude/projects/**/*.jsonl` under the workspace root via `RealFileSystem`, excluding any path containing a `/subagents/` segment (those are flattened subagent transcripts, not root sessions). When exactly one candidate remains, it is used directly as the active session (no prompt). When more than one remains, `vscode.window.showQuickPick` lets the user choose. When none remain, the command reports an error via the output channel and `vscode.window.showErrorMessage` without throwing an unhandled rejection.
9. **No new dependencies.** `fast-check` is not installed and is not added; the module is T3/T4 dev tooling, so property-based tests are not required by tier rules. Standard Jest unit tests satisfy the coverage gate.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance, Baseline & Toolchain Capture

- [x] [P0-T1] Read `.claude/rules/general-code-change.md` in full before touching code
  - Acceptance: file read confirmed; listed in `docs/features/active/subagent-tree-command/evidence/baseline/phase0-instructions-read.md`
- [x] [P0-T2] Read `.claude/rules/general-unit-test.md` in full before touching code
  - Acceptance: listed in `docs/features/active/subagent-tree-command/evidence/baseline/phase0-instructions-read.md`
- [x] [P0-T3] Read `.claude/rules/typescript.md` in full before touching code
  - Acceptance: listed in `docs/features/active/subagent-tree-command/evidence/baseline/phase0-instructions-read.md`
- [x] [P0-T4] Read `.claude/rules/typescript-suppressions.md` in full before touching code
  - Acceptance: listed in `docs/features/active/subagent-tree-command/evidence/baseline/phase0-instructions-read.md`
- [x] [P0-T5] Read `.claude/rules/architecture-boundaries.md` in full before touching code
  - Acceptance: listed in `docs/features/active/subagent-tree-command/evidence/baseline/phase0-instructions-read.md`
- [x] [P0-T6] Read `.claude/rules/quality-tiers.md` in full before touching code
  - Acceptance: listed in `docs/features/active/subagent-tree-command/evidence/baseline/phase0-instructions-read.md`
- [x] [P0-T7] Write `docs/features/active/subagent-tree-command/evidence/baseline/phase0-instructions-read.md` recording `Timestamp:`, `Policy Order:` (the six files above in read order), and the explicit file list
  - Acceptance: artifact exists with all three required fields populated (no placeholder text)
- [x] [P0-T8] Capture a non-mutating baseline format check by running `npx prettier --check "src/**/*.ts" "test/**/*.ts"` from `extensions/drm-copilot/` and writing the result to `docs/features/active/subagent-tree-command/evidence/baseline/baseline-format.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the real exit code and a concise pass/fail summary
- [x] [P0-T9] Capture baseline lint results by running `npm run lint` from `extensions/drm-copilot/` and writing the result to `docs/features/active/subagent-tree-command/evidence/baseline/baseline-lint.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the real exit code and error/warning counts
- [x] [P0-T10] Capture baseline type-check results by running `npm run typecheck` from `extensions/drm-copilot/` and writing the result to `docs/features/active/subagent-tree-command/evidence/baseline/baseline-typecheck.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the real exit code
- [x] [P0-T11] Capture baseline coverage by running `npm run test:coverage` from `extensions/drm-copilot/` and writing the result to `docs/features/active/subagent-tree-command/evidence/baseline/baseline-test-coverage.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the numeric pass/fail test count and the aggregate line/branch coverage percentages reported by the run

### Phase 1 — Pure Types & Transcript Line Parser

- [x] [P1-T1] Create `extensions/drm-copilot/src/lib/subagent-tree/types.ts` defining `TreeNode`, `SubagentMeta`, `ScannedTranscript`, and `ScannedSession` interfaces with no VS Code imports and no `any`
  - Acceptance: `npx tsc -p extensions/drm-copilot --noEmit` reports zero errors for this file; file is under 500 lines
- [x] [P1-T2] Create `extensions/drm-copilot/src/lib/subagent-tree/transcript-parser.ts` implementing `parseTranscriptLines(lines: readonly string[]): { models: readonly string[]; agentToolUseIds: readonly string[] }` per Design Decision items 3 and 6 and the issue's algorithm step 1 (skip blank lines; ignore lines whose `message` is not an object; collect the model only when `message.model` is truthy; collect `Agent` tool-use ids from assistant `message.content[]` blocks in file line order)
  - Acceptance: file compiles with no `any`; exports exactly `parseTranscriptLines`; file is under 500 lines
- [x] [P1-T3] Create `extensions/drm-copilot/test/lib/subagent-tree/transcript-parser.test.ts` with a positive-scenario test: a transcript with three lines containing two distinct `Agent` tool-use blocks and one `message.model` value produces the tool-use ids in file line order and a one-element models array
  - Acceptance: `npx jest test/lib/subagent-tree/transcript-parser.test.ts` (run from `extensions/drm-copilot/`) passes
- [x] [P1-T4] Add a multi-model scenario test to `extensions/drm-copilot/test/lib/subagent-tree/transcript-parser.test.ts`: a transcript whose turns carry two different truthy `message.model` values produces both values in the returned `models` array
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/transcript-parser.test.ts`
- [x] [P1-T5] Add a blank/malformed-line scenario test to `extensions/drm-copilot/test/lib/subagent-tree/transcript-parser.test.ts`: input lines include a blank line, a non-JSON line, and a line whose `message` field is a string rather than an object; all three are ignored without throwing and do not appear in the output
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/transcript-parser.test.ts`
- [x] [P1-T6] Add a tool-use ordering scenario test to `extensions/drm-copilot/test/lib/subagent-tree/transcript-parser.test.ts`: two `Agent` tool-use ids whose alphabetical order differs from their file line order are returned in file line order
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/transcript-parser.test.ts`

### Phase 2 — Filesystem-Backed Transcript Scanner

- [x] [P2-T1] Create `extensions/drm-copilot/src/lib/subagent-tree/transcript-scanner.ts` implementing `scanTranscripts(rootSessionPath: string, fileSystem: FileSystem): ScannedSession` per Design Decision items 2 and 7: derive the sibling `subagents` directory, glob `agent-*.meta.json` via `fileSystem.glob`, read each meta JSON and its sibling `.jsonl`, and delegate line parsing to `parseTranscriptLines`; import `FileSystem` from `../file-system`
  - Acceptance: file imports only `../file-system` and `./transcript-parser` (plus `./types`); zero `vscode` imports (verified by `grep -n "vscode" extensions/drm-copilot/src/lib/subagent-tree/transcript-scanner.ts` returning no matches); file is under 500 lines
- [x] [P2-T2] Create `extensions/drm-copilot/test/lib/subagent-tree/in-memory-file-system.ts` implementing the `FileSystem` interface backed by in-memory `Map`s (no temp files, no real disk access), following the existing `test/lib/pr-context/tree-file-system.ts` pattern
  - Acceptance: file compiles and satisfies the `FileSystem` interface with no `any`
- [x] [P2-T3] Create `extensions/drm-copilot/test/lib/subagent-tree/transcript-scanner.test.ts` with a positive multi-agent scenario: an in-memory `FileSystem` seeded with a root `.jsonl`, a `subagents` directory containing two `agent-*.jsonl` + `agent-*.meta.json` pairs, asserting `scanTranscripts(...).subagents.length === 2` and that each entry's `meta` fields match the seeded JSON
  - Acceptance: `npx jest test/lib/subagent-tree/transcript-scanner.test.ts` passes
- [x] [P2-T4] Add an empty-subagents scenario test to `extensions/drm-copilot/test/lib/subagent-tree/transcript-scanner.test.ts`: the `subagents` directory does not exist in the fake filesystem; `scanTranscripts` returns `subagents: []` without throwing
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/transcript-scanner.test.ts`
- [x] [P2-T5] Add a multi-depth-nesting scan scenario test to `extensions/drm-copilot/test/lib/subagent-tree/transcript-scanner.test.ts`: a subagent transcript itself contains an `Agent` tool-use whose id is referenced by a second subagent's `meta.toolUseId` (a grandchild), asserting both subagents are present in `ScannedSession.subagents` with their own parsed `agentToolUseIds`
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/transcript-scanner.test.ts`

### Phase 3 — Tree Assembly Algorithm

- [x] [P3-T1] Create `extensions/drm-copilot/src/lib/subagent-tree/tree-assembler.ts` implementing `assembleTree(scanned: ScannedSession): TreeNode` per Design Decision items 3, 4, and 5 (spawnDepth passthrough, parent/child matching by exact `toolUseId` equality, sibling ordering by spawn-index, orphan attachment under root)
  - Acceptance: file has zero I/O calls and zero `vscode` imports (verified by `grep -n "vscode\|readTextFile\|readFileSync" extensions/drm-copilot/src/lib/subagent-tree/tree-assembler.ts` returning no matches); file is under 500 lines
- [x] [P3-T2] Create `extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts` with a positive multi-agent scenario: a root with two direct subagent children assembles a `TreeNode` whose `children` array has length 2 in the expected order
  - Acceptance: `npx jest test/lib/subagent-tree/tree-assembler.test.ts` passes
- [x] [P3-T3] Add an empty-subagents scenario test to `extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts`: `ScannedSession.subagents` is an empty array; the assembled root `TreeNode.children` is an empty array
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/tree-assembler.test.ts`
- [x] [P3-T4] Add a multi-model-node scenario test to `extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts`: a subagent's `ScannedTranscript.models` contains two distinct values; the assembled node's `models` array contains both, sorted ascending
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/tree-assembler.test.ts`
- [x] [P3-T5] Add a multi-depth-nesting (grandchild) scenario test to `extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts`: a child subagent's own `agentToolUseIds` matches a grandchild's `toolUseId`; the assembled tree places the grandchild inside the child's `children` array, not the root's
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/tree-assembler.test.ts`
- [x] [P3-T6] Add an orphan/unmatched-`toolUseId` scenario test to `extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts`: one subagent's `meta.toolUseId` matches no transcript's `agentToolUseIds`; `assembleTree` does not throw and the orphan appears as a root child after the normally-matched children, per Design Decision item 4
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/tree-assembler.test.ts`
- [x] [P3-T7] Add a sibling-ordering scenario test to `extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts`: two sibling subagents whose `agentId` alphabetical order is the reverse of their spawning tool-use line order in the parent transcript; the assembled `children` array follows line order, not alphabetical order
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/tree-assembler.test.ts`

### Phase 4 — Tree Renderer and Barrel Export

- [x] [P4-T1] Create `extensions/drm-copilot/src/lib/subagent-tree/tree-formatter.ts` implementing `formatTree(node: TreeNode): string` per Design Decision item 6 (two-space indent per `depth`, `agentType · [models] · depth · description` line format, recursive child rendering)
  - Acceptance: file compiles with no `any`; exports exactly `formatTree`; file is under 500 lines
- [x] [P4-T2] Create `extensions/drm-copilot/test/lib/subagent-tree/tree-formatter.test.ts` with a positive scenario: a two-level tree (root + one child) renders two lines with the child indented two spaces relative to the root and both lines matching the exact `agentType · [models] · depth · description` format
  - Acceptance: `npx jest test/lib/subagent-tree/tree-formatter.test.ts` passes
- [x] [P4-T3] Add a multi-model rendering scenario test to `extensions/drm-copilot/test/lib/subagent-tree/tree-formatter.test.ts`: a node with two distinct models renders both, comma-joined and sorted ascending, inside the `[...]` segment
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/tree-formatter.test.ts`
- [x] [P4-T4] Add an empty-subagents rendering scenario test to `extensions/drm-copilot/test/lib/subagent-tree/tree-formatter.test.ts`: a root node with no children renders exactly one line
  - Acceptance: the new test case passes under `npx jest test/lib/subagent-tree/tree-formatter.test.ts`
- [x] [P4-T5] Create `extensions/drm-copilot/src/lib/subagent-tree/index.ts` as a barrel exporting `buildSubagentTree(rootSessionPath: string, deps: { fileSystem: FileSystem }): TreeNode` (composing `scanTranscripts` and `assembleTree`), `formatTree`, and the `TreeNode` type
  - Acceptance: file compiles with no `any`; `npx tsc -p extensions/drm-copilot --noEmit` reports zero errors
- [x] [P4-T6] Create `extensions/drm-copilot/test/lib/subagent-tree/index.test.ts` verifying `buildSubagentTree` composes the scanner and assembler end-to-end against the in-memory `FileSystem` fixture for the positive multi-agent scenario, and that its output round-trips through `formatTree` without throwing
  - Acceptance: `npx jest test/lib/subagent-tree/index.test.ts` passes

### Phase 5 — VS Code Command Wiring & Registration

- [x] [P5-T1] Create `extensions/drm-copilot/src/subagent-tree-command.ts` implementing `registerSubagentTreeCommand(options: { output: vscode.OutputChannel }): vscode.Disposable` per Design Decision item 8: discover `.claude/projects/**/*.jsonl` root-session candidates via `RealFileSystem`, exclude paths containing `/subagents/`, auto-select when exactly one candidate exists, otherwise prompt via `vscode.window.showQuickPick`, then call `buildSubagentTree` and `formatTree` and write the result to the output channel
  - Acceptance: file compiles with no `any`; registers the command id `drmCopilotExtension.showSubagentTree`; file is under 500 lines
- [x] [P5-T2] Update `extensions/drm-copilot/src/extension.ts` to import `registerSubagentTreeCommand` and push its returned disposable into `context.subscriptions` inside `activate`
  - Acceptance: `npx tsc -p extensions/drm-copilot --noEmit` reports zero errors; `registerSubagentTreeCommand` is called exactly once in `activate`
- [x] [P5-T3] Add the command contribution entry `{ "command": "drmCopilotExtension.showSubagentTree", "title": "drm-copilot: Show Subagent Tree" }` to the `contributes.commands` array in `extensions/drm-copilot/package.json`
  - Acceptance: `contributes.commands` in `extensions/drm-copilot/package.json` contains an entry with that exact `command` and `title`
- [x] [P5-T4] Create `extensions/drm-copilot/test/subagent-tree-command.test.ts` following the `test/extension.collect-pr-context.test.ts` mocking pattern (mocked `vscode`, mocked `node:fs`) with a scenario asserting: zero candidate sessions produces an error message via the output channel and does not throw
  - Acceptance: `npx jest test/subagent-tree-command.test.ts` (run from `extensions/drm-copilot/`) passes
- [x] [P5-T5] Add a single-candidate auto-select scenario test to `extensions/drm-copilot/test/subagent-tree-command.test.ts`: exactly one discovered `.jsonl` root session is used directly without invoking `showQuickPick`, and the rendered tree text is written to the output channel
  - Acceptance: the new test case passes under `npx jest test/subagent-tree-command.test.ts`
- [x] [P5-T6] Add a multi-candidate quick-pick scenario test to `extensions/drm-copilot/test/subagent-tree-command.test.ts`: two discovered `.jsonl` root sessions trigger `vscode.window.showQuickPick`, and the session selected by the mock is the one passed to `buildSubagentTree`
  - Acceptance: the new test case passes under `npx jest test/subagent-tree-command.test.ts`

### Phase 6 — Coverage Threshold Configuration

- [x] [P6-T1] Add a `coverageThreshold` entry with `{ lines: 85, branches: 75 }` for `./src/lib/subagent-tree/types.ts` to `extensions/drm-copilot/jest.config.cjs`
  - Acceptance: the entry is present in `jest.config.cjs` with the exact path key and threshold values
- [x] [P6-T2] Add a `coverageThreshold` entry with `{ lines: 85, branches: 75 }` for `./src/lib/subagent-tree/transcript-parser.ts` to `extensions/drm-copilot/jest.config.cjs`
  - Acceptance: the entry is present in `jest.config.cjs` with the exact path key and threshold values
- [x] [P6-T3] Add a `coverageThreshold` entry with `{ lines: 85, branches: 75 }` for `./src/lib/subagent-tree/transcript-scanner.ts` to `extensions/drm-copilot/jest.config.cjs`
  - Acceptance: the entry is present in `jest.config.cjs` with the exact path key and threshold values
- [x] [P6-T4] Add a `coverageThreshold` entry with `{ lines: 85, branches: 75 }` for `./src/lib/subagent-tree/tree-assembler.ts` to `extensions/drm-copilot/jest.config.cjs`
  - Acceptance: the entry is present in `jest.config.cjs` with the exact path key and threshold values
- [x] [P6-T5] Add a `coverageThreshold` entry with `{ lines: 85, branches: 75 }` for `./src/lib/subagent-tree/tree-formatter.ts` to `extensions/drm-copilot/jest.config.cjs`
  - Acceptance: the entry is present in `jest.config.cjs` with the exact path key and threshold values
- [x] [P6-T6] Add a `coverageThreshold` entry with `{ lines: 85, branches: 75 }` for `./src/lib/subagent-tree/index.ts` to `extensions/drm-copilot/jest.config.cjs`
  - Acceptance: the entry is present in `jest.config.cjs` with the exact path key and threshold values
- [x] [P6-T7] Add a `coverageThreshold` entry with `{ lines: 85, branches: 75 }` for `./src/subagent-tree-command.ts` to `extensions/drm-copilot/jest.config.cjs`
  - Acceptance: the entry is present in `jest.config.cjs` with the exact path key and threshold values
- [x] [P6-T8] Verify `extensions/drm-copilot/jest.config.cjs`'s `collectCoverageFrom` array (`["src/**/*.ts", "!src/**/*.d.ts"]`) requires no changes to cover the seven new files and that none of the seven new files appears in any `exclude`-style pattern
  - Acceptance: grep of `jest.config.cjs` for `subagent-tree` shows only the seven `coverageThreshold` entries above (no exclusion pattern)

### Phase 7 — Final QA Loop

- [x] [P7-T1] Run `npm run format` from `extensions/drm-copilot/` and write the result to `docs/features/active/subagent-tree-command/evidence/qa-gates/final-format.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`; if the command modifies any file, the loop restarts from this task
- [x] [P7-T2] Run `npm run lint` from `extensions/drm-copilot/` and write the result to `docs/features/active/subagent-tree-command/evidence/qa-gates/final-lint.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` with zero lint errors reported
- [x] [P7-T3] Run `npm run typecheck` from `extensions/drm-copilot/` and write the result to `docs/features/active/subagent-tree-command/evidence/qa-gates/final-typecheck.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` with zero type errors reported
- [x] [P7-T4] Verify the architecture boundary manually by running `grep -rn "vscode" extensions/drm-copilot/src/lib/subagent-tree/` and writing the result to `docs/features/active/subagent-tree-command/evidence/qa-gates/final-arch-boundary.md`, noting that no `dependency-cruiser` config exists for this extension so this manual grep is the enforcement mechanism for this change
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` confirming zero `vscode` matches inside `src/lib/subagent-tree/`
- [x] [P7-T5] Run `npm run test:coverage` from `extensions/drm-copilot/` and write the full result to `docs/features/active/subagent-tree-command/evidence/qa-gates/final-test-coverage.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` with the aggregate pass/fail test count and the aggregate line/branch coverage percentages
- [x] [P7-T6] Verify each of the seven new production files individually meets or exceeds 85% line / 75% branch coverage from the Phase 7 coverage run, and write the per-file breakdown to `docs/features/active/subagent-tree-command/evidence/qa-gates/final-coverage-per-file.md`
  - Acceptance: artifact lists all seven file paths with their line and branch percentages, each >= 85% line and >= 75% branch, alongside the Phase 0 baseline aggregate percentages from `baseline-test-coverage.md` for comparison
- [x] [P7-T7] Run `npm run build` from `extensions/drm-copilot/` and write the result to `docs/features/active/subagent-tree-command/evidence/qa-gates/final-build.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming `tsc --noEmit`, `bundle:extension`, and `bundle:mcp-server` all completed without error

## Test Plan

- **Unit (Jest, `extensions/drm-copilot/`):**
  - `test/lib/subagent-tree/transcript-parser.test.ts` — positive, multi-model, blank/malformed lines, ordering.
  - `test/lib/subagent-tree/transcript-scanner.test.ts` — positive multi-agent, empty-subagents, multi-depth nesting (scan level).
  - `test/lib/subagent-tree/tree-assembler.test.ts` — positive multi-agent, empty-subagents, multi-model node, multi-depth nesting (grandchild), orphan/unmatched `toolUseId`, sibling ordering.
  - `test/lib/subagent-tree/tree-formatter.test.ts` — positive rendering, multi-model rendering, empty-subagents rendering.
  - `test/lib/subagent-tree/index.test.ts` — end-to-end composition of scanner + assembler + formatter.
  - `test/subagent-tree-command.test.ts` — host wiring: zero candidates, single-candidate auto-select, multi-candidate quick-pick.
- **Integration/Manual:** none required; the command is exercised entirely through the injected `FileSystem` seam in tests. No temp files are created by any test.
- **Coverage evidence:**
  - Baseline artifacts: `docs/features/active/subagent-tree-command/evidence/baseline/baseline-format.md`, `baseline-lint.md`, `baseline-typecheck.md`, `baseline-test-coverage.md`.
  - Final-QC artifacts: `docs/features/active/subagent-tree-command/evidence/qa-gates/final-format.md`, `final-lint.md`, `final-typecheck.md`, `final-arch-boundary.md`, `final-test-coverage.md`, `final-coverage-per-file.md`, `final-build.md`.
  - Per-file comparison: `final-coverage-per-file.md` reports baseline aggregate vs. post-change aggregate vs. new-file coverage for each of the seven new production files.

## Open Questions / Notes

- The orphan-attachment rule (Design Decision item 4) is a deliberate, testable choice among several reasonable options (attach to root vs. list separately vs. drop). If a future requirement needs orphans surfaced differently (e.g., a dedicated "unmatched" section in `formatTree`), that is a follow-on change, not part of this plan.
- `formatTree`'s exact line format (`agentType · [models] · depth · description`, two-space indent per depth) is this plan's chosen rendering; the issue does not mandate a specific indentation character count.
- No `dependency-cruiser` configuration exists for `extensions/drm-copilot/` today; Phase 7's architecture-boundary check is a manual grep rather than an automated tool run. Introducing `dependency-cruiser` for this extension is out of scope for this feature.

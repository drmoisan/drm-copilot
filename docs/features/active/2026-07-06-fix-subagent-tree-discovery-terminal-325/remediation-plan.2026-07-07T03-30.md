# Remediation Atomic Plan: fix-subagent-tree-discovery-terminal (Issue #325)

**Plan Timestamp:** 2026-07-07T03-30
**Scope:** Exactly the two Blocking findings enumerated in
`docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/remediation-inputs.2026-07-07T03-30.md`
— (1) the `command-runtime.ts` file-size violation via extraction of the
`TerminalWriter` seam into a new module, and (2) CRLF normalization of
internal newlines in `PseudoterminalTerminalWriter.write()`. No other change
is in scope. The "Do Not Do" list in the remediation-inputs is binding for
every task below; no acceptance-criteria checkbox in `issue.md` is touched by
this plan.

**Toolchain (from `extensions/drm-copilot/`):** format → lint → typecheck →
test:coverage → build (Jest). Per-file coverage gate: lines >= 85% / branches
>= 75% for touched/new files; no production file may be excluded from
coverage measurement.

**Evidence root:** all evidence artifacts produced by this plan resolve
under `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/<kind>/`,
never under `artifacts/`. Executors must substitute the actual ISO-8601
run timestamp (`yyyy-MM-ddTHH-mm`) wherever `<TIMESTAMP>` appears in a
filename below.

---

### Phase 0 — Policy Read and Minimal Remediation Baseline

Phase 0 is intentionally minimal per the remediation directive: full
toolchain baseline capture (format/lint/typecheck/test:coverage/build) was
already performed and recorded under
`docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/baseline/`
and `.../evidence/qa-gates/` (timestamps `2026-07-07T02-45` and
`2026-07-07T03-15`) prior to this remediation cycle and is not re-run here.
Phase 0 below covers only the policy re-read and the audit-input read
required before editing begins.

- [x] [P0-T1] Read the required policy files in order — `CLAUDE.md`,
  `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
  `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`,
  `.claude/rules/architecture-boundaries.md` — and write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/remediation-baseline/phase0-instructions-read.md`
  containing `Timestamp:`, `Policy Order:`, and the explicit list of the six
  files read, in the order read. Acceptance: the artifact exists and lists
  all six file paths in the stated order.

- [x] [P0-T2] Read the three triggering audit artifacts —
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/policy-audit.2026-07-07T03-30.md`,
  `.../code-review.2026-07-07T03-30.md`,
  `.../feature-audit.2026-07-07T03-30.md` — and the
  `remediation-inputs.2026-07-07T03-30.md` file itself, then write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/remediation-baseline/audit-inputs-read.md`
  containing `Timestamp:` and a one-line confirmation per file read.
  Acceptance: the artifact lists all four file paths with a confirmation
  line for each.

- [x] [P0-T3] Capture the pre-fix line count of
  `extensions/drm-copilot/src/command-runtime.ts` by running
  `wc -l extensions/drm-copilot/src/command-runtime.ts` and write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/remediation-baseline/line-count-baseline.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`
  recording the reported line count. Acceptance: the artifact records a
  numeric line count matching the file's actual pre-fix length (expected
  669).

---

### Phase 1 — Fix 1 (TerminalWriter Extraction) and Fix 2 (CRLF Normalization)

- [x] [P1-T1] Create `extensions/drm-copilot/src/terminal-writer.ts`
  containing a verbatim move (no behavior change) of the `TerminalWriter`
  interface, the `SUBAGENT_TREE_TERMINAL_NAME` constant, the
  `PseudoterminalTerminalWriter` class, and the
  `createSubagentTreeTerminalWriter()` factory currently at lines 179–276 of
  `extensions/drm-copilot/src/command-runtime.ts`, together with the single
  `import * as vscode from "vscode";` line the moved code requires. The new
  file must remain host-bound (uses `vscode`) and must NOT be placed under
  `extensions/drm-copilot/src/lib/subagent-tree/`. Acceptance: the new file
  exists at the stated path and exports `TerminalWriter`,
  `SUBAGENT_TREE_TERMINAL_NAME`, and `createSubagentTreeTerminalWriter`,
  with `PseudoterminalTerminalWriter` defined (non-exported, matching its
  current visibility).

- [x] [P1-T2] Remove the moved `TerminalWriter` interface,
  `SUBAGENT_TREE_TERMINAL_NAME` constant, `PseudoterminalTerminalWriter`
  class, and `createSubagentTreeTerminalWriter()` factory from
  `extensions/drm-copilot/src/command-runtime.ts`, leaving every other
  export in that file unchanged. Acceptance: `command-runtime.ts` contains
  no occurrence of `TerminalWriter`, `PseudoterminalTerminalWriter`, or
  `SUBAGENT_TREE_TERMINAL_NAME`.

- [x] [P1-T3] Verify post-move line counts by running
  `wc -l extensions/drm-copilot/src/command-runtime.ts` and
  `wc -l extensions/drm-copilot/src/terminal-writer.ts`, then write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/file-size-verification.<TIMESTAMP>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`
  recording both line counts. Acceptance: the recorded line count for
  `command-runtime.ts` is <= 500 and for `terminal-writer.ts` is <= 500.

- [x] [P1-T4] Update the import block in
  `extensions/drm-copilot/src/subagent-tree-command.ts` so that
  `createSubagentTreeTerminalWriter` and the `TerminalWriter` type are
  imported from `./terminal-writer` instead of `./command-runtime`, leaving
  the `getClaudeProjectsRoot` and `getWorkspaceRoot` imports from
  `./command-runtime` unchanged. Acceptance: the file's import statements
  reference `./terminal-writer` for `TerminalWriter` and
  `createSubagentTreeTerminalWriter`, and reference `./command-runtime` only
  for `getClaudeProjectsRoot` and `getWorkspaceRoot`.

- [x] [P1-T5] Add a `coverageThreshold` entry keyed
  `"./src/terminal-writer.ts"` with `{ lines: 85, branches: 75 }` to
  `extensions/drm-copilot/jest.config.cjs`, matching the existing entry
  format, without modifying or removing any existing entry (including
  `"./src/command-runtime.ts"`, which must remain at `{ lines: 85,
  branches: 75 }`). Acceptance: `jest.config.cjs` contains the new key with
  the stated values and every pre-existing key is byte-identical to its
  prior value.

- [x] [P1-T6] Update `extensions/drm-copilot/test/subagent-tree-command.test.ts`:
  change the `import type { TerminalWriter } from "../src/command-runtime";`
  statement to `from "../src/terminal-writer";`, and move the
  `createSubagentTreeTerminalWriter: jest.fn(() => { throw new Error(...) })`
  mock export out of the existing `jest.mock("../src/command-runtime", ...)`
  block into a new `jest.mock("../src/terminal-writer", () => ({
  createSubagentTreeTerminalWriter: jest.fn(() => { throw ... }) }))` block,
  leaving `getWorkspaceRoot` and `getClaudeProjectsRoot` in the
  `../src/command-runtime` mock unchanged. Acceptance: the file imports
  `TerminalWriter` from `../src/terminal-writer`, and a
  `jest.mock("../src/terminal-writer", ...)` block exists providing
  `createSubagentTreeTerminalWriter`.

- [x] [P1-T7] Create `extensions/drm-copilot/test/terminal-writer.test.ts`
  containing the relocated `describe("createSubagentTreeTerminalWriter", ...)`
  suite (the 5 existing test cases currently at lines 120–207 of
  `extensions/drm-copilot/test/command-runtime.test.ts`), the
  `FakeEventEmitter` class, the `FakeTerminal` interface, the
  `createTerminalMock` fixture, and the `jest.mock("vscode", ...)` block
  those tests depend on, importing `createSubagentTreeTerminalWriter` and
  `SUBAGENT_TREE_TERMINAL_NAME` from `../src/terminal-writer` instead of
  `../src/command-runtime`. All 5 relocated test bodies must be unchanged
  (pure relocation, no removal or relaxation). Acceptance: the new file
  exists, contains exactly the 5 relocated `it(...)` blocks unchanged, and
  imports from `../src/terminal-writer`.

- [x] [P1-T8] Remove the relocated `describe("createSubagentTreeTerminalWriter", ...)`
  block and its now-unused `FakeEventEmitter`/`FakeTerminal`/
  `createTerminalMock`/`vscode` mock scaffolding from
  `extensions/drm-copilot/test/command-runtime.test.ts`, leaving the
  `describe("getClaudeProjectsRoot", ...)` suite and its imports intact
  (retaining a minimal virtual `vscode` mock only if required for the
  module to import cleanly). Acceptance: `command-runtime.test.ts` no
  longer references `createSubagentTreeTerminalWriter`,
  `SUBAGENT_TREE_TERMINAL_NAME`, `PseudoterminalTerminalWriter`, or
  `createTerminalMock`, and the existing `getClaudeProjectsRoot` tests are
  unchanged.

- [x] [P1-T9] In `extensions/drm-copilot/src/terminal-writer.ts`, change
  `PseudoterminalTerminalWriter.write()`'s assignment
  `this.pendingContent = \`${header}\r\n${body}\`;` to
  `this.pendingContent = \`${header}\r\n${body}\`.replace(/\r?\n/g, "\r\n");`
  so every internal line break in a multi-line `body` is normalized to
  `\r\n`, not only the header/body boundary. No new runtime dependency is
  introduced. Acceptance: the file contains the `.replace(/\r?\n/g,
  "\r\n")` normalization on the `pendingContent` assignment in `write()`.

- [x] [P1-T10] Add a new test case to
  `extensions/drm-copilot/test/terminal-writer.test.ts` (within the
  relocated `createSubagentTreeTerminalWriter` suite) that constructs a
  writer via `createSubagentTreeTerminalWriter()`, calls
  `writer.write("HEADER", "line1\nline2\nline3")`, opens the captured
  Pseudoterminal, and asserts the emitted content equals
  `"HEADER\r\nline1\r\nline2\r\nline3"`. This test must be added alongside
  (not replacing) the 5 relocated single-line-body tests from P1-T7.
  Acceptance: the new `it(...)` block exists with the stated assertion and
  all 5 pre-existing test cases remain present unchanged.

- [x] [P1-T11] Add a new test case to
  `extensions/drm-copilot/test/subagent-tree-command.test.ts` using a
  multi-line `formatTree` fixture: register, via `InMemoryFileSystem`, a
  root session transcript plus at least one nested transcript under a
  `/subagents/` path segment (mirroring the fixture-construction pattern in
  `extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts`),
  invoke the command handler, and assert the `FakeTerminalWriter`'s
  captured `body` for that invocation contains an embedded `\n` (is
  multi-line) and matches the expected joined multi-line string produced by
  `formatTree`. This test must be added alongside (not replacing) the
  existing single-session test case at lines 221–240. Acceptance: the new
  `it(...)` block exists, asserts on a multi-line `body`, and every
  pre-existing test case in the file remains present unchanged.

- [x] [P1-T12] (Authorized additional extraction, remediation cycle 1 —
  "COMPLETE FIX 1" directive.) Fix 1's stated goal ("`command-runtime.ts`
  returns to at or under 500 lines") was not met after P1-T1 through P1-T11
  alone: `command-runtime.ts` was 570 lines (pre-existingly 531 on main).
  Create `extensions/drm-copilot/src/runtime-detection.ts` and move verbatim
  (no behavior change) the executable/runtime-resolution group from
  `command-runtime.ts` — private helpers `executableExists`,
  `getPathExtensions`, `findExecutableOnPath`, `normalizeExecutablePath`,
  `buildCodexExecutableCandidates`, `findCodexInInstalledExtensionRoots`;
  exported `resolveCodexExecutable` and `detectRuntime`; and the
  `RuntimeKind` type and `RuntimeResolution` interface. Add re-exports in
  `command-runtime.ts` (`export { detectRuntime, resolveCodexExecutable }
  from "./runtime-detection";` and `export type { RuntimeKind,
  RuntimeResolution } from "./runtime-detection";`) so `src/extension.ts`
  and `test/extension-test-harness.ts` require no edits. Add a
  `coverageThreshold` entry `"./src/runtime-detection.ts": { lines: 85,
  branches: 75 }` to `jest.config.cjs` without weakening any existing key.
  Acceptance: `runtime-detection.ts` exists, is host-bound (uses
  `node:fs`/`node:path` only, no `vscode` import), does not import from
  `command-runtime.ts` (one-directional: `command-runtime.ts` imports
  `RuntimeKind`/`detectRuntime` from `runtime-detection.ts`), is not placed
  under `src/lib/subagent-tree/`, and both `command-runtime.ts` and
  `runtime-detection.ts` are <= 500 lines. Verified: `command-runtime.ts` =
  368 lines, `runtime-detection.ts` = 211 lines (see
  `evidence/qa-gates/file-size-verification.2026-07-07T04-02.md` and
  `evidence/qa-gates/file-size-verification-final.2026-07-07T04-02.md`).

---

### Phase 2 — Final QC Loop

Run the five-stage toolchain below, in order, from `extensions/drm-copilot/`.
If any stage fails or modifies files, restart the loop from P2-T1 (format)
and re-run every stage until all five stages pass in a single clean pass;
record the restart (with a new `<TIMESTAMP>`) in the corresponding evidence
artifact(s) rather than overwriting a failed run's evidence. Every command
task below is unconditional: `EXIT_CODE: SKIPPED` is not a valid outcome for
any of P2-T1 through P2-T5.

- [x] [P2-T1] Run `npm run format` from `extensions/drm-copilot/` and write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/format.<TIMESTAMP>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0` and no files changed by the formatter (or, if
  files changed, the loop restarts from this task per the rerun rule
  above).

- [x] [P2-T2] Run `npm run lint` from `extensions/drm-copilot/` and write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/lint.<TIMESTAMP>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0` with 0 lint errors reported.

- [x] [P2-T3] Run `npm run typecheck` from `extensions/drm-copilot/` and
  write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/typecheck.<TIMESTAMP>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0` with 0 type errors reported.

- [x] [P2-T4] Run `npm run test:coverage` from `extensions/drm-copilot/`
  and write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/test-coverage.<TIMESTAMP>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The
  `Output Summary:` must record: the total test count (pass/fail), the
  numeric overall line/branch coverage, and numeric per-file lines/branches
  for each of `command-runtime.ts`, `terminal-writer.ts` (new),
  `subagent-tree-command.ts`, and `workspace-encoding.ts`. Acceptance:
  `EXIT_CODE: 0`, all tests pass (no `SKIPPED` outcome), and each of the
  four named files reports lines >= 85% and branches >= 75% with no
  regression versus the pre-remediation baseline
  (`command-runtime.ts` 94.02%/87.10% per
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/test-coverage.2026-07-07T03-15.md`).

- [x] [P2-T5] Run `npm run build` from `extensions/drm-copilot/` and write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/build.<TIMESTAMP>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  Acceptance: `EXIT_CODE: 0`.

- [x] [P2-T6] Re-run `wc -l extensions/drm-copilot/src/command-runtime.ts`
  and `wc -l extensions/drm-copilot/src/terminal-writer.ts` after the clean
  toolchain pass, and write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/file-size-verification-final.<TIMESTAMP>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`
  recording both final line counts. Acceptance: both counts are <= 500.

- [x] [P2-T7] Write
  `docs/features/active/2026-07-06-fix-subagent-tree-discovery-terminal-325/evidence/qa-gates/final-qc-clean-pass.<TIMESTAMP>.md`
  summarizing that P2-T1 through P2-T6 all passed in a single clean pass
  (no restart), listing each stage's `EXIT_CODE` and referencing each
  stage's evidence artifact by filename. Acceptance: the artifact lists all
  six preceding evidence filenames with `EXIT_CODE: 0` for each, and states
  that no acceptance-criteria checkbox in `issue.md` was modified by this
  remediation.

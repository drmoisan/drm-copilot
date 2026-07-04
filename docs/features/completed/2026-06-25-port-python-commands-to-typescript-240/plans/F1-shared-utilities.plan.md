# F1 — ts-shared-subprocess-and-utility-layer — Atomic Implementation Plan

**Issue:** #240
**Feature:** F1 (foundational shared subprocess runner and utility layer)
**Work Mode:** full-feature
**Plan path:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/plans/F1-shared-utilities.plan.md`
**Feature folder (`<FEATURE>`):** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`

## Scope Summary

Port the following Python modules to TypeScript under `extensions/drm-copilot/src/lib/`, replicating behavior exactly (signatures, return shapes, error messages, edge cases):

1. `scripts/dev_tools/prompt_mode_contract.py` → `extensions/drm-copilot/src/lib/prompt-mode-contract.ts`
2. `scripts/dev_tools/json_config.py` → `extensions/drm-copilot/src/lib/json-config.ts`
3. `scripts/dev_tools/markdown_label_formatter.py` → `extensions/drm-copilot/src/lib/markdown-label-formatter.ts`
4. Shared subprocess runner (modeled on `scripts/dev_tools/pr_context/git.py` `SubprocessRunner`/`CommandResult`) → `extensions/drm-copilot/src/lib/subprocess-runner.ts`
5. Shared filesystem abstraction (modeled on Python `FileSystem` Protocol; required by `json-config.ts` directory traversal) → `extensions/drm-copilot/src/lib/file-system.ts`

Tests (Jest, mirroring Python test scenarios) under `extensions/drm-copilot/test/lib/`.

## Toolchain Facts (authoritative for this plan)

- The package `extensions/drm-copilot/` uses **Jest** (`jest.config.cjs`, `ts-jest`, `run-jest.cjs`), NOT Vitest. All tests MUST use Jest conventions: `import { describe, expect, it, jest } from "@jest/globals";`, `jest.fn()`, `jest.spyOn()`, `jest.mock()`.
- All toolchain commands run from inside `extensions/drm-copilot/`.
  - Format: `npm run format`
  - Lint: `npm run lint`
  - Type-check: `npm run typecheck`
  - Test: `npm test`
  - Coverage: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (the `run-jest.cjs` wrapper forwards all extra args to Jest; there is no `test:coverage` npm script and no configured `coverageThreshold`, so coverage thresholds must be verified manually against policy: line >= 85%, branch >= 75%).
- `tsconfig.json` uses `module: "Node16"`, `rootDir: "src"`, `strict: true`, `noUncheckedIndexedAccess: true`, `exactOptionalPropertyTypes: true`. New `src/lib/*.ts` files are included automatically. No `any`; prefer `unknown` plus narrowing.

## Constraints (must hold for every task)

- No production or test file may exceed 500 lines.
- ES modules only; no `require`/`module.exports` in `src/`.
- Strong typing; no `any`. Kebab-case filenames.
- Tests hermetic: no real subprocess, no temp files, no real filesystem writes. Mock `node:child_process`; inject the `FileSystem` interface.
- AAA (Arrange–Act–Assert) test structure; reset mocks in `afterEach`.
- Do NOT modify `repo-automation-service.ts`, `command-runtime.ts`, MCP handlers, or any service wiring in F1. F1 adds only the `src/lib/` layer plus its tests.
- Do NOT modify policy files under `.claude/rules/` or `.github/instructions/`.

## Evidence Location Invariant

All evidence artifacts MUST be written under `<FEATURE>/evidence/<kind>/`:
- Baseline: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/`
- QA gates: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/`
- Regression: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/regression-testing/`

Writing evidence to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any non-canonical path is a policy violation. Each command-step evidence artifact MUST include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Coverage artifacts MUST record numeric line and branch coverage values.

---

### Phase 0 — Baseline Capture and Policy Reading

- [x] [P0-T1] Read repository policy files in required order and record evidence. Read, in order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/self-explanatory-code-commenting.md`. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:` (the ordered list above), and an explicit `Files Read:` list. Acceptance: the evidence file exists and lists every file above.
- [x] [P0-T2] Read all F1 Python source files to be ported and record their observed signatures/return shapes. Read `scripts/dev_tools/prompt_mode_contract.py`, `scripts/dev_tools/json_config.py`, `scripts/dev_tools/markdown_label_formatter.py`, `scripts/dev_tools/pr_context/git.py`, `scripts/dev_tools/pr_context/models.py` (for `CommandResult`). Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/phase0-python-sources.md` with `Timestamp:`, the list of files read, and a `Signatures:` section enumerating each function/class to be ported. Acceptance: the evidence file exists and enumerates every public function from the four port targets.
- [x] [P0-T3] Capture baseline TypeScript format state. From `extensions/drm-copilot/`, run `npm run format`. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/baseline-format.md` with `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: artifact exists with all four fields populated.
- [x] [P0-T4] Capture baseline TypeScript lint state. From `extensions/drm-copilot/`, run `npm run lint`. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/baseline-lint.md` with `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: artifact exists with all four fields populated.
- [x] [P0-T5] Capture baseline TypeScript type-check state. From `extensions/drm-copilot/`, run `npm run typecheck`. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/baseline-typecheck.md` with `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: artifact exists with all four fields populated.
- [x] [P0-T6] Capture baseline test and coverage state. From `extensions/drm-copilot/`, run `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/baseline-test-coverage.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including the baseline numeric line coverage and branch coverage headline values (the `src/lib/**` denominator is empty pre-implementation; record the observed values, e.g. existing suite pass count and the reported coverage totals). Acceptance: artifact exists with all four fields and numeric coverage values recorded.

---

### Phase 1 — Subprocess Runner and Filesystem Abstractions

- [x] [P1-T1] Create `extensions/drm-copilot/src/lib/subprocess-runner.ts` defining the `CommandResult` interface and the runner contract. Define `interface CommandResult { stdout: string; stderr: string; code: number; }` (mirror `pr_context/models.py` `CommandResult`; field `code` is the exit code). Define `interface CommandRunner { run(args: readonly string[], options?: { cwd?: string; allowError?: boolean }): CommandResult; }` mirroring the Python `CommandRunner` Protocol. Export both. Acceptance: file exists, exports `CommandResult` and `CommandRunner`, contains no implementation logic beyond type declarations and the runner class added in P1-T2, and is under 500 lines.
- [x] [P1-T2] Implement `SubprocessRunner` in `extensions/drm-copilot/src/lib/subprocess-runner.ts` using `node:child_process`. Use `spawnSync(args[0], args.slice(1), { cwd, shell: false })` capturing stdout/stderr as `Buffer`, then decode with `buffer.toString("utf8")` to match Python `encoding="utf-8", errors="replace"`. Replicate Python behavior exactly: strip a single trailing `\n` from stdout and stderr via `rstrip("\n")` equivalent (remove trailing newline characters), build `CommandResult` with integer `code` from `status` (treat `null` status as a non-zero failure), and when `allowError` is false and `code !== 0` throw an `Error` with message `` `${args.join(" ")} failed (${code}): ${joined}` `` where `joined` is `(stdout + "\n" + stderr).trim()`. Add a class docstring/JSDoc and decision/intent comments per the commenting policy. Acceptance: `npm run typecheck` passes for this file; the throw message format and trailing-newline stripping match `git.py` `SubprocessRunner.run`.
- [x] [P1-T3] Create `extensions/drm-copilot/src/lib/file-system.ts` defining a `FileSystem` interface for hermetic file I/O. Model on the Python `FileSystem` Protocol pattern. Define an interface with the operations required by `json-config.ts` and `markdown-label-formatter.ts`: at minimum `glob(root: string, pattern: string): string[]`, `isFile(path: string): boolean`, `readTextFile(path: string): string`, and `writeTextFile(path: string, content: string): void`. Export the interface and a `RealFileSystem` class implementing it via `node:fs` (`fs.readFileSync`/`fs.writeFileSync` with `"utf8"`, `fs.statSync().isFile()`, and a glob implementation consistent with Python `Path.glob` semantics for the governed/exclude patterns). Add JSDoc. Acceptance: `npm run typecheck` passes; interface and `RealFileSystem` both exported; file under 500 lines.

---

### Phase 2 — Port `prompt-mode-contract.ts`

- [x] [P2-T1] Create `extensions/drm-copilot/src/lib/prompt-mode-contract.ts` porting `scripts/dev_tools/prompt_mode_contract.py`. Export constants `CANONICAL_WORK_MODES = ["minor-audit", "full-feature", "full-bug"] as const`, `LEGACY_FULL_MODE = "full"`, and `ACCEPTED_WORK_MODES`. Export `normalizeRequestedWorkMode(requestedMode: string, promotionType: string): string` replicating all branches and the exact error message strings: `"work_mode must be one of: minor-audit, full-feature, full-bug, full"`, `"full-bug may only be used with bug work"`, `"full-feature may not be used with bug work"`. Export `parseIssueWorkMode(issueContent: string): { mode: string | null; malformed: boolean }` using regex equivalent to the Python `(?im)^-\s*Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$` for the valid case and `(?im)^-\s*Work Mode:\s*(.+)\s*$` for the malformed-detection case. Export `resolveSelectedWorkMode(issueContent: string | null): string` and `buildFallbackReason(issueContent: string | null): string` replicating the exact returned reason strings from the Python source. Throw `Error` (not a custom type) for the validation failures. Add JSDoc and decision-logic comments. Acceptance: `npm run typecheck` passes; the file contains no `any`; all four functions and three constants are exported; error and reason strings match the Python source verbatim.
- [x] [P2-T2] Create `extensions/drm-copilot/test/lib/prompt-mode-contract.test.ts` mirroring `tests/scripts/dev_tools/test_prompt_mode_contract.py`. Use `import { describe, expect, it } from "@jest/globals";`. Port every scenario from the Python test: valid `minor-audit` marker parse; valid `full-feature` marker parse; legacy `full` normalization to `full-feature` via `resolveSelectedWorkMode`; fail-closed when marker missing; fail-closed when marker malformed; `buildFallbackReason` for missing marker; `normalizeRequestedWorkMode` minor-audit unchanged; full-feature accepted for feature; legacy full → full-bug for bug; reject full-bug for feature work (expect thrown `Error` with matching message); reject full-feature for bug work (expect thrown `Error` with matching message); `buildFallbackReason` returns `"none"` for valid marker; legacy-full normalization reason; malformed-marker reason. Add an extra case for `resolveSelectedWorkMode(null)` returning `"full-feature"` and `buildFallbackReason(null)` returning the missing-file reason, plus a malformed-marker `parseIssueWorkMode` case asserting `malformed === true`, to reach branch coverage. Use AAA structure. Acceptance: `npm test` runs this file and all assertions pass.

---

### Phase 3 — Port `markdown-label-formatter.ts`

- [x] [P3-T1] Create `extensions/drm-copilot/src/lib/markdown-label-formatter.ts` porting the pure-logic functions of `scripts/dev_tools/markdown_label_formatter.py`. Export `LABEL_PREFIXES = ["User:", "GitHub Copilot:"] as const`, `SEPARATOR_LINE = "---"`. Export `isLabelLine(line: string): boolean`, `isSeparatorLine(line: string): boolean`, `formatLabelHeading(line: string): { heading: string; trailing: string }` (use `partition(":")` equivalent: split on first `:`, heading is `` `# ${label.trim()}:` ``, trailing is the remainder left-stripped), `ensureSeparatorBlock(outputLines: string[]): void` (mutates the array exactly as Python: pop trailing blank lines, then push `"", "---", ""`), `prefixContentLine(line: string): string`, and `processMarkdown(content: string): string` replicating `content.splitlines()` semantics and trailing-newline preservation. Acceptance: `npm run typecheck` passes; no `any`; `processMarkdown` output matches the Python expected strings in the test scenarios exactly.
- [x] [P3-T2] Add file I/O functions to `extensions/drm-copilot/src/lib/markdown-label-formatter.ts` using the injected `FileSystem` interface (not direct `fs`/stdin). Port `readContent` and `writeOutput` as functions that accept a `FileSystem` and an optional path: `readContent(fs: FileSystem, source: string | null, stdin: () => string): string` and `writeOutput(fs: FileSystem, content: string, target: string | null, stdout: (s: string) => void): void`. This keeps logic testable without touching real files or process streams (the Python CLI `argparse`/`main` glue is out of scope for F1 since service wiring is deferred; do not port `parse_args`/`main`). Document in JSDoc that the CLI entry-point glue is intentionally deferred to a consuming feature. Acceptance: `npm run typecheck` passes; `readContent`/`writeOutput` take injected `FileSystem` and stream callbacks; no direct `node:fs` or `process.stdin`/`process.stdout` use in this module.
- [x] [P3-T3] Create `extensions/drm-copilot/test/lib/markdown-label-formatter.test.ts` mirroring `tests/scripts/dev_tools/test_markdown_label_formatter.py`. Use `@jest/globals`. Port the `processMarkdown` scenarios verbatim: first label with content; separator before non-initial label; multiple labels quoting other lines; label without inline text skips extra spacing; trailing newline preserved; whitespace-only separator handling. Port helper-function tests: `isLabelLine` recognizes `User:` and `GitHub Copilot:` and rejects non-labels; `isSeparatorLine` for blank, `---`, and content; `formatLabelHeading` with and without trailing text; `prefixContentLine` with and without text; `ensureSeparatorBlock` adds separator and removes trailing blanks. Port the I/O tests using a fake `FileSystem` object (in-memory map) and stub stream callbacks rather than mocking `node:fs`: `readContent` from file; `readContent` from "stdin" callback when path is null; `writeOutput` to file; `writeOutput` to "stdout" callback when path is null. Use AAA. Acceptance: `npm test` runs this file and all assertions pass; no real filesystem or temp files used.

---

### Phase 4 — Port `json-config.ts`

- [x] [P4-T1] Create `extensions/drm-copilot/src/lib/json-config.ts` porting `scripts/dev_tools/json_config.py`. Export `GOVERNED_GLOBS = ["scripts/**/*.json", "docs/**/*.json", "examples/**/*.json"] as const` and `EXCLUDE_GLOBS` mirroring the Python tuple exactly (`"data/**"`, `"artifacts/**"`, `"htmlcov/**"`, `"coverage*/**"`, `"**/node_modules/**"`, `".venv"`, `".venv/**"`, `"**/.venv"`, `"**/.venv/**"`). Export `iterGovernedFiles(fs: FileSystem, root: string): string[]` that accepts the injected `FileSystem` (per P1-T3), replicating the Python algorithm: resolve include matches via `fs.glob`, build the exclusion set via `fs.glob`, then yield each included path that is a file (`fs.isFile`) and whose parents are not excluded and which is not itself excluded. The exclusion-by-parent check must mirror the Python `any(parent in excluded for parent in path.parents)` semantics. Return an array (TypeScript has no generator requirement; an array of paths matches `list(iter_governed_files(...))` usage in the Python tests). Add JSDoc and an intent comment on the iteration. Acceptance: `npm run typecheck` passes; no `any`; constants match the Python source; `iterGovernedFiles` takes an injected `FileSystem`.
- [x] [P4-T2] Create `extensions/drm-copilot/test/lib/json-config.test.ts` mirroring `tests/scripts/dev_tools/test_json_config.py`. Use `@jest/globals` and a fake in-memory `FileSystem` implementation (no real filesystem). Port every scenario: `GOVERNED_GLOBS` is a non-empty array containing `"scripts/**/*.json"`; `EXCLUDE_GLOBS` is a non-empty array containing `"data/**"`; empty filesystem yields `[]`; excludes `.vscode/*.json`; excludes nested `.vscode/**/*.json`; excludes `data/**`; excludes `artifacts/**`; excludes when a parent dir is excluded (`htmlcov/subdir/report.json`); excludes `.devcontainer/*.json`; finds `scripts/**/*.json`; finds `docs/**/*.json`; finds `examples/**/*.json`; accepts a string root; mixed included/excluded yields only included; skips non-file glob matches (a directory named `weird.json`). The fake `FileSystem.glob` must implement glob/exclude matching consistent with the production `RealFileSystem.glob` so the tests validate `iterGovernedFiles` logic, not the glob engine. Use AAA. Acceptance: `npm test` runs this file and all assertions pass.

---

### Phase 5 — Subprocess Runner Tests

- [x] [P5-T1] Create `extensions/drm-copilot/test/lib/subprocess-runner.test.ts` covering `SubprocessRunner` with `node:child_process` mocked. Use `import { afterEach, describe, expect, it, jest } from "@jest/globals";` and `jest.mock("node:child_process", () => ({ spawnSync: jest.fn() }));`. Reset mocks in `afterEach(() => { jest.resetAllMocks(); })`. Cover these scenarios: (1) success — `spawnSync` returns `{ status: 0, stdout: Buffer.from("out\n"), stderr: Buffer.from("") }`; assert `result.code === 0`, `result.stdout === "out"` (trailing newline stripped), `result.stderr === ""`; (2) non-zero exit with `allowError: true` returns the result with `code !== 0` instead of throwing; (3) non-zero exit with `allowError` false (default) throws `Error` whose message matches the `` `${args.join(" ")} failed (${code}): ${joined}` `` format; (4) stderr capture — assert stderr buffer content is decoded and trailing newline stripped; (5) UTF-8 replacement — provide a `Buffer` containing an invalid UTF-8 byte sequence (e.g. `Buffer.from([0xff, 0xfe])`) and assert `result.stdout` contains the U+FFFD replacement character rather than throwing; (6) `null` status treated as failure. Use AAA. Acceptance: `npm test` runs this file and all assertions pass; no real subprocess is spawned.
- [x] [P5-T2] Add `extensions/drm-copilot/test/lib/file-system.test.ts` covering `RealFileSystem` glob and predicate logic with `node:fs` mocked. Use `@jest/globals` and `jest.mock("node:fs", ...)`. Cover `isFile` true/false via mocked `statSync`, `readTextFile` returning decoded UTF-8 content via mocked `readFileSync`, `writeTextFile` delegating to mocked `writeFileSync` with `"utf8"`, and `glob` returning matches consistent with the governed/exclude pattern semantics used by `json-config`. Reset mocks in `afterEach`. Acceptance: `npm test` runs this file and all assertions pass; no real filesystem access.

---

### Phase 6 — Final QA Loop and Coverage Verification

Run the full toolchain in order. If any step fails or changes files, fix and restart from P6-T1.

- [x] [P6-T1] Run formatting. From `extensions/drm-copilot/`, run `npm run format`. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/final-format.md` with `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, `Output Summary:`. Acceptance: EXIT_CODE 0; if files changed, restart the loop at P6-T1.
- [x] [P6-T2] Run linting. From `extensions/drm-copilot/`, run `npm run lint`. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/final-lint.md` with `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, `Output Summary:` (must report 0 errors). Acceptance: EXIT_CODE 0 and 0 lint errors; otherwise fix and restart at P6-T1.
- [x] [P6-T3] Run type checking. From `extensions/drm-copilot/`, run `npm run typecheck`. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/final-typecheck.md` with `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, `Output Summary:` (must report 0 type errors). Acceptance: EXIT_CODE 0; otherwise fix and restart at P6-T1.
- [x] [P6-T4] Run tests with coverage and verify thresholds. From `extensions/drm-copilot/`, run `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/final-test-coverage.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording numeric line coverage and branch coverage for `src/lib/**`. Acceptance: EXIT_CODE 0, all tests pass, line coverage >= 85% and branch coverage >= 75% for the `src/lib/**` files added in F1; if any test fails or thresholds are unmet, add/adjust tests and restart at P6-T1.
- [x] [P6-T5] Record coverage delta verification. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/coverage-delta.md` with `Timestamp:`, baseline coverage (from P0-T6), post-change coverage (from P6-T4), and new/changed-code coverage for the F1 `src/lib/**` files. Acceptance: artifact reports baseline, post-change, and new-code coverage; new-code line coverage >= 85% and branch coverage >= 75%.
- [x] [P6-T6] Verify no out-of-scope files were modified. Confirm via `git status` (from repo root) that the only changes are under `extensions/drm-copilot/src/lib/`, `extensions/drm-copilot/test/lib/`, and `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/`. Confirm `repo-automation-service.ts`, `command-runtime.ts`, MCP handlers, and policy files are unchanged. Write `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/scope-verification.md` with `Timestamp:`, `Command: git status --porcelain`, `EXIT_CODE:`, and `Output Summary:` listing changed paths. Acceptance: no changes outside the allowed paths.

---

## Acceptance Criteria Checklist (F1)

- [x] `extensions/drm-copilot/src/lib/subprocess-runner.ts` exists, exports `CommandResult`, `CommandRunner`, and `SubprocessRunner`; uses `node:child_process` with `Buffer` capture decoded via `buffer.toString("utf8")`; returns typed `{ stdout, stderr, code }`; throws on non-zero exit when `allowError` is false with the message format matching `git.py`.
- [x] `extensions/drm-copilot/src/lib/file-system.ts` exists, exports a `FileSystem` interface and `RealFileSystem` implementation enabling injectable, hermetic file I/O.
- [x] `extensions/drm-copilot/src/lib/prompt-mode-contract.ts` replicates `prompt_mode_contract.py` behavior exactly (functions, constants, error and reason strings).
- [x] `extensions/drm-copilot/src/lib/markdown-label-formatter.ts` replicates `markdown_label_formatter.py` pure-logic and I/O behavior (I/O via injected `FileSystem`); CLI glue intentionally deferred.
- [x] `extensions/drm-copilot/src/lib/json-config.ts` replicates `json_config.py` constants and `iterGovernedFiles` semantics via injected `FileSystem`.
- [x] All four Jest test files exist under `extensions/drm-copilot/test/lib/` mirroring the Python test scenarios, plus `subprocess-runner.test.ts` and `file-system.test.ts`.
- [x] All tests use Jest conventions (`@jest/globals`, `jest.fn()`, `jest.mock()`, `jest.spyOn()`), AAA structure, and are hermetic (no real subprocess, no temp files).
- [x] No file exceeds 500 lines.
- [x] `npm run format`, `npm run lint`, `npm run typecheck` all pass with 0 errors from `extensions/drm-copilot/`.
- [x] Tests pass with line coverage >= 85% and branch coverage >= 75% for `src/lib/**`.
- [x] `repo-automation-service.ts`, `command-runtime.ts`, MCP handlers, and policy files are unmodified.
- [x] All evidence artifacts written under `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/<kind>/` with required schema fields.

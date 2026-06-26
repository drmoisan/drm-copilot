# F6 Phase 0 — Policy and Source-of-Truth Read Evidence

Timestamp: 2026-06-26T02-08

Policy Order: CLAUDE.md (standing instructions, always loaded) → .claude/rules/general-code-change.md (cross-language code change policy) → .claude/rules/general-unit-test.md (cross-language unit test policy) → TypeScript domain rules (.claude/rules/typescript.md, .claude/rules/typescript-suppressions.md) → .claude/rules/quality-tiers.md → .claude/rules/architecture-boundaries.md → .claude/rules/tonality.md

## Policy Files Read (in required order)

1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/typescript.md
5. .claude/rules/typescript-suppressions.md
6. .claude/rules/quality-tiers.md
7. .claude/rules/architecture-boundaries.md
8. .claude/rules/tonality.md

Note: All eight files above were read. CLAUDE.md and the general code-change/unit-test/quality-tiers/tonality rules were loaded via standing-instruction context; the TypeScript domain rules, suppressions, architecture-boundaries, and self-explanatory-code-commenting rule were read explicitly during Phase 0.

## Toolchain Divergence Acknowledgement (D1)

The repository TypeScript rule (.claude/rules/typescript.md) names Vitest as the test framework. The `extensions/drm-copilot/` package uses Jest (jest.config.cjs, ts-jest, run-jest.cjs; `npm test` = `node run-jest.cjs`). Per the plan's binding Toolchain Facts and accepted decision D1, all F6 toolchain commands run from inside `extensions/drm-copilot/` using Jest:
- Format: `npm run format`
- Lint: `npm run lint`
- Type-check: `npm run typecheck`
- Test / coverage: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`

## Files Read for Port (P0-T2)

Timestamp: 2026-06-26T02-08

All of the following files were read; no file was modified.

Parity target and references:
- extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py (BUNDLED port source — parity target; 465 LoC)
- extensions/drm-copilot/resources/templates/new_potential_bug_entry.py (wrapper; confirms the service invokes the bundled module via in-process import)
- scripts/dev_tools/new_potential_bug_entry.py (reference) — NOTE: this root reference path was not opened separately; the BUNDLED copy is the authoritative parity target per Scope Constraints and the wrapper delegates to `dev_tools.new_potential_bug_entry` from bundled sources. The bundled copy is read in full.
- tests/scripts/dev_tools/test_new_potential_bug_entry.py (test scenarios to mirror)
- extensions/drm-copilot/resources/feature-templates/bug/potential_bug.md (template confirms placeholders `<bug-name>`, `YYYY-MM-DD`, `- Author: name`)

F1 reuse targets:
- extensions/drm-copilot/src/lib/file-system.ts (FileSystem interface: glob/isFile/readTextFile/writeTextFile/ensureDir; toPosixPath; RealFileSystem). No `copyFile` method — port uses readTextFile + render + writeTextFile.
- extensions/drm-copilot/src/lib/subprocess-runner.ts (CommandRunner, CommandResult, CommandRunOptions, SubprocessRunner; run(args, {allowError}))

Service and precedents:
- extensions/drm-copilot/src/repo-automation-service.ts — `newPotentialBugEntry` method at lines 269-286 (current body is 18 lines, spawns Python via executeScript); `this.templateRoot = buildTemplateRoot(this.extensionRoot)`; `this.fileSystem`/`this.runner` injected; `this.output.appendLine`. File line count = 500.
- extensions/drm-copilot/src/repo-automation-service-support.ts (`normalizeGeneratedPath` at line 70)
- extensions/drm-copilot/src/lib/resolve/resolve-prompts-service-call.ts (service-call helper precedent to mirror)
- extensions/drm-copilot/src/mcp-handlers/feature-entry-handlers.ts (`handleNewPotentialBugEntry` delegates to `service.newPotentialBugEntry(input)`)
- extensions/drm-copilot/src/mcp-tool-inputs.ts (`resolveNewPotentialBugEntryToolInput` — input shape `WorkspaceExecutionInput & { shortName }`; already validates `short_name` at the boundary)

Test harness and F4 precedent:
- extensions/drm-copilot/test/extension.collect-commit-context-inprocess.test.ts (F4 in-process sibling precedent)
- extensions/drm-copilot/test/collect-commit-context-test-support.ts (`installInProcessFsCaptures` pattern using `fsMock`)
- extensions/drm-copilot/test/extension-test-harness.ts (`fsMock` mocks `node:fs` readFileSync/writeFileSync/mkdirSync/statSync; `childProcessMock`; extensionRoot fsPath `C:/extension`; service uses production RealFileSystem over mocked node:fs)

## Extension tests asserting the Python spawn for `new_potential_bug_entry` (exact enumeration)

In `extensions/drm-copilot/test/extension.workflow-commands.test.ts`:
- `registers newPotentialBugEntry` (line 116) — registration only; PRESERVE unchanged.
- `newPotentialBugEntry passes the bundled script path and short-name args` (line 163) — asserts spawn with `.py` path + `--short-name`; REWORK to in-process.
- `newPotentialBugEntry direct --short-name invocation skips prompts` (line 181) — asserts spawn args; REWORK (preserve skip-prompts behavior).
- `newPotentialBugEntry direct mode rejects invalid short-name pattern` (line 196) — asserts `/short-name/i` throw, no spawn; PRESERVE behavior (now surfaced by in-process validateShortName).
- `newPotentialBugEntry returns early when the input box is cancelled` (line 210) — no spawn; PRESERVE behavior.
- `newPotentialBugEntry surfaces a missing python runtime error` (line 221) — DELETE and replace with a case asserting success without python present.
- `newPotentialBugEntry surfaces non-zero exit failures` (line 234) — Python exit-code concept; REPLACE with in-process failure (missing template -> file-not-found) or remove with rationale.
- `newPotentialBugEntry passes --template-root pointing to bundled feature-templates` (line 828) — asserts spawn `--template-root`; REWORK to assert in-process uses `resources/feature-templates`.

Other-file references (incidental; leave unchanged, confirm still pass — P2-T5):
- test/mcp-server.test.ts (line 27 mock-service `newPotentialBugEntry: jest.fn()`; line 85 tool-name list entry `"new_potential_bug_entry"`)
- test/extension.test.ts (line 108 `drmCopilotExtension.newPotentialBugEntryPyPlaceholder` — unrelated placeholder command registration)
- test/mcp-tools.push-down-claude.test.ts (line 28 mock-service `newPotentialBugEntry: jest.fn()`)
- test/mcp-tools.codex-native-converter.test.ts (line 26 mock-service `newPotentialBugEntry: jest.fn()`)

None of the four other-file references assert a Python spawn/runtime for this command.

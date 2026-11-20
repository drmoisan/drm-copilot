# F6 Behavior-Parity Capture

Timestamp: 2026-06-26T02-23

Command: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (run from `extensions/drm-copilot/`)

EXIT_CODE: 0

Output Summary: 64 suites / 725 tests passed. Each parity property below maps to a passing test. Parity target: the BUNDLED Python `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`.

## Parity property -> test mapping

1. Short-name validation rule and byte-identical error message.
   - `SHORT_NAME_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/`; blank or non-matching throws `Aborted: '<name>' is invalid. Use kebab-case letters/numbers only (e.g., api-timeout).`
   - Tests: `validateShortName accepts a valid kebab-case name without throwing`; `validateShortName rejects an invalid name with the byte-identical Python message`; `validateShortName rejects an empty string` (in `test/lib/new-potential-bug-entry.test.ts`).

2. Replace-all `renderContent` placeholder substitution (`<bug-name>`, `YYYY-MM-DD`, `- Author: name`), including multi-occurrence.
   - Test: `renderContent replaces all occurrences of every placeholder`.

3. Author resolution order: git `user.name` -> `USERNAME` env -> `"Unknown"`.
   - Tests: `getAuthor returns git config user.name when present`; `getAuthor falls back to USERNAME env when git lookup is blank`; `getAuthor returns 'Unknown' when both lookups return undefined`; `defaultEnvLookup returns undefined for a blank value`; `defaultGitConfigLookup returns undefined when the runner reports a git failure (allowError path)`; `defaultGitConfigLookup returns the trimmed stdout when git succeeds`.

4. Date / slug / target-path construction (`<workspace>/docs/features/potential/<date>-<shortName>.md`; today's `YYYY-MM-DD` default; `entryDate` override).
   - Tests: `createBugEntry writes the rendered file at the workspace potential path and returns it`; `createBugEntry defaults the entry date to today's YYYY-MM-DD when no entryDate is given`.

5. Template selection: `templateRoot/bug/potential_bug.md` when `templateRoot` provided, else `<workspace>/docs/features/templates/bug/potential_bug.md`.
   - Tests: `createBugEntry uses templateRoot/bug/potential_bug.md when templateRoot is provided`; `createBugEntry falls back to the workspace template when templateRoot is undefined`.

6. `ensureDir` is called on the target directory before writing.
   - Test: `createBugEntry calls ensureDir on the target directory before writing`.

7. `code`/`code-insiders` launch is a guarded no-op in the MCP/service path (launcher returns `false`, no subprocess), and insiders-signal detection + candidate ordering preserved.
   - Tests (launcher logic): `isInsidersSession / resolveCodeCli prefers code-insiders when an insiders signal env var is set`; `... probes code first for a non-insiders session`; `defaultCodeLauncher returns true and invokes the resolved CLI with --reuse-window and the file path`; `defaultCodeLauncher returns false when no CLI resolves (probe order ['code', 'code-insiders'])`; `defaultWhichLookup returns undefined when PATH is empty` (in `test/lib/new-potential-bug-entry-launcher.test.ts`).
   - Tests (no-op in service path): `newPotentialBugEntryServiceCall uses a no-op launcher so the manual-open warning lines are emitted (no subprocess launch)` (in `test/lib/new-potential-bug-entry-service-call.test.ts`); `extension.new-potential-bug-entry-inprocess.test.ts` asserts no Python `.py` spawn across all behavioral cases.

8. Warning-line output when the launcher returns `false` (`WARNING: VS Code 'code' command not found. Open file manually:` and `  <targetPath>`).
   - Tests: `createBugEntry emits the two WARNING lines through log when the launcher returns false`; `newPotentialBugEntryServiceCall uses a no-op launcher so the manual-open warning lines are emitted`.

9. File-not-found behavior for a missing template (read throws, mirroring Python `copy_file` raising `FileNotFoundError`).
   - Tests: `createBugEntry throws a file-not-found error when the template path is absent`; `extension.new-potential-bug-entry-inprocess.test.ts -> surfaces a file-not-found error when the bundled template is absent`.

10. Validation occurs before any filesystem work (invalid short name -> no write).
    - Tests: `createBugEntry throws the validation error and performs no write for an invalid short name`; `newPotentialBugEntryServiceCall propagates the validation error for an invalid short name`; `extension... direct mode rejects an invalid short-name pattern before any filesystem work`.

11. Preserved service return contract: `tool: "new_potential_bug_entry"`, `workspaceRoot`, exact `summary` (`Created a new potential bug entry for '<shortName>'.`), plus the created-artifact path.
    - Tests: `newPotentialBugEntryServiceCall returns the preserved tool, workspaceRoot, and exact summary`; `newPotentialBugEntryServiceCall returns artifacts containing the normalized created path`.

12. Preserved MCP input contract (`short_name`).
    - `mcp-tool-inputs.ts` `resolveNewPotentialBugEntryToolInput`, the handler `handleNewPotentialBugEntry`, and the tool name `new_potential_bug_entry` are unmodified; their existing tests continue to pass unmodified (full suite green). `mcp-server.test.ts` tool-name list assertion still includes `new_potential_bug_entry`.

## Decisions recorded

- `artifacts`-field decision (P2-T1): the created file path is included as a single `artifacts` entry (`artifacts: [normalizeGeneratedPath(createdPath)]`). No existing test asserted the absence of an `artifacts` field for this command (checked `repo-automation-service*.test.ts` and the extension suite), so the plan default (include the created path) was taken. This is the only intentional enrichment over the prior output and is reflected in the service-call tests.
- Collapsed copy+read: the F1 `FileSystem` interface has no `copyFile`; the port performs `ensureDir` + `readTextFile(template)` + render + `writeTextFile(target)`, behaviorally identical to Python copy-then-read-then-write for the observable target file content. No `copyFile` was added to the shared interface.

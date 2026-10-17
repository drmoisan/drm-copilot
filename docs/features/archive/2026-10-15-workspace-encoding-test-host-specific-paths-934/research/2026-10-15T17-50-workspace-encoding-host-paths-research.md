# Research: workspace-encoding test host-specific paths (Issue #934)

- Work mode: minor-audit (bug)
- Timestamp note: no clock tool was available to this researcher; the filename timestamp is set just after the plan timestamp (2026-10-15T17-44) and is not a clock reading.
- Tooling note: this researcher had read/search tools only. No command was executed. `extensions/drm-copilot/node_modules` is absent in this worktree, so every command result below is marked "expected (unobserved)".

## 1. Production module under test

`extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts` (73 lines, pure, no filesystem or vscode import).

- `encodeWorkspacePath(workspacePath)` at line 30: `workspacePath.replace(/[\\/:]/g, "-")` (line 31). Every `\`, `/` and `:` becomes `-`. No case normalization, no drive-letter special case. `C:\a` therefore becomes `C--a` (colon and separator each become one hyphen).
- `matchEncodedDirectories(directoryNames, encodedWorkspaceName)` at lines 59-73: lowercases both sides (line 63, 67); keeps a directory when it equals the target or starts with `<target>-wt-` (`WORKTREE_INFIX = "-wt-"`, line 19, used at line 64). Input order preserved.
- Coverage gate: `jest.config.cjs` lines 214-217 gates this file at 85% lines / 75% branches.

### Behaviors exercised by each existing test (test file)

| Lines | Test | Behavior |
|---|---|---|
| 8-17 | replaces backslashes, forward slashes, and colons | `encodeWorkspacePath` backslash path |
| 19-30 | forward-slash path encodes identically | `encodeWorkspacePath` separator equivalence |
| 34-54 | lowercase drive-letter directory matches | case-insensitive match; other-repo rejection |
| 56-81 | per-worktree sibling | equality + `-wt-` prefix; unrelated-suffix rejection; other-repo rejection |
| 83-102 | worktree-of-a-worktree (flat) | nested `-wt-` extension |
| 104-119 | empty result | no match |
| 121-146 | new-scheme nested sibling | `/` before timestamp encodes to the `-wt-` infix |
| 148-168 | new-scheme worktree-of-a-worktree | forward-slash workspace root, nested suffix |
| 170-191 | exact equality on nested leaf | equality branch |

## 2. Lines containing the host user segment

Case-insensitive search for the user-name token in the test file returns 33 lines (the issue says "about 30"). Mixed-case form `DanMoisan` on 31 lines; lowercase form `danmoisan` on lines 42 and 53.

By test case:

- Test 1 (8-17): 10 (path literal), 16 (expected encoded).
- Test 2 (19-30): 21 (backslash path), 22 (forward-slash path).
- Test 3 (34-54): 39 (path literal), 42 (lowercase directory name), 43 (other-repo directory name), 53 (expected lowercase result).
- Test 4 (56-81): 59 (path literal), 62, 63, 64, 65 (directory names), 78, 79 (expected results).
- Test 5 (83-102): 87 (path literal), 90, 91 (directory names).
- Test 6 (104-119): 107 (path literal), 109 (directory name).
- Test 7 (121-146): 123 (comment, contains a forward-slash host path), 128 (path literal), 131, 132 (directory names), 143, 144 (expected results).
- Test 8 (148-168): 153 (forward-slash path literal), 156, 157 (directory names).
- Test 9 (170-191): 174 (forward-slash path literal), 177, 178 (directory names), 189 (expected result).

Lines 123 and the comments at 35-37 and 122-126 are the only prose; only 123 contains the token.

Additional host-shaped content without the user token: the literal drive-letter absolute paths on 12 lines of the test file (the `C:` search count for the subagent-tree test directory is 12 in this file, 1 in `session-transcript-resolver.test.ts`) and encoded `C--Users-...` names. All must go, because the requirement forbids encoding any absolute path, not just the host one.

## 3. Mirrors and scope boundary

- `workspace-encoding` appears (outside `docs/`) only in: `src/subagent-tree-command.ts`, `src/lib/subagent-tree/session-transcript-resolver.ts`, `jest.config.cjs`, and the test file. No `.codex`, `.github`, `resources`, `dist`, or bundled copy of the test exists.
- The user-name token (case-insensitive) in `.ts` files under `extensions/drm-copilot`: 33 lines, all in `workspace-encoding.test.ts`. No other `.ts` file under `extensions/drm-copilot/test` or `src` contains it.
- Conclusion: scope is exactly this one test file. No byte-identical mirror must be kept in sync.
- Outside scope, candidate unrelated follow-ups (not to be fixed under #934):
  - `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts` lines 6, 10, 12 use the literal `<drive>:\\Users\\<host-user>\\repos\\drm-copilot` and its encoded form. It is a truncated user name rather than the full host segment, but it is still a literal absolute path.
  - Across the whole repository the user-name token appears in hundreds of lines in docs, workflows, `package.json` publisher fields (`"publisher": "DanMoisan"` is a real marketplace publisher id, not a path), and PowerShell tests. These are not enumerated here.

## 4. Candidate approaches and recommendation

### Option A (recommended): runtime composition from neutral segments with separator constants

Compose both the input path and the expected encoded name from one list of neutral segments. No absolute path literal and no encoded absolute literal remains in source. Separators come from `node:path` constants (`path.win32.sep`, `path.posix.sep`), so even a backslash literal is absent from the file.

Why it counts as "not encoding an absolute path": the file contains only a drive-letter token, separator constants and relative segment names. An absolute path exists only as a runtime value inside the test. A text search of the artifact finds no drive-letter-plus-separator sequence and no `Users` path.

### Option B (rejected): replace the host name with another literal absolute path such as a fixture-root literal

Smallest diff, but each line is still a literal absolute path, which the task statement disallows on its own.

### Option C (rejected): `path.win32.join` / `path.posix.join` as the only composer

Works, but `path.win32.join` normalizes `/` to `\`, so the forward-slash cases (tests 2, 8, 9) cannot be built with it and would need `path.posix.join`. Two join APIs plus a drive-prefix workaround is more machinery than a three-line template helper. `path.win32.join("C:", "a")` also yields the drive-relative `C:a`, not `C:\a`, so a trailing separator on the drive argument is required. Not selected.

### Recommended design

Constants and helpers at the top of the test file (names are proposals):

```ts
import * as path from "node:path";

const UPPER_DRIVE = "C";
const LOWER_DRIVE = "c";
const PARENT_SEGMENTS = ["Users", "fixtureuser", "repos"];
const REPO = "drm-copilot";
const OTHER_REPO = "some-other-repo";
const BACKSLASH = path.win32.sep;
const SLASH = path.posix.sep;

// Absolute path assembled at runtime: "<drive>:<sep><segments joined by sep>".
function workspacePathOf(separator: string, ...segments: string[]): string {
  return `${UPPER_DRIVE}:${separator}${[...PARENT_SEGMENTS, ...segments].join(separator)}`;
}

// Expected encoded name, derived without calling the code under test:
// colon and first separator each become "-", every other separator becomes "-".
function encodedNameOf(drive: string, ...segments: string[]): string {
  return `${drive}--${[...PARENT_SEGMENTS, ...segments].join("-")}`;
}
```

`fixtureuser` has no hyphen so segment boundaries stay unambiguous. The `Users`/`repos` shape is kept so the encoded strings have the same segment depth as before.

Derivations (old literal to new expression):

| Old | New |
|---|---|
| `"<drive>:\\Users\\<host-user>\\repos\\drm-copilot"` (10, 21, 39, 59, 107, 128) | `workspacePathOf(BACKSLASH, REPO)` |
| `"<drive>:/Users/<host-user>/repos/drm-copilot"` (22) | `workspacePathOf(SLASH, REPO)` |
| `"<drive>--Users-<host-user>-repos-drm-copilot"` (16, 62, 78, 131, 143) | `encodedNameOf(UPPER_DRIVE, REPO)` |
| `"<drive-lowercase>--users-<host-user>-repos-drm-copilot"` (42, 53) | `encodedNameOf(UPPER_DRIVE, REPO).toLowerCase()` (equals the old lowercase literal, which is the point of the test) |
| `"<drive>--Users-<host-user>-repos-some-other-repo"` (43, 65, 109, 178) | `encodedNameOf(UPPER_DRIVE, OTHER_REPO)` |
| `...-drm-copilot-wt-2026-06-13-11-51` (63, 79) | `encodedNameOf(UPPER_DRIVE, `${REPO}-wt-2026-06-13-11-51`)` |
| `...-drm-copilot-unrelated-suffix` (64) | `encodedNameOf(UPPER_DRIVE, `${REPO}-unrelated-suffix`)` |
| `"C:\\...\\drm-copilot-wt-2026-07-03-16-18"` (87) | `workspacePathOf(BACKSLASH, `${REPO}-wt-2026-07-03-16-18`)` |
| 90 | `encodedNameOf(UPPER_DRIVE, `${REPO}-wt-2026-07-03-16-18`)` |
| 91 | `encodedNameOf(UPPER_DRIVE, `${REPO}-wt-2026-07-03-16-18-wt-2026-07-03-22-30`)` |
| `"C:/.../drm-copilot-wt/2026-07-07T12-00"` (153, 174) | `workspacePathOf(SLASH, `${REPO}-wt`, "2026-07-07T12-00")` |
| 132, 144 | `encodedNameOf(UPPER_DRIVE, `${REPO}-wt-2026-07-07T12-00`)` |
| 156, 189 | same as 132 |
| 157 | `encodedNameOf(UPPER_DRIVE, `${REPO}-wt-2026-07-07T12-00-wt-2026-07-07T18-00`)` |
| comment at 123 | rewrite as prose: "under the nested scheme the on-disk worktree is `<workspace parent>/drm-copilot-wt/<timestamp>`" (no drive or user) |

`LOWER_DRIVE` is unnecessary when `.toLowerCase()` is used; omit it.

Assertion equivalence: every assertion keeps the same input shape and the same expected value except for the substituted user segment (`<host-user>` to `fixtureuser`) and Users/repos path now being assembled. Covered shapes preserved: backslash (tests 1, 3-7), forward slash (tests 2, 8, 9), drive-letter case (test 3, uppercase input vs lowercase directory), `-wt-` suffix variants (tests 4, 5, 7, 8, 9), unrelated-suffix rejection (test 4), other-repo rejection (tests 3, 4, 6, 9). Test 2 still compares production output against production output for the two separators; test 1 still compares against an expected string independent of the production function. The expected-name helper deliberately does not call `encodeWorkspacePath`, so the helper cannot mask a production regression.

Residual risk: `encodedNameOf` restates the encoding rule (colon plus separator gives `--`). That is the same coupling the old literals had, expressed once. If a reviewer wants the first test to keep a visible literal for the rule, a short relative-only example (for example the encoding of a relative path containing `:` and both separators) can be added, but that is optional and would change the test inventory.

Line count: the file is 192 lines now; the change adds about 20 helper lines and shrinks several. It stays far below the 500-line limit.

## 5. Verification commands

All run from `extensions/drm-copilot`. Dependencies must be installed first (`npm ci`; not present in this worktree, so nothing below was observed).

1. Single-file test: `npm test -- --testPathPatterns workspace-encoding` (script `test` = `node run-jest.cjs`, which runs jest with `--config jest.config.cjs`; `run-jest.cjs` lines 21-23 rewrite the legacy `--testPathPattern` to `--testPathPatterns`, and lines 9-19 reject `--passWithNoTests`, `--onlyChanged`, `--lastCommit`). Coverage is off by default (`collectCoverage: false`, jest.config.cjs line 13), and `coverageThreshold` only applies when `--coverage` is passed, so a single-file run without `--coverage` is not broken by the per-file thresholds. Expected (unobserved): `PASS test/lib/subagent-tree/workspace-encoding.test.ts`, `Tests: 9 passed, 9 total`, exit 0. The test count is 9 per the inventory in section 1; the change must not alter it.
2. Optional coverage check for this module: `npm run test:coverage -- --testPathPatterns workspace-encoding --collectCoverageFrom=src/lib/subagent-tree/workspace-encoding.ts`. Note that running with `--coverage` on one test file can fail the other per-file thresholds in `jest.config.cjs` because their tests are not run, so this is not a recommended gate; use the full `npm run test:coverage` instead if a coverage artifact is required.
3. Format: `npx prettier --check test/lib/subagent-tree/workspace-encoding.test.ts` (expected: `All matched files use Prettier code style!`, exit 0). Use `npx prettier --write` on the same path first. No prettier config file exists in the directory, so Prettier defaults apply.
4. Lint: `npx eslint test/lib/subagent-tree/workspace-encoding.test.ts` (expected: no output, exit 0; config `eslint.config.mjs` is `eslint.configs.recommended` plus `typescript-eslint` recommended).
5. Type check: `npm run typecheck` (runs `tsc -p ./ --noEmit` then `tsc -p tsconfig.jest.json --noEmit`, the latter includes `test/**/*.ts`). Expected: no output, exit 0.

Search tokens for absence checks (use the Grep tool or `rg`; no backslash needed, immune to line wrapping because each token fits on one line):

- Host user segment, case-insensitive: pattern `danmoisan` with `-i` on the test file. Expected: 0 matches (currently 33 lines).
- Generic neutrality of the user token: pattern `Users` on the test file. Expected: only matches inside the `PARENT_SEGMENTS` constant (one line).
- Drive-letter absolute literal: pattern `[A-Za-z]:[^ ]` on the test file. Expected: 0 matches (the template `${UPPER_DRIVE}:${separator}` has `}` before the colon, so it does not match). Currently matches the 12 drive-letter lines.
- Encoded absolute literal: pattern `[A-Za-z]--` on the test file. Expected: 0 matches in source other than the template string in `encodedNameOf` (`${drive}--`, which has `}` before `--` and so does not match either).

Known limitation: the `[A-Za-z]:[^ ]` check also matches TypeScript object-type annotations written without a space, which Prettier removes by formatting; run it after `prettier --write`.

## Automation Feasibility

Fully automatable. No human interaction, approval, or manual inspection is expected: the edit is confined to one test file, and verification is the commands and zero-match searches above. The only prerequisite is installing dependencies in the working checkout (`npm ci` in `extensions/drm-copilot`).

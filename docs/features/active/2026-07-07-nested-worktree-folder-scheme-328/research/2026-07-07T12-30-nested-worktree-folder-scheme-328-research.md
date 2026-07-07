# Research: Nested Worktree Folder Scheme (Issue #328)

- Date: 2026-07-07
- Feature: `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/`
- Scope: change worktree on-disk scheme from flat `<parent>/<repoName>-wt-<yyyy-MM-dd-HH-mm>` to nested `<parent>/<repoName>-wt/<yyyy-MM-ddTHH-mm>`.
- Method: full reads of every named module, repo-wide ripgrep for `-wt-`, `-wt/`, `yyyy-MM-dd-HH-mm`, and symbol names; git upstream source verification for `git worktree add` directory-creation behavior.

## 1. Directory creation before `git worktree add`

### Verified git behavior

`git worktree add <path>` creates missing intermediate parent directories itself. Verified against current git master (`builtin/worktree.c`, function `add_worktree`), which builds `<path>/.git` and calls:

```c
strbuf_addf(&sb_git, "%s/.git", path);
if (safe_create_leading_directories_const(the_repository, sb_git.buf))
    die_errno(_("could not create leading directories of '%s'"), sb_git.buf);
```

Creating the leading directories of `<path>/.git` creates `<path>` itself and every missing ancestor, including the new `<repoName>-wt` grouping directory. So the nested scheme works with no extra `mkdir` on any modern git.

However, the acceptance criterion states explicitly: "Any folder in the chain that does not already exist must be created before `git worktree add` runs" (issue.md, Proposed Behavior). An explicit guard also removes dependence on git internals and makes the behavior unit-testable. Recommendation: add the explicit guard in both paths.

### Current dispatch mechanisms (verified)

- PowerShell script path: `scripts/dev-tools/new-claude-worktree-session.ps1` runs git in-process via `Invoke-GitWorktreeAdd` (lines 107-120):
  ```powershell
  & $InvokeGit @('worktree', 'add', $WorktreePath, '-b', $BranchName)
  ```
  `Test-PreconditionsMet` (lines 80-105) checks only that the leaf `$WorktreePath` does not already exist; an existing `<repoName>-wt` grouping directory does not trip it. No directory creation exists anywhere in the script.
- Extension path: `extensions/drm-copilot/src/extension.ts` does not spawn git for session creation. Both handlers (`newClaudeWorktreeSession`, lines 146-247; `newCodexWorktreeSession`, lines 249-338) send prebuilt PowerShell strings via `terminal.sendText(...)` (lines 207, 309). The git string is built by the pure builders:
  - `claude-worktree-session.ts:177`: `` git: `git -C ${quotedRepoRoot} worktree add ${quotedPath} -b ${quotedBranch}` ``
  - `codex-worktree-session.ts:94`: same shape.
  No directory creation happens before the git send in either handler.
  (Note: `remove-worktrees-runner.ts` uses `node:child_process.spawn`, but that is the removal command, not creation.)

### Recommended minimal, testable seams

PowerShell (`scripts/dev-tools/new-claude-worktree-session.ps1` and the bundled template):
- Add one new advanced function, e.g. `New-WorktreeParentDirectory`, with an injectable scriptblock seam per `.claude/rules/powershell.md` (option 2, injectable delegate):
  ```powershell
  function New-WorktreeParentDirectory {
      param(
          [Parameter(Mandatory = $true)][string] $WorktreePath,
          [scriptblock] $NewDirectory = { param([string] $Path) New-Item -ItemType Directory -Force -Path $Path | Out-Null }
      )
      $parent = Split-Path -Parent $WorktreePath
      if ($parent) { & $NewDirectory $parent }
  }
  ```
  Call it in the script body between `Test-PreconditionsMet` and `Invoke-GitWorktreeAdd` (inside the `ShouldProcess` gate or its own gate). `New-Item -Force` is idempotent for existing directories and creates the whole chain.
- Note: the Pester integration test asserts "contains all seven expected function definitions" (`tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1:268-278`); a new function makes it eight.

TypeScript / Terminal.sendText path:
- Because the extension dispatches via `Terminal.sendText`, the guard must itself be a PowerShell command string emitted by the pure builders. Add a new field to `WorktreeSessionCommands` and `CodexWorktreeSessionCommands`, e.g.:
  ```ts
  ensureParentDirectory: `New-Item -ItemType Directory -Force -Path ${quoteForPwsh(parentDirectory)} | Out-Null`,
  ```
  where `parentDirectory` is `<parent>/<repoName>-wt` (derivable inside `buildWorktreePath`'s module; simplest is a sibling helper `buildWorktreeGroupDirectory(workspaceParent, repoName)` used by both the path builder and the command builders, so path and guard cannot drift). The handlers send it with its own `sendText` immediately before `commands.git`.
- Tradeoff of the alternative (prefixing the git string with `New-Item ...;`): avoids changing sendText call-count assertions in extension tests, but mixes two concerns in one command line and is harder to assert in isolation. The separate-field approach matches the existing one-command-per-prompt design documented at `claude-worktree-session.ts:34-40`.

## 2. `workspace-encoding.ts` — does `-wt-` matching survive the new scheme?

File: `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts`

- Line 19: `const WORKTREE_INFIX = "-wt-";`
- Lines 30-32: `encodeWorkspacePath` = `workspacePath.replace(/[\\/:]/g, "-")` (every `\`, `/`, `:` becomes `-`).
- Lines 50-64: `matchEncodedDirectories` matches a candidate when it equals the encoded workspace name or `startsWith(`${target}${WORKTREE_INFIX}`)` (case-insensitive).

Encoded names, worked example (workspace root `C:/Users/x/repo`, encoded target `C--Users-x-repo`):

| Scheme | Worktree path | Encoded directory name |
|---|---|---|
| OLD | `C:/Users/x/repo-wt-2026-07-07-12-00` | `C--Users-x-repo-wt-2026-07-07-12-00` |
| NEW | `C:/Users/x/repo-wt/2026-07-07T12-00` | `C--Users-x-repo-wt-2026-07-07T12-00` |

In the NEW scheme the `/` between `repo-wt` and the timestamp encodes to `-`, so the encoded name still begins with `C--Users-x-repo` + `-wt-`. The `T` is not in the replaced character class `[\\/:]` and stays literal, appearing only after the prefix already matched. Therefore the existing prefix match **still matches the new scheme with zero functional change**.

Two secondary cases also verified:
- Opening the nested worktree itself as the workspace: `encodeWorkspacePath("C:/Users/x/repo-wt/2026-07-07T12-00")` = `C--Users-x-repo-wt-2026-07-07T12-00`, which equals the on-disk transcript directory name exactly (equality branch, line 60).
- Worktree-of-a-worktree under the new scheme (workspace root is the leaf `.../repo-wt/2026-07-07T12-00`; `repoName` becomes `2026-07-07T12-00`, producing `.../repo-wt/2026-07-07T12-00-wt/2026-07-08T09-00`): encodes to `C--Users-x-repo-wt-2026-07-07T12-00-wt-2026-07-08T09-00`, which begins with `<encoded leaf>` + `-wt-`. Still matches.

Required change: **none to logic**. Recommended: update the doc comments (lines 38-43 describe `-wt-` as a "per-worktree sibling" name; under the new scheme the `-wt-` in the encoded name comes from `-wt` + encoded `/`) and add new-scheme test cases (see section 6).

Callers (complete, verified by repo-wide grep):
- `matchEncodedDirectories`: `extensions/drm-copilot/src/subagent-tree-command.ts:118` (in `discoverRootSessionCandidates`); tests at `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`.
- `encodeWorkspacePath`: `extensions/drm-copilot/src/subagent-tree-command.ts:116`; same test file.

## 3. Remove Secondary Worktrees under the nested scheme

Files: `extensions/drm-copilot/src/remove-worktrees.ts`, `extensions/drm-copilot/src/remove-worktrees-runner.ts`, wiring in `extension.ts:340-377`.

- Discovery is **purely porcelain-based**. `removeAllSecondaryWorktrees` (`remove-worktrees-runner.ts:99-160`) runs `git worktree list --porcelain` (line 104-107), parses blocks with `parseWorktreePorcelain` (`remove-worktrees.ts:64-118`), and selects non-primary entries positionally (`selectSecondaryWorktrees`, lines 130-134). There is no `-wt-` or path-pattern matching anywhere in either file. Nested `<repoName>-wt/<timestamp>` worktrees will therefore be discovered and removed with no change.
- Removal is `git worktree remove <path>` (runner lines 135-138, NON-force). `git worktree remove` deletes the worktree directory itself; it does not delete parent directories. After removing the last leaf under `<repoName>-wt`, an **empty `<repoName>-wt` directory remains on disk**. No code in the runner or the extension performs any parent-directory cleanup (the runner deliberately imports no `node:fs`).

Empty-parent cleanup — options (decision for spec, not decided here):

1. **Do nothing (smallest scope).** One leftover empty `<repoName>-wt` folder per repo, versus the many flat folders the feature eliminates. No new I/O seam, no new failure modes. The folder is reused by the next session.
2. **Best-effort cleanup in the runner.** After the removal loop, for each removed path compute its parent; if the parent's basename ends with `-wt` and the directory is now empty, remove it. Requires a filesystem seam (injectable, mirroring the `GitRunner` pattern) plus tests; must handle the caller-supplied custom `WorktreeParentPath` case in the PowerShell script (a custom parent will not end in `-wt` and must never be deleted). Adds scope to a command whose contract is currently "git state only".
3. **Cleanup scoped by name and emptiness only, reported in the summary.** Same as 2 but surfaced in `WorktreeSummary`/message so the behavior is observable. Largest test surface.

Tradeoff summary: option 1 preserves the runner's pure-git contract and the smallest diff; options 2/3 trade a new I/O boundary and tests for a tidier disk. The acceptance criteria require only that removal still works (it does, unchanged); cleanup is an enhancement.

## 4. Branch naming (decision point)

Current: `Build-BranchName` (`new-claude-worktree-session.ps1:60-78`) and `buildBranchName` (`claude-worktree-session.ts:103-105`) both return `<repoName>-wt-<timestamp>`. The user requirement is explicitly about the **folder**; branch naming is an open decision.

Git refname facts relevant to the choice:
- Slashes are legal in branch names (hierarchical refs). `git check-ref-format` forbids components starting with `.`, ending with `.lock`, `..`, `//`, trailing `/`, and control characters; `T` and `-` are legal. `2026-07-07T12-00` is a valid component.
- Refname collision risk: because loose refs are stored as files/directories, a branch `foo` cannot coexist with `foo/bar`. Adopting `repo-wt/<timestamp>` fails if a branch literally named `repo-wt` ever exists (and conversely blocks creating one). Existing flat branches `repo-wt-<ts>` do **not** collide with `repo-wt/<ts>` (different names), so migration is not blocked either way.

Recommended policy: **keep the flat branch name, adopting only the new timestamp format**: `<repoName>-wt-<yyyy-MM-ddTHH-mm>` (e.g. `drm-copilot-wt-2026-07-07T12-00`). Justification:
- Zero refname-collision risk; no dependence on no-branch-named-`<repo>-wt` invariants.
- Keeps `Build-BranchName`/`buildBranchName` signatures and the `-b` dispatch unchanged; only the timestamp input changes.
- Terminal names (`Claude: ${branchName}`, `extension.ts:194`; `Codex: ...`, line 302) and the test regexes `/^Claude: workspace-wt-/` remain structurally valid.
- The folder-organization goal is fully met by the directory change; branches are not browsed as a folder tree in the same way.

Rejected alternative: `repo-wt/<timestamp>` slash branch. Advantage: mirrors the folder hierarchy and groups branches in `git branch` listings/UIs. Disadvantages: `foo` vs `foo/bar` collision class; larger test churn (`buildBranchName`, terminal-name regexes, Pester assertions); no functional benefit for the stated requirement.

## 5. Timestamp format

Both formatters must change and must stay consistent (the TS docstring at `claude-worktree-session.ts:59-61` explicitly documents parity with the PowerShell helper):

- `scripts/dev-tools/new-claude-worktree-session.ps1:40`: `return $now.ToString('yyyy-MM-dd-HH-mm')` → `'yyyy-MM-ddTHH-mm'`.
- `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1:40`: identical line, same change.
- `extensions/drm-copilot/src/claude-worktree-session.ts:64-71` (`formatWorktreeTimestamp`): line 70 `` return `${year}-${month}-${day}-${hour}-${minute}`; `` → `` `${year}-${month}-${day}T${hour}-${minute}` ``. Doc comments at lines 56, 62, 77, 99 reference `yyyy-MM-dd-HH-mm` and must be updated.

Length note: the new format is still 16 characters (`2026-07-07T12-00`), so the "16-character" claims in the docstring (line 62) and test name (`claude-worktree-session.test.ts:12`, plus `toHaveLength(16)` at line 32) remain numerically true after separator updates.

Round-tripping: repo-wide search (`yyyy-MM-dd-HH-mm` and timestamp-shaped regexes outside `docs/`) found **no production code that parses the worktree timestamp back**. The only pattern-matching consumers are test regexes (`extension.workflow-commands.test.ts:321,324` use `\d{4}-\d{2}-\d{2}-\d{2}-\d{2}`) and the encoded-name prefix matcher (section 2), which does not inspect the timestamp. The new format also aligns with the repo-wide artifact timestamp convention (`yyyy-MM-ddTHH-mm`, per evidence/timestamp conventions).

## 6. Tests requiring update (complete enumeration)

PowerShell — `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`:
- Line 20-24: `It "returns correct yyyy-MM-dd-HH-mm format for injected fixed datetime"` — expects `"2026-04-20-09-59"`; becomes `"2026-04-20T09-59"` (rename the It as well).
- Lines 34-37: `It "output contains the repoName-wt- segment"` — asserts `Should -Match "auth-wt-"`; the nested path contains `auth-wt/`, so this assertion must change (e.g. `-Match "auth-wt/"`).
- Lines 39-42: `It "output ends with the timestamp"` — `-Match "-2026-04-20-09-59$"`; becomes `/2026-04-20T09-59$` (leading separator is now `/`).
- Lines 44-47: `It "full path matches expected format"` — `Should -Be "/parent/auth-wt-2026-04-20-09-59"` → `"/parent/auth-wt/2026-04-20T09-59"`.
- Lines 57-60: `It "returns default repoName-wt-timestamp branch when BranchName is empty"` — `Should -Be "auth-wt-2026-04-20-09-59"`; under the recommended policy becomes `"auth-wt-2026-04-20T09-59"` (timestamp input changes; builder logic unchanged).
- Lines 268-278: `It "contains all seven expected function definitions"` — add the new parent-directory function and update the count.
- New tests needed: parent-directory creation function (creates missing chain, idempotent when present, seam-injected).

TypeScript — `extensions/drm-copilot/test/claude-worktree-session.test.ts`:
- `describe("formatWorktreeTimestamp")` lines 11-34: expected values `"2026-04-20-09-59"` (line 20) and `"2026-01-01-00-00"` (line 31) become `T`-separated; test names updated.
- `describe("buildWorktreePath")` lines 36-71: expected values at lines 47, 58, 69 (`/parent/auth-wt-2026-04-20-09-59`, `C:/repos/auth-wt-2026-04-20-09-59`) become nested (`/parent/auth-wt/2026-04-20T09-59`, etc.).
- `describe("buildBranchName")` lines 73-81: expected `"auth-wt-2026-04-20-09-59"` — timestamp fixture only, if flat policy adopted.
- `describe("buildWorktreeSessionCommands")` lines 117-323: `baseInput` fixture paths/branch (lines 120-121) and expected `git`/`setLocation` strings (lines 135, 148) are fixture-only updates; plus new tests for the `ensureParentDirectory` command if the recommended seam is adopted.

TypeScript — `extensions/drm-copilot/test/extension.workflow-commands.test.ts`:
- Line 294: `expect(terminalOptions.name).toMatch(/^Claude: workspace-wt-/)` — valid under flat branch policy; must change if slash branches are adopted.
- Line 308: `expect(terminal.sendText).toHaveBeenCalledTimes(2)` and the call-index destructuring at lines 309-314, 330-331 — an added `ensureParentDirectory` sendText shifts counts/indices in this test and in every ordering test in the file (its at lines 262, 344, 390, 420, 450, 488, 521, 565, 603).
- Line 321: `/-b 'workspace-wt-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}'$/` → `T` separator.
- Line 324: `/^Set-Location 'C:\/workspace-wt-\d{4}-...'$/` → `C:\/workspace-wt\/\d{4}-\d{2}-\d{2}T\d{2}-\d{2}`.

TypeScript — `extensions/drm-copilot/test/codex-worktree-session.test.ts`:
- Lines 46-47 (fixture `worktreePath`/`branchName`), 58 (`git` expectation), 61 (`Set-Location`), 122 (`-WorktreeRoot 'C:/workspace-wt-2026-04-20-09-59'`) — fixture/expectation updates; plus new `ensureParentDirectory` coverage.

TypeScript — `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`:
- Line 60: `/^Codex: workspace-wt-/` (branch-policy dependent, same as above).
- Lines 91, 156, 189, 221: `expect(postCmd).toContain("-WorktreeRoot 'C:/workspace-wt-")` — under the nested scheme the path is `C:/workspace-wt/...`, so these substrings **fail as written** and must become `"-WorktreeRoot 'C:/workspace-wt/"`.
- sendText call-count/index assertions in this file shift if a new command is inserted.

TypeScript — `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`:
- Existing tests (lines 33-119) use old-scheme encoded names and continue to pass; they represent historical on-disk directories and should be retained.
- Add new-scheme cases: encoded sibling `C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-07T12-00` matches; nested worktree-of-worktree new-scheme name matches; exact-equality match when the workspace root is the nested leaf.

Not affected (verified): `tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1` uses `C:/repo-wt/...` only as arbitrary destination fixture strings, not the naming convention; `extension-test-harness.ts` references only the config section name.

## 7. Other repo consumers of the `-wt-` convention

Repo-wide search for `-wt-`/`-wt/` excluding `docs/` and `artifacts/` found consumers only in the files already listed above. Specifically verified as **not** requiring change:
- `extensions/drm-copilot/package.json` — command metadata (lines 157-158) and the `preClaudeScriptPath` setting (lines 46-49) contain no path-scheme text.
- `README.md` (root, lines 150, 162) and `extensions/drm-copilot/README.md` (New Claude Worktree Session section) describe the commands but never state the `-wt-` path pattern (grep for `wt-`/`wt/` in both files: no matches).
- No `.claude/hooks`, skills, or scripts outside the files above reference the convention.
- `docs/features/completed/**` contain historical `-wt-` references; historical artifacts are not updated.

Bundled template status: `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` is content-identical to `scripts/dev-tools/new-claude-worktree-session.ps1` (verified by full line-by-line reads of both). No production code references this template path (repo-wide grep for `templates/new-claude` and `new-claude-worktree-session.ps1` outside `docs/` matches only the Pester test pointing at the `scripts/dev-tools` copy). It ships with the extension but is currently unreferenced; it should be updated in lockstep to preserve parity (its removal would be a separate scope decision).

## Recommended approach (single recommendation)

1. Change `Build-WorktreePath` (script + template) to `"$WorktreeParentPath/$RepoName-wt/$Timestamp"` and `Get-WorktreeTimestamp` to `'yyyy-MM-ddTHH-mm'`; add `New-WorktreeParentDirectory` with an injectable `New-Item -Force` seam, invoked before `Invoke-GitWorktreeAdd`.
2. Change `formatWorktreeTimestamp` to emit the `T` separator and `buildWorktreePath` to emit `${normalizedParent}/${repoName}-wt/${timestamp}`; add an `ensureParentDirectory` PowerShell command field to both `WorktreeSessionCommands` and `CodexWorktreeSessionCommands` (built with `quoteForPwsh`), sent via its own `Terminal.sendText` before the git command in both `extension.ts` handlers.
3. Keep branch names flat: `<repoName>-wt-<yyyy-MM-ddTHH-mm>` (decision point — see Open decisions).
4. Leave `workspace-encoding.ts` logic unchanged; update comments and add new-scheme tests.
5. Leave remove-worktrees behavior unchanged (porcelain-driven discovery already covers nested paths); empty-parent cleanup is an open decision.

Rejected alternatives (brief): relying solely on git's implicit leading-directory creation (fails the explicit acceptance criterion; behavior lives in git internals rather than testable repo code); folding the `mkdir` into the git command string (mixes concerns, harder to test in isolation); slash-style branch names (refname collision class `foo` vs `foo/bar`, larger test churn, no requirement benefit).

## Files requiring change

- `scripts/dev-tools/new-claude-worktree-session.ps1` (timestamp format line 40; path builder line 57; branch default line 77 comment/timestamp; new parent-dir function; header comment line 19)
- `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` (identical changes, lockstep)
- `extensions/drm-copilot/src/claude-worktree-session.ts` (`formatWorktreeTimestamp` line 70; `buildWorktreePath` line 93; docs lines 56-99; new `ensureParentDirectory` field in `WorktreeSessionCommands`/`buildWorktreeSessionCommands`)
- `extensions/drm-copilot/src/codex-worktree-session.ts` (new `ensureParentDirectory` field in `CodexWorktreeSessionCommands`/`buildCodexWorktreeSessionCommands`)
- `extensions/drm-copilot/src/extension.ts` (send the new command before `commands.git` in both handlers, lines ~207 and ~309)
- `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` (assertions enumerated in section 6)
- `extensions/drm-copilot/test/claude-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`
- `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
- `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` (additive new-scheme cases)
- `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts` (comment-only)

## Files to verify but likely unchanged

- `extensions/drm-copilot/src/remove-worktrees.ts` and `remove-worktrees-runner.ts` (porcelain-driven; no pattern dependence)
- `extensions/drm-copilot/src/subagent-tree-command.ts` (caller of unchanged matcher)
- `extensions/drm-copilot/package.json`, `README.md` (root), `extensions/drm-copilot/README.md` (no path-scheme text)
- `extensions/drm-copilot/test/extension-test-harness.ts` (config-section reference only)
- `tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1` (fixture strings only)

## Open decisions for spec

1. **Branch naming**: flat `<repoName>-wt-<yyyy-MM-ddTHH-mm>` (recommended) versus nested-style `<repoName>-wt/<timestamp>` (refname collision risk: a branch named `<repoName>-wt` cannot coexist with `<repoName>-wt/<ts>`; extra test churn in terminal-name regexes).
2. **Empty-parent cleanup in Remove Secondary Worktrees**: none (recommended smallest scope; one empty `<repoName>-wt` folder can remain), best-effort silent cleanup of empty `*-wt` parents, or cleanup surfaced in the removal summary (options and tradeoffs in section 3).
3. **Bundled template**: update in lockstep (recommended) or remove the unreferenced `resources/templates/new-claude-worktree-session.ps1` in a separate change.

## Testing implications (strategy, no code)

- Pester: assert new nested path/timestamp outputs; new seam-injected tests for parent-directory creation (chain creation, idempotence); update the function-count integration assertion. No temporary files — the seam scriptblock captures the requested path instead of touching disk.
- Vitest: fixed-`Date` formatter tests for the `T` separator; nested-path builder tests including backslash-parent and trailing-slash normalization; `ensureParentDirectory` command-string tests (quoting, parent derivation); handler ordering tests updated for the added sendText (fake timers already in use); additive workspace-encoding new-scheme match tests. Both toolchains run via the mandatory format → lint/analyze → typecheck (TS) → test loops.

## Automation Feasibility

Not applicable. Every step in this change is local git/filesystem/code work (PowerShell script, TypeScript builders, unit tests); no step requires third-party UI interaction.

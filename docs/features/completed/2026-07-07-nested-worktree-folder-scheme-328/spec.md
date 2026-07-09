# nested-worktree-folder-scheme — Spec

- **Issue:** #328
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-07T13-00
- **Status:** Ready
- **Version:** 1.0
- **Research:** [research/2026-07-07T12-30-nested-worktree-folder-scheme-328-research.md](research/2026-07-07T12-30-nested-worktree-folder-scheme-328-research.md)

## Overview

The `drm-copilot: New Claude Worktree Session` command creates each new worktree as a
sibling directory named `<repoName>-wt-<yyyy-MM-dd-HH-mm>`. Over time this produces a
proliferation of flat sibling folders in the repos directory, which is disorganized and
hard to browse.

This feature changes the on-disk worktree scheme to a nested layout: a single grouping
directory `<repoName>-wt` per repository, containing one timestamped leaf directory per
worktree session. The branch naming scheme remains flat. The `Remove Secondary
Worktrees` command gains empty-parent cleanup so the grouping directory does not linger
after the last worktree is removed.

## Behavior

### 1. Worktree path scheme (nested)

New worktrees are created at:

```
<parent>/<repoName>-wt/<yyyy-MM-ddTHH-mm>
```

replacing the previous flat scheme `<parent>/<repoName>-wt-<yyyy-MM-dd-HH-mm>`.

- The grouping directory `<repoName>-wt` holds all timestamped worktrees for the repo.
- The leaf directory name is the timestamp only.
- Applies identically to the Claude and Codex worktree session paths (both are built by
  the same path builder inputs and must emit the same scheme).

### 2. Timestamp format

The timestamp format is `yyyy-MM-ddTHH-mm`:

- Literal `T` between the date and time components.
- 24-hour `HH`.
- 16 characters total (e.g. `2026-07-07T12-00`), same length as the previous format.

This format applies to **both** formatters, which must stay consistent:

- PowerShell `Get-WorktreeTimestamp` in `scripts/dev-tools/new-claude-worktree-session.ps1`
  (format string `'yyyy-MM-ddTHH-mm'`).
- TypeScript `formatWorktreeTimestamp` in
  `extensions/drm-copilot/src/claude-worktree-session.ts` (emit
  `${year}-${month}-${day}T${hour}-${minute}`).

Consistency is verified by unit tests in both toolchains asserting identical output for
an equivalent fixed date-time fixture. No production code parses the worktree timestamp
back (verified in research section 5), so no parser changes are required.

### 3. Parent-directory creation (explicit, idempotent)

The `<repoName>-wt` grouping directory must be created if it does not exist, **before**
`git worktree add` runs. Creation must be idempotent: running it when the directory
already exists is a no-op and not an error. The implementation must not rely on git's
implicit leading-directory creation.

Implementations:

- **PowerShell script** (`scripts/dev-tools/new-claude-worktree-session.ps1` and the
  bundled template): a new advanced function (e.g. `New-WorktreeParentDirectory`) with
  an injectable scriptblock seam for the filesystem operation
  (`New-Item -ItemType Directory -Force`), invoked between the precondition check and
  `Invoke-GitWorktreeAdd`. `-Force` provides idempotence and full-chain creation.
- **TypeScript / extension path**: the extension dispatches via `Terminal.sendText`, so
  the guard is a PowerShell command string emitted by the pure command builders. Add an
  `ensureParentDirectory` field (a guarded, idempotent
  `New-Item -ItemType Directory -Force -Path '<parent>/<repoName>-wt' | Out-Null`
  command, quoted with `quoteForPwsh`) to both `WorktreeSessionCommands`
  (`claude-worktree-session.ts`) and `CodexWorktreeSessionCommands`
  (`codex-worktree-session.ts`). Both `extension.ts` handlers send it via its own
  `terminal.sendText` immediately **before** the git command. The grouping-directory
  path must be derived by a shared helper used by both the path builder and the command
  builders so the worktree path and the guard cannot drift.

### 4. Branch naming — remains flat (explicit decision)

The branch name **remains flat**:

```
<repoName>-wt-<yyyy-MM-ddTHH-mm>
```

The branch name is **not** nested with a slash (`<repoName>-wt/<timestamp>` is
explicitly rejected). Only the timestamp portion changes (the `T` separator); the
`Build-BranchName` / `buildBranchName` structure and the `git worktree add ... -b`
dispatch are unchanged.

Rationale (decided; do not reopen): git stores loose refs as files/directories, so a
branch `foo` cannot coexist with `foo/bar`. A nested branch `<repoName>-wt/<ts>` would
collide with any branch literally named `<repoName>-wt` and vice versa. Keeping the
branch flat eliminates that refname collision class and minimizes blast radius
(terminal names, test regexes, and builder signatures stay structurally valid). The
folder-organization goal is fully met by the directory change alone.

### 5. Remove Secondary Worktrees — discovery unchanged, empty-parent cleanup added

Discovery and removal are already porcelain-based (`git worktree list --porcelain`
parsed by `parseWorktreePorcelain`, non-primary entries selected positionally, removed
via `git worktree remove <path>`). Nested worktrees are therefore discovered and
removed with **no change to discovery logic**.

New behavior — empty-parent cleanup:

- After all secondary worktrees have been removed, if the `<repoName>-wt` grouping
  directory exists and is now **empty**, remove it.
- The removal of the grouping directory is **reported in the operation summary**
  (surfaced in `WorktreeSummary` / the completion message) so the behavior is
  observable.
- The cleanup must **never** remove a non-empty directory. Emptiness is checked
  immediately before removal; any remaining entry (file or directory) aborts the
  cleanup for that parent without error.
- The primary worktree must remain safe: cleanup applies only to the grouping directory
  of removed secondary worktrees, never to the primary worktree path or its parent.
- The cleanup decision logic must be **pure and unit-testable**: filesystem access
  (existence check, directory listing, directory removal) goes through an injectable
  seam mirroring the existing `GitRunner` injection pattern; the pure logic decides
  *whether* to remove given the listing, and the seam performs I/O.
- A caller-supplied custom worktree parent that does not follow the `<repoName>-wt`
  naming pattern must never be deleted; cleanup is scoped to parents whose basename
  ends with `-wt` and that are empty.

### 6. subagent-tree workspace-encoding — no functional change

`matchEncodedDirectories` in
`extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts` requires **no
logic change**. Under the new scheme, the `/` between `<repoName>-wt` and the timestamp
encodes to `-` (the encoder replaces `[\\/:]` with `-`) and the `T` stays literal, so
the encoded directory name still begins with `<encodedTarget>-wt-` and the existing
prefix match resolves it (verified in research section 2, including the
worktree-of-a-worktree and workspace-root-is-the-leaf cases).

In scope: doc-comment updates (the comments describe `-wt-` as a per-worktree sibling
name; under the new scheme the `-wt-` in the encoded name arises from `-wt` plus the
encoded `/`) and **additive** test cases for new-scheme encoded names. Matching
behavior must not be altered; existing old-scheme tests are retained (they represent
historical on-disk directories).

### 7. Bundled template — updated in lockstep

`extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` is
content-identical to `scripts/dev-tools/new-claude-worktree-session.ps1` and must
receive the identical changes (timestamp format, nested path builder, parent-directory
function and invocation). The template is not deleted. Parity between the two files
must hold after the change.

## Inputs / Outputs

- Inputs: unchanged. The command derives repo name and parent directory from the
  current workspace; an optional caller-supplied worktree parent path remains supported
  by the PowerShell script.
- Outputs: a worktree at `<parent>/<repoName>-wt/<yyyy-MM-ddTHH-mm>` on a flat branch
  `<repoName>-wt-<yyyy-MM-ddTHH-mm>`; on removal, an operation summary that reports
  removed worktrees and, when applicable, the removed empty `<repoName>-wt` grouping
  directory.
- Config keys and defaults: none added or changed (`package.json` command metadata and
  the `preClaudeScriptPath` setting contain no path-scheme text).
- Backward compatibility: existing flat-scheme worktrees and branches are untouched.
  Flat branches `<repoName>-wt-<old-ts>` do not collide with anything introduced here.
  The workspace-encoding matcher continues to resolve both old-scheme and new-scheme
  encoded directory names.

## API / CLI Surface

- `drm-copilot: New Claude Worktree Session` — behavior change only (path scheme,
  timestamp separator, parent-directory guard sent as an additional terminal command
  before the git command). No new user-facing flags.
- `drm-copilot: New Codex Worktree Session` — same path/timestamp/guard changes via
  `CodexWorktreeSessionCommands`.
- `drm-copilot: Remove Secondary Worktrees` — unchanged invocation; summary additionally
  reports removal of an emptied `<repoName>-wt` grouping directory.
- Contract additions: `WorktreeSessionCommands.ensureParentDirectory` and
  `CodexWorktreeSessionCommands.ensureParentDirectory` (PowerShell command strings,
  pure-builder output).
- Example: repo `auth` at `/parent/auth`, timestamp fixture `2026-04-20T09-59` →
  worktree path `/parent/auth-wt/2026-04-20T09-59`, branch `auth-wt-2026-04-20T09-59`,
  guard command `New-Item -ItemType Directory -Force -Path '/parent/auth-wt' | Out-Null`.

## Data & State

- On-disk layout: one `<repoName>-wt` grouping directory per repo parent; one
  timestamped leaf per session. No migration of existing flat worktrees is performed.
- Invariants: PowerShell and TypeScript formatters emit byte-identical timestamps for
  the same instant; path builder and `ensureParentDirectory` derive the grouping
  directory from one shared helper; branch name never contains `/`.
- State transitions on removal: secondary worktrees removed via git; grouping directory
  removed only when empty; primary worktree and non-`-wt` custom parents never removed.
- No caching, persistence, or backfill requirements.

## Constraints & Risks

- Cross-cutting change spanning PowerShell (`scripts/dev-tools`), the bundled resource
  template, and TypeScript (`extensions/drm-copilot/src`). Lockstep parity between the
  script and template must be maintained.
- The worktree naming convention is consumed by `subagent-tree/workspace-encoding.ts`
  (`WORKTREE_INFIX = "-wt-"`); the encoded directory name continues to match with no
  logic change (verified), but the matcher's behavior must be protected by additive
  tests, not modified.
- The added `ensureParentDirectory` sendText shifts call-count and call-index
  assertions across the extension workflow tests; all affected tests must be updated
  (enumerated in research section 6).
- Empty-parent cleanup introduces a filesystem boundary into a command whose contract
  was previously git-only; the seam must be injectable and the decision logic pure so
  no test touches the real filesystem (temporary files in tests are prohibited).
- PowerShell constraints: PoshQC format/analyze/test loop; wrapper/scriptblock seams
  for git and filesystem access; files under 500 lines; PowerShell 7+.
- TypeScript constraints: Prettier/ESLint/tsc/Vitest loop; pure command-builder modules
  remain side-effect free (no `vscode`, `node:fs`, or `node:child_process` imports);
  kebab-case filenames.

## Implementation Strategy

- Scope (what changes):
  - `scripts/dev-tools/new-claude-worktree-session.ps1` — timestamp format
    (`'yyyy-MM-ddTHH-mm'`), nested path in `Build-WorktreePath`, new
    `New-WorktreeParentDirectory` (injectable seam) invoked before
    `Invoke-GitWorktreeAdd`, header comment.
  - `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` —
    identical changes, lockstep.
  - `extensions/drm-copilot/src/claude-worktree-session.ts` — `T` separator in
    `formatWorktreeTimestamp`, nested `buildWorktreePath`, shared grouping-directory
    helper, `ensureParentDirectory` field, doc comments.
  - `extensions/drm-copilot/src/codex-worktree-session.ts` — `ensureParentDirectory`
    field.
  - `extensions/drm-copilot/src/extension.ts` — send `ensureParentDirectory` before
    `commands.git` in both session handlers.
  - `extensions/drm-copilot/src/remove-worktrees.ts` /
    `remove-worktrees-runner.ts` — pure empty-parent cleanup decision logic plus an
    injectable filesystem seam; summary reporting.
  - `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts` —
    doc comments only.
  - Test updates and additions per research section 6 (Pester and Vitest).
- Dependency changes: none.
- Logging/telemetry: removal summary extended to report grouping-directory cleanup; no
  other logging changes.
- Rollout: no feature flag. New sessions use the nested scheme immediately; existing
  flat worktrees continue to work and are removable via the unchanged porcelain-based
  discovery.

## Acceptance Criteria

- [x] New worktrees are created at `<parent>/<repoName>-wt/<yyyy-MM-ddTHH-mm>`.
- [x] The `<repoName>-wt` grouping directory is created when missing, before
      `git worktree add` runs, and creation is idempotent when the directory already
      exists.
- [x] The timestamp format is `yyyy-MM-ddTHH-mm` (literal `T`, 24-hour `HH`) in both
      the PowerShell `Get-WorktreeTimestamp` and the TypeScript
      `formatWorktreeTimestamp`, and unit tests verify the two formatters are
      consistent for an equivalent fixed date-time fixture.
- [x] The branch name remains flat `<repoName>-wt-<yyyy-MM-ddTHH-mm>` (no slash-nested
      branch names are produced).
- [x] `drm-copilot: Remove Secondary Worktrees` still discovers and removes worktrees
      created under the nested scheme.
- [x] After secondary-worktree removal, an emptied `<repoName>-wt` grouping directory
      is removed and the removal is reported in the operation summary; a non-empty
      grouping directory is never removed; the primary worktree is never removed.
- [x] The `workspace-encoding.ts` matcher continues to resolve transcript directories
      for the new scheme with no change to matching logic, covered by additive test
      cases (old-scheme tests retained).
- [x] The PowerShell script and the bundled template
      (`extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`)
      produce the new scheme identically (lockstep parity maintained).
- [x] All existing tests affected by the scheme change are updated, and new behavior
      (parent-directory creation, `ensureParentDirectory` command, empty-parent
      cleanup, new-scheme encoding matches) has unit coverage meeting repository
      thresholds (line >= 85%, branch >= 75%).

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Path/branch builder unit tests (PowerShell Pester + Vitest): nested path output,
      flat branch output, backslash-parent and trailing-slash normalization.
- [ ] Timestamp formatter unit tests for the `T` separator (fixed date-time fixtures,
      16-character length, cross-toolchain consistency).
- [ ] Parent-directory creation behavior: seam-injected chain creation, idempotence
      when the directory exists, invocation ordering before `git worktree add`, and the
      `ensureParentDirectory` command string (quoting, parent derivation).
- [ ] Remove-worktrees discovery under the nested scheme (porcelain fixtures) plus
      empty-parent cleanup: removes an empty `*-wt` parent and reports it; skips a
      non-empty parent; never targets the primary or a non-`-wt` custom parent.
- [ ] workspace-encoding matcher under the encoded nested path: sibling new-scheme
      match, worktree-of-a-worktree match, exact-equality match when the workspace
      root is the nested leaf; old-scheme cases retained.

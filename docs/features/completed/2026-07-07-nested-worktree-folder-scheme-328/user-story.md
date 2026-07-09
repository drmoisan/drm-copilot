# `nested-worktree-folder-scheme` — User Story

- Issue: #328
- Owner: drmoisan
- Status: Ready
- Last Updated: 2026-07-07T13-00

## Story Statement

- As a developer who runs multiple Claude/Codex worktree sessions per day, I want each
  repo's worktrees grouped under a single `<repoName>-wt` folder with timestamp-named
  leaves, so that my repos directory stays organized and easy to browse.
- As a developer cleaning up finished sessions, I want `Remove Secondary Worktrees` to
  also remove the `<repoName>-wt` grouping folder when it becomes empty and tell me it
  did so, so that no stale empty folders accumulate after cleanup.

## Problem / Why

The `drm-copilot: New Claude Worktree Session` command creates each new worktree as a
sibling directory named `<repoName>-wt-<yyyy-MM-dd-HH-mm>`. Over time this produces a
proliferation of flat sibling folders in the repos directory, which is disorganized and
hard to browse. Nesting all timestamped worktrees under one `<repoName>-wt` grouping
directory per repo reduces the parent directory to at most one extra entry per repo.

## Personas & Scenarios

- Persona: Extension user running parallel agent sessions.
  - Who: a developer using the drm-copilot VS Code extension to spin up isolated
    worktree sessions for Claude and Codex agents.
  - Cares about: a tidy repos directory, fast session start, and reliable cleanup.
  - Constraints: works on Windows with PowerShell 7+; multiple repos share one parent
    directory; sometimes several sessions per repo per day.
  - Frustration: dozens of flat `<repo>-wt-<timestamp>` siblings clutter the parent
    directory and make the actual repos hard to find.

- Scenario: Creating a session under the nested scheme.
  - The developer opens repo `auth` and runs `drm-copilot: New Claude Worktree
    Session`.
  - The command ensures `/parent/auth-wt` exists (creating it if missing, silently
    succeeding if present), then creates the worktree at
    `/parent/auth-wt/2026-07-07T14-30` on branch `auth-wt-2026-07-07T14-30`.
  - A second session later the same day lands at `/parent/auth-wt/2026-07-07T16-05`;
    the parent directory still shows only `auth` and `auth-wt`.
  - The subagent-tree command continues to resolve the session's transcript directory,
    because the encoded worktree name still carries the `-wt-` infix.

- Scenario: Cleaning up sessions.
  - The developer runs `drm-copilot: Remove Secondary Worktrees` from the primary
    `auth` workspace.
  - Both nested worktrees are discovered via `git worktree list --porcelain` and
    removed; the now-empty `/parent/auth-wt` grouping directory is then removed, and
    the operation summary reports the worktree removals and the grouping-directory
    cleanup.
  - If any file or directory remained inside `auth-wt`, the grouping directory would be
    left in place; the primary `auth` worktree is never touched.

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

## Non-Goals

- Nesting the branch name (`<repoName>-wt/<timestamp>`): explicitly rejected due to git
  refname collision risk (`foo` vs `foo/bar`) and larger blast radius; branches remain
  flat.
- Migrating or renaming existing flat-scheme worktrees or branches; they remain valid
  and removable.
- Changing `matchEncodedDirectories` logic in `workspace-encoding.ts`; only doc
  comments and additive tests are in scope.
- Removing the bundled template
  `resources/templates/new-claude-worktree-session.ps1`; it is updated in lockstep, not
  deleted.
- Any change to command names, configuration keys, or required-check configuration.

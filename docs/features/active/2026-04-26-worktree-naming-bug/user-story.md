# User Story — Worktree Naming Bug Fix

## Story

As a developer using the `drm-copilot: New Claude Worktree Session` command from any repository,
I want the resulting worktree directory and branch to be named using my current repository's name and a readable timestamp,
So that I can identify which repository a worktree belongs to and when it was created without confusion.

## Scenarios

### Scenario 1 — Worktree prefix reflects the destination repo

**Given** I am working in a repository named `my-api`
**When** I run `drm-copilot: New Claude Worktree Session`
**Then** the worktree directory is named `my-api-wt-<timestamp>` (not `drm-copilot-wt-<timestamp>`)

### Scenario 2 — Timestamp is human-readable with no seconds

**Given** the command runs at 2026-04-26 19:31
**When** the worktree is created
**Then** the timestamp component is `2026-04-26-19-31` (dash-separated, no seconds)

### Scenario 3 — Branch name matches worktree directory name

**Given** the worktree is named `my-api-wt-2026-04-26-19-31`
**Then** the branch is also named `my-api-wt-2026-04-26-19-31` (no `feature/` prefix, no ShortName)

### Scenario 4 — No ShortName prompt is shown

**Given** I invoke the command
**When** the command executes
**Then** I am prompted only for an optional objective — not for a ShortName

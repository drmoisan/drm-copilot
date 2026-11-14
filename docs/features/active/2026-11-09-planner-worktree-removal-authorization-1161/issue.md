# planner-worktree-removal-authorization (Issue #1161)

- Date captured: 2026-11-09
- Status: Adopted -> docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/ (Issue #1161)
- Issue: #1161
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1161
- Last Updated: 2026-11-09
- Work Mode: full-feature

> Mirror note: this file mirrors the body of GitHub issue #1161, which was filed before orchestration and adopted read-only (`gh issue view`). The GitHub issue is the authoritative scope.

## Problem / Why

The epic worktree-removal gate cannot authorize removing a worktree that the epic planner created for preparation, because no checkpoint records it. A detached HEAD was the only way to free the branch.

## Proposed Behavior

- The epic planner records every worktree it creates (path, branch, purpose, preparation status) in its checkpoint.
- The removal gate accepts removal of a recorded preparation worktree once its feature's preparation is committed and pushed and the worktree has no uncommitted changes.

## Acceptance Criteria

- [ ] The epic planner checkpoint records each created worktree (path, branch, purpose, preparation status); validators tolerate and validate the new field.
- [ ] The removal gate allows removal of a recorded preparation worktree when preparation is committed and pushed and the worktree is clean.
- [ ] Tests cover allowed removal, a dirty worktree, an unrecorded worktree, and a worktree still in use.
- [ ] epic-plan skill, epic-planner agent and gate documentation updated.
- [ ] Recorded paths follow the never-encode-absolute-paths rule (store a worktree identity resolvable at runtime, not a host path), or the decision is recorded.

## Constraints & Risks

(not provided in potential file)

## Test Conditions

(not provided in potential file)

## Source

From: docs/features/potential/2026-11-09-planner-worktree-removal-authorization.md (lifecycle record not present in the repository at adoption time)

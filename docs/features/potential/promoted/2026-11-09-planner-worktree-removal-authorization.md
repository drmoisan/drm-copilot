# Worktree removal for planner-created worktrees (Issue #1161)

- Date captured: 2026-11-09
- Author: Dan Moisan (owner request), captured by Claude
- Status: Promoted -> docs/features/active/Worktree_removal_for_planner-created_worktrees/ (Issue #1161)

- Issue: #1161
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1161
- Last Updated: 2026-11-09
## Problem / Why

The epic worktree-removal gate cannot authorize removing a worktree that the epic planner created for preparation, because no checkpoint records it. A detached HEAD was the only way to free the branch.

## Proposed Behavior

- The epic planner records every worktree it creates (path, branch, purpose, preparation status) in its checkpoint.
- The removal gate accepts removal of a recorded preparation worktree once its feature's preparation is committed and pushed and the worktree has no uncommitted changes.

## Acceptance Criteria (early draft)

- [ ] The epic planner checkpoint records each created worktree (path, branch, purpose, preparation status); validators tolerate and validate the new field.
- [ ] The removal gate allows removal of a recorded preparation worktree when preparation is committed and pushed and the worktree is clean.
- [ ] Tests cover allowed removal, a dirty worktree, an unrecorded worktree, and a worktree still in use.
- [ ] epic-plan skill, epic-planner agent and gate documentation updated.
- [ ] Recorded paths follow the never-encode-absolute-paths rule (store a worktree identity resolvable at runtime, not a host path), or the decision is recorded.

## General Constraints (all harness-learnings workstreams)

- Keep pure logic (calculations, classification, scheduling, parsing) in host-neutral modules with unit tests; keep I/O (git, gh, filesystem, process inspection) in thin adapters.
- Inject clocks, randomness, filesystem and process seams; no temporary files and no wall-clock waits in tests.
- Every new configuration knob has a safe default that preserves today's behavior unless this entry states otherwise.
- Update the skill and agent documentation that describes each changed behavior, and keep the push-down payload consistent with it.
- New pushed-down code (skills, hooks, libs) is PowerShell or bash; TypeScript only for MCP or extension commands; no new Python.
- Existing gate decisions are unchanged except where this entry explicitly changes them, shown by parity or regression tests.
- New configuration keys are documented, validated, and default to today's behavior.
- The push-down payload carries every changed skill, agent, hook, and script.
- Delivered as its own issue and PR with unit tests for the pure logic, updated skill and agent documentation, and fully green CI.

## Source

Owner request of 2026-11-09: observations from a multi-feature epic with five features running in parallel on one shared development machine.

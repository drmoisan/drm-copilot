# Agent-isolated worktrees and session-root resolution in hooks (Issue #1163)

- Date captured: 2026-11-09
- Author: Dan Moisan (owner request), captured by Claude
- Status: Promoted -> docs/features/active/Agent-isolated_worktrees_and_session-root_resolution_in_hooks/ (Issue #1163)

- Issue: #1163
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1163
- Last Updated: 2026-11-09
## Problem / Why

- Stop hooks resolve child-agent checkpoints and outputs under the coordinator's main checkout instead of the child's worktree. That produced false negatives and reverted in-place fixes made by validators.
- Agents could not reliably locate their own worktree's checkpoint after a session moved between machines.

## Proposed Behavior

Every hook that reads a checkpoint or output resolves the target worktree from the delegation's branch and issue lines, or from the agent's working directory, never from the coordinator's root.

## Acceptance Criteria (early draft)

- [ ] A shared pure resolver chooses the target worktree from delegation branch/issue lines or the agent working directory, never the coordinator root; every checkpoint- or output-reading hook uses it.
- [ ] Tests cover a coordinator root that differs from the agent worktree, and a handoff checkpoint restored on a different host path.
- [ ] Validators no longer revert in-place fixes in the child worktree (regression test).
- [ ] Hook documentation and push-down payload updated.

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

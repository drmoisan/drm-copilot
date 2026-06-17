# `remove-secondary-worktrees-command` — User Story

- Issue: #194
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-06-17T16-01

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

The repository workflow creates secondary git worktrees (for example, the `New Claude Worktree Session` command creates `<repo>-wt-<timestamp>` worktrees). These accumulate and must be cleaned up. A draft PowerShell script exists at `scripts/dev-tools/remove-worktrees.ps1`, but it is untested, is not integrated into the extension workflow, and uses a Windows-centric file-lock probe that does not generalize. There is no extension command to remove secondary worktrees safely.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [x] A new extension command removes all secondary worktrees and never removes the primary worktree.
- [x] A worktree that cannot be fully removed is skipped and left intact; the command continues with remaining worktrees.
- [x] The command reports removed and skipped worktrees with reasons.
- [x] Implemented in TypeScript with pure logic separated from git I/O.
- [x] Unit tests cover positive, negative, and edge cases; coverage meets repository thresholds.
- [x] The command is registered in `package.json` contributions and `extension.ts`, and documented in the extension README.


## Non-Goals

Call out what is explicitly excluded from this feature.

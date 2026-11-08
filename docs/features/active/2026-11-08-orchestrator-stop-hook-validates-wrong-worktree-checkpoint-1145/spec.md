# orchestrator-stop-hook-validates-wrong-worktree-checkpoint (Spec)

- **Issue:** #1145
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T15-53
- **Status:** Draft
- **Version:** 0.1

## Context
The orchestrator SubagentStop hook validates the wrong checkpoint when the orchestrator worked in a different worktree from the one the hook runs in. It reads `artifacts/orchestration/orchestrator-state.json` from the hook's own working directory (the session root or the subagent's isolation worktree), not from the item worktree the orchestrator actually used, so it blocks or passes based on an unrelated checkpoint.

Environment:
- OS/version: Windows 11 Pro, Claude Code CLI
- Python version: n/a (PowerShell hooks)
- Command/flags used: `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08; also coordinator-launched orchestrators working in `.claude/worktrees/<name>`
- Data source or fixture: orchestrator delegation prompt naming the item worktree and branch; item checkpoint inside that worktree

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. From a coordinator session, launch `Agent(orchestrator)` with a prompt that names an item worktree (for example `.claude/worktrees/<name>`, branch `bug/x`) and work only there.
2. The orchestrator writes and updates the checkpoint in that worktree.
3. The orchestrator stops; `validate-orchestrator-output.ps1` (SubagentStop) runs.

Expected:
The stop hook resolves the target worktree the orchestrator worked in (via `Resolve-HookTargetWorktree`, or a worktree path or branch recorded in the delegation prompt or checkpoint) and validates that worktree's checkpoint.

Actual:
The hook validates the checkpoint in its own cwd (main checkout or isolation worktree): it blocks the orchestrator for errors in an unrelated checkpoint, or passes a stop that should have been blocked.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: stop-hook block naming a checkpoint path outside the orchestrator's item worktree.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Hooks run with the session's or subagent's cwd and main's scripts; payload cwd does not identify a coordinator's target item. `Resolve-HookTargetWorktree` exists (PRs #1113/#1120 fixed similar resolution for other hooks) but the orchestrator stop hook does not use it, or the delegation prompt's worktree/branch lines are not consulted. Related, already merged: #1140 and #1143 added `hook-epic-fan-in.ps1` with a scope-object seam; #1142 added nesting-depth checks; #1128 added a runbook stop hook with a TargetWorktree test pattern. Never encode absolute paths in committed artifacts; resolve by branch/issue identity or payload data.


## Proposed Fix

### Design summary (what changes where):

### Boundaries and invariants to preserve:

### Dependencies or blocked work:

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:

#### Functions/classes/CLI commands impacted:

#### Data flow and validation changes:

#### Error handling and logging updates:

#### Rollback/feature-flag considerations (if applicable):

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

#### Required configuration keys and defaults:

#### Backward-compatibility expectations:

#### Performance constraints (latency/throughput/memory):

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
- Constraints (budget, performance, compatibility):
- External dependencies (services, libraries, releases):

## Data / API / Config Impact
- User-facing or API changes:
- Data or migration considerations:
- Logging/telemetry updates (if any):
- Compatibility notes (CLI flags, config schemas, versioning):

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: stop hook resolves the item worktree from the transcript/prompt (`branch:` line, worktree path) or payload; validates that checkpoint; falls back to cwd only when no target is identifiable; never validates an unrelated checkpoint.
- [ ] Integration scenario to retest: coordinator-launched orchestrator working in `.claude/worktrees/<name>` stops with a valid item checkpoint while the session root has a different or invalid one.
- [ ] Manual verification notes: document the resolution order in the orchestrate skill and the hook-context brief; destinations need a push-down refresh.

- Regression tests to add or update:
- Unit tests (pytest) for the fixed behavior and boundaries:
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
- Error handling and logging verification:
- Coverage impact and targets for changed lines/modules:
- Toolchain commands to run (format → lint → type-check → test):
- Manual validation steps (if required):


## Acceptance Criteria
- [ ] Repro steps now produce the expected behavior in all documented environments.
- [ ] Regression test(s) added and passing (list file path and test name).
- [ ] Edge cases and invalid inputs are handled with correct errors or fallbacks.
- [ ] No unintended behavior changes outside the defined scope.
- [ ] Required logs/telemetry updated and validated (if applicable).
- [ ] Performance constraints met or explicitly waived with rationale.
- [ ] Full toolchain pass completed (format → lint → type-check → test).
- [ ] Docs/config references updated to match the new behavior.

## Risks & Mitigations
- Technical or operational risks:
- Mitigations and rollbacks:

## Rollout & Follow-up
- Release/rollout steps:
- Post-fix monitoring or clean-up tasks:
- Links: issue, PRs, related docs

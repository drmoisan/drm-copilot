# preimpl-gate-blocks-post-fanin-integration-writes (Spec)

- **Issue:** #1136
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T11-00
- **Status:** Draft
- **Version:** 0.1

## Context
After every child feature of an epic has merged into the epic integration branch (fan-in complete), the preimplementation gate still blocks two legitimate writes on that integration branch: the commit of the updated `docs/features/epics/<slug>/epic-status.md`, and the pr-author receipt `artifacts/pr_body_<N>.receipt.json` for the integration-to-main PR. The epic-orchestrator therefore cannot finish an epic without a human workaround.

Environment:
- OS/version: Windows 11 Pro, Claude Code CLI
- Python version: n/a (PowerShell hooks)
- Command/flags used: `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08
- Data source or fixture: epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json` showing every feature merged

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run an epic with `/epic-run` until every child PR has merged into `epic/<slug>-integration`.
2. On the integration branch, have epic-orchestrator update `epic-status.md` and `git add` / `git commit` it.
3. Delegate pr-author for the integration-to-main PR; it writes `artifacts/pr_body_<N>.md` and `artifacts/pr_body_<N>.receipt.json`.

Expected:
When the epic checkpoint records every feature as merged (fan-in complete), the gate allows both the epic-status commit and the pr-author receipt write on the integration branch, without a per-item readiness checkpoint and without a hand-authored checkpoint.

Actual:
The preimplementation gate denies both operations because no readiness checkpoint (`artifacts/orchestration/orchestrator-state.json` with lifecycle readiness) exists for the integration branch. Agents then either stall or attempt to hand-author a checkpoint.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: preimplementation gate deny on `git commit` of `epic-status.md` and on Write of `artifacts/pr_body_<N>.receipt.json` on `epic/<slug>-integration`.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The preimplementation gate recognizes only per-item orchestrator checkpoints. It has no notion of the epic checkpoint's fan-in-complete state. Related findings filed separately and run sequentially because they touch the same gate and hook target resolution: follow-up on an already-merged feature (finding 3) and orchestrator stop hook validating the wrong worktree's checkpoint (finding 9).

Constraint from the owner: do not weaken the gate's intent; make the legitimate path pass. The allowance must be narrow: only the epic-status file and the pr-author body/receipt paths, only on the integration branch named in the epic checkpoint, only when every feature is recorded merged.


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

- [ ] Unit coverage areas: gate allows the two writes when the epic checkpoint shows all features merged; still denies them when any feature is not merged; still denies other production paths on the integration branch; still denies on a branch that is not the checkpoint's integration branch.
- [ ] Integration scenario to retest: post-fan-in epic-status commit and pr-author receipt write on an integration branch.
- [ ] Manual verification notes: update the epic-orchestrate skill and the gate's documentation to describe the recognized path; destinations need a push-down refresh.

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

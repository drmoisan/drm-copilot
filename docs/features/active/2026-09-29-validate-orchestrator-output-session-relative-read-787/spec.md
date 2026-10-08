# 2026-09-29-validate-orchestrator-output-session-relative-read (Spec)

- **Issue:** #787
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T13-54
- **Status:** Draft
- **Version:** 0.1

## Context
`.claude/hooks/validate-orchestrator-output.ps1` runs at SubagentStop and reads `-CheckpointPath` relative to the session root (#690 research section 3, row 18). #690 changed the PreToolUse gates to locate run checkpoints through `WorktreeRunResolution.psm1`, but this hook was out of scope. In the two-worktree topology, where the epic checkpoint lives in a different worktree from the session root, the hook can read a missing or stale checkpoint and block the epic-orchestrator when it terminates.


## Repro & Evidence
- Steps to reproduce (with data/flags/inputs):
- Expected vs actual behavior:
- Logs/screenshots/error snippets:
- Frequency / determinism (always, intermittent, data-dependent):

## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
- Current hypothesis or confirmed root cause:
- Signals/evidence supporting it:
- Affected components/modules (paths, services, pipelines):

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

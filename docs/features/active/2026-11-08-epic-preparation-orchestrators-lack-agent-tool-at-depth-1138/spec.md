# epic-preparation-orchestrators-lack-agent-tool-at-depth (Spec)

- **Issue:** #1138
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T11-44
- **Status:** Draft
- **Version:** 0.1

## Context
`/epic-plan` and `/epic-run` break when the per-feature orchestrators they delegate to run two levels below the session root: those orchestrators had no Agent tool, so they could not delegate to task-researcher, atomic-planner, atomic-executor or the other specialists, and the epic stalled or the orchestrator did the work itself.

Environment:
- OS/version: Windows 11 Pro, Claude Code CLI
- Python version: n/a
- Command/flags used: `/epic-plan` and `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08
- Data source or fixture: epic-planner -> preparation-mode Agent(orchestrator) -> specialist chain

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. From a session root, run `/epic-plan` (forks epic-planner) or `/epic-run` (epic-orchestrator).
2. epic-planner / epic-orchestrator delegates `Agent(orchestrator)` per feature.
3. The per-feature orchestrator attempts to delegate to atomic-planner or another specialist.

Expected:
Either the per-feature orchestrator has the Agent tool and delegates normally, or the workflow detects the missing Agent tool before starting work and fails fast with an actionable message, and the documented topology avoids the unsupported depth (for example, the coordinator session launches per-feature orchestrators directly, or the chain is flattened).

Actual:
Preparation orchestrators two levels down had no Agent tool. No preflight detected this; they proceeded without delegation or stalled. Note: in a separate drm-copilot session on 2026-11-08 an epic-run did delegate successfully at depth 2, so the condition depends on how the chain is entered (skill fork vs. direct agent, host, or version). Reproduce and characterize the exact condition first.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: per-feature orchestrator reported no Agent tool available.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Claude Code limits subagent nesting and/or does not give the Agent tool to subagents beyond a certain depth or when entered through a `context: fork` skill. The epic skills assume three levels (root -> epic agent -> orchestrator -> specialists) without stating or checking the assumption.


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

- [ ] Preflight in orchestrator (and epic agents) that fails fast with a clear message when the Agent tool is missing.
- [ ] Document the depth assumption in epic-plan, epic-run, epic-orchestrate and orchestrate skills.
- [ ] Topology change: the coordinator session launches per-feature orchestrators (or the chain is flattened) so specialists are always reachable.
- [ ] Regression test for the preflight and the documented topology.

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

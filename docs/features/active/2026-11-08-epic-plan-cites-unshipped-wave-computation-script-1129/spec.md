# epic-plan-cites-unshipped-wave-computation-script (Spec)

- **Issue:** #1129
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T08-08
- **Status:** Draft
- **Version:** 0.1

## Context
The `epic-plan` skill cites `scripts/dev_tools/epic_wave_computation.py` as the reference implementation for wave layering, but the push-down does not ship that script to destination repositories. In iar-migration the planner computed the waves by hand.

Environment:
- OS/version: Windows 11 Pro, Claude Code
- Python version: n/a
- Command/flags used: `/epic-plan` in a pushed-down destination repository
- Data source or fixture: iar-migration E1/E2 planning, 2026-11-07/08

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Push down the Claude customizations to a destination repository.
2. Run `/epic-plan` there.
3. Observe that the skill points to `scripts/dev_tools/epic_wave_computation.py`, which does not exist in the destination.

Expected:
The wave-layering reference the skill names exists in every repository the skill is pushed to, or the skill names a script that is shipped.

Actual:
The cited script is missing in destination repositories, so the planner computes waves by hand, without the reference implementation's cycle and unresolved-reference checks.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `epic-plan` SKILL.md `## Decomposition and Wave Design`, step 4.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The script lives under `scripts/dev_tools/` in this repository, which the push-down does not bundle. Repository policy prefers PowerShell or bash for pushed-down skill tooling over new Python. Options: ship a PowerShell port under the skill or `.claude/lib/` and cite it, with parity against the Python reference; or ship the existing script in the bundle. Check the same issue for other scripts the epic skills cite.


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

- [ ] Unit coverage areas: wave layering, cycle detection, and unresolved references in the shipped implementation; parity with the Python reference if both remain.
- [ ] Integration scenario to retest: a push-down to a scratch destination contains every script the epic skills cite.
- [ ] Manual verification notes: update `epic-plan` and `epic-orchestrate` text and mirrors; add a test that fails when a skill cites a script the push-down does not ship; state that destination repositories need a push-down refresh.

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

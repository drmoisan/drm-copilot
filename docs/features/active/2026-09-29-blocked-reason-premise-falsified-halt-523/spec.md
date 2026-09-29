# 2026-09-29-blocked-reason-premise-falsified-halt (Spec)

- **Issue:** #523
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T15-52
- **Status:** Draft
- **Version:** 0.1

## Context
The orchestrator checkpoint's `blocked_reason` field is a seven-member enum covering only **mechanical** failure modes (`delegation_launch_failed`, `validator_failed`, and similar). It cannot express a halt in which every delegation and every validator **succeeded** but the work's premise was falsified by evidence gathered during execution.

Environment:
- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: orchestrator-state validation (Python `scripts/dev_tools/validate_orchestrator_state.py`, PowerShell `.claude/lib/orchestrator-state/OrchestratorState.psm1`, TypeScript `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`)
- Data source or fixture: an orchestrator checkpoint recording a halt whose premise was falsified

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run an orchestration whose delegations and validators all succeed, but whose measurements falsify the defect hypothesis the plan was built on.
2. Attempt to record the halt in `artifacts/orchestration/orchestrator-state.json` using `blocked_reason`.
3. Observe that no enum member describes the halt; the only non-misrepresenting value is `none`.

Expected:
The halt is expressible in structured checkpoint fields, and a genuinely blocked run is distinguishable from an unblocked one without reading free-form text.

Actual:
During the `quickfiler-suite-determinism-foundation` epic run (2026-08-22), the child for drmoisan/TaskMaster#511/#571 completed Phases 0 through 4 with every delegation and validator green, then halted because its own measurements falsified the defect hypothesis the plan was built on. No enum member describes that.

The child set `blocked_reason: none` and recorded the real reason in free-form keys, explicitly declining to pick a mechanical member that would misrepresent the halt. That is the correct call, but it means a genuinely blocked run is indistinguishable from an unblocked one by the enum alone, and any tooling that reads `blocked_reason` to triage halts will mis-triage this class.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `blocked_reason: none` recorded on a halted child checkpoint (TaskMaster#511/#571, 2026-08-22).


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
A premise-falsified halt is the most valuable kind of halt — it is the orchestration system catching a planning error before it reaches `main`. Making it unrepresentable in the structured field pushes it into prose, where automated triage cannot see it.

The enum is defined in three runtimes: `VALID_BLOCKED_REASONS` in `scripts/dev_tools/validate_orchestrator_state.py` (authoritative), `$script:VALID_BLOCKED_REASONS` in `.claude/lib/orchestrator-state/OrchestratorState.psm1` (plus its bundled copy), and `VALID_BLOCKED_REASONS` in `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`.


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

- [ ] Unit coverage areas: enum acceptance and rejection in all three runtimes; cross-runtime parity fixtures.
- [ ] Integration scenario to retest: existing checkpoints validate byte-identically.
- [ ] Manual verification notes: skill documents enumerating `blocked_reason` values list the new representation.

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

# 2026-02-04-extension-tests-fail-in-container (Spec)

- **Issue:** #12
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-04T18-36
- **Status:** Draft
- **Version:** 0.1

## Context
Extension integration tests cannot run inside the dev container, so the integration suite fails consistently.
This blocks running the full test workflow in container environments.

Environment:
- OS/version: Linux (dev container)
- Python version: Unknown (not provided)
- Command/flags used: Extension integration test suite executed in the container
- Data source or fixture: Extension test harness (no external data sources reported)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Open the repo in the dev container.
2. Run the extension integration tests from the container.
3. Observe that the integration suite fails due to container limitations.

Expected:
Integration tests complete successfully when run in the container, or are implemented in a way that works in both container and host environments.

Actual:
Integration tests fail consistently in the dev container because the container cannot run the required integration test environment.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: Not provided.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The current integration test harness relies on a runtime that is not available in the dev container. The suite should be rewritten to use the Jest provider so it can run in container or on host.


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

- [ ] Unit coverage areas: Ensure Jest-based tests cover the same integration behaviors currently covered by container-incompatible tests.
- [ ] Integration scenario to retest: Run the Jest-based integration suite in the dev container and on host to confirm parity.
- [ ] Manual verification notes: Validate that the extension still behaves correctly in a local VS Code instance after test rewrite.

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

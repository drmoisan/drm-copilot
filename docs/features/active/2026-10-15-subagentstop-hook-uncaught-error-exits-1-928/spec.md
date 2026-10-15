# subagentstop-hook-uncaught-error-exits-1 (Spec)

- **Issue:** #928
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15T15-44
- **Status:** Draft
- **Version:** 0.1

## Context
SubagentStop validators now block with exit 2 for deliberate block decisions (epic #904), but an uncaught terminating error in any of them still ends the pwsh -File process with exit 1. SubagentStop does not block on exit 1, so a crashing validator lets the subagent result through unchecked (NB-6).

Environment:
- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Make any SubagentStop validator (for example `.claude/hooks/validate-task-researcher-output.ps1`) throw an unhandled terminating error, for example by corrupting an imported module.
2. Observe exit code 1; the SubagentStop event is not blocked.

Expected:
Any unhandled error in a SubagentStop validator blocks (exit 2) with a reason, consistent with fail-closed hook policy.

Actual:
The process exits 1 and the event proceeds.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: E3 code-review NB-6 (docs/features/active/subagentstop-envelope-artifact-gates-905/code-review.2026-10-12T04-58.md): "An uncaught terminating error in any hook still ends the pwsh -File process with exit 1, which does not block a SubagentStop event."


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
- Applies to all 9 SubagentStop validators migrated by epic #904 (E1 helper `.claude/hooks/subagentstop-envelope.ps1`, E2-E4).
- #786 already converted two handlers to the uniform deny for the same exit-code reason.


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

- [ ] Add a top-level trap/try in each validator (or in the shared helper's entry contract) that converts any unhandled error to `Exit-SubagentStopBlock` with a reason.
- [ ] Add one test per validator that forces an unhandled error and asserts exit 2.
- [ ] Mirror to the bundled copies.

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

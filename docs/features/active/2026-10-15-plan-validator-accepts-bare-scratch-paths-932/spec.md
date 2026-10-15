# plan-validator-accepts-bare-scratch-paths (Spec)

- **Issue:** #932
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-15T15-45
- **Status:** Draft
- **Version:** 0.1

## Context
The scratch-location rule added by #900 (PR #922) has no preflight enforcement: a plan that defines SCRATCH as the bare scratchpad root still passes plan validation. The test guard is a fixed denylist.

Environment:
- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low


## Repro & Evidence
Steps to Reproduce:
1. Write a plan that sets SCRATCH to the bare scratchpad root and run the plan validator; it passes.
2. `tests/scripts/dev_tools/test_scratch_location_contracts.py` `FORBIDDEN_SCRATCH_PATHS` (lines 93-100) lists six literals only.

Expected:
Plan preflight rejects a SCRATCH definition that is not namespaced by issue number.

Actual:
Only the executor-side mechanism and a literal denylist apply.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: #900 code-review.2026-10-12T17-38.md (Low advisory and Info rows); feature-audit.2026-10-12T17-38.md:56.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The fix requires editing .claude/rules/plan-acceptance-gates.md, a policy file that needs operator approval. The .codex/agents TOML update was also noted as out of scope.


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

- [ ] With operator approval, add a plan-acceptance gate rejecting bare SCRATCH definitions and implement it in the plan validator.
- [ ] Replace the literal denylist with a pattern check; update the .codex/agents TOML.

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

# promotion-gate-lacks-preexisting-issue-branch (Spec)

- **Issue:** #509
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T15-26
- **Status:** Draft
- **Version:** 0.1

## Context
The routing-contract completion gate unconditionally requires a promotion receipt for every required MCP tool, including the promote-to-issue tool. When an issue already exists, for example because it was transferred from another repository, that tool cannot be run truthfully: it has no idempotent path and always files a new issue. The orchestration is then forced to choose between filing a duplicate issue and failing its own completion gate.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: `validate_orchestration_artifacts orchestrator-state <path> --require-complete`
- Data source or fixture: `scripts/dev_tools/_orchestrator_state_routing.py` and `config/orchestration-routing.json`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. It does not affect delivered code, but it makes the completion gate unsatisfiable for a legitimate and recurring situation, and it creates pressure to either fabricate a receipt or pollute the issue tracker with duplicates. Encountered directly while orchestrating issue #500, which was transferred from another repository; that run proceeded by recording the substitution under `human_interaction.requirements[]` and accepting the delta.


## Repro & Evidence
Steps to Reproduce:
1. Begin an orchestration against an issue that already exists on GitHub and has no local potential record, which is the normal state after an issue is transferred between repositories.
2. Run the promotion lifecycle. The potential-entry and active-folder tools run truthfully; the promote-to-issue tool cannot, because it would create a second issue for the same defect.
3. Complete the work and run the completion validator.

Expected:
An orchestration working a pre-existing issue can reach a clean completion without filing a duplicate. The gate recognises that the promote-to-issue step was satisfied out of band and accepts evidence of the existing issue in place of a receipt.

Actual:
`validate_routing_contract` requires a receipt for every entry in the route's `required_mcp_tools` and offers no branch for an already-existing issue, so completion reports a missing MCP receipt. The only ways forward are to file a duplicate issue purely to satisfy the gate, or to complete with a documented gate exception.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet, the shape of the failure:

  ```text
  Checkpoint missing successful MCP receipt: <promote-to-issue tool>.
  ```


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The routing matrix models promotion as a single linear path from potential entry to issue to folder, and the validator treats each step as mandatory. Transfers, manually filed issues, and issues created before an orchestration begins all break that assumption. Note also that the promote-to-issue implementation parses the URL of a freshly created issue, so it has no way to recognise or adopt an existing one.


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

- [ ] Add a recognised alternative receipt, for example an `issue_adopted` record naming the existing issue number and its origin, that satisfies the same required-tool slot.
- [ ] Alternatively, make the promote-to-issue tool idempotent by accepting an existing issue number and annotating the potential record rather than creating a new issue.
- [ ] Unit coverage areas: `validate_routing_contract` accepting the alternative receipt, and rejecting a fabricated one.
- [ ] Integration scenario to retest: a full orchestration against a pre-existing issue reaches completion with no duplicate filed.
- [ ] Manual verification notes: also review the promotion-only hook, which blocks read-only inspection of the promotion sources because it pattern-matches the tool name anywhere in a shell command.

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

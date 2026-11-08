# runbook-commands-not-checked-against-pinned-tool-versions (Spec)

- **Issue:** #1128
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T08-08
- **Status:** Draft
- **Version:** 0.1

## Context
The `human-exception-runbook` skill wrote a Windows packaging runbook that told the user to run `python -m nuitka --clean-cache=clcache`. Nuitka 4.3.4, the version pinned in the lockfile, rejects that value; `--clean-cache=all` works. Runbook commands are not checked against the pinned tool version.

Environment:
- OS/version: Windows 11 Pro, Claude Code
- Python version: per the iar-migration lockfile
- Command/flags used: `python -m nuitka --clean-cache=clcache`
- Data source or fixture: iar-migration E1 Windows packaging runbook, 2026-11-07/08

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Have the orchestrator invoke `human-exception-runbook` for a step that needs a tool command, in a repository whose lockfile pins the tool (Nuitka 4.3.4).
2. Read the generated runbook.
3. Run the command it gives.

Expected:
Every tool command in a runbook is either checked against the version pinned in the lockfile, or clearly marked as not verified, with the pinned version stated.

Actual:
The runbook gave a flag value the pinned version rejects, with no indication that the command had not been verified.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: Nuitka 4.3.4 rejects `--clean-cache=clcache`; `--clean-cache=all` is accepted.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The skill sources procedures MCP-first and web-second, and nothing ties a command to the installed or pinned version. Fix options: resolve the pinned version from the lockfile and check the command against that version's help or documentation; or mark each unverified command with an explicit "not verified against <tool> <version>" note. Do not weaken the runbook's purpose.


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

- [ ] Unit coverage areas: version resolution from a lockfile fixture; an unverified command is marked; a verified command carries the version it was checked against.
- [ ] Integration scenario to retest: a runbook for a pinned tool produces either a verified or a marked command.
- [ ] Manual verification notes: update the `human-exception-runbook` skill and agent text and mirrors; state whether destination repositories need a push-down refresh.

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

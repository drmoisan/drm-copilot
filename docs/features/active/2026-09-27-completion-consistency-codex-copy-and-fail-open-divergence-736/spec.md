# 2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence (Spec)

- **Issue:** #736
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T13-52
- **Status:** Draft
- **Version:** 0.1

## Context
#708 (PR #726) fixed the Claude completion-consistency hook to read the Edit call's own target file. The Codex copy still has the original defect, and review found three related defects. One of them is a policy divergence: fail-open on Claude versus fail-closed on Codex.

Environment:
- OS/version: any
- Python version: n/a (PowerShell hooks)
- Command/flags used: Edit calls on orchestration checkpoints
- Data source or fixture: #708 `evidence/other/follow-ups.md` on main

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. `.codex/hooks/enforce-completion-consistency.ps1:308` (and its bundle copy) still resolves the checkpoint from a relative path; `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1:392-403` pins that behaviour.
2. The hook's patch step uses `String.Replace`, which replaces EVERY occurrence of `old_string`. The Edit tool replaces a single occurrence unless `replace_all` is set, so the reconstructed checkpoint can differ from what the Edit will actually produce.
3. When the targeted checkpoint is missing or unreadable, the Claude hook ALLOWS the Edit and the Codex hook DENIES it.
4. `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1:47-51` uses the default reader with a relative path, so it depends on the working directory. No test drives the default reader against a real file.

Expected:
Both surfaces read the targeted file, reproduce the Edit tool's replace semantics exactly, and behave identically on a missing checkpoint (fail-closed is the repository norm).

Actual:
As described in steps 1-4.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: #708 follow-ups 1-4 and 6.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
#708 was scoped to the Claude surface under its D-decisions.


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

- [ ] Unit coverage areas: port the #708 fix to Codex (rewrite the pinning test); honour `replace_all` (a single replacement by default); align both surfaces on fail-closed and record the decision; make the default-reader tests hermetic.
- [ ] Integration scenario to retest: an isolated-worktree subagent completing its checkpoint by Edit on both surfaces.
- [ ] Manual verification notes: post-merge live confirmation (#708 follow-up 5).

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

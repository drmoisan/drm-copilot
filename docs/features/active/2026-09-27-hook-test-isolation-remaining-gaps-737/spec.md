# 2026-09-27-hook-test-isolation-remaining-gaps (Spec)

- **Issue:** #737
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T13-54
- **Status:** Draft
- **Version:** 0.1

## Context
#709 (PR #728) mocked the epic-checkpoint read in seven gate suites and added a structural guard. Several suites and guard gaps remain, and #707 found a related gap in the no-Python guard.

Environment:
- OS/version: developer machines (CI has no local state)
- Python version: n/a (Pester)
- Command/flags used: the Pester suites under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`
- Data source or fixture: #709 `evidence/other/follow-ups.md`; the #707 follow-ups

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low


## Repro & Evidence
Steps to Reproduce:
1. D8: four other epic gate suites may read `artifacts/orchestration/epic-orchestrator-state.json` without the mock.
2. D5: the Codex suites are not covered by #709's mocks or guard.
3. D9: the structural guard checks a hard-coded list of seven suites, so a new suite that reads epic state is not caught.
4. Review found:
   - CR-1: no test proves the mock actually intercepts the read.
   - CR-2: two ways the guard can pass wrongly.
   - CR-3: untested guard branches.
   - CR-7: a stale comment.
5. #707: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` does not scan `.codex/hooks`.

Expected:
Every gate suite on both surfaces is hermetic against local orchestration state. The guards discover their targets instead of using fixed lists, and cover both surfaces.

Actual:
The gaps listed above.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: #709 and #707 follow-ups on main.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Same class as #510: gitignored local state leaking into tests.


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

- [ ] Unit coverage areas: extend the mocks to the four remaining suites and to the Codex suites; make the guard discover suites by pattern; add an interception-proof test; close the CR-2 and CR-3 gaps; extend the no-Python guard's scan roots to `.codex/hooks`.
- [ ] Integration scenario to retest: run the suites with a deliberately present local epic checkpoint and expect identical results.
- [ ] Manual verification notes: none.

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

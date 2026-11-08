# epic-child-pr-merges-without-ci (Spec)

- **Issue:** #1130
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T08-08
- **Status:** Draft
- **Version:** 0.1

## Context
In a destination repository whose CI runs automatically only on pull requests to `main`, child PRs into an epic integration branch get no CI, and the merge gate lets them merge anyway. Several iar-migration E1 child PRs, for example #161, merged into the integration branch with no CI run. One agent worked around it by dispatching the workflow manually on the PR head.

Environment:
- OS/version: Windows 11 Pro, Claude Code
- Python version: n/a
- Command/flags used: `gh pr merge` on a child PR whose base is `epic/<slug>-integration`
- Data source or fixture: iar-migration E1, 2026-11-07/08; this repository's own `ci.yml` already includes `epic/**` in its pull_request trigger

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. In a repository whose CI `pull_request` trigger lists only `main`, open a child PR into `epic/<slug>-integration`.
2. Observe that no CI runs.
3. Merge it through `epic-orchestrator`; observe that the merge gate allows it.

Expected:
`epic-orchestrator` and the merge gate require a green CI result on the child PR head SHA before merging into the integration branch, from either a `pull_request` run or a recorded `workflow_dispatch` run on the same SHA. Repository bootstrap and push-down add the integration-branch pattern (`epic/**`) to the CI `pull_request` trigger.

Actual:
Child PRs merge into the integration branch with no CI result at all.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: iar-migration PR #161 merged into the E1 integration branch with zero checks.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The merge gate (`.claude/hooks/enforce-epic-merge-gate.ps1` and its helpers, plus the Codex copy) checks epic membership and checkpoint state but not a CI result tied to the head SHA for epic children. The `epic-orchestrate` skill's CI step assumes CI runs. Do not weaken the gate: the legitimate path is a recorded green run on the head SHA.


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

- [ ] Unit coverage areas: merge gate denies an epic-child merge with no CI record; allows one with a green `pull_request` run on the head SHA; allows one with a recorded green `workflow_dispatch` run on the same SHA; denies a run on a different SHA.
- [ ] Integration scenario to retest: `epic-orchestrator` dispatches CI when no run exists and records it before merging.
- [ ] Manual verification notes: update `epic-orchestrate` and `epic-run` text and mirrors, the bootstrap or push-down that writes the CI trigger, and state that destination repositories need a push-down refresh.

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

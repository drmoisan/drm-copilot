# hooks-read-main-checkout-not-item-worktree (Spec)

- **Issue:** #1105
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T08-48
- **Status:** Draft
- **Version:** 0.1

## Context
Several stop hooks and the review coverage hook resolve an item's artifacts against the main checkout instead of the item's worktree. As a result they reject correct returns, skip their deeper checks, or read stale data.

Environment:
- OS/version: Windows 11 Pro, PowerShell 7
- Python version: 3.13 (Poetry environment)
- Command/flags used: orchestrator runs that delegate to subagents working in item worktrees under `.claude/worktrees/`
- Data source or fixture: issues #1031, #1034, #1096, and #1097, observed on 2026-11-07

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Correct work is rejected, which costs review and preflight rounds. Checks that should run are silently skipped. A stale coverage file can block every review, or could pass a review on another branch's figures.


## Repro & Evidence
Steps to Reproduce:
1. Start an orchestrated item in its own worktree, with a feature folder that exists only on the item branch.
2. Let a researcher, `prd-feature`, planner, executor, preflight, or feature-review subagent return a repo-relative artifact path.
3. Observe the stop hook resolve that path from the main checkout.
4. For a review, let the review coverage hook run while the main checkout holds an old `artifacts/pester/powershell-coverage.xml`.

Expected:
Each hook resolves artifact paths and coverage files against the item worktree that produced them, then runs its full checks against the item's own content.

Actual:
- The researcher, `prd-feature`, planner, and executor artifact hooks accept only repo-relative paths, then test them from the main checkout, where the item's feature folder does not exist. Their deeper checks did not run, including the planner hook's Pre-Mortem check (#1096).
- An executor's stop hook rejected a preflight return because it looked for the preflight fix record in the main checkout. The record was committed on the item branch at `697ddeab8` (#1034).
- A feature-review stop hook rejected a PASS review because the artifacts existed only in the worktree (#1031).
- The review coverage hook read `artifacts/pester/powershell-coverage.xml` in the main checkout. That file dated from 2026-11-05 and came from another branch, at 12.33%, so the hook rejected every #1097 review. The item's real coverage was 93.96% to 94.01%. The coordinator deleted the stale file on 2026-11-07 as a stopgap.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: the reports are in the orchestrator returns for #1096 and #1097 and the review returns for #1031 and #1034.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The hooks run with the main checkout's scripts and resolve paths against their own working directory or the repository root, not the worktree identified by the payload or the delegation. The repository already has `Resolve-HookTargetWorktree`, which the batch-budget hooks use. The issue-adoption feature-folder probe already reads the run worktree with `git -C <worktree root>`.


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

- [ ] Unit coverage areas: path resolution for each affected hook, with a path that exists only in the item worktree, only in the main checkout, and in both.
- [ ] Integration scenario to retest: a full item run in a worktree in which every stop hook runs its deeper checks and none rejects a correct return.
- [ ] Manual verification notes: the coverage hook reads the item worktree's coverage output, or fails closed with a clear message when it is absent or older than the item's head, and never reads another branch's file.

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

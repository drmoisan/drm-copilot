# worktree-agent-inherits-main-venv (Spec)

- **Issue:** #1127
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T08-08
- **Status:** Draft
- **Version:** 0.1

## Context
An agent running `poetry install` in a sibling worktree changes the packages in the main checkout's `.venv`, because the session environment points Poetry at that environment. Agent worktrees should use their own virtual environment.

Environment:
- OS/version: Windows 11 Pro, PowerShell 7, Claude Code
- Python version: 3.13 through Poetry
- Command/flags used: `poetry install` in an agent worktree under `.claude/worktrees/`
- Data source or fixture: observed in iar-migration (E1/E2, 2026-11-07/08), and repeatedly in this repository (drm-copilot `.pth` files repointed at a worktree during Epic #1019)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. From a session whose `VIRTUAL_ENV` (or Poetry configuration) points at the main checkout's `.venv`, create an agent worktree.
2. Run `poetry install` in the worktree.
3. Observe that the main checkout's `.venv` packages and editable-install `.pth` files now point at the worktree.

Expected:
Each agent worktree uses its own virtual environment, so installs in a worktree never change the main checkout's environment.

Actual:
The main checkout's `.venv` is modified. In iar-migration an agent restored it with `poetry sync`; in drm-copilot the coordinator restored it with `poetry install` from the main checkout. Agents worked around it with `env -u VIRTUAL_ENV`, which in a worktree with no `.venv` creates a nearly empty one.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: drm-copilot 2026-11-06, `drm_copilot_discovery.pth` pointed at `.claude/worktrees/docs-1031-r2` after a worktree `poetry install`.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The session environment carries `VIRTUAL_ENV` and Poetry resolves the active environment from it, not from the worktree. Fix options: `POETRY_VIRTUALENVS_IN_PROJECT=true` per worktree, or an explicit `poetry env use` in a worktree bootstrap. The fix must cover how agent worktrees are created and the instructions agents receive.


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

- [ ] Unit coverage areas: the worktree bootstrap sets an in-project environment and never inherits the session `VIRTUAL_ENV`.
- [ ] Integration scenario to retest: `poetry install` in a fresh worktree leaves the main checkout's `.venv` byte-identical (compare `.pth` files and the installed package list).
- [ ] Manual verification notes: document the rule in the `execution-environment` skill and its mirrors; state whether destination repositories need a push-down refresh.

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

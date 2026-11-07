# codex-review-coverage-hook-reads-stale-or-foreign-artifacts (Spec)

- **Issue:** #1114
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T13-15
- **Status:** Draft
- **Version:** 0.1

## Context
The Codex review coverage hook, `.codex/hooks/validate-feature-review-coverage.ps1`, reads coverage reports with no freshness check, and it selects the newest policy audit across all active feature folders. It can therefore judge a review against stale coverage or against another item's audit. Issue #1105 (PR #1113) fixed the same defect class in the Claude hooks and left this Codex twin out of scope.

Environment:
- OS/version: Windows 11 Pro, PowerShell 7
- Python version: 3.13 (Poetry environment)
- Command/flags used: Codex runtime review stop with `.codex/hooks/validate-feature-review-coverage.ps1`
- Data source or fixture: any checkout with more than one active feature folder, or with a coverage report older than the item's latest commit

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Have two active feature folders, each with a policy audit, with the other item's audit written more recently.
2. Run a Codex feature review for the first item.
3. Observe the hook select the other item's audit.
4. Separately, leave a coverage report older than the item's newest commit, and observe the hook accept it.

Expected:
The hook reads the policy audit of the item under review, and the coverage report from that item's worktree. It blocks with a clear message when the report is missing or older than the newest item commit that touches the language, matching the Claude behaviour from #1105.

Actual:
The hook picks the newest policy audit across all active feature folders and reads coverage reports without checking their age. A review can pass or fail on another item's audit or on stale coverage.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: reported by the #1105 orchestrator, 2026-11-07, as an out-of-scope finding.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The Claude fix added `.claude/hooks/subagentstop-target-worktree.ps1`, which reuses `Resolve-HookTargetWorktree`, plus a freshness check. The Codex hook predates it and resolves the audit by recency, not by item.


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

- [ ] Unit coverage areas: audit selection by item identity; coverage freshness against the newest item commit per language; a missing report; another item's newer audit present.
- [ ] Integration scenario to retest: a Codex review stop with two active items and a stale report.
- [ ] Manual verification notes: reuse the #1105 design and helpers where the Codex runtime allows, and keep behaviour unchanged for a single-item checkout with a fresh report.

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

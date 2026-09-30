# quality-tiers-yml-missing-and-unenforced (Spec)

- **Issue:** #734
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T21-45
- **Status:** Draft
- **Version:** 0.1

## Context
`quality-tiers.yml` does not exist at the repository root on `main`. `.claude/rules/quality-tiers.md` says every project must be classified there, and that CI's `tier-classification` stage fails when a project is unclassified. Either that stage does not exist or it does not fail on a missing file.

Environment:
- OS/version: any
- Python version: n/a
- Command/flags used: `git ls-files --error-unmatch quality-tiers.yml` on main (fails: "did you forget to git add?"); `git ls-tree --name-only origin/main | grep -i tier` (no match)
- Data source or fixture: main at 2026-09-27

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The tier-dependent gates (mutation score, property-test density, determinism budgets) cannot be applied reliably without the classification source.


## Repro & Evidence
Steps to Reproduce:
1. Check out main.
2. Look for `quality-tiers.yml` at the root: it is absent.
3. CI is green, so no stage enforces the documented requirement.

Expected:
`quality-tiers.yml` classifies every project (T1-T4). CI fails when a project is unclassified or the file is missing.

Actual:
The file is absent, and plans assume a tier. #706 assumed T4 "because quality-tiers.yml was absent". Reviewers on #707, #708 and #710 flagged it independently.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: #706 spec (tier assumption); the #707, #708 and #710 reports.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The file was never authored, or it was removed. Verify whether a `tier-classification` job exists in `.github/workflows/`. `.claude/rules/quality-tiers.md` names `docs/ci.research.md` section 1 as the source of truth, and that doc is itself missing (see open issue #511).


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

- [ ] Unit coverage areas: author `quality-tiers.yml` covering every project (extension, mcp-server, scripts, .claude libs, hooks), using the examples in the rules doc; add or repair a CI stage that fails when the file is missing, a project is unclassified, or a tier is invalid.
- [ ] Integration scenario to retest: removing a project's entry makes CI fail.
- [ ] Manual verification notes: coordinate with #511.

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

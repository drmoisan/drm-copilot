# 2026-11-15-test-launcher-drops-positional-jest-path (Spec)

- **Issue:** #1192
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-15T11-44
- **Status:** Draft
- **Version:** 0.1

## Context
The test-execution-policy launcher (`run-test-suite.sh`, added by #1158) drops a positional Jest test-file argument, so a targeted Jest task check silently runs the whole Jest suite instead of the named file. The #1173 run reported it (PR #1185). It wastes time under the one-suite-at-a-time machine lock and makes a targeted check's evidence misleading.

Environment:
- OS/version: Windows 11 (local), Claude Code runtime
- Python version: not applicable
- Command/flags used: the launcher with the Jest lane and a positional test path, for example a single `extensions/drm-copilot/tests/...test.ts` file
- Data source or fixture: reported in PR #1185 (issue #1173) "Not fixed" notes

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run a Jest task check through the launcher, passing one test file as a positional argument.
2. Observe that the whole Jest suite runs (thousands of tests) instead of the named file.

Expected:
Positional test paths (and other runner-supported selectors) are forwarded to Jest, so a targeted check runs only the named files; the launcher still applies its lock and lane rules.

Actual:
The positional path is not forwarded; the full suite runs with no warning.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: see PR #1185 body.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The launcher's command builder (`.claude/hooks/test-execution-policy.ps1` and the bash launcher) likely builds the Jest command from lane configuration and ignores trailing positional arguments, or only forwards flags. Check the pytest and Pester legs for the same defect. Also fix the stale comment in `extensions/drm-copilot/jest.config.cjs` line 6 ("the five docs MCP modules"; there are now seven) in the same change.


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

- [ ] Forward positional test paths for Jest (and confirm pytest and Pester behaviour), keeping the lock and lane exclusions
- [ ] Tests: a single-file Jest invocation builds a command naming only that file; no positional argument keeps the full-suite command; an integration or golden path is still refused
- [ ] Update the stale jest.config.cjs comment

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

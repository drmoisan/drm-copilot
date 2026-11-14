# 2026-11-14-prettier-format-check-fails-on-docs-fixtures (Spec)

- **Issue:** #1179
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14T03-36
- **Status:** Draft
- **Version:** 0.1

## Context
The repository-root Prettier format check (`format:check`) fails on three JSON fixtures under `tests/scripts/claude-lib/docs/fixtures/`. CI does not run the root check, so the failure is visible only locally, where it makes the format stage of the mandatory toolchain loop fail for every orchestration that runs it.

Environment:
- OS/version: Windows 11 (local); reported by two independent orchestration runs (#1163, #1157) on 2026-11-13
- Python version: not applicable
- Command/flags used: root `npm run format:check` (Prettier `--check`)
- Data source or fixture: `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`, `python-native-corpus.json`, `python-surface-corpus.json`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low


## Repro & Evidence
Steps to Reproduce:
1. Check out `main`.
2. Run the root Prettier check over the repository (`npm run format:check`).
3. Observe the three fixture files reported as not formatted.

Expected:
The root format check passes on `main`, and CI enforces the same check so that a regression fails a PR.

Actual:
Prettier reports formatting differences in the three fixtures. CI stays green because no CI job runs the root check over these paths.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: Prettier `[warn]` lines naming the three fixture files, as reported by the #1163 and #1157 runs.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The fixtures are consumed by Pester suites under `tests/scripts/claude-lib/docs/` (snapshot, parity and analyzer tests) and one pytest suite. Some consumers may compare bytes or hashes, so reformatting may require regenerating pinned values, or the fixtures may instead need a `.prettierignore` entry if their exact layout is part of the contract. Decide which by reading the consumers.


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

- [ ] Either format the fixtures and update any byte/hash pins, or add them to `.prettierignore` with a stated reason, whichever keeps the consumer contracts intact
- [ ] Make CI run the root format check (or extend an existing format job) so the class cannot recur
- [ ] Re-run the consuming Pester and pytest suites in parallel and confirm no regression

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

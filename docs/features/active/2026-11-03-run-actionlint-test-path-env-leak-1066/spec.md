# run-actionlint-test-path-env-leak (Spec)

- **Issue:** #1066
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-03T17-43
- **Status:** Draft
- **Version:** 0.1

## Context
The Pester test "Add-DirectoryToPath handles paths with trailing separator" in tests/scripts/dev-tools/run-actionlint.Tests.ps1 sets `$env:PATH` and never restores it. In a single-process Pester run, later suites inherit the altered PATH and fail. This is a test-order dependence, which repository policy treats as a violation.

Environment:
- OS/version: Linux Codespace (PowerShell 7.6, Pester 5.9.x); CI runs the suite on windows-latest, where each shard is a separate process and the leak is not visible.
- Python version: not applicable.
- Command/flags used: Invoke-Pester over tests/scripts/dev-tools in a single process.
- Data source or fixture: none; the test assigns `$env:PATH = '/existing'` directly (about line 495).

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run Invoke-Pester single-process over tests/scripts/dev-tools including run-actionlint.Tests.ps1.
2. Observe that eight later suites fail.
3. Run the same suites without run-actionlint.Tests.ps1, or with the leaking test excluded; the failures disappear.

Expected:
Every test restores process-global state (environment variables) it changes, so suites pass in any order and in a single process.

Actual:
After the test at about line 495 runs, `$env:PATH` remains '/existing' (plus the added directory), and eight later suites fail because commands cannot be resolved.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: reported by the issue 1026 run; see its isolation-parallel evidence note (89 host failures plus this leak affecting 8 later suites).


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The Add-DirectoryToPath Describe (about lines 225-303) saves and restores PATH in BeforeEach and AfterEach. The later block that contains the trailing-separator test has no such restore. The test file dates from 2026-02-21 (e467a0e8b) and was last changed in df7cb4f31 (2026-03-11). Other tests in the same file may also change process-global state without restoring it. A sibling item (Pester fixtures platform independence) fixes the 89 Linux host failures in 17 other suites and must not be mixed into this item.


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

- [x] Unit coverage areas: restore PATH (and any other changed process state) in every block of run-actionlint.Tests.ps1; add a regression guard that fails if a suite leaves PATH or other process environment changed.
- [x] Integration scenario to retest: single-process Invoke-Pester over tests/scripts/dev-tools in forward and reversed order; the eight victim suites must pass.
- [ ] Manual verification notes

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

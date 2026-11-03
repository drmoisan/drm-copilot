# pester-fixtures-platform-independent (Spec)

- **Issue:** #1067
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-03T17-43
- **Status:** Draft
- **Version:** 0.1

## Context
Seventeen Pester suites under tests/scripts/dev-tools and tests/scripts/powershell/PoshQC use Windows-specific fixtures and fail on Linux (89 failures of 308 tests). The fixtures should be platform independent so the suites pass on both Windows and Linux.

Environment:
- OS/version: Linux Codespace (PowerShell 7.6, Pester 5.9.x). CI runs these suites on windows-latest only.
- Python version: not applicable.
- Command/flags used: Invoke-Pester over tests/scripts/dev-tools and tests/scripts/powershell/PoshQC, single process, coverage disabled.
- Data source or fixture: hardcoded C:\ paths, backslash path expectations, writes to /repo, Windows prompt strings.

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. On a Linux host, run Invoke-Pester over tests/scripts/dev-tools and tests/scripts/powershell/PoshQC.
2. Observe 308 tests, 219 passed, 89 failed across 17 suites.
3. Compare with the same run at the merge base of the issue 1026 branch; the distribution is identical.

Expected:
The suites pass on Linux and Windows without host-specific fixtures, and make no real writes outside mocks.

Actual:
Representative errors: `DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.`; `Expected: 'C:\fixture\ws'`; `UnauthorizedAccessException: Access to the path '/repo' is denied.`; `A parameter cannot be found that matches parameter name 'Raw'.`

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: the issue 1026 evidence note isolation-parallel.2026-11-03T18-55.md lists per-suite counts and messages.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Fixtures were written for a Windows host. Commit df7cb4f31 (2026-03-11) normalized other suites with a portable pattern: Join-Path, [IO.Path]::DirectorySeparatorChar, mocks in place of real file system access, no temp files. A sibling item fixes the $env:PATH leak in run-actionlint.Tests.ps1 and must merge first; edits to that file belong to this item only after main is updated.


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

- [x] Unit coverage areas: apply the portable fixture pattern to each of the 17 suites; add any helper under the existing test-support location rather than new copies.
- [x] Integration scenario to retest: single-process Invoke-Pester over the 17 suites on Linux shows 0 failures; Windows CI shards pass; evaluate making the suites eligible for the ubuntu-latest PowerShell leg.
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

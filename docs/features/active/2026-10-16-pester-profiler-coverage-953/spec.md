# 2026-10-16-pester-profiler-coverage (Spec)

- **Issue:** #953
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T00-16
- **Status:** Draft
- **Version:** 0.1

## Context
The Windows `poshqc / PowerShell QC` job sets the length of every CI run. In run 38846579572 it took 18.6 minutes, 15.5 of them in the `Invoke-PoshQCTest` step: about 5,300 Pester tests with breakpoint-based code coverage. Every other job finishes within about 6 minutes. Switching to profiler-based coverage (`CodeCoverage.UseBreakpoints = $false`, Pester 5.4 or later) should shorten that step substantially.

Environment:
- OS/version: GitHub Actions windows-latest; local Windows 11
- Python version: n/a
- Command/flags used: `Invoke-PoshQCTest -Root <workspace>` in `.github/workflows/_poshqc.yml`
- Data source or fixture: full repository Pester suite

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Open any PR against `main`.
2. Inspect the step timings of the `poshqc / PowerShell QC` job.
3. Observe that `Test PowerShell` takes about 15.5 minutes, while every other job finishes within about 6 minutes.

Expected:
The Windows Pester step finishes in a time comparable to the other CI jobs, with no reduction in coverage enforcement.

Actual:
The step takes about 15.5 minutes, so every CI run takes 14–19 minutes.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: run 38846579572 step timings: Analyze PowerShell 2.1m, Test PowerShell 15.5m.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
- Pester coverage uses breakpoint mode, which is markedly slower than profiler mode.
- The Pester version is pinned at 5.6.1 locally in `PoshQC.psm1` but runs as 5.9.0 in CI. Reconcile both to one supported minimum.
- Profiler mode counts lines differently, so per-file coverage figures may shift. Thresholds must still pass. Do not exclude any production file and do not lower any threshold. Document every baseline change.
- Leave the `ci.yml` triggers alone, because a sibling merge-queue item edits them.


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

- [x] Unit coverage areas: the PoshQC module configuration tests, and any test that pins the Pester configuration.
- [x] Integration scenario to retest: full suite under profiler mode with the coverage thresholds evaluated.
- [x] Manual verification notes: record the CI step and job times before and after. If the step is still above about 8 minutes, shard it across a matrix and merge the coverage reports.

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

# 2026-09-27-ci-gaps-linux-pester-and-kcov-set-u (Spec)

- **Issue:** #743
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-30T03-15
- **Status:** Draft
- **Version:** 0.1

## Context
Two CI coverage gaps surfaced as plan and CI surprises. There is no Linux Pester job, and a bats pattern fails only under CI kcov tracing, with nothing to catch it earlier.

Environment:
- OS/version: GitHub runners (windows-latest for Pester; ubuntu for shell coverage)
- Python version: n/a
- Command/flags used: `.github/workflows/_poshqc.yml` (`runs-on: windows-latest`); `_shell-coverage.yml` (bats + kcov)
- Data source or fixture: #707 (AC-16 "Linux runner" wording), #706 (kcov failures)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. CI's only Pester job runs on windows-latest, so the Codex and Claude hook suites have never run on Linux. Planners keep writing "Linux runner" into Pester acceptance criteria (#707 AC-16, amended as D18).
2. A bats test that sources a `set -u` helper inside `bash -c` fails only under kcov tracing, because kcov reads an unset `BASH_SOURCE`. Local bats and preflight do not catch it (#706 FU-706-3).
3. Git for Windows grep 3.0 reads `\\` in a fixed-string pattern as one backslash, so some plan checks cannot pass locally (#706 FU-706-4).

Expected:
PowerShell suites that must be portable run on Linux as well, and known CI-only failure patterns are caught before CI.

Actual:
As above.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: #707 D18; #706 FU-706-3 and FU-706-4; memory note kcov-bash-c-source-set-u.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
A Linux Pester leg would also catch Windows-only path assumptions in PowerShell tests (compare the `C:/workspace` class in memory note ci-gate-polling-and-linux-only-test-failures).


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

- [ ] Unit coverage areas: add an ubuntu matrix leg to `_poshqc.yml`, at least for the hook suites; add a shellcheck or custom lint rule, or a preflight check, for the kcov `set -u` + `bash -c` pattern; add planner guidance on the runner matrix and on the Git-for-Windows grep backslash quirk.
- [ ] Integration scenario to retest: the hook suites pass on both runners.
- [ ] Manual verification notes: expect some Windows-only test assumptions to surface on the first Linux run.

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

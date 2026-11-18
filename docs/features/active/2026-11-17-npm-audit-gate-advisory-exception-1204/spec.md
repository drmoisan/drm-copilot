# 2026-11-17-npm-audit-gate-advisory-exception (Spec)

- **Issue:** #1204
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-17T22-23
- **Status:** Draft
- **Version:** 0.1

## Context
The NPM Audit Gate (`.github/workflows/_npm-audit-gate.yml`, `npm audit --audit-level=moderate` in `.`, `extensions/drm-copilot` and `packages/mcp-server`) now fails on every branch, including `main`. The cause is advisory GHSA-fc5q-39xc-vjpf: a high-severity ReDoS in `picomatch` (`<= 4.0.7`, published 2026-10-19, updated 2026-11-17). It has no patched version, and 4.0.7 is the latest release. `picomatch` reaches the repository only through development dependencies (`jest`, `@parcel/watcher`): `npm ls picomatch --omit=dev --all` is empty in all three manifests, so no shipped artifact contains it. Every PR is blocked, including the high-priority #1201 and its release, and epic #1018.

Environment:
- OS/version: GitHub Actions ubuntu-latest, Node 26.13.0
- Python version: not applicable
- Command/flags used: `npm audit --audit-level=moderate`
- Data source or fixture: the three npm manifests and lockfiles; 42 high findings, all from GHSA-fc5q-39xc-vjpf

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run CI on any branch.
2. Observe that `NPM Audit Gate / npm audit (.)` and `(extensions/drm-copilot)` fail with GHSA-fc5q-39xc-vjpf.

Expected:
The gate still fails on any advisory at or above the configured level, except for advisories listed in a committed, reviewed exception file. Each exception names one advisory id, gives a reason, an owner-approved date and an expiry date, and applies only while every affected path is a development dependency. An exception that has expired, or whose advisory reaches a production dependency, fails the gate. All exceptions are reported in the job log.

Actual:
The gate fails on a development-only advisory that has no fix, so every PR is blocked.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `picomatch <=4.0.7 Severity: high ... ReDoS through single-branch repeated extglobs - https://github.com/advisories/GHSA-fc5q-39xc-vjpf`, with no fix available.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Upstream has not published a patched `picomatch`. The gate has no exception mechanism. Coordinator decision under the owner's autonomy directive: add the narrowest exception possible. It covers one advisory id, is dev-only (verified in the gate with `npm ls <package> --omit=dev --all` or the audit JSON `isDirect`/`effects` data, whichever is simpler and reliable), and expires 30 days after merge (2026-12-18). The exception is recorded in the process-reduction ledger with the prior gate text and a revert note, so it can be removed once upstream ships a fix. The logic goes in bash or node inside the workflow, or in a small PowerShell or bash script under `scripts/ci/`, with no new Python.


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

- [ ] `config/npm-audit-exceptions.json` with one entry for GHSA-fc5q-39xc-vjpf (id, package, reason, approved_at, expires)
- [ ] Gate step: run `npm audit --json`, fail on any advisory at or above the level that is not excepted, fail on an expired exception, and fail when an excepted advisory reaches a production dependency
- [ ] Tests for the filter script: excepted dev-only advisory passes; unexcepted advisory fails; expired exception fails; excepted advisory in a production path fails; malformed exception file fails
- [ ] Process-reduction ledger entry with the prior text and a revert note; actionlint passes; the gate goes green on the PR

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

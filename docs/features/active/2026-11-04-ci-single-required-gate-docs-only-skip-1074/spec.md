# ci-single-required-gate-docs-only-skip (Spec)

- **Issue:** #1074
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-04T09-46
- **Status:** Draft
- **Version:** 0.1

## Context
On a docs-only change, ci.yml's fast pass leaves 8 of the 20 required contexts of ruleset 15241672 unreported, so the pull request stays BLOCKED. Replace the 20 individually required contexts with one required gate job that aggregates the results of every CI job, so the docs-only fast pass can pass without any job faking a result and the individual jobs stay visible.

Environment:
- OS/version: GitHub Actions (ubuntu-latest, windows-latest); Codespace token cannot dispatch workflows (HTTP 403).
- Python version: not applicable.
- Command/flags used: pull_request run of .github/workflows/ci.yml on a head whose last push touches only docs.
- Data source or fixture: PRs #1064, #1070 and #1072 (final docs-only check-off heads).

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Open a PR into main whose latest push changes only docs files (for example an acceptance-criteria check-off).
2. Let ci.yml run. scripts/ci/Invoke-CiChangeScope.ps1 returns code=false.
3. Read mergeStateStatus: BLOCKED; 12 of 20 required contexts reported.

Expected:
A docs-only head passes the required checks quickly (that was the purpose of the change-scope fast pass), and every required check reports.

Actual:
These required contexts never report: `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` (poshqc-shard has a job-level `if: inputs.run-heavy`, so a skipped matrix job never expands its name and reports as `PowerShell QC shard ${{ matrix.shard }}`); `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)` and `(windows-latest)`; `NPM Audit Gate / npm audit (extensions/drm-copilot)`, `(.)`, `(packages/mcp-server)` (ci.yml skips the whole called workflow with `if: needs.changes.outputs.code != 'false'`, so the nested names never appear).

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: PR #1070 head 964caff0c: 12 of 20 required contexts reported, mergeStateStatus BLOCKED; the previous head 86ef18ef1 had all 20 green.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Two inconsistent skip patterns. quality-checks7, security-scan, build-check, shell-coverage and the extension tests keep the job running and guard steps with `if: inputs.run-heavy`, so the job reports under its required name. poshqc-shard/poshqc-static skip at job level, and root-typescript-tests and npm-audit-gate are skipped by ci.yml. Owner decision (2026-11-04): move to ONE required gate. `poshqc / PowerShell QC` already uses an aggregate pattern (needs, if: always()).


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

- [x] Unit coverage areas: add one gate job (for example `CI Required Gate`) to ci.yml with `needs:` on every CI job and `if: always()`; it fails when any needed job's result is `failure` or `cancelled`, accepts `skipped` only for jobs the change scope intentionally skipped, writes a per-job result table to the run summary, and passes on the docs-only path. Keep all underlying jobs visible. Update the workflow pin tests (for example PoshQcWorkflow.Tests.ps1) and any docs describing required checks.
- [x] Integration scenario to retest: (1) a code-touching PR: gate green only when every job is green, red when any job fails (prove with a deliberately failing job on the branch); (2) a docs-only PR: gate green with the heavy jobs skipped; the modified-workflow-needs-green-run rule applies.
- [ ] Manual verification notes: the ruleset change (replace the 20 contexts with the single gate) is a branch-protection edit that must happen AFTER the gate has run green on main; the coordinator or owner applies it with `gh api` on ruleset 15241672. The plan must give the exact command and a rollback command and must not apply it.

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

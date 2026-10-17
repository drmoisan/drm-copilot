# 2026-10-17-ci-docs-only-pr-runs-full-ci (Spec)

- **Issue:** #973
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-17T08-16
- **Status:** Draft
- **Version:** 0.1

## Context
A pull request that changes only documentation still runs the full CI suite. The #962 change-scope gate skips heavy jobs only when it can compare against an earlier full green run on the same branch, so a new docs-only PR (no prior green run) always decides `code=true reason=NO_FULL_GREEN_RUN`. Separately, the docs-only allowlist omits `docs/features/archive/`, `docs/features/parallel/` and `docs/features/epics/`, so archive moves and run-status documents never qualify.

Environment:
- OS/version: GitHub Actions runners (`.github/workflows/ci.yml` `Change scope` job)
- Python version: n/a
- Command/flags used: `scripts/ci/Invoke-CiChangeScope.ps1` with `scripts/ci/CiChangeScope.psm1` and `config/ci-docs-only-paths.json`
- Data source or fixture: PR #972 (records consolidation, docs only), run 39031193305, job 117391813610; PR #941 (archive moves)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Branch from main and change only Markdown files under `docs/features/` (for example, move a folder from `docs/features/active/` to `docs/features/archive/`).
2. Open a pull request.
3. Read the `Change scope` job log.

Expected:
When every path changed relative to the PR's merge base with main is on the docs-only allowlist, the heavy jobs are skipped on the first run, and the 11 required status checks still report success. Archive, parallel-run and epic documentation paths are on the allowlist.

Actual:
The `Change scope` job logs `code=true reason=NO_FULL_GREEN_RUN` and every heavy job runs (PowerShell QC shards 1 to 3, the Linux hook suites, four Python legs, shell coverage). PR #972 (455 renames, 4 additions, 3 modifications, all under `docs/features/`) took a full run. With the base gap fixed, the archive renames would still fail the allowlist check (`NON_ALLOWLISTED_PATH`) because `docs/features/archive/` is not an include prefix.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `2026-10-17T12:06:13.2781666Z code=true reason=NO_FULL_GREEN_RUN` (job 117391813610)


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
- The base for the docs-only comparison is selected only from earlier full green runs on the branch (`Select-CiGreenBaseCandidates` in `scripts/ci/CiChangeScope.psm1`). When there is none, the decision falls through to `NO_FULL_GREEN_RUN` and a full run.
- `config/ci-docs-only-paths.json` `include_prefixes` lists `docs/features/active/`, `completed/`, `potential/` and `docs/research/` only.
- #962 was scoped to the evidence-commit case (the second run of the triple CI run). The new-docs-only-PR case was not covered; this is a scope gap in #962, not a regression.


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

- [x] Unit coverage areas: when no full green run exists on the branch, fall back to the PR merge base with main as the comparison base (main merges only after passing CI under the non-strict ruleset, and push CI on main is confirmed after every merge); decide `code=false` with a `DOCS_ONLY_SINCE_` reason only when every changed path, including both sides of each rename, is allowlisted. Add `docs/features/archive/`, `docs/features/parallel/` and `docs/features/epics/` to `include_prefixes`. Pester rows for: merge-base fallback skip, merge-base fallback with one non-allowlisted path (full run), rename whose source or destination is outside the allowlist (full run), each new prefix, and fail-closed behavior when the merge base cannot be resolved.
- [x] Integration scenario to retest: a docs-only PR (archive move) whose first CI run skips the heavy jobs with all 11 required checks green; then a commit touching a non-allowlisted path on the same PR returns to a full run.
- [ ] Manual verification notes: confirm push CI on main still runs in full after a docs-only merge, or document the intended main-push behavior.

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

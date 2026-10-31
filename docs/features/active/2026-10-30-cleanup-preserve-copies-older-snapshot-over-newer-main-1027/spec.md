# 2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main (Spec)

- **Issue:** #1027
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T20-10
- **Status:** Draft
- **Version:** 0.1

## Context
`cleanup-worktrees.sh --preserve` copies a `preserved_files[]` source file whole onto `target_path`. For `change_class: modified` records, the worktree's copy is often an older snapshot of a note that `main` has since extended, so copying it whole silently drops `main`'s newer lines.

Environment:
- OS/version: not recorded
- Python version: not applicable
- Command/flags used: `cleanup-worktrees.sh --preserve` from the `cleanup-merged-worktrees` skill
- Data source or fixture: a manifest with a `preserved_files[]` record whose `change_class` is `modified` and whose `main` version is newer than the worktree's copy

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

The loss is silent and affects lesson and memory notes, which are the content the workflow exists to preserve.


## Repro & Evidence
Steps to Reproduce:
1. Have a worktree holding an older snapshot of a documentation or memory note that `main` has since extended.
2. Write a manifest with a `preserved_files[]` record for it, with `change_class: modified`.
3. Run `cleanup-worktrees.sh --preserve`.
4. Compare the staged file on the consolidation branch with `main`'s version.

Expected:
- For `modified` records, stage only the worktree's added lines onto `main`'s current version (a three-way merge against the merge-base, or an "added lines only" mode).
- Otherwise refuse the record with `ACTION|preserve-stage|<path>|REFUSED-WOULD-REGRESS`.
- Never overwrite a target whose `main` version has lines absent from the source.

Actual:
The source file is copied whole onto `target_path`, so `main`'s newer lines are silently lost.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: none; the failure is silent.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
`--preserve` treats every record as a whole-file copy. It has no merge-base comparison and no regression check against the current `main` version. Same workflow as the sibling bug on checkpoint gates blocking the cleanup workflow; this defect is independent of it and can be fixed separately.


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

- [x] Unit coverage areas: `--preserve` on a `modified` record whose `main` version is newer is either merged without losing `main` lines or refused with `REFUSED-WOULD-REGRESS`, and is never overwritten; an unmodified `main` version still copies as before; an `added` record is unaffected. Bats cases where the script is tested.
- [ ] Integration scenario to retest: the full cleanup workflow end to end (see the sibling bug).
- [ ] Manual verification notes

Language note: the script is bash; the fix stays in bash.

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

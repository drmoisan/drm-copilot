# 2026-10-16-ci-skip-evidence-only-commits (Spec)

- **Issue:** #962
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T10-27
- **Status:** Draft
- **Version:** 0.1

## Context
Each item costs three full CI runs (about 12–19 minutes each) to reach a clean merge:
1. the run that proves the code green;
2. a run triggered by the commit that records that CI evidence (docs only);
3. a run after the branch is re-synced with main.

Run 3 is removed by the merge queue (#952). This issue removes run 2. When every file changed since the branch's last fully green CI commit is an evidence or docs path, the heavy CI jobs are skipped and only docs validation runs. Evidence documentation is still committed in full.

Environment:
- OS/version: GitHub Actions (windows-latest, ubuntu-latest)
- Python version: n/a
- Command/flags used: `.github/workflows/ci.yml` on `pull_request` events
- Data source or fixture: #953 / PR #959, which ran CI three times for one code state

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Push code to an item branch and wait for a green CI.
2. Commit the CI evidence under `docs/features/<item>/` and push.
3. Observe that a full CI run starts, although the code tree is identical to the one just tested.

Expected:
A push whose diff since the last fully green commit touches only evidence or docs paths runs docs validation only. Every required check still reports success.

Actual:
Every push runs the full matrix, about 12–19 minutes.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: PR #959 CI runs 38896856766, 38896898318 and 38899482473 cover one code state.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
Design: add a first `changes` job to `ci.yml`.
- **Find the base.** Locate the newest commit on the PR head branch that has a successful, non-skipped full CI run, using the Actions API and `GITHUB_TOKEN`, read-only.
- **Ancestry.** Require that commit to be an ancestor of HEAD.
- **Diff.** Compute `git diff --name-only <green>..HEAD`.
- **Decision.** If the diff is non-empty and every path matches a configured evidence/docs allowlist (`docs/features/**`, `docs/research/**`, and others to be decided in the spec), output `code=false`. Otherwise output `code=true`.
- **Fail closed.** Missing green run, non-ancestor, API error, or any path outside the allowlist all give `code=true`.
- **Never skip** on `merge_group`, `push` to main, or `workflow_dispatch` events.

Heavy jobs then use `if: needs.changes.outputs.code == 'true'`. A job skipped by `if:` satisfies required status checks. Confirm this for reusable-workflow callers and matrix jobs, including the sharded `poshqc / PowerShell QC` aggregator from #953 and the required-check contexts of ruleset 15241672. Docs validation always runs.

Coordinate with #952, which adds the `merge_group` trigger to `ci.yml`, and with #953, which shards `_poshqc.yml`. Schedule this item after both.

The repository's own CI-gate tooling (`.claude/lib/ci-gate`, the orchestrate step 9 durable-green check) must treat skipped-by-design required checks as green. Check that it does, and fix it if not.


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

- [x] Unit coverage areas: the path-classification and ancestry decision logic as a testable script (bash or PowerShell, no Python), with tests for the allowlist, a non-ancestor base, a missing base, an empty diff and mixed diffs.
- [x] Integration scenario to retest: on this PR, push a docs-only evidence commit after a green run and confirm that the heavy jobs show as skipped and every required check passes. Then push a code change and confirm the full run.
- [x] Manual verification notes: record the time an evidence-commit CI takes before and after.

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

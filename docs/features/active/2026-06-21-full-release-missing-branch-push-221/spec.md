# full-release-missing-branch-push (Spec)

- **Issue:** #221
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-21T12-06
- **Status:** Draft
- **Version:** 0.1

## Context
`scripts/dev-tools/Invoke-FullRelease.ps1` fails when opening the release PR because the locally created release branch is never pushed to the remote before `gh pr create` runs.

Environment:
- OS/version: Windows, PowerShell 7+
- Python version: n/a
- Command/flags used: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/Invoke-FullRelease.ps1 -ConfirmToken yes`
- Data source or fixture: n/a

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The full release task cannot open a PR; the release flow is blocked at the final step.


## Repro & Evidence
Steps to Reproduce:
1. Ensure a clean working tree on a branch ahead of `main`.
2. Run the "Release: Open Full Version-Bump PR" task (`Invoke-FullRelease.ps1 -ConfirmToken yes`).
3. Observe the run reach Step 5 (`gh pr create`).

Expected:
The release branch is published to `origin` and a version-bump PR is opened against `main`.

Actual:
PR creation fails with:

```
pull request create failed: GraphQL: Head sha can't be blank, Base sha can't be blank, No commits between main and release/full-20260621155124, Head ref must be a branch (createPullRequest)
Failed to open release PR (gh exit code 1).
```

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior.


## Scope & Non-Goals
- In scope: Add a release-branch push step to `scripts/dev-tools/Invoke-FullRelease.ps1` between the commit (Step 4) and PR creation (Step 5); add/update Pester coverage in `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`.
- Out of scope / non-goals: Changes to `Invoke-ReleaseTagPush.ps1`; changes to CI workflows; changes to version-bump logic; changes to the PR title/body content.
- Explicitly excluded systems, integrations, or datasets: No live git/gh/npm execution; no network calls in tests (wrapper seams are mocked).

## Root Cause Analysis
In `Invoke-FullReleaseGuarded`, Step 4 commits the bumped manifests on the local release branch, then Step 5 calls `gh pr create --base main --head $branchName`. The branch is never pushed to `origin`. In non-interactive mode with an explicit `--head`, `gh pr create` does not push the branch, so the remote has no ref or SHA for it. GitHub therefore reports blank head/base SHAs and "No commits between main and release/...".

The companion `Invoke-ReleaseTagPush.ps1` establishes the correct pattern: it explicitly pushes via the `Invoke-GitExe` seam (`git push origin <tag>`). `Invoke-FullRelease.ps1` is missing the equivalent branch push.


## Proposed Fix

### Design summary (what changes where):
Insert a branch-push step in `Invoke-FullReleaseGuarded` after the commit (Step 4) and before `gh pr create` (Step 5). The step runs `git push -u origin $branchName` through the existing `Invoke-GitExe` seam. On a non-zero exit code, write a `Write-StderrLine` diagnostic and return 1, matching the established failure-handling pattern.

### Boundaries and invariants to preserve:
- All external executable calls remain isolated behind the `Invoke-GitExe` / `Invoke-NpmExe` / `Invoke-GhExe` wrapper seams.
- Existing return-code contract preserved: 2 on missing confirmation, 1 on missing manifest / dirty tree / failed git or gh seam, npm exit code on bump failure, 0 on success.
- No tagging and no publishing in this script.
- File remains under 500 lines.

### Dependencies or blocked work: none.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `scripts/dev-tools/Invoke-FullRelease.ps1` (production)
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (tests)

#### Functions/classes/CLI commands impacted:
- `Invoke-FullReleaseGuarded` — add the push step.

#### Data flow and validation changes:
- New `Invoke-GitExe -GitArgs @('push', '-u', 'origin', $branchName)` call; branch the result's `ExitCode`.

#### Error handling and logging updates:
- New diagnostic on push failure: "Failed to push release branch '<branch>' to origin (git exit code <n>)." Return 1.

#### Rollback/feature-flag considerations (if applicable): none.

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

- [x] Unit coverage areas: add a Pester case for the push-failure path; update the success-path test to assert the push call occurs before `gh pr create`.
- [ ] Integration scenario to retest
- [x] Manual verification notes: re-run the release task and confirm a PR opens.

Add a Step between commit (Step 4) and PR creation (Step 5) that runs `git push -u origin $branchName` through the existing `Invoke-GitExe` seam, returning a non-zero exit with a `Write-StderrLine` diagnostic on failure.

- Regression tests to add or update:
- Unit tests (pytest) for the fixed behavior and boundaries:
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
- Error handling and logging verification:
- Coverage impact and targets for changed lines/modules:
- Toolchain commands to run (format → lint → type-check → test):
- Manual validation steps (if required):


## Acceptance Criteria
- [x] Repro steps now produce the expected behavior in all documented environments.
- [x] Regression test(s) added and passing (list file path and test name).
- [x] Edge cases and invalid inputs are handled with correct errors or fallbacks.
- [x] No unintended behavior changes outside the defined scope.
- [x] Required logs/telemetry updated and validated (if applicable).
- [x] Performance constraints met or explicitly waived with rationale.
- [x] Full toolchain pass completed (format → lint → type-check → test).
- [x] Docs/config references updated to match the new behavior.

## Risks & Mitigations
- Technical or operational risks:
- Mitigations and rollbacks:

## Rollout & Follow-up
- Release/rollout steps:
- Post-fix monitoring or clean-up tasks:
- Links: issue, PRs, related docs

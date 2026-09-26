# 2026-08-28-pr-context-gh-detection-false-negative (Spec)

- **Issue:** #588
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-25T22-06
- **Status:** Draft
- **Version:** 0.1

## Context
The PR-context collector reports `GitHub CLI unavailable: GitHub CLI (gh) is not installed` in sessions where `gh` is installed and working. Because the `pr-author` skill correctly refuses to emit an unverified `Closes #<N>` keyword, the false negative silently produces a PR body with no autoclose link, and the issue stays open after merge.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment (`poetry run`)
- Command/flags used: `mcp__drm-copilot__collect_pr_context` with `base=origin/main`; equivalent CLI entry point writes `artifacts/pr_context.summary.txt`
- Data source or fixture: worktree `drm-copilot-wt/2026-08-28T19-50`, branch `feature/atomic-preflight-convergence-586`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Severity rationale: the failure is silent and produces a wrong end state (issue left open on merge) rather than an error. It is recoverable by a second `pr-author` pass, but only if a human or orchestrator notices the missing link. Every PR authored from a bundle generated under this condition is affected.


## Repro & Evidence
Steps to Reproduce:
1. In a worktree where `gh auth status` succeeds, run the PR-context collector against a base branch (`collect_pr_context` with `base=origin/main`).
2. Read `artifacts/pr_context.summary.txt` and look at the GitHub CLI availability line and the `Issues to autoclose (verified or pending):` line.
3. In the same shell and same working directory, run `gh issue view <N> --json number,state,title`.

Expected:
The collector detects the working `gh` binary, verifies the candidate issue, and lists it under `Issues to autoclose (verified or pending):` so that `pr-author` can emit `Closes #<N>` on the verified path.

Actual:
The summary records `GitHub CLI unavailable: GitHub CLI (gh) is not installed` and `Issues to autoclose (verified or pending): None`, while `gh issue view 586` in the same session returns `{"number":586,"state":"OPEN","title":"Feature: atomic-preflight-convergence"}` and `gh pr create` succeeds moments later. `pr-author` therefore applies its documented no-`Closes` fallback and the PR body ships with the issue recorded only as author-asserted.

Logs / Screenshots:
- [x] Attached minimal logs or snippet
- Snippet:
  - `artifacts/pr_context.summary.txt`: `GitHub CLI unavailable: GitHub CLI (gh) is not installed`
  - `artifacts/pr_context.summary.txt`: `Issues to autoclose (verified or pending): None`
  - Same session: `gh issue view 586 --json number,state,title` -> `{"number":586,"state":"OPEN","title":"Feature: atomic-preflight-convergence"}`
  - After manual remediation: `gh pr view 587 --json closingIssuesReferences` returns issue 586


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
- The collector's `gh` availability probe resolves the executable differently from the shell used by `Bash(gh *)` tool calls, most likely a PATH or executable-resolution difference in the subprocess the collector spawns on Windows (for example resolving `gh` without the `.exe`/`.cmd` extension, or spawning without shell resolution).
- Observed first on issue #586 / PR #587 on 2026-08-28.
- Files to inspect: the PR-context collection implementation behind `mcp__drm-copilot__collect_pr_context` and whatever helper performs the GitHub CLI availability check and the autoclose-issue verification.


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

- [x] Unit coverage areas: the `gh` availability probe, with a test that a resolvable-but-extension-suffixed executable is detected on Windows; and the autoclose-verification path, with a test distinguishing "gh unavailable" from "gh available and issue not found", since those two states currently collapse to the same `None` output.
- [x] Integration scenario to retest: run the collector in a session where `gh auth status` succeeds and assert the summary reports the CLI as available and lists the verified autoclose issue.
- [x] Manual verification notes: after any fix, confirm end to end with `gh pr view <N> --json closingIssuesReferences`, which is GitHub's own parse of the keyword and therefore stronger evidence than grepping the PR body for the literal text.
- Consider making the two states textually distinct in the summary so a reader can tell a probe failure from a genuine absence of autoclose candidates.

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

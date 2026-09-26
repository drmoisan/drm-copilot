# 2026-08-29-cleanup-worktrees-apply-deletes-local-main (Spec)

- **Issue:** #594
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-25T22-07
- **Status:** Draft
- **Version:** 0.1

## Context
`scripts/bash/cleanup-worktrees.sh --apply` deletes the local `main` branch on every invocation in this repository. It processes `main` as an ordinary candidate branch, diffs it against itself, and the empty diff classifies as `MERGED_CLEAN`, which the apply-mode deletion pass then acts on with `git branch -D main`.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: N/A (bash script, not Python)
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh --apply`
- Data source or fixture: live repository state (110 local branches, ~50 worktrees) in `C:\Users\DanMoisan\repos\drm-copilot`

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Rationale: this is the repository's primary integration branch. Losing the local ref breaks any local tooling, script, or workflow that assumes `main` exists as a local branch (merge-base resolution, other worktrees' ancestry checks, manual `git checkout main`), until manually restored.


## Repro & Evidence
Steps to Reproduce:
1. From the repository root, with a local `main` branch present and up to date with `origin/main`, run `bash scripts/bash/cleanup-worktrees.sh --apply`.
2. Let the run proceed through its full branch enumeration.
3. Observe the report line `BRANCH|main|MERGED_CLEAN` followed by `ACTION|branch-delete|main|OK`, and confirm afterward that `git branch --list main` returns nothing.
4. Reproduced twice in the same session (two separate `--apply` invocations), with the identical outcome both times.

Expected:
`main` (and any other repository default/protected branch) must never appear as a deletable candidate in apply mode. The script already has a `PROTECTED_CURRENT` classification for the branch checked out in the primary worktree; `main` should receive equivalent, unconditional protection regardless of which branch is currently checked out, since it is the fixed comparison base every other branch's ancestry is judged against.

Actual:
Local `main` is deleted (`ACTION|branch-delete|main|OK`) whenever a different branch (in this case `chore/cleanup`) is checked out in the primary worktree at run time. Once `main` is gone, every subsequent `BRANCH|...` classification in the same run degrades to `ANCESTRY_ERROR`, because `git merge-base`/`git diff main...<branch>` can no longer resolve `main`. This cascaded across roughly 50 branches in each affected run, masking their true classification for that pass.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:
```
BRANCH|main|MERGED_CLEAN
ACTION|branch-delete|main|OK
BRANCH|parallel/critical-bug-fixes-plan|ANCESTRY_ERROR
BRANCH|worktree-agent-a046a08b20e685723|ANCESTRY_ERROR
... (cascades through all remaining branches in the run)
```


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
- Files to inspect: `scripts/bash/cleanup-worktrees.sh`, `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh` — specifically wherever the branch-enumeration loop builds its candidate list and wherever `PROTECTED_CURRENT` is assigned. `main` is very likely being fed through the same self-diff/self-merge-base comparison as any other branch instead of being short-circuited as the immovable comparison base.
- Both observed runs restored `main` successfully afterward via `git branch main origin/main`, since local `main` was byte-identical to `origin/main` (no divergence) immediately before each run — no data was lost in either occurrence, but this will not hold if `main` ever has local-only commits at the time `--apply` runs.
- A related, apparently unrelated observation from the same session: a worktree that appeared mid-run (`drm-copilot-wt/2026-08-29T11-55`, live and owned by a concurrent session on branch `feature/claude-planning-integrity-593`) hit `Permission denied` during its removal attempt and was reported `BLOCKED-DIRTY`; the worktree itself was left intact and undamaged. Worth confirming the script has no other code path that could partially remove a live worktree's `.git` file on a failed deletion, even though this instance ended safely.


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

- [ ] Unit coverage areas: add a regression test asserting that `main` (and, more generally, the branch matching the repository's configured default branch) is excluded from the apply-mode deletion candidate set unconditionally, independent of `PROTECTED_CURRENT`/current-branch detection.
- [ ] Integration scenario to retest: run `--apply` in a throwaway fixture repo with a non-`main` branch checked out and confirm `main` survives and is never even reported as a `BRANCH|main|...` candidate line (or is reported with a distinct always-protected state).
- [ ] Manual verification notes: after the fix, re-run `--apply` in this repository and confirm `git branch --list main` still returns `main` afterward, and that no `ANCESTRY_ERROR` cascade appears for the remaining ~50 branches.

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

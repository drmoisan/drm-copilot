# 2026-11-17-release-commit-allowance-preimplementation-gate (Spec)

- **Issue:** #1201
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-17T14-05
- **Status:** Draft
- **Version:** 0.1

## Context
The preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, its helpers, and the `.codex/hooks` twin) denies every agent `git add` / `git commit` unless `artifacts/orchestration/orchestrator-state.json` holds a ready checkpoint. A routine release version bump has no orchestration checkpoint, so an agent running a release skill cannot commit the bumped version files. A destination repository cannot add its own exemption: the hooks are push-down managed (a local edit is overwritten on refresh), and a separate local hook cannot override another hook's deny. The exemption must ship from this repository, with each destination declaring its own allowance in a file that push-down never writes. High priority.

Environment:
- OS/version: Windows 11 and Linux, Claude Code and Codex runtimes
- Python version: not applicable
- Command/flags used: an agent release skill running `git add package.json CHANGELOG.md` then `git commit -m "..."` on a `release/v*` branch with no orchestration checkpoint
- Data source or fixture: any destination repository receiving the push-down hooks

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. In a destination repository with the pushed-down hooks, check out a release branch with no orchestration checkpoint.
2. Bump the version files and have an agent run `git add` on them.
3. Observe PREIMPLEMENTATION_GATE_BLOCKED.

Expected:
1. Repository-owned config file `.claude/release-commit-allowance.json` (listed in no pack manifest; push-down never creates, overwrites or deletes it). Schema version 1: `{ "schema_version": 1, "allowances": [ { "id": "release-version-bump", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json", "CHANGELOG.md"] } ] }`. `id` non-empty and unique; `branch_patterns` non-empty list of globs matched against the full current branch name; `allowed_paths` non-empty list of literal repository-relative forward-slash paths (no globs, directories, `..` segments, or absolute paths). File absent: gate behaves exactly as today. File present but unreadable or invalid (bad JSON, unknown schema_version, missing or empty fields, a glob or directory in allowed_paths): the gate denies with a specific code, for example `RELEASE_ALLOWANCE_CONFIG_INVALID: <detail>`; never silently allow.
2. New allow leg in the gate, command leg only (Bash and PowerShell `command` input; Write/Edit path leg and delegation leg unchanged). Allow-side only: consulted after the checkpoint readiness check fails, like the cleanup-context legs (#1026) and the orchestration-bookkeeping staging exemption (#539); never suppresses another hook's deny; never changes trigger classification.
   - Branch: resolve the current branch of the target worktree (honour literal `git -C <path>` like the existing resolver; deny an unexpandable `-C` value such as a shell variable). Detached HEAD or an unmatched branch gets no allowance.
   - Chained commands fail closed: the whole line must split cleanly and every segment must independently qualify as an allowed `git add` or `git commit` under the same allowance; any other segment denies.
   - `git add`: only literal path operands, each in that allowance's allowed_paths, optionally after `--`. Deny -A, --all, -u, --update, `.`, globs, directories, -f/--force, --pathspec-from-file, -p/-i, and any operand not in the list.
   - `git commit`: allowed options only -m/--message, -F/--file (repeatable), -s/--signoff. Deny -a/--all, --amend, --no-verify/-n, -c/-C/--reuse-message, --fixup/--squash, --allow-empty, --only/--include, any pathspec operand, and any `git -c <key>=<value>` prefix. The staged index (`git diff --cached --name-only -z` in the target worktree) must be non-empty and every staged path in allowed_paths; an unreadable index denies.
   - Deny suffixes follow the cleanup-leg convention, one code per failure: RELEASE_ALLOWANCE_BRANCH_NOT_MATCHED, RELEASE_ALLOWANCE_PATH_NOT_ALLOWED, RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED, RELEASE_ALLOWANCE_STAGED_PATH_NOT_ALLOWED, RELEASE_ALLOWANCE_STAGED_INDEX_EMPTY, RELEASE_ALLOWANCE_STAGED_INDEX_UNREADABLE. The suffix is appended to the existing PREIMPLEMENTATION_GATE_BLOCKED reason only when a release allowance exists for the repository; repositories without the file see today's text.
3. Out of scope: no change to the pr-author hooks (PR creation stays exclusive to pr-author); no change to git push handling or any other gate; no default allowance ships in the payload.
4. Tests and contracts: Pester tests for the config parser (valid, absent, each invalid case) and table-driven tests for the allow leg (allowed add, allowed commit, each forbidden option, a forbidden operand, branch mismatch, detached HEAD, chained command with one non-qualifying segment, staged index with an extra path, empty index, unreadable index, unexpandable `-C`). Mock git through the existing wrapper seam; no live git, no temporary files. A push-down contract test asserting no pack manifest lists the allowance file and a refresh leaves an existing allowance file byte-identical. Keep `.claude`/`.codex` twins byte-identical; add any new helper to the core pack manifest so the dependency-closure test passes.
5. Documentation: the allowance file, schema, matching rules and deny codes in the execution-environment skill (hook section) and in the rule that describes the preimplementation gate; a changelog entry stating destinations receive the leg through the next push-down refresh and opt in by creating the file.

Actual:
Every agent `git add` / `git commit` without a ready checkpoint is denied, including a release version bump.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.`


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
The gate has allow legs for cleanup contexts (#1026) and orchestration bookkeeping (#539) but none for a repository-declared release commit. Acceptance: without the file, decisions and deny text unchanged (existing gate tests pass unmodified); with a valid file, an agent on a matching branch can `git add <allowed paths>` then `git commit -m "<message>"` with only those paths staged and no checkpoint; every forbidden variation is denied with its specific code; a push-down refresh does not modify the allowance file. The epic #1018 architecture is changing the hooks (dispatcher, generators, push-down consolidation), so this change may need adapting when merged into the epic integration branch.


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

- [ ] Config parser module (PowerShell) with the validation rules above
- [ ] Allow leg sibling file wired into the gate after the readiness failure, both runtimes, bundles and core pack manifest
- [ ] Table-driven Pester tests with the git wrapper seam; push-down contract test
- [ ] Docs and changelog

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

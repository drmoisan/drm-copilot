# remove-secondary-worktrees-command — Spec

- **Issue:** #194
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-17T16-01
- **Status:** Draft
- **Version:** 0.1

## Overview

The repository workflow creates secondary git worktrees (for example, the `New Claude Worktree Session` command creates `<repo>-wt-<timestamp>` worktrees). These accumulate and must be cleaned up. A draft PowerShell script exists at `scripts/dev-tools/remove-worktrees.ps1`, but it is untested, is not integrated into the extension workflow, and uses a Windows-centric file-lock probe that does not generalize. There is no extension command to remove secondary worktrees safely.


## Behavior

Add a VS Code command to the drm-copilot extension that removes all secondary worktrees of the current repository. The command must:

- Enumerate worktrees and exclude the primary (main) worktree.
- Attempt to remove each secondary worktree.
- Be robust to errors: a worktree that cannot be fully removed is left intact (not partially deleted), and the command continues with the remaining worktrees.
- Report which worktrees were removed and which were skipped, with reasons.
- Be implemented in TypeScript to avoid runtime dependencies and be fully unit-tested with pure logic separated from the git I/O boundary.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

## Constraints & Risks

- Cross-platform: the file-lock probe in the draft PowerShell script does not translate to Node/TypeScript. The non-removability determination must rely on `git worktree remove` semantics (non-`--force` failure for dirty/locked worktrees) rather than OS-specific lock probing.
- Destructive operation: must never partially delete a worktree or remove the primary worktree.
- Must follow the extension's established command-runtime and pure-logic/I/O separation patterns.
- Bundled-mirror and toolchain (Prettier/ESLint/TSC/Jest) obligations apply.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [x] Edge cases and error handling covered by tests
- [x] Docs updated (README, docs/features/active/... links)
- [x] Telemetry/logging added or updated (if applicable)
- [x] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Parsing of `git worktree list --porcelain`, including the primary-worktree exclusion.
- [x] Aggregation of per-worktree success/failure outcomes.
- [x] Skip-on-failure behavior with continuation.
- [x] No-secondary-worktrees case.
- [x] Command registration and disposal.

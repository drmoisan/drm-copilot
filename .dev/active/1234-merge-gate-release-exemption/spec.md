# 2026-11-23-merge-gate-release-exemption — Spec

- **Issue:** #1234
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23T22-54
- **Status:** Draft
- **Version:** 0.1

## Overview

Issue #1201 lets an agent commit a release version bump without an orchestration checkpoint on a branch matching the destination-owned `.claude/release-commit-allowance.json`, and issue #1231 (PR #1232) lets the same agent open the release pull request without a checkpoint. Merging that pull request is still blocked. `.claude/hooks/enforce-epic-merge-gate.ps1` admits a `gh pr merge` only through an epic, parallel, green-CI standalone, or `standalone_merge_authorizations` branch, and every one of those reads an orchestrator checkpoint. A checkpoint-free release pull request therefore reaches `EPIC_MERGE_GATE_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE`, and the release flow stops one step before completion. This was recorded as out of scope (decision D1) in #1231.


## Behavior

Add a release leg to the merge gate, keyed on the same `.claude/release-commit-allowance.json` (schema version 1, unchanged) and built like the release legs of #1231:

- The leg is evaluated only after the existing branches decline, and only when no orchestrator checkpoint records the pull request number.
- It admits a single structural `gh pr merge <N>` (one explicit number, no chain, wrapper, `-R`/`--repo`, URL selector, `--auto`, or `--admin`) that carries `--match-head-commit <sha>`.
- One bounded `gh pr view <N>` read supplies the head branch, base branch, live head SHA, state, and changed files. The head branch must match a `branch_patterns` entry of one allowance, the live head must equal `--match-head-commit`, and every changed path must equal an `allowed_paths` entry of that same allowance.
- CI on the live head must be green: the newest `CI` workflow run for the head commit, from a `pull_request` event, is `completed` with conclusion `success`.
- Without an allowance file, deny text is byte-identical and no extra `gh` call is made. Each failure appends a distinct `RELEASE_MERGE_*` sub-code after the existing reasons.
- The Codex merge gate is evaluated for parity: if `.codex/hooks/enforce-epic-merge-gate.ps1` blocks the same case, the same leg is added there; otherwise the decision is recorded.


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

- Policy-level control, not a security control: whoever commits the allowance file decides which paths may be merged without a checkpoint. CI green on the exact head is the remaining safeguard.
- A push after the lookup can change the head; requiring `--match-head-commit` closes that race.
- The allowance file is destination-owned and never pushed down; this repository commits none.
- PowerShell only; `enforce-epic-merge-gate.ps1` is at 498 lines, so the leg goes in a sibling file.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, .dev/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage of the release merge predicate with injected `gh` and file seams
- [ ] Integration through the merge gate's decision order with existing branches declining
- [ ] Byte-identity of mirrors and pack-manifest listing

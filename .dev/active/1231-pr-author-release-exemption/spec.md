# 2026-11-23-pr-author-release-exemption — Spec

- **Issue:** #1231
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23T17-58
- **Status:** Draft
- **Version:** 0.1

## Overview

Issue #1201 added the release-commit allowance: a destination repository that commits `.claude/release-commit-allowance.json` lets an agent stage and commit a release version bump on a matching branch without an orchestration checkpoint. Opening the release pull request remains blocked. `.claude/hooks/enforce-pr-author-skill.ps1` requires an orchestrator-state checkpoint that passes `--require-pr-creation-ready` for every `gh pr create --body-file`, and its only checkpoint-free exemptions are the docs-only exemption (#901, every path under `docs/`) and the cleanup consolidation exemption (#1026, branch `documentationandmemories`). A release diff changes package manifests, lockfiles, and configuration files, so neither exemption applies.

Today a release pull request is opened only because `scripts/dev-tools/Invoke-FullRelease.ps1` calls `gh pr create` inside a PowerShell process the hook cannot read. That is an inspection gap, not a designed path, and destination repositories have no equivalent script. An agent-driven release therefore needs a full orchestration checkpoint for a version-bump diff of a few files.


## Behavior

Add a release exemption to the checkpoint-free path of the pr-author surface, keyed on the existing destination-owned `.claude/release-commit-allowance.json` (schema version 1, unchanged):

- `enforce-pr-author-skill.ps1`: after the checkpoint preflight fails and the docs-only and cleanup exemptions decline, exempt a structural `gh pr create` when no checkpoint exists at the resolved path, the command carries exactly one explicit `--head` and one explicit `--base`, the head branch matches a `branch_patterns` entry of one allowance, the pushed remote head equals the worktree `HEAD`, and every path in the `origin/<base>...HEAD` diff equals an `allowed_paths` entry of that same allowance. The receipt checks (body file, context summary, SHA-256 receipt) still run unchanged.
- Any other gate that blocks a checkpoint-free release pull request (for example the `Agent(pr-author)` model-routing gate and the preimplementation gate for the receipt Write) gains an equivalent allow-side leg, built the same way as the existing cleanup and docs-estate legs.
- Failures append a release sub-code after the existing exemption reasons; deny text without an allowance file is unchanged.


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

- Policy-level control, not a security control: whoever can commit the allowance file decides which paths may reach a pull request without a checkpoint.
- The allowance file is destination-owned and never pushed down; this repository commits none.
- PowerShell only; file-size limits apply to the hook files (split into a sibling file as the docs-only and cleanup legs do).
- Hooks run with the default branch's copy in isolated subagents, so behaviour is proven by Pester.


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
- [ ] Unit coverage of the release exemption predicate with injected git and file seams
- [ ] Integration through `Get-PrAuthorBypassReason` with a stubbed checkpoint preflight
- [ ] Byte-identity of mirrors and pack-manifest listing

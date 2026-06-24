# require-pr-author-agent-for-prs — Spec

- **Issue:** #231
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T15-17
- **Status:** Draft
- **Version:** 0.1

## Overview

PR bodies must be produced by the `pr-author` skill, but the current enforcement (`enforce-pr-author-skill.ps1`) only checks that `gh pr create`/`gh pr edit` use `--body-file` with the PR-context artifact present. It does not verify that the body was authored by a dedicated `pr-author` agent, and there is no `pr-author` agent in `.claude/agents/`. As a result, the orchestrator (main thread) can hand-write a PR body to a file and open the PR directly, bypassing the `pr-author` skill workflow — which is exactly what happened for PR #228.


## Behavior

- Add a `pr-author.md` agent under `.claude/agents/` (and bundled/translated copies in the Codex and GitHub Copilot ecosystems) whose sole responsibility is to run the `pr-author` skill: consume the canonical PR-context bundle and produce the PR body, then open/update the PR.
- Strengthen the enforcement so that opening a PR (`gh pr create`) — and editing a PR body (`gh pr edit --body`/`--body-file`) — is permitted only when performed by the `pr-author` agent. Any attempt by the main thread or another agent to open a PR is blocked.
- Provide a verifiable signal the hook can use to attribute the action to the `pr-author` agent (for example an env var identifying the active subagent, or an authorization artifact emitted by the agent), determined during research.


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

- The hook must reliably attribute a `gh pr create` call to the `pr-author` agent; the available attribution mechanism (env var vs. authorization artifact) must be verified before implementation.
- Must not deadlock orchestration: the orchestrator must be able to delegate to the `pr-author` agent to satisfy the gate.
- Cross-ecosystem consistency: root and bundled copies must stay in sync; Codex copies are translations.


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
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] PreToolUse hook unit tests for allowed and blocked PR-open attempts.
- [ ] Attribution-signal handling (present vs. absent).
- [ ] Backward compatibility with the existing `--body-file` + context-artifact checks.

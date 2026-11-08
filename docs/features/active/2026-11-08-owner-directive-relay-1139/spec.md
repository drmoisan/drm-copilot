# owner-directive-relay — Spec

- **Issue:** #1139
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T12-32
- **Status:** Draft
- **Version:** 0.1

## Overview

When the repository owner gives an instruction to the coordinator session (for example "merge without waiting for X", "skip the optional Y", "approve one more planner revision"), the coordinator relays it to a delegated orchestrator or specialist in the delegation prompt or via SendMessage. Subagents refuse these relayed instructions because they cannot distinguish an owner directive from model-authored text, and the harness tells them that agent-to-agent messages carry no user authority. Observed in the iar-migration three-layer redesign epic (E1/E2, 2026-11-07/08): owner instructions relayed by the coordinator were refused, stalling the run. There is no defined, auditable mechanism for an owner directive to reach a subagent.


## Behavior

Define an auditable owner-directive mechanism:

- A recorded owner-directive block with a fixed shape (directive id, verbatim owner text, timestamp, scope: issue/branch/step, issuing coordinator session, expiry) carried in the delegation prompt and persisted in the checkpoint (`owner_directives[]` in orchestrator-state / epic-orchestrator-state).
- A written policy (in the orchestrate / epic-orchestrate skills and a rule) stating which directive classes subagents honor (e.g. scheduling, merge timing in autonomous mode, granting one extra planner revision, scope narrowing, accepting a recorded non-blocking deviation) and which they must refuse regardless (bypassing hooks, weakening gates, force pushes, tag pushes/publishing, editing policy files, permission or settings changes, deleting evidence).
- Subagents record each honored or refused directive in the checkpoint with the reason.
- A validator or hook check that a directive referenced in the checkpoint matches the recorded block (no invented directives).


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

- Must not create a path for prompt injection or self-authored "owner" directives: directives originate only from the coordinator session's owner turns and are recorded before relay.
- No new Python; hooks and libraries in PowerShell or bash.
- Must not weaken any gate's intent.


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
- [ ] Unit coverage areas: directive schema validation, classification of allowed vs refused classes, checkpoint recording.
- [ ] Integration scenarios: coordinator relays an allowed directive (extra planner revision) and a refused one (bypass a hook).
- [ ] CLI/API examples: validator run on a checkpoint with and without a matching directive block.

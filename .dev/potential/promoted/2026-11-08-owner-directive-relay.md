# owner-directive-relay (Issue #1139)

- Date captured: 2026-11-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/owner-directive-relay/ (Issue #1139)

- Issue: #1139
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1139
- Last Updated: 2026-11-08
## Problem / Why

When the repository owner gives an instruction to the coordinator session (for example "merge without waiting for X", "skip the optional Y", "approve one more planner revision"), the coordinator relays it to a delegated orchestrator or specialist in the delegation prompt or via SendMessage. Subagents refuse these relayed instructions because they cannot distinguish an owner directive from model-authored text, and the harness tells them that agent-to-agent messages carry no user authority. Observed in the iar-migration three-layer redesign epic (E1/E2, 2026-11-07/08): owner instructions relayed by the coordinator were refused, stalling the run. There is no defined, auditable mechanism for an owner directive to reach a subagent.

## Proposed Behavior

Define an auditable owner-directive mechanism:

- A recorded owner-directive block with a fixed shape (directive id, verbatim owner text, timestamp, scope: issue/branch/step, issuing coordinator session, expiry) carried in the delegation prompt and persisted in the checkpoint (`owner_directives[]` in orchestrator-state / epic-orchestrator-state).
- A written policy (in the orchestrate / epic-orchestrate skills and a rule) stating which directive classes subagents honor (e.g. scheduling, merge timing in autonomous mode, granting one extra planner revision, scope narrowing, accepting a recorded non-blocking deviation) and which they must refuse regardless (bypassing hooks, weakening gates, force pushes, tag pushes/publishing, editing policy files, permission or settings changes, deleting evidence).
- Subagents record each honored or refused directive in the checkpoint with the reason.
- A validator or hook check that a directive referenced in the checkpoint matches the recorded block (no invented directives).

## Acceptance Criteria (early draft)

- [ ] Directive block schema and checkpoint field defined and validated.
- [ ] Honor/refuse policy documented in orchestrate, epic-orchestrate, and the relevant agent definitions (all mirrors and bundle copies).
- [ ] A relayed directive in an allowed class is honored and recorded; a directive in a refused class is refused and recorded.
- [ ] No hook or gate is weakened; refused classes are enforced by existing hooks regardless of directives.
- [ ] Regression tests for schema validation and the honor/refuse classification.

## Constraints & Risks

- Must not create a path for prompt injection or self-authored "owner" directives: directives originate only from the coordinator session's owner turns and are recorded before relay.
- No new Python; hooks and libraries in PowerShell or bash.
- Must not weaken any gate's intent.

## Test Conditions to Consider

- [ ] Unit coverage areas: directive schema validation, classification of allowed vs refused classes, checkpoint recording.
- [ ] Integration scenarios: coordinator relays an allowed directive (extra planner revision) and a refused one (bypass a hook).
- [ ] CLI/API examples: validator run on a checkpoint with and without a matching directive block.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/owner-directive-relay/` folder from the template

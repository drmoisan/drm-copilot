# Owner directives must reach every executing agent (Issue #1157)

- Date captured: 2026-11-09
- Author: Dan Moisan (owner request), captured by Claude
- Status: Promoted -> docs/features/active/Owner_directives_must_reach_every_executing_agent/ (Issue #1157)

- Issue: #1157
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1157
- Last Updated: 2026-11-09
## Problem / Why

- Directives recorded at the epic level did not reach the agents running commands.
- The epic orchestrator ended its turn after launching children, so the directives it was asked to relay never reached them.
- Messages to a feature orchestrator queue until its next step, but the orchestrator is blocked while its executor subagent runs. The executor kept retrying non-compliant commands (killed test runs, renamed wrapper scripts) for many minutes after the owner's instruction.

## Proposed Behavior

- Directives in a parent checkpoint whose scope covers a child are passed down automatically at every delegation (preparation, execution, remediation, review). Each is recorded in the child checkpoint before the delegation prompt is built, and the fenced directive block is included verbatim.
- Atomic executors and other workers receive the block in their delegation prompt and record whether they followed or refused each directive; the record goes in the parent orchestrator's checkpoint, through the orchestrator on return.
- Course-correction path that reaches a running executor: the coordinator or epic orchestrator writes new directives to the item checkpoint; a PreToolUse hook for executor and worker agents reads the item checkpoint's directives and injects any not yet acknowledged into the agent's context on its next tool call; the agent must record a decision before proceeding. Refused classes stay refused.
- The epic orchestrator does not end its turn while children are running and directives are pending relay; alternatively pass-down happens at the hook level so it does not depend on the orchestrator being active.

## Acceptance Criteria (early draft)

- [ ] Parent-checkpoint directives whose scope covers a child are recorded in the child checkpoint before every delegation prompt is built (preparation, execution, remediation, review), and the fenced block is included verbatim.
- [ ] Workers record honored/refused per directive, and the orchestrator writes that record to its checkpoint on return.
- [ ] A PreToolUse hook for executor and worker agents injects unacknowledged item-checkpoint directives on the next tool call and requires a recorded decision before proceeding; refused classes stay refused.
- [ ] Relay does not depend on the epic orchestrator remaining active (hook-level pass-down or a no-end-turn rule while relay is pending).
- [ ] Validator: a record without a matching directive, or an honored record for a refused class, still blocks; a new check verifies every in-scope running child has the parent's unexpired directives.
- [ ] owner-directives, orchestrate, epic-orchestrate, and executor/worker agent docs updated; unit tests for the pure scope/selection/injection logic.

## General Constraints (all harness-learnings workstreams)

- Keep pure logic (calculations, classification, scheduling, parsing) in host-neutral modules with unit tests; keep I/O (git, gh, filesystem, process inspection) in thin adapters.
- Inject clocks, randomness, filesystem and process seams; no temporary files and no wall-clock waits in tests.
- Every new configuration knob has a safe default that preserves today's behavior unless this entry states otherwise.
- Update the skill and agent documentation that describes each changed behavior, and keep the push-down payload consistent with it.
- New pushed-down code (skills, hooks, libs) is PowerShell or bash; TypeScript only for MCP or extension commands; no new Python.
- Existing gate decisions are unchanged except where this entry explicitly changes them, shown by parity or regression tests.
- New configuration keys are documented, validated, and default to today's behavior.
- The push-down payload carries every changed skill, agent, hook, and script.
- Delivered as its own issue and PR with unit tests for the pure logic, updated skill and agent documentation, and fully green CI.

## Source

Owner request of 2026-11-09: observations from a multi-feature epic with five features running in parallel on one shared development machine.

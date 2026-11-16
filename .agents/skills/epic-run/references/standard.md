# Gold Standard: epic-run

## Objective

Execute a previously planned epic by replaying the committed epic-kickoff artifact through the epic-orchestrator agent. Use after /epic-plan has prepared the epic (issues, folders, research, specs, atomic plans, preflight clearance) and the user is ready to execute end-to-end. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Procedure: Resolve a bare slug to `docs/features/epics/<epic-slug>/`;.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Procedure, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-1) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

# Gold Standard: orchestrate

## Objective

Route a repository request through the deterministic orchestration workflow for feature, bug, research, planning, execution, and review handoffs. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Read `AGENTS.md` for repository tone policy and architectural context.
- **OB-2** Checkpoint Handling: Read `artifacts/orchestration/orchestrator-state.json` to check for existing state.
- **OB-3** Prepared-State Portable Handoff Intake: Treat a portable prepared-state checkpoint as a resume request, not as a new orchestration intake.
- **OB-4** Preparation Mode: A parent prompt containing the literal marker `Preparation mode: true` selects only `route_id: preparation`.
- **OB-5** Autonomous-Execution Mandate: The orchestrator must achieve all actions agentically with no unrecorded manual dependency.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Checkpoint Handling, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Prepared-State Portable Handoff Intake, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Preparation Mode, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Autonomous-Execution Mandate, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

# Gold Standard: discovery-workflow

## Objective

Dispatch an explicit canonical discovery workflow without adding authority. Use when invoking the legacy discovery umbrella with a selected skill_id. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: Forward all other supplied canonical inputs to the selected target.
- **OB-2** Dispatch: Select exactly one canonical workflow using `skill_id`.
- **OB-3** Stop and result: Return the selected canonical workflow's explicit result and references without changing failed, blocked, pending or incremental outcomes into completion.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Dispatch, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Stop and result, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

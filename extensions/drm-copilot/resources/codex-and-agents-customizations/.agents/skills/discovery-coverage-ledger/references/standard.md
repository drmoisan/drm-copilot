# Gold Standard: discovery-coverage-ledger

## Objective

Dispatch explicit inventory, extraction or review without mixing coverage ownership. Use when invoking the existing coverage-ledger alias with action=inventory, extract or review. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: Forward all other supplied canonical inputs to the selected target.
- **OB-2** Dispatch: `action=inventory|extract|review` selects the corresponding canonical workflow.
- **OB-3** Stop and result: Return the selected canonical workflow's explicit result and references without changing failed, blocked, pending or incremental outcomes into completion.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Dispatch, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Stop and result, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

# Gold Standard: execute-hard-lock

## Objective

Produce the outcome that the execute-hard-lock skill exists for, with the same observable result in every tool that runs it. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: `plan-path` — absolute or repo-relative path to the plan-of-record markdown file.
- **OB-2** Invocation Flow: `target` (required): the plan-of-record path (`${plan-path}`).
- **OB-3** Abort Conditions: Stop immediately and report `BLOCKED: execute-hard-lock <cause>` in any of these cases.
- **OB-4** Equivalent Entry Points (Reference): The three entry points below all produce the same resolved hard-lock prompt for a given plan path.
- **OB-5** Delegation Contract: `policy-compliance-order` — mandatory policy reading order.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Invocation Flow, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Abort Conditions, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Equivalent Entry Points (Reference), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Delegation Contract, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

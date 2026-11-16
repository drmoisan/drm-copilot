# Gold Standard: policy-audit-template-usage

## Objective

Policy audit template usage and output requirements. Use when creating timestamped policy-audit artifacts from the repository templates. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Template Source: The resolved MCP asset is authoritative even when a matching repo file also exists.
- **OB-2** Required Steps: `## Appendix A: Test Inventory`.
- **OB-3** Invalid Outputs: A freeform summary note is invalid.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Template Source, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Required Steps, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Invalid Outputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

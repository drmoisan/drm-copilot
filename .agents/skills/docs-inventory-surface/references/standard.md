# Gold Standard: docs-inventory-surface

## Objective

Inventory the documented surface of a repository (commands, options, routes, configuration keys, public symbols) through the docs MCP tools. Use as the first step of docs-architect work. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Without that library every root step in this skill is unavailable;.
- **OB-2** Steps: Before this skill runs, the root persists the snapshot through the root inventory step of `documentation-workflow`, so the snapshot path exists on a first run.
- **OB-3** Result: Report the snapshot path, the element counts by kind and the element ids that changed.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Steps, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Result, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

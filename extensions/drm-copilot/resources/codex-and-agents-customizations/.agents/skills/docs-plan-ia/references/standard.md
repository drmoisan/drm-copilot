# Gold Standard: docs-plan-ia

## Objective

Plan the documentation information architecture: pages, Diataxis modes, audiences and owners. Use after the surface inventory, before any page is written. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Without that library every root step in this skill is unavailable;.
- **OB-2** Steps: Call `run_docs_coverage` with `workspace_root` and `profile` to list the elements without a documented, excluded or deferred disposition.
- **OB-3** Result: Write a `## Information Architecture` section into the report with one line per planned page: its repository-relative path, Diataxis mode, audience, owner and the element ids it covers.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Steps, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Result, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

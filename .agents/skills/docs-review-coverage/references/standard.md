# Gold Standard: docs-review-coverage

## Objective

Review documentation coverage, page accuracy and the surface delta of a branch, read-only. Use before docs-complete validation and during feature review of a change that alters the documented surface. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Root steps run the docs command entry point of the docs helper library under PowerShell 7.4 or later; without that library every root step in this skill is unavailable, and the docs MCP tools stay available.
- **OB-2** Steps: For a branch change, the root session first runs the surface delta against the base branch and records it.
- **OB-3** Result: Report the coverage findings, the page findings and each `accurate` judgment so that `docs-reconciler` can record it with `set-dimension`.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Steps, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Result, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

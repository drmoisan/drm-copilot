# Gold Standard: docs-reconcile-behavior

## Objective

Record coverage dispositions, evidence pins and parity dimensions through update_docs_ledger, previewing each change as a dry run first. Use when coverage findings or review judgments must be written to the estate artifacts. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Without that library every root step in this skill is unavailable;.
- **OB-2** Steps: Call `run_docs_coverage` with `workspace_root` and `profile` to list the uncovered elements.
- **OB-3** Result: Report the number of applied operations, the exit code of the last `update_docs_ledger` call and the element ids changed.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Steps, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Result, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

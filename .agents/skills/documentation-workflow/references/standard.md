# Gold Standard: documentation-workflow

## Objective

Run the documentation estate workflow from initialization to docs-complete validation by dispatching the seven docs skills in order. Use when a repository documentation estate must be created, extended or brought to docs-complete. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Without that library every root step in this skill is unavailable;.
- **OB-2** Dispatch Order: Run the skills in this order.
- **OB-3** Rules: Pass each role its prepared inputs: `workspace_root`, the profile path and the outputs of the earlier steps.
- **OB-4** Commit, Receipt and Pull Request: The root session runs this stage itself after the dispatch order.
- **OB-5** Refresh After Rebase or Source Change: After a rebase, or after a source path under `surface_selection.source_roots` changes, the receipt revision rule denies the existing receipt.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Dispatch Order, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Rules, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Commit, Receipt and Pull Request, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Refresh After Rebase or Source Change, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

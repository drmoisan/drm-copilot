# Gold Standard: docs-author-page

## Objective

Write or revise one documentation page from the template for its Diataxis mode, fill its front matter and link it from its root entry page. Use for every page docs-author writes. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Root steps run the docs command entry point of the docs helper library under PowerShell 7.4 or later; without that library every root step in this skill is unavailable, and the docs MCP tools stay available.
- **OB-2** Templates: The templates live in the `templates/` folder of this skill, outside every documentation root, so `run_docs_check` does not scan them.
- **OB-3** Steps: Copy the template for the page's mode to the planned page path.
- **OB-4** Result: Report the pages written and the exit code of the last `run_docs_check` call.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Templates, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Steps, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Result, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

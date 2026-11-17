# Gold Standard: docs-init

## Objective

Create the documentation estate profile for a repository and validate it. Use from the root session before any other docs skill runs. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Root steps run the docs command entry point of the docs helper library under PowerShell 7.4 or later; without that library every root step in this skill is unavailable, and the docs MCP tools stay available.
- **OB-2** Steps: Preview the initialization as a dry run.
- **OB-3** Linter Configuration: `init -Write` writes the Vale configuration to `docs/documentation-estate/.vale.ini`, the Vale styles and vocabulary under `docs/documentation-estate/.vale/styles/`, and the markdownlint configuration to `docs/documentation-estate/.markdownlint.json`.
- **OB-4** Result: Report the profile path, the CI workflow `.github/workflows/_docs-quality.yml` that init adds (its `ci-workflow` line), the exit code of each step and, on failure, the findings the command returned.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Steps, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Linter Configuration, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Result, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

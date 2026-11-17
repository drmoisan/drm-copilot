# Gold Standard: docs-validate

## Objective

Validate the documentation estate artifacts for one mode and the head revision, read-only; receipt persistence is a root or CI step. Use to establish docs-complete before an integration merge. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Prerequisites: Root steps run the docs command entry point of the docs helper library under PowerShell 7.4 or later; without that library every root step in this skill is unavailable, and the docs MCP tools stay available.
- **OB-2** Steps: Call `validate_docs_artifacts` with `workspace_root`, `profile`, `mode` set to `docs-complete` and `revision` set to the head revision (40 or 64 lowercase hexadecimal characters).
- **OB-3** Result: Report the validated mode, the revision, the exit code of `validate_docs_artifacts` and the receipt id supplied by the root, or `none`.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Prerequisites, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Steps, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Result, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-1, OB-2, OB-3) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

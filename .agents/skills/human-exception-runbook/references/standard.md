# Gold Standard: human-exception-runbook

## Objective

Contract for runbooks that document permitted human exceptions recorded in orchestrator state. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Path: The `runbook_path` recorded in `orchestrator-state.json` (`human_interaction.requirements[].runbook_path`) is the path relative to the repo root.
- **OB-2** Required Sections: The event or state that triggers the runbook (for example, "the orchestrator recorded an `exception` for Global-Administrator admin consent").
- **OB-3** Sourcing Rule (MCP-first / web-second): Prefer an MCP documentation source (for example a Microsoft Learn MCP query) as the primary source.
- **OB-4** Tool Command Version Rule: Every tool command in a runbook is either checked against the version pinned in the repository's lockfile or marked as not verified, with the pinned version stated.
- **OB-5** Conformance: A runbook is contract-conformant when it lives at `<FEATURE>/runbooks/<name>.runbook.md`, contains all five required sections, records at least one source URL and a capture date in its Source and Citation section, sources third-party UI steps MCP-first and web-second, and carries `Version check:` marker lines in every counted shell block.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Path, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Required Sections, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Sourcing Rule (MCP-first / web-second), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Tool Command Version Rule, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Conformance, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

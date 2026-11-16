# Gold Standard: powershell-change-budget-router

## Objective

Produce the outcome that the powershell-change-budget-router skill exists for, with the same observable result in every tool that runs it. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Routing Rules: `1-2` production files (+ corresponding tests) → small path (`powershell-typed-engineer` direct mode).
- **OB-2** Orchestrated Small-Path Requirements: If the MCP server or required tool is unavailable, stop before promotion,.
- **OB-3** Direct-Mode Rejection Rule: Stop before implementation.
- **OB-4** Documentation Expectations: Estimated production file count,.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Routing Rules, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Orchestrated Small-Path Requirements, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Direct-Mode Rejection Rule, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Documentation Expectations, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

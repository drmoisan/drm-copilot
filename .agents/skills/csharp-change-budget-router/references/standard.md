# Gold Standard: csharp-change-budget-router

## Objective

Produce the outcome that the csharp-change-budget-router skill exists for, with the same observable result in every tool that runs it. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Routing Rules: `1-3` production files (+ corresponding tests) → small path (`csharp-typed-engineer` direct mode).
- **OB-2** Orchestrated Small-Path Requirements: If the MCP server or required tool is unavailable, stop before promotion,.
- **OB-3** Direct-Mode Rejection Rule: Stop before implementation.
- **OB-4** Invocation Mode: Direct mode (default): no handoff directive present.
- **OB-5** Per-Batch Cap: In all modes, per-batch budget remains: at most 3 production files and 3 test files unless an explicit override is approved by the user.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Routing Rules, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Orchestrated Small-Path Requirements, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Direct-Mode Rejection Rule, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Invocation Mode, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Per-Batch Cap, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

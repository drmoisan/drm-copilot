# Gold Standard: feature-promotion-lifecycle

## Objective

Deterministic promotion workflow from potential feature/bug entry to issue, branch, active feature folder, and downstream spec/research handoffs. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** MCP Tool Availability Preflight: If the required MCP tools are unavailable, stop before potential-entry creation, issue promotion, or active-folder creation begins.
- **OB-2** Agent-Session Promotion Execution Rule: Potential-entry creation, issue promotion, and active feature folder creation run only through the repository automation promotion tools, which are the sole authoritative execution path for them in agent sessions.
- **OB-3** Canonical Variables: `${promotion-type}`: `feature` or `bug`.
- **OB-4** Required Outputs for Downstream Handoffs: `${feature-folder}/issue.md`.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under MCP Tool Availability Preflight, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Agent-Session Promotion Execution Rule, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Canonical Variables, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Required Outputs for Downstream Handoffs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

# Gold Standard: python-change-budget-router

## Objective

Budget-first routing contract for Python work. Estimate production-file scope, choose small vs large path, and route direct-mode work of more than 3 production files to the orchestrated large path. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Routing Rules: Estimate rough change budget first based on likely production Python files touched.
- **OB-2** Direct-Mode Rejection Rule: Stop before editing the 4th production file.
- **OB-3** Orchestrated Small-Path Requirements: If the MCP server or required tool is unavailable, stop before promotion.
- **OB-4** Documentation Expectations: The response or logs record the estimated production file count, the chosen path (`small` or `large`), and a rationale summary of one to three bullets.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Routing Rules, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Direct-Mode Rejection Rule, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Orchestrated Small-Path Requirements, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Documentation Expectations, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

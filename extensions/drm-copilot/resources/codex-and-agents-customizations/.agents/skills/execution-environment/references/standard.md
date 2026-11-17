# Gold Standard: execution-environment

## Objective

Execution-environment brief for research, planning, preflight, execution, and orchestration. Use before planning or delegating work so tool routes, command-text restrictions, the batch budget, hook context, CI shape, contract tests, evidence rules, coverage and file-size gates, test runtime, and test-isolation checks are known and are not restated in plans. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Purpose and Maintenance: This brief states the environment facts that every researcher, planner, preflight executor, executor, and orchestrator needs before work starts.
- **OB-2** Development Toolchain Baseline: The host manifest, both devcontainer Dockerfiles, and development CI select Python 3.13.18, Node.js 26.13.0/npm 11.20.0, PowerShell 7.6.9, and Poetry 2.5.1.
- **OB-3** Tool Routes by Agent: `atomic-executor` has no PowerShell tool.
- **OB-4** Command-Text Restrictions: Command text is restricted by two separate mechanisms with different causes and fixes, the runtime worktree isolation guard, which is not a repository hook and refuses command text it cannot show stays inside an agent-isolated worktree, and the repository command hooks, which deny destructive patterns, a directory change followed later in the same command by a file-reading command, a direct test runner in place of the test-execution launcher, and merge text that cannot be bound to one pull request when a checkpoint records concurrent review, so the preferred forms name the target directory on the tool instead of changing into it, issue a merge as one pull request number in its own command, and place a multi-line inline Python program in a file because it otherwise exits without running.
- **OB-5** PowerShell Route and PoshQC MCP Limits: PoshQC MCP results carry no output.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Purpose and Maintenance, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Development Toolchain Baseline, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Tool Routes by Agent, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Command-Text Restrictions, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under PowerShell Route and PoshQC MCP Limits, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.

# Change Plan

## Objective

Add a stdio MCP bridge in `extensions/drm-copilot` that exposes semantic repo-automation tools backed by the same bundled workflow execution core used by the existing VS Code commands.

## Planned Work

- [x] Extract a shared repo-automation service that owns bundled workflow execution.
- [x] Refactor VS Code command handlers to validate inputs, gather UI selections when needed, and delegate to the shared service.
- [x] Add a stdio MCP server entrypoint and semantic tool registry for the bundled workflows.
- [x] Extend argument validation for non-interactive PR-context collection and MCP tool inputs.
- [x] Add Jest coverage for shared-service reuse, MCP dispatch, validation failures, and non-interactive PR-context execution.
- [x] Update extension and root documentation with MCP configuration and usage guidance.
- [x] Run the extension quality loop and confirm the final pass is clean.

## Follow-up: Root Jest Invocation

- [x] Replace the root `jest` CLI script entries with a Node-resolved wrapper so `npm run test:unit` works on Windows worktrees where the bare `jest` command is not found.
- [x] Run the root quality loop and confirm the final pass is clean.

## Follow-up: VS Code PowerShell 7 Test Host

- [x] Pin the VS Code PowerShell extension session to PowerShell 7 for this workspace so Test Explorer does not fall back to Windows PowerShell 5.1.
- [x] Document the workspace PowerShell-host expectation and the local override needed if `pwsh.exe` is installed outside the default Windows path.

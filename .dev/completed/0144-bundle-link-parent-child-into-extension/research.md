# Task Research Notes: bundle-link-parent-child-into-extension

## Request Summary

Bundle the workflow currently invoked by the VS Code task `Dev: 4 Link GitHub Parent/Child Issues` so it is available through the published extension automation surface. Expose it through:

1. An extension command with the same interactive inputs as the task:
   - child issue number
   - parent tracking issue number
2. A semantic MCP tool with explicit predefined inputs for the same workflow.

## Relevant Current Behavior

- `.vscode/tasks.json`
  - The task `Dev: 4 Link GitHub Parent/Child Issues` calls `pwsh -File ${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber <input> -ParentIssueNumber <input>`.
- `scripts/dev-tools/link-parent-child.ps1`
  - Contains the current workflow and existing CLI contract that should remain the source behavior unless a minimal additive bundling seam is required.
- `tests/scripts/dev-tools/link-parent-child.Tests.ps1`
  - Already exercises the root script behavior and provides the most direct PowerShell regression home for any additive contract seams.

## Extension Seams To Mirror

- `extensions/drm-copilot/src/extension.ts`
  - Registers workflow commands such as `drmCopilotExtension.newPotentialEntry`, `drmCopilotExtension.potentialToIssue`, and `drmCopilotExtension.newActiveFeatureFolder`.
  - The current command-registration style supports both interactive prompting and direct flag-based invocation.
- `extensions/drm-copilot/src/workflow-command-arguments.ts`
  - Defines CLI-style direct invocation parsers and validators for workflow commands.
  - A new `link-parent-child` command should follow this pattern for:
    - interactive mode when no args are supplied
    - direct mode when explicit flags are supplied
- `extensions/drm-copilot/src/repo-automation-service.ts`
  - Centralizes bundled script execution through `executeBundledScriptFromExtensionRoot`.
  - Existing patterns show PowerShell-backed workflows can be launched with a bundled template path and deterministic argv-based execution.
- `extensions/drm-copilot/resources/templates/`
  - Contains bundled entrypoints for extension-published automation workflows.
  - The parent/child-link workflow should be surfaced here rather than through a workspace-relative script path.

## MCP Surface Seams

- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
  - Normalizes MCP input objects into typed runtime inputs.
- `extensions/drm-copilot/src/mcp-tools.ts`
  - Declares semantic MCP tools and dispatches them to the repo automation service.
- `extensions/drm-copilot/src/mcp-server.ts`
  - Hosts the published server surface consumed by Codex or other MCP clients.

## Existing Test Surfaces Relevant To The Feature

- `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
  - Covers command registration, interactive prompting, direct invocation parsing, and subprocess argv expectations for existing workflow commands.
- `extensions/drm-copilot/test/repo-automation-service.test.ts`
  - Covers bundled path selection, runtime kind selection, and command argv propagation for repo automation service methods.
- `extensions/drm-copilot/test/workflow-command-arguments.test.ts`
  - Covers direct invocation parsing and validation for workflow commands.
- `extensions/drm-copilot/test/mcp-tool-inputs.test.ts`
  - Covers MCP input normalization.
- `extensions/drm-copilot/test/mcp-server.test.ts`
  - Covers MCP dispatch from server surface to service methods.
- `extensions/drm-copilot/test/extension.integration.test.ts`
  - Covers extension command execution against bundled assets in realistic workspace scenarios.

## Likely Implementation Shape

1. Add a bundled PowerShell wrapper or mirrored script under `extensions/drm-copilot/resources/templates/`.
2. Add a new repo automation service method, likely `linkParentChild`, that runs the bundled script with:
   - `-ChildIssueNumber`
   - `-ParentIssueNumber`
3. Add a new extension command that:
   - prompts for child issue number and parent tracking issue number in interactive mode
   - accepts explicit direct invocation flags in non-interactive mode
4. Add a new MCP tool with explicit numeric-string inputs for the same workflow.
5. Add or update targeted tests across the existing TypeScript and PowerShell suites.

## Constraints To Preserve

- Preserve the root script behavior and CLI parameter names unless a minimal additive seam is required for bundling.
- Preserve task-equivalent interactive prompts for:
  - child issue number
  - parent issue number
- Keep lifecycle automation routed through the extension’s shared repo automation service rather than introducing a one-off subprocess path in the command handler or MCP layer.

## Workflow Note

The large-path requirements package is complete and the canonical plan path is known. The next required workflow step is delegated planning at `plan.2026-04-12T15-09.md`. This host does not expose `spawn_agent`, so orchestration is expected to block at the delegated planning boundary unless the host surface changes.

Timestamp: 2026-04-12T15:29:00-04:00
Objective:
- Bundle the existing parent/child issue-link PowerShell workflow into the published extension automation surface.
- Add a VS Code command with task-equivalent prompts for child and parent issue numbers.
- Add a semantic MCP tool with explicit `child_issue_number` and `parent_issue_number` inputs.

Constraints Preserved:
- Keep the root script behavior intact.
- Preserve the `-ChildIssueNumber` and `-ParentIssueNumber` parameter names.
- Keep the change additive and avoid removing the legacy task-backed workflow.

Extension Surface:
- `drmCopilotExtension.linkParentChild`
- bundled PowerShell asset under `extensions/drm-copilot/resources/templates/link-parent-child.ps1`
- repo automation service method `linkParentChild`

MCP Surface:
- semantic tool `link_parent_child`
- normalized input fields `child_issue_number` and `parent_issue_number`

Files In Scope:
- `extensions/drm-copilot/src/extension-command-helpers.ts`
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
- `extensions/drm-copilot/src/mcp-tools.ts`
- `extensions/drm-copilot/src/repo-automation-service.ts`
- `extensions/drm-copilot/src/workflow-command-arguments.ts`
- `extensions/drm-copilot/resources/templates/link-parent-child.ps1`
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/README.md`
- targeted Jest suites under `extensions/drm-copilot/test/`

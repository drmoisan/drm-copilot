Timestamp: 2026-04-12T15:25:50-04:00
Command: rg -n "Dev: 4 Link GitHub Parent/Child Issues|drmCopilotExtension\.linkParentChild|link_parent_child|link-parent-child\.ps1|ChildIssueNumber|ParentIssueNumber" .vscode/tasks.json extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/resources scripts tests -S
EXIT_CODE: 0
Output Summary:
- The legacy task in `.vscode/tasks.json` still points at `${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1` and supplies `-ChildIssueNumber` plus `-ParentIssueNumber`.
- The extension source already contains the proposed command surface `drmCopilotExtension.linkParentChild`.
- The repo automation service already contains the semantic workflow key `link_parent_child` and targets `resources/templates/link-parent-child.ps1`.
- The MCP tool metadata and dispatch surface already include `link_parent_child`.
- The bundled script currently exists at `extensions/drm-copilot/resources/templates/link-parent-child.ps1`.
- Targeted TypeScript tests already exist in `workflow-command-arguments.test.ts`, `repo-automation-service.test.ts`, `extension.workflow-commands.test.ts`, `extension.integration.test.ts`, `mcp-tool-inputs.test.ts`, and `mcp-server.test.ts`.
- The likely changed production files are `extensions/drm-copilot/src/repo-automation-service.ts`, `extensions/drm-copilot/src/workflow-command-arguments.ts`, `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tools.ts`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/README.md`, and `extensions/drm-copilot/resources/templates/link-parent-child.ps1`.
- The likely changed test files are `extensions/drm-copilot/test/repo-automation-service.test.ts`, `extensions/drm-copilot/test/workflow-command-arguments.test.ts`, `extensions/drm-copilot/test/extension.workflow-commands.test.ts`, `extensions/drm-copilot/test/extension.integration.test.ts`, `extensions/drm-copilot/test/mcp-tool-inputs.test.ts`, `extensions/drm-copilot/test/mcp-server.test.ts`, `extensions/drm-copilot/test/extension.test.ts`, and `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.

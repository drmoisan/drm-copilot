# bundle-link-parent-child-into-extension (Issue #144)

- Date captured: 2026-04-12
- Author: Dan Moisan
- Status: Review Ready -> docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/ (Issue #144)

- Issue: #144
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/144
- Last Updated: 2026-04-12T15-29
- Work Mode: full-feature

## Problem / Why

The repository includes a working PowerShell script for linking a child GitHub issue to a parent tracking issue, but the current developer entrypoint depends on the workspace-local path from `.vscode/tasks.json`. That keeps the workflow outside the published extension automation surface and prevents the MCP bridge from exposing the same semantic operation with explicit inputs. The result is inconsistent access: the task works for a checked-out repo, but extension-hosted automation and MCP consumers cannot invoke the same workflow through the bundled runtime surface.

## Proposed Behavior

Bundle the existing `link-parent-child.ps1` workflow in the extension in the same manner as the other published automation scripts. Add an extension command that prompts for the same two inputs as the current task, then runs the bundled workflow through the repo automation service. Expose the same workflow through the published MCP server with predefined explicit inputs for child and parent issue numbers.

## Scope Notes

- Add a bundled extension-side script or wrapper for the parent/child-link workflow so the extension no longer depends on `${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1`.
- Add a VS Code command contribution and runtime handler that support both interactive prompting and direct argument invocation.
- Add a semantic MCP tool with explicit `child_issue_number` and `parent_issue_number` inputs.
- Keep the existing root PowerShell script behavior intact unless a minimal additive seam is required for bundling parity.

## Acceptance Criteria (early draft)

- [x] The published extension contributes a `link-parent-child` command that prompts for child issue number and parent tracking issue number, then executes the bundled workflow rather than the workspace script path.
- [x] The repo automation service runs a bundled copy or wrapper for the parent/child-link workflow and preserves the existing script behavior and CLI contract except for any minimal additive seams required for bundling.
- [x] The MCP bridge exposes a semantic `link-parent-child` tool with explicit child and parent issue inputs and dispatches the request through the same bundled automation surface.
- [x] Tests cover command registration, interactive prompting, direct invocation parsing, repo automation service execution, MCP input normalization, MCP dispatch, and bundled-script expectations.

## Constraints & Risks

- Preserve the current interactive input contract: child issue number and parent tracking issue number.
- Preserve the existing script behavior and CLI parameter names unless a minimal additive bundling seam is required.
- Keep the implementation aligned with existing extension bundling patterns in `repo-automation-service.ts`, `workflow-command-arguments.ts`, and the MCP server surface.
- The change spans TypeScript extension code, PowerShell script bundling, command registration, and multiple test suites, so it exceeds the small-path budget.

## Test Conditions to Consider

- [x] Unit coverage for command contribution, argument parsing, repo automation execution, MCP input parsing, and MCP server dispatch
- [x] Integration verification that the extension command runs the bundled workflow with prompted values
- [x] Bundled runtime expectations proving the extension path no longer depends on `${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1`

## Likely Files In Scope

- Production:
  - `scripts/dev-tools/link-parent-child.ps1`
  - `extensions/drm-copilot/resources/templates/` new bundled wrapper or mirrored script
  - `extensions/drm-copilot/src/extension.ts`
  - `extensions/drm-copilot/src/repo-automation-service.ts`
  - `extensions/drm-copilot/src/workflow-command-arguments.ts`
  - `extensions/drm-copilot/src/mcp-tool-inputs.ts`
  - `extensions/drm-copilot/src/mcp-tools.ts`
  - `extensions/drm-copilot/src/mcp-server.ts`
  - `extensions/drm-copilot/package.json`
- Tests:
  - `tests/scripts/dev-tools/link-parent-child.Tests.ps1`
  - `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
  - `extensions/drm-copilot/test/extension.integration.test.ts`
  - `extensions/drm-copilot/test/repo-automation-service.test.ts`
  - `extensions/drm-copilot/test/mcp-tool-inputs.test.ts`
  - `extensions/drm-copilot/test/mcp-server.test.ts`
  - `extensions/drm-copilot/test/workflow-command-arguments.test.ts`

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/` folder from the template
- [x] Finalize `spec.md`, `user-story.md`, and `research.md`
- [x] Delegate canonical planning at `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/plan.2026-04-12T15-09.md`

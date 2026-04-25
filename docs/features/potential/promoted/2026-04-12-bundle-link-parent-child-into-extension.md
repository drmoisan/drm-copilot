# bundle-link-parent-child-into-extension (Issue #144)

- Date captured: 2026-04-12
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bundle-link-parent-child-into-extension/ (Issue #144)

- Issue: #144
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/144
- Last Updated: 2026-04-12
## Problem / Why

The repository includes a working PowerShell script for linking a child GitHub issue to a parent tracking issue, but the current developer entrypoint depends on the workspace-local path from `.vscode/tasks.json`. That keeps the workflow outside the published extension automation surface and prevents the MCP bridge from exposing the same semantic operation with explicit inputs. The result is inconsistent access: the task works for a checked-out repo, but extension-hosted automation and MCP consumers cannot invoke the same workflow through the bundled runtime surface.

## Proposed Behavior

Bundle the existing `link-parent-child.ps1` workflow in the extension in the same manner as the other published automation scripts. Add an extension command that prompts for the same two inputs as the current task, then runs the bundled workflow through the repo automation service. Expose the same workflow through the published MCP server with predefined explicit inputs for child and parent issue numbers.

## Acceptance Criteria (early draft)

- [ ] The published extension contributes a `link-parent-child` command that prompts for child issue number and parent tracking issue number, then executes the bundled workflow rather than the workspace script path.
- [ ] The repo automation service runs a bundled copy or wrapper for the parent/child-link workflow and preserves the existing script behavior and CLI contract except for any minimal additive seams required for bundling.
- [ ] The MCP bridge exposes a semantic `link-parent-child` tool with explicit child and parent issue inputs and dispatches the request through the same bundled automation surface.
- [ ] Tests cover command registration, interactive prompting, direct invocation parsing, repo automation service execution, MCP input normalization, MCP dispatch, and bundled-script expectations.

## Constraints & Risks

- Preserve the current interactive input contract: child issue number and parent tracking issue number.
- Preserve the existing script behavior and CLI parameter names unless a minimal additive bundling seam is required.
- Keep the implementation aligned with existing extension bundling patterns in `repo-automation-service.ts`, `workflow-command-arguments.ts`, and the MCP server surface.
- The change spans TypeScript extension code, PowerShell script bundling, command registration, and multiple test suites, so it exceeds the small-path budget.

## Test Conditions to Consider

- [ ] Unit coverage for command contribution, argument parsing, repo automation execution, MCP input parsing, and MCP server dispatch
- [ ] Integration verification that the extension command runs the bundled workflow with prompted values
- [ ] Bundled runtime expectations proving the extension path no longer depends on `${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1`

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/bundle-link-parent-child-into-extension/` folder from the template

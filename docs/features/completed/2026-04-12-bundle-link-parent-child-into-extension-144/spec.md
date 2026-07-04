# 2026-04-12-bundle-link-parent-child-into-extension — Spec

- **Issue:** #144
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-12T15-29
- **Status:** Implemented
- **Version:** 0.2

## Overview

- Bundle the existing parent/child-link PowerShell workflow into the published extension automation surface.
- Provide two supported entrypoints:
  - a VS Code command with task-equivalent interactive prompts
  - an MCP tool with explicit semantic inputs
- Preserve the current script contract and repository behavior while removing the extension/runtime dependency on the workspace-local script path.

## Behavior

The extension contributes a new command dedicated to linking child and parent issues. In interactive mode, the command prompts the user for the child issue number and the parent tracking issue number using the same two inputs currently used by `.vscode/tasks.json`. In direct mode, the command accepts explicit flags so tests and automation can bypass prompts.

The command delegates execution to the shared repo automation service. The service launches a bundled PowerShell script or wrapper from the extension installation so the published runtime no longer depends on `${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1`.

The MCP server exposes the same workflow as a semantic tool with explicit `child_issue_number` and `parent_issue_number` fields. MCP dispatch normalizes those inputs, then routes them through the same repo automation service method used by the extension command.

## Inputs / Outputs

- Inputs:
  - extension command interactive prompts:
    - child issue number
    - parent issue number
  - extension direct invocation flags:
    - `-ChildIssueNumber`
    - `-ParentIssueNumber`
  - MCP tool fields:
    - `child_issue_number`
    - `parent_issue_number`
- Outputs:
  - the bundled script performs the existing GitHub mutation workflow
  - extension and MCP command layers should return a concise execution summary
  - artifact reporting is optional unless the bundled script already emits deterministic artifact paths
- Config keys and defaults:
  - no new configuration is required
- Versioning or backward-compatibility constraints:
  - preserve the root script CLI parameters `-ChildIssueNumber` and `-ParentIssueNumber`
  - keep existing task behavior intact until the extension command is available as the canonical path

## API / CLI Surface

- Extension command:
  - new command contribution under `drmCopilotExtension.*`
  - supports interactive invocation with no args
  - supports direct invocation with explicit child/parent inputs for tests and automation
- Repo automation service:
  - add a typed method that launches the bundled PowerShell workflow with argv-based execution
- MCP tool:
  - semantic tool name should be explicit about linking parent and child issues
  - accepts `child_issue_number` and `parent_issue_number`
  - dispatches to the repo automation service
- Contracts and validation rules:
  - both issue numbers must be required, non-empty, digit-only strings
  - interactive command prompts must preserve the same logical questions as the existing task
  - the extension runtime path must point to a bundled asset, not `${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1`

## Data & State

- Data flow:
  - user or caller provides child and parent issue numbers
  - command or MCP layer validates and normalizes inputs
  - repo automation service launches bundled script
  - bundled script performs GitHub issue mutation through the existing script behavior
- Invariants:
  - child and parent issue numbers remain explicit and not inferred
  - bundled and root workflow behavior remain aligned
- Caching or persistence details:
  - no new persistent application state is expected
- Migration or backfill requirements:
  - none

## Constraints & Risks

- Preserve the current interactive input contract: child issue number and parent tracking issue number.
- Preserve the existing script behavior and CLI parameter names unless a minimal additive bundling seam is required.
- Keep the implementation aligned with existing extension bundling patterns in `repo-automation-service.ts`, `workflow-command-arguments.ts`, and the MCP server surface.
- The change spans TypeScript extension code, PowerShell script bundling, command registration, and multiple test suites, so it exceeds the small-path budget.

## Implementation Strategy

- Implementation scope:
  - add a bundled extension-side workflow entrypoint for parent/child linking
  - add extension command registration and handler logic
  - add repo automation service support
  - add MCP input normalization, tool metadata, and server dispatch
  - add or update targeted tests across PowerShell and TypeScript suites
- New classes/functions/commands to add or update:
  - `extensions/drm-copilot/src/extension.ts`
  - `extensions/drm-copilot/src/repo-automation-service.ts`
  - `extensions/drm-copilot/src/workflow-command-arguments.ts`
  - `extensions/drm-copilot/src/mcp-tool-inputs.ts`
  - `extensions/drm-copilot/src/mcp-tools.ts`
  - `extensions/drm-copilot/src/mcp-server.ts`
  - `extensions/drm-copilot/package.json`
  - bundled script or wrapper under `extensions/drm-copilot/resources/templates/`
- Dependency changes:
  - none expected
- Logging/telemetry additions:
  - follow the existing extension output-channel summary style for workflow commands
- Rollout plan:
  - additive command and MCP surface only
  - no feature flag expected
  - keep root script available as the underlying source behavior and task reference during transition

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [x] Edge cases and error handling covered by tests
- [x] Docs updated (README, docs/features/active/... links)
- [x] Telemetry/logging added or updated (if applicable)
- [x] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Unit coverage for command contribution, argument parsing, repo automation execution, MCP input parsing, and MCP server dispatch
- [x] Integration verification that the extension command runs the bundled workflow with prompted values
- [x] Bundled runtime expectations proving the extension path no longer depends on `${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1`

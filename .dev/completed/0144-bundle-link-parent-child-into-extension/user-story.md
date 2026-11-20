# `2026-04-12-bundle-link-parent-child-into-extension` — User Story

- Issue: #144
- Owner: drmoisan
- Status: Implemented
- Last Updated: 2026-04-12T15-29

## Story Statement

- As a repository maintainer using the published extension automation surface, I want a bundled command for linking child and parent GitHub issues so that I can run the workflow without depending on the workspace-local script path.
- As a Codex or MCP client, I want a semantic parent/child-link tool with explicit inputs so that automation can invoke the workflow deterministically and without interactive task wiring.

## Problem / Why

The repository includes a working PowerShell script for linking a child GitHub issue to a parent tracking issue, but the current developer entrypoint depends on the workspace-local path from `.vscode/tasks.json`. That keeps the workflow outside the published extension automation surface and prevents the MCP bridge from exposing the same semantic operation with explicit inputs. The result is inconsistent access: the task works for a checked-out repo, but extension-hosted automation and MCP consumers cannot invoke the same workflow through the bundled runtime surface.


## Personas & Scenarios

- Persona: Repository maintainer working in VS Code
  - Works from the published extension command surface rather than memorizing individual repository script paths
  - Needs interactive prompts for the exact child and parent issue numbers
  - Expects the extension command to behave consistently with the existing task-backed workflow
- Persona: Automation client using the MCP bridge
  - Invokes semantic tools instead of VS Code tasks
  - Needs explicit machine-validated inputs and predictable dispatch through the extension runtime surface
  - Expects the MCP tool to execute the same workflow as the extension command
- Scenario: Link a child issue to a parent tracking issue from the extension
  - The maintainer triggers the extension command without direct arguments.
  - The extension prompts for the child issue number.
  - The extension prompts for the parent tracking issue number.
  - The command validates those values and routes execution through the repo automation service.
  - The bundled PowerShell workflow runs and applies the existing GitHub linking behavior.
  - The maintainer receives a concise success or failure summary from the extension output surface.
- Scenario: Link a child issue to a parent tracking issue from MCP
  - An automation client calls the semantic MCP tool with explicit child and parent issue numbers.
  - The server normalizes the input object.
  - The tool dispatches to the same repo automation service workflow used by the extension command.
  - The client receives a deterministic response without any interactive prompts.


## Acceptance Criteria

- [x] The published extension contributes a `link-parent-child` command that prompts for child issue number and parent tracking issue number, then executes the bundled workflow rather than the workspace script path.
- [x] The repo automation service runs a bundled copy or wrapper for the parent/child-link workflow and preserves the existing script behavior and CLI contract except for any minimal additive seams required for bundling.
- [x] The MCP bridge exposes a semantic `link-parent-child` tool with explicit child and parent issue inputs and dispatches the request through the same bundled automation surface.
- [x] Tests cover command registration, interactive prompting, direct invocation parsing, repo automation service execution, MCP input normalization, MCP dispatch, and bundled-script expectations.


## Non-Goals

- Changing the business logic of how parent and child GitHub issues are linked, beyond any minimal additive seams needed for bundling or validation
- Replacing or removing the root `scripts/dev-tools/link-parent-child.ps1` script
- Redesigning unrelated extension workflow commands or MCP tools

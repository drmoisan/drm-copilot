# legacy-discovery-mcp-vscode (Issue #370)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-mcp-vscode/ (Issue #370)
- Epic: legacy-discovery-and-parity (child feature #9011 placeholder)

- Issue: #370
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/370
- Last Updated: 2026-07-17
- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability whose functional features each ship a `dev.discovery.*`
Python CLI command (validators, init, analyzers, acceptance-scenario generation,
reports). The repository's CLI-before-MCP-before-VS-Code ordering requires that those
CLI commands also be exposed as TypeScript MCP tools in the `drm-copilot` MCP server and
as VS Code commands, so agents and interactive users can invoke discovery operations
through the same surfaces as the existing 21 repo-automation tools. Without this
exposure layer, the discovery commands are reachable only from the Python CLI.

## Proposed Behavior

Expose the existing `dev.discovery.*` Python CLI commands as MCP tools and VS Code
commands, in lockstep across the MCP server's tool-name union, tool-definitions
(JSON-Schema-shaped `inputSchema`, `additionalProperties: false`), dispatch switch, a
handler per tool, and the service call that shells out to the bundled Python script.
The exposure is a thin wrapper layer: it re-authors no `dev.discovery.*` CLI command
(those ship in the owning functional features). The layer stays domain-neutral: it
surfaces the generic discovery commands and contains no TaskMaster/TMW/Outlook/VSTO/
email/task-management-specific behavior.

## Acceptance Criteria (early draft)

- [ ] Each in-scope `dev.discovery.*` CLI command is exposed as an MCP tool with a name in the `REPO_AUTOMATION_TOOLS` union, a tool-definition with `additionalProperties: false`, a dispatch-switch case, a handler, and a service call that shells out to the bundled Python script.
- [ ] Each exposed command is also registered as a VS Code command.
- [ ] The exposure layer wraps the existing Python commands and re-authors none of them.
- [ ] The MCP tool surface stays domain-neutral (no domain-specific identifiers).
- [ ] TypeScript Jest tests mirrored under `extensions/drm-copilot/test/` plus MCP contract tests cover the new tools, meeting line >= 85% and branch >= 75% coverage.

## Constraints & Risks

- The MCP server is TypeScript-only; there is no Python MCP bridge. New tools shell out
  to bundled Python via the existing `executeBundledScriptFromExtensionRoot` path.
- The five MCP touch-points (tool-names, tool-definitions, dispatch switch, handler,
  service call) must change in lockstep or the contract tests fail.
- Several upstream `dev.discovery.*` commands may still be in preparation at
  implementation time; the wrapper must design against the planned command contracts
  (objective-source.md sections 8, 9, 12).
- Asset mirroring into `resources/` is the publishing feature's responsibility (#9012),
  not this feature's.

## Test Conditions to Consider

- [ ] Unit coverage: each handler, each service call, dispatch-switch routing per tool.
- [ ] Integration scenarios: MCP contract tests validating tool-definition schema shape.
- [ ] CLI/API examples: each exposed tool maps to its `dev.discovery.*` command invocation.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-mcp-vscode/` folder from the template

# docs-mcp-tools — Spec

- **Issue:** #1036
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-58
- **Status:** Draft
- **Version:** 0.1

## Overview

The documentation-estate-tooling epic (#1019) delivers its pushed-down logic as PowerShell behind
one entry script, `.claude/lib/docs/Invoke-DocsCommand.ps1`, with the subcommands `check` (#1021),
`inventory` (#1022), `coverage`, `update-ledger` and `validate` (#1023), and `generate-reference`
(#1024). Agents that work through the drm-copilot MCP server have no tool surface for these
subcommands. The documentation roles planned by a later child (900009) are restricted to MCP tools
and must not hold direct Write access to ledger or matrix artifacts, so they need typed MCP tools
that call the PowerShell entry and return its structured result.

Under the owner directive on implementation language (epic `## Owner Directive: Implementation
Language (2026-10-30, refined)`), TypeScript is permitted only for MCP tools and extension
commands, and the logic each tool exposes must remain reachable from a skill through the
PowerShell entry.


## Behavior

Add six TypeScript MCP tool wrappers in `extensions/drm-copilot/src/` (bundled into
`packages/mcp-server`): `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
`update_docs_ledger`, `generate_docs_reference` and `validate_docs_artifacts`.

- Each tool validates its input, maps it to the arguments of one subcommand, and invokes
  `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name> -Json ...` with
  the workspace root as working directory.
- Each tool parses the `-Json` envelope `{command, exit_code, findings, ok, result}` (schema
  `schemas/docs/v1/docs-command-envelope.schema.json`) and returns structured output including the
  exit code and findings; exit codes are 0 success, 1 findings, 2 usage or input error, 3 internal
  or I/O error.
- `update_docs_ledger` is the only mutating tool and routes through `-Command update-ledger`.
  `validate_docs_artifacts` never persists receipts.
- TypeScript holds only argument mapping and result parsing.

Planned files (create): `mcp-docs-tool-definitions.ts`, `mcp-handlers/docs-handlers.ts`,
`mcp-tool-inputs-docs.ts`, `repo-automation-execute-docs.ts`, and Jest tests under
`extensions/drm-copilot/test/`. Planned files (edit): `mcp-tools.ts`,
`repo-automation-tool-names.ts`, and every existing test that enumerates the MCP tool set.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

## Constraints & Risks

- The MCP server must locate `.claude/lib/docs/Invoke-DocsCommand.ps1` in a destination
  repository or in the bundled resources, following the pattern of existing PowerShell-backed MCP
  tools.
- The subcommand contracts are owned by #1021, #1022, #1023 and #1024, which are being re-prepared
  concurrently; argument names come from the epic's naming contract.
- Tests must not create temporary files; process execution is injected.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: input validation, argument mapping, envelope parsing, exit-code mapping
- [ ] Integration scenarios: tool registration and enumeration in the MCP tool set
- [ ] CLI/API examples: one invocation per tool

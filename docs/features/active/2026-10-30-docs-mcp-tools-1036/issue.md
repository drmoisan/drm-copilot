# docs-mcp-tools (Issue #1036)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-mcp-tools/ (Issue #1036)
- Parent epic: #1019 (documentation-estate-tooling), child 900007 (wave 3, band C3)
- Depends on: #1021, #1022, #1023, #1024

- Issue: #1036
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1036
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

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

## Proposed Behavior

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

## Acceptance Criteria (early draft)

- [ ] Each of the six tools validates its input, invokes the matching subcommand with `-Json`, and returns structured output including the exit code and findings.
- [ ] Invalid input is rejected before any process starts.
- [ ] `update_docs_ledger` is the only mutating tool and routes through `-Command update-ledger`.
- [ ] No logic beyond argument mapping and result parsing lives in TypeScript; every operation is reachable from a skill through `Invoke-DocsCommand.ps1`.
- [ ] Jest line coverage >= 85% and branch coverage >= 75% on the new modules.

## Constraints & Risks

- The MCP server must locate `.claude/lib/docs/Invoke-DocsCommand.ps1` in a destination
  repository or in the bundled resources, following the pattern of existing PowerShell-backed MCP
  tools.
- The subcommand contracts are owned by #1021, #1022, #1023 and #1024, which are being re-prepared
  concurrently; argument names come from the epic's naming contract.
- Tests must not create temporary files; process execution is injected.

## Test Conditions to Consider

- [ ] Unit coverage areas: input validation, argument mapping, envelope parsing, exit-code mapping
- [ ] Integration scenarios: tool registration and enumeration in the MCP tool set
- [ ] CLI/API examples: one invocation per tool

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/docs-mcp-tools/` folder from the template

# `docs-mcp-tools` — User Story

- Issue: #1036
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30T18-58

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

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


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] Each of the six tools validates its input, invokes the matching subcommand with `-Json`, and returns structured output including the exit code and findings.
- [ ] Invalid input is rejected before any process starts.
- [ ] `update_docs_ledger` is the only mutating tool and routes through `-Command update-ledger`.
- [ ] No logic beyond argument mapping and result parsing lives in TypeScript; every operation is reachable from a skill through `Invoke-DocsCommand.ps1`.
- [ ] Jest line coverage >= 85% and branch coverage >= 75% on the new modules.


## Non-Goals

Call out what is explicitly excluded from this feature.

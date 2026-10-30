# `docs-mcp-tools` — User Story

- Issue: #1036
- Owner: drmoisan
- Status: Draft
- Version: 0.2
- Last Updated: 2026-10-30T23-45

## Story Statement

- As a documentation role agent working only through MCP tools, I want typed `drm-copilot` tools
  for the docs subcommands that return the exit code and findings as structured data, so that I can
  check pages, read inventory and coverage, update the ledger and validate artifacts without direct
  Write access to ledger or matrix files.
- As a skill author, I want each MCP tool to run the same `.claude/lib/docs/Invoke-DocsCommand.ps1`
  subcommand that my skill runs, so that an MCP verdict and a skill or CI verdict over the same
  artifacts agree.
- As a maintainer of the drm-copilot extension, I want the docs tools covered by Jest gates that
  need no real process and no temporary files, so that the tool surface, the enumeration tests and
  the coverage thresholds stay verifiable in CI on every platform.

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

- Persona: documentation role agent (for example `docs-reconciler`, defined later by 900009)
  - Is a subagent whose tool allowlist holds MCP tools and no Write or Edit on ledger or matrix
    paths.
  - Cares about receiving findings as structured data it can act on, and about not mutating
    artifacts by accident.
  - Constraint: cannot run `pwsh` directly; any failure must be distinguishable as a findings
    result, a usage error or a host problem.
- Scenario: reconciling the ledger after a surface change
  - The agent is asked to reconcile documentation after a CLI option was added.
  - It calls `run_docs_coverage` with `workspace_root`; the result has `ok: false`, exit 1, and
    findings in `docs.findings` naming the uncovered element.
  - It calls `update_docs_ledger` with `operation: "set-disposition"`, the element id,
    `disposition: "documented"`, one page, `actor_kind: "agent"` and its `actor_id`, without
    `write`; the dry-run result shows the planned change.
  - It repeats the call with `write: true`; the ledger changes inside PowerShell.
  - It calls `validate_docs_artifacts` with `mode: "ledger"` and the head revision and receives the
    result without any receipt being persisted.
  - If it passes a `rationale` beginning with `-`, the call is rejected before any process starts.

- Persona: skill author
  - Writes skills that call `Invoke-DocsCommand.ps1` directly with `pwsh`.
  - Cares that MCP and the skill path run identical logic and read the same envelope.
- Scenario: comparing a skill run with an MCP run
  - The author runs `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command check -Json`
    in the workspace and calls `run_docs_check` with the same `workspace_root`.
  - Both read the workspace copy of `.claude/lib/docs/`; the MCP `docs` field equals the envelope
    the skill printed.
  - When the workspace lacks the pushed-down lib, the MCP call returns `DOCS_ENTRY_SCRIPT_MISSING`
    with a next action naming `push_down_claude_customizations`.

- Persona: extension maintainer
  - Runs `node run-jest.cjs` locally and relies on the `drm-copilot-extension-tests` CI job.
  - Cares about coverage gates per file, isolation, file-size limits and enumeration tests that do
    not drift.
- Scenario: adding the tools
  - The maintainer runs the Jest suite; the enumeration tests show the docs names in the agreed
    position, the coverage output reports per-file figures for the new modules, and a seeded
    shuffled run passes without spawning `pwsh` or writing files.

## Acceptance Criteria

Epic criteria (verbatim):

- [ ] Each of the six tools validates its input, invokes the matching subcommand with `-Json`, and returns structured output including the exit code and findings.
- [ ] Invalid input is rejected before any process starts.
- [ ] `update_docs_ledger` is the only mutating tool and routes through `-Command update-ledger`.
- [ ] No logic beyond argument mapping and result parsing lives in TypeScript; every operation is reachable from a skill through `Invoke-DocsCommand.ps1`.
- [ ] Jest line coverage >= 85% and branch coverage >= 75% on the new modules.

### Story 1 - Documentation role agent

- [ ] Exit 1, 2 and 3 return `ok: false` results whose `docs` field carries the full envelope (`command`, `exit_code`, `findings`, `ok`, `result`) and whose `summary` has the form `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>`; exit 0 returns `ok: true` with the envelope in `docs`.
- [ ] Host failures (`DOCS_WORKSPACE_ROOT_INVALID`, `DOCS_ENTRY_SCRIPT_MISSING`, `DOCS_PWSH_UNAVAILABLE`, `DOCS_RUNTIME_UNAVAILABLE`, `DOCS_ENVELOPE_EMPTY`, `DOCS_ENVELOPE_MALFORMED`, `DOCS_ENVELOPE_EXIT_MISMATCH`, `DOCS_ENVELOPE_COMMAND_MISMATCH`) return `ok: false` without a `docs` field and with a message prefixed by the code.
- [ ] `update_docs_ledger` without `write`, or with `write: false`, runs as a dry run (no `-Write` in the argv); only `write: true` emits `-Write`.
- [ ] `run_docs_inventory` and `generate_docs_reference` never emit `-Write`, and `validate_docs_artifacts` never emits `-WriteReceipt` (OQ-A provisional default).
- [ ] The tool listing carries `annotations` with `readOnlyHint: true` on the read-only docs tools and `readOnlyHint: false`, `destructiveHint: true` on `update_docs_ledger`, and `DOCS_MUTATING_TOOLS` equals `["update_docs_ledger"]`.
- [ ] A string value beginning with `-` in any field is rejected before launch (OQ-C provisional default).

### Story 2 - Skill author

- [ ] Each tool launches `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <subcommand> -Json <options>` with the working directory equal to `workspace_root`, using the workspace copy of the script.
- [ ] Each tool's options match its row in spec `## Upstream Contract Dependencies`, and the PowerShell option names are held in one declarative table per tool.
- [ ] The `docs` field equals the envelope the entry script printed, unchanged; `result` is not reshaped by TypeScript.
- [ ] TypeScript does not reject an input whose only defect is a missing companion value that 1023 reports as a ledger finding; PowerShell reports it.
- [ ] A missing entry script returns `DOCS_ENTRY_SCRIPT_MISSING` with a next action naming `push_down_claude_customizations`, and the launcher is not called.
- [ ] The execution-environment brief bullet stating that the docs tools run the workspace's `.claude/lib/docs/Invoke-DocsCommand.ps1` is present and byte-identical in every copy listed in spec `## Implementation Strategy`.

### Story 3 - Extension maintainer

- [ ] The existing enumeration tests follow spec `## Existing Tests That Enumerate the MCP Tool Set`: the listed updates are made and every row marked **Unchanged** passes without edit.
- [ ] `REPO_AUTOMATION_TOOLS` has 49 entries with the docs names immediately after `render_subagent_tree` and before `validate_discovery_artifacts`.
- [ ] A contract test reads the committed `schemas/docs/v1/docs-command-envelope.schema.json` read-only and checks its `required` set and `additionalProperties: false` against the parser.
- [ ] `extensions/drm-copilot/jest.docs-coverage.json` registers an 85/75 entry for each new production file, merged into `jest.config.cjs` by one spread line, with per-file figures recorded under `evidence/coverage/`.
- [ ] No test creates a temporary file or spawns `pwsh`; launcher, `FileSystem` and `pwsh` resolution are injected, and a seeded shuffled Jest run passes.
- [ ] Every new file is below 500 logical lines and the seven-stage toolchain passes in a single pass.

## Non-Goals

- New PowerShell logic or edits under `.claude/lib/docs/` (owned by 1020-1024 and 1034).
- MCP tools for `init`, `validate-profile` or `surface-delta`.
- Persisting inventory snapshots, generated reference pages or receipts through MCP (OQ-A).
- Adding the docs tools to `.codex/config.toml` `enabled_tools` or the `.claude/settings.json`
  allow list (OQ-B; 900009 decides).
- Documentation roles, skills and allowlists (900009).
- A JSON Schema validator dependency, or full schema validation of real output in Jest (1020's
  Pester suites own it).
- Edits to `src/discovery-runtime.ts`, release version bumps or the `packages/mcp-server` package.
- A real `pwsh` round trip in unit tests; Windows quoting and non-ASCII stdout remain an execution
  probe after 1020-1024 merge.

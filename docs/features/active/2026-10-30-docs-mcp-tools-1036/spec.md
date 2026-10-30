# docs-mcp-tools — Spec

- **Issue:** #1036
- **Parent (optional):** #1019 (documentation-estate-tooling, child 900007, wave 3, band C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T23-45
- **Status:** Draft
- **Version:** 0.2

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

Requirement sources, in order of authority: the epic (`### Naming contract (fixed for all
children)`, `## Owner Decisions`, `### Amendment of 1020 required by D3 and D5`, `### Command
contract decisions from the first preparation of 1023`, `### 900007 - docs-mcp-tools (wave 3,
C3)`); `research/orchestrator-confirmations.2026-10-30T23-30.md` (binding option maps and envelope
schema text; supersedes the provisional option table in the research file); and
`research/research.2026-10-30T23-05.md` (`## Recommended Design`, dispositions, classification).

## Behavior

Add six TypeScript MCP tool wrappers in `extensions/drm-copilot/src/` (bundled into
`packages/mcp-server`): `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
`update_docs_ledger`, `generate_docs_reference` and `validate_docs_artifacts`.

Per call, in this order:

1. `dispatchRepoAutomationTool` (`src/mcp-tools.ts`) reaches one of six literal `case` labels that
   fall through to `handleDocsTool(toolName, rawInput, service)` (`src/mcp-handlers/docs-handlers.ts`).
2. The tool's resolver (`src/mcp-tool-inputs-docs.ts`) validates the raw input against the tool's
   declarative input table and returns `{ workspaceRoot, subcommand, options }`, where `options` is
   an ordered list built from that table. Any violation throws before any filesystem or process
   call.
3. If `service.runDocsCommand` is undefined, the handler fails with `DOCS_RUNTIME_UNAVAILABLE`.
4. `DefaultRepoAutomationService.runDocsCommand` delegates to `invokeDocsCommand(request, deps)`
   (`src/repo-automation-execute-docs.ts`). It checks, in order, that `workspace_root` is absolute
   (`DOCS_WORKSPACE_ROOT_INVALID`), that `<workspace_root>/.claude/lib/docs/Invoke-DocsCommand.ps1`
   exists through the injected `FileSystem.isFile` (`DOCS_ENTRY_SCRIPT_MISSING`), and that `pwsh`
   resolves through `resolveExecutableOnPath` (`DOCS_PWSH_UNAVAILABLE`). It then launches
   `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <subcommand> -Json <options>`
   with the working directory set to `workspace_root` and empty stdin, through a
   `DiscoveryProcessLauncher` (default `createNodeProcessLauncher()`, imported from
   `src/discovery-runtime.ts`, which is not edited).
5. `parseDocsEnvelope(stdout, { exitCode, stderr, command })` (`src/docs-command-envelope.ts`)
   returns the typed envelope or throws one of the envelope host failure codes.
6. The handler returns a `RepoAutomationMcpToolResult` with `ok = envelope.ok`, `tool`,
   `workspace_root`, `summary`, a `docs` field carrying the envelope unchanged, and
   `stderr_excerpt` when `exit_code` is 3.

Exit codes follow the naming contract: 0 success, 1 findings, 2 usage or input error, 3 internal or
I/O error. Exit codes 1 to 3 are returned as `ok: false` results that carry the full envelope in
`docs`; they are not thrown, so findings reach the caller. `toCallToolResult` sets `isError: true`
for them. Transport failures (host failure codes) are returned as `ok: false` through
`toFailureToolResult` with a code-prefixed message and no envelope.

`update_docs_ledger` is the only mutating tool and routes through `-Command update-ledger`; it is a
dry run unless `write` is `true`. `run_docs_inventory` returns the snapshot in `result` without
writing it; `generate_docs_reference` runs as a dry run only; `validate_docs_artifacts` never
persists receipts (OQ-A). TypeScript holds only declarative argument mapping, pre-launch input
checks that mirror published grammars, and envelope parsing; one process per call, no retries, no
writes by TypeScript.

## Inputs / Outputs

- Inputs: one MCP tool call with a JSON object matching the tool's `inputSchema`
  (`additionalProperties: false`). Every tool requires `workspace_root` (absolute path), which
  becomes the process working directory and is never passed as an option.
- Optional `profile` (relative path) maps to `-Profile`; when omitted, PowerShell resolves its
  default (`docs/documentation-estate/docs-profile.json`).
- Outputs: `RepoAutomationMcpToolResult` with the existing fields plus an optional `docs` field of
  type `DocsCommandEnvelope` (`command`, `exit_code`, `findings`, `ok`, `result`). `summary` has the
  1020 summary-line shape `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>`, counted from
  `findings`. `stderr_excerpt` holds the first eight non-empty stderr lines when `exit_code` is 3.
- Environment: PowerShell 7.4 or later on PATH as `pwsh` (no fallback to Windows `powershell`);
  the pushed-down docs lib present in the workspace.
- Configuration keys: none. Test seams only: optional `RepoAutomationServiceOptions.docs` with
  `launcher` and `resolvePwsh`.
- Compatibility: `runDocsCommand?` and `ToolDefinition.annotations?` are optional additions; no
  existing caller, definition or mock changes type.

## API / CLI Surface

### Tool input tables

Each tool has one declarative input table in `src/mcp-tool-inputs-docs.ts`; PowerShell option names
appear only there (see `## Upstream Contract Dependencies`).

| Tool | Subcommand | Input field (type; required) | PowerShell option (kind) |
|---|---|---|---|
| `run_docs_check` | `check` | `workspace_root` (absolute path; required); `profile` (relative path); `paths` (array of relative paths) | `-Profile` (value); `-Path` (multi) |
| `run_docs_inventory` | `inventory` | `workspace_root`; `profile`; `analyzers` (array of identifiers); `revision` (full revision) | `-Profile` (value); `-Analyzer` (multi); `-Revision` (value). Never `-Write` |
| `run_docs_coverage` | `coverage` | `workspace_root`; `profile` | `-Profile` (value) |
| `update_docs_ledger` | `update-ledger` | `workspace_root`; `operation` (enum `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`, `sync-refs`; required); `element` (element id); `limit` (positive integer); `disposition` (enum `documented`, `excluded`, `deferred`); `pages` (array of page references); `rationale`, `target`, `claim` (text); `owner` (identifier); `dimension` (enum `exists`, `accurate`, `example_present`, `owner_assigned`, `diataxis_mode`); `state` (enum `pass`, `fail`, `not-assessed`, `not-applicable`); `actor_kind` (enum `human`, `agent`, `tool`; required); `actor_id` (identifier; required); `write` (boolean, default `false`); `profile` | `-Operation`, `-Element`, `-Limit`, `-Disposition` (value); `-Page` (multi); `-Rationale`, `-Owner`, `-Target`, `-Dimension`, `-State`, `-Claim`, `-ActorKind`, `-ActorId` (value); `-Profile` (value); `-Write` (switch, emitted only when `write` is `true`) |
| `generate_docs_reference` | `generate-reference` | `workspace_root`; `profile`; `snapshot` (relative path); `output_directory` (relative path) | `-Profile`, `-Snapshot`, `-OutputDirectory` (value). Never `-Write` |
| `validate_docs_artifacts` | `validate` | `workspace_root`; `mode` (enum `profile`, `ledger`, `matrix`, `docs-complete`; required); `revision` (full revision; required); `profile` | `-Mode`, `-Revision`, `-Profile` (value). Never `-WriteReceipt` |

### Validation rules (all before launch)

- Unknown keys, wrong types, enum values outside the list, and empty strings are rejected.
- Grammars mirror the published docs-common definitions and are pinned by a parity test: relative
  path (docs-common `relative-path` pattern), identifier `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`, full
  revision `^(?:[0-9a-f]{40}|[0-9a-f]{64})$`, element id
  `^(?:cli-command|cli-option|http-route|config-key|public-symbol|architecture-component)-[0-9a-f]{64}$`,
  page reference (relative path, optionally `#<anchor>` with a non-empty anchor).
- Any string value whose first character is `-` is rejected (OQ-C).
- Duplicate `pages` entries are rejected.
- `update_docs_ledger` per-operation table (from the 1023 `update-ledger` contract):
  `set-disposition` requires `element` and `disposition` and permits `pages`, `rationale`, `owner`,
  `target`; `remove-entry` requires `element`; `pin` requires `element` and exactly one `pages`
  entry without anchor and permits `claim`; `unpin` requires `element` and one page without anchor;
  `set-dimension` requires `element`, one page without anchor, `dimension` and `state` and permits
  `rationale`; `sync-refs` requires none. `limit` is permitted only for the operations the 1023
  committed table permits it for. Missing companion values that 1023 reports as ledger findings
  (for example `excluded` without `rationale`) are not rejected by TypeScript.
- PowerShell remains authoritative: anything TypeScript accepts and PowerShell rejects returns exit
  2 with `DOCS_CLI_ARGUMENTS` in the envelope.

### Option emission

- The argv is `[<pwsh path>, "-NoProfile", "-File", ".claude/lib/docs/Invoke-DocsCommand.ps1",
  "-Command", <subcommand>, "-Json", ...options]`.
- Options are emitted in declarative-table order. A `value` option emits `-<Name> <value>`; a
  `switch` option emits `-<Name>` only; a `multi` option emits one entry per array element in the
  multi-value form defined by 1020's `Invoke-DocsCommand.ps1` dispatch contract; an empty array or
  an omitted field emits nothing; integers are emitted as decimal strings.
- The reserved names `Command`, `Json`, `Help` and `RepositoryRoot` are never emitted from input.

### Host failure codes

| Code | Condition | Process launched |
|---|---|---|
| `DOCS_WORKSPACE_ROOT_INVALID` | `workspace_root` missing or not absolute (`normalizeWorkspaceRoot`, `isAbsolutePathLike` in `src/workflow-command-arguments.ts`) | no |
| `DOCS_ENTRY_SCRIPT_MISSING` | entry script absent; next action names `push_down_claude_customizations` | no |
| `DOCS_PWSH_UNAVAILABLE` | `pwsh` not resolvable on PATH, or the launcher reports a launch error | no (or launch failed) |
| `DOCS_RUNTIME_UNAVAILABLE` | the service has no `runDocsCommand` seam | no |
| `DOCS_ENVELOPE_EMPTY` | stdout is empty or whitespace | yes |
| `DOCS_ENVELOPE_MALFORMED` | stdout is not exactly one JSON document; key set not exactly `command, exit_code, findings, ok, result`; wrong type; `exit_code` outside 0-3; `ok` not equal to `exit_code === 0`; a finding whose key set is not the docs-common `finding` key set (`code, severity, artifact_path, pointer, related_ids, related_paths, message, next_action`) | yes |
| `DOCS_ENVELOPE_EXIT_MISMATCH` | envelope `exit_code` differs from the process exit code | yes |
| `DOCS_ENVELOPE_COMMAND_MISMATCH` | envelope `command` differs from the requested subcommand | yes |

`pwsh` 7.0-7.3 is not detected in TypeScript; the entry returns exit 3 with
`DOCS_RUNTIME_UNSUPPORTED` in a normal envelope.

### Example invocations

- `run_docs_check` `{ "workspace_root": "<abs>", "paths": ["docs/index.md"] }` ->
  `-Command check -Json -Path docs/index.md`.
- `run_docs_inventory` `{ "workspace_root": "<abs>", "analyzers": ["python-cli"] }` ->
  `-Command inventory -Json -Analyzer python-cli`.
- `run_docs_coverage` `{ "workspace_root": "<abs>" }` -> `-Command coverage -Json`.
- `update_docs_ledger` `{ "workspace_root": "<abs>", "operation": "sync-refs", "actor_kind": "agent", "actor_id": "docs-reconciler" }`
  -> `-Command update-ledger -Json -Operation sync-refs -ActorKind agent -ActorId docs-reconciler` (dry run).
- `generate_docs_reference` `{ "workspace_root": "<abs>", "output_directory": "docs/reference" }` ->
  `-Command generate-reference -Json -OutputDirectory docs/reference` (dry run).
- `validate_docs_artifacts` `{ "workspace_root": "<abs>", "mode": "docs-complete", "revision": "<40-hex>" }`
  -> `-Command validate -Json -Mode docs-complete -Revision <40-hex>`.

The exact emitted order follows the declarative table; the examples show option content only.

### Tool annotations

`ToolDefinition` in `src/mcp-repo-automation-tool-definitions.ts` and `src/mcp-tool-definitions.ts`
gains optional `annotations?: { readOnlyHint?; destructiveHint?; idempotentHint?; openWorldHint? }`
(readonly booleans). `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
`generate_docs_reference` and `validate_docs_artifacts` set `readOnlyHint: true`;
`update_docs_ledger` sets `readOnlyHint: false` and `destructiveHint: true`; all six set
`openWorldHint: false`. `src/mcp-docs-tool-definitions.ts` exports
`DOCS_MUTATING_TOOLS = ["update_docs_ledger"] as const`. Annotations are hints; enforcement is
structural (no write field on the read-only tools and argv builders that never emit the write
switches).

## Data & State

- TypeScript writes nothing and holds no state between calls; no module-level mutable state in the
  new modules.
- The envelope is passed through unchanged in `docs`; `result` is opaque to TypeScript.
- Persistence happens only inside PowerShell, only for `update_docs_ledger` with `write: true`.
- No migration or backfill.

## Constraints & Risks

- The subcommand option maps are pre-clearance upstream text on the 1020-1024 feature branches;
  a rename is a one-line change in the declarative table.
- The envelope schema file `schemas/docs/v1/docs-command-envelope.schema.json` is committed by 1020
  before 900007 executes (900007 depends on 1021-1024, which depend on 1020). The schema contract
  test depends on it.
- Windows argument quoting of values containing `"` and the stdout encoding of non-ASCII text
  through `pwsh -File` are unverified (confirmation F4); they are probe items after 1020-1024 merge
  into the integration branch, not assumptions.
- Through MCP, the docs logic is the workspace (branch) copy of `.claude/lib/docs/` while the
  wrapper is the installed extension; the execution-environment brief records this.
- No JSON Schema validator library is added; the extension depends only on
  `@modelcontextprotocol/sdk` (locked at 1.32.1, confirmation F3).
- Tests must not create temporary files; process execution, filesystem and `pwsh` resolution are
  injected.

## Implementation Strategy

- New modules (`extensions/drm-copilot/src/`): `mcp-docs-tool-definitions.ts` (definitions,
  annotations, `DOCS_MUTATING_TOOLS`), `mcp-tool-inputs-docs.ts` (declarative input tables,
  grammars, per-operation table, resolvers), `mcp-handlers/docs-handlers.ts` (`handleDocsTool`,
  result mapping), `repo-automation-execute-docs.ts` (`invokeDocsCommand`, pre-launch checks,
  argv), `docs-command-envelope.ts` (pure parser `parseDocsEnvelope`, `DocsCommandEnvelope` type).
- Edited modules: `mcp-tools.ts` (six `case` labels, optional `docs` on
  `RepoAutomationMcpToolResult`), `repo-automation-tool-names.ts` (six names after
  `render_subagent_tree`, before `validate_discovery_artifacts`),
  `mcp-repo-automation-tool-definitions.ts` and `mcp-tool-definitions.ts` (`annotations?`, spread
  of one shared docs-definition constant into both), `repo-automation-service-contract.ts`
  (`runDocsCommand?`, `docs` options), `repo-automation-service.ts` (`runDocsCommand`).
- Coverage registration: new `extensions/drm-copilot/jest.docs-coverage.json` with one 85/75 entry
  per new production file, merged into `jest.config.cjs` by one spread line (precedent
  `jest.discovery-coverage.json`).
- Documentation: `extensions/drm-copilot/README.md` (`### Exposed MCP Tools`,
  `### MCP Input Summary`, `### MCP Result Shape`, PowerShell 7.4 and pushed-down-lib
  prerequisite); `extensions/drm-copilot/CHANGELOG.md` (`## [Unreleased]` `### Added`); one bullet
  under `## MCP Surfaces Run the Installed Extension` in every copy of the execution-environment
  brief: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`,
  `.github/skills/execution-environment/SKILL.md`,
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`,
  `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`,
  `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.
  The bullet states that the docs tools invoke the workspace's
  `.claude/lib/docs/Invoke-DocsCommand.ps1`, so branch edits to the docs lib apply through MCP
  immediately, while the wrapper itself is the installed extension.
- Dependencies: none added.
- Logging: none beyond the existing MCP result fields.
- Rollout: ships with the next MCP package release (release mechanics out of scope).
- Rejected alternatives (research `### Rejected alternatives`): bundled script from extension
  resources; `executeScriptServiceCall` / `runCommandWithOutput`; `SubprocessRunner`; a required
  `runDocsCommand`; appending names after the discovery block.

## Artifact Classification

Rule references: E1 = epic `### Artifact classes for this epic` row "MCP tool wrapper | TypeScript |
`extensions/drm-copilot/src/`"; E2 = row "Test | ... Jest for TypeScript | `extensions/drm-copilot/test/`";
E3 = row "Schema, example, configuration | JSON/YAML/INI data"; R2 = owner directive clause (2)
(TypeScript only for MCP commands); DOC = documentation (Markdown).

| File | Action | Class | Language | Permitting rule |
|---|---|---|---|---|
| `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` | create | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/mcp-tool-inputs-docs.ts` | create | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/mcp-handlers/docs-handlers.ts` | create | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/repo-automation-execute-docs.ts` | create | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/docs-command-envelope.ts` | create | MCP tool (pure envelope parser) | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/mcp-tools.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/repo-automation-tool-names.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/repo-automation-service.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/test/mcp-docs-tool-definitions.test.ts`, `test/mcp-tool-inputs-docs.test.ts`, `test/mcp-handlers/docs-handlers.test.ts`, `test/repo-automation-execute-docs.test.ts`, `test/docs-command-envelope.test.ts`, `test/mcp-server.docs.test.ts` | create | test | TypeScript (Jest) | E2 |
| `extensions/drm-copilot/test/mcp-server.test.ts`, `test/mcp-discovery-authority-tool-definitions.test.ts`, `test/mcp-server-test-service.ts`, the existing `repo-automation-service` test suite (one `runDocsCommand` case) | edit | test | TypeScript (Jest) | E2 |
| `extensions/drm-copilot/jest.docs-coverage.json` | create | schema/config/data | JSON | E3 |
| `extensions/drm-copilot/jest.config.cjs` (one merge line) | edit | schema/config/data (existing test-tool configuration) | CommonJS JavaScript | Existing file; data registration required by the coverage policy (precedent `jest.discovery-coverage.json`); no new logic |
| `extensions/drm-copilot/README.md`, `extensions/drm-copilot/CHANGELOG.md` | edit | documentation | Markdown | DOC |
| execution-environment `SKILL.md` (every copy listed under `## Implementation Strategy`) | edit | documentation (skill text) | Markdown | DOC; mirror parity required |
| `docs/features/active/2026-10-30-docs-mcp-tools-1036/**` | create/edit | documentation | Markdown | DOC |

No artifact requires a language outside the rule. Not edited: `src/discovery-runtime.ts`,
`.codex/config.toml` and its bundle copy, `.claude/settings.json`, any agent file, any
`packages/mcp-server` file, any `.claude/lib/docs/` file.

## Existing Tests That Enumerate the MCP Tool Set

Search scope and patterns: research `## 4. Every test or contract that enumerates the MCP tool set`.
Row 2's count change is backed by research `## Numeric Derivation Evidence` N1 (43 before, 49 after).

| # | Path | Test name | Assertion kind | Disposition |
|---|---|---|---|---|
| 1 | `extensions/drm-copilot/test/mcp-server.test.ts` | `registers the semantic repo automation tools` | Exact ordered list from `client.listTools()` | **Update**: insert the six names after `render_subagent_tree`; move the expected list into `test/mcp-server-test-service.ts` as an exported constant to keep the file below 500 lines |
| 2 | `extensions/drm-copilot/test/mcp-discovery-authority-tool-definitions.test.ts` | `advertises all nineteen discovery tools in union order` | Slice from `validate_discovery_artifacts`; `DISCOVERY_TOOL_DEFINITIONS` length; `REPO_AUTOMATION_TOOLS` length | **Update** the `REPO_AUTOMATION_TOOLS` length from 43 to 49; slice assertion unchanged because the docs names precede the discovery block |
| 3 | `extensions/drm-copilot/test/mcp-discovery-tool-definitions.test.ts` | `keeps the definition list aligned with the widened union order` | Derived equality; discovery tail slice | **Unchanged** (docs block inserted before the discovery block) |
| 4 | `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` | `defines one schema entry for every advertised repo automation tool`; `declares the same input-schema properties and required arrays on both tool-definition surfaces`; `lists workspace_root in inputSchema.required for every repo automation tool (all 28)` | Derived equality; shared-name equality; `required` contains `workspace_root` | **Unchanged**; constrains design: each docs definition requires `workspace_root` and is one constant spread into both surfaces |
| 5 | `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` | `exposes one shared tool set to the standalone server and the extension provider` | Derived equality; `src/mcp-tools.ts` contains `case "<name>":` per name | **Unchanged**; constrains design: literal `case` labels per docs tool |
| 6 | `extensions/drm-copilot/test/extension.list-mcp-tools.test.ts` | `shows the MCP tool list in a Quick Pick and logs it to the output channel` | `arrayContaining` membership | **Unchanged** |
| 7 | `extensions/drm-copilot/test/repo-automation-render-subagent-tree.test.ts` | `listRepoAutomationTools advertisement` | Membership | **Unchanged** |
| 8 | `extensions/drm-copilot/test/mcp-server-test-service.ts` (`createMockService`), `test/mcp-tools.workspace-root.test.ts` and other suites typed `jest.Mocked<RepoAutomationService>` | n/a (fixtures) | Object literals of required service methods | **Unchanged** because `runDocsCommand` is optional; `mcp-server-test-service.ts` gains an optional `runDocsCommand` mock and the moved expected list |
| 9 | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (`EXPECTED_DRM_COPILOT_TOOLS`, `assert_full_drm_copilot_transport`) | assertions in that helper | Tuple equality of `.codex/config.toml` `enabled_tools` | **Unchanged** (OQ-B) |
| 10 | `tests/scripts/claude-runtime/claude-settings.Tests.ps1` | `requires .claude/settings.json to use the active PowerShell MCP contract`; discovery handler test | Regex membership; `mcp__.*` matcher | **Unchanged** (OQ-B) |
| 11 | `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | rule, agent and architecture-doc tests | Regex membership of PoshQC names | **Unchanged** |
| 12 | `.claude/lib/discovery-validation/DiscoveryToolRouting.psm1` (`$script:ControlledToolOperations`), `src/discovery-authorization-record.ts` (`CONTROLLED_TOOLS`); `DiscoveryToolRouting.Tests.ps1`, `DiscoveryAuthorization.Tests.ps1`, `mcp-discovery-authorization-gate.test.ts` | various | Controlled discovery tools only | **Unchanged**; docs tools are not controlled tools |
| 13 | `src/lib/validate/plan-gate-observability.ts`, `scripts/dev_tools/plan_gate_observability.py` and their tests | G7 PoshQC marker table | PoshQC tool suffixes only | **Unchanged** |
| 14 | `README.md` `### MCP tool surface`; `extensions/drm-copilot/README.md` `### Exposed MCP Tools`, `### MCP Input Summary` | none | Hand-maintained lists | **Update the extension README**; root README optional |

## Upstream Contract Dependencies

Option maps per subcommand, as committed on the upstream feature branches (confirmation F1;
pre-clearance text). The option names live in one declarative table per tool in
`src/mcp-tool-inputs-docs.ts`, so a later rename is a one-line change.

| Subcommand | Owner | Upstream option map | Options emitted by 900007 |
|---|---|---|---|
| `check` | 1021 | `Profile` value; `Path` multi | `-Profile`, `-Path` |
| `inventory` | 1022 | `Profile` value; `Analyzer` multi; `Revision` value; `Write` switch | `-Profile`, `-Analyzer`, `-Revision`; never `-Write` (OQ-A) |
| `coverage` | 1023 | `Profile` value | `-Profile` |
| `update-ledger` | 1023 | `Profile`, `Operation`, `Element`, `Limit`, `Disposition` value; `Page` multi; `Rationale`, `Owner`, `Target`, `Dimension`, `State`, `Claim`, `ActorKind`, `ActorId` value; `Write` switch | all upstream options; `-Write` only when `write` is `true` |
| `validate` | 1023 | `Profile` value; `Mode` value; `Revision` value; `WriteReceipt` switch | `-Profile`, `-Mode`, `-Revision`; never `-WriteReceipt` |
| `generate-reference` | 1024 | `Profile` value; `Snapshot` value; `OutputDirectory` value; `Write` switch | `-Profile`, `-Snapshot`, `-OutputDirectory`; never `-Write` (OQ-A) |

Further upstream dependencies:

- 1020 envelope schema `schemas/docs/v1/docs-command-envelope.schema.json` (confirmation F2):
  `$id` `urn:drm-copilot:docs:1.0.0:docs-command-envelope`; `additionalProperties: false`;
  `required` `command, exit_code, findings, ok, result`; `exit_code` integer enum 0-3; `findings`
  items reference docs-common `finding`; `result` open; conditional exit rules. This schema governs
  (D5 and `### Amendment of 1020 required by D3 and D5`); the earlier "the envelope has no schema
  file" sentences in the 1020 spec and the epic's `### PowerShell contracts from the re-preparation
  of 1020` are superseded. Full schema validation of real output stays in 1020's Pester suites.
- 1020 `Invoke-DocsCommand.ps1` dispatch contract: reserved names, the multi-value emission form,
  exit-code findings `DOCS_CLI_ARGUMENTS` and `DOCS_CLI_RUNTIME`, PowerShell 7.4 floor.
- 1020 docs-common grammars (`schemas/docs/v1/common.schema.json`); until committed, the parity
  test reads `schemas/discovery/v2/common.schema.json`, from which the docs definitions are copied.
- 1021 `-Path` value grammar (relative path assumed; if 1021 accepts path-or-glob, the input table
  grammar changes accordingly).
- 1023 `update-ledger` per-operation table, including which operations permit `-Limit`.

## Contracts Later Children Must Honor

For 900009 (docs-authoring-workflow) and any later caller:

- Tool names: `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`, `update_docs_ledger`,
  `generate_docs_reference`, `validate_docs_artifacts` (MCP form `mcp__drm-copilot__<name>`).
- Input field names and types as in `### Tool input tables`; `workspace_root` is required on every
  tool; free-text values cannot begin with `-` (OQ-C).
- Result: `RepoAutomationMcpToolResult` with `ok`, `tool`, `workspace_root`, `summary`
  (`<command>: exit=<n> errors=<n> warnings=<n> infos=<n>`), `docs` (the unchanged envelope) and,
  for exit 3, `stderr_excerpt`. Exit codes 1-3 arrive as `ok: false` with `docs` present; host
  failures arrive as `ok: false` without `docs` and with a message prefixed by a host failure code.
- `DOCS_MUTATING_TOOLS` (`["update_docs_ledger"]`) and the `annotations` on each definition are the
  classification a role allowlist reads; `update_docs_ledger` writes only with `write: true`.
- No docs tool persists an inventory snapshot, generated pages or a receipt; persistence of those
  stays with skills and CI through `Invoke-DocsCommand.ps1` (OQ-A).
- OQ-B: 900007 does not add the docs tools to `.codex/config.toml` `enabled_tools` or the
  `.claude/settings.json` allow list; 900009 decides that exposure when it defines the roles.

## Owner Questions

Provisional defaults stand; this feature does not decide beyond them.

- **OQ-A - Scope of "only mutating tool".** The epic criterion says `update_docs_ledger` is the
  only mutating tool, while `inventory` and `generate-reference` define `-Write` switches and 1023
  narrows "mutating" to the ledger, matrix and pins. Provisional default: strict reading. Through
  MCP, `run_docs_inventory` returns the snapshot in `result` without writing it, and
  `generate_docs_reference` runs as a dry run only; persisting a snapshot or generated pages
  remains available to skills and CI through `Invoke-DocsCommand.ps1`. Alternative: allow those
  write switches and restate the criterion as "the only tool that changes ledger, matrix or pin
  artifacts".
- **OQ-B - Codex and Claude permission exposure.** `.codex/config.toml` `enabled_tools` and the
  `.claude/settings.json` allow list are curated subsets that omit the discovery tools. Provisional
  default: 900007 adds the docs tools to neither; 900009 decides (consistent with epic OQ-2).
- **OQ-C - Option-like values (cross-feature, 1020).** A value beginning with `-` passed through
  `pwsh -File` reaches `ValueFromRemainingArguments` as a separate token and could be read as an
  option. Provisional default: 900007 rejects such values before launch; 1020's
  `ConvertFrom-DocsCommandArgument` should also treat the token after a `value` option as its
  value. Free-text fields (`rationale`, `claim`, `target`) therefore cannot begin with `-` through
  MCP.

No artifact in this feature falls outside the language rule, so no further owner question arises
from classification.

## Acceptance Criteria

Epic criteria (verbatim):

- [ ] Each of the six tools validates its input, invokes the matching subcommand with `-Json`, and returns structured output including the exit code and findings.
- [ ] Invalid input is rejected before any process starts.
- [ ] `update_docs_ledger` is the only mutating tool and routes through `-Command update-ledger`.
- [ ] No logic beyond argument mapping and result parsing lives in TypeScript; every operation is reachable from a skill through `Invoke-DocsCommand.ps1`.
- [ ] Jest line coverage >= 85% and branch coverage >= 75% on the new modules.

Refined criteria:

- [ ] `REPO_AUTOMATION_TOOLS` lists `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`, `update_docs_ledger`, `generate_docs_reference`, `validate_docs_artifacts` in that order, immediately after `render_subagent_tree` and immediately before `validate_discovery_artifacts`, and has 49 entries.
- [ ] `src/mcp-tools.ts` contains a literal `case "<name>":` label for each docs tool, and `exposes one shared tool set to the standalone server and the extension provider` passes without edit.
- [ ] Each docs tool definition has `additionalProperties: false`, lists `workspace_root` in `required`, and is identical on `REPO_AUTOMATION_TOOL_DEFINITIONS` and `toolDefinitions` (one shared constant spread into both).
- [ ] `ToolDefinition` in both definition files accepts optional `annotations`; the read-only docs tools set `readOnlyHint: true`, `update_docs_ledger` sets `readOnlyHint: false` and `destructiveHint: true`, every docs tool sets `openWorldHint: false`, and a Jest `client.listTools()` test observes the annotations in the listing.
- [ ] `DOCS_MUTATING_TOOLS` equals `["update_docs_ledger"]`, equals the set of docs definitions whose `readOnlyHint` is not `true`, and `update_docs_ledger` is the only docs definition with a `write` field; no docs definition has a `write_receipt` or output-file field.
- [ ] For each tool, a Jest test asserts the exact argv `[<pwsh path>, "-NoProfile", "-File", ".claude/lib/docs/Invoke-DocsCommand.ps1", "-Command", <subcommand>, "-Json", ...options]` and that the options match the tool's row in `## Upstream Contract Dependencies`, emitted from one declarative table per tool.
- [ ] `update_docs_ledger` emits `-Write` only when `write` is `true`; with `write` omitted or `false` the argv contains no `-Write`.
- [ ] No argv built by `run_docs_inventory` or `generate_docs_reference` contains `-Write`, and no argv built by `validate_docs_artifacts` contains `-WriteReceipt`, for any accepted input.
- [ ] No argv contains `-Command`, `-Json`, `-Help` or `-RepositoryRoot` derived from tool input, and an empty array or omitted field emits no option.
- [ ] Each of these inputs is rejected with the launcher and `runDocsCommand` not called: an unknown key; a wrong type; an enum value outside its list; an empty string; a value failing its grammar (relative path, identifier, full revision, element id, page reference); a string value beginning with `-`; duplicate `pages` entries; an `update_docs_ledger` operation missing a required field or carrying a field its per-operation table does not permit; `validate_docs_artifacts` without `mode` or `revision`.
- [ ] TypeScript does not reject an `update_docs_ledger` input whose only defect is a missing companion value that 1023 reports as a ledger finding (for example `disposition: "excluded"` without `rationale`).
- [ ] A grammar parity test asserts that each TypeScript pattern string equals the corresponding `pattern` value in the committed docs-common schema (discovery v2 common while docs common is absent).
- [ ] `DOCS_WORKSPACE_ROOT_INVALID`, `DOCS_ENTRY_SCRIPT_MISSING`, `DOCS_PWSH_UNAVAILABLE` and `DOCS_RUNTIME_UNAVAILABLE` are each produced by their condition in `### Host failure codes` with the launcher not called, returned as `ok: false` with a message prefixed by the code, and checked in the order workspace root, entry script, `pwsh`.
- [ ] A launch error reported by the injected launcher returns `ok: false` with `DOCS_PWSH_UNAVAILABLE`, and no resolution falls back to Windows `powershell`.
- [ ] `parseDocsEnvelope` returns `DOCS_ENVELOPE_EMPTY`, `DOCS_ENVELOPE_MALFORMED`, `DOCS_ENVELOPE_EXIT_MISMATCH` and `DOCS_ENVELOPE_COMMAND_MISMATCH` for each condition in `### Host failure codes`, and accepts valid envelopes for exit codes 0, 1, 2 and 3, tested with in-memory fixtures.
- [ ] A contract test reads the committed `schemas/docs/v1/docs-command-envelope.schema.json` read-only and asserts that its top-level `required` set equals the parser's key set and that `additionalProperties` is `false`.
- [ ] Exit 0 yields `ok: true`; exit 1, 2 and 3 yield `ok: false` results (not thrown) whose `docs` field equals the parsed envelope, whose `summary` has the form `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>`, and which carry `stderr_excerpt` only for exit 3; through `InMemoryTransport` the call returns `structuredContent.docs` and `isError` set per exit code.
- [ ] The process runs with `cwd` equal to `workspace_root`, one launch per call and no retry, through a `DiscoveryProcessLauncher` imported from `src/discovery-runtime.ts`, and `src/discovery-runtime.ts` is unchanged.
- [ ] `runDocsCommand` is optional on `RepoAutomationService`; the existing `jest.Mocked<RepoAutomationService>` literals compile without edit, and a `repo-automation-service` test asserts that `runDocsCommand` uses the injected `docs` dependencies and `fileSystem`.
- [ ] Every row of `## Existing Tests That Enumerate the MCP Tool Set` holds: rows 1, 2 and 14 are updated as stated, and every row marked **Unchanged** passes without edit.
- [ ] `.codex/config.toml`, its bundle copy and `.claude/settings.json` are unchanged by this feature (OQ-B).
- [ ] The execution-environment brief bullet for the docs tools is present and byte-identical in every copy listed under `## Implementation Strategy`, and the push-down resource contract tests pass.
- [ ] `extensions/drm-copilot/README.md` lists the docs tools, their inputs, the `docs` result field and the PowerShell 7.4 and pushed-down-lib prerequisite, and `extensions/drm-copilot/CHANGELOG.md` has an `### Added` entry under `## [Unreleased]`.
- [ ] `extensions/drm-copilot/jest.docs-coverage.json` holds an 85/75 entry for each new production file, `jest.config.cjs` merges it with one spread line, and the per-file figures from the Jest coverage output are recorded under `evidence/coverage/`.
- [ ] No new or edited test creates a temporary file or spawns `pwsh`; process launch, `FileSystem` and `pwsh` resolution are injected fakes, and a seeded shuffled run (`node run-jest.cjs --randomize --seed=<n>`) passes with evidence under `evidence/regression-testing/`.
- [ ] Every new production and test file is below 500 logical lines, no edited file rises above 800, and the seven-stage toolchain passes in a single pass.

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

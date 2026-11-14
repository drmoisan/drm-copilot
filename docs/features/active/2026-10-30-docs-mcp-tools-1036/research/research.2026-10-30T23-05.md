# docs-mcp-tools (Issue #1036) - Research

- Issue: #1036 (epic #1019 child 900007, wave 3, band C3; depends on #1021, #1022, #1023, #1024)
- Branch: `feature/docs-mcp-tools-1036`
- Mode: preparation (planning only; no production code written)
- Researcher tools: Read, Grep, Glob, WebFetch. `git show` and `gh` were not available; facts that
  need them are listed under `## Facts Needing Orchestrator Confirmation`.
- Verification legend: **[R]** file read end to end or in the cited section; **[G]** grep or glob
  over the named scope; **[W]** web fetch of the named external source.

## Summary of Recommendation

Add six MCP tools as TypeScript wrappers that (1) validate their input against a declarative
per-tool table, (2) build an argv for `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1
-Command <subcommand> -Json <options>` resolved inside `workspace_root`, (3) launch it through an
injected asynchronous process launcher, and (4) parse the canonical `-Json` envelope structurally and
return it unchanged inside the MCP result. Wire the process call through a new optional service
method `runDocsCommand?` on `RepoAutomationService`, following the optional-seam precedent of
`discoveryCapabilitySentinel?` and `transitionPreparedOrchestration?`, so the existing hand-written
service mocks in the Jest suite keep compiling. Insert the six names in `REPO_AUTOMATION_TOOLS`
after `render_subagent_tree` and before `validate_discovery_artifacts`, so the discovery tail-order
tests keep passing; two existing tests change (an exact list and a count).

## Requirements Sources and Authority

| Source | Status | Use in this research |
|---|---|---|
| `docs/features/epics/documentation-estate-tooling/epic.md` | Authoritative for subcommand names, exit codes, envelope keys, artifact classes, owner decisions D1-D5 | [R] whole file |
| `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` (v0.3) | Authoritative for the entry-script contract (`### Entry script (Invoke-DocsCommand.ps1)`, `#### Exit codes and the -Json envelope`, `## Decisions Later Children Must Honor`) except where the epic amendment supersedes it | [R] sections named |
| 1021, 1022, 1023, 1024 feature folders | Committed text is the withdrawn Python design; used only for option vocabulary | [R] specs; [G] for `Invoke-DocsCommand`, `PowerShell`, `pwsh`, `.psm1` |
| `docs/features/active/2026-10-30-docs-mcp-tools-1036/spec.md`, `issue.md`, `user-story.md` | Draft acceptance criteria (same five as epic `### 900007`) | [R] |

### Envelope schema: which text governs

- 1020 spec `#### Exit codes and the -Json envelope` says "The envelope has no schema file; Pester
  and 900007 Jest tests pin it." The epic `### PowerShell contracts from the re-preparation of 1020`
  repeats "the envelope has no schema file". [R]
- Epic `## Owner Decisions` D5 ("The JSON output envelope gets its own schema") and `### Amendment of
  1020 required by D3 and D5` (adds `schemas/docs/v1/docs-command-envelope.schema.json`; "every
  subcommand's `-Json` output validates against the envelope schema") are later and binding. [R]
- **Governing text: the amendment and D5.** Both "no schema file" sentences are stale and are
  superseded. 1020 is re-planned once for the amendment (epic text); the final schema text did not
  exist on this branch at research time: [G] `schemas/docs/**` and `.claude/lib/docs/**` return no
  files.
- What 900007 must do: no JSON Schema validator library is a dependency of the extension.
  `extensions/drm-copilot/package.json` `dependencies` lists only `@modelcontextprotocol/sdk`; its
  `devDependencies` list no `ajv` or other validator [R]. A transitive validator must not be
  imported (not approved; general-code-change `## Dependencies`). Therefore:
  1. A pure TypeScript structural parser validates the envelope (exact key set
     `command, exit_code, findings, ok, result`; `exit_code` in 0-3 and equal to the process exit
     code; `ok === (exit_code === 0)`; `command` equal to the requested subcommand; each finding has
     exactly the eight docs-common `finding` keys `code, severity, artifact_path, pointer, related_ids,
     related_paths, message, next_action` with the 1020 types). `result` is opaque.
  2. Jest pins the shape with literal canonical-JSON fixtures in memory.
  3. One contract test reads the committed `schemas/docs/v1/docs-command-envelope.schema.json`
     (read-only, no temporary file; precedent: `extensions/drm-copilot/test/packaging/discovery-resources.test.ts`
     reads committed repository files through `REPO_ROOT`) and asserts that its top-level `required`
     set equals the parser's key set and that `additionalProperties` is `false`. No full schema
     validation in Jest; full validation of real output stays in 1020's Pester suites (D5).

## 1. Existing PowerShell-backed and process-backed MCP tools

| Concern | Symbol and file | Behavior | Evidence |
|---|---|---|---|
| Tool name union | `REPO_AUTOMATION_TOOLS`, `RepoAutomationToolName` in `extensions/drm-copilot/src/repo-automation-tool-names.ts` | Ordered `as const` tuple, 43 entries | [R] |
| Advertised definitions | `REPO_AUTOMATION_TOOL_DEFINITIONS`, `ToolDefinition` in `src/mcp-repo-automation-tool-definitions.ts`; spreads `POSHQC_TOOL_DEFINITIONS` (`src/mcp-repo-automation-tool-definitions-poshqc.ts`), `HANDOFF_TOOL_DEFINITIONS`, `DISCOVERY_TOOL_DEFINITIONS` (`src/mcp-discovery-tool-definitions.ts`) | `ToolDefinition` has `name`, `description`, `inputSchema` (`additionalProperties: false`); no `annotations` field | [R] |
| Second definition surface | `toolDefinitions` in `src/mcp-tool-definitions.ts` (spreads `HANDOFF_TOOL_DEFINITIONS`, `DISCOVERY_TOOL_DEFINITIONS`) | Imported only by tests [G `mcp-tool-definitions"`]; kept aligned for shared names | [R], [G] |
| Dispatch | `dispatchRepoAutomationTool`, `listRepoAutomationTools`, `isRepoAutomationToolName`, `toMcpToolResult`, `toFailureToolResult`, `RepoAutomationMcpToolResult` in `src/mcp-tools.ts` | `switch` with one literal `case` per tool; errors become `ok: false` with `summary` = message and optional `stderr_excerpt` | [R] |
| Server | `createRepoAutomationMcpServer`, `toCallToolResult` in `src/mcp-server.ts` | `isError: !result.ok`; `structuredContent` = result | [R] |
| PoshQC handlers | `handleRunPoshQCFormat` ... `handleRunPoshQCSuite` in `src/mcp-handlers/poshqc-handlers.ts`; input resolver `resolveRunPoshQCSuiteToolInput` in `src/mcp-tool-inputs.ts` | Delegate to `service.runPoshQC*` | [R] |
| PoshQC executor | `runPoshQcWorkflow` (private) in `src/repo-automation-service.ts` -> `executeScriptServiceCall` in `src/repo-automation-execute-script.ts` -> `executeBundledScriptFromExtensionRoot` / `runCommandWithOutput` in `src/command-runtime.ts` | Resolves the script under the installed extension root; rejects on non-zero exit with `CommandExecutionError`; the returned record carries only `tool`, `workspaceRoot`, `summary`, `artifacts` (no stdout, no exit code) | [R]; matches the execution-environment brief |
| Runtime resolution | `detectRuntime` in `src/runtime-detection.ts` | `"powershell"` prefers `pwsh` then falls back to Windows `powershell`, prefix `-NoLogo -NoProfile -ExecutionPolicy Bypass -File` | [R] |
| Tool that captures stdout and exit code | `invokeDiscoveryRuntime` in `src/discovery-runtime.ts` with `DiscoveryProcessLauncher` / `DiscoveryProcessOutcome` (`exitCode`, `stdout`, `stderr`, `launchError`) and `createNodeProcessLauncher()` (async `child_process.spawn`, `shell: false`, `windowsHide: true`, no output size cap); result parsing in `parseDiscoveryResult` / `toExecutionResult` in `src/discovery-result.ts` | Captures all output and the exit code; injected through `DiscoveryRuntimeDependencies.launcher`; parser checks envelope fields, `ok`/`exit_code` agreement and process-exit agreement | [R] |
| Second runner seam | `CommandRunner` / `SubprocessRunner` in `src/lib/subprocess-runner.ts`, injected as `RepoAutomationServiceOptions.runner` | `spawnSync`; a spawn failure maps to `code: 1` (indistinguishable from docs exit 1); Node `spawnSync` default `maxBuffer` applies | [R] |
| Non-ok discovery results | `toExecutionResult` throws `DiscoveryOperationError`; `toFailureToolResult` keeps only `error.message` | Findings of a failed discovery call are not returned as structured data | [R] |

Recommended process seam for docs: reuse `DiscoveryProcessLauncher` and `createNodeProcessLauncher`
by import from `src/discovery-runtime.ts` (no edit to that file). It already captures stdout, stderr,
exit code and launch failure asynchronously and is test-injectable without temporary files.
`SubprocessRunner` is rejected for docs because a missing `pwsh` would read as exit 1 and because a
large inventory snapshot can exceed the synchronous buffer.

## 2. Script location

- Bundled-resource pattern: PoshQC and the bundled `.ps1` workflows resolve from the installed
  extension root (`resolveBundledScriptPath` and the comment in
  `executeBundledScriptFromExtensionRoot`: "Resolve scripts relative to the installed extension so
  commands always use the bundled resources rather than depending on workspace copies"). [R]
- Workspace pattern: no existing MCP tool runs a workspace script. The VS Code command
  `newClaudeWorktreeSession` runs a worktree-relative `.claude/hooks/pre-claude-session.ps1` guarded
  by `Test-Path` (`src/claude-worktree-session.ts`, setting
  `drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath`). [R]
- MCP server root: `resolveExtensionRoot()` in `src/mcp-server.ts` is the package root; for the npm
  package `packages/mcp-server/prepack.cjs` copies `extensions/drm-copilot/resources/` (minus `.py`
  and the root `scripts/` subtree) into `packages/mcp-server/resources/`, so a bundled copy would be
  present at `resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1`. [R]

**Recommendation: run the workspace copy** at `<workspace_root>/.claude/lib/docs/Invoke-DocsCommand.ps1`.

- It is the text both the epic (`### 900007`) and 1020 (`## Decisions Later Children Must Honor`)
  name: a workspace-relative script with the workspace root as working directory.
- It is the same code a destination's skills, hooks and CI run (A6), so an MCP verdict and a CI
  verdict over the same artifacts cannot diverge by version. The bundled copy could differ from the
  destination's pushed-down copy until the next push-down.
- Failure behavior, all before any process starts, surfaced as `ok: false` through
  `toFailureToolResult` with a code-prefixed message:
  - `workspace_root` missing or not absolute (`normalizeWorkspaceRoot` plus `isAbsolutePathLike` from
    `src/workflow-command-arguments.ts`): `DOCS_WORKSPACE_ROOT_INVALID`.
  - Script absent (checked through the service's injected `FileSystem.isFile`, `src/lib/file-system.ts`):
    `DOCS_ENTRY_SCRIPT_MISSING`, next action "run push_down_claude_customizations for this workspace".
  - `pwsh` not on PATH (resolved with the pure, injectable `resolveExecutableOnPath` from
    `src/lib/executable-resolver.ts`, name `pwsh`; no fallback to Windows `powershell`, because 1020
    requires PowerShell 7.4): `DOCS_PWSH_UNAVAILABLE`. A launch error reported by the launcher maps
    to the same code.
  - `pwsh` 7.0-7.3 is not detected in TypeScript: the entry exits 3 with `DOCS_RUNTIME_UNSUPPORTED`
    and the envelope is returned normally.
- Consequence for this repository: through MCP the docs logic is the workspace (branch) copy while
  the TypeScript wrapper is the installed extension. See question 8 for the brief.

## 3. Bundling and registration surface

- `packages/mcp-server/esbuild-mcp-server.cjs` bundles the single entry
  `../../extensions/drm-copilot/src/mcp-server.ts` (vscode shimmed); there is no generated tool list.
  `extensions/drm-copilot/package.json` contributes only `mcpServerDefinitionProviders`
  (`drmCopilotMcpProvider`) and VS Code commands; MCP tools are not listed there. `listMcpTools`
  (`src/repo-automation-command-registration-admin.ts`) reads `listRepoAutomationTools()`. [R]
- Edits outside `extensions/drm-copilot/src/` that are required: the two existing tests below,
  `extensions/drm-copilot/jest.config.cjs` coverage registration, and documentation
  (`extensions/drm-copilot/README.md`, `extensions/drm-copilot/CHANGELOG.md`). No manifest,
  `package.json` contribution, `packages/mcp-server` file, `.claude/settings.json`, `.codex/config.toml`
  or agent file must change. [R]/[G]
- `packages/mcp-server/package.json` version and the pinned `@danmoisan/drm-copilot-mcp@1.1.23` in
  `.codex/config.toml` are release mechanics, out of scope. [R]

## 4. Every test or contract that enumerates the MCP tool set

Search scope: `extensions/drm-copilot/test/**`, `tests/**`, `scripts/**`, `.claude/settings.json`,
`.claude/agents/**`, `.codex/config.toml`, both READMEs, `docs/engineering/**`. Patterns:
`REPO_AUTOMATION_TOOLS`, `REPO_AUTOMATION_TOOL_DEFINITIONS`, `listRepoAutomationTools`,
`isRepoAutomationToolName`, `toolDefinitions`, `render_subagent_tree`, `run_poshqc_suite`,
`run_poshqc_analyze_autofix`, `run_discovery_report`, `discovery_capability_sentinel`,
`mcp__drm-copilot__`, `enabled_tools`. [G]

| # | Path | Test name | Assertion kind | Disposition |
|---|---|---|---|---|
| 1 | `extensions/drm-copilot/test/mcp-server.test.ts` | `registers the semantic repo automation tools` | Exact ordered list (43 literals) from `client.listTools()` | **Update**: insert the six names after `render_subagent_tree`. File is 494 lines; move the expected list into `test/mcp-server-test-service.ts` as an exported constant to keep headroom below the 500-line guidance |
| 2 | `extensions/drm-copilot/test/mcp-discovery-authority-tool-definitions.test.ts` | `advertises all nineteen discovery tools in union order` | `slice(indexOf("validate_discovery_artifacts"))` equality, `DISCOVERY_TOOL_DEFINITIONS` length 19, `REPO_AUTOMATION_TOOLS` length 43 | **Update** the count 43 to 49 (see `## Numeric Derivation Evidence`); slice assertion unchanged only if docs names precede the discovery block |
| 3 | `extensions/drm-copilot/test/mcp-discovery-tool-definitions.test.ts` | `keeps the definition list aligned with the widened union order` | Definitions equal `[...REPO_AUTOMATION_TOOLS]` (derived); `slice(-19)` equals the discovery names | **Unchanged** if the docs block is inserted before the discovery block; appending at the end would fail it |
| 4 | `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` | `defines one schema entry for every advertised repo automation tool`; `declares the same input-schema properties and required arrays on both tool-definition surfaces`; `lists workspace_root in inputSchema.required for every repo automation tool (all 28)` | Derived equality; shared-name property/required equality; derived length plus `required` contains `workspace_root` | **Unchanged**; constrains design: each docs definition requires `workspace_root`, and a docs definition present on both surfaces must be identical (spread one constant into both) |
| 5 | `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` | `exposes one shared tool set to the standalone server and the extension provider` | Derived equality, and `src/mcp-tools.ts` text contains `case "<name>":` for every name | **Unchanged**; constrains design: six literal `case` labels are required (a grouped fall-through is sufficient; a pre-switch `if` is not) |
| 6 | `extensions/drm-copilot/test/extension.list-mcp-tools.test.ts` | `shows the MCP tool list in a Quick Pick and logs it to the output channel` | `arrayContaining` membership | **Unchanged** |
| 7 | `extensions/drm-copilot/test/repo-automation-render-subagent-tree.test.ts` | `listRepoAutomationTools advertisement` | Membership (`find`) | **Unchanged** |
| 8 | `extensions/drm-copilot/test/mcp-server-test-service.ts` (`createMockService`), `test/mcp-tools.workspace-root.test.ts` and the other suites typed `jest.Mocked<RepoAutomationService>` (28 files reference `RepoAutomationService` [G count]) | n/a (fixtures) | Object literals list every required service method | **Unchanged** if `runDocsCommand` is optional; a required method would break every literal at type-check. `mcp-server-test-service.ts` gains an optional `runDocsCommand` mock for the new server-level tests |
| 9 | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (`EXPECTED_DRM_COPILOT_TOOLS`, `assert_full_drm_copilot_transport`) | assertions in that helper | Tuple equality of `.codex/config.toml` `enabled_tools` (20 curated names; no discovery tool) | **Unchanged**; `.codex/config.toml` and its bundle copy are not edited (Codex reach is epic OQ-2) |
| 10 | `tests/scripts/claude-runtime/claude-settings.Tests.ps1` | `requires .claude/settings.json to use the active PowerShell MCP contract`; discovery handler test | Regex membership; discovery hook matcher `mcp__.*` | **Unchanged**; `.claude/settings.json` allow list is a curated subset (no discovery tools) and is not edited |
| 11 | `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | rule, agent and architecture-doc tests | Regex membership of PoshQC names | **Unchanged** |
| 12 | `.claude/lib/discovery-validation/DiscoveryToolRouting.psm1` (`$script:ControlledToolOperations`), `src/discovery-authorization-record.ts` (`CONTROLLED_TOOLS`); tests `DiscoveryToolRouting.Tests.ps1`, `DiscoveryAuthorization.Tests.ps1`, `mcp-discovery-authorization-gate.test.ts` | various | Controlled discovery tools only | **Unchanged**; docs tools are not controlled. A root call of a non-controlled `drm-copilot` tool is allowed (`DiscoveryAuthorization.psm1`, code `ROOT`, "ordinary gates apply") [R] |
| 13 | `src/lib/validate/plan-gate-observability.ts`, `scripts/dev_tools/plan_gate_observability.py` and their tests | G7 PoshQC marker table | PoshQC tool suffixes only | **Unchanged** (docs tools return output, so no output-free rule applies) |
| 14 | `README.md` `### MCP tool surface`; `extensions/drm-copilot/README.md` `### Exposed MCP Tools`, `### MCP Input Summary` | none (no test pins them [G `Exposed MCP Tools|MCP tool surface|MCP Input Summary` over test trees: no README pin]) | Hand-maintained lists that already omit the discovery tools | **Update the extension README** (documentation task); root README optional |

## 5. Mutation classification

- No definition carries `annotations` (`readOnlyHint`, `destructiveHint`): [G] over
  `extensions/drm-copilot/src` finds none, and `ToolDefinition` declares no such field. No read-only
  or mutating list exists in `repo-automation-tool-names.ts` or elsewhere; the only classification
  tables are the discovery `CONTROLLED_TOOLS` / `ROOT_ONLY_OPERATIONS`. [R]/[G]
- MCP `Tool.annotations` is an optional protocol field; clients must treat annotations as untrusted
  hints (MCP specification 2025-06-18, `server/tools`, `### Tool`). [W]
- Recommendation:
  1. Add an optional `annotations?: { readonly readOnlyHint?: boolean; readonly destructiveHint?: boolean; readonly idempotentHint?: boolean; readonly openWorldHint?: boolean }`
     to `ToolDefinition` in both definition files (non-breaking).
  2. Set `readOnlyHint: true` on `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
     `generate_docs_reference` and `validate_docs_artifacts`; `readOnlyHint: false`,
     `destructiveHint: true` (`remove-entry` and binding removal delete records) on
     `update_docs_ledger`. `openWorldHint: false` on all six.
  3. Export `DOCS_MUTATING_TOOLS = ["update_docs_ledger"] as const` from
     `src/mcp-docs-tool-definitions.ts`; a Jest test asserts that it equals the set of docs
     definitions whose `readOnlyHint` is not `true`, and that only `update_docs_ledger` accepts a
     `write` field.
  4. Enforcement is structural, not the hint: `validate_docs_artifacts` has no write-receipt field
     and its argv builder never emits `-WriteReceipt`; `run_docs_inventory` has no output-file field;
     `generate_docs_reference` has no write field (see OQ-A). With `additionalProperties: false` and
     a resolver that rejects unknown keys, a caller cannot request persistence through those tools.
- Whether the SDK's `Tool` type in the installed `@modelcontextprotocol/sdk` (`^1.31.0`) includes
  `annotations` could not be read: [G] found no `node_modules/@modelcontextprotocol/sdk` in this
  worktree. The definitions are returned through `ListToolsRequestSchema`'s handler as plain objects;
  confirm with the orchestrator (see facts list).

## 6. Per-tool subcommand and argument mapping

Common rules for every tool:

- `workspace_root` (required, absolute) -> process working directory; not passed as an option.
- `profile` (optional relative path) -> `-Profile <path>`; default resolved by PowerShell
  (`docs/documentation-estate/docs-profile.json`, `Get-DocsDefaultProfilePath`).
- `-Json` is always passed; text output is never requested.
- Reserved PowerShell names `Command`, `Json`, `Help`, `RepositoryRoot` are never emitted as options
  (1020 `#### Dispatch table`).
- Rejected before any process starts: unknown keys; wrong types; enum values outside the list;
  strings failing the grammar below; empty strings; and **any string value whose first character is
  `-`**. Reason: values reach `ValueFromRemainingArguments` as separate tokens through `pwsh -File`,
  so a value such as `-Write` in a free-text field could be read by `ConvertFrom-DocsCommandArgument`
  as an option; TypeScript cannot rely on PowerShell to disambiguate. This is a cross-feature item for
  1020 (see OQ-C).
- Grammars, mirrored from docs common and pinned by a parity test against the committed schema text
  (`schemas/docs/v1/common.schema.json` once present; the definitions are copied from
  `schemas/discovery/v2/common.schema.json`, which exists now [R]):
  - relative path (`Test-DocsRelativePath` equivalent): the docs-common `relative-path` pattern.
  - path or glob: the `path-or-glob` pattern.
  - identifier: `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`.
  - full revision (`Test-DocsFullRevision`): `^(?:[0-9a-f]{40}|[0-9a-f]{64})$`.
  - element id: `^(?:cli-command|cli-option|http-route|config-key|public-symbol|architecture-component)-[0-9a-f]{64}$` (1020 `#### Element identifiers`, `<kind>-<sha256>`).
  - page reference for `update-ledger`: relative path, optionally `#<anchor>` with a non-empty anchor.

PowerShell option names are **provisional**: none of 1021-1024 has committed PowerShell option names
(see the disagreement table). The names below are the PascalCase forms of the withdrawn CLI flags,
which is the convention 1020's `Option` map uses. Keep them in one declarative table per tool so a
rename is a one-line change.

| Tool | Subcommand | Tool input (type; required) | PowerShell option (kind) |
|---|---|---|---|
| `run_docs_check` | `check` | `profile` (relative path); `root` (relative path); `entry_pages` (array of relative paths); `exclude` (array of path-or-glob) | `-Profile` (value), `-Root` (value), `-Entry` (multi), `-Exclude` (multi) |
| `run_docs_inventory` | `inventory` | `profile`; `analyzers` (array of identifiers); `revision` (full revision) | `-Profile`, `-Analyzer` (multi), `-Revision` (value). No `-Output` (OQ-A) |
| `run_docs_coverage` | `coverage` | `profile` | `-Profile` |
| `update_docs_ledger` | `update-ledger` | `operation` (enum `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`, `sync-refs`; required); `element` (element id); `disposition` (enum `documented`, `excluded`, `deferred`); `pages` (array of page references); `rationale`, `target`, `claim` (text); `owner` (identifier); `dimension` (enum `exists`, `accurate`, `example_present`, `owner_assigned`, `diataxis_mode`); `state` (enum `pass`, `fail`, `not-assessed`, `not-applicable`); `actor_kind` (enum `human`, `agent`, `tool`; required); `actor_id` (identifier; required); `write` (boolean, default false); `profile` | `-Operation`, `-Element`, `-Disposition`, `-Page` (multi), `-Rationale`, `-Owner`, `-Target`, `-Dimension`, `-State`, `-Claim`, `-ActorKind`, `-ActorId`, `-Write` (switch, only when `write` is true), `-Profile` |
| `generate_docs_reference` | `generate-reference` | `profile`; `snapshot` (relative path); `output_dir` (relative path) | `-Profile`, `-Snapshot`, `-OutputDir`. No `-Write` (OQ-A) |
| `validate_docs_artifacts` | `validate` | `mode` (enum `profile`, `ledger`, `matrix`, `docs-complete`; required); `revision` (full revision; required); `profile` | `-Mode`, `-Revision`, `-Profile`. Never `-WriteReceipt` |

Per-operation rules for `update_docs_ledger` (from the 1023 committed `### dev.docs.update-ledger`
table, language-independent): required and permitted fields per operation are held as a declarative
table in `src/mcp-tool-inputs-docs.ts` and checked before launch (`set-disposition`: requires
`element`, `disposition`, permits `pages` (repeatable), `rationale`, `owner`, `target`;
`remove-entry`: `element`; `pin`: `element`, exactly one `pages` entry without anchor, permits
`claim`; `unpin`: `element`, one page without anchor; `set-dimension`: `element`, one page without
anchor, `dimension`, `state`, permits `rationale`; `sync-refs`: none). PowerShell remains
authoritative (exit 2 with `DOCS_CLI_ARGUMENTS` for anything TypeScript accepts and PowerShell
rejects). Missing companion values (for example `excluded` without `rationale`) are not usage errors
in 1023; they are ledger findings with exit 1, so TypeScript must not reject them.

### Disagreements between upstream folders and the epic

| Subcommand | Epic (authority) | Upstream committed text | Disagreement |
|---|---|---|---|
| `check` (1021) | `Invoke-DocsCommand.ps1 -Command check`, exit 0/1/2/3, `-Json` envelope | `spec.md` v0.2: Python package `dev.docs.check [--root DIR] [--entry PATH ...] [--exclude GLOB ...] [--format text|json]`; exit 0/1/2 only; JSON report `{findings, report_version, summary, tool}`; findings carry `line`, `path`, `related_path` | Entry point, exit 3 absent, report shape is not the envelope, finding keys differ from the docs-common `finding`. [R]; [G] no `Invoke-DocsCommand` in the 1021 folder |
| `inventory` (1022) | `-Command inventory` | `dev.docs.inventory [--profile] [--analyzer]... [--revision] [--output]`; exit 0/1/2/3; profile JSON or YAML | Entry point; YAML profile (1020 now rejects YAML); `--output` writes a file (conflicts with the strict mutating rule, OQ-A). [R] |
| `coverage`, `update-ledger`, `validate` (1023) | `-Command coverage/update-ledger/validate`; `update-ledger` dry run unless write switch; `validate` mode plus required revision; receipt not persisted by 900007 | `dev.docs.coverage`, `dev.docs.update-ledger` (`--operation` ... `--write`), `dev.docs.validate` (`--mode`, `--revision`, `--write-receipt`), `--format json` envelope `{command, ok, exit_code, findings, result}` with `command` = `dev.docs.<name>` | Entry point; envelope `command` value is the console-script name, not the subcommand name (1020 requires the subcommand name); option vocabulary otherwise agrees with the epic. [R] |
| `generate-reference` (1024) | `-Command generate-reference`, dry run default, write switch | `dev.docs.generate-reference [--profile] [--snapshot] [--output-dir] [--write] [--format]`; JSON report `{findings, mode, ok, pages, report_version, summary, tool, uncertain_paths, unrendered}`; exit 2 and some exit 3 cases print nothing on stdout | Entry point; report is not the envelope; empty stdout on exit 2/3 conflicts with 1020 (exactly one envelope on every exit). [R] |
| Dispatch anchors (1020) | Owners 1022, 1024, 1034 | 1020 `#### Dispatch table` anchors `# --- 900003: inventory ---`, `# --- 900006: generate-reference ---`, `# --- 900008: surface-delta ---` | Placeholder numbers; real issues are 1022, 1024, 1034. Cosmetic for 900007 (it does not read anchors). [R] |
| Envelope schema (1020) | D5 and the amendment add `docs-command-envelope.schema.json` | 1020 spec and the epic's own 1020-contracts bullet say no schema file | Resolved above: the amendment governs. [R] |
| Mutating tools | `update_docs_ledger` is the only mutating tool | 1023 narrows "mutating" to ledger, matrix and pins; 1022 `--output` and 1024 `--write` write files | Owner question OQ-A. [R] |

## 7. Jest configuration and file-size headroom

- `extensions/drm-copilot/jest.config.cjs`: `testMatch: ["**/test/**/*.test.ts"]`, `ts-jest`
  with `tsconfig.jest.json`, `coverageProvider: "v8"`, `collectCoverageFrom: ["src/**/*.ts",
  "!src/**/*.d.ts"]`, `coverageThreshold` per-file entries only (no `global` key), merged with
  `./jest.discovery-coverage.json` (issue #980 precedent for keeping the file below the 700-line
  advisory). Tests run with `node run-jest.cjs` (`package.json` scripts `test`, `test:coverage`). [R]
- Existing entries already gate `./src/mcp-tools.ts`, `./src/repo-automation-tool-names.ts`,
  `./src/mcp-repo-automation-tool-definitions.ts`, `./src/mcp-tool-definitions.ts`,
  `./src/repo-automation-service.ts` (85/75 each); `./src/repo-automation-service-contract.ts` is
  deliberately ungated as interface-only. [R]
- Each new production file needs its own entry (85 lines / 75 branches). Recommendation: put the new
  entries in a new sibling JSON map `extensions/drm-copilot/jest.docs-coverage.json` merged with one
  spread line in `jest.config.cjs`, following `jest.discovery-coverage.json`. Direct entries would
  take `jest.config.cjs` from 535 to about 555 lines (still below 700; acceptable fallback).
- `extensions/drm-copilot` is T3 in `quality-tiers.yml` (no property-test or mutation obligation). [R]
- Logical line counts ([G] `^` count, which equals logical lines for LF-terminated files) and
  projected growth; `config/file-size-baseline.json` has no `extensions/drm-copilot` entry [G]:

| File | Now | Projected | Tier after change |
|---|---|---|---|
| `src/mcp-tools.ts` | 461 | about 475 (6 case labels, 1 handler call, imports, optional `docs` field on `RepoAutomationMcpToolResult`) | below 500 |
| `src/repo-automation-tool-names.ts` | 47 | 53 | below 500 |
| `src/mcp-repo-automation-tool-definitions.ts` | 425 | about 433 (import, spread, `annotations` type) | below 500 |
| `src/mcp-tool-definitions.ts` | 462 | about 470 | below 500 |
| `src/repo-automation-service.ts` | 450 | about 465 (method, option field) | below 500 |
| `src/repo-automation-service-contract.ts` | 298 | about 315 | below 500 |
| `jest.config.cjs` | 535 | 536 with the sibling JSON | 500-699 guidance band (unchanged band) |
| `test/mcp-server.test.ts` | 494 | 494 or less if the list moves to the test-service module | below 500 |
| `test/mcp-server-test-service.ts` | 165 | about 230 | below 500 |
| `test/mcp-discovery-authority-tool-definitions.test.ts` | 198 | 198 | below 500 |

New files are expected well below 500 each: definitions (about 250), inputs (about 300), handler
(about 120), executor (about 150), envelope parser (about 120).

## 8. Execution-environment brief and extension documentation

- `.claude/skills/execution-environment/SKILL.md` `## MCP Surfaces Run the Installed Extension`
  states "Every `mcp__drm-copilot__*` tool runs the installed extension, not the branch." [R] With
  the recommended workspace-script design the docs tools run the installed TypeScript wrapper over the
  workspace (branch) copy of `.claude/lib/docs/`. The sentence stays literally true but becomes
  misleading for docs tools. Recommendation: the plan carries a brief-update task adding one bullet
  ("The docs tools ... invoke the workspace's `.claude/lib/docs/Invoke-DocsCommand.ps1`, so branch
  edits to the docs lib apply through MCP immediately; the wrapper itself is the installed
  extension") in all six byte-identical copies: `.claude/`, `.agents/`, `.github/` and the three
  bundle copies under `extensions/drm-copilot/resources/` (`claude-customizations/.claude/...`,
  `codex-and-agents-customizations/.agents/...`, `customizations/.github/...`) [G]. No other brief
  fact changes: no CI job, required context, tool route, batch-budget rule or PoshQC statement is
  altered (`RepoAutomationExecutionResult` keeps no exit-code field; the docs envelope travels in a
  separate MCP result field). If the bundled-script alternative were chosen instead, the brief would
  need no change.
- `extensions/drm-copilot/README.md` lists tools in `### Exposed MCP Tools` and
  `### MCP Input Summary` and describes `### MCP Result Shape`; add the six tools, their inputs, the
  `docs` result field, the PowerShell 7.4 and pushed-down-lib prerequisite. `CHANGELOG.md` has an
  `## [Unreleased]` section; add an `### Added` entry. Root `README.md` `### MCP tool surface` is
  optional (it already omits the discovery tools). None is pinned by a test. [R]/[G]

## 9. Artifact classification

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
| `extensions/drm-copilot/src/docs-command-envelope.ts` (refinement: pure envelope parser) | create | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/mcp-tools.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/repo-automation-tool-names.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/src/repo-automation-service.ts` | edit | MCP tool | TypeScript | E1, R2 |
| `extensions/drm-copilot/test/mcp-docs-tool-definitions.test.ts`, `test/mcp-tool-inputs-docs.test.ts`, `test/mcp-handlers/docs-handlers.test.ts`, `test/repo-automation-execute-docs.test.ts`, `test/docs-command-envelope.test.ts`, `test/mcp-server.docs.test.ts` | create | test | TypeScript (Jest) | E2 |
| `extensions/drm-copilot/test/mcp-server.test.ts`, `test/mcp-discovery-authority-tool-definitions.test.ts`, `test/mcp-server-test-service.ts` | edit | test | TypeScript (Jest) | E2 |
| `extensions/drm-copilot/jest.docs-coverage.json` | create | schema/config/data | JSON | E3 |
| `extensions/drm-copilot/jest.config.cjs` (one merge line) | edit | schema/config/data (existing test-tool configuration) | CommonJS JavaScript | Existing file; edit is data registration required by the coverage policy (precedent `jest.discovery-coverage.json`). Not new logic; recorded for the owner's visibility, not an owner question |
| `extensions/drm-copilot/README.md`, `extensions/drm-copilot/CHANGELOG.md` | edit | documentation | Markdown | DOC |
| `execution-environment/SKILL.md` (six copies listed in question 8) | edit | documentation (skill text) | Markdown | DOC; mirror parity required |
| `docs/features/active/2026-10-30-docs-mcp-tools-1036/**` | create/edit | documentation | Markdown | DOC |

No artifact requires a language outside the rule; no owner question arises from classification.

## 10. Reachability

| Tool | Subcommand | Owner | Reachable from a skill through `Invoke-DocsCommand.ps1 -Command <name>` |
|---|---|---|---|
| `run_docs_check` | `check` | 1021 | yes |
| `run_docs_inventory` | `inventory` | 1022 | yes |
| `run_docs_coverage` | `coverage` | 1023 | yes |
| `update_docs_ledger` | `update-ledger` | 1023 | yes |
| `generate_docs_reference` | `generate-reference` | 1024 | yes |
| `validate_docs_artifacts` | `validate` | 1023 | yes |

TypeScript adds no operation. Its only checks duplicate published grammars (relative path, path or
glob, identifier, revision, element id), enums and the `update-ledger` per-operation field table;
each duplicate is pinned by a parity or fixture test, and PowerShell remains authoritative. Not
exposed through MCP (by design, per the epic's six names): `init`, `validate-profile` (the `validate`
mode `profile` covers profile validation), `surface-delta`.

## Recommended Design

State and flow (per call):

1. `dispatchRepoAutomationTool` has six literal `case` labels that fall through to
   `return handleDocsTool(toolName, rawInput, service);` (precedent: the grouped handoff cases).
2. `handleDocsTool` (`src/mcp-handlers/docs-handlers.ts`) calls the tool's resolver
   (`src/mcp-tool-inputs-docs.ts`), which returns `{ workspaceRoot, subcommand, options }` where
   `options` is an ordered list of `[PascalName, kind, value]` built from the declarative table; any
   violation throws before step 3.
3. If `service.runDocsCommand` is undefined, throw `DOCS_RUNTIME_UNAVAILABLE` (precedent:
   `admitControlledToolCall` refusing when an optional seam is absent).
4. `DefaultRepoAutomationService.runDocsCommand` delegates to `invokeDocsCommand(request, deps)` in
   `src/repo-automation-execute-docs.ts`, with `deps = { fileSystem: this.fileSystem, launcher:
   options.docs?.launcher ?? createNodeProcessLauncher(), resolvePwsh: options.docs?.resolvePwsh ??
   <resolveExecutableOnPath bound to process env> }`. It checks the absolute root, the script file
   and `pwsh`, then launches `[pwshPath, "-NoProfile", "-File", ".claude/lib/docs/Invoke-DocsCommand.ps1",
   "-Command", subcommand, "-Json", ...options]` with `cwd = workspaceRoot` and empty stdin.
5. `parseDocsEnvelope(stdout, { exitCode, stderr, command })` (`src/docs-command-envelope.ts`) returns
   the typed envelope or throws `DOCS_ENVELOPE_EMPTY`, `DOCS_ENVELOPE_MALFORMED`,
   `DOCS_ENVELOPE_EXIT_MISMATCH` or `DOCS_ENVELOPE_COMMAND_MISMATCH` (pattern of `parseDiscoveryResult`).
6. The handler returns `RepoAutomationMcpToolResult` directly: `ok = envelope.ok`, `tool`,
   `workspace_root`, `summary` = `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>` (counted
   from findings, the 1020 summary-line shape), `docs` = the envelope, and `stderr_excerpt` (first
   eight non-empty stderr lines) when `exit_code` is 3. Exit 1-3 are returned, not thrown, so
   findings reach the caller; `isError` is `true` for them through `toCallToolResult`.

Ordering rules: validation before any filesystem or process call; script check before `pwsh`
resolution; one process per call; no retries; no writes by TypeScript.

### Rejected alternatives

- Run the bundled script from the extension resources: always available, but can disagree with the
  destination's pushed-down lib version and contradicts the epic and 1020 wording.
- Reuse `executeScriptServiceCall` / `runCommandWithOutput`: discards stdout and rejects on non-zero
  exit, so findings and exit codes would be lost.
- Reuse `SubprocessRunner`: synchronous, buffer-limited, and maps a launch failure to exit code 1.
- A required `runDocsCommand` method: breaks every hand-written `jest.Mocked<RepoAutomationService>`
  literal across the suite.
- Append the docs names after the discovery block: breaks `slice(-19)` in
  `mcp-discovery-tool-definitions.test.ts` and the slice equality in
  `mcp-discovery-authority-tool-definitions.test.ts`.

## Behavior Semantics

- Success: process exit code equals envelope `exit_code`; result `ok` true only for exit 0.
- Findings (exit 1), usage error (exit 2, exactly one `DOCS_CLI_ARGUMENTS`, `result` null), internal
  error (exit 3, exactly one finding, `result` null, one stderr line): returned as structured `ok:
  false` results with the full envelope. TypeScript does not enforce the per-exit finding counts
  (that is 1020's contract, pinned by Pester).
- Transport failure (no process, empty or malformed stdout, exit disagreement, command
  disagreement): `ok: false` through `toFailureToolResult`, message prefixed by the host code; no
  envelope.
- Edge cases: `write` omitted on `update_docs_ledger` means dry run (no `-Write`); empty arrays for
  multi options emit nothing; duplicate `pages` entries are rejected (1023 treats a repeated page as
  a usage error); a value beginning with `-` is rejected; non-ASCII text in values is passed
  unchanged (see Risks).

## Testing Implications

All tests are Jest under `extensions/drm-copilot/test/`, run with `node run-jest.cjs`; no temporary
files; no real process.

- `mcp-tool-inputs-docs.test.ts`: per tool, positive mapping to the exact ordered option list;
  every enum boundary; every grammar (accept and reject, including `..`, leading `/`, backslash,
  drive letter, control character); unknown key; leading `-` value; `update-ledger` per-operation
  table (each operation's missing required field and each forbidden field); `write: true` emits
  `-Write` only for `update_docs_ledger`.
- Grammar parity test: reads the committed docs-common schema (discovery v2 common until docs common
  exists) and asserts the TypeScript pattern strings equal the schema `pattern` values.
- `docs-command-envelope.test.ts`: valid envelopes for exit 0-3; each malformed variant (missing key,
  extra key, wrong type, `ok`/`exit_code` disagreement, process-exit disagreement, command mismatch,
  empty stdout, two documents, trailing non-JSON); finding key-set violations; plus the schema-file
  contract test described under `### Envelope schema`.
- `repo-automation-execute-docs.test.ts`: fake launcher records argv, cwd and call count; in-memory
  `FileSystem`; `resolvePwsh` stub. Cases: script missing (launcher not called), `pwsh` missing
  (launcher not called), launch error, exact argv (`-NoProfile -File <script> -Command <name> -Json`
  first), `cwd` equals `workspace_root`, relative `workspace_root` rejected.
- `docs-handlers.test.ts`: result mapping for exit 0-3 (`ok`, `summary`, `docs`, `stderr_excerpt`),
  absent `runDocsCommand` seam, resolver failure leaves the service mock uncalled.
- `mcp-docs-tool-definitions.test.ts`: six names in order, `additionalProperties: false`,
  `workspace_root` required, enums equal the resolver constants, no `write`/`write_receipt`/`output`
  field outside `update_docs_ledger`, annotations as specified, `DOCS_MUTATING_TOOLS`.
- `mcp-server.docs.test.ts`: through `InMemoryTransport` with `createMockService()` programmed with
  `runDocsCommand`: listing includes the six; a call returns `structuredContent.docs` and `isError`
  per exit code; invalid input returns `isError: true` and `runDocsCommand` is not called.
- `repo-automation-service` test addition: `runDocsCommand` uses the injected `docs` deps and
  `fileSystem` (keeps the 85/75 gate on `repo-automation-service.ts`).
- Isolation evidence: seeded shuffled run `node run-jest.cjs --randomize --seed=<n>`.
- Coverage: `jest.docs-coverage.json` entries for the five new production files; existing entries
  for edited files remain.

## Numeric Derivation Evidence

### N1 - Size of `REPO_AUTOMATION_TOOLS` before and after this feature (used by the test-count update 43 -> 49)

- Complete Family: string literals in the `REPO_AUTOMATION_TOOLS` tuple in
  `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
- Exhaustive Search Scope: the whole file (47 logical lines), read end to end; the tuple is the only
  array in the file.
- Inclusion Rules: every quoted element of the tuple.
- Exclusion Rules: the type alias line; no other symbol.
- Primary Search Strategy or Query Expression: Read of the file, enumerating tuple elements in order.
- Primary Member Set: `collect_commit_context`, `collect_pr_context`, `run_codex_native_converter`,
  `push_down_copilot_customizations`, `push_down_codex_and_agents_customizations`,
  `push_down_claude_customizations`, `new_potential_bug_entry`, `new_potential_entry`,
  `link_parent_child`, `potential_to_issue`, `new_active_feature_folder`, `run_poshqc_format`,
  `run_poshqc_analyze`, `run_poshqc_test`, `run_poshqc_analyze_autofix`, `run_poshqc_suite`,
  `resolve_policy_audit_template_asset`, `resolve_execute_hard_lock_prompt`,
  `resolve_atomic_plan_prompt`, `validate_orchestration_artifacts`, `resolve_orchestration_topology`,
  `resolve_provider_routing`, `transition_prepared_orchestration`, `render_subagent_tree`,
  `validate_discovery_artifacts`, `run_discovery_init`, `run_discovery_repo_inventory`,
  `run_discovery_dotnet_analyzer`, `run_discovery_vsto_analyzer`, `run_discovery_scenario_generation`,
  `run_discovery_report`, `create_discovery_artifact`, `update_discovery_artifact`,
  `link_discovery_evidence`, `configure_discovery_workspace`, `transfer_discovery_snapshot`,
  `import_discovery_inventory`, `migrate_discovery_artifacts`, `run_discovery_doctor`,
  `read_discovery_source`, `prepare_discovery_agent`, `finalize_discovery_agent`,
  `discovery_capability_sentinel`.
- Primary Count: 43.
- Cross-check Search Strategy or Query Expression: independent enumeration of the hand-written
  expected list in `extensions/drm-copilot/test/mcp-server.test.ts`, test
  `registers the semantic repo automation tools` (`toEqual([...])` literal array); corroborated by the
  existing literal `expect(REPO_AUTOMATION_TOOLS).toHaveLength(43)` in
  `mcp-discovery-authority-tool-definitions.test.ts`.
- Cross-check Member Set: the same 43 names, in the same order (the test list was enumerated element
  by element from the test file, not derived from the source tuple).
- Cross-check Count: 43.
- Member-set Comparison: the normalized sets are equal (43 = 43, no name present in one and absent
  in the other, identical order). The six docs names are disjoint from both sets (none occurs in
  either list). After the change the family is 43 + 6 = 49 members.

### N2 - The six docs tools

- Complete Family: MCP tool names owned by 900007.
- Exhaustive Search Scope: epic `### Naming contract (fixed for all children)` and `### 900007 -
  docs-mcp-tools`; 1036 `spec.md` `## Behavior`; 1036 `issue.md` `## Proposed Behavior`.
- Inclusion Rules: backticked tool names listed as 900007 MCP tools.
- Exclusion Rules: subcommand names, role names.
- Primary Search Strategy or Query Expression: Read of the epic naming-contract bullet "MCP tools
  (900007): ...".
- Primary Member Set: `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
  `update_docs_ledger`, `generate_docs_reference`, `validate_docs_artifacts`.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: Read of 1036 `spec.md` `## Behavior` first
  bullet list and `issue.md` `## Proposed Behavior`.
- Cross-check Member Set: the same six names.
- Cross-check Count: 6.
- Member-set Comparison: equal sets in all three sources; no additional or missing name.

## Automation Feasibility

| Check | Automatable | Method |
|---|---|---|
| Input validation, mapping, envelope parsing, result mapping | yes | Jest unit tests with in-memory fixtures and injected launcher, `FileSystem` and `pwsh` resolver |
| Tool registration and enumeration | yes | Jest (`mcp-server.docs.test.ts`, updated existing tests) |
| Coverage 85/75 per new file | yes | `node run-jest.cjs --coverage` with `jest.docs-coverage.json` entries; CI job `drm-copilot-extension-tests` on ubuntu and windows |
| Grammar parity with the schemas | yes | Jest reading committed schema files |
| Envelope schema conformance of real PowerShell output | yes, upstream | 1020 Pester (`Test-Json` against the self-contained schema); not re-run in Jest |
| Real `pwsh` round trip (Windows argument quoting, stdout encoding of non-ASCII text, exit propagation) | partly | Not a unit test. Recommend an orchestrator-run probe on the integration branch after 1020-1024 merge: one call per tool against a committed read-only fixture, evidence under `<FEATURE>/evidence/other/`. A CI integration test is possible (both runners ship PowerShell 7) but would depend on the docs lib being present on the branch |
| Annotations accepted by the SDK listing path | yes | Jest `client.listTools()` returns the `annotations` object |
| Brief update parity (six copies) | yes | `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py` and the bundle-parity checks named in the brief |

## Pre-Mortem

- Review checklists: a reviewer may flag that TypeScript duplicates PowerShell rules (grammars and the `update-ledger` field table) against the "no logic beyond mapping and parsing" criterion, or that `jest.config.cjs` was edited; mitigation: the plan records each duplicate as published-contract mirroring with a parity test, keeps all checks declarative, and states the coverage-registration reason for the config edit.
- Coverage: a new production file without a `coverageThreshold` entry is ungated, and the executor's spawn path could be measured only through blanket mocks; mitigation: one entry per new file in `jest.docs-coverage.json`, the default launcher is imported (already covered by discovery tests), and every branch of the executor is reached through injected fakes rather than module mocks.
- Mirror parity: the execution-environment brief update must be byte-identical in six copies, and `.codex/config.toml` plus its bundle copy must stay untouched so `test_push_down_codex_and_agents_resource_contracts.py` keeps passing; mitigation: one brief-update task edits all six copies in one change and runs the push-down contract tests; no task edits `.codex/config.toml` or `.claude/settings.json`.
- File size: `mcp-server.test.ts` is at 494 lines and `jest.config.cjs` at 535; mitigation: move the expected tool list into `mcp-server-test-service.ts`, register coverage through the sibling JSON, and keep each new module below 500 lines (split the envelope parser out of the executor).
- Test isolation: new suites could leave programmed mocks on the shared `createMockService()` object or depend on suite order; mitigation: each test builds its own mock service and launcher, no module-level mutable state in the new modules, and a seeded shuffled Jest run is recorded under `evidence/regression-testing/`.
- CI-only behavior: Linux runners reject drive-letter workspace roots and are case-sensitive; mitigation: fixtures use `VIRTUAL_WORKSPACE_ROOT` from `mcp-server-test-service.ts`, the script path is joined with forward slashes, the schema-reading tests resolve paths with `path.resolve(__dirname, ...)` like `packaging/discovery-resources.test.ts`, and no test spawns `pwsh`.
- Evidence: coverage and isolation claims could be made from the combined terminal summary or from an artifact without the required fields; mitigation: per-file figures are read from the Jest coverage output for the five new files and recorded with `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` under `<FEATURE>/evidence/<kind>/`, with `SCRATCH` used for scratch locations.

## Owner Questions

- **OQ-A - Scope of "only mutating tool".** The epic AC says `update_docs_ledger` is the only
  mutating tool, while 1022 (`--output`) and 1024 (`--write`) define file-writing options and 1023
  narrows "mutating" to the ledger, matrix and pins. Provisional default: strict reading. Through MCP,
  `run_docs_inventory` returns the snapshot in `result` without writing it, and
  `generate_docs_reference` runs as a dry run only; persisting a snapshot or generated pages remains
  available to skills and CI through `Invoke-DocsCommand.ps1`. Alternative: allow those two write
  options and restate the AC as "the only tool that changes ledger, matrix or pin artifacts".
- **OQ-B - Codex and Claude permission exposure.** `.codex/config.toml` `enabled_tools` and the
  `.claude/settings.json` allow list are curated subsets that omit the discovery tools. Provisional
  default: 900007 does not add the docs tools to either; 900009 decides when it defines the roles
  (consistent with epic OQ-2).
- **OQ-C - Option-like values (cross-feature, 1020).** A value beginning with `-` passed through
  `pwsh -File` reaches `ValueFromRemainingArguments` as a separate token. Provisional default:
  900007 rejects such values before launch; 1020's `ConvertFrom-DocsCommandArgument` should also
  treat the token after a `value` option as its value. Free-text fields (`rationale`, `claim`,
  `target`) therefore cannot begin with `-` through MCP.

## Risks

- Upstream contracts are not yet PowerShell-final (all four upstream folders carry the withdrawn
  Python design); the option table must be re-confirmed against the re-prepared specs before the
  plan is cleared.
- Windows argument quoting through `pwsh -File` for values containing double quotes, and the stdout
  encoding of non-ASCII text when `pwsh` writes to a pipe, are unverified; 1020's entry script may
  need to set UTF-8 console output encoding. Both are probe items, not assumptions.
- Envelope-schema contract test depends on the final 1020 amendment text.

## Facts Needing Orchestrator Confirmation

1. Whether the 1020 amendment (envelope schema, `analysis_method`, declaration-lines digest) and the
   re-prepared 1021-1024 specs have landed on `epic/documentation-estate-tooling-integration`, and the
   final PowerShell option names per subcommand (needs `git show` on the integration branch).
2. The exact text of `schemas/docs/v1/docs-command-envelope.schema.json` once committed (top-level
   `required`, `additionalProperties`, finding definition placement).
3. That the installed `@modelcontextprotocol/sdk` version accepts and forwards `annotations` on tool
   definitions (no `node_modules` in this worktree; check `npm ls @modelcontextprotocol/sdk` in
   `extensions/drm-copilot`).
4. Whether `pwsh -File` on the `windows-latest` runner passes a value containing `"` or non-ASCII
   characters to `ValueFromRemainingArguments` unchanged, and whether stdout is UTF-8 when piped.
5. That no open pull request or concurrent child edits `src/mcp-tools.ts`,
   `src/repo-automation-tool-names.ts` or `test/mcp-server.test.ts` (needs `gh`).

# `legacy-discovery-mcp-vscode` — User Story

- Issue: #370
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-17

## Story Statement

- As an agent operating in a consumer/migrating repository, I want the epic's
  `dev.discovery.*` CLI operations exposed as MCP tools in the `drm-copilot` MCP
  server, so that I can run discovery init, validation, analyzers, scenario
  generation, and reports through the same tool surface as the existing
  repo-automation tools, without shelling out to the Python CLI myself.
- As a developer in a consumer/migrating repository using VS Code, I want each
  discovery operation available as a VS Code command, so that I can invoke discovery
  operations interactively (or programmatically with direct arguments) and see the
  results in the `drm-copilot` output channel.

## Problem / Why

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability whose functional features each ship a `dev.discovery.*`
Python CLI command (validators, init, analyzers, acceptance-scenario generation,
reports). The repository's CLI-before-MCP-before-VS-Code ordering requires that those
CLI commands also be exposed as TypeScript MCP tools in the `drm-copilot` MCP server and
as VS Code commands, so agents and interactive users can invoke discovery operations
through the same surfaces as the existing repo-automation tools. Without this
exposure layer, the discovery commands are reachable only from the Python CLI.

This feature is the exposure layer only: it wraps the workspace's `dev.discovery.*`
commands via a Python subprocess and re-authors none of them. Note the corrected
substrate (per the feature research): the MCP server bundles no Python, so the wrapper
spawns the workspace discovery CLI (`python -m scripts.discovery.<module>`, `cwd =
workspace_root`) rather than a bundled script.

## Personas & Scenarios

- Persona: **Discovery agent in a migrating repository (e.g. TaskMaster)**
  - An autonomous agent driving the discovery/parity workflow via MCP.
  - Cares about: a stable, schema-validated tool contract; deterministic success and
    failure shapes; artifact paths returned in results.
  - Constraints: can only reach operations exposed as MCP tools; must not depend on
    domain-specific behavior in the framework layer.
  - Goals: run inventory/analyzers/reports against the repository declared in the
    domain profile and consume the produced artifacts.
  - Frustrations avoided: silent failures (non-zero CLI exits must surface a stderr
    excerpt and `ok: false`), invalid arguments discovered only after a spawn.
- Persona: **Developer in a consumer/migrating repository using VS Code**
  - Works interactively; runs discovery steps while authoring the domain profile and
    reviewing generated artifacts.
  - Cares about: discoverable commands in the palette, prompts for required arguments,
    output visible in the `drm-copilot` output channel.
  - Constraints: their workspace supplies the Python interpreter and the discovery
    package; the extension bundles neither.

- Scenario: **Agent generates a parity report via MCP**
  - The agent, resuming the discovery workflow, needs a current parity report.
  - It calls the `run_discovery_report` MCP tool with
    `{ "report_type": "parity", "profile_path": "discovery/domain-profile.yml" }`.
  - The tool resolves and validates the input, the service spawns
    `python -m scripts.discovery.report parity --profile discovery/domain-profile.yml`
    with `cwd = workspace_root`, and the CLI writes the report artifact.
  - The agent receives `{ ok: true, tool, workspace_root, summary, artifacts }` and
    reads the report path from `artifacts`.
  - If the workspace lacks the discovery package, the CLI exits non-zero and the agent
    receives `ok: false` with a `stderr_excerpt` identifying the import failure.
- Scenario: **Developer initializes a discovery workspace from VS Code**
  - A developer starting a migration opens the command palette and runs
    "drm-copilot: Run Discovery Init".
  - The command prompts for the optional profile path (or accepts direct arguments in
    a programmatic invocation), then calls the shared service method, which spawns the
    workspace `dev.discovery.*` init CLI.
  - The output channel shows the CLI's streamed output; the scaffolded discovery
    workspace appears in the repository.

## Acceptance Criteria

- [ ] Seven discovery MCP tools are exposed — `validate_discovery_artifacts`, `run_discovery_init`, `run_discovery_repo_inventory`, `run_discovery_dotnet_analyzer`, `run_discovery_vsto_analyzer`, `run_discovery_scenario_generation`, `run_discovery_report` — and each satisfies all five touch-points: a `REPO_AUTOMATION_TOOLS` union entry in `repo-automation-tool-names.ts`; a tool definition with JSON-Schema-shaped `inputSchema` and `additionalProperties: false` in `mcp-repo-automation-tool-definitions.ts` plus an aligned base entry in `mcp-tool-definitions.ts`; a dispatch-switch case in `mcp-tools.ts`; a handler in `mcp-handlers/` paired with a `resolve<X>ToolInput` input resolver; and a service method on both the `RepoAutomationService` interface and `DefaultRepoAutomationService`.
- [ ] Each service call invokes the workspace discovery CLI via a Python subprocess (`python -m scripts.discovery.<module>` argv shape) with `cwd = workspace_root`, reusing the existing `runCommandWithOutput` / `CommandExecutionError` semantics; no Python is bundled into the VSIX and no `.vscodeignore` or packaging change is made.
- [ ] `RuntimeKind` in `runtime-detection.ts` is extended with a `"python"` kind and `detectRuntime` gains a Python interpreter probe, covered by tests for found and not-found cases.
- [ ] The tool-name-to-CLI mapping (module path and flag composition per tool) is centralized in a single table module; no `dev.discovery.*` command logic is re-authored in TypeScript.
- [ ] `run_discovery_report` exposes a required `report_type` enum exactly `["coverage", "parity", "completion"]`, and `validate_discovery_artifacts` exposes a required `artifact_type` enum covering the domain profile and the seven discovery schema artifact kinds; both enums are duplicated in the input resolvers and rejected values fail before any spawn.
- [ ] Each of the seven tools is registered as a VS Code command: a `contributes.commands` entry in `extensions/drm-copilot/package.json` and a registration function in a dedicated discovery registration module called from `extension.ts` `activate`, with disposables pushed to `context.subscriptions`, supporting both direct-argument and interactive invocation.
- [ ] The exposure layer is domain-neutral: no TaskMaster/TMW/Outlook/email/task-management-specific identifier appears in any tool name, command id, schema field, description, or implementation; domain specificity is supplied only via runtime arguments (e.g. `--profile`).
- [ ] The design-against-planned status is preserved in the implementation: assumed upstream command names/flags are confined to the mapping table, and live end-to-end execution is documented as dependent on the upstream `dev.discovery.*` merges per epic wave ordering.
- [ ] TypeScript Jest tests are mirrored under `extensions/drm-copilot/test/`, covering: definitions contract (union order, cross-file alignment, `additionalProperties: false`, enums), input resolvers, dispatch/handler routing per tool, service-call argv/cwd/error mapping with a faked spawn boundary, runtime detection, `mcp-server.test.ts` list/dispatch round-trips, and VS Code command harness tests.
- [ ] Every new production file has a per-file `coverageThreshold` entry of `{ lines: 85, branches: 75 }` in `jest.config.cjs`, and `npm run test:coverage` passes with line coverage >= 85% and branch coverage >= 75% on all new files.
- [ ] The full extension toolchain passes in `extensions/drm-copilot/`: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test`, `npm run test:coverage` (Jest 30 + ts-jest, v8 coverage).

## Non-Goals

- Re-authoring, porting, or modifying any `dev.discovery.*` CLI command; those ship in
  the owning functional features and this layer only wraps them.
- Bundling Python source into the VSIX or changing `.vscodeignore` / esbuild packaging.
- Mirroring assets into `resources/` or push-down packaging — that is the publishing
  feature's (#9012) responsibility.
- Any domain-specific (TaskMaster/TMW/Outlook/VSTO-domain/email/task-management)
  behavior in the exposure layer.
- Live end-to-end execution against real upstream CLI commands before the upstream
  features merge (epic Wave 3 ordering); this feature's verification is unit and
  contract testing with a faked spawn boundary.

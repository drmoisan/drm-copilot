# `legacy-discovery-mcp-vscode` — User Story

- Issue: #370
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-19 (reconciled against the landed discovery CLI)

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
substrate: the MCP server bundles no Python, so the wrapper spawns the workspace
discovery CLI as an interpreter `-c` `module:function` subprocess (argv `[pythonExe,
"-c", "import sys; from <module> import <function>; sys.exit(<function>())",
...cliArgs]`, `cwd = workspace_root`) rather than a bundled script; `-c` is required
because the landed dotnet/vsto/init console-script entries are not `python -m`-runnable.

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
    `{ "report_type": "parity", "input_path": "discovery/parity-matrix.yaml",
    "output_path": "discovery/reports/parity-report.md" }`.
  - The tool resolves and validates the input (including the report_type-aware
    required `input_path`), the service spawns the landed
    `scripts.dev_tools.discovery.parity_report:main` entry via the interpreter `-c`
    mechanism with `--input discovery/parity-matrix.yaml --output
    discovery/reports/parity-report.md` and `cwd = workspace_root`, and the CLI writes
    the report artifact.
  - The agent receives `{ ok: true, tool, workspace_root, summary }` and reads the
    report at the `output_path` it supplied (the report scripts print no artifact path
    to stdout, so the result carries no parsed `artifacts`).
  - If the workspace lacks the discovery package, the CLI exits non-zero and the agent
    receives `ok: false` with a `stderr_excerpt` identifying the import failure.
- Scenario: **Developer initializes a discovery workspace from VS Code**
  - A developer starting a migration opens the command palette and runs
    "drm-copilot: Run Discovery Init".
  - The command prompts for the required target directory and the optional template
    root / force flag (or accepts direct arguments in a programmatic invocation), then
    calls the shared service method, which spawns the workspace
    `scripts.dev_tools.discovery.init_cli:main` entry with the positional `target_dir`.
  - The output channel shows the CLI's streamed output; the scaffolded discovery
    workspace appears in the repository.

## Acceptance Criteria

- [x] Seven discovery MCP tools are exposed — `validate_discovery_artifacts`, `run_discovery_init`, `run_discovery_repo_inventory`, `run_discovery_dotnet_analyzer`, `run_discovery_vsto_analyzer`, `run_discovery_scenario_generation`, `run_discovery_report` — and each satisfies all five touch-points: a `REPO_AUTOMATION_TOOLS` union entry in `repo-automation-tool-names.ts`; a tool definition with JSON-Schema-shaped `inputSchema` and `additionalProperties: false` in `mcp-repo-automation-tool-definitions.ts` plus an aligned base entry in `mcp-tool-definitions.ts`; a dispatch-switch case in `mcp-tools.ts`; a handler in `mcp-handlers/` paired with a `resolve<X>ToolInput` input resolver; and a service method on both the `RepoAutomationService` interface and `DefaultRepoAutomationService`.
- [x] Each service call invokes the workspace discovery CLI via a Python subprocess with the interpreter `-c` `module:function` argv shape — `[pythonExe, "-c", "import sys; from <module> import <function>; sys.exit(<function>())", ...cliArgs]` targeting the landed console-script entries — with `cwd = workspace_root`, reusing the existing `runCommandWithOutput` / `CommandExecutionError` semantics; no Python is bundled into the VSIX and no `.vscodeignore` or packaging change is made.
- [x] `RuntimeKind` in `runtime-detection.ts` is extended with a `"python"` kind and `detectRuntime` gains a Python interpreter probe, covered by tests for found and not-found cases.
- [x] The tool-name-to-CLI mapping (dotted module path, entry-function name, and CLI-arg composition per wrapped invocation, including the per-kind validate entries and the per-`report_type` report entries) is centralized in a single table module; no `dev.discovery.*` command logic is re-authored in TypeScript.
- [x] `run_discovery_report` exposes a required `report_type` enum exactly `["coverage", "parity", "completion"]` with report_type-aware required inputs validated by the resolver before any spawn (`input_path` for `coverage`/`parity`; `coverage_input` and `parity_input` for `completion`), and `validate_discovery_artifacts` exposes a required `artifact_type` enum exactly `["profile", "feature-contract", "coverage-ledger", "runtime-scenario", "parity-matrix", "unspecified-behavior", "product-decision", "evidence-reference", "all"]`; both enums are duplicated in the input resolvers and rejected values fail before any spawn.
- [x] Each of the seven tools is registered as a VS Code command: a `contributes.commands` entry in `extensions/drm-copilot/package.json` and a registration function in a dedicated discovery registration module called from `extension.ts` `activate`, with disposables pushed to `context.subscriptions`, supporting both direct-argument and interactive invocation.
- [x] The exposure layer is domain-neutral: no TaskMaster/TMW/Outlook/email/task-management-specific identifier appears in any tool name, command id, schema field, description, or implementation; domain specificity is supplied only via runtime arguments (e.g. the domain-profile path).
- [x] The landed-contract reconciliation is preserved in the implementation: the landed module/function names and flags are confined to the mapping table and enum constants module, and the helper's header doc comment records that the mapping targets the merged `dev.discovery.*` console-script entries and justifies the `-c` invocation mechanism (dotnet/vsto/init entries are not `python -m`-runnable; no Poetry-on-PATH dependency).
- [x] TypeScript Jest tests are mirrored under `extensions/drm-copilot/test/`, covering: definitions contract (union order, cross-file alignment, `additionalProperties: false`, enums), input resolvers, dispatch/handler routing per tool, service-call argv/cwd/error mapping with a faked spawn boundary, runtime detection, `mcp-server.test.ts` list/dispatch round-trips, and VS Code command harness tests.
- [x] Every new production file has a per-file `coverageThreshold` entry of `{ lines: 85, branches: 75 }` in `jest.config.cjs`, and `npm run test:coverage` passes with line coverage >= 85% and branch coverage >= 75% on all new files.
- [x] The full extension toolchain passes in `extensions/drm-copilot/`: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test`, `npm run test:coverage` (Jest 30 + ts-jest, v8 coverage).

## Non-Goals

- Re-authoring, porting, or modifying any `dev.discovery.*` CLI command; those ship in
  the owning functional features and this layer only wraps them.
- Bundling Python source into the VSIX or changing `.vscodeignore` / esbuild packaging.
- Mirroring assets into `resources/` or push-down packaging — that is the publishing
  feature's (#9012) responsibility.
- Any domain-specific (TaskMaster/TMW/Outlook/VSTO-domain/email/task-management)
  behavior in the exposure layer.
- Live end-to-end execution against the merged upstream CLI commands as part of this
  feature's automated verification; the upstream waves are merged on the integration
  branch, but this feature's verification remains unit and contract testing with a
  faked spawn boundary (no real subprocess in tests).

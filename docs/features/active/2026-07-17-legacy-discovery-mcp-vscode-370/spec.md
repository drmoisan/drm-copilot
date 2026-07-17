# legacy-discovery-mcp-vscode — Spec

- **Issue:** #370
- **Parent (optional):** epic `legacy-discovery-and-parity` (child #9011 placeholder)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 0.2

## Overview

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability whose functional features each ship a `dev.discovery.*`
Python CLI command (validators, init, repo inventory and .NET/VSTO analyzers,
acceptance-scenario generation, reports). The repository's CLI-before-MCP-before-VS-Code
ordering requires that those CLI commands also be exposed as TypeScript MCP tools in the
`drm-copilot` MCP server and as VS Code commands, so agents and interactive users can
invoke discovery operations through the same surfaces as the existing repo-automation
tools. Without this exposure layer, the discovery commands are reachable only from the
Python CLI.

This feature is the MCP + VS Code exposure layer only. Each functional feature already
ships its own `dev.discovery.*` Python CLI command; this feature wraps those commands
and re-authors none of them. The layer stays domain-neutral: it surfaces the generic
discovery commands and contains no TaskMaster/TMW/Outlook/VSTO/email/task-management-
specific behavior. All domain specificity (which repository, which paths) is supplied at
runtime through the domain-profile argument.

**Substrate correction (authoritative, from feature research
`research/2026-07-17T16-30-legacy-discovery-mcp-vscode-370-research.md`):** the prior
assumption that new tools "shell out to the bundled Python script" is stale and
unsatisfiable. The MCP server no longer bundles or shells out to Python: feature #240
ported the former Python tools in-process, `RuntimeKind` is PowerShell-only
(`extensions/drm-copilot/src/runtime-detection.ts`), and `.vscodeignore` excludes
`**/*.py` from the VSIX (no `.py` exists under extension resources). The corrected
design, verified by research, is to extend the runtime with a `python` kind and spawn
the **workspace** discovery CLI as a Python subprocess (`python -m
scripts.discovery.<module>`) with `cwd = workspace_root`, reusing the existing
`runCommandWithOutput` / `CommandExecutionError` semantics. This feature introduces no
VSIX bundling; `resources/` asset mirroring remains the publishing feature's (#9012)
responsibility.

## Behavior

Expose seven discovery operations as MCP tools in the `drm-copilot` MCP server and as
VS Code commands. Each tool is a thin wrapper: it validates and normalizes MCP input,
calls a shared `RepoAutomationService` method, and that service method spawns the
workspace's `dev.discovery.*` Python CLI as a subprocess. The VS Code command for each
tool is a second front-end over the same service method (there is no automatic
MCP-to-command bridge in this codebase).

Wrapper contract semantics:

- **Success:** the CLI exits 0; the service returns
  `{ tool, workspaceRoot, summary, artifacts? }`, mapped by the dispatch layer to the
  snake_case MCP result `{ ok: true, tool, workspace_root, summary, artifacts? }`. The
  VS Code command logs to the `drm-copilot` output channel.
- **Failure:** the CLI exits non-zero; the service call throws `CommandExecutionError`;
  the dispatch `catch` returns `{ ok: false, summary: <error message>, stderr_excerpt:
  <= 8 lines }` with MCP `isError: true`.
- **Invalid input:** the `resolve<X>ToolInput` resolver throws before any service or
  spawn work; the service is never called.
- **Ordering invariant (CLI-before-MCP-before-VS-Code):** each dispatch case calls only
  its handler; each VS Code command calls only the shared service method; neither
  re-implements any CLI logic.
- **Edge cases:** missing Python interpreter (runtime probe failure message, mirroring
  the existing PowerShell probe error style); workspace without the discovery package
  installed (non-zero exit surfaces the stderr excerpt); omitted `workspace_root`
  (defaults to `process.cwd()` on the MCP path via `inferWorkspaceRoot`, and to
  `getWorkspaceRoot()` on the VS Code path); enum-out-of-range `report_type` /
  `artifact_type` (resolver rejects before spawn).

## Inputs / Outputs

- **Inputs (MCP tool arguments):** every tool accepts an optional `workspace_root`
  (reusing the shared `workspaceRootProperty` fragment) plus tool-specific fields listed
  in the API surface below. All input schemas set `additionalProperties: false`.
- **Inputs (VS Code):** each command supports direct argument invocation
  (programmatic/test path) with fallback to interactive prompts, per the existing
  `resolveWorkflowInvocation` idiom.
- **Outputs:** `RepoAutomationExecutionResult` mapped to the MCP structured result
  (`ok`, `tool`, `workspace_root`, `summary`, optional `artifacts`). Artifact paths
  (ledger/matrix/report files) are parsed from CLI stdout via a
  `stdoutArtifactPattern`-style regex once the upstream stdout contract is fixed
  (design-against-planned assumption; confirm at implementation time).
- **Logs:** all subprocess stdout/stderr streams through the injected `CommandOutput`
  sink; the MCP path uses a per-call buffered output (no terminal is created on the MCP
  path — existing invariant, must be preserved).
- **Env vars / config keys:** none introduced. Interpreter resolution order for the
  Python runtime probe (workspace `.venv` interpreter, then `py`/`python` on PATH) is
  fixed at planning time.
- **Versioning / backward compatibility:** additive only. Existing tool names,
  definitions, and dispatch behavior are unchanged; new union entries append to
  `REPO_AUTOMATION_TOOLS` with definitions in union order (contract test enforces
  order parity).

## API / CLI Surface

### Exposed tool set (design baseline)

Seven MCP tools and seven VS Code commands. Tool names, wrapped CLI modules, and flags
are designed against the **planned** upstream contracts (upstream specs
#361/#362/#363/#364 and placeholder children #9010/#9014 are not yet on the integration
branch); the tool-name-to-CLI mapping is centralized in one table module so an upstream
rename is a one-line change.

| MCP tool | VS Code command | Wrapped workspace CLI invocation (assumed shape) | Tool-specific input fields |
|---|---|---|---|
| `validate_discovery_artifacts` | `drmCopilotExtension.validateDiscoveryArtifacts` | `python -m scripts.discovery.validate <artifact_type> --path <artifact_path>` | `artifact_type` (required, enum: domain profile + the seven schema artifact kinds), `artifact_path` (required string) |
| `run_discovery_init` | `drmCopilotExtension.runDiscoveryInit` | `python -m scripts.discovery.init [--profile <path>] [--force]` | `profile_path` (optional string), `force` (optional boolean) |
| `run_discovery_repo_inventory` | `drmCopilotExtension.runDiscoveryRepoInventory` | `python -m scripts.discovery.analyze_repo --profile <path> [--output-root <path>]` | `profile_path` (required string), `output_root` (optional string) |
| `run_discovery_dotnet_analyzer` | `drmCopilotExtension.runDiscoveryDotnetAnalyzer` | `python -m scripts.discovery.analyze_dotnet --profile <path> [--output-root <path>]` | `profile_path` (required string), `output_root` (optional string) |
| `run_discovery_vsto_analyzer` | `drmCopilotExtension.runDiscoveryVstoAnalyzer` | `python -m scripts.discovery.analyze_vsto --profile <path> [--output-root <path>]` | `profile_path` (required string), `output_root` (optional string) |
| `run_discovery_scenario_generation` | `drmCopilotExtension.runDiscoveryScenarioGeneration` | `python -m scripts.discovery.generate_scenarios --profile <path> [selectors]` | `profile_path` (required string), optional contract/scenario selector fields (fixed at planning against #9009's contract) |
| `run_discovery_report` | `drmCopilotExtension.runDiscoveryReport` | `python -m scripts.discovery.report <report_type> --profile <path> [--output <path>]` | `report_type` (required, enum `["coverage", "parity", "completion"]`), `profile_path` (required string), `output_path` (optional string) |

Every tool additionally accepts optional `workspace_root`. All schemas are
JSON-Schema-shaped objects with `additionalProperties: false`. `run_discovery_report`
folds the three report kinds into one enum-dispatched tool (mirroring the
`validate_orchestration_artifacts` enum pattern) rather than triplicating touch-points;
if upstream ships three separate report commands and per-command fidelity is preferred,
the planner may split it (9 tools instead of 7).

Domain-neutrality of names: "dotnet"/"vsto" name the analyzed technology stack declared
by the epic's own domain-neutral feature naming, not a consumer domain. No
TaskMaster/TMW/Outlook/email/task-management identifier appears in any tool name,
command id, schema field, or description.

### Five-touch-point lockstep contract

Adding one MCP tool requires, in lockstep (a missing piece is a compile or contract-test
failure):

1. **Tool-name union entry** — append the tool name to `REPO_AUTOMATION_TOOLS` in
   `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
2. **Tool definition** — add a `ToolDefinition` with JSON-Schema-shaped `inputSchema`
   and `additionalProperties: false` to
   `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, **in union
   order**, plus the aligned base entry in
   `extensions/drm-copilot/src/mcp-tool-definitions.ts` (cross-file alignment is
   contract-tested).
3. **Dispatch-switch case** — one `case` in `dispatchRepoAutomationTool` in
   `extensions/drm-copilot/src/mcp-tools.ts`. The switch is exhaustive over
   `RepoAutomationToolName` with no `default`, so a missing case is a compile error.
4. **Handler + input resolver** — a handler in
   `extensions/drm-copilot/src/mcp-handlers/*.ts` paired with a
   `resolve<X>ToolInput` in `src/mcp-tool-inputs.ts` (or a per-family
   `mcp-tool-inputs-*.ts`) that validates/normalizes raw MCP arguments and throws on
   invalid input.
5. **Service method** — a method on both the `RepoAutomationService` interface and
   `DefaultRepoAutomationService` in
   `extensions/drm-copilot/src/repo-automation-service.ts`.

Plus the **VS Code command layer**: a `contributes.commands` entry in
`extensions/drm-copilot/package.json` and a registration function in a new
`discovery-command-registration.ts` module (following the
`repo-automation-command-registration-feature-workflows.ts` pattern), called from
`extension.ts` `activate` with disposables pushed to `context.subscriptions`. The
`extension.ts` file is near the 500-line cap, so registration must live in the new
module. The MCP server (`src/mcp-server.ts`) and MCP provider (`src/mcp-provider.ts`)
need no change; `listTools` and the `listMcpTools` QuickPick pick up new tools
automatically.

And one feature-specific **sixth production touch-point**: `RuntimeKind` in
`extensions/drm-copilot/src/runtime-detection.ts` widens from `"powershell"` to
`"powershell" | "python"`, and `detectRuntime` gains a Python interpreter probe
(resolution order: workspace `.venv` interpreter, then `py`/`python` on PATH via the
existing `findExecutableOnPath` helper).

## Data & State

- **Invocation model (Python subprocess, no bundling):** each service method builds
  argv `[pythonExe, "-m", "scripts.discovery.<module>", ...flags]` and spawns via the
  existing `runCommandWithOutput` with `cwd = workspace_root`. The discovery code lives
  in the target workspace (the `dev.discovery.*` commands are Poetry console scripts
  mapping to `scripts.discovery.<module>:main`), not in the extension, so
  extension-root script resolution and VSIX bundling are unnecessary; `python -m`
  avoids requiring the Poetry venv's script shims on PATH.
- **Service-call helper:** a discovery-specific sibling of
  `repo-automation-execute-script.ts` forwards `{ runtimeKind: "python", args,
  workspaceRoot, invocationId }`, optionally parses one artifact path from stdout, and
  returns `RepoAutomationExecutionResult`. Failure is signaled by throwing
  `CommandExecutionError` (which carries `executable, args, cwd, exitCode, stdout,
  stderr`) so the dispatch layer can attach `stderr_excerpt`.
- **Central mapping table:** one module maps tool name -> Python module path + flag
  composition, so upstream CLI renames are single-line changes and no discovery logic
  leaks into TypeScript.
- **State changes:** none in the extension. All artifacts produced (ledgers, matrices,
  reports, scaffolds) are written by the wrapped CLI into the target workspace per the
  domain profile. No caching, persistence, migration, or backfill is introduced.
- **Data invariant:** the wrapper transforms only argument shape (snake_case MCP fields
  -> CLI flags) and result shape (exit code/stdout -> MCP result); it never interprets
  or rewrites discovery artifact content.

## Constraints & Risks

- **Substrate correction (blocking wording fix):** the issue's original criterion "a
  service call that shells out to the bundled Python script" is unsatisfiable on the
  current substrate — the MCP server bundles no Python (feature #240; PowerShell-only
  `RuntimeKind`; `.vscodeignore` excludes `**/*.py`). The criterion is corrected in
  this spec to: the service call invokes the **workspace** discovery CLI via a Python
  subprocess. No VSIX bundling change is in scope.
- **Lockstep requirement:** the five MCP touch-points (plus base-definitions parity and
  per-file coverage thresholds) must change together or the contract tests fail; the
  exhaustive dispatch switch turns a missing case into a compile error.
- **Upstream-dependency assumption (design-against-planned):** none of the wrapped
  `dev.discovery.*` commands exist on the integration branch today. Upstream specs
  (#361/#362/#363/#364, and placeholder children #9009/#9010/#9014) define the planned
  contracts this layer wraps. Command names, module paths, flags, and the stdout
  artifact pattern are assumptions to confirm; the central mapping table localizes the
  churn. Live end-to-end execution of a wrapped tool requires the upstream features to
  be merged (epic Wave 3 ordering); implementation and automated testing are unaffected
  because the spawn boundary is faked in tests.
- **Runtime interpreter dependency:** at runtime the target workspace must have the
  drm-copilot Python package (with the merged discovery modules) importable by the
  resolved interpreter. A missing interpreter or missing package surfaces as a probe
  error or a non-zero exit with stderr excerpt — it must fail explicitly, not silently.
- **Mirroring is out of scope:** `resources/` asset mirroring and push-down packaging
  are the publishing feature's (#9012) responsibility. This feature adds no
  `resources/` assets and reverts no `.vscodeignore` exclusion.
- **Domain neutrality:** no TaskMaster/TMW/Outlook/email/task-management-specific
  identifier or behavior may appear in the exposure layer; domain specificity arrives
  only via the `--profile` runtime argument.
- **File-size cap:** `extension.ts` is near the 500-line limit; command registration
  must live in a new module.

## Implementation Strategy

- **Scope of change (all under `extensions/drm-copilot/` unless noted):**
  - `src/repo-automation-tool-names.ts` — seven new union entries.
  - `src/mcp-repo-automation-tool-definitions.ts` and `src/mcp-tool-definitions.ts` —
    seven aligned tool definitions each, `additionalProperties: false`, reusing
    `workspaceRootProperty`.
  - `src/mcp-tools.ts` — seven dispatch cases.
  - `src/mcp-handlers/discovery-handlers.ts` (new) — seven handlers.
  - `src/mcp-tool-inputs-discovery.ts` (new) — seven input resolvers with enum sets
    matching the schema enums.
  - `src/repo-automation-service.ts` — seven interface methods + implementations
    delegating to the discovery service-call helper.
  - `src/repo-automation-execute-discovery.ts` (new, name indicative) — Python
    subprocess service-call helper plus the central tool-to-CLI mapping table.
  - `src/runtime-detection.ts` — `RuntimeKind` widened with `"python"`; Python probe.
  - `src/discovery-command-registration.ts` (new) — VS Code command registration;
    wired from `src/extension.ts` `activate`.
  - `package.json` — seven `contributes.commands` entries.
  - `jest.config.cjs` — per-file `coverageThreshold` entries
    (`{ lines: 85, branches: 75 }`) for every new production file.
- **Dependency changes:** none. No new npm package; no Python bundling; no
  esbuild/packaging change.
- **Logging/telemetry:** subprocess output streams through the existing
  `CommandOutput` sink (buffered on the MCP path, output channel on the VS Code path);
  runtime-probe start/failure logging mirrors the existing PowerShell pattern. No new
  telemetry.
- **Rollout / fallback:** additive tool surface; no feature flag. If an upstream CLI
  contract shifts before merge, only the mapping table and the affected input resolver
  change.
- **Testing (Jest 30 + ts-jest, mirrored under `test/`):**
  - Definitions contract: extend the union-order/definition-parity test and add
    per-tool schema assertions in both definition files (including
    `additionalProperties: false` and enum contents).
  - Input resolvers: valid / missing / wrong-type / normalization cases per resolver.
  - Dispatch + handlers: `dispatchRepoAutomationTool` with a mocked service per tool
    (success; thrown-error mapping to `ok: false` + `stderr_excerpt`).
  - Service calls: fake the spawn boundary; assert argv composition
    (`python -m scripts.discovery.<module>` + flags), `cwd = workspaceRoot`, artifact
    parsing, summary strings. No real subprocess, no temporary files.
  - Runtime detection: Python probe found/not-found and PATHEXT behavior.
  - End-to-end MCP: extend `mcp-server.test.ts` mock service, `listTools` expectation,
    and one dispatch round-trip per tool; preserve the no-terminal invariant.
  - VS Code commands: harness-based tests for interactive and direct-args invocation
    per command.
- **Evidence:** Phase-0 baseline and final QC evidence are written to
  `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/<kind>/`
  per the evidence-and-timestamp conventions.

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

## Definition of Done

- [ ] All acceptance criteria above are implemented, verified, and checked off with evidence.
- [ ] Behavior matches the wrapper contract semantics (success, failure, invalid-input, ordering invariant, edge cases) documented in `## Behavior`.
- [ ] Edge cases and error handling are covered by tests (missing interpreter, missing discovery package, omitted `workspace_root`, out-of-range enums).
- [ ] Docs updated: this spec and `user-story.md` remain consistent with the delivered surface; feature folder cross-references use issue #370.
- [ ] Logging via the existing `CommandOutput` sink verified on both the MCP (buffered, no terminal) and VS Code (output channel) paths.
- [ ] Toolchain pass completed in `extensions/drm-copilot/`: `npm run format` -> `npm run lint` -> `npm run typecheck` -> `npm run test` -> `npm run test:coverage`, all clean in a single pass.
- [ ] QC and coverage evidence stored under `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/<kind>/`.

## Seeded Test Conditions (from potential)

- [ ] Unit coverage: each handler, each service call, dispatch-switch routing per tool.
- [ ] Integration scenarios: MCP contract tests validating tool-definition schema shape.
- [ ] CLI/API examples: each exposed tool maps to its `dev.discovery.*` command invocation.

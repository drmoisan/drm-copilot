# legacy-discovery-mcp-vscode (Issue #370) — Research

- Date: 2026-07-17
- Author: task-researcher agent
- Feature: `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/`
- Epic: `docs/features/epics/legacy-discovery-and-parity/` (child #9011 placeholder, real issue #370)
- Scope: MCP + VS Code exposure layer for the epic's `dev.discovery.*` Python CLI commands. Wrapper only; re-authors no CLI command. Domain-neutral surface.

Evidence classes used throughout:

- **VERIFIED** — read directly from files in this worktree, with file and line citations.
- **DESIGN-AGAINST-PLANNED** — derived from `objective-source.md` / `epic.md` planned scope; the upstream command implementations and specs (#361/#362/#363/#364 and placeholder children #9003, #9005, #9006, #9009, #9010, #9014) are **not present on this integration branch**. No `dev.discovery.*` command, module, or spec exists in the worktree today (grep for `dev\.discovery` matches only this feature's docs and the epic docs).

---

## 1. Five-touch-point pattern for adding one MCP tool (VERIFIED)

Traced end-to-end. Note on the representative tool: **no current MCP tool shells out to bundled Python** (see section 2 — this is a material substrate correction). The closest live analogues are:

- Script-spawning tools (PowerShell): `run_poshqc_*`, `new_potential_entry`, `link_parent_child` — these exercise `executeBundledScriptFromExtensionRoot`.
- In-process TS ports: `validate_orchestration_artifacts`, `collect_pr_context`, etc.

The five touch-points, using `run_poshqc_test` (script-spawning) and `validate_orchestration_artifacts` (input-resolution shape) as references:

### Touch-point 1 — tool-name union

`extensions/drm-copilot/src/repo-automation-tool-names.ts` (entire file, 26 lines). `REPO_AUTOMATION_TOOLS` is an `as const` string array (lines 1–23); `RepoAutomationToolName` is derived at line 25. Adding a tool = appending one string literal. `isRepoAutomationToolName` in `mcp-tools.ts` (lines 265–269) and the exhaustive dispatch switch consume this union.

### Touch-point 2 — tool definition

`extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`. `ToolDefinition` interface (lines 9–18) requires `{ name: RepoAutomationToolName; description; inputSchema: { type: "object"; properties; required?; additionalProperties: false } }`. Every entry in `REPO_AUTOMATION_TOOL_DEFINITIONS` (lines 20–488) sets `additionalProperties: false`. Shared property fragments come from `mcp-push-down-schema-properties.ts` (`workspaceRootProperty`, imported at lines 2–7). Representative entries: `run_poshqc_test` (lines 295–314, optional `scan_folders` array), `validate_orchestration_artifacts` (lines 413–469, required `["artifact_type", "artifact_path"]`, enum-constrained `artifact_type`).

**Second definitions file:** `extensions/drm-copilot/src/mcp-tool-definitions.ts` exports `toolDefinitions` with an identical `ToolDefinition` shape. It is imported only by tests (`test/mcp-repo-automation-tool-definitions.test.ts` line 3, `test/mcp-epic-validation-definitions.test.ts` line 3, `test/mcp-tools.push-down-claude.test.ts` line 16) — no `src/` module imports it. The MCP server serves `REPO_AUTOMATION_TOOL_DEFINITIONS` (via `listRepoAutomationTools`, `mcp-tools.ts` lines 121–123). Existing contract tests assert cross-file alignment for several tools (e.g. `mcp-repo-automation-tool-definitions.test.ts` lines 22–45, 63–78, 80–107, 132–153), and `jest.config.cjs` carries a per-file coverage threshold for `mcp-tool-definitions.ts` (lines 66–69). Convention for new tools: add matching entries to **both** files.

### Touch-point 3 — dispatch-switch case

`extensions/drm-copilot/src/mcp-tools.ts`, `dispatchRepoAutomationTool` (lines 133–257). One `case` per tool name; the switch is exhaustive over `RepoAutomationToolName` (no `default`), so adding a union member without a case is a compile error. Representative case (lines 206–208):

```typescript
case "run_poshqc_test": {
  return toMcpToolResult(await handleRunPoshQCTest(rawInput, service));
}
```

Wrapping helpers: `inferWorkspaceRoot` (lines 64–77), `toMcpToolResult` (lines 79–99, maps `RepoAutomationExecutionResult` -> snake_case MCP result), `toFailureToolResult` (lines 101–114, catches thrown errors, attaches `stderr_excerpt` via `getStderrExcerpt` from `command-runtime.ts` lines 355–368). The `try/catch` around the whole switch (lines 140–256) is the single failure path: handlers and service calls signal failure by **throwing**.

### Touch-point 4 — handler

`extensions/drm-copilot/src/mcp-handlers/*.ts`, one small module per tool family. Pattern (`mcp-handlers/poshqc-handlers.ts` lines 23–29):

```typescript
export async function handleRunPoshQCTest(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveRunPoshQCSuiteToolInput(rawInput);
  return service.runPoshQCTest(input);
}
```

Handlers pair with an input resolver in `src/mcp-tool-inputs.ts` (or a per-family `mcp-tool-inputs-*.ts`). Resolvers validate/normalize raw MCP arguments and throw `Error("Field '<x>' must be ...")` on invalid input — see `resolveRunPoshQCSuiteToolInput` (lines 418–446) and `resolveValidateOrchestrationArtifactsToolInput` (lines 459–498, with the `VALID_ARTIFACT_TYPES` set at lines 448–457 duplicating the schema enum). Normalization helpers (`normalizeWorkspaceRoot`, `normalizeRequiredText`, `normalizeOptionalText`, `normalizeWorkspaceDestinationPath`) come from `workflow-command-arguments.ts`.

### Touch-point 5 — service call

`extensions/drm-copilot/src/repo-automation-service.ts`. Two lockstep edits:

1. Method signature on the `RepoAutomationService` interface (lines 57–158), e.g. `runPoshQCTest` at lines 113–117.
2. Implementation on `DefaultRepoAutomationService` (lines 192–491). Script-spawning implementations delegate to the private `executeScript` (lines 486–490), which calls `executeScriptServiceCall` in `repo-automation-execute-script.ts`. Example: `runPoshQcWorkflow` (lines 428–453) builds `{ args, bundledRelativePath, summary }` via `buildPoshQcWorkflowArguments` (`repo-automation-args.ts`) and passes `runtimeKind: "powershell"`.

The MCP server itself (`src/mcp-server.ts`) needs **no change**: `createRepoAutomationMcpServer` (lines 64–116) wires `ListToolsRequestSchema -> listRepoAutomationTools()` and `CallToolRequestSchema -> dispatchRepoAutomationTool(...)` generically, guarded by `isRepoAutomationToolName`.

---

## 2. `executeBundledScriptFromExtensionRoot` / `command-runtime.ts` contract (VERIFIED — with a critical substrate correction)

### Critical correction to the delegation's substrate facts

The claim "`executeBundledScriptFromExtensionRoot` shells out to bundled Python" is **stale**. Verified current state:

1. **PowerShell is the only supported runtime.** `extensions/drm-copilot/src/runtime-detection.ts` line 10: `export type RuntimeKind = "powershell";`. The doc comment (lines 4–9, 163–174) states: "Only PowerShell remains: all formerly-interpreted commands run in-process in TypeScript, so no interpreter is detected or spawned beyond PowerShell" and "never probes a Python interpreter." `detectRuntime` (lines 175–211) resolves only `pwsh` then `powershell`, with args prefix `-NoLogo -NoProfile -ExecutionPolicy Bypass -File`.
2. **No Python is bundled in the extension.** `extensions/drm-copilot/.vscodeignore` lines 15–19 exclude `**/__pycache__/**`, `**/*.pyc`, `**/*.pyo`, `**/*.py`, and `resources/scripts/**` from the VSIX. Glob for `extensions/drm-copilot/resources/**/*.py` returns nothing; `resources/templates/` contains only `.ps1` scripts.
3. Formerly-Python tools were ported in-process (F3–F10 comments in `repo-automation-service.ts`, e.g. lines 221–222, 233–234, 246–247, 338–340, 417, 424; feature `docs/features/completed/2026-06-25-port-python-commands-to-typescript-240/`).

Consequence: this feature **cannot** literally "shell out to the bundled Python script" as the issue.md acceptance-criterion wording assumes. See "Candidate approaches" below for how to satisfy the intent (wrap the CLI, re-author nothing).

### The mechanism as it exists (for whatever spawn path is chosen)

`extensions/drm-copilot/src/command-runtime.ts`:

- `executeBundledScriptFromExtensionRoot(output, spec)` (lines 277–327):
  1. Logs `[commandId] runtime probe start`, calls `detectRuntime(spec.runtimeKind)`; failure logs and rethrows (lines 281–288).
  2. Resolves the script path via `resolveBundledScriptPath(spec.extensionRoot, spec.bundledRelativePath)` (lines 177–194; forward-slash normalization; Windows drive-prefix preservation).
  3. Builds argv as `[...runtime.argsPrefix, scriptPath, ...spec.args]` (line 303) and spawns via `runCommandWithOutput(output, runtime.executable, args, spec.workspaceRoot)` — i.e. **cwd = workspaceRoot**, script path = extension-root-relative.
  4. `runCommandWithOutput` (lines 206–267): `cp.spawn(..., { stdio: ["ignore","pipe","pipe"], shell: false })`, streams stdout/stderr lines into the `CommandOutput` sink, resolves `{ exitCode: 0, stdout, stderr }` on exit 0, rejects with `CommandExecutionError` (lines 60–85: carries `executable, args, cwd, exitCode, stdout, stderr`) on non-zero exit.
- `executeScriptServiceCall` (`repo-automation-execute-script.ts` lines 43–71) is the service-side wrapper: it forwards `ScriptExecutionOptions` (`runtimeKind`, `bundledRelativePath`, `invocationId`, `args`, `workspaceRoot`), optionally parses one artifact path from stdout via `stdoutArtifactPattern` (`parseFirstArtifactPath` from `repo-automation-service-support.ts`), and returns `{ tool, workspaceRoot, summary, artifacts? }`.
- Error contract to MCP: a thrown `CommandExecutionError` propagates up through the dispatch `catch`, where `getStderrExcerpt` (lines 355–368) trims stderr to <= 8 non-empty lines for `stderr_excerpt`.
- MCP diagnostics sink: the server uses `createBufferedOutput()` (lines 101–114) per call — no terminal is ever created on the MCP path (asserted by `test/mcp-server.test.ts` lines 362–379).

**Contract a new discovery service call must follow:** accept `{ workspaceRoot, invocationId?, ...toolFields }`; run the CLI with cwd = `workspaceRoot`; log through the injected `CommandOutput`; return `RepoAutomationExecutionResult` (`{ tool, workspaceRoot, summary, artifacts? ... }`, `repo-automation-service.ts` lines 46–55); signal failure by throwing (preferably `CommandExecutionError` so `stderr_excerpt` works).

### Candidate approaches for invoking the Python CLI

**Approach A (recommended) — spawn the workspace's Python CLI, no bundling.** Extend `RuntimeKind` to `"powershell" | "python"` in `runtime-detection.ts` and add a Python probe (interpreter resolution order to be fixed at planning: workspace `.venv` interpreter, then `py`/`python` on PATH — the existing `findExecutableOnPath` at lines 39–61 already handles PATH/PATHEXT). Add a discovery-specific service-call helper (sibling of `repo-automation-execute-script.ts`) that invokes the CLI **as a module of the target workspace**, e.g. argv `[pythonExe, "-m", "scripts.discovery.<module>", ...args]` with cwd = `workspaceRoot`, reusing `runCommandWithOutput` for streaming/error semantics. Rationale: the `dev.discovery.*` commands are Poetry console scripts defined in this repository's `pyproject.toml` (verified convention: `[tool.poetry.scripts]` lines 47–69, e.g. `"dev.validate-json" = "scripts.dev_tools.validate_json:main"`); the code lives in the workspace, not the extension, so extension-root script resolution and VSIX bundling are unnecessary; `python -m` avoids requiring the Poetry venv's script shims on PATH. This wraps the CLI without re-authoring it and leaves all `resources/` mirroring to #9012.

**Rejected alternatives (brief):**
- *Bundle the discovery Python into the VSIX and re-add extension-root Python execution.* Requires reverting `.vscodeignore` `**/*.py` exclusion and mirroring Python into `resources/` — packaging/mirroring is explicitly #9012's responsibility, and it duplicates source that already ships in the workspace. Contradicts the migration direction of feature #240 (all bundled interpreted code is PowerShell-only).
- *Port the discovery commands to in-process TypeScript* (the pattern used by `validate_orchestration_artifacts` etc.). Violates this feature's non-negotiable constraint: the exposure layer re-authors no `dev.discovery.*` command.
- *Wrap via a bundled PowerShell shim that calls Python.* Adds an indirection layer with no benefit over Approach A and still needs a Python interpreter probe.

**Flag for the planner:** issue.md line 45–48 and spec.md lines 56–57 say "shell out to bundled Python via the existing `executeBundledScriptFromExtensionRoot` path." That wording is unsatisfiable as written on the current substrate; the acceptance criterion should be interpreted (or amended) as "the service call spawns the `dev.discovery.*` Python CLI as a subprocess" per Approach A.

---

## 3. VS Code command registration pattern (VERIFIED)

Two coordinated locations:

1. **Manifest:** `extensions/drm-copilot/package.json`, `contributes.commands` (lines 63–172). One `{ "command": "drmCopilotExtension.<camelCaseName>", "title": "drm-copilot: <Title>" }` entry per command. 28 commands exist today.
2. **Activation:** `extensions/drm-copilot/src/extension.ts`, `activate` (lines 109–479) builds one shared `RepoAutomationService` (lines 111–114) and delegates registration to per-family modules; every disposable is pushed to `context.subscriptions` (lines 460–478).
   - `registerRepoAutomationCommands` (`repo-automation-command-registration.ts` lines 14–21) fans out to `repo-automation-command-registration-admin.ts` and `repo-automation-command-registration-feature-workflows.ts`.
   - Registration idiom (e.g. `registerNewPotentialBugEntryCommand`, `repo-automation-command-registration-feature-workflows.ts` lines 24–61): `vscode.commands.registerCommand(id, async (...rawArgs) => {...})`; a `resolveWorkflowInvocation(output, commandId, () => resolve<X>Invocation(rawArgs))` call supports **direct argument invocation** (programmatic/test) with fallback to **interactive prompts** (`promptForChoice`, `promptForShortName`, etc. from `extension-command-helpers.ts`); both paths end in the same `options.service.<method>({ workspaceRoot: getWorkspaceRoot(), invocationId: commandId, ...input })` service call.

**How an MCP tool is "surfaced as a VS Code command":** there is no automatic bridge. The MCP tool and the VS Code command are two front-ends over the same `RepoAutomationService` method (touch-point 5). The MCP path enters via `mcp-server.ts` -> `dispatchRepoAutomationTool`; the VS Code path enters via `registerCommand` -> service method. The MCP server itself is surfaced to VS Code via `mcpServerDefinitionProviders` (`package.json` lines 37–41) and `registerMcpProvider` (`src/mcp-provider.ts` lines 15–66), which points a `McpStdioServerDefinition` at `out/mcp-server.js` run under `node` — no change needed there for new tools. `drmCopilotExtension.listMcpTools` (`repo-automation-command-registration-admin.ts` lines 359–391) renders `listRepoAutomationTools()` in a QuickPick and picks up new tools automatically.

For this feature: each discovery tool needs a `contributes.commands` entry plus a registration function (a new `discovery-command-registration.ts` module following the feature-workflows pattern keeps `extension.ts` under the 500-line cap — it is at 489 lines today).

---

## 4. MCP contract-test pattern under `extensions/drm-copilot/test/` (VERIFIED)

Jest, flat mirror of `src/` under `test/` (`jest.config.cjs` line 4: `testMatch: ["<rootDir>/test/**/*.test.ts"]`). Files a new tool must extend:

1. **`test/mcp-repo-automation-tool-definitions.test.ts`** — the definitions contract:
   - Lines 14–20: `REPO_AUTOMATION_TOOL_DEFINITIONS.map(d => d.name)` must `toEqual(REPO_AUTOMATION_TOOLS)` — one definition per union entry, **in union order**. Any union addition without a definition (or out of order) fails here.
   - Per-tool schema-shape assertions with `toMatchObject`, including `additionalProperties: false` and required-field checks (e.g. lines 47–61, 109–130, 155–171), and cross-file alignment with the base `toolDefinitions` (lines 22–45, 63–78, 132–153). New tools add analogous cases.
2. **`test/mcp-server.test.ts`** — end-to-end MCP contract over `InMemoryTransport` (SDK `Client` + server, lines 52–81):
   - `createMockService()` (lines 27–50) is a full `jest.Mocked<RepoAutomationService>`; widening the service interface **forces** this mock to gain the new methods (type error otherwise).
   - The `listTools` test (lines 83–109) asserts the exact advertised tool-name array — must be extended.
   - Per-tool dispatch tests assert: service called with camelCase-normalized input, `result.isError === false`, `structuredContent` matches `{ ok, tool, workspace_root, ... }` (e.g. lines 111–144); the invalid-input test asserts the resolver's thrown message surfaces as `summary` with `ok: false` **without** calling the service (lines 146–162); the no-terminal invariant (lines 362–379).
3. **`test/mcp-tool-inputs.test.ts`** (plus per-family variants `mcp-tool-inputs.codex-native-converter.test.ts`, `mcp-tool-inputs-epic-validation.test.ts`) — unit tests for each `resolve<X>ToolInput` (valid, missing, wrong-type, normalization cases).
4. **Handler/dispatch-focused suites** — `test/mcp-tools.codex-native-converter.test.ts`, `test/mcp-tools.push-down-claude.test.ts`, `test/repo-automation-render-subagent-tree.test.ts` call `dispatchRepoAutomationTool` directly with a mocked service; the render-subagent-tree suite is the best template for a new tool family (it covers definitions + dispatch + handler + service call added by one feature).
5. **VS Code command tests** — `test/extension.workflow-commands.test.ts`, `test/extension.run-poshqc-commands.test.ts` etc. use the harness in `test/extension-test-harness.ts` with a virtual `vscode` mock to drive registered commands (interactive and direct-args paths).
6. **Coverage gate** — `jest.config.cjs` `coverageThreshold` (lines 25–131) is **per-changed-file** (no `global` key, per issue #305 comment at lines 20–24): every new production file this feature adds must receive its own `{ lines: 85, branches: 75 }` entry.

The `test/` tree mirrors `src/` (`test/lib/<area>/...` for `src/lib/<area>/...`; flat `test/*.test.ts` for flat `src/*.ts`). In-memory fakes live beside tests (e.g. `test/lib/codex-native-converter/in-memory-file-system.ts`); temporary files are prohibited by repo test policy.

---

## 5. The `dev.discovery.*` command set to wrap (DESIGN-AGAINST-PLANNED)

**Explicit assumption flag:** none of the upstream commands exist in this worktree. The epic docs do not fix literal command names or flags; the upstream feature specs (#361/#362/#363/#364 per delegation; placeholder manifest ids #9003, #9005, #9006, #9009, #9010, #9014 in `epic.md` frontmatter lines 25–51) are not on the integration branch. Everything below is designed from `objective-source.md` sections 5, 7, 8, 9 (numbered item 9 = "CLI and MCP Integration", lines 101–104), 11, 12 and `epic.md` "## Shared Design" (lines 102–125), plus the verified naming convention in `pyproject.toml` `[tool.poetry.scripts]` (lines 47–69: `"dev.<kebab-name>" = "scripts.<package>.<module>:main"`). The wrapper's tool-name-to-CLI mapping must be centralized (one table module) so a rename upstream is a one-line change.

| Owning feature | Planned CLI (assumed shape) | Key arguments (assumed) | Proposed MCP tool name | VS Code command |
|---|---|---|---|---|
| validators (#9003) | `dev.discovery.validate` — argparse **subparser per artifact** (domain profile + 7 schemas), mirroring `validate_orchestration_artifacts.py` per epic.md lines 112–113 | `<artifact_type> --path <file>` | `validate_discovery_artifacts` (`artifact_type` enum + `artifact_path`, modeled on `validate_orchestration_artifacts`) | `drmCopilotExtension.validateDiscoveryArtifacts` |
| init + templates (#9005) | `dev.discovery.init` | target workspace root; optional profile path / force flag | `run_discovery_init` | `drmCopilotExtension.runDiscoveryInit` |
| analyzer framework, repo inventory (#9006) | `dev.discovery.analyze-repo` (language-neutral solution/project/file inventory, objective-source lines 91–99) | `--profile <domain-profile path>`; optional output root | `run_discovery_repo_inventory` | `drmCopilotExtension.runDiscoveryRepoInventory` |
| .NET/C# inventory (#9014) | `dev.discovery.analyze-dotnet` (namespace/type enumeration, event-subscription detection) | `--profile <path>`; optional output root | `run_discovery_dotnet_analyzer` | `drmCopilotExtension.runDiscoveryDotnetAnalyzer` |
| VSTO/Office analyzer (#9014) | `dev.discovery.analyze-vsto` (Ribbon-XML, COM-interop pattern detection) | `--profile <path>`; optional output root | `run_discovery_vsto_analyzer` | `drmCopilotExtension.runDiscoveryVstoAnalyzer` |
| acceptance scenarios (#9009) | `dev.discovery.generate-scenarios` (from feature contracts + parity/characterization evidence, objective-source lines 112–113) | `--profile <path>`; optional contract/scenario selectors | `run_discovery_scenario_generation` | `drmCopilotExtension.runDiscoveryScenarioGeneration` |
| reports (#9010) | `dev.discovery.report` with subcommands `coverage` / `parity` / `completion` (objective-source lines 115–116; epic.md line 154), or three sibling commands | `<report_type> --profile <path>`; optional output path | `run_discovery_report` with `report_type` enum `["coverage","parity","completion"]` (one tool, enum-dispatched — mirrors `validate_orchestration_artifacts`'s enum pattern rather than 3x touch-point duplication) | `drmCopilotExtension.runDiscoveryReport` |

Net: **7 MCP tools / 7 VS Code commands** (7 tools x 5 touch-points, if reports are enum-folded; 9 x 5 if upstream ships three separate report commands and one-tool-per-command fidelity is preferred). Whether #9014 ships one combined or two analyzer commands is likewise unresolved upstream — the table assumes two.

Domain-neutrality check for proposed names: no TaskMaster/TMW/Outlook/VSTO-as-domain/email/task-management identifier appears; "dotnet"/"vsto" name the analyzed **technology stack** declared by the epic itself (objective-source lines 96–97) and appear in the epic's own domain-neutral feature naming (`legacy-discovery-dotnet-vsto-analyzers`). All domain specificity (which repo, which paths) arrives via the `--profile` argument at runtime.

Common input-schema shape (all tools): optional `workspace_root` (reuse `workspaceRootProperty`), tool-specific fields as above, `additionalProperties: false`. Result artifacts (ledger/matrix/report paths) should be surfaced via the existing `artifacts` field, parsed from CLI stdout with a `stdoutArtifactPattern`-style regex once upstream fixes its stdout contract — another assumption to confirm at implementation time.

---

## 6. Changes required outside the five touch-points (VERIFIED)

1. **VS Code layer (in scope by definition):** `package.json` `contributes.commands` entries; a new registration module (pattern of `repo-automation-command-registration-feature-workflows.ts`); wiring in `extension.ts` `activate` + `context.subscriptions`.
2. **`runtime-detection.ts`:** under recommended Approach A, `RuntimeKind` widens to include `"python"` and `detectRuntime` gains a Python probe (lines 10, 175–211). This is a real sixth production touch-point specific to this feature.
3. **Base definitions file:** `src/mcp-tool-definitions.ts` should receive matching entries (convention enforced by cross-file alignment tests; see section 1, touch-point 2).
4. **`jest.config.cjs`:** per-file `coverageThreshold` entries for every new production file (lines 25–131 pattern).
5. **Test files:** `mcp-server.test.ts` mock-service and `listTools` expectation, `mcp-repo-automation-tool-definitions.test.ts` cases, new input/handler/service-call/command test files (section 4).
6. **Bundling — NOT a dependency under Approach A.** Verified: the extension bundles **no** Python (`.vscodeignore` lines 15–19); nothing in `esbuild-extension.cjs`/`esbuild-mcp-server.cjs` or `resources/` carries Python. Approach A spawns the CLI from the target workspace, so no VSIX packaging change is needed. `resources/` asset mirroring (agents/skills/hooks/schemas/templates of the epic) remains #9012's job (epic.md lines 120–122; issue.md lines 52–53); this feature adds no `resources/` assets. **Dependency assumption to record in the plan:** at runtime the target workspace must have the drm-copilot Python package (with the merged upstream discovery modules) importable by the resolved interpreter — i.e. the upstream features must be merged to the integration branch before this feature's tools can execute end-to-end; unit/contract tests are unaffected because the runner/spawn is faked.

---

## 7. TypeScript toolchain for this extension (VERIFIED)

From `extensions/drm-copilot/package.json` `scripts` (lines 174–185), run with cwd `extensions/drm-copilot`:

| Stage | Command | Notes |
|---|---|---|
| Format | `npm run format` | `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` |
| Lint | `npm run lint` | `eslint --no-error-on-unmatched-pattern src test` (flat config `eslint.config.mjs`) |
| Type check | `npm run typecheck` | `tsc -p ./ --noEmit` |
| Unit tests | `npm test` (= `npm run test:unit`) | `node run-jest.cjs` -> Jest 30 + ts-jest against `jest.config.cjs` / `tsconfig.jest.json`; `run-jest.cjs` rewrites `--testPathPattern` -> `--testPathPatterns` |
| Coverage | `npm run test:coverage` | `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`; v8 provider; output `extensions/drm-copilot/coverage/`; per-file thresholds in `jest.config.cjs` |
| Bundle (build sanity) | `npm run compile` / `npm run build` | `tsc --noEmit` + `esbuild-extension.cjs` + `esbuild-mcp-server.cjs` |

**Confirmed: the extension uses Jest, not Vitest** (devDependencies `jest ^30.0.0`, `ts-jest ^29.4.0`, `@jest/globals`; `jest.config.cjs`). The repo-level TypeScript rule's Vitest naming does not apply to this package. No dependency-cruiser config exists in `extensions/drm-copilot/` (no architecture-boundary stage at this package level). Coverage gates: line >= 85% / branch >= 75% per changed file, enforced by adding `coverageThreshold` entries.

Phase-0 baseline / Phase-2 final QC evidence must be written to `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (canonical `<FEATURE>/evidence/` location; non-canonical `artifacts/...` paths are rejected by hook).

---

## Behavior semantics (wrapper contract)

- **Success:** CLI exits 0 -> `{ ok: true, tool, workspace_root, summary, artifacts? }`; VS Code command logs to the `drm-copilot` output channel.
- **Failure:** CLI exits non-zero -> service throws `CommandExecutionError` -> dispatch returns `{ ok: false, summary: <error message>, stderr_excerpt: <=8 lines }` with MCP `isError: true` (`mcp-tools.ts` lines 101–114; `mcp-server.ts` lines 45–56).
- **Invalid input:** resolver throws before any service/spawn work; service mock untouched (contract-tested per `mcp-server.test.ts` lines 146–162).
- **Ordering invariant:** CLI-before-MCP-before-VS-Code — each tool's dispatch case calls only its handler; each VS Code command calls only the shared service method; neither re-implements CLI logic.
- **Edge cases to cover:** missing Python interpreter (probe failure message, mirroring the PowerShell probe error style at `runtime-detection.ts` lines 208–210); workspace without the discovery package installed (non-zero exit surfaces stderr excerpt); `workspace_root` omitted (defaults to `process.cwd()` on the MCP path, `mcp-tools.ts` lines 64–77; `getWorkspaceRoot()` on the VS Code path); enum-out-of-range `report_type`/`artifact_type`.

## Testing implications (strategy, no code)

1. Definitions contract: extend the union-order/definition-parity test and add per-tool schema assertions (both definition files), including `additionalProperties: false` and enum contents.
2. Input resolvers: unit tests per resolver (valid/missing/wrong-type/normalization) in `test/mcp-tool-inputs.<family>.test.ts`.
3. Dispatch + handlers: `dispatchRepoAutomationTool` tests with a mocked service per tool (success, thrown-error mapping to `ok:false` + `stderr_excerpt`).
4. Service calls: fake the spawn boundary (inject a fake `CommandOutput` + stub the execute helper or runner as `repo-automation-execute-script` tests do) — assert argv composition (`python -m scripts.discovery.<module>` + flags), cwd = workspaceRoot, artifact parsing, summary strings. No real subprocess, no temp files.
5. Runtime detection: tests for the new Python probe branch (found/not-found, PATHEXT behavior) mirroring existing `command-runtime.test.ts` coverage of `detectRuntime`.
6. End-to-end MCP: extend `mcp-server.test.ts` mock service + `listTools` array + one dispatch round-trip per new tool.
7. VS Code commands: harness-based tests for interactive-prompt and direct-args invocation per command.
8. Coverage: add per-file `jest.config.cjs` thresholds for every new production file; capture baseline and post-change `test:coverage` outputs under `<FEATURE>/evidence/coverage/`.

## Automation Feasibility

All work in this feature is autonomously automatable:

- Every deliverable is code, configuration, or tests inside this repository (`extensions/drm-copilot/src`, `test`, `package.json`, `jest.config.cjs`) plus feature docs/evidence.
- No third-party UI interaction, no external service, no credential, and no human approval step is required for implementation or verification; the full QC loop (format/lint/typecheck/Jest/coverage) runs headlessly via the npm scripts in section 7.
- The MCP contract tests run the real SDK server over an in-memory transport (no VS Code host needed); VS Code command tests use the existing virtual `vscode` mock harness.
- The only external dependency is sequencing, not human interaction: end-to-end execution of a wrapped tool against a real CLI requires the upstream `dev.discovery.*` features to be merged (section 6, item 6). This gates *live* verification, not implementation or automated testing, and is handled by the epic's wave ordering (this feature is Wave 3, `epic.md` lines 158–160).

No unautomatable step was discovered.

## Requirements mapping (acceptance criteria -> design)

| Acceptance criterion (issue.md lines 37–41) | Design element |
|---|---|
| Each in-scope command exposed with union + definition + dispatch + handler + service call | Sections 1 and 5: 7 tools x 5 touch-points, plus `runtime-detection.ts` Python probe and base-definitions parity |
| Each exposed command registered as a VS Code command | Section 3: `contributes.commands` + new registration module + `extension.ts` wiring |
| Wraps existing Python commands, re-authors none | Approach A: subprocess spawn of `dev.discovery.*` modules; central name/module/flag mapping table; no discovery logic in TS |
| Surface stays domain-neutral | Section 5 name audit; all domain input via `--profile` runtime argument |
| Jest tests mirrored under `test/` + MCP contract tests, line >= 85% / branch >= 75% | Section 4 + Testing implications; per-file `coverageThreshold` entries |

**Wording conflict to resolve at planning time:** issue.md/spec.md "shells out to the *bundled* Python script" vs the verified substrate (no bundled Python, PowerShell-only runtime). Recommend the plan restate the criterion as "spawns the workspace's `dev.discovery.*` CLI as a subprocess through the extension's command-runtime error/logging contract."

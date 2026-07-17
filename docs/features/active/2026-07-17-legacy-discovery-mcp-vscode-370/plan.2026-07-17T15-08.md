# legacy-discovery-mcp-vscode — Plan

- **Issue:** #370
- **Parent (optional):** epic `legacy-discovery-and-parity` (child #9011 placeholder)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T15-08
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-feature

## Required References

- Requirements sources (acceptance criteria): `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/spec.md` and `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md`
- Context: `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/issue.md`
- Research (authoritative substrate facts): `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/research/2026-07-17T16-30-legacy-discovery-mcp-vscode-370-research.md`
- Epic shared design: `docs/features/epics/legacy-discovery-and-parity/epic.md` (`## Shared Design`), `docs/features/epics/legacy-discovery-and-parity/objective-source.md` (scope items 8, 9, 11, 12)
- Policies: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/python.md`

**All work must comply with these policies; do not duplicate their content here.**

## Scope Summary

Expose seven discovery operations as MCP tools in the drm-copilot MCP server and as VS Code commands, wrapping the epic's `dev.discovery.*` Python CLI commands without re-authoring any of them. The exposure layer is domain-neutral. All changes live under `extensions/drm-copilot/` (Jest 30 + ts-jest; per-file coverage thresholds `{ lines: 85, branches: 75 }` in `jest.config.cjs`).

The seven tools and their VS Code command ids:

| MCP tool | VS Code command | Wrapped CLI module (assumed) |
|---|---|---|
| `validate_discovery_artifacts` | `drmCopilotExtension.validateDiscoveryArtifacts` | `scripts.discovery.validate` |
| `run_discovery_init` | `drmCopilotExtension.runDiscoveryInit` | `scripts.discovery.init` |
| `run_discovery_repo_inventory` | `drmCopilotExtension.runDiscoveryRepoInventory` | `scripts.discovery.analyze_repo` |
| `run_discovery_dotnet_analyzer` | `drmCopilotExtension.runDiscoveryDotnetAnalyzer` | `scripts.discovery.analyze_dotnet` |
| `run_discovery_vsto_analyzer` | `drmCopilotExtension.runDiscoveryVstoAnalyzer` | `scripts.discovery.analyze_vsto` |
| `run_discovery_scenario_generation` | `drmCopilotExtension.runDiscoveryScenarioGeneration` | `scripts.discovery.generate_scenarios` |
| `run_discovery_report` | `drmCopilotExtension.runDiscoveryReport` | `scripts.discovery.report` (`report_type` enum `["coverage", "parity", "completion"]`) |

**Substrate design (authoritative, per research):** the MCP server bundles no Python (feature #240; `RuntimeKind` is currently PowerShell-only; `.vscodeignore` excludes `**/*.py`). The service layer therefore spawns the WORKSPACE discovery CLI as a Python subprocess (`python -m scripts.discovery.<module>`) with `cwd = workspace_root`, reusing `runCommandWithOutput` / `CommandExecutionError` from `extensions/drm-copilot/src/command-runtime.ts`. No VSIX bundling change; `resources/` mirroring is #9012's responsibility and out of scope. The issue.md wording "shells out to the bundled Python script" is superseded by the spec's substrate correction.

**Upstream-dependency note (design-against-planned):** none of the wrapped `dev.discovery.*` commands exist on the integration branch today (upstream specs #361/#362/#363/#364 and placeholder children #9009/#9010/#9014 are Wave-0/1/2 work; execution ordering is the epic-orchestrator's responsibility). Live end-to-end invocation of any wrapped tool depends on those upstream merges. This plan's implementation and tests are unaffected: every test fakes or mocks the subprocess spawn boundary, so no `dev.discovery.*` command needs to exist for any task below to complete. All assumed command names, module paths, and flags are confined to the central mapping table so an upstream rename is a one-line change.

**File-size constraints (measured):** `extensions/drm-copilot/src/repo-automation-service.ts` is 498 lines and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` is 489 lines; both would exceed the 500-line cap if extended in place, so Phases 3 and 5 include unconditional extraction tasks. `extensions/drm-copilot/src/extension.ts` is 489 lines; registration logic must live in a new module.

**Evidence locations (non-overridable):** all evidence artifacts resolve under `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/<kind>/` (`baseline`, `qa-gates`). No `artifacts/` evidence path is used. `<TS>` below denotes an ISO-8601 `yyyy-MM-ddTHH-mm` timestamp captured at execution time.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Compliance and TypeScript Baseline

- [ ] [P0-T1] Read the policy files in the required order — `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, `.claude/rules/python.md` (Python CLI contracts are referenced by the wrapper design) — and record the read in `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/baseline/phase0-instructions-read.md`
  - Acceptance: artifact exists and contains `Timestamp:`, `Policy Order:`, and the explicit list of files read
- [ ] [P0-T2] Capture the formatting baseline by running `cd extensions/drm-copilot && npm run format` and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/baseline/baseline-format.<TS>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (including whether `git status --porcelain` shows any files rewritten by Prettier)
- [ ] [P0-T3] Capture the lint baseline by running `cd extensions/drm-copilot && npm run lint` and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/baseline/baseline-lint.<TS>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
- [ ] [P0-T4] Capture the type-check baseline by running `cd extensions/drm-copilot && npm run typecheck` and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/baseline/baseline-typecheck.<TS>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`
- [ ] [P0-T5] Capture the test-and-coverage baseline by running `cd extensions/drm-copilot && npm run test:coverage` and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/baseline/baseline-test-coverage.<TS>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values (baseline line % and branch % from the text-summary reporter) plus test pass/fail counts

### Phase 1 — Python Runtime Kind in runtime-detection.ts

- [ ] [P1-T1] Widen `RuntimeKind` in `extensions/drm-copilot/src/runtime-detection.ts` from `"powershell"` to `"powershell" | "python"` and extend `detectRuntime` with a Python interpreter probe (resolution order: workspace `.venv` interpreter, then `py`, then `python` via the existing `findExecutableOnPath` helper; empty `argsPrefix` suitable for `-m` module invocation; probe-failure error message mirroring the existing PowerShell probe style), updating the module doc comment that currently states no Python interpreter is probed
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0; existing PowerShell probe behavior is unchanged
- [ ] [P1-T2] Create `extensions/drm-copilot/test/runtime-detection.test.ts` (mirroring `src/runtime-detection.ts`) covering the Python probe: found via workspace `.venv`, found via `py`/`python` on PATH (including PATHEXT behavior on Windows), and not-found error message; reuse `extensions/drm-copilot/test/runtime-test-helpers.ts` fakes and verify existing PowerShell probe cases in `extensions/drm-copilot/test/command-runtime.test.ts` still pass
  - Acceptance: `cd extensions/drm-copilot && npm test` exits 0 with the new cases passing

### Phase 2 — Discovery Service-Call Helper and Central CLI Mapping Table

- [ ] [P2-T1] Create `extensions/drm-copilot/src/repo-automation-execute-discovery.ts` containing (a) the single central mapping table from each of the seven tool names to its Python module path (`scripts.discovery.<module>` per the Scope Summary table) and flag composition, and (b) an `executeDiscoveryServiceCall`-style helper that resolves the interpreter via `detectRuntime("python")`, builds argv `[pythonExe, "-m", "scripts.discovery.<module>", ...flags]`, spawns via `runCommandWithOutput` with `cwd = workspaceRoot`, streams through the injected `CommandOutput` sink, optionally parses one artifact path from stdout (`stdoutArtifactPattern`-style regex, marked as an assumption), returns `RepoAutomationExecutionResult`, and signals failure by letting `CommandExecutionError` propagate; include a header doc comment recording the design-against-planned status and the upstream `dev.discovery.*` merge dependency
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0; file <= 500 lines; no `dev.discovery.*` logic re-authored in TypeScript; no domain-specific identifier in the module
- [ ] [P2-T2] Create `extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts` faking the spawn boundary (no real subprocess, no temporary files) and asserting per tool: exact argv composition (`python -m scripts.discovery.<module>` plus flags, including `report_type` positional and `--profile`/`--path`/`--output-root`/`--force` composition), `cwd === workspaceRoot`, artifact-path parsing from stdout, summary strings, and non-zero-exit propagation as `CommandExecutionError` carrying stderr
  - Acceptance: `cd extensions/drm-copilot && npm test` exits 0 with the new suite passing

### Phase 3 — RepoAutomationService Discovery Methods

- [ ] [P3-T1] Extract the existing service contract declarations (the `RepoAutomationService` interface and its input/result type aliases) from `extensions/drm-copilot/src/repo-automation-service.ts` into a new `extensions/drm-copilot/src/repo-automation-service-contract.ts`, re-exporting every moved symbol from `repo-automation-service.ts` so all existing imports remain valid, to create headroom under the 500-line cap (the file is at 498 lines)
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0 and `npm test` exits 0 with no test changes; `repo-automation-service.ts` <= 440 lines
- [ ] [P3-T2] Add the seven discovery methods (one per tool in the Scope Summary table) to the `RepoAutomationService` interface and implement them on `DefaultRepoAutomationService` in `extensions/drm-copilot/src/repo-automation-service.ts` as thin delegations to the Phase 2 helper in `repo-automation-execute-discovery.ts`, and in the same change extend the `createMockService` factory in all four test files that build a full `jest.Mocked<RepoAutomationService>` — `extensions/drm-copilot/test/mcp-server.test.ts`, `extensions/drm-copilot/test/mcp-server-epic-validation.test.ts`, `extensions/drm-copilot/test/mcp-tools.codex-native-converter.test.ts`, and `extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts` — with the seven mocked `jest.fn()` entries so every mock builder stays type-complete against the widened interface
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0; `repo-automation-service.ts` and `repo-automation-service-contract.ts` each <= 500 lines; all four `createMockService` builders list every interface method (no builder missing a discovery method)
- [ ] [P3-T3] Create `extensions/drm-copilot/test/repo-automation-service.discovery.test.ts` verifying each of the seven service methods delegates to the discovery helper with the expected tool name, argument forwarding, `workspaceRoot`, and `invocationId` (helper boundary mocked; no real subprocess)
  - Acceptance: `cd extensions/drm-copilot && npm test` exits 0 with the new suite passing

### Phase 4 — Discovery Input Resolvers and Handlers

- [ ] [P4-T1] Create `extensions/drm-copilot/src/mcp-tool-inputs-discovery.ts` with seven `resolve<X>ToolInput` resolvers (one per tool) using the normalization helpers from `extensions/drm-copilot/src/workflow-command-arguments.ts`, including exported enum constants for `artifact_type` (domain profile plus the seven discovery schema artifact kinds — literals fixed here as the single design-against-planned source) and `report_type` (exactly `["coverage", "parity", "completion"]`); every resolver throws a specific `Error` on missing/wrong-type/out-of-enum input before any service or spawn work
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0; file <= 500 lines
- [ ] [P4-T2] Create `extensions/drm-copilot/test/mcp-tool-inputs-discovery.test.ts` covering, per resolver: valid input, missing required field, wrong-type field, enum-out-of-range rejection (`artifact_type`, `report_type`), optional-field omission, and `workspace_root` normalization
  - Acceptance: `cd extensions/drm-copilot && npm test` exits 0 with the new suite passing
- [ ] [P4-T3] Create `extensions/drm-copilot/src/mcp-handlers/discovery-handlers.ts` with seven handlers following the existing handler pattern (resolve raw input via the Phase 4 resolver, then call the matching `RepoAutomationService` method)
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0; file <= 500 lines

### Phase 5 — MCP Tool Surface Lockstep (Union, Definitions, Dispatch, Contract Tests)

- [ ] [P5-T1] In one lockstep change, append the seven tool names to `REPO_AUTOMATION_TOOLS` in `extensions/drm-copilot/src/repo-automation-tool-names.ts` and add the seven corresponding `case` arms to the exhaustive `dispatchRepoAutomationTool` switch (no `default`) in `extensions/drm-copilot/src/mcp-tools.ts`, each case calling only its Phase 4 handler via the existing `toMcpToolResult` wrapper
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0 (union and switch changed atomically, so the tree is never uncompilable); `mcp-tools.ts` <= 500 lines
- [ ] [P5-T2] Create `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts` exporting the seven discovery `ToolDefinition` entries (in union order; each reusing `workspaceRootProperty` from `mcp-push-down-schema-properties.ts`; each with JSON-Schema-shaped `inputSchema`, `additionalProperties: false`, correct `required` arrays, and enum values imported from or equal to the Phase 4 resolver constants), and spread them at the end of `REPO_AUTOMATION_TOOL_DEFINITIONS` in `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (489 lines today; the spread keeps it under the 500-line cap)
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0; both files <= 500 lines; every new definition sets `additionalProperties: false`
- [ ] [P5-T3] Spread the same seven discovery definitions into the base `toolDefinitions` array in `extensions/drm-copilot/src/mcp-tool-definitions.ts` (aligned base entries; alignment holds by construction because both files consume `mcp-discovery-tool-definitions.ts`)
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0; file <= 500 lines
- [ ] [P5-T4] Extend `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` with per-tool assertions for the seven discovery tools: schema shape (`additionalProperties: false`, `required` contents), `report_type` enum exactly `["coverage", "parity", "completion"]`, `artifact_type` enum equal to the resolver's exported constant, cross-file alignment with `toolDefinitions`, and confirm the existing union-order/definition-parity test passes over the widened union
  - Acceptance: `cd extensions/drm-copilot && npm test` exits 0 with the extended suite passing
- [ ] [P5-T5] Create `extensions/drm-copilot/test/mcp-tools.discovery.test.ts` calling `dispatchRepoAutomationTool` with a mocked service, asserting per tool: success mapping to the snake_case MCP result (`ok: true, tool, workspace_root, summary, artifacts?`), thrown `CommandExecutionError` mapping to `ok: false` with `stderr_excerpt` (<= 8 lines), and invalid input rejected by the resolver with the service never called
  - Acceptance: `cd extensions/drm-copilot && npm test` exits 0 with the new suite passing
- [ ] [P5-T6] Extend `extensions/drm-copilot/test/mcp-server.test.ts`: add the seven tool names to the `listTools` exact-array expectation, add one dispatch round-trip per discovery tool over `InMemoryTransport` (mocked service; camelCase-normalized input assertion; `structuredContent` shape), add an invalid-enum round-trip for `run_discovery_report` and `validate_discovery_artifacts`, and confirm the no-terminal-on-MCP-path invariant test still passes
  - Acceptance: `cd extensions/drm-copilot && npm test` exits 0 with the extended suite passing

### Phase 6 — VS Code Command Layer

- [ ] [P6-T1] Add the seven `contributes.commands` entries to `extensions/drm-copilot/package.json` using the command ids in the Scope Summary table and `"drm-copilot: <Title>"` titles, with no domain-specific identifier in any id or title
  - Acceptance: `cd extensions/drm-copilot && npm run format && npm run lint` exit 0; the seven entries are present alongside the existing commands
- [ ] [P6-T2] Create `extensions/drm-copilot/src/discovery-command-registration.ts` exporting a `registerDiscoveryCommands`-style function that registers the seven commands following the `repo-automation-command-registration-feature-workflows.ts` pattern: `resolveWorkflowInvocation` for direct-argument invocation with interactive-prompt fallback (prompt helpers from `extension-command-helpers.ts`), each command calling only its shared `RepoAutomationService` method with `workspaceRoot = getWorkspaceRoot()` and `invocationId = <commandId>`, returning disposables
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0; file <= 500 lines; no CLI logic re-implemented
- [ ] [P6-T3] Wire the discovery registration into `activate` in `extensions/drm-copilot/src/extension.ts` (one import plus one registration call pushing all returned disposables to `context.subscriptions`)
  - Acceptance: `cd extensions/drm-copilot && npm run typecheck` exits 0; `extension.ts` <= 500 lines (489 today)
- [ ] [P6-T4] Create `extensions/drm-copilot/test/extension.discovery-commands.test.ts` using `extensions/drm-copilot/test/extension-test-harness.ts` to drive each of the seven registered commands through both the direct-argument path and the interactive-prompt path, asserting the mocked service method is called with the expected input and output is logged to the output channel
  - Acceptance: `cd extensions/drm-copilot && npm test` exits 0 with the new suite passing

### Phase 7 — Coverage Gates and Policy Audits

- [ ] [P7-T1] Add per-file `coverageThreshold` entries of `{ lines: 85, branches: 75 }` to `extensions/drm-copilot/jest.config.cjs` for every new production file (`src/repo-automation-execute-discovery.ts`, `src/mcp-tool-inputs-discovery.ts`, `src/mcp-handlers/discovery-handlers.ts`, `src/mcp-discovery-tool-definitions.ts`, `src/discovery-command-registration.ts`, and `src/repo-automation-service-contract.ts` unless it is a type-only module with no executable behavior, in which case record that policy-based omission in the task note), and verify entries already exist for the modified files (`src/runtime-detection.ts`, `src/mcp-tools.ts`, `src/repo-automation-service.ts`, `src/mcp-repo-automation-tool-definitions.ts`, `src/mcp-tool-definitions.ts`), adding any that are missing
  - Acceptance: `cd extensions/drm-copilot && npm run test:coverage` exits 0 with all per-file thresholds satisfied
- [ ] [P7-T2] Verify domain neutrality by searching all files added or modified by this feature (including `package.json` command entries) for the identifiers `TaskMaster`, `TMW`, `Outlook`, `email`, and `task-management`, and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/domain-neutrality.<TS>.md` with `Timestamp:`, `SearchScope:`, `SearchPatterns:`, and `SearchResult:`
  - Acceptance: artifact exists with zero domain-specific matches in the exposure layer (or each match justified as non-domain usage)
- [ ] [P7-T3] Verify the 500-line cap on every production and test file touched by this feature (`repo-automation-service.ts`, `mcp-repo-automation-tool-definitions.ts`, `mcp-tool-definitions.ts`, `mcp-tools.ts`, `extension.ts`, all new `src/` and `test/` files) and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/file-size-audit.<TS>.md` listing each file and its line count
  - Acceptance: artifact exists with `Timestamp:` and every listed file <= 500 lines
- [ ] [P7-T4] Verify the design-against-planned documentation is in place: the header doc comment of `extensions/drm-copilot/src/repo-automation-execute-discovery.ts` records the assumed upstream command contracts and states that live end-to-end execution depends on the upstream `dev.discovery.*` merges (epic wave ordering), and all assumed names/flags appear only in the mapping table and the enum constants module
  - Acceptance: header comment present; a `grep` for `scripts.discovery.` under `extensions/drm-copilot/src/` matches only `repo-automation-execute-discovery.ts` (and string constants it exports)

### Phase 8 — Final QA Loop (TypeScript)

- [ ] [P8-T1] Run `cd extensions/drm-copilot && npm run format` and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-format.<TS>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (including whether any file was rewritten); if files were rewritten, the loop restarts at P8-T1 after the rewrite is committed to the working tree
- [ ] [P8-T2] Run `cd extensions/drm-copilot && npm run lint` and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-lint.<TS>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; `EXIT_CODE: 0`
- [ ] [P8-T3] Run `cd extensions/drm-copilot && npm run typecheck` and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-typecheck.<TS>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; `EXIT_CODE: 0`
- [ ] [P8-T4] Run `cd extensions/drm-copilot && npm run test:coverage` and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-test-coverage.<TS>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric post-change line % and branch % (text-summary reporter) plus test counts; `EXIT_CODE: 0` with all per-file thresholds satisfied
- [ ] [P8-T5] Verify the loop completed as a single clean pass: if any of P8-T1 through P8-T4 failed or modified files, restart the loop from P8-T1 and repeat until all four steps pass in one pass without file changes; record the final loop confirmation in `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/final-qc-loop.<TS>.md`
  - Acceptance: artifact contains `Timestamp:` and `Output Summary:` stating the number of loop iterations and that the final iteration passed all four steps cleanly
- [ ] [P8-T6] Compare coverage against the Phase 0 baseline and record `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/qa-gates/coverage-delta.<TS>.md` reporting: baseline line/branch % (from `evidence/baseline/baseline-test-coverage.<TS>.md`), post-change line/branch % (from P8-T4), and per-new-file line/branch % for every new production file
  - Acceptance: artifact contains `Timestamp:` and numeric values for all three categories; every new production file reports line >= 85% and branch >= 75%; no coverage regression on changed lines; if any required numeric value is unavailable the outcome is remediation-required, not PASS

## Test Plan

- Unit: runtime Python-probe cases (`test/runtime-detection.test.ts`); discovery helper argv/cwd/artifact/error cases (`test/repo-automation-execute-discovery.test.ts`); service-method delegation (`test/repo-automation-service.discovery.test.ts`); resolver validation matrix (`test/mcp-tool-inputs-discovery.test.ts`); dispatch/handler routing and error mapping (`test/mcp-tools.discovery.test.ts`). All spawn boundaries are faked; no real subprocess, no temporary files, no dependency on the not-yet-merged upstream `dev.discovery.*` commands.
- Contract/integration: definitions contract (union order, one-definition-per-union-entry, cross-file alignment, `additionalProperties: false`, enum contents) in `test/mcp-repo-automation-tool-definitions.test.ts`; end-to-end MCP `listTools` exact-array and per-tool dispatch round-trips over `InMemoryTransport` with the no-terminal invariant in `test/mcp-server.test.ts`.
- VS Code: harness-based direct-args and interactive invocation per command in `test/extension.discovery-commands.test.ts`.
- Coverage evidence: baseline `evidence/baseline/baseline-test-coverage.<TS>.md`; post-change `evidence/qa-gates/final-qc-test-coverage.<TS>.md`; comparison `evidence/qa-gates/coverage-delta.<TS>.md` (all under `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/`).

## Open Questions / Notes

- Upstream dependency: live end-to-end invocation of the wrapped tools requires the upstream `dev.discovery.*` features (Wave-0/1/2 of the epic) to be merged; the epic-orchestrator owns that execution ordering. This plan is implementable and fully testable before those merges because every test mocks or fakes the subprocess boundary.
- Design-against-planned assumptions confined to single locations: CLI module paths and flag composition live only in the mapping table (`src/repo-automation-execute-discovery.ts`); the `artifact_type` enum literals live only in `src/mcp-tool-inputs-discovery.ts` and are consumed by the tool definitions and asserted equal by contract tests. An upstream rename is a one-line change.
- Wording conflict resolved: issue.md's "shells out to the bundled Python script" is unsatisfiable on the current substrate (no bundled Python since feature #240); the spec's substrate correction (workspace Python subprocess, `cwd = workspace_root`) is authoritative and this plan implements it.
- The stdout artifact-path parsing regex is an assumption to confirm when the upstream stdout contract is fixed; it is isolated in the discovery helper.
- `run_discovery_report` folds the three report kinds into one enum-dispatched tool (7 tools total). If upstream ships three separate report commands and per-command fidelity is later preferred, the split affects only the mapping table, one definition, one resolver, and one dispatch case per added tool.

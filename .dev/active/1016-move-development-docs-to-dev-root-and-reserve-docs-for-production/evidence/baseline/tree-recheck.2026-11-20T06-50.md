# Tree Re-check ([P0-T2])

Timestamp: 2026-11-20T06-50
Command: sh SCRATCH/issue-1016-register.sh (grep -cF per register entry under extensions/drm-copilot); grep of child 2 exports; reads of the registration surfaces; git -C <worktree> merge-base <ref> HEAD then git -C <worktree> diff --name-status <merge base> <ref> -- <overlap files>; git -C <worktree> status --porcelain; wc -l <edited files>
EXIT_CODE: 0
Output Summary: every register entry PRESENT (0 MOVED); all 9 child 2 exports MATCH (0 DIFFERS); all (c) anchors present; pinned values recorded (`toHaveLength(51)`, 51 expected names); overlap listing empty for both refs; worktree clean; largest edited file 682 lines (jest.config.cjs, +1 planned), none reaches 700. Result: premise holds, no BLOCKED condition.

HEAD: equals the `origin/epic/shared-agent-harness-layer-integration` tip after the [P0-T1] fetch.

## (a) Citation Register (EXT = extensions/drm-copilot)

| Entry | Result |
| --- | --- |
| `EXT/src/repo-automation-tool-names.ts` `REPO_AUTOMATION_TOOLS`, `RepoAutomationToolName` | PRESENT |
| `EXT/src/mcp-repo-automation-tool-definitions.ts` `REPO_AUTOMATION_TOOL_DEFINITIONS`, `ToolDefinition` | PRESENT |
| `EXT/src/mcp-tool-definitions.ts` `toolDefinitions` | PRESENT |
| `EXT/src/mcp-docs-tool-definitions.ts` `DOCS_TOOL_DEFINITIONS` | PRESENT |
| `EXT/src/mcp-discovery-tool-definitions.ts` `DISCOVERY_TOOL_DEFINITIONS` | PRESENT |
| `EXT/src/mcp-tools.ts` `dispatchRepoAutomationTool`, `toFailureToolResult`, `toMcpToolResult`, `listRepoAutomationTools` | PRESENT |
| `EXT/src/mcp-server.ts` `main`, `createRepoAutomationMcpServer` | PRESENT |
| `EXT/src/mcp-provider.ts` spawns `out/mcp-server.js` | PRESENT |
| `EXT/src/repo-automation-service-contract.ts` `RepoAutomationService`, `RepoAutomationExecutionResult`, `resolveOrchestrationTopology?` | PRESENT |
| `EXT/src/repo-automation-service.ts` `DefaultRepoAutomationService`, `createRepoAutomationService` | PRESENT |
| `EXT/src/lib/subprocess-runner.ts` `CommandRunOptions`, `CommandRunner`, `SubprocessRunner` | PRESENT |
| `EXT/src/lib/file-system.ts` `FileSystem`, `RealFileSystem`, `ensureDir` | PRESENT |
| `EXT/jest.config.cjs` `coverageThreshold`; `EXT/jest.docs-coverage.json`; `EXT/jest.discovery-coverage.json` | PRESENT |
| `EXT/package.json` scripts `lint`, `typecheck`, `test:coverage`, `format` | PRESENT |
| root `jest.config.cjs` `testMatch` | PRESENT |
| `EXT/test/mcp-server-test-service.ts` `EXPECTED_REPO_AUTOMATION_TOOL_NAMES`, `createMockService` | PRESENT |
| `mcp-server.test.ts` "registers the semantic repo automation tools" | PRESENT |
| `mcp-discovery-authority-tool-definitions.test.ts` "advertises all nineteen discovery tools in union order" | PRESENT |
| `mcp-discovery-tool-definitions.test.ts` "keeps the definition list aligned with the widened union order" | PRESENT |
| `mcp-repo-automation-tool-definitions.test.ts` "defines one schema entry for every advertised repo automation tool" | PRESENT |
| `mcp-repo-automation-tool-definitions.test.ts` "lists workspace_root in inputSchema.required for every repo automation tool (all 28)" | PRESENT |
| `mcp-docs-tool-definitions.test.ts` "spreads the same definition objects into both definition surfaces" | PRESENT |
| `packaging/discovery-resources.test.ts` (three named tests) | PRESENT |
| `packaging/mcp-server-prepack.test.ts` | PRESENT |
| `lib/subprocess-runner.test.ts` "passes cwd through to spawnSync when provided" | PRESENT |
| `mcp-tools.workspace-root.test.ts` `createMockService` | PRESENT |
| `discovery-coverage-contracts.test.ts` | PRESENT |
| `packages/mcp-server/package.json` `bin`, `files`, `build`; `packages/mcp-server/README.md` | PRESENT |
| `EXT/README.md` `### Exposed MCP Tools`, `### MCP Input Summary` | PRESENT |
| `docs/features/templates/policy_audit/` templates | PRESENT |
| Child 2 exports in `EXT/src/lib/development-docs/root.ts` and `feature-folder-name.ts` | PRESENT |

## (b) Child 2 exports against child 2 spec `## API / CLI Surface`

| Export | Result |
| --- | --- |
| `parseFeatureFolderName(name: string): FeatureFolderName` | MATCH |
| `formatFeatureFolderName(issueNumber: number, feature: string): string` | MATCH |
| `stripDateFirstPrefix(stem: string): string` | MATCH |
| `FeatureFolderName` union (date-first, issue-first, other) | MATCH |
| `developmentDocsPath(root, area): string` | MATCH |
| `resolveDevelopmentDocsRoot(reader, workspaceRoot): DevelopmentDocsRoot` | MATCH (first parameter is the structural `DevelopmentDocsReader`, which the repository `FileSystem` satisfies; callers passing a `FileSystem` type-check as the spec states) |
| `KNOWN_DEVELOPMENT_DOCS_ROOTS: ReadonlyArray<DevelopmentDocsRoot>` = `["docs/features", ".dev"]` | MATCH |
| `DevelopmentDocsArea` (12 members) | MATCH |
| member `"discovery-templates"` | MATCH |

## (c) Registration anchors after #1051

| Anchor | Result |
| --- | --- |
| `"run_docs_check"` is the first docs name in `REPO_AUTOMATION_TOOLS` | present (directly after `render_subagent_tree`) |
| `...DOCS_TOOL_DEFINITIONS` spread in `REPO_AUTOMATION_TOOL_DEFINITIONS` | present (followed by `...PUSH_DOWN_INTEGRATION_TOOL_DEFINITIONS`, then `...DISCOVERY_TOOL_DEFINITIONS`) |
| `...DOCS_TOOL_DEFINITIONS` spread in `toolDefinitions` | present (same order) |
| `dispatchRepoAutomationTool` holds one `case` per name | present (51 `case "` lines, 51 names) |

Pinned values (records):

- `REPO_AUTOMATION_TOOLS` length pin in "advertises all nineteen discovery tools in union order": `toHaveLength(51)`; [P2-T3] raises it to 52.
- `EXPECTED_REPO_AUTOMATION_TOOL_NAMES`: 51 entries, `run_docs_check` through `validate_docs_artifacts`, then `detect_push_down_integration`, `validate_push_down_integration`, then the discovery names.

Notes (records, not mismatches):

- `mcp-docs-tool-definitions.test.ts` "spreads the same definition objects into both definition surfaces" now pins `next: "detect_push_down_integration"` (the #1051 tools follow the docs block), not `validate_discovery_artifacts` as the [P2-T3] disposition reason states. The test checks the item after the docs block; the insertion lands before the docs block, so the "unchanged" disposition holds.
- Jest readers of `repo-automation-tool-names.ts` not named in [P2-T3], each unaffected: `mcp-handlers/push-down-integration-handlers.test.ts` (asserts the two names after `validate_docs_artifacts`), `push-down-wrapper-compatibility.test.ts`, `mcp-discovery-authority-tools.test.ts`, `mcp-discovery-authority-tools.gate.test.ts` (type import only). They run in the phase-gate Jest runs.
- `config/orchestration-routing.json` lists docs tools in per-agent `mcp_tools`; it pins no complete name set and is unaffected.
- `ProcessReductionChain.Ledger.Tests.ps1` disposition ([P2-T5]): the `0010` patch hunk for `EXT/jest.config.cjs` has context around the `epic-orchestrator-state-wave-barrier.ts` entry, far below the spread lines at the head of `coverageThreshold`; `...pushDownCoverageThresholds` now follows `...docsCoverageThresholds`.

## (d) Upstream changes to the overlap files (spec `## Execution Preconditions`)

| Ref | Derivation | Commits on ref since merge base | Overlap files changed |
| --- | --- | --- | --- |
| `origin/main` | merge base of `origin/main` and `HEAD` | 0 | none |
| `INTEGRATION` | merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD` | 0 | none |

`git status --porcelain`: empty (clean worktree).

## (e) Physical line counts of existing files this plan edits

| File | Lines | Planned growth |
| --- | --- | --- |
| `EXT/src/lib/subprocess-runner.ts` | 142 | small |
| `EXT/src/repo-automation-tool-names.ts` | 55 | +1 |
| `EXT/src/mcp-repo-automation-tool-definitions.ts` | 436 | +2 |
| `EXT/src/mcp-tool-definitions.ts` | 473 | +2 |
| `EXT/src/mcp-tools.ts` | 488 | about +5 |
| `EXT/src/repo-automation-service-contract.ts` | 338 | about +5 |
| `EXT/src/repo-automation-service.ts` | 513 | about +15 |
| `EXT/src/mcp-server.ts` | 136 | about +15 |
| `EXT/jest.config.cjs` | 682 | +2 |
| `EXT/test/mcp-server-test-service.ts` | 229 | +1 |
| `EXT/test/mcp-discovery-authority-tool-definitions.test.ts` | 198 | 0 |
| `EXT/test/lib/subprocess-runner.test.ts` | 139 | about +30 |
| `EXT/README.md` | 319 | Markdown (exempt) |
| `packages/mcp-server/README.md` | 50 | Markdown (exempt) |

No file reaches 700 with its planned growth.

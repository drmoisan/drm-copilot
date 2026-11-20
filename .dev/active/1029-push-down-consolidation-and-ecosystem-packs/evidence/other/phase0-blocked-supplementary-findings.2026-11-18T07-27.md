# Phase 0 Supplementary Findings After the P0-T1 Block

Timestamp: 2026-11-18T07-27
Command: sh SCRATCH/issue-1029-tree-recheck.sh; gh issue view 1029 --json state,comments; gh issue view 1018 --json state,body,comments; grep over extensions/drm-copilot/jest.config.cjs and extensions/drm-copilot/run-jest.cjs
EXIT_CODE: 0
Output Summary: These are read-only checks run after P0-T1 recorded `Result: BLOCKED`, so the one plan revision can cover them. P0-T2 and P0-T3 are not executed or checked off; their records will be written when the revised plan runs. All cited symbols and files are present. Four line counts have drifted from the plan text. No owner answers are recorded on #1029 or #1018.

## P0-T2 citation check (read-only, at HEAD)

- Every symbol the plan cites is present under `extensions/drm-copilot/src` or `extensions/drm-copilot/test`. The symbols checked are `DESTINATION_WRITE_DECORATORS`, `VIRTUAL_RESOURCE_DIRECTORIES`, `VIRTUAL_RESOURCE_PAIRS`, `VIRTUAL_ROOT_FOLDERS`, `ROOT_FOLDERS`, `MERGED_RELATIVE_PATHS`, `ROUTING_MERGE_RELATIVE_PATH`, `EXCLUDED_RELATIVE_PATHS`, `RoutingConfigFileSystem`, `CodexFilteringFileSystem`, `COPILOT_ROOT_FOLDERS`, `PushDownFileResult`, `renderPushDownSummary`, `EXCLUSION_CONFLICT_LINE_PREFIX`, `assertManifestPathIsRootLevel`, `stringifySorted`, `ExclusionFilterFileSystem`, `ExcludingFileSystem`, `RoutingMergeFileSystem`, `mergeClaudeGitignore`, `deliverDestinationGitignore`, `LOCAL_RUNTIME_RELATIVE_DIRECTORIES`, `ReadThroughPushDownFileSystem`, `buildInMemoryFileSystem`, `enumerateSourceFiles`, `rewriteTextReferences`, `createRepoAutomationService`, `dispatchRepoAutomationTool`, `REPO_AUTOMATION_TOOL_DEFINITIONS`, `toolDefinitions`, `toMcpToolResult`, `RepoAutomationMcpToolResult`, `copilotPushDownSelectionProperties`, `resolvePushDownCopilotCustomizationsToolInput`, `ManifestError`, `seedClaudeBundle`, `seedCodexBundle`, the options and summary types, `PushDownServiceCallResult` and `RepoAutomationExecutionResult`.
- `PRE_EXISTING_UNRELATED_AGENT_EXCEPTIONS`, `PRE_EXISTING_UNRELATED_SKILL_EXCEPTIONS` and `REQUIRED_PACK_MANIFESTS` are present under `tests/scripts/`.
- Every cited test and production file is present.
- `extensions/drm-copilot/jest.config.cjs` still requires `jest.discovery-coverage.json` and `jest.docs-coverage.json` and spreads both into `coverageThreshold` (the D9 shape). Its `testMatch` is `**/test/**/*.test.ts`, and `run-jest.cjs` has no integration filter.

Line counts that differ from the plan text:

| File | Plan text | HEAD | Effect |
| --- | --- | --- | --- |
| `extensions/drm-copilot/jest.config.cjs` | 596 (D9, Pre-Mortem) | 624 | D9 reasoning unchanged (above the 500 guidance tier) |
| `PD/claude-customizations.ts` | 496 (D10, Pre-Mortem) | 497 | D10 reasoning unchanged |
| `extensions/drm-copilot/src/repo-automation-service.ts` | 476 (Pre-Mortem) | 495 | P3-T2 caps it at 500 lines, which leaves 5 lines of headroom for the `PushDownCopilotCustomizationsInput` signature change |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tools.ts` | 483, 473 | 483, 473 | none |

## P0-T3 owner answers (read-only)

- Issue #1029 is open with 0 comments. Issue #1018 is open with 0 comments.
- The #1029 body records no answer to Q1 or O-1 to O-12. All thirteen questions therefore resolve to the spec defaults, and no non-default answer would change a task.

# Preflight Fixes (Stage A, Round 2)

Timestamp: 2026-10-31T00-01
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T18-59.md
Directive: PREFLIGHT VALIDATION ONLY (stage A, second and final round)

## Fixes

1. `## Scope and Conventions` | stale heading citation | The user-story heading is `### (b) Destination migration via` followed by `npx` in backticks; the citation omitted the backticks. Citation now reproduces the heading text. Intent unchanged.
2. [P2-T1] | stale heading citation | The spec heading is `### MCP tool` followed by `migrate_development_docs` in backticks; the citation omitted the backticks. Citation now reproduces the heading text. Intent unchanged.
3. [P2-T5] | stale heading citation | The dispatch-test paragraph cited the spec heading as `### MCP tool` with the tool name outside the span. Citation now reproduces the full heading text. The quoted output rule and the four dispatch cases are unchanged.

## Revision Verification (round 1 substantive defect)

- [P2-T5] now creates `EXT/test/mcp-tools.development-docs.test.ts` with dispatch cases (a) to (d). Verified against the tree: `dispatchRepoAutomationTool` wraps its `switch` in a `try`/`catch` that returns `toFailureToolResult(toolName, workspaceRoot, error)`, whose `summary` is the error message, so cases (b), (c) and (d) observe `ok: false` with the handler, input-resolution or rejection message; `toMcpToolResult` copies `tool`, `summary` and `artifacts` from the service result, so case (a) is observable. `createMockService` exists in `EXT/test/mcp-tools.workspace-root.test.ts` and that suite mocks only `vscode` as a virtual module.
- [P4-T8] runs the dispatch suite; [P4-T6] keeps the no-decrease condition for `mcp-tools.ts`; the Pre-Mortem `Coverage` bullet names the dispatch suite.
- Sibling checks: `mcp-discovery-authority-tool-definitions.test.ts` asserts `REPO_AUTOMATION_TOOLS` length 43 (update to 44 is named); `mcp-discovery-tool-definitions.test.ts` and `mcp-repo-automation-tool-definitions.test.ts` assert definition order equals `REPO_AUTOMATION_TOOLS` (insertion after `render_subagent_tree` and the spread before `...DISCOVERY_TOOL_DEFINITIONS` keep the orders equal); `packaging/discovery-resources.test.ts` requires a `case` per tool name in `mcp-tools.ts` (satisfied by [P2-T5]). [P4-T4] token search covers created test files only and the dispatch suite mocks no `node:child_process`.

## Validators

- `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`: EXIT_CODE 0, "plan validation passed".
- MCP `validate_orchestration_artifacts` (`artifact_type: plan`): ok true.

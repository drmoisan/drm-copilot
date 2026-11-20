# Preflight Fixes - Issue #1051 (confirming pass)

Timestamp: 2026-11-14T16-48
Plan: docs/features/active/2026-10-31-push-down-integration-mcp-tools-and-skill-1051/plan.2026-11-14T10-43.md
Mode: single-pass preflight (DIRECTIVE: PREFLIGHT VALIDATION ONLY), confirming pass after the one planner revision; task text edits only, no task added, removed or reordered. The earlier record `preflight-fixes.2026-11-14T16-29.md` is unchanged.

## Fixes

1. `[P2-T3]` | validator-blind changed-behavior disposition (execution-environment brief, `## Preflight Defect Classes the Validator Cannot See`) | `spreads the same definition objects into both definition surfaces` in `EXT/test/mcp-docs-tool-definitions.test.ts` was listed as unchanged. The test locates the docs slice by the index of `run_docs_check` and asserts that the name following the slice is `validate_discovery_artifacts` on both surfaces. [P2-T3] spreads `PUSH_DOWN_INTEGRATION_TOOL_DEFINITIONS` after `...DOCS_TOOL_DEFINITIONS`, so the following name becomes `detect_push_down_integration` and the test would fail, which would make the task's own acceptance ("every existing test named in this task passes") unsatisfiable. The disposition now reads "updated", with the expected `next` value changed to `detect_push_down_integration` and the reason stated. The test keeps its meaning (the docs slice is spread as the same objects and is followed by the next tool family); the task acceptance text is unchanged.
2. `## Artifact Language Classification` | consequential listing | `EXT/test/mcp-docs-tool-definitions.test.ts` added to the edited TypeScript test files, matching fix 1.
3. `[P2-T2]` | design clarification without assertion change | `ToolDefinition.name` is typed `RepoAutomationToolName` (`EXT/src/mcp-repo-automation-tool-definitions.ts`), which does not hold either new name until [P2-T3] registers them, so a definitions module typed as `ToolDefinition` would fail the type-check step of the [P2-T2] task check. The task now states that the definitions are typed as `Omit<ToolDefinition, "name">` with a local two-name union, following the existing `DocsToolDefinition` pattern in `EXT/src/mcp-docs-tool-definitions.ts`; the objects become assignable to `ToolDefinition` once [P2-T3] widens the union. The acceptance text is unchanged.

## Re-validation

The branch Python CLI plan validator (`scripts/dev_tools/validate_orchestration_artifacts.py`, `plan` subcommand) was run after the fixes: `plan validation passed`, exit 0, no `PLAN GATE WARNING:` line. The plan has 18 canonical tasks and 153 physical lines.
